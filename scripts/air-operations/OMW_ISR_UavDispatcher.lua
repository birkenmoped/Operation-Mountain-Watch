-- Operation Mountain Watch - MOOSE-only player ISR UAV dispatch adapter.
--
-- This adapter selects a preconfigured ISR Cell profile, reserves exactly one
-- CampaignState aircraft, registers the existing Mission Editor payload with
-- AIRWING and submits an AUFTRAG. It intentionally contains no native
-- DCS spawn, route or target-marker path.

local Dispatcher = {}
Dispatcher.__index = Dispatcher

local TAG = "[OMW][ISR.UavDispatcher]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then
    fail(label .. " must be a function")
  end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " must be a non-empty string")
  end
  return value
end

function Dispatcher.New(config)
  config = requireTable(config, "config")
  local moose = config.moose or _G
  requireTable(moose.ZONE_RADIUS, "MOOSE ZONE_RADIUS")
  requireTable(moose.AUFTRAG, "MOOSE AUFTRAG")
  requireTable(moose.ENUMS, "MOOSE ENUMS")
  requireTable(moose.SCHEDULER, "MOOSE SCHEDULER")
  if type(config.campaignAdapter) ~= "table" then
    fail("config.campaignAdapter is required")
  end
  requireFunction(config.campaignAdapter.Reserve, "campaignAdapter.Reserve")
  requireFunction(config.campaignAdapter.ConsumeAtPhysicalStart, "campaignAdapter.ConsumeAtPhysicalStart")
  requireFunction(config.campaignAdapter.RecoverAfterPhysicalRecovery,
    "campaignAdapter.RecoverAfterPhysicalRecovery")

  if config.onMissionStarted ~= nil then requireFunction(config.onMissionStarted, "config.onMissionStarted") end
  if config.onMissionExecuting ~= nil then requireFunction(config.onMissionExecuting, "config.onMissionExecuting") end
  if config.onMissionCancelled ~= nil then requireFunction(config.onMissionCancelled, "config.onMissionCancelled") end
  if config.onMissionCancelledBeforeStart ~= nil then
    requireFunction(config.onMissionCancelledBeforeStart, "config.onMissionCancelledBeforeStart")
  end
  if config.onMissionDone ~= nil then requireFunction(config.onMissionDone, "config.onMissionDone") end

  return setmetatable({
    moose = moose,
    campaignAdapter = config.campaignAdapter,
    source = requireTable(config.source or config.kandahar, "config.source"),
    profiles = requireTable(config.profiles, "config.profiles"),
    registeredPayloadProfileIds = {},
    missionsByRequestId = {},
    onMissionStarted = config.onMissionStarted,
    onMissionExecuting = config.onMissionExecuting,
    onMissionCancelled = config.onMissionCancelled,
    onMissionCancelledBeforeStart = config.onMissionCancelledBeforeStart,
    onMissionDone = config.onMissionDone,
  }, Dispatcher)
end

function Dispatcher:_Airwing(profile)
  local airwingKey = requireNonEmptyString(profile.airwingKey or "Main", "profile.airwingKey")
  local airwing = self.source.Airwings and self.source.Airwings[airwingKey] or nil
  if not airwing or type(airwing.NewPayload) ~= "function" or type(airwing.AddMission) ~= "function" then
    fail("configured source AIRWING is not available key=" .. airwingKey)
  end
  return airwing
end

function Dispatcher:_Squadron(profile)
  local squadronKey = requireNonEmptyString(profile.squadronKey, "profile.squadronKey")
  local squadron = self.source.Squadrons and self.source.Squadrons[squadronKey] or nil
  if type(squadron) ~= "table" then
    fail("configured source squadron is not available key=" .. squadronKey)
  end
  return squadron
end

