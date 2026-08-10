-- Operation Mountain Watch - combined STORAGE special-case topology test.
--
-- Purpose:
--   * Kandahar vs Kandahar Heliport warehouse independence/aliasing
--   * Shindand vs Shindand Heliport warehouse independence/aliasing
--   * FOB Salerno vs Khost warehouse separation
--
-- Uses public MOOSE AIRBASE/STORAGE methods only. CampaignState is not mutated.
-- A temporary 37 kg JETFUEL perturbation is used only when a pair does not
-- already resolve to the same STORAGE/DCS warehouse identity. The original
-- value is restored immediately and both sides are verified afterwards.

local TEST_ID = "CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1"
local TAG = "[OMW][TEST][StorageSpecialCases]"
local PROBE_DELTA_KG = 37

local pairsToTest = {
  {
    id = "KANDAHAR_MAIN_VS_HELIPORT",
    a = "Kandahar",
    b = "Kandahar Heliport",
  },
  {
    id = "SHINDAND_MAIN_VS_HELIPORT",
    a = "Shindand",
    b = "Shindand Heliport",
  },
  {
    id = "SALERNO_VS_KHOST",
    a = "FOB Salerno",
    b = "Khost",
  },
}

local liquidTypes = {
  { name = "JETFUEL", value = STORAGE.Liquid.JETFUEL },
  { name = "GASOLINE", value = STORAGE.Liquid.GASOLINE },
  { name = "MW50", value = STORAGE.Liquid.MW50 },
  { name = "DIESEL", value = STORAGE.Liquid.DIESEL },
}

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function resolve(name)
  local airbase = AIRBASE and AIRBASE:FindByName(name) or nil
  if not airbase then
    fail("AIRBASE_NOT_FOUND name=" .. tostring(name))
  end

  local byAirbase = airbase.GetStorage and airbase:GetStorage() or nil
  local byName = STORAGE and STORAGE:FindByName(name) or nil
  if not byAirbase then
    fail("AIRBASE_STORAGE_NOT_FOUND name=" .. tostring(name))
  end
  if not byName then
    fail("STORAGE_FIND_BY_NAME_FAILED name=" .. tostring(name))
  end
  if byAirbase ~= byName then
    fail("STORAGE_RESOLUTION_MISMATCH name=" .. tostring(name))
  end

  local dcsWarehouse = airbase.GetWarehouse and airbase:GetWarehouse() or nil
  if not dcsWarehouse then
    fail("DCS_WAREHOUSE_NOT_FOUND name=" .. tostring(name))
  end

  return {
    name = name,
    airbase = airbase,
    storage = byName,
    dcsWarehouse = dcsWarehouse,
  }
end

local function readLiquids(endpoint)
  local values = {}
  for _, liquid in ipairs(liquidTypes) do
    local amount = endpoint.storage:GetLiquidAmount(liquid.value)
    values[liquid.name] = amount
  end
  return values
end

local function logEndpoint(endpoint, values)
  log(string.format(
    "ENDPOINT name=%s airbaseId=%s jetfuelKg=%s gasolineKg=%s mw50Kg=%s dieselKg=%s",
    tostring(endpoint.name),
    tostring(endpoint.airbase:GetID()),
    tostring(values.JETFUEL),
    tostring(values.GASOLINE),
    tostring(values.MW50),
    tostring(values.DIESEL)
  ))
end

local function liquidsUnlimited(endpoint)
  if type(endpoint.storage.IsUnlimitedLiquids) ~= "function" then
    return nil
  end
  local ok, result = pcall(function()
    return endpoint.storage:IsUnlimitedLiquids()
  end)
  if not ok then
    return nil
  end
  return result == true
end

local function restoreAndVerify(source, observer, sourceBefore, observerBefore)
  source.storage:SetLiquid(STORAGE.Liquid.JETFUEL, sourceBefore.JETFUEL)

  local sourceAfter = readLiquids(source)
  local observerAfter = readLiquids(observer)

  if sourceAfter.JETFUEL ~= sourceBefore.JETFUEL then
    fail(string.format(
      "RESTORE_FAILED source=%s expected=%s actual=%s",
      source.name,
      tostring(sourceBefore.JETFUEL),
      tostring(sourceAfter.JETFUEL)
    ))
  end

  if observerAfter.JETFUEL ~= observerBefore.JETFUEL then
    fail(string.format(
      "OBSERVER_RESTORE_FAILED observer=%s expected=%s actual=%s",
      observer.name,
      tostring(observerBefore.JETFUEL),
      tostring(observerAfter.JETFUEL)
    ))
  end

  log(string.format("RESTORE_PASS source=%s observer=%s", source.name, observer.name))
