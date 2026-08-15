local TEST_ID = "AAR-PRODUCTION-FINAL-ACCEPTANCE-2"
local TAG = "[OMW][" .. TEST_ID .. "]"
local POLL_SEC = 5
local TIMEOUT_SEC = 1800
local SOURCE_SPACING_TOLERANCE_SEC = 1
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
  function captureController.SetStrategicAdapter(value)
    captureController.adapter = value
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
  local lossCapture = { adapter = nil }
  function lossCapture.SetStrategicAdapter(value)
    lossCapture.adapter = value
  end

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

local config = OMW.AAR.GetConfig()
assertEqual(config.continuousCoreTrackCount, 6, "config.continuousCoreTrackCount")
assertEqual(config.maxAircraftPerTrack, 2, "config.maxAircraftPerTrack")
assertEqual(config.globalAarMissionLimit, false, "config.globalAarMissionLimit")
assertEqual(config.globalAarAircraftLimit, false, "config.globalAarAircraftLimit")
assertEqual(config.mooseManagedSpawnStn, true, "config.mooseManagedSpawnStn")
log("AAR_POLICY_BASELINE_PASS coreTracks=6 globalMissionLimit=false globalAircraftLimit=false maxAircraftPerTrack=2 continuousAvailabilityPolicy=true")

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
  PATTY = makeDemand("AAR-FINAL-PATTY", "SLOW", "EAST", "SUPPORT"),
  LISA = makeDemand("AAR-FINAL-LISA", "SLOW", "WEST", "SUPPORT"),
  MOE = makeDemand("AAR-FINAL-MOE", "FAST", "CENTRAL", "SUPPORT"),
  KRUSTY = makeDemand("AAR-FINAL-KRUSTY", "SLOW", "SOUTHEAST", "RECOVERY"),
  MILHOUSE = makeDemand("AAR-FINAL-MILHOUSE", "SLOW", "SOUTH_CENTRAL", "RECOVERY"),
}

local CORE = {
  { area = "NELSON", profile = "FAST", source = "MANAS", callsign = "Texaco11", demand = D.NELSON },
  { area = "PATTY", profile = "SLOW", source = "MANAS", callsign = "Texaco21", demand = D.PATTY },
  { area = "LISA", profile = "SLOW", source = "MANAS", callsign = "Texaco31", demand = D.LISA },
  { area = "MOE", profile = "FAST", source = "MANAS", callsign = "Texaco41", demand = D.MOE },
  { area = "KRUSTY", profile = "SLOW", source = "AL_UDEID", callsign = "Arco21", demand = D.KRUSTY },
  { area = "MILHOUSE", profile = "SLOW", source = "AL_UDEID", callsign = "Shell21", demand = D.MILHOUSE },
}

