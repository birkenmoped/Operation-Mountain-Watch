-- Operation Mountain Watch - Stage 3 reconciled full-response integration acceptance.
-- Test-ID: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2
--
-- The local Honaker alarm / Guard / QRF chain is the accepted production FSSR Base.
-- This acceptance keeps deterministic Wright/Jalalabad providers only as test fixtures
-- behind the generic C2 support-demand boundary.

local TEST_ID="STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2"
local TAG="[OMW]["..TEST_ID.."]"
local SITE_ID="COP_HONAKER"
local RED_FIXTURE="BadGuys_A3_HONAKER"
local HONAKER_NODE="GROUND_NODE_HONAKER"
local WRIGHT_NODE="GROUND_NODE_WRIGHT"
local JALALABAD_NODE="GROUND_NODE_JALALABAD"
local AMMO_RESOURCE="GROUND_AMMO_PACKAGE"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"
local WRIGHT_WAREHOUSE="WH_BLUE_GND_WRIGHT"
local WRIGHT_BATTERY="TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2"
local M1083_TEMPLATE="TPL_BLUE_GND_SUP_M1083"
local WRIGHT_RESUPPLY_ZONE="ZON_BLUE_GND_WRIGHT_RESUPPLY"
local PICKUP_ZONE="ZON_BLUE_LOG_SLG_JALALABAD_01"
local DROP_ZONE="OMW_BLUE_LZ_WRIGHT_01"
local FLIGHTPATH_BASE="OMW_FlightPath"
local WEST_PATHLINE="OMW_FlightPath_WEST"
local JUNCTION_MAX_DISTANCE_M=1000
local C2_FIRE_OBSERVATION_RADIUS_NM=5
local FIRE_SHELLS=4
local ARTY_WAIT_FOR_SHOT_SEC=300
local CAS_TACTICAL_RADIUS_NM=5
local CAS_ENGAGE_RANGE_NM=5
local CAS_COMBAT_HEIGHT_FT_AGL=2500
local CAS_SPEED_KTS=125
local CAS_NO_CONTACT_STABLE_SEC=30
local CH47_TRANSIT_SPEED_KTS=125
local CH47_LEAD_TURN_DISTANCE_M=250
local PRIMARY_ALTITUDE_FT_AGL=500
local WEST_ALTITUDE_FT_AGL=2500
local STARTUP_NO_GUARD_WINDOW_SEC=20
local MIN_FIXTURE_MOVE_M=25
local TEST_TIMEOUT_SEC=1800
local PRECONDITION_TX="STAGE3-A2-WRIGHT-AMMO-PRECONDITION"
local REARM_TX="STAGE3-A2-WRIGHT-LOCAL-REARM"
local RESUPPLY_DEMAND_ID="RESUPPLY-STAGE3-A2-WRIGHT-AMMO-AIR-001"
local TRANSFER_ID="TRANSFER-STAGE3-A2-JALALABAD-WRIGHT-AMMO-AIR-001"
local CARGO_ID="CARGO-STAGE3-A2-JALALABAD-WRIGHT-AMMO-AIR-001"
local CARRIER_ID="AIR-RESUPPLY-STAGE3-A2-JALALABAD-WRIGHT-CH47-001"
local SOURCE_STORAGE_NAME="OMW_STAGE3_A2_OPSTRANSPORT_SOURCE_STORAGE_001"
local DEST_STORAGE_NAME="OMW_STAGE3_A2_OPSTRANSPORT_WRIGHT_STORAGE_001"
local CARRIER_RECRUIT_RETRY_SEC=5
local CARRIER_RECRUIT_MAX_ATTEMPTS=6
local PHYSICAL_CARGO_TYPE=ENUMS.Storage.weapons.bombs.Mk_82
local PHYSICAL_CARGO_AMOUNT=4
local PHYSICAL_CARGO_ITEM_WEIGHT_KG=230
local PHYSICAL_CARGO_TOTAL_WEIGHT_KG=PHYSICAL_CARGO_AMOUNT*PHYSICAL_CARGO_ITEM_WEIGHT_KG

