-- Operation Mountain Watch - approved Stage 3 external-slingload corridor handoff.
--
-- MOOSE-first boundary:
--   AUFTRAG:NewCARGOTRANSPORT owns spawn, pickup, cargo identity, tasking and AIRWING lifecycle.
--   After physical slingload pickup, pinned MOOSE exposes no public API to constrain the
--   running DCS CargoTransportation main task to an owner-authored PATHLINE.
--
-- Owner-approved narrow exception:
--   After confirmed pickup, pause the current AUFTRAG through the public MOOSE
--   OPSGROUP/FLIGHTGROUP PauseMission lifecycle. Wait until MOOSE reports that the
--   executing CargoTransportation waypoint task is no longer current. Only then use
--   public FLIGHTGROUP waypoint/task APIs to install the owner-authored outbound/return
--   route. At the Wright-side route exit a waypoint task re-issues the documented DCS
--   CargoTransportation task for the same cargo and ME drop zone. On confirmed physical
--   delivery the original AUFTRAG is completed with AUFTRAG:Success(), so the normal
--   AIRWING/LEGION lifecycle remains authoritative for the aircraft.
--
-- Diagnostic note:
--   Lifecycle snapshots below are observation-only. They do not gate, cancel, pause,
--   unpause, reroute, or otherwise alter execution. A small set of MOOSE internal fields
--   is logged only to identify the unexpected PAUSED -> OVER transition seen in DCS.
--
-- No raw DCS controller task assignment, native coalition spawning, teleport, or polling
-- faster than five seconds is used here.

local Handoff = {}

local TAG = "[OMW][SlingloadCorridorHandoff]"
Handoff.SchemaVersion = "OMW-SLINGLOAD-CORRIDOR-HANDOFF-5"

local Corridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
if type(Corridor) ~= "table" or type(Corridor.Install) ~= "function" then
  error(TAG .. " OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR.Install() is required", 2)
end

local originalInstall = Corridor.Install

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
end

local function missionIsCargoTransport(mission)
  return type(mission) == "table"
    and type(AUFTRAG) == "table"
    and type(AUFTRAG.Type) == "table"
    and mission.type == AUFTRAG.Type.CARGOTRANSPORT
end

local function validCargoId(value)
  if type(value) == "string" then return value ~= "" end
  return type(value) == "number"
end

local function safeCall(container, methodName, ...)
  if type(container) ~= "table" or type(container[methodName]) ~= "function" then return nil end
  local ok, value = pcall(container[methodName], container, ...)
  if not ok then return "<error:" .. tostring(value) .. ">" end
  return value
end

local function tableCount(value)
  if type(value) ~= "table" then return 0 end
  local count = 0
  for _ in pairs(value) do count = count + 1 end
  return count
end

local function tableContains(value, needle)
  if type(value) ~= "table" then return false end
  for _, item in pairs(value) do
    if item == needle then return true end
  end
  return false
end

local function missionLabel(mission)
  if type(mission) ~= "table" then return tostring(mission) end
  return tostring(mission.name or mission.missionname or mission.type or mission)
end