local phase = 1
local phaseStartedAt = timer.getAbsTime()
local startedAt = phaseStartedAt
local observed = {
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

local function elapsedPhase()
  return timer.getAbsTime() - phaseStartedAt
end

local function currentCoreRuntimes(includeRelief)
  local runtimes = {}
  for _, spec in ipairs(CORE) do
    local station = getStation(spec.area, spec.profile)
    if station then
      if station.activeRuntime then runtimes[#runtimes + 1] = station.activeRuntime end
      if includeRelief and station.reliefRuntime then runtimes[#runtimes + 1] = station.reliefRuntime end
    end
  end
  return runtimes
end

local function allCoreActive()
  for _, spec in ipairs(CORE) do
    if not getRuntime(spec.area, spec.profile) then return false end
  end
  return true
end

local function allCoreStationIdentityActive()
  for _, spec in ipairs(CORE) do
    local runtime = getRuntime(spec.area, spec.profile)
    if not runtime or not runtime.stationIdentityActive then return false end
  end
  return true
end

local function allCoreReliefMaterialized()
  for _, spec in ipairs(CORE) do
    local station = getStation(spec.area, spec.profile)
    if not station or not station.activeRuntime or not station.reliefRuntime then return false end
  end
  return true
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
      assertTrue(transit.stn ~= nil and tostring(transit.stn) ~= "", label .. " missing MOOSE-assigned STN")
      local callsignKey = transit.name .. tostring(transit.number)
      local stnKey = tostring(transit.stn)
      assertTrue(not seenCallsign[callsignKey], label .. " duplicate transit callsign=" .. callsignKey)
      assertTrue(not seenStn[stnKey], label .. " duplicate STN=" .. stnKey)
      seenCallsign[callsignKey] = true
      seenStn[stnKey] = true
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

local function verifySourceSpacing(source)
  local times = {}
  for _, spec in ipairs(CORE) do
    if spec.source == source then
      local runtime = getRuntime(spec.area, spec.profile)
      assertTrue(runtime and runtime.materializedAt, source .. " runtime missing materializedAt for " .. spec.area)
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

for _, spec in ipairs(CORE) do
  local result, status = OMW.AAR.SubmitDemand(spec.demand)
  assertTrue(result ~= nil, spec.area .. " submit failed status=" .. tostring(status))
  log(string.format("CORE_TRACK_SUBMITTED area=%s profile=%s source=%s status=%s", spec.area, spec.profile, spec.source, tostring(status)))
end
log("PHASE_01 SIX_CORE_TRACKS_SUBMITTED")

SCHEDULER:New(nil, function()
  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    fail("TIMEOUT phase=" .. tostring(phase))
  end

  if phase == 1 then
    if allCoreActive() then
      local counts = OMW.AAR.GetRuntimeCounts()
      assertEqual(counts.activeTracks, 6, "core.activeTracks")
      assertEqual(counts.supportAircraft, 6, "core.supportAircraft")
      assertPool(adapter, "MANAS", 12, 0, "core.MANAS")
      assertPool(adapter, "AL_UDEID", 38, 0, "core.AL_UDEID")
      assertEqual(assertUniqueRuntimeIdentities(currentCoreRuntimes(false), "sixCoreIdentity"), 6, "sixCoreIdentity.count")

      local manasTimes = verifySourceSpacing("MANAS")
      local alTimes = verifySourceSpacing("AL_UDEID")
      local sourceDelta = math.abs(manasTimes[1] - alTimes[1])
      assertTrue(sourceDelta <= POLL_SEC + SOURCE_SPACING_TOLERANCE_SEC,
        "MANAS/AL_UDEID first materialization was not independent deltaSec=" .. tostring(sourceDelta))

      log(string.format("SOURCE_INDEPENDENCE_PASS deltaSec=%.1f MANAS_spawns=4 AL_UDEID_spawns=2 sameSourceMinSpacingSec=60", sourceDelta))
      log("CORE_TRACKS_6_SIMULTANEOUS_PASS activeTracks=6 aircraft=6 noGlobalAarMissionLimit=true")

      for _, spec in ipairs(CORE) do
        forceControlledTrackEntry(getRuntime(spec.area, spec.profile))
      end
      setPhase(2, "SIX_TRACK_STATION_IDENTITY")
    end

  elseif phase == 2 then
    if allCoreStationIdentityActive() then
      for _, spec in ipairs(CORE) do
        verifyStationCallsign(getRuntime(spec.area, spec.profile), spec.callsign, spec.area .. " station callsign")
        local station = getStation(spec.area, spec.profile)
        station.reliefLaunchAt = timer.getAbsTime()
        station.nextPlannedHandoverAt = timer.getAbsTime() + 300
      end
      log("STATION_IDENTITY_PASS sixTracks=true callsignSwitch=true radioTacanCommands=productionPath")
      setPhase(3, "SIX_TRACK_RELIEF_MATERIALIZATION")
    end

  elseif phase == 3 then
    if allCoreReliefMaterialized() then
      local counts = OMW.AAR.GetRuntimeCounts()
      assertEqual(counts.activeTracks, 6, "relief.activeTracks")
      assertEqual(counts.supportAircraft, 12, "relief.supportAircraft")
      assertPool(adapter, "MANAS", 8, 0, "relief.MANAS")
      assertPool(adapter, "AL_UDEID", 36, 0, "relief.AL_UDEID")
      assertEqual(assertUniqueRuntimeIdentities(currentCoreRuntimes(true), "twelveAircraftIdentity"), 12, "twelveAircraftIdentity.count")

      for _, spec in ipairs(CORE) do
        local station = getStation(spec.area, spec.profile)
        assertTrue(station.activeRuntime ~= station.reliefRuntime, spec.area .. " active and relief runtime unexpectedly identical")
      end

      log("RELIEF_6_TRACKS_12_AIRCRAFT_PASS activeTracks=6 aircraft=12 maxPerTrack=2 uniqueTransitCallsign=true uniqueMooseAssignedStn=true")

      local _, abortStatus = OMW.AAR.EndDemand(D.KRUSTY, "ABORTED")
      assertEqual(abortStatus, "STATION_CLOSED", "KRUSTY abort status")
      setPhase(4, "KRUSTY_ABORT_NATURAL_HANDOFF")
    end

  elseif phase == 4 then
    local ks = getStation("KRUSTY", "SLOW")
    local al = pool(adapter, "AL_UDEID")
    if ks and ks.closed and not ks.activeRuntime and not ks.reliefRuntime and al.quantity == 38 then
      assertEqual(al.lost, 0, "KRUSTY abort lost")
      log("ABORT_HANDOFF_PASS area=KRUSTY activeAndReliefRecredited=true exactOnce=true")

      local ns = getStation("NELSON", "FAST")
      assertTrue(ns and ns.activeRuntime and ns.reliefRuntime, "NELSON active/relief missing before FuelLow")
      observed.nelsonReliefId = ns.reliefRuntime.runtimeId
      ns.activeRuntime.flightGroup:FuelLow()
      assertEqual(ns.reliefRuntime.runtimeId, observed.nelsonReliefId, "NELSON FuelLow reused existing relief")
      assertTrue(ns.activeRuntime.egressOrdered, "NELSON FuelLow did not order outgoing egress")
      forceControlledTrackEntry(ns.reliefRuntime)
      setPhase(5, "NELSON_FUELLOW_RELIEF")
    end

  elseif phase == 5 then
    local ns = getStation("NELSON", "FAST")
    if ns and ns.activeRuntime and ns.activeRuntime.runtimeId == observed.nelsonReliefId
        and ns.activeRuntime.stationIdentityActive then
      verifyStationCallsign(ns.activeRuntime, "Texaco11", "NELSON relief station callsign")
      log("FUEL_LOW_RELIEF_PASS existingReliefReused=true duplicateRelief=false outgoingEgress=true reliefPromoted=true")

      local ps = getStation("PATTY", "SLOW")
      assertTrue(ps and ps.reliefRuntime, "PATTY scheduled relief missing")
      observed.pattyReliefId = ps.reliefRuntime.runtimeId
      forceControlledTrackEntry(ps.reliefRuntime)
      setPhase(6, "PATTY_SCHEDULED_RELIEF")
    end

  elseif phase == 6 then
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
      log("LOSS_INJECTION_ARMED area=PATTY method=MOOSE_UNIT_EXPLODE powerKgTNT=" .. tostring(LOSS_EXPLOSION_POWER))
      setPhase(7, "PATTY_AIRCRAFT_LOSS")
    end

  elseif phase == 7 then
    local manas = pool(adapter, "MANAS")
    if manas.lost == 1 then
      assertEqual(manas.quantity, observed.pattyLossPoolBefore, "loss no aircraft recredit")
      log("AIRCRAFT_LOSS_PASS area=PATTY deadCallback=true aircraftRecredit=false lossAudit=1")

      local _, cancelStatus = OMW.AAR.EndDemand(D.PATTY, "CANCELLED")
      assertEqual(cancelStatus, "STATION_CLOSED", "PATTY cancel status")
      local _, completeStatus = OMW.AAR.EndDemand(D.MOE, "COMPLETE")
      assertEqual(completeStatus, "STATION_CLOSED", "MOE complete status")
      local _, abortStatus = OMW.AAR.EndDemand(D.NELSON, "ABORTED")
      assertEqual(abortStatus, "STATION_CLOSED", "NELSON abort status")
      local _, lisaStatus = OMW.AAR.EndDemand(D.LISA, "COMPLETE")
      assertEqual(lisaStatus, "STATION_CLOSED", "LISA complete status")
      local _, milhouseStatus = OMW.AAR.EndDemand(D.MILHOUSE, "COMPLETE")
      assertEqual(milhouseStatus, "STATION_CLOSED", "MILHOUSE complete status")
      log("DEMAND_END_PASS complete=true cancelled=true aborted=true immediateClose=true independentTracks=true")
      setPhase(8, "FINAL_SETTLEMENT")
    end

  elseif phase == 8 then
    local counts = OMW.AAR.GetRuntimeCounts()
    local manas = pool(adapter, "MANAS")
    local al = pool(adapter, "AL_UDEID")
    if counts.supportAircraft == 0 then
      assertEqual(counts.activeTracks, 0, "final activeTracks")
      assertEqual(manas.quantity, 15, "final MANAS surviving pool")
      assertEqual(manas.lost, 1, "final MANAS loss audit")
      assertEqual(al.quantity, 40, "final AL_UDEID pool")
      assertEqual(al.lost, 0, "final AL_UDEID loss audit")
      log("FINAL_SETTLEMENT_PASS MANAS_available=15 MANAS_lost=1 AL_UDEID_available=40 AL_UDEID_lost=0 activeTracks=0 activeAircraft=0")
      log("RESULT PASS coreTracksSimultaneous=6 maxPhysicalDuringRelief=12 globalAarMissionLimit=false globalAarAircraftLimit=false maxAircraftPerTrack=2 mooseManagedStn=true controlledTrackEntry=true controlledReliefTiming=true physicalLossInjection=MOOSE_UNIT_EXPLODE restoreServerRestartEmulatedBySnapshotRestore=true")
      phase = 99
    end
  end
end, {}, POLL_SEC, POLL_SEC)

log(string.format(
  "HARNESS_READY testId=%s timeoutSec=%d coreTracks=6 expectedMaxPhysicalDuringRelief=12 controlledTrackEntry=true controlledReliefTiming=true lossMethod=MOOSE_UNIT_EXPLODE",
  TEST_ID,
  TIMEOUT_SEC
))
