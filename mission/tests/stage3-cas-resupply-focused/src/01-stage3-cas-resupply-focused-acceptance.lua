-- Operation Mountain Watch - focused Stage 3 CAS + Air-AMMO resupply acceptance.
-- Test-ID: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1
--
-- Scope: AH-64 CAS routing/execution plus CH-47 slingload routing only.
-- Guard/QRF/ARTY/CampaignState are intentionally excluded.
-- No IncidentParticipants or KNOWN_ATTACKERS_NEUTRALIZED completion gate is used.

local TEST_ID = "STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local R500 = "OMW_FlightPath_R500"
local WEST = "OMW_FlightPath_WEST"
local HONAKER_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"
local PICKUP_ZONE = "ZON_BLUE_LOG_SLG_JALALABAD_01"
local DROP_ZONE = "OMW_BLUE_LZ_WRIGHT_01"
local AH64_TEMPLATE = "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP"
local CH47_TEMPLATE = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
local CARGO_NAME = "CARGO-STAGE3-CAS-RESUPPLY-FOCUSED-001"

local CAS_RADIUS_NM = 5
local CAS_SPEED_KTS = 120
local R500_ALT_FT_AGL = 500
local WEST_ALT_FT_AGL = 2500
local CAS_ALT_FT_AGL = 2500
local CAS_RELEASE_DELAY_SEC = 90
local JUNCTION_MAX_M = 1000
local CARGO_CHECK_SEC = 5
local CARGO_MAX_HANDOFF_ATTEMPTS = 12

local Corridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local Handoff = OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF

local state = {
  failed=false, passed=false,
  airwing=nil, ah64d=nil, ch47=nil,
  casMission=nil, casFlight=nil, casAsset=nil, casZone=nil, casResolved=nil,
  casIngress=nil, casRouteInstalled=false, casShot=false, casRelease=false,
  casHome=false, casReturned=false, shotHandler=nil,
  pickup=nil, drop=nil, cargo=nil, cargoMission=nil, cargoFlight=nil, cargoAsset=nil,
  cargoPickup=false, cargoHandoff=false, cargoAttempts=0, cargoDelivered=false,
  cargoHome=false, cargoReturned=false, cargoMonitor=nil,
}

local function log(text) env.info(TAG .. " " .. tostring(text), false) end
local function msg(topic,text,seconds)
  local line="[STAGE3 FOCUSED]["..topic.."] "..tostring(text)
  log(line)
  MESSAGE:New(line,seconds or 10):ToAll()
end
local function fail(reason)
  if state.failed or state.passed then return end
  state.failed=true
  if state.cargoMonitor and type(state.cargoMonitor.Stop)=="function" then state.cargoMonitor:Stop() end
  state.cargoMonitor=nil
  msg("FAIL",reason,25)
end
local function need(value,label)
  if value==nil then fail("missing "..tostring(label)) end
  return value
end
local function aglToAslFt(coord,aglFt)
  return UTILS.MetersToFeet(coord:GetLandHeight())+aglFt
end
local function maybePass()
  if state.failed or state.passed then return end
  if not (state.casRouteInstalled and state.casShot and state.casRelease and state.casHome and state.casReturned) then return end
  if not (state.cargoPickup and state.cargoHandoff and state.cargoDelivered and state.cargoHome and state.cargoReturned) then return end
  state.passed=true
  if state.cargoMonitor and type(state.cargoMonitor.Stop)=="function" then state.cargoMonitor:Stop() end
  state.cargoMonitor=nil
  msg("PASS","AH-64 explicit CAS geometry/attack/recovery and CH-47 physical pickup/R500/Wright/R500 recovery confirmed",30)
end

local function casAltitude(segmentIndex)
  return segmentIndex==1 and R500_ALT_FT_AGL or WEST_ALT_FT_AGL
end

