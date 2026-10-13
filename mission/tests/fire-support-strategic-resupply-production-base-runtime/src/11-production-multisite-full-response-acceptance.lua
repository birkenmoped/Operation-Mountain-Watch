-- Operation Mountain Watch - Production Base Acceptance 11.
-- Combined multi-installation autonomous full-response acceptance.
--
-- Harness role: composition, fixture stimulus, observation and assertion only.
-- Production modules own Guard/QRF, ARTY fire control, CAS route/release/recovery,
-- OPSTRANSPORT routing/cargo/settlement and all MOOSE provider/asset selection.

local TAG="[OMW][FSSR-PRODUCTION-BASE-A11]"

local START_DELAY_SEC=10
local POLL_SEC=2
local WATCHDOG_SEC=3600
local POSITION_TOLERANCE_M=1.0
local FIXTURE_ROUTE_SPEED_KMH=20
local INTRUSION_DEPTH_FRACTION=0.65

local GUARD_TEMPLATE="TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE="TPL_BLUE_GND_QRF_MIXED_6"

local CAS_RADIUS_NM=5
local CAS_RANGE_NM=5
local CAS_SPEED_KTS=125
local CAS_ALTITUDE_FT_AGL=2500

local FLIGHTPATH_BASE="OMW_FlightPath"
local RESUPPLY_PICKUP_ZONE="ZON_BLUE_LOG_SLG_JALALABAD_01"
local RESUPPLY_DROP_ZONE="OMW_BLUE_LZ_WRIGHT_01"
local RESUPPLY_SOURCE_STORAGE_NAME="OMW_FSSR_A11_SOURCE_STORAGE"
local RESUPPLY_DEST_STORAGE_NAME="OMW_FSSR_A11_WRIGHT_STORAGE"
local RESUPPLY_RESOURCE_ID="GROUND_AMMO_PACKAGE"
local RESUPPLY_CARGO_TYPE=ENUMS.Storage.weapons.bombs.Mk_82
local RESUPPLY_CARGO_AMOUNT=4
local RESUPPLY_ITEM_WEIGHT_KG=230
local RESUPPLY_TOTAL_WEIGHT_KG=RESUPPLY_CARGO_AMOUNT*RESUPPLY_ITEM_WEIGHT_KG
local RESUPPLY_ALTITUDE_FT_AGL=500
local RESUPPLY_SPEED_KTS=125
local RESUPPLY_LEAD_TURN_M=250

local ATTACK_SITES={
  {siteId="FOB_JOYCE",fixture="BadGuys_A3_JOYCE"},
  {siteId="FOB_WRIGHT",fixture="BadGuys_A3_WRIGHT"},
  {siteId="COP_HONAKER",fixture="BadGuys_A3_HONAKER"},
}

local FIXED_ASSETS={
  BOSTICK={
    siteId="FOB_BOSTICK",templateName="TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",
    platoonName="BostickArtillery",weaponTypeName="L118_Unit",
  },
  WRIGHT={
    siteId="FOB_WRIGHT",templateName="TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",
    platoonName="WrightArtillery",weaponTypeName="L118_Unit",
  },
  FORTRESS={
    siteId="COP_FORTRESS",templateName="TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1",
    platoonName="FortressArtillery",weaponTypeName="L118_Unit",
  },
  HONAKER={
    siteId="COP_HONAKER",templateName="TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2",
    platoonName="HonakerMortar",weaponTypeName="2B11 mortar",
  },
}

local state={
  failed=false,passed=false,startedAt=nil,watchdogWarned=false,
  package=nil,modules=nil,runtime=nil,base=nil,commander=nil,
  brigades={},site={},perimeters={},registry=nil,owners={},materializationSnapshot={},
  fixturesReleased=false,supportRequested=false,
  artyDemands={},artyObserved={},artySeenL118=false,artySeenMortar=false,
  casDemands={},casEvidence={},
  resupplyRow=nil,resupplyDemand=nil,resupplySourceBefore=nil,resupplyDestinationBefore=nil,
  sourceStatic=nil,destStatic=nil,sourceStorage=nil,destStorage=nil,
  pickupZone=nil,dropZone=nil,resolvedTransportCorridor=nil,
  resupplyOutbound=false,resupplyReturn=false,resupplyHome=false,resupplyReturned=false,
  resupplyTerminal=nil,resupplyAsset=nil,resupplyLegion=nil,resupplyObserversInstalled=false,
}

local function log(message) env.info(TAG.." "..tostring(message),false) end
local function announce(kind,message,time)
  local text="[PRODUCTION BASE A11]["..kind.."] "..tostring(message)
  log(text)
  MESSAGE:New(text,time or 12):ToAll()
end
local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  announce("FAIL",message,45)
end
local function need(value,label)
  if value==nil then fail("MISSING_OBJECT "..tostring(label)); return nil end
  return value
end
local function package()
  return OMW and OMW.FireSupStratResupply or nil
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
  local total=arty:GetAmmo(false)
  return total
end
local function tableCount(value)
  local count=0
  for _ in pairs(value or {}) do count=count+1 end
  return count
end

local function focusedRegistry(p)
  local sites={}
  for _,d in ipairs(ATTACK_SITES) do sites[d.siteId]=p.SiteRegistry.Sites[d.siteId] end
  return {
    SchemaVersion=p.SiteRegistry.SchemaVersion,
    GuardTemplateName=p.SiteRegistry.GuardTemplateName,
    Sites=sites,
  }
end

local function discoverAirwings(commander)
  if type(OMW)~="table" or type(OMW.AirOps)~="table" then return 0 end
  local count=0
  local seen={}
  local function add(airwing)
    if type(airwing)~="table" then return end
    local alias=tostring(airwing.alias or airwing.name or airwing)
    if seen[airwing] then return end
    seen[airwing]=true
    commander:AddAirwing(airwing)
    count=count+1
    log("C2_AIRWING_REGISTERED alias="..alias)
  end
  for _,node in pairs(OMW.AirOps) do
    if type(node)=="table" and node.Status=="RUNNING" then
      add(node.Airwing)
      for _,airwing in pairs(node.Airwings or {}) do add(airwing) end
    end
  end
  return count
