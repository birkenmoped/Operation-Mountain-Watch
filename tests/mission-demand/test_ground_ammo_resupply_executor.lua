local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Executor = dofile("scripts/ground/OMW_GroundAmmoResupplyExecutor.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end

local store = CampaignState.New({
  nodes = {
    { nodeId="GROUND_NODE_JALALABAD", airbaseName="Jalalabad", resources={ GROUND_AMMO_PACKAGE={ quantity=100, unit="count" } } },
    { nodeId="GROUND_NODE_WRIGHT", airbaseName="Wright", resources={ GROUND_AMMO_PACKAGE={ quantity=15, unit="count" } } },
  },
})
local registry = MissionDemand.New()
local demand = registry:Create({
  id="RESUPPLY|GROUND_NODE_WRIGHT|GROUND_AMMO_PACKAGE|15",
  missionType=MissionDemand.Type.RESUPPLY,
  origin="GROUND_NODE_JALALABAD",
  objective="Restore Wright ammo",
  target={ nodeId="GROUND_NODE_WRIGHT", resourceId="GROUND_AMMO_PACKAGE", resourceClass="AMMO", requestedQuantity=15, targetQuantity=30 },
  priority=20,
  playerCapable=false,
  aiCapable=true,
  reservationState="UNRESERVED",
  successCriteria={ destinationQuantity=30 },
  failureConsequences={ resourceTransfer="NOT_RESERVED_OR_FAILED_BY_EXECUTOR" },
  createdReason="REORDER",
  dedupeKey="RESUPPLY|GROUND_NODE_WRIGHT|GROUND_AMMO_PACKAGE",
})

local destinationZone = { name="ZON_BLUE_GND_WRIGHT_ACCESS" }
local originZone = { name="ZON_BLUE_GND_JALALABAD_ACCESS" }
local mission = {
  cancelled=false,
  SetMissionSpeed=function(self, value) self.speed=value return self end,
  SetFormation=function(self, value) self.formation=value return self end,
  SetReturnToLegion=function(self, value) self.returnToLegion=value return self end,
  SetPriority=function(self, value) self.priority=value return self end,
  __Cancel=function(self, delay) self.cancelled=true self.cancelDelay=delay return self end,
  GetName=function() return "TEST_AMMOSUPPLY" end,
}
local brigade = {
  added=nil,
  AddMission=function(self, value) self.added=value return self end,
  I=function() end,
}
local deferredCallback, deferredSeconds
local returnedArmy, returnedZone
local executor = Executor.New({
  campaignState=CampaignState,
  store=store,
  missionDemand=MissionDemand,
  registry=registry,
  brigade=brigade,
  destinationZone=destinationZone,
  originZone=originZone,
  ammoResourceId="GROUND_AMMO_PACKAGE",
  assigneeId="BRIGADE:GROUND_NODE_JALALABAD",
  carrierEntityId="GROUND_AMMO_CARRIER|WRIGHT|1",
  missionSpeedKts=27,
  formation="OnRoad",
  returnDelaySeconds=30,
  missionFactory=function(zone)
    assertEqual(zone, destinationZone, "mission destination zone")
    return mission
  end,
  defer=function(callback, seconds)
    deferredCallback, deferredSeconds = callback, seconds
  end,
  returnToOrigin=function(army, zone)
    returnedArmy, returnedZone = army, zone
    return true
  end,
})

local execution, started, reason = executor:Start(demand)
assertTrue(started, "executor started")
assertEqual(reason, nil, "executor start reason")
assertEqual(brigade.added, mission, "brigade mission")
assertEqual(mission.speed, 27, "mission speed")
assertEqual(mission.formation, "OnRoad", "mission formation")
assertEqual(mission.returnToLegion, false, "mission return-to-legion")
assertEqual(mission.priority, 20, "mission priority")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.AI_ASSIGNED, "demand assigned")
assertEqual(registry:Get(demand.id).reservationState, "RESERVED", "reservation state reserved")
assertEqual(store:GetResource("GROUND_NODE_JALALABAD", "GROUND_AMMO_PACKAGE").available, 85, "origin reserved available")
assertEqual(store:GetResource("GROUND_NODE_JALALABAD", "GROUND_AMMO_PACKAGE").quantity, 100, "origin quantity before transit")

local duplicate, duplicateStarted, duplicateReason = executor:Start(registry:Get(demand.id))
assertEqual(duplicate, execution, "duplicate execution")
assertEqual(duplicateStarted, false, "duplicate not started")
assertEqual(duplicateReason, "ALREADY_STARTED", "duplicate reason")

brigade:OnAfterAssetSpawned("FROM", "AssetSpawned", "TO", {}, {}, {})
assertEqual(store:GetTransaction(execution.transactionId).status, CampaignState.TransactionStatus.LOADING, "transaction loading")
assertEqual(registry:Get(demand.id).reservationState, "LOADING", "reservation loading")

