-- Operation Mountain Watch - Air Tasking to existing AAR runtime correlation bridge.
--
-- Architecture boundary:
--   * Air Tasking owns stable ASR/ATM/EXE domain correlation only.
--   * The existing AAR controller remains authoritative for AAR area/profile policy.
--   * The existing AAR CampaignState adapter remains authoritative for KC-135 transactions.
--   * MOOSE remains responsible for physical tanker execution through the existing controller.
--   * No MOOSE or DCS object is persisted by this module.

local Bridge = {}
Bridge.__index = Bridge

local TAG = "[OMW][AirTasking.AARBridge]"

local TERMINAL_MISSION_STATUS = {
  COMPLETED = true,
  FAILED = true,
  CANCELLED = true,
  ABORTED = true,
}

local TERMINAL_REQUEST_STATUS = {
  FULFILLED = true,
  DENIED = true,
  CANCELLED = true,
  ABORTED = true,
}

local ACTIVE_EXECUTION_STATUS = {
  PENDING = true,
  STARTED = true,
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then fail(label .. " must be a function") end
  return value
end

local function requireString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function requirePrefix(value, prefix, label)
  value = requireString(value, label)
  if value:sub(1, #prefix) ~= prefix then
    fail(string.format("%s must use %s prefix value=%s", label, prefix, value))
  end
  return value
end

local function copyArray(source)
  local target = {}
  for index, value in ipairs(source or {}) do target[index] = value end
  return target
end

local function shallowCopy(source)
  local target = {}
  for key, value in pairs(source or {}) do target[key] = value end
  return target
end

local function incrementChangeSerial(record)
  record.change_serial = (record.change_serial or 0) + 1
end

local function setStatus(record, status)
  if record.status == status then return false end
  record.status = status
  incrementChangeSerial(record)
  return true
end

local function appendUnique(array, value)
  for _, existing in ipairs(array) do
    if existing == value then return false end
  end
  array[#array + 1] = value
  return true
end

local function executionIsActive(attempt)
  return attempt and ACTIVE_EXECUTION_STATUS[attempt.status] == true
end

function Bridge.New(spec)
  spec = requireTable(spec, "spec")
  local controller = requireTable(spec.controller, "spec.controller")
  requireFunction(controller.SelectArea, "controller.SelectArea")
  requireFunction(controller.SubmitDemand, "controller.SubmitDemand")
  requireFunction(controller.EndDemand, "controller.EndDemand")

  local baseAdapterModule = requireTable(spec.baseAdapterModule, "spec.baseAdapterModule")
  requireFunction(baseAdapterModule.New, "baseAdapterModule.New")

  local nextExecutionId = requireFunction(spec.nextExecutionId, "spec.nextExecutionId")

  return setmetatable({
    controller = controller,
    baseAdapterModule = baseAdapterModule,
    nextExecutionId = nextExecutionId,
    logger = spec.logger,
    recordsByMissionId = {},
    recordsByDemandId = {},
    executionByRuntimeId = {},
  }, Bridge)
end

function Bridge:_Log(eventName, record, extra)
  local missionId = record and record.mission and record.mission.mission_id or "NONE"
  local requestId = record and record.request and record.request.request_id or "NONE"
  local demandId = record and record.missionDemand and record.missionDemand.missionDemandId or "NONE"
  local text = string.format("%s event=%s mission=%s request=%s demand=%s%s",
    TAG, tostring(eventName), tostring(missionId), tostring(requestId), tostring(demandId),
    extra and (" " .. tostring(extra)) or "")

  if type(self.logger) == "function" then
    self.logger(text)
  elseif env and type(env.info) == "function" then
    env.info(text)
  end
end

function Bridge:_GetRecordByMissionId(missionId)
  return self.recordsByMissionId[requirePrefix(missionId, "ATM-", "missionId")]
end

function Bridge:_GetRecordByDemandId(missionDemandId)
  if type(missionDemandId) ~= "string" then return nil end
  return self.recordsByDemandId[missionDemandId]
end

function Bridge:_CountActiveExecutions(record)
  local count = 0
  for _, attempt in ipairs(record.executionAttempts) do
    if executionIsActive(attempt) then count = count + 1 end
  end
  return count
end

function Bridge:_FindPendingExecution(record)
  for _, attempt in ipairs(record.executionAttempts) do
    if attempt.status == "PENDING" and attempt.runtime_id == nil then return attempt end
  end
  return nil
end

function Bridge:_CreateExecution(record, status)
  local executionId = requirePrefix(self.nextExecutionId(), "EXE-", "nextExecutionId()")
  local attempt = {
    execution_attempt_id = executionId,
    status = status or "PENDING",
    runtime_id = nil,
    result = nil,
    change_serial = 0,
  }
  record.executionAttempts[#record.executionAttempts + 1] = attempt
  appendUnique(record.mission.execution_attempt_ids, executionId)
  if attempt.status == "STARTED" then record.mission.active_execution_attempt_id = executionId end
  incrementChangeSerial(record.mission)
  return attempt
end

function Bridge:_StartExecution(record, runtime)
  if not record or not runtime or type(runtime.runtimeId) ~= "string" then return nil end

  local existing = self.executionByRuntimeId[runtime.runtimeId]
  if existing then return existing end

  local attempt = self:_FindPendingExecution(record) or self:_CreateExecution(record, "PENDING")
  attempt.runtime_id = runtime.runtimeId
  setStatus(attempt, "STARTED")
  record.mission.active_execution_attempt_id = attempt.execution_attempt_id
  if record.mission.status == "TASKED" then setStatus(record.mission, "EXECUTING") end
  if record.request.status == "TASKED" then setStatus(record.request, "EXECUTING") end

  self.executionByRuntimeId[runtime.runtimeId] = { record = record, attempt = attempt }
  self:_Log("EXECUTION_STARTED", record,
    string.format("execution=%s runtime=%s", attempt.execution_attempt_id, runtime.runtimeId))
  return attempt
end

function Bridge:_FinishPendingTerminal(record)
  if not record.pendingTerminal then return false end
  if self:_CountActiveExecutions(record) > 0 then return false end

  local terminal = record.pendingTerminal
  record.pendingTerminal = nil
  record.mission.active_execution_attempt_id = nil

  if terminal == "COMPLETED" then
    setStatus(record.mission, "COMPLETED")
    record.mission.result = "SUCCESS"
    setStatus(record.request, "FULFILLED")
  elseif terminal == "CANCELLED" then
    setStatus(record.mission, "CANCELLED")
    record.mission.result = "CANCELLED"
    setStatus(record.request, "CANCELLED")
  elseif terminal == "ABORTED" then
    setStatus(record.mission, "ABORTED")
    record.mission.result = "ABORTED"
    setStatus(record.request, "ABORTED")
  else
    fail("unsupported pending terminal=" .. tostring(terminal))
  end

  self:_Log("MISSION_TERMINAL", record, "status=" .. record.mission.status)
  return true
end

function Bridge:_OnMaterialized(selection, runtime, settlement)
  local record = selection and self:_GetRecordByDemandId(selection.missionDemandId) or nil
  if not record then return end

  self:_StartExecution(record, runtime)

  if type(settlement) == "table" then
    if settlement.transactionId then
      appendUnique(record.mission.resource_reservation_refs, settlement.transactionId)
    end
    if settlement.reservationId then
      appendUnique(record.mission.resource_reservation_refs, settlement.reservationId)
    end
  end
end

function Bridge:_OnHandoff(selection, runtime)
  local correlation = runtime and self.executionByRuntimeId[runtime.runtimeId] or nil
  if not correlation then return end

  local record = correlation.record
  local attempt = correlation.attempt
  setStatus(attempt, "ENDED")
  attempt.result = "HANDOFF"
  self.executionByRuntimeId[runtime.runtimeId] = nil

  if record.mission.active_execution_attempt_id == attempt.execution_attempt_id then
    record.mission.active_execution_attempt_id = nil
  end

  self:_Log("EXECUTION_ENDED", record,
    string.format("execution=%s runtime=%s result=HANDOFF", attempt.execution_attempt_id, runtime.runtimeId))
  self:_FinishPendingTerminal(record)
end

function Bridge:_OnLost(selection, runtime, reason)
  local correlation = runtime and self.executionByRuntimeId[runtime.runtimeId] or nil
  if not correlation then return end

  local record = correlation.record
  local attempt = correlation.attempt
  setStatus(attempt, "FAILED")
  attempt.result = "AIRCRAFT_LOSS:" .. tostring(reason or "DEAD")
  self.executionByRuntimeId[runtime.runtimeId] = nil

  if record.mission.active_execution_attempt_id == attempt.execution_attempt_id then
    record.mission.active_execution_attempt_id = nil
  end

  self:_Log("EXECUTION_FAILED", record,
    string.format("execution=%s runtime=%s reason=%s", attempt.execution_attempt_id,
      runtime.runtimeId, tostring(reason or "DEAD")))

  if record.pendingTerminal then
    self:_FinishPendingTerminal(record)
    return
  end

  -- The accepted AAR controller automatically replaces a lost tanker while the
  -- reserve station remains open. Keep the ATM mission identity and create the
  -- next stable execution attempt before the replacement is physically materialized.
  local replacement = self:_CreateExecution(record, "PENDING")
  record.mission.active_execution_attempt_id = replacement.execution_attempt_id
  self:_Log("EXECUTION_REPLACEMENT_PENDING", record,
    "execution=" .. replacement.execution_attempt_id)
end

function Bridge:GetAdapterModule()
  local owner = self
  local baseModule = self.baseAdapterModule
  local wrappedModule = {}

  function wrappedModule.New(store, campaignState)
    local base = baseModule.New(store, campaignState)
    local proxy = {}

    function proxy:CanMaterialize(selection)
      return base:CanMaterialize(selection)
    end

    function proxy:OnMaterialized(selection, runtime)
      local result = base:OnMaterialized(selection, runtime)
      owner:_OnMaterialized(selection, runtime, result)
      return result
    end

    function proxy:OnHandoff(selection, runtime)
      local result = base:OnHandoff(selection, runtime)
      owner:_OnHandoff(selection, runtime)
      return result
    end

    function proxy:OnLost(selection, runtime, reason)
      local result = base:OnLost(selection, runtime, reason)
      owner:_OnLost(selection, runtime, reason)
      return result
    end

    if type(base.ReconcileRestore) == "function" then
      function proxy:ReconcileRestore()
        return base:ReconcileRestore()
      end
    end

    if type(base.GetPoolStatus) == "function" then
      function proxy:GetPoolStatus(sourceDomain)
        return base:GetPoolStatus(sourceDomain)
      end
    end

    if type(base.GetConfig) == "function" then
      function proxy:GetConfig()
        return base:GetConfig()
      end
    end

    return proxy
  end

  return wrappedModule
end

function Bridge:SubmitApprovedAAR(spec)
  spec = requireTable(spec, "spec")
  local requestId = requirePrefix(spec.requestId, "ASR-", "requestId")
  local missionId = requirePrefix(spec.missionId, "ATM-", "missionId")
  local missionDemand = requireTable(spec.missionDemand, "missionDemand")
  local missionDemandId = requirePrefix(missionDemand.missionDemandId, "MD-", "missionDemand.missionDemandId")

  if spec.requestStatus ~= "APPROVED" then
    fail("SubmitApprovedAAR requires explicit requestStatus=APPROVED")
  end
  if self.recordsByMissionId[missionId] then fail("duplicate missionId=" .. missionId) end
  if self.recordsByDemandId[missionDemandId] then fail("MissionDemand already bridged id=" .. missionDemandId) end

  -- Use the existing AAR policy for validation and area/profile selection.
  local selection, reason = self.controller.SelectArea(missionDemand)
  if not selection then
    return nil, reason
  end

  local request = {
    request_id = requestId,
    mission_demand_id = missionDemandId,
    support_type = "AAR",
    request_timing = spec.requestTiming,
    priority = missionDemand.priority,
    required_effect_or_task = spec.requiredEffectOrTask or "AAR_SUPPORT",
    area_or_target_reference = missionDemand.operationsArea,
    status = "APPROVED",
    assigned_mission_ids = { missionId },
    change_serial = spec.requestChangeSerial or 0,
  }

  local mission = {
    mission_id = missionId,
    mission_type = "AAR",
    request_ids = { requestId },
    mission_demand_ids = { missionDemandId },
    status = "ALLOCATED",
    mission_area_id = selection.area,
    resource_reservation_refs = {},
    execution_attempt_ids = {},
    active_execution_attempt_id = nil,
    result = nil,
    closure_reason = nil,
    change_serial = spec.missionChangeSerial or 0,
  }

  local record = {
    request = request,
    mission = mission,
    missionDemand = shallowCopy(missionDemand),
    selection = shallowCopy(selection),
    executionAttempts = {},
    pendingTerminal = nil,
  }

  self.recordsByMissionId[missionId] = record
  self.recordsByDemandId[missionDemandId] = record

  local runtimeOrTrack, submitReason = self.controller.SubmitDemand(missionDemand)
  if not runtimeOrTrack then
    self.recordsByMissionId[missionId] = nil
    self.recordsByDemandId[missionDemandId] = nil
    return nil, submitReason
  end

  setStatus(request, "TASKED")
  setStatus(mission, "TASKED")
  self:_Log("MISSION_TASKED", record,
    string.format("area=%s controllerReason=%s", tostring(selection.area), tostring(submitReason)))

  -- If the existing controller reused an already materialized compatible runtime,
  -- no new adapter OnMaterialized event is emitted. Correlate that runtime here.
  if type(runtimeOrTrack) == "table" and type(runtimeOrTrack.runtimeId) == "string" then
    self:_StartExecution(record, runtimeOrTrack)
  end

  return record, submitReason
end

function Bridge:EndAAR(missionId, outcome)
  local record = self:_GetRecordByMissionId(missionId)
  if not record then return nil, "UNKNOWN_MISSION" end
  if TERMINAL_MISSION_STATUS[record.mission.status] then return record, "ALREADY_TERMINAL" end

  outcome = requireString(outcome, "outcome"):upper()
  local terminal
  local controllerStatus

  if outcome == "COMPLETE" or outcome == "COMPLETED" then
    if record.mission.status ~= "EXECUTING" then
      fail("COMPLETED requires EXECUTING mission=" .. missionId)
    end
    terminal = "COMPLETED"
    controllerStatus = "COMPLETE"
  elseif outcome == "CANCELLED" then
    if record.mission.status == "EXECUTING" then
      terminal = "ABORTED"
      controllerStatus = "ABORTED"
    else
      terminal = "CANCELLED"
      controllerStatus = "CANCELLED"
    end
  elseif outcome == "ABORTED" then
    terminal = "ABORTED"
    controllerStatus = "ABORTED"
  else
    fail("outcome must be COMPLETE, CANCELLED or ABORTED")
  end

  record.pendingTerminal = terminal
  record.mission.closure_reason = outcome
  local controllerResult, reason = self.controller.EndDemand(record.missionDemand, controllerStatus)

  -- EndDemand removes queued reserve materialization when the demand is closed.
  -- Any stable PENDING EXE record therefore becomes cancelled for this mission.
  for _, attempt in ipairs(record.executionAttempts) do
    if attempt.status == "PENDING" and attempt.runtime_id == nil then
      setStatus(attempt, "CANCELLED")
      attempt.result = "DEMAND_ENDED_BEFORE_MATERIALIZATION"
    end
  end

  self:_Log("MISSION_END_REQUESTED", record,
    string.format("terminal=%s controllerStatus=%s controllerReason=%s", terminal,
      controllerStatus, tostring(reason)))
  self:_FinishPendingTerminal(record)
  return record, reason, controllerResult
end

function Bridge:GetMission(missionId)
  local record = self:_GetRecordByMissionId(missionId)
  return record and record.mission or nil
end

function Bridge:GetRequest(requestId)
  requestId = requirePrefix(requestId, "ASR-", "requestId")
  for _, record in pairs(self.recordsByMissionId) do
    if record.request.request_id == requestId then return record.request end
  end
  return nil
end

function Bridge:GetExecutionAttempts(missionId)
  local record = self:_GetRecordByMissionId(missionId)
  if not record then return nil end
  return record.executionAttempts
end

function Bridge:ExportSnapshot()
  local missions = {}
  local requests = {}
  local executions = {}

  for _, record in pairs(self.recordsByMissionId) do
    missions[#missions + 1] = {
      mission_id = record.mission.mission_id,
      mission_type = record.mission.mission_type,
      request_ids = copyArray(record.mission.request_ids),
      mission_demand_ids = copyArray(record.mission.mission_demand_ids),
      status = record.mission.status,
      mission_area_id = record.mission.mission_area_id,
      resource_reservation_refs = copyArray(record.mission.resource_reservation_refs),
      execution_attempt_ids = copyArray(record.mission.execution_attempt_ids),
      active_execution_attempt_id = record.mission.active_execution_attempt_id,
      result = record.mission.result,
      closure_reason = record.mission.closure_reason,
      change_serial = record.mission.change_serial,
    }

    requests[#requests + 1] = {
      request_id = record.request.request_id,
      mission_demand_id = record.request.mission_demand_id,
      support_type = record.request.support_type,
      request_timing = record.request.request_timing,
      priority = record.request.priority,
      required_effect_or_task = record.request.required_effect_or_task,
      area_or_target_reference = record.request.area_or_target_reference,
      status = record.request.status,
      assigned_mission_ids = copyArray(record.request.assigned_mission_ids),
      change_serial = record.request.change_serial,
    }

    for _, attempt in ipairs(record.executionAttempts) do
      -- runtime_id is deliberately not persisted. AAR restore reconciliation resolves
      -- physical runtime commitments separately through the existing CampaignState adapter.
      executions[#executions + 1] = {
        execution_attempt_id = attempt.execution_attempt_id,
        mission_id = record.mission.mission_id,
        status = attempt.status,
        result = attempt.result,
        change_serial = attempt.change_serial,
      }
    end
  end

  return {
    requests = requests,
    missions = missions,
    execution_attempts = executions,
  }
end

return Bridge
