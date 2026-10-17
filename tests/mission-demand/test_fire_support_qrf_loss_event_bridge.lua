local Factory = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")
local function eq(actual, expected, label)
  if actual ~= expected then error(label .. " expected=" .. tostring(expected)
    .. " actual=" .. tostring(actual), 2) end
end

local coordinate = {Get2DDistance=function() return 200 end}
local targetGroup = {
  IsInstanceOf=function(_,cls) return cls=="GROUP" end,
  IsAlive=function() return true end,
  GetCoordinate=function() return coordinate end,
  GetName=function() return "RED_LIVE" end,
}
local unit = {
  IsAlive=function() return true end,
  GetCoordinate=function() return coordinate end,
}
local zone = {IsCoordinateInZone=function() return true end}
local mission
AUFTRAG = {NewONGUARD=function(_,coord)
  eq(coord,coordinate,"QRF target coordinate")
  mission={
    SetReturnToLegion=function() end,
    SetTeleport=function() end,
    SetRequiredAssets=function() end,
    SetPriority=function() end,
    IsOver=function() return false end,
    Cancel=function() end,
  }
  return mission
end}
local losses,previous = 0,0
local factory=Factory.New({
  resolveTarget=function() return targetGroup,nil end,
  resolveTargets=function() return {unit} end,
  resolveEngageZone=function() return zone end,
  onGroupDestroyed=function(demand,context,group)
    losses=losses+1
    eq(demand.demandId,"QRF-A1","destruction correlation")
    eq(group.groupname,"ARMY-ONE","destroyed group")
  end,
})
local demand={
  demandId="QRF-A1",siteId="COP_HONAKER",supportType="QRF",priority=10
}
local result,ok = factory:Create(demand,{incident={incidentId="INC-HONAKER"}},{})
eq(ok,true,"QRF mission built via MOOSE")
local armyGroup={
  groupname="ARMY-ONE",
  GetCoordinate=function() return coordinate end,
  EngageTarget=function() end,
  OnAfterDestroyed=function() previous=previous+1 end,
}
result:_OMWQrfBindArmyGroup(armyGroup)
eq(type(armyGroup.OnAfterDestroyed),"function","MOOSE destruction callback linked")
armyGroup:OnAfterDestroyed("Active","Destroyed","Destroyed")
armyGroup:OnAfterDestroyed("Active","Destroyed","Destroyed")
eq(previous,2,"prior MOOSE handler retained")
eq(losses,1,"single replacement signal per destroyed QRF")
eq(result._OMWQrfLossReported,true,"loss deduped")
print("PASS test_fire_support_qrf_loss_event_bridge")
