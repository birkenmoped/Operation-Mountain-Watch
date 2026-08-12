-- Operation Mountain Watch - F-16 client rearm exchange observation.
-- MOOSE-first, read-only STORAGE observation. No CampaignState or STORAGE mutation.

local TAG = "[OMW][StorageClientRearmExchange]"
local TEST_ID = "STORAGE-CLIENT-REARM-EXCHANGE-1"
local STORAGE_NAME = "Bagram"
local CLIENT_TYPE = "F-16C_50"
local POLL_INTERVAL_S = 5
local START_DELAY_S = 10
local MAX_RUNTIME_S = 3600
local MESSAGE_DURATION_S = 12

local runtime = {
  startedAt = timer.getTime(),
  finished = false,
  storage = nil,
  clientSet = nil,
  activeClientName = nil,
  activePlayerName = nil,
  lastWeapons = nil,
  lastAmmo = nil,
  snapshots = 0,
  storageChanges = 0,
  ammoChanges = 0,
  weaponRearmEvents = 0,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function notify(message)
  MESSAGE:New(tostring(message), MESSAGE_DURATION_S, "OMW Rearm"):ToAll()
end

local function copyNumericMap(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "number" then
      result[tostring(key)] = value
    end
  end
  return result
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map or {}) do
    keys[#keys + 1] = tostring(key)
  end
  table.sort(keys)
  return keys
end

local function readStorageWeapons()
  local aircraft, liquids, weapons = runtime.storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error("STORAGE:GetInventory() returned an invalid inventory tuple")
  end
  return copyNumericMap(weapons)
end

local function readAmmo(client)
  local result = {}
  local ammo = client:GetAmmo()
  for _, item in ipairs(ammo or {}) do
    local descriptor = item and item.desc or nil
    local typeName = descriptor and descriptor.typeName or nil
    local count = item and item.count or nil
    if type(typeName) == "string" and type(count) == "number" then
      result[typeName] = (result[typeName] or 0) + count
    end
  end
  return result
end

local function mapsEqual(a, b)
  for key, value in pairs(a or {}) do
    if (b and b[key] or 0) ~= value then
      return false
    end
  end
  for key, value in pairs(b or {}) do
    if (a and a[key] or 0) ~= value then
      return false
    end
  end
  return true
end

local function logMapDelta(family, before, after, reason)
  local seen = {}
  for key in pairs(before or {}) do seen[key] = true end
  for key in pairs(after or {}) do seen[key] = true end
  local changes = 0
  for _, key in ipairs(sortedKeys(seen)) do
    local oldValue = tonumber(before and before[key]) or 0
    local newValue = tonumber(after and after[key]) or 0
    if oldValue ~= newValue then
      changes = changes + 1
      log(string.format(
        "DELTA family=%s reason=%s item=%s before=%.3f after=%.3f delta=%.3f",
        tostring(family), tostring(reason), tostring(key), oldValue, newValue, newValue - oldValue
      ))
    end
  end
  return changes
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

local function logSnapshot(reason, client)
  local weapons = readStorageWeapons()
  local ammo = client and readAmmo(client) or {}
  runtime.snapshots = runtime.snapshots + 1

  if runtime.lastWeapons then
    local storageDelta = logMapDelta("STORAGE_WEAPON", runtime.lastWeapons, weapons, reason)
    if storageDelta > 0 then
      runtime.storageChanges = runtime.storageChanges + storageDelta
    end
  end

  if runtime.lastAmmo and client then
    local ammoDelta = logMapDelta("AIRCRAFT_AMMO", runtime.lastAmmo, ammo, reason)
    if ammoDelta > 0 then
      runtime.ammoChanges = runtime.ammoChanges + ammoDelta
    end
  end

  runtime.lastWeapons = weapons
  runtime.lastAmmo = ammo

  log(string.format(
    "SNAPSHOT reason=%s client=%s player=%s snapshots=%d storageKeys=%d ammoKeys=%d",
    tostring(reason), tostring(runtime.activeClientName), tostring(runtime.activePlayerName), runtime.snapshots,
    #sortedKeys(weapons), #sortedKeys(ammo)
  ))
end

local function bindClient(client)
  local clientName = client:GetName()
  local playerName = client:GetPlayerName() or "UNKNOWN"
  if runtime.activeClientName ~= clientName then
    runtime.activeClientName = clientName
    runtime.activePlayerName = playerName
    runtime.lastWeapons = nil
    runtime.lastAmmo = nil
    log(string.format("CLIENT_BOUND unit=%s player=%s type=%s", clientName, playerName, CLIENT_TYPE))
    notify("F-16 rearm observation active. Change loadouts through normal ground-crew rearm.")
    logSnapshot("CLIENT_BOUND", client)
  end
end

local eventHandler = EVENTHANDLER:New()
if EVENTS.WeaponRearm and EVENTS.WeaponRearm >= 0 then
  eventHandler:HandleEvent(EVENTS.WeaponRearm, function(_, eventData)
    local iniName = eventData and eventData.IniUnitName or nil
    if iniName and runtime.activeClientName and iniName == runtime.activeClientName then
      runtime.weaponRearmEvents = runtime.weaponRearmEvents + 1
      log(string.format("WEAPON_REARM_EVENT unit=%s count=%d", iniName, runtime.weaponRearmEvents))
    end
  end)
else
  log("WEAPON_REARM_EVENT_UNAVAILABLE fallback=STORAGE_AND_AMMO_POLLING")
end

local function finish(reason)
  if runtime.finished then return end
  runtime.finished = true
  log(string.format(
    "RESULT testId=%s status=OBSERVATION_COMPLETE reason=%s snapshots=%d storageChanges=%d ammoChanges=%d weaponRearmEvents=%d storageMutation=false campaignStateMutation=false",
    TEST_ID, tostring(reason), runtime.snapshots, runtime.storageChanges, runtime.ammoChanges, runtime.weaponRearmEvents
  ))
  notify("Rearm observation complete. Exit DCS and provide dcs.log/debrief.log plus the tested MIZ.")
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
    local weapons = readStorageWeapons()
    local ammo = readAmmo(client)
    if not mapsEqual(runtime.lastWeapons, weapons) or not mapsEqual(runtime.lastAmmo, ammo) then
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
    "READY testId=%s storage=%s clientType=%s pollInterval=%d maxRuntime=%d storageMutation=false campaignStateMutation=false",
    TEST_ID, STORAGE_NAME, CLIENT_TYPE, POLL_INTERVAL_S, MAX_RUNTIME_S
  ))
  notify("F-16 rearm test ready. Enter a Bagram F-16 client and rearm several times.")

  SCHEDULER:New(nil, poll, {}, 0, POLL_INTERVAL_S)
  SCHEDULER:New(nil, function() finish("SAFETY_TIMEOUT") end, {}, MAX_RUNTIME_S)
end

SCHEDULER:New(nil, start, {}, START_DELAY_S)
