-- Operation Mountain Watch - real MOOSE asset registry for fixed ARTY/Mortar batteries.
--
-- Owner-approved contract:
-- * existing site-bound ME groups become one real MOOSE PLATOON asset each;
-- * ME groups must be late activated / not alive when registered;
-- * BRIGADE/WAREHOUSE owns the operational asset lifecycle;
-- * BRIGADE:LoadBackAssetInPosition() performs one exact-coordinate startup materialization;
-- * COMMANDER/LEGION recruits the real spawned asset;
-- * selection AUFTRAG is never queued as a second FireAtPoint owner;
-- * accepted Functional ARTY remains sole fire/rearm owner;
-- * no relocation/patrol/RTZ mission is introduced for fixed batteries.

local Registry = {}
local Instance = {}
Instance.__index = Instance

Registry.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-REAL-ASSET-REGISTRY-1"

local TAG = "[OMW][FireSupStratResupply.ArtyRealAssetRegistry]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end
local function finite(value) return type(value) == "number" and value == value and value > -math.huge and value < math.huge end
local function copy(value) local result={} for k,v in pairs(value) do result[k]=v end return result end

local function defaultMetersToNm(value)
  if type(UTILS) ~= "table" or type(UTILS.MetersToNM) ~= "function" then fail("MOOSE UTILS.MetersToNM() is required") end
  return UTILS.MetersToNM(value)
end

local function defaultCoordinateFactory(vec2)
  if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec2) ~= "function" then
    fail("MOOSE COORDINATE:NewFromVec2() is required")
  end
  return COORDINATE:NewFromVec2(vec2)
end

local function defaultRangeResolver(typeName)
  if type(ARTY) ~= "table" or type(ARTY.db) ~= "table" then fail("MOOSE ARTY.db is required") end
  local row=ARTY.db[typeName]
  if type(row) ~= "table" then return nil,"ARTY_RANGE_UNAVAILABLE type="..tostring(typeName) end
  if not finite(row.minrange) or not finite(row.maxrange) or row.minrange < 0 or row.maxrange <= row.minrange then
    return nil,"ARTY_RANGE_INVALID type="..tostring(typeName)
  end
  return {minMeters=row.minrange,maxMeters=row.maxrange},nil
end

