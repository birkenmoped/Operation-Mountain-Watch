-- Operation Mountain Watch - focused Stage 3 CAS + OPSTRANSPORT Air-AMMO resupply acceptance.
-- Test-ID: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1
--
-- Scope: existing AH-64 CAS routing/execution plus CH-47 MOOSE OPSTRANSPORT storage transfer.
-- Guard/QRF/ARTY/CampaignState strategic accounting are intentionally excluded.
-- No IncidentParticipants or KNOWN_ATTACKERS_NEUTRALIZED completion gate is used.
--
-- Acceptance instrumentation rule:
--   CAS and RESUPPLY have independent failure state. An observation/failure in one
--   subsystem must never prevent the other subsystem from executing its real MOOSE path.

local TEST_ID = "STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local FLIGHTPATH_BASE = "OMW_FlightPath"
local WEST = "OMW_FlightPath_WEST"
local HONAKER_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"
local PICKUP_ZONE = "ZON_BLUE_LOG_SLG_JALALABAD_01"
local DROP_ZONE = "OMW_BLUE_LZ_WRIGHT_01"
local AH64_TEMPLATE = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP"
local CH47_TEMPLATE = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
local SOURCE_STORAGE_NAME = "OMW_STAGE3_OPSTRANSPORT_SOURCE_STORAGE_001"
local DEST_STORAGE_NAME = "OMW_STAGE3_OPSTRANSPORT_WRIGHT_STORAGE_001"

local CAS_RADIUS_NM = 5
local CAS_SPEED_KTS = 120
local PRIMARY_ALT_FT_AGL = 500
local WEST_ALT_FT_AGL = 2500
local CAS_ALT_FT_AGL = 2500
local CAS_RELEASE_DELAY_SEC = 90
local JUNCTION_MAX_M = 1000
local CARRIER_RECRUIT_RETRY_SEC = 5
local CARRIER_RECRUIT_MAX_ATTEMPTS = 6

-- Acceptance resource token. This is deliberately a temporary MOOSE STORAGE fixture,
-- not a production OMW ammunition inventory decision.
local AMMO_TYPE = ENUMS.Storage.weapons.bombs.Mk_82
local AMMO_AMOUNT = 4
local AMMO_ITEM_WEIGHT_KG = 230
local AMMO_TOTAL_WEIGHT_KG = AMMO_AMOUNT * AMMO_ITEM_WEIGHT_KG

local FlightPathNameContract = OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT
local Corridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local TransportCorridor = OMW_STAGE3_OPSTRANSPORT_CORRIDOR_ADAPTER

local state = {
  fatalFailed=false,
  casFailed=false,
  cargoFailed=false,
  passed=false,
  airwing=nil, ah64d=nil, ch47=nil, carrierUnitType=nil,
  flightPathName=nil, flightPath=nil, flightPathOffset=nil,
  casMission=nil, casFlight=nil, casAsset=nil, casZone=nil, casResolved=nil,
  casIngress=nil, casRouteInstalled=false, casShot=false, casRelease=false,
  casHome=false, casReturned=false, shotHandler=nil,
  pickup=nil, drop=nil,
  sourceStatic=nil, destStatic=nil, sourceStorage=nil, destStorage=nil,
  cargoTransport=nil, cargoResolved=nil, cargoAsset=nil, cargoFlight=nil, cargoBinding=nil,
  cargoRecruitAttempts=0, cargoRecruitPending=false,
  cargoOutboundInstalled=false, cargoDelivered=false, cargoReturnInstalled=false,
  cargoHome=false, cargoReturned=false,
}

local function log(text) env.info(TAG .. " " .. tostring(text), false) end
local function msg(topic,text,seconds)
  local line="[STAGE3 FOCUSED]["..topic.."] "..tostring(text)
  log(line)
  MESSAGE:New(line,seconds or 10):ToAll()
end

local function fatalFail(reason)
  if state.fatalFailed then return end
  state.fatalFailed=true
  msg("FATAL",reason,25)
end

local function casFail(reason)
  if state.casFailed then return end
  state.casFailed=true
  msg("CAS FAIL",reason,25)
end

local function cargoFail(reason)
  if state.cargoFailed then return end
  state.cargoFailed=true
  msg("RESUPPLY FAIL",reason,25)
end

local function need(value,label)
  if value==nil then fatalFail("missing "..tostring(label)) end
  return value
end

local function aglToAslFt(coord,aglFt)
  return UTILS.MetersToFeet(coord:GetLandHeight())+aglFt
