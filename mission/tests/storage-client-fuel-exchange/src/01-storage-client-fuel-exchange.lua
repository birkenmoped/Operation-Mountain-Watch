-- Operation Mountain Watch - F-16 client fuel exchange observation.
-- MOOSE-first, read-only STORAGE observation. No CampaignState or STORAGE mutation.

local TAG = "[OMW][StorageClientFuelExchange]"
local TEST_ID = "STORAGE-CLIENT-FUEL-EXCHANGE-1"
local STORAGE_NAME = "Bagram"
local CLIENT_TYPE = "F-16C_50"
local POLL_INTERVAL_S = 2
local START_DELAY_S = 10
local MAX_RUNTIME_S = 1800
local MESSAGE_DURATION_S = 12
local CHANGE_EPSILON_KG = 0.5

local runtime = {
  startedAt = timer.getTime(),
  finished = false,
  storage = nil,
  clientSet = nil,
  activeClientName = nil,
  activePlayerName = nil,
  lastStorageJetFuelKg = nil,
  lastAircraftFuelKg = nil,
  snapshots = 0,
  storageChanges = 0,
  aircraftFuelChanges = 0,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message)
  MESSAGE:New(tostring(message), MESSAGE_DURATION_S, "OMW Fuel Exchange"):ToAll()
end

local function findActiveClient()
  local found = nil
  runtime.clientSet:ForEachClient(function(client)
    if not found and client and client:IsAlive() then
      local playerName = client:GetPlayerName()
      if playerName and playerName ~= "" then
        found = client
      end
    end
  end)
  return found
end

local function readStorageJetFuelKg()
  local amount = runtime.storage:GetLiquidAmount(STORAGE.Liquid.JETFUEL)
  if type(amount) ~= "number" then
    error("STORAGE:GetLiquidAmount(JETFUEL) returned non-numeric value")
  end
  return amount
end

local function readAircraftFuelKg(client)
  local amount = client:GetCurrentFuelKgs()
  if type(amount) ~= "number" then
    error("UNIT:GetCurrentFuelKgs() returned non-numeric value")
  end
  return amount
end

local function changed(before, after)
  if before == nil or after == nil then
    return true
  end
  return math.abs(after - before) >= CHANGE_EPSILON_KG
end

local function logSnapshot(reason, client)
  local storageJetFuelKg = readStorageJetFuelKg()
  local aircraftFuelKg = readAircraftFuelKg(client)
  local storageDeltaKg = runtime.lastStorageJetFuelKg and (storageJetFuelKg - runtime.lastStorageJetFuelKg) or 0
  local aircraftDeltaKg = runtime.lastAircraftFuelKg and (aircraftFuelKg - runtime.lastAircraftFuelKg) or 0
  runtime.snapshots = runtime.snapshots + 1

  if runtime.lastStorageJetFuelKg and changed(runtime.lastStorageJetFuelKg, storageJetFuelKg) then
    runtime.storageChanges = runtime.storageChanges + 1
  end
  if runtime.lastAircraftFuelKg and changed(runtime.lastAircraftFuelKg, aircraftFuelKg) then
    runtime.aircraftFuelChanges = runtime.aircraftFuelChanges + 1
  end

  log(string.format(
    "SNAPSHOT reason=%s client=%s player=%s storageJetFuelKg=%.3f storageDeltaKg=%.3f aircraftFuelKg=%.3f aircraftDeltaKg=%.3f snapshots=%d",
    tostring(reason), tostring(runtime.activeClientName), tostring(runtime.activePlayerName),
    storageJetFuelKg, storageDeltaKg, aircraftFuelKg, aircraftDeltaKg, runtime.snapshots
  ))

  if runtime.lastStorageJetFuelKg and runtime.lastAircraftFuelKg and
     (changed(runtime.lastStorageJetFuelKg, storageJetFuelKg) or changed(runtime.lastAircraftFuelKg, aircraftFuelKg)) then
    log(string.format(
      "DELTA reason=%s storageJetFuelKg=%.3f aircraftFuelKg=%.3f combinedDeltaKg=%.3f",
      tostring(reason), storageDeltaKg, aircraftDeltaKg, storageDeltaKg + aircraftDeltaKg
    ))
  end

  runtime.lastStorageJetFuelKg = storageJetFuelKg
  runtime.lastAircraftFuelKg = aircraftFuelKg
end

local function bindClient(client)
  local clientName = client:GetName()
  local playerName = client:GetPlayerName() or "UNKNOWN"
  if runtime.activeClientName ~= clientName then
    runtime.activeClientName = clientName
    runtime.activePlayerName = playerName
    runtime.lastStorageJetFuelKg = nil
    runtime.lastAircraftFuelKg = nil
    log(string.format("CLIENT_BOUND unit=%s player=%s type=%s", clientName, playerName, CLIENT_TYPE))
    notify("Fuel exchange observation active. Use ground crew fuel changes only: 100 -> 50 -> 80 -> 30 -> 100 percent.")
    logSnapshot("CLIENT_BOUND", client)
  end
end

local function finish(reason)
  if runtime.finished then return end
  runtime.finished = true
  log(string.format(
    "RESULT testId=%s status=OBSERVATION_COMPLETE reason=%s snapshots=%d storageChanges=%d aircraftFuelChanges=%d storageMutation=false campaignStateMutation=false",
    TEST_ID, tostring(reason), runtime.snapshots, runtime.storageChanges, runtime.aircraftFuelChanges
  ))
  notify("Fuel exchange observation complete. Exit DCS and provide dcs.log/debrief.log plus the tested MIZ.")
end

local function poll()
  if runtime.finished then return end
  if timer.getTime() - runtime.startedAt >= MAX_RUNTIME_S then
    finish("MAX_RUNTIME")
    return
  end

  local client = findActiveClient()
  if client then
    bindClient(client)
    local storageJetFuelKg = readStorageJetFuelKg()
    local aircraftFuelKg = readAircraftFuelKg(client)
    if changed(runtime.lastStorageJetFuelKg, storageJetFuelKg) or changed(runtime.lastAircraftFuelKg, aircraftFuelKg) then
      logSnapshot("POLL_CHANGE", client)
    end
  end
end

local function start()
  local airbase = AIRBASE:FindByName(STORAGE_NAME)
  if not airbase then error("AIRBASE unresolved name=" .. STORAGE_NAME) end
  local fromAirbase = airbase:GetStorage()
  local fromRegistry = STORAGE:FindByName(STORAGE_NAME)
  if not fromAirbase or not fromRegistry then error("STORAGE unresolved name=" .. STORAGE_NAME) end
  if fromAirbase ~= fromRegistry then error("STORAGE wrapper identity mismatch name=" .. STORAGE_NAME) end
  runtime.storage = fromAirbase

  runtime.clientSet = SET_CLIENT:New():FilterCategories("plane"):FilterTypes(CLIENT_TYPE):FilterStart()
  log(string.format(
    "READY testId=%s storage=%s clientType=%s pollInterval=%d maxRuntime=%d liquid=JETFUEL storageMutation=false campaignStateMutation=false",
    TEST_ID, STORAGE_NAME, CLIENT_TYPE, POLL_INTERVAL_S, MAX_RUNTIME_S
  ))
  notify("F-16 fuel exchange test ready. Enter a Bagram F-16 client; no engine start or flight required.")

  SCHEDULER:New(nil, poll, {}, 0, POLL_INTERVAL_S)
  SCHEDULER:New(nil, function() finish("SAFETY_TIMEOUT") end, {}, MAX_RUNTIME_S)
end

SCHEDULER:New(nil, start, {}, START_DELAY_S)