end

local function isAttackSite(siteId)
  for _,d in ipairs(ATTACK_SITES) do if d.siteId==siteId then return true end end
  return false
end

local function ensureBrigade(siteId)
  if state.brigades[siteId] then return state.brigades[siteId] end
  local site=state.package.SiteRegistry.Sites[siteId]
  if not site then fail("SITE_REGISTRY_MISSING "..tostring(siteId)); return nil end

  local brigade=BRIGADE:New(site.warehouseName,"BDE_FSSR_A11_"..siteId)
  if not brigade then fail("BRIGADE_CREATE_FAILED "..siteId); return nil end

  if isAttackSite(siteId) then
    local guard=PLATOON:New(site.guardTemplateName,1,"PLT_FSSR_A11_GUARD_"..siteId)
    local qrf=PLATOON:New(QRF_TEMPLATE,1,"PLT_FSSR_A11_QRF_"..siteId)
    guard:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
    qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
    brigade:AddPlatoon(guard)
    brigade:AddPlatoon(qrf)

    state.site[siteId]={
      fixtureActivated=false,incident=nil,guardObserved=false,qrfObserved=false,qrfEngage=false,
    }

    local previous=brigade.OnAfterArmyOnMission
    brigade.OnAfterArmyOnMission=function(self,From,Event,To,armyGroup,mission)
      if previous then previous(self,From,Event,To,armyGroup,mission) end
      local group=armyGroup and armyGroup:GetGroup() or nil
      if not group then return end
      local attribute=group:GetAttribute()
      local siteState=state.site[siteId]
      if attribute==GROUP.Attribute.GROUND_INFANTRY then
        siteState.guardObserved=true
        siteState.guardGroup=group
        log("GUARD_OBSERVED siteId="..siteId.." group="..tostring(group:GetName()))
      elseif attribute==GROUP.Attribute.GROUND_APC then
        if siteState.qrfArmy and siteState.qrfArmy~=armyGroup then
          fail("QRF_DOUBLE_BOOKED siteId="..siteId)
          return
        end
        siteState.qrfArmy=armyGroup
        siteState.qrfGroup=group
        siteState.qrfObserved=true
        log("QRF_OBSERVED siteId="..siteId.." group="..tostring(group:GetName())
          .." missionType="..tostring(mission and mission:GetType()))
        local oldEngage=armyGroup.OnAfterEngageTarget
        armyGroup.OnAfterEngageTarget=function(selfArmy,F,E,T,target,speed,formation)
          if oldEngage then oldEngage(selfArmy,F,E,T,target,speed,formation) end
          siteState.qrfEngage=true
          log("QRF_DIRECT_TARGET_ENGAGE siteId="..siteId
            .." target="..tostring(target and target.GetName and target:GetName() or "unknown")
            .." formation="..tostring(formation))
        end
      end
    end
  end

  state.brigades[siteId]=brigade
  return brigade
end

local function buildPerimeters()
  for _,d in ipairs(ATTACK_SITES) do
    local site=state.package.SiteRegistry.Sites[d.siteId]
    local alarm=site and site.alarm
    if type(alarm)~="table" or type(alarm.radiusM)~="number" or alarm.radiusM<=0 then
      fail("ALARM_CONFIG_INVALID "..d.siteId); return false
    end

    local anchor
    if alarm.anchorKind=="WAREHOUSE" then
      local brigade=state.brigades[d.siteId]
      anchor=brigade and brigade:GetCoordinate() or nil
    elseif alarm.anchorKind=="MOOSE_ZONE" then
      local source=ZONE:FindByName(alarm.anchorName)
      anchor=source and source:GetCoordinate() or nil
    else
      fail("ALARM_ANCHOR_KIND_UNSUPPORTED "..d.siteId.." "..tostring(alarm.anchorKind)); return false
    end
    if not anchor then fail("ALARM_ANCHOR_UNAVAILABLE "..d.siteId); return false end

    state.site[d.siteId].alarmAnchor=anchor
    state.perimeters[d.siteId]={
      anchorCoordinate=anchor,
      securityZone=nil,
      zoneName="OMW_SECURITY_"..site.installationId,
      radiusM=alarm.radiusM,
      priority=0,
    }
    log(string.format("PERIMETER_CONFIG siteId=%s radiusM=%.1f",d.siteId,alarm.radiusM))
  end
  return true
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

local function verifyExactMaterialization(assetId)
  local definition=state.registry:GetAsset(assetId)
  if not definition or not definition.asset or not definition.asset.flightgroup then
    return false,"REAL_ASSET_UNAVAILABLE assetId="..assetId
  end
  local group=definition.asset.flightgroup:GetGroup()
  if not group or group:IsAlive()~=true then return false,"REAL_GROUP_NOT_ALIVE assetId="..assetId end
  local expected=definition.asset.template and definition.asset.template.units or nil
  local actual=group:GetUnits() or {}
  if type(expected)~="table" or #expected~=#actual then
    return false,"REAL_ASSET_UNIT_CARDINALITY_MISMATCH assetId="..assetId
  end
  local snapshot={}
  for index,unit in ipairs(actual) do
    local vec2=unit:GetCoordinate():GetVec2()
    local delta=dist2(vec2,{x=expected[index].x,y=expected[index].y})
    if delta>POSITION_TOLERANCE_M then
      return false,string.format("EXACT_POSITION_MISMATCH assetId=%s index=%d deltaM=%.3f",assetId,index,delta)
    end
    snapshot[index]={x=vec2.x,y=vec2.y}
  end
  state.materializationSnapshot[assetId]=snapshot
  log("EXACT_POSITION_PASS assetId="..assetId)
  return true,nil
