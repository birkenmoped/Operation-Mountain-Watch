local TEST_ID = "AAR-PRODUCTION-FINAL-ACCEPTANCE-5"
local TAG = "[OMW][" .. TEST_ID .. "]"
local POLL_SEC = 5
local TIMEOUT_SEC = 12 * 60 * 60
local SOURCE_SPACING_TOLERANCE_SEC = 1
local RELIEF_TEST_DWELL_SEC = 60
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
  local selection = { missionDemandId = "AAR-RESTORE-UNRESOLVED", sourceDomain = "MANAS" }
  local store = buildStore()
  local adapter = OMW_AAR_TEST_Adapter.New(store, OMW_AAR_TEST_CampaignState)
  adapter:OnMaterialized(selection, { runtimeId = "AAR-RESTORE-0001" })
  assertPool(adapter, "MANAS", 15, 0, "restore.preSnapshot")

  local snapshot = store:ExportSnapshot()
  local restoredStore = OMW_AAR_TEST_CampaignState.Restore(snapshot)
  local captureController = { adapter = nil }
  function captureController.SetStrategicAdapter(value) captureController.adapter = value end

  local attached = OMW_AAR_TEST_RuntimeIntegration.Attach({
    store = restoredStore,
    campaignState = OMW_AAR_TEST_CampaignState,
    adapterModule = OMW_AAR_TEST_Adapter,
    controller = captureController,
    restored = true,
  })
  assertEqual(attached.reconciliation.reconciled, 1, "restore.reconciled")
  assertPool(attached.adapter, "MANAS", 16, 0, "restore.firstAttach")

  local second = attached.adapter:ReconcileRestore()
  assertEqual(second.reconciled, 0, "restore.second.reconciled")
  assertEqual(second.alreadyResolved, 1, "restore.second.alreadyResolved")
  assertPool(attached.adapter, "MANAS", 16, 0, "restore.secondAttach")

  local lossStore = buildStore()
  local lossAdapter = OMW_AAR_TEST_Adapter.New(lossStore, OMW_AAR_TEST_CampaignState)
  local lossSelection = { missionDemandId = "AAR-RESTORE-LOSS", sourceDomain = "AL_UDEID" }
  local lossRuntime = { runtimeId = "AAR-RESTORE-LOSS-0001" }
  lossAdapter:OnMaterialized(lossSelection, lossRuntime)
  lossAdapter:OnLost(lossSelection, lossRuntime, "TEST_PERSISTED_LOSS")
  local lossSnapshot = lossStore:ExportSnapshot()
  local restoredLossStore = OMW_AAR_TEST_CampaignState.Restore(lossSnapshot)
  local lossCapture = { adapter = nil }
  function lossCapture.SetStrategicAdapter(value) lossCapture.adapter = value end
  local attachedLoss = OMW_AAR_TEST_RuntimeIntegration.Attach({
    store = restoredLossStore,
    campaignState = OMW_AAR_TEST_CampaignState,
    adapterModule = OMW_AAR_TEST_Adapter,
    controller = lossCapture,
    restored = true,
  })
  assertEqual(attachedLoss.reconciliation.preservedLosses, 1, "restore.loss.preservedLosses")
  assertPool(attachedLoss.adapter, "AL_UDEID", 39, 1, "restore.loss.restored")
  log("RESTORE_RECONCILIATION_PASS unresolvedCreditOnce=true duplicateCredit=false persistedLossPreserved=true")
end

assertTrue(OMW_AAR_TEST_CampaignState ~= nil, "CampaignState test module unavailable")
assertTrue(OMW_AAR_TEST_StrategicStock ~= nil, "AAR strategic stock test module unavailable")
assertTrue(OMW_AAR_TEST_Initializer ~= nil, "CampaignState initializer test module unavailable")
assertTrue(OMW_AAR_TEST_Adapter ~= nil, "AAR CampaignState adapter test module unavailable")
assertTrue(OMW_AAR_TEST_RuntimeIntegration ~= nil, "AAR RuntimeIntegration test module unavailable")
assertTrue(OMW and OMW.AAR, "production AAR controller unavailable")

