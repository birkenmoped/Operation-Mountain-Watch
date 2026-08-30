-- Operation Mountain Watch - native MOOSE Ground homezone return Acceptance 1.
--
-- Purpose:
-- prove the standard MOOSE BRIGADE/PLATOON/ARMYGROUP return-to-origin lifecycle
-- without an OMW spawn-zone override, without SetReturnToLegion(false), and
-- without an explicit custom RTZ command.

local TEST_ID = "GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1"
local WAREHOUSE_NAME = "WH_BLUE_GND_JOYCE"
local BRIGADE_NAME = "BDE_BLUE_GND_JOYCE_NATIVE_HOMEZONE_A1"
local PLATOON_NAME = "PLT_BLUE_GND_JOYCE_NATIVE_HOMEZONE_A1"
local TEMPLATE_NAME = "TPL_BLUE_GND_PATROL_MATV_4"
local DESTINATION_ZONE_NAME = "ZON_BLUE_GND_JOYCE_PATROL_TEST_01"
local EXPECTED_DEFAULT_HOMEZONE_NAME = "Warehouse WH_BLUE_GND_JOYCE spawn zone"
local MISSION_NAME = "OMW_GROUND_NATIVE_HOMEZONE_RETURN_A1"
local MISSION_SPEED_KTS = 27
local MISSION_DURATION_SEC = 30
local POST_START_DELAY_SEC = 5
local DESTINATION_CHECK_INTERVAL_SEC = 15
local DESTINATION_EXECUTION_GRACE_SEC = 90
local RETURN_SETTLEMENT_DELAY_SEC = 12

local logger = BASE:New()
local state = {
  failed = false,
  passed = false,
  brigade = nil,
  platoon = nil,
  mission = nil,
  armyGroup = nil,
  destinationZone = nil,
  spawnCount = 0,
  armyOnMissionCount = 0,
  missionExecuteCount = 0,
  missionDoneCount = 0,
  rtzCount = 0,
  returnedCount = 0,
  addAssetCount = 0,
  destinationObserved = false,
  armyGroupName = nil,
  rtzZoneName = nil,
}

local function log(message)
  logger:I(string.format("[OMW][%s] %s", TEST_ID, tostring(message)))
end

local function fail(message)
  if state.failed or state.passed then return end
  state.failed = true
  logger:E(string.format("[OMW][%s] FAIL %s", TEST_ID, tostring(message)))
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(string.format("%s expected=%s actual=%s", tostring(label), tostring(expected), tostring(actual)))
    return false
  end
  return true
end

local function verifyFinalState()
  if state.failed or state.passed then return end
  if not expectEqual(state.spawnCount, 1, "SPAWN_COUNT") then return end
  if not expectEqual(state.armyOnMissionCount, 1, "ARMY_ON_MISSION_COUNT") then return end
  if not expectEqual(state.missionExecuteCount, 1, "MISSION_EXECUTE_COUNT") then return end
  if not expectEqual(state.missionDoneCount, 1, "MISSION_DONE_COUNT") then return end
  if not expectEqual(state.rtzCount, 1, "RTZ_COUNT") then return end
  if not expectEqual(state.returnedCount, 1, "RETURNED_COUNT") then return end
  if not expectEqual(state.addAssetCount, 1, "WAREHOUSE_ADD_ASSET_COUNT") then return end
  if state.destinationObserved ~= true then fail("DESTINATION_NOT_OBSERVED"); return end
  if not expectEqual(state.rtzZoneName, EXPECTED_DEFAULT_HOMEZONE_NAME, "RTZ_DEFAULT_HOMEZONE") then return end
  if state.armyGroup and state.armyGroup:IsAlive() then
    fail("PHYSICAL_GROUP_STILL_ALIVE_AFTER_WAREHOUSE_ADD_ASSET")
    return
  end

  state.passed = true
  log(string.format(
    "PASS originWarehouse=%s template=%s mission=NOTHING destination=%s returnMode=NATIVE_MOOSE legionReturn=DEFAULT_TRUE rtzZone=%s returnedCount=%d warehouseAddAssetCount=%d physicalCleanup=true",
    WAREHOUSE_NAME,
    TEMPLATE_NAME,
    DESTINATION_ZONE_NAME,
    tostring(state.rtzZoneName),
    state.returnedCount,
    state.addAssetCount
  ))
end

