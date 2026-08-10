-- Operation Mountain Watch - combined CampaignState to STORAGE multi-node sync test.
--
-- Scope:
--   * all currently confirmed OMW AirOps fuel STORAGE nodes in one DCS run
--   * one-way CampaignState -> StorageFuelAdapter -> MOOSE STORAGE synchronization
--   * exact readback, idempotency, no reverse CampaignState mutation, restore
--
-- Test node IDs below are fixture-local identifiers. They do not establish the
-- production CampaignState node-ID schema.

local TEST_ID = "CAMPAIGNSTATE-STORAGE-MULTINODE-1"
local TAG = "[OMW][TEST][CampaignStateStorageMultiNode]"

local nodes = {
  { nodeId = "TEST_NODE_BAGRAM", airbaseName = "Bagram", jp8DeltaKg = 1010, avgasDeltaKg = 510 },
  { nodeId = "TEST_NODE_JALALABAD", airbaseName = "Jalalabad", jp8DeltaKg = 1020, avgasDeltaKg = 520 },
  { nodeId = "TEST_NODE_KANDAHAR", airbaseName = "Kandahar", jp8DeltaKg = 1030, avgasDeltaKg = 530 },
  { nodeId = "TEST_NODE_KANDAHAR_HELIPORT", airbaseName = "Kandahar Heliport", jp8DeltaKg = 1040, avgasDeltaKg = 540 },
  { nodeId = "TEST_NODE_SALERNO", airbaseName = "FOB Salerno", jp8DeltaKg = 1050, avgasDeltaKg = 550 },
  { nodeId = "TEST_NODE_TARINKOT", airbaseName = "Tarinkot", jp8DeltaKg = 1060, avgasDeltaKg = 560 },
  { nodeId = "TEST_NODE_SHINDAND_HELIPORT", airbaseName = "Shindand Heliport", jp8DeltaKg = 1070, avgasDeltaKg = 570 },
}

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function assertEqual(label, expected, actual)
  if expected ~= actual then
    error(string.format(
      "%s ASSERT_FAIL label=%s expected=%s actual=%s",
      TAG,
      tostring(label),
      tostring(expected),
      tostring(actual)
    ), 2)
  end
end

