-- Operation Mountain Watch - Production Base Acceptance 7.
-- Compact full-lifecycle Base acceptance after rejected A6.
--
-- Scope:
--   physical RED attack at FOB Joyce
--   -> production MOOSE perimeter / authoritative installation incident
--   -> production QRF direct-target response
--   -> explicit Base CAS escalation
--   -> generic ExternalSupportRuntime / CommanderBridge
--   -> MOOSE COMMANDER/LEGION selects the eligible operational provider/asset
--   -> selected provider receives its owner-authored rotary-wing route profile
--   -> PATROLZONE + SetEngageDetected
--   -> supported-element/no-contact release
--   -> reverse owner route
--   -> physical landing and LEGION/AIRWING asset return
--
-- No Acceptance-owned AIRWING/SQUADRON/aircraft selection is performed.
-- Unsupported provider/profile combinations fail before MissionAssign and therefore
-- before physical dispatch. A7 must never fall back to a direct-line helicopter route.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A7]"
local TEST_ID="FSSR-PRODUCTION-BASE-ACCEPTANCE-7"
local SITE_ID="FOB_JOYCE"
local FIXTURE_NAME="BadGuys_A3_JOYCE"
local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"

local FLIGHTPATH_BASE="OMW_FlightPath"
local WEST_PATHLINE="OMW_FlightPath_WEST"
local JUNCTION_MAX_DISTANCE_M=1000

local CAS_TACTICAL_RADIUS_NM=5
local CAS_ENGAGE_RANGE_NM=5
local CAS_SPEED_KTS=125
local CAS_COMBAT_HEIGHT_FT_AGL=2500
local PRIMARY_ALTITUDE_FT_AGL=500
local WEST_ALTITUDE_FT_AGL=2500
local CAS_NO_CONTACT_STABLE_SEC=30
local CAS_ROUTE_GATE_NM=3.5

local STARTUP_SEC=20
local TELEMETRY_SEC=5
local TEST_TIMEOUT_SEC=900

local FlightPathNameContract=OMW_A7_FLIGHTPATH_NAME_CONTRACT
local HelicopterCorridor=OMW_A7_HELICOPTER_FLIGHTPATH_CORRIDOR
local CasTacticalCorridor=OMW_A7_HELICOPTER_CAS_TACTICAL_CORRIDOR

local state={
  failed=false,
  passed=false,
  startedAt=nil,
  fixtureActivated=false,

  runtime=nil,
  base=nil,
  brigade=nil,
  commander=nil,
  perimeterState=nil,

  sourceIncident=nil,
  baseIncident=nil,
  qrfArmy=nil,
  qrfGroup=nil,
  qrfEngageObserved=false,

  candidateAirwings={},
  eligibleCohorts=0,
  casCapableCohorts=0,

  casDemand=nil,
  casRequested=false,
  casHandle=nil,
  casMission=nil,
  casZone=nil,
  casAltitudeFtAsl=nil,

  selectedAirwing=nil,
  selectedAirwingAlias=nil,
  selectedSquadron=nil,
  routeProfile=nil,
  casGeometry=nil,
  casResolved=nil,

  casFlight=nil,
  casGroup=nil,
  casInitialAlive=nil,
  casCorridorInstalled=false,
  casOnStation=false,
  casDetectedEligibleCount=nil,
  casNoContactSince=nil,
  casNoContactReported=false,
  supportedElementClear=false,
  recoveryRequested=false,
  fuelLowObserved=false,
  homeLanded=false,
  assetReturned=false,
}

local ROUTE_PROFILES={
  -- This is route metadata, not provider selection. MOOSE still selects the
  -- operational provider. The profile is applied only if that provider is chosen.
  AW_US_JBAD_TF_SHOOTER_6_6_CAV={
    kind="ROTARY_KUNAR_OWNER_ROUTE",
    pathlineBase=FLIGHTPATH_BASE,
    pathlineNames={FLIGHTPATH_BASE,WEST_PATHLINE},
    primaryAltitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL,
    westAltitudeFtAgl=WEST_ALTITUDE_FT_AGL,
    combatAltitudeFtAgl=CAS_COMBAT_HEIGHT_FT_AGL,
    speedKts=CAS_SPEED_KTS,
    routeGateNm=CAS_ROUTE_GATE_NM,
  },
}

