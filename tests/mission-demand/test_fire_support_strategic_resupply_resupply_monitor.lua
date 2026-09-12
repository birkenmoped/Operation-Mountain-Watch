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
local u,uCreated,uReason=unknownMonitor:EvaluateAll()[1].demand,unknownMonitor:EvaluateAll()[1].created,unknownMonitor:EvaluateAll()[1].reason
-- The repeated EvaluateAll calls above are harmless because no site demand can be created.
eq(u,nil,"unknown node no demand")
no(uCreated,"unknown node not created")
eq(uReason,"SITE_NOT_REGISTERED_FOR_RESOURCE_NODE","unknown node reason")

print("PASS test_fire_support_strategic_resupply_resupply_monitor")
