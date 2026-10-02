local Registry=dofile("scripts/campaign/OMW_FireSupStratResupply_ArtySelectionDescriptorRegistry.lua")
local function eq(a,b,label) if a~=b then error(string.format("%s expected=%s actual=%s",label,tostring(b),tostring(a))) end end
local function yes(v,label) if v~=true then error(label.." expected=true") end end
local function no(v,label) if v~=false then error(label.." expected=false") end end

local commander={brigades={}}
function commander:AddBrigade(b) self.brigades[#self.brigades+1]=b return self end
local function brigade(name)
  local b={name=name,platoons={}}
  function b:AddPlatoon(p) self.platoons[#self.platoons+1]=p return self end
  return b
end
local brigades={BOSTICK=brigade("BOSTICK"),WRIGHT=brigade("WRIGHT")}
local groups={TPL_ARTY_SELECT_BOSTICK={alive=false},TPL_ARTY_SELECT_WRIGHT={alive=false}}
for _,g in pairs(groups) do function g:IsAlive() return self.alive end end
local created={}
local function platoonFactory(templateName,count,platoonName)
  eq(count,1,"descriptor stock count")
  local p={templateName=templateName,name=platoonName}
  function p:AddMissionCapability(kind,performance) self.kind=kind;self.performance=performance;return self end
  function p:SetMissionRange(range) self.missionRange=range;return self end
  function p:AddWeaponRange(min,max,bit) self.min=min;self.max=max;self.bit=bit;return self end
  created[platoonName]=p
  return p
end
local function ownerFor(descriptor)
  local c={}; function c:GetName() return descriptor.physicalGroupName end
  return {arty={Controllable=c,AssignTargetCoord=function() end,RemoveTarget=function() end}}
end
local registry=Registry.New({
  commander=commander,brigades=brigades,
  descriptors={
    {id="ARTY_BOSTICK",siteId="BOSTICK",templateName="TPL_ARTY_SELECT_BOSTICK",platoonName="PLT_ARTY_SELECT_BOSTICK",physicalGroupName="TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",rangeMinNm=0.1,rangeMaxNm=9.0,performance=70},
    {id="ARTY_WRIGHT",siteId="WRIGHT",templateName="TPL_ARTY_SELECT_WRIGHT",platoonName="PLT_ARTY_SELECT_WRIGHT",physicalGroupName="TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",rangeMinNm=0.2,rangeMaxNm=8.0,performance=80},
  },
  platoonFactory=platoonFactory,resolveTemplateGroup=function(name) return groups[name] end,
  resolveFunctionalArty=function(descriptor) return ownerFor(descriptor) end,missionTypeArty="ARTY",weaponFlagAuto=999,
})
eq(#commander.brigades,2,"one registration per brigade")
eq(created.PLT_ARTY_SELECT_BOSTICK.kind,"ARTY","ARTY capability")
eq(created.PLT_ARTY_SELECT_BOSTICK.missionRange,0,"broad cohort range disabled")
eq(created.PLT_ARTY_SELECT_BOSTICK.min,0.1,"min weapon range")
eq(created.PLT_ARTY_SELECT_BOSTICK.max,9.0,"max weapon range")
local asset={assignment="PLT_ARTY_SELECT_WRIGHT",templatename="TPL_ARTY_SELECT_WRIGHT",spawned=false}
local owner,reason=registry:ResolveFunctionalArty(asset,brigades.WRIGHT,{},{},{})
yes(owner~=nil,"descriptor maps to owner"); eq(reason,nil,"owner reason"); eq(owner.selectionDescriptorId,"ARTY_WRIGHT","descriptor identity attached")
asset.spawned=true
local spawned,spawnedReason=registry:ResolveFunctionalArty(asset,brigades.WRIGHT,{},{},{})
eq(spawned,nil,"spawned descriptor rejected"); eq(spawnedReason,"ARTY_SELECTION_DESCRIPTOR_SPAWNED","spawned descriptor reason")
asset.spawned=false
local wrong,wrongReason=registry:ResolveFunctionalArty(asset,brigades.BOSTICK,{},{},{})
eq(wrong,nil,"wrong legion rejected"); yes(wrongReason:find("LEGION_MISMATCH",1,true)~=nil,"wrong legion reason")
groups.TPL_ARTY_SELECT_BOSTICK.alive=true
local aliveOk=pcall(function()
  Registry.New({commander={AddBrigade=function() end},brigades={BOSTICK=brigade("B2")},
    descriptors={{id="X",siteId="BOSTICK",templateName="TPL_ARTY_SELECT_BOSTICK",platoonName="PLT_X",physicalGroupName="REAL",rangeMinNm=0,rangeMaxNm=1}},
    platoonFactory=platoonFactory,resolveTemplateGroup=function(name) return groups[name] end,resolveFunctionalArty=function() return nil end,
    missionTypeArty="ARTY",weaponFlagAuto=999})
end)
no(aliveOk,"alive descriptor must fail before WAREHOUSE registration")
print("PASS test_fire_support_strategic_resupply_arty_selection_descriptor_registry")
