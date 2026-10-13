-- Operation Mountain Watch - Production Base Acceptance 10.
-- Real fixed ARTY/Mortar asset materialization -> MOOSE COMMANDER selection ->
-- existing Functional ARTY fire owner -> accepted M1083/CampaignState rearm.
--
-- Harness role: composition, stimulus, observation and assertion only.
-- It does not select a provider, queue AUFTRAG:NewARTY through COMMANDER,
-- move a fixed battery, implement a second fire-control owner or reimplement
-- the accepted M1083/ARTY rearm FSM.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A10]"
local TEST_TIMEOUT_SEC=1800
local POLL_SEC=2
local POSITION_TOLERANCE_M=1.0
local RESOURCE_ID="GROUND_AMMO_PACKAGE"
local DEMAND_ID="FSSR-A10-REAL-ARTY-SELECTION"

local SITE_SPECS={
  BOSTICK={
    siteId="BOSTICK",warehouse="WH_BLUE_GND_BOSTICK",
    template="TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",platoon="BostickArtillery",
    weaponType="L118_Unit",nodeId="GROUND_NODE_BOSTICK",
    supportZone="ZON_BLUE_GND_BOSTICK_RESUPPLY",alias="Bostick L118 A10",
  },
  WRIGHT={
    siteId="WRIGHT",warehouse="WH_BLUE_GND_WRIGHT",
    template="TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",platoon="WrightArtillery",
    weaponType="L118_Unit",nodeId="GROUND_NODE_WRIGHT",
    supportZone="ZON_BLUE_GND_WRIGHT_RESUPPLY",alias="Wright L118 A10",
  },
  FORTRESS={
    siteId="FORTRESS",warehouse="WH_BLUE_GND_FORTRESS",
    template="TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1",platoon="FortressArtillery",
    weaponType="L118_Unit",nodeId="GROUND_NODE_FORTRESS",
    supportZone="ZON_BLUE_GND_FORTRESS_RESUPPLY",alias="Fortress L118 A10",
  },
  HONAKER={
    siteId="HONAKER",warehouse="WH_BLUE_GND_HONAKER",
    template="TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2",platoon="HonakerMortar",
    weaponType="2B11 mortar",nodeId="GROUND_NODE_HONAKER",
    supportZone="ZON_BLUE_GND_HONAKER_RESUPPLY",alias="Honaker 2B11 A10",
    requireAmmoDepleted=true,
  },
}

local state={
  failed=false,passed=false,startedAt=nil,
  commander=nil,brigades={},registry=nil,selection=nil,targetCoordinate=nil,
  owners={},materializationSnapshot={},selectedSiteId=nil,selectionState=nil,
  initialAmmo=nil,postFireAmmo=nil,finalAmmo=nil,rearmService=nil,rearmRequested=false,
  resourceBefore=nil,supportReturned=false,
}

local function log(message) env.info(TAG.." "..tostring(message),false) end
local function announce(kind,message,time)
  local text="[PRODUCTION BASE A10]["..kind.."] "..message
  log(text)
  MESSAGE:New(text,time or 10):ToAll()
end
local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  announce("FAIL",message,40)
end
local function requireObject(value,label)
  if value==nil then fail("MISSING_OBJECT "..tostring(label)); return nil end
  return value
end
local function package()
  return OMW and OMW.FireSupStratResupply or nil
end
local function modules()
  local p=package()
  return p and p.Modules or nil
end
local function groundContext()
  if type(OMW)~="table" or type(OMW.Ground)~="table" or type(OMW.Ground.Base)~="table"
      or type(OMW.Ground.Base.GetContext)~="function" then return nil end
  return OMW.Ground.Base.GetContext()
end
local function dist2(a,b)
  local dx=a.x-b.x
  local dy=a.y-b.y
  return math.sqrt(dx*dx+dy*dy)
end
local function ammoTotal(arty)
  local total,shells,rockets,missiles,artilleryShells=arty:GetAmmo(false)
  log("ARTY_AMMO total="..tostring(total).." shells="..tostring(shells)
    .." rockets="..tostring(rockets).." missiles="..tostring(missiles)
    .." artilleryShells="..tostring(artilleryShells))
  return total
end

local function liveUnitPositions(group)
  local result={}
  for index,unit in ipairs(group:GetUnits() or {}) do
    local coordinate=unit:GetCoordinate()
    local vec2=coordinate and coordinate:GetVec2() or nil
    if not vec2 then return nil,"UNIT_COORDINATE_UNAVAILABLE index="..tostring(index) end
    result[index]={x=vec2.x,y=vec2.y}
  end
  return result,nil
