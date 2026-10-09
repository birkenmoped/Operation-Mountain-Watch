local Bridge=dofile("scripts/campaign/OMW_FireSupStratResupply_InstallationIncidentBridge.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local calls={support={}}
local base={}
function base:OpenIncident(spec)
  calls.open=spec
  return {incidentId="BASE|"..spec.incidentKey},true,nil
end
function base:RequestIncidentSupport(incidentId,supportType,spec)
  calls.support[#calls.support+1]={incidentId=incidentId,supportType=supportType,spec=spec}
  if supportType=="GUARD" then return {demandId="GUARD-1"},true,nil end
  return {demandId="QRF-1"},true,nil
end
function base:CloseIncident(incidentId,reason)
  calls.close={incidentId=incidentId,reason=reason}
  return {incidentId=incidentId,closed=true},true,nil
end

local registry={Sites={FOB_JOYCE={siteId="FOB_JOYCE",installationId="BLUE_GROUND_FOB_JOYCE"}}}
local bridge=Bridge.New({base=base,siteRegistry=registry})
local position={x=1,y=2,z=3}
local reportedTarget={targetKind="INSTALLATION_SECURITY_PERIMETER"}
local initiatorGroup={name="BadGuys_A3_JOYCE"}
function initiatorGroup:GetName() return self.name end
local coordinator={}
function coordinator:GetParticipants() return {initiatorGroup} end
local source={incidentId="INSTALLATION-ATTACK|BLUE_GROUND_FOB_JOYCE|1",installationId="BLUE_GROUND_FOB_JOYCE"}
local evidence={evidenceType="PROXIMITY_INTRUSION",priority=80,position=position,reportedTarget=reportedTarget,initiatorGroup=initiatorGroup}
local opened,created,reason,qrf,guard=bridge:OnIncidentStarted(coordinator,source,evidence)
yes(created,"base incident created")
eq(reason,nil,"start reason")
eq(calls.open.siteId,"FOB_JOYCE","site mapped")
eq(calls.open.incidentKey,source.incidentId,"source incident key preserved")
eq(calls.open.priority,80,"initial evidence priority preserved")
eq(calls.open.context.source,"INSTALLATION_ATTACK_INCIDENT","incident source")
eq(calls.open.context.sourceIncidentCoordinator,coordinator,"source incident participant authority preserved")
eq(calls.open.context.initialEvidenceType,"PROXIMITY_INTRUSION","initial evidence")
eq(calls.open.context.position,position,"evidence position preserved")
eq(calls.open.context.reportedTarget,reportedTarget,"reported target preserved")
eq(calls.open.context.physicalTargetGroup,initiatorGroup,"physical hostile group preserved for QRF road-forward direction")
eq(#calls.support,2,"Guard and QRF requested exactly once")
local guardCall,qrfCall=calls.support[1],calls.support[2]
eq(guardCall.incidentId,opened.incidentId,"Guard bound to base incident")
eq(guardCall.supportType,"GUARD","local Guard requested")
eq(guardCall.spec.requestKey,"INSTALLATION_ATTACK_LOCAL_GUARD","stable Guard request key")
eq(guardCall.spec.priority,80,"Guard priority preserved")
eq(guardCall.spec.cancelWhenIncidentClosed,true,"Guard follows incident lifecycle")
eq(guardCall.spec.context.activation,"INCIDENT_LOCAL_SECURITY","Guard local-security activation")
eq(qrfCall.incidentId,opened.incidentId,"QRF bound to base incident")
eq(qrfCall.supportType,"QRF","initial QRF requested")
eq(qrfCall.spec.requestKey,"INSTALLATION_ATTACK_INITIAL_QRF","stable QRF request key")
eq(qrfCall.spec.priority,80,"QRF priority preserved")
eq(qrfCall.spec.cancelWhenIncidentClosed,false,"incident close must not auto-cancel dispatched QRF")
eq(qrf.demandId,"QRF-1","QRF result forwarded")
eq(guard.demandId,"GUARD-1","Guard result forwarded")
eq(bridge:GetBaseIncidentId(source.incidentId),opened.incidentId,"source binding stored")

local refreshed,refreshCreated,refreshReason=bridge:OnIncidentUpdated(coordinator,source,{evidenceType="DIRECT_FIRE_ATTACK"})
eq(refreshed,opened.incidentId,"refresh resolves base incident")
no(refreshCreated,"refresh creates no response")
eq(refreshReason,"INCIDENT_REFRESH_ONLY","refresh reason")
eq(#calls.support,2,"refresh creates no duplicate Guard/QRF")

local closed,changed,closeReason=bridge:OnIncidentClosed(coordinator,source,"KNOWN_ATTACKERS_NEUTRALIZED")
yes(changed,"base incident closed")
eq(closeReason,nil,"close reason")
eq(calls.close.incidentId,opened.incidentId,"correct base incident closed")
eq(calls.close.reason,"KNOWN_ATTACKERS_NEUTRALIZED","authoritative close reason forwarded")
eq(closed.closed,true,"closed state forwarded")
eq(bridge:GetBaseIncidentId(source.incidentId),nil,"binding released")
eq(guardCall.spec.cancelWhenIncidentClosed,true,"closing incident retains Guard cancellation policy")
eq(qrfCall.spec.cancelWhenIncidentClosed,false,"closing incident does not mutate QRF cancellation policy")

local missing,missingCreated,missingReason=bridge:OnIncidentStarted(coordinator,{incidentId="X",installationId="UNKNOWN"},{evidenceType="PROXIMITY_INTRUSION"})
eq(missing,nil,"unknown installation ignored")
no(missingCreated,"unknown installation not created")
eq(missingReason,"INSTALLATION_NOT_REGISTERED","unknown installation reason")

print("PASS test_fire_support_strategic_resupply_installation_incident_bridge")