local Bridge = dofile("scripts/campaign/OMW_FireSupStratResupply_PerimeterBridge.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end
local function assertFalse(value, label) if value ~= false then error(label .. " expected=false actual=" .. tostring(value)) end end

local calls = { open=0, support=0, close=0 }
local fakeBase = {}
function fakeBase:OpenIncident(spec)
  calls.open=calls.open+1
  calls.openSpec=spec
  return { incidentId="INC|"..spec.siteId.."|"..spec.incidentKey, siteId=spec.siteId }, true, nil
end
function fakeBase:RequestIncidentSupport(incidentId, supportType, spec)
  calls.support=calls.support+1
  calls.supportIncidentId=incidentId
  calls.supportType=supportType
  calls.supportSpec=spec
  return { demandId="QRF-1", supportType=supportType }, true, nil
end
function fakeBase:CloseIncident()
  calls.close=calls.close+1
  error("perimeter clear must not close incident")
end

local registry = {
  Sites = {
    COP_FORTRESS = {
      siteId="COP_FORTRESS",
      installationId="BLUE_GROUND_COP_FORTRESS",
    },
  },
}

local logs = {}
local bridge = Bridge.New({base=fakeBase, siteRegistry=registry, logger=function(line) logs[#logs+1]=line end})
assertEqual(Bridge.SchemaVersion, "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-1", "schema")

local incident = {
  incidentId="FOB-THREAT|BLUE_GROUND_COP_FORTRESS|1",
  installationId="BLUE_GROUND_COP_FORTRESS",
  priority=90,
  position={x=1,y=2,z=3},
  reportedTarget={evidence="OPSZONE_ATTACKED",radiusM=1000},
}
local opened, created, reason, qrf = bridge:HandleThreat(nil, nil, incident)
assertTrue(created, "incident opened")
assertEqual(reason, nil, "bridge reason")
assertEqual(opened.siteId, "COP_FORTRESS", "installation maps to site")
assertEqual(calls.open, 1, "one incident open")
assertEqual(calls.openSpec.incidentKey, incident.incidentId, "source incident key")
assertEqual(calls.openSpec.context.source, "OPSZONE_SECURITY_PERIMETER", "incident source")
assertEqual(calls.support, 1, "one support request")
assertEqual(calls.supportType, "QRF", "initial perimeter support is QRF only")
assertEqual(calls.supportSpec.requestKey, "PERIMETER_INITIAL_QRF", "QRF request key")
assertEqual(calls.supportSpec.context.activation, "INCIDENT_LOCAL_DEFENSE", "QRF activation")
assertEqual(qrf.supportType, "QRF", "QRF result")
assertTrue(#logs > 0, "bridge logs")

local cleared, closed, clearReason = bridge:HandleClear(nil, nil, 1, incident)
assertEqual(cleared, incident, "clear returns source incident")
assertFalse(closed, "clear does not close incident")
assertEqual(clearReason, "PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT", "clear semantics")
assertEqual(calls.close, 0, "base close never called")

local missing, missingCreated, missingReason = bridge:HandleThreat(nil, nil, {
  incidentId="FOB-THREAT|UNKNOWN|1", installationId="UNKNOWN", priority=1,
})
assertEqual(missing, nil, "unknown installation result")
assertFalse(missingCreated, "unknown installation not opened")
assertEqual(missingReason, "INSTALLATION_NOT_REGISTERED", "unknown installation reason")

print("PASS test_fire_support_strategic_resupply_perimeter_bridge")
