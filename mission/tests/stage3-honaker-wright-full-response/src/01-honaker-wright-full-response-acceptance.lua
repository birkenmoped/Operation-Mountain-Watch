-- Operation Mountain Watch - Stage 3 full-response integration acceptance.
-- Test-ID: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
--
-- RED attack -> MOOSE OPSZONE threat qualification -> Honaker attack incident
-- -> owner-authored Guard PATHLINE patrol + one-group mixed QRF + Jalalabad rotary CAS
-- -> Wright Functional ARTY live coordinate fire -> local M1083 rearm -> CampaignState
-- AMMO reorder -> exactly one strategic RESUPPLY -> Jalalabad CH-47 CARGOTRANSPORT.

local TEST_ID = "STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local INSTALLATION_ID = "BLUE_GROUND_COP_HONAKER"
local HONAKER_NODE = "GROUND_NODE_HONAKER"
local WRIGHT_NODE = "GROUND_NODE_WRIGHT"
local JALALABAD_NODE = "GROUND_NODE_JALALABAD"
local PERSONNEL_RESOURCE = "GROUND_PERSONNEL"
local AMMO_RESOURCE = "GROUND_AMMO_PACKAGE"
local HONAKER_WAREHOUSE = "WH_BLUE_GND_HONAKER"
local HONAKER_ACCESS_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"
local WRIGHT_WAREHOUSE = "WH_BLUE_GND_WRIGHT"
local GUARD_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"
local QRF_VEHICLE_TYPE = "CHAP_MATV"
local GUARD_PATHLINE = "OMW_RTE_BLUE_GUARD_HONAKER_01"
local WRIGHT_BATTERY = "TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2"
local M1083_TEMPLATE = "TPL_BLUE_GND_SUP_M1083"
local WRIGHT_RESUPPLY_ZONE = "ZON_BLUE_GND_WRIGHT_RESUPPLY"
local PICKUP_ZONE = "ZON_BLUE_LOG_SLG_JALALABAD_01"
local DROP_ZONE = "OMW_BLUE_LZ_WRIGHT_01"
local PRIMARY_PATHLINE = "OMW_FlightPath_R500"
local WEST_PATHLINE = "OMW_FlightPath_WEST"
local CAS_PATHLINES = { PRIMARY_PATHLINE, WEST_PATHLINE }
local AIR_AMMO_PATHLINES = { PRIMARY_PATHLINE }
local JUNCTION_MAX_DISTANCE_M = 1000
local SECURITY_RADIUS_M = 1000
local GUARD_PATROL_SPEED_KMH = 5
local QRF_PERSONNEL = 5
local PERSONNEL_FLOOR = 80
local QRF_TACTICAL_RADIUS_NM = 5
local QRF_ENGAGE_RANGE_NM = 5
local FIRE_SHELLS = 4
local FIRE_TARGET_ACQUIRE_DELAY_SEC = 15
local ARTY_WAIT_FOR_SHOT_SEC = 300
local CAS_TACTICAL_RADIUS_NM = 5
local CAS_ENGAGE_RANGE_NM = 5
local CAS_COMBAT_HEIGHT_FT_AGL = 2500
local CAS_SPEED_KTS = 120
local PRIMARY_ALTITUDE_FT_AGL = 500
local WEST_ALTITUDE_FT_AGL = 2500
local PRECONDITION_TX = "STAGE3-E2E-WRIGHT-AMMO-PRECONDITION"
local REARM_TX = "STAGE3-E2E-WRIGHT-LOCAL-REARM"
local RESUPPLY_DEMAND_ID = "RESUPPLY-STAGE3-E2E-WRIGHT-AMMO-AIR-001"
local TRANSFER_ID = "TRANSFER-STAGE3-E2E-JALALABAD-WRIGHT-AMMO-AIR-001"
local CARGO_ID = "CARGO-STAGE3-E2E-JALALABAD-WRIGHT-AMMO-AIR-001"
local CARRIER_ID = "AIR-RESUPPLY-STAGE3-E2E-JALALABAD-WRIGHT-CH47-001"

local MissionDemand = OMW_STAGE3_MISSION_DEMAND
local CasPolicy = OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY
local FirePolicy = OMW_STAGE3_FIRE_SUPPORT_DEMAND_POLICY
local ThreatAdapter = OMW_STAGE3_FOB_THREAT_OPSZONE_ADAPTER
local IncidentCoordinator = OMW_STAGE3_GROUND_INSTALLATION_ATTACK_INCIDENT
local CasAdapter = OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER
local CasPatrolClosure = OMW_STAGE3_FOB_ATTACK_CAS_PATROL_CLOSURE
local FireAdapter = OMW_STAGE3_FUNCTIONAL_ARTY_DISPATCH_ADAPTER
local PersonnelLedger = OMW_STAGE3_PERSONNEL_LEDGER
local ResourceDemandPolicy = OMW_STAGE3_RESOURCE_DEMAND_POLICY
local ResourceDemandCoordinator = OMW_STAGE3_RESOURCE_DEMAND_COORDINATOR
local GroundAmmoRearmAdapter = OMW_STAGE3_GROUND_AMMO_REARM_ADAPTER
local FixedFireSupportAmmoSupport = OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_SUPPORT
local FixedFireSupportAmmoRearmService = OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_REARM_SERVICE
local GroundSupportMaterializer = OMW_STAGE3_GROUND_SUPPORT_MATERIALIZER
local HelicopterCorridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local MissionOwnedCorridor = OMW_STAGE3_HELICOPTER_MISSION_OWNED_CORRIDOR

local registry = MissionDemand.New()
local state = {
  failed=false, passed=false, ctx=nil, airwing=nil, ah64d=nil, ch47=nil,
  brigade=nil, guardCoord=nil, guardPathline=nil, guardPlatoon=nil, guardMission=nil, guardArmy=nil, guardGroup=nil, guardPatrolStarted=false,
  qrfPlatoon=nil, qrfEntries={}, qrfDeployed=false, qrfEngaged=false, qrfTacticalZone=nil,
  qrfRecoveryRequested=false, qrfReturned=false,
  threat=nil, threatStarted=false, threatStopped=false, perimeterClear=false, incident=nil, attackIncident=nil, attackIncidentClosed=false,
  tacticalRedCount=nil,
  casAdapter=nil, casDemand=nil, casMission=nil, casFlight=nil, casExecuting=false, casCorridor=false, casFired=false,
  casShotObserver=nil, casTacticalZone=nil, casAltitudeFtAsl=nil, casResolved=nil, casLifecycle=nil, casClosed=false,
  casFailed=false, casFailureReason=nil,
  battery=nil, arty=nil, fireAdapter=nil, fireDemand=nil, fireStarted=false, fireComplete=false,
  fireTargetCount=0, fireTargetCompleteCount=0, fireLastSourceGroupName=nil,
  physicalAmmoBefore=nil, physicalAmmoAfter=nil, physicalAmmoBeforeByTarget={}, physicalAmmoAfterByTarget={},
  rearmService=nil, rearmComplete=false, supportReturned=false,
  resupply=nil, cargo=nil, airMission=nil, airFlight=nil, airAsset=nil,
  loading=false, inTransit=false, delivered=false, airCorridor=false, airCorridorRequested=false, homeLanded=false, assetReturned=false,
  transitScheduler=nil, finishScheduler=nil,
}

