-- Operation Mountain Watch - focused Stage 3 CAS + Air-AMMO resupply acceptance.
-- Test-ID: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1
--
-- Purpose:
--   Validate only the two air paths that failed in the previous full-response run.
--   GUARD/QRF/ARTY/CampaignState are intentionally excluded from this probe.
--
-- CAS contract:
--   Jalalabad -> R500 -> WEST -> tactical ingress -> MOOSE CAS working area
--   -> acceptance-only release after confirmed weapon employment -> tactical egress
--   -> WEST reverse -> R500 reverse -> Jalalabad.
--
-- Air-AMMO contract:
--   physical slingload pickup -> public MOOSE task release -> R500 outbound
--   -> Wright physical delivery -> R500 reverse -> Jalalabad.
--
-- Important: no IncidentParticipants or KNOWN_ATTACKERS_NEUTRALIZED state is used
-- as a completion/release condition in this acceptance.

local TEST_ID = "STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local CAS_PRIMARY_PATHLINE = "OMW_FlightPath_R500"
local CAS_WEST_PATHLINE = "OMW_FlightPath_WEST"
local CAS_PATHLINES = { CAS_PRIMARY_PATHLINE, CAS_WEST_PATHLINE }
local CAS_ZONE_RADIUS_NM = 5
local CAS_SPEED_KTS = 120
local CAS_PRIMARY_ALTITUDE_FT_AGL = 500
local CAS_WEST_ALTITUDE_FT_AGL = 2500
local CAS_WORK_ALTITUDE_FT_AGL = 2500
local CAS_RELEASE_AFTER_SHOT_SEC = 90
local JUNCTION_MAX_DISTANCE_M = 1000
local HONAKER_REFERENCE_ZONE = "ZON_BLUE_GND_HONAKER_ACCESS"
local AH64_TEMPLATE = "TPL_AIR_US_JBAD_AH64D_ATTACK_2SHIP"

local PICKUP_ZONE_NAME = "ZON_BLUE_LOG_SLG_JALALABAD_01"
local DROP_ZONE_NAME = "OMW_BLUE_LZ_WRIGHT_01"
local CH47_PATHLINE_NAME = "OMW_FlightPath_R500"
local CH47_TEMPLATE = "TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP"
local CARGO_NAME = "CARGO-STAGE3-CAS-RESUPPLY-FOCUSED-001"
local CH47_ALTITUDE_FT_AGL = 500
local CH47_CHECK_INTERVAL_SEC = 5
local CH47_MAX_HANDOFF_ATTEMPTS = 12

local Corridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local Handoff = OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF

local state = {
  failed=false,
  passed=false,
  airwing=nil,
  ah64d=nil,
  ch47=nil,

  casMission=nil,
  casFlight=nil,
  casAsset=nil,
  casZone=nil,
  casResolved=nil,
  casIngress=nil,
  casEgress=nil,
  casRouteInstalled=false,
  casShot=false,
  casReleaseRequested=false,
  casHomeLanded=false,
  casAssetReturned=false,
  casShotObserver=nil,

  pickupZone=nil,
  dropZone=nil,
  cargo=nil,
  cargoMission=nil,
  cargoFlight=nil,
  cargoAsset=nil,
  cargoPickupConfirmed=false,
  cargoHandoffInstalled=false,
  cargoHandoffAttempts=0,
  cargoDeliveryConfirmed=false,
  cargoHomeLanded=false,
  cargoAssetReturned=false,
  cargoMonitor=nil,
}

local function log(text)
  env.info(TAG .. " " .. tostring(text), false)
end

local function msg(topic, text, seconds)
  local line = "[STAGE3 FOCUSED][" .. tostring(topic) .. "] " .. tostring(text)
  log(line)
  MESSAGE:New(line, seconds or 10):ToAll()
end

local function fail(reason)
  if state.failed or state.passed then return end
  state.failed=true
  if state.cargoMonitor and type(state.cargoMonitor.Stop)=="function" then state.cargoMonitor:Stop() end
  state.cargoMonitor=nil
  msg("FAIL", reason, 25)
end

local function need(value, label)
  if value == nil then fail("missing " .. tostring(label)) end
  return value
end

