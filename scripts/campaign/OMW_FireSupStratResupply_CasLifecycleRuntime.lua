-- Operation Mountain Watch - production CAS lifecycle runtime.
--
-- Shared production owner for FSSR CAS route/release/recovery after MOOSE
-- COMMANDER/LEGION selected the operational provider and asset.
--
-- This module deliberately owns no provider selection. It wraps the generic
-- COMMANDER bridge, preserves MOOSE recruitment authority, binds the selected
-- provider's owner-authored route profile, monitors the selected FLIGHTGROUP's
-- own detection picture, requests supported-element release through the existing
-- public Cancel() handle, and observes physical recovery.
--
-- Accepted/binding inheritance:
--   Stage 2B accepted OMW_FlightPath outbound/reverse route lifecycle
--   STAGE3 CAS own-detection + supported-element/no-contact release law
--   MOOSE physical landing / LEGION asset-return lifecycle
--
-- No Acceptance watchdog or test state is allowed to become lifecycle authority.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1"

local TAG = "[OMW][FireSupStratResupply.CasLifecycleRuntime]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function needTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function needPositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
    fail(label .. " must be a positive finite number")
  end
  return value
end

local function selectedLegion(legions)
  local selected = nil
  local count = 0
  for _, legion in pairs(legions or {}) do
    selected = legion
    count = count + 1
  end
  if count ~= 1 then return nil, "EXPECTED_ONE_SELECTED_LEGION actual=" .. tostring(count) end
  return selected, nil
end

local function livingRedGroundParticipants(context, redCoalition)
  local incident = context and context.incident or nil
  local incidentContext = incident and incident.context or nil
  local coordinator = incidentContext and incidentContext.sourceIncidentCoordinator or nil
  if not coordinator or type(coordinator.GetParticipants) ~= "function" then
    return nil, "SOURCE_INCIDENT_COORDINATOR_UNAVAILABLE"
  end

  local alive = 0
  for _, group in ipairs(coordinator:GetParticipants(true) or {}) do
    if group and group:IsAlive() == true and group:GetCoalition() == redCoalition then
      alive = alive + 1
    end
  end
  return alive, nil
end

function Runtime.New(spec)
  needTable(spec, "spec")
  local innerAdapter = needTable(spec.innerAdapter, "innerAdapter")
  local commander = needTable(spec.commander, "commander")
  local flightPathNameContract = needTable(spec.flightPathNameContract, "flightPathNameContract")
  local helicopterCorridor = needTable(spec.helicopterCorridor, "helicopterCorridor")
  local casTacticalCorridor = needTable(spec.casTacticalCorridor, "casTacticalCorridor")
  local casPatrolClosure = needTable(spec.casPatrolClosure, "casPatrolClosure")
  local executionProfiles = needTable(spec.executionProfiles, "executionProfiles")
  local pathlineRegistry = needTable(spec.pathlineRegistry, "pathlineRegistry")

  needFunction(innerAdapter, "Dispatch", "innerAdapter")
  needFunction(flightPathNameContract, "SelectFromRegistry", "flightPathNameContract")
  needFunction(helicopterCorridor, "ResolveSequence", "helicopterCorridor")
  needFunction(casTacticalCorridor, "PlanRouteGated", "casTacticalCorridor")
  needFunction(casTacticalCorridor, "ConfigureMission", "casTacticalCorridor")
  needFunction(casTacticalCorridor, "Bind", "casTacticalCorridor")
  needFunction(casPatrolClosure, "Request", "casPatrolClosure")

  if type(spec.logger) ~= "function" then fail("logger must be a function") end
  if spec.onEvidence ~= nil and type(spec.onEvidence) ~= "function" then
    fail("onEvidence must be a function when provided")
  end
  if spec.isSupportedElementClear ~= nil and type(spec.isSupportedElementClear) ~= "function" then
    fail("isSupportedElementClear must be a function when provided")
  end
  if type(SCHEDULER) ~= "table" or type(SCHEDULER.New) ~= "function" then
    fail("MOOSE SCHEDULER is required")
  end

  local self = setmetatable({
    innerAdapter = innerAdapter,
    commander = commander,
    flightPathNameContract = flightPathNameContract,
    helicopterCorridor = helicopterCorridor,
    casTacticalCorridor = casTacticalCorridor,
    casPatrolClosure = casPatrolClosure,
    executionProfiles = executionProfiles,
    pathlineRegistry = pathlineRegistry,
    redCoalition = spec.redCoalition or (coalition and coalition.side and coalition.side.RED),
    noContactStableSec = needPositive(spec.noContactStableSec or 30, "noContactStableSec"),
    updateSeconds = needPositive(spec.updateSeconds or 5, "updateSeconds"),
    logger = spec.logger,
    onEvidence = spec.onEvidence,
    isSupportedElementClear = spec.isSupportedElementClear,
    entries = {},
    missionEntries = {},
    legionHooks = {},
    scheduler = nil,
  }, Instance)

  self:_installCommanderCallbacks()
  self.scheduler = SCHEDULER:New(nil, function() self:_updateAll() end, {}, self.updateSeconds, self.updateSeconds)
  return self