end

local function verifyNoMovement(assetId,label)
  local definition=state.registry:GetAsset(assetId)
  local baseline=state.materializationSnapshot[assetId]
  if not definition or not definition.asset or not definition.asset.flightgroup or not baseline then
    return false,"FIXED_POSITION_BASELINE_UNAVAILABLE assetId="..assetId
  end
  local actual,reason=liveUnitPositions(definition.asset.flightgroup:GetGroup())
  if not actual then return false,reason end
  if #actual~=#baseline then return false,"FIXED_POSITION_UNIT_COUNT_CHANGED assetId="..assetId end
  for index,pos in ipairs(actual) do
    local delta=dist2(pos,baseline[index])
    if delta>POSITION_TOLERANCE_M then
      return false,string.format("FIXED_BATTERY_MOVED assetId=%s phase=%s index=%d deltaM=%.3f",assetId,label,index,delta)
    end
  end
  return true,nil
end

local function allFixedMaterialized()
  for assetId,_ in pairs(FIXED_ASSETS) do
    if not state.registry:IsMaterialized(assetId) then return false end
  end
  return true
end

local function resolveFunctionalOwner(definition,asset,legion,group)
  local existing=state.owners[definition.id]
  if existing then return existing,nil end

  local arty=ARTY:New(group,definition.id.." A11")
  if not arty then return nil,"ARTY_CREATE_FAILED assetId="..definition.id end
  arty:SetReportOFF()
  arty:SetWaitForShotTime(120)
  arty:Start()

  local owner={
    arty=arty,
    priority=10,
    maxEngagements=1,
    acceptedRadiusM=50,
    acceptedShots=4,
    weaponType=ARTY.WeaponType.Auto,
  }
  state.owners[definition.id]=owner
  log("FUNCTIONAL_ARTY_OWNER_CREATED assetId="..definition.id.." group="..group:GetName())
  return owner,nil
end

local function activeBaseIncident(siteId)
  local site=state.package.SiteRegistry.Sites[siteId]
  local incidentRuntime=state.runtime and state.runtime.installationIncidentRuntime or nil
  local coordinator=incidentRuntime and incidentRuntime:GetCoordinator(site.installationId) or nil
  local active=coordinator and coordinator:GetActive() or nil
  if not active then return nil end
  return state.base:GetIncident(state.package.IdContract.Incident(siteId,active.incidentId))
end

local function resolvePhysicalTarget(context,label)
  local incident=context and context.incident
  local physical=incident and incident.context and incident.context.physicalTargetGroup or nil
  if not physical or physical:IsAlive()~=true then return nil,label.."_PHYSICAL_TARGET_UNAVAILABLE" end
  local coordinate=physical:GetCoordinate()
  if not coordinate then return nil,label.."_TARGET_COORDINATE_UNAVAILABLE" end
  return coordinate,nil
end

local function resolveArtyTarget(_,context)
  local coordinate,reason=resolvePhysicalTarget(context,"ARTY")
  if not coordinate then return nil,reason end
  return {coordinate=coordinate,shots=4,radiusM=50},nil
end

local function resolveCasGeometry(demand,context)
  local coordinate,reason=resolvePhysicalTarget(context,"CAS")
  if not coordinate then return nil,reason end
  local zone=ZONE_RADIUS:New(
    "OMW_FSSR_A11_CAS_"..tostring(demand.demandId),
    coordinate:GetVec2(),UTILS.NMToMeters(CAS_RADIUS_NM))
  local altitudeFt=UTILS.MetersToFeet(zone:GetCoordinate():GetLandHeight())+CAS_ALTITUDE_FT_AGL
  return {
    missionMode="PATROLZONE_ENGAGE",
    zone=zone,
    altitudeFt=altitudeFt,
    speedKts=CAS_SPEED_KTS,
    engageDetectedRangeNm=CAS_RANGE_NM,
    engageDetectedTargetTypes={"Ground Units"},
    targetTypes={"Ground Units"},
    requiredAttributes=GROUP.Attribute.AIR_ATTACKHELO,
    configureMission=function(mission)
      mission:SetName("OMW_FSSR_A11_CAS_"..tostring(demand.siteId))
    end,
  },nil
end

local function onCasEvidence(fields,entry)
  local demandId=fields.demandId
  if type(demandId)=="string" then
    state.casEvidence[demandId]=state.casEvidence[demandId] or {}
    state.casEvidence[demandId][fields.event]=fields
  end
  log("CAS_EVIDENCE event="..tostring(fields.event)
    .." demandId="..tostring(demandId)
    .." provider="..tostring(fields.provider)
    .." asset="..tostring(fields.asset)
    .." reason="..tostring(fields.reason))
end

local function findGroundAmmoRow(nodeId)
  for _,row in ipairs(GroundInitialStock.Rows or {}) do
    if row.nodeId==nodeId and row.resourceId==RESUPPLY_RESOURCE_ID then return row end
  end
  return nil
end

