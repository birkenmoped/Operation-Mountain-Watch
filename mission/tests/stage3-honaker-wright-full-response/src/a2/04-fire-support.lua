local function fireTargetTelemetry(target)
  local coordinate=target:GetCoordinate(); local distance=state.battery:GetCoordinate():Get2DDistance(coordinate)
  local minRange,maxRange=state.arty.minrange,state.arty.maxrange
  if type(minRange)=="number" and distance<minRange then return nil,"BELOW_MOOSE_MIN_RANGE" end
  if type(maxRange)=="number" and distance>maxRange then return nil,"BEYOND_MOOSE_MAX_RANGE" end
  return {coordinate=coordinate,distanceM=distance,minRangeM=minRange,maxRangeM=maxRange},nil
end
local function selectNextFireTarget()
  if state.casOnStation then return nil,"CAS_ON_STATION_ARTY_DECONFLICTION" end
  local targets=c2FireObservationGroups(); if #targets==0 then targets=incidentGroups() end
  for _,target in ipairs(targets) do if not state.fireScheduledSourceGroups[target:GetName()] then return target,nil end end
  return nil,"NO_FRESH_C2_OBSERVED_RED_GROUND_GROUP"
end
local function reportFireMission(target,number)
  local t,reason=fireTargetTelemetry(target); if not t then fail("Wright target range rejected: "..tostring(reason)); return false end
  msg("FIRE SUPPORT",string.format("Fire mission %d -> %s; Wright range %.2f km",number,target:GetName(),t.distanceM/1000),10); return true
end
local function queueNextFireMission(demandId)
  local ammo=state.arty:GetAmmo(false)
  if type(ammo)=="number" and ammo<FIRE_SHELLS then return false end
  local target=selectNextFireTarget(); if not target then return false end
  local nextNumber=state.fireTargetCount+1; if not reportFireMission(target,nextNumber) then return false end
  local targetName,queued,reason=state.fireAdapter:QueueTarget(demandId,target)
  if queued~=true then fail("Wright ARTY live retarget failed: "..tostring(reason)); return false end
  state.fireTargetCount=nextNumber; state.fireScheduledSourceGroups[target:GetName()]=true
  log(string.format("LIVE_FIRE_RETARGET demandId=%s mission=%d sourceGroup=%s artyTarget=%s",tostring(demandId),nextNumber,target:GetName(),tostring(targetName)))
  return true
end
local function setupFireSupport()
  local ctx=context(); state.battery=need(GROUP:FindByName(WRIGHT_BATTERY),WRIGHT_BATTERY)
  local supportZone=need(ZONE:FindByName(WRIGHT_RESUPPLY_ZONE),WRIGHT_RESUPPLY_ZONE); need(GROUP:FindByName(M1083_TEMPLATE),M1083_TEMPLATE)
  if state.failed then return false end
  state.arty=ARTY:New(state.battery,"Wright L118 Stage3 A2"); state.arty:SetReportOFF(); state.arty:SetWaitForShotTime(ARTY_WAIT_FOR_SHOT_SEC); state.arty:Start()
  local rearmBrigade=BRIGADE:New(WRIGHT_WAREHOUSE,"BDE_BLUE_GND_WRIGHT_STAGE3_A2_REARM")
  state.rearmService=FixedFireSupportAmmoRearmService.New({
    fixedFireSupportAmmoSupportModule=FixedFireSupportAmmoSupport,groundAmmoRearmAdapterModule=GroundAmmoRearmAdapter,
    store=ctx.store,campaignState=ctx.campaignState,artyFactory=function(group) if group~=state.battery then error(TAG.." wrong battery",2) end; return state.arty end,
    brigade=rearmBrigade,spawnZone=supportZone,spawnZoneMaxDistanceM=500,materializerModule=GroundSupportMaterializer,
    platoonFactory=function(t,c,n) return PLATOON:New(t,c,n) end,descriptorGroupName=WAREHOUSE.Descriptor.GROUPNAME,templateName=M1083_TEMPLATE,
    platoonName="PLT_BLUE_GND_WRIGHT_STAGE3_A2_REARM",assignment="OMW:WRIGHT:AMMO-SUPPORT:STAGE3-A2",carrierEntityId="WRIGHT-AMMO-SUPPORT-M1083-STAGE3-A2",
    nodeId=WRIGHT_NODE,alias="Wright L118 Stage3 A2",stockCount=1,priority=20,returnCheckIntervalSec=5,returnTimeoutSec=300,
    log=function(level,text) log("REARM "..tostring(level).." "..tostring(text)) end,
    onRearmed=function() state.rearmComplete=true; msg("FIRE SUPPORT","Wright local L118 rearm complete; CampaignState AMMO 15 / 30",12) end,
    onSupportReturned=function() state.supportReturned=true; startAirResupply() end,
    onSupportReturnFailed=function(_,reason) fail("Wright M1083 return failed: "..tostring(reason)) end,
  })
  state.fireAdapter=FireAdapter.New({
    missionDemand=MissionDemand,registry=registry,arty=state.arty,assigneeId="ARTY:WRIGHT:L118",priority=10,radiusM=50,shells=FIRE_SHELLS,maxEngagements=1,weaponType=ARTY.WeaponType.Auto,
    onFireStarted=function(_,target)
      state.fireStarted=true; local name=target and target.name or "unknown"; local ammo=state.arty:GetAmmo(false)
      if state.physicalAmmoBefore==nil then state.physicalAmmoBefore=ammo end
      state.physicalAmmoBeforeByTarget[name]=ammo; state.firePhysicalShotsByTarget[name]=0; state.fireActiveTargetName=name
    end,
    verifyFireComplete=function(_,target)
      local name=target and target.name or "unknown"; local after=state.arty:GetAmmo(false); state.physicalAmmoAfterByTarget[name]=after; state.physicalAmmoAfter=after; state.fireActiveTargetName=nil
      if (state.firePhysicalShotsByTarget[name] or 0)<1 then return false,"NO_MOOSE_ARTY_EVENTS_SHOT" end
      return true
    end,
    onTargetComplete=function(demandId) state.fireTargetCompleteCount=state.fireTargetCompleteCount+1; queueNextFireMission(demandId) end,
    onFireRejected=function(_,_,_,reason) fail("Wright L118 physical fire not confirmed: "..tostring(reason)) end,
    onFireComplete=function(demandId)
      state.fireCycleActive=false; state.fireComplete=true
      if not state.rearmComplete then
        state.rearmService:Request({transactionId=REARM_TX,missionDemandId=demandId,nodeId=WRIGHT_NODE,resourceId=AMMO_RESOURCE,quantity=1,
          artilleryGroup=state.battery,alias="Wright L118 Stage3 A2",onRoad=false,rearmingDistance=100,supportReturnRadiusM=100,startArty=false})
      end
    end,
  })
  local previousShot=state.arty.OnEventShot
  function state.arty:OnEventShot(EventData)
    if previousShot then previousShot(self,EventData) end
    if not EventData or EventData.IniGroupName~=state.battery:GetName() or not state.fireActiveTargetName then return end
    local name=state.fireActiveTargetName; state.firePhysicalShotsByTarget[name]=(state.firePhysicalShotsByTarget[name] or 0)+1; state.firePhysicalShotsTotal=state.firePhysicalShotsTotal+1
  end
  return true
