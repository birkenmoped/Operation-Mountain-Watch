local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_Runtime.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local sites={Sites={FOB_JOYCE={siteId="FOB_JOYCE",installationId="BLUE_GROUND_FOB_JOYCE"}}}
local profiles={Profiles={}}
local ids={Incident=function() end}
local brigades={FOB_JOYCE={alias="BDE_BLUE_GND_JOYCE"}}
local marker={}
local calls={}

local modules={}
modules.guardMaterializationAdapter={New=function() end}
modules.guardRouteAdapter={New=function() end}
modules.guardMissionFactory={New=function() end}
modules.qrfMissionFactory={New=function() end}
modules.legionBridge={New=function() end}
modules.installationAttackIncident={New=function() end}

modules.guardRuntime={}
function modules.guardRuntime.New(spec)
  calls.guardSpec=spec
  local r={}
  function r:Prepare() calls.guardPrepared=true return self,true,nil end
  function r:Dispatch() return marker,true,nil end
  return r
end
modules.qrfRuntime={}
function modules.qrfRuntime.New(spec)
  calls.qrfSpec=spec
  local r={}
  function r:Dispatch() return marker,true,nil end
  return r
end
modules.lifecycleAdapter={}
function modules.lifecycleAdapter.New(spec) calls.lifecycleSpec=spec;return {Register=function() end,Cancel=function() end} end
modules.base={}
function modules.base.New(spec)
  calls.baseSpec=spec
  local b={}
  function b:StartSite(siteId,spec2) calls.startSite={siteId=siteId,spec=spec2};return {siteId=siteId},true,nil end
  return b
end
modules.installationIncidentBridge={}
function modules.installationIncidentBridge.New(spec)
  calls.installationIncidentBridgeSpec=spec
  return {OnIncidentStarted=function() end,OnIncidentUpdated=function() end,OnIncidentClosed=function() end}
end
modules.installationIncidentRuntime={}
function modules.installationIncidentRuntime.New(spec)
  calls.installationIncidentRuntimeSpec=spec
  local r={}
  calls.installationIncidentRuntime=r
  function r:Prepare() calls.installationIncidentsPrepared=true;return self,true,nil end
  function r:ReportEvidence(evidence) calls.reportEvidence=evidence;return {incidentId="SOURCE-INCIDENT"},true,nil end
  function r:CloseInstallationIncident(installationId,reason) calls.closeInstallation={installationId=installationId,reason=reason};return {incidentId="SOURCE-INCIDENT"},true,nil end
  return r
end
modules.perimeterBridge={}
function modules.perimeterBridge.New(spec) calls.perimeterBridgeSpec=spec;return {HandleThreat=function() end,HandleClear=function() end} end
modules.threatAdapter={New=function() end}
modules.perimeterRuntime={}
function modules.perimeterRuntime.New(spec)
  calls.perimeterSpec=spec
  local p={}
  function p:StartAll() calls.perimetersStarted=true;return {FOB_JOYCE=true},true,nil end
  function p:StopAll() calls.perimetersStopped=true;return self,true,nil end
  return p
end
modules.resupplyMonitor={}
function modules.resupplyMonitor.New(spec)
  calls.resupplySpec=spec
  local monitor={}
  function monitor:EvaluateAll() calls.resupplyEvaluated=true;return {{reason="NO_SHORTAGE"}} end
  function monitor:ReleaseDemand(demandId,reason) calls.resupplyRelease={demandId=demandId,reason=reason};return marker,true,nil end
  return monitor
end
modules.commanderBridge={New=function() end}
modules.storageTransportFactory={New=function() end}
modules.transportSettlement={}
function modules.transportSettlement.New(spec)
  calls.transportSettlementSpec=spec
  return {Attach=function() end}
end
modules.resupplyTransportRuntime={}
function modules.resupplyTransportRuntime.New(spec)
  calls.resupplyTransportSpec=spec
  local ground={marker="GROUND_RESUPPLY"}
  local air={marker="AIR_RESUPPLY"}
  return {
    GetAdapters=function() return {GROUND_RESUPPLY=ground,AIR_RESUPPLY=air} end,
    GetAdapter=function(_,supportType) return supportType=="GROUND_RESUPPLY" and ground or air end,
  }
end