local MissionDemand=OMW_STAGE3_MISSION_DEMAND
local CasPolicy=OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY
local FirePolicy=OMW_STAGE3_FIRE_SUPPORT_DEMAND_POLICY
local CasAdapter=OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER
local CasPatrolClosure=OMW_STAGE3_FOB_ATTACK_CAS_PATROL_CLOSURE
local FireAdapter=OMW_STAGE3_FUNCTIONAL_ARTY_DISPATCH_ADAPTER
local ResourceDemandPolicy=OMW_STAGE3_RESOURCE_DEMAND_POLICY
local ResourceDemandCoordinator=OMW_STAGE3_RESOURCE_DEMAND_COORDINATOR
local GroundAmmoRearmAdapter=OMW_STAGE3_GROUND_AMMO_REARM_ADAPTER
local FixedFireSupportAmmoSupport=OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_SUPPORT
local FixedFireSupportAmmoRearmService=OMW_STAGE3_FIXED_FIRE_SUPPORT_AMMO_REARM_SERVICE
local GroundSupportMaterializer=OMW_STAGE3_GROUND_SUPPORT_MATERIALIZER
local HelicopterCorridor=OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local CasTacticalCorridor=OMW_STAGE3_HELICOPTER_CAS_TACTICAL_CORRIDOR
local FlightPathNameContract=OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT
local TransportCorridor=OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER

local registry=MissionDemand.New()
local state={
  failed=false,passed=false,startedAt=nil,ctx=nil,
  package=nil,runtime=nil,base=nil,site=nil,brigade=nil,perimeterState=nil,
  guardArmy=nil,guardGroup=nil,guardReturned=false,qrfArmy=nil,qrfGroup=nil,qrfEngaged=false,qrfReturned=false,
  preAlarmNoGuard=false,fixtureActivated=false,fixtureStart=nil,fixtureMove=0,
  sourceIncident=nil,baseIncidentId=nil,incidentClosed=false,honakerNoKnownAttackers=false,
  guardDemand=nil,qrfDemand=nil,artyBaseDemand=nil,casBaseDemand=nil,
  c2FireObservationZone=nil,c2FireObservationOpsZone=nil,
  airwing=nil,ah64d=nil,ch47=nil,carrierUnitType=nil,flightPathName=nil,flightPath=nil,
  casAdapter=nil,casDemand=nil,casMission=nil,casFlight=nil,casExecuting=false,casCorridor=false,
  casFired=false,casEngaged=false,casTacticalZone=nil,casAltitudeFtAsl=nil,casResolved=nil,casGeometry=nil,
  casSupportRequirementActive=false,casClosed=false,casOnStation=false,casDetectedEligibleCount=nil,casNoContactReported=false,
  casNoContactSince=nil,casReleaseRequested=false,casReleaseReason=nil,casRecoveryRequested=false,
  casHomeLanded=false,casAssetReturned=false,casFailed=false,casFailureReason=nil,casShotObserver=nil,
  battery=nil,arty=nil,fireAdapter=nil,fireDemand=nil,fireDemands={},fireStarted=false,fireComplete=false,
  fireCycleNumber=0,fireCycleActive=false,fireTargetCount=0,fireTargetCompleteCount=0,fireScheduledSourceGroups={},
  fireActiveTargetName=nil,firePhysicalShotsByTarget={},firePhysicalShotsTotal=0,
  physicalAmmoBefore=nil,physicalAmmoAfter=nil,physicalAmmoBeforeByTarget={},physicalAmmoAfterByTarget={},
  rearmService=nil,rearmComplete=false,supportReturned=false,resupply=nil,pickup=nil,drop=nil,
  sourceStatic=nil,destStatic=nil,sourceStorage=nil,destStorage=nil,cargoTransport=nil,cargoAsset=nil,cargoFlight=nil,
  cargoResolved=nil,cargoRecruitAttempts=0,cargoRecruitPending=false,loading=false,inTransit=false,delivered=false,
  airCorridor=false,cargoReturnInstalled=false,homeLanded=false,assetReturned=false,finishScheduler=nil,
}

