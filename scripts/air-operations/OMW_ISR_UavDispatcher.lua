-- Operation Mountain Watch - MOOSE-only player ISR UAV dispatch adapter.
--
-- This adapter submits each valid request directly to the configured MOOSE
-- AIRWING queue. MOOSE alone decides physical asset availability and turnover.
-- CampaignState is updated only after MOOSE confirms physical start, then again
-- after physical recovery. It intentionally contains no native DCS spawn, route
-- or target-marker path and no local dispatch/retry queue.

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
  requireFunction(config.campaignAdapter.BeginPhysicalStart,
    "campaignAdapter.BeginPhysicalStart")
  requireFunction(config.campaignAdapter.RecoverAfterPhysicalRecovery,
    "campaignAdapter.RecoverAfterPhysicalRecovery")

  if config.onMissionStarted ~= nil then requireFunction(config.onMissionStarted, "config.onMissionStarted") end
  if config.onMissionExecuting ~= nil then requireFunction(config.onMissionExecuting, "config.onMissionExecuting") end
  if config.onMissionCancelled ~= nil then requireFunction(config.onMissionCancelled, "config.onMissionCancelled") end
  if config.onMissionCancelledBeforeStart ~= nil then
    requireFunction(config.onMissionCancelledBeforeStart, "config.onMissionCancelledBeforeStart")
  end
  if config.onMissionDone ~= nil then requireFunction(config.onMissionDone, "config.onMissionDone") end
  if config.onMissionReconciliationFailure ~= nil then
    requireFunction(config.onMissionReconciliationFailure,
      "config.onMissionReconciliationFailure")
  end
  if config.onMissionRecovered ~= nil then
    requireFunction(config.onMissionRecovered, "config.onMissionRecovered")
  end

  return setmetatable({
    moose = moose,
    campaignAdapter = config.campaignAdapter,
    source = requireTable(config.source or config.kandahar, "config.source"),
    profiles = requireTable(config.profiles, "config.profiles"),
    registeredPayloadProfileIds = {},
    missionsByRequestId = {},
    reconciliationBlocked = false,
    onMissionStarted = config.onMissionStarted,
    onMissionExecuting = config.onMissionExecuting,
    onMissionCancelled = config.onMissionCancelled,
    onMissionCancelledBeforeStart = config.onMissionCancelledBeforeStart,
    onMissionDone = config.onMissionDone,
    onMissionReconciliationFailure = config.onMissionReconciliationFailure,
    onMissionRecovered = config.onMissionRecovered,
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

function Dispatcher:_CaptureAsset(record)
  if record.asset then
    return true
  end
  if type(record.squadron) ~= "table" or type(record.squadron.assets) ~= "table" then
    return nil, "MOOSE_SQUADRON_ASSET_TABLE_UNAVAILABLE"
  end
  for _, asset in pairs(record.squadron.assets) do
    for _, opsGroup in ipairs(record.opsGroups or {}) do
      if asset.flightgroup == opsGroup then
        record.asset = asset
        return true
      end
    end
  end
  return nil, "MOOSE_ASSET_FOR_OPS_GROUP_NOT_FOUND"
end

function Dispatcher:_MarkTakeoff(record, source)
  if record.takeoffConfirmed then
    return
  end
  record.takeoffConfirmed = true
  record.takeoffSource = source
  log("MISSION_TAKEOFF_CONFIRMED requestId=" .. record.requestId
    .. " mission=" .. record.mission.name .. " platform=" .. record.platformId
    .. " source=" .. source)
end

function Dispatcher:_ObserveTakeoff(record)
  if record.takeoffConfirmed or not record.opsGroups then
    return record.takeoffConfirmed
  end

  record.takeoffObservers = record.takeoffObservers or {}
  for _, opsGroup in ipairs(record.opsGroups) do
    if type(opsGroup.IsAirborne) == "function" and opsGroup:IsAirborne() == true then
      self:_MarkTakeoff(record, "MOOSE_IS_AIRBORNE")
      return true
    end

    if not record.takeoffObservers[opsGroup] then
      local previous = opsGroup.OnAfterElementTakeoff
      opsGroup.OnAfterElementTakeoff = function(group, from, event, to, element, airbase)
        if previous then
          previous(group, from, event, to, element, airbase)
        end
        self:_MarkTakeoff(record, "MOOSE_ELEMENT_TAKEOFF")
      end
      record.takeoffObservers[opsGroup] = true
    end
  end
  return false
end

function Dispatcher:_WaiveTurnoverAfterNoTakeoff(record)
  if record.takeoffConfirmed then
    return false, "TAKEOFF_CONFIRMED"
  end
  local captured, captureReason = self:_CaptureAsset(record)
  if not captured then
    return nil, captureReason
  end
  -- MOOSE LEGION unconditionally sets Asset.Treturned when a returned asset is
  -- re-added to its cohort. MOOSE exposes no per-asset public waiver for that
  -- timestamp. This narrowly removes only the maintenance timestamp after the
  -- MOOSE physical return is complete and only when its ElementTakeoff callback
  -- never occurred.
  if record.asset.Treturned == nil then
    return nil, "MOOSE_RETURN_TIMESTAMP_UNAVAILABLE"
  end
  record.asset.Treturned = nil
  return true
end

function Dispatcher:_TurnoverSeconds(record)
  if not record.asset or type(record.squadron) ~= "table"
      or type(record.squadron.GetRepairTime) ~= "function" then
    return nil, "MOOSE_TURNOVER_TIME_UNAVAILABLE"
  end
  local seconds = record.squadron:GetRepairTime(record.asset)
  if type(seconds) ~= "number" then
    return nil, "MOOSE_TURNOVER_TIME_INVALID"
  end
  return math.max(0, seconds)
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

  if record.reconciliationFailure then
    record.recoveryCompleted = true
    self:_StopRecoveryMonitor(record)
    log("MISSION_RECOVERED_RECONCILIATION_REQUIRED requestId=" .. record.requestId
      .. " mission=" .. record.mission.name
      .. " platform=" .. record.platformId
      .. " reason=" .. tostring(record.reconciliationFailure))
    if self.onMissionReconciliationFailure then
      self.onMissionReconciliationFailure(record.request, record.mission,
        record.reconciliationFailure)
    end
    return
  end

  -- Do not settle CampaignState before MOOSE has re-added the returned asset.
  -- In the no-takeoff branch that is also the only safe point to remove the
  -- MOOSE-maintenance timestamp. A recovery scheduler retry handles the small
  -- interval between OPSGROUP despawn and LEGION asset-return processing.
  local turnoverWaived = false
  local turnoverWaiverReason = nil
  if not record.takeoffConfirmed then
    turnoverWaived, turnoverWaiverReason = self:_WaiveTurnoverAfterNoTakeoff(record)
    if turnoverWaived then
      log("MISSION_TURNOVER_WAIVED_NO_TAKEOFF requestId=" .. record.requestId
        .. " mission=" .. record.mission.name .. " platform=" .. record.platformId)
    else
      log("MISSION_TURNOVER_WAIVER_AWAITING_MOOSE_RETURN requestId=" .. record.requestId
        .. " reason=" .. tostring(turnoverWaiverReason))
      return
    end
  end

  local recovery, reason = self.campaignAdapter:RecoverAfterPhysicalRecovery(record.requestId)
  if not recovery then
    log("MISSION_RECOVERY_SETTLEMENT_FAILED requestId=" .. record.requestId
      .. " reason=" .. tostring(reason))
    return
  end

  local turnoverSeconds, turnoverReason = self:_TurnoverSeconds(record)
  record.recoveryCompleted = true
  self:_StopRecoveryMonitor(record)
  log("MISSION_RECOVERED requestId=" .. record.requestId
    .. " mission=" .. record.mission.name .. " platform=" .. record.platformId
    .. " resourceRestored=true"
    .. " takeoffConfirmed=" .. tostring(record.takeoffConfirmed == true)
    .. " turnoverWaived=" .. tostring(turnoverWaived == true)
    .. " turnoverSeconds=" .. tostring(turnoverSeconds)
    .. " turnoverReason=" .. tostring(turnoverReason))
  if self.onMissionDone then self.onMissionDone(record.request, record.mission) end
  if self.onMissionRecovered then
    self.onMissionRecovered(record.request, record.mission, {
      takeoffConfirmed = record.takeoffConfirmed == true,
      turnoverWaived = turnoverWaived == true,
      turnoverSeconds = turnoverSeconds,
      turnoverReason = turnoverReason,
    })
  end
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

  self:_ObserveTakeoff(record)
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
      else
        local assetCaptured, assetReason = self:_CaptureAsset(record)
        if not assetCaptured then
          log("MISSION_RECOVERY_ASSET_CAPTURE_DEFERRED requestId=" .. request.id
            .. " reason=" .. assetReason)
        end
        self:_ObserveTakeoff(record)
      end
    end

    -- MOOSE has now selected and physically started this specific mission. This
    -- is the first CampaignState settlement point; it is deliberately not an
    -- admission gate for AIRWING's queue.
    local reservation, settlementReason =
      self.campaignAdapter:BeginPhysicalStart(request.id, profile)
    if not reservation then
      record.reconciliationFailure = settlementReason or "CAMPAIGNSTATE_MOOSE_DIVERGENCE"
      self.reconciliationBlocked = true
      log("MISSION_START_RECONCILIATION_FAILED requestId=" .. request.id
        .. " mission=" .. mission.name
        .. " platform=" .. profile.platformId
        .. " reason=" .. tostring(record.reconciliationFailure))
      if self.onMissionStarted then self.onMissionStarted(request, mission, nil) end

      -- The physical mission has already been started by MOOSE. Cancel through
      -- MOOSE and wait for its physical return; do not invent a local recovery
      -- path or credit CampaignState for an un-settled sortie.
      record.cancelMode = "RECONCILIATION_FAILURE"
      mission:Cancel()
      return
    end

    record.transactionId = reservation.transactionId
    log("MISSION_STARTED requestId=" .. request.id .. " mission=" .. mission.name
      .. " platform=" .. profile.platformId
      .. " transactionId=" .. tostring(reservation.transactionId))
    if self.onMissionStarted then self.onMissionStarted(request, mission, reservation) end
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
      local reason = record.cancelMode == "RECALL" and "OWNER_RECALL"
        or (record.cancelMode == "RECONCILIATION_FAILURE"
          and "CAMPAIGNSTATE_RECONCILIATION_FAILURE" or "MISSION_COMPLETED")
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
  if self.reconciliationBlocked then
    return nil, "RECONCILIATION_BLOCKED"
  end
  if self.missionsByRequestId[request.id] then
    return nil, "REQUEST_ALREADY_DISPATCHED"
  end

  for _, profile in ipairs(self.profiles) do
    -- AIRWING owns resource admission: payload registration and AddMission happen
    -- before, and independently of, CampaignState settlement.
    local airwing = self:_Airwing(profile)
    local squadron = self:_Squadron(profile)
    self:_RegisterPayload(airwing, profile)
    local mission = self:_BuildMission(request, profile, squadron)
    local record = {
      requestId = request.id,
      request = request,
      profileId = profile.id,
      profile = profile,
      platformId = profile.platformId,
      mission = mission,
      squadron = squadron,
    }
    self.missionsByRequestId[request.id] = record
    airwing:AddMission(mission)
    log("MISSION_QUEUED requestId=" .. request.id .. " mission=" .. mission.name
      .. " platform=" .. profile.platformId .. " airwing=" .. tostring(profile.airwingKey or "Main")
      .. " squadron=" .. profile.squadronKey .. " authority=MOOSE_AIRWING_QUEUE")
    return record
  end

  return nil, "NO_ISR_PROFILE"
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