local resourcePolicy={Evaluate=function() end}
local campaignStore={GetResource=function() end}
local campaignState={TransactionKind={TRANSFER="TRANSFER"},TransactionStatus={}}
local resourceRows={{nodeId="GROUND_NODE_JOYCE",resourceId="GROUND_PERSONNEL"}}
local selectSupportType=function() return "GROUND_RESUPPLY" end
local groundCommander={AddOpsTransport=function() end}
local airCommander={AddOpsTransport=function() end}
local resolveGroundTransport=function() return {} end
local resolveAirTransport=function() return {} end
local transferResolver=function() return {originNodeId="GROUND_NODE_JALALABAD",destinationNodeId="GROUND_NODE_JOYCE"} end
local terminalObserved={}
local arty={marker="ARTY"}
local runtime=Runtime.New({
  modules=modules,
  siteRegistry=sites,
  supportProfiles=profiles,
  idContract=ids,
  brigades=brigades,
  resolveGuardPathline=function() return {} end,
  resolveGuardTemplateGroup=function() return {} end,
  resolveQrfCoordinate=function() return {} end,
  externalAdapters={ARTY=arty},
  perimeters={FOB_JOYCE={anchorCoordinate={},radiusM=1000,priority=10}},
  blueCoalition=2,
  redCoalition=1,
  resupply={
    policy=resourcePolicy,
    store=campaignStore,
    rows=resourceRows,
    selectSupportType=selectSupportType,
    transport={
      campaignState=campaignState,
      groundCommander=groundCommander,
      resolveGroundTransport=resolveGroundTransport,
      airCommander=airCommander,
      resolveAirTransport=resolveAirTransport,
      resolveTransfer=transferResolver,
      onTerminal=function(demand,outcome) terminalObserved={demandId=demand.demandId,outcome=outcome} end,
    },
  },
})

local before,beforeCreated,beforeReason=runtime:StartSite("FOB_JOYCE",{})
eq(before,nil,"start before prepare nil")
no(beforeCreated,"start before prepare false")
eq(beforeReason,"RUNTIME_NOT_PREPARED","start before prepare reason")
local beforeEvidence,beforeEvidenceCreated,beforeEvidenceReason=runtime:ReportInstallationEvidence({installationId="BLUE_GROUND_FOB_JOYCE",evidenceType="PROXIMITY_INTRUSION"})
eq(beforeEvidence,nil,"evidence before prepare nil")
no(beforeEvidenceCreated,"evidence before prepare false")
eq(beforeEvidenceReason,"RUNTIME_NOT_PREPARED","evidence before prepare reason")

local _,prepared,reason=runtime:Prepare()
yes(prepared,"runtime prepared")
eq(reason,nil,"prepare reason")
yes(calls.guardPrepared,"Guard runtime prepared")
yes(calls.installationIncidentsPrepared,"installation incident runtime prepared")
eq(calls.guardSpec.brigades,brigades,"Guard receives injected brigades")
eq(calls.qrfSpec.brigades,brigades,"QRF receives injected brigades")
eq(calls.baseSpec.adapters.GUARD,runtime:GetAdapter("GUARD"),"Base GUARD adapter")
eq(calls.baseSpec.adapters.QRF,runtime:GetAdapter("QRF"),"Base QRF adapter")
eq(calls.baseSpec.adapters.ARTY,arty,"external ARTY adapter preserved")
yes(runtime:GetAdapter("GROUND_RESUPPLY")~=nil,"ground resupply adapter installed")
yes(runtime:GetAdapter("AIR_RESUPPLY")~=nil,"air resupply adapter installed")
eq(calls.resupplyTransportSpec.groundCommander,groundCommander,"ground commander forwarded")
eq(calls.resupplyTransportSpec.airCommander,airCommander,"air commander forwarded")
eq(calls.resupplyTransportSpec.resolveGroundTransport,resolveGroundTransport,"ground resolver forwarded")
eq(calls.resupplyTransportSpec.resolveAirTransport,resolveAirTransport,"air resolver forwarded")
eq(calls.resupplyTransportSpec.settlement.Attach~=nil,true,"settlement attached to transport runtime")
eq(calls.transportSettlementSpec.store,campaignStore,"settlement uses CampaignState store")
eq(calls.transportSettlementSpec.campaignState,campaignState,"settlement campaign module")
eq(calls.transportSettlementSpec.resolveTransfer,transferResolver,"transfer resolver forwarded")
eq(calls.installationIncidentBridgeSpec.base,runtime:GetBase(),"incident bridge uses same Base")
eq(calls.installationIncidentRuntimeSpec.incidentCoordinator,modules.installationAttackIncident,"authoritative incident coordinator injected")
eq(calls.perimeterBridgeSpec.incidentRuntime,calls.installationIncidentRuntime,"perimeter bridge receives installation incident runtime")
eq(calls.perimeterSpec.perimeters.FOB_JOYCE.radiusM,1000,"perimeter config forwarded")
eq(calls.perimeterSpec.blueCoalition,2,"blue coalition forwarded")
eq(calls.perimeterSpec.redCoalition,1,"red coalition forwarded")
eq(calls.resupplySpec.base,runtime:GetBase(),"resupply monitor uses same Base")
eq(calls.resupplySpec.policy,resourcePolicy,"resource policy forwarded")
eq(calls.resupplySpec.store,campaignStore,"CampaignState store forwarded")
eq(calls.resupplySpec.rows,resourceRows,"resource rows forwarded")
eq(calls.resupplySpec.selectSupportType,selectSupportType,"resupply transport selector forwarded")