local function lifecycleSnapshot(flightGroup, mission, label)
  if type(flightGroup) ~= "table" or type(mission) ~= "table" then return end

  local missionState = safeCall(mission, "GetState")
  local groupStatus = safeCall(mission, "GetGroupStatus", flightGroup)
  local publicCurrentMission = safeCall(flightGroup, "GetMissionCurrent")
  local publicCurrentTask = safeCall(flightGroup, "GetTaskCurrent")

  -- Diagnostic-only inspection of pinned MOOSE runtime fields. These are never used to
  -- make routing or mission decisions and therefore are not treated as stable API.
  local internalCurrentMission = flightGroup.currentmission
  local internalTaskCurrent = flightGroup.taskcurrent
  local pausedMissions = flightGroup.pausedmissions

  local text = string.format(
    " LIFECYCLE label=%s mission=%s missionState=%s groupStatus=%s publicCurrentMissionIsTarget=%s publicTaskPresent=%s internalCurrentMission=%s internalTaskCurrent=%s pausedCount=%d pausedContainsTarget=%s",
    tostring(label),
    missionLabel(mission),
    tostring(missionState),
    tostring(groupStatus),
    tostring(publicCurrentMission == mission),
    tostring(publicCurrentTask ~= nil),
    tostring(internalCurrentMission),
    tostring(internalTaskCurrent),
    tableCount(pausedMissions),
    tostring(tableContains(pausedMissions, mission))
  )

  if type(flightGroup.I) == "function" then
    flightGroup:I(TAG .. text)
  elseif env and type(env.info) == "function" then
    env.info(TAG .. text, false)
  end
end

local function scheduleLifecycleSnapshots(flightGroup, mission)
  for _, delay in ipairs({1, 2, 3, 5}) do
    SCHEDULER:New(nil, function()
      lifecycleSnapshot(flightGroup, mission, "POST_PAUSE_T+" .. tostring(delay) .. "S")
    end, {}, delay)
  end
end

local function installLifecycleDiagnostics(flightGroup, mission)
  if flightGroup.__omwSlingloadLifecycleDiagnosticsInstalled then
    flightGroup.__omwSlingloadLifecycleDiagnosticMission = mission
    return
  end

  flightGroup.__omwSlingloadLifecycleDiagnosticsInstalled = true
  flightGroup.__omwSlingloadLifecycleDiagnosticMission = mission

  local previousPause = flightGroup.OnAfterPauseMission
  function flightGroup:OnAfterPauseMission(From, Event, To, ...)
    if previousPause then previousPause(self, From, Event, To, ...) end
    local diagnosticMission = self.__omwSlingloadLifecycleDiagnosticMission
    lifecycleSnapshot(self, diagnosticMission, "EVENT_OnAfterPauseMission")
  end

  local previousTaskDone = flightGroup.OnAfterTaskDone
  function flightGroup:OnAfterTaskDone(From, Event, To, Task, ...)
    if previousTaskDone then previousTaskDone(self, From, Event, To, Task, ...) end
    local diagnosticMission = self.__omwSlingloadLifecycleDiagnosticMission
    lifecycleSnapshot(self, diagnosticMission, "EVENT_OnAfterTaskDone")

    local binding = self.__omwSlingloadCorridorBinding
    if not binding or binding.delivered or Task ~= binding.deliveryTask then return end
    if binding.completeDelivery and binding.completeDelivery(binding) then return end
    binding.lastReason = "CARGO_TASK_DONE_WITHOUT_PHYSICAL_DELIVERY"
    if type(self.E) == "function" then self:E(TAG .. " " .. binding.lastReason) end
  end

  local previousMissionDone = flightGroup.OnAfterMissionDone
  function flightGroup:OnAfterMissionDone(From, Event, To, Mission, ...)
    if previousMissionDone then previousMissionDone(self, From, Event, To, Mission, ...) end
    local diagnosticMission = self.__omwSlingloadLifecycleDiagnosticMission
    lifecycleSnapshot(self, diagnosticMission, "EVENT_OnAfterMissionDone")
  end
end

local function profileFor(resolved, segmentIndex, fallbackAltitudeFtAgl)
  local profile = resolved.segmentProfiles and resolved.segmentProfiles[segmentIndex] or nil
  return {
    altitudeFtAgl = profile and profile.altitudeFtAgl or fallbackAltitudeFtAgl,
    pathlineName = resolved.pathlineNames and resolved.pathlineNames[segmentIndex] or resolved.pathlineName,
  }
end

local function stopDeliveryMonitor(binding)
  if binding.deliveryMonitor and type(binding.deliveryMonitor.Stop) == "function" then
    binding.deliveryMonitor:Stop()
  end
  binding.deliveryMonitor = nil
