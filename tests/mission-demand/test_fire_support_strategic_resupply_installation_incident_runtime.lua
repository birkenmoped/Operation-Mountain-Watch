local Runtime=dofile("scripts/campaign/OMW_FireSupStratResupply_InstallationIncidentRuntime.lua")
local Incident=dofile("scripts/ground/OMW_GroundInstallationAttackIncident.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local calls={started=0,updated=0,closed=0}
local bridge={}
function bridge:OnIncidentStarted(_,incident,evidence) calls.started=calls.started+1;calls.lastStarted={incident=incident,evidence=evidence};return incident,true,nil end
function bridge:OnIncidentUpdated(_,incident,evidence) calls.updated=calls.updated+1;calls.lastUpdated={incident=incident,evidence=evidence};return incident,false,"INCIDENT_REFRESH_ONLY" end
function bridge:OnIncidentClosed(_,incident,reason) calls.closed=calls.closed+1;calls.lastClosed={incident=incident,reason=reason};return incident,true,nil end

local registry={Sites={
  FOB_JOYCE={siteId="FOB_JOYCE",installationId="BLUE_GROUND_FOB_JOYCE"},
  FOB_WRIGHT={siteId="FOB_WRIGHT",installationId="BLUE_GROUND_FOB_WRIGHT"},
}}
local runtime=Runtime.New({siteRegistry=registry,incidentCoordinator=Incident,bridge=bridge})
local before,beforeCreated,beforeReason=runtime:ReportEvidence({installationId="BLUE_GROUND_FOB_JOYCE",evidenceType="PROXIMITY_INTRUSION"})
eq(before,nil,"evidence before prepare")
no(beforeCreated,"evidence before prepare not created")
eq(beforeReason,"RUNTIME_NOT_PREPARED","evidence before prepare reason")

local _,prepared,prepareReason=runtime:Prepare()
yes(prepared,"runtime prepared")
eq(prepareReason,nil,"prepare reason")
yes(runtime:GetCoordinator("BLUE_GROUND_FOB_JOYCE")~=nil,"Joyce coordinator exists")
yes(runtime:GetCoordinator("BLUE_GROUND_FOB_WRIGHT")~=nil,"Wright coordinator exists")
local _,preparedAgain,againReason=runtime:Prepare()
no(preparedAgain,"prepare idempotent")
eq(againReason,"ALREADY_PREPARED","second prepare reason")

local first,created,reason=runtime:ReportEvidence({installationId="BLUE_GROUND_FOB_JOYCE",evidenceType="PROXIMITY_INTRUSION"})
yes(created,"first evidence opens incident")
eq(reason,nil,"first evidence reason")
eq(calls.started,1,"one start callback")
eq(first.installationId,"BLUE_GROUND_FOB_JOYCE","correct installation")

local same,createdAgain,refreshReason=runtime:ReportEvidence({installationId="BLUE_GROUND_FOB_JOYCE",evidenceType="CONFIRMED_HIT_ATTACK"})
eq(same,first,"second evidence refreshes same incident")
no(createdAgain,"refresh creates no second incident")
eq(refreshReason,"ACTIVE_INCIDENT_REFRESHED","coordinator refresh reason")
eq(calls.updated,1,"one update callback")
eq(first.evidenceCount,2,"evidence aggregated")

local other,otherCreated=runtime:ReportEvidence({installationId="BLUE_GROUND_FOB_WRIGHT",evidenceType="DIRECT_FIRE_ATTACK"})
yes(otherCreated,"independent installation incident")
yes(other~=first,"independent coordinator")
eq(calls.started,2,"two installations started")

local closed,closedOk,closeReason=runtime:CloseInstallationIncident("BLUE_GROUND_FOB_JOYCE","KNOWN_ATTACKERS_NEUTRALIZED")
yes(closedOk,"explicit close succeeds")
eq(closeReason,nil,"close reason result")
eq(closed.status,Incident.Status.CLOSED,"coordinator incident closed")
eq(calls.closed,1,"one close callback")
eq(calls.lastClosed.reason,"KNOWN_ATTACKERS_NEUTRALIZED","close reason forwarded")

local missing,missingCreated,missingReason=runtime:ReportEvidence({installationId="UNKNOWN",evidenceType="PROXIMITY_INTRUSION"})
eq(missing,nil,"unknown evidence ignored")
no(missingCreated,"unknown evidence not created")
eq(missingReason,"INSTALLATION_NOT_REGISTERED","unknown evidence reason")

print("PASS test_fire_support_strategic_resupply_installation_incident_runtime")
