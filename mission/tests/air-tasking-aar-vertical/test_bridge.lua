local Bridge = dofile("../../../scripts/air-operations/OMW_AirTasking_AARBridge.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)), 2)
  end
end

local function assertTrue(value, label)
  if value ~= true then error(label .. " expected true", 2) end
end

local logs = {}
local controllerEnds = {}
local nextExecutionSerial = 0

local fakeController = {}

function fakeController.SelectArea(demand)
  if demand.operationsArea == "WEST" and demand.receiverProfile == "FAST" then
    return {
      missionDemandId = demand.missionDemandId,
      area = "LISA",
      receiverProfile = "FAST",
      requestedReceiverProfile = "FAST",
      operationsArea = "WEST",
      supportMode = demand.supportMode,
      sourceDomain = "AL_UDEID",
      transitProfile = "AL_UDEID_NORTH_HIGH",
      firFix = "DAVER",
      continuousCore = false,
      availability = "RESERVE",
    }
  end
  return nil, "NO_AAR_POLICY"
end

function fakeController.SubmitDemand(demand)
  local selection, reason = fakeController.SelectArea(demand)
  if not selection then return nil, reason end
  return selection, "RESERVE_TRACK_QUEUED"
end

function fakeController.EndDemand(demand, terminalStatus)
  controllerEnds[#controllerEnds + 1] = {
    missionDemandId = demand.missionDemandId,
    terminalStatus = terminalStatus,
  }
  return { closed = true }, "RESERVE_TRACK_EGRESS"
end

local fakeBaseAdapterModule = {}

function fakeBaseAdapterModule.New()
  local adapter = {}

  function adapter:CanMaterialize()
    return true
  end

  function adapter:OnMaterialized(selection, runtime)
    return {
      runtimeId = runtime.runtimeId,
      nodeId = selection.sourceDomain == "AL_UDEID" and "OFFMAP_AL_UDEID" or "OFFMAP_MANAS",
      resourceId = "AIRCRAFT_KC135",
    }
  end

  function adapter:OnHandoff(selection, runtime)
    return { runtimeId = runtime.runtimeId, nodeId = selection.sourceDomain }
  end

  function adapter:OnLost(selection, runtime)
    return { runtimeId = runtime.runtimeId, nodeId = selection.sourceDomain }
  end

  function adapter:ReconcileRestore()
    return { reconciled = 0, preservedLosses = 0, alreadyResolved = 0 }
  end

  return adapter
end

local bridge = Bridge.New({
  controller = fakeController,
  baseAdapterModule = fakeBaseAdapterModule,
  nextExecutionId = function()
    nextExecutionSerial = nextExecutionSerial + 1
    return string.format("EXE-%06d", nextExecutionSerial)
  end,
  logger = function(message)
    logs[#logs + 1] = message
  end,
})

local adapter = bridge:GetAdapterModule().New({}, {})

local demand1 = {
  missionDemandId = "MD-000001",
  receiverProfile = "FAST",
  operationsArea = "WEST",
  supportMode = "SUPPORT",
  priority = "HIGH",
}

local record1, submitReason1 = bridge:SubmitApprovedAAR({
  requestId = "ASR-000001",
  missionId = "ATM-000001",
  missionDemand = demand1,
  requestStatus = "APPROVED",
  requestTiming = "PREPLANNED",
})

assertEqual(submitReason1, "RESERVE_TRACK_QUEUED", "normal submit reason")
assertEqual(record1.request.status, "TASKED", "request tasked")
assertEqual(record1.mission.status, "TASKED", "mission tasked")
assertEqual(#record1.executionAttempts, 0, "no execution before materialization")

local runtime1 = { runtimeId = "AAR-0001" }
adapter:OnMaterialized(record1.selection, runtime1)
assertEqual(record1.request.status, "EXECUTING", "request executing")
assertEqual(record1.mission.status, "EXECUTING", "mission executing")
assertEqual(#record1.executionAttempts, 1, "execution created")
assertEqual(record1.executionAttempts[1].execution_attempt_id, "EXE-000001", "execution id")
assertEqual(record1.executionAttempts[1].status, "STARTED", "execution started")

local ended1, endReason1 = bridge:EndAAR("ATM-000001", "COMPLETE")
assertEqual(endReason1, "RESERVE_TRACK_EGRESS", "normal end reason")
assertEqual(ended1.mission.status, "EXECUTING", "mission remains executing until handoff")
assertEqual(controllerEnds[1].terminalStatus, "COMPLETE", "controller complete mapping")

adapter:OnHandoff(record1.selection, runtime1)
assertEqual(record1.executionAttempts[1].status, "ENDED", "execution ended")
assertEqual(record1.mission.status, "COMPLETED", "mission completed after handoff")
assertEqual(record1.request.status, "FULFILLED", "request fulfilled after completion")

local snapshot1 = bridge:ExportSnapshot()
assertEqual(snapshot1.missions[1].mission_id, "ATM-000001", "snapshot mission id")
assertEqual(snapshot1.execution_attempts[1].execution_attempt_id, "EXE-000001", "snapshot execution id")
assertEqual(snapshot1.execution_attempts[1].runtime_id, nil, "runtime id not persisted")

local demand2 = {
  missionDemandId = "MD-000002",
  receiverProfile = "FAST",
  operationsArea = "WEST",
  supportMode = "SUPPORT",
  priority = "HIGH",
}

local record2 = bridge:SubmitApprovedAAR({
  requestId = "ASR-000002",
  missionId = "ATM-000002",
  missionDemand = demand2,
  requestStatus = "APPROVED",
  requestTiming = "IMMEDIATE",
})

local runtime2 = { runtimeId = "AAR-0002" }
adapter:OnMaterialized(record2.selection, runtime2)
assertEqual(record2.executionAttempts[1].execution_attempt_id, "EXE-000002", "loss first execution id")

adapter:OnLost(record2.selection, runtime2, "TEST_LOSS")
assertEqual(record2.executionAttempts[1].status, "FAILED", "lost execution failed")
assertEqual(record2.executionAttempts[2].execution_attempt_id, "EXE-000003", "replacement execution id")
assertEqual(record2.executionAttempts[2].status, "PENDING", "replacement pending")
assertEqual(record2.mission.status, "EXECUTING", "mission continues across replacement")

local runtime3 = { runtimeId = "AAR-0003" }
adapter:OnMaterialized(record2.selection, runtime3)
assertEqual(#record2.executionAttempts, 2, "pending replacement reused")
assertEqual(record2.executionAttempts[2].status, "STARTED", "replacement started")
assertEqual(record2.executionAttempts[2].runtime_id, "AAR-0003", "replacement runtime correlated")

bridge:EndAAR("ATM-000002", "CANCELLED")
assertEqual(controllerEnds[2].terminalStatus, "ABORTED", "executing cancellation maps to abort")
assertEqual(record2.mission.status, "EXECUTING", "abort waits for handoff")
adapter:OnHandoff(record2.selection, runtime3)
assertEqual(record2.mission.status, "ABORTED", "mission aborted after egress handoff")
assertEqual(record2.request.status, "ABORTED", "request aborted after egress handoff")

assertTrue(#logs > 0, "bridge emitted stable-id logs")

print("AIR_TASKING_AAR_BRIDGE_TEST_PASS")
