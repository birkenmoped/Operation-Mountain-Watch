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
Adapter.SchemaVersion = "OMW-FOB-ATTACK-FUNCTIONAL-ARTY-DISPATCH-ADAPTER-2"

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
  requireFunction(arty, "AssignAttackGroup", "arty")
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
    onFireStarted = spec.onFireStarted,
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
    local demandId = target and adapter.demandIdByTargetName[target.name] or nil
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
      adapter:_log("fire-support rejected demandId=" .. tostring(demandId) .. " target=" .. tostring(target and target.name) .. " reason=" .. tostring(failureReason or "PHYSICAL_FIRE_NOT_CONFIRMED"))
      if type(adapter.onFireRejected) == "function" then adapter.onFireRejected(demandId, target, Controllable, failureReason or "PHYSICAL_FIRE_NOT_CONFIRMED") end
      return
    end
    if demand and demand.status == adapter.missionDemand.Status.ACTIVE then
      adapter.registry:Succeed(demandId, {
        executor = adapter.assigneeId,
        functionalArtyTarget = target.name,
        fireMissionExecuted = true,
        physicalFireConfirmed = adapter.verifyFireComplete ~= nil,
      })
    end
    adapter:_log("fire-support complete demandId=" .. tostring(demandId) .. " target=" .. tostring(target and target.name))
    if type(adapter.onFireComplete) == "function" then adapter.onFireComplete(demandId, target, Controllable) end
  end

  local previousDead = self.arty.OnAfterDead
  self.arty.OnAfterDead = function(selfArty, Controllable, From, Event, To, Unitname)
    if previousDead then previousDead(selfArty, Controllable, From, Event, To, Unitname) end
    for demandId, targetName in pairs(adapter.targetsByDemandId) do
      local demand = adapter.registry:Get(demandId)
      if demand and (demand.status == adapter.missionDemand.Status.AI_ASSIGNED or demand.status == adapter.missionDemand.Status.ACTIVE) then
        adapter.registry:Fail(demandId, "MOOSE_ARTY_DEAD")
        adapter:_log("fire-support failed demandId=" .. tostring(demandId) .. " reason=MOOSE_ARTY_DEAD target=" .. tostring(targetName))
      end
    end
  end
end

function Instance:Dispatch(demand, targetGroup)
  requireTable(demand, "demand")
  requireNonEmptyString(demand.id, "demand.id")
  requireTable(targetGroup, "targetGroup")

  if demand.missionType ~= self.missionDemand.Type.FIRE_SUPPORT_IMMEDIATE then
    return nil, false, "UNSUPPORTED_MISSION_TYPE"
  end
  if demand.aiCapable ~= true then return nil, false, "DEMAND_NOT_AI_CAPABLE" end

  local existing = self.targetsByDemandId[demand.id]
  if existing then return existing, false, "ALREADY_DISPATCHED" end
  if demand.status ~= self.missionDemand.Status.OPEN then return nil, false, "DEMAND_NOT_OPEN" end

  if type(targetGroup.IsAlive) == "function" and targetGroup:IsAlive() ~= true then
    return nil, false, "TARGET_NOT_ALIVE"
  end

  local targetName = self.arty:AssignAttackGroup(
    targetGroup,
    self.priority,
    self.radiusM,
    self.shells,
    self.maxEngagements,
    nil,
    self.weaponType,
    nil,
    true
  )
  if not targetName then return nil, false, "MOOSE_ARTY_TARGET_REJECTED" end

  self.registry:AssignAI(demand.id, self.assigneeId)
  self.targetsByDemandId[demand.id] = targetName
  self.demandIdByTargetName[targetName] = demand.id
  self:_log(string.format(
    "ARTY target queued demandId=%s requester=%s assigneeId=%s target=%s shells=%s radiusM=%s",
    tostring(demand.id), tostring(demand.origin), tostring(self.assigneeId), tostring(targetName),
    tostring(self.shells), tostring(self.radiusM)))
  return targetName, true, nil
end

function Instance:GetTargetName(demandId)
  requireNonEmptyString(demandId, "demandId")
  return self.targetsByDemandId[demandId]
end

return Adapter