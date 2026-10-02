local Monitor = dofile("scripts/campaign/OMW_FireSupStratResupply_ResupplyMonitor.lua")

local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local state={available=3}
local store={}
function store:GetResource(nodeId,resourceId)
  return {nodeId=nodeId,resourceId=resourceId,available=state.available,quantity=state.available,canonicalUnit="count",reserved=0}
end
local policy={}
function policy.Evaluate(row,snapshot)
  if snapshot.available > row.reorder then return nil end
  return {
    level=snapshot.available<=row.critical and "CRITICAL" or "REORDER",
    destinationNodeId=row.nodeId,
    destinationResourceId=row.resourceId,
    resourceClass=row.resourceClass,
    canonicalUnit="count",
    supplyParent=row.supplyParent,
    requestedQuantity=row.target-snapshot.available,
  }
end

local sites={Sites={FOB_JOYCE={siteId="FOB_JOYCE",campaignNodeId="GROUND_NODE_JOYCE"}}}
local requests={}
local base={}
function base:RequestResupply(siteId,supportType,spec)
  local demand={demandId=string.format("D|%s|%s|%s",siteId,supportType,spec.requestKey),siteId=siteId,supportType=supportType,resourceId=spec.resourceId,quantity=spec.quantity,context=spec.context}
  requests[#requests+1]={siteId=siteId,supportType=supportType,spec=spec,demand=demand}
  return demand,true,nil
end
local rows={{nodeId="GROUND_NODE_JOYCE",resourceId="GROUND_PERSONNEL",resourceClass="PERSONNEL",target=10,reorder=5,critical=2,supplyParent="GROUND_NODE_JALALABAD"}}
local monitor=Monitor.New({
  base=base,siteRegistry=sites,policy=policy,store=store,rows=rows,
  selectSupportType=function(candidate,site,snapshot)
    eq(site.siteId,"FOB_JOYCE","selector site")
    return "GROUND_RESUPPLY"
  end,
  priorityForCandidate=function(candidate) return candidate.level=="CRITICAL" and 10 or 20 end,
})

local demand,created,reason,candidate=monitor:EvaluateRow(rows[1])
yes(created,"first shortage demand created")
eq(reason,nil,"first shortage reason")
eq(candidate.level,"REORDER","reorder level")
eq(demand.resourceId,"GROUND_PERSONNEL","resource forwarded")
eq(demand.quantity,7,"restore-to-target quantity")
eq(requests[1].supportType,"GROUND_RESUPPLY","selected support type")
eq(requests[1].spec.priority,20,"reorder priority")
eq(requests[1].spec.requestKey,"RESOURCE_THRESHOLD|GROUND_PERSONNEL|1","first shortage generation")
eq(requests[1].spec.context.supplyParent,"GROUND_NODE_JALALABAD","supply parent context")

local same,sameCreated,sameReason=monitor:EvaluateRow(rows[1])
eq(same,demand,"active shortage returns same demand")
no(sameCreated,"active shortage not duplicated")
eq(sameReason,"SHORTAGE_ALREADY_ACTIVE","active shortage reason")
eq(#requests,1,"no duplicate Base request")

state.available=8
local clear,clearCreated,clearReason=monitor:EvaluateRow(rows[1])
eq(clear,nil,"resolved shortage no demand")
no(clearCreated,"resolved shortage not created")
eq(clearReason,"NO_SHORTAGE","resolved shortage reason")
eq(monitor:GetActive("GROUND_NODE_JOYCE","GROUND_PERSONNEL"),nil,"active shortage cleared")

state.available=1
local second,secondCreated,secondReason,secondCandidate=monitor:EvaluateRow(rows[1])
yes(secondCreated,"second shortage episode created")
eq(secondReason,nil,"second shortage reason")
eq(secondCandidate.level,"CRITICAL","critical level")
eq(requests[2].spec.requestKey,"RESOURCE_THRESHOLD|GROUND_PERSONNEL|2","second shortage generation")
eq(requests[2].spec.priority,10,"critical priority")
local released,releasedChanged=monitor:ReleaseDemand(second.demandId,"TRANSPORT_LOST")
eq(released,second,"released demand")
yes(releasedChanged,"active demand release")
eq(monitor:GetActive("GROUND_NODE_JOYCE","GROUND_PERSONNEL"),nil,"release permits later reevaluation")
local third,thirdCreated=monitor:EvaluateRow(rows[1])
yes(thirdCreated,"terminal release permits new shortage demand")
eq(requests[3].spec.requestKey,"RESOURCE_THRESHOLD|GROUND_PERSONNEL|3","third shortage generation")

local unknownMonitor=Monitor.New({
  base=base,siteRegistry=sites,policy=policy,store=store,
  rows={{nodeId="GROUND_NODE_UNKNOWN",resourceId="GROUND_PERSONNEL",resourceClass="PERSONNEL",target=10,reorder=5,critical=2,supplyParent="OFF_MAP"}},
  selectSupportType=function() return "GROUND_RESUPPLY" end,
})
local unknownResult=unknownMonitor:EvaluateAll()[1]
eq(unknownResult.demand,nil,"unknown node no demand")
no(unknownResult.created,"unknown node not created")
eq(unknownResult.reason,"SITE_NOT_REGISTERED_FOR_RESOURCE_NODE","unknown node reason")

-- Distinct node/resource shortage episodes remain independently active.
do
  local availability={GROUND_NODE_JOYCE=2,GROUND_NODE_HONAKER=1}
  local concurrentStore={}
  function concurrentStore:GetResource(nodeId,resourceId)
    local available=availability[nodeId]
    return {nodeId=nodeId,resourceId=resourceId,available=available,quantity=available,canonicalUnit="count",reserved=0}
  end
  local concurrentSites={Sites={
    FOB_JOYCE={siteId="FOB_JOYCE",campaignNodeId="GROUND_NODE_JOYCE"},
    COP_HONAKER={siteId="COP_HONAKER",campaignNodeId="GROUND_NODE_HONAKER"},
  }}
  local concurrentRows={
    {nodeId="GROUND_NODE_JOYCE",resourceId="GROUND_AMMO_PACKAGE",resourceClass="AMMO",target=6,reorder=3,critical=1,supplyParent="GROUND_NODE_JALALABAD"},
    {nodeId="GROUND_NODE_HONAKER",resourceId="GROUND_AMMO_PACKAGE",resourceClass="AMMO",target=5,reorder=2,critical=1,supplyParent="GROUND_NODE_JOYCE"},
  }
  local concurrentRequests={}
  local concurrentBase={}
  function concurrentBase:RequestResupply(siteId,supportType,spec)
    local demand={demandId="C|"..siteId.."|"..spec.requestKey,siteId=siteId,supportType=supportType,resourceId=spec.resourceId,quantity=spec.quantity}
    concurrentRequests[#concurrentRequests+1]=demand
    return demand,true,nil
  end
  local concurrentMonitor=Monitor.New({
    base=concurrentBase,siteRegistry=concurrentSites,policy=policy,store=concurrentStore,rows=concurrentRows,
    selectSupportType=function() return "GROUND_RESUPPLY" end,
  })
  local results=concurrentMonitor:EvaluateAll()
  yes(results[1].created,"Joyce concurrent shortage created")
  yes(results[2].created,"Honaker concurrent shortage created")
  eq(#concurrentRequests,2,"two independent resupply demands")
  yes(concurrentMonitor:GetActive("GROUND_NODE_JOYCE","GROUND_AMMO_PACKAGE")~=nil,"Joyce active demand retained")
  yes(concurrentMonitor:GetActive("GROUND_NODE_HONAKER","GROUND_AMMO_PACKAGE")~=nil,"Honaker active demand retained")
  concurrentMonitor:ReleaseDemand(results[1].demand.demandId,"DELIVERED")
  eq(concurrentMonitor:GetActive("GROUND_NODE_JOYCE","GROUND_AMMO_PACKAGE"),nil,"Joyce release is demand-local")
  yes(concurrentMonitor:GetActive("GROUND_NODE_HONAKER","GROUND_AMMO_PACKAGE")~=nil,"Honaker demand survives Joyce release")
end

print("PASS test_fire_support_strategic_resupply_resupply_monitor")
