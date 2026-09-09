-- Operation Mountain Watch - Stage 3 full-response integration acceptance.
-- Test-ID: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
--
-- RED attack -> MOOSE OPSZONE threat qualification -> Honaker attack incident
-- -> owner-authored Guard PATHLINE patrol + one-group mixed QRF + Jalalabad rotary CAS
-- -> Wright Functional ARTY live coordinate fire -> local M1083 rearm -> CampaignState
-- AMMO reorder -> exactly one strategic RESUPPLY -> Jalalabad CH-47 MOOSE OPSTRANSPORT.

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
local FLIGHTPATH_BASE = "OMW_FlightPath"
local WEST_PATHLINE = "OMW_FlightPath_WEST"
local JUNCTION_MAX_DISTANCE_M = 1000
local SECURITY_RADIUS_M = 1000
local GUARD_PATROL_SPEED_KMH = 5
local QRF_PERSONNEL = 5
local PERSONNEL_FLOOR = 80
local QRF_TACTICAL_RADIUS_NM = 5
local QRF_ENGAGE_RANGE_NM = 5
local C2_FIRE_OBSERVATION_RADIUS_NM = 5
local FIRE_SHELLS = 4
local FIRE_TARGET_ACQUIRE_DELAY_SEC = 15
local ARTY_WAIT_FOR_SHOT_SEC = 300
local CAS_TACTICAL_RADIUS_NM = 5
local CAS_ENGAGE_RANGE_NM = 5
local CAS_COMBAT_HEIGHT_FT_AGL = 2500
local CAS_SPEED_KTS = 125
local CAS_NO_CONTACT_STABLE_SEC = 30
local CH47_TRANSIT_SPEED_KTS = 125
local CH47_LEAD_TURN_DISTANCE_M = 250
local PRIMARY_ALTITUDE_FT_AGL = 500
local WEST_ALTITUDE_FT_AGL = 2500
local PRECONDITION_TX = "STAGE3-E2E-WRIGHT-AMMO-PRECONDITION"
local REARM_TX = "STAGE3-E2E-WRIGHT-LOCAL-REARM"
local RESUPPLY_DEMAND_ID = "RESUPPLY-STAGE3-E2E-WRIGHT-AMMO-AIR-001"
local TRANSFER_ID = "TRANSFER-STAGE3-E2E-JALALABAD-WRIGHT-AMMO-AIR-001"
local CARGO_ID = "CARGO-STAGE3-E2E-JALALABAD-WRIGHT-AMMO-AIR-001"
local CARRIER_ID = "AIR-RESUPPLY-STAGE3-E2E-JALALABAD-WRIGHT-CH47-001"
local SOURCE_STORAGE_NAME = "OMW_STAGE3_E2E_OPSTRANSPORT_SOURCE_STORAGE_001"
local DEST_STORAGE_NAME = "OMW_STAGE3_E2E_OPSTRANSPORT_WRIGHT_STORAGE_001"
local CARRIER_RECRUIT_RETRY_SEC = 5
local CARRIER_RECRUIT_MAX_ATTEMPTS = 6

-- This MOOSE STORAGE fixture is physical execution evidence only. CampaignState remains
-- authoritative for the strategic 15 x GROUND_AMMO_PACKAGE transfer.
local PHYSICAL_CARGO_TYPE = ENUMS.Storage.weapons.bombs.Mk_82
local PHYSICAL_CARGO_AMOUNT = 4
local PHYSICAL_CARGO_ITEM_WEIGHT_KG = 230
local PHYSICAL_CARGO_TOTAL_WEIGHT_KG = PHYSICAL_CARGO_AMOUNT * PHYSICAL_CARGO_ITEM_WEIGHT_KG

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
local FlightPathNameContract = OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT
local TransportCorridor = OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER

