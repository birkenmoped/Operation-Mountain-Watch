-- Operation Mountain Watch - combined STORAGE special-case topology test.
--
-- Purpose:
--   * Kandahar vs Kandahar Heliport warehouse independence/aliasing
--   * Shindand vs Shindand Heliport warehouse independence/aliasing
--   * FOB Salerno vs Khost warehouse separation
--
-- Uses public MOOSE AIRBASE/STORAGE methods already source-reviewed for OMW.
-- CampaignState is not mutated. A temporary 37 kg JETFUEL perturbation is
-- used when needed and the original value is restored immediately.

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

  return {
    name = name,
    airbase = airbase,
    storage = byName,
  }
end

local function readLiquids(endpoint)
  local values = {}
  for _, liquid in ipairs(liquidTypes) do
    values[liquid.name] = endpoint.storage:GetLiquidAmount(liquid.value)
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
  local target = sourceBefore.JETFUEL + PROBE_DELTA_KG
  source.storage:SetLiquid(STORAGE.Liquid.JETFUEL, target)

  local sourceDuring = readLiquids(source)
  local observerDuring = readLiquids(observer)

  if sourceDuring.JETFUEL ~= target then
    log(string.format(
      "PROBE_NOT_WRITABLE source=%s expected=%s actual=%s",
      source.name,
      tostring(target),
      tostring(sourceDuring.JETFUEL)
    ))
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
  log(string.format(
    "IDENTITY id=%s storageWrapperSame=%s",
    definition.id,
    tostring(wrapperSame)
  ))

  local classification = nil
  local firstReason = nil
  local secondReason = nil

  if wrapperSame then
    classification = "SHARED_IDENTITY"
  else
    classification, firstReason = probeDirection(a, b, aBefore, bBefore)
    if not classification then
      classification, secondReason = probeDirection(b, a, bBefore, aBefore)
    end
  end

  if not classification then
    classification = "INCONCLUSIVE"
  end

  log(string.format(
    "PAIR_RESULT id=%s a=%s b=%s classification=%s firstProbe=%s secondProbe=%s",
    definition.id,
    a.name,
    b.name,
    classification,
    tostring(firstReason or "none"),
    tostring(secondReason or "none")
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
