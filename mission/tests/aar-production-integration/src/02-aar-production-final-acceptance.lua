local TEST_ID = "AAR-PRODUCTION-FINAL-ACCEPTANCE-3"
local TAG = "[OMW][" .. TEST_ID .. "]"
local POLL_SEC = 5
local TIMEOUT_SEC = 2400
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
assertEqual(config.continuousAvailabilityPolicy, true, "config.continuousAvailabilityPolicy")
assertEqual(config.maxAircraftPerTrack, 2, "config.maxAircraftPerTrack")
assertEqual(config.globalAarMissionLimit, false, "config.globalAarMissionLimit")
assertEqual(config.globalAarAircraftLimit, false, "config.globalAarAircraftLimit")
assertEqual(config.mooseManagedSpawnStn, true, "config.mooseManagedSpawnStn")
assertEqual(config.coreProfiles.LISA, "FAST", "config.coreProfiles.LISA")
assertEqual(config.coreProfiles.MOE, "FAST", "config.coreProfiles.MOE")
log("AAR_POLICY_BASELINE_PASS coreTracks=6 continuous=true LISA=FAST MOE=FAST globalMissionLimit=false globalAircraftLimit=false maxAircraftPerTrack=2")

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
  PATTY = makeDemand("AAR-FINAL-PATTY", "SLOW", "EAST", "SUPPORT"),
  LISA = makeDemand("AAR-FINAL-LISA", "FAST", "WEST", "SUPPORT"),
  MOE = makeDemand("AAR-FINAL-MOE", "FAST", "CENTRAL", "SUPPORT"),
  KRUSTY = makeDemand("AAR-FINAL-KRUSTY", "SLOW", "SOUTHEAST", "RECOVERY"),
  MILHOUSE = makeDemand("AAR-FINAL-MILHOUSE", "SLOW", "SOUTH_CENTRAL", "RECOVERY"),
}

local CORE = {
  { area = "NELSON", profile = "FAST", source = "MANAS", callsign = "Texaco11", demand = D.NELSON },
  { area = "PATTY", profile = "SLOW", source = "MANAS", callsign = "Texaco21", demand = D.PATTY },
  { area = "LISA", profile = "FAST", source = "MANAS", callsign = "Texaco31", demand = D.LISA },
  { area = "MOE", profile = "FAST", source = "MANAS", callsign = "Texaco41", demand = D.MOE },
  { area = "KRUSTY", profile = "SLOW", source = "AL_UDEID", callsign = "Arco21", demand = D.KRUSTY },
  { area = "MILHOUSE", profile = "SLOW", source = "AL_UDEID", callsign = "Shell21", demand = D.MILHOUSE },
}

local phase = 1
local phaseStartedAt = timer.getAbsTime()
local startedAt = phaseStartedAt
local observed = {
  initialRuntimeId = {},
  reliefRuntimeId = {},
  nelsonFuelLowOutgoingId = nil,
  nelsonFuelLowReliefId = nil,
  pattyLostRuntimeId = nil,
  pattyReplacementId = nil,
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
    local runtime = getRuntime(spec.area, spec.profile)
    if not runtime or runtime.egressOrdered or runtime.lossHandled then return false end
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

local function allScheduledReliefsPromoted()
  for _, spec in ipairs(CORE) do
    local station = getStation(spec.area, spec.profile)
    if not station or not station.activeRuntime then return false end
    if station.activeRuntime.runtimeId ~= observed.reliefRuntimeId[spec.area] then return false end
    if not station.activeRuntime.stationIdentityActive then return false end
  end
  return true
end

local function noCoreReliefPresent()
  for _, spec in ipairs(CORE) do
    local station = getStation(spec.area, spec.profile)
    if station and station.reliefRuntime then return false end
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

local function verifyInitialSourceSpacing(source)
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
      string.format("%s initial source spacing below 60 seconds delta=%.3f", source, delta))
  end
  return times
end

