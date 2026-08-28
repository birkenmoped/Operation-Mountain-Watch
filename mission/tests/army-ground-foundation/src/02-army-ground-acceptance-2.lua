-- Operation Mountain Watch - ARMY Ground Foundation Acceptance 2 harness.
-- Scope: one Joyce BRIGADE, one patrol PLATOON, staged mounted movement,
-- road convoy approach, Vee tactical deployment, ARMOREDGUARD halt and hold.

local TEST_ID = "ARMY-GROUND-ACCEPTANCE-2-1"
local TAG = "OMW_GND_A2"

local WAREHOUSE_NAME = "WH_BLUE_GND_JOYCE"
local BRIGADE_NAME = "BDE_BLUE_GND_JOYCE"
local PLATOON_NAME = "PLT_BLUE_GND_JOYCE_PATROL"
local TEMPLATE_NAME = "TPL_BLUE_GND_PATROL_MATV_4"
local ACCESS_ZONE_NAME = "ZON_BLUE_GND_JOYCE_ACCESS"
local OBS_ZONE_NAME = "ZON_BLUE_GND_JOYCE_PATROL_TEST_01"

local POST_START_DELAY_SEC = 5
local APPROACH_HOLD_SEC = 10
local FOLLOWUP_DELAY_SEC = 2
local HOLD_STABILITY_SEC = 20
local APPROACH_STANDOFF_M = 1500
local MIN_TACTICAL_LEG_M = 1050
local HOLD_MAX_MOVEMENT_M = 75
local TARGET_MAX_DISTANCE_M = 250
local ROAD_SPEED_KNOTS = 10
local TACTICAL_SPEED_KNOTS = 8