end

local function verifyExactMaterialization(siteId)
  local definition=state.registry:GetAsset(siteId)
  if not definition or not definition.asset or not definition.asset.flightgroup then
    return false,"REAL_ASSET_UNAVAILABLE site="..siteId
  end
  local group=definition.asset.flightgroup:GetGroup()
  if not group or group:IsAlive()~=true then return false,"REAL_GROUP_NOT_ALIVE site="..siteId end
  local expected=definition.asset.template and definition.asset.template.units or nil
  local actual=group:GetUnits() or {}
  if type(expected)~="table" then return false,"ASSET_TEMPLATE_UNAVAILABLE site="..siteId end
  if #expected~=#actual then
    return false,"UNIT_COUNT_MISMATCH site="..siteId.." expected="..tostring(#expected).." actual="..tostring(#actual)
  end
  local snapshot={}
  for i,unit in ipairs(actual) do
    local coordinate=unit:GetCoordinate()
    local vec2=coordinate and coordinate:GetVec2() or nil
    if not vec2 then return false,"UNIT_COORDINATE_UNAVAILABLE site="..siteId.." index="..tostring(i) end
    local dx=vec2.x-expected[i].x
    local dy=vec2.y-expected[i].y
    local delta=math.sqrt(dx*dx+dy*dy)
    if delta>POSITION_TOLERANCE_M then
      return false,string.format("EXACT_POSITION_MISMATCH site=%s index=%d deltaM=%.3f",siteId,i,delta)
    end
    snapshot[i]={x=vec2.x,y=vec2.y}
    log(string.format("EXACT_POSITION_PASS site=%s index=%d deltaM=%.3f x=%.3f y=%.3f",
      siteId,i,delta,vec2.x,vec2.y))
  end
  state.materializationSnapshot[siteId]=snapshot
  return true,nil
end

local function verifyNoMovement(siteId,label)
  local definition=state.registry:GetAsset(siteId)
  local baseline=state.materializationSnapshot[siteId]
  if not definition or not definition.asset or not definition.asset.flightgroup or not baseline then
    return false,"NO_MOVEMENT_BASELINE_UNAVAILABLE site="..siteId
  end
  local group=definition.asset.flightgroup:GetGroup()
  local actual,reason=liveUnitPositions(group)
  if not actual then return false,reason end
  if #actual~=#baseline then return false,"NO_MOVEMENT_UNIT_COUNT_CHANGED site="..siteId end
  for i,pos in ipairs(actual) do
    local delta=dist2(pos,baseline[i])
    if delta>POSITION_TOLERANCE_M then
      return false,string.format("FIXED_BATTERY_MOVED site=%s phase=%s index=%d deltaM=%.3f",siteId,label,i,delta)
    end
  end
  log("FIXED_BATTERY_STATIONARY site="..siteId.." phase="..label)
  return true,nil
end

local function allMaterialized()
  for siteId,_ in pairs(SITE_SPECS) do
    if not state.registry:IsMaterialized(siteId) then return false end
  end
  return true
end

local function makeTargetCoordinate()
  local wright=state.registry:GetAsset("WRIGHT")
  local honaker=state.registry:GetAsset("HONAKER")
  local wx,wy=wright.spawnVec2.x,wright.spawnVec2.y
  local hx,hy=honaker.spawnVec2.x,honaker.spawnVec2.y
  local midpoint={x=(wx+hx)/2,y=(wy+hy)/2}
  local target=COORDINATE:NewFromVec2(midpoint)

  local wrightDistance=state.brigades.WRIGHT:GetCoordinate():Get2DDistance(target)
  local honakerDistance=state.brigades.HONAKER:GetCoordinate():Get2DDistance(target)
  local wrightRange=wright.rangeMaxMeters
  local honakerRange=honaker.rangeMaxMeters
  if wrightDistance>wrightRange or honakerDistance>honakerRange then
    fail(string.format("MULTI_PROVIDER_TARGET_NOT_ELIGIBLE wright=%.1f/%.1f honaker=%.1f/%.1f",
      wrightDistance,wrightRange,honakerDistance,honakerRange))
    return nil
  end
  log(string.format("MULTIPLE_ELIGIBLE_PROVIDERS target=WRIGHT_HONAKER_MIDPOINT wrightDistanceM=%.1f wrightMaxM=%.1f honakerDistanceM=%.1f honakerMaxM=%.1f",
    wrightDistance,wrightRange,honakerDistance,honakerRange))
  return target
end

local function buildRearmService(siteId,group,arty)
  local spec=SITE_SPECS[siteId]
  local context=groundContext()
  if type(context)~="table" or type(context.store)~="table" or type(context.campaignState)~="table" then
    fail("AUTHORITATIVE_CAMPAIGN_CONTEXT_UNAVAILABLE")
    return nil
  end
  local supportZone=requireObject(ZONE:FindByName(spec.supportZone),spec.supportZone)
  if state.failed then return nil end
  local supportBrigade=requireObject(BRIGADE:New(spec.warehouse,"BDE_FSSR_A10_REARM_"..siteId),"support brigade "..siteId)
  if state.failed then return nil end

  local service=FixedFireSupportAmmoRearmService.New({
    fixedFireSupportAmmoSupportModule=FixedFireSupportAmmoSupport,
    groundAmmoRearmAdapterModule=GroundAmmoRearmAdapter,
    store=context.store,
    campaignState=context.campaignState,
    artyFactory=function(artilleryGroup)
      if artilleryGroup~=group then error(TAG.." unexpected artillery group for rearm site="..siteId,2) end
      return arty
    end,
    brigade=supportBrigade,
    spawnZone=supportZone,
    spawnZoneMaxDistanceM=500,
    materializerModule=GroundSupportMaterializer,
    platoonFactory=function(templateName,count,platoonName) return PLATOON:New(templateName,count,platoonName) end,
    descriptorGroupName=WAREHOUSE.Descriptor.GROUPNAME,
    templateName="TPL_BLUE_GND_SUP_M1083",
    platoonName="PLT_FSSR_A10_REARM_"..siteId,
    assignment="OMW:A10:"..siteId..":AMMO-SUPPORT",
    carrierEntityId="A10-"..siteId.."-M1083",
    nodeId=spec.nodeId,
    alias=spec.alias,
    stockCount=1,
    priority=20,
    returnCheckIntervalSec=5,
    returnTimeoutSec=300,
    log=function(level,message) log("REARM_LOG site="..siteId.." level="..tostring(level).." "..tostring(message)) end,
    onRearmed=function()
      state.finalAmmo=ammoTotal(arty)
      log("REARM_COMPLETED site="..siteId.." finalAmmo="..tostring(state.finalAmmo))
    end,
    onSupportReturned=function(contextReturn)
      state.supportReturned=true
      log("M1083_RETURNED_TO_STOCK site="..siteId.." transactionId="..tostring(contextReturn.transactionId))
    end,
    onSupportReturnFailed=function(_,reason)
      fail("M1083_RETURN_FAILED site="..siteId.." reason="..tostring(reason))
    end,
  })
  return service,context
end

local function resolveFunctionalOwner(definition,asset,legion,group)
  local existing=state.owners[definition.id]
  if existing then return existing,nil end

  local arty=ARTY:New(group,definition.id.." A10")
  if not arty then return nil,"ARTY_CREATE_FAILED site="..definition.id end
  arty:SetReportOFF()
  arty:SetWaitForShotTime(120)
  arty:Start()

  local owner={
    arty=arty,
    priority=10,
    maxEngagements=1,
    acceptedRadiusM=50,
    acceptedShots=definition.id=="HONAKER" and 40 or 4,
    weaponType=ARTY.WeaponType.Auto,
  }
  state.owners[definition.id]=owner
  log("FUNCTIONAL_ARTY_OWNER_CREATED site="..definition.id.." group="..group:GetName()
    .." acceptedShots="..tostring(owner.acceptedShots))
  return owner,nil
end

local function dispatchSelection()
  state.targetCoordinate=makeTargetCoordinate()
  if not state.targetCoordinate then return end

  local m=modules()
  local factory=m.artyMissionFactory.New({
    resolveTarget=function()
      return {coordinate=state.targetCoordinate,shots=4,radiusM=50},nil
    end,
    requiredAssetsMin=1,requiredAssetsMax=1,logger=log,
  })
  state.selection=m.artySelectionRuntime.New({
    commander=state.commander,
    artyMissionFactory=factory,
    resolveFunctionalArty=state.registry:GetResolver(),
    logger=log,
  })

  local demand={demandId=DEMAND_ID,supportType="ARTY",siteId="A10_MULTI_PROVIDER",priority=10}
  local handle,created,reason=state.selection:Dispatch(demand,{acceptance="A10"})
  if not handle or created~=true then
    fail("ARTY_SELECTION_DISPATCH_FAILED reason="..tostring(reason))
    return
  end
  local selectionState=state.selection:GetState(DEMAND_ID)
  if not selectionState or not selectionState.owner then fail("ARTY_SELECTION_STATE_UNAVAILABLE"); return end
  state.selectionState=selectionState
  state.selectedSiteId=selectionState.owner.realAssetId
  if state.selectedSiteId~="WRIGHT" and state.selectedSiteId~="HONAKER" then
    fail("MOOSE_SELECTED_OUT_OF_RANGE_PROVIDER site="..tostring(state.selectedSiteId))
    return
  end
  state.initialAmmo=ammoTotal(selectionState.arty)
  if not state.initialAmmo or state.initialAmmo<=0 then fail("INITIAL_AMMO_INVALID"); return end
  log("MOOSE_REAL_ARTY_SELECTED site="..state.selectedSiteId
    .." legion="..tostring(selectionState.legion and (selectionState.legion.alias or selectionState.legion.name))
    .." asset="..tostring(selectionState.asset and selectionState.asset.spawngroupname)
    .." initialAmmo="..tostring(state.initialAmmo))
end

local function requestRearmIfReady()
  if state.rearmRequested or not state.selectionState then return end
  local entry=state.selection:GetState(DEMAND_ID)
  if not entry or not entry.completed or not entry.released then return end

  local stationary,moveReason=verifyNoMovement(state.selectedSiteId,"POST_FIRE")
  if not stationary then fail(moveReason); return end
  state.postFireAmmo=ammoTotal(entry.arty)
  if not state.postFireAmmo or state.postFireAmmo>=state.initialAmmo then
    fail("FIRE_DID_NOT_CONSUME_AMMO initial="..tostring(state.initialAmmo).." postFire="..tostring(state.postFireAmmo))
    return
  end
  if state.selectedSiteId=="HONAKER" and state.postFireAmmo~=0 then
    fail("HONAKER_AMMO_NOT_DEPLETED expected=0 actual="..tostring(state.postFireAmmo))
    return
  end

  local definition=state.registry:GetAsset(state.selectedSiteId)
  local group=definition.asset.flightgroup:GetGroup()
  local service,context=buildRearmService(state.selectedSiteId,group,entry.arty)
  if not service then return end
  state.rearmService=service
  state.resourceBefore=context.store:GetResource(SITE_SPECS[state.selectedSiteId].nodeId,RESOURCE_ID)
  if not state.resourceBefore then fail("RESOURCE_BEFORE_UNAVAILABLE"); return end

  state.rearmRequested=true
  local txId="FSSR-A10-REARM-"..state.selectedSiteId
  local rearmContext=service:Request({
    transactionId=txId,
    missionDemandId=DEMAND_ID,
    nodeId=SITE_SPECS[state.selectedSiteId].nodeId,
    resourceId=RESOURCE_ID,
    quantity=1,
    artilleryGroup=group,
    alias=SITE_SPECS[state.selectedSiteId].alias,
    onRoad=false,
    rearmingDistance=100,
    supportReturnRadiusM=100,
    startArty=false,
  })
  log("M1083_REARM_REQUESTED site="..state.selectedSiteId.." transactionId="..txId
    .." status="..tostring(rearmContext and rearmContext.status)
    .." resourceBefore="..tostring(state.resourceBefore.available))
end

local function evaluatePass()
  if not state.rearmRequested or not state.supportReturned then return end
  local entry=state.selection:GetState(DEMAND_ID)
  if not entry or not entry.released then fail("SELECTION_RESERVATION_NOT_RELEASED"); return end
  local stationary,moveReason=verifyNoMovement(state.selectedSiteId,"POST_REARM")
  if not stationary then fail(moveReason); return end
  if not state.finalAmmo or state.finalAmmo<state.initialAmmo then
    fail("AMMO_NOT_RESTORED initial="..tostring(state.initialAmmo).." final="..tostring(state.finalAmmo))
    return
  end
  local context=groundContext()
  local resourceAfter=context.store:GetResource(SITE_SPECS[state.selectedSiteId].nodeId,RESOURCE_ID)
  if not resourceAfter or resourceAfter.available~=state.resourceBefore.available-1 then
    fail("CAMPAIGNSTATE_RESOURCE_DEBIT_INVALID before="..tostring(state.resourceBefore and state.resourceBefore.available)
      .." after="..tostring(resourceAfter and resourceAfter.available))
    return
  end
  state.passed=true
  announce("PASS","real MOOSE ARTY assets materialized at exact ME positions; Wright and Honaker were both eligible; COMMANDER selected the real spawned asset; Functional ARTY fired without battery movement; selection reservation released; accepted M1083/CampaignState rearm completed and returned to stock.",45)
end

local function evaluate()
  if state.failed or state.passed then return end
  if not state.selectionState then
    if not allMaterialized() then
      if timer.getTime()-state.startedAt>60 then fail("REAL_ASSET_MATERIALIZATION_TIMEOUT") end
      return
    end
    for siteId,_ in pairs(SITE_SPECS) do
      local ok,reason=verifyExactMaterialization(siteId)
      if not ok then fail(reason); return end
    end
    dispatchSelection()
    return
  end
  requestRearmIfReady()
  evaluatePass()
  if timer.getTime()-state.startedAt>TEST_TIMEOUT_SEC then
    fail("TIMEOUT selected="..tostring(state.selectedSiteId)
      .." started="..tostring(state.selectionState and state.selectionState.started)
      .." completed="..tostring(state.selectionState and state.selectionState.completed)
      .." released="..tostring(state.selectionState and state.selectionState.released)
      .." rearmRequested="..tostring(state.rearmRequested)
      .." supportReturned="..tostring(state.supportReturned))
  end
end

local function start()
  if OMW_GROUND_READY~=1 then fail("GROUND_BASE_NOT_READY flag="..tostring(OMW_GROUND_READY)); return end
  local p=package()
  local m=modules()
  if type(p)~="table" or type(m)~="table" then fail("FSSR_PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  if type(m.artyRealAssetRegistry)~="table" or type(m.artyRealAssetRegistry.New)~="function" then
    fail("ARTY_REAL_ASSET_REGISTRY_UNAVAILABLE"); return
  end
  if type(m.artySelectionRuntime)~="table" or type(m.artyMissionFactory)~="table" then
    fail("ARTY_SELECTION_MODULES_UNAVAILABLE"); return
  end
  if not requireObject(GROUP:FindByName("TPL_BLUE_GND_SUP_M1083"),"TPL_BLUE_GND_SUP_M1083") then return end

  state.commander=COMMANDER:New(coalition.side.BLUE,"OMW_FSSR_BASE_A10_C2")
  if not state.commander then fail("COMMANDER_CREATE_FAILED"); return end
  state.commander:SetVerbosity(2)

  local assets={}
  for siteId,spec in pairs(SITE_SPECS) do
    local template=requireObject(GROUP:FindByName(spec.template),spec.template)
    if not template then return end
    if template:IsAlive()==true then fail("ARTY_TEMPLATE_MUST_BE_LATE_ACTIVATION site="..siteId); return end
    local brigade=requireObject(BRIGADE:New(spec.warehouse,"BDE_FSSR_A10_"..siteId),"site brigade "..siteId)
    if not brigade then return end
    state.brigades[siteId]=brigade
    assets[#assets+1]={
      id=siteId,siteId=siteId,templateName=spec.template,platoonName=spec.platoon,
      weaponTypeName=spec.weaponType,performance=50,
    }
  end

  state.registry=m.artyRealAssetRegistry.New({
    commander=state.commander,
    brigades=state.brigades,
    assets=assets,
    platoonFactory=function(templateName,count,platoonName) return PLATOON:New(templateName,count,platoonName) end,
    resolveTemplateGroup=function(name) return GROUP:FindByName(name) end,
    resolveFunctionalArty=resolveFunctionalOwner,
    logger=log,
  })

  for siteId,brigade in pairs(state.brigades) do
    brigade:Start()
    log("SITE_BRIGADE_STARTED site="..siteId.." alias="..tostring(brigade.alias))
  end
  state.commander:Start()
  state.startedAt=timer.getTime()
  announce("READY","A10 real fixed-fire-support assets are being materialized by MOOSE at their original Mission Editor positions. No fixed battery movement mission is queued.",20)
  SCHEDULER:New(nil,evaluate,{},POLL_SEC,POLL_SEC)
end

SCHEDULER:New(nil,start,{},10)
