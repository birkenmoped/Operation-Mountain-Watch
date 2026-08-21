local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local RearmAdapter = dofile("scripts/ground/OMW_GroundAmmoRearmAdapter.lua")

local function fail(message)
  error("GROUND_AMMO_REARM_PRESTARTED_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local store = CampaignState.New({
  schemaVersion = "GROUND-AMMO-REARM-PRESTARTED-TEST-1",
  nodes = {
    {
      nodeId = "GROUND_NODE_BOSTICK",
      airbaseName = "BOSTICK",
      resources = {
        GROUND_AMMO_PACKAGE = { quantity = 2, unit = "count" },
      },
    },
  },
})

local startCalls = 0
local rearmCalls = 0
local fakeArty = {}
function fakeArty:SetRearmingGroup(group) self.rearmingGroup = group return self end
function fakeArty:SetRearmingGroupOnRoad(onRoad) self.onRoad = onRoad return self end
function fakeArty:Start() startCalls = startCalls + 1 return self end
function fakeArty:Rearm()
  rearmCalls = rearmCalls + 1
  if self.OnBeforeRearm and self:OnBeforeRearm({}, "CombatReady", "Rearm", "Rearming") == false then
    return false
  end
  return true
end

local artilleryGroup = { name = "TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2" }
local rearmingGroup = { name = "TPL_BLUE_GND_SUP_M1083" }
local adapter = RearmAdapter.New({
  store = store,
  campaignState = CampaignState,
  artyFactory = function()
    return fakeArty
  end,
})

local context, created = adapter:Request({
  transactionId = "GROUND-REARM-BOSTICK-PRESTARTED",
  nodeId = "GROUND_NODE_BOSTICK",
  artilleryGroup = artilleryGroup,
  rearmingGroup = rearmingGroup,
  startArty = false,
})

expectEqual(created, true, "TRANSACTION_CREATED")
expectEqual(startCalls, 0, "PRESTARTED_ARTY_NOT_RESTARTED")
expectEqual(rearmCalls, 1, "REARM_CALLED")
expectEqual(context.startArty, false, "CONTEXT_START_ARTY")
expectEqual(context.status, "CONSUMED", "CONTEXT_STATUS")
expectEqual(store:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 1, "AMMO_AFTER_CONSUME")
expectEqual(store:GetTransaction("GROUND-REARM-BOSTICK-PRESTARTED").status, CampaignState.TransactionStatus.CONSUMED, "TRANSACTION_STATUS")

print("PASS Ground prestarted ARTY rearm preserves original ammo baseline contract")