calls.transportSettlementSpec.onTerminal({demandId="D-TRANSPORT"},"LOST",{}, {}, {})
eq(calls.resupplyRelease.demandId,"D-TRANSPORT","terminal transport releases active shortage")
eq(calls.resupplyRelease.reason,"LOST","terminal outcome forwarded to monitor")
eq(terminalObserved.demandId,"D-TRANSPORT","owner terminal callback demand")
eq(terminalObserved.outcome,"LOST","owner terminal callback outcome")

local _,preparedAgain,againReason=runtime:Prepare()
no(preparedAgain,"second prepare idempotent")
eq(againReason,"ALREADY_PREPARED","second prepare reason")

local sourceIncident,sourceCreated=runtime:ReportInstallationEvidence({installationId="BLUE_GROUND_FOB_JOYCE",evidenceType="PROXIMITY_INTRUSION"})
yes(sourceCreated,"installation evidence forwarded")
eq(sourceIncident.incidentId,"SOURCE-INCIDENT","source incident result")
eq(calls.reportEvidence.evidenceType,"PROXIMITY_INTRUSION","evidence type forwarded")
local closedInstallation,closedInstallationChanged=runtime:CloseInstallationIncident("BLUE_GROUND_FOB_JOYCE","TACTICAL_COMPLETION")
yes(closedInstallationChanged,"installation close forwarded")
eq(closedInstallation.incidentId,"SOURCE-INCIDENT","installation close result")
eq(calls.closeInstallation.reason,"TACTICAL_COMPLETION","installation close reason forwarded")

local siteState,siteStarted=runtime:StartSite("FOB_JOYCE",{priority=50})
yes(siteStarted,"site start forwarded")
eq(siteState.siteId,"FOB_JOYCE","site state")
eq(calls.startSite.spec.priority,50,"site spec forwarded")
local _,perimetersStarted=runtime:StartPerimeters();yes(perimetersStarted,"perimeters started")
yes(calls.perimetersStarted,"perimeter StartAll called")
local _,perimetersStopped=runtime:StopPerimeters();yes(perimetersStopped,"perimeters stopped")
yes(calls.perimetersStopped,"perimeter StopAll called")
local resupplyResults,resupplyEvaluated,resupplyReason=runtime:EvaluateResupply()
yes(resupplyEvaluated,"resupply evaluation available")
eq(resupplyReason,nil,"resupply evaluation reason")
eq(resupplyResults[1].reason,"NO_SHORTAGE","resupply monitor result forwarded")
yes(calls.resupplyEvaluated,"resupply monitor EvaluateAll called")
local released,releasedChanged=runtime:ReleaseResupplyDemand("D1","TRANSPORT_LOST")
eq(released,marker,"resupply release result forwarded")
yes(releasedChanged,"resupply release changed")
eq(calls.resupplyRelease.demandId,"D1","release demand id")
eq(calls.resupplyRelease.reason,"TRANSPORT_LOST","release reason")

local noPerimeter=Runtime.New({
  modules=modules,
  siteRegistry=sites,
  supportProfiles=profiles,
  idContract=ids,
  brigades=brigades,
  resolveGuardPathline=function() return {} end,
  resolveGuardTemplateGroup=function() return {} end,
  resolveQrfCoordinate=function() return {} end,
})
noPerimeter:Prepare()
local p,pCreated,pReason=noPerimeter:StartPerimeters()
eq(p,nil,"no perimeter runtime nil")
no(pCreated,"no perimeter false")
eq(pReason,"PERIMETERS_NOT_CONFIGURED","no perimeter explicit reason")
local r,rCreated,rReason=noPerimeter:EvaluateResupply()
eq(r,nil,"no resupply monitor nil")
no(rCreated,"no resupply monitor false")
eq(rReason,"RESUPPLY_MONITOR_NOT_CONFIGURED","no resupply monitor explicit reason")

print("PASS test_fire_support_strategic_resupply_runtime")
