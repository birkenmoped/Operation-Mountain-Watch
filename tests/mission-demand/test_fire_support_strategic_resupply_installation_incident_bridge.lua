local Bridge=dofile("scripts/campaign/OMW_FireSupStratResupply_InstallationIncidentBridge.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local calls={}
local base={}
function base:OpenIncident(spec)
  calls.open=spec
  return {incidentId="BASE|"..spec.incidentKey},true,nil
end
function base:RequestIncidentSupport(incidentId,supportType,spec)
  calls.support={incidentId=incidentId,supportType=supportType,spec=spec}
  return {demandId="QRF-1"},true,nil
end
function base:CloseIncident(incidentId,reason)
  calls.close={incidentId=incidentId,reason=reason}
  return {incidentId=incidentId,closed=true},true,nil
end

local registry={Sites={FOB_JOYCE={siteId="FOB_JOYCE",installationId="BLUE_GROUND_FOB_JOYCE"}}}
local bridge=Bridge.New({base=base,siteRegistry=registry})
local source={incidentId="INSTALLATION-ATTACK|BLUE_GROUND_FOB_JOYCE|1",installationId="BLUE_GROUND_FOB_JOYCE",priority=80}
local opened,created,reason,qrf=bridge:OnIncidentStarted(nil,source,{evidenceType="PROXIMITY_INTRUSION"})
yes(created,"base incident created")
eq(reason,nil,"start reason")
eq(calls.open.siteId,"FOB_JOYCE","site mapped")
eq(calls.open.incidentKey,source.incidentId,"source incident key preserved")
eq(calls.open.context.source,"INSTALLATION_ATTACK_INCIDENT","incident source")
eq(calls.open.context.initialEvidenceType,"PROXIMITY_INTRUSION","initial evidence")
eq(calls.support.incidentId,opened.incidentId,"QRF bound to base incident")
eq(calls.support.supportType,"QRF","only initial QRF requested")
eq(calls.support.spec.requestKey,"INSTALLATION_ATTACK_INITIAL_QRF","stable QRF request key")
eq(qrf.demandId,"QRF-1","QRF result forwarded")
eq(bridge:GetBaseIncidentId(source.incidentId),opened.incidentId,"source binding stored")

local refreshed,refreshCreated,refreshReason=bridge:OnIncidentUpdated(nil,source,{evidenceType="DIRECT_FIRE_ATTACK"})
eq(refreshed,opened.incidentId,"refresh resolves base incident")
no(refreshCreated,"refresh creates no response")
eq(refreshReason,"INCIDENT_REFRESH_ONLY","refresh reason")
eq(calls.support.spec.requestKey,"INSTALLATION_ATTACK_INITIAL_QRF","no duplicate QRF mutation")

local closed,changed,closeReason=bridge:OnIncidentClosed(nil,source,"KNOWN_ATTACKERS_NEUTRALIZED")
yes(changed,"base incident closed")
eq(closeReason,nil,"close reason")
eq(calls.close.incidentId,opened.incidentId,"correct base incident closed")
eq(calls.close.reason,"KNOWN_ATTACKERS_NEUTRALIZED","authoritative close reason forwarded")
eq(closed.closed,true,"closed state forwarded")
eq(bridge:GetBaseIncidentId(source.incidentId),nil,"binding released")

local missing,missingCreated,missingReason=bridge:OnIncidentStarted(nil,{incidentId="X",installationId="UNKNOWN"},{evidenceType="PROXIMITY_INTRUSION"})
eq(missing,nil,"unknown installation ignored")
no(missingCreated,"unknown installation not created")
eq(missingReason,"INSTALLATION_NOT_REGISTERED","unknown installation reason")

print("PASS test_fire_support_strategic_resupply_installation_incident_bridge")