local function log(text) env.info(TAG .. " " .. tostring(text), false) end
local function msg(topic, text, seconds)
  local line = "[STAGE 3][" .. topic .. "] " .. text
  log(line)
  MESSAGE:New(line, seconds or 8):ToAll()
end
local function stopFinishScheduler()
  if state.finishScheduler and type(state.finishScheduler.Stop)=="function" then
    state.finishScheduler:Stop()
    state.finishScheduler=nil
  end
end
local function fail(reason)
  if state.failed or state.passed then return end
  state.failed = true
  stopFinishScheduler()
  msg("FAIL", tostring(reason), 20)
end
local function failCas(reason)
  if state.casFailed or state.passed then return end
  state.casFailed = true
  state.casFailureReason = tostring(reason)
  msg("CAS FAIL", state.casFailureReason .. "; Guard/QRF/ARTY/logistics diagnostics continue", 20)
end
local function need(value, label)
  if not value then fail("missing " .. label) end
  return value
end
local function context()
  if state.ctx then return state.ctx end
  if type(OMW) ~= "table" or type(OMW.Ground) ~= "table" or type(OMW.Ground.Base) ~= "table" then fail("OMW Ground Base unavailable") return nil end
  state.ctx = OMW.Ground.Base.GetContext()
  return state.ctx
end
local function stockRow(nodeId, resourceId)
  for _, row in ipairs(OMW.Ground.Base.GetInitialStock().Rows or {}) do
    if row.nodeId == nodeId and row.resourceId == resourceId then return row end
  end
  return nil