local function log(text) env.info(TAG.." "..tostring(text),false) end
local function msg(topic,text,seconds)
  local line="[STAGE 3 A2]["..topic.."] "..text
  log(line); MESSAGE:New(line,seconds or 8):ToAll()
end
local function fail(reason)
  if state.failed or state.passed then return end
  state.failed=true; msg("FAIL",tostring(reason).."; independent physical lifecycle observation remains visible",30)
end
local function failCas(reason)
  if state.casFailed or state.passed then return end
  state.casFailed=true; state.casFailureReason=tostring(reason); msg("CAS FAIL",state.casFailureReason,20)
end
local function need(value,label) if not value then fail("missing "..label) end return value end
local function context()
  if state.ctx then return state.ctx end
  if type(OMW)~="table" or type(OMW.Ground)~="table" or type(OMW.Ground.Base)~="table" then fail("OMW Ground Base unavailable"); return nil end
  state.ctx=OMW.Ground.Base.GetContext(); return state.ctx
end
local function stockRow(nodeId,resourceId)
  for _,row in ipairs(OMW.Ground.Base.GetInitialStock().Rows or {}) do
    if row.nodeId==nodeId and row.resourceId==resourceId then return row end
  end
  return nil
end
local function primaryPathlineName() return state.flightPathName or FLIGHTPATH_BASE end
local function casPathlineNames() return {primaryPathlineName(),WEST_PATHLINE} end
local function routeLabel(names) return table.concat(names," -> ") end

local function sourceCoordinator()
  if not state.runtime or not state.site then return nil end
  local ir=state.runtime.installationIncidentRuntime
  return ir and ir:GetCoordinator(state.site.installationId) or nil
end
local function activeSourceIncident()
  local c=sourceCoordinator(); return c and c:GetActive() or nil
end
local function incidentGroups()
  local result={}
  local c=sourceCoordinator()
  if not c then return result end
  for _,group in ipairs(c:GetParticipants(true) or {}) do
    if group and group:IsAlive()==true and group:GetCoalition()==coalition.side.RED then result[#result+1]=group end
  end
  table.sort(result,function(a,b) return state.brigade:GetCoordinate():Get2DDistance(a:GetCoordinate())<state.brigade:GetCoordinate():Get2DDistance(b:GetCoordinate()) end)
  return result
end
local function c2FireObservationGroups()
  local result={}
  if not state.c2FireObservationOpsZone then return result end
  local set=state.c2FireObservationOpsZone:GetScannedGroupSet()
  local raw=set and set:GetSet() or {}
  for _,group in pairs(raw) do
    if group and group:IsAlive()==true and group:GetCoalition()==coalition.side.RED then result[#result+1]=group end
  end
  table.sort(result,function(a,b) return state.brigade:GetCoordinate():Get2DDistance(a:GetCoordinate())<state.brigade:GetCoordinate():Get2DDistance(b:GetCoordinate()) end)
  return result
end

local function resolveBaseDemands()
  local active=activeSourceIncident()
  if not active or not state.base then return end
  state.sourceIncident=active
  state.baseIncidentId=state.package.IdContract.Incident(SITE_ID,active.incidentId)
  local incident=state.base:GetIncident(state.baseIncidentId)
  if not incident then return end
  for _,id in ipairs(incident.demandIds or {}) do
    local demand=state.base:GetDemand(id)
    if demand then
      if demand.supportType=="GUARD" then state.guardDemand=demand end
      if demand.supportType=="QRF" then state.qrfDemand=demand end
      if demand.supportType=="ARTY" then state.artyBaseDemand=demand end
      if demand.supportType=="CAS" then state.casBaseDemand=demand end
    end
  end
end