local registry = MissionDemand.New()
local state = {
  failed=false, passed=false, ctx=nil, airwing=nil, ah64d=nil, ch47=nil, carrierUnitType=nil,
  flightPathName=nil, flightPath=nil, flightPathOffset=nil,
  brigade=nil, guardCoord=nil, guardPathline=nil, guardPlatoon=nil, guardMission=nil, guardArmy=nil, guardGroup=nil, guardPatrolStarted=false,
  qrfPlatoon=nil, qrfEntries={}, qrfDeployed=false, qrfEngaged=false, qrfTacticalZone=nil,
  qrfRecoveryRequested=false, qrfReturned=false,
  c2FireObservationZone=nil, c2FireObservationOpsZone=nil, c2FireObservationStarted=false,
  threat=nil, threatStarted=false, threatStopped=false, perimeterClear=false, incident=nil, attackIncident=nil, attackIncidentClosed=false,
  honakerNoKnownAttackers=false,
  casAdapter=nil, casDemand=nil, casMission=nil, casFlight=nil, casExecuting=false, casCorridor=false, casFired=false, casEngaged=false,
  casShotObserver=nil, casTacticalZone=nil, casAltitudeFtAsl=nil, casResolved=nil, casLifecycle=nil, casClosed=false,
  casSupportRequirementActive=false, casOnStation=false, casOnStationAt=nil, casDetectedEligibleCount=nil, casDetectedEligibleNames={},
  casContactReported=false, casNoContactReported=false, casNoContactSince=nil, casLastContactAt=nil,
  casReleaseRequested=false, casReleaseReason=nil, casRecoveryRequested=false, casHomeLanded=false, casAssetReturned=false,
  casFailed=false, casFailureReason=nil,
  battery=nil, arty=nil, fireAdapter=nil, fireDemand=nil, fireStarted=false, fireComplete=false,
  fireTargetCount=0, fireTargetCompleteCount=0, fireLastSourceGroupName=nil,
  physicalAmmoBefore=nil, physicalAmmoAfter=nil, physicalAmmoBeforeByTarget={}, physicalAmmoAfterByTarget={},
  rearmService=nil, rearmComplete=false, supportReturned=false,
  resupply=nil, pickup=nil, drop=nil,
  sourceStatic=nil, destStatic=nil, sourceStorage=nil, destStorage=nil,
  cargoTransport=nil, cargoAsset=nil, cargoFlight=nil, cargoResolved=nil, cargoBinding=nil,
  cargoRecruitAttempts=0, cargoRecruitPending=false,
  loading=false, inTransit=false, delivered=false, airCorridor=false, cargoReturnInstalled=false, homeLanded=false, assetReturned=false,
  finishScheduler=nil,
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
local function c2FireObservationGroups()
  if not state.c2FireObservationOpsZone then return {} end
  return redGroups(state.c2FireObservationOpsZone)
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
local function primaryPathlineName() return state.flightPathName or FLIGHTPATH_BASE end
local function casPathlineNames() return { primaryPathlineName(), WEST_PATHLINE } end
local function routeLabel(pathlineNames) return table.concat(pathlineNames, " -> ") end

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
    if unit and unit:IsAlive() and unit:GetTypeName()~=QRF_VEHICLE_TYPE then survivors=survivors+1 end
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
    msg("QRF","Honaker local incident complete; mixed QRF mission cancelled and MOOSE ReturnToLegion recovery requested",12)
  end
  return requested
end

local function getCasDetectedEligibleGroups()
  local result={}
  if not state.casFlight or not state.casTacticalZone then return result,0 end
  local detected=state.casFlight:GetDetectedGroups()
  local set=(detected and type(detected.GetSet)=="function") and detected:GetSet() or {}
  local detectedTotal=0
  local flightCoord=state.casFlight:GetCoordinate()
  if not flightCoord then return result,0 end

  for _,group in pairs(set) do
    detectedTotal=detectedTotal+1
    if group and group:IsAlive() and group:GetCoalition()==coalition.side.RED then
      local coordinate=group:GetCoordinate()
      local inZone=coordinate and state.casTacticalZone:IsCoordinateInZone(coordinate)
      local inRange=coordinate and flightCoord:Get3DDistance(coordinate)<=UTILS.NMToMeters(CAS_ENGAGE_RANGE_NM)
      local rightType=type(group.HasAttribute)=="function" and group:HasAttribute("Ground Units",false)
      if inZone and inRange and rightType then result[#result+1]=group end
    end
  end

  table.sort(result,function(a,b) return a:GetName()<b:GetName() end)
  return result,detectedTotal
end

local function releaseCasBySupportedElement(reason)
  if state.casClosed or state.casFailed or not state.casDemand then return false end
  if not state.casSupportRequirementActive then return false end
  if not state.honakerNoKnownAttackers then return false end
  if not state.casOnStation or not state.casNoContactReported then return false end
  if not state.casNoContactSince or timer.getAbsTime() - state.casNoContactSince < CAS_NO_CONTACT_STABLE_SEC then return false end

  state.casRecoveryRequested=true
  local _,closed,why=CasPatrolClosure.Complete({
    adapter=state.casAdapter,
    registry=registry,
    missionDemand=MissionDemand,
    demandId=state.casDemand.id,
    tacticalComplete=true,
    executionEvidenceConfirmed=state.casFired,
    reason=reason,
    releaseSource=INSTALLATION_ID,
    executor="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
  })
  if closed~=true then failCas("CAS supported-element release failed: "..tostring(why)); return false end

  state.casSupportRequirementActive=false
  state.casReleaseRequested=true
  state.casReleaseReason=reason
  state.casClosed=true
  requestQrfRecovery()
  msg("CAS","Honaker/control explicitly released CAS after stable own no-contact; MOOSE PATROLZONE cancellation proceeds on the installed reverse corridor",15)
  return true
end

local function updateCasSupportState()
  if state.failed or state.casFailed or state.casClosed or not state.casExecuting or not state.casFlight or not state.casTacticalZone then return end
  local flightCoord=state.casFlight:GetCoordinate()
  if not flightCoord then return end
  local now=timer.getAbsTime()
  local physicallyInside=state.casTacticalZone:IsCoordinateInZone(flightCoord)
  if physicallyInside and not state.casOnStation then
    state.casOnStation=true
    state.casOnStationAt=now
    msg("CAS","AH-64D reports ON STATION; CAS own MOOSE/DCS detection picture now participates in support-status reconciliation",12)
  end
  if not state.casOnStation then return end

  local eligible,detectedTotal=getCasDetectedEligibleGroups()
  local names={}
  for _,group in ipairs(eligible) do names[#names+1]=group:GetName() end
  local count=#eligible
  if count~=state.casDetectedEligibleCount then
    state.casDetectedEligibleCount=count
    state.casDetectedEligibleNames=names
    if count>0 then
      state.casContactReported=true
      state.casNoContactReported=false
      state.casNoContactSince=nil
      state.casLastContactAt=now
      log(string.format("CAS_SENSOR_REPORT onStation=true detectedTotal=%d eligible=%d names=%s source=FLIGHTGROUP_GetDetectedGroups",detectedTotal,count,table.concat(names,",")))
      msg("CAS",string.format("AH-64D reports %d relevant detected RED ground group(s) in current task envelope; CAS requirement remains ACTIVE",count),10)
    else
      state.casNoContactSince=now
      log(string.format("CAS_SENSOR_REPORT onStation=true detectedTotal=%d eligible=0 names= source=FLIGHTGROUP_GetDetectedGroups qualification=PENDING_%ds",detectedTotal,CAS_NO_CONTACT_STABLE_SEC))
      msg("CAS","AH-64D reports NO CONTACT in current task envelope; qualifying this own sensor picture before any release",10)
    end
  end

  if count==0 and state.casNoContactSince and not state.casNoContactReported and now-state.casNoContactSince>=CAS_NO_CONTACT_STABLE_SEC then
    state.casNoContactReported=true
    log(string.format("CAS_NO_CONTACT_REPORTED onStation=true stableSeconds=%d source=FLIGHTGROUP_GetDetectedGroups",CAS_NO_CONTACT_STABLE_SEC))
    msg("CAS","AH-64D own no-contact report is stable; supported element may now release CAS if its local requirement is also clear",10)
  end

  if state.honakerNoKnownAttackers and count==0 and state.casNoContactReported then
    releaseCasBySupportedElement("SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT")
  end
end
local function closeAttackIncidentIfClear()
  if state.attackIncidentClosed then
    updateCasSupportState()
    return true
  end
  if not state.attackIncident or not state.attackIncident:GetActive() then return false end
  if state.attackIncident:HasAliveParticipants() then return false end

  local _,closed,reason=state.attackIncident:Close("HONAKER_NO_KNOWN_ATTACKERS")
  if closed~=true then fail("Honaker local incident closure failed: "..tostring(reason)); return false end
  state.attackIncidentClosed=true
  state.honakerNoKnownAttackers=true
  msg("HONAKER","No known attack participants remain. This local status report does NOT itself release CAS.",14)
  if state.threat and state.threat.started and not state.threatStopped then
    state.threat:Stop()
    state.threatStopped=true
    msg("HONAKER","Local 1000-m OPSZONE alarm scan stopped after local incident closure; CAS lifecycle remains independent",10)
  end
  updateCasSupportState()
  return true
end

local function logCorridorProfiles(kind, installed)
  if not installed or not installed.waypointProfiles then return end
  for direction, profiles in pairs(installed.waypointProfiles) do
    for index, profile in ipairs(profiles) do
      log(string.format("%s_ROUTE_PROFILE direction=%s index=%d uid=%s pathline=%s altitudeFtAgl=%s speedKts=%s altType=%s",
        tostring(kind), tostring(direction), index, tostring(profile.uid), tostring(profile.pathlineName), tostring(profile.altitudeFtAgl), tostring(profile.speedKts), tostring(profile.altType)))
    end
  end
  for uid, transition in pairs(installed.profileTransitions or {}) do
    log(string.format("%s_ROUTE_TRANSITION uid=%s pathline=%s altitudeFtAgl=%s keep=%s formation=%s",
      tostring(kind), tostring(uid), tostring(transition.pathlineName), tostring(transition.altitudeFtAgl), tostring(transition.keepAltitude == true), tostring(transition.formation)))
  end
end

local function resolveConfiguredFlightPath()
  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then
    fail("MOOSE DATABASE.PATHLINES registry unavailable for configured FlightPath discovery")
    return false
  end
  local selected,reason=FlightPathNameContract.SelectFromRegistry(FLIGHTPATH_BASE,_DATABASE.PATHLINES)
  if not selected then fail(reason); return false end
  if type(selected.pathline)~="table" then fail("configured FlightPath registry entry is not a PATHLINE: "..tostring(selected.name)); return false end
  state.flightPathName=selected.name
  state.flightPath=selected.pathline
  state.flightPathOffset=selected.offset
  msg("ROUTE",string.format("configured FlightPath selected: %s offset=%s %dm",selected.name,selected.offset.side,selected.offset.meters),12)
  return true
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
  local ch47Template=GROUP:FindByName("TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP")
  if not ch47Template then log("AIRWING_PRECHECK Jalalabad CH47 template missing") return false end
  state.carrierUnitType=ch47Template:GetTypeName()
  if not state.flightPath or not PATHLINE:FindByName(WEST_PATHLINE) then
    log("AIRWING_PRECHECK required configured FlightPath/WEST PATHLINE missing")
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

  local pathlineNames=casPathlineNames()
  state.casResolved = HelicopterCorridor.ResolveSequence({
    pathlineNames=pathlineNames,
    pathlines={state.flightPath},
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
    routeLabel(pathlineNames), tostring(primaryOffset and primaryOffset.signedRightM), tostring(westOffset and westOffset.signedRightM)))

  state.casAdapter = CasAdapter.New({
    missionDemand=MissionDemand, registry=registry, airwing=state.airwing,
    assigneeId="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
    missionMode=CasAdapter.MissionMode.PATROLZONE_ENGAGE,
    casAltitudeFt=state.casAltitudeFtAsl, casSpeedKts=CAS_SPEED_KTS,
    engageDetectedRangeNm=CAS_ENGAGE_RANGE_NM, engageDetectedTargetTypes={"Ground Units"}, squadrons={state.ah64d},
    requireExecutionEvidence=false,
    missionConfigurator=function(mission)
      mission:SetName("OMW_STAGE3_HONAKER_CAS_PATROLZONE_ENGAGE")
      state.casLifecycle = MissionOwnedCorridor.ConfigureMission(mission, state.casResolved, {
        speedKts=CAS_SPEED_KTS, defaultAltitudeFtAgl=CAS_COMBAT_HEIGHT_FT_AGL,
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
    if confirmed ~= true and reason ~= "EVIDENCE_ALREADY_CONFIRMED" then failCas("CAS shot evidence could not be correlated: " .. tostring(reason)); return end
    msg("CAS", "AH-64D weapon employment confirmed: " .. tostring(weaponType) .. "; weapon use does not itself terminate CAS", 12)
  end
end

local function bindCasMissionOwnedCorridor(flight, mission)
  local installed, ok, reason = MissionOwnedCorridor.Bind(flight, mission, state.casResolved, {
    defaultAltitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL,
    speedKts=CAS_SPEED_KTS,
    onInstalled=function(result)
      state.casCorridor = true
      logCorridorProfiles("CAS", result)
      msg("CAS", "One-shot MOOSE waypoint/task chain installed: common-route entry -> " .. primaryPathlineName() .. " -> WEST -> CAS -> WEST reverse -> " .. primaryPathlineName() .. " reverse -> Jalalabad egress", 12)
    end,
    onFailed=function(why) failCas("CAS mission-owned corridor failed: " .. tostring(why)) end,
  })
  if ok then state.casCorridor = true; logCorridorProfiles("CAS", installed) end
  if not ok and reason ~= "MISSION_ROUTE_UIDS_NOT_READY" then failCas("CAS mission-owned corridor failed: " .. tostring(reason)) end
end

local function markAirAmmoInTransit()
  if state.inTransit then return true end
  if not state.loading then return false end
  context().store:MarkInTransit(TRANSFER_ID)
  registry:SetReservationState(RESUPPLY_DEMAND_ID, "IN_TRANSIT")
  local demand=registry:Get(RESUPPLY_DEMAND_ID)
  if demand and demand.status==MissionDemand.Status.AI_ASSIGNED then registry:Activate(RESUPPLY_DEMAND_ID) end
  state.inTransit=true
  msg("LOGISTICS", "MOOSE OPSTRANSPORT loading complete; Jalalabad -> Wright IN TRANSIT via " .. primaryPathlineName(), 10)
  return true
end

local function installAirObserver()
  if not state.airwing or state.airwing.__omwStage3E2EObserver then return end
  state.airwing.__omwStage3E2EObserver = true

  local previousFlight = state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
    if previousFlight then previousFlight(self, From, Event, To, FlightGroup, Mission) end
    if Mission ~= state.casMission then return end
    state.casFlight = FlightGroup
    if type(FlightGroup.SetDefaultSpeed)=="function" then FlightGroup:SetDefaultSpeed(CAS_SPEED_KTS) end
    installCasShotObserver()

    local previousEngage=FlightGroup.OnAfterEngageTarget
    function FlightGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
      if previousEngage then previousEngage(self,F,E,T,Target,Speed,Formation) end
      state.casEngaged=true
      state.casNoContactReported=false
      state.casNoContactSince=nil
      state.casLastContactAt=timer.getAbsTime()
      local targetName=Target and type(Target.GetName)=="function" and Target:GetName() or "unknown"
      log("CAS_ENGAGE_EVENT target="..tostring(targetName).." source=MOOSE_FLIGHTGROUP_OnAfterEngageTarget")
      msg("CAS","MOOSE FLIGHTGROUP engaging detected target "..tostring(targetName),10)
    end

    local previousLanded=FlightGroup.OnAfterLanded
    function FlightGroup:OnAfterLanded(F,E,T,Airbase)
      if previousLanded then previousLanded(self,F,E,T,Airbase) end
      if state.casRecoveryRequested and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then
        state.casHomeLanded=true
        msg("CAS","AH-64D landed at Jalalabad after controlled PATROLZONE recovery corridor",10)
      end
    end

    msg("CAS", string.format("Jalalabad AH-64D assigned to PATROLZONE + SetEngageDetected; explicit transit speed=%d kt; CAS own detection telemetry armed",CAS_SPEED_KTS), 12)
    bindCasMissionOwnedCorridor(FlightGroup, Mission)
  end

  local previousSpawned=state.airwing.OnAfterAssetSpawned
  function state.airwing:OnAfterAssetSpawned(From, Event, To, Group, Asset, Request)
    if previousSpawned then previousSpawned(self, From, Event, To, Group, Asset, Request) end
    if not state.cargoAsset or Asset~=state.cargoAsset then return end
    local flight=Asset.flightgroup
    if not flight then fail("CH-47 OPSTRANSPORT FLIGHTGROUP unavailable after AIRWING spawn") return end
    state.cargoFlight=flight

    local binding,ok,reason=TransportCorridor.Bind(flight,state.cargoTransport,state.cargoResolved,PRIMARY_ALTITUDE_FT_AGL,{
      speedKts=CH47_TRANSIT_SPEED_KTS,
      leadTurnDistanceM=CH47_LEAD_TURN_DISTANCE_M,
      onOutboundInstalled=function(installed)
        state.airCorridor=true
        markAirAmmoInTransit()
        msg("LOGISTICS",string.format("CH-47 %s outbound installed: %d waypoints from %d source points; smoothedCorners=%d speed=%d kt leadTurn=%d m",
          primaryPathlineName(),installed.outboundWaypointCount,installed.outboundSourcePointCount,installed.outboundSmoothedCorners,CH47_TRANSIT_SPEED_KTS,CH47_LEAD_TURN_DISTANCE_M),12)
      end,
      onReturnInstalled=function(installed)
        state.cargoReturnInstalled=true
        msg("LOGISTICS",string.format("CH-47 %s reverse installed after OPSTRANSPORT Delivered: %d waypoints from %d source points; smoothedCorners=%d speed=%d kt leadTurn=%d m",
          primaryPathlineName(),installed.returnWaypointCount,installed.returnSourcePointCount,installed.returnSmoothedCorners,CH47_TRANSIT_SPEED_KTS,CH47_LEAD_TURN_DISTANCE_M),12)
      end,
      onError=function(adapterReason) fail("CH-47 OPSTRANSPORT "..primaryPathlineName().." adapter failed: "..tostring(adapterReason)) end,
    })
    if not ok then fail("CH-47 OPSTRANSPORT corridor bind failed: "..tostring(reason)) return end
    state.cargoBinding=binding

    local oldLanded = flight.OnAfterLanded
    function flight:OnAfterLanded(F,E,T,Airbase)
      if oldLanded then oldLanded(self,F,E,T,Airbase) end
      if state.delivered and Airbase and Airbase:GetName() == state.airwing:GetAirbaseName() then
        state.homeLanded = true
        msg("LOGISTICS", "CH-47 landed back at Jalalabad via " .. primaryPathlineName(), 9)
      end
    end
  end

  local oldReturn = state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(From, Event, To, Cohort, Asset)
    if oldReturn then oldReturn(self, From, Event, To, Cohort, Asset) end
    if state.casRecoveryRequested and Asset and Asset.flightgroup==state.casFlight then
      state.casAssetReturned=true
      msg("CAS","AH-64D asset returned to Jalalabad AIRWING/LEGION stock after landing",10)
    end
    if state.cargoAsset and Asset == state.cargoAsset then
      if not state.homeLanded then fail("CH47 returned to AIRWING before home landing") return end
      state.assetReturned = true
      msg("LOGISTICS", "CH-47 recovered by Jalalabad AIRWING after OPSTRANSPORT", 8)
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

local function createAirAmmoStorageFixtures()
  state.sourceStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :AddCargoResource(STORAGE.Type.WEAPONS,PHYSICAL_CARGO_TYPE,PHYSICAL_CARGO_AMOUNT,PHYSICAL_CARGO_TOTAL_WEIGHT_KG)
    :InitCoordinate(state.pickup:GetCoordinate())
    :InitValidateAndRepositionStatic(false)
    :Spawn(0,SOURCE_STORAGE_NAME)
  state.destStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :ResetCargoResources()
    :InitCoordinate(state.drop:GetCoordinate())
    :InitValidateAndRepositionStatic(false)
    :Spawn(0,DEST_STORAGE_NAME)
  if not state.sourceStatic or not state.destStatic then return false,"storage static spawn failed" end
  state.sourceStorage=state.sourceStatic:GetStaticStorage()
  state.destStorage=state.destStatic:GetStaticStorage()
  if not state.sourceStorage or not state.destStorage then return false,"MOOSE STORAGE wrapper unavailable" end
  local sourceAmount=state.sourceStorage:GetAmount(PHYSICAL_CARGO_TYPE)
  local destAmount=state.destStorage:GetAmount(PHYSICAL_CARGO_TYPE)
  if sourceAmount~=PHYSICAL_CARGO_AMOUNT or destAmount~=0 then
    return false,string.format("storage fixture mismatch source=%s destination=%s",tostring(sourceAmount),tostring(destAmount))
  end
  return true,nil
end

local function carrierRecruitSnapshot()
  return {
    cohortState=state.ch47:GetState(), onDuty=state.ch47:IsOnDuty(),
    capability=state.ch47:GetMissionCapability(AUFTRAG.Type.OPSTRANSPORT)~=nil,
    stock=state.ch47:CountAssets(true,{AUFTRAG.Type.OPSTRANSPORT}),
    payloads=state.airwing:CountPayloadsInStock({AUFTRAG.Type.OPSTRANSPORT},state.carrierUnitType),
  }
end

local armCargoCarrier
local function scheduleCargoRecruitment()
  if state.failed or state.cargoAsset or state.cargoRecruitPending then return end
  state.cargoRecruitPending=true
  SCHEDULER:New(nil,function() state.cargoRecruitPending=false; armCargoCarrier() end,{},CARRIER_RECRUIT_RETRY_SEC)
end

armCargoCarrier=function()
  if state.failed or state.cargoAsset then return end
  state.cargoRecruitAttempts=state.cargoRecruitAttempts+1
  local snapshot=carrierRecruitSnapshot()
  log(string.format("AIR_AMMO_OPSTRANSPORT_RECRUIT attempt=%d/%d cohortState=%s onDuty=%s capability=%s stock=%s payloads=%s unitType=%s",
    state.cargoRecruitAttempts,CARRIER_RECRUIT_MAX_ATTEMPTS,tostring(snapshot.cohortState),tostring(snapshot.onDuty),tostring(snapshot.capability),tostring(snapshot.stock),tostring(snapshot.payloads),tostring(state.carrierUnitType)))
  if not snapshot.onDuty or not snapshot.capability or snapshot.stock<1 or snapshot.payloads<1 then
    if state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS then scheduleCargoRecruitment(); return end
    fail(string.format("CH-47 recruitment readiness timeout after %d attempts: cohortState=%s onDuty=%s capability=%s stock=%s payloads=%s",
      state.cargoRecruitAttempts,tostring(snapshot.cohortState),tostring(snapshot.onDuty),tostring(snapshot.capability),tostring(snapshot.stock),tostring(snapshot.payloads)))
    return
  end

  local recruited,assets,legions=LEGION.RecruitCohortAssets(
    {state.ch47},AUFTRAG.Type.OPSTRANSPORT,nil,1,1,state.drop:GetVec2(),
    nil,nil,nil,PHYSICAL_CARGO_TOTAL_WEIGHT_KG,PHYSICAL_CARGO_TOTAL_WEIGHT_KG,nil,nil,nil,nil,nil,nil)
  local assetCount=type(assets)=="table" and #assets or -1
  local legionCount=0
  local recruitedLegion=nil
  if type(legions)=="table" then for _,legion in pairs(legions) do legionCount=legionCount+1; recruitedLegion=legion end end
  local expectedLegion=recruitedLegion==state.airwing
  log(string.format("AIR_AMMO_OPSTRANSPORT_RECRUIT_RESULT attempt=%d recruited=%s assets=%d legions=%d expectedLegion=%s",
    state.cargoRecruitAttempts,tostring(recruited),assetCount,legionCount,tostring(expectedLegion)))
  if recruited and type(assets)=="table" and assetCount==1 and legionCount==1 and expectedLegion then
    state.cargoAsset=assets[1]
    state.cargoTransport:AddAsset(state.cargoAsset)
    state.airwing:TransportAssign(state.cargoTransport,legions)
    msg("LOGISTICS",string.format("MOOSE OPSTRANSPORT queued after carrier recruitment attempt %d: internal STORAGE fixture %d x %s, carrier=Jalalabad CH-47, route=%s",
      state.cargoRecruitAttempts,PHYSICAL_CARGO_AMOUNT,PHYSICAL_CARGO_TYPE,primaryPathlineName()),15)
    return
  end
  if recruited and type(assets)=="table" and assetCount>0 then LEGION.UnRecruitAssets(assets) end
  if state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS then scheduleCargoRecruitment(); return end
  fail(string.format("unable to recruit exactly one Jalalabad CH-47 for OPSTRANSPORT after %d attempts: recruited=%s assets=%d legions=%d expectedLegion=%s",
    state.cargoRecruitAttempts,tostring(recruited),assetCount,legionCount,tostring(expectedLegion)))
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
  if type(duplicate) ~= "table" or duplicate.id ~= demand.id or duplicate.dedupeKey ~= demand.dedupeKey
      or duplicateCreated ~= false or duplicateReason ~= "active_duplicate" then fail("RESUPPLY semantic dedupe failed") return end
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

  state.pickup=need(ZONE:FindByName(PICKUP_ZONE),PICKUP_ZONE)
  state.drop=need(ZONE:FindByName(DROP_ZONE),DROP_ZONE)
  if state.failed then return end
  local fixturesOk,fixturesReason=createAirAmmoStorageFixtures()
  if not fixturesOk then fail(fixturesReason); return end
  state.cargoResolved=HelicopterCorridor.Resolve({
    pathlineName=state.flightPathName, pathline=state.flightPath,
    originCoordinate=state.pickup:GetCoordinate(), destinationCoordinate=state.drop:GetCoordinate(),
    offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
  })
  if not state.cargoResolved or not state.cargoResolved.outbound or #state.cargoResolved.outbound<2 or
      not state.cargoResolved.returnRoute or #state.cargoResolved.returnRoute<2 then fail(primaryPathlineName().." corridor resolution failed"); return end

  state.cargoTransport=OPSTRANSPORT:New(nil,state.pickup,state.drop)
  state.cargoTransport:SetRequiredCarriers(1,1)
  state.cargoTransport:SetPriority(20)
  state.cargoTransport:AddCargoStorage(state.sourceStorage,state.destStorage,PHYSICAL_CARGO_TYPE,PHYSICAL_CARGO_AMOUNT,PHYSICAL_CARGO_ITEM_WEIGHT_KG)

  local oldExecuting=state.cargoTransport.OnAfterExecuting
  function state.cargoTransport:OnAfterExecuting(F,E,T)
    if oldExecuting then oldExecuting(self,F,E,T) end
    local tx=ctx.store:MarkLoading(TRANSFER_ID)
    registry:SetReservationState(RESUPPLY_DEMAND_ID,"LOADING")
    state.loading=tx and tx.status==ctx.campaignState.TransactionStatus.LOADING
    msg("LOGISTICS","MOOSE OPSTRANSPORT executing; CH-47 internal load/transport/unload lifecycle active",12)
  end
  local oldDelivered=state.cargoTransport.OnAfterDelivered
  function state.cargoTransport:OnAfterDelivered(F,E,T)
    if oldDelivered then oldDelivered(self,F,E,T) end
    local sourceAmount=state.sourceStorage:GetAmount(PHYSICAL_CARGO_TYPE)
    local destAmount=state.destStorage:GetAmount(PHYSICAL_CARGO_TYPE)
    if sourceAmount~=0 or destAmount~=PHYSICAL_CARGO_AMOUNT then
      fail(string.format("OPSTRANSPORT Delivered without expected STORAGE transfer source=%s destination=%s",tostring(sourceAmount),tostring(destAmount)))
      return
    end
    if not state.inTransit then markAirAmmoInTransit() end
    ctx.store:MarkDelivered(TRANSFER_ID)
    registry:SetReservationState(RESUPPLY_DEMAND_ID,"DELIVERED")
    registry:Succeed(RESUPPLY_DEMAND_ID,{transactionId=TRANSFER_ID,cargoId=CARGO_ID,carrierEntityId=CARRIER_ID,physicalMission="OPSTRANSPORT:STORAGE",corridor=primaryPathlineName()})
    state.delivered=true
    msg("LOGISTICS", "MOOSE STORAGE delivery confirmed at Wright; strategic stock restored to 30 / 30; awaiting configured reverse route", 12)
  end
  local oldCancel=state.cargoTransport.OnAfterCancel
  function state.cargoTransport:OnAfterCancel(F,E,T)
    if oldCancel then oldCancel(self,F,E,T) end
    if not state.delivered then fail("MOOSE OPSTRANSPORT cancelled before Wright delivery") end
  end

  registry:AssignAI(RESUPPLY_DEMAND_ID,"AI:SQUADRON:SQ_US_JBAD_CH47_HEAVYLIFT")
  armCargoCarrier()
  if not state.cargoAsset and not state.failed then msg("LOGISTICS","OPSTRANSPORT STORAGE setup active; bounded Jalalabad CH-47 recruitment retry is pending",12) end
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
  if state.casOnStation then return nil,"CAS_ON_STATION_ARTY_DECONFLICTION" end
  local targets = c2FireObservationGroups()
  if #targets == 0 then targets = incidentGroups() end
  if #targets == 0 then return nil,"NO_C2_OBSERVED_RED_GROUND_GROUP" end
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
  local target,targetReason = selectNextFireTarget()
  if not target then
    if targetReason=="CAS_ON_STATION_ARTY_DECONFLICTION" then
      msg("FIRE SUPPORT","C2 fire hold: CAS is ON STATION. No new ARTY round is queued while rotary CAS occupies the tactical area.",10)
    else
      msg("FIRE SUPPORT","No C2-observed RED ground group remains for this fire cycle; local rearm/reorder path may proceed.",10)
    end
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
      msg("FIRE SUPPORT",string.format("Fire mission %d complete: %s ammo %s -> %s; reacquiring C2-observed RED ground groups",
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
  if not target then fail("no C2-observed RED ground group available for Wright fire support") return end
  if not reportFireMission(target,1) then return end
  local p = target:GetCoordinate():GetVec3()
  local demand,created,reason = FirePolicy.CreateDemand(MissionDemand,registry,incident,{
    targetKind="DETECTED_RED_GROUND_GROUP", targetName=target:GetName(), position={x=p.x,y=p.y,z=p.z},
  })
  if created~=true then fail("fire-support demand failed: "..tostring(reason)) return end
  state.fireDemand=demand
  state.fireTargetCount=1
  state.fireLastSourceGroupName=target:GetName()
  msg("FIRE SUPPORT","Honaker requests immediate fire support; local mortar unavailable; C2-observed retarget cycle armed",12)
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

      state.c2FireObservationZone=ZONE_RADIUS:New("OMW_C2_FIRE_OBSERVATION_BLUE_GROUND_COP_HONAKER_STAGE3",state.guardCoord:GetVec2(),UTILS.NMToMeters(C2_FIRE_OBSERVATION_RADIUS_NM))
      state.c2FireObservationOpsZone=OPSZONE:New(state.c2FireObservationZone,coalition.side.BLUE)
      state.c2FireObservationOpsZone:SetObjectCategories({Object.Category.UNIT})
      state.c2FireObservationOpsZone:SetUnitCategories({Unit.Category.GROUND_UNIT})
      state.c2FireObservationOpsZone:SetCaptureThreatlevel(0)
      state.c2FireObservationOpsZone:SetCaptureNunits(1)
      state.c2FireObservationOpsZone:SetDrawZone(false)
      state.c2FireObservationOpsZone:SetMarkZone(false)
      state.c2FireObservationOpsZone.UpdateSeconds=5
      function state.c2FireObservationOpsZone:OnAfterEvaluated(From,Event,To)
        local groups=c2FireObservationGroups()
        local names={}
        for _,group in ipairs(groups) do names[#names+1]=group:GetName() end
        log(string.format("C2_FIRE_OBSERVATION source=OPSZONE radiusNm=%d observedRedGround=%d names=%s authority=QRF_ARTY_ONLY",C2_FIRE_OBSERVATION_RADIUS_NM,#groups,table.concat(names,",")))
      end
      state.c2FireObservationOpsZone:Start()
      state.c2FireObservationStarted=true
      msg("C2",string.format("MOOSE 5-NM C2 fire observation started for QRF/ARTY only; it has no CAS release or termination authority",C2_FIRE_OBSERVATION_RADIUS_NM),12)

      state.threat=ThreatAdapter.New({
        missionDemand=MissionDemand,
        registry=registry,
        policy={CreateDemand=function(md,reg,incident)
          if state.casDemand then return state.casDemand,false,"ACTIVE_CAS_SUPPORT_REQUIREMENT" end
          local demand,created,reason=CasPolicy.CreateDemand(md,reg,incident)
          if created then
            state.casDemand=demand
            if not ensureCasContext() then return demand,created,"CAS_CONTEXT_FAILED" end
            local mission,ok,why=state.casAdapter:Dispatch(demand,state.casTacticalZone)
            if ok then
              state.casMission=mission
              state.casSupportRequirementActive=true
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
          if added>0 then log(string.format("HONAKER_LOCAL_PICTURE incidentId=%s added=%d alive=%d authority=HONAKER_ONLY",
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
          msg("THREAT",string.format("COP Honaker under attack - MOOSE OPSZONE Attacked confirmed; incident %s has %d known RED participant(s); CAS requirement is independent once allocated",
            tostring(active.incidentId),#state.attackIncident:GetParticipants(true)),12)
          dispatchQrf()
          msg("FIRE SUPPORT",string.format("Waiting %d s for OPSZONE evaluations to populate the attack incident before starting live coordinate fire cycle",FIRE_TARGET_ACQUIRE_DELAY_SEC),10)
          SCHEDULER:New(nil,function() if not state.failed then dispatchFire(incident) end end,{},FIRE_TARGET_ACQUIRE_DELAY_SEC)
        end,
        onThreatCleared=function()
          state.perimeterClear=true
          msg("THREAT","COP Honaker 1000-m alarm perimeter clear - MOOSE OPSZONE Defeated RED; this local alarm transition has NO CAS release authority",14)
        end,
      })
      state.threat:Start()
      msg("READY","Honaker Stage-3 armed: infantry Guard + mixed QRF + Wright ARTY; PATROLZONE CAS is support-status owned; CH-47 internal OPSTRANSPORT uses 125-kt/250-m lead-turn profile",15)
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
  if not resolveConfiguredFlightPath() then return end
  prepareAirwing()
  installAirObserver()
  if not preconditionWright() then return end
  if not setupFireSupport() then return end
  setupDefenceAndThreat()
end

local function finish()
  if state.failed or state.passed then return end
  closeAttackIncidentIfClear()
  updateCasSupportState()
  local validCasExecution=state.casFired or state.casNoContactReported
  local casTerminal = state.casFailed or (state.casExecuting and state.casCorridor and state.casClosed and validCasExecution
    and state.casRecoveryRequested and state.casHomeLanded and state.casAssetReturned)
  if not (state.guardPatrolStarted and state.threatStarted and state.threatStopped and state.attackIncidentClosed and state.qrfDeployed and state.qrfReturned and casTerminal
      and state.fireStarted and state.fireComplete and state.rearmComplete and state.supportReturned and state.resupply
      and state.inTransit and state.delivered and state.airCorridor and state.cargoReturnInstalled and state.homeLanded and state.assetReturned) then return end
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
  if not cd or cd.status~=MissionDemand.Status.SUCCESS then fail("CAS demand lacks supported-element PATROLZONE closure") return end
  if not rd or rd.status~=MissionDemand.Status.SUCCESS then fail("RESUPPLY demand not SUCCESS") return end
  if state.fireTargetCompleteCount ~= state.fireTargetCount or state.fireTargetCount < 1 then fail("not all Wright coordinate fire missions completed") return end
  if type(state.physicalAmmoBefore)~="number" or type(state.physicalAmmoAfter)~="number" or state.physicalAmmoAfter>=state.physicalAmmoBefore then fail("Wright L118 did not consume physical ammo") return end

  state.passed=true
  stopFinishScheduler()
  msg("PASS",string.format("Honaker full response complete: Guard/QRF + supported-element CAS release + %d live Wright fire missions + M1083 rearm + CH-47 OPSTRANSPORT internal Air-AMMO via %s at %d kt with %d-m lead-turn profile + Wright 30/30",
    state.fireTargetCount,primaryPathlineName(),CH47_TRANSIT_SPEED_KTS,CH47_LEAD_TURN_DISTANCE_M),30)
  log("PASS WrightAmmo=30 JalalabadAmmo=85 fireDemand="..fd.id.." casDemand="..cd.id.." resupplyDemand="..rd.id
    .." perimeterClear="..tostring(state.perimeterClear).." threatStopped="..tostring(state.threatStopped)
    .." qrfEngaged="..tostring(state.qrfEngaged).." qrfReturned="..tostring(state.qrfReturned)
    .." guardPathline="..GUARD_PATHLINE.." qrfTemplate="..QRF_TEMPLATE
    .." casMode=PATROLZONE_ENGAGE casOnStation="..tostring(state.casOnStation).." casDetectedEligible="..tostring(state.casDetectedEligibleCount)
    .." casEngaged="..tostring(state.casEngaged).." casFired="..tostring(state.casFired).." casNoContact="..tostring(state.casNoContactReported)
    .." casReleaseReason="..tostring(state.casReleaseReason).." casCorridor="..routeLabel(casPathlineNames())
    .." airAmmoCorridor="..primaryPathlineName().." ch47SpeedKts="..tostring(CH47_TRANSIT_SPEED_KTS).." ch47LeadTurnM="..tostring(CH47_LEAD_TURN_DISTANCE_M))
end

SCHEDULER:New(nil,start,{},5)
state.finishScheduler=SCHEDULER:New(nil,finish,{},10,10)
