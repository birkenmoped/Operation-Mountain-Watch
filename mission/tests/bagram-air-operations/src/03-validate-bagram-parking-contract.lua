-- Operation Mountain Watch - validate Bagram client/static/template parking contract.
local TAG = "[OMW][AirOps.BGRAM.ParkingContract]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local CLIENT_TOLERANCE_METERS = 2
local STATIC_OVERLAP_METERS = 12
local TEMPLATE_CLEARANCE_METERS = 100

local EXPECTED_CLIENT_TERMINALS = {
  CLIENT_US_BGRM_F15E_01 = 128,
  CLIENT_US_BGRM_F15E_02 = 42,
  CLIENT_US_BGRM_F16_01 = 119,
  CLIENT_US_BGRM_F16_02 = 12,
  CLIENT_US_BGRM_C130_01 = 21,
  CLIENT_US_BGRM_C130_02 = 111,
  CLIENT_US_BGRM_CH47F_01 = 88,
  CLIENT_US_BGRM_CH47F_02 = 85
}

local REQUIRED_TEMPLATES = {
  "TPL_AIR_US_BGRM_F15E_CAS_2SHIP",
  "TPL_AIR_US_BGRM_F16_CAS_2SHIP",
  "TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP",
  "TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP",
  "TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP",
  "TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP"
}

local function distance2D(a, b)
  local av = a and a:GetVec3() or nil
  local bv = b and b:GetVec3() or nil
  if not av or not bv then return nil end
  local dx = (av.x or 0) - (bv.x or 0)
  local dz = (av.z or 0) - (bv.z or 0)
  return math.sqrt(dx * dx + dz * dz)
end

local function nearestSpot(coordinate, spots)
  local nearest, nearestDistance = nil, nil
  for _, spot in ipairs(spots or {}) do
    local d = distance2D(coordinate, spot.Coordinate)
    if d and (not nearestDistance or d < nearestDistance) then
      nearest, nearestDistance = spot, d
    end
  end
  return nearest, nearestDistance
end

local function fail(cfg, reason)
  cfg.ParkingContractOK = false
  cfg.ParkingContractFailure = reason
  log("RESULT: FAIL reason=" .. tostring(reason) .. " AIRWING_START_BLOCKED=true")
end

local function main()
  local cfg = OMW and OMW.AirOps and OMW.AirOps.Bagram
  if not cfg or not cfg.Airbase or not cfg.Airwing then
    log("WAITING: Bagram AIRWING/AIRBASE unavailable.")
    return
  end
  if not _DATABASE or not _DATABASE.GetGroupTemplate then
    fail(cfg, "DATABASE:GetGroupTemplate unavailable")
    return
  end
  if not cfg.Airbase.SetParkingSpotBlacklist then
    fail(cfg, "AIRBASE:SetParkingSpotBlacklist unavailable")
    return
  end

  local spots = cfg.Airbase:GetParkingSpotsTable() or {}
  local blacklist, seen = {}, {}
  local violations = 0

  for groupName, expectedTerminalID in pairs(EXPECTED_CLIENT_TERMINALS) do
    local template = _DATABASE:GetGroupTemplate(groupName)
    local unit = template and template.units and template.units[1] or nil
    if not unit or not unit.x or not unit.y then
      log("ERROR CLIENT_MISSING group=" .. groupName)
      violations = violations + 1
    else
      local coordinate = COORDINATE:New(unit.x, land.getHeight({ x = unit.x, y = unit.y }), unit.y)
      local spot, d = nearestSpot(coordinate, spots)
      if not spot or spot.TerminalID ~= expectedTerminalID or not d or d > CLIENT_TOLERANCE_METERS then
        log(string.format("ERROR CLIENT_TERMINAL_MISMATCH group=%s expected=%s actual=%s distance=%s", groupName, tostring(expectedTerminalID), spot and tostring(spot.TerminalID) or "nil", d and string.format("%.2f", d) or "nil"))
        violations = violations + 1
      else
        if not seen[expectedTerminalID] then blacklist[#blacklist + 1] = expectedTerminalID; seen[expectedTerminalID] = true end
        log(string.format("OK CLIENT_RESERVED group=%s TerminalID=%d distance=%.2fm", groupName, expectedTerminalID, d))
      end
    end
  end

  for _, templateName in ipairs(REQUIRED_TEMPLATES) do
    local template = _DATABASE:GetGroupTemplate(templateName)
    if not template or not template.units then
      log("ERROR TEMPLATE_MISSING name=" .. templateName)
      violations = violations + 1
    else
      for index, unit in ipairs(template.units) do
        local coordinate = COORDINATE:New(unit.x, land.getHeight({ x = unit.x, y = unit.y }), unit.y)
        local spot, d = nearestSpot(coordinate, spots)
        if d and d < TEMPLATE_CLEARANCE_METERS then
          log(string.format("ERROR TEMPLATE_ON_PARKING name=%s unit=%d nearestTerminalID=%s distance=%.1fm", templateName, index, spot and tostring(spot.TerminalID) or "nil", d))
          violations = violations + 1
        else
          log(string.format("OK TEMPLATE_OFF_PARKING name=%s unit=%d nearestTerminalID=%s distance=%s", templateName, index, spot and tostring(spot.TerminalID) or "nil", d and string.format("%.1fm", d) or "unknown"))
        end
      end
    end
  end

  if SET_STATIC then
    local statics = SET_STATIC:New():FilterPrefixes("STATIC_AIR_US_BGRM_"):FilterOnce()
    statics:ForEachStatic(function(static)
      local spot, d = nearestSpot(static:GetCoordinate(), spots)
      if spot and d and d < STATIC_OVERLAP_METERS then
        if not seen[spot.TerminalID] then blacklist[#blacklist + 1] = spot.TerminalID; seen[spot.TerminalID] = true end
        log(string.format("RESERVE STATIC_OVERLAP name=%s TerminalID=%s distance=%.1fm", static:GetName(), tostring(spot.TerminalID), d))
      end
    end)
  else
    fail(cfg, "SET_STATIC unavailable")
    return
  end

  table.sort(blacklist)
  if violations > 0 then
    fail(cfg, "parking contract violations=" .. tostring(violations))
    return
  end

  cfg.Airbase:SetParkingSpotBlacklist(blacklist)
  cfg.Airwing:SetSafeParkingOn()
  cfg.ParkingBlacklist = blacklist
  cfg.ParkingContractOK = true
  cfg.ParkingContractFailure = nil
  log(string.format("RESULT: PASS clients=8 blacklistCount=%d terminalIDs=%s AIRWING_START_BLOCKED=false", #blacklist, table.concat(blacklist, ",")))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 10)
else
  timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 10)
end
