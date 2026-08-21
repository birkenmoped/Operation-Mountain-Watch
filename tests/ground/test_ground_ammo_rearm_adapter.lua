local CampaignState = dofile("scripts/campaign/OMW_CampaignState.lua")
local RearmAdapter = dofile("scripts/ground/OMW_GroundAmmoRearmAdapter.lua")

local function fail(message)
  error("GROUND_AMMO_REARM_ADAPTER_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local function newStore(quantity)
  return CampaignState.New({
    schemaVersion = "GROUND-AMMO-REARM-TEST-1",
    nodes = {
      {
        nodeId = "GROUND_NODE_BOSTICK",
        airbaseName = "BOSTICK",
        resources = {
          GROUND_AMMO_PACKAGE = { quantity = quantity, unit = "count" },
        },
      },
    },
  })
end

local function newFakeArty(options)
  options = options or {}
  local arty = { rearmingGroup = nil, onRoad = nil, started = false, rearmCalled = false }
  function arty:SetRearmingGroup(group) self.rearmingGroup = group return self end
  function arty:SetRearmingGroupOnRoad(onRoad) self.onRoad = onRoad return self end
  function arty:SetRearmingDistance(distance) self.rearmingDistance = distance return self end
  function arty:SetRearmingGroupSpeed(speed) self.rearmingSpeedKph = speed return self end
  function arty:Start() self.started = true return self end
  function arty:Rearm()
    self.rearmCalled = true
    if options.reject then return false end
    if self.OnBeforeRearm and self:OnBeforeRearm({}, "CombatReady", "Rearm", "Rearming") == false then return false end
    return true
  end
  function arty:CompleteRearm()
    if self.OnAfterRearmed then self:OnAfterRearmed({}, "Rearming", "Rearmed", "Rearmed") end
  end
  return arty
end

local artilleryGroup = { name = "TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2" }
local rearmingGroup = { name = "TPL_BLUE_GND_SUP_M1083" }

do
  local store = newStore(3)
  local fakeArty = newFakeArty()
  local rearmedCount = 0
  local service = RearmAdapter.New({
    store = store,
    campaignState = CampaignState,
    artyFactory = function(group, alias)
      expectEqual(group, artilleryGroup, "ARTY_GROUP")
      expectEqual(alias, "Bostick L118", "ARTY_ALIAS")
      return fakeArty
    end,
    onRearmed = function(context)
      rearmedCount = rearmedCount + 1
      expectEqual(context.status, "REARMED", "CALLBACK_STATUS")
    end,
  })

  local context, created = service:Request({
    transactionId = "GROUND-REARM-BOSTICK-001",
    nodeId = "GROUND_NODE_BOSTICK",
    artilleryGroup = artilleryGroup,
    rearmingGroup = rearmingGroup,
    alias = "Bostick L118",
    quantity = 1,
    rearmingDistance = 100,
    rearmingSpeedKph = 25,
  })

  expectEqual(created, true, "TRANSACTION_CREATED")
  expectEqual(context.status, "CONSUMED", "STATUS_AFTER_REARM_ACCEPT")
  expectEqual(fakeArty.started, true, "ARTY_STARTED")
  expectEqual(fakeArty.rearmCalled, true, "ARTY_REARM_CALLED")
  expectEqual(fakeArty.rearmingGroup, rearmingGroup, "REARMING_GROUP")
  expectEqual(fakeArty.onRoad, true, "ON_ROAD")
  expectEqual(fakeArty.rearmingDistance, 100, "REARMING_DISTANCE")
  expectEqual(fakeArty.rearmingSpeedKph, 25, "REARMING_SPEED")
  expectEqual(store:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 2, "AMMO_AFTER_CONSUME")
  expectEqual(store:GetTransaction("GROUND-REARM-BOSTICK-001").status, CampaignState.TransactionStatus.CONSUMED, "TX_CONSUMED")

  fakeArty:CompleteRearm()
  expectEqual(context.status, "REARMED", "STATUS_AFTER_COMPLETE")
  expectEqual(rearmedCount, 1, "REARMED_CALLBACK_COUNT")
end

do
  local store = newStore(3)
  local fakeArty = newFakeArty({ reject = true })
  local service = RearmAdapter.New({ store = store, campaignState = CampaignState, artyFactory = function() return fakeArty end })
  local context = service:Request({
    transactionId = "GROUND-REARM-BOSTICK-REJECT",
    nodeId = "GROUND_NODE_BOSTICK",
    artilleryGroup = artilleryGroup,
    rearmingGroup = rearmingGroup,
  })
  expectEqual(context.status, "REJECTED", "REJECT_STATUS")
  expectEqual(store:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 3, "AMMO_AFTER_REJECT")
  expectEqual(store:GetTransaction("GROUND-REARM-BOSTICK-REJECT").status, CampaignState.TransactionStatus.CANCELLED, "TX_CANCELLED")
end

do
  local store = newStore(3)
  local fakeArty = newFakeArty()
  local factoryCalls = 0
  local service = RearmAdapter.New({
    store = store,
    campaignState = CampaignState,
    artyFactory = function() factoryCalls = factoryCalls + 1 return fakeArty end,
  })
  local first, firstCreated = service:Request({
    transactionId = "GROUND-REARM-BOSTICK-IDEMPOTENT",
    nodeId = "GROUND_NODE_BOSTICK",
    artilleryGroup = artilleryGroup,
    rearmingGroup = rearmingGroup,
  })
  local second, secondCreated = service:Request({
    transactionId = "GROUND-REARM-BOSTICK-IDEMPOTENT",
    nodeId = "GROUND_NODE_BOSTICK",
    artilleryGroup = artilleryGroup,
    rearmingGroup = rearmingGroup,
  })
  expectEqual(first, second, "IDEMPOTENT_CONTEXT")
  expectEqual(firstCreated, true, "FIRST_CREATED")
  expectEqual(secondCreated, false, "SECOND_CREATED")
  expectEqual(factoryCalls, 1, "FACTORY_CALLS")
  expectEqual(store:GetResource("GROUND_NODE_BOSTICK", "GROUND_AMMO_PACKAGE").available, 2, "IDEMPOTENT_AMMO")
end

print("PASS Ground CampaignState consumption to ARTY rearm adapter contract")
