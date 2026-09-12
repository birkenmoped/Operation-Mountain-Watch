local Bridge = dofile("scripts/campaign/OMW_FireSupStratResupply_PerimeterBridge.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end
local function assertFalse(value, label) if value ~= false then error(label .. " expected=false actual=" .. tostring(value)) end end

local calls={evidence=0,close=0}
local incidentRuntime={}
function incidentRuntime:ReportEvidence(evidence)
  calls.evidence=calls.evidence+1
  calls.evidenceSpec=evidence
  return {incidentId="INSTALLATION-ATTACK|BLUE_GROUND_COP_FORTRESS|1",installationId=evidence.installationId},true,nil
end
function incidentRuntime:CloseInstallationIncident()
  calls.close=calls.close+1
  error("perimeter clear must not close authoritative incident")
end

local registry={Sites={COP_FORTRESS={siteId="COP_FORTRESS",installationId="BLUE_GROUND_COP_FORTRESS"}}}
local logs={}
local bridge=Bridge.New({incidentRuntime=incidentRuntime,siteRegistry=registry,logger=function(line) logs[#logs+1]=line end})
assertEqual(Bridge.SchemaVersion,"OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-2","schema")

local source={
  incidentId="FOB-THREAT|BLUE_GROUND_COP_FORTRESS|1",
  installationId="BLUE_GROUND_COP_FORTRESS",
  priority=90,
  position={x=1,y=2,z=3},
  reportedTarget={evidence="OPSZONE_ATTACKED",radiusM=1000},
}
local incident,created,reason,evidence=bridge:HandleThreat(nil,nil,source)
assertTrue(created,"proximity evidence opens authoritative incident")
assertEqual(reason,nil,"bridge reason")
assertEqual(calls.evidence,1,"one evidence report")
assertEqual(calls.evidenceSpec.installationId,"BLUE_GROUND_COP_FORTRESS","installation preserved")
assertEqual(calls.evidenceSpec.evidenceType,"PROXIMITY_INTRUSION","domain evidence type")
assertEqual(calls.evidenceSpec.sourceEvent,"OPSZONE_Attacked","MOOSE source retained")
assertEqual(calls.evidenceSpec.sourceIncidentId,source.incidentId,"raw perimeter correlation retained")
assertEqual(evidence,calls.evidenceSpec,"evidence returned")
assertEqual(incident.installationId,"BLUE_GROUND_COP_FORTRESS","authoritative incident returned")
assertTrue(#logs>0,"bridge logs")

local cleared,closed,clearReason=bridge:HandleClear(nil,nil,1,source)
assertEqual(cleared,source,"clear returns source perimeter incident")
assertFalse(closed,"clear does not close incident")
assertEqual(clearReason,"PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT","clear semantics")
assertEqual(calls.close,0,"authoritative close never called by perimeter")

local missing,missingCreated,missingReason=bridge:HandleThreat(nil,nil,{incidentId="FOB-THREAT|UNKNOWN|1",installationId="UNKNOWN",priority=1})
assertEqual(missing,nil,"unknown installation result")
assertFalse(missingCreated,"unknown installation not reported")
assertEqual(missingReason,"INSTALLATION_NOT_REGISTERED","unknown installation reason")

print("PASS test_fire_support_strategic_resupply_perimeter_bridge")