function Dispatcher:_RegisterPayload(airwing, profile)
  if self.registeredPayloadProfileIds[profile.id] then
    return
  end
  -- The template is the existing Mission Editor template, including its fixed
  -- loadout. NewPayload only makes that template operationally selectable.
  local missionTypes = { self.moose.AUFTRAG.Type.RECON }
  if profile.missionKind == "ORBIT_CIRCLE" then
    missionTypes[#missionTypes + 1] = self.moose.AUFTRAG.Type.ORBIT
  end
  airwing:NewPayload(profile.template, -1, missionTypes, profile.performance)
  self.registeredPayloadProfileIds[profile.id] = true
  log("PAYLOAD_REGISTERED profile=" .. profile.id .. " template=" .. profile.template)
end

function Dispatcher:_CaptureOpsGroups(record)
  if record.opsGroups and #record.opsGroups > 0 then
    return true
  end
  if type(record.mission.GetOpsGroups) ~= "function" then
    return nil, "MOOSE_AUFTRAG_GET_OPS_GROUPS_UNAVAILABLE"
  end

  local opsGroups = record.mission:GetOpsGroups()
  if type(opsGroups) ~= "table" or #opsGroups == 0 then
    return nil, "MOOSE_AUFTRAG_HAS_NO_OPS_GROUPS"
  end
  for _, opsGroup in ipairs(opsGroups) do
    if type(opsGroup.IsAlive) ~= "function" then
      return nil, "MOOSE_OPS_GROUP_IS_ALIVE_UNAVAILABLE"
    end
  end
  record.opsGroups = opsGroups
  return true
end

function Dispatcher:_StopRecoveryMonitor(record)
  if record.recoveryScheduler and record.recoveryScheduleId then
    record.recoveryScheduler:Stop(record.recoveryScheduleId)
  end
  record.recoveryScheduler = nil
  record.recoveryScheduleId = nil
end

function Dispatcher:_CompleteAfterPhysicalRecovery(record)
  if record.recoveryCompleted then
    return
  end
  local recovery, reason = self.campaignAdapter:RecoverAfterPhysicalRecovery(record.requestId)
  if not recovery then
    log("MISSION_RECOVERY_SETTLEMENT_FAILED requestId=" .. record.requestId
      .. " reason=" .. tostring(reason))
    return
  end
  record.recoveryCompleted = true
  self:_StopRecoveryMonitor(record)
  log("MISSION_RECOVERED requestId=" .. record.requestId
    .. " mission=" .. record.mission.name .. " platform=" .. record.platformId
    .. " resourceRestored=true")
  if self.onMissionDone then self.onMissionDone(record.request, record.mission) end
end

function Dispatcher:_ObservePhysicalRecovery(requestId)
  local record = self.missionsByRequestId[requestId]
  if not record or not record.returning or record.recoveryCompleted then
    return
  end

  local captured = self:_CaptureOpsGroups(record)
  if not captured then
    log("MISSION_RECOVERY_AWAITING_GROUP requestId=" .. requestId)
    return
  end

  for _, opsGroup in ipairs(record.opsGroups) do
    if opsGroup:IsAlive() == true then
      return
    end
  end
  self:_CompleteAfterPhysicalRecovery(record)
end

function Dispatcher:_StartRecoveryMonitor(record)
  if record.recoveryScheduler then
    return
  end
  local scheduler, scheduleId = self.moose.SCHEDULER:New(
    nil,
    function(requestId)
      self:_ObservePhysicalRecovery(requestId)
    end,
    { record.requestId },
    5,
    5
  )
  record.recoveryScheduler = scheduler
  record.recoveryScheduleId = scheduleId
end

function Dispatcher:_MarkReturning(record, reason)
  if record.returning then
    return
  end
  record.returning = true
  log("MISSION_RETURNING requestId=" .. record.requestId .. " mission=" .. record.mission.name
    .. " platform=" .. record.platformId .. " reason=" .. reason)
  if self.onMissionCancelled then self.onMissionCancelled(record.request, record.mission) end
  self:_StartRecoveryMonitor(record)
end

function Dispatcher:_BuildMission(request, profile, squadron)
  local mission

  if profile.missionKind == "ORBIT_CIRCLE" then
    -- A static marker request requires a circular orbit centred on the submitted
    -- coordinate; no heading or leg may create a race-track pattern.
    mission = self.moose.AUFTRAG:NewORBIT_CIRCLE(
      request.coordinate,
      profile.reconAltitudeFeet,
      profile.reconSpeedKnots
    )
    mission.optionROE = self.moose.ENUMS.ROE.WeaponHold
  else
    local zone = self.moose.ZONE_RADIUS:New(
      "ISR_RECON_" .. request.id,
      request.coordinate:GetVec2(),
      profile.reconRadiusMeters
    )
    mission = self.moose.AUFTRAG:NewRECON(
      zone,
      profile.reconSpeedKnots,
      profile.reconAltitudeFeet,
      false,
      false
    )
  end

  requireFunction(mission.AssignSquadrons, "MOOSE AUFTRAG.AssignSquadrons")
  requireFunction(mission.Cancel, "MOOSE AUFTRAG.Cancel")
  mission:AssignSquadrons({ squadron })
  mission:SetName("ISR " .. request.id .. " " .. profile.platformId)
  mission:SetTime(0)
  mission:SetDuration(profile.onStationSeconds)
  mission:SetTeleport(false)
  mission.OnAfterStarted = function(_, _, _, _, _, _)
    local record = self.missionsByRequestId[request.id]
    if record then
      record.started = true
      local captured, reason = self:_CaptureOpsGroups(record)
      if not captured then
        log("MISSION_RECOVERY_GROUP_CAPTURE_DEFERRED requestId=" .. request.id .. " reason=" .. reason)
      end
    end
    self.campaignAdapter:ConsumeAtPhysicalStart(request.id)
    log("MISSION_STARTED requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
    if self.onMissionStarted then self.onMissionStarted(request, mission) end
  end
  mission.OnAfterExecuting = function(_, _, _, _, _, _)
    log("MISSION_ON_STATION requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
    if self.onMissionExecuting then self.onMissionExecuting(request, mission) end
  end
  mission.OnAfterCancel = function(_, _, _, _, _, _)
    local record = self.missionsByRequestId[request.id]
    if record and record.cancelMode == "BEFORE_START" then
      log("MISSION_CANCELLED_BEFORE_START requestId=" .. request.id .. " mission=" .. mission.name)
      if self.onMissionCancelledBeforeStart then self.onMissionCancelledBeforeStart(request, mission) end
      return
    end
    if record then
      local reason = record.cancelMode == "RECALL" and "OWNER_RECALL" or "MISSION_COMPLETED"
      self:_MarkReturning(record, reason)
    end
  end
  mission.OnAfterDone = function(_, _, _, _, _, _)
    local record = self.missionsByRequestId[request.id]
    if record and record.cancelMode == "BEFORE_START" then
      return
    end
    if record then
      record.taskDone = true
      -- MOOSE marks the AUFTRAG done when its task ends, before its assigned
      -- aircraft has completed the return flight. The request stays RETURNING
      -- until the tracked MOOSE OPSGROUP is no longer alive after recovery.
      self:_MarkReturning(record, record.cancelMode == "RECALL" and "OWNER_RECALL" or "MISSION_COMPLETED")
      log("MISSION_TASK_DONE requestId=" .. request.id .. " mission=" .. mission.name
        .. " platform=" .. profile.platformId .. " awaitingPhysicalRecovery=true")
    end
  end
  return mission
end

function Dispatcher:Dispatch(request)
  requireTable(request, "request")
  if self.missionsByRequestId[request.id] then
    return nil, "REQUEST_ALREADY_DISPATCHED"
  end
  for _, profile in ipairs(self.profiles) do
    -- Validate the complete physical dispatch target before creating the
    -- CampaignState reservation, so a profile wiring error cannot strand one.
    local airwing = self:_Airwing(profile)
    local squadron = self:_Squadron(profile)
    local reservation, reason = self.campaignAdapter:Reserve(request.id, profile)
    if reservation then
      self:_RegisterPayload(airwing, profile)
      local mission = self:_BuildMission(request, profile, squadron)
      airwing:AddMission(mission)
      log("MISSION_QUEUED requestId=" .. request.id .. " mission=" .. mission.name
        .. " platform=" .. profile.platformId .. " airwing=" .. tostring(profile.airwingKey or "Main")
        .. " squadron=" .. profile.squadronKey)
      self.missionsByRequestId[request.id] = {
        requestId = request.id,
        request = request,
        profileId = profile.id,
        platformId = profile.platformId,
        transactionId = reservation.transactionId,
        mission = mission,
      }
      return self.missionsByRequestId[request.id]
    end
    if reason ~= "RESOURCE_UNAVAILABLE" then
      return nil, reason
    end
  end
  return nil, "NO_AVAILABLE_ISR_ASSET"
end

function Dispatcher:CancelRequest(requestId)
  requestId = requireNonEmptyString(requestId, "requestId")
  local record = self.missionsByRequestId[requestId]
  if not record then
    return nil, "NO_DISPATCHED_MISSION"
  end
  if record.cancelMode == "BEFORE_START" then
    return "CANCELLED_BEFORE_START"
  end
  if record.cancelMode == "RECALL" then
    return "RECALL_ALREADY_ORDERED"
  end

  if record.started then
    record.cancelMode = "RECALL"
    log("MISSION_RECALL_ORDERED requestId=" .. requestId
      .. " mission=" .. tostring(record.mission.name)
      .. " platform=" .. tostring(record.platformId))
    record.mission:Cancel()
    return "RECALL_ORDERED"
  end

  record.cancelMode = "BEFORE_START"
  log("MISSION_CANCEL_REQUESTED_BEFORE_START requestId=" .. requestId
    .. " mission=" .. tostring(record.mission.name))
  record.mission:Cancel()
  return "CANCELLED_BEFORE_START"
end

return Dispatcher
