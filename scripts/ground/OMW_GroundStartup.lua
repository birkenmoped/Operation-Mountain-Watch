-- Operation Mountain Watch - Ground production startup bridge.
--
-- Attaches the already loaded Ground production base to the single authoritative
-- CampaignState context created by the AirOps Warehouse production base.
-- This module creates no strategic store and no physical DCS/MOOSE asset.

local GroundStartup = {}

local TAG = "[OMW][Ground.Startup]"
local WAREHOUSE_READY_FLAG = "OMW_WAREHOUSE_READY"
local GROUND_READY_FLAG = "OMW_GROUND_READY"

GroundStartup.SchemaVersion = "OMW-GROUND-STARTUP-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message), false)
  end
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(container, name, label)
  if type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
end

local function readyFlag(name)
  if type(USERFLAG) ~= "table" or type(USERFLAG.New) ~= "function" then
    fail("MOOSE USERFLAG:New() is unavailable")
  end
  return USERFLAG:New(name)
end

function GroundStartup.Start()
  local warehouseFlag = readyFlag(WAREHOUSE_READY_FLAG)
  local groundFlag = readyFlag(GROUND_READY_FLAG)

  if warehouseFlag:Get() ~= 1 then
    fail("OMW_WAREHOUSE_READY must be 1 before Ground startup")
  end

  local omw = requireTable(OMW, "OMW")
  local airOps = requireTable(omw.AirOps, "OMW.AirOps")
  local campaignContext = requireTable(airOps.CampaignContext, "OMW.AirOps.CampaignContext")
  local store = requireTable(campaignContext.store, "OMW.AirOps.CampaignContext.store")
  local campaignState = requireTable(campaignContext.campaignState, "OMW.AirOps.CampaignContext.campaignState")

  local ground = requireTable(omw.Ground, "OMW.Ground")
  local groundBase = requireTable(ground.Base, "OMW.Ground.Base")
  requireFunction(groundBase, "Attach", "OMW.Ground.Base")
  requireFunction(groundBase, "GetContext", "OMW.Ground.Base")

  local existing = groundBase.GetContext()
  if existing ~= nil then
    if type(existing) ~= "table" or existing.store ~= store or existing.campaignState ~= campaignState then
      fail("Ground Base is already attached to a different CampaignState context")
    end
    if groundFlag:Get() ~= 1 then
      fail("Ground Base context exists but OMW_GROUND_READY is not 1")
    end
    log("START_SKIPPED reason=ALREADY_ATTACHED authority=OMW.AirOps.CampaignContext")
    return existing
  end

  local context = groundBase.Attach({
    store = store,
    campaignState = campaignState,
    restored = campaignContext.restored == true,
  })

  if type(context) ~= "table" or context.store ~= store or context.campaignState ~= campaignState then
    fail("Ground Base attach returned a mismatched CampaignState context")
  end
  if groundBase.GetContext() ~= context then
    fail("Ground Base context readback mismatch")
  end
  if groundFlag:Get() ~= 1 then
    fail("OMW_GROUND_READY did not become 1 after Ground Base attach")
  end

  ground.CampaignContext = campaignContext
  ground.RuntimeContext = context

  log("READY authority=OMW.AirOps.CampaignContext restored=" .. tostring(campaignContext.restored == true)
    .. " warehouseReady=1 groundReady=1")

  return context
end

return GroundStartup