local function seedAuthoritativeShortage()
  local context=groundContext()
  if type(context)~="table" or type(context.store)~="table" or type(context.campaignState)~="table" then
    fail("AUTHORITATIVE_CAMPAIGN_CONTEXT_UNAVAILABLE"); return false
  end
  local row=findGroundAmmoRow("GROUND_NODE_WRIGHT")
  if not row then fail("WRIGHT_AMMO_POLICY_ROW_UNAVAILABLE"); return false end
  state.resupplyRow=row

  local snapshot=context.store:GetResource(row.nodeId,row.resourceId)
  if not snapshot then fail("WRIGHT_AMMO_SNAPSHOT_UNAVAILABLE"); return false end
  state.resupplyDestinationBefore=snapshot.available

  local targetAvailable=math.max(0,row.reorder-1)
  if snapshot.available>targetAvailable then
    local quantity=snapshot.available-targetAvailable
    local txId="FSSR-A11-PRECONDITION-WRIGHT-AMMO"
    local transaction=context.store:ReserveResource({
      transactionId=txId,
      reservationId=txId,
      missionDemandId="FSSR-A11-PRECONDITION",
      kind=context.campaignState.TransactionKind.CONSUMPTION,
      resourceId=row.resourceId,
      quantity=quantity,
      canonicalUnit=snapshot.canonicalUnit,
      originNodeId=row.nodeId,
    })
    context.store:Consume(txId)
    context.store:CompleteConsumption(txId)
    log(string.format("AUTHORITATIVE_SHORTAGE_PRECONDITION nodeId=%s resourceId=%s consumed=%s before=%s after=%s reorder=%s target=%s",
      row.nodeId,row.resourceId,tostring(quantity),tostring(snapshot.available),tostring(targetAvailable),
      tostring(row.reorder),tostring(row.target)))
  end

  local after=context.store:GetResource(row.nodeId,row.resourceId)
  if not after or after.available>row.reorder then
    fail("SHORTAGE_PRECONDITION_NOT_BELOW_REORDER"); return false
  end

  local source=context.store:GetResource(row.supplyParent,row.resourceId)
  if not source then fail("RESUPPLY_SOURCE_SNAPSHOT_UNAVAILABLE"); return false end
  state.resupplySourceBefore=source.available
  return true
end