end
local function redGroups(opsZone)
  local result = {}
  for _, group in pairs(opsZone:GetScannedGroupSet():GetSet()) do
    if group and group:IsAlive() and group:GetCoalition() == coalition.side.RED then result[#result+1] = group end
  end
  table.sort(result, function(a,b)
    return state.guardCoord:Get2DDistance(a:GetCoordinate()) < state.guardCoord:Get2DDistance(b:GetCoordinate())
  end)
  return result
end
local function incidentGroups()
  local result = {}
  if not state.attackIncident then return result end
  for _, group in ipairs(state.attackIncident:GetParticipants(true)) do
    if group and group:GetCoalition() == coalition.side.RED then result[#result+1] = group end
  end
  table.sort(result, function(a,b)
    return state.guardCoord:Get2DDistance(a:GetCoordinate()) < state.guardCoord:Get2DDistance(b:GetCoordinate())
  end)
  return result
end
local function routeLabel(pathlineNames) return table.concat(pathlineNames, " -> ") end

local function countRedGroundGroupsInTacticalZone()
  if not state.casTacticalZone then return nil end
  local redSet=SET_GROUP:New()
    :FilterCoalitions("red")
    :FilterCategoryGround()
    :FilterActive(true)
    :FilterZones({state.casTacticalZone})
    :FilterOnce()
  return redSet:CountAlive()
end

local function buildGuardPatrolRoute(group, pathline)
  local coordinates = pathline:GetCoordinates()
  if type(coordinates) ~= "table" or #coordinates < 2 then return nil, "GUARD_PATHLINE_REQUIRES_AT_LEAST_TWO_COORDINATES" end
  local route = {}
  for _, coordinate in ipairs(coordinates) do
    route[#route+1] = coordinate:WaypointGround(GUARD_PATROL_SPEED_KMH, "Off Road")
  end
  local repeatTask = group:TaskFunction("CONTROLLABLE.Route", route, 2)
  group:SetTaskWaypoint(route[#route], repeatTask)
  return route, nil
end

local function countQrfPersonnelSurvivors(armyGroup)
  if not armyGroup or type(armyGroup.GetGroup)~="function" then return 0 end
  local group=armyGroup:GetGroup()
  if not group or type(group.GetUnits)~="function" then return 0 end
  local survivors=0
  for _,unit in ipairs(group:GetUnits() or {}) do
    if unit and unit:IsAlive() and unit:GetTypeName()~=QRF_VEHICLE_TYPE then
      survivors=survivors+1
    end
  end
  return math.min(survivors,QRF_PERSONNEL)
end

local function requestQrfRecovery()
  if state.qrfRecoveryRequested then return true end
  local requested=false
  for _,entry in ipairs(state.qrfEntries) do
    if entry.mission and entry.army and not entry.recoveryRequested then
      entry.recoveryRequested=true
      entry.mission:Cancel()
      requested=true
    end
  end
  if requested then
    state.qrfRecoveryRequested=true
    msg("QRF","Known Honaker attack participants neutralized; mixed QRF mission cancelled and MOOSE ReturnToLegion recovery requested",12)
  end
  return requested
end

local function closeCasIfReady()
  if state.casClosed or state.casFailed or not state.attackIncidentClosed or not state.casDemand then return false end
  local _, closed, reason = CasPatrolClosure.Complete({
    adapter=state.casAdapter,
    registry=registry,
    missionDemand=MissionDemand,
    demandId=state.casDemand.id,
    tacticalComplete=true,
    executionEvidenceConfirmed=state.casFired,
    reason="KNOWN_ATTACKERS_NEUTRALIZED",
    executor="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
  })
  if closed ~= true then failCas("CAS patrol closure failed: " .. tostring(reason)); return false end
  state.casClosed = true
  msg("CAS", "Known Honaker attack participants neutralized; PATROLZONE CAS closed immediately and one-shot WEST/R500 recovery chain released; shotEvidence=" .. tostring(state.casFired), 12)
  return true
end

local function closeAttackIncidentIfClear()
  if state.attackIncidentClosed then
    requestQrfRecovery()
    closeCasIfReady()
    return true
  end
  if not state.attackIncident or not state.attackIncident:GetActive() then return false end
  if state.attackIncident:HasAliveParticipants() then return false end

  local tacticalRed=countRedGroundGroupsInTacticalZone()
  if tacticalRed and tacticalRed~=state.tacticalRedCount then
    state.tacticalRedCount=tacticalRed
    log(string.format("TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC radiusNm=%d alive=%d completionGate=INCIDENT_PARTICIPANTS",QRF_TACTICAL_RADIUS_NM,tacticalRed))
  end

  local _, closed, reason = state.attackIncident:Close("KNOWN_ATTACKERS_NEUTRALIZED")
  if closed ~= true then fail("Honaker attack incident closure failed: " .. tostring(reason)); return false end
  state.attackIncidentClosed = true
  msg("THREAT", "All known Honaker attack participants neutralized; attack incident closed", 14)
  if state.threat and state.threat.started and not state.threatStopped then
    state.threat:Stop()
    state.threatStopped=true
    msg("THREAT","Honaker response complete; 5-second MOOSE OPSZONE alarm scan stopped",10)
  end
  requestQrfRecovery()
  closeCasIfReady()
  return true
end

local function logCorridorProfiles(kind, installed)
  if not installed or not installed.waypointProfiles then return end
  for direction, profiles in pairs(installed.waypointProfiles) do
    for index, profile in ipairs(profiles) do
      log(string.format("%s_ROUTE_PROFILE direction=%s index=%d uid=%s pathline=%s altitudeFtAgl=%s altType=%s",
        tostring(kind), tostring(direction), index, tostring(profile.uid), tostring(profile.pathlineName),
        tostring(profile.altitudeFtAgl), tostring(profile.altType)))
    end
  end
  for uid, transition in pairs(installed.profileTransitions or {}) do
    log(string.format("%s_ROUTE_TRANSITION uid=%s pathline=%s altitudeFtAgl=%s keep=%s formation=%s",
      tostring(kind), tostring(uid), tostring(transition.pathlineName), tostring(transition.altitudeFtAgl),
      tostring(transition.keepAltitude == true), tostring(transition.formation)))
  end
end

-- Legacy corridor installation is retained only for the already accepted CH-47 cargo path.
-- Stage-3 opts into the owner-approved suffix contract so _R500 is exactly +500 m.
-- The caller must invoke this only AFTER physical slingload pickup has been confirmed.
local function installCargoCorridor(flight, mission, destination, pathlineNames, cargoReferences)
  local attempts = 0
  local function attempt()
    attempts = attempts + 1
    local resolved
    if #pathlineNames == 1 then
      resolved = HelicopterCorridor.Resolve({
        pathlineName=pathlineNames[1], originCoordinate=flight:GetCoordinate(), destinationCoordinate=destination,
        offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
      })
    else
      resolved = HelicopterCorridor.ResolveSequence({
        pathlineNames=pathlineNames,
        originCoordinate=flight:GetCoordinate(), destinationCoordinate=destination,
        maxJunctionDistanceM=JUNCTION_MAX_DISTANCE_M,
        offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
      })
    end
    local installed, ok, reason = HelicopterCorridor.Install(flight, mission, resolved, PRIMARY_ALTITUDE_FT_AGL, cargoReferences)
    if ok then
      state.airCorridor = true
      logCorridorProfiles("AIR-AMMO", installed)
      msg("LOGISTICS", "Slingload attached; AIR-AMMO outbound + return route installed via " .. routeLabel(pathlineNames) .. " with explicit cargo/drop references", 12)
      return
    end
    if reason == "MISSION_ROUTE_UIDS_NOT_READY" and attempts < 8 then SCHEDULER:New(nil, attempt, {}, 2); return end
    if reason ~= "MISSION_ROUTE_UIDS_NOT_READY" then fail("AIR-AMMO corridor failed: " .. tostring(reason)) end
  end
  attempt()
end

local function prepareAirwing()
  local air = OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(air) ~= "table" or air.Status ~= "RUNNING" or not air.Airwing then
    log("AIRWING_PRECHECK unavailable; ground response remains armed and CAS will report a scoped failure only if demanded")
    return false
  end
  if not air.Squadrons or not air.Squadrons.AH64D or not air.Squadrons.CH47 then
    log("AIRWING_PRECHECK Jalalabad AH64D/CH47 squadron missing; ground response remains armed")
    return false
  end
  state.airwing = air.Airwing
  state.ah64d = air.Squadrons.AH64D
  state.ch47 = air.Squadrons.CH47
  if not GROUP:FindByName("TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP") then log("AIRWING_PRECHECK Jalalabad CH47 template missing") return false end
  if not PATHLINE:FindByName(PRIMARY_PATHLINE) or not PATHLINE:FindByName(WEST_PATHLINE) then
    log("AIRWING_PRECHECK required helicopter PATHLINE missing; primary must use owner-approved _R500 suffix")
    return false
  end
  return true
end

local function ensureCasContext()
  if state.casAdapter and state.casTacticalZone and state.casResolved then return true end
  if not state.airwing or not state.ah64d then failCas("Jalalabad AIRWING/AH64D unavailable when CAS demand was created") return false end
  local centerVec2 = state.guardCoord:GetVec2()
  local landHeightM = state.guardCoord:GetLandHeight()
  state.casAltitudeFtAsl = UTILS.MetersToFeet(landHeightM) + CAS_COMBAT_HEIGHT_FT_AGL
  state.casTacticalZone = ZONE_RADIUS:New("OMW_TACTICAL_BLUE_GROUND_COP_HONAKER_STAGE3_CAS", centerVec2, UTILS.NMToMeters(CAS_TACTICAL_RADIUS_NM))
  if not state.casTacticalZone then failCas("MOOSE ZONE_RADIUS creation failed for Honaker CAS tactical area") return false end

  state.casResolved = HelicopterCorridor.ResolveSequence({
    pathlineNames=CAS_PATHLINES,
    originCoordinate=state.airwing:GetCoordinate(),
    destinationCoordinate=state.casTacticalZone:GetCoordinate(),
    maxJunctionDistanceM=JUNCTION_MAX_DISTANCE_M,
    offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
    segmentProfiles={
      { altitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL },
      { altitudeFtAgl=WEST_ALTITUDE_FT_AGL, formation=ENUMS.Formation.RotaryWing.Column.D70 },
    },
  })

  local primaryOffset = state.casResolved.segmentOffsets and state.casResolved.segmentOffsets[1] or nil
  local westOffset = state.casResolved.segmentOffsets and state.casResolved.segmentOffsets[2] or nil
  log(string.format("CAS_ROUTE_POLICY path=%s primaryOffsetM=%s westOffsetM=%s altitudeSource=WAYPOINT_RADIO_ONLY",
    routeLabel(CAS_PATHLINES), tostring(primaryOffset and primaryOffset.signedRightM), tostring(westOffset and westOffset.signedRightM)))

  state.casAdapter = CasAdapter.New({
    missionDemand=MissionDemand,
    registry=registry,
    airwing=state.airwing,
    assigneeId="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
    missionMode=CasAdapter.MissionMode.PATROLZONE_ENGAGE,
    casAltitudeFt=state.casAltitudeFtAsl,
    casSpeedKts=CAS_SPEED_KTS,
    engageDetectedRangeNm=CAS_ENGAGE_RANGE_NM,
    engageDetectedTargetTypes={"Ground Units"},
    squadrons={state.ah64d},
    requireExecutionEvidence=false,
    missionConfigurator=function(mission)
      mission:SetName("OMW_STAGE3_HONAKER_CAS_PATROLZONE_ENGAGE")
      state.casLifecycle = MissionOwnedCorridor.ConfigureMission(mission, state.casResolved, {
        speedKts=CAS_SPEED_KTS,
        defaultAltitudeFtAgl=CAS_COMBAT_HEIGHT_FT_AGL,
      })
    end,
  })
  return state.casAdapter ~= nil
end

local function installCasShotObserver()
  if state.casShotObserver then return end
  state.casShotObserver = EVENTHANDLER:New()
  state.casShotObserver:HandleEvent(EVENTS.Shot)
  function state.casShotObserver:OnEventShot(EventData)
    if state.failed or state.casFailed or state.casFired or not state.casFlight or not state.casDemand then return end
    if not EventData or EventData.IniGroupName ~= state.casFlight:GetName() then return end
    state.casFired = true
    local weaponType = EventData.WeaponTypeName or (EventData.Weapon and EventData.Weapon.getTypeName and EventData.Weapon:getTypeName()) or "unknown"
    local _, confirmed, reason = state.casAdapter:ConfirmExecutionEvidence(state.casDemand.id, { event="SHOT", weaponType=weaponType })
    if confirmed ~= true then failCas("CAS shot evidence could not be correlated: " .. tostring(reason)); return end
    msg("CAS", "AH-64D weapon employment confirmed: " .. tostring(weaponType) .. "; tactical completion owns immediate mission closure", 12)
    closeAttackIncidentIfClear()
  end
end

local function bindCasMissionOwnedCorridor(flight, mission)
  local installed, ok, reason = MissionOwnedCorridor.Bind(flight, mission, state.casResolved, {
    defaultAltitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL,
    onInstalled=function(result)
      state.casCorridor = true
      logCorridorProfiles("CAS", result)
      msg("CAS", "One-shot MOOSE waypoint/task chain installed: common-route entry -> R500 -> WEST -> CAS -> WEST reverse -> R500 reverse -> Jalalabad egress", 12)
    end,
    onFailed=function(why) failCas("CAS mission-owned corridor failed: " .. tostring(why)) end,
  })
  if ok then state.casCorridor = true; logCorridorProfiles("CAS", installed) end
  if not ok and reason ~= "MISSION_ROUTE_UIDS_NOT_READY" then failCas("CAS mission-owned corridor failed: " .. tostring(reason)) end
end

local function installAirObserver()
  if not state.airwing or state.airwing.__omwStage3E2EObserver then return end
  state.airwing.__omwStage3E2EObserver = true
  local previous = state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previous then previous(self, From, Event, To, FlightGroup, Mission) end
    if Mission == state.casMission then
      state.casFlight = FlightGroup
      installCasShotObserver()
      msg("CAS", "Jalalabad AH-64D assigned to PATROLZONE + SetEngageDetected; route entry is now the native MOOSE ingress anchor before the CAS objective", 12)
      bindCasMissionOwnedCorridor(FlightGroup, Mission)
      return
    end
    if Mission ~= state.airMission then return end
    state.airFlight = FlightGroup
    state.airAsset = Mission:GetAssetByName(FlightGroup:GetName())
    if not state.airAsset then fail("CH47 mission asset not found") return end
    local tx = context().store:MarkLoading(TRANSFER_ID)
    registry:SetReservationState(RESUPPLY_DEMAND_ID, "LOADING")
    state.loading = tx and tx.status == context().campaignState.TransactionStatus.LOADING
    msg("LOGISTICS", "CH-47 assigned; Air-AMMO manifest loading at Jalalabad; corridor injection waits for physical slingload pickup", 10)
    local oldLanded = FlightGroup.OnAfterLanded
    function FlightGroup:OnAfterLanded(F,E,T,Airbase)
      if oldLanded then oldLanded(self,F,E,T,Airbase) end
      if state.delivered and Airbase and Airbase:GetName() == state.airwing:GetAirbaseName() then
        state.homeLanded = true
        msg("LOGISTICS", "CH-47 landed back at Jalalabad via " .. PRIMARY_PATHLINE, 9)
      end
    end
    state.transitScheduler = SCHEDULER:New(nil, function()
      if state.failed or state.inTransit or not state.loading then return end
      if not state.cargo or state.cargo:IsAlive() ~= true then fail("Air-AMMO cargo lost before transit") return end
      if state.cargo:IsInZone(ZONE:FindByName(PICKUP_ZONE)) then return end
      context().store:MarkInTransit(TRANSFER_ID)
      registry:SetReservationState(RESUPPLY_DEMAND_ID, "IN_TRANSIT")
      local demand = registry:Get(RESUPPLY_DEMAND_ID)
      if demand and demand.status == MissionDemand.Status.AI_ASSIGNED then registry:Activate(RESUPPLY_DEMAND_ID) end
      state.inTransit = true
      if state.transitScheduler and type(state.transitScheduler.Stop)=="function" then state.transitScheduler:Stop() end
      msg("LOGISTICS", "Air-AMMO cargo physically picked up; Jalalabad -> Wright IN TRANSIT; corridor routing starts now", 10)
      if not state.airCorridorRequested then
        state.airCorridorRequested=true
        local dropZone = ZONE:FindByName(DROP_ZONE)
        installCargoCorridor(FlightGroup, Mission, dropZone:GetCoordinate(), AIR_AMMO_PATHLINES, {
          cargo=state.cargo,
          dropZone=dropZone,
        })
      end
    end, {}, 2, 2)
  end
  local oldReturn = state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(From, Event, To, Cohort, Asset)
    if oldReturn then oldReturn(self, From, Event, To, Cohort, Asset) end
    if state.airAsset and Asset == state.airAsset then
      if not state.homeLanded then fail("CH47 returned to AIRWING before home landing") return end
      state.assetReturned = true
      msg("LOGISTICS", "CH-47 recovered by Jalalabad AIRWING", 8)
    end
  end
end

local function preconditionWright()
  local ctx = context()
  local before = ctx.store:GetResource(WRIGHT_NODE, AMMO_RESOURCE)
  if not before or before.quantity ~= 30 then fail("Wright initial AMMO expected 30") return false end
  local tx, created = ctx.store:ReserveResource({
    transactionId=PRECONDITION_TX, reservationId="ACCEPTANCE:"..PRECONDITION_TX,
    kind=ctx.campaignState.TransactionKind.CONSUMPTION, resourceId=AMMO_RESOURCE, quantity=14,
    canonicalUnit="count", originNodeId=WRIGHT_NODE,
  })
  if created ~= true then fail("Wright precondition transaction failed") return false end
  ctx.store:Consume(tx.transactionId)
  ctx.store:CompleteConsumption(tx.transactionId)
  if ctx.store:GetResource(WRIGHT_NODE, AMMO_RESOURCE).quantity ~= 16 then fail("Wright precondition did not reach 16") return false end
  msg("CAMPAIGN", "Acceptance precondition: Wright strategic AMMO 30 -> 16; one real rearm will cross reorder threshold", 12)
  return true
end

local function startAirResupply()
  if state.resupply then return end
  if not state.airwing or not state.ch47 then fail("Jalalabad AIRWING/CH47 unavailable when strategic Air-AMMO resupply became necessary") return end
  local ctx = context()
  local row = stockRow(WRIGHT_NODE, AMMO_RESOURCE)
  local wright = ctx.store:GetResource(WRIGHT_NODE, AMMO_RESOURCE)
  if not row or not wright or wright.quantity ~= 15 then fail("Wright must be at 15 AMMO after local rearm") return end
  msg("LOGISTICS", "Wright AMMO reorder threshold reached: 15 / 30", 10)
  local demand, created, reason = ResourceDemandCoordinator.EvaluateAndCreate({
    policy=ResourceDemandPolicy, missionDemand=MissionDemand, registry=registry, store=ctx.store, row=row,
    demandIdFactory=function() return RESUPPLY_DEMAND_ID end,
  })
  if not demand or created ~= true then fail("Wright RESUPPLY demand failed: " .. tostring(reason)) return end
  state.resupply = demand
  local duplicate, duplicateCreated, duplicateReason = ResourceDemandCoordinator.EvaluateAndCreate({
    policy=ResourceDemandPolicy, missionDemand=MissionDemand, registry=registry, store=ctx.store, row=row,
    demandIdFactory=function() return "DUPLICATE" end,
  })
  if type(duplicate) ~= "table"
      or duplicate.id ~= demand.id
      or duplicate.dedupeKey ~= demand.dedupeKey
      or duplicateCreated ~= false
      or duplicateReason ~= "active_duplicate" then
    fail("RESUPPLY semantic dedupe failed")
    return
  end
  msg("LOGISTICS", "Exactly one strategic RESUPPLY demand created; active duplicate confirmed by id/dedupeKey", 10)
  local transfer, transferCreated = ctx.store:ReserveResource({
    transactionId=TRANSFER_ID, reservationId="MISSION-DEMAND:"..RESUPPLY_DEMAND_ID, cargoId=CARGO_ID,
    missionDemandId=RESUPPLY_DEMAND_ID, carrierEntityId=CARRIER_ID, kind=ctx.campaignState.TransactionKind.TRANSFER,
    resourceId=AMMO_RESOURCE, quantity=15, canonicalUnit="count", originNodeId=JALALABAD_NODE, destinationNodeId=WRIGHT_NODE,
  })
  if transferCreated ~= true then fail("Air-AMMO transfer reservation failed") return end
  registry:SetReservationState(RESUPPLY_DEMAND_ID, "RESERVED", {
    transactionId=TRANSFER_ID, cargoId=CARGO_ID, originNodeId=JALALABAD_NODE, destinationNodeId=WRIGHT_NODE,
    resourceId=AMMO_RESOURCE, quantity=15, carrierEntityId=CARRIER_ID,
  })
  local pickup = need(ZONE:FindByName(PICKUP_ZONE), PICKUP_ZONE)
  local drop = need(ZONE:FindByName(DROP_ZONE), DROP_ZONE)
  if state.failed then return end
  state.cargo = SPAWNSTATIC:NewFromType("ammo_cargo", "Cargos", country.id.USA):InitCargo(true):InitCargoMass(1000)
    :InitCoordinate(pickup:GetCoordinate()):InitValidateAndRepositionStatic(false):Spawn(0,CARGO_ID)
  if not state.cargo then fail("physical Air-AMMO cargo spawn failed") return end
  msg("LOGISTICS", "Physical slingload manifest created in " .. PICKUP_ZONE, 8)
  state.airMission = AUFTRAG:NewCARGOTRANSPORT(state.cargo, drop)
  state.airMission:SetName("OMW_STAGE3_E2E_AIR_AMMO_JALALABAD_TO_WRIGHT")
  state.airMission:SetRequiredAssets(1,1)
  state.airMission:AssignSquadrons({state.ch47})
  state.airMission:SetPriority(20,true)
  local oldSuccess = state.airMission.OnAfterSuccess
  function state.airMission:OnAfterSuccess(From,Event,To)
    if oldSuccess then oldSuccess(self,From,Event,To) end
    if not state.inTransit or not state.cargo:IsAlive() or not state.cargo:IsInZone(drop) then fail("Air-AMMO success lacks physical delivery evidence") return end
    if state.transitScheduler and type(state.transitScheduler.Stop)=="function" then state.transitScheduler:Stop() end
    ctx.store:MarkDelivered(TRANSFER_ID)
    registry:SetReservationState(RESUPPLY_DEMAND_ID,"DELIVERED")
    registry:Succeed(RESUPPLY_DEMAND_ID,{
      transactionId=TRANSFER_ID, cargoId=CARGO_ID, carrierEntityId=CARRIER_ID,
      physicalMission="AUFTRAG:CARGOTRANSPORT", corridor=PRIMARY_PATHLINE,
    })
    state.delivered = true
    msg("LOGISTICS", "Air-AMMO delivered at Wright; strategic stock restored to 30 / 30", 12)
  end
  local oldFailed = state.airMission.OnAfterFailed
  function state.airMission:OnAfterFailed(From,Event,To)
    if oldFailed then oldFailed(self,From,Event,To) end
    fail("MOOSE CARGOTRANSPORT failed")
  end
  registry:AssignAI(RESUPPLY_DEMAND_ID,"AI:SQUADRON:SQ_US_JBAD_CH47_HEAVYLIFT")
  state.airwing:AddMission(state.airMission)
  msg("LOGISTICS", "Jalalabad CH-47 Air-AMMO mission queued; pickup must precede corridor ingress", 12)
end

local function fireTargetTelemetry(target)
  local coordinate = target:GetCoordinate()
  local vec3 = coordinate:GetVec3()
  local distance = state.battery:GetCoordinate():Get2DDistance(coordinate)
  local minRange = state.arty.minrange
  local maxRange = state.arty.maxrange
  if type(minRange)=="number" and distance < minRange then return nil, "BELOW_MOOSE_MIN_RANGE" end
  if type(maxRange)=="number" and distance > maxRange then return nil, "BEYOND_MOOSE_MAX_RANGE" end
  return { coordinate=coordinate, vec3=vec3, distanceM=distance, minRangeM=minRange, maxRangeM=maxRange }, nil
end

local function selectNextFireTarget()
  local targets = incidentGroups()
  if #targets == 0 then return nil end
  if not state.fireLastSourceGroupName then return targets[1] end
  for index, target in ipairs(targets) do
    if target:GetName() == state.fireLastSourceGroupName then return targets[(index % #targets) + 1] end
  end
  return targets[1]
end

local function reportFireMission(target, missionNumber)
  local telemetry, reason = fireTargetTelemetry(target)
  if not telemetry then fail("Wright target range rejected for " .. tostring(target:GetName()) .. ": " .. tostring(reason)) return nil end
  msg("FIRE SUPPORT",string.format("Fire mission %d -> %s current x=%.0f z=%.0f; Wright range %.2f km; envelope %.2f-%.2f km",
    missionNumber, target:GetName(), telemetry.vec3.x, telemetry.vec3.z, telemetry.distanceM/1000,
    (tonumber(telemetry.minRangeM) or 0)/1000, (tonumber(telemetry.maxRangeM) or 0)/1000),12)
  return telemetry
end

local function queueNextFireMission(demandId)
  if state.failed or state.fireComplete then return false end
  local ammo = state.arty:GetAmmo(false)
  if type(ammo)=="number" and ammo < FIRE_SHELLS then
    msg("FIRE SUPPORT",string.format("Wright physical ammo %d below next %d-round mission; ending fire cycle for rearm",ammo,FIRE_SHELLS),12)
    return false
  end
  local target = selectNextFireTarget()
  if not target then
    closeAttackIncidentIfClear()
    msg("FIRE SUPPORT","No living known RED attack participant remains; ending current fire cycle and releasing CAS/QRF recovery immediately",10)
    return false
  end
  local nextNumber = state.fireTargetCount + 1
  if not reportFireMission(target,nextNumber) then return false end
  local targetName, queued, reason = state.fireAdapter:QueueTarget(demandId,target)
  if queued ~= true then fail("Wright ARTY live retarget failed: "..tostring(reason)) return false end
  state.fireTargetCount = nextNumber
  state.fireLastSourceGroupName=target:GetName()
  log(string.format("LIVE_FIRE_RETARGET demandId=%s mission=%d sourceGroup=%s artyTarget=%s",tostring(demandId),nextNumber,tostring(target:GetName()),tostring(targetName)))
  return true
end

local function setupFireSupport()
  local ctx = context()
  state.battery = need(GROUP:FindByName(WRIGHT_BATTERY), WRIGHT_BATTERY)
  local supportZone = need(ZONE:FindByName(WRIGHT_RESUPPLY_ZONE), WRIGHT_RESUPPLY_ZONE)
  need(GROUP:FindByName(M1083_TEMPLATE), M1083_TEMPLATE)
  if state.failed then return false end
  state.arty = ARTY:New(state.battery,"Wright L118 Stage3 E2E")
  state.arty:SetReportOFF()
  state.arty:SetWaitForShotTime(ARTY_WAIT_FOR_SHOT_SEC)
  state.arty:Start()
  local rearmBrigade = BRIGADE:New(WRIGHT_WAREHOUSE,"BDE_BLUE_GND_WRIGHT_STAGE3_E2E_REARM")
  state.rearmService = FixedFireSupportAmmoRearmService.New({
    fixedFireSupportAmmoSupportModule=FixedFireSupportAmmoSupport,
    groundAmmoRearmAdapterModule=GroundAmmoRearmAdapter,
    store=ctx.store, campaignState=ctx.campaignState,
    artyFactory=function(group) if group~=state.battery then error(TAG.." wrong battery",2) end; return state.arty end,
    brigade=rearmBrigade, spawnZone=supportZone, spawnZoneMaxDistanceM=500,
    materializerModule=GroundSupportMaterializer, platoonFactory=function(t,c,n) return PLATOON:New(t,c,n) end,
    descriptorGroupName=WAREHOUSE.Descriptor.GROUPNAME, templateName=M1083_TEMPLATE,
    platoonName="PLT_BLUE_GND_WRIGHT_STAGE3_E2E_REARM", assignment="OMW:WRIGHT:AMMO-SUPPORT:STAGE3-E2E",
    carrierEntityId="WRIGHT-AMMO-SUPPORT-M1083-STAGE3-E2E", nodeId=WRIGHT_NODE, alias="Wright L118 Stage3 E2E",
    stockCount=1, priority=20, returnCheckIntervalSec=5, returnTimeoutSec=300,
    log=function(level,text) log("REARM "..tostring(level).." "..tostring(text)) end,
    onRearmed=function() state.rearmComplete=true; msg("FIRE SUPPORT","Wright local L118 rearm complete; CampaignState AMMO 15 / 30",12) end,
    onSupportReturned=function() state.supportReturned=true; msg("FIRE SUPPORT","Wright M1083 returned to Warehouse stock",8); startAirResupply() end,
    onSupportReturnFailed=function(_,reason) fail("Wright M1083 return failed: "..tostring(reason)) end,
  })
  state.fireAdapter = FireAdapter.New({
    missionDemand=MissionDemand, registry=registry, arty=state.arty, assigneeId="ARTY:WRIGHT:L118",
    priority=10, radiusM=50, shells=FIRE_SHELLS, maxEngagements=1, weaponType=ARTY.WeaponType.Auto,
    onFireStarted=function(_,target)
      state.fireStarted=true
      local targetName = target and target.name or "unknown"
      local metadata = state.fireAdapter:GetTargetMetadata(targetName)
      local sourceName = metadata and metadata.sourceGroupName or targetName
      local ammo = state.arty:GetAmmo(false)
      if state.physicalAmmoBefore == nil then state.physicalAmmoBefore = ammo end
      state.physicalAmmoBeforeByTarget[targetName] = ammo
      msg("FIRE SUPPORT",string.format("Wright L118 firing at %s; physical ammo before=%s",sourceName,tostring(ammo)),12)
    end,
    verifyFireComplete=function(_,target)
      local targetName = target and target.name or "unknown"
      local before = state.physicalAmmoBeforeByTarget[targetName]
      local after = state.arty:GetAmmo(false)
      state.physicalAmmoAfterByTarget[targetName] = after
      state.physicalAmmoAfter = after
      if type(before)~="number" or type(after)~="number" then return false,"PHYSICAL_AMMO_UNAVAILABLE" end
      if after>=before then return false,"PHYSICAL_AMMO_UNCHANGED" end
      return true
    end,
    onTargetComplete=function(demandId,target)
      state.fireTargetCompleteCount = state.fireTargetCompleteCount + 1
      local targetName = target and target.name or "unknown"
      local metadata = state.fireAdapter:GetTargetMetadata(targetName)
      local sourceName = metadata and metadata.sourceGroupName or targetName
      msg("FIRE SUPPORT",string.format("Fire mission %d complete: %s ammo %s -> %s; reacquiring living attack-incident participants",
        state.fireTargetCompleteCount,sourceName,tostring(state.physicalAmmoBeforeByTarget[targetName]),tostring(state.physicalAmmoAfterByTarget[targetName])),12)
      queueNextFireMission(demandId)
    end,
    onFireRejected=function(_,target,_,reason)
      local targetName = target and target.name or "unknown"
      local metadata = state.fireAdapter:GetTargetMetadata(targetName)
      local sourceName = metadata and metadata.sourceGroupName or targetName
      msg("FIRE SUPPORT",string.format("Wright physical fire NOT confirmed for %s: ammo %s -> %s; %s",
        sourceName,tostring(state.physicalAmmoBeforeByTarget[targetName]),tostring(state.physicalAmmoAfterByTarget[targetName]),tostring(reason)),20)
      fail("Wright L118 physical fire not confirmed: "..tostring(reason))
    end,
    onFireComplete=function(demandId)
      if state.fireComplete then return end
      state.fireComplete=true
      msg("FIRE SUPPORT",string.format("Wright live fire cycle ended after %d coordinate missions; total physical ammo %s -> %s; local M1083 rearm requested",
        state.fireTargetCount,tostring(state.physicalAmmoBefore),tostring(state.physicalAmmoAfter)),14)
      state.rearmService:Request({
        transactionId=REARM_TX, missionDemandId=demandId, nodeId=WRIGHT_NODE, resourceId=AMMO_RESOURCE, quantity=1,
        artilleryGroup=state.battery, alias="Wright L118 Stage3 E2E", onRoad=false, rearmingDistance=100,
        supportReturnRadiusM=100, startArty=false,
      })
    end,
  })
  return true
end

local function dispatchQrf()
  local targets = incidentGroups()
  if #targets == 0 then fail("no known RED attack participants available for Honaker QRF") return end
  if not state.qrfTacticalZone then
    state.qrfTacticalZone = ZONE_RADIUS:New("OMW_TACTICAL_BLUE_GROUND_COP_HONAKER_STAGE3_QRF", state.guardCoord:GetVec2(), UTILS.NMToMeters(QRF_TACTICAL_RADIUS_NM))
  end
  if not state.qrfTacticalZone then fail("Honaker QRF tactical ZONE_RADIUS creation failed") return end
  local personnel = context().store:GetResource(HONAKER_NODE,PERSONNEL_RESOURCE)
  if not personnel or personnel.available - QRF_PERSONNEL < PERSONNEL_FLOOR then fail("Honaker mixed QRF blocked by personnel reserve floor") return end
  if state.qrfPlatoon:CountAssets(true,AUFTRAG.Type.ONGUARD) < 1 then fail("Honaker mixed QRF asset unavailable") return end

  msg("QRF",string.format("Honaker requests mixed QRF package: 5 infantry + 1 M-ATV/MRAP-class vehicle in one 6-unit GROUP in shared %d-NM tactical area",QRF_TACTICAL_RADIUS_NM),12)
  local deployment = PersonnelLedger.New({
    store=context().store, campaignState=context().campaignState, nodeId=HONAKER_NODE, resourceId=PERSONNEL_RESOURCE,
    deploymentId="STAGE3-HONAKER-QRF-MIXED-6", entityId="HONAKER-QRF-MIXED-6", quantity=QRF_PERSONNEL, missionDemandId=TEST_ID,
  })
  local target = targets[1]
  local mission = AUFTRAG:NewONGUARD(target:GetCoordinate())
  mission:SetEngageDetected(QRF_ENGAGE_RANGE_NM,{"Ground Units"},state.qrfTacticalZone)
  mission:SetRequiredAssets(1,1)
  mission:SetReturnToLegion(true)
  mission:SetName("OMW_STAGE3_HONAKER_QRF_MIXED")
  mission:AssignCohort(state.qrfPlatoon)
  state.qrfEntries[1]={role="MIXED",mission=mission,initialTargetName=target:GetName(),deployment=deployment,army=nil,engaged=false,recoveryRequested=false,returned=false}
  state.brigade:AddMission(mission)
end

local function dispatchFire(incident)
  local target = selectNextFireTarget()
  if not target then fail("no living known RED attack participant for Wright fire support") return end
  if not reportFireMission(target,1) then return end
  local p = target:GetCoordinate():GetVec3()
  local demand,created,reason = FirePolicy.CreateDemand(MissionDemand,registry,incident,{
    targetKind="DETECTED_RED_GROUND_GROUP", targetName=target:GetName(), position={x=p.x,y=p.y,z=p.z},
  })
  if created~=true then fail("fire-support demand failed: "..tostring(reason)) return end
  state.fireDemand=demand
  state.fireTargetCount=1
  state.fireLastSourceGroupName=target:GetName()
  msg("FIRE SUPPORT","Honaker requests immediate fire support; local mortar unavailable; incident-participant retarget cycle armed",12)
  msg("FIRE SUPPORT","Wright L118 selected; one current MOOSE coordinate Fire At Point mission queued",10)
  local targetName,dispatched,dispatchReason=state.fireAdapter:Dispatch(demand,target)
  if dispatched~=true then fail("Wright ARTY dispatch failed: "..tostring(dispatchReason)) return end
  log(string.format("LIVE_FIRE_RETARGET demandId=%s mission=1 sourceGroup=%s artyTarget=%s",tostring(demand.id),tostring(target:GetName()),tostring(targetName)))
end

local function setupDefenceAndThreat()
  state.brigade = BRIGADE:New(HONAKER_WAREHOUSE,"BDE_BLUE_GND_HONAKER_STAGE3_E2E")
  state.guardCoord = state.brigade:GetCoordinate()
  local accessZone = need(ZONE:FindByName(HONAKER_ACCESS_ZONE), HONAKER_ACCESS_ZONE)
  state.guardPathline = need(PATHLINE:FindByName(GUARD_PATHLINE), GUARD_PATHLINE)
  state.attackIncident = IncidentCoordinator.New({ installationId=INSTALLATION_ID, incidentIdFactory=function(_,seq) return "INC-STAGE3-HONAKER-"..seq end })
  if state.failed then return false end
  state.brigade:SetSpawnZone(accessZone)
  log("HONAKER_GROUND_SPAWN_ZONE " .. HONAKER_ACCESS_ZONE .. " applies to Guard and QRF materialization via MOOSE default 5000-m SetSpawnZone limit")

  state.guardPlatoon = PLATOON:New(GUARD_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_GUARD")
  state.guardPlatoon:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  state.brigade:AddPlatoon(state.guardPlatoon)

  state.qrfPlatoon = PLATOON:New(QRF_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_QRF_MIXED_6")
  state.qrfPlatoon:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  state.brigade:AddPlatoon(state.qrfPlatoon)

  state.brigade.OnAfterArmyOnMission=function(self,From,Event,To,ArmyGroup,Mission)
    if Mission == state.guardMission then
      state.guardArmy = ArmyGroup
      state.guardGroup = ArmyGroup:GetGroup()
      if not state.guardGroup then fail("Honaker Guard ArmyGroup has no MOOSE GROUP wrapper") return end
      local route, routeReason = buildGuardPatrolRoute(state.guardGroup, state.guardPathline)
      if not route then fail("Honaker Guard PATHLINE route build failed: "..tostring(routeReason)) return end
      state.guardGroup:Route(route,2)
      state.guardPatrolStarted=true
      msg("GUARD",string.format("Honaker infantry Guard deployed and routed on %s via MOOSE PATHLINE/GetCoordinates/WaypointGround/TaskFunction/Route; %d route points, repeated circuit",GUARD_PATHLINE,#route),12)
      return
    end
    for _,entry in ipairs(state.qrfEntries) do
      if entry.mission==Mission then
        entry.army=ArmyGroup
        state.qrfDeployed=true
        msg("QRF","Honaker mixed QRF group deployed; MOOSE ONGUARD detection remains active against the shared incident picture",10)
        local oldEngage=ArmyGroup.OnAfterEngageTarget
        function ArmyGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
          if oldEngage then oldEngage(self,F,E,T,Target,Speed,Formation) end
          entry.engaged=true
          state.qrfEngaged=true
          local engagedName=entry.initialTargetName
          if Target and type(Target.GetName)=="function" then engagedName=Target:GetName() end
          msg("QRF","Honaker mixed QRF engaging detected "..tostring(engagedName),8)
        end
        local oldReturned=ArmyGroup.OnAfterReturned
        function ArmyGroup:OnAfterReturned(F,E,T)
          if oldReturned then oldReturned(self,F,E,T) end
          if entry.returned then return end
          local survivors=countQrfPersonnelSurvivors(self)
          local settlement,settled=entry.deployment:SettleReturned(survivors)
          entry.returned=true
          state.qrfReturned=true
          msg("QRF",string.format("Honaker mixed QRF returned to camp/Warehouse; personnel survivors=%d casualties=%d reservationSettled=%s",
            survivors,settlement and settlement.casualties or -1,tostring(settled==true)),12)
        end
        if state.attackIncidentClosed and not entry.recoveryRequested then requestQrfRecovery() end
      end
    end
  end

  state.brigade.OnAfterStart=function()
    SCHEDULER:New(nil,function()
      state.guardMission=AUFTRAG:NewONGUARD(state.guardPathline:GetCoordinates()[1])
      state.guardMission:SetEngageDetected(SECURITY_RADIUS_M/1852,{"Ground Units"})
      state.guardMission:SetRequiredAssets(1,1)
      state.guardMission:SetName("OMW_STAGE3_HONAKER_GUARD")
      state.guardMission:AssignCohort(state.guardPlatoon)
      state.brigade:AddMission(state.guardMission)

      state.threat=ThreatAdapter.New({
        missionDemand=MissionDemand,
        registry=registry,
        policy={CreateDemand=function(md,reg,incident)
          if state.attackIncident and state.attackIncident:GetActive() and state.casDemand then return state.casDemand,false,"ACTIVE_INCIDENT_REFRESHED" end
          local demand,created,reason=CasPolicy.CreateDemand(md,reg,incident)
          if created then
            state.casDemand=demand
            if not ensureCasContext() then return demand,created,"CAS_CONTEXT_FAILED" end
            local mission,ok,why=state.casAdapter:Dispatch(demand,state.casTacticalZone)
            if ok then
              state.casMission=mission
              local prev=mission.OnAfterExecuting
              function mission:OnAfterExecuting(F,E,T)
                if prev then prev(self,F,E,T) end
                state.casExecuting=true
                msg("CAS",string.format("Jalalabad AH-64D PATROLZONE + SetEngageDetected executing for Honaker; radius=%d NM; patrol altitude=%.0f ft ASL; detected-target range=%d NM",
                  CAS_TACTICAL_RADIUS_NM,state.casAltitudeFtAsl,CAS_ENGAGE_RANGE_NM),12)
              end
            else
              failCas("CAS dispatch failed: "..tostring(why))
            end
          end
          return demand,created,reason
        end},
        anchorCoordinate=state.guardCoord, installationId=INSTALLATION_ID,
        zoneName="OMW_SECURITY_BLUE_GROUND_COP_HONAKER_STAGE3_E2E", priority=90, radiusM=SECURITY_RADIUS_M,
        blueCoalition=coalition.side.BLUE, redCoalition=coalition.side.RED, updateSeconds=5, captureThreatlevel=0, captureNunits=1,
        incidentIdFactory=function(_,seq) return "INC-STAGE3-HONAKER-"..seq end,
        onThreatEvaluated=function(_,opsZone)
          if not state.threatStarted or not state.attackIncident or not state.attackIncident:GetActive() then return end
          local added=state.attackIncident:AddParticipants(redGroups(opsZone))
          if added>0 then log(string.format("ATTACK_INCIDENT_PARTICIPANTS incidentId=%s added=%d alive=%d",
            tostring(state.attackIncident:GetActive().incidentId),added,#state.attackIncident:GetParticipants(true))) end
        end,
        onThreatStarted=function(_,opsZone,demand,created,reason,incident)
          if state.threatStarted then return end
          local active,incidentCreated,incidentReason=state.attackIncident:ReportEvidence({
            installationId=INSTALLATION_ID, evidenceType="PROXIMITY_INTRUSION", participantGroups=redGroups(opsZone),
          })
          if incidentCreated~=true or not active then fail("Honaker attack incident creation failed: "..tostring(incidentReason)) return end
          if active.incidentId~=incident.incidentId then fail("Honaker attack incident ID mismatch") return end
          state.threatStarted=true
          state.incident=incident
          msg("THREAT",string.format("COP Honaker under attack - MOOSE OPSZONE Attacked confirmed; incident %s has %d known RED participant(s)",
            tostring(active.incidentId),#state.attackIncident:GetParticipants(true)),12)
          dispatchQrf()
          msg("FIRE SUPPORT",string.format("Waiting %d s for OPSZONE evaluations to populate the attack incident before starting live coordinate fire cycle",FIRE_TARGET_ACQUIRE_DELAY_SEC),10)
          SCHEDULER:New(nil,function() if not state.failed then dispatchFire(incident) end end,{},FIRE_TARGET_ACQUIRE_DELAY_SEC)
        end,
        onThreatCleared=function()
          state.perimeterClear=true
          msg("THREAT","COP Honaker 1000-m alarm perimeter clear - MOOSE OPSZONE Defeated RED; response completion follows known attack-incident participants",14)
        end,
      })
      state.threat:Start()
      msg("READY","Honaker Stage-3 armed: infantry Guard on owner-authored PATHLINE + 5-infantry/1-M-ATV mixed ONGUARD QRF + Wright ARTY; PATROLZONE CAS created only on demand",15)
    end,{},5)
  end
  state.brigade:Start()
  return true
end

local function start()
  if OMW_GROUND_READY~=1 then fail("Ground Base not ready") return end
  need(GROUP:FindByName(GUARD_TEMPLATE),GUARD_TEMPLATE)
  need(GROUP:FindByName(QRF_TEMPLATE),QRF_TEMPLATE)
  need(PATHLINE:FindByName(GUARD_PATHLINE),GUARD_PATHLINE)
  if not context() then return end
  prepareAirwing()
  installAirObserver()
  if not preconditionWright() then return end
  if not setupFireSupport() then return end
  setupDefenceAndThreat()
end

local function finish()
  if state.failed or state.passed then return end
  closeAttackIncidentIfClear()
  closeCasIfReady()
  local casTerminal = state.casFailed or (state.casExecuting and state.casCorridor and state.casFired and state.casClosed)
  if not (state.guardPatrolStarted and state.threatStarted and state.threatStopped and state.attackIncidentClosed and state.qrfDeployed and state.qrfReturned and casTerminal
      and state.fireStarted and state.fireComplete and state.rearmComplete and state.supportReturned and state.resupply
      and state.inTransit and state.delivered and state.airCorridor and state.homeLanded and state.assetReturned) then return end
  if state.casFailed then fail("CAS subsystem failed while other Stage-3 chains remained observable: " .. tostring(state.casFailureReason)) return end

  local ctx=context()
  local w=ctx.store:GetResource(WRIGHT_NODE,AMMO_RESOURCE)
  local j=ctx.store:GetResource(JALALABAD_NODE,AMMO_RESOURCE)
  local fd=state.fireDemand and registry:Get(state.fireDemand.id) or nil
  local cd=state.casDemand and registry:Get(state.casDemand.id) or nil
  local rd=registry:Get(RESUPPLY_DEMAND_ID)
  if not w or w.quantity~=30 then fail("Wright final AMMO not 30") return end
  if not j or j.quantity~=85 then fail("Jalalabad final AMMO not 85") return end
  if not fd or fd.status~=MissionDemand.Status.SUCCESS then fail("fire-support demand not SUCCESS") return end
  if not cd or cd.status~=MissionDemand.Status.SUCCESS then fail("CAS demand lacks PATROLZONE tactical closure") return end
  if not rd or rd.status~=MissionDemand.Status.SUCCESS then fail("RESUPPLY demand not SUCCESS") return end
  if state.fireTargetCompleteCount ~= state.fireTargetCount or state.fireTargetCount < 1 then fail("not all Wright coordinate fire missions completed") return end
  if type(state.physicalAmmoBefore)~="number" or type(state.physicalAmmoAfter)~="number" or state.physicalAmmoAfter>=state.physicalAmmoBefore then fail("Wright L118 did not consume physical ammo") return end

  state.passed=true
  stopFinishScheduler()
  msg("PASS",string.format("Honaker full response complete: access-zone Guard/QRF materialization + incident-participant closure + immediate PATROLZONE CAS release onto WEST/R500 recovery + mixed QRF recovery + %d live Wright fire missions + M1083 rearm + semantic dedupe + CH-47 SLG-zone pickup-first R500 Air-AMMO + Wright 30/30",state.fireTargetCount),30)
  log("PASS WrightAmmo=30 JalalabadAmmo=85 fireDemand="..fd.id.." casDemand="..cd.id.." resupplyDemand="..rd.id
    .." perimeterClear="..tostring(state.perimeterClear).." threatStopped="..tostring(state.threatStopped)
    .." tacticalRedCount="..tostring(state.tacticalRedCount).." qrfEngaged="..tostring(state.qrfEngaged).." qrfReturned="..tostring(state.qrfReturned)
    .." guardPathline="..GUARD_PATHLINE.." qrfTemplate="..QRF_TEMPLATE
    .." casMode=PATROLZONE_ENGAGE casRadiusNm="..tostring(CAS_TACTICAL_RADIUS_NM)
    .." casAltitudeFtAsl="..tostring(state.casAltitudeFtAsl).." casCorridor="..routeLabel(CAS_PATHLINES)
    .." airAmmoCorridor="..routeLabel(AIR_AMMO_PATHLINES))
end

SCHEDULER:New(nil,start,{},5)
state.finishScheduler=SCHEDULER:New(nil,finish,{},10,10)
