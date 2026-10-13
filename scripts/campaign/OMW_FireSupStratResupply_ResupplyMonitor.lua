-- Operation Mountain Watch - strategic resource shortage -> generic Base resupply bridge.
--
-- No scheduler and no resource ownership. CampaignState + ResourceDemandPolicy own
-- the strategic resource snapshot/threshold decision. This module only turns one
-- shortage episode into one Base resupply demand. MOOSE remains transport authority.

local Monitor = {}
local Instance = {}
Instance.__index = Instance

Monitor.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-MONITOR-1"
local TAG = "[OMW][FireSupStratResupply.ResupplyMonitor]"

local SUPPORT_TYPES = { GROUND_RESUPPLY=true, AIR_RESUPPLY=true }

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function keyFor(nodeId, resourceId) return tostring(nodeId) .. "\0" .. tostring(resourceId) end

function Monitor.New(spec)
  needTable(spec, "spec")
  local base = needTable(spec.base, "base")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local policy = needTable(spec.policy, "policy")
  local store = needTable(spec.store, "store")
  local rows = needTable(spec.rows, "rows")
  needFunction(base, "RequestResupply", "base")
  needFunction(policy, "Evaluate", "policy")
  needFunction(store, "GetResource", "store")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  if type(spec.selectSupportType) ~= "function" then fail("selectSupportType must be a function") end
  if spec.priorityForCandidate ~= nil and type(spec.priorityForCandidate) ~= "function" then fail("priorityForCandidate must be a function when provided") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  local byNode = {}
  for siteId, site in pairs(siteRegistry.Sites) do
    if type(site) == "table" and type(site.campaignNodeId) == "string" and site.campaignNodeId ~= "" then
      if byNode[site.campaignNodeId] then fail("duplicate campaignNodeId " .. site.campaignNodeId) end
      byNode[site.campaignNodeId] = { siteId=site.siteId or siteId, site=site }
    end
  end

  return setmetatable({
    base=base,
    siteRegistry=siteRegistry,
    policy=policy,
    store=store,
    rows=rows,
    selectSupportType=spec.selectSupportType,
    priorityForCandidate=spec.priorityForCandidate,
    logger=spec.logger,
    byNode=byNode,
    active={},
    generations={},
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:EvaluateRow(row)
  needTable(row, "row")
  local snapshot = self.store:GetResource(row.nodeId, row.resourceId)
  local candidate = self.policy.Evaluate(row, snapshot)
  local key = keyFor(row.nodeId, row.resourceId)

  if candidate == nil then
    local cleared = self.active[key]
    self.active[key] = nil
    if cleared then
      self:_log(string.format("shortage cleared nodeId=%s resourceId=%s demandId=%s",
        tostring(row.nodeId), tostring(row.resourceId), tostring(cleared.demandId)))
    end
    return nil, false, "NO_SHORTAGE", nil, snapshot
  end

  local active = self.active[key]
  if active then return active.demand, false, "SHORTAGE_ALREADY_ACTIVE", candidate, snapshot end

  local siteRecord = self.byNode[candidate.destinationNodeId]
  if not siteRecord then return nil, false, "SITE_NOT_REGISTERED_FOR_RESOURCE_NODE", candidate, snapshot end

  local supportType, selectReason = self.selectSupportType(candidate, siteRecord.site, snapshot)
  if supportType == nil then return nil, false, selectReason or "RESUPPLY_SUPPORT_TYPE_NOT_SELECTED", candidate, snapshot end
  if not SUPPORT_TYPES[supportType] then fail("selectSupportType returned invalid supportType=" .. tostring(supportType)) end

  local generation = (self.generations[key] or 0) + 1
  self.generations[key] = generation
  local requestKey = string.format("RESOURCE_THRESHOLD|%s|%d", tostring(candidate.destinationResourceId), generation)
  local priority = self.priorityForCandidate and self.priorityForCandidate(candidate, siteRecord.site, snapshot) or nil
  local demand, created, reason = self.base:RequestResupply(siteRecord.siteId, supportType, {
    requestKey = requestKey,
    resourceId = candidate.destinationResourceId,
    quantity = candidate.requestedQuantity,
    priority = priority,
    context = {
      activation = "RESOURCE_THRESHOLD",
      level = candidate.level,
      supplyParent = candidate.supplyParent,
      campaignSnapshot = snapshot,
      resourceCandidate = candidate,
    },
  })

  if demand ~= nil then
    self.active[key] = {
      demandId = demand.demandId,
      demand = demand,
      siteId = siteRecord.siteId,
      resourceId = candidate.destinationResourceId,
      supportType = supportType,
      generation = generation,
    }
  end
  self:_log(string.format(
    "evaluated nodeId=%s resourceId=%s siteId=%s supportType=%s generation=%s demandId=%s created=%s reason=%s",
    tostring(candidate.destinationNodeId), tostring(candidate.destinationResourceId), tostring(siteRecord.siteId),
    tostring(supportType), tostring(generation), tostring(demand and demand.demandId), tostring(created), tostring(reason)))
  return demand, created, reason, candidate, snapshot
end

function Instance:EvaluateAll()
  local results = {}
  for index, row in ipairs(self.rows) do
    local demand, created, reason, candidate, snapshot = self:EvaluateRow(row)
    results[index] = { demand=demand, created=created, reason=reason, candidate=candidate, snapshot=snapshot }
  end
  return results
end

function Instance:ReleaseDemand(demandId, reason)
  if type(demandId) ~= "string" or demandId == "" then fail("demandId is required") end
  for key, active in pairs(self.active) do
    if active.demandId == demandId then
      self.active[key] = nil
      self:_log(string.format("released demandId=%s siteId=%s resourceId=%s reason=%s",
        demandId, tostring(active.siteId), tostring(active.resourceId), tostring(reason)))
      return active.demand, true, nil
    end
  end
  return nil, false, "DEMAND_NOT_ACTIVE"
end

function Instance:GetActive(nodeId, resourceId)
  return self.active[keyFor(nodeId, resourceId)]
end

return Monitor