local function createStorageFixtures()
  state.pickupZone=need(ZONE:FindByName(RESUPPLY_PICKUP_ZONE),RESUPPLY_PICKUP_ZONE)
  state.dropZone=need(ZONE:FindByName(RESUPPLY_DROP_ZONE),RESUPPLY_DROP_ZONE)
  if state.failed then return false end

  state.sourceStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :AddCargoResource(STORAGE.Type.WEAPONS,RESUPPLY_CARGO_TYPE,RESUPPLY_CARGO_AMOUNT,RESUPPLY_TOTAL_WEIGHT_KG)
    :InitCoordinate(state.pickupZone:GetCoordinate())
    :InitValidateAndRepositionStatic(false)
    :Spawn(0,RESUPPLY_SOURCE_STORAGE_NAME)

  state.destStatic=SPAWNSTATIC:NewFromType("ammo_cargo","Cargos",country.id.USA)
    :ResetCargoResources()
    :InitCoordinate(state.dropZone:GetCoordinate())
    :InitValidateAndRepositionStatic(false)
    :Spawn(0,RESUPPLY_DEST_STORAGE_NAME)

  if not state.sourceStatic or not state.destStatic then fail("STORAGE_STATIC_SPAWN_FAILED"); return false end
  state.sourceStorage=state.sourceStatic:GetStaticStorage()
  state.destStorage=state.destStatic:GetStaticStorage()
  if not state.sourceStorage or not state.destStorage then fail("MOOSE_STORAGE_WRAPPER_UNAVAILABLE"); return false end
  if state.sourceStorage:GetAmount(RESUPPLY_CARGO_TYPE)~=RESUPPLY_CARGO_AMOUNT
      or state.destStorage:GetAmount(RESUPPLY_CARGO_TYPE)~=0 then
    fail("STORAGE_FIXTURE_AMOUNT_INVALID"); return false
  end

  local selected,reason=state.modules.flightPathNameContract.SelectFromRegistry(
    FLIGHTPATH_BASE,_DATABASE.PATHLINES)
  if not selected then fail("FLIGHTPATH_SELECTION_FAILED "..tostring(reason)); return false end

  state.resolvedTransportCorridor=state.modules.helicopterCorridor.Resolve({
    pathlineName=selected.name,
    pathline=selected.pathline,
    originCoordinate=state.pickupZone:GetCoordinate(),
    destinationCoordinate=state.dropZone:GetCoordinate(),
    offsetMode=state.modules.helicopterCorridor.OffsetMode.PATHLINE_SUFFIX,
  })
  if type(state.resolvedTransportCorridor)~="table"
      or type(state.resolvedTransportCorridor.outbound)~="table"
      or type(state.resolvedTransportCorridor.returnRoute)~="table" then
    fail("RESUPPLY_CORRIDOR_RESOLUTION_FAILED"); return false
  end
  log("RESUPPLY_CORRIDOR_READY path="..tostring(selected.name)
    .." outboundPoints="..tostring(#state.resolvedTransportCorridor.outbound)
    .." returnPoints="..tostring(#state.resolvedTransportCorridor.returnRoute))
  return true
end

local function installResupplyFlightObserver(asset)
  if not asset or not asset.flightgroup or asset.__omwA11LandingObserver then return end
  local flight=asset.flightgroup
  local previous=flight.OnAfterLanded
  flight.OnAfterLanded=function(self,F,E,T,airbase)
    if previous then previous(self,F,E,T,airbase) end
    local expected=state.resupplyLegion and type(state.resupplyLegion.GetAirbaseName)=="function"
      and state.resupplyLegion:GetAirbaseName() or nil
    local actual=airbase and airbase:GetName() or nil
    if expected~=nil and actual==expected then
      state.resupplyHome=true
      log("RESUPPLY_HOME_LANDED airbase="..tostring(actual))
    end
  end
  asset.__omwA11LandingObserver=true
end

local function resolveAirTransport(demand)
  if demand.siteId~="FOB_WRIGHT" or demand.resourceId~=RESUPPLY_RESOURCE_ID then
    return nil,"A11_RESUPPLY_DESCRIPTOR_SCOPE_MISMATCH"
  end
  return {
    pickupZone=state.pickupZone,
    deployZone=state.dropZone,
    sourceStorage=state.sourceStorage,
    destinationStorage=state.destStorage,
    cargoType=RESUPPLY_CARGO_TYPE,
    cargoAmount=RESUPPLY_CARGO_AMOUNT,
    cargoWeightKg=RESUPPLY_ITEM_WEIGHT_KG,
    requiredCarriersMin=1,
    requiredCarriersMax=1,
    resolvedCorridor=state.resolvedTransportCorridor,
    corridorAltitudeFtAgl=RESUPPLY_ALTITUDE_FT_AGL,
    corridorOptions={
      speedKts=RESUPPLY_SPEED_KTS,
      leadTurnDistanceM=RESUPPLY_LEAD_TURN_M,
      onOutboundInstalled=function(binding,_,asset)
        state.resupplyOutbound=true
        state.resupplyAsset=asset
        installResupplyFlightObserver(asset)
        log("RESUPPLY_OUTBOUND_CORRIDOR_INSTALLED waypoints="..tostring(binding.outboundWaypointCount))
      end,
      onReturnInstalled=function(binding,_,asset)
        state.resupplyReturn=true
        state.resupplyAsset=asset
        installResupplyFlightObserver(asset)
        log("RESUPPLY_RETURN_CORRIDOR_INSTALLED waypoints="..tostring(binding.returnWaypointCount))
      end,
      onError=function(reason)
        fail("RESUPPLY_CORRIDOR_FAILED "..tostring(reason))
      end,
    },
  },nil
end

local function routeFixture(d)
  local fixture=GROUP:FindByName(d.fixture)
  if not fixture then fail("FIXTURE_GROUP_MISSING "..d.fixture); return false end
  if fixture:IsAlive()~=true then fixture:Activate() end

  local perimeter=state.perimeters[d.siteId]
  local from=fixture:GetCoordinate()
  local anchor=perimeter and perimeter.anchorCoordinate
  if not from or not anchor then fail("FIXTURE_ROUTE_COORDINATE_UNAVAILABLE "..d.siteId); return false end
  local targetDistance=perimeter.radiusM*INTRUSION_DEPTH_FRACTION
  local target=anchor:GetIntermediateCoordinate(from,targetDistance)
  if not target then fail("FIXTURE_ROUTE_TARGET_UNAVAILABLE "..d.siteId); return false end
  fixture:RouteGroundTo(target,FIXTURE_ROUTE_SPEED_KMH,"Off Road",1)
  state.site[d.siteId].fixtureActivated=true
  log(string.format("FIXTURE_RELEASED siteId=%s fixture=%s targetDepthM=%.1f",
    d.siteId,d.fixture,targetDistance))
  return true
end

local function releaseFixtures()
  if state.fixturesReleased then return end
  for _,d in ipairs(ATTACK_SITES) do if not routeFixture(d) then return end end
  state.fixturesReleased=true
  state.startedAt=timer.getTime()
  announce("ATTACK","Joyce, Wright and Honaker RED fixtures released concurrently toward their owner-defined installation perimeters.",20)
end

local function updateIncidents()
  for _,d in ipairs(ATTACK_SITES) do
    if not state.site[d.siteId].incident then
      local incident=activeBaseIncident(d.siteId)
      if incident then
        state.site[d.siteId].incident=incident
        log("INCIDENT_ACTIVE siteId="..d.siteId.." incidentId="..tostring(incident.incidentId))
      end
    end
  end
end

local function allIncidentsActive()
  for _,d in ipairs(ATTACK_SITES) do if not state.site[d.siteId].incident then return false end end
  return true
end

local function requestIncidentSupport(siteId,supportType,key)
  local incident=state.site[siteId].incident
  if not incident then return nil end
  local demand,created,reason=state.base:RequestIncidentSupport(
    incident.incidentId,supportType,
    {requestKey=key,priority=20,cancelWhenIncidentClosed=false})
  log("SUPPORT_REQUEST siteId="..siteId.." supportType="..supportType
    .." demandId="..tostring(demand and demand.demandId)
    .." created="..tostring(created).." reason="..tostring(reason)
    .." status="..tostring(demand and demand.status))
  if not demand or demand.status=="NOT_DISPATCHED" or demand.status=="NO_ADAPTER" then
    fail("SUPPORT_DISPATCH_FAILED siteId="..siteId.." supportType="..supportType.." reason="..tostring(reason))
    return nil
  end
  return demand
end

local function allQrfEngaged()
  for _,d in ipairs(ATTACK_SITES) do
    local s=state.site[d.siteId]
    if not s or not s.guardObserved or not s.qrfObserved or not s.qrfEngage then return false end
  end
  return true
end

local function requestCombinedSupport()
  if state.supportRequested or not allIncidentsActive() or not allQrfEngaged() then return end

  -- Sequential calls in the same tick intentionally create overlapping reservations.
  -- MOOSE still decides the actual operational provider/asset for every demand.
  local artyW=requestIncidentSupport("FOB_WRIGHT","ARTY","A11_ARTY_WRIGHT")
  local artyH=requestIncidentSupport("COP_HONAKER","ARTY","A11_ARTY_HONAKER")
  local casJ=requestIncidentSupport("FOB_JOYCE","CAS","A11_CAS_JOYCE")
  local casH=requestIncidentSupport("COP_HONAKER","CAS","A11_CAS_HONAKER")
  if state.failed then return end

  state.artyDemands={artyW,artyH}
  state.casDemands={casJ,casH}

  local results,ok,reason=state.runtime:EvaluateResupply()
  if ok~=true then fail("RESUPPLY_EVALUATION_FAILED "..tostring(reason)); return end
  for _,result in ipairs(results or {}) do
    if result.demand and result.candidate and result.candidate.destinationNodeId=="GROUND_NODE_WRIGHT"
        and result.candidate.destinationResourceId==RESUPPLY_RESOURCE_ID then
      state.resupplyDemand=result.demand
      log("RESUPPLY_DEMAND_CREATED demandId="..tostring(result.demand.demandId)
        .." quantity="..tostring(result.demand.quantity)
        .." level="..tostring(result.candidate.level)
        .." status="..tostring(result.demand.status)
        .." reason="..tostring(result.reason))
    end
  end
  if not state.resupplyDemand or state.resupplyDemand.status~="DISPATCHED" then
    fail("A11_STRATEGIC_RESUPPLY_NOT_DISPATCHED")
    return
  end

  state.supportRequested=true
  announce("SUPPORT","Concurrent ARTY x2, CAS x2 and threshold-driven AIR_RESUPPLY demands dispatched through the shared Production Base. Provider/carrier selection remains MOOSE-owned.",25)
end

local function observeArty()
  local runtime=state.runtime and state.runtime.externalSupportRuntime
  local selection=runtime and runtime.artySelection or nil
  if not selection then return false end

  local activeAssets={}
  local allComplete=#state.artyDemands==2
  for _,demand in ipairs(state.artyDemands) do
    if demand then
      local entry=selection:GetState(demand.demandId)
      if not entry or not entry.owner then
        allComplete=false
      else
        local observed=state.artyObserved[demand.demandId]
        if not observed then
          observed={
            asset=entry.asset,
            assetId=entry.owner.realAssetId,
            initialAmmo=ammoTotal(entry.arty),
          }
          state.artyObserved[demand.demandId]=observed
          if observed.assetId=="HONAKER" then state.artySeenMortar=true else state.artySeenL118=true end
          log("ARTY_SELECTION demandId="..demand.demandId
            .." assetId="..tostring(observed.assetId)
            .." legion="..tostring(entry.legion and (entry.legion.alias or entry.legion.name))
            .." asset="..tostring(entry.asset and entry.asset.spawngroupname)
            .." initialAmmo="..tostring(observed.initialAmmo))
        end

        if not entry.released then
          local key=tostring(entry.asset)
          if activeAssets[key] then
            fail("ARTY_ASSET_DOUBLE_BOOKED demands="..activeAssets[key]..","..demand.demandId)
            return false
          end
          activeAssets[key]=demand.demandId
        end

        if entry.completed and entry.released and not observed.completed then
          observed.finalAmmo=ammoTotal(entry.arty)
          if not observed.initialAmmo or not observed.finalAmmo or observed.finalAmmo>=observed.initialAmmo then
            fail("ARTY_FIRE_AMMO_NOT_DECREASED demandId="..demand.demandId)
            return false
          end
          local stationary,moveReason=verifyNoMovement(observed.assetId,"POST_FIRE")
          if not stationary then fail(moveReason); return false end
          observed.completed=true
          log("ARTY_COMPLETE demandId="..demand.demandId.." assetId="..observed.assetId
            .." ammoBefore="..tostring(observed.initialAmmo).." ammoAfter="..tostring(observed.finalAmmo))
        end
        if not observed.completed then allComplete=false end
      end
    end
  end
  return allComplete and state.artySeenMortar and state.artySeenL118
end

local CAS_REQUIRED_EVIDENCE={
  "CAS_PROVIDER_PROFILE_BOUND",
  "CAS_MISSION_ASSIGNED",
  "CAS_OWNER_CORRIDOR_INSTALLED",
  "CAS_EXECUTING",
  "CAS_CONTROLLED_RELEASE",
  "CAS_HOME_LANDED",
  "CAS_LEGION_ASSET_RETURNED",
  "CAS_LIFECYCLE_COMPLETE",
}

local function observeCas()
  local runtime=state.runtime and state.runtime.externalSupportRuntime
  local lifecycle=runtime and runtime.casLifecycle or nil
  if not lifecycle then return false end

  local activeAssets={}
  local complete=#state.casDemands==2
  for _,demand in ipairs(state.casDemands) do
    if demand then
      local entry=lifecycle:GetState(demand.demandId)
      if not entry then
        complete=false
      else
        if entry.failed then
          fail("CAS_LIFECYCLE_FAILED demandId="..demand.demandId.." reason="..tostring(entry.failureReason))
          return false
        end
        if entry.fuelLowBeforeRelease then
          fail("CAS_FUEL_LOW_BEFORE_RELEASE demandId="..demand.demandId)
          return false
        end
        if entry.selectedAsset and not entry.completed then
          local key=tostring(entry.selectedAsset)
          if activeAssets[key] then
            fail("CAS_ASSET_DOUBLE_BOOKED demands="..activeAssets[key]..","..demand.demandId)
            return false
          end
          activeAssets[key]=demand.demandId
        end
        local evidence=state.casEvidence[demand.demandId] or {}
        for _,eventName in ipairs(CAS_REQUIRED_EVIDENCE) do
          if not evidence[eventName] then complete=false end
        end
        if not entry.completed then complete=false end
      end
    end
  end
  return complete
end

local function installResupplyReturnObserver()
  if state.resupplyObserversInstalled or not state.resupplyDemand or not state.runtime then return end
  local adapter=state.runtime.resupplyTransportRuntime
    and state.runtime.resupplyTransportRuntime:GetAdapter("AIR_RESUPPLY") or nil
  local handle=adapter and adapter.items and adapter.items[state.resupplyDemand.demandId] or nil
  if not handle or not handle.assets or not handle.legions then return end

  local asset
  for _,candidate in pairs(handle.assets) do asset=candidate break end
  local legion
  for _,candidate in pairs(handle.legions) do legion=candidate break end
  if not asset or not legion then return end

  state.resupplyAsset=asset
  state.resupplyLegion=legion
  installResupplyFlightObserver(asset)

  local previous=legion.OnAfterLegionAssetReturned
  legion.OnAfterLegionAssetReturned=function(self,F,E,T,cohort,returnedAsset)
    if previous then previous(self,F,E,T,cohort,returnedAsset) end
    if returnedAsset==asset then
      state.resupplyReturned=true
      log("RESUPPLY_LEGION_ASSET_RETURNED asset="..tostring(asset.spawngroupname)
        .." legion="..tostring(legion.alias or legion.name))
    end
  end
  state.resupplyObserversInstalled=true
  log("RESUPPLY_SELECTED_ASSET asset="..tostring(asset.spawngroupname)
    .." legion="..tostring(legion.alias or legion.name))
end

local function observeResupply()
  if not state.resupplyDemand then return false end
  installResupplyReturnObserver()

  local binding=state.runtime.transportSettlement
    and state.runtime.transportSettlement:GetBinding(state.resupplyDemand.demandId) or nil
  if binding and binding.terminal then state.resupplyTerminal=binding.terminal end

  if state.resupplyTerminal=="LOST" or state.resupplyTerminal=="CANCELLED" then
    fail("RESUPPLY_TERMINAL_FAILURE outcome="..tostring(state.resupplyTerminal))
    return false
  end
  if state.resupplyTerminal~="DELIVERED" then return false end
  if not state.resupplyOutbound or not state.resupplyReturn then return false end
  if not state.resupplyHome or not state.resupplyReturned then return false end

  if state.sourceStorage:GetAmount(RESUPPLY_CARGO_TYPE)~=0
      or state.destStorage:GetAmount(RESUPPLY_CARGO_TYPE)~=RESUPPLY_CARGO_AMOUNT then
    fail("RESUPPLY_STORAGE_SETTLEMENT_MISMATCH")
    return false
  end

  local context=groundContext()
  local destination=context.store:GetResource("GROUND_NODE_WRIGHT",RESUPPLY_RESOURCE_ID)
  local source=context.store:GetResource("GROUND_NODE_JALALABAD",RESUPPLY_RESOURCE_ID)
  if not destination or destination.available~=state.resupplyRow.target then
    fail("RESUPPLY_CAMPAIGN_DESTINATION_NOT_RESTORED expected="
      ..tostring(state.resupplyRow.target).." actual="..tostring(destination and destination.available))
    return false
  end
  if not source or source.available~=state.resupplySourceBefore-state.resupplyDemand.quantity then
    fail("RESUPPLY_CAMPAIGN_SOURCE_DEBIT_INVALID before="..tostring(state.resupplySourceBefore)
      .." quantity="..tostring(state.resupplyDemand.quantity)
      .." actual="..tostring(source and source.available))
    return false
  end
  return true
end

local function observeGroundRegression()
  local complete=true
  for _,d in ipairs(ATTACK_SITES) do
    local s=state.site[d.siteId]
    if not s.incident or not s.guardObserved or not s.qrfObserved or not s.qrfEngage then complete=false end
  end
  return complete
end

local function evaluate()
  if state.failed or state.passed then return end

  if not state.fixturesReleased then
    if allFixedMaterialized() then
      for assetId,_ in pairs(FIXED_ASSETS) do
        local ok,reason=verifyExactMaterialization(assetId)
        if not ok then fail(reason); return end
      end
      releaseFixtures()
    elseif state.startedAt and timer.getTime()-state.startedAt>60 then
      fail("FIXED_ASSET_MATERIALIZATION_TIMEOUT")
    end
    return
  end

  updateIncidents()
  requestCombinedSupport()
  if state.failed or not state.supportRequested then return end

  local groundOk=observeGroundRegression()
  local artyOk=observeArty()
  local casOk=observeCas()
  local resupplyOk=observeResupply()

  if groundOk and artyOk and casOk and resupplyOk then
    state.passed=true
    announce("PASS","A11 combined multi-site response complete: overlapping Joyce/Wright/Honaker incidents; Guard/QRF regression; MOOSE-selected L118 + real 2B11 fire; two independent CAS lifecycles; mandatory-corridor Strategic Resupply with exact CampaignState settlement and physical carrier return.",60)
    return
  end

  if state.startedAt and not state.watchdogWarned and timer.getTime()-state.startedAt>WATCHDOG_SEC then
    state.watchdogWarned=true
    announce("WARN","A11 observation watchdog elapsed. Productive lifecycles continue; harness does not cancel, reroute, force return or settle them.",25)
  end
end

local function start()
  if OMW_GROUND_READY~=1 then fail("GROUND_BASE_NOT_READY flag="..tostring(OMW_GROUND_READY)); return end
  state.package=package()
  state.modules=state.package and state.package.Modules or nil
  if type(state.package)~="table" or type(state.modules)~="table" then
    fail("FSSR_PRODUCTION_PACKAGE_UNAVAILABLE"); return
  end
  if type(_DATABASE)~="table" or type(_DATABASE.PATHLINES)~="table" then
    fail("PATHLINE_REGISTRY_UNAVAILABLE"); return
  end
  if not GROUP:FindByName(GUARD_TEMPLATE) or not GROUP:FindByName(QRF_TEMPLATE) then
    fail("BLUE_SECURITY_TEMPLATE_MISSING"); return
  end

  for _,d in ipairs(ATTACK_SITES) do
    if not GROUP:FindByName(d.fixture) then fail("FIXTURE_GROUP_MISSING "..d.fixture); return end
    ensureBrigade(d.siteId)
    if state.failed then return end
  end
  for _,spec in pairs(FIXED_ASSETS) do
    local template=GROUP:FindByName(spec.templateName)
    if not template then fail("FIXED_ASSET_TEMPLATE_MISSING "..spec.templateName); return end
    if template:IsAlive()==true then fail("FIXED_ASSET_TEMPLATE_MUST_BE_LATE_ACTIVATION "..spec.templateName); return end
    ensureBrigade(spec.siteId)
    if state.failed then return end
  end

  state.commander=COMMANDER:New(coalition.side.BLUE,"OMW_FSSR_BASE_A11_C2")
  if not state.commander then fail("COMMANDER_CREATE_FAILED"); return end
  state.commander:SetVerbosity(2)
  local airwingCount=discoverAirwings(state.commander)
  if airwingCount<1 then fail("NO_RUNNING_AIRWINGS"); return end

  local assets={}
  for assetId,spec in pairs(FIXED_ASSETS) do
    assets[#assets+1]={
      id=assetId,
      siteId=spec.siteId,
      templateName=spec.templateName,
      platoonName=spec.platoonName,
      weaponTypeName=spec.weaponTypeName,
      performance=50,
    }
  end

  state.registry=state.modules.artyRealAssetRegistry.New({
    commander=state.commander,
    brigades=state.brigades,
    assets=assets,
    platoonFactory=function(templateName,count,platoonName)
      return PLATOON:New(templateName,count,platoonName)
    end,
    resolveTemplateGroup=function(name) return GROUP:FindByName(name) end,
    resolveFunctionalArty=resolveFunctionalOwner,
    logger=log,
  })

  if not buildPerimeters() then return end
  if not seedAuthoritativeShortage() then return end
  if not createStorageFixtures() then return end

  local focused=focusedRegistry(state.package)
  local context=groundContext()
  local okRuntime,runtimeOrError=pcall(function()
    local runtime=state.package.New({
      siteRegistry=focused,
      brigades=state.brigades,
      resolveGuardPathline=function(name) return PATHLINE:FindByName(name) end,
      resolveGuardTemplateGroup=function(name) return GROUP:FindByName(name) end,
      guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
      resolveQrfCoordinate=function(_,ctx)
        local incident=ctx and ctx.incident
        local physical=incident and incident.context and incident.context.physicalTargetGroup
        if not physical then return nil,"QRF_PHYSICAL_TARGET_UNAVAILABLE" end
        return physical,nil
      end,
      qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
      blueCoalition=coalition.side.BLUE,
      redCoalition=coalition.side.RED,
      perimeters=state.perimeters,
      externalSupport={
        commander=state.commander,
        resolveArtyTarget=resolveArtyTarget,
        resolveCasGeometry=resolveCasGeometry,
        artyRequiredAssetsMin=1,
        artyRequiredAssetsMax=1,
        artyFunctionalSelection={
          resolveFunctionalArty=state.registry:GetResolver(),
        },
        casRequiredAssetsMin=1,
        casRequiredAssetsMax=1,
        casLifecycle={
          executionProfiles={
            AW_US_JBAD_TF_SHOOTER_6_6_CAV={
              pathlineBase="OMW_FlightPath",
              pathlineNames={"OMW_FlightPath","OMW_FlightPath_WEST"},
              segmentProfiles={
                {altitudeFtAgl=500},
                {altitudeFtAgl=2500,formation=ENUMS.Formation.RotaryWing.Column.D70},
              },
              maxJunctionDistanceM=1000,
              routeGateDistanceNm=3.5,
              transitAltitudeFtAgl=2500,
              missionAltitudeFtAgl=2500,
              speedKts=CAS_SPEED_KTS,
            },
          },
          pathlineRegistry=_DATABASE.PATHLINES,
          releasePolicy={
            mode="SUPPORTED_ELEMENT_STABLE_NO_CONTACT",
            stableNoContactSec=30,
          },
          updateSeconds=5,
          redCoalition=coalition.side.RED,
          onEvidence=onCasEvidence,
        },
      },
      resupply={
        policy=ResourceDemandPolicy,
        store=context.store,
        rows={state.resupplyRow},
        selectSupportType=function(candidate)
          if candidate.destinationNodeId=="GROUND_NODE_WRIGHT"
              and candidate.destinationResourceId==RESUPPLY_RESOURCE_ID then
            return "AIR_RESUPPLY"
          end
          return nil,"A11_RESUPPLY_MODE_SCOPE_MISMATCH"
        end,
        priorityForCandidate=function() return 20 end,
        transport={
          campaignState=context.campaignState,
          airCommander=state.commander,
          resolveAirTransport=resolveAirTransport,
          onTerminal=function(demand,outcome,transaction)
            state.resupplyTerminal=outcome
            log("RESUPPLY_TERMINAL demandId="..tostring(demand.demandId)
              .." outcome="..tostring(outcome)
              .." transactionId="..tostring(transaction and transaction.transactionId))
          end,
          onPartial=function(demand,detail)
            fail("RESUPPLY_PARTIAL_UNSUPPORTED demandId="..tostring(demand.demandId)
              .." delivered="..tostring(detail and detail.delivered)
              .." lost="..tostring(detail and detail.lost))
          end,
        },
      },
      logger=log,
    })
    return runtime:Prepare()
  end)

  if not okRuntime or not runtimeOrError then
    fail("RUNTIME_PREPARE_FAILED "..tostring(runtimeOrError)); return
  end
  state.runtime=runtimeOrError
  state.base=state.runtime:GetBase()

  local _,perimetersStarted,perimeterReason=state.runtime:StartPerimeters()
  if perimetersStarted~=true then fail("PERIMETER_START_FAILED "..tostring(perimeterReason)); return end

  for _,brigade in pairs(state.brigades) do brigade:Start() end
  state.commander:Start()

  for _,d in ipairs(ATTACK_SITES) do
    local _,created,reason=state.runtime:StartSite(d.siteId,{})
    if created==false then fail("SITE_START_FAILED siteId="..d.siteId.." reason="..tostring(reason)); return end
  end

  state.startedAt=timer.getTime()
  announce("READY","A11 composition armed. Fixed-fire-support materializes first; then Joyce/Wright/Honaker attack fixtures overlap. Harness observes only production Guard/QRF, ARTY, CAS and mandatory-corridor Strategic Resupply lifecycles.",30)
  SCHEDULER:New(nil,evaluate,{},POLL_SEC,POLL_SEC)
end

SCHEDULER:New(nil,start,{},START_DELAY_SEC)
