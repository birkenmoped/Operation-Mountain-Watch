local Incident = dofile("scripts/ground/OMW_GroundInstallationAttackIncident.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end
local function assertFalse(value, label) if value ~= false then error(label .. " expected=false actual=" .. tostring(value)) end end

local function group(name, alive)
  local value={name=name,alive=alive}
  function value:GetName() return self.name end
  function value:IsAlive() return self.alive end
  return value
end

local redA=group("RED-A",true)
local redB=group("RED-B",true)
local starts, updates, closes = 0,0,0
local coordinator=Incident.New({
  installationId="BLUE_GROUND_COP_HONAKER_MIRACLE",
  incidentIdFactory=function(_,sequence) return "INC-HONAKER-"..sequence end,
  onIncidentStarted=function() starts=starts+1 end,
  onIncidentUpdated=function() updates=updates+1 end,
  onIncidentClosed=function() closes=closes+1 end,
})

local first,created,reason=coordinator:ReportEvidence({
  installationId="BLUE_GROUND_COP_HONAKER_MIRACLE",
  evidenceType="PROXIMITY_INTRUSION",
  participantGroups={redA,redB},
})
assertTrue(created,"first evidence creates incident")
assertEqual(reason,nil,"first reason")
assertEqual(first.incidentId,"INC-HONAKER-1","first incident id")
assertEqual(starts,1,"one incident start")
assertEqual(#coordinator:GetParticipants(true),2,"two initial participants")

local second,secondCreated,secondReason=coordinator:ReportEvidence({
  installationId="BLUE_GROUND_COP_HONAKER_MIRACLE",
  evidenceType="DIRECT_FIRE_ATTACK",
  initiatorGroup=redA,
})
assertEqual(second,first,"second evidence refreshes same incident")
assertFalse(secondCreated,"second evidence creates no incident")
assertEqual(secondReason,"ACTIVE_INCIDENT_REFRESHED","refresh reason")
assertEqual(first.evidenceCount,2,"two evidence items")
assertEqual(#coordinator:GetParticipants(true),2,"participant dedupe")
assertEqual(updates,1,"one incident update")

redA.alive=false
assertEqual(#coordinator:GetParticipants(true),1,"dead participant excluded from alive set")
assertTrue(coordinator:HasAliveParticipants(),"one attacker remains alive")
redB.alive=false
assertFalse(coordinator:HasAliveParticipants(),"all known attackers neutralized")

local closed,closedOk,closeReason=coordinator:Close("KNOWN_ATTACKERS_NEUTRALIZED")
assertTrue(closedOk,"incident closes explicitly")
assertEqual(closeReason,nil,"close result")
assertEqual(closed.status,Incident.Status.CLOSED,"closed status")
assertEqual(closed.closeReason,"KNOWN_ATTACKERS_NEUTRALIZED","close reason stored")
assertEqual(closes,1,"one close callback")
assertEqual(coordinator:GetActive(),nil,"no active incident after close")
assertEqual(#coordinator:GetHistory(),1,"closed incident retained in history")

local third,thirdCreated=coordinator:ReportEvidence({
  installationId="BLUE_GROUND_COP_HONAKER_MIRACLE",
  evidenceType="INDIRECT_FIRE_ATTACK",
  initiatorGroup=redA,
})
assertTrue(thirdCreated,"new evidence after closure creates next incident")
assertEqual(third.incidentId,"INC-HONAKER-2","next incident id")
assertEqual(starts,2,"second incident start")

local mismatch,mismatchCreated,mismatchReason=coordinator:ReportEvidence({
  installationId="BLUE_GROUND_COP_OTHER",
  evidenceType="DIRECT_FIRE_ATTACK",
})
assertEqual(mismatch,nil,"wrong installation ignored")
assertFalse(mismatchCreated,"wrong installation not created")
assertEqual(mismatchReason,"INSTALLATION_MISMATCH","wrong installation reason")

print("PASS test_ground_installation_attack_incident")
