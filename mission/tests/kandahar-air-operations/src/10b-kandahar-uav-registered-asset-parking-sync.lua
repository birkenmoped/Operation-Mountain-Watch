-- Operation Mountain Watch - Kandahar UAV registered-asset parking synchronization.
--
-- MOOSE copies SQUADRON.parkingIDs into each warehouse asset when the asset is
-- registered by LEGION:onafterNewAsset. The Kandahar UAV pool is filtered only
-- after registration because static and client exclusions are runtime-derived.
-- Therefore the accepted filtered IDs must be synchronized to the already
-- registered asset records before the AIRWING is started.
--
-- This file does not start an AIRWING, spawn an asset, create a mission or
-- transport, mutate payloads, or issue taxi/takeoff commands.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVAssetParkingSync]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local EXPECTED = {
  MQ1 = {
    Squadron = "SQ_US_KAF_MQ1_361_ERS",
    AssetGroups = 4
  },
  MQ9 = {
    Squadron = "SQ_US_KAF_MQ9_361_ERS",
    AssetGroups = 2
  }
}

local violations = 0

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function copyNumericList(values)
  local copy = {}
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then copy[#copy + 1] = number end
  end
  table.sort(copy)
  return copy
end

local function toNumericSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then result[number] = true end
  end
  return result
end

local function sameNumericSet(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" then return false end
  local a = toNumericSet(actual)
  local e = toNumericSet(expected)
  for value in pairs(a) do if not e[value] then return false end end
  for value in pairs(e) do if not a[value] then return false end end
  return true
end

local function join(values)
  if not values or #values == 0 then return "none" end
  local text = {}
  for _, value in ipairs(values) do text[#text + 1] = tostring(value) end
  return table.concat(text, ",")
end

local function syncPool(key, definition, registration, contract)
  local pool = contract[key]
  local squadron = registration.Squadrons and registration.Squadrons[definition.Squadron] or nil
  if not pool or not squadron then
    fail(string.format(
      "POOL_RUNTIME_OBJECT_MISSING pool=%s squadron=%s poolPresent=%s squadronPresent=%s",
      key,
      definition.Squadron,
      tostring(pool ~= nil),
      tostring(squadron ~= nil)
    ))
    return 0
  end

  local availableIDs = copyNumericList(pool.AvailableIDs)
  if #availableIDs == 0 then
    fail("POOL_AVAILABLE_IDS_EMPTY pool=" .. key)
    return 0
  end

  if not sameNumericSet(squadron.parkingIDs, availableIDs) then
    fail(string.format(
      "SQUADRON_PARKING_IDS_NOT_APPLIED pool=%s expected=%s",
      key,
      join(availableIDs)
    ))
  end

  local assetCount = 0
  for _, asset in pairs(squadron.assets or {}) do
    assetCount = assetCount + 1
    asset.parkingIDs = copyNumericList(availableIDs)

    if not sameNumericSet(asset.parkingIDs, availableIDs) then
      fail(string.format(
        "ASSET_PARKING_IDS_MISMATCH pool=%s asset=%s expected=%s",
        key,
        tostring(asset.spawngroupname or asset.uid),
        join(availableIDs)
      ))
    end

    log(string.format(
      "ASSET_SYNCED pool=%s squadron=%s asset=%s terminalIDs=%s",
      key,
      definition.Squadron,
      tostring(asset.spawngroupname or asset.uid),
      join(asset.parkingIDs)
    ))
  end

  if assetCount ~= tonumber(definition.AssetGroups) then
    fail(string.format(
      "ASSET_GROUP_COUNT_MISMATCH pool=%s expected=%d actual=%d",
      key,
      tonumber(definition.AssetGroups),
      assetCount
    ))
  end

  log(string.format(
    "POOL_SYNCED pool=%s squadron=%s assets=%d terminalIDs=%s",
    key,
    definition.Squadron,
    assetCount,
    join(availableIDs)
  ))

  return assetCount
end

local function main()
  log("BEGIN registeredAssetParkingSync=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true")

  if OMW.AirOps.KandaharUAVAssetParkingSync then
    log("RESULT: FAIL reason=UAV_ASSET_PARKING_SYNC_ALREADY_EXECUTED noStart=true noSpawn=true")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  local contract = OMW.AirOps.KandaharUAVParkingContract
  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_PREFLIGHT_NOT_PASSED noStart=true noSpawn=true")
    return
  end
  if not contract or contract.Applied ~= true or tonumber(contract.Violations) ~= 0 then
    log("RESULT: FAIL reason=UAV_PARKING_CONTRACT_NOT_PASSED noStart=true noSpawn=true")
    return
  end

  local mainAirwing = registration.Airwings and registration.Airwings.Main or nil
  if not mainAirwing then
    log("RESULT: FAIL reason=MAIN_AIRWING_MISSING noStart=true noSpawn=true")
    return
  end

  if mainAirwing.IsRunning then
    local ok, running = pcall(function() return mainAirwing:IsRunning() end)
    if ok and running == true then
      log("RESULT: FAIL reason=MAIN_AIRWING_ALREADY_RUNNING noStart=true noSpawn=true")
      return
    end
  end

  local mq1Assets = syncPool("MQ1", EXPECTED.MQ1, registration, contract)
  local mq9Assets = syncPool("MQ9", EXPECTED.MQ9, registration, contract)
  local applied = violations == 0

  OMW.AirOps.KandaharUAVAssetParkingSync = {
    MQ1Assets = mq1Assets,
    MQ9Assets = mq9Assets,
    Violations = violations,
    Applied = applied,
    Started = false
  }

  contract.AssetParkingSyncApplied = applied
  contract.AssetParkingSyncViolations = violations

  if applied then
    log(string.format(
      "RESULT: PASS mq1Assets=%d mq1TerminalIDs=%s mq9Assets=%d mq9TerminalIDs=%s registeredAssetsSynchronized=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      mq1Assets,
      join(contract.MQ1.AvailableIDs),
      mq9Assets,
      join(contract.MQ9.AvailableIDs)
    ))
  else
    contract.Violations = tonumber(contract.Violations or 0) + violations
    contract.Applied = false
    log(string.format(
      "RESULT: FAIL violations=%d mq1Assets=%d mq9Assets=%d registeredAssetsSynchronized=false noStart=true noSpawn=true",
      violations,
      mq1Assets,
      mq9Assets
    ))
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 28)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 28)
end
