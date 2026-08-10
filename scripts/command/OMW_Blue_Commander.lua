-- Operation Mountain Watch - BLUE COMMANDER foundation.
--
-- Scope: register the productive BLUE AIRWING foundations exposed on main and
-- start one central MOOSE COMMANDER. This file does not create AUFTRAG or
-- OPSTRANSPORT instances and does not mutate CampaignState.

OMW = OMW or {}
OMW.Command = OMW.Command or {}

local TAG = "[OMW][Command.Blue.Foundation]"
local MOOSE_COMMIT = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
local MOOSE_SHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915"

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local registry = {
  { id = "BAGRAM_USAF", base = "Bagram", slot = "USAF" },
  { id = "BAGRAM_ARMY", base = "Bagram", slot = "Army" },
  { id = "JALALABAD", base = "Jalalabad" },
  { id = "KANDAHAR_MAIN", base = "Kandahar", slot = "Main" },
  { id = "KANDAHAR_HELIPORT", base = "Kandahar", slot = "Heliport" },
  { id = "SALERNO", base = "Salerno" },
  { id = "SHINDAND", base = "Shindand" },
  { id = "TARINKOT", base = "Tarinkot" },
}

local function resolveAirwing(entry)
  local airOps = OMW and OMW.AirOps or nil
  local foundation = airOps and airOps[entry.base] or nil
  if not foundation then
    return nil, "foundation_missing"
  end
  if foundation.Status ~= "RUNNING" then
    return nil, "foundation_not_running:" .. tostring(foundation.Status)
  end

  local airwing = nil
  if entry.slot then
    airwing = foundation.Airwings and foundation.Airwings[entry.slot] or nil
  else
    airwing = foundation.Airwing
  end
  if not airwing then
    return nil, "airwing_export_missing"
  end

  if airwing.GetState then
    local state = airwing:GetState()
    if state ~= "Running" then
      return nil, "airwing_not_running:" .. tostring(state)
    end
  end

  return airwing, nil
end

local function constructFoundation()
  log("BEGIN BLUE COMMANDER foundation initialization")
  log("MOOSE commit=" .. MOOSE_COMMIT .. " sha256=" .. MOOSE_SHA256)

  if not COMMANDER or not coalition or not coalition.side or not coalition.side.BLUE then
    error("Required MOOSE COMMANDER or BLUE coalition constant is unavailable")
  end

  local commander = COMMANDER:New(coalition.side.BLUE, "OMW BLUE Commander")
  if not commander then
    error("COMMANDER:New returned nil")
  end

  local registrations = {}
  local registered = 0
  local skipped = 0

  for _, entry in ipairs(registry) do
    local airwing, reason = resolveAirwing(entry)
    if airwing then
      commander:AddAirwing(airwing)
      registered = registered + 1
      registrations[#registrations + 1] = { id = entry.id, registered = true }
      log("AIRWING_REGISTERED id=" .. entry.id)
    else
      skipped = skipped + 1
      registrations[#registrations + 1] = { id = entry.id, registered = false, reason = reason }
      log("AIRWING_SKIPPED id=" .. entry.id .. " reason=" .. tostring(reason))
    end
  end

  if registered == 0 then
    error("No productive BLUE AIRWING foundation is available for registration")
  end

  OMW.Command.Blue = {
    Status = "FOUNDATION_READY",
    Commander = commander,
    ExpectedAirwings = #registry,
    RegisteredAirwings = registered,
    SkippedAirwings = skipped,
    Registrations = registrations,
    GeneratedMissions = 0,
    GeneratedTransports = 0,
    CampaignStateMutation = false,
    Scope = "BLUE_COMMANDER_FOUNDATION_ONLY",
  }

  commander:Start()
  OMW.Command.Blue.Status = "RUNNING"

  local commanderState = commander.GetState and commander:GetState() or "UNKNOWN"
  log(string.format(
    "RESULT status=%s commanderState=%s expectedAirwings=%d registeredAirwings=%d skippedAirwings=%d generatedMissions=0 generatedTransports=0 campaignStateMutation=false",
    tostring(OMW.Command.Blue.Status),
    tostring(commanderState),
    #registry,
    registered,
    skipped
  ))
end

local ok, err = pcall(constructFoundation)
if not ok then
  env.error(TAG .. " ERROR " .. tostring(err), false)
  OMW.Command.Blue = OMW.Command.Blue or {}
  OMW.Command.Blue.Status = "ERROR"
  OMW.Command.Blue.Error = tostring(err)
end
