-- Operation Mountain Watch - Phase 1 runtime parking-pool enforcement
-- Loaded after the pinned-MOOSE compatibility layer so it can reject Client births
-- before the generic provisional-birth observer sees them.
local TAG = "[OMW][AirOps.JBAD.PH1.PARKING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local handler = ph1 and ph1.EventHandler
if not cfg or not ph1 or not handler then
  log("ERROR: Phase 1 runtime components are unavailable.")
else
  local function groupName(eventData)
    if eventData.IniGroupName then return eventData.IniGroupName end
    if eventData.IniGroup and eventData.IniGroup.GetName then
      local ok, value = pcall(function() return eventData.IniGroup:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function typeName(eventData)
    if eventData.IniTypeName then return eventData.IniTypeName end
    if eventData.IniUnit and eventData.IniUnit.GetTypeName then
      local ok, value = pcall(function() return eventData.IniUnit:GetTypeName() end)
      if ok then return value end
    end
    return nil
  end

  local function coordinate(eventData)
    if eventData.IniUnit and eventData.IniUnit.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniUnit:GetCoordinate() end)
      if ok then return value end
    end
    if eventData.IniGroup and eventData.IniGroup.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniGroup:GetCoordinate() end)
      if ok then return value end
    end
    return nil
  end

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx = (a.x or 0) - (b.x or 0)
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function isClientOrAuthoring(name)
    if not name then return false end
    if string.sub(name, 1, 15) == "CLIENT_US_JBAD_" or
       string.sub(name, 1, 16) == "TPL_AIR_US_JBAD_" or
       string.find(name, "_CLIENT_", 1, true) or
       string.find(name, "CLIENT", 1, true) then
      return true
    end
    local entry = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[name] or nil
    for _, unit in ipairs(entry and entry.Template and entry.Template.units or {}) do
      local skill = string.lower(tostring(unit.skill or ""))
      if skill == "client" or skill == "player" then return true end
    end
    return false
  end

  local function nearestParking(point)
    local nearestId, nearestDistance
    for _, spot in ipairs((cfg.Airbase and cfg.Airbase:GetParkingSpotsTable()) or {}) do
      local distance = distance2D(point, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then
        nearestId = spot.TerminalID
        nearestDistance = distance
      end
    end
    return nearestId, nearestDistance
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local previousBirth = handler.OnEventBirth
  function handler:OnEventBirth(eventData)
    local name = groupName(eventData)
    if isClientOrAuthoring(name) then
      log("IGNORED_AUTHORING_OR_CLIENT_BIRTH group=" .. tostring(name))
      return
    end

    previousBirth(self, eventData)
    if not ph1.ActiveMission or not ph1.Runtime or not ph1.ActiveDefinition then return end
    if typeName(eventData) ~= ph1.ActiveDefinition.ExpectedType then return end
    if not name or not ph1.Runtime.ExpectedGroupNames or not ph1.Runtime.ExpectedGroupNames[name] then return end

    local terminalId, parkingDistance = nearestParking(coordinate(eventData))
    local poolKey = ph1.ActiveDefinition.ParkingPoolKey or ph1.ActiveDefinition.SquadronKey
    local allowed = cfg.ParkingPoolTerminalIDs and cfg.ParkingPoolTerminalIDs[poolKey] or nil
    if not terminalId or not parkingDistance or parkingDistance > ph1.Limits.ParkingBirthMatchMeters or not allowed or not allowed[terminalId] then
      increment("parkingViolations")
      ph1.Runtime.HardFailure = "spawn-outside-squadron-pool-" .. tostring(terminalId)
      log(string.format("ERROR SPAWN_OUTSIDE_SQUADRON_POOL testId=%s group=%s squadron=%s TerminalID=%s distance=%s", tostring(ph1.ActiveTestId), tostring(name), tostring(poolKey), tostring(terminalId), parkingDistance and string.format("%.1fm", parkingDistance) or "unknown"))
      return
    end

    log(string.format("SPAWN_POOL_CONFIRMED testId=%s group=%s squadron=%s label=%s TerminalID=%s distance=%.1fm", tostring(ph1.ActiveTestId), tostring(name), tostring(poolKey), tostring(cfg:GetSquadronParkingLabel(poolKey, terminalId)), tostring(terminalId), parkingDistance))
  end

  log("READY clientBirthFilter=true exclusiveSquadronPoolEnforcement=true")
end