local function checkDestinationProgress()
  if state.failed or state.passed or state.destinationObserved then return end
  if not state.armyGroup or not state.armyGroup:IsAlive() then return end

  if state.armyGroup:IsInZone(state.destinationZone) == true then
    state.destinationObserved = true
    log(string.format(
      "DESTINATION_ZONE_ENTERED group=%s zone=%s graceSec=%d",
      tostring(state.armyGroup:GetName()),
      DESTINATION_ZONE_NAME,
      DESTINATION_EXECUTION_GRACE_SEC
    ))

    SCHEDULER:New(nil, function()
      if state.failed or state.passed or state.missionExecuteCount > 0 then return end
      fail(string.format(
        "DESTINATION_EXECUTION_TIMEOUT seconds=%d missionExecuteCount=%d missionDoneCount=%d",
        DESTINATION_EXECUTION_GRACE_SEC,
        state.missionExecuteCount,
        state.missionDoneCount
      ))
    end, {}, DESTINATION_EXECUTION_GRACE_SEC)
    return
  end

  SCHEDULER:New(nil, checkDestinationProgress, {}, DESTINATION_CHECK_INTERVAL_SEC)
end

local function attachArmyGroupCallbacks(armyGroup)
  if armyGroup.__omwNativeHomezoneAcceptanceCallbacks then return end
  armyGroup.__omwNativeHomezoneAcceptanceCallbacks = true

  function armyGroup:OnAfterMissionExecute(From, Event, To, Mission)
    if state.failed or Mission ~= state.mission then return end
    state.missionExecuteCount = state.missionExecuteCount + 1
    if not expectEqual(state.missionExecuteCount, 1, "MISSION_EXECUTE_COUNT_EVENT") then return end
    if self:IsInZone(state.destinationZone) ~= true then
      fail("MISSION_EXECUTE_OUTSIDE_DESTINATION")
      return
    end
    log(string.format(
      "MISSION_EXECUTE_OBSERVED group=%s destination=%s durationSec=%d",
      tostring(self:GetName()),
      DESTINATION_ZONE_NAME,
      MISSION_DURATION_SEC
    ))
  end

  function armyGroup:OnAfterMissionDone(From, Event, To, Mission)
    if state.failed or Mission ~= state.mission then return end
    state.missionDoneCount = state.missionDoneCount + 1
    if not expectEqual(state.missionDoneCount, 1, "MISSION_DONE_COUNT_EVENT") then return end
    log(string.format(
      "MISSION_DONE group=%s returnController=NATIVE_MOOSE explicitRTZ=false setReturnToLegionFalse=false",
      tostring(self:GetName())
    ))
  end

  function armyGroup:OnAfterRTZ(From, Event, To, Zone, Formation)
    if state.failed then return end
    state.rtzCount = state.rtzCount + 1
    if not expectEqual(state.rtzCount, 1, "RTZ_COUNT_EVENT") then return end
    if not Zone then fail("NATIVE_RTZ_ZONE_NIL"); return end
    state.rtzZoneName = Zone:GetName()
    if not expectEqual(state.rtzZoneName, EXPECTED_DEFAULT_HOMEZONE_NAME, "NATIVE_RTZ_ZONE_NAME") then return end
    log(string.format(
      "NATIVE_RTZ_ACTIVE group=%s zone=%s formation=%s source=LEGION_SPAWNZONE",
      tostring(self:GetName()),
      tostring(state.rtzZoneName),
      tostring(Formation)
    ))
  end

  function armyGroup:OnAfterReturned(From, Event, To)
    if state.failed then return end
    if self ~= state.armyGroup then fail("RETURNED_DIFFERENT_GROUP"); return end
    state.returnedCount = state.returnedCount + 1
    if not expectEqual(state.returnedCount, 1, "RETURNED_COUNT_EVENT") then return end
    log(string.format(
      "RETURNED_HANDOFF group=%s originWarehouse=%s rtzZone=%s",
      tostring(self:GetName()),
      WAREHOUSE_NAME,
      tostring(state.rtzZoneName)
    ))
  end
end

state.destinationZone = ZONE:FindByName(DESTINATION_ZONE_NAME)
if not state.destinationZone then
  error(string.format("[OMW][%s] FAIL missing destination zone=%s", TEST_ID, DESTINATION_ZONE_NAME), 2)
end

local templateGroup = GROUP:FindByName(TEMPLATE_NAME)
if not templateGroup then
  error(string.format("[OMW][%s] FAIL missing template=%s", TEST_ID, TEMPLATE_NAME), 2)
