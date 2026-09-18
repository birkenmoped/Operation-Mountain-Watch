local function logCorridorProfiles(kind,installed)
  if not installed or not installed.waypointProfiles then return end
  for direction,profiles in pairs(installed.waypointProfiles) do
    for index,profile in ipairs(profiles) do
      log(string.format("%s_ROUTE_PROFILE direction=%s index=%d uid=%s pathline=%s altitudeFtAgl=%s speedKts=%s altType=%s",
        tostring(kind),tostring(direction),index,tostring(profile.uid),tostring(profile.pathlineName),tostring(profile.altitudeFtAgl),tostring(profile.speedKts),tostring(profile.altType)))
    end
  end
end
local function resolveConfiguredFlightPath()
  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then fail("MOOSE DATABASE.PATHLINES unavailable"); return false end
  local selected,reason=FlightPathNameContract.SelectFromRegistry(FLIGHTPATH_BASE,_DATABASE.PATHLINES)
  if not selected then fail(reason); return false end
  if type(selected.pathline)~="table" then fail("configured FlightPath is not PATHLINE: "..tostring(selected.name)); return false end
  state.flightPathName=selected.name; state.flightPath=selected.pathline
  msg("ROUTE",string.format("configured FlightPath selected: %s offset=%s %dm",selected.name,selected.offset.side,selected.offset.meters),12)
  return true
end
local function prepareAirwing()
  local air=OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(air)~="table" or air.Status~="RUNNING" or not air.Airwing then return false end
  if not air.Squadrons or not air.Squadrons.AH64D or not air.Squadrons.CH47 then return false end
  state.airwing=air.Airwing; state.ah64d=air.Squadrons.AH64D; state.ch47=air.Squadrons.CH47
  local tpl=GROUP:FindByName("TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP")
  if not tpl then return false end
  state.carrierUnitType=tpl:GetTypeName()
  return state.flightPath~=nil and PATHLINE:FindByName(WEST_PATHLINE)~=nil