local function maybePass()
  if state.failed or state.passed then return end
  if not (state.casRouteInstalled and state.casShot and state.casReleaseRequested and state.casHomeLanded and state.casAssetReturned) then return end
  if not (state.cargoPickupConfirmed and state.cargoHandoffInstalled and state.cargoDeliveryConfirmed and state.cargoHomeLanded and state.cargoAssetReturned) then return end
  state.passed=true
  if state.cargoMonitor and type(state.cargoMonitor.Stop)=="function" then state.cargoMonitor:Stop() end
  state.cargoMonitor=nil
  msg("PASS", "CAS explicit ingress/working-area/egress + real weapon employment + planned recovery AND CH-47 pickup/R500/Wright/R500 recovery confirmed", 30)
end

local function aslFeetForAgl(coordinate, aglFeet)
  return UTILS.MetersToFeet(coordinate:GetLandHeight()) + aglFeet
end

local function casProfileFor(segmentIndex)
  if segmentIndex == 1 then return CAS_PRIMARY_ALTITUDE_FT_AGL end
  return CAS_WEST_ALTITUDE_FT_AGL
end

local function resolveCasGeometry()
  local honaker=need(ZONE:FindByName(HONAKER_REFERENCE_ZONE), HONAKER_REFERENCE_ZONE)
  if state.failed then return false end
  local center=honaker:GetCoordinate()
  state.casZone=ZONE_RADIUS:New("OMW_STAGE3_FOCUSED_CAS_WORKING_AREA", center:GetVec2(), UTILS.NMToMeters(CAS_ZONE_RADIUS_NM))
  state.casResolved=Corridor.ResolveSequence({
    pathlineNames=CAS_PATHLINES,
    originCoordinate=state.airwing:GetCoordinate(),
    destinationCoordinate=center,
    maxJunctionDistanceM=JUNCTION_MAX_DISTANCE_M,
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
    segmentProfiles={
      { altitudeFtAgl=CAS_PRIMARY_ALTITUDE_FT_AGL },
      { altitudeFtAgl=CAS_WEST_ALTITUDE_FT_AGL, formation=ENUMS.Formation.RotaryWing.Column.D70 },
    },
  })
  if not state.casResolved or not state.casResolved.outbound or #state.casResolved.outbound < 2 then
    fail("CAS corridor resolution unavailable")
    return false
  end

  -- Tactical ingress and egress are deliberately the WEST corridor exit for this
  -- focused acceptance. MOOSE receives them explicitly; they are not random points.
  state.casIngress=state.casResolved.outbound[#state.casResolved.outbound]
  state.casEgress=state.casIngress

  log(string.format(
    "CAS_GEOMETRY ingressToHonakerNm=%.2f ingressAltFtAsl=%.0f workAltFtAsl=%.0f path=%s",
    state.casIngress:Get2DDistance(center)/1852,
    aslFeetForAgl(state.casIngress, CAS_WEST_ALTITUDE_FT_AGL),
    aslFeetForAgl(center, CAS_WORK_ALTITUDE_FT_AGL),
    table.concat(CAS_PATHLINES, " -> ")))
  return true
end

local function installCasRoute(flight, mission)
  local missionUid=mission:GetGroupWaypointIndex(flight)
  local egressUid=mission:GetGroupEgressWaypointUID(flight)
  if type(missionUid)~="number" or type(egressUid)~="number" then return false,"MISSION_ROUTE_UIDS_NOT_READY" end

  local missionIndex=flight:GetWaypointIndex(missionUid)
  local egressIndex=flight:GetWaypointIndex(egressUid)
  if type(missionIndex)~="number" or missionIndex < 3 or type(egressIndex)~="number" then
    return false,"MISSION_ROUTE_UIDS_NOT_READY"
  end

  local ingressUid=flight:GetWaypointUIDFromIndex(missionIndex-1)
  local predecessorUid=flight:GetWaypointUIDFromIndex(missionIndex-2)
  if type(ingressUid)~="number" or type(predecessorUid)~="number" then return false,"MISSION_ROUTE_UIDS_NOT_READY" end

  local afterUid=predecessorUid
  local outboundCount=0
  -- Last resolved outbound coordinate is the explicit MOOSE ingress and must not
  -- be duplicated. All prior R500/WEST coordinates are inserted before ingress.
  for index=1,#state.casResolved.outbound-1 do
    local coordinate=state.casResolved.outbound[index]
    local segmentIndex=state.casResolved.outboundSegmentIndexes and state.casResolved.outboundSegmentIndexes[index] or 1
    local wp=flight:AddWaypoint(coordinate,nil,afterUid,casProfileFor(segmentIndex),false)
    afterUid=wp.uid
    outboundCount=outboundCount+1
  end

  afterUid=egressUid
  local returnCount=0
  -- First reverse coordinate coincides with explicit tactical egress and is skipped.
  for index=2,#state.casResolved.returnRoute do
    local coordinate=state.casResolved.returnRoute[index]
    local segmentIndex=state.casResolved.returnSegmentIndexes and state.casResolved.returnSegmentIndexes[index] or 1
    local wp=flight:AddWaypoint(coordinate,nil,afterUid,casProfileFor(segmentIndex),false)
    afterUid=wp.uid
    returnCount=returnCount+1
  end

  flight:UpdateRoute()
  state.casRouteInstalled=true
  msg("CAS", string.format("Owner route installed around explicit MOOSE ingress/egress: outbound=%d return=%d; no PATROLZONE random mission waypoint",outboundCount,returnCount), 15)
  return true,nil
end

local function bindCasRoute(flight, mission)
  local attempts=0
  local function attempt()
    if state.failed or state.casRouteInstalled then return end
    attempts=attempts+1
    local ok,reason=installCasRoute(flight,mission)
    if ok then return end
    if reason=="MISSION_ROUTE_UIDS_NOT_READY" and attempts < 12 then
      SCHEDULER:New(nil,attempt,{},1)
      return
    end
    fail("CAS route installation failed after bounded retries: " .. tostring(reason))
  end
  attempt()
end

local function installCasShotObserver()
  if state.casShotObserver then return end
  state.casShotObserver=EVENTHANDLER:New()
  state.casShotObserver:HandleEvent(EVENTS.Shot)
  function state.casShotObserver:OnEventShot(EventData)
    if state.failed or state.casShot or not state.casFlight then return end
    if not EventData or EventData.IniGroupName~=state.casFlight:GetName() then return end
    state.casShot=true
    local weaponType=EventData.WeaponTypeName or "unknown"
    msg("CAS", "Real AH-64 weapon employment confirmed: " .. tostring(weaponType), 12)

    -- Acceptance-only release: exercise MOOSE egress and the owner-authored return
    -- route after a real attack. This timer is NOT production CAS completion doctrine.
    SCHEDULER:New(nil,function()
      if state.failed or state.casReleaseRequested or not state.casMission then return end
      state.casReleaseRequested=true
      state.casMission:Cancel()
      msg("CAS", "Acceptance-only release after confirmed attack; MOOSE egress -> WEST reverse -> R500 reverse", 12)
    end,{},CAS_RELEASE_AFTER_SHOT_SEC)
  end
end

local function startCas()
  if not resolveCasGeometry() then return end
  local center=state.casZone:GetCoordinate()
  local workAltitudeFtAsl=aslFeetForAgl(center,CAS_WORK_ALTITUDE_FT_AGL)
  local ingressAltitudeFtAsl=aslFeetForAgl(state.casIngress,CAS_WEST_ALTITUDE_FT_AGL)
  local egressAltitudeFtAsl=aslFeetForAgl(state.casEgress,CAS_WEST_ALTITUDE_FT_AGL)

  -- Use MOOSE's dedicated AIR CAS mission, not PATROLZONE. The explicit orbit
  -- coordinate is the Honaker working-area center; the engage zone remains 5 NM.
  state.casMission=AUFTRAG:NewCAS(
    state.casZone,
    workAltitudeFtAsl,
    CAS_SPEED_KTS,
    center,
    nil,
    nil,
    {"Ground Units"}
  )
  state.casMission:SetName("OMW_STAGE3_FOCUSED_HONAKER_CAS")
  state.casMission:SetMissionIngressCoord(state.casIngress,ingressAltitudeFtAsl,CAS_SPEED_KTS)
  state.casMission:SetMissionEgressCoord(state.casEgress,egressAltitudeFtAsl,CAS_SPEED_KTS)
  state.casMission:SetMissionWaypointRandomization(0)
  state.casMission:SetRequiredAssets(1,1)
  state.casMission:AssignSquadrons({state.ah64d})
  state.casMission:SetPriority(10,true)

  state.airwing:AddMission(state.casMission)
  msg("CAS", string.format("Queued MOOSE NewCAS: explicit WEST ingress/egress, Honaker working-area center, %d-NM engage zone, waypoint randomization=0",CAS_ZONE_RADIUS_NM), 15)
end

local function resolveCargoR500()
  return Corridor.Resolve({
    pathlineName=CH47_PATHLINE_NAME,
    originCoordinate=state.cargoFlight:GetCoordinate(),
    destinationCoordinate=state.dropZone:GetCoordinate(),
    offsetMode=Corridor.OffsetMode.PATHLINE_SUFFIX,
  })
end

local function tryCargoHandoff()
  if state.failed or state.cargoHandoffInstalled or not state.cargoPickupConfirmed then return end
  state.cargoHandoffAttempts=state.cargoHandoffAttempts+1
  local resolved=resolveCargoR500()
  local installed,ok,reason=Handoff.Install(state.cargoFlight,state.cargoMission,resolved,CH47_ALTITUDE_FT_AGL,{
    cargo=state.cargo,
    dropZone=state.dropZone,
    cargoId=state.cargo:GetID(),
    zoneId=state.dropZone.ZoneID,
  })
  if ok==true then
    state.cargoHandoffInstalled=true
    msg("RESUPPLY",string.format("R500 slingload handoff installed after %d attempt(s); outbound=%s return=%s cargoId=%s zoneId=%s",
      state.cargoHandoffAttempts,tostring(installed.outboundWaypointCount),tostring(installed.returnWaypointCount),tostring(state.cargo:GetID()),tostring(state.dropZone.ZoneID)),15)
    return
  end
  if reason=="CARGOTRANSPORT_PAUSE_REQUESTED" or reason=="CARGOTRANSPORT_TASK_STILL_EXECUTING" or reason=="CURRENT_WAYPOINT_UID_UNAVAILABLE_AFTER_PICKUP" then
    log("CARGO_HANDOFF_WAIT attempt="..tostring(state.cargoHandoffAttempts).." reason="..tostring(reason))
    if state.cargoHandoffAttempts>=CH47_MAX_HANDOFF_ATTEMPTS then fail("CH-47 bounded handoff exhausted: "..tostring(reason)) end
    return
  end
  fail("CH-47 R500 handoff failed: "..tostring(reason))
end

local function startCargoMonitor()
  if state.cargoMonitor then return end
  state.cargoMonitor=SCHEDULER:New(nil,function()
    if state.failed or state.passed then return end
    if not state.cargo or state.cargo:IsAlive()~=true then fail("physical slingload cargo lost") return end
    if not state.cargoPickupConfirmed then
      if state.cargo:IsInZone(state.pickupZone) then return end
      state.cargoPickupConfirmed=true
      msg("RESUPPLY","Physical slingload pickup confirmed; explicit cargo/drop IDs retained; requesting public MOOSE task release",12)
    end
    tryCargoHandoff()
  end,{},CH47_CHECK_INTERVAL_SEC,CH47_CHECK_INTERVAL_SEC)
end

local function startCargo()
  state.cargo=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :InitCargo(true)
    :InitCargoMass(1000)
    :InitCoordinate(state.pickupZone:GetCoordinate())
    :InitValidateAndRepositionStatic(false)
    :Spawn(0,CARGO_NAME)
  if not state.cargo or state.cargo:IsAlive()~=true then fail("physical slingload cargo spawn failed") return end
  if not state.cargo:IsInZone(state.pickupZone) then fail("physical slingload cargo not in pickup zone") return end
  if type(state.cargo.GetID)~="function" or type(state.cargo:GetID())~="number" then fail("physical cargo requires numeric GetID()") return end
  if type(state.dropZone.ZoneID)~="number" then fail("Wright drop zone requires numeric ZoneID") return end

  state.cargoMission=AUFTRAG:NewCARGOTRANSPORT(state.cargo,state.dropZone)
  state.cargoMission:SetName("OMW_STAGE3_FOCUSED_AIR_AMMO_R500")
  state.cargoMission:SetRequiredAssets(1,1)
  state.cargoMission:AssignSquadrons({state.ch47})
  state.cargoMission:SetPriority(20,true)

  local previousSuccess=state.cargoMission.OnAfterSuccess
  function state.cargoMission:OnAfterSuccess(From,Event,To)
    if previousSuccess then previousSuccess(self,From,Event,To) end
    if state.failed then return end
    if not state.cargoPickupConfirmed or not state.cargoHandoffInstalled then fail("cargo mission succeeded before R500 handoff") return end
    if not state.cargo:IsAlive() or not state.cargo:IsInZone(state.dropZone) then fail("cargo success lacks physical Wright delivery") return end
    state.cargoDeliveryConfirmed=true
    msg("RESUPPLY","Physical slingload delivery at Wright confirmed; awaiting R500 reverse and Jalalabad recovery",12)
    maybePass()
  end

  local previousFailed=state.cargoMission.OnAfterFailed
  function state.cargoMission:OnAfterFailed(From,Event,To)
    if previousFailed then previousFailed(self,From,Event,To) end
    if not state.cargoDeliveryConfirmed then fail("MOOSE CARGOTRANSPORT failed") end
  end

  state.airwing:AddMission(state.cargoMission)
  msg("RESUPPLY",string.format("Queued MOOSE CARGOTRANSPORT with explicit runtime refs cargoId=%d zoneId=%d; waiting for physical pickup",state.cargo:GetID(),state.dropZone.ZoneID),15)
end

local function installAirwingObservers()
  local previousFlightOnMission=state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(From,Event,To,FlightGroup,Mission)
    if previousFlightOnMission then previousFlightOnMission(self,From,Event,To,FlightGroup,Mission) end

    if Mission==state.casMission then
      if state.casFlight then fail("multiple AH-64 CAS flights assigned") return end
      state.casFlight=FlightGroup
      state.casAsset=Mission:GetAssetByName(FlightGroup:GetName())
      if not state.casAsset then fail("AH-64 CAS mission asset unavailable") return end
      installCasShotObserver()
      bindCasRoute(FlightGroup,Mission)

      local oldLanded=FlightGroup.OnAfterLanded
      function FlightGroup:OnAfterLanded(F,E,T,Airbase)
        if oldLanded then oldLanded(self,F,E,T,Airbase) end
        if state.casReleaseRequested and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then
          state.casHomeLanded=true
          msg("CAS","AH-64 landed back at Jalalabad after explicit egress/return route",10)
          maybePass()
        end
      end
      return
    end

    if Mission==state.cargoMission then
      if state.cargoFlight then fail("multiple CH-47 cargo flights assigned") return end
      state.cargoFlight=FlightGroup
      state.cargoAsset=Mission:GetAssetByName(FlightGroup:GetName())
      if not state.cargoAsset then fail("CH-47 cargo mission asset unavailable") return end
      local oldLanded=FlightGroup.OnAfterLanded
      function FlightGroup:OnAfterLanded(F,E,T,Airbase)
        if oldLanded then oldLanded(self,F,E,T,Airbase) end
        if state.cargoDeliveryConfirmed and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then
          state.cargoHomeLanded=true
          msg("RESUPPLY","CH-47 landed back at Jalalabad after physical Wright delivery",10)
          maybePass()
        end
      end
      startCargoMonitor()
    end
  end

  local previousReturned=state.airwing.OnAfterLegionAssetReturned
  function state.airwing:OnAfterLegionAssetReturned(From,Event,To,Cohort,Asset)
    if previousReturned then previousReturned(self,From,Event,To,Cohort,Asset) end
    if state.casAsset and Asset==state.casAsset then
      if not state.casHomeLanded then fail("AH-64 returned to AIRWING before Jalalabad landing") return end
      state.casAssetReturned=true
      msg("CAS","AH-64 recovered by Jalalabad AIRWING",8)
      maybePass()
      return
    end
    if state.cargoAsset and Asset==state.cargoAsset then
      if not state.cargoHomeLanded then fail("CH-47 returned to AIRWING before Jalalabad landing") return end
      state.cargoAssetReturned=true
      msg("RESUPPLY","CH-47 recovered by Jalalabad AIRWING",8)
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
  need(PATHLINE:FindByName(CAS_PRIMARY_PATHLINE),CAS_PRIMARY_PATHLINE)
  need(PATHLINE:FindByName(CAS_WEST_PATHLINE),CAS_WEST_PATHLINE)
  state.pickupZone=need(ZONE:FindByName(PICKUP_ZONE_NAME),PICKUP_ZONE_NAME)
  state.dropZone=need(ZONE:FindByName(DROP_ZONE_NAME),DROP_ZONE_NAME)
  if state.failed then return end

  installAirwingObservers()
  startCas()
  startCargo()
  msg("READY","Focused parallel test armed: AH-64 MOOSE CAS with explicit tactical ingress/egress + CH-47 physical slingload R500 handoff. No IncidentParticipants completion gate.",20)
end

SCHEDULER:New(nil,start,{},5)
