-- Operation Mountain Watch - Fire Support / Strategic Resupply local LEGION bridge.
--
-- MOOSE-first boundary for installation-local Ground support. The bridge resolves
-- the site-local LEGION/BRIGADE, creates one public MOOSE mission and submits it
-- via LEGION:AddMission(). MOOSE remains responsible for cohort/asset selection,
-- warehouse recruitment, queueing and physical execution.

local Bridge = {}
local Instance = {}
Instance.__index = Instance

Bridge.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-LEGION-BRIDGE-1"

local TAG = "[OMW][FireSupStratResupply.LegionBridge]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function needTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function needFunction(value, label)
  if type(value) ~= "function" then fail(label .. " must be a function") end
  return value
end

function Bridge.New(spec)
  needTable(spec, "spec")
  local resolveLegion = needFunction(spec.resolveLegion, "resolveLegion")
  local factory = needFunction(spec.factory, "factory")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  return setmetatable({
    resolveLegion = resolveLegion,
    factory = factory,
    logger = spec.logger,
    items = {},
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Dispatch(demand, context)
  needTable(demand, "demand")
  if type(demand.demandId) ~= "string" or demand.demandId == "" then fail("demandId is required") end
  if type(demand.siteId) ~= "string" or demand.siteId == "" then fail("siteId is required") end
  if self.items[demand.demandId] then return self.items[demand.demandId], false, "ALREADY_DISPATCHED" end

  local legion, reason = self.resolveLegion(demand.siteId, demand, context)
  if legion == nil then
    self:_log(string.format("local legion unavailable demandId=%s siteId=%s supportType=%s reason=%s",
      tostring(demand.demandId), tostring(demand.siteId), tostring(demand.supportType), tostring(reason)))
    return nil, false, reason or "LOCAL_LEGION_UNAVAILABLE"
  end
  needTable(legion, "resolved legion")
  if type(legion.AddMission) ~= "function" then fail("resolved legion.AddMission() is required") end

  local mission = self.factory(demand, context, legion)
  needTable(mission, "factory mission")
  if type(mission.Cancel) ~= "function" then fail("factory mission must expose Cancel()") end

  -- Public MOOSE LEGION path. Do not select cohorts/assets here.
  legion:AddMission(mission)

  local handle = {
    mission = mission,
    legion = legion,
    cancelRequested = false,
  }
  function handle:Cancel()
    if self.cancelRequested then return false end
    self.cancelRequested = true
    self.mission:Cancel()
    return true
  end

  self.items[demand.demandId] = handle
  self:_log(string.format("queued local mission demandId=%s siteId=%s supportType=%s legion=%s",
    tostring(demand.demandId), tostring(demand.siteId), tostring(demand.supportType),
    tostring(legion.alias or legion.ClassName or legion)))
  return handle, true, nil
end

return Bridge