local function resolveCas()
  local honaker=need(ZONE:FindByName(HONAKER_ZONE),HONAKER_ZONE)
  if state.failed then return false end
  local center=honaker:GetCoordinate()
  state.casZone=ZONE_RADIUS:New("OMW_STAGE3_FOCUSED_CAS_AO",center:GetVec2(),UTILS.NMToMeters(CAS_RADIUS_NM))
  state.casResolved=Corridor.ResolveSequence({
    pathlineNames={R500,WEST},
    originCoordinate=state.airwing:GetCoordinate(),
    destinationCoordinate=center,
    maxJunctionDistanceM=JUNCTION_MAX_M,
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
    segmentProfiles={
      {altitudeFtAgl=R500_ALT_FT_AGL},
      {altitudeFtAgl=WEST_ALT_FT_AGL,formation=ENUMS.Formation.RotaryWing.Column.D70},
    },
  })
  if not state.casResolved or not state.casResolved.outbound or #state.casResolved.outbound<2 then
    fail("CAS corridor resolution failed")
    return false
  end
  state.casIngress=state.casResolved.outbound[#state.casResolved.outbound]
  log(string.format("CAS_GEOMETRY ingressToAoNm=%.2f path=%s -> %s",
    state.casIngress:Get2DDistance(center)/1852,R500,WEST))
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
  msg("CAS",string.format("R500/WEST route installed around explicit MOOSE ingress/egress: outbound=%d return=%d",outCount,retCount),15)
  return true,nil
end

local function bindCasRoute(flight,mission)
  local attempts=0
  local function attempt()
    if state.failed or state.casRouteInstalled then return end
    attempts=attempts+1
    local ok,reason=installCasRoute(flight,mission)
    if ok then return end
    if reason=="MISSION_ROUTE_UIDS_NOT_READY" and attempts<12 then
      SCHEDULER:New(nil,attempt,{},1)
      return
    end
    fail("CAS route installation failed: "..tostring(reason))
  end
  attempt()
end

local function installShotHandler()
  if state.shotHandler then return end
  state.shotHandler=EVENTHANDLER:New()
  state.shotHandler:HandleEvent(EVENTS.Shot)
  function state.shotHandler:OnEventShot(eventData)
    if state.failed or state.casShot or not state.casFlight then return end
    if not eventData or eventData.IniGroupName~=state.casFlight:GetName() then return end
    state.casShot=true
    msg("CAS","AH-64 weapon employment confirmed: "..tostring(eventData.WeaponTypeName or "unknown"),12)
    -- Acceptance-only release to exercise egress/recovery. Not production doctrine.
    SCHEDULER:New(nil,function()
      if state.failed or state.casRelease then return end
      state.casRelease=true
      state.casMission:Cancel()
      msg("CAS","Acceptance-only release after real attack; use explicit egress and WEST/R500 reverse",12)
    end,{},CAS_RELEASE_DELAY_SEC)
  end
end

local function startCas()
  if not resolveCas() then return end
  local center=state.casZone:GetCoordinate()
  local casAsl=aglToAslFt(center,CAS_ALT_FT_AGL)
  local ingressAsl=aglToAslFt(state.casIngress,WEST_ALT_FT_AGL)

  -- Dedicated MOOSE AIR CAS instead of PATROLZONE. The working/orbit point is
  -- explicitly Honaker AO center; ingress and egress are explicitly WEST exit.
  state.casMission=AUFTRAG:NewCAS(state.casZone,casAsl,CAS_SPEED_KTS,center,nil,nil,{"Ground Units"})
  state.casMission:SetName("OMW_STAGE3_FOCUSED_HONAKER_CAS")
  state.casMission:SetMissionIngressCoord(state.casIngress,ingressAsl,CAS_SPEED_KTS)
  state.casMission:SetMissionEgressCoord(state.casIngress,ingressAsl,CAS_SPEED_KTS)
  state.casMission:SetMissionWaypointRandomization(0)
  state.casMission:SetRequiredAssets(1,1)
  state.casMission:AssignSquadrons({state.ah64d})
  state.casMission:SetPriority(10,true)
  state.airwing:AddMission(state.casMission)
  msg("CAS",string.format("MOOSE NewCAS queued: explicit WEST ingress/egress, AO-center working point, %d-NM engage zone, randomization=0",CAS_RADIUS_NM),15)
end

local function resolveCargo()
  return Corridor.Resolve({
    pathlineName=R500,
    originCoordinate=state.cargoFlight:GetCoordinate(),
    destinationCoordinate=state.drop:GetCoordinate(),
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
  })
end

local function tryCargoHandoff()
  if state.failed or state.cargoHandoff or not state.cargoPickup then return end
  state.cargoAttempts=state.cargoAttempts+1
  local installed,ok,reason=Handoff.Install(state.cargoFlight,state.cargoMission,resolveCargo(),R500_ALT_FT_AGL,{
    cargo=state.cargo,
    dropZone=state.drop,
    cargoId=state.cargo:GetID(),
    zoneId=state.drop.ZoneID,
  })
  if ok then
    state.cargoHandoff=true
    msg("RESUPPLY",string.format("CH-47 R500 handoff installed attempt=%d outbound=%s return=%s cargoId=%s zoneId=%s",
      state.cargoAttempts,tostring(installed.outboundWaypointCount),tostring(installed.returnWaypointCount),tostring(state.cargo:GetID()),tostring(state.drop.ZoneID)),15)
    return
  end
  if reason=="CARGOTRANSPORT_PAUSE_REQUESTED" or reason=="CARGOTRANSPORT_TASK_STILL_EXECUTING" or reason=="CURRENT_WAYPOINT_UID_UNAVAILABLE_AFTER_PICKUP" then
    log("CARGO_HANDOFF_WAIT attempt="..state.cargoAttempts.." reason="..tostring(reason))
    if state.cargoAttempts>=CARGO_MAX_HANDOFF_ATTEMPTS then fail("CH-47 handoff timeout: "..tostring(reason)) end
    return
  end
  fail("CH-47 R500 handoff failed: "..tostring(reason))
end

local function startCargoMonitor()
  if state.cargoMonitor then return end
  state.cargoMonitor=SCHEDULER:New(nil,function()
    if state.failed or state.passed then return end
    if not state.cargo or state.cargo:IsAlive()~=true then fail("slingload cargo lost") return end
    if not state.cargoPickup then
      if state.cargo:IsInZone(state.pickup) then return end
      state.cargoPickup=true
      msg("RESUPPLY","Physical pickup confirmed; exact cargoId/drop zoneId retained before handoff",12)
    end
    tryCargoHandoff()
  end,{},CARGO_CHECK_SEC,CARGO_CHECK_SEC)
end

local function startCargo()
  state.cargo=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :InitCargo(true):InitCargoMass(1000):InitCoordinate(state.pickup:GetCoordinate())
    :InitValidateAndRepositionStatic(false):Spawn(0,CARGO_NAME)
  if not state.cargo or state.cargo:IsAlive()~=true or not state.cargo:IsInZone(state.pickup) then fail("physical cargo spawn/pickup-zone validation failed") return end
  if type(state.cargo.GetID)~="function" or type(state.cargo:GetID())~="number" then fail("cargo numeric ID unavailable") return end
  if type(state.drop.ZoneID)~="number" then fail("drop numeric ZoneID unavailable") return end

  state.cargoMission=AUFTRAG:NewCARGOTRANSPORT(state.cargo,state.drop)
  state.cargoMission:SetName("OMW_STAGE3_FOCUSED_AIR_AMMO_R500")
  state.cargoMission:SetRequiredAssets(1,1)
  state.cargoMission:AssignSquadrons({state.ch47})
  state.cargoMission:SetPriority(20,true)

  local oldSuccess=state.cargoMission.OnAfterSuccess
  function state.cargoMission:OnAfterSuccess(F,E,T)
    if oldSuccess then oldSuccess(self,F,E,T) end
    if state.failed then return end
    if not state.cargoPickup or not state.cargoHandoff then fail("cargo success before confirmed R500 handoff") return end
    if not state.cargo:IsAlive() or not state.cargo:IsInZone(state.drop) then fail("cargo success without physical Wright delivery") return end
    state.cargoDelivered=true
    msg("RESUPPLY","Physical Wright delivery confirmed; awaiting R500 reverse/Jalalabad recovery",12)
    maybePass()
  end
  local oldFailed=state.cargoMission.OnAfterFailed
  function state.cargoMission:OnAfterFailed(F,E,T)
    if oldFailed then oldFailed(self,F,E,T) end
    if not state.cargoDelivered then fail("MOOSE CARGOTRANSPORT failed") end
  end

  state.airwing:AddMission(state.cargoMission)
  msg("RESUPPLY",string.format("MOOSE CARGOTRANSPORT queued cargoId=%d zoneId=%d",state.cargo:GetID(),state.drop.ZoneID),12)
end

local function installAirwingObservers()
  local oldFlight=state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(F,E,T,flight,mission)
    if oldFlight then oldFlight(self,F,E,T,flight,mission) end
    if mission==state.casMission then
      state.casFlight=flight
      state.casAsset=mission:GetAssetByName(flight:GetName())
      if not state.casAsset then fail("AH-64 mission asset unavailable") return end
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
      return
    end
    if mission==state.cargoMission then
      state.cargoFlight=flight
      state.cargoAsset=mission:GetAssetByName(flight:GetName())
      if not state.cargoAsset then fail("CH-47 mission asset unavailable") return end
      local oldLanded=flight.OnAfterLanded
      function flight:OnAfterLanded(f,e,t,airbase)
        if oldLanded then oldLanded(self,f,e,t,airbase) end
        if state.cargoDelivered and airbase and airbase:GetName()==state.airwing:GetAirbaseName() then
          state.cargoHome=true
          msg("RESUPPLY","CH-47 landed at Jalalabad",8)
          maybePass()
        end
      end
      startCargoMonitor()
    end
  end

  local oldReturned=state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(F,E,T,cohort,asset)
    if oldReturned then oldReturned(self,F,E,T,cohort,asset) end
    if state.casAsset and asset==state.casAsset then
      if not state.casHome then fail("AH-64 AIRWING return before home landing") return end
      state.casReturned=true
      msg("CAS","AH-64 recovered by AIRWING",8)
      maybePass()
      return
    end
    if state.cargoAsset and asset==state.cargoAsset then
      if not state.cargoHome then fail("CH-47 AIRWING return before home landing") return end
      state.cargoReturned=true
      msg("RESUPPLY","CH-47 recovered by AIRWING",8)
      maybePass()
    end
  end
end

local function start()
  local air=OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(air)~="table" or air.Status~="RUNNING" or not air.Airwing then fail("Jalalabad AIRWING not running") return end
  if not air.Squadrons or not air.Squadrons.AH64D or not air.Squadrons.CH47 then fail("Jalalabad AH64D/CH47 squadrons unavailable") return end
  state.airwing=air.Airwing
  state.ah64d=air.Squadrons.AH64D
  state.ch47=air.Squadrons.CH47
  need(GROUP:FindByName(AH64_TEMPLATE),AH64_TEMPLATE)
  need(GROUP:FindByName(CH47_TEMPLATE),CH47_TEMPLATE)
  need(PATHLINE:FindByName(R500),R500)
  need(PATHLINE:FindByName(WEST),WEST)
  state.pickup=need(ZONE:FindByName(PICKUP_ZONE),PICKUP_ZONE)
  state.drop=need(ZONE:FindByName(DROP_ZONE),DROP_ZONE)
  if state.failed then return end
  installAirwingObservers()
  startCas()
  startCargo()
  msg("READY","Parallel focused test armed: AH-64 explicit MOOSE CAS geometry + CH-47 explicit slingload R500 handoff",20)
end

SCHEDULER:New(nil,start,{},5)
