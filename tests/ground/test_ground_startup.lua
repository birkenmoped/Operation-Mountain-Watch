local flags = {
  OMW_WAREHOUSE_READY = 1,
  OMW_GROUND_READY = 0,
}

USERFLAG = {}
function USERFLAG:New(name)
  return {
    Get = function() return flags[name] or 0 end,
    Set = function(_, value) flags[name] = value end,
  }
end

env = { info = function() end }

local campaignState = { TransactionKind = { CONSUMPTION = "CONSUMPTION" } }
local store = { id = "shared-store" }
local campaignContext = {
  store = store,
  campaignState = campaignState,
  restored = false,
}

local attachedContext = nil
local attachCount = 0
local groundBase = {}
function groundBase.Attach(spec)
  attachCount = attachCount + 1
  if spec.store ~= store then error("unexpected store") end
  if spec.campaignState ~= campaignState then error("unexpected CampaignState module") end
  if spec.restored ~= false then error("unexpected restored flag") end
  attachedContext = {
    store = spec.store,
    campaignState = spec.campaignState,
    restored = spec.restored,
  }
  flags.OMW_GROUND_READY = 1
  return attachedContext
end
function groundBase.GetContext()
  return attachedContext
end

OMW = {
  AirOps = {
    CampaignContext = campaignContext,
  },
  Ground = {
    Base = groundBase,
  },
}

local GroundStartup = dofile("scripts/ground/OMW_GroundStartup.lua")
local first = GroundStartup.Start()
assert(first.store == store, "Ground startup must reuse authoritative store")
assert(first.campaignState == campaignState, "Ground startup must reuse authoritative CampaignState module")
assert(flags.OMW_GROUND_READY == 1, "Ground startup must require GroundBase Attach to raise ready flag")
assert(attachCount == 1, "Ground startup must attach once")
assert(OMW.Ground.CampaignContext == campaignContext, "Ground startup must expose the shared campaign context")
assert(OMW.Ground.RuntimeContext == first, "Ground startup must expose Ground runtime context")

local second = GroundStartup.Start()
assert(second == first, "Ground startup must be idempotent for the same context")
assert(attachCount == 1, "idempotent Ground startup must not attach twice")

print("PASS test_ground_startup")