local function run()
  log("BEGIN testId=" .. TEST_ID .. " nodesExpected=" .. tostring(#nodes))

  local originalByNodeId = {}
  local desiredNodes = {}
  local preflightFailed = {}

  for _, definition in ipairs(nodes) do
    log(string.format("NODE_BEGIN node=%s airbase=%s", definition.nodeId, definition.airbaseName))
    local ok, originalOrError = pcall(function()
      return OMWStorageFuelAdapter.ReadNode(definition.nodeId, definition.airbaseName)
    end)

    if not ok then
      preflightFailed[definition.nodeId] = tostring(originalOrError)
      log(string.format(
        "NODE_FAIL node=%s airbase=%s stage=PREFLIGHT reason=%s",
        definition.nodeId,
        definition.airbaseName,
        tostring(originalOrError)
      ))
    else
      local original = originalOrError
      originalByNodeId[definition.nodeId] = original
      desiredNodes[#desiredNodes + 1] = {
        nodeId = definition.nodeId,
        airbaseName = definition.airbaseName,
        resourcesKg = {
          FUEL_JP8 = original.resourcesKg.FUEL_JP8 + definition.jp8DeltaKg,
          FUEL_AVGAS = original.resourcesKg.FUEL_AVGAS + definition.avgasDeltaKg,
        },
      }
      log(string.format(
        "NODE_PREFLIGHT_PASS node=%s airbase=%s originalJp8Kg=%s originalAvgasKg=%s",
        definition.nodeId,
        definition.airbaseName,
        tostring(original.resourcesKg.FUEL_JP8),
        tostring(original.resourcesKg.FUEL_AVGAS)
      ))
    end
  end

  local campaignState = nil
  local sync = nil
  if #desiredNodes > 0 then
    campaignState = OMWCampaignState.New({
      schemaVersion = "CAMPAIGNSTATE-FUEL-MULTINODE-TEST-1",
      nodes = desiredNodes,
    })
    sync = OMWCampaignStateStorageSync.New(campaignState, OMWStorageFuelAdapter)
  end

  local nodesPassed = 0
  local nodesFailed = 0

  for _, definition in ipairs(nodes) do
    local original = originalByNodeId[definition.nodeId]
    if not original then
      nodesFailed = nodesFailed + 1
    else
      local desiredJp8 = original.resourcesKg.FUEL_JP8 + definition.jp8DeltaKg
      local desiredAvgas = original.resourcesKg.FUEL_AVGAS + definition.avgasDeltaKg

      local nodeOk, nodeError = pcall(function()
        local snapshot = campaignState:GetFuelSnapshot(definition.nodeId)
        assertEqual("snapshot node", definition.nodeId, snapshot.nodeId)
        assertEqual("snapshot airbase", definition.airbaseName, snapshot.airbaseName)
        assertEqual("snapshot jp8", desiredJp8, snapshot.resourcesKg.FUEL_JP8)
        assertEqual("snapshot avgas", desiredAvgas, snapshot.resourcesKg.FUEL_AVGAS)
        log("CAMPAIGNSTATE_SNAPSHOT_PASS node=" .. definition.nodeId)

        local plan = sync:PlanNode(definition.nodeId)
        assertEqual("initial plan changeCount", 2, plan.changeCount)
        log("SYNC_PLAN_PASS node=" .. definition.nodeId .. " changes=2")

        local apply = sync:ApplyNode(definition.nodeId)
        assertEqual("initial apply verified", true, apply.verified)
        assertEqual("jp8 readback", desiredJp8, apply.readbackKg.FUEL_JP8)
        assertEqual("avgas readback", desiredAvgas, apply.readbackKg.FUEL_AVGAS)
        log("SYNC_WRITE_READBACK_PASS node=" .. definition.nodeId)

        local secondPlan = sync:PlanNode(definition.nodeId)
        assertEqual("second plan changeCount", 0, secondPlan.changeCount)
        local secondApply = sync:ApplyNode(definition.nodeId)
        assertEqual("second apply verified", true, secondApply.verified)
        assertEqual("second apply changeCount", 0, secondApply.plan.changeCount)
        log("SYNC_IDEMPOTENCY_PASS node=" .. definition.nodeId)

        assertEqual(
          "campaignstate jp8 unchanged",
          desiredJp8,
          campaignState:GetResourceKg(definition.nodeId, "FUEL_JP8")
        )
        assertEqual(
          "campaignstate avgas unchanged",
          desiredAvgas,
          campaignState:GetResourceKg(definition.nodeId, "FUEL_AVGAS")
        )
        log("NO_REVERSE_MUTATION_PASS node=" .. definition.nodeId)
      end)

      local restoreOk, restoreError = pcall(function()
        local restore = OMWStorageFuelAdapter.ApplySnapshot(original)
        assertEqual("restore verified", true, restore.verified)
        local restored = OMWStorageFuelAdapter.ReadNode(definition.nodeId, definition.airbaseName)
        assertEqual("restore jp8", original.resourcesKg.FUEL_JP8, restored.resourcesKg.FUEL_JP8)
        assertEqual("restore avgas", original.resourcesKg.FUEL_AVGAS, restored.resourcesKg.FUEL_AVGAS)
        log("RESTORE_PASS node=" .. definition.nodeId)
      end)

      if nodeOk and restoreOk then
        nodesPassed = nodesPassed + 1
        log(string.format("NODE_PASS node=%s airbase=%s", definition.nodeId, definition.airbaseName))
      else
        nodesFailed = nodesFailed + 1
        log(string.format(
          "NODE_FAIL node=%s airbase=%s stage=SYNC_OR_RESTORE syncError=%s restoreError=%s",
          definition.nodeId,
          definition.airbaseName,
          tostring(nodeOk and "none" or nodeError),
          tostring(restoreOk and "none" or restoreError)
        ))
      end
    end
  end

  local status = nodesFailed == 0 and "PASS" or "FAIL"
  log(string.format(
    "RESULT testId=%s nodesExpected=%d nodesPassed=%d nodesFailed=%d status=%s direction=CampaignState-to-STORAGE campaignStateMutation=false reverseOverwrite=false persistence=false automaticAircraftDebit=false",
    TEST_ID,
    #nodes,
    nodesPassed,
    nodesFailed,
    status
  ))
end

local ok, err = pcall(run)
if not ok then
  log("RESULT testId=" .. TEST_ID .. " status=FAIL fatalError=" .. tostring(err))
end