local function log(message)
  env.info(TAG.." "..tostring(message),false)
end

local function announce(kind,message,time)
  local text="[PRODUCTION BASE A7]["..kind.."] "..tostring(message)
  log(text)
  MESSAGE:New(text,time or 10):ToAll()
end

local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  announce("FAIL",message,30)
end

local function package()
  return OMW and OMW.FireSupStratResupply or nil
end

local function site()
  local p=package()
  return p and p.SiteRegistry and p.SiteRegistry.Sites[SITE_ID] or nil
end

local function isOurMission(mission)
  return mission and type(mission.GetName)=="function" and mission:GetName()=="OMW_FSSR_BASE_A7_CAS"
end

local function addCandidateAirwing(airwing)
  if type(airwing)~="table" then return end
  local alias=tostring(airwing.alias or airwing.name or airwing)
  if state.candidateAirwings[alias] then return end
  state.candidateAirwings[alias]=airwing
end

local function cohortHasMission(cohort,missionType)
  if not cohort or type(cohort.GetMissionCapability)~="function" then return false end
  return cohort:GetMissionCapability(missionType)~=nil
end

local function discoverAirwings()
  if type(OMW)~="table" or type(OMW.AirOps)~="table" then
    return nil,false,"OMW_AIROPS_UNAVAILABLE"
  end

  for nodeName,node in pairs(OMW.AirOps) do
    if type(node)=="table" and node.Status=="RUNNING" then
      addCandidateAirwing(node.Airwing)
      if type(node.Airwings)=="table" then
        for _,airwing in pairs(node.Airwings) do addCandidateAirwing(airwing) end
      end
      log("C2_AIROPS_NODE_DISCOVERED node="..tostring(nodeName))
    end
  end

  local airwingCount=0
  local casCapable=0
  local eligible=0

  for alias,airwing in pairs(state.candidateAirwings) do
    airwingCount=airwingCount+1
    for _,cohort in pairs(airwing.cohorts or {}) do
      local cas=cohortHasMission(cohort,AUFTRAG.Type.CAS) or cohortHasMission(cohort,AUFTRAG.Type.CASENHANCED)
      local patrol=cohortHasMission(cohort,AUFTRAG.Type.PATROLZONE)
      local attackHelo=(cohort.attribute==GROUP.Attribute.AIR_ATTACKHELO)
      if cas then casCapable=casCapable+1 end
      if patrol and attackHelo then eligible=eligible+1 end
      log(string.format(
        "C2_COHORT_CANDIDATE airwing=%s cohort=%s attribute=%s cas=%s patrolzone=%s eligibleA7=%s",
        tostring(alias),tostring(cohort.name),tostring(cohort.attribute),
        tostring(cas),tostring(patrol),tostring(patrol and attackHelo)))
    end
  end

  state.casCapableCohorts=casCapable
  state.eligibleCohorts=eligible

  if airwingCount<1 then return nil,false,"NO_RUNNING_AIRWING" end
  if eligible<1 then return nil,false,"NO_PATROLZONE_ATTACKHELO_COHORT" end

  return {airwings=airwingCount,casCapable=casCapable,eligible=eligible},true,nil
end

local function selectedLegion(Legions)
  local one=nil
  local count=0
  for _,legion in pairs(Legions or {}) do
    count=count+1
    one=legion
  end
  if count~=1 then return nil,"EXPECTED_ONE_SELECTED_LEGION actual="..tostring(count) end
  return one,nil
end

