-- Operation Mountain Watch - ARMY Ground Foundation Acceptance 1 harness.
-- Scope: one Joyce BRIGADE, one PATROL PLATOON, one PATROLZONE mission,
-- SetReturnToLegion(false), MissionDone persistence, and same-group follow-up reuse.

local TEST_ID = "ARMY-GROUND-ACCEPTANCE-1-1"
local TAG = "OMW_GND_A1"

local WAREHOUSE_NAME = "WH_BLUE_GND_JOYCE"
local BRIGADE_NAME = "BDE_BLUE_GND_JOYCE"
local PLATOON_NAME = "PLT_BLUE_GND_JOYCE_PATROL"
local TEMPLATE_NAME = "TPL_BLUE_GND_PATROL_MATV_4"
local ACCESS_ZONE_NAME = "ZON_BLUE_GND_JOYCE_ACCESS"
local PATROL_ZONE_NAME = "ZON_BLUE_GND_JOYCE_PATROL_TEST_01"

local POST_START_DELAY_SEC = 5
local MISSION1_CANCEL_DELAY_SEC = 120
local FOLLOWUP_DELAY_SEC = 5
local PATROL_SPEED_KNOTS = 10

local state = {
  failed = false,
  reservation = "RESERVED",
  spawnCount = 0,
  spawnedGroupName = nil,
  firstArmyGroup = nil,
  firstArmyGroupName = nil,
  mission1 = nil,
  mission2 = nil,
  mission1CancelScheduled = false,
  mission1Done = false,
  mission2Seen = false,
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

log("START testId=" .. TEST_ID)

local warehouseHost = UNIT:FindByName(WAREHOUSE_NAME)
if not warehouseHost then
  warehouseHost = STATIC:FindByName(WAREHOUSE_NAME, false)
end

local templateGroup = GROUP:FindByName(TEMPLATE_NAME)
local accessZone = ZONE:FindByName(ACCESS_ZONE_NAME)
local patrolZone = ZONE:FindByName(PATROL_ZONE_NAME)

if not requireObject(warehouseHost, WAREHOUSE_NAME) then return end
if not requireObject(templateGroup, TEMPLATE_NAME) then return end
if not requireObject(accessZone, ACCESS_ZONE_NAME) then return end
if not requireObject(patrolZone, PATROL_ZONE_NAME) then return end

log("WAREHOUSE_RESOLVED " .. WAREHOUSE_NAME)
log("TEMPLATE_RESOLVED " .. TEMPLATE_NAME)
log("ACCESS_ZONE_RESOLVED " .. ACCESS_ZONE_NAME)
log("PATROL_ZONE_RESOLVED " .. PATROL_ZONE_NAME)

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

platoon:AddMissionCapability(AUFTRAG.Type.PATROLZONE, 100)
brigade:AddPlatoon(platoon)

local function queueMission2()
  if state.failed or not state.mission1Done then
    return
  end

  state.mission2 = AUFTRAG:NewPATROLZONE(patrolZone, PATROL_SPEED_KNOTS, nil, nil)
  state.mission2:SetName("OMW_GND_A1_PATROL_2")
  state.mission2:SetReturnToLegion(false)
  brigade:AddMission(state.mission2)
  log("MISSION2_QUEUED reservation=" .. state.reservation)
end

local function attachArmyGroupCallbacks(armyGroup)
  if armyGroup.__omwGroundA1Callbacks then
    return
  end
  armyGroup.__omwGroundA1Callbacks = true

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

      local groupName = self:GetName()
      log("GROUP_STILL_ALIVE " .. tostring(groupName))

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
    state.spawnedGroupName = groupName
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

  local groupName = ArmyGroup:GetName()
  attachArmyGroupCallbacks(ArmyGroup)

  if Mission == state.mission1 then
    if state.firstArmyGroup and state.firstArmyGroup ~= ArmyGroup then
      fail("DUPLICATE_GROUP first=" .. tostring(state.firstArmyGroupName) .. " second=" .. tostring(groupName))
      return
    end

    state.firstArmyGroup = ArmyGroup
    state.firstArmyGroupName = groupName

    if not state.spawnedGroupName then
      state.spawnedGroupName = groupName
      log("GROUP_MATERIALIZED " .. tostring(groupName))
    end

    if not state.mission1CancelScheduled then
      state.mission1CancelScheduled = true
      state.mission1:__Cancel(MISSION1_CANCEL_DELAY_SEC)
      log("MISSION1_CANCEL_SCHEDULED delaySec=" .. tostring(MISSION1_CANCEL_DELAY_SEC))
    end

  elseif Mission == state.mission2 then
    state.mission2Seen = true

    if not state.firstArmyGroup then
      fail("MISSION2_WITHOUT_MISSION1_GROUP")
      return
    end

    if ArmyGroup ~= state.firstArmyGroup or groupName ~= state.firstArmyGroupName then
      fail("DUPLICATE_GROUP mission2=" .. tostring(groupName) .. " expected=" .. tostring(state.firstArmyGroupName))
      return
    end

    if state.spawnCount > 1 then
      fail("DUPLICATE_GROUP count=" .. tostring(state.spawnCount))
      return
    end

    if not ArmyGroup:IsAlive() then
      fail("MISSION2_GROUP_NOT_ALIVE")
      return
    end

    log("SAME_GROUP_REUSED " .. tostring(groupName))
    log("PASS reservation=" .. state.reservation .. " spawnCount=" .. tostring(state.spawnCount))
  end
end

local function queueMission1()
  if state.failed then
    return
  end

  local availableAssets = platoon:CountAssets(true, AUFTRAG.Type.PATROLZONE)
  if availableAssets ~= 1 then
    fail("PLATOON_ASSET_COUNT expected=1 actual=" .. tostring(availableAssets))
    return
  end

  log("PLATOON_READY assets=" .. tostring(availableAssets))

  state.reservation = "COMMITTED"
  state.mission1 = AUFTRAG:NewPATROLZONE(patrolZone, PATROL_SPEED_KNOTS, nil, nil)
  state.mission1:SetName("OMW_GND_A1_PATROL_1")
  state.mission1:SetReturnToLegion(false)
  brigade:AddMission(state.mission1)

  log("MISSION1_QUEUED reservation=" .. state.reservation)
end

function brigade:OnAfterStart(From, Event, To)
  if state.failed then
    return
  end

  log("BRIGADE_STARTED " .. BRIGADE_NAME)
  SCHEDULER:New(nil, queueMission1, {}, POST_START_DELAY_SEC)
end

brigade:Start()