end

local function completeDelivery(binding)
  if binding.delivered then return true end
  local cargo = binding.cargo
  local dropZone = binding.dropZone
  if not cargo or cargo:IsAlive() ~= true or not cargo:IsInZone(dropZone) then return false end

  binding.delivered = true
  stopDeliveryMonitor(binding)
  lifecycleSnapshot(binding.flightGroup, binding.mission, "PHYSICAL_DELIVERY_CONFIRMED_BEFORE_SUCCESS")

  if type(binding.mission.Success) ~= "function" then
    fail("AUFTRAG:Success() is required after physical slingload delivery")
  end
  binding.mission:Success()
  lifecycleSnapshot(binding.flightGroup, binding.mission, "PHYSICAL_DELIVERY_CONFIRMED_AFTER_SUCCESS")

  if type(binding.flightGroup.I) == "function" then
    binding.flightGroup:I(TAG .. " physical slingload delivery confirmed; paused CARGOTRANSPORT AUFTRAG completed")
  end
  return true
end

local function installDeliveryMonitor(binding)
  if binding.deliveryMonitor then return end
  binding.deliveryMonitor = SCHEDULER:New(nil, function()
    if binding.delivered then stopDeliveryMonitor(binding); return end
    if completeDelivery(binding) then return end
    if type(binding.mission.IsOver) == "function" and binding.mission:IsOver() then
      lifecycleSnapshot(binding.flightGroup, binding.mission, "DELIVERY_MONITOR_MISSION_IS_OVER")
      stopDeliveryMonitor(binding)
      binding.lastReason = "CARGOTRANSPORT_ENDED_BEFORE_PHYSICAL_DELIVERY"
      if type(binding.flightGroup.E) == "function" then
        binding.flightGroup:E(TAG .. " " .. binding.lastReason)
      end
    end
  end, {}, 5, 5)
end

local function resolveCargoReferences(mission, explicitReferences)
  local params = mission.DCStask and mission.DCStask.params or nil
  local explicit = type(explicitReferences) == "table" and explicitReferences or nil
  local cargo = explicit and explicit.cargo or (params and params.cargo or nil)
  local dropZone = explicit and explicit.dropZone or (params and params.zone or nil)
  local cargoId = explicit and explicit.cargoId or (params and params.groupId or nil)
  local zoneId = explicit and explicit.zoneId or (params and params.zoneId or nil)

  -- Pinned MOOSE OBJECT:GetID() is documented as a string and
  -- AUFTRAG:NewCARGOTRANSPORT passes it directly as DCS CargoTransportation groupId.
  if cargo and cargoId == nil and type(cargo.GetID) == "function" then
    cargoId = cargo:GetID()
  end
  if dropZone and type(zoneId) ~= "number" then
    zoneId = dropZone.ZoneID
  end

  return cargo, dropZone, cargoId, zoneId
end