local config = OMW.AAR.GetConfig()
assertEqual(config.standardTrackCount, 4, "config.standardTrackCount")
assertEqual(config.reserveTrackCount, 2, "config.reserveTrackCount")
assertEqual(config.maxAircraftPerTrack, 2, "config.maxAircraftPerTrack")
assertEqual(config.globalAarMissionLimit, false, "config.globalAarMissionLimit")
assertEqual(config.globalAarAircraftLimit, false, "config.globalAarAircraftLimit")
assertEqual(config.stableSortieCallsign, true, "config.stableSortieCallsign")
assertEqual(config.firFixRoutingEnabled, true, "config.firFixRoutingEnabled")
assertEqual(config.externalSpawnHandoffSeparated, true, "config.externalSpawnHandoffSeparated")
assertEqual(config.airwaysRoutingEnabled, false, "config.airwaysRoutingEnabled")
assertEqual(config.availabilityByArea.LISA, "RESERVE", "config.availability.LISA")
assertEqual(config.availabilityByArea.MOE, "RESERVE", "config.availability.MOE")
assertEqual(config.availabilityByArea.NELSON, "STANDARD", "config.availability.NELSON")
assertEqual(config.availabilityByArea.PATTY, "STANDARD", "config.availability.PATTY")
assertEqual(config.availabilityByArea.KRUSTY, "STANDARD", "config.availability.KRUSTY")
assertEqual(config.availabilityByArea.MILHOUSE, "STANDARD", "config.availability.MILHOUSE")
assertEqual(config.firFixByArea.NELSON, "EGPAN", "config.fir.NELSON")
assertEqual(config.firFixByArea.PATTY, "EGPAN", "config.fir.PATTY")
assertEqual(config.firFixByArea.KRUSTY, "DAVER", "config.fir.KRUSTY")
assertEqual(config.firFixByArea.MILHOUSE, "DAVER", "config.fir.MILHOUSE")
assertEqual(config.firFixByArea.LISA, "PINAX", "config.fir.LISA")
assertEqual(config.firFixByArea.MOE, "PINAX", "config.fir.MOE")
log("AAR_POLICY_BASELINE_PASS standardTracks=4 reserveTracks=2 naturalTrackEntry=true controlledTrackEntry=false airwaysRouting=false")

runRestoreReconciliationChecks()

local liveStore = buildStore()
local preAdapter = OMW_AAR_TEST_Adapter.New(liveStore, OMW_AAR_TEST_CampaignState)
assertPool(preAdapter, "MANAS", 16, 0, "live.initial.MANAS")
assertPool(preAdapter, "AL_UDEID", 40, 0, "live.initial.AL_UDEID")
log("POOL_BASELINE_PASS MANAS=16 AL_UDEID=40")

local live = OMW_AAR_TEST_RuntimeIntegration.Attach({
  store = liveStore,
  campaignState = OMW_AAR_TEST_CampaignState,
  adapterModule = OMW_AAR_TEST_Adapter,
  controller = OMW.AAR,
  restored = false,
})
local adapter = live.adapter

local D = {
  NELSON = makeDemand("AAR-FINAL-NELSON", "FAST", "NORTHEAST", "SUPPORT"),
  LISA = makeDemand("AAR-FINAL-LISA", "FAST", "WEST", "SUPPORT"),
  MOE = makeDemand("AAR-FINAL-MOE", "FAST", "CENTRAL", "SUPPORT"),
}

local STANDARD = {
  { area = "NELSON", profile = "FAST", source = "MANAS", family = "Texaco", firFix = "EGPAN" },
  { area = "PATTY", profile = "SLOW", source = "MANAS", family = "Texaco", firFix = "EGPAN" },
  { area = "KRUSTY", profile = "SLOW", source = "AL_UDEID", family = "Arco", firFix = "DAVER" },
  { area = "MILHOUSE", profile = "SLOW", source = "AL_UDEID", family = "Shell", firFix = "DAVER" },
}

local phase = 1
local startedAt = timer.getAbsTime()
local observed = {
  milhouseOutgoing = nil,
  milhouseRelief = nil,
  milhouseReliefTriggerAt = nil,
  nelsonOutgoing = nil,
  nelsonRelief = nil,
  lisa = nil,
  moe = nil,
  pattyLostRuntimeId = nil,
  pattyReplacement = nil,
}

