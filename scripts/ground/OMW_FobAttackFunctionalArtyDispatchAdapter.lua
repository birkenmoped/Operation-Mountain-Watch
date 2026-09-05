-- Operation Mountain Watch - immediate fire-support MissionDemand -> MOOSE Functional ARTY adapter.
--
-- MissionDemand remains assignment/status authority. A caller-owned MOOSE ARTY
-- instance remains the sole physical fire-control owner so the same ARTY FSM can
-- later execute the accepted local rearm lifecycle without a second MOOSE owner.
-- This adapter owns no CampaignState stock and creates no parallel target scan.

local Adapter = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobAttackFunctionalArtyDispatchAdapter]"
Adapter.SchemaVersion = "OMW-FOB-ATTACK-FUNCTIONAL-ARTY-DISPATCH-ADAPTER-4"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function isFinite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function Adapter.New(spec)
  requireTable(spec, "spec")
  local missionDemand = requireTable(spec.missionDemand, "missionDemand")
  local registry = requireTable(spec.registry, "registry")
  local arty = requireTable(spec.arty, "arty")

  if type(missionDemand.Type) ~= "table" or missionDemand.Type.FIRE_SUPPORT_IMMEDIATE == nil then
    fail("missionDemand.Type.FIRE_SUPPORT_IMMEDIATE is required")
  end
  if type(missionDemand.Status) ~= "table" then fail("missionDemand.Status is required") end
  for _, name in ipairs({ "Get", "AssignAI", "Activate", "Succeed", "Fail" }) do
    requireFunction(registry, name, "registry")
  end
  requireFunction(arty, "AssignTargetCoord", "arty")
  requireNonEmptyString(spec.assigneeId, "assigneeId")

  if spec.priority ~= nil and (not isFinite(spec.priority) or spec.priority < 1 or spec.priority > 100) then
    fail("priority must be finite in range 1..100 when provided")
  end
  if spec.radiusM ~= nil and (not isFinite(spec.radiusM) or spec.radiusM <= 0) then
    fail("radiusM must be positive finite when provided")
  end
  if spec.shells ~= nil and (not isFinite(spec.shells) or spec.shells <= 0) then
    fail("shells must be positive finite when provided")
  end
  if spec.maxEngagements ~= nil and (not isFinite(spec.maxEngagements) or spec.maxEngagements < 1) then
    fail("maxEngagements must be at least one when provided")
  end
  if spec.verifyFireComplete ~= nil and type(spec.verifyFireComplete) ~= "function" then
    fail("verifyFireComplete must be a function when provided")
  end

  local instance = setmetatable({
    missionDemand = missionDemand,
    registry = registry,
    arty = arty,
    assigneeId = spec.assigneeId,
    priority = spec.priority or 10,
    radiusM = spec.radiusM or 50,
    shells = spec.shells or 4,
    maxEngagements = spec.maxEngagements or 1,
    weaponType = spec.weaponType,
    targetsByDemandId = {},
    demandIdByTargetName = {},
    completedTargetsByDemandId = {},
    targetSequenceByDemandId = {},
    targetMetadataByName = {},
    onFireStarted = spec.onFireStarted,
    onTargetComplete = spec.onTargetComplete,
    onFireComplete = spec.onFireComplete,
    onFireRejected = spec.onFireRejected,
    verifyFireComplete = spec.verifyFireComplete,
  }, Instance)

  instance:_installCallbacks()
  return instance
end

function Instance:_log(message)
  if type(self.arty.I) == "function" then self.arty:I(TAG .. " " .. tostring(message)) end
end

function Instance:_allTargetsComplete(demandId)
  local targets = self.targetsByDemandId[demandId] or {}
  local completed = self.completedTargetsByDemandId[demandId] or {}
  if #targets == 0 then return false end
  for _, targetName in ipairs(targets) do
    if completed[targetName] ~= true then return false end
  end
  return true
end

function Instance:_prepareTargetGroup(targetGroup, label)
  requireTable(targetGroup, label)
  requireFunction(targetGroup, "GetCoordinate", label)
  requireFunction(targetGroup, "GetName", label)
  if type(targetGroup.IsAlive) == "function" and targetGroup:IsAlive() ~= true then
    return nil, "TARGET_NOT_ALIVE"
  end
  local coordinate = targetGroup:GetCoordinate()
  if type(coordinate) ~= "table" then return nil, "TARGET_COORDINATE_UNAVAILABLE" end
  local groupName = targetGroup:GetName()
  if type(groupName) ~= "string" or groupName == "" then return nil, "TARGET_NAME_UNAVAILABLE" end
  return { coordinate=coordinate, groupName=groupName, group=targetGroup }, nil
