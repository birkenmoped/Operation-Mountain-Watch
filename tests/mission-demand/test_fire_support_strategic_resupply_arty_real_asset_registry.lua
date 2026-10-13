local Registry=dofile("scripts/campaign/OMW_FireSupStratResupply_ArtyRealAssetRegistry.lua")
local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local commander={brigades={}}
function commander:AddBrigade(b) self.brigades[#self.brigades+1]=b return self end

local function newBrigade(name)
  local b={name=name,platoons={},loadbacks={}}
  function b:AddPlatoon(p)
    self.platoons[#self.platoons+1]=p
    local asset={uid=#self.platoons,assignment=p.name,spawngroupname=p.name.."_AID-"..tostring(#self.platoons),spawned=false}
    if self.OnAfterNewAsset then self:OnAfterNewAsset("Running","NewAsset","Running",asset,p.name) end
    return self
  end
  function b:LoadBackAssetInPosition(alias,coordinate)
    self.loadbacks[#self.loadbacks+1]={alias=alias,coordinate=coordinate}
    return self
  end
  return b
end

local brigades={BOSTICK=newBrigade("BOSTICK"),WRIGHT=newBrigade("WRIGHT"),HONAKER=newBrigade("HONAKER")}
local groups={
  TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2={alive=false,points={{x=10,y=20}}},
  TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2={alive=false,points={{x=30,y=40}}},
  TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2={alive=false,points={{x=50,y=60}}},
}
for _,g in pairs(groups) do
  function g:IsAlive() return self.alive end
  function g:GetTemplateRoutePoints() return self.points end
end

local created={}
local function platoonFactory(templateName,count,platoonName)
  eq(count,1,"real asset count")
  local p={templateName=templateName,name=platoonName}
  function p:AddMissionCapability(kind,performance) self.kind=kind;self.performance=performance;return self end
  function p:SetMissionRange(range) self.missionRange=range;return self end
  function p:AddWeaponRange(min,max,bit) self.min=min;self.max=max;self.bit=bit;return self end
  created[platoonName]=p
  return p
end

local function coordinateFactory(vec2) return {x=vec2.x,y=vec2.y,marker="COORD"} end
local ranges={L118_Unit={minMeters=500,maxMeters=17500},["2B11 mortar"]={minMeters=500,maxMeters=7000}}
local function resolveRange(name) return ranges[name] end
local function metersToNm(m) return m/1852 end

local ownerGroupName=nil
local registry=Registry.New({
  commander=commander,brigades=brigades,
  assets={
    {id="ARTY_BOSTICK",siteId="BOSTICK",templateName="TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",platoonName="BostickArtillery",weaponTypeName="L118_Unit",performance=70},
    {id="ARTY_WRIGHT",siteId="WRIGHT",templateName="TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",platoonName="WrightArtillery",weaponTypeName="L118_Unit",performance=80},
    {id="MORTAR_HONAKER",siteId="HONAKER",templateName="TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2",platoonName="HonakerMortar",weaponTypeName="2B11 mortar",performance=75},
  },
  platoonFactory=platoonFactory,
  resolveTemplateGroup=function(name) return groups[name] end,
  coordinateFactory=coordinateFactory,resolveRange=resolveRange,metersToNm=metersToNm,
  resolveFunctionalArty=function(definition,asset,legion,group)
    ownerGroupName=group:GetName()
    return {arty={Controllable={GetName=function() return group:GetName() end},AssignTargetCoord=function() end,RemoveTarget=function() end}}
  end,
  missionTypeArty="ARTY",weaponFlagAuto=999,
})

eq(#commander.brigades,3,"one registration per site brigade")
eq(created.BostickArtillery.kind,"ARTY","ARTY capability")
eq(created.BostickArtillery.missionRange,0,"broad mission range disabled")
eq(created.BostickArtillery.min,500/1852,"min range")
eq(created.BostickArtillery.max,17500/1852,"max range")
eq(#brigades.BOSTICK.loadbacks,1,"Bostick materialization request")
eq(brigades.BOSTICK.loadbacks[1].coordinate.x,10,"Bostick exact x")
eq(brigades.BOSTICK.loadbacks[1].coordinate.y,20,"Bostick exact y")
eq(#brigades.WRIGHT.loadbacks,1,"Wright materialization request")
eq(brigades.WRIGHT.loadbacks[1].coordinate.x,30,"Wright exact x")
eq(brigades.WRIGHT.loadbacks[1].coordinate.y,40,"Wright exact y")
eq(created.HonakerMortar.kind,"ARTY","2B11 uses generic ARTY mission capability")
eq(created.HonakerMortar.min,500/1852,"2B11 min range from pinned ARTY.db")
eq(created.HonakerMortar.max,7000/1852,"2B11 max range from pinned ARTY.db")
eq(#brigades.HONAKER.loadbacks,1,"Honaker materialization request")
eq(brigades.HONAKER.loadbacks[1].coordinate.x,50,"Honaker exact x")
eq(brigades.HONAKER.loadbacks[1].coordinate.y,60,"Honaker exact y")

local definition=registry:GetAsset("ARTY_WRIGHT")
yes(definition.materializationRequested,"materialization requested")
no(registry:IsMaterialized("ARTY_WRIGHT"),"not materialized before AssetSpawned")
local physicalGroup={name="WrightArtillery_AID-1"}
function physicalGroup:GetName() return self.name end
local armygroup={alive=true,group=physicalGroup}
function armygroup:IsAlive() return self.alive end
function armygroup:GetGroup() return self.group end
definition.asset.spawned=true
definition.asset.flightgroup=armygroup
brigades.WRIGHT:OnAfterAssetSpawned("Running","AssetSpawned","Running",physicalGroup,definition.asset,{assignment="WrightArtillery"})
yes(registry:IsMaterialized("ARTY_WRIGHT"),"materialized after AssetSpawned")

local owner,reason=registry:ResolveFunctionalArty(definition.asset,brigades.WRIGHT,{},{},{})
yes(owner~=nil,"real asset resolves owner")
eq(reason,nil,"owner reason")
eq(owner.realAssetId,"ARTY_WRIGHT","real asset id")
eq(owner.physicalGroupName,"WrightArtillery_AID-1","physical group identity")
eq(ownerGroupName,"WrightArtillery_AID-1","resolver gets selected physical group")

local honaker=registry:GetAsset("MORTAR_HONAKER")
local honakerGroup={name="HonakerMortar_AID-1"}
function honakerGroup:GetName() return self.name end
local honakerArmy={alive=true,group=honakerGroup}
function honakerArmy:IsAlive() return self.alive end
function honakerArmy:GetGroup() return self.group end
honaker.asset.spawned=true
honaker.asset.flightgroup=honakerArmy
brigades.HONAKER:OnAfterAssetSpawned("Running","AssetSpawned","Running",honakerGroup,honaker.asset,{assignment="HonakerMortar"})
yes(registry:IsMaterialized("MORTAR_HONAKER"),"2B11 materialized through same real asset path")
local mortarOwner,mortarReason=registry:ResolveFunctionalArty(honaker.asset,brigades.HONAKER,{},{},{})
yes(mortarOwner~=nil,"2B11 resolves generic Functional ARTY owner")
eq(mortarReason,nil,"2B11 owner reason")
eq(mortarOwner.realAssetId,"MORTAR_HONAKER","2B11 real asset id")
eq(mortarOwner.physicalGroupName,"HonakerMortar_AID-1","2B11 physical identity")

definition.asset.spawned=false
local missing,missingReason=registry:ResolveFunctionalArty(definition.asset,brigades.WRIGHT,{},{},{})
eq(missing,nil,"unspawned rejected")
eq(missingReason,"ARTY_REAL_ASSET_NOT_SPAWNED","unspawned reason")
definition.asset.spawned=true

local wrong,wrongReason=registry:ResolveFunctionalArty(definition.asset,brigades.BOSTICK,{},{},{})
eq(wrong,nil,"wrong legion rejected")
yes(wrongReason:find("LEGION_MISMATCH",1,true)~=nil,"wrong legion reason")

groups.TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2.alive=true
local aliveOk=pcall(function()
  Registry.New({commander={AddBrigade=function() end},brigades={BOSTICK=newBrigade("B2")},
    assets={{id="X",siteId="BOSTICK",templateName="TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",platoonName="BostickX",weaponTypeName="L118_Unit"}},
    platoonFactory=platoonFactory,resolveTemplateGroup=function(name) return groups[name] end,
    coordinateFactory=coordinateFactory,resolveRange=resolveRange,metersToNm=metersToNm,
    resolveFunctionalArty=function() return nil end,missionTypeArty="ARTY",weaponFlagAuto=999})
end)
no(aliveOk,"live ME battery must fail registration")

groups.TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2.alive=false
local underscoreOk=pcall(function()
  Registry.New({commander={AddBrigade=function() end},brigades={WRIGHT=newBrigade("B3")},
    assets={{id="Y",siteId="WRIGHT",templateName="TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",platoonName="PLT_WRIGHT_ARTY",weaponTypeName="L118_Unit"}},
    platoonFactory=platoonFactory,resolveTemplateGroup=function(name) return groups[name] end,
    coordinateFactory=coordinateFactory,resolveRange=resolveRange,metersToNm=metersToNm,
    resolveFunctionalArty=function() return nil end,missionTypeArty="ARTY",weaponFlagAuto=999})
end)
no(underscoreOk,"LoadBack platoon alias must avoid underscore")

print("PASS test_fire_support_strategic_resupply_arty_real_asset_registry")