local function releaseActiveCargoTask(flightGroup, mission)
  requireFunction(flightGroup, "GetTaskCurrent", "FLIGHTGROUP")
  requireFunction(flightGroup, "GetMissionCurrent", "FLIGHTGROUP")
  requireFunction(flightGroup, "PauseMission", "FLIGHTGROUP")

  installLifecycleDiagnostics(flightGroup, mission)

  local currentTask = flightGroup:GetTaskCurrent()
  local pauseState = flightGroup.__omwSlingloadCorridorPauseState

  if currentTask then
    if not pauseState then
      local currentMission = flightGroup:GetMissionCurrent()
      if currentMission ~= mission then
        return false, "CARGOTRANSPORT_CURRENT_MISSION_MISMATCH"
      end
      flightGroup.__omwSlingloadCorridorPauseState = {
        mission = mission,
        requested = true,
        task = currentTask,
      }
      lifecycleSnapshot(flightGroup, mission, "BEFORE_PauseMission")
      flightGroup:PauseMission()
      lifecycleSnapshot(flightGroup, mission, "AFTER_PauseMission_CALL")
      scheduleLifecycleSnapshots(flightGroup, mission)
      if type(flightGroup.I) == "function" then
        flightGroup:I(TAG .. " confirmed pickup; requested public MOOSE PauseMission before corridor UpdateRoute")
      end
      return false, "CARGOTRANSPORT_PAUSE_REQUESTED"
    end

    if pauseState.mission ~= mission then
      return false, "CARGOTRANSPORT_PAUSE_MISSION_MISMATCH"
    end
    lifecycleSnapshot(flightGroup, mission, "WAITING_FOR_TASK_RELEASE")
    return false, "CARGOTRANSPORT_TASK_STILL_EXECUTING"
  end

  if pauseState and pauseState.mission ~= mission then
    return false, "CARGOTRANSPORT_PAUSE_MISSION_MISMATCH"
  end

  lifecycleSnapshot(flightGroup, mission, "TASK_RELEASED_BEFORE_ROUTE_INSTALL")
  return true, nil
end