local state = {
  failed = false,
  reservation = "RESERVED",
  spawnCount = 0,
  firstArmyGroup = nil,
  firstArmyGroupName = nil,
  mission1 = nil,
  mission2 = nil,
  mission1Done = false,
  mission2Executing = false,
  approachCoord = nil,
  targetCoord = nil,
  holdStartCoord = nil,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function fail(reason)
  if state.failed then
    return
  end
  state.failed = true
  log("FAIL " .. tostring(reason))
end

local function requireObject(value, label)
  if not value then
    fail("MISSING_OBJECT " .. label)
    return false
  end
  return true
end

local function roundMeters(value)
  return math.floor((value or 0) + 0.5)
end

log("START testId=" .. TEST_ID)

local warehouseHost = UNIT:FindByName(WAREHOUSE_NAME)
if not warehouseHost then
  warehouseHost = STATIC:FindByName(WAREHOUSE_NAME, false)
end

local templateGroup = GROUP:FindByName(TEMPLATE_NAME)
local accessZone = ZONE:FindByName(ACCESS_ZONE_NAME)
local observationZone = ZONE:FindByName(OBS_ZONE_NAME)

if not requireObject(warehouseHost, WAREHOUSE_NAME) then return end
if not requireObject(templateGroup, TEMPLATE_NAME) then return end
if not requireObject(accessZone, ACCESS_ZONE_NAME) then return end
if not requireObject(observationZone, OBS_ZONE_NAME) then return end

state.targetCoord = observationZone:GetCoordinate()
local accessCoord = accessZone:GetCoordinate()
local totalDistance = accessCoord:Get2DDistance(state.targetCoord)

if totalDistance <= APPROACH_STANDOFF_M + 500 then
  fail("GEOMETRY_TOO_SHORT totalDistanceM=" .. tostring(roundMeters(totalDistance)))
  return
end

local approachFraction = (totalDistance - APPROACH_STANDOFF_M) / totalDistance
local rawApproachCoord = accessCoord:GetIntermediateCoordinate(state.targetCoord, approachFraction)
state.approachCoord = rawApproachCoord:GetClosestPointToRoad() or rawApproachCoord

local tacticalLeg = state.approachCoord:Get2DDistance(state.targetCoord)
if tacticalLeg <= MIN_TACTICAL_LEG_M then
  fail("TACTICAL_LEG_TOO_SHORT distanceM=" .. tostring(roundMeters(tacticalLeg)))
  return
end

log("WAREHOUSE_RESOLVED " .. WAREHOUSE_NAME)
log("TEMPLATE_RESOLVED " .. TEMPLATE_NAME)
log("ACCESS_ZONE_RESOLVED " .. ACCESS_ZONE_NAME)
log("OBS_ZONE_RESOLVED " .. OBS_ZONE_NAME)
log("GEOMETRY totalDistanceM=" .. tostring(roundMeters(totalDistance)) .. " tacticalLegM=" .. tostring(roundMeters(tacticalLeg)))

local brigade = BRIGADE:New(WAREHOUSE_NAME, BRIGADE_NAME)
if not brigade then
  fail("BRIGADE_CONSTRUCTION")
  return
end

brigade:SetSpawnZone(accessZone, 1000)

local platoon = PLATOON:New(TEMPLATE_NAME, 1, PLATOON_NAME)
if not platoon then
  fail("PLATOON_CONSTRUCTION")
  return
end

platoon:AddMissionCapability(AUFTRAG.Type.ARMOREDGUARD, 100)
brigade:AddPlatoon(platoon)

local function verifyGuardHold()
  if state.failed or not state.mission2Executing then
    return
  end

  local armyGroup = state.firstArmyGroup
  if not armyGroup or not armyGroup:IsAlive() then
    fail("GUARD_GROUP_NOT_ALIVE")
    return
  end

  local currentCoord = armyGroup:GetCoordinate()
  local moved = state.holdStartCoord and state.holdStartCoord:Get2DDistance(currentCoord) or math.huge
  local targetDistance = currentCoord:Get2DDistance(state.targetCoord)

  if moved > HOLD_MAX_MOVEMENT_M then
    fail("GUARD_NOT_STABLE movedM=" .. tostring(roundMeters(moved)))
    return
  end

  if targetDistance > TARGET_MAX_DISTANCE_M then
    fail("GUARD_TOO_FAR_FROM_TARGET distanceM=" .. tostring(roundMeters(targetDistance)))
    return
  end

  log("GUARD_HOLD_STABLE movedM=" .. tostring(roundMeters(moved)) .. " targetDistanceM=" .. tostring(roundMeters(targetDistance)))
  log("RUNTIME_PASS_VISUAL_PENDING reservation=" .. state.reservation .. " spawnCount=" .. tostring(state.spawnCount) .. " formation=Vee")
end

local function queueMission2()
  if state.failed or not state.mission1Done then
    return
  end

  local armyGroup = state.firstArmyGroup
  if not armyGroup or not armyGroup:IsAlive() then
    fail("MISSION2_GROUP_NOT_ALIVE")
    return
  end

  local distanceToTarget = armyGroup:GetCoordinate():Get2DDistance(state.targetCoord)
  if distanceToTarget <= MIN_TACTICAL_LEG_M then
    fail("MISSION2_TACTICAL_LEG_TOO_SHORT distanceM=" .. tostring(roundMeters(distanceToTarget)))
    return
  end

  state.mission2 = AUFTRAG:NewARMOREDGUARD(state.targetCoord, ENUMS.Formation.Vehicle.Vee)
  state.mission2:SetName("OMW_GND_A2_OBSERVATION_GUARD")
  state.mission2:SetMissionSpeed(TACTICAL_SPEED_KNOTS)
  state.mission2:SetReturnToLegion(false)
  brigade:AddMission(state.mission2)

  log("MISSION2_QUEUED formation=Vee distanceM=" .. tostring(roundMeters(distanceToTarget)))
end

local function attachArmyGroupCallbacks(armyGroup)
  if armyGroup.__omwGroundA2Callbacks then
    return
  end
  armyGroup.__omwGroundA2Callbacks = true

  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if state.failed then
      return
    end

    if Mission == state.mission1 then
      local distance = self:GetCoordinate():Get2DDistance(state.approachCoord)
      log("APPROACH_GUARD_EXECUTING distanceM=" .. tostring(roundMeters(distance)) .. " formation=On Road")
      state.mission1:__Cancel(APPROACH_HOLD_SEC)
      log("APPROACH_CANCEL_SCHEDULED delaySec=" .. tostring(APPROACH_HOLD_SEC))

    elseif Mission == state.mission2 then
      if self ~= state.firstArmyGroup or self:GetName() ~= state.firstArmyGroupName then
        fail("MISSION2_DIFFERENT_GROUP name=" .. tostring(self:GetName()))
        return
      end

      state.mission2Executing = true
      state.holdStartCoord = self:GetCoordinate()
      local distance = state.holdStartCoord:Get2DDistance(state.targetCoord)
      log("OBS_GUARD_EXECUTING distanceM=" .. tostring(roundMeters(distance)) .. " formation=Vee")
      log("FORMATION_VISUAL_REQUIRED Vee")
      SCHEDULER:New(nil, verifyGuardHold, {}, HOLD_STABILITY_SEC)
    end
  end

  function armyGroup:OnAfterMissionDone(From, Event, To, Mission)
    if state.failed then
      return
    end

    if Mission == state.mission1 then
      state.mission1Done = true
      state.reservation = "FIELD_DEPLOYED"
      log("MISSION1_DONE reservation=" .. state.reservation)

      if not self:IsAlive() then
        fail("GROUP_REMOVED_AFTER_MISSION1")
        return
      end

      log("GROUP_STILL_ALIVE " .. tostring(self:GetName()))
      SCHEDULER:New(nil, queueMission2, {}, FOLLOWUP_DELAY_SEC)
    end
  end
end

function brigade:OnAfterAssetSpawned(From, Event, To, Group, Asset, Request)
  if state.failed then
    return
  end

  state.spawnCount = state.spawnCount + 1
  local groupName = Group and Group:GetName() or "UNKNOWN"

  if state.spawnCount == 1 then
    log("GROUP_MATERIALIZED " .. tostring(groupName))
  else
    fail("DUPLICATE_GROUP count=" .. tostring(state.spawnCount) .. " name=" .. tostring(groupName))
  end
end

function brigade:OnAfterArmyOnMission(From, Event, To, ArmyGroup, Mission)
  if state.failed then
    return
  end

  if not ArmyGroup then
    fail("ARMYGROUP_NIL")
    return
  end

  attachArmyGroupCallbacks(ArmyGroup)
  local groupName = ArmyGroup:GetName()

  if not state.firstArmyGroup then
    state.firstArmyGroup = ArmyGroup
    state.firstArmyGroupName = groupName
    log("FIRST_GROUP " .. tostring(groupName))
  elseif ArmyGroup ~= state.firstArmyGroup or groupName ~= state.firstArmyGroupName then
    fail("DUPLICATE_GROUP missionGroup=" .. tostring(groupName) .. " expected=" .. tostring(state.firstArmyGroupName))
    return
  end

  if state.spawnCount > 1 then
    fail("DUPLICATE_GROUP count=" .. tostring(state.spawnCount))
    return
  end

  if Mission == state.mission1 then
    log("MISSION1_ON_MISSION " .. tostring(groupName))
  elseif Mission == state.mission2 then
    log("MISSION2_SAME_GROUP " .. tostring(groupName))
  end
end

local function queueMission1()
  if state.failed then
    return
  end

  local availableAssets = platoon:CountAssets(true, AUFTRAG.Type.ARMOREDGUARD)
  if availableAssets ~= 1 then
    fail("PLATOON_ASSET_COUNT expected=1 actual=" .. tostring(availableAssets))
    return
  end

  log("PLATOON_READY assets=" .. tostring(availableAssets))

  state.reservation = "COMMITTED"
  state.mission1 = AUFTRAG:NewARMOREDGUARD(state.approachCoord, ENUMS.Formation.Vehicle.OnRoad)
  state.mission1:SetName("OMW_GND_A2_ROAD_APPROACH")
  state.mission1:SetMissionSpeed(ROAD_SPEED_KNOTS)
  state.mission1:SetReturnToLegion(false)
  brigade:AddMission(state.mission1)

  log("MISSION1_QUEUED reservation=" .. state.reservation .. " formation=On Road")
end

function brigade:OnAfterStart(From, Event, To)
  if state.failed then
    return
  end

  log("BRIGADE_STARTED " .. BRIGADE_NAME)
  SCHEDULER:New(nil, queueMission1, {}, POST_START_DELAY_SEC)
end

brigade:Start()
