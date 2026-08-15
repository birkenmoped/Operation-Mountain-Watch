local TEST_ID = "AAR-PRODUCTION-FINAL-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local POLL_SEC = 5
local TIMEOUT_SEC = 900
local SOURCE_SPACING_TOLERANCE_SEC = 2
local LOSS_EXPLOSION_POWER = 1000

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message))
  error(TAG .. " " .. tostring(message), 2)
end

local function assertTrue(condition, message)
  if not condition then fail(message) end
end

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    fail(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function normalizeCallsign(value)
  if type(value) ~= "string" then return nil end
  return value:gsub("[%s%-]", "")
end

local function makeDemand(id, profile, area, mode)
  return {
    missionDemandId = id,
    receiverProfile = profile,
    operationsArea = area,
    supportMode = mode,
    priority = "FINAL_ACCEPTANCE",
  }
end

local function pool(adapter, source)
  return adapter:GetPoolStatus(source)
end

local function assertPool(adapter, source, quantity, lost, label)
  local status = pool(adapter, source)
  assertEqual(status.quantity, quantity, label .. ".quantity")
  assertEqual(status.available, quantity, label .. ".available")
  assertEqual(status.lost, lost, label .. ".lost")
end

local function buildStore()
  local created = OMW_AAR_TEST_Initializer.CreateStore(
    OMW_AAR_TEST_CampaignState,
    OMW_AAR_TEST_StrategicStock
  )
  return created.store
end

local function runRestoreReconciliationChecks()
  local selection = {
    missionDemandId = "AAR-RESTORE-UNRESOLVED",
    sourceDomain = "MANAS",
  }

  local store = buildStore()
  local adapter = OMW_AAR_TEST_Adapter.New(store, OMW_AAR_TEST_CampaignState)
  adapter:OnMaterialized(selection, { runtimeId = "AAR-RESTORE-0001" })
  assertPool(adapter, "MANAS", 15, 0, "restore.preSnapshot")

  local snapshot = store:ExportSnapshot()
  local restoredStore = OMW_AAR_TEST_CampaignState.Restore(snapshot)
  local captureController = { adapter = nil }
  function captureController:SetStrategicAdapter(value)
    self.adapter = value
  end

  local attached = OMW_AAR_TEST_RuntimeIntegration.Attach({
    store = restoredStore,
    campaignState = OMW_AAR_TEST_CampaignState,
    adapterModule = OMW_AAR_TEST_Adapter,
    controller = captureController,
    restored = true,
  })

  assertEqual(attached.reconciliation.reconciled, 1, "restore.reconciled")
  assertEqual(attached.reconciliation.preservedLosses, 0, "restore.preservedLosses")
  assertPool(attached.adapter, "MANAS", 16, 0, "restore.firstAttach")

  local second = attached.adapter:ReconcileRestore()
  assertEqual(second.reconciled, 0, "restore.second.reconciled")
  assertEqual(second.alreadyResolved, 1, "restore.second.alreadyResolved")
  assertPool(attached.adapter, "MANAS", 16, 0, "restore.secondAttach")

  local lossStore = buildStore()
  local lossAdapter = OMW_AAR_TEST_Adapter.New(lossStore, OMW_AAR_TEST_CampaignState)
  local lossSelection = {
    missionDemandId = "AAR-RESTORE-LOSS",
    sourceDomain = "AL_UDEID",
  }
  local lossRuntime = { runtimeId = "AAR-RESTORE-LOSS-0001" }
  lossAdapter:OnMaterialized(lossSelection, lossRuntime)
  lossAdapter:OnLost(lossSelection, lossRuntime, "TEST_PERSISTED_LOSS")
  assertPool(lossAdapter, "AL_UDEID", 39, 1, "restore.loss.preSnapshot")

  local lossSnapshot = lossStore:ExportSnapshot()
  local restoredLossStore = OMW_AAR_TEST_CampaignState.Restore(lossSnapshot)
  local lossCapture = {}
  function lossCapture:SetStrategicAdapter(value) self.adapter = value end
  local attachedLoss = OMW_AAR_TEST_RuntimeIntegration.Attach({
    store = restoredLossStore,
    campaignState = OMW_AAR_TEST_CampaignState,
    adapterModule = OMW_AAR_TEST_Adapter,
    controller = lossCapture,
    restored = true,
  })
  assertEqual(attachedLoss.reconciliation.preservedLosses, 1, "restore.loss.preservedLosses")
  assertEqual(attachedLoss.reconciliation.reconciled, 0, "restore.loss.reconciled")
  assertPool(attachedLoss.adapter, "AL_UDEID", 39, 1, "restore.loss.restored")

  log("RESTORE_RECONCILIATION_PASS unresolvedCreditOnce=true duplicateCredit=false persistedLossPreserved=true")
end

assertTrue(OMW_AAR_TEST_CampaignState ~= nil, "CampaignState test module unavailable")
assertTrue(OMW_AAR_TEST_StrategicStock ~= nil, "AAR strategic stock test module unavailable")
assertTrue(OMW_AAR_TEST_Initializer ~= nil, "CampaignState initializer test module unavailable")
assertTrue(OMW_AAR_TEST_Adapter ~= nil, "AAR CampaignState adapter test module unavailable")
assertTrue(OMW_AAR_TEST_RuntimeIntegration ~= nil, "AAR RuntimeIntegration test module unavailable")
assertTrue(OMW and OMW.AAR, "production AAR controller unavailable")

runRestoreReconciliationChecks()

local liveStore = buildStore()
local live = OMW_AAR_TEST_RuntimeIntegration.Attach({
  store = liveStore,
  campaignState = OMW_AAR_TEST_CampaignState,
  adapterModule = OMW_AAR_TEST_Adapter,
  controller = OMW.AAR,
  restored = false,
})
local adapter = live.adapter

assertPool(adapter, "MANAS", 16, 0, "live.initial.MANAS")
assertPool(adapter, "AL_UDEID", 40, 0, "live.initial.AL_UDEID")
log("POOL_BASELINE_PASS MANAS=16 AL_UDEID=40")

local D = {
  NELSON = makeDemand("AAR-FINAL-NELSON", "FAST", "NORTHEAST", "SUPPORT"),
  KRUSTY = makeDemand("AAR-FINAL-KRUSTY", "SLOW", "SOUTHEAST", "RECOVERY"),
  PATTY = makeDemand("AAR-FINAL-PATTY", "SLOW", "EAST", "SUPPORT"),
  MOE = makeDemand("AAR-FINAL-MOE", "FAST", "CENTRAL", "SUPPORT"),
}

local phase = 1
local phaseStartedAt = timer.getAbsTime()
local startedAt = phaseStartedAt
local observed = {
  initialSpawnAt = {},
  initialRuntimeId = {},
  nelsonReliefId = nil,
  pattyReliefId = nil,
  pattyLossPoolBefore = nil,
}

local function setPhase(nextPhase, marker)
  phase = nextPhase
  phaseStartedAt = timer.getAbsTime()
  log(string.format("PHASE_%02d %s", nextPhase, marker or ""))
end

local function getRuntime(area, profile)
  return OMW.AAR.GetActive(area, profile)
end

local function getStation(area, profile)
  return OMW.AAR.GetStation(area, profile)
end

local function runtimeIdentityKey(runtime)
  if not runtime or not runtime.transitCallsign then return nil end
  return string.format("%s:%d:%05d", runtime.transitCallsign.name, runtime.transitCallsign.number, runtime.transitCallsign.stn)
end

local function assertUniqueRuntimeIdentities(runtimes, label)
  local seenCallsign = {}
  local seenStn = {}
  local count = 0
  for _, runtime in ipairs(runtimes) do
    if runtime and not runtime.handoffComplete and not runtime.lossHandled then
      count = count + 1
      local transit = runtime.transitCallsign
      assertTrue(transit ~= nil, label .. " missing transit identity")
      local callsignKey = transit.name .. tostring(transit.number)
      assertTrue(not seenCallsign[callsignKey], label .. " duplicate transit callsign=" .. callsignKey)
      assertTrue(not seenStn[transit.stn], label .. " duplicate STN=" .. tostring(transit.stn))
      seenCallsign[callsignKey] = true
      seenStn[transit.stn] = true
    end
  end
  return count
end

local function forceControlledTrackEntry(runtime)
  assertTrue(runtime and runtime.flightGroup and runtime.flightGroup:IsAlive(), "controlled track entry requires alive runtime")
  local current = runtime.flightGroup:GetCoordinate()
  assertTrue(current ~= nil, "controlled track entry current coordinate unavailable")
  runtime.trackCoord = current
end

local function verifyStationCallsign(runtime, expected, label)
  local actual = runtime and runtime.group and runtime.group:GetCallsign() or nil
  assertEqual(normalizeCallsign(actual), normalizeCallsign(expected), label)
end

local function elapsedPhase() return timer.getAbsTime() - phaseStartedAt end

local submit1, status1 = OMW.AAR.SubmitDemand(D.NELSON)
assertTrue(submit1 ~= nil, "NELSON submit failed status=" .. tostring(status1))
local submit2, status2 = OMW.AAR.SubmitDemand(D.KRUSTY)
assertTrue(submit2 ~= nil, "KRUSTY submit failed status=" .. tostring(status2))
log("PHASE_01 INITIAL_PARALLEL_SUBMIT NELSON=" .. tostring(status1) .. " KRUSTY=" .. tostring(status2))

SCHEDULER:New(nil, function()
  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    fail("TIMEOUT phase=" .. tostring(phase))
  end

  if phase == 1 then
    local nelson = getRuntime("NELSON", "FAST")
    local krusty = getRuntime("KRUSTY", "SLOW")
    if nelson and krusty then
      observed.initialSpawnAt.NELSON = observed.initialSpawnAt.NELSON or timer.getAbsTime()
      observed.initialSpawnAt.KRUSTY = observed.initialSpawnAt.KRUSTY or timer.getAbsTime()
      observed.initialRuntimeId.NELSON = nelson.runtimeId
      observed.initialRuntimeId.KRUSTY = krusty.runtimeId
      local counts = OMW.AAR.GetRuntimeCounts()
      assertEqual(counts.supportMissions, 2, "initial.supportMissions")
      assertEqual(counts.supportAircraft, 2, "initial.supportAircraft")
      assertPool(adapter, "MANAS", 15, 0, "initial.MANAS")
      assertPool(adapter, "AL_UDEID", 39, 0, "initial.AL_UDEID")
      assertUniqueRuntimeIdentities({ nelson, krusty }, "initialIdentity")
      verifyStationCallsign(nelson, nelson.transitCallsign.name .. nelson.transitCallsign.number .. "1", "NELSON transit callsign")
      verifyStationCallsign(krusty, krusty.transitCallsign.name .. krusty.transitCallsign.number .. "1", "KRUSTY transit callsign")
      local delta = math.abs(observed.initialSpawnAt.NELSON - observed.initialSpawnAt.KRUSTY)
      assertTrue(delta <= POLL_SEC + SOURCE_SPACING_TOLERANCE_SEC,
        "MANAS/AL_UDEID initial materialization did not occur in parallel deltaSec=" .. tostring(delta))
      log(string.format("SOURCE_INDEPENDENCE_PASS deltaSec=%.1f missions=2 aircraft=2", delta))

      local result3, status3 = OMW.AAR.SubmitDemand(D.PATTY)
      assertTrue(result3 ~= nil, "PATTY submit failed")
      log("THIRD_MISSION_SUBMITTED status=" .. tostring(status3))
      setPhase(2, "MISSION_CONCURRENCY_BLOCK")
    end

  elseif phase == 2 then
    if elapsedPhase() >= 15 then
      local counts = OMW.AAR.GetRuntimeCounts()
      assertEqual(counts.supportMissions, 2, "missionLimit.supportMissions")
      assertEqual(counts.supportAircraft, 2, "missionLimit.supportAircraft")
      assertTrue(getRuntime("PATTY", "SLOW") == nil, "PATTY materialized despite 2-mission limit")
      assertTrue(counts.queued >= 1, "third mission was not retained in queue")
      log("CONCURRENCY_MISSION_LIMIT_PASS maxMissions=2 thirdDemandQueued=true")

      local _, endStatus = OMW.AAR.EndDemand(D.KRUSTY, "ABORTED")
      assertEqual(endStatus, "STATION_CLOSED", "KRUSTY abort status")
      setPhase(3, "ABORT_HANDOFF_AND_PATTY_RELEASE")
    end

  elseif phase == 3 then
    local krusty = getRuntime("KRUSTY", "SLOW")
    local patty = getRuntime("PATTY", "SLOW")
    local al = pool(adapter, "AL_UDEID")
    if not krusty and al.quantity == 40 and patty then
      assertEqual(al.lost, 0, "abort AL_UDEID lost")
      log("ABORT_HANDOFF_PASS status=ABORTED gateHandoff=true exactRecredit=true")

      forceControlledTrackEntry(getRuntime("NELSON", "FAST"))
      forceControlledTrackEntry(patty)
      setPhase(4, "CONTROLLED_TRACK_ENTRY")
    end

  elseif phase == 4 then
    local nelson = getRuntime("NELSON", "FAST")
    local patty = getRuntime("PATTY", "SLOW")
    local ns = getStation("NELSON", "FAST")
    local ps = getStation("PATTY", "SLOW")
    if nelson and patty and nelson.stationIdentityActive and patty.stationIdentityActive then
      verifyStationCallsign(nelson, "Texaco11", "NELSON station callsign")
      verifyStationCallsign(patty, "Texaco21", "PATTY station callsign")
      log("STATION_IDENTITY_PASS controlledTrackEntry=true callsignSwitch=true radioTacanCommands=productionPath")

      ns.reliefLaunchAt = timer.getAbsTime()
      ps.reliefLaunchAt = timer.getAbsTime()
      ns.nextPlannedHandoverAt = timer.getAbsTime() + 300
      ps.nextPlannedHandoverAt = timer.getAbsTime() + 300
      setPhase(5, "SCHEDULED_RELIEF_QUEUE")
    end

  elseif phase == 5 then
    local ns = getStation("NELSON", "FAST")
    local ps = getStation("PATTY", "SLOW")
    if ns and ps and ns.reliefRuntime and ps.reliefRuntime then
      observed.nelsonReliefId = ns.reliefRuntime.runtimeId
      observed.pattyReliefId = ps.reliefRuntime.runtimeId
      local counts = OMW.AAR.GetRuntimeCounts()
      assertEqual(counts.supportMissions, 2, "relief.supportMissions")
      assertEqual(counts.supportAircraft, 4, "relief.supportAircraft")
      assertUniqueRuntimeIdentities({ ns.activeRuntime, ns.reliefRuntime, ps.activeRuntime, ps.reliefRuntime }, "fourAircraftIdentity")
      log("CONCURRENCY_2_2_4_PASS missions=2 aircraftPerMission=2 aircraftGlobal=4 uniqueTransitIdentity=true")

      local result4, status4 = OMW.AAR.SubmitDemand(D.MOE)
      assertTrue(result4 ~= nil, "MOE submit failed")
      log("FOURTH_MISSION_SUBMITTED status=" .. tostring(status4))
      setPhase(6, "GLOBAL_LIMIT_AND_FUELLOW")
    end

  elseif phase == 6 then
    if elapsedPhase() >= 15 then
      local counts = OMW.AAR.GetRuntimeCounts()
      assertEqual(counts.supportMissions, 2, "globalLimit.supportMissions")
      assertEqual(counts.supportAircraft, 4, "globalLimit.supportAircraft")
      assertTrue(getRuntime("MOE", "FAST") == nil, "MOE materialized despite 2/2/4 limits")
      log("CONCURRENCY_GLOBAL_LIMIT_PASS fourthMissionQueued=true aircraft=4")

      local ns = getStation("NELSON", "FAST")
      assertTrue(ns and ns.activeRuntime and ns.reliefRuntime, "NELSON active/relief missing before FuelLow")
      local reliefId = ns.reliefRuntime.runtimeId
      ns.activeRuntime.flightGroup:FuelLow()
      assertEqual(ns.reliefRuntime.runtimeId, reliefId, "FuelLow reused relief")
      assertTrue(ns.activeRuntime.egressOrdered, "FuelLow did not order outgoing egress")
      log("FUEL_LOW_RELIEF_PASS existingReliefReused=true duplicateRelief=false outgoingEgress=true")

      forceControlledTrackEntry(ns.reliefRuntime)
      setPhase(7, "FUELLOW_RELIEF_HANDOVER")
    end

  elseif phase == 7 then
    local ns = getStation("NELSON", "FAST")
    if ns and ns.activeRuntime and ns.activeRuntime.runtimeId == observed.nelsonReliefId
        and ns.activeRuntime.stationIdentityActive then
      verifyStationCallsign(ns.activeRuntime, "Texaco11", "NELSON relief station callsign")
      log("FUEL_LOW_HANDOVER_PASS reliefPromoted=true stationIdentityTransferred=true")

      local ps = getStation("PATTY", "SLOW")
      assertTrue(ps and ps.reliefRuntime, "PATTY scheduled relief missing")
      forceControlledTrackEntry(ps.reliefRuntime)
      setPhase(8, "SCHEDULED_RELIEF_HANDOVER")
    end

  elseif phase == 8 then
    local ps = getStation("PATTY", "SLOW")
    if ps and ps.activeRuntime and ps.activeRuntime.runtimeId == observed.pattyReliefId
        and ps.activeRuntime.stationIdentityActive then
      verifyStationCallsign(ps.activeRuntime, "Texaco21", "PATTY relief station callsign")
      log("SCHEDULED_RELIEF_PASS controlledTiming=true outgoingIdentityOff=true reliefIdentityOn=true")

      local before = pool(adapter, "MANAS")
      observed.pattyLossPoolBefore = before.quantity
      local unit = ps.activeRuntime.group and ps.activeRuntime.group:GetUnit(1) or nil
      assertTrue(unit and unit:IsAlive(), "PATTY loss target unit unavailable")
      unit:Explode(LOSS_EXPLOSION_POWER)
      log("LOSS_INJECTION_ARMED method=MOOSE_UNIT_EXPLODE powerKgTNT=" .. tostring(LOSS_EXPLOSION_POWER))
      setPhase(9, "AIRCRAFT_LOSS")
    end

  elseif phase == 9 then
    local manas = pool(adapter, "MANAS")
    if manas.lost == 1 then
      assertEqual(manas.quantity, observed.pattyLossPoolBefore, "loss no aircraft recredit")
      log("AIRCRAFT_LOSS_PASS deadCallback=true aircraftRecredit=false lossAudit=1")
      local _, cancelStatus = OMW.AAR.EndDemand(D.PATTY, "CANCELLED")
      assertEqual(cancelStatus, "STATION_CLOSED", "PATTY cancel status")
      local _, completeStatus = OMW.AAR.EndDemand(D.MOE, "COMPLETE")
      assertEqual(completeStatus, "STATION_CLOSED", "MOE complete status")
      local _, abortStatus = OMW.AAR.EndDemand(D.NELSON, "ABORTED")
      assertEqual(abortStatus, "STATION_CLOSED", "NELSON final abort status")
      log("DEMAND_END_PASS complete=true cancelled=true aborted=true immediateClose=true")
      setPhase(10, "FINAL_SETTLEMENT")
    end

  elseif phase == 10 then
    local counts = OMW.AAR.GetRuntimeCounts()
    local manas = pool(adapter, "MANAS")
    local al = pool(adapter, "AL_UDEID")
    if counts.supportAircraft == 0 then
      assertEqual(counts.supportMissions, 0, "final supportMissions")
      assertEqual(manas.quantity, 15, "final MANAS surviving pool")
      assertEqual(manas.lost, 1, "final MANAS loss audit")
      assertEqual(al.quantity, 40, "final AL_UDEID pool")
      assertEqual(al.lost, 0, "final AL_UDEID loss audit")
      log("FINAL_SETTLEMENT_PASS MANAS_available=15 MANAS_lost=1 AL_UDEID_available=40 AL_UDEID_lost=0 activeAircraft=0")
      log("RESULT PASS controlledTrackEntry=true controlledReliefTiming=true naturalGateTransit=false physicalLossInjection=MOOSE_UNIT_EXPLODE restoreServerRestartEmulatedBySnapshotRestore=true")
      phase = 99
    end
  end
end, {}, POLL_SEC, POLL_SEC)

log(string.format(
  "HARNESS_READY testId=%s timeoutSec=%d controlledTrackEntry=true controlledReliefTiming=true lossMethod=MOOSE_UNIT_EXPLODE",
  TEST_ID,
  TIMEOUT_SEC
))
