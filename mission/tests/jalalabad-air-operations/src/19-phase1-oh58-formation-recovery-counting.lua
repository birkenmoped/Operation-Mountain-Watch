-- Operation Mountain Watch - Phase 1 package-contract enforcement and OH-58 recovery corridor
local TAG = "[OMW][AirOps.JBAD.PH1.PACKAGE]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local controller = ph1 and ph1.Controller
local factory = ph1 and ph1.Factory
local observer = ph1 and ph1.Observer

if not cfg or not ph1 or not controller or not factory or not observer then
  log("ERROR: Phase 1 runtime components unavailable.")
else
  ph1.Version = "JBAD-PHASE1-7"

  local function queueCount()
    local count = 0
    for _ in pairs((cfg.Airwing and cfg.Airwing.missionqueue) or {}) do count = count + 1 end
    return count
  end

  local function inventoryReady(snapshots)
    for key, expected in pairs(ph1.AssetGroupInventory or {}) do
      local item = snapshots and snapshots[key]
      if not item or item.total ~= expected or item.busy ~= 0 or item.available ~= expected then
        return false, string.format("%s total=%s available=%s busy=%s expectedAssetGroups=%d", key, item and item.total or "nil", item and item.available or "nil", item and item.busy or "nil", expected)
      end
    end
    return true
  end

  local function coalitionMessage(text, seconds)
    if trigger and trigger.action and trigger.action.outTextForCoalition then
      trigger.action.outTextForCoalition(coalition.side.BLUE, "OMW Jalalabad Phase 1\n" .. tostring(text), seconds or 15)
    end
  end

  function controller:InitializeWhenReady()
    if ph1.State ~= "WAITING_FOR_BASELINE" and ph1.State ~= "BLOCKED" then return true end
    if cfg.Status ~= "OPERATIONAL" or not cfg.Airwing then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = "Jalalabad AIRWING baseline not operational"
      return false
    end
    if cfg.PackageContractsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "package-contracts-invalid" return false end
    if cfg.ParkingReservationsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-reservation-regression" return false end
    if cfg.ParkingPoolsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-pools-invalid" return false end
    if cfg.NameContractOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "runtime-name-contract-invalid" return false end

    cfg.BaselineReady = true
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
    local ready, reason = inventoryReady(snapshots)
    if not ready then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = reason
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
    log("READY packageContracts=true assetGroups=OH58D:12/AH64D:4/UH60:8/CH47:8 testPackages=OH58D:1x2/AH64D:1x2/UH60:1x1/CH47:1x1")
    return true
  end

  function controller:StartTest(testId)
    if ph1.ActiveMission then coalitionMessage("Abgelehnt: Test aktiv: " .. tostring(ph1.ActiveTestId), 12) return false end
    if not self:InitializeWhenReady() then coalitionMessage("Nicht bereit: " .. tostring(ph1.BlockReason or ph1.State), 15) return false end

    local definition = ph1.Tests[testId]
    if not definition then coalitionMessage("Unbekannter Test: " .. tostring(testId), 10) return false end
    local package = cfg:GetTestPackageContract(testId)
    local squadron = package and cfg:GetSquadronContract(package.SquadronKey) or nil
    if not package or not squadron then coalitionMessage("Abgelehnt: Paketvertrag fehlt.", 15) return false end
    if definition.ExpectedGroups ~= package.RequiredGroups or definition.ExpectedAircraft ~= package.RequiredAircraft then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "test-definition-package-mismatch-" .. tostring(testId)
      return false
    end
    if definition.ExpectedAircraft ~= definition.ExpectedGroups * squadron.Grouping then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "grouping-package-arithmetic-mismatch-" .. tostring(testId)
      return false
    end

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
    ph1.ActiveDefinition = definition
    self:ResetRuntime(definition)
    ph1.BaselineInventory = snapshots
    observer:LogSnapshot("BEFORE_" .. testId, snapshots)

    local mission, createError = factory:Create(testId)
    if not mission then
      ph1.Runtime.PendingFailure = "mission-create-failed: " .. tostring(createError)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    ph1.ActiveMission = mission
    ph1.Counters.missionsCreated = (ph1.Counters.missionsCreated or 0) + 1
    ph1.State = "QUEUING"
    local ok, result = pcall(function() return cfg.Airwing:AddMission(mission) end)
    if not ok then
      ph1.Runtime.PendingFailure = "airwing-add-mission-failed: " .. tostring(result)
      self:FinalizeTest("FAIL", ph1.Runtime.PendingFailure, false)
      return false
    end

    ph1.Counters.missionsQueued = (ph1.Counters.missionsQueued or 0) + 1
    ph1.State = "ACTIVE"
    log(string.format("START testId=%s packageModel=%s squadronModel=%s expectedGroups=%d expectedAircraft=%d grouping=%d unitSuffixes=%s", testId, tostring(definition.PackageModel), tostring(definition.SquadronModel), definition.ExpectedGroups, definition.ExpectedAircraft, squadron.Grouping, table.concat(definition.ExpectedUnitSuffixes or {}, ",")))
    coalitionMessage("Gestartet: " .. definition.Label, 12)
    return true
  end

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
      ViaZone = ph1.Objects.ReconZones[1],
      AltitudeFeet = altitudeFeet,
      SpeedKnots = speedKnots,
      AppliedGroups = {}
    }
    log(string.format("RECOVERY_CORRIDOR_CONFIGURED route=RECON_03->RECON_02->RECON_01->Jalalabad altitude=%dft speed=%dkt directLastPointToBase=false", altitudeFeet, speedKnots))
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

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
  end

  local function applyRecoveryCorridor(mission, attempt)
    local runtime = ph1.Runtime
    if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "OH58D_RECON" or not runtime or not runtime.ReconRecoveryCorridor then return end
    local corridor = runtime.ReconRecoveryCorridor
    local zone1 = ZONE and ZONE:FindByName(corridor.ViaZone) or nil
    if not zone1 then runtime.HardFailure = "recovery-corridor-zone-unavailable" return end

    local ok, groups = pcall(function() return mission:GetOpsGroups() end)
    if ok then
      for _, opsgroup in pairs(groups or {}) do
        local groupName = opsGroupName(opsgroup)
        if groupName and not corridor.AppliedGroups[groupName] then
          local egressUID
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
              if opsgroup.UpdateRoute then pcall(function() opsgroup:UpdateRoute() end) end
              log(string.format("RECOVERY_CORRIDOR_APPLIED group=%s route=RECON_03->RECON_02->RECON_01->Jalalabad", groupName))
            end
          end
        end
      end
    end

    if countKeys(corridor.AppliedGroups) >= ph1.ActiveDefinition.ExpectedGroups then
      runtime.RecoveryCorridorApplied = true
      log("RECOVERY_CORRIDOR_READY expectedGroups=" .. tostring(ph1.ActiveDefinition.ExpectedGroups) .. " appliedGroups=" .. tostring(countKeys(corridor.AppliedGroups)))
      return
    end

    local nextAttempt = (attempt or 1) + 1
    if nextAttempt <= 30 then
      SCHEDULER:New(nil, function() applyRecoveryCorridor(mission, nextAttempt) end, {}, 2)
    else
      runtime.HardFailure = "recovery-corridor-not-applied"
      log("ERROR RECOVERY_CORRIDOR_FAILED attempts=" .. tostring(attempt or 1))
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

  local previousStatus = controller.GetStatusText
  function controller:GetStatusText()
    local text = previousStatus(self)
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if runtime and definition then
      if runtime.LandingCount == definition.ExpectedAircraft and runtime.LastPendingCriterion == "landing-count-mismatch" then
        runtime.LastPendingCriterion = "awaiting-inventory-release"
      end
      text = text .. "\nPackage: " .. tostring(definition.PackageModel)
      text = text .. "\nGroups/Aircraft: " .. tostring(definition.ExpectedGroups) .. "/" .. tostring(definition.ExpectedAircraft)
    end
    return text
  end

  log("READY version=JBAD-PHASE1-7 packageContractsEnforced=true OH58DPhysicalTwoShip=true AH64DPhysicalTwoShip=true UH60IndependentLeadGuardAssets=true CH47SingleShip=true")
end
