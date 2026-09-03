-- Operation Mountain Watch - approved Stage 3 external-slingload corridor handoff.
--
-- MOOSE-first boundary:
--   AUFTRAG:NewCARGOTRANSPORT owns spawn, pickup, cargo identity, tasking and AIRWING lifecycle.
--   After physical slingload pickup, pinned MOOSE exposes no public API to constrain the
--   running DCS CargoTransportation main task to an owner-authored PATHLINE.
--
-- Owner-approved narrow exception:
--   Use public MOOSE FLIGHTGROUP waypoint/task APIs to replace the already-running
--   CargoTransportation task only after pickup. The outbound/return route remains in
--   FLIGHTGROUP. At the Wright-side route exit a waypoint task re-issues the documented
--   DCS CargoTransportation task for the same cargo and ME drop zone. On confirmed
--   physical delivery the original AUFTRAG is completed with AUFTRAG:Success(), so the
--   normal AIRWING/LEGION lifecycle remains authoritative for the aircraft.
--
-- No raw DCS controller task assignment, native coalition spawning, teleport, or polling
-- faster than five seconds is used here.

local Handoff = {}

local TAG = "[OMW][SlingloadCorridorHandoff]"
Handoff.SchemaVersion = "OMW-SLINGLOAD-CORRIDOR-HANDOFF-1"

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

  if type(binding.mission.Success) ~= "function" then
    fail("AUFTRAG:Success() is required after physical slingload delivery")
  end
  binding.mission:Success()

  if type(binding.flightGroup.I) == "function" then
    binding.flightGroup:I(TAG .. " physical slingload delivery confirmed; original CARGOTRANSPORT AUFTRAG completed")
  end
  return true
end

local function installTaskDoneHook(flightGroup)
  if flightGroup.__omwSlingloadCorridorTaskHook then return end
  flightGroup.__omwSlingloadCorridorTaskHook = true
  local previous = flightGroup.OnAfterTaskDone
  function flightGroup:OnAfterTaskDone(From, Event, To, Task)
    if previous then previous(self, From, Event, To, Task) end
    local binding = self.__omwSlingloadCorridorBinding
    if not binding or binding.delivered or Task ~= binding.deliveryTask then return end
    if completeDelivery(binding) then return end
    binding.lastReason = "CARGO_TASK_DONE_WITHOUT_PHYSICAL_DELIVERY"
    if type(self.E) == "function" then self:E(TAG .. " " .. binding.lastReason) end
  end
end

local function installDeliveryMonitor(binding)
  if binding.deliveryMonitor then return end
  binding.deliveryMonitor = SCHEDULER:New(nil, function()
    if binding.delivered then stopDeliveryMonitor(binding); return end
    if completeDelivery(binding) then return end
    if type(binding.mission.IsOver) == "function" and binding.mission:IsOver() then
      stopDeliveryMonitor(binding)
      binding.lastReason = "CARGOTRANSPORT_ENDED_BEFORE_PHYSICAL_DELIVERY"
      if type(binding.flightGroup.E) == "function" then
        binding.flightGroup:E(TAG .. " " .. binding.lastReason)
      end
    end
  end, {}, 5, 5)
end

local function installCargoHandoff(flightGroup, mission, resolved, altitudeFtAgl)
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

  local params = mission.DCStask and mission.DCStask.params or nil
  local cargo = params and params.cargo or nil
  local dropZone = params and params.zone or nil
  local cargoId = params and params.groupId or nil
  local zoneId = params and params.zoneId or nil
  if not cargo or type(cargo.IsAlive) ~= "function" or type(cargo.IsInZone) ~= "function" then
    return nil, false, "CARGOTRANSPORT_CARGO_REFERENCE_UNAVAILABLE"
  end
  if not dropZone or type(zoneId) ~= "number" or type(cargoId) ~= "number" then
    return nil, false, "CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE"
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
    result = {
      mode = "APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF",
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
    },
  }
  flightGroup.__omwSlingloadCorridorBinding = binding
  installTaskDoneHook(flightGroup)
  installDeliveryMonitor(binding)

  flightGroup:UpdateRoute()

  if type(flightGroup.I) == "function" then
    flightGroup:I(TAG .. string.format(
      " installed approved slingload handoff anchorUid=%d outbound=%d return=%d cargoId=%d zoneId=%d",
      anchorUid, #outboundProfiles, #returnProfiles, cargoId, zoneId))
  end

  return binding.result, true, nil
end

function Corridor.Install(flightGroup, mission, resolved, altitudeFtAgl)
  if not missionIsCargoTransport(mission) then
    return originalInstall(flightGroup, mission, resolved, altitudeFtAgl)
  end
  return installCargoHandoff(flightGroup, mission, resolved, altitudeFtAgl)
end

Handoff.Install = installCargoHandoff
Handoff.OriginalInstall = originalInstall

return Handoff