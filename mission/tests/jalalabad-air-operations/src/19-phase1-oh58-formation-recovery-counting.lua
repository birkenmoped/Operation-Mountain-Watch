-- Operation Mountain Watch - Phase 1 OH-58D physical two-ship, explicit recovery corridor and lifecycle correction
local TAG = "[OMW][AirOps.JBAD.PH1.OH58FIX]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local controller = ph1 and ph1.Controller
local factory = ph1 and ph1.Factory
local observer = ph1 and ph1.Observer
local handler = ph1 and ph1.EventHandler

if not cfg or not ph1 or not controller or not factory or not observer or not handler then
  log("ERROR: Phase 1 runtime components unavailable.")
else
  ph1.Version = "JBAD-PHASE1-6"

  local definition = ph1.Tests and ph1.Tests.OH58D_RECON
  if not definition then
    log("ERROR: OH58D_RECON definition unavailable.")
    return
  end

  definition.ExpectedGroups = 1
  definition.ExpectedAircraft = 2
  definition.ExpectedUnitSuffix = "-01"
  definition.ExpectedUnitSuffixes = { "-01", "-02" }
  definition.RecoveryCorridorZones = {
    ph1.Objects.ReconZones[2],
    ph1.Objects.ReconZones[1]
  }

  if cfg.Parking and cfg.Parking.SquadronPools and cfg.Parking.SquadronPools.OH58D then
    cfg.Parking.SquadronPools.OH58D.GroupSize = 2
  end
  if cfg.Parking then
    cfg.Parking.Model = "OH58D_PHYSICAL_TWO_SHIP_OTHER_SQUADRONS_SINGLE_SHIP_EXCLUSIVE_POOLS"
  end

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

  local function getGroupName(eventData)
    if eventData.IniGroupName then return eventData.IniGroupName end
    if eventData.IniGroup and eventData.IniGroup.GetName then
      local ok, value = pcall(function() return eventData.IniGroup:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function getUnitName(eventData)
    if eventData.IniUnitName then return eventData.IniUnitName end
    if eventData.IniUnit and eventData.IniUnit.GetName then
      local ok, value = pcall(function() return eventData.IniUnit:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function getTypeName(eventData)
    if eventData.IniTypeName then return eventData.IniTypeName end
    if eventData.IniUnit and eventData.IniUnit.GetTypeName then
      local ok, value = pcall(function() return eventData.IniUnit:GetTypeName() end)
      if ok then return value end
    end
    return nil
  end

  local function getCoordinate(eventData)
    if eventData.IniUnit and eventData.IniUnit.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniUnit:GetCoordinate() end)
      if ok then return value end
    end
    if eventData.IniGroup and eventData.IniGroup.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniGroup:GetCoordinate() end)
      if ok then return value end
    end
    return nil
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function coalitionMessage(text, seconds)
    if trigger and trigger.action and trigger.action.outTextForCoalition then
      trigger.action.outTextForCoalition(coalition.side.BLUE, "OMW Jalalabad Phase 1\n" .. tostring(text), seconds or 15)
    end
  end

  local function queueCount()
    local count = 0
    for _ in pairs((cfg.Airwing and cfg.Airwing.missionqueue) or {}) do count = count + 1 end
    return count
  end

  local expectedAssetGroups = { OH58D = 12, AH64D = 8, UH60 = 8, CH47 = 8 }

  local function inventoryReady(snapshots)
    for key, expected in pairs(expectedAssetGroups) do
      local item = snapshots and snapshots[key]
      if not item or item.total ~= expected or item.busy ~= 0 or item.available ~= expected then
        return false, string.format("%s total=%s available=%s busy=%s expected=%d", key, item and item.total or "nil", item and item.available or "nil", item and item.busy or "nil", expected)
      end
    end
    return true
  end

  -- The final readiness/start implementation must use the actual asset-group
  -- inventory: twelve two-aircraft OH-58D groups and single-aircraft groups for
  -- the remaining squadrons.
  function controller:InitializeWhenReady()
    if ph1.State ~= "WAITING_FOR_BASELINE" and ph1.State ~= "BLOCKED" then return true end
    if cfg.Status ~= "OPERATIONAL" or not cfg.Airwing then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = "Jalalabad AIRWING baseline not operational"
      return false
    end
    cfg.BaselineReady = true

    if cfg.ParkingReservationsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-reservation-regression" return false end
    if cfg.ParkingPoolsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-pools-invalid" return false end
    if cfg.NameContractOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "runtime-name-contract-invalid" return false end

    local objectsReady, missing = factory:ValidateMissionEditorObjects()
    if not objectsReady then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "missing Mission Editor objects: " .. table.concat(missing or {}, ",")
      return false
    end

    if not ph1.ClientParkingResolved and not observer:ResolveClientParkingIDs() then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "client-parking-unresolved"
      return false
    end

    local snapshots = observer:SnapshotAllSquadrons()
    local inventoryOK, inventoryReason = inventoryReady(snapshots)
    if not inventoryOK then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = inventoryReason
      return false
    end
    if queueCount() ~= 0 then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "pre-existing-airwing-mission-queue"
      return false
    end

    ph1.State = "READY"
    ph1.BlockReason = nil
    observer:LogSnapshot("PHASE1_READY", snapshots)
    log("READY inventoryAssetGroups=OH58D:12/AH64D:8/UH60:8/CH47:8 OH58Aircraft=24 OH58PhysicalTwoShip=true")
    return true
  end

  function controller:StartTest(testId)
    if ph1.ActiveMission then coalitionMessage("Abgelehnt: Test aktiv: " .. tostring(ph1.ActiveTestId), 12) return false end
    if not self:InitializeWhenReady() then coalitionMessage("Nicht bereit: " .. tostring(ph1.BlockReason or ph1.State), 15) return false end

    local testDefinition = ph1.Tests[testId]
    if not testDefinition then coalitionMessage("Unbekannter Test: " .. tostring(testId), 10) return false end
    if not testDefinition.ExpectedGroupPrefix or testDefinition.ExpectedGroupPrefix == "" then coalitionMessage("Abgelehnt: Runtime-Gruppenpräfix fehlt.", 15) return false end

    local testReady, testReason = factory:ValidateTestReady(testId, true)
    if not testReady then
      ph1.BlockReason = tostring(testId) .. ": " .. tostring(testReason)
      log("TEST_START_BLOCKED testId=" .. tostring(testId) .. " reason=" .. tostring(testReason))
      coalitionMessage("Nicht bereit: " .. tostring(ph1.BlockReason), 20)
      return false
    end

    if queueCount() ~= 0 then ph1.State = "BLOCKED" ph1.BlockReason = "airwing-mission-queue-not-empty" return false end

    local snapshots = observer:SnapshotAllSquadrons()
    local ready, reason = inventoryReady(snapshots)
    if not ready then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "inventory-not-clean: " .. tostring(reason)
      observer:LogSnapshot("START_BLOCKED", snapshots)
      coalitionMessage("Abgelehnt: Bestand nicht vollständig frei.", 15)
      return false
    end

    ph1.ActiveTestId = testId
    ph1.ActiveDefinition = testDefinition
    self:ResetRuntime(testDefinition)
    ph1.BaselineInventory = snapshots
    observer:LogSnapshot("BEFORE_" .. testId, snapshots)

    local mission, createError = factory:Create(testId)
    if not mission then
      ph1.Runtime.PendingFailure = "mission-create-failed: " .. tostring(createError)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    ph1.ActiveMission = mission
    increment("missionsCreated")
    ph1.State = "QUEUING"
    local ok, result = pcall(function() return cfg.Airwing:AddMission(mission) end)
    if not ok then
      ph1.Runtime.PendingFailure = "airwing-add-mission-failed: " .. tostring(result)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    increment("missionsQueued")
    ph1.State = "ACTIVE"
    log(string.format("START testId=%s squadron=%s expectedGroups=%d expectedAircraft=%d physicalGroupSize=%s", testId, testDefinition.SquadronKey, testDefinition.ExpectedGroups, testDefinition.ExpectedAircraft, testId == "OH58D_RECON" and "2" or "1"))
    coalitionMessage("Gestartet: " .. testDefinition.Label, 12)
    return true
  end

  -- MOOSE supports one mission egress coordinate. For the OH-58D mission the
  -- first recovery point is RECON_02. Once MOOSE has built the FLIGHTGROUP
  -- route, RECON_01 is inserted directly after that egress waypoint and before
  -- the existing Jalalabad landing waypoint. The resulting recovery route is:
  -- RECON_03 -> RECON_02 -> RECON_01 -> Jalalabad.
  local previousCreate = factory.Create
  function factory:Create(testId)
    local mission, createError = previousCreate(self, testId)
    if not mission or testId ~= "OH58D_RECON" then return mission, createError end

    local zone2 = ZONE and ZONE:FindByName(ph1.Objects.ReconZones[2]) or nil
    local zone1 = ZONE and ZONE:FindByName(ph1.Objects.ReconZones[1]) or nil
    if not zone2 or not zone1 then return nil, "OH-58D recovery corridor zones unavailable" end
    if not mission.SetMissionEgressCoord then return nil, "AUFTRAG:SetMissionEgressCoord unavailable" end

    local altitudeFeet = ph1.ReconProfile and ph1.ReconProfile.AltitudeFeet or 6000
    local speedKnots = ph1.OperationalPolicy and ph1.OperationalPolicy.Recon and ph1.OperationalPolicy.Recon.SpeedKnots or 80
    mission:SetMissionEgressCoord(zone2:GetCoordinate(), altitudeFeet, speedKnots)
    if mission.SetFormation then mission:SetFormation("Vee") end

    ph1.Runtime.ReconRecoveryCorridor = {
      EgressZone = ph1.Objects.ReconZones[2],
      ViaZone = ph1.Objects.ReconZones[1],
      AltitudeFeet = altitudeFeet,
      SpeedKnots = speedKnots,
      AppliedGroups = {}
    }
    log(string.format("RECOVERY_CORRIDOR_CONFIGURED route=%s->%s->Jalalabad altitude=%dft speed=%dkt directLastPointToBase=false", ph1.Objects.ReconZones[2], ph1.Objects.ReconZones[1], altitudeFeet, speedKnots))
    return mission
  end

  local function opsGroupName(opsgroup)
    if not opsgroup then return nil end
    if opsgroup.groupname then return opsgroup.groupname end
    if opsgroup.GetName then
      local ok, value = pcall(function() return opsgroup:GetName() end)
      if ok then return value end
    end
    if opsgroup.group and opsgroup.group.GetName then
      local ok, value = pcall(function() return opsgroup.group:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function applyRecoveryCorridor(mission, attempt)
    local runtime = ph1.Runtime
    if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "OH58D_RECON" or not runtime or not runtime.ReconRecoveryCorridor then return end

    local corridor = runtime.ReconRecoveryCorridor
    local zone1 = ZONE and ZONE:FindByName(corridor.ViaZone) or nil
    if not zone1 then
      runtime.HardFailure = "recovery-corridor-zone-unavailable"
      return
    end

    local ok, groups = pcall(function() return mission:GetOpsGroups() end)
    local pending = 0
    local applied = 0
    if ok then
      for _, opsgroup in pairs(groups or {}) do
        local groupName = opsGroupName(opsgroup)
        if groupName and not corridor.AppliedGroups[groupName] then
          local egressUID = nil
          if mission.GetGroupEgressWaypointUID then
            local uidOK, value = pcall(function() return mission:GetGroupEgressWaypointUID(opsgroup) end)
            if uidOK then egressUID = value end
          end
          if egressUID and opsgroup.AddWaypoint then
            local addOK, waypoint = pcall(function()
              return opsgroup:AddWaypoint(zone1:GetCoordinate(), corridor.SpeedKnots, egressUID, corridor.AltitudeFeet, false)
            end)
            if addOK and waypoint then
              corridor.AppliedGroups[groupName] = true
              applied = applied + 1
              log(string.format("RECOVERY_CORRIDOR_APPLIED group=%s afterEgressUID=%s via=%s then=Jalalabad", groupName, tostring(egressUID), corridor.ViaZone))
            else
              pending = pending + 1
            end
          else
            pending = pending + 1
          end
        end
      end
    else
      pending = 1
    end

    if countKeys(corridor.AppliedGroups) >= definition.ExpectedGroups then
      runtime.RecoveryCorridorApplied = true
      log("RECOVERY_CORRIDOR_READY expectedGroups=1 appliedGroups=" .. tostring(countKeys(corridor.AppliedGroups)) .. " route=RECON_03->RECON_02->RECON_01->Jalalabad")
      return
    end

    local nextAttempt = (attempt or 1) + 1
    if nextAttempt <= 30 then
      SCHEDULER:New(nil, function() applyRecoveryCorridor(mission, nextAttempt) end, {}, 2)
    else
      runtime.HardFailure = "recovery-corridor-not-applied"
      log("ERROR RECOVERY_CORRIDOR_FAILED attempts=" .. tostring(attempt or 1) .. " pending=" .. tostring(pending) .. " newlyApplied=" .. tostring(applied))
    end
  end

  local previousOnMissionState = controller.OnMissionState
  function controller:OnMissionState(state, mission, from, event, to)
    local result = previousOnMissionState(self, state, mission, from, event, to)
    if mission == ph1.ActiveMission and ph1.ActiveTestId == "OH58D_RECON" and (state == "SCHEDULED" or state == "STARTED") then
      SCHEDULER:New(nil, function() applyRecoveryCorridor(mission, 1) end, {}, 1)
    end
    return result
  end

  -- Exact event handling for the physical two-ship. Both unit names belong to
  -- the same exact MOOSE AID group: <group>-01 and <group>-02.
  local function isAuthoringName(groupName, unitName)
    return (groupName and cfg.AuthoringGroupNames and cfg.AuthoringGroupNames[groupName] == true) or
           (unitName and cfg.AuthoringUnitNames and cfg.AuthoringUnitNames[unitName] ~= nil)
  end

  local function suffixAllowed(testDefinition, groupName, unitName)
    if not testDefinition or not startsWith(groupName, testDefinition.ExpectedGroupPrefix) then return false end
    for _, suffix in ipairs(testDefinition.ExpectedUnitSuffixes or { testDefinition.ExpectedUnitSuffix or "-01" }) do
      if unitName == groupName .. suffix then return true end
    end
    return false
  end

  local function ensureExpectedGroup(groupName, testDefinition)
    local runtime = ph1.Runtime
    if not runtime or not groupName then return false end
    if runtime.ExpectedGroupNames[groupName] then return true end
    if countKeys(runtime.ExpectedGroupNames) >= testDefinition.ExpectedGroups then
      runtime.HardFailure = "too-many-exact-runtime-groups"
      return false
    end
    runtime.ExpectedGroupNames[groupName] = true
    runtime.ExpectedUnitNames = runtime.ExpectedUnitNames or {}
    for _, suffix in ipairs(testDefinition.ExpectedUnitSuffixes or { testDefinition.ExpectedUnitSuffix or "-01" }) do
      runtime.ExpectedUnitNames[groupName .. suffix] = groupName
    end
    log("MISSION_GROUP group=" .. groupName .. " expectedUnits=" .. table.concat(testDefinition.ExpectedUnitSuffixes or { testDefinition.ExpectedUnitSuffix or "-01" }, ","))
    return true
  end

  local function expectedEvent(eventData)
    local testDefinition = ph1.ActiveDefinition
    local runtime = ph1.Runtime
    if not ph1.ActiveMission or not runtime or not testDefinition then return false end
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    if isAuthoringName(groupName, unitName) then return false end
    if typeName ~= testDefinition.ExpectedType then return false end
    if not suffixAllowed(testDefinition, groupName, unitName) then return false end
    if not ensureExpectedGroup(groupName, testDefinition) then return false end
    return runtime.ExpectedUnitNames and runtime.ExpectedUnitNames[unitName] == groupName
  end

  local function setUnitEvent(bucket, unitName)
    local runtime = ph1.Runtime
    if not runtime or not unitName then return false end
    runtime[bucket] = runtime[bucket] or {}
    if runtime[bucket][unitName] then return false end
    runtime[bucket][unitName] = true
    return true
  end

  local function nearestParking(coordinate)
    local nearestId, nearestDistance
    for _, spot in ipairs((cfg.Airbase and cfg.Airbase:GetParkingSpotsTable()) or {}) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then nearestId, nearestDistance = spot.TerminalID, distance end
    end
    return nearestId, nearestDistance
  end

  local function nearestStatic(coordinate)
    local nearestName, nearestDistance
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      for _, name in ipairs((cfg.Statics and cfg.Statics[key]) or {}) do
        local static = STATIC and STATIC:FindByName(name, false) or nil
        if static then
          local distance = distance2D(coordinate, static:GetCoordinate())
          if distance and (not nearestDistance or distance < nearestDistance) then nearestName, nearestDistance = name, distance end
        end
      end
    end
    return nearestName, nearestDistance
  end

  local function registerExpectedEvent(stage, bucket, counter, eventData)
    if not expectedEvent(eventData) then return false end
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    if setUnitEvent(bucket, unitName) then
      increment(counter)
      ph1.Runtime[stage .. "Count"] = (ph1.Runtime[stage .. "Count"] or 0) + 1
      log(string.format("EVENT testId=%s stage=%s group=%s unit=%s type=%s count=%d", tostring(ph1.ActiveTestId), stage, groupName, unitName, typeName, ph1.Runtime[stage .. "Count"]))
    end
    return true
  end

  function handler:OnEventBirth(eventData)
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    local coordinate = getCoordinate(eventData)

    if expectedEvent(eventData) then
      if setUnitEvent("BornUnits", unitName) then
        increment("aircraftSpawned")
        ph1.Runtime.BirthCount = (ph1.Runtime.BirthCount or 0) + 1
      end
      local newGroup = not ph1.Runtime.BornGroupNames[groupName]
      ph1.Runtime.BornGroupNames[groupName] = true
      if newGroup then increment("groupsSpawned") end

      local testDefinition = ph1.ActiveDefinition
      if ph1.Runtime.BirthCount > testDefinition.ExpectedAircraft then ph1.Runtime.HardFailure = "unexpected-aircraft-count-" .. tostring(ph1.Runtime.BirthCount) end
      if countKeys(ph1.Runtime.BornGroupNames) > testDefinition.ExpectedGroups then ph1.Runtime.HardFailure = "unexpected-group-count-" .. tostring(countKeys(ph1.Runtime.BornGroupNames)) end

      local terminalId, parkingDistance = nearestParking(coordinate)
      local staticName, staticDistance = nearestStatic(coordinate)
      local poolKey = testDefinition.ParkingPoolKey or testDefinition.SquadronKey
      local allowed = cfg.ParkingPoolTerminalIDs and cfg.ParkingPoolTerminalIDs[poolKey] or nil
      log(string.format("EVENT testId=%s stage=SPAWN group=%s unit=%s type=%s TerminalID=%s parkingDistance=%s", tostring(ph1.ActiveTestId), groupName, unitName, typeName, tostring(terminalId), parkingDistance and string.format("%.1fm", parkingDistance) or "unknown"))

      if not terminalId or not parkingDistance or parkingDistance > ph1.Limits.ParkingBirthMatchMeters or not allowed or not allowed[terminalId] then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-outside-squadron-pool-" .. tostring(terminalId)
      else
        log(string.format("SPAWN_POOL_CONFIRMED group=%s unit=%s label=%s TerminalID=%s", groupName, unitName, tostring(cfg:GetSquadronParkingLabel(poolKey, terminalId)), tostring(terminalId)))
      end
      if terminalId and ph1.ClientParkingIDs and ph1.ClientParkingIDs[terminalId] then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-on-client-terminal-" .. tostring(terminalId)
      end
      if staticDistance and staticDistance < ph1.Limits.StaticSpawnClearanceMeters then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-too-close-to-static-" .. tostring(staticName)
      end
      if controller.OnExpectedBirth then controller:OnExpectedBirth(groupName, unitName, typeName) end
      return
    end

    if isAuthoringName(groupName, unitName) then return end
    local managed = false
    for _, prefix in pairs(cfg.RuntimeGroupPrefixes or {}) do
      if startsWith(groupName, prefix) then managed = true break end
    end
    local nearBase = observer:IsNearJalalabad(coordinate)
    if ph1.ActiveMission and managed and nearBase then
      increment("unexpectedSpawns")
      ph1.Runtime.HardFailure = "unexpected-managed-spawn-" .. tostring(groupName)
      log("ERROR UNEXPECTED_MANAGED_SPAWN group=" .. tostring(groupName) .. " unit=" .. tostring(unitName))
    end
  end

  function handler:OnEventEngineStartup(eventData) registerExpectedEvent("EngineStart", "EngineUnits", "engineStarts", eventData) end
  function handler:OnEventTakeoff(eventData) registerExpectedEvent("Takeoff", "TakeoffUnits", "takeoffs", eventData) end

  function handler:OnEventLand(eventData)
    if not expectedEvent(eventData) then return end
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local nearBase, distance = observer:IsNearJalalabad(getCoordinate(eventData), ph1.Limits.RTBDetectionRadiusMeters)
    if nearBase then
      if setUnitEvent("LandedUnits", unitName) then
        increment("landings")
        ph1.Runtime.LandingCount = (ph1.Runtime.LandingCount or 0) + 1
      end
      ph1.Runtime.RTBObserved = true
      log(string.format("EVENT testId=%s stage=LAND_AT_JALALABAD group=%s unit=%s distance=%.0fm count=%d expected=%d", tostring(ph1.ActiveTestId), groupName, unitName, distance or -1, ph1.Runtime.LandingCount or 0, ph1.ActiveDefinition.ExpectedAircraft))
    else
      ph1.Runtime.RemoteLandingCount = (ph1.Runtime.RemoteLandingCount or 0) + 1
      increment("remoteLandings")
      log("EVENT stage=REMOTE_LANDING group=" .. tostring(groupName) .. " unit=" .. tostring(unitName))
    end
  end

  function handler:OnEventEngineShutdown(eventData) registerExpectedEvent("EngineShutdown", "ShutdownUnits", "engineShutdowns", eventData) end

  local function handleLoss(stage, eventData)
    if expectedEvent(eventData) then
      local unitName = getUnitName(eventData)
      increment("losses")
      ph1.Runtime.HardFailure = string.lower(stage) .. "-" .. tostring(unitName)
      log("ERROR EVENT stage=" .. stage .. " unit=" .. tostring(unitName))
    end
  end
  function handler:OnEventCrash(eventData) handleLoss("CRASH", eventData) end
  function handler:OnEventDead(eventData) handleLoss("DEAD", eventData) end

  local previousPollActive = controller.PollActive
  function controller:PollActive()
    previousPollActive(self)
    local runtime = ph1.Runtime
    local activeDefinition = ph1.ActiveDefinition
    if not runtime or not activeDefinition then return end

    local lifecycleOK, lifecycleReason = self:LifecycleSatisfied()
    if lifecycleOK then
      if (runtime.ReleaseStablePolls or 0) < ph1.Limits.ReleaseStablePolls then
        runtime.LastPendingCriterion = "awaiting-inventory-release"
      else
        runtime.LastPendingCriterion = nil
      end
    else
      runtime.LastPendingCriterion = lifecycleReason
    end
  end

  log("READY version=JBAD-PHASE1-6 OH58PhysicalTwoShip=true expectedGroups=1 expectedAircraft=2 exactUnits=-01,-02 recoveryRoute=RECON_03->RECON_02->RECON_01->Jalalabad staleLandingStatusFixed=true")
end