local army = {
  IsInZone=function(self, zone) return zone == destinationZone end,
}
brigade:OnAfterArmyOnMission("FROM", "ArmyOnMission", "TO", army, mission)
assertEqual(store:GetTransaction(execution.transactionId).status, CampaignState.TransactionStatus.IN_TRANSIT, "transaction in transit")
assertEqual(store:GetResource("GROUND_NODE_JALALABAD", "GROUND_AMMO_PACKAGE").quantity, 85, "origin debited")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.ACTIVE, "demand active")

army:OnAfterMissionExecute("FROM", "MissionExecute", "TO", mission)
assertEqual(store:GetTransaction(execution.transactionId).status, CampaignState.TransactionStatus.DELIVERED, "transaction delivered")
assertEqual(store:GetResource("GROUND_NODE_WRIGHT", "GROUND_AMMO_PACKAGE").quantity, 30, "destination credited")
assertEqual(registry:Get(demand.id).status, MissionDemand.Status.SUCCESS, "demand succeeded")
assertEqual(registry:Get(demand.id).reservationState, "DELIVERED", "reservation delivered")
assertEqual(mission.cancelled, true, "mission cancelled after delivery")

army:OnAfterMissionDone("FROM", "MissionDone", "TO", mission)
assertEqual(deferredSeconds, 30, "return settlement delay")
assertTrue(type(deferredCallback)=="function", "return callback scheduled")
deferredCallback()
assertEqual(returnedArmy, army, "returned army")
assertEqual(returnedZone, originZone, "returned origin zone")
army:OnAfterReturned("FROM", "Returned", "TO")
assertEqual(execution.returned, true, "execution returned")
assertEqual(execution.closed, true, "execution closed")

local failedStore = CampaignState.New({ nodes={
  { nodeId="GROUND_NODE_JALALABAD", airbaseName="Jalalabad", resources={ GROUND_AMMO_PACKAGE={ quantity=100, unit="count" } } },
  { nodeId="GROUND_NODE_WRIGHT", airbaseName="Wright", resources={ GROUND_AMMO_PACKAGE={ quantity=15, unit="count" } } },
} })
local failedRegistry = MissionDemand.New()
local failedDemand = failedRegistry:Create({
  id="RESUPPLY|GROUND_NODE_WRIGHT|GROUND_AMMO_PACKAGE|FAIL", missionType=MissionDemand.Type.RESUPPLY,
  origin="GROUND_NODE_JALALABAD", objective="Restore Wright ammo",
  target={ nodeId="GROUND_NODE_WRIGHT", resourceId="GROUND_AMMO_PACKAGE", requestedQuantity=15, targetQuantity=30 },
  priority=20, playerCapable=false, aiCapable=true, reservationState="UNRESERVED",
  successCriteria={}, failureConsequences={}, createdReason="REORDER",
  dedupeKey="RESUPPLY|GROUND_NODE_WRIGHT|GROUND_AMMO_PACKAGE",
})
local failedMission = { SetReturnToLegion=function() end, GetName=function() return "FAILED_AMMOSUPPLY" end }
local failedBrigade = { AddMission=function(self, value) self.added=value end, I=function() end }
local failedExecutor = Executor.New({
  campaignState=CampaignState, store=failedStore, missionDemand=MissionDemand, registry=failedRegistry,
  brigade=failedBrigade, destinationZone=destinationZone, originZone=originZone,
  ammoResourceId="GROUND_AMMO_PACKAGE", assigneeId="BRIGADE:JBAD", carrierEntityId="CARRIER:FAIL",
  missionFactory=function() return failedMission end,
  defer=function() end, returnToOrigin=function() end,
})
local failedExecution = failedExecutor:Start(failedDemand)
failedBrigade:OnAfterAssetSpawned("FROM", "AssetSpawned", "TO", {}, {}, {})
local failedArmy = { IsInZone=function() return false end }
failedBrigade:OnAfterArmyOnMission("FROM", "ArmyOnMission", "TO", failedArmy, failedMission)
failedArmy:OnAfterMissionExecute("FROM", "MissionExecute", "TO", failedMission)
assertEqual(failedStore:GetTransaction(failedExecution.transactionId).status, CampaignState.TransactionStatus.LOST, "out-of-zone transfer lost")
assertEqual(failedRegistry:Get(failedDemand.id).status, MissionDemand.Status.FAILED, "out-of-zone demand failed")
assertEqual(failedStore:GetResource("GROUND_NODE_WRIGHT", "GROUND_AMMO_PACKAGE").quantity, 15, "failed destination not credited")

print("PASS test_ground_ammo_resupply_executor")