end

local function routeLabel()
  return state.flightPathName or FLIGHTPATH_BASE
end

local function maybePass()
  if state.fatalFailed or state.casFailed or state.cargoFailed or state.passed then return end
  if not (state.casRouteInstalled and state.casShot and state.casRelease and state.casHome and state.casReturned) then return end
  if not (state.cargoOutboundInstalled and state.cargoDelivered and state.cargoReturnInstalled and state.cargoHome and state.cargoReturned) then return end
  state.passed=true
  msg("PASS","AH-64 explicit CAS geometry/attack/recovery and CH-47 OPSTRANSPORT storage delivery/configured FlightPath recovery confirmed",30)
end

local function casAltitude(segmentIndex)
  return segmentIndex==1 and PRIMARY_ALT_FT_AGL or WEST_ALT_FT_AGL
end

local function resolveCas()
  local honaker=ZONE:FindByName(HONAKER_ZONE)
  if not honaker then casFail("missing "..HONAKER_ZONE); return false end
  local center=honaker:GetCoordinate()
  state.casZone=ZONE_RADIUS:New("OMW_STAGE3_FOCUSED_CAS_AO",center:GetVec2(),UTILS.NMToMeters(CAS_RADIUS_NM))
  state.casResolved=Corridor.ResolveSequence({
    pathlineNames={state.flightPathName,WEST},
    pathlines={state.flightPath},
    originCoordinate=state.airwing:GetCoordinate(),
    destinationCoordinate=center,
    maxJunctionDistanceM=JUNCTION_MAX_M,
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
    segmentProfiles={
      {altitudeFtAgl=PRIMARY_ALT_FT_AGL},
      {altitudeFtAgl=WEST_ALT_FT_AGL,formation=ENUMS.Formation.RotaryWing.Column.D70},
    },
  })
  if not state.casResolved or not state.casResolved.outbound or #state.casResolved.outbound<2 then
    casFail("CAS corridor resolution failed")
    return false
  end
  state.casIngress=state.casResolved.outbound[#state.casResolved.outbound]
  log(string.format("CAS_GEOMETRY ingressToAoNm=%.2f path=%s -> %s",
    state.casIngress:Get2DDistance(center)/1852,routeLabel(),WEST))
  return true
end

local function installCasRoute(flight,mission)
  local missionUid=mission:GetGroupWaypointIndex(flight)
  local egressUid=mission:GetGroupEgressWaypointUID(flight)
  if type(missionUid)~="number" or type(egressUid)~="number" then return false,"MISSION_ROUTE_UIDS_NOT_READY" end
  local missionIndex=flight:GetWaypointIndex(missionUid)
  if type(missionIndex)~="number" or missionIndex<3 then return false,"MISSION_ROUTE_UIDS_NOT_READY" end
  local ingressUid=flight:GetWaypointUIDFromIndex(missionIndex-1)
  local predecessorUid=flight:GetWaypointUIDFromIndex(missionIndex-2)
  if type(ingressUid)~="number" or type(predecessorUid)~="number" then return false,"MISSION_ROUTE_UIDS_NOT_READY" end

  local afterUid=predecessorUid
  local outCount=0
  for i=1,#state.casResolved.outbound-1 do
    local seg=state.casResolved.outboundSegmentIndexes and state.casResolved.outboundSegmentIndexes[i] or 1
    local wp=flight:AddWaypoint(state.casResolved.outbound[i],nil,afterUid,casAltitude(seg),false)
    afterUid=wp.uid
    outCount=outCount+1
  end

  afterUid=egressUid
  local retCount=0
  for i=2,#state.casResolved.returnRoute do
    local seg=state.casResolved.returnSegmentIndexes and state.casResolved.returnSegmentIndexes[i] or 1
    local wp=flight:AddWaypoint(state.casResolved.returnRoute[i],nil,afterUid,casAltitude(seg),false)
    afterUid=wp.uid
    retCount=retCount+1
  end
  flight:UpdateRoute()
  state.casRouteInstalled=true
  msg("CAS",string.format("%s/WEST route installed around explicit MOOSE ingress/egress: outbound=%d return=%d",routeLabel(),outCount,retCount),15)
  return true,nil
end

local function bindCasRoute(flight,mission)
  local attempts=0
  local function attempt()
    if state.casFailed or state.casRouteInstalled then return end
    attempts=attempts+1
    local ok,reason=installCasRoute(flight,mission)
    if ok then return end
    if reason=="MISSION_ROUTE_UIDS_NOT_READY" and attempts<12 then
      SCHEDULER:New(nil,attempt,{},1)
      return
    end
    casFail("CAS route installation failed: "..tostring(reason))
  end
  attempt()
end

local function installShotHandler()
  if state.shotHandler then return end
  state.shotHandler=EVENTHANDLER:New()
  state.shotHandler:HandleEvent(EVENTS.Shot)
  function state.shotHandler:OnEventShot(eventData)
    if state.casFailed or state.casShot or not state.casFlight then return end
    if not eventData or eventData.IniGroupName~=state.casFlight:GetName() then return end
    state.casShot=true
    msg("CAS","AH-64 weapon employment confirmed: "..tostring(eventData.WeaponTypeName or "unknown"),12)
    SCHEDULER:New(nil,function()
      if state.casFailed or state.casRelease then return end
      state.casRelease=true
      state.casMission:Cancel()
      msg("CAS",string.format("Acceptance-only release after real attack; use explicit egress and WEST/%s reverse",routeLabel()),12)
    end,{},CAS_RELEASE_DELAY_SEC)
  end
end

local function startCas()
  if not resolveCas() then return false end
  local center=state.casZone:GetCoordinate()
  local casAsl=aglToAslFt(center,CAS_ALT_FT_AGL)
  local ingressAsl=aglToAslFt(state.casIngress,WEST_ALT_FT_AGL)

  state.casMission=AUFTRAG:NewCAS(state.casZone,casAsl,CAS_SPEED_KTS,center,nil,nil,{"Ground Units"})
  state.casMission:SetName("OMW_STAGE3_FOCUSED_HONAKER_CAS")
  state.casMission:SetMissionIngressCoord(state.casIngress,ingressAsl,CAS_SPEED_KTS)
  state.casMission:SetMissionEgressCoord(state.casIngress,ingressAsl,CAS_SPEED_KTS)
  state.casMission:SetMissionWaypointRandomization(0)
  state.casMission:SetEngageDetected(CAS_RADIUS_NM,{"Ground Units"},state.casZone,nil)
  state.casMission:SetROE(ENUMS.ROE.OpenFire)
  state.casMission:SetROT(ENUMS.ROT.PassiveDefense)
  state.casMission:SetRequiredAssets(1,1)
  state.casMission:AssignSquadrons({state.ah64d})
  state.casMission:SetPriority(10,true)
  state.airwing:AddMission(state.casMission)
  msg("CAS READY",string.format("MOOSE NewCAS armed: %s/WEST ingress/egress, AO center, EngageDetected %d NM, OpenFire, PassiveDefense",routeLabel(),CAS_RADIUS_NM),15)
  return true
end

local function createStorageFixtures()
  state.sourceStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :AddCargoResource(STORAGE.Type.WEAPONS,AMMO_TYPE,AMMO_AMOUNT,AMMO_TOTAL_WEIGHT_KG)
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

  local sourceAmount=state.sourceStorage:GetAmount(AMMO_TYPE)
  local destAmount=state.destStorage:GetAmount(AMMO_TYPE)
  if sourceAmount~=AMMO_AMOUNT or destAmount~=0 then
    return false,string.format("storage fixture mismatch source=%s destination=%s",tostring(sourceAmount),tostring(destAmount))
  end
  return true,nil
end

local function carrierRecruitSnapshot()
  local cohortState=state.ch47:GetState()
  local onDuty=state.ch47:IsOnDuty()
  local capability=state.ch47:GetMissionCapability(AUFTRAG.Type.OPSTRANSPORT)~=nil
  local stock=state.ch47:CountAssets(true,{AUFTRAG.Type.OPSTRANSPORT})
  local payloads=state.airwing:CountPayloadsInStock({AUFTRAG.Type.OPSTRANSPORT},state.carrierUnitType)
  return {
    cohortState=cohortState,
    onDuty=onDuty,
    capability=capability,
    stock=stock,
    payloads=payloads,
  }
end

local armCargoCarrier
local function scheduleCargoRecruitment()
  if state.cargoFailed or state.cargoAsset or state.cargoRecruitPending then return end
  state.cargoRecruitPending=true
  SCHEDULER:New(nil,function()
    state.cargoRecruitPending=false
    armCargoCarrier()
  end,{},CARRIER_RECRUIT_RETRY_SEC)
end

armCargoCarrier=function()
  if state.cargoFailed or state.cargoAsset then return end
  state.cargoRecruitAttempts=state.cargoRecruitAttempts+1

  local snapshot=carrierRecruitSnapshot()
  log(string.format("[STAGE3 FOCUSED][RESUPPLY RECRUIT] attempt=%d/%d cohortState=%s onDuty=%s capability=%s stock=%s payloads=%s unitType=%s",
    state.cargoRecruitAttempts,CARRIER_RECRUIT_MAX_ATTEMPTS,tostring(snapshot.cohortState),tostring(snapshot.onDuty),
    tostring(snapshot.capability),tostring(snapshot.stock),tostring(snapshot.payloads),tostring(state.carrierUnitType)))

  if not snapshot.onDuty or not snapshot.capability or snapshot.stock<1 or snapshot.payloads<1 then
    if state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS then
      scheduleCargoRecruitment()
      return
    end
    cargoFail(string.format("CH-47 recruitment readiness timeout after %d attempts: cohortState=%s onDuty=%s capability=%s stock=%s payloads=%s",
      state.cargoRecruitAttempts,tostring(snapshot.cohortState),tostring(snapshot.onDuty),tostring(snapshot.capability),tostring(snapshot.stock),tostring(snapshot.payloads)))
    return
  end

  local recruited,assets,legions=LEGION.RecruitCohortAssets(
    {state.ch47},AUFTRAG.Type.OPSTRANSPORT,nil,1,1,state.drop:GetVec2(),
    nil,nil,nil,AMMO_TOTAL_WEIGHT_KG,AMMO_TOTAL_WEIGHT_KG,nil,nil,nil,nil,nil,nil)

  local assetCount=type(assets)=="table" and #assets or -1
  local legionCount=0
  local recruitedLegion=nil
  if type(legions)=="table" then
    for _,legion in pairs(legions) do
      legionCount=legionCount+1
      recruitedLegion=legion
    end
  end
  local expectedLegion=recruitedLegion==state.airwing
  log(string.format("[STAGE3 FOCUSED][RESUPPLY RECRUIT RESULT] attempt=%d recruited=%s assets=%d legions=%d expectedLegion=%s",
    state.cargoRecruitAttempts,tostring(recruited),assetCount,legionCount,tostring(expectedLegion)))

  if recruited and type(assets)=="table" and assetCount==1 and legionCount==1 and expectedLegion then
    state.cargoAsset=assets[1]
    state.cargoTransport:AddAsset(state.cargoAsset)
    state.airwing:TransportAssign(state.cargoTransport,legions)
    msg("RESUPPLY READY",string.format("MOOSE OPSTRANSPORT queued after carrier recruitment attempt %d: %d x %s, totalWeight=%dkg, carrier=Jalalabad CH-47, route=%s",
      state.cargoRecruitAttempts,AMMO_AMOUNT,AMMO_TYPE,AMMO_TOTAL_WEIGHT_KG,routeLabel()),15)
    return
  end

  if recruited and type(assets)=="table" and assetCount>0 then
    LEGION.UnRecruitAssets(assets)
  end

  if state.cargoRecruitAttempts<CARRIER_RECRUIT_MAX_ATTEMPTS then
    scheduleCargoRecruitment()
    return
  end

  cargoFail(string.format("unable to recruit exactly one Jalalabad CH-47 for OPSTRANSPORT after %d attempts: recruited=%s assets=%d legions=%d expectedLegion=%s cohortState=%s stock=%s payloads=%s",
    state.cargoRecruitAttempts,tostring(recruited),assetCount,legionCount,tostring(expectedLegion),tostring(snapshot.cohortState),tostring(snapshot.stock),tostring(snapshot.payloads)))
end

local function startCargo()
  local fixturesOk,fixturesReason=createStorageFixtures()
  if not fixturesOk then cargoFail(fixturesReason); return false end

  state.cargoResolved=Corridor.Resolve({
    pathlineName=state.flightPathName,
    pathline=state.flightPath,
    originCoordinate=state.pickup:GetCoordinate(),
    destinationCoordinate=state.drop:GetCoordinate(),
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
  })
  if not state.cargoResolved or not state.cargoResolved.outbound or #state.cargoResolved.outbound<2 or
     not state.cargoResolved.returnRoute or #state.cargoResolved.returnRoute<2 then
    cargoFail(routeLabel().." corridor resolution failed")
    return false
  end

  state.cargoTransport=OPSTRANSPORT:New(nil,state.pickup,state.drop)
  state.cargoTransport:SetRequiredCarriers(1,1)
  state.cargoTransport:SetPriority(20)
  state.cargoTransport:AddCargoStorage(state.sourceStorage,state.destStorage,AMMO_TYPE,AMMO_AMOUNT,AMMO_ITEM_WEIGHT_KG)

  local oldExecuting=state.cargoTransport.OnAfterExecuting
  function state.cargoTransport:OnAfterExecuting(F,E,T)
    if oldExecuting then oldExecuting(self,F,E,T) end
    msg("RESUPPLY","MOOSE OPSTRANSPORT executing; CH-47 pickup/load/transport/unload lifecycle active",12)
  end

  local oldDelivered=state.cargoTransport.OnAfterDelivered
  function state.cargoTransport:OnAfterDelivered(F,E,T)
    if oldDelivered then oldDelivered(self,F,E,T) end
    if state.cargoFailed then return end
    local sourceAmount=state.sourceStorage:GetAmount(AMMO_TYPE)
    local destAmount=state.destStorage:GetAmount(AMMO_TYPE)
    if sourceAmount~=0 or destAmount~=AMMO_AMOUNT then
      cargoFail(string.format("OPSTRANSPORT Delivered without expected STORAGE transfer source=%s destination=%s",tostring(sourceAmount),tostring(destAmount)))
      return
    end
    state.cargoDelivered=true
    msg("RESUPPLY",string.format("MOOSE STORAGE delivery confirmed at Wright: %d x %s; awaiting %s reverse/Jalalabad recovery",AMMO_AMOUNT,AMMO_TYPE,routeLabel()),15)
    maybePass()
  end

  local oldCancel=state.cargoTransport.OnAfterCancel
  function state.cargoTransport:OnAfterCancel(F,E,T)
    if oldCancel then oldCancel(self,F,E,T) end
    if not state.cargoDelivered then cargoFail("MOOSE OPSTRANSPORT cancelled before Wright delivery") end
  end

  armCargoCarrier()
  if state.cargoFailed then return false end
  if not state.cargoAsset then
    msg("RESUPPLY","OPSTRANSPORT STORAGE setup active; bounded Jalalabad CH-47 recruitment retry is pending",12)
  end
  return true
end

local function installAirwingObservers()
  local oldFlight=state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(F,E,T,flight,mission)
    if oldFlight then oldFlight(self,F,E,T,flight,mission) end
    if mission==state.casMission then
      state.casFlight=flight
      state.casAsset=mission:GetAssetByName(flight:GetName())
      if not state.casAsset then casFail("AH-64 mission asset unavailable") return end
      installShotHandler()
      bindCasRoute(flight,mission)
      local oldLanded=flight.OnAfterLanded
      function flight:OnAfterLanded(f,e,t,airbase)
        if oldLanded then oldLanded(self,f,e,t,airbase) end
        if state.casRelease and airbase and airbase:GetName()==state.airwing:GetAirbaseName() then
          state.casHome=true
          msg("CAS","AH-64 landed at Jalalabad",8)
          maybePass()
        end
      end
    end
  end

  local oldAssetSpawned=state.airwing.OnAfterAssetSpawned
  function state.airwing:OnAfterAssetSpawned(F,E,T,group,asset,request)
    if oldAssetSpawned then oldAssetSpawned(self,F,E,T,group,asset,request) end
    if not state.cargoAsset or asset~=state.cargoAsset then return end

    local flight=asset.flightgroup
    if not flight then cargoFail("CH-47 OPSTRANSPORT FLIGHTGROUP unavailable after AIRWING spawn") return end
    state.cargoFlight=flight

    local binding,ok,reason=TransportCorridor.Bind(flight,state.cargoTransport,state.cargoResolved,PRIMARY_ALT_FT_AGL,{
      onOutboundInstalled=function(installed)
        state.cargoOutboundInstalled=true
        msg("RESUPPLY",string.format("CH-47 %s outbound installed by OPSTRANSPORT corridor adapter: %d waypoints",routeLabel(),installed.outboundWaypointCount),12)
      end,
      onReturnInstalled=function(installed)
        state.cargoReturnInstalled=true
        msg("RESUPPLY",string.format("CH-47 %s reverse installed after OPSTRANSPORT Delivered: %d waypoints",routeLabel(),installed.returnWaypointCount),12)
        maybePass()
      end,
      onError=function(adapterReason)
        cargoFail("CH-47 OPSTRANSPORT "..routeLabel().." adapter failed: "..tostring(adapterReason))
      end,
    })
    if not ok then cargoFail("CH-47 OPSTRANSPORT corridor bind failed: "..tostring(reason)) return end
    state.cargoBinding=binding

    local oldLanded=flight.OnAfterLanded
    function flight:OnAfterLanded(f,e,t,airbase)
      if oldLanded then oldLanded(self,f,e,t,airbase) end
      if state.cargoDelivered and airbase and airbase:GetName()==state.airwing:GetAirbaseName() then
        state.cargoHome=true
        msg("RESUPPLY","CH-47 landed at Jalalabad after OPSTRANSPORT delivery",8)
        maybePass()
      end
    end
  end

  local oldReturned=state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(F,E,T,cohort,asset)
    if oldReturned then oldReturned(self,F,E,T,cohort,asset) end
    if state.casAsset and asset==state.casAsset then
      if not state.casHome then casFail("AH-64 AIRWING return before home landing") return end
      state.casReturned=true
      msg("CAS","AH-64 recovered by AIRWING",8)
      maybePass()
      return
    end
    if state.cargoAsset and asset==state.cargoAsset then
      if not state.cargoHome then cargoFail("CH-47 AIRWING return before home landing") return end
      state.cargoReturned=true
      msg("RESUPPLY","CH-47 recovered by AIRWING after OPSTRANSPORT",8)
      maybePass()
    end
  end
end

local function resolveConfiguredFlightPath()
  -- Validation-only registry read. Pinned MOOSE 2.9.18 exposes PATHLINE:FindByName()
  -- only for exact names and provides no public wildcard/enumeration API. The MOOSE
  -- DATABASE.PATHLINES registry is therefore read once here solely to identify the
  -- owner-configured OMW_FlightPath[_Rnnn/_Lnnn] name. All geometry remains MOOSE PATHLINE.
  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then
    fatalFail("MOOSE DATABASE.PATHLINES registry unavailable for configured FlightPath discovery")
    return false
  end

  local selected,reason=FlightPathNameContract.SelectFromRegistry(FLIGHTPATH_BASE,_DATABASE.PATHLINES)
  if not selected then fatalFail(reason); return false end
  if type(selected.pathline)~="table" then fatalFail("configured FlightPath registry entry is not a PATHLINE: "..tostring(selected.name)); return false end

  state.flightPathName=selected.name
  state.flightPath=selected.pathline
  state.flightPathOffset=selected.offset
  msg("ROUTE",string.format("configured FlightPath selected: %s offset=%s %dm",selected.name,selected.offset.side,selected.offset.meters),12)
  return true
end

local function start()
  local air=OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(air)~="table" or air.Status~="RUNNING" or not air.Airwing then fatalFail("Jalalabad AIRWING not running") return end
  if not air.Squadrons or not air.Squadrons.AH64D or not air.Squadrons.CH47 then fatalFail("Jalalabad AH64D/CH47 squadrons unavailable") return end
  state.airwing=air.Airwing
  state.ah64d=air.Squadrons.AH64D
  state.ch47=air.Squadrons.CH47
  need(GROUP:FindByName(AH64_TEMPLATE),AH64_TEMPLATE)
  local ch47Template=need(GROUP:FindByName(CH47_TEMPLATE),CH47_TEMPLATE)
  if ch47Template then state.carrierUnitType=ch47Template:GetTypeName() end
  if not resolveConfiguredFlightPath() then return end
  need(PATHLINE:FindByName(WEST),WEST)
  state.pickup=need(ZONE:FindByName(PICKUP_ZONE),PICKUP_ZONE)
  state.drop=need(ZONE:FindByName(DROP_ZONE),DROP_ZONE)
  if state.fatalFailed then return end

  installAirwingObservers()
  local casArmed=startCas()
  local cargoArmed=startCargo()

  if casArmed and cargoArmed then
    msg("READY","CAS armed; OPSTRANSPORT RESUPPLY setup active with bounded MOOSE carrier recruitment; subsystem failure cannot suppress the other path",20)
  elseif casArmed then
    msg("READY","CAS armed; OPSTRANSPORT RESUPPLY failed to arm but CAS execution remains active",20)
  elseif cargoArmed then
    msg("READY","OPSTRANSPORT RESUPPLY setup active; CAS failed to arm but RESUPPLY execution remains active",20)
  else
    msg("FATAL","Neither focused subsystem armed",25)
  end
end

SCHEDULER:New(nil,start,{},5)
