-- Operation Mountain Watch - CampaignState to STORAGE sync foundation test.

local TEST_ID = "CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1"
local NODE_ID = "HUB_KANDAHAR"
local AIRBASE_NAME = "Kandahar"
local TAG = "[OMW][TEST][CampaignStateStorageSync]"

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function assertEqual(label, expected, actual)
  if expected ~= actual then
    fail(string.format("ASSERT_FAIL label=%s expected=%s actual=%s", tostring(label), tostring(expected), tostring(actual)))
  end
end

local function run()
  log("BEGIN testId=" .. TEST_ID)

  local original = OMWStorageFuelAdapter.ReadNode(NODE_ID, AIRBASE_NAME)
  local originalJp8 = original.resourcesKg.FUEL_JP8
  local originalAvgas = original.resourcesKg.FUEL_AVGAS

  log(string.format("ORIGINAL jp8Kg=%s avgasKg=%s", tostring(originalJp8), tostring(originalAvgas)))

  local campaignState = OMWCampaignState.New({
    schemaVersion = "CAMPAIGNSTATE-FUEL-FOUNDATION-1",
    nodes = {
      {
        nodeId = NODE_ID,
        airbaseName = AIRBASE_NAME,
        resourcesKg = {
          FUEL_JP8 = originalJp8 + 1000,
          FUEL_AVGAS = originalAvgas + 500,
        },
      },
    },
  })

  local sync = OMWCampaignStateStorageSync.New(campaignState, OMWStorageFuelAdapter)

  local snapshot = campaignState:GetFuelSnapshot(NODE_ID)
  assertEqual("snapshot node", NODE_ID, snapshot.nodeId)
  assertEqual("snapshot airbase", AIRBASE_NAME, snapshot.airbaseName)
  assertEqual("snapshot jp8", originalJp8 + 1000, snapshot.resourcesKg.FUEL_JP8)
  assertEqual("snapshot avgas", originalAvgas + 500, snapshot.resourcesKg.FUEL_AVGAS)
  log("CAMPAIGNSTATE_SNAPSHOT_PASS")

  local plan = sync:PlanNode(NODE_ID)
  assertEqual("initial plan changeCount", 2, plan.changeCount)
  log("SYNC_PLAN_PASS changes=2")

  local apply = sync:ApplyNode(NODE_ID)
  assertEqual("initial apply verified", true, apply.verified)
  assertEqual("jp8 readback", originalJp8 + 1000, apply.readbackKg.FUEL_JP8)
  assertEqual("avgas readback", originalAvgas + 500, apply.readbackKg.FUEL_AVGAS)
  log("SYNC_WRITE_READBACK_PASS")

  local secondPlan = sync:PlanNode(NODE_ID)
  assertEqual("second plan changeCount", 0, secondPlan.changeCount)
  local secondApply = sync:ApplyNode(NODE_ID)
  assertEqual("second apply verified", true, secondApply.verified)
  assertEqual("second apply changeCount", 0, secondApply.plan.changeCount)
  log("SYNC_IDEMPOTENCY_PASS")

  assertEqual("campaignstate jp8 unchanged", originalJp8 + 1000, campaignState:GetResourceKg(NODE_ID, "FUEL_JP8"))
  assertEqual("campaignstate avgas unchanged", originalAvgas + 500, campaignState:GetResourceKg(NODE_ID, "FUEL_AVGAS"))
  log("NO_REVERSE_MUTATION_PASS")

  local restore = OMWStorageFuelAdapter.ApplySnapshot(original)
  assertEqual("restore verified", true, restore.verified)
  log("RESTORE_PASS")

  log("RESULT testId=" .. TEST_ID .. " status=PASS direction=CampaignState-to-STORAGE campaignStateMutation=false reverseOverwrite=false persistence=false automaticAircraftDebit=false")
end

local ok, err = pcall(run)
if not ok then
  log("RESULT testId=" .. TEST_ID .. " status=FAIL error=" .. tostring(err))
end
