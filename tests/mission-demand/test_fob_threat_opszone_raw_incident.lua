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

local redGroup={alive=true,coalition=1}
function redGroup:IsAlive() return self.alive end
function redGroup:GetCoalition() return self.coalition end
local scanned={objects={}}
function scanned:GetSetObjects() return self.objects end
local ops = {UpdateSeconds=120}
for _,name in ipairs({"SetObjectCategories","SetUnitCategories","SetCaptureThreatlevel","SetCaptureNunits","SetDrawZone","SetMarkZone"}) do
  ops[name]=function(self, value) self[name.."Value"]=value return self end
end
function ops:GetScannedGroupSet() return scanned end
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
    assertEqual(incident.incidentId,"RAW|"..tostring(clearedCalls),"raw clear incident")
  end,
})

assertEqual(ThreatAdapter.SchemaVersion,"OMW-FOB-THREAT-OPSZONE-ADAPTER-6","schema")
local _, started = adapter:Start(); assertTrue(started,"raw adapter starts")

-- No permanent BLUE defender is required. MOOSE OPSZONE Evaluated provides the
-- scanned set and RED presence itself is the installation alarm stimulus.
scanned.objects={redGroup}
ops:OnAfterEvaluated("Empty","Evaluated","Captured")
assertEqual(handlerCalls,1,"first RED presence handled once")
assertEqual(startedCalls,1,"first RED presence callback once")
local result, created, reason, incident = adapter:ProcessThreat(1)
assertEqual(result.incidentId,"BASE|RAW|1","active result reused")
assertFalse(created,"active incident not recreated")
assertEqual(reason,"ACTIVE_INCIDENT","active incident reason")
assertEqual(incident.incidentId,"RAW|1","active source incident reused")
assertEqual(handlerCalls,1,"active presence does not call handler twice")

-- Native Attacked may also happen when a BLUE group is present; it remains an
-- idempotent fast path and must not create a second strategic incident.
ops:OnAfterAttacked("Guarded","Attacked","Attacked",1)
assertEqual(handlerCalls,1,"Attacked callback does not duplicate active incident")
assertEqual(startedCalls,1,"Attacked callback does not duplicate start callback")

scanned.objects={}
ops:OnAfterEvaluated("Captured","Evaluated","Empty")
assertEqual(clearedCalls,1,"RED absence clears adapter-local intrusion state")

scanned.objects={redGroup}
ops:OnAfterEvaluated("Empty","Evaluated","Captured")
assertEqual(handlerCalls,2,"new RED entry after clear can open")
assertEqual(startedCalls,2,"new RED entry callback")
assertEqual(adapter.activeIncident.incidentId,"RAW|2","new source incident after clear")

ops:OnAfterDefeated("Attacked","Defeated","Guarded",1)
assertEqual(clearedCalls,2,"native Defeated also clears active RED intrusion")

Object, Unit = previousObject, previousUnit
print("PASS test_fob_threat_opszone_raw_incident")