end
local function getCasDetectedEligibleGroups()
  local result={}
  if not state.casFlight or not state.casTacticalZone then return result,0 end
  local detected=state.casFlight:GetDetectedGroups()
  local set=(detected and type(detected.GetSet)=="function") and detected:GetSet() or {}
  local total=0
  local flightCoord=state.casFlight:GetCoordinate()
  if not flightCoord then return result,total end
  for _,group in pairs(set) do
    total=total+1
    if group and group:IsAlive()==true and group:GetCoalition()==coalition.side.RED then
      local coordinate=group:GetCoordinate()
      local inZone=coordinate and state.casTacticalZone:IsCoordinateInZone(coordinate)
      local inRange=coordinate and flightCoord:Get3DDistance(coordinate)<=UTILS.NMToMeters(CAS_ENGAGE_RANGE_NM)
      local rightType=type(group.HasAttribute)=="function" and group:HasAttribute("Ground Units",false)
      if inZone and inRange and rightType then result[#result+1]=group end
    end
  end
  return result,total
end
local function releaseCasBySupportedElement(reason)
  if state.casClosed or state.casFailed or not state.casDemand then return false end
  if not state.casSupportRequirementActive or not state.honakerNoKnownAttackers then return false end
  if not state.casOnStation or not state.casNoContactReported then return false end
  if not state.casNoContactSince or timer.getAbsTime()-state.casNoContactSince<CAS_NO_CONTACT_STABLE_SEC then return false end
  state.casRecoveryRequested=true
  local _,closed,why=CasPatrolClosure.Complete({
    adapter=state.casAdapter,registry=registry,missionDemand=MissionDemand,demandId=state.casDemand.id,
    tacticalComplete=true,executionEvidenceConfirmed=state.casFired,reason=reason,
    releaseSource=state.site.installationId,executor="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
  })
  if closed~=true then failCas("CAS supported-element release failed: "..tostring(why)); return false end
  state.casSupportRequirementActive=false; state.casReleaseRequested=true; state.casReleaseReason=reason; state.casClosed=true
  msg("CAS","Honaker/control released CAS after stable own no-contact; controlled reverse corridor remains authoritative",15)
  return true
end
local function updateCasSupportState()
  if state.casFailed or state.casClosed or not state.casExecuting or not state.casFlight or not state.casTacticalZone then return end
  local coord=state.casFlight:GetCoordinate(); if not coord then return end
  local now=timer.getAbsTime()
  if state.casTacticalZone:IsCoordinateInZone(coord) and not state.casOnStation then
    state.casOnStation=true; msg("CAS","AH-64D reports ON STATION; own MOOSE/DCS detection picture now controls contact status",12)
  end
  if not state.casOnStation then return end
  local eligible,total=getCasDetectedEligibleGroups(); local count=#eligible
  if count~=state.casDetectedEligibleCount then
    state.casDetectedEligibleCount=count
    if count>0 then
      state.casNoContactReported=false; state.casNoContactSince=nil
      log(string.format("CAS_SENSOR_REPORT detectedTotal=%d eligible=%d",total,count))
    else
      state.casNoContactSince=now
      log(string.format("CAS_SENSOR_REPORT detectedTotal=%d eligible=0 qualification=PENDING_%ds",total,CAS_NO_CONTACT_STABLE_SEC))
    end
  end
  if count==0 and state.casNoContactSince and not state.casNoContactReported and now-state.casNoContactSince>=CAS_NO_CONTACT_STABLE_SEC then
    state.casNoContactReported=true; log("CAS_NO_CONTACT_REPORTED source=FLIGHTGROUP_GetDetectedGroups")
  end
  if state.honakerNoKnownAttackers and count==0 and state.casNoContactReported then
    releaseCasBySupportedElement("SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT")
  end
end
local function ensureCasContext()
  if state.casAdapter and state.casTacticalZone and state.casResolved then return true end
  if not state.airwing or not state.ah64d then failCas("Jalalabad AIRWING/AH64D unavailable"); return false end
  local center=state.brigade:GetCoordinate()
  state.casAltitudeFtAsl=UTILS.MetersToFeet(center:GetLandHeight())+CAS_COMBAT_HEIGHT_FT_AGL
  state.casTacticalZone=ZONE_RADIUS:New("OMW_TACTICAL_BLUE_GROUND_COP_HONAKER_STAGE3_A2_CAS",center:GetVec2(),UTILS.NMToMeters(CAS_TACTICAL_RADIUS_NM))
  local names=casPathlineNames()
  state.casResolved=HelicopterCorridor.ResolveSequence({
    pathlineNames=names,pathlines={state.flightPath},originCoordinate=state.airwing:GetCoordinate(),
    destinationCoordinate=state.casTacticalZone:GetCoordinate(),maxJunctionDistanceM=JUNCTION_MAX_DISTANCE_M,
    offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
    segmentProfiles={{altitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL},{altitudeFtAgl=WEST_ALTITUDE_FT_AGL,formation=ENUMS.Formation.RotaryWing.Column.D70}},
  })
  state.casGeometry=CasTacticalCorridor.PlanRouteGated({
    allocationId=state.casDemand and state.casDemand.id or TEST_ID.."-CAS",outboundRoute=state.casResolved.outbound,
    returnRoute=state.casResolved.returnRoute,
    outboundSegmentIndexes=state.casResolved.outboundSegmentIndexes,
    returnSegmentIndexes=state.casResolved.returnSegmentIndexes,
    ingressSegmentIndex=#names,
    egressSegmentIndex=#names,
    destinationCoordinate=state.casTacticalZone:GetCoordinate(),routeGateDistanceNm=3.5,
    transitAltitudeFtAgl=WEST_ALTITUDE_FT_AGL,missionAltitudeFtAgl=CAS_COMBAT_HEIGHT_FT_AGL,speedKts=CAS_SPEED_KTS,
    honakerReference=state.site.installationId,westReference=WEST_PATHLINE,
  })
  state.casAdapter=CasAdapter.New({
    missionDemand=MissionDemand,registry=registry,airwing=state.airwing,assigneeId="AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV",
    missionMode=CasAdapter.MissionMode.PATROLZONE_ENGAGE,casAltitudeFt=state.casAltitudeFtAsl,casSpeedKts=CAS_SPEED_KTS,
    engageDetectedRangeNm=CAS_ENGAGE_RANGE_NM,engageDetectedTargetTypes={"Ground Units"},squadrons={state.ah64d},
    requireExecutionEvidence=false,
    missionConfigurator=function(mission)
      mission:SetName("OMW_STAGE3_A2_HONAKER_CAS_PATROLZONE_ENGAGE")
      CasTacticalCorridor.ConfigureMission(mission,state.casGeometry)
    end,
  })
  log("CAS_ROUTE_POLICY path="..routeLabel(names).." dynamicRouteGates=true")
  return true
end
local function installCasShotObserver()
  if state.casShotObserver then return end
  state.casShotObserver=EVENTHANDLER:New(); state.casShotObserver:HandleEvent(EVENTS.Shot)
  function state.casShotObserver:OnEventShot(EventData)
    if state.casFailed or state.casFired or not state.casFlight or not state.casDemand then return end
    if not EventData or EventData.IniGroupName~=state.casFlight:GetName() then return end
    state.casFired=true
    local weaponType=EventData.WeaponTypeName or "unknown"
    state.casAdapter:ConfirmExecutionEvidence(state.casDemand.id,{event="SHOT",weaponType=weaponType})
    msg("CAS","AH-64D weapon employment confirmed: "..tostring(weaponType),12)
  end
end
local function bindCasFlightPathCorridor(flight,mission)
  local binding,_,ok,reason=CasTacticalCorridor.Bind(flight,mission,state.casGeometry,{
    onInstalled=function(installed) state.casCorridor=true; logCorridorProfiles("CAS",installed) end,
    onFailed=function(why) failCas("CAS tactical corridor failed: "..tostring(why)) end,
  })
  state.casBinding=binding
  if ok then state.casCorridor=true elseif reason~="MISSION_ROUTE_UIDS_NOT_READY" then failCas("CAS corridor bind failed: "..tostring(reason)) end
end
