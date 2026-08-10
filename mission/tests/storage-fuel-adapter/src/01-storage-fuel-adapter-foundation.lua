-- Operation Mountain Watch - STORAGE fuel adapter foundation test harness.
--
-- The builder injects the local OMWStorageFuelAdapter module before this harness.
-- Scope: controlled read/write/readback/idempotency/restore check only.

local TAG = "[OMW][Test.StorageFuelAdapter]"
local TEST_ID = "STORAGE-FUEL-ADAPTER-FOUNDATION-1"
local NODE_ID = "HUB_KANDAHAR"
local AIRBASE_NAME = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Kandahar or "Kandahar"
local UNLIMITED_SENTINEL_THRESHOLD = 2 ^ 29

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireEqual(actual, expected, label)
  if actual ~= expected then
    fail(string.format("ASSERT_FAIL label=%s expected=%s actual=%s", tostring(label), tostring(expected), tostring(actual)))
  end
end

local function run()
  if type(OMWStorageFuelAdapter) ~= "table" then
    fail("Adapter module was not injected by the builder")
  end

  local resourceId = OMWStorageFuelAdapter.ResourceId
  if not resourceId then
    fail("Adapter resource IDs are unavailable")
  end

  log("BEGIN testId=" .. TEST_ID .. " nodeId=" .. NODE_ID .. " airbaseName=" .. AIRBASE_NAME)

  local original = OMWStorageFuelAdapter.ReadNode(NODE_ID, AIRBASE_NAME)
  local originalJP8 = original.resourcesKg[resourceId.JP8]
  local originalAVGAS = original.resourcesKg[resourceId.AVGAS]

  log(string.format("ORIGINAL jp8Kg=%s avgasKg=%s", tostring(originalJP8), tostring(originalAVGAS)))

  if originalJP8 > UNLIMITED_SENTINEL_THRESHOLD or originalAVGAS > UNLIMITED_SENTINEL_THRESHOLD then
    fail(string.format(
      "LIQUID_STORAGE_APPEARS_UNLIMITED jp8Kg=%s avgasKg=%s threshold=%s",
      tostring(originalJP8),
      tostring(originalAVGAS),
      tostring(UNLIMITED_SENTINEL_THRESHOLD)
    ))
  end

  local desired = {
    nodeId = NODE_ID,
    airbaseName = AIRBASE_NAME,
    resourcesKg = {
      [resourceId.JP8] = originalJP8 + 1000,
      [resourceId.AVGAS] = originalAVGAS + 500,
    },
  }

  local testOk, testErr = pcall(function()
    local plan = OMWStorageFuelAdapter.PlanSnapshot(desired)
    requireEqual(plan.changeCount, 2, "initial plan changeCount")
    log("PLAN_PASS changes=" .. tostring(plan.changeCount))

    local applied = OMWStorageFuelAdapter.ApplySnapshot(desired)
    requireEqual(applied.verified, true, "initial apply verified")
    requireEqual(applied.readbackKg[resourceId.JP8], desired.resourcesKg[resourceId.JP8], "JP8 readback")
    requireEqual(applied.readbackKg[resourceId.AVGAS], desired.resourcesKg[resourceId.AVGAS], "AVGAS readback")
    log("WRITE_READBACK_PASS")

    local idempotentPlan = OMWStorageFuelAdapter.PlanSnapshot(desired)
    requireEqual(idempotentPlan.changeCount, 0, "idempotent plan changeCount")

    local idempotentApply = OMWStorageFuelAdapter.ApplySnapshot(desired)
    requireEqual(idempotentApply.verified, true, "idempotent apply verified")
    requireEqual(idempotentApply.plan.changeCount, 0, "idempotent apply changeCount")
    log("IDEMPOTENCY_PASS")
  end)

  local restore = {
    nodeId = NODE_ID,
    airbaseName = AIRBASE_NAME,
    resourcesKg = {
      [resourceId.JP8] = originalJP8,
      [resourceId.AVGAS] = originalAVGAS,
    },
  }

  local restoreOk, restoreErr = pcall(function()
    local restored = OMWStorageFuelAdapter.ApplySnapshot(restore)
    requireEqual(restored.verified, true, "restore verified")

    local final = OMWStorageFuelAdapter.ReadNode(NODE_ID, AIRBASE_NAME)
    requireEqual(final.resourcesKg[resourceId.JP8], originalJP8, "restored JP8")
    requireEqual(final.resourcesKg[resourceId.AVGAS], originalAVGAS, "restored AVGAS")
  end)

  if not restoreOk then
    fail("RESTORE_FAIL error=" .. tostring(restoreErr) .. " testError=" .. tostring(testErr))
  end

  log("RESTORE_PASS")

  if not testOk then
    fail("TEST_FAIL_AFTER_RESTORE error=" .. tostring(testErr))
  end

  log(string.format(
    "RESULT testId=%s status=PASS nodeId=%s airbaseName=%s jp8Separated=true avgasSeparated=true canonicalUnit=kg automaticAircraftDebit=false persistence=false campaignStateMutation=false",
    TEST_ID,
    NODE_ID,
    AIRBASE_NAME
  ))
end

local ok, err = pcall(run)
if not ok then
  env.error(TAG .. " RESULT testId=" .. TEST_ID .. " status=FAIL error=" .. tostring(err), false)
end