end

function Instance:_log(message)
  self.logger(TAG .. " " .. tostring(message))
end

function Instance:_evidence(entry, eventName, fields)
  fields = fields or {}
  fields.event = eventName
  fields.demandId = entry and entry.demand and entry.demand.demandId or nil
  fields.siteId = entry and entry.demand and entry.demand.siteId or nil
  if self.onEvidence then self.onEvidence(fields, entry) end

  local parts = { eventName }
  local keys = {}
  for key in pairs(fields) do
    if key ~= "event" then keys[#keys + 1] = key end
  end
  table.sort(keys)
  for _, key in ipairs(keys) do
    parts[#parts + 1] = tostring(key) .. "=" .. tostring(fields[key])
  end
  self:_log(table.concat(parts, " "))
end

function Instance:_profileForLegion(legion)
  local alias = tostring(legion and (legion.alias or legion.name) or "")
  local profile = self.executionProfiles[alias]
  if not profile then
    return nil, alias, "SELECTED_PROVIDER_HAS_NO_OWNER_ROUTE_PROFILE"
  end
  if type(profile.pathlineBase) ~= "string" or profile.pathlineBase == "" then
    return nil, alias, "PROFILE_PATHLINE_BASE_MISSING"
  end
  if type(profile.pathlineNames) ~= "table" or #profile.pathlineNames < 2 then
    return nil, alias, "PROFILE_PATHLINE_SEQUENCE_INVALID"
  end
  return profile, alias, nil
end

function Instance:_prepareSelectedProvider(entry, mission, legion)
  local profile, alias, profileReason = self:_profileForLegion(legion)
  if not profile then return nil, profileReason .. " alias=" .. tostring(alias) end

  local geometry = mission._omwFssrCasGeometry
  if type(geometry) ~= "table" or type(geometry.zone) ~= "table" then
    return nil, "CAS_MISSION_GEOMETRY_UNAVAILABLE"
  end

  local primary, primaryReason = self.flightPathNameContract.SelectFromRegistry(
    profile.pathlineBase,
    self.pathlineRegistry
  )
  if not primary or type(primary.pathline) ~= "table" then
    return nil, "PRIMARY_OWNER_ROUTE_UNAVAILABLE " .. tostring(primaryReason)
  end

  local pathlines = {}
  local resolvedNames = {}
  for index, logicalName in ipairs(profile.pathlineNames) do
    if index == 1 then
      pathlines[index] = primary.pathline
      resolvedNames[index] = primary.name
    else
      local pathline = PATHLINE:FindByName(logicalName)
      if not pathline then
        return nil, "OWNER_ROUTE_SEGMENT_UNAVAILABLE name=" .. tostring(logicalName)
      end
      pathlines[index] = pathline
      resolvedNames[index] = logicalName
    end
  end

  local origin = legion:GetCoordinate()
  if not origin then return nil, "SELECTED_PROVIDER_COORDINATE_UNAVAILABLE" end

  local segmentProfiles = {}
  for index = 1, #resolvedNames do
    local configured = profile.segmentProfiles and profile.segmentProfiles[index] or {}
    segmentProfiles[index] = configured
  end

  local okResolved, resolvedOrError = pcall(function()
    return self.helicopterCorridor.ResolveSequence({
      pathlineNames = resolvedNames,
      pathlines = pathlines,
      originCoordinate = origin,
      destinationCoordinate = geometry.zone:GetCoordinate(),
      maxJunctionDistanceM = profile.maxJunctionDistanceM or 1000,
      offsetMode = self.helicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
      segmentProfiles = segmentProfiles,
    })
  end)
  if not okResolved or type(resolvedOrError) ~= "table" then
    return nil, "OWNER_ROUTE_RESOLVE_FAILED " .. tostring(resolvedOrError)
  end

  local okPlan, planOrError = pcall(function()
    return self.casTacticalCorridor.PlanRouteGated({
      allocationId = entry.demand.demandId,
      outboundRoute = resolvedOrError.outbound,
      returnRoute = resolvedOrError.returnRoute,
      destinationCoordinate = geometry.zone:GetCoordinate(),
      routeGateDistanceNm = profile.routeGateDistanceNm or 3.5,
      transitAltitudeFtAgl = profile.transitAltitudeFtAgl,
      missionAltitudeFtAgl = profile.missionAltitudeFtAgl,
      speedKts = profile.speedKts,
      honakerReference = entry.demand.siteId,
      westReference = resolvedNames[#resolvedNames],
    })
  end)
  if not okPlan or type(planOrError) ~= "table" then
    return nil, "CAS_ROUTE_GATE_FAILED " .. tostring(planOrError)
  end

  local okConfigure, configureError = pcall(function()
    self.casTacticalCorridor.ConfigureMission(mission, planOrError)
  end)
  if not okConfigure then
    return nil, "CAS_MISSION_ROUTE_CONFIG_FAILED " .. tostring(configureError)
  end

  local home = type(legion.GetAirbase) == "function" and legion:GetAirbase() or nil
  local homeName = home and type(home.GetName) == "function" and home:GetName() or nil
  if not homeName then return nil, "SELECTED_PROVIDER_HOME_AIRBASE_UNAVAILABLE" end

  entry.selectedLegion = legion
  entry.selectedProviderAlias = alias
  entry.profile = profile
  entry.route = resolvedOrError
  entry.tacticalGeometry = planOrError
  entry.homeAirbaseName = homeName

  self:_evidence(entry, "CAS_PROVIDER_PROFILE_BOUND", {
    provider = alias,
    home = homeName,
    primaryPathline = primary.name,
    routePoints = #(resolvedOrError.outbound or {}),
  })

  return planOrError, nil
end

function Instance:_installLegionReturnHook(legion)
  if self.legionHooks[legion] then return end
  self.legionHooks[legion] = true

  local runtime = self
  local previous = legion.OnAfterLegionAssetReturned
  function legion:OnAfterLegionAssetReturned(From, Event, To, Cohort, Asset)
    if previous then previous(self, From, Event, To, Cohort, Asset) end

    for _, entry in pairs(runtime.entries) do
      if entry.selectedLegion == self and entry.selectedAsset then
        local same = Asset == entry.selectedAsset
        if not same and Asset and entry.selectedAsset
            and Asset.uid ~= nil and entry.selectedAsset.uid ~= nil then
          same = Asset.uid == entry.selectedAsset.uid
        end
        if same then
          entry.assetReturned = true
          runtime:_evidence(entry, "CAS_LEGION_ASSET_RETURNED", {
            provider = entry.selectedProviderAlias,
            cohort = Cohort and Cohort.name,
            asset = Asset and Asset.spawngroupname,
          })
        end
      end
    end
  end
end

function Instance:_bindFlight(entry, opsGroup)
  if entry.flight and entry.flight ~= opsGroup then
    entry.failed = true
    entry.failureReason = "MULTIPLE_CAS_OPSGROUPS"
    self:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
    return
  end
  if not entry.tacticalGeometry then
    entry.failed = true
    entry.blocked = true
    entry.failureReason = "CAS_OPSGROUP_WITHOUT_OWNER_ROUTE_PROFILE"
    self:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
    return
  end

  for _, method in ipairs({
    "GetGroup", "GetCoordinate", "GetDetectedGroups", "GetWaypointIndex",
    "GetWaypointUIDFromIndex", "AddWaypoint", "UpdateRoute", "GetName",
  }) do
    if type(opsGroup[method]) ~= "function" then
      entry.failed = true
      entry.blocked = true
      entry.failureReason = "CAS_SELECTED_OPSGROUP_NOT_FLIGHTGROUP missing=" .. method
      self:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
      return
    end
  end

  entry.flight = opsGroup
  entry.group = opsGroup:GetGroup()
  entry.initialAlive = entry.group
    and type(entry.group.CountAliveUnits) == "function"
    and entry.group:CountAliveUnits()
    or nil

  local runtime = self
  local _, _, bound, bindReason = self.casTacticalCorridor.Bind(
    opsGroup,
    entry.mission,
    entry.tacticalGeometry,
    {
      onInstalled = function(result)
        entry.corridorInstalled = true
        runtime:_evidence(entry, "CAS_OWNER_CORRIDOR_INSTALLED", {
          missionUid = result and result.missionUid,
          ingressUid = result and result.ingressUid,
          egressUid = result and result.egressUid,
          waypointProfiles = result and result.waypointProfiles and #result.waypointProfiles or 0,
        })
      end,
      onFailed = function(reason)
        entry.failed = true
        entry.failureReason = "CAS_OWNER_CORRIDOR_BIND_FAILED " .. tostring(reason)
        runtime:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
      end,
    }
  )

  if not bound and bindReason ~= "MISSION_ROUTE_UIDS_NOT_READY" then
    entry.failed = true
    entry.failureReason = "CAS_OWNER_CORRIDOR_BIND_FAILED " .. tostring(bindReason)
    self:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
    return
  end

  local previousFuelLow = opsGroup.OnAfterFuelLow
  function opsGroup:OnAfterFuelLow(From, Event, To)
    if previousFuelLow then previousFuelLow(self, From, Event, To) end
    entry.fuelLowObserved = true
    entry.fuelLowBeforeRelease = entry.releaseRequested ~= true
    runtime:_evidence(entry, "CAS_FUEL_LOW", {
      beforeRelease = entry.fuelLowBeforeRelease,
      provider = entry.selectedProviderAlias,
    })
  end

  local previousLanded = opsGroup.OnAfterLanded
  function opsGroup:OnAfterLanded(From, Event, To, Airport)
    if previousLanded then previousLanded(self, From, Event, To, Airport) end
    local actual = Airport and type(Airport.GetName) == "function" and Airport:GetName() or tostring(Airport)
    if actual == entry.homeAirbaseName then
      entry.homeLanded = true
      runtime:_evidence(entry, "CAS_HOME_LANDED", {
        provider = entry.selectedProviderAlias,
        airport = actual,
      })
    else
      entry.failed = true
      entry.failureReason = "CAS_LANDED_AT_WRONG_AIRBASE expected="
        .. tostring(entry.homeAirbaseName) .. " actual=" .. tostring(actual)
      runtime:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
    end
  end

  self:_evidence(entry, "CAS_OPSGROUP_BOUND", {
    provider = entry.selectedProviderAlias,
    group = opsGroup:GetName(),
  })
end

function Instance:_installCommanderCallbacks()
  local runtime = self

  local previousBefore = self.commander.OnBeforeMissionAssign
  function self.commander:OnBeforeMissionAssign(From, Event, To, Mission, Legions)
    if previousBefore and previousBefore(self, From, Event, To, Mission, Legions) == false then
      return false
    end

    local entry = runtime.missionEntries[Mission]
    if not entry then return true end

    local legion, reason = selectedLegion(Legions)
    if not legion then
      entry.failed = true
      entry.blocked = true
      entry.failureReason = "C2_PROVIDER_SELECTION_INVALID " .. tostring(reason)
      runtime:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
      return false
    end

    local _, profileReason = runtime:_prepareSelectedProvider(entry, Mission, legion)
    if profileReason then
      entry.failed = true
      entry.blocked = true
      entry.failureReason = profileReason
      runtime:_evidence(entry, "CAS_PROVIDER_PROFILE_REJECTED", {
        reason = profileReason,
        provider = tostring(legion.alias or legion.name),
      })
      return false
    end

    runtime:_installLegionReturnHook(legion)
    return true
  end

  local previousAssign = self.commander.OnAfterMissionAssign
  function self.commander:OnAfterMissionAssign(From, Event, To, Mission, Legions)
    if previousAssign then previousAssign(self, From, Event, To, Mission, Legions) end

    local entry = runtime.missionEntries[Mission]
    if not entry then return end

    local asset = Mission.assets and Mission.assets[1] or nil
    entry.selectedAsset = asset
    entry.selectedSquadron = asset and asset.squadname or nil
    if not asset then
      entry.failed = true
      entry.blocked = true
      entry.failureReason = "CAS_SELECTED_ASSET_EVIDENCE_MISSING"
      runtime:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
      return
    end

    runtime:_evidence(entry, "CAS_MISSION_ASSIGNED", {
      provider = entry.selectedProviderAlias,
      squadron = entry.selectedSquadron,
      home = entry.homeAirbaseName,
      asset = asset.spawngroupname,
    })
  end

  local previousOps = self.commander.OnAfterOpsOnMission
  function self.commander:OnAfterOpsOnMission(From, Event, To, OpsGroup, Mission)
    if previousOps then previousOps(self, From, Event, To, OpsGroup, Mission) end

    local entry = runtime.missionEntries[Mission]
    if not entry then return end
    runtime:_bindFlight(entry, OpsGroup)
  end
end

function Instance:_detectedEligible(entry)
  local result = {}
  if not entry.flight or not entry.mission._omwFssrCasGeometry then
    return result, 0, false
  end

  local detected = entry.flight:GetDetectedGroups()
  if not detected or type(detected.GetSet) ~= "function" then
    return result, 0, false
  end

  local geometry = entry.mission._omwFssrCasGeometry
  local zone = geometry.zone
  local engageRangeNm = geometry.engageDetectedRangeNm
  if not zone or type(engageRangeNm) ~= "number" then
    return result, 0, false
  end

  local flightCoord = entry.flight:GetCoordinate()
  if not flightCoord then return result, 0, false end

  local total = 0
  for _, group in pairs(detected:GetSet() or {}) do
    total = total + 1
    if group and group:IsAlive() == true and group:GetCoalition() == self.redCoalition then
      local coordinate = group:GetCoordinate()
      local inZone = coordinate and zone:IsCoordinateInZone(coordinate)
      local inRange = coordinate
        and flightCoord:Get3DDistance(coordinate) <= UTILS.NMToMeters(engageRangeNm)
      local ground = type(group.HasAttribute) == "function"
        and group:HasAttribute("Ground Units", false)
      if inZone and inRange and ground then result[#result + 1] = group end
    end
  end

  return result, total, true
end

function Instance:_supportedElementClear(entry)
  if self.isSupportedElementClear then
    return self.isSupportedElementClear(entry.demand, entry.context, entry)
  end
  local alive, reason = livingRedGroundParticipants(entry.context, self.redCoalition)
  if alive == nil then return nil, reason end
  return alive == 0, nil
end

function Instance:_updateEntry(entry)
  if entry.completed or entry.blocked then return end

  if entry.group and entry.initialAlive and type(entry.group.CountAliveUnits) == "function" then
    local alive = entry.group:CountAliveUnits()
    if alive < entry.initialAlive and not entry.assetLossReported then
      entry.assetLossReported = true
      entry.failed = true
      entry.failureReason = "CAS_ASSET_LOSS initialAlive=" .. tostring(entry.initialAlive)
        .. " alive=" .. tostring(alive)
      self:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
      -- Do not stop the operational release/recovery monitor. A surviving flight
      -- must still be released and recovered even though the acceptance result is FAIL.
    end
  end

  if entry.mission and type(entry.mission.IsExecuting) == "function"
      and entry.mission:IsExecuting() and not entry.executing then
    entry.executing = true
    entry.executingSince = timer.getAbsTime()
    self:_evidence(entry, "CAS_EXECUTING", {
      provider = entry.selectedProviderAlias,
      squadron = entry.selectedSquadron,
    })
  end

  if entry.executing and not entry.releaseRequested then
    local eligible, total, sensorReady = self:_detectedEligible(entry)
    if sensorReady then
      local count = #eligible
      if count ~= entry.detectedEligibleCount then
        entry.detectedEligibleCount = count
        if count > 0 then
          entry.noContactSince = nil
          entry.noContactReported = false
        elseif not entry.noContactSince then
          entry.noContactSince = timer.getAbsTime()
        end
        self:_evidence(entry, "CAS_SENSOR_REPORT", {
          detectedTotal = total,
          eligible = count,
        })
      elseif count == 0 and not entry.noContactSince then
        entry.noContactSince = timer.getAbsTime()
        self:_evidence(entry, "CAS_SENSOR_REPORT", {
          detectedTotal = total,
          eligible = 0,
        })
      end

      if count == 0 and entry.noContactSince and not entry.noContactReported
          and timer.getAbsTime() - entry.noContactSince >= self.noContactStableSec then
        entry.noContactReported = true
        self:_evidence(entry, "CAS_NO_CONTACT_REPORTED", {
          stableSec = self.noContactStableSec,
          source = "FLIGHTGROUP_GetDetectedGroups",
        })
      end
    elseif not entry.sensorWaitReported then
      entry.sensorWaitReported = true
      self:_evidence(entry, "CAS_SENSOR_WAIT", { source = "FLIGHTGROUP_GetDetectedGroups" })
    end

    local supportedClear, clearReason = self:_supportedElementClear(entry)
    if supportedClear == true and not entry.supportedElementClear then
      entry.supportedElementClear = true
      self:_evidence(entry, "CAS_SUPPORTED_ELEMENT_CLEAR", {
        source = "INSTALLATION_INCIDENT_PARTICIPANTS",
      })
    elseif supportedClear == nil and not entry.supportedElementWaitReported then
      entry.supportedElementWaitReported = true
      self:_evidence(entry, "CAS_SUPPORTED_ELEMENT_WAIT", { reason = clearReason })
    end

    if entry.supportedElementClear and entry.noContactReported then
      local _, changed, closureReason = self.casPatrolClosure.Request({
        demandId = entry.demand.demandId,
        tacticalComplete = true,
        executionEvidenceConfirmed = true,
        reason = "SUPPORTED_ELEMENT_RELEASE_NO_CONTACT",
        requestClosure = function(_, reason)
          local requested = entry.handle:Cancel(reason)
          return entry.mission, requested, requested and nil or "CLOSURE_ALREADY_REQUESTED"
        end,
      })
      if changed ~= true then
        if entry.handle.cancelRequested == true then
          entry.releaseRequested = true
          entry.releaseAt = timer.getAbsTime()
          self:_evidence(entry, "CAS_CONTROLLED_RELEASE", {
            reason = "SUPPORTED_ELEMENT_RELEASE_NO_CONTACT_ALREADY_REQUESTED",
            reverseOwnerRoute = true,
          })
          return
        end
        if not entry.releaseFailureReported then
          entry.releaseFailureReported = true
          entry.failed = true
          entry.failureReason = "CAS_CONTROLLED_RELEASE_FAILED " .. tostring(closureReason)
          self:_evidence(entry, "CAS_LIFECYCLE_FAILED", { reason = entry.failureReason })
        end
        return
      end
      entry.releaseRequested = true
      entry.releaseAt = timer.getAbsTime()
      self:_evidence(entry, "CAS_CONTROLLED_RELEASE", {
        reason = "SUPPORTED_ELEMENT_RELEASE_NO_CONTACT",
        reverseOwnerRoute = true,
      })
    end
  end

  if entry.releaseRequested and entry.homeLanded and entry.assetReturned then
    entry.completed = true
    entry.completedAt = timer.getAbsTime()
    self:_evidence(entry, "CAS_LIFECYCLE_COMPLETE", {
      provider = entry.selectedProviderAlias,
      squadron = entry.selectedSquadron,
      fuelLowBeforeRelease = entry.fuelLowBeforeRelease == true,
    })
  end
end

function Instance:_updateAll()
  for _, entry in pairs(self.entries) do
    self:_updateEntry(entry)
  end
end

function Instance:Dispatch(demand, context)
  needTable(demand, "demand")
  if type(demand.demandId) ~= "string" or demand.demandId == "" then
    fail("demand.demandId is required")
  end
  if self.entries[demand.demandId] then
    return self.entries[demand.demandId].handle, false, "ALREADY_DISPATCHED"
  end

  local handle, created, reason = self.innerAdapter:Dispatch(demand, context)
  if not handle then return nil, created, reason end
  if type(handle.runtime) ~= "table" then fail("inner CAS handle.runtime mission is required") end
  if type(handle.Cancel) ~= "function" then fail("inner CAS handle.Cancel() is required") end

  local entry = {
    demand = demand,
    context = context,
    handle = handle,
    mission = handle.runtime,
    executing = false,
    corridorInstalled = false,
    releaseRequested = false,
    homeLanded = false,
    assetReturned = false,
    completed = false,
    failed = false,
    detectedEligibleCount = nil,
    noContactSince = nil,
    noContactReported = false,
    supportedElementClear = false,
    fuelLowObserved = false,
    fuelLowBeforeRelease = false,
    assetLossReported = false,
    blocked = false,
    releaseFailureReported = false,
  }

  self.entries[demand.demandId] = entry
  self.missionEntries[entry.mission] = entry

  self:_evidence(entry, "CAS_LIFECYCLE_REGISTERED", {
    mission = type(entry.mission.GetName) == "function" and entry.mission:GetName() or nil,
  })

  return handle, created, reason
end

function Instance:GetState(demandId)
  if type(demandId) ~= "string" or demandId == "" then fail("demandId is required") end
  return self.entries[demandId]
end

function Instance:GetStateByMission(mission)
  return self.missionEntries[mission]
end

function Instance:Stop()
  if self.scheduler and type(self.scheduler.Stop) == "function" then
    self.scheduler:Stop()
  end
end

return Runtime