local function installCargoHandoff(flightGroup, mission, resolved, altitudeFtAgl, explicitReferences)
  requireFunction(flightGroup, "GetWaypointCurrentUID", "FLIGHTGROUP")
  requireFunction(flightGroup, "AddWaypoint", "FLIGHTGROUP")
  requireFunction(flightGroup, "AddTaskWaypoint", "FLIGHTGROUP")
  requireFunction(flightGroup, "UpdateRoute", "FLIGHTGROUP")

  if type(resolved) ~= "table" or type(resolved.outbound) ~= "table" or #resolved.outbound < 2 then
    return nil, false, "CARGO_CORRIDOR_OUTBOUND_UNAVAILABLE"
  end
  if type(resolved.returnRoute) ~= "table" or #resolved.returnRoute < 2 then
    return nil, false, "CARGO_CORRIDOR_RETURN_UNAVAILABLE"
  end

  local cached = flightGroup.__omwSlingloadCorridorBinding
  if cached and cached.mission == mission and cached.result then
    return cached.result, true, "ALREADY_INSTALLED"
  end

  local cargo, dropZone, cargoId, zoneId = resolveCargoReferences(mission, explicitReferences)
  if not cargo or type(cargo.IsAlive) ~= "function" or type(cargo.IsInZone) ~= "function" then
    return nil, false, "CARGOTRANSPORT_CARGO_REFERENCE_UNAVAILABLE"
  end
  if not dropZone or type(zoneId) ~= "number" or not validCargoId(cargoId) then
    return nil, false, "CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE"
  end

  local released, releaseReason = releaseActiveCargoTask(flightGroup, mission)
  if released ~= true then
    return nil, false, releaseReason
  end

  local anchorUid = flightGroup:GetWaypointCurrentUID()
  if type(anchorUid) ~= "number" then
    return nil, false, "CURRENT_WAYPOINT_UID_UNAVAILABLE_AFTER_PICKUP"
  end

  local altitude = altitudeFtAgl or 500
  local outboundProfiles = {}
  local returnProfiles = {}
  local afterUid = anchorUid
  local outboundLast = nil

  for index, coordinate in ipairs(resolved.outbound) do
    local segmentIndex = resolved.outboundSegmentIndexes and resolved.outboundSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, altitude)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
    outboundProfiles[#outboundProfiles + 1] = {
      uid = waypoint.uid,
      sourceIndex = index,
      segmentIndex = segmentIndex,
      pathlineName = profile.pathlineName,
      altitudeFtAgl = profile.altitudeFtAgl,
      altType = "RADIO",
    }
    afterUid = waypoint.uid
    outboundLast = waypoint
  end

  local cargoTask = {
    id = "CargoTransportation",
    params = {
      groupId = cargoId,
      zoneId = zoneId,
    },
  }
  local deliveryTask = flightGroup:AddTaskWaypoint(
    cargoTask,
    outboundLast,
    "OMW Stage3 resume external slingload delivery at Wright route exit",
    10
  )
  if not deliveryTask then return nil, false, "CARGO_DELIVERY_WAYPOINT_TASK_CREATION_FAILED" end

  for index, coordinate in ipairs(resolved.returnRoute) do
    local segmentIndex = resolved.returnSegmentIndexes and resolved.returnSegmentIndexes[index] or 1
    local profile = profileFor(resolved, segmentIndex, altitude)
    local waypoint = flightGroup:AddWaypoint(coordinate, nil, afterUid, profile.altitudeFtAgl, false)
    returnProfiles[#returnProfiles + 1] = {
      uid = waypoint.uid,
      sourceIndex = index,
      segmentIndex = segmentIndex,
      pathlineName = profile.pathlineName,
      altitudeFtAgl = profile.altitudeFtAgl,
      altType = "RADIO",
    }
    afterUid = waypoint.uid
  end

  local binding = {
    mission = mission,
    flightGroup = flightGroup,
    cargo = cargo,
    dropZone = dropZone,
    deliveryTask = deliveryTask,
    delivered = false,
    lastReason = nil,
    completeDelivery = completeDelivery,
    result = {
      mode = "APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF",
      pauseMode = "MOOSE_OPSGROUP_PAUSE_MISSION",
      activeTaskClearedBeforeRoute = true,
      lifecycleDiagnostics = "OBSERVATION_ONLY_PUBLIC_API_PLUS_PINNED_MOOSE_INTERNAL_FIELDS",
      anchorUid = anchorUid,
      outboundWaypointCount = #outboundProfiles,
      returnWaypointCount = #returnProfiles,
      waypointProfiles = {
        outbound = outboundProfiles,
        returnRoute = returnProfiles,
      },
      pathlineNames = resolved.pathlineNames,
      segmentOffsets = resolved.segmentOffsets,
      offsetMode = resolved.offsetMode,
      nativeException = "DCS_CargoTransportation_waypoint_task_after_confirmed_pickup",
      referenceSource = explicitReferences and "EXPLICIT_ACCEPTANCE_CONTEXT" or "MOOSE_MISSION_TASK",
    },
  }
  flightGroup.__omwSlingloadCorridorBinding = binding
  installLifecycleDiagnostics(flightGroup, mission)
  installDeliveryMonitor(binding)

  lifecycleSnapshot(flightGroup, mission, "BEFORE_UpdateRoute")
  flightGroup:UpdateRoute()
  lifecycleSnapshot(flightGroup, mission, "AFTER_UpdateRoute")

  if type(flightGroup.I) == "function" then
    flightGroup:I(TAG .. string.format(
      " installed approved slingload handoff after MOOSE task release anchorUid=%d outbound=%d return=%d cargoId=%s zoneId=%d referenceSource=%s",
      anchorUid, #outboundProfiles, #returnProfiles, tostring(cargoId), zoneId, binding.result.referenceSource))
  end

  return binding.result, true, nil
end

function Corridor.Install(flightGroup, mission, resolved, altitudeFtAgl, explicitReferences)
  if not missionIsCargoTransport(mission) then
    return originalInstall(flightGroup, mission, resolved, altitudeFtAgl)
  end
  local result, ok, reason = installCargoHandoff(flightGroup, mission, resolved, altitudeFtAgl, explicitReferences)
  if ok ~= true and (reason == "CARGOTRANSPORT_PAUSE_REQUESTED" or reason == "CARGOTRANSPORT_TASK_STILL_EXECUTING") then
    return result, false, "MISSION_ROUTE_UIDS_NOT_READY"
  end
  return result, ok, reason
end

Handoff.Install = installCargoHandoff
Handoff.OriginalInstall = originalInstall

return Handoff