end

function Instance:_assignPreparedTarget(demandId, prepared)
  local sequence = (self.targetSequenceByDemandId[demandId] or 0) + 1
  self.targetSequenceByDemandId[demandId] = sequence
  local targetAlias = string.format("%s|FS|%03d", prepared.groupName, sequence)

  local targetName = self.arty:AssignTargetCoord(
    prepared.coordinate,
    self.priority,
    self.radiusM,
    self.shells,
    self.maxEngagements,
    nil,
    self.weaponType,
    targetAlias,
    true
  )
  if not targetName then return nil, false, "MOOSE_ARTY_TARGET_REJECTED" end

  self.targetsByDemandId[demandId][#self.targetsByDemandId[demandId] + 1] = targetName
  self.demandIdByTargetName[targetName] = demandId
  self.targetMetadataByName[targetName] = {
    sourceGroupName = prepared.groupName,
    sourceGroup = prepared.group,
    coordinate = prepared.coordinate,
    sequence = sequence,
  }
  self:_log(string.format(
    "ARTY coordinate target queued demandId=%s target=%s sourceGroup=%s sequence=%d shells=%s radiusM=%s",
    tostring(demandId), tostring(targetName), tostring(prepared.groupName), sequence,
    tostring(self.shells), tostring(self.radiusM)))
  return targetName, true, nil
end

function Instance:_installCallbacks()
  if self.arty.__omwFobAttackFunctionalArtyDispatchAdapter then
    fail("ARTY instance already has OMW functional fire-support dispatch ownership")
  end
  self.arty.__omwFobAttackFunctionalArtyDispatchAdapter = self

  local adapter = self
  local previousOpenFire = self.arty.OnAfterOpenFire
  self.arty.OnAfterOpenFire = function(selfArty, Controllable, From, Event, To, target)
    if previousOpenFire then previousOpenFire(selfArty, Controllable, From, Event, To, target) end
    local demandId = target and adapter.demandIdByTargetName[target.name] or nil
    if not demandId then return end
    local demand = adapter.registry:Get(demandId)
    if demand and demand.status == adapter.missionDemand.Status.AI_ASSIGNED then
      adapter.registry:Activate(demandId)
    end
    adapter:_log("fire-support started demandId=" .. tostring(demandId) .. " target=" .. tostring(target and target.name))
    if type(adapter.onFireStarted) == "function" then adapter.onFireStarted(demandId, target, Controllable) end
  end

  local previousCeaseFire = self.arty.OnAfterCeaseFire
  self.arty.OnAfterCeaseFire = function(selfArty, Controllable, From, Event, To, target)
    if previousCeaseFire then previousCeaseFire(selfArty, Controllable, From, Event, To, target) end
    local targetName = target and target.name or nil
    local demandId = targetName and adapter.demandIdByTargetName[targetName] or nil
    if not demandId then return end
    local demand = adapter.registry:Get(demandId)
    local verified, failureReason = true, nil
    if type(adapter.verifyFireComplete) == "function" then
      verified, failureReason = adapter.verifyFireComplete(demandId, target, Controllable)
      verified = verified == true
    end
    if not verified then
      if demand and (demand.status == adapter.missionDemand.Status.AI_ASSIGNED or demand.status == adapter.missionDemand.Status.ACTIVE) then
        adapter.registry:Fail(demandId, failureReason or "PHYSICAL_FIRE_NOT_CONFIRMED")
      end
      adapter:_log("fire-support rejected demandId=" .. tostring(demandId) .. " target=" .. tostring(targetName) .. " reason=" .. tostring(failureReason or "PHYSICAL_FIRE_NOT_CONFIRMED"))
      if type(adapter.onFireRejected) == "function" then adapter.onFireRejected(demandId, target, Controllable, failureReason or "PHYSICAL_FIRE_NOT_CONFIRMED") end
      return
    end

    local completed = adapter.completedTargetsByDemandId[demandId]
    if completed and completed[targetName] ~= true then
      completed[targetName] = true
      if type(adapter.onTargetComplete) == "function" then adapter.onTargetComplete(demandId, target, Controllable) end
    end

    if not adapter:_allTargetsComplete(demandId) then
      adapter:_log("fire-support target complete demandId=" .. tostring(demandId) .. " target=" .. tostring(targetName) .. " awaitingRemainingTargets=true")
      return
    end

    demand = adapter.registry:Get(demandId)
    if demand and demand.status == adapter.missionDemand.Status.ACTIVE then
      adapter.registry:Succeed(demandId, {
        executor = adapter.assigneeId,
        functionalArtyTargets = adapter.targetsByDemandId[demandId],
        fireMissionExecuted = true,
        physicalFireConfirmed = adapter.verifyFireComplete ~= nil,
      })
    end
    adapter:_log("fire-support complete demandId=" .. tostring(demandId) .. " targets=" .. tostring(#(adapter.targetsByDemandId[demandId] or {})))
    if type(adapter.onFireComplete) == "function" then adapter.onFireComplete(demandId, target, Controllable) end
  end

  local previousDead = self.arty.OnAfterDead
  self.arty.OnAfterDead = function(selfArty, Controllable, From, Event, To, Unitname)
    if previousDead then previousDead(selfArty, Controllable, From, Event, To, Unitname) end
    for demandId, targetNames in pairs(adapter.targetsByDemandId) do
      local demand = adapter.registry:Get(demandId)
      if demand and (demand.status == adapter.missionDemand.Status.AI_ASSIGNED or demand.status == adapter.missionDemand.Status.ACTIVE) then
        adapter.registry:Fail(demandId, "MOOSE_ARTY_DEAD")
        adapter:_log("fire-support failed demandId=" .. tostring(demandId) .. " reason=MOOSE_ARTY_DEAD targets=" .. tostring(#targetNames))
      end
    end
  end
end

function Instance:DispatchTargets(demand, targetGroups)
  requireTable(demand, "demand")
  requireNonEmptyString(demand.id, "demand.id")
  requireTable(targetGroups, "targetGroups")
  if #targetGroups < 1 then return nil, false, "NO_TARGETS" end

  if demand.missionType ~= self.missionDemand.Type.FIRE_SUPPORT_IMMEDIATE then
    return nil, false, "UNSUPPORTED_MISSION_TYPE"
  end
  if demand.aiCapable ~= true then return nil, false, "DEMAND_NOT_AI_CAPABLE" end

  local existing = self.targetsByDemandId[demand.id]
  if existing then return existing, false, "ALREADY_DISPATCHED" end
  if demand.status ~= self.missionDemand.Status.OPEN then return nil, false, "DEMAND_NOT_OPEN" end

  local prepared = {}
  for index, targetGroup in ipairs(targetGroups) do
    local item, reason = self:_prepareTargetGroup(targetGroup, "targetGroups[" .. tostring(index) .. "]")
    if not item then return nil, false, reason end
    prepared[#prepared + 1] = item
  end

  self.targetsByDemandId[demand.id] = {}
  self.completedTargetsByDemandId[demand.id] = {}
  self.targetSequenceByDemandId[demand.id] = 0

  local targetNames = self.targetsByDemandId[demand.id]
  for _, item in ipairs(prepared) do
    local _, queued, reason = self:_assignPreparedTarget(demand.id, item)
    if not queued then return nil, false, reason end
  end

  self.registry:AssignAI(demand.id, self.assigneeId)
  self:_log(string.format(
    "ARTY coordinate dispatch demandId=%s requester=%s assigneeId=%s targets=%s shellsPerTarget=%s radiusM=%s",
    tostring(demand.id), tostring(demand.origin), tostring(self.assigneeId), tostring(#targetNames),
    tostring(self.shells), tostring(self.radiusM)))
  return targetNames, true, nil
end

function Instance:QueueTarget(demandId, targetGroup)
  requireNonEmptyString(demandId, "demandId")
  local demand = self.registry:Get(demandId)
  if not demand then return nil, false, "DEMAND_NOT_FOUND" end
  if demand.status ~= self.missionDemand.Status.AI_ASSIGNED and demand.status ~= self.missionDemand.Status.ACTIVE then
    return nil, false, "DEMAND_NOT_ACTIVE"
  end
  if not self.targetsByDemandId[demandId] then return nil, false, "DEMAND_NOT_DISPATCHED" end

  local prepared, reason = self:_prepareTargetGroup(targetGroup, "targetGroup")
  if not prepared then return nil, false, reason end
  return self:_assignPreparedTarget(demandId, prepared)
end

function Instance:Dispatch(demand, targetGroup)
  local targetNames, dispatched, reason = self:DispatchTargets(demand, { targetGroup })
  if type(targetNames) == "table" then return targetNames[1], dispatched, reason end
  return targetNames, dispatched, reason
end

function Instance:GetTargetName(demandId)
  requireNonEmptyString(demandId, "demandId")
  local targets = self.targetsByDemandId[demandId]
  return targets and targets[1] or nil
end

function Instance:GetTargetNames(demandId)
  requireNonEmptyString(demandId, "demandId")
  return self.targetsByDemandId[demandId]
end

function Instance:GetTargetMetadata(targetName)
  requireNonEmptyString(targetName, "targetName")
  return self.targetMetadataByName[targetName]
end

return Adapter