end
local function stage3IncidentFor(demand,context)
  local source=context and context.incident and context.incident.context or {}
  return {incidentId=demand.incidentId,installationId=state.site.installationId,priority=demand.priority or 90,position=source.position,reportedTarget=source.reportedTarget}
end
local function dispatchStage3Arty(demand,context)
  if state.fireDemand then return {Cancel=function() return false end},false,"ALREADY_DISPATCHED" end
  local target=selectNextFireTarget(); if not target then return nil,false,"C2_FIRE_TARGET_UNAVAILABLE" end
  if not reportFireMission(target,1) then return nil,false,"TARGET_REJECTED" end
  local p=target:GetCoordinate():GetVec3(); local incident=stage3IncidentFor(demand,context)
  local md,created,reason=FirePolicy.CreateDemand(MissionDemand,registry,incident,{targetKind="DETECTED_RED_GROUND_GROUP",targetName=target:GetName(),position={x=p.x,y=p.y,z=p.z}})
  if created~=true then return nil,false,reason end
  local _,dispatched,why=state.fireAdapter:Dispatch(md,target); if dispatched~=true then return nil,false,why end
  state.fireDemand=md; state.fireDemands[1]=md.id; state.fireCycleNumber=1; state.fireCycleActive=true; state.fireTargetCount=1; state.fireScheduledSourceGroups[target:GetName()]=true
  msg("C2","Deterministic Acceptance provider allocation: Wright L118 selected for generic FSSR ARTY demand",12)
  return {Cancel=function() return false,"ARTY_CANCEL_NOT_EXERCISED_IN_STAGE3_A2" end},true,nil
end
local function dispatchStage3Cas(demand,context)
  if state.casDemand then return {Cancel=function() return false end},false,"ALREADY_DISPATCHED" end
  local incident=stage3IncidentFor(demand,context)
  local md,created,reason=CasPolicy.CreateDemand(MissionDemand,registry,incident); if created~=true then return nil,false,reason end
  state.casDemand=md; if not ensureCasContext() then return nil,false,"CAS_CONTEXT_FAILED" end
  local mission,dispatched,why=state.casAdapter:Dispatch(md,state.casTacticalZone); if dispatched~=true then return nil,false,why end
  state.casMission=mission; state.casSupportRequirementActive=true
  local prev=mission.OnAfterExecuting
  function mission:OnAfterExecuting(F,E,T) if prev then prev(self,F,E,T) end; state.casExecuting=true end
  msg("C2","Deterministic Acceptance provider allocation: Jalalabad AH-64D selected for generic FSSR CAS demand",12)
  local handle={cancelRequested=false}
  function handle:Cancel()
    if self.cancelRequested then return false end
    self.cancelRequested=true
    local _,changed,closeReason=state.casAdapter:RequestMissionClosure(state.casDemand.id,"FSSR_BASE_CANCEL")
    return changed==true,closeReason
  end
  return handle,true,nil
end