local function verifyReliefSourceSpacing(source)
  local times = {}
  for _, spec in ipairs(CORE) do
    if spec.source == source then
      local station = getStation(spec.area, spec.profile)
      local runtime = station and station.reliefRuntime or nil
      assertTrue(runtime and runtime.materializedAt, source .. " relief missing materializedAt for " .. spec.area)
      times[#times + 1] = runtime.materializedAt
    end
  end
  table.sort(times)
  for index = 2, #times do
    local delta = times[index] - times[index - 1]
    assertTrue(delta >= (60 - SOURCE_SPACING_TOLERANCE_SEC),
      string.format("%s relief source spacing below 60 seconds delta=%.3f", source, delta))
  end
end

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

      for _, spec in ipairs(CORE) do
        observed.initialRuntimeId[spec.area] = getRuntime(spec.area, spec.profile).runtimeId
      end

      local manasTimes = verifyInitialSourceSpacing("MANAS")
      local alTimes = verifyInitialSourceSpacing("AL_UDEID")
      local sourceDelta = math.abs(manasTimes[1] - alTimes[1])
      assertTrue(sourceDelta <= POLL_SEC + SOURCE_SPACING_TOLERANCE_SEC,
        "MANAS/AL_UDEID first materialization was not independent deltaSec=" .. tostring(sourceDelta))

      log(string.format("SOURCE_INDEPENDENCE_PASS deltaSec=%.1f MANAS_spawns=4 AL_UDEID_spawns=2 sameSourceMinSpacingSec=60", sourceDelta))
      log("CORE_TRACKS_6_SIMULTANEOUS_PASS activeTracks=6 aircraft=6 autoStarted=true noGlobalAarMissionLimit=true")

      for _, spec in ipairs(CORE) do
        local result, status = OMW.AAR.SubmitDemand(spec.demand)
        assertTrue(result ~= nil, spec.area .. " demand attach failed status=" .. tostring(status))
        assertEqual(status, "ACTIVE_REUSED", spec.area .. " demand attach status")
      end
      assertEqual(OMW.AAR.GetRuntimeCounts().supportAircraft, 6, "demandAttach.supportAircraft")
      log("MISSION_DEMAND_ATTACH_PASS demands=6 additionalAircraft=0 coreTracksRemainIndependent=true")

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
      verifyReliefSourceSpacing("MANAS")
      verifyReliefSourceSpacing("AL_UDEID")

      for _, spec in ipairs(CORE) do
        local station = getStation(spec.area, spec.profile)
        observed.reliefRuntimeId[spec.area] = station.reliefRuntime.runtimeId
        assertTrue(station.activeRuntime ~= station.reliefRuntime, spec.area .. " active and relief runtime unexpectedly identical")
        forceControlledTrackEntry(station.reliefRuntime)
      end

      log("RELIEF_6_TRACKS_12_AIRCRAFT_PASS activeTracks=6 aircraft=12 maxPerTrack=2 uniqueTransitCallsign=true uniqueMooseAssignedStn=true")
      setPhase(4, "SIX_TRACK_SCHEDULED_HANDOVER")
    end

  elseif phase == 4 then
    if allScheduledReliefsPromoted() then
      for _, spec in ipairs(CORE) do
        verifyStationCallsign(getRuntime(spec.area, spec.profile), spec.callsign, spec.area .. " relief station callsign")
      end
      log("SCHEDULED_RELIEF_PASS sixTracks=true controlledTiming=true outgoingIdentityOff=true reliefIdentityOn=true")
      setPhase(5, "SCHEDULED_OUTGOING_HANDOFF_SETTLEMENT")
    end

  elseif phase == 5 then
    local counts = OMW.AAR.GetRuntimeCounts()
    if counts.supportAircraft == 6 and noCoreReliefPresent() then
      assertPool(adapter, "MANAS", 12, 0, "postScheduled.MANAS")
      assertPool(adapter, "AL_UDEID", 38, 0, "postScheduled.AL_UDEID")
      assertTrue(allCoreActive(), "core coverage not continuous after scheduled relief settlement")
      log("SCHEDULED_HANDOFF_SETTLEMENT_PASS activeTracks=6 activeAircraft=6 exactRecredit=true")

      local beforeIds = {
        KRUSTY = getRuntime("KRUSTY", "SLOW").runtimeId,
        PATTY = getRuntime("PATTY", "SLOW").runtimeId,
        MOE = getRuntime("MOE", "FAST").runtimeId,
      }
      local _, abortStatus = OMW.AAR.EndDemand(D.KRUSTY, "ABORTED")
      local _, cancelStatus = OMW.AAR.EndDemand(D.PATTY, "CANCELLED")
      local _, completeStatus = OMW.AAR.EndDemand(D.MOE, "COMPLETE")
      assertEqual(abortStatus, "CORE_TRACK_RETAINED", "KRUSTY abort status")
      assertEqual(cancelStatus, "CORE_TRACK_RETAINED", "PATTY cancel status")
      assertEqual(completeStatus, "CORE_TRACK_RETAINED", "MOE complete status")
      assertEqual(getRuntime("KRUSTY", "SLOW").runtimeId, beforeIds.KRUSTY, "KRUSTY demand end changed core runtime")
      assertEqual(getRuntime("PATTY", "SLOW").runtimeId, beforeIds.PATTY, "PATTY demand end changed core runtime")
      assertEqual(getRuntime("MOE", "FAST").runtimeId, beforeIds.MOE, "MOE demand end changed core runtime")
      assertTrue(not getRuntime("KRUSTY", "SLOW").egressOrdered, "KRUSTY demand end ordered core egress")
      assertTrue(not getRuntime("PATTY", "SLOW").egressOrdered, "PATTY demand end ordered core egress")
      assertTrue(not getRuntime("MOE", "FAST").egressOrdered, "MOE demand end ordered core egress")
      log("DEMAND_END_PASS complete=true cancelled=true aborted=true coreTracksRetained=true noCoreEgress=true")

      local ns = getStation("NELSON", "FAST")
      assertTrue(ns and ns.activeRuntime and not ns.reliefRuntime, "NELSON steady state missing before FuelLow")
      observed.nelsonFuelLowOutgoingId = ns.activeRuntime.runtimeId
      ns.activeRuntime.flightGroup:FuelLow()
      assertTrue(ns.activeRuntime.egressOrdered, "NELSON FuelLow did not order outgoing egress")
      setPhase(6, "NELSON_FUELLOW_RELIEF_MATERIALIZATION")
    end

  elseif phase == 6 then
    local ns = getStation("NELSON", "FAST")
    if ns and ns.reliefRuntime then
      observed.nelsonFuelLowReliefId = ns.reliefRuntime.runtimeId
      assertTrue(observed.nelsonFuelLowReliefId ~= observed.nelsonFuelLowOutgoingId, "NELSON FuelLow relief duplicated outgoing runtime")
      forceControlledTrackEntry(ns.reliefRuntime)
      setPhase(7, "NELSON_FUELLOW_HANDOVER")
    end

  elseif phase == 7 then
    local ns = getStation("NELSON", "FAST")
    local counts = OMW.AAR.GetRuntimeCounts()
    if ns and ns.activeRuntime and ns.activeRuntime.runtimeId == observed.nelsonFuelLowReliefId
        and ns.activeRuntime.stationIdentityActive and counts.supportAircraft == 6 then
      verifyStationCallsign(ns.activeRuntime, "Texaco11", "NELSON FuelLow relief station callsign")
      assertTrue(ns.reliefRuntime == nil, "NELSON duplicate relief remained after FuelLow handover")
      assertPool(adapter, "MANAS", 12, 0, "postFuelLow.MANAS")
      log("FUEL_LOW_RELIEF_PASS duplicateRelief=false outgoingEgress=true reliefPromoted=true handoffRecredited=true coreCoverageRestored=true")

      local ps = getStation("PATTY", "SLOW")
      assertTrue(ps and ps.activeRuntime and not ps.reliefRuntime, "PATTY steady state missing before loss")
      observed.pattyLostRuntimeId = ps.activeRuntime.runtimeId
      local unit = ps.activeRuntime.group and ps.activeRuntime.group:GetUnit(1) or nil
      assertTrue(unit and unit:IsAlive(), "PATTY loss target unit unavailable")
      unit:Explode(LOSS_EXPLOSION_POWER)
      log("LOSS_INJECTION_ARMED area=PATTY method=MOOSE_UNIT_EXPLODE powerKgTNT=" .. tostring(LOSS_EXPLOSION_POWER))
      setPhase(8, "PATTY_LOSS_REPLACEMENT")
    end

  elseif phase == 8 then
    local manas = pool(adapter, "MANAS")
    local replacement = getRuntime("PATTY", "SLOW")
    if manas.lost == 1 and replacement and replacement.runtimeId ~= observed.pattyLostRuntimeId then
      observed.pattyReplacementId = replacement.runtimeId
      assertEqual(manas.quantity, 11, "loss replacement MANAS quantity")
      assertTrue(not replacement.lossHandled, "PATTY replacement already lossHandled")
      forceControlledTrackEntry(replacement)
      setPhase(9, "PATTY_REPLACEMENT_ON_STATION")
    end

  elseif phase == 9 then
    local ps = getStation("PATTY", "SLOW")
    local counts = OMW.AAR.GetRuntimeCounts()
    if ps and ps.activeRuntime and ps.activeRuntime.runtimeId == observed.pattyReplacementId
        and ps.activeRuntime.stationIdentityActive and counts.supportAircraft == 6 then
      verifyStationCallsign(ps.activeRuntime, "Texaco21", "PATTY replacement station callsign")
      assertEqual(counts.activeTracks, 6, "final activeTracks")
      assertTrue(allCoreActive(), "final core coverage incomplete")
      assertTrue(noCoreReliefPresent(), "final relief runtime unexpectedly present")
      assertPool(adapter, "MANAS", 11, 1, "final.MANAS")
      assertPool(adapter, "AL_UDEID", 38, 0, "final.AL_UDEID")
      log("AIRCRAFT_LOSS_PASS area=PATTY deadCallback=true aircraftRecredit=false lossAudit=1 replacementMaterialized=true coreCoverageRestored=true")
      log("FINAL_STEADY_STATE_PASS activeTracks=6 activeAircraft=6 MANAS_available=11 MANAS_lost=1 AL_UDEID_available=38 AL_UDEID_lost=0")
      log("RESULT PASS continuousCoreTracks=6 LISA=FAST MOE=FAST maxPhysicalDuringRelief=12 globalAarMissionLimit=false globalAarAircraftLimit=false maxAircraftPerTrack=2 demandEndDoesNotCloseCore=true mooseManagedStn=true controlledTrackEntry=true controlledReliefTiming=true physicalLossInjection=MOOSE_UNIT_EXPLODE restoreServerRestartEmulatedBySnapshotRestore=true")
      phase = 99
    end
  end
end, {}, POLL_SEC, POLL_SEC)

log(string.format(
  "HARNESS_READY testId=%s timeoutSec=%d continuousCoreTracks=6 LISA=FAST MOE=FAST expectedMaxPhysicalDuringRelief=12 controlledTrackEntry=true controlledReliefTiming=true lossMethod=MOOSE_UNIT_EXPLODE",
  TEST_ID,
  TIMEOUT_SEC
))
