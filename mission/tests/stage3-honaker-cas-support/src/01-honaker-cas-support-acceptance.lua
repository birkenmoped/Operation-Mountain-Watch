-- Operation Mountain Watch - focused Stage 3 Honaker CAS support acceptance.
-- Test-ID: STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1
--
-- Scope: isolate CAS after the Build 1-19 full-response run proved Guard/QRF/ARTY/
-- OPSTRANSPORT paths but exposed a CAS lifecycle regression and no weapon employment.
-- This acceptance deliberately does not dispatch Guard, QRF, ARTY or logistics.

local TEST_ID = "STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"

local INSTALLATION_ID = "BLUE_GROUND_COP_HONAKER"
local HONAKER_WAREHOUSE = "WH_BLUE_GND_HONAKER"
local FLIGHTPATH_BASE = "OMW_FlightPath"
local WEST_PATHLINE = "OMW_FlightPath_WEST"
local SECURITY_RADIUS_M = 1000
local CAS_TACTICAL_RADIUS_NM = 5
local CAS_ENGAGE_RANGE_NM = 5
local CAS_COMBAT_HEIGHT_FT_AGL = 2500
local CAS_SPEED_KTS = 120
local PRIMARY_ALTITUDE_FT_AGL = 500
local WEST_ALTITUDE_FT_AGL = 2500
local JUNCTION_MAX_DISTANCE_M = 1000
local STATUS_INTERVAL_SEC = 10
local MAX_RUNTIME_SEC = 1800

local MissionDemand = OMW_STAGE3_MISSION_DEMAND
local CasPolicy = OMW_STAGE3_FOB_ATTACK_DEMAND_POLICY
local ThreatAdapter = OMW_STAGE3_FOB_THREAT_OPSZONE_ADAPTER
local IncidentCoordinator = OMW_STAGE3_GROUND_INSTALLATION_ATTACK_INCIDENT
local CasAdapter = OMW_STAGE3_FOB_ATTACK_CAS_DISPATCH_ADAPTER
local CasPatrolClosure = OMW_STAGE3_FOB_ATTACK_CAS_PATROL_CLOSURE
local HelicopterCorridor = OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR
local MissionOwnedCorridor = OMW_STAGE3_HELICOPTER_MISSION_OWNED_CORRIDOR
local FlightPathNameContract = OMW_STAGE3_FLIGHTPATH_NAME_CONTRACT

local registry = MissionDemand.New()

local state = {
  failed=false,
  passed=false,
  startedAt=timer.getTime(),
  airwing=nil,
  ah64d=nil,
  honakerCoord=nil,
  flightPathName=nil,
  flightPath=nil,
  casAdapter=nil,
  casDemand=nil,
  casMission=nil,
  casFlight=nil,
  casTacticalZone=nil,
  casAltitudeFtAsl=nil,
  casResolved=nil,
  casLifecycle=nil,
  casExecuting=false,
  casCorridor=false,
  casFired=false,
  casEngaged=false,
  casShotObserver=nil,
  casSupportRequirementActive=false,
  casOnStation=false,
  casDetectedEligibleCount=nil,
  casDetectedEligibleNames={},
  casContactReported=false,
  casNoContactReported=false,
  casReleaseRequested=false,
  casReleaseReason=nil,
  casClosed=false,
  casHomeLanded=false,
  honakerNoKnownAttackers=false,
  threat=nil,
  threatStarted=false,
  threatStopped=false,
  perimeterClear=false,
  attackIncident=nil,
  attackIncidentClosed=false,
  statusScheduler=nil,
}

local function log(text)
  env.info(TAG .. " " .. tostring(text), false)
end

local function msg(topic, text, seconds)
  local line = "[STAGE 3 CAS][" .. tostring(topic) .. "] " .. tostring(text)
  log(line)
  MESSAGE:New(line, seconds or 8):ToAll()
end

local function stopScheduler()
  if state.statusScheduler and type(state.statusScheduler.Stop)=="function" then
    state.statusScheduler:Stop()
    state.statusScheduler=nil
  end
end

local function fail(reason)
  if state.failed or state.passed then return end
  state.failed=true
  stopScheduler()
  msg("FAIL", reason, 25)
end