end

state.brigade = BRIGADE:New(WAREHOUSE_NAME, BRIGADE_NAME)
state.platoon = PLATOON:New(TEMPLATE_NAME, 1, PLATOON_NAME)
state.platoon:AddMissionCapability(AUFTRAG.Type.NOTHING, 100)
state.brigade:AddPlatoon(state.platoon)

state.brigade.OnAfterAssetSpawned = function(self, From, Event, To, Group, Asset, Request)
  if state.failed then return end
  state.spawnCount = state.spawnCount + 1
  if not expectEqual(state.spawnCount, 1, "SPAWN_COUNT_EVENT") then return end
  state.armyGroupName = Group and Group:GetName() or nil
  log(string.format(
    "GROUP_MATERIALIZED name=%s template=%s spawnZoneMode=MOOSE_DEFAULT_250M warehouse=%s",
    tostring(state.armyGroupName),
    TEMPLATE_NAME,
    WAREHOUSE_NAME
  ))
end

state.brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
  if state.failed or Mission ~= state.mission then return end
  state.armyOnMissionCount = state.armyOnMissionCount + 1
  if not expectEqual(state.armyOnMissionCount, 1, "ARMY_ON_MISSION_COUNT_EVENT") then return end
  if not ArmyGroup then fail("ARMYGROUP_NIL"); return end

  state.armyGroup = ArmyGroup
  state.armyGroupName = ArmyGroup:GetName()
  attachArmyGroupCallbacks(ArmyGroup)
  log(string.format(
    "ARMY_ON_MISSION group=%s mission=NOTHING destination=%s returnToLegion=DEFAULT_TRUE explicitRTZ=false",
    tostring(state.armyGroupName),
    DESTINATION_ZONE_NAME
  ))
  SCHEDULER:New(nil, checkDestinationProgress, {}, DESTINATION_CHECK_INTERVAL_SEC)
end

state.brigade.OnAfterAddAsset = function(self, From, Event, To, Group, Groups)
  if state.failed then return end
  state.addAssetCount = state.addAssetCount + 1
  if not expectEqual(state.addAssetCount, 1, "WAREHOUSE_ADD_ASSET_COUNT_EVENT") then return end
  log(string.format(
    "WAREHOUSE_ADD_ASSET group=%s originWarehouse=%s",
    tostring(Group and Group:GetName() or state.armyGroupName),
    WAREHOUSE_NAME
  ))
  SCHEDULER:New(nil, verifyFinalState, {}, RETURN_SETTLEMENT_DELAY_SEC)
end

state.brigade.OnAfterStart = function(self, From, Event, To)
  if state.failed then return end
  log(string.format(
    "BRIGADE_STARTED brigade=%s warehouse=%s spawnZoneOverride=false expectedDefaultSpawnZone=%s",
    BRIGADE_NAME,
    WAREHOUSE_NAME,
    EXPECTED_DEFAULT_HOMEZONE_NAME
  ))

  SCHEDULER:New(nil, function()
    if state.failed then return end
    local availableAssets = state.platoon:CountAssets(true, AUFTRAG.Type.NOTHING)
    if not expectEqual(availableAssets, 1, "PLATOON_ASSET_COUNT") then return end

    state.mission = AUFTRAG:NewNOTHING(state.destinationZone)
    state.mission:SetName(MISSION_NAME)
    state.mission:SetMissionSpeed(MISSION_SPEED_KTS)
    state.mission:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
    state.mission:SetDuration(MISSION_DURATION_SEC)
    state.mission:SetPriority(20, true)
    state.brigade:AddMission(state.mission)

    log(string.format(
      "MISSION_QUEUED type=NOTHING destination=%s speedKt=%d formation=OnRoad durationSec=%d spawnZoneOverride=false setReturnToLegionFalse=false explicitRTZ=false",
      DESTINATION_ZONE_NAME,
      MISSION_SPEED_KTS,
      MISSION_DURATION_SEC
    ))
  end, {}, POST_START_DELAY_SEC)
end

log(string.format(
  "READY warehouse=%s template=%s destination=%s expectedDefaultSpawnZone=%s testPurpose=NATIVE_MOOSE_RETURN_TO_ORIGIN",
  WAREHOUSE_NAME,
  TEMPLATE_NAME,
  DESTINATION_ZONE_NAME,
  EXPECTED_DEFAULT_HOMEZONE_NAME
))
state.brigade:Start()