end

local function probeDirection(source, observer, sourceBefore, observerBefore)
  local sourceUnlimited = liquidsUnlimited(source)
  if sourceUnlimited == true then
    return nil, "SOURCE_UNLIMITED"
  elseif sourceUnlimited == nil then
    return nil, "UNLIMITED_STATE_UNKNOWN"
  end

  local target = sourceBefore.JETFUEL + PROBE_DELTA_KG
  source.storage:SetLiquid(STORAGE.Liquid.JETFUEL, target)

  local sourceDuring = readLiquids(source)
  local observerDuring = readLiquids(observer)

  if sourceDuring.JETFUEL ~= target then
    restoreAndVerify(source, observer, sourceBefore, observerBefore)
    return nil, "SOURCE_NOT_WRITABLE"
  end

  local observerChanged = observerDuring.JETFUEL ~= observerBefore.JETFUEL
  local classification = observerChanged and "SHARED_BEHAVIOR" or "INDEPENDENT_BEHAVIOR"

  log(string.format(
    "PERTURB source=%s observer=%s deltaKg=%d sourceBefore=%s sourceDuring=%s observerBefore=%s observerDuring=%s classification=%s",
    source.name,
    observer.name,
    PROBE_DELTA_KG,
    tostring(sourceBefore.JETFUEL),
    tostring(sourceDuring.JETFUEL),
    tostring(observerBefore.JETFUEL),
    tostring(observerDuring.JETFUEL),
    classification
  ))

  restoreAndVerify(source, observer, sourceBefore, observerBefore)
  return classification, nil
end

local function classifyPair(definition)
  local a = resolve(definition.a)
  local b = resolve(definition.b)
  local aBefore = readLiquids(a)
  local bBefore = readLiquids(b)

  log("PAIR_BEGIN id=" .. definition.id .. " a=" .. a.name .. " b=" .. b.name)
  logEndpoint(a, aBefore)
  logEndpoint(b, bBefore)

  local wrapperSame = a.storage == b.storage
  local dcsWarehouseSame = a.dcsWarehouse == b.dcsWarehouse
  log(string.format(
    "IDENTITY id=%s storageWrapperSame=%s dcsWarehouseSame=%s",
    definition.id,
    tostring(wrapperSame),
    tostring(dcsWarehouseSame)
  ))

  local classification = nil
  local probeReason = nil

  if wrapperSame or dcsWarehouseSame then
    classification = "SHARED_IDENTITY"
  else
    classification, probeReason = probeDirection(a, b, aBefore, bBefore)
    if not classification then
      classification, probeReason = probeDirection(b, a, bBefore, aBefore)
    end
  end

  if not classification then
    classification = "INCONCLUSIVE"
  end

  log(string.format(
    "PAIR_RESULT id=%s a=%s b=%s classification=%s probeReason=%s",
    definition.id,
    a.name,
    b.name,
    classification,
    tostring(probeReason or "none")
  ))

  return {
    id = definition.id,
    classification = classification,
  }
end

local function run()
  log("BEGIN testId=" .. TEST_ID .. " pairCount=" .. tostring(#pairsToTest))

  if not AIRBASE or not STORAGE or not STORAGE.Liquid then
    fail("Required MOOSE AIRBASE/STORAGE classes are unavailable")
  end
  if type(STORAGE.FindByName) ~= "function" then
    fail("Required MOOSE STORAGE:FindByName is unavailable")
  end

  local results = {}
  local inconclusive = 0
  for _, definition in ipairs(pairsToTest) do
    local result = classifyPair(definition)
    results[#results + 1] = result
    if result.classification == "INCONCLUSIVE" then
      inconclusive = inconclusive + 1
    end
  end

  local status = inconclusive == 0 and "PASS" or "INCONCLUSIVE"
  log(string.format(
    "RESULT testId=%s status=%s pairs=%d inconclusive=%d campaignStateMutation=false reverseOverwrite=false persistentMutation=false",
    TEST_ID,
    status,
    #results,
    inconclusive
  ))
end

local ok, err = pcall(run)
if not ok then
  log("RESULT testId=" .. TEST_ID .. " status=FAIL error=" .. tostring(err))
end
