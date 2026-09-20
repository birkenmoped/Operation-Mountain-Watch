local function loadModule(path)
  return assert(loadfile(path))()
end

local function eq(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)), 2)
  end
end

local now = 100
timer = { getAbsTime=function() return now end }

coalition = { side={ RED=1, BLUE=2 } }

UTILS = {
  NMToMeters=function(value) return value * 1852 end,
}

SCHEDULER = {}
function SCHEDULER:New(_, callback, _, _, _)
  return {
    callback=callback,
    Stop=function(self) self.stopped=true end,
  }
end

local pathlineWest={name="OMW_FlightPath_WEST"}
PATHLINE = {}
function PATHLINE:FindByName(name)
  if name=="OMW_FlightPath_WEST" then return pathlineWest end
  return nil
end

local Runtime=loadModule("scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua")

local evidence={}
local function record(fields)
  evidence[#evidence+1]=fields
end

local function hasEvent(name)
  for _,item in ipairs(evidence) do
    if item.event==name then return item end
  end
  return nil
end

local primaryPathline={name="OMW_FlightPath_R500"}
local flightPathNameContract={}
function flightPathNameContract.SelectFromRegistry(baseName,registry)
  eq(baseName,"OMW_FlightPath","pathline base")
  eq(registry.primary,primaryPathline,"pathline registry")
  return {name="OMW_FlightPath_R500",pathline=primaryPathline},nil
end

local helicopterCorridor={OffsetMode={PATHLINE_SUFFIX="PATHLINE_SUFFIX"}}
function helicopterCorridor.ResolveSequence(spec)
  eq(spec.pathlineNames[1],"OMW_FlightPath_R500","resolved primary name")
  eq(spec.pathlineNames[2],"OMW_FlightPath_WEST","resolved west name")
  return {
    outbound={spec.originCoordinate,{name="WEST"},spec.destinationCoordinate},
    returnRoute={spec.destinationCoordinate,{name="WEST"},spec.originCoordinate},
  }
end

local tacticalCorridor={}
function tacticalCorridor.PlanRouteGated(spec)
  return {
    missionIngressCoordinate={name="INGRESS"},
    missionEgressCoordinate={name="EGRESS"},
    outboundRoute=spec.outboundRoute,
    returnRoute=spec.returnRoute,
  }
end
function tacticalCorridor.ConfigureMission(mission,geometry)
  mission.configuredGeometry=geometry
end
function tacticalCorridor.Bind(flight,mission,geometry,callbacks)
  flight.boundGeometry=geometry
  callbacks.onInstalled({missionUid=10,ingressUid=20,egressUid=30,waypointProfiles={1,2,3}})
  return {},{},true,nil
end

local detectedSet={}
local detected={}
function detected:GetSet() return detectedSet end

local zone={}
function zone:GetCoordinate() return {name="AO"} end
function zone:IsCoordinateInZone(_) return true end

local flightCoord={}
function flightCoord:Get3DDistance(_) return 100 end

local group={
  alive=2,
  CountAliveUnits=function(self) return self.alive end,
}

local flight={
  name="CAS-FLIGHT",
  GetName=function(self) return self.name end,
  GetGroup=function() return group end,
  GetCoordinate=function() return flightCoord end,
  GetDetectedGroups=function() return detected end,
  GetWaypointIndex=function() return 1 end,
  GetWaypointUIDFromIndex=function() return 10 end,
  AddWaypoint=function() end,
  UpdateRoute=function() end,
}

local homeAirbase={GetName=function() return "Jalalabad" end}
local legion={
  alias="AW_US_JBAD_TF_SHOOTER_6_6_CAV",
  GetCoordinate=function() return {name="HOME"} end,
  GetAirbase=function() return homeAirbase end,
}

local asset={uid=77,squadname="SQ_US_JBAD_AH64D_B_1_10_AVN",spawngroupname="CAS-FLIGHT"}

local mission={
  name="OMW_TEST_CAS",
  executing=false,
  assets={asset},
  _omwFssrCasGeometry={
    zone=zone,
    engageDetectedRangeNm=5,
  },
}
function mission:GetName() return self.name end
function mission:IsExecuting() return self.executing end

local cancelCount=0
local handle={runtime=mission,cancelRequested=false}
function handle:Cancel(reason)
  if self.cancelRequested then return false end
  self.cancelRequested=true
  self.reason=reason
  cancelCount=cancelCount+1
  return true
end

local innerAdapter={}
function innerAdapter:Dispatch(demand,context)
  return handle,true,nil
end

local commander={}
local runtime=Runtime.New({
  innerAdapter=innerAdapter,
  commander=commander,
  flightPathNameContract=flightPathNameContract,
  helicopterCorridor=helicopterCorridor,
  casTacticalCorridor=tacticalCorridor,
  executionProfiles={
    AW_US_JBAD_TF_SHOOTER_6_6_CAV={
      pathlineBase="OMW_FlightPath",
      pathlineNames={"OMW_FlightPath","OMW_FlightPath_WEST"},
      segmentProfiles={{altitudeFtAgl=500},{altitudeFtAgl=2500}},
      transitAltitudeFtAgl=2500,
      missionAltitudeFtAgl=2500,
      speedKts=125,
      routeGateDistanceNm=3.5,
    },
  },
  pathlineRegistry={primary=primaryPathline},
  noContactStableSec=30,
  updateSeconds=5,
  redCoalition=coalition.side.RED,
  isSupportedElementClear=function() return true,nil end,
  onEvidence=record,
  logger=function() end,
})

local demand={demandId="D-CAS-1",siteId="FOB_JOYCE"}
local context={incident={context={}}}
local returned,created=runtime:Dispatch(demand,context)
eq(returned,handle,"dispatch handle")
eq(created,true,"dispatch created")
eq(hasEvent("CAS_LIFECYCLE_REGISTERED")~=nil,true,"registered evidence")

local allow=commander:OnBeforeMissionAssign("*","MissionAssign","*",mission,{legion})
eq(allow,true,"mission assign allowed")
eq(mission.configuredGeometry~=nil,true,"mission owner route configured")
eq(hasEvent("CAS_PROVIDER_PROFILE_BOUND")~=nil,true,"provider profile evidence")

commander:OnAfterMissionAssign("*","MissionAssign","*",mission,{legion})
eq(hasEvent("CAS_MISSION_ASSIGNED").squadron,"SQ_US_JBAD_AH64D_B_1_10_AVN","selected squadron evidence")

commander:OnAfterOpsOnMission("*","OpsOnMission","*",flight,mission)
eq(flight.boundGeometry~=nil,true,"flight corridor bound")
eq(hasEvent("CAS_OWNER_CORRIDOR_INSTALLED")~=nil,true,"corridor evidence")

mission.executing=true
runtime:_updateAll()
eq(hasEvent("CAS_EXECUTING")~=nil,true,"executing evidence")
eq(cancelCount,0,"no early cancel")

now=129
runtime:_updateAll()
eq(cancelCount,0,"no cancel before stable window")

now=131
runtime:_updateAll()
eq(cancelCount,1,"controlled release after stable no contact")
eq(handle.reason,"SUPPORTED_ELEMENT_RELEASE_NO_CONTACT","release reason")
eq(hasEvent("CAS_CONTROLLED_RELEASE")~=nil,true,"release evidence")

flight:OnAfterFuelLow("*","FuelLow","*")
eq(hasEvent("CAS_FUEL_LOW").beforeRelease,false,"fuel low after release is not pre-release failure")

flight:OnAfterLanded("*","Landed","*",homeAirbase)
eq(hasEvent("CAS_HOME_LANDED").airport,"Jalalabad","home landing evidence")

legion:OnAfterLegionAssetReturned("*","LegionAssetReturned","*",{name="AH64"},asset)
runtime:_updateAll()
eq(hasEvent("CAS_LEGION_ASSET_RETURNED")~=nil,true,"asset returned evidence")
eq(hasEvent("CAS_LIFECYCLE_COMPLETE")~=nil,true,"lifecycle complete evidence")
eq(runtime:GetState("D-CAS-1").completed,true,"lifecycle completed")

-- Unknown provider is fail-closed before physical dispatch assignment.
local mission2={
  name="OMW_TEST_CAS_2",
  assets={{uid=88,squadname="OTHER",spawngroupname="OTHER"}},
  _omwFssrCasGeometry={zone=zone,engageDetectedRangeNm=5},
  GetName=function(self) return self.name end,
  IsExecuting=function() return false end,
}
local handle2={runtime=mission2,Cancel=function() return true end}
innerAdapter.Dispatch=function() return handle2,true,nil end
runtime:Dispatch({demandId="D-CAS-2",siteId="FOB_JOYCE"},context)
local unsupported={alias="AW_UNSUPPORTED",GetCoordinate=function() return {name="X"} end,GetAirbase=function() return homeAirbase end}
local allowed2=commander:OnBeforeMissionAssign("*","MissionAssign","*",mission2,{unsupported})
eq(allowed2,false,"unsupported provider rejected")
eq(runtime:GetState("D-CAS-2").failed,true,"unsupported provider state failed")
eq(hasEvent("CAS_PROVIDER_PROFILE_REJECTED")~=nil,true,"unsupported provider evidence")

print("PASS fire support CAS lifecycle runtime")
