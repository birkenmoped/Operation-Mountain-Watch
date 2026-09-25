-- Operation Mountain Watch - selection-only MOOSE descriptor registry for fixed ARTY batteries.
--
-- Option A contract:
--   * descriptor assets are MOOSE-only reservation/selection representations;
--   * descriptor templates must NOT be alive when registered;
--   * descriptor assets are never queued or materialized;
--   * each descriptor maps one-to-one to one already-existing Functional ARTY owner;
--   * CampaignState remains the strategic resource authority.

local Registry = {}
local Instance = {}
Instance.__index = Instance

Registry.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-DESCRIPTOR-REGISTRY-1"

local TAG = "[OMW][FireSupStratResupply.ArtySelectionDescriptorRegistry]"

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
local function needRange(value, label, allowZero)
  if not finite(value) or value < 0 or (not allowZero and value == 0) then
    fail(label .. " requires " .. (allowZero and "non-negative" or "positive") .. " finite number")
  end
  return value
end
local function copy(value) local result={} for k,v in pairs(value) do result[k]=v end return result end

function Registry.New(spec)
  needTable(spec, "spec")
  local commander = needTable(spec.commander, "commander")
  needFunction(commander, "AddBrigade", "commander")
  local brigades = needTable(spec.brigades, "brigades")
  if type(spec.platoonFactory) ~= "function" then fail("platoonFactory must be a function") end
  if type(spec.resolveTemplateGroup) ~= "function" then fail("resolveTemplateGroup must be a function") end
  if type(spec.resolveFunctionalArty) ~= "function" then fail("resolveFunctionalArty must be a function") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

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
    commander=commander,brigades=brigades,resolveFunctionalArty=spec.resolveFunctionalArty,logger=spec.logger,
    descriptors={},byPlatoonName={},registeredBrigades={},missionTypeArty=missionTypeArty,weaponFlagAuto=weaponFlagAuto,
  },Instance)

  local descriptors=needTable(spec.descriptors,"descriptors")
  if #descriptors==0 then fail("descriptors requires at least one entry") end
  for index,raw in ipairs(descriptors) do
    local d=needTable(raw,"descriptors["..tostring(index).."]")
    local descriptor={
      id=needString(d.id,"descriptor.id"),siteId=needString(d.siteId,"descriptor.siteId"),
      templateName=needString(d.templateName,"descriptor.templateName"),platoonName=needString(d.platoonName,"descriptor.platoonName"),
      physicalGroupName=needString(d.physicalGroupName,"descriptor.physicalGroupName"),
      rangeMinNm=needRange(d.rangeMinNm,"descriptor.rangeMinNm",true),rangeMaxNm=needRange(d.rangeMaxNm,"descriptor.rangeMaxNm",false),
      performance=d.performance or 50,
    }
    if descriptor.rangeMaxNm<=descriptor.rangeMinNm then fail("descriptor.rangeMaxNm must be greater than rangeMinNm id="..descriptor.id) end
    if not finite(descriptor.performance) or descriptor.performance<1 or descriptor.performance>100 then fail("descriptor.performance must be finite in range 1..100 id="..descriptor.id) end
    if self.descriptors[descriptor.id] then fail("duplicate descriptor.id="..descriptor.id) end
    if self.byPlatoonName[descriptor.platoonName] then fail("duplicate descriptor.platoonName="..descriptor.platoonName) end

    local brigade=needTable(brigades[descriptor.siteId],"brigades["..descriptor.siteId.."]")
    needFunction(brigade,"AddPlatoon","brigade "..descriptor.siteId)
    local templateGroup=spec.resolveTemplateGroup(descriptor.templateName)
    needTable(templateGroup,"descriptor template group "..descriptor.templateName)
    needFunction(templateGroup,"IsAlive","descriptor template group "..descriptor.templateName)
    if templateGroup:IsAlive()==true then
      fail("descriptor template must not be alive; WAREHOUSE:AddAsset would destroy it template="..descriptor.templateName)
    end

    local platoon=spec.platoonFactory(descriptor.templateName,1,descriptor.platoonName)
    needTable(platoon,"descriptor platoon "..descriptor.platoonName)
    needFunction(platoon,"AddMissionCapability","descriptor platoon "..descriptor.platoonName)
    needFunction(platoon,"SetMissionRange","descriptor platoon "..descriptor.platoonName)
    needFunction(platoon,"AddWeaponRange","descriptor platoon "..descriptor.platoonName)
    platoon:AddMissionCapability(missionTypeArty,descriptor.performance)
    platoon:SetMissionRange(0)
    platoon:AddWeaponRange(descriptor.rangeMinNm,descriptor.rangeMaxNm,weaponFlagAuto)
    brigade:AddPlatoon(platoon)

    descriptor.brigade=brigade
    descriptor.platoon=platoon
    self.descriptors[descriptor.id]=descriptor
    self.byPlatoonName[descriptor.platoonName]=descriptor
    if not self.registeredBrigades[brigade] then
      commander:AddBrigade(brigade)
      self.registeredBrigades[brigade]=true
    end
    if self.logger then
      self.logger(TAG..string.format(" descriptor registered id=%s siteId=%s template=%s platoon=%s physical=%s rangeNm=%.3f..%.3f",
        descriptor.id,descriptor.siteId,descriptor.templateName,descriptor.platoonName,descriptor.physicalGroupName,descriptor.rangeMinNm,descriptor.rangeMaxNm))
    end
  end
  return self
