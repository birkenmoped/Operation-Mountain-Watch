local ThreatAdapter = dofile("scripts/ground/OMW_FobThreatOpsZoneAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end
local function assertFalse(value, label) if value ~= false then error(label .. " expected=false actual=" .. tostring(value)) end end

local previousObject, previousUnit = Object, Unit
Object = { Category = { UNIT = 1 } }
Unit = { Category = { GROUND_UNIT = 2 } }

local anchor = {}
function anchor:GetVec2() return {x=100,y=200} end
function anchor:GetVec3() return {x=100,y=300,z=200} end

local ops = {UpdateSeconds=120}
for _,name in ipairs({"SetObjectCategories","SetUnitCategories","SetCaptureThreatlevel","SetCaptureNunits","SetDrawZone","SetMarkZone"}) do
  ops[name]=function(self, value) self[name.."Value"]=value return self end
end
function ops:GetScannedGroupSet() return {} end
function ops:Start() self.started=true return self end
function ops:Stop() self.stopped=true return self end
function ops:I(_) return self end

local handlerCalls, startedCalls, clearedCalls = 0, 0, 0
local adapter = ThreatAdapter.New({
  anchorCoordinate=anchor,
  installationId="BLUE_GROUND_COP_FORTRESS",
  zoneName="OMW_SECURITY_BLUE_GROUND_COP_FORTRESS",
  priority=90,
  radiusM=1000,
  blueCoalition=2,
  redCoalition=1,
  zoneRadiusFactory=function(name,vec2,radius) return {name=name,vec2=vec2,radius=radius} end,
  opsZoneFactory=function() return ops end,
  incidentIdFactory=function(_,sequence) return "RAW|"..tostring(sequence) end,
  threatHandler=function(_,_,incident)
    handlerCalls=handlerCalls+1
    return {incidentId="BASE|"..incident.incidentId}, true, nil
  end,
  onThreatStarted=function(_,_,result,created,reason,incident)
    startedCalls=startedCalls+1
    assertTrue(created, "raw start created")
    assertEqual(reason,nil,"raw start reason")
    assertEqual(result.incidentId,"BASE|"..incident.incidentId,"raw result correlation")
  end,
  onThreatCleared=function(_,_,coalition,incident)
    clearedCalls=clearedCalls+1
    assertEqual(coalition,1,"raw clear coalition")
    assertEqual(incident.incidentId,"RAW|1","raw clear incident")
  end,
})

assertEqual(ThreatAdapter.SchemaVersion,"OMW-FOB-THREAT-OPSZONE-ADAPTER-4","schema")
local _, started = adapter:Start(); assertTrue(started,"raw adapter starts")

ops:OnAfterAttacked("Guarded","Attacked","Attacked",1)
assertEqual(handlerCalls,1,"first attack handled once")
assertEqual(startedCalls,1,"first attack callback once")
local result, created, reason, incident = adapter:ProcessThreat(1)
assertEqual(result.incidentId,"BASE|RAW|1","active result reused")
assertFalse(created,"active incident not recreated")
assertEqual(reason,"ACTIVE_INCIDENT","active incident reason")
assertEqual(incident.incidentId,"RAW|1","active source incident reused")
assertEqual(handlerCalls,1,"active attack does not call handler twice")

ops:OnAfterDefeated("Attacked","Defeated","Guarded",1)
assertEqual(clearedCalls,1,"raw clear callback")
local nextResult, nextCreated, nextReason, nextIncident = adapter:ProcessThreat(1)
assertTrue(nextCreated,"new attack after defeat can open")
assertEqual(nextReason,nil,"new attack reason")
assertEqual(nextResult.incidentId,"BASE|RAW|2","new result after defeat")
assertEqual(nextIncident.incidentId,"RAW|2","new source incident after defeat")
assertEqual(handlerCalls,2,"handler called for new attack")

Object, Unit = previousObject, previousUnit
print("PASS test_fob_threat_opszone_raw_incident")