function Registry.New(spec)
  needTable(spec,"spec")
  local commander=needTable(spec.commander,"commander")
  needFunction(commander,"AddBrigade","commander")
  local brigades=needTable(spec.brigades,"brigades")
  if type(spec.platoonFactory)~="function" then fail("platoonFactory must be a function") end
  if type(spec.resolveTemplateGroup)~="function" then fail("resolveTemplateGroup must be a function") end
  if type(spec.resolveFunctionalArty)~="function" then fail("resolveFunctionalArty must be a function") end
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end

  local missionTypeArty=spec.missionTypeArty
  if missionTypeArty==nil then
    if type(AUFTRAG)~="table" or type(AUFTRAG.Type)~="table" or AUFTRAG.Type.ARTY==nil then fail("AUFTRAG.Type.ARTY is required") end
    missionTypeArty=AUFTRAG.Type.ARTY
  end
  local weaponFlagAuto=spec.weaponFlagAuto
  if weaponFlagAuto==nil then
    if type(ENUMS)~="table" or type(ENUMS.WeaponFlag)~="table" or ENUMS.WeaponFlag.Auto==nil then fail("ENUMS.WeaponFlag.Auto is required") end
    weaponFlagAuto=ENUMS.WeaponFlag.Auto
  end

  local self=setmetatable({
    commander=commander,
    brigades=brigades,
    resolveFunctionalArty=spec.resolveFunctionalArty,
    logger=spec.logger,
    missionTypeArty=missionTypeArty,
    weaponFlagAuto=weaponFlagAuto,
    metersToNm=spec.metersToNm or defaultMetersToNm,
    coordinateFactory=spec.coordinateFactory or defaultCoordinateFactory,
    resolveRange=spec.resolveRange or defaultRangeResolver,
    assets={},
    byPlatoonName={},
    registeredBrigades={},
    hookedBrigades={},
  },Instance)

  local function installHooks(brigade)
    if self.hookedBrigades[brigade] then return end
    needFunction(brigade,"LoadBackAssetInPosition","brigade")
    local previousNewAsset=brigade.OnAfterNewAsset
    local previousAssetSpawned=brigade.OnAfterAssetSpawned
    local registry=self

    brigade.OnAfterNewAsset=function(selfBrigade,From,Event,To,asset,assignment)
      if previousNewAsset then previousNewAsset(selfBrigade,From,Event,To,asset,assignment) end
      local definition=assignment and registry.byPlatoonName[assignment] or nil
      if not definition then return end
      if asset.assignment~=definition.platoonName then
        fail("new asset assignment mismatch id="..definition.id.." expected="..definition.platoonName.." actual="..tostring(asset.assignment))
      end
      if type(asset.spawngroupname)~="string" or asset.spawngroupname=="" then
        fail("new asset spawngroupname unavailable id="..definition.id)
      end
      definition.asset=asset
      definition.assetUid=asset.uid
      definition.materializationRequested=true
      selfBrigade:LoadBackAssetInPosition(asset.spawngroupname,definition.spawnCoordinate)
      registry:_log(string.format("materialization requested id=%s siteId=%s assetUid=%s alias=%s",
        definition.id,definition.siteId,tostring(asset.uid),tostring(asset.spawngroupname)))
    end

    brigade.OnAfterAssetSpawned=function(selfBrigade,From,Event,To,group,asset,request)
      if previousAssetSpawned then previousAssetSpawned(selfBrigade,From,Event,To,group,asset,request) end
      local definition=asset and asset.assignment and registry.byPlatoonName[asset.assignment] or nil
      if not definition then return end
      if definition.assetUid~=nil and asset.uid~=definition.assetUid then
        fail("spawned asset uid mismatch id="..definition.id)
      end
      definition.asset=asset
      definition.assetUid=asset.uid
      definition.group=group
      definition.materialized=true
      registry:_log(string.format("materialized id=%s siteId=%s assetUid=%s group=%s",
        definition.id,definition.siteId,tostring(asset.uid),tostring(group and group.GetName and group:GetName())))
    end

    self.hookedBrigades[brigade]=true
  end

  local definitions=needTable(spec.assets,"assets")
  if #definitions==0 then fail("assets requires at least one entry") end

  for index,raw in ipairs(definitions) do
    local d=needTable(raw,"assets["..tostring(index).."]")
    local definition={
      id=needString(d.id,"asset.id"),
      siteId=needString(d.siteId,"asset.siteId"),
      templateName=needString(d.templateName,"asset.templateName"),
      platoonName=needString(d.platoonName,"asset.platoonName"),
      weaponTypeName=needString(d.weaponTypeName,"asset.weaponTypeName"),
      performance=d.performance or 50,
    }
    if string.find(definition.platoonName,"_",1,true) then
      fail("asset.platoonName must not contain underscore because pinned BRIGADE:LoadBackAssetInPosition() splits alias on '_' id="..definition.id)
    end
    if not finite(definition.performance) or definition.performance<1 or definition.performance>100 then
      fail("asset.performance must be finite in range 1..100 id="..definition.id)
    end
    if self.assets[definition.id] then fail("duplicate asset.id="..definition.id) end
    if self.byPlatoonName[definition.platoonName] then fail("duplicate asset.platoonName="..definition.platoonName) end

    local brigade=needTable(brigades[definition.siteId],"brigades["..definition.siteId.."]")
    needFunction(brigade,"AddPlatoon","brigade "..definition.siteId)
    installHooks(brigade)

    local templateGroup=spec.resolveTemplateGroup(definition.templateName)
    needTable(templateGroup,"template group "..definition.templateName)
    needFunction(templateGroup,"IsAlive","template group "..definition.templateName)
    needFunction(templateGroup,"GetTemplateRoutePoints","template group "..definition.templateName)
    if templateGroup:IsAlive()==true then
      fail("real ARTY template must not be alive at registration; set Late Activation template="..definition.templateName)
    end
    local routePoints=templateGroup:GetTemplateRoutePoints()
    if type(routePoints)~="table" or type(routePoints[1])~="table" or not finite(routePoints[1].x) or not finite(routePoints[1].y) then
      fail("template first route point unavailable template="..definition.templateName)
    end
    definition.spawnVec2={x=routePoints[1].x,y=routePoints[1].y}
    definition.spawnCoordinate=self.coordinateFactory(definition.spawnVec2)
    needTable(definition.spawnCoordinate,"spawn coordinate "..definition.id)

    local range,rangeReason=self.resolveRange(definition.weaponTypeName)
    if range==nil then fail(rangeReason or ("range unavailable id="..definition.id)) end
    needTable(range,"range "..definition.id)
    if not finite(range.minMeters) or not finite(range.maxMeters) or range.minMeters<0 or range.maxMeters<=range.minMeters then
      fail("invalid range id="..definition.id)
    end
    definition.rangeMinMeters=range.minMeters
    definition.rangeMaxMeters=range.maxMeters
    definition.rangeMinNm=self.metersToNm(range.minMeters)
    definition.rangeMaxNm=self.metersToNm(range.maxMeters)

    local platoon=spec.platoonFactory(definition.templateName,1,definition.platoonName)
    needTable(platoon,"platoon "..definition.platoonName)
    needFunction(platoon,"AddMissionCapability","platoon "..definition.platoonName)
    needFunction(platoon,"SetMissionRange","platoon "..definition.platoonName)
    needFunction(platoon,"AddWeaponRange","platoon "..definition.platoonName)
    platoon:AddMissionCapability(missionTypeArty,definition.performance)
    platoon:SetMissionRange(0)
    platoon:AddWeaponRange(definition.rangeMinNm,definition.rangeMaxNm,weaponFlagAuto)

    definition.brigade=brigade
    definition.platoon=platoon
    definition.templateGroup=templateGroup
    self.assets[definition.id]=definition
    self.byPlatoonName[definition.platoonName]=definition

    brigade:AddPlatoon(platoon)
    if not self.registeredBrigades[brigade] then
      commander:AddBrigade(brigade)
      self.registeredBrigades[brigade]=true
    end

    self:_log(string.format("registered real asset id=%s siteId=%s template=%s platoon=%s weapon=%s rangeM=%.0f..%.0f",
      definition.id,definition.siteId,definition.templateName,definition.platoonName,definition.weaponTypeName,
      definition.rangeMinMeters,definition.rangeMaxMeters))
  end

  return self