local function need(value, label)
  if not value then fail("missing " .. tostring(label)) end
  return value
end

local function primaryPathlineName()
  return state.flightPathName or FLIGHTPATH_BASE
end

local function casPathlineNames()
  return { primaryPathlineName(), WEST_PATHLINE }
end

local function routeLabel(names)
  return table.concat(names, " -> ")
end

local function redGroups(opsZone)
  local result={}
  for _,group in pairs(opsZone:GetScannedGroupSet():GetSet()) do
    if group and group:IsAlive() and group:GetCoalition()==coalition.side.RED then
      result[#result+1]=group
    end
  end
  table.sort(result,function(a,b) return a:GetName()<b:GetName() end)
  return result
end

local function resolveConfiguredFlightPath()
  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then
    fail("MOOSE DATABASE.PATHLINES registry unavailable")
    return false
  end
  local selected,reason=FlightPathNameContract.SelectFromRegistry(FLIGHTPATH_BASE,_DATABASE.PATHLINES)
  if not selected then fail(reason); return false end
  if type(selected.pathline)~="table" then
    fail("configured FlightPath registry entry is not a PATHLINE: "..tostring(selected.name))
    return false
  end
  state.flightPathName=selected.name
  state.flightPath=selected.pathline
  msg("ROUTE",string.format("configured FlightPath selected: %s offset=%s %dm",selected.name,selected.offset.side,selected.offset.meters),10)
  return true
end

local function prepareAirwing()
  local air=OMW and OMW.AirOps and OMW.AirOps.Jalalabad or nil
  if type(air)~="table" or air.Status~="RUNNING" or not air.Airwing then
    fail("Jalalabad AIRWING foundation is not RUNNING")
    return false
  end
  if not air.Squadrons or not air.Squadrons.AH64D then
    fail("Jalalabad AH-64D squadron unavailable")
    return false
  end
  if not PATHLINE:FindByName(WEST_PATHLINE) then
    fail("required WEST PATHLINE unavailable")
    return false
  end
  state.airwing=air.Airwing
  state.ah64d=air.Squadrons.AH64D
  return true
end

local function logCorridorProfiles(installed)
  if not installed or not installed.waypointProfiles then return end
  for direction,profiles in pairs(installed.waypointProfiles) do
    for index,profile in ipairs(profiles) do
      log(string.format("CAS_ROUTE_PROFILE direction=%s index=%d uid=%s pathline=%s altitudeFtAgl=%s altType=%s",
        tostring(direction),index,tostring(profile.uid),tostring(profile.pathlineName),tostring(profile.altitudeFtAgl),tostring(profile.altType)))
    end
  end
end

local function bindCasMissionOwnedCorridor(flight, mission)
  local installed,ok,reason=MissionOwnedCorridor.Bind(flight,mission,state.casResolved,{
    defaultAltitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL,
    onInstalled=function(result)
      state.casCorridor=true
      logCorridorProfiles(result)
      msg("CAS","One-shot route installed: "..routeLabel(casPathlineNames()).." -> CAS -> reverse -> Jalalabad",12)
    end,
    onFailed=function(why)
      fail("CAS mission-owned corridor failed: "..tostring(why))
    end,
  })
  if ok then
    state.casCorridor=true
    logCorridorProfiles(installed)
  elseif reason~="MISSION_ROUTE_UIDS_NOT_READY" then
    fail("CAS mission-owned corridor failed: "..tostring(reason))
  end
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
      if inZone and inRange and rightType then
        result[#result+1]=group
      end
    end
  end

  table.sort(result,function(a,b) return a:GetName()<b:GetName() end)
  return result,detectedTotal
end

local function releaseCasBySupportedElement(reason)
  if state.casClosed or state.failed or not state.casDemand then return false end
  if not state.casSupportRequirementActive then return false end
  if not state.honakerNoKnownAttackers then return false end
  if not state.casOnStation or not state.casNoContactReported then return false end

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
  if closed~=true then
    fail("CAS supported-element release failed: "..tostring(why))
    return false
  end

  state.casSupportRequirementActive=false
  state.casReleaseRequested=true
  state.casReleaseReason=reason
  state.casClosed=true
  msg("CAS","Honaker/control explicitly released CAS after HONAKER_NO_KNOWN_ATTACKERS + CAS_NO_CONTACT; recovery route remains MOOSE/OMW-owned",15)
  return true
end

local function updateCasSupportState()
  if state.failed or state.casClosed or not state.casExecuting or not state.casFlight or not state.casTacticalZone then return end

  local flightCoord=state.casFlight:GetCoordinate()
  if not flightCoord then return end
  local physicallyInside=state.casTacticalZone:IsCoordinateInZone(flightCoord)
  if physicallyInside and not state.casOnStation then
    state.casOnStation=true
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
      log(string.format("CAS_SENSOR_REPORT onStation=true detectedTotal=%d eligible=%d names=%s source=FLIGHTGROUP_GetDetectedGroups",
        detectedTotal,count,table.concat(names,",")))
      msg("CAS",string.format("AH-64D reports %d relevant detected RED ground group(s) in current task envelope; CAS requirement remains ACTIVE",count),10)
    else
      state.casNoContactReported=true
      log(string.format("CAS_SENSOR_REPORT onStation=true detectedTotal=%d eligible=0 names= source=FLIGHTGROUP_GetDetectedGroups",detectedTotal))
      msg("CAS","AH-64D reports NO CONTACT in current task envelope; this report alone does not end CAS",10)
    end
  end

  if state.honakerNoKnownAttackers and count==0 and state.casNoContactReported then
    releaseCasBySupportedElement("SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT")
  end
end

local function closeHonakerIncidentIfClear()
  if state.attackIncidentClosed then return true end
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

local function installCasShotObserver()
  if state.casShotObserver then return end
  state.casShotObserver=EVENTHANDLER:New()
  state.casShotObserver:HandleEvent(EVENTS.Shot)
  function state.casShotObserver:OnEventShot(EventData)
    if state.failed or state.casFired or not state.casFlight or not state.casDemand then return end
    if not EventData or EventData.IniGroupName~=state.casFlight:GetName() then return end
    state.casFired=true
    local weaponType=EventData.WeaponTypeName or (EventData.Weapon and EventData.Weapon.getTypeName and EventData.Weapon:getTypeName()) or "unknown"
    local _,confirmed,reason=state.casAdapter:ConfirmExecutionEvidence(state.casDemand.id,{event="SHOT",weaponType=weaponType})
    if confirmed~=true and reason~="EVIDENCE_ALREADY_CONFIRMED" then
      fail("CAS shot evidence could not be correlated: "..tostring(reason))
      return
    end
    msg("CAS","AH-64D weapon employment confirmed: "..tostring(weaponType).."; weapon use does not itself terminate CAS",12)
  end
end

local function ensureCasContext()
  if state.casAdapter and state.casTacticalZone and state.casResolved then return true end
  if not state.airwing or not state.ah64d then fail("Jalalabad AIRWING/AH64D unavailable") return false end

  local landHeightM=state.honakerCoord:GetLandHeight()
  state.casAltitudeFtAsl=UTILS.MetersToFeet(landHeightM)+CAS_COMBAT_HEIGHT_FT_AGL
  state.casTacticalZone=ZONE_RADIUS:New("OMW_TACTICAL_BLUE_GROUND_COP_HONAKER_STAGE3_CAS_FOCUSED",state.honakerCoord:GetVec2(),UTILS.NMToMeters(CAS_TACTICAL_RADIUS_NM))
  if not state.casTacticalZone then fail("MOOSE CAS tactical ZONE_RADIUS creation failed") return false end

  local pathlineNames=casPathlineNames()
  state.casResolved=HelicopterCorridor.ResolveSequence({
    pathlineNames=pathlineNames,
    pathlines={state.flightPath},
    originCoordinate=state.airwing:GetCoordinate(),
    destinationCoordinate=state.casTacticalZone:GetCoordinate(),
    maxJunctionDistanceM=JUNCTION_MAX_DISTANCE_M,
    offsetMode=HelicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
    segmentProfiles={
      {altitudeFtAgl=PRIMARY_ALTITUDE_FT_AGL},
      {altitudeFtAgl=WEST_ALTITUDE_FT_AGL,formation=ENUMS.Formation.RotaryWing.Column.D70},
    },
  })

  state.casAdapter=CasAdapter.New({
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
      mission:SetName("OMW_STAGE3_HONAKER_CAS_SUPPORT_FOCUSED")
      state.casLifecycle=MissionOwnedCorridor.ConfigureMission(mission,state.casResolved,{
        speedKts=CAS_SPEED_KTS,
        defaultAltitudeFtAgl=CAS_COMBAT_HEIGHT_FT_AGL,
      })
    end,
  })
  return state.casAdapter~=nil
end

local function installAirwingObserver()
  if state.airwing.__omwStage3CasSupportFocusedObserver then return end
  state.airwing.__omwStage3CasSupportFocusedObserver=true

  local previousFlight=state.airwing.OnAfterFlightOnMission
  function state.airwing:OnAfterFlightOnMission(From,Event,To,FlightGroup,Mission)
    if previousFlight then previousFlight(self,From,Event,To,FlightGroup,Mission) end
    if Mission~=state.casMission then return end
    state.casFlight=FlightGroup
    installCasShotObserver()

    local previousEngage=FlightGroup.OnAfterEngageTarget
    function FlightGroup:OnAfterEngageTarget(F,E,T,Target,Speed,Formation)
      if previousEngage then previousEngage(self,F,E,T,Target,Speed,Formation) end
      state.casEngaged=true
      local targetName=Target and type(Target.GetName)=="function" and Target:GetName() or "unknown"
      log("CAS_ENGAGE_EVENT target="..tostring(targetName).." source=MOOSE_FLIGHTGROUP_OnAfterEngageTarget")
      msg("CAS","MOOSE FLIGHTGROUP engaging detected target "..tostring(targetName),10)
    end

    local previousLanded=FlightGroup.OnAfterLanded
    function FlightGroup:OnAfterLanded(F,E,T,Airbase)
      if previousLanded then previousLanded(self,F,E,T,Airbase) end
      if state.casClosed and Airbase and Airbase:GetName()==state.airwing:GetAirbaseName() then
        state.casHomeLanded=true
        msg("CAS","AH-64D landed back at Jalalabad after supported-element release",10)
      end
    end

    bindCasMissionOwnedCorridor(FlightGroup,Mission)
    msg("CAS","Jalalabad AH-64D assigned to MOOSE PATROLZONE + SetEngageDetected; CAS own detection telemetry armed",12)
  end
end

local function dispatchCas(demand)
  if not ensureCasContext() then return false end
  local mission,ok,reason=state.casAdapter:Dispatch(demand,state.casTacticalZone)
  if ok~=true then fail("CAS dispatch failed: "..tostring(reason)); return false end
  state.casMission=mission
  state.casSupportRequirementActive=true

  local previousExecuting=mission.OnAfterExecuting
  function mission:OnAfterExecuting(F,E,T)
    if previousExecuting then previousExecuting(self,F,E,T) end
    state.casExecuting=true
    msg("CAS",string.format("PATROLZONE + SetEngageDetected executing; tacticalRadius=%dNM engageRange=%dNM altitude=%.0fft ASL",
      CAS_TACTICAL_RADIUS_NM,CAS_ENGAGE_RANGE_NM,state.casAltitudeFtAsl),12)
  end
  return true
end

local function setupThreat()
  state.attackIncident=IncidentCoordinator.New({
    installationId=INSTALLATION_ID,
    incidentIdFactory=function(_,seq) return "INC-STAGE3-HONAKER-CAS-"..seq end,
  })

  state.threat=ThreatAdapter.New({
    missionDemand=MissionDemand,
    registry=registry,
    policy={
      CreateDemand=function(md,reg,incident)
        if state.casDemand then return state.casDemand,false,"ACTIVE_CAS_SUPPORT_REQUIREMENT" end
        local demand,created,reason=CasPolicy.CreateDemand(md,reg,incident)
        if created then
          state.casDemand=demand
          if not dispatchCas(demand) then return demand,created,"CAS_DISPATCH_FAILED" end
        end
        return demand,created,reason
      end,
    },
    anchorCoordinate=state.honakerCoord,
    installationId=INSTALLATION_ID,
    zoneName="OMW_SECURITY_BLUE_GROUND_COP_HONAKER_STAGE3_CAS_FOCUSED",
    priority=90,
    radiusM=SECURITY_RADIUS_M,
    blueCoalition=coalition.side.BLUE,
    redCoalition=coalition.side.RED,
    updateSeconds=5,
    captureThreatlevel=0,
    captureNunits=1,
    incidentIdFactory=function(_,seq) return "INC-STAGE3-HONAKER-CAS-"..seq end,
    onThreatEvaluated=function(_,opsZone)
      if not state.threatStarted or not state.attackIncident:GetActive() then return end
      local added=state.attackIncident:AddParticipants(redGroups(opsZone))
      if added>0 then
        log(string.format("HONAKER_LOCAL_PICTURE incidentId=%s added=%d alive=%d authority=HONAKER_ONLY",
          tostring(state.attackIncident:GetActive().incidentId),added,#state.attackIncident:GetParticipants(true)))
      end
    end,
    onThreatStarted=function(_,opsZone,demand,created,reason,incident)
      if state.threatStarted then return end
      local active,incidentCreated,incidentReason=state.attackIncident:ReportEvidence({
        installationId=INSTALLATION_ID,
        evidenceType="PROXIMITY_INTRUSION",
        participantGroups=redGroups(opsZone),
      })
      if incidentCreated~=true or not active then fail("Honaker local attack incident creation failed: "..tostring(incidentReason)); return end
      if active.incidentId~=incident.incidentId then fail("Honaker attack incident ID mismatch"); return end
      state.threatStarted=true
      msg("HONAKER",string.format("Attack detected; local incident=%s knownParticipants=%d. CAS support requirement created independently.",
        tostring(active.incidentId),#state.attackIncident:GetParticipants(true)),12)
    end,
    onThreatCleared=function()
      state.perimeterClear=true
      msg("HONAKER","1000-m alarm perimeter clear. This diagnostic/local alarm transition has NO CAS release authority.",12)
    end,
  })

  state.threat:Start()
  msg("READY","Focused Honaker CAS test armed. Guard/QRF/ARTY/logistics are intentionally not dispatched by this LUA.",15)
end

local function statusTick()
  if state.failed or state.passed then return end

  closeHonakerIncidentIfClear()
  updateCasSupportState()

  if timer.getTime()-state.startedAt>MAX_RUNTIME_SEC then
    fail(string.format("CAS focused acceptance timeout: threat=%s executing=%s onStation=%s detectedEligible=%s engaged=%s fired=%s honakerNoKnown=%s released=%s landed=%s",
      tostring(state.threatStarted),tostring(state.casExecuting),tostring(state.casOnStation),tostring(state.casDetectedEligibleCount),
      tostring(state.casEngaged),tostring(state.casFired),tostring(state.honakerNoKnownAttackers),tostring(state.casClosed),tostring(state.casHomeLanded)))
    return
  end

  if not state.casClosed then return end
  local demand=state.casDemand and registry:Get(state.casDemand.id) or nil
  if not demand or demand.status~=MissionDemand.Status.SUCCESS then return end
  if not state.casCorridor then return end

  local validExecution=state.casFired or state.casNoContactReported
  if not validExecution then return end

  state.passed=true
  stopScheduler()
  msg("PASS",string.format("CAS lifecycle reconciled: onStation=%s contactReported=%s engaged=%s fired=%s noContact=%s releaseReason=%s. Ground alarm/incident counts did not directly close CAS.",
    tostring(state.casOnStation),tostring(state.casContactReported),tostring(state.casEngaged),tostring(state.casFired),
    tostring(state.casNoContactReported),tostring(state.casReleaseReason)),25)
end

local function start()
  if OMW_GROUND_READY~=1 then fail("Ground Base not ready") return end
  local brigade=BRIGADE:New(HONAKER_WAREHOUSE,"BDE_BLUE_GND_HONAKER_STAGE3_CAS_FOCUSED_ANCHOR")
  state.honakerCoord=brigade:GetCoordinate()
  if not state.honakerCoord then fail("Honaker coordinate unavailable") return end
  if not resolveConfiguredFlightPath() then return end
  if not prepareAirwing() then return end
  installAirwingObserver()
  setupThreat()
  state.statusScheduler=SCHEDULER:New(nil,statusTick,{},STATUS_INTERVAL_SEC,STATUS_INTERVAL_SEC)
end

SCHEDULER:New(nil,start,{},2)