local function resolveRouteForSelectedProvider(mission,legion)
  local alias=tostring(legion and (legion.alias or legion.name) or "")
  local profile=ROUTE_PROFILES[alias]
  if not profile then
    return nil,"SELECTED_PROVIDER_HAS_NO_OWNER_ROUTE_PROFILE alias="..alias
  end

  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then
    return nil,"MOOSE_DATABASE_PATHLINES_UNAVAILABLE"
  end

  local primary,primaryReason=FlightPathNameContract.SelectFromRegistry(profile.pathlineBase,_DATABASE.PATHLINES)
  if not primary or type(primary.pathline)~="table" then
    return nil,"PRIMARY_OWNER_ROUTE_UNAVAILABLE "..tostring(primaryReason)
  end

  local west=PATHLINE:FindByName(WEST_PATHLINE)
  if not west then return nil,"WEST_OWNER_ROUTE_UNAVAILABLE" end

  local origin=legion:GetCoordinate()
  if not origin then return nil,"SELECTED_PROVIDER_COORDINATE_UNAVAILABLE" end
  if not state.casZone then return nil,"CAS_ZONE_UNAVAILABLE" end

  local okResolved,resolvedOrError=pcall(function()
    return HelicopterCorridor.ResolveSequence({
      pathlineNames={primary.name,WEST_PATHLINE},
      pathlines={primary.pathline,west},
      originCoordinate=origin,
      destinationCoordinate=state.casZone:GetCoordinate(),
      maxJunctionDistanceM=JUNCTION_MAX_DISTANCE_M,
      offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
      segmentProfiles={
        {altitudeFtAgl=profile.primaryAltitudeFtAgl},
        {altitudeFtAgl=profile.westAltitudeFtAgl,formation=ENUMS.Formation.RotaryWing.Column.D70},
      },
    })
  end)
  if not okResolved or type(resolvedOrError)~="table" then
    return nil,"OWNER_ROUTE_RESOLVE_FAILED "..tostring(resolvedOrError)
  end

  local resolved=resolvedOrError
  local okGeometry,geometryOrError=pcall(function()
    return CasTacticalCorridor.PlanRouteGated({
      allocationId=state.casDemand and state.casDemand.demandId or TEST_ID.."-CAS",
      outboundRoute=resolved.outbound,
      returnRoute=resolved.returnRoute,
      destinationCoordinate=state.casZone:GetCoordinate(),
      routeGateDistanceNm=profile.routeGateNm,
      transitAltitudeFtAgl=profile.westAltitudeFtAgl,
      missionAltitudeFtAgl=profile.combatAltitudeFtAgl,
      speedKts=profile.speedKts,
      honakerReference=SITE_ID,
      westReference=WEST_PATHLINE,
    })
  end)
  if not okGeometry or type(geometryOrError)~="table" then
    return nil,"CAS_ROUTE_GATE_FAILED "..tostring(geometryOrError)
  end

  local geometry=geometryOrError
  local okConfigure,configureError=pcall(function()
    CasTacticalCorridor.ConfigureMission(mission,geometry)
  end)
  if not okConfigure then
    return nil,"CAS_MISSION_ROUTE_CONFIG_FAILED "..tostring(configureError)
  end

  state.routeProfile=profile
  state.casResolved=resolved
  state.casGeometry=geometry
  state.selectedAirwing=legion
  state.selectedAirwingAlias=alias

  log(string.format(
    "C2_PROVIDER_ROUTE_BOUND provider=%s profile=%s primary=%s west=%s originDistanceM=%.1f routePoints=%d",
    alias,tostring(profile.kind),tostring(primary.name),WEST_PATHLINE,
    tonumber(resolved.originDistanceM) or -1,#(resolved.outbound or {})))

  return geometry,nil
end

local function attachCommanderLifecycle(commander)
  local previousBefore=commander.OnBeforeMissionAssign
  function commander:OnBeforeMissionAssign(From,Event,To,Mission,Legions)
    if previousBefore and previousBefore(self,From,Event,To,Mission,Legions)==false then return false end
    if not isOurMission(Mission) then return true end

    local legion,reason=selectedLegion(Legions)
    if not legion then
      fail("C2_PROVIDER_SELECTION_INVALID "..tostring(reason))
      return false
    end

    local geometry,routeReason=resolveRouteForSelectedProvider(Mission,legion)
    if not geometry then
      fail("C2_PROVIDER_ROUTE_REJECTED "..tostring(routeReason))
      return false
    end

    log("C2_PROVIDER_SELECTED_AND_PROFILED legion="..tostring(state.selectedAirwingAlias))
    return true
  end

  local previousAssign=commander.OnAfterMissionAssign
  function commander:OnAfterMissionAssign(From,Event,To,Mission,Legions)
    if previousAssign then previousAssign(self,From,Event,To,Mission,Legions) end
    if not isOurMission(Mission) then return end
    state.casMission=Mission
    local asset=Mission.assets and Mission.assets[1] or nil
    state.selectedSquadron=asset and asset.squadname or nil
    log("C2_CAS_MISSION_ASSIGNED provider="..tostring(state.selectedAirwingAlias)
      .." squadron="..tostring(state.selectedSquadron))
  end

  local previousOps=commander.OnAfterOpsOnMission
  function commander:OnAfterOpsOnMission(From,Event,To,OpsGroup,Mission)
    if previousOps then previousOps(self,From,Event,To,OpsGroup,Mission) end
    if not isOurMission(Mission) then return end
    if state.casFlight and state.casFlight~=OpsGroup then
      fail("MULTIPLE_CAS_OPSGROUPS")
      return
    end
    if not state.casGeometry then
      fail("CAS_OPSGROUP_WITHOUT_OWNER_ROUTE_PROFILE")
      return
    end

    state.casFlight=OpsGroup
    state.casGroup=type(OpsGroup.GetGroup)=="function" and OpsGroup:GetGroup() or nil
    state.casInitialAlive=state.casGroup and type(state.casGroup.CountAliveUnits)=="function" and state.casGroup:CountAliveUnits() or nil

    local binding,_,bound,bindReason=CasTacticalCorridor.Bind(OpsGroup,Mission,state.casGeometry,{
      onInstalled=function(result)
        state.casCorridorInstalled=true
        log(string.format("CAS_OWNER_CORRIDOR_INSTALLED missionUid=%s ingressUid=%s egressUid=%s added=%s",
          tostring(result and result.missionUid),tostring(result and result.ingressUid),
          tostring(result and result.egressUid),tostring(result and result.waypointProfiles and #result.waypointProfiles or 0)))
      end,
      onFailed=function(reason)
        fail("CAS_OWNER_CORRIDOR_BIND_FAILED "..tostring(reason))
      end,
    })
    state.casBinding=binding
    if not bound and bindReason~="MISSION_ROUTE_UIDS_NOT_READY" then
      fail("CAS_OWNER_CORRIDOR_BIND_FAILED "..tostring(bindReason))
      return
    end

    -- Fail closed before MOOSE can execute its normal FuelLow RTB fallback.
    -- A7 must prove an earlier supported-element/no-contact release and owner-route
    -- recovery; FuelLow is therefore a regression, not an alternate completion path.
    local previousBeforeFuelLow=OpsGroup.OnBeforeFuelLow
    function OpsGroup:OnBeforeFuelLow(F,E,T)
      if previousBeforeFuelLow and previousBeforeFuelLow(self,F,E,T)==false then return false end
      state.fuelLowObserved=true
      fail("CAS_FUEL_LOW_BEFORE_PHYSICAL_RETURN")
      return false
    end

    local previousLanded=OpsGroup.OnAfterLanded
    function OpsGroup:OnAfterLanded(F,E,T,Airport)
      if previousLanded then previousLanded(self,F,E,T,Airport) end
      state.homeLanded=true
      local airportName=Airport and type(Airport.GetName)=="function" and Airport:GetName() or tostring(Airport)
      log("CAS_HOME_LANDED airport="..tostring(airportName).." provider="..tostring(state.selectedAirwingAlias))
    end

    if state.selectedAirwing then
      local airwing=state.selectedAirwing
      local previousReturned=airwing.OnAfterLegionAssetReturned
      function airwing:OnAfterLegionAssetReturned(F,E,T,Cohort,Asset)
        if previousReturned then previousReturned(self,F,E,T,Cohort,Asset) end
        local same=false
        if Asset and Asset.flightgroup and Asset.flightgroup==state.casFlight then same=true end
        if not same and Asset and state.casFlight and type(state.casFlight.GetName)=="function"
            and Asset.spawngroupname==state.casFlight:GetName() then same=true end
        if same then
          state.assetReturned=true
          log("CAS_LEGION_ASSET_RETURNED provider="..tostring(state.selectedAirwingAlias)
            .." cohort="..tostring(Cohort and Cohort.name)
            .." asset="..tostring(Asset and Asset.spawngroupname))
        end
      end
    end

    log("C2_CAS_OPS_ON_MISSION provider="..tostring(state.selectedAirwingAlias)
      .." squadron="..tostring(state.selectedSquadron)
      .." group="..tostring(state.casGroup and state.casGroup:GetName() or OpsGroup:GetName()))
  end
end

local function buildCommander()
  local summary,ok,reason=discoverAirwings()
  if not ok then return nil,false,reason end

  local commander=COMMANDER:New(coalition.side.BLUE,"OMW_FSSR_BASE_A7_C2")
  if not commander then return nil,false,"COMMANDER_CREATE_FAILED" end
  commander:SetVerbosity(2)

  for alias,airwing in pairs(state.candidateAirwings) do
    commander:AddAirwing(airwing)
    log("C2_LEGION_REGISTERED alias="..tostring(alias))
  end

  attachCommanderLifecycle(commander)
  commander:Start()
  state.commander=commander

  log(string.format("C2_READY airwings=%d casCapableCohorts=%d patrolzoneAttackHeloEligible=%d",
    summary.airwings,summary.casCapable,summary.eligible))
  return commander,true,nil
end

local function buildBrigade(p)
  local s=p.SiteRegistry.Sites[SITE_ID]
  local brigade=BRIGADE:New(s.warehouseName,"BDE_FSSR_A7_"..SITE_ID)
  local guard=PLATOON:New(s.guardTemplateName,1,"PLT_FSSR_A7_GUARD_"..SITE_ID)
  local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A7_QRF_"..SITE_ID)
  guard:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  brigade:AddPlatoon(guard)
  brigade:AddPlatoon(qrf)

  local previousArmy=brigade.OnAfterArmyOnMission
  function brigade:OnAfterArmyOnMission(From,Event,To,ArmyGroup,Mission)
    if previousArmy then previousArmy(self,From,Event,To,ArmyGroup,Mission) end
    local group=ArmyGroup and ArmyGroup:GetGroup() or nil
    if not group then return end
    if group:GetAttribute()==GROUP.Attribute.GROUND_APC then
      if state.qrfArmy and state.qrfArmy~=ArmyGroup then
        fail("DUPLICATE_QRF_ARMYGROUP")
        return
      end
      state.qrfArmy=ArmyGroup
      state.qrfGroup=group
      local previousEngage=ArmyGroup.OnAfterEngageTarget
      function ArmyGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
        if previousEngage then previousEngage(self,F,E,T,Target,Speed,Formation) end
        state.qrfEngageObserved=true
        local targetName=Target and type(Target.GetName)=="function" and Target:GetName() or tostring(Target)
        log("QRF_DIRECT_TARGET_ENGAGE target="..tostring(targetName)
          .." speed="..tostring(Speed).." formation="..tostring(Formation))
      end
      log("QRF_MATERIALIZED group="..tostring(group:GetName())
        .." missionType="..tostring(Mission and Mission:GetType()))
    end
  end

  state.brigade=brigade
end

local function buildPerimeter(p)
  local s=p.SiteRegistry.Sites[SITE_ID]
  local alarm=s.alarm
  if type(alarm)~="table" or alarm.anchorKind~="WAREHOUSE" or type(alarm.radiusM)~="number" then
    return nil,"JOYCE_ALARM_CONFIG_INVALID"
  end
  local anchor=state.brigade:GetCoordinate()
  if not anchor then return nil,"JOYCE_WAREHOUSE_COORDINATE_UNAVAILABLE" end
  return {
    [SITE_ID]={
      anchorCoordinate=anchor,
      zoneName="OMW_SECURITY_"..s.installationId,
      radiusM=alarm.radiusM,
      priority=0,
    },
  },nil
end

local function sourceCoordinator()
  local s=site()
  local ir=state.runtime and state.runtime.installationIncidentRuntime or nil
  return ir and s and ir:GetCoordinator(s.installationId) or nil
end

local function activeBaseIncident()
  local p=package()
  local s=site()
  local coordinator=sourceCoordinator()
  local active=coordinator and coordinator:GetActive() or nil
  if not active or not p then return nil,nil end
  local incidentId=p.IdContract.Incident(SITE_ID,active.incidentId)
  return state.base:GetIncident(incidentId),active
end

local function livingIncidentGroups()
  local result={}
  local coordinator=sourceCoordinator()
  if not coordinator then return result end
  for _,group in ipairs(coordinator:GetParticipants(true) or {}) do
    if group and group:IsAlive()==true and group:GetCoalition()==coalition.side.RED then
      result[#result+1]=group
    end
  end
  return result
end

local function casDetectedEligibleGroups()
  local result={}
  if not state.casFlight or not state.casZone then return result,0 end
  local detected=state.casFlight:GetDetectedGroups()
  local set=(detected and type(detected.GetSet)=="function") and detected:GetSet() or {}
  local total=0
  local flightCoord=state.casFlight:GetCoordinate()
  if not flightCoord then return result,total end

  for _,group in pairs(set) do
    total=total+1
    if group and group:IsAlive()==true and group:GetCoalition()==coalition.side.RED then
      local coordinate=group:GetCoordinate()
      local inZone=coordinate and state.casZone:IsCoordinateInZone(coordinate)
      local inRange=coordinate and flightCoord:Get3DDistance(coordinate)<=UTILS.NMToMeters(CAS_ENGAGE_RANGE_NM)
      local ground=type(group.HasAttribute)=="function" and group:HasAttribute("Ground Units",false)
      if inZone and inRange and ground then result[#result+1]=group end
    end
  end
  return result,total
end

local function resolveCasGeometry(demand,context)
  local targetGroup=context and context.incident and context.incident.context
    and context.incident.context.physicalTargetGroup or nil
  if not targetGroup or targetGroup:IsAlive()~=true then
    return nil,"CAS_PHYSICAL_TARGET_UNAVAILABLE"
  end

  local coordinate=targetGroup:GetCoordinate()
  if not coordinate then return nil,"CAS_TARGET_COORDINATE_UNAVAILABLE" end

  state.casZone=ZONE_RADIUS:New(
    "OMW_FSSR_BASE_A7_CAS_"..tostring(demand.demandId),
    coordinate:GetVec2(),
    UTILS.NMToMeters(CAS_TACTICAL_RADIUS_NM))

  state.casAltitudeFtAsl=UTILS.MetersToFeet(state.casZone:GetCoordinate():GetLandHeight())+CAS_COMBAT_HEIGHT_FT_AGL

  return {
    missionMode="PATROLZONE_ENGAGE",
    zone=state.casZone,
    altitudeFt=state.casAltitudeFtAsl,
    speedKts=CAS_SPEED_KTS,
    engageDetectedRangeNm=CAS_ENGAGE_RANGE_NM,
    engageDetectedTargetTypes={"Ground Units"},
    targetTypes={"Ground Units"},
    requiredAttributes=GROUP.Attribute.AIR_ATTACKHELO,
    configureMission=function(mission)
      mission:SetName("OMW_FSSR_BASE_A7_CAS")
    end,
  },nil
end

local function requestCasIfReady()
  if state.casRequested or not state.runtime then return end
  local incident=activeBaseIncident()
  if not incident then return end

  state.baseIncident=incident
  local demand,created,reason=state.base:RequestIncidentSupport(
    incident.incidentId,
    "CAS",
    {
      requestKey="A7_FULL_LIFECYCLE",
      priority=20,
      cancelWhenIncidentClosed=false,
    })

  if not demand then
    fail("CAS_REQUEST_FAILED reason="..tostring(reason))
    return
  end

  state.casDemand=demand
  state.casRequested=true

  local external=state.runtime.externalSupportRuntime
  local bridge=external and external.cas or nil
  local item=bridge and bridge.items and bridge.items[demand.demandId] or nil
  state.casHandle=item
  state.casMission=item and item.runtime or nil

  if not state.casHandle or not state.casMission then
    fail("CAS_RUNTIME_HANDLE_UNAVAILABLE")
    return
  end

  log("CAS_ESCALATION_REQUESTED demandId="..tostring(demand.demandId)
    .." status="..tostring(demand.status)
    .." created="..tostring(created)
    .." reason="..tostring(reason))
end

local function updateCasLifecycle()
  if state.failed or state.passed or not state.casFlight then return end

  if state.casGroup and state.casInitialAlive and type(state.casGroup.CountAliveUnits)=="function" then
    local alive=state.casGroup:CountAliveUnits()
    if alive<state.casInitialAlive then
      fail("CAS_ASSET_LOSS initialAlive="..tostring(state.casInitialAlive).." alive="..tostring(alive))
      return
    end
  end

  local coordinate=state.casFlight:GetCoordinate()
  if coordinate and state.casZone and state.casZone:IsCoordinateInZone(coordinate) and not state.casOnStation then
    state.casOnStation=true
    log("CAS_ON_STATION provider="..tostring(state.selectedAirwingAlias)
      .." squadron="..tostring(state.selectedSquadron))
  end

  if not state.casOnStation or state.recoveryRequested then return end

  local eligible,total=casDetectedEligibleGroups()
  local count=#eligible
  if count~=state.casDetectedEligibleCount then
    state.casDetectedEligibleCount=count
    if count>0 then
      state.casNoContactSince=nil
      state.casNoContactReported=false
      log(string.format("CAS_SENSOR_REPORT detectedTotal=%d eligible=%d",total,count))
    else
      state.casNoContactSince=timer.getAbsTime()
      log(string.format("CAS_SENSOR_REPORT detectedTotal=%d eligible=0 qualification=PENDING_%ds",
        total,CAS_NO_CONTACT_STABLE_SEC))
    end
  end

  if count==0 and state.casNoContactSince and not state.casNoContactReported
      and timer.getAbsTime()-state.casNoContactSince>=CAS_NO_CONTACT_STABLE_SEC then
    state.casNoContactReported=true
    log("CAS_NO_CONTACT_REPORTED source=FLIGHTGROUP_GetDetectedGroups")
  end

  state.supportedElementClear=(#livingIncidentGroups()==0)

  if state.supportedElementClear and state.casNoContactReported then
    state.recoveryRequested=true
    local changed,reason=state.casHandle:Cancel()
    if changed~=true then
      fail("CAS_CONTROLLED_RELEASE_FAILED "..tostring(reason))
      return
    end
    log("CAS_CONTROLLED_RELEASE reason=SUPPORTED_ELEMENT_CLEAR_AND_STABLE_OWN_NO_CONTACT reverseOwnerRoute=true")
  end
end

local function evaluate()
  if state.failed or state.passed then return end

  requestCasIfReady()
  updateCasLifecycle()

  if state.qrfEngageObserved
      and state.casRequested
      and state.selectedAirwing
      and state.casCorridorInstalled
      and state.casOnStation
      and state.recoveryRequested
      and state.homeLanded
      and state.assetReturned
      and not state.fuelLowObserved then
    state.passed=true
    announce("PASS",
      "Joyce attack -> production incident/QRF plus Base CAS demand -> MOOSE-selected attack-helicopter provider/asset -> owner route -> own detection/no-contact release -> reverse owner route -> physical landing -> LEGION asset return.",
      45)
    return
  end

  if state.startedAt and timer.getTime()-state.startedAt>TEST_TIMEOUT_SEC then
    fail("TIMEOUT qrfEngage="..tostring(state.qrfEngageObserved)
      .." casRequested="..tostring(state.casRequested)
      .." provider="..tostring(state.selectedAirwingAlias)
      .." corridor="..tostring(state.casCorridorInstalled)
      .." onStation="..tostring(state.casOnStation)
      .." noContact="..tostring(state.casNoContactReported)
      .." supportedClear="..tostring(state.supportedElementClear)
      .." recovery="..tostring(state.recoveryRequested)
      .." landed="..tostring(state.homeLanded)
      .." assetReturned="..tostring(state.assetReturned)
      .." fuelLow="..tostring(state.fuelLowObserved))
  end
end

local function activateFixture()
  if state.fixtureActivated or state.failed then return end
  local fixture=GROUP:FindByName(FIXTURE_NAME)
  if not fixture then fail("FIXTURE_GROUP_MISSING "..FIXTURE_NAME); return end
  if fixture:IsAlive()~=true then fixture:Activate() end
  state.fixtureActivated=true
  state.startedAt=timer.getTime()
  announce("ATTACK","Joyce RED fixture activated on its existing Mission Editor route; no route rewrite.",15)
end

local function start()
  local p=package()
  if type(p)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then
    fail("BLUE_TEMPLATE_MISSING")
    return
  end
  if not GROUP:FindByName(FIXTURE_NAME) then
    fail("FIXTURE_GROUP_MISSING "..FIXTURE_NAME)
    return
  end
  if type(COMMANDER)~="table" or type(COMMANDER.New)~="function" then
    fail("MOOSE_COMMANDER_UNAVAILABLE")
    return
  end
  if type(GROUP.Attribute)~="table" or not GROUP.Attribute.AIR_ATTACKHELO then
    fail("MOOSE_ATTACK_HELO_ATTRIBUTE_UNAVAILABLE")
    return
  end

  local commander,commanderOk,commanderReason=buildCommander()
  if not commanderOk then
    fail("C2_PREFLIGHT_FAILED "..tostring(commanderReason))
    return
  end

  buildBrigade(p)
  local perimeters,perimeterReason=buildPerimeter(p)
  if not perimeters then
    fail("PERIMETER_CONFIG_FAILED "..tostring(perimeterReason))
    return
  end

  local singleSiteRegistry={
    SchemaVersion=p.SiteRegistry.SchemaVersion,
    Sites={[SITE_ID]=p.SiteRegistry.Sites[SITE_ID]},
  }

  local ok,runtimeOrError=pcall(function()
    local runtime=p.New({
      siteRegistry=singleSiteRegistry,
      brigades={[SITE_ID]=state.brigade},
      resolveGuardPathline=function(name) return PATHLINE:FindByName(name) end,
      resolveGuardTemplateGroup=function(name) return GROUP:FindByName(name) end,
      guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
      resolveQrfCoordinate=function(_,context)
        local physical=context and context.incident and context.incident.context
          and context.incident.context.physicalTargetGroup or nil
        if not physical then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
        return physical,nil
      end,
      qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
      blueCoalition=coalition.side.BLUE,
      redCoalition=coalition.side.RED,
      perimeters=perimeters,
      externalSupport={
        commander=commander,
        resolveArtyTarget=function() return nil,"ARTY_NOT_IN_ACCEPTANCE_7_SCOPE" end,
        resolveCasGeometry=resolveCasGeometry,
        casRequiredAssetsMin=1,
        casRequiredAssetsMax=1,
      },
      logger=log,
    })
    return runtime:Prepare()
  end)

  if not ok or not runtimeOrError then
    fail("RUNTIME_PREPARE_FAILED "..tostring(runtimeOrError))
    return
  end

  state.runtime=runtimeOrError
  state.base=state.runtime:GetBase()

  local perimeterStates,started,reason=state.runtime:StartPerimeters()
  if started~=true then
    fail("PERIMETER_START_FAILED "..tostring(reason))
    return
  end
  state.perimeterState=perimeterStates and perimeterStates[SITE_ID] or nil

  state.brigade:Start()
  local _,siteStarted,siteReason=state.runtime:StartSite(SITE_ID,{})
  if siteStarted==false then
    fail("SITE_START_FAILED "..tostring(siteReason))
    return
  end

  announce("READY",
    "Joyce Base runtime active. MOOSE COMMANDER owns provider/asset selection. A7 requires PATROLZONE attack-helicopter capability and binds an owner route only after MOOSE selects the provider.",
    20)

  SCHEDULER:New(nil,activateFixture,{},STARTUP_SEC)
  SCHEDULER:New(nil,evaluate,{},TELEMETRY_SEC,TELEMETRY_SEC)
end

SCHEDULER:New(nil,start,{},10)