end

function Instance:_log(message)
  if self.logger then self.logger(TAG.." "..tostring(message)) end
end

function Instance:ResolveFunctionalArty(asset,legion,demand,context,selectionMission)
  needTable(asset,"selected asset")
  if asset.spawned~=true then return nil,"ARTY_REAL_ASSET_NOT_SPAWNED" end
  local definition=asset.assignment and self.byPlatoonName[asset.assignment] or nil
  if not definition then return nil,"ARTY_REAL_ASSET_UNKNOWN assignment="..tostring(asset.assignment) end
  if legion~=definition.brigade then return nil,"ARTY_REAL_ASSET_LEGION_MISMATCH id="..definition.id end
  if definition.assetUid~=nil and asset.uid~=definition.assetUid then
    return nil,"ARTY_REAL_ASSET_UID_MISMATCH id="..definition.id
  end
  local flightgroup=asset.flightgroup
  if type(flightgroup)~="table" or type(flightgroup.GetGroup)~="function" or type(flightgroup.IsAlive)~="function" then
    return nil,"ARTY_REAL_ASSET_ARMYGROUP_UNAVAILABLE id="..definition.id
  end
  if flightgroup:IsAlive()~=true then return nil,"ARTY_REAL_ASSET_NOT_ALIVE id="..definition.id end
  local group=flightgroup:GetGroup()
  if type(group)~="table" or type(group.GetName)~="function" then
    return nil,"ARTY_REAL_ASSET_GROUP_UNAVAILABLE id="..definition.id
  end
  local owner,reason=self.resolveFunctionalArty(copy(definition),asset,legion,group,demand,context,selectionMission)
  if owner==nil then return nil,reason or "SELECTED_ARTY_OWNER_UNAVAILABLE" end
  needTable(owner,"resolved Functional ARTY owner")
  local arty=needTable(owner.arty,"resolved Functional ARTY owner.arty")
  local controllable=needTable(arty.Controllable,"resolved Functional ARTY owner.arty.Controllable")
  needFunction(controllable,"GetName","resolved Functional ARTY owner.arty.Controllable")
  local actualName=controllable:GetName()
  local selectedName=group:GetName()
  if actualName~=selectedName then
    return nil,"ARTY_REAL_ASSET_PHYSICAL_IDENTITY_MISMATCH expected="..tostring(selectedName).." actual="..tostring(actualName)
  end
  owner.realAssetId=definition.id
  owner.realAssetUid=asset.uid
  owner.siteId=definition.siteId
  owner.physicalGroupName=selectedName
  return owner,nil
end

function Instance:GetResolver()
  local registry=self
  return function(asset,legion,demand,context,selectionMission)
    return registry:ResolveFunctionalArty(asset,legion,demand,context,selectionMission)
  end
end

function Instance:GetAsset(id) return self.assets[id] end
function Instance:IsMaterialized(id)
  local definition=self.assets[id]
  return definition~=nil and definition.materialized==true
end
function Instance:GetConfig()
  local assets={}
  local count=0
  for id,d in pairs(self.assets) do
    count=count+1
    assets[id]={id=d.id,siteId=d.siteId,templateName=d.templateName,platoonName=d.platoonName,weaponTypeName=d.weaponTypeName,
      performance=d.performance,rangeMinMeters=d.rangeMinMeters,rangeMaxMeters=d.rangeMaxMeters,
      rangeMinNm=d.rangeMinNm,rangeMaxNm=d.rangeMaxNm,materialized=d.materialized==true}
  end
  return {schemaVersion=Registry.SchemaVersion,assetCount=count,assets=assets}
end

return Registry