end

function Instance:ResolveFunctionalArty(asset, legion, demand, context, selectionMission)
  needTable(asset,"selected asset")
  if asset.spawned==true then return nil,"ARTY_SELECTION_DESCRIPTOR_SPAWNED" end
  local descriptor=asset.assignment and self.byPlatoonName[asset.assignment] or nil
  if not descriptor then return nil,"ARTY_SELECTION_DESCRIPTOR_UNKNOWN assignment="..tostring(asset.assignment) end
  if legion~=descriptor.brigade then return nil,"ARTY_SELECTION_DESCRIPTOR_LEGION_MISMATCH id="..descriptor.id end
  if asset.templatename~=nil and asset.templatename~=descriptor.templateName then
    return nil,"ARTY_SELECTION_DESCRIPTOR_TEMPLATE_MISMATCH id="..descriptor.id
  end
  local owner,reason=self.resolveFunctionalArty(copy(descriptor),asset,legion,demand,context,selectionMission)
  if owner==nil then return nil,reason or "SELECTED_ARTY_OWNER_UNAVAILABLE" end
  needTable(owner,"resolved Functional ARTY owner")
  local arty=needTable(owner.arty,"resolved Functional ARTY owner.arty")
  local controllable=needTable(arty.Controllable,"resolved Functional ARTY owner.arty.Controllable")
  needFunction(controllable,"GetName","resolved Functional ARTY owner.arty.Controllable")
  local actualName=controllable:GetName()
  if actualName~=descriptor.physicalGroupName then
    return nil,"ARTY_SELECTION_PHYSICAL_IDENTITY_MISMATCH expected="..descriptor.physicalGroupName.." actual="..tostring(actualName)
  end
  owner.selectionDescriptorId=descriptor.id
  owner.selectionDescriptorTemplate=descriptor.templateName
  owner.physicalGroupName=descriptor.physicalGroupName
  return owner,nil
end

function Instance:GetResolver()
  local registry=self
  return function(asset,legion,demand,context,selectionMission)
    return registry:ResolveFunctionalArty(asset,legion,demand,context,selectionMission)
  end
end

function Instance:GetDescriptor(id) return self.descriptors[id] end

function Instance:GetConfig()
  local descriptors={}
  local count=0
  for id,d in pairs(self.descriptors) do
    count=count+1
    descriptors[id]={id=d.id,siteId=d.siteId,templateName=d.templateName,platoonName=d.platoonName,physicalGroupName=d.physicalGroupName,
      rangeMinNm=d.rangeMinNm,rangeMaxNm=d.rangeMaxNm,performance=d.performance}
  end
  return {schemaVersion=Registry.SchemaVersion,descriptorCount=count,descriptors=descriptors}
end

return Registry