local function setPhase(nextPhase, marker)
  phase = nextPhase
  log(string.format("PHASE_%02d %s", nextPhase, marker or ""))
end

local function getRuntime(area, profile) return OMW.AAR.GetActive(area, profile) end
local function getStation(area, profile) return OMW.AAR.GetStation(area, profile) end

local function assertRuntimeIdentity(runtime, expectedFamily, label)
  assertTrue(runtime ~= nil, label .. " runtime missing")
  local callsign = runtime.sortieCallsign
  assertTrue(callsign ~= nil, label .. " sortie callsign missing")
  assertEqual(callsign.name, expectedFamily, label .. ".family")
  assertTrue(callsign.number >= 1 and callsign.number <= 9, label .. " invalid group number")
  assertTrue(callsign.stn ~= nil and tostring(callsign.stn) ~= "", label .. " missing MOOSE-assigned STN")
  local actual = runtime.group and runtime.group:GetCallsign() or nil
  local expected = callsign.name .. tostring(callsign.number) .. "1"
  assertEqual(normalizeCallsign(actual), normalizeCallsign(expected), label .. ".dcsCallsign")
end

local function allStandardMaterialized()
  for _, spec in ipairs(STANDARD) do
    local runtime = getRuntime(spec.area, spec.profile)
    if not runtime or runtime.egressOrdered or runtime.lossHandled then return false end
  end
  return true
end

local function allStandardFirIngressPassed()
  for _, spec in ipairs(STANDARD) do
    local runtime = getRuntime(spec.area, spec.profile)
    if not runtime or not runtime.firIngressPassed then return false end
  end
  return true
end

local function allStandardOnActualTrack()
  for _, spec in ipairs(STANDARD) do
    local runtime = getRuntime(spec.area, spec.profile)
    if not runtime or not runtime.onStationAt or not runtime.stationIdentityActive then return false end
  end
  return true
end

