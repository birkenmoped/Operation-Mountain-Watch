-- Operation Mountain Watch - MOOSE-first Phase-1 runtime observer
-- Operative ownership comes from AIRWING:OnAfterFlightOnMission or OPSTRANSPORT
-- carrier objects. Names are assertions only; they are no longer used to discover
-- or reconstruct the active MOOSE asset.
local TAG = "[OMW][AirOps.JBAD.PH1.OBS]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.ManifestOK then
  log("ERROR: Phase-1 manifest unavailable.")
else
  local observer = ph1.Observer or {}
  ph1.Observer = observer

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
  end

  local function startsWith(value, prefix)
    return value and prefix and string.sub(value, 1, #prefix) == prefix
  end

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx = (a.x or 0) - (b.x or 0)
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function objectName(object)
    if not object then return nil end
    if type(object) == "string" then return object end
    if object.GetName then
      local ok, value = pcall(function() return object:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function flightGroupName(flightgroup)
    return objectName(flightgroup)
  end

  local function eventUnitName(eventData)
    if not eventData then return nil end
    return eventData.IniUnitName or (eventData.IniUnit and objectName(eventData.IniUnit)) or nil
  end

  local function eventGroupName(eventData)
    if not eventData then return nil end
    return eventData.IniGroupName or (eventData.IniGroup and objectName(eventData.IniGroup)) or nil
  end

  local function eventPlaceName(eventData)
    if not eventData then return nil end
    return eventData.PlaceName or objectName(eventData.Place) or objectName(eventData.place)
  end

  local function exactJalalabadPlace(eventData)
    local expected = objectName(cfg.Airbase) or cfg.AirbaseName
    local actual = eventPlaceName(eventData)
    return expected and actual and string.lower(expected) == string.lower(actual), actual
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function setUnitEvent(bucket, unitName)
    local runtime = ph1.Runtime
    if not runtime or not unitName then return false end
    runtime[bucket] = runtime[bucket] or {}
    if runtime[bucket][unitName] then return false end
    runtime[bucket][unitName] = true
    return true
  end

  local function expectedUnitName(definition, groupName, unitName)
    if not definition or not groupName or not unitName then return false end
    if not startsWith(groupName, definition.ExpectedGroupPrefix) then return false end
    for _, suffix in ipairs(definition.ExpectedUnitSuffixes or {}) do
      if unitName == groupName .. suffix then return true end
    end
    return false
  end

  local function nearestParking(coordinate)
    if not cfg.Airbase or not coordinate then return nil, nil end
    local nearestId, nearestDistance
    for _, spot in ipairs(cfg.Airbase:GetParkingSpotsTable() or {}) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then
        nearestId, nearestDistance = spot.TerminalID, distance
      end
    end
    return nearestId, nearestDistance
  end

  local function nearestStatic(coordinate)
    if not coordinate then return nil, nil end
    local nearestName, nearestDistance
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      for _, name in ipairs((cfg.Statics and cfg.Statics[key]) or {}) do
        local static = STATIC and STATIC:FindByName(name, false) or nil
        if static then
          local distance = distance2D(coordinate, static:GetCoordinate())
          if distance and (not nearestDistance or distance < nearestDistance) then
            nearestName, nearestDistance = name, distance
          end
        end
      end
    end
    return nearestName, nearestDistance
  end

  function observer:GetMissionQueueCount()
    if not cfg.Airwing or not cfg.Airwing.CountMissionsInQueue then return -1 end
    local ok, value = pcall(function() return cfg.Airwing:CountMissionsInQueue() end)
    return ok and tonumber(value) or -1
  end

  function observer:SnapshotSquadron(squadron)
    local snapshot = { total = 0, stock = 0, spawned = 0, onMission = 0, pending = 0, queued = 0, available = 0, busy = 0 }
    if not squadron or not squadron.CountAssets then return snapshot end
    snapshot.total = squadron:CountAssets(nil)
    snapshot.stock = squadron:CountAssets(true)
    snapshot.spawned = squadron:CountAssets(false)
    if cfg.Airwing and cfg.Airwing.CountAssetsOnMission then
      snapshot.onMission, snapshot.pending, snapshot.queued = cfg.Airwing:CountAssetsOnMission(nil, squadron)
    end
    snapshot.busy = math.max(snapshot.spawned or 0, snapshot.onMission or 0)
    snapshot.available = snapshot.stock
    return snapshot
  end

  function observer:SnapshotAllSquadrons()
    local result = {}
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      result[key] = self:SnapshotSquadron(cfg.Squadrons and cfg.Squadrons[key])
    end
    return result
  end

  function observer:LogSnapshot(label, snapshots)
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      local item = snapshots and snapshots[key] or {}
      log(string.format("INVENTORY label=%s squadron=%s total=%s stock=%s spawned=%s onMission=%s pending=%s queued=%s",
        tostring(label), key, tostring(item.total), tostring(item.stock), tostring(item.spawned),
        tostring(item.onMission), tostring(item.pending), tostring(item.queued)))
    end
  end

  function observer:IsInventoryClean(snapshots)
    for key, expected in pairs(ph1.AssetGroupInventory or {}) do
      local item = snapshots and snapshots[key]
      if not item then return false, "snapshot-missing-" .. key end
      if item.total ~= expected then return false, string.format("total-mismatch-%s-%d-%d", key, item.total, expected) end
      if item.stock ~= expected or item.spawned ~= 0 or item.onMission ~= 0 then
        return false, string.format("inventory-busy-%s-stock%d-spawned%d-onMission%d", key, item.stock, item.spawned, item.onMission)
      end
    end
    return true
  end

  function observer:IsInventoryRestored(baseline)
    local current = self:SnapshotAllSquadrons()
    local clean, reason = self:IsInventoryClean(current)
    if not clean then return false, reason, current end
    if baseline then
      for key, before in pairs(baseline) do
        local after = current[key]
        if not after or before.total ~= after.total then return false, "baseline-total-changed-" .. tostring(key), current end
      end
    end
    return true, nil, current
  end

  function observer:ResolveClientParkingIDs()
    ph1.ClientParkingIDs = {}
    ph1.ClientParkingMappings = {}
    local groups = {}
    for _, key in ipairs({ "OH58D", "AH64D", "CH47" }) do
      for _, name in ipairs((cfg.PlayerGroups.Required and cfg.PlayerGroups.Required[key]) or {}) do groups[#groups + 1] = name end
    end
    local ok = true
    for _, groupName in ipairs(groups) do
      local group = GROUP and GROUP:FindByName(groupName) or nil
      local template = group and group.GetTemplate and group:GetTemplate() or nil
      local unit = template and template.units and template.units[1] or nil
      local coordinate = unit and COORDINATE:NewFromVec2({ x = unit.x or 0, y = unit.y or unit.z or 0 }) or nil
      local terminalId, nearestDistance = nearestParking(coordinate)
      if terminalId and nearestDistance and nearestDistance <= ph1.Limits.ClientParkingMatchMeters then
        ph1.ClientParkingIDs[terminalId] = true
        ph1.ClientParkingMappings[groupName] = terminalId
        log(string.format("CLIENT_PARKING group=%s TerminalID=%s distance=%.1fm protected=true", groupName, tostring(terminalId), nearestDistance))
      else
        ok = false
        log(string.format("ERROR CLIENT_PARKING_UNRESOLVED group=%s TerminalID=%s distance=%s", groupName, tostring(terminalId), nearestDistance and string.format("%.1fm", nearestDistance) or "unknown"))
      end
    end
    ph1.ClientParkingResolved = ok and #groups == 6
    return ph1.ClientParkingResolved
  end

  local function validateSpawnParking(definition, groupName, unit)
    local coordinate = unit and unit:GetCoordinate() or nil
    local terminalId, parkingDistance = nearestParking(coordinate)
    local staticName, staticDistance = nearestStatic(coordinate)
    local poolKey = definition.SquadronKey
    local allowed = cfg.ParkingPoolTerminalIDs and cfg.ParkingPoolTerminalIDs[poolKey] or nil
    log(string.format("SPAWN_ASSERT group=%s unit=%s TerminalID=%s parkingDistance=%s",
      groupName, unit and unit:GetName() or "nil", tostring(terminalId), parkingDistance and string.format("%.1fm", parkingDistance) or "unknown"))
    if not terminalId or not parkingDistance or parkingDistance > ph1.Limits.ParkingBirthMatchMeters or not allowed or not allowed[terminalId] then
      increment("parkingViolations")
      ph1.Runtime.HardFailure = "spawn-outside-squadron-pool-" .. tostring(terminalId)
    elseif ph1.ClientParkingIDs and ph1.ClientParkingIDs[terminalId] then
      increment("parkingViolations")
      ph1.Runtime.HardFailure = "spawn-on-client-terminal-" .. tostring(terminalId)
    elseif staticDistance and staticDistance < ph1.Limits.StaticSpawnClearanceMeters then
      increment("parkingViolations")
      ph1.Runtime.HardFailure = "spawn-too-close-to-static-" .. tostring(staticName)
    end
  end

  local function recordBoundGroupBirth(groupName, group)
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition then return false end
    if not startsWith(groupName, definition.ExpectedGroupPrefix) then
      runtime.HardFailure = "bound-group-prefix-mismatch-" .. tostring(groupName)
      return false
    end
    if runtime.BoundGroupNames[groupName] then return true end
    if countKeys(runtime.BoundGroupNames) >= definition.ExpectedGroups then
      runtime.HardFailure = "too-many-bound-flightgroups"
      return false
    end

    local units = group and group:GetUnits() or {}
    if #units ~= definition.ExpectedAircraft / definition.ExpectedGroups then
      runtime.HardFailure = string.format("bound-group-size-mismatch-%d", #units)
      return false
    end

    runtime.BoundGroupNames[groupName] = true
    runtime.ExpectedUnitNames = runtime.ExpectedUnitNames or {}
    runtime.BornUnits = runtime.BornUnits or {}
    for _, unit in ipairs(units) do
      local unitName = unit:GetName()
      if not expectedUnitName(definition, groupName, unitName) then
        runtime.HardFailure = "bound-unit-name-mismatch-" .. tostring(unitName)
        return false
      end
      runtime.ExpectedUnitNames[unitName] = groupName
      if not runtime.BornUnits[unitName] then
        runtime.BornUnits[unitName] = true
        runtime.BirthCount = (runtime.BirthCount or 0) + 1
        increment("aircraftSpawned")
        validateSpawnParking(definition, groupName, unit)
      end
    end
    increment("groupsSpawned")
    log(string.format("FLIGHTGROUP_BOUND testId=%s group=%s aircraft=%d source=MOOSE_OBJECT_REFERENCE", tostring(ph1.ActiveTestId), groupName, #units))
    return true
  end

  local function activeGroupEvent(groupName, eventData)
    if not ph1.Runtime or not ph1.Runtime.BoundGroupNames[groupName] then return false end
    return eventGroupName(eventData) == groupName
  end

  local function attachGroupEvents(groupName, group)
    if not group or group.OMWPhase1EventsAttached then return end
    group.OMWPhase1EventsAttached = true
    for _, event in ipairs({ EVENTS.EngineStartup, EVENTS.Takeoff, EVENTS.Land, EVENTS.EngineShutdown, EVENTS.Crash, EVENTS.Dead }) do
      group:HandleEvent(event)
    end

    local previousEngine = group.OnEventEngineStartup
    function group:OnEventEngineStartup(eventData)
      if previousEngine then pcall(previousEngine, self, eventData) end
      if not activeGroupEvent(groupName, eventData) then return end
      local unitName = eventUnitName(eventData)
      if setUnitEvent("EngineUnits", unitName) then
        ph1.Runtime.EngineStartCount = (ph1.Runtime.EngineStartCount or 0) + 1
        increment("engineStarts")
        log(string.format("EVENT testId=%s stage=ENGINE_START group=%s unit=%s count=%d", tostring(ph1.ActiveTestId), groupName, tostring(unitName), ph1.Runtime.EngineStartCount))
      end
    end

    local previousTakeoff = group.OnEventTakeoff
    function group:OnEventTakeoff(eventData)
      if previousTakeoff then pcall(previousTakeoff, self, eventData) end
      if not activeGroupEvent(groupName, eventData) then return end
      local unitName = eventUnitName(eventData)
      if setUnitEvent("TakeoffUnits", unitName) then
        ph1.Runtime.TakeoffCount = (ph1.Runtime.TakeoffCount or 0) + 1
        increment("takeoffs")
        log(string.format("EVENT testId=%s stage=TAKEOFF group=%s unit=%s count=%d", tostring(ph1.ActiveTestId), groupName, tostring(unitName), ph1.Runtime.TakeoffCount))
      end
    end

    local previousLand = group.OnEventLand
    function group:OnEventLand(eventData)
      if previousLand then pcall(previousLand, self, eventData) end
      if not activeGroupEvent(groupName, eventData) then return end
      local unitName = eventUnitName(eventData)
      local atBase, placeName = exactJalalabadPlace(eventData)
      if atBase then
        if setUnitEvent("LandedUnits", unitName) then
          ph1.Runtime.LandingCount = (ph1.Runtime.LandingCount or 0) + 1
          increment("landings")
        end
        ph1.Runtime.RTBObserved = true
        log(string.format("EVENT testId=%s stage=LAND_AT_JALALABAD_EXACT group=%s unit=%s place=%s count=%d", tostring(ph1.ActiveTestId), groupName, tostring(unitName), tostring(placeName), ph1.Runtime.LandingCount or 0))
      else
        ph1.Runtime.RemoteLandingCount = (ph1.Runtime.RemoteLandingCount or 0) + 1
        increment("remoteLandings")
        log(string.format("EVENT testId=%s stage=OPERATIONAL_LANDING group=%s unit=%s place=%s", tostring(ph1.ActiveTestId), groupName, tostring(unitName), tostring(placeName or "none")))
        if ph1.Logistics and ph1.Logistics.OnCarrierLanding then ph1.Logistics:OnCarrierLanding(groupName, eventData) end
      end
    end

    local previousShutdown = group.OnEventEngineShutdown
    function group:OnEventEngineShutdown(eventData)
      if previousShutdown then pcall(previousShutdown, self, eventData) end
      if not activeGroupEvent(groupName, eventData) then return end
      local unitName = eventUnitName(eventData)
      if setUnitEvent("ShutdownUnits", unitName) then
        ph1.Runtime.EngineShutdownCount = (ph1.Runtime.EngineShutdownCount or 0) + 1
        increment("engineShutdowns")
      end
    end

    local function loss(stage, eventData)
      if not activeGroupEvent(groupName, eventData) then return end
      local unitName = eventUnitName(eventData)
      if setUnitEvent("LostUnits", unitName) then
        increment("losses")
        ph1.Runtime.HardFailure = string.lower(stage) .. "-" .. tostring(unitName)
        log(string.format("ERROR EVENT testId=%s stage=%s group=%s unit=%s", tostring(ph1.ActiveTestId), stage, groupName, tostring(unitName)))
      end
    end
    local previousCrash = group.OnEventCrash
    function group:OnEventCrash(eventData)
      if previousCrash then pcall(previousCrash, self, eventData) end
      loss("CRASH", eventData)
    end
    local previousDead = group.OnEventDead
    function group:OnEventDead(eventData)
      if previousDead then pcall(previousDead, self, eventData) end
      loss("DEAD", eventData)
    end
  end

  local function attachFlightGroupCallbacks(groupName, flightgroup)
    if not flightgroup or flightgroup.OMWPhase1CallbacksAttached then return end
    flightgroup.OMWPhase1CallbacksAttached = true
    local previousRTB = flightgroup.OnAfterRTB
    function flightgroup:OnAfterRTB(from, event, to, airbase, speedTo, speedHold, speedLand)
      if previousRTB then pcall(previousRTB, self, from, event, to, airbase, speedTo, speedHold, speedLand) end
      if ph1.Runtime and ph1.Runtime.BoundGroupNames[groupName] then
        ph1.Runtime.RTBRequested = true
        log(string.format("FLIGHTGROUP_EVENT testId=%s stage=RTB_REQUESTED group=%s airbase=%s", tostring(ph1.ActiveTestId), groupName, tostring(objectName(airbase))))
      end
    end
    local previousDead = flightgroup.OnAfterDead
    function flightgroup:OnAfterDead(from, event, to)
      if previousDead then pcall(previousDead, self, from, event, to) end
      if ph1.Runtime and ph1.Runtime.BoundGroupNames[groupName] then ph1.Runtime.HardFailure = "flightgroup-dead-" .. groupName end
    end
  end

  function observer:BindFlightGroup(flightgroup, owner, source)
    if not ph1.Runtime or not ph1.ActiveDefinition or not flightgroup then return false end
    local groupName = flightGroupName(flightgroup)
    if not groupName then ph1.Runtime.HardFailure = "flightgroup-name-unavailable" return false end
    local group = GROUP and GROUP:FindByName(groupName) or nil
    if not group then ph1.Runtime.HardFailure = "flightgroup-wrapper-unavailable-" .. groupName return false end
    if not recordBoundGroupBirth(groupName, group) then return false end
    ph1.Runtime.FlightGroups[groupName] = flightgroup
    attachGroupEvents(groupName, group)
    attachFlightGroupCallbacks(groupName, flightgroup)
    if ph1.Routing and ph1.Routing.OnFlightGroupBound then ph1.Routing:OnFlightGroupBound(flightgroup, owner) end
    if ph1.Controller and ph1.Controller.OnFlightGroupBound then ph1.Controller:OnFlightGroupBound(flightgroup, owner, source) end
    return true
  end

  local previousFlightOnMission = cfg.Airwing.OnAfterFlightOnMission
  function cfg.Airwing:OnAfterFlightOnMission(from, event, to, flightgroup, mission)
    if previousFlightOnMission then pcall(previousFlightOnMission, self, from, event, to, flightgroup, mission) end
    if ph1.ActiveObject == mission and ph1.ActiveDefinition and ph1.ActiveDefinition.OperationKind == "AUFTRAG" then
      observer:BindFlightGroup(flightgroup, mission, "AIRWING_FLIGHT_ON_MISSION")
    end
  end

  log("READY sourceOfTruth=MOOSE_OBJECT_REFERENCES inventory=CountAssets/CountAssetsOnMission queue=CountMissionsInQueue lifecycle=object-scoped-GROUP+FLIGHTGROUP events nameMatching=ASSERTION_ONLY")
end