local function verifyInitialSourceSpacing(source)
  local times = {}
  for _, spec in ipairs(STANDARD) do
    if spec.source == source then
      local runtime = getRuntime(spec.area, spec.profile)
      assertTrue(runtime and runtime.materializedAt, source .. " materializedAt missing for " .. spec.area)
      times[#times + 1] = runtime.materializedAt
    end
  end
  table.sort(times)
  for index = 2, #times do
    local delta = times[index] - times[index - 1]
    assertTrue(delta >= (60 - SOURCE_SPACING_TOLERANCE_SEC),
      string.format("%s source spacing below 60 seconds delta=%.3f", source, delta))
  end
  return times
end

local function reserveGone(area, profile)
  local station = getStation(area, profile)
  if not station then return true end
  if station.activeRuntime or station.reliefRuntime or station.activeQueued or station.reliefQueued then return false end
  return true
end

SCHEDULER:New(nil, function()
  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then fail("TIMEOUT phase=" .. tostring(phase)) end

  if phase == 1 then
    if allStandardMaterialized() then
      assertEqual(OMW.AAR.GetRuntimeCounts().activeTracks, 4, "standard.activeTracks")
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 4, "standard.supportAircraft")
      assertTrue(getRuntime("LISA", "FAST") == nil, "LISA reserve auto-started")
      assertTrue(getRuntime("MOE", "FAST") == nil, "MOE reserve auto-started")
      assertPool(adapter, "MANAS", 14, 0, "standard.MANAS")
      assertPool(adapter, "AL_UDEID", 38, 0, "standard.AL_UDEID")
      for _, spec in ipairs(STANDARD) do
        local runtime = getRuntime(spec.area, spec.profile)
        assertRuntimeIdentity(runtime, spec.family, spec.area .. ".initial")
        assertEqual(runtime.firFixName, spec.firFix, spec.area .. ".firFix")
      end
      local manasTimes = verifyInitialSourceSpacing("MANAS")
      local alTimes = verifyInitialSourceSpacing("AL_UDEID")
      assertTrue(math.abs(manasTimes[1] - alTimes[1]) <= POLL_SEC + SOURCE_SPACING_TOLERANCE_SEC,
        "source domains did not start independently")
      log("STANDARD_TRACKS_4_PASS initialAircraft=4 reserveAircraft=0")
      setPhase(2, "WAIT_NATURAL_STANDARD_FIR_INGRESS")
    end

  elseif phase == 2 then
    if allStandardFirIngressPassed() then
      log("FIR_INGRESS_STANDARD_PASS NELSON=EGPAN PATTY=EGPAN KRUSTY=DAVER MILHOUSE=DAVER naturalFixTransit=true")
      setPhase(3, "WAIT_NATURAL_STANDARD_TRACK_ENTRY")
    end

  elseif phase == 3 then
    if allStandardOnActualTrack() then
      log("NATURAL_STANDARD_TRACK_ENTRY_PASS controlledTrackEntry=false physicalTeleport=false")
      local attached, status = OMW.AAR.SubmitDemand(D.NELSON)
      assertTrue(attached ~= nil, "NELSON demand attach failed")
      assertEqual(status, "ACTIVE_REUSED", "NELSON demand attach status")
      local before = getRuntime("NELSON", "FAST").runtimeId
      local _, endStatus = OMW.AAR.EndDemand(D.NELSON, "ABORTED")
      assertEqual(endStatus, "CORE_TRACK_RETAINED", "NELSON standard demand end")
      assertEqual(getRuntime("NELSON", "FAST").runtimeId, before, "NELSON standard demand changed runtime")
      assertTrue(not getRuntime("NELSON", "FAST").egressOrdered, "NELSON standard demand end ordered egress")
      log("STANDARD_DEMAND_END_PASS area=NELSON trackRetained=true")

      local ms = getStation("MILHOUSE", "SLOW")
      observed.milhouseOutgoing = ms.activeRuntime
      observed.milhouseReliefTriggerAt = timer.getAbsTime() + RELIEF_TEST_DWELL_SEC
      setPhase(4, "MILHOUSE_SCHEDULED_RELIEF_DWELL")
    end

  elseif phase == 4 then
    if timer.getAbsTime() >= observed.milhouseReliefTriggerAt then
      local ms = getStation("MILHOUSE", "SLOW")
      assertTrue(ms and ms.activeRuntime == observed.milhouseOutgoing, "MILHOUSE active changed before relief trigger")
      assertTrue(ms.reliefRuntime == nil and not ms.reliefQueued, "MILHOUSE relief existed before test trigger")
      ms.reliefLaunchAt = timer.getAbsTime()
      log("SCHEDULED_RELIEF_TRIGGERED area=MILHOUSE testAcceleration=launchTimeOnly naturalReliefTransit=true")
      setPhase(5, "MILHOUSE_RELIEF_TRANSIT")
    end

  elseif phase == 5 then
    local ms = getStation("MILHOUSE", "SLOW")
    if ms and ms.reliefRuntime then
      observed.milhouseRelief = observed.milhouseRelief or ms.reliefRuntime
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 5, "singleScheduled.supportAircraft")
      assertRuntimeIdentity(observed.milhouseOutgoing, "Shell", "MILHOUSE.outgoing")
      assertRuntimeIdentity(observed.milhouseRelief, "Shell", "MILHOUSE.relief")
      assertTrue(observed.milhouseOutgoing.sortieCallsign.number ~= observed.milhouseRelief.sortieCallsign.number,
        "MILHOUSE relief reused outgoing Shell group number")
      assertTrue(not observed.milhouseRelief.stationIdentityActive,
        "MILHOUSE relief incorrectly owns station during transit")
      if observed.milhouseRelief.firIngressPassed then
        log("RELIEF_TRANSIT_OVERLAP_PASS area=MILHOUSE physicalTankers=2 stationOwners=1 DAVER_ingress=true")
        setPhase(6, "WAIT_NATURAL_MILHOUSE_HANDOVER")
      end
    end

  elseif phase == 6 then
    local ms = getStation("MILHOUSE", "SLOW")
    if ms and observed.milhouseRelief and ms.activeRuntime == observed.milhouseRelief
        and observed.milhouseRelief.stationIdentityActive and observed.milhouseOutgoing.handoffComplete then
      assertTrue(observed.milhouseOutgoing.firEgressPassed, "MILHOUSE outgoing did not pass DAVER egress")
      assertTrue(observed.milhouseOutgoing.externalHandoffRouted, "MILHOUSE outgoing not routed to external handoff")
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 4, "postScheduled.supportAircraft")
      assertPool(adapter, "AL_UDEID", 38, 0, "postScheduled.AL_UDEID")
      assertRuntimeIdentity(ms.activeRuntime, "Shell", "MILHOUSE.newActive")
      log("SINGLE_SCHEDULED_RELIEF_PASS area=MILHOUSE naturalTrackHandover=true sameFamily=Shell DAVER_egress=true externalHandoff=true exactRecredit=true")

      local ns = getStation("NELSON", "FAST")
      observed.nelsonOutgoing = ns.activeRuntime
      ns.activeRuntime.flightGroup:FuelLow()
      assertTrue(ns.activeRuntime.egressOrdered, "NELSON FuelLow did not order egress")
      setPhase(7, "NELSON_FUELLOW_RELIEF")
    end

  elseif phase == 7 then
    local ns = getStation("NELSON", "FAST")
    if ns and ns.reliefRuntime then
      observed.nelsonRelief = observed.nelsonRelief or ns.reliefRuntime
      assertRuntimeIdentity(observed.nelsonOutgoing, "Texaco", "NELSON.outgoing")
      assertRuntimeIdentity(observed.nelsonRelief, "Texaco", "NELSON.relief")
      assertTrue(observed.nelsonOutgoing.sortieCallsign.number ~= observed.nelsonRelief.sortieCallsign.number,
        "NELSON relief reused outgoing Texaco group number")
      assertTrue(not observed.nelsonRelief.stationIdentityActive,
        "NELSON relief incorrectly owns station during transit")
      if observed.nelsonRelief.firIngressPassed then setPhase(8, "WAIT_NATURAL_NELSON_HANDOVER") end
    end

  elseif phase == 8 then
    local ns = getStation("NELSON", "FAST")
    if ns and observed.nelsonRelief and ns.activeRuntime == observed.nelsonRelief
        and observed.nelsonRelief.stationIdentityActive and observed.nelsonOutgoing.handoffComplete then
      assertTrue(observed.nelsonOutgoing.firEgressPassed, "NELSON outgoing did not pass EGPAN egress")
      assertTrue(observed.nelsonOutgoing.externalHandoffRouted, "NELSON outgoing not routed to external handoff")
      assertPool(adapter, "MANAS", 14, 0, "postFuelLow.MANAS")
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 4, "postFuelLow.supportAircraft")
      log("FUEL_LOW_RELIEF_PASS area=NELSON naturalTrackHandover=true EGPAN_egress=true externalHandoff=true")

      local lisaResult, lisaStatus = OMW.AAR.SubmitDemand(D.LISA)
      local moeResult, moeStatus = OMW.AAR.SubmitDemand(D.MOE)
      assertTrue(lisaResult ~= nil and moeResult ~= nil, "reserve demand submission failed")
      assertEqual(lisaStatus, "RESERVE_TRACK_QUEUED", "LISA reserve start status")
      assertEqual(moeStatus, "RESERVE_TRACK_QUEUED", "MOE reserve start status")
      setPhase(9, "RESERVE_LISA_MOE_NATURAL_TRANSIT")
    end

  elseif phase == 9 then
    local lisa = getRuntime("LISA", "FAST")
    local moe = getRuntime("MOE", "FAST")
    if lisa and moe then
      observed.lisa = observed.lisa or lisa
      observed.moe = observed.moe or moe
      assertRuntimeIdentity(observed.lisa, "Texaco", "LISA.reserve")
      assertRuntimeIdentity(observed.moe, "Texaco", "MOE.reserve")
      assertEqual(observed.lisa.firFixName, "PINAX", "LISA reserve firFix")
      assertEqual(observed.moe.firFixName, "PINAX", "MOE reserve firFix")
      if observed.lisa.firIngressPassed and observed.moe.firIngressPassed
          and observed.lisa.stationIdentityActive and observed.moe.stationIdentityActive then
        log("RESERVE_NATURAL_INGRESS_AND_TRACK_PASS LISA=PINAX MOE=PINAX")
        local _, lisaEnd = OMW.AAR.EndDemand(D.LISA, "COMPLETE")
        local _, moeEnd = OMW.AAR.EndDemand(D.MOE, "CANCELLED")
        assertEqual(lisaEnd, "RESERVE_TRACK_EGRESS", "LISA reserve end")
        assertEqual(moeEnd, "RESERVE_TRACK_EGRESS", "MOE reserve end")
        setPhase(10, "RESERVE_PINAX_EGRESS_AND_EXTERNAL_HANDOFF")
      end
    end

  elseif phase == 10 then
    if observed.lisa and observed.moe and observed.lisa.handoffComplete and observed.moe.handoffComplete then
      assertTrue(observed.lisa.firEgressPassed and observed.moe.firEgressPassed, "reserve tanker missed PINAX egress")
      assertTrue(observed.lisa.externalHandoffRouted and observed.moe.externalHandoffRouted,
        "reserve external handoff route missing")
      assertTrue(reserveGone("LISA", "FAST"), "LISA reserve still active after handoff")
      assertTrue(reserveGone("MOE", "FAST"), "MOE reserve still active after handoff")
      assertEqual(OMW.AAR.GetRuntimeCounts().activeTracks, 4, "postReserve.activeTracks")
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 4, "postReserve.supportAircraft")
      assertPool(adapter, "MANAS", 14, 0, "postReserve.MANAS")
      log("RESERVE_DEMAND_LIFECYCLE_PASS LISA=FAST MOE=FAST PINAX_ingressEgress=true externalHandoff=true")

      local ps = getStation("PATTY", "SLOW")
      assertTrue(ps and ps.activeRuntime and not ps.reliefRuntime, "PATTY steady state missing before loss")
      observed.pattyLostRuntimeId = ps.activeRuntime.runtimeId
      local unit = ps.activeRuntime.group and ps.activeRuntime.group:GetUnit(1) or nil
      assertTrue(unit and unit:IsAlive(), "PATTY loss target unit unavailable")
      unit:Explode(LOSS_EXPLOSION_POWER)
      log("LOSS_INJECTION_ARMED area=PATTY method=MOOSE_UNIT_EXPLODE")
      setPhase(11, "PATTY_LOSS_REPLACEMENT_NATURAL_TRANSIT")
    end

  elseif phase == 11 then
    local manas = pool(adapter, "MANAS")
    local replacement = getRuntime("PATTY", "SLOW")
    if manas.lost == 1 and replacement and replacement.runtimeId ~= observed.pattyLostRuntimeId then
      observed.pattyReplacement = observed.pattyReplacement or replacement
      assertRuntimeIdentity(observed.pattyReplacement, "Texaco", "PATTY.replacement")
      if observed.pattyReplacement.firIngressPassed and observed.pattyReplacement.stationIdentityActive then
        assertEqual(manas.quantity, 13, "loss.MANAS.quantity")
        assertEqual(manas.available, 13, "loss.MANAS.available")
        assertEqual(manas.lost, 1, "loss.MANAS.lost")
        log("AIRCRAFT_LOSS_PASS area=PATTY noRecredit=true lossAudit=1 replacementNaturalTrackEntry=true")
        setPhase(12, "FINAL_STEADY_STATE")
      end
    end

  elseif phase == 12 then
    if allStandardOnActualTrack() and reserveGone("LISA", "FAST") and reserveGone("MOE", "FAST") then
      assertEqual(OMW.AAR.GetRuntimeCounts().activeTracks, 4, "final.activeTracks")
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 4, "final.supportAircraft")
      assertPool(adapter, "MANAS", 13, 1, "final.MANAS")
      assertPool(adapter, "AL_UDEID", 38, 0, "final.AL_UDEID")
      log("FINAL_STEADY_STATE_PASS standardTracks=4 reserveTracks=0 supportAircraft=4 naturalTrackEntry=true")
      log("RESULT PASS")
      phase = 99
    end
  end
end, {}, 0, POLL_SEC)
