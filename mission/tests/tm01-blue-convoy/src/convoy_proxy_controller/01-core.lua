local ConvoyProxyController = {}

local REPRESENTATION_NOT_STARTED = "NOT_STARTED"
local REPRESENTATION_EXPANDED = "EXPANDED"
local REPRESENTATION_COLLAPSED = "COLLAPSED_PROXY"
local REPRESENTATION_DESTROYED = "DESTROYED"
local REPRESENTATION_ARRIVED = "ARRIVED"

local TRANSITION_IDLE = "IDLE"
local TRANSITION_PACKING = "PACKING"
local TRANSITION_UNPACKING = "UNPACKING"

local MOVEMENT_NOT_STARTED = "NOT_STARTED"
local MOVEMENT_EN_ROUTE = "EN_ROUTE"
local MOVEMENT_ARRIVED = "ARRIVED"
local MOVEMENT_DESTROYED = "DESTROYED"
local MOVEMENT_FAILED = "FAILED"

local MOOSE_FORMATIONS = {
  ON_ROAD = "On Road",
}

local function copyArray(values)
  local result = {}
  for index, value in ipairs(values or {}) do
    result[index] = value
  end
  return result
end

local function copyVec2(vec2)
  return { x = vec2.x, y = vec2.y }
end

local function deepCopy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for key, item in pairs(value) do
    result[deepCopy(key)] = deepCopy(item)
  end
  return result
end

local function arraysEqual(left, right)
  if #(left or {}) ~= #(right or {}) then
    return false
  end
  for index, value in ipairs(left or {}) do
    if right[index] ~= value then
      return false
    end
  end
  return true
end

local function reverseArray(values)
  local result = {}
  for index = #values, 1, -1 do
    result[#result + 1] = values[index]
  end
  return result
end

local function joinNumbers(values)
  local result = {}
  for index, value in ipairs(values or {}) do
    result[index] = tostring(value)
  end
  return #result > 0 and table.concat(result, ",") or "none"
end

local function clamp(value, minimum, maximum)
  if value < minimum then
    return minimum
  end
  if value > maximum then
    return maximum
  end
  return value
end

local function distanceSquared(left, right)
  local dx = right.x - left.x
  local dy = right.y - left.y
  return dx * dx + dy * dy
end

local function distance2d(left, right)
  return math.sqrt(distanceSquared(left, right))
end

local function interpolateVec2(left, right, fraction)
  return {
    x = left.x + (right.x - left.x) * fraction,
    y = left.y + (right.y - left.y) * fraction,
  }
end

local function atan2(y, x)
  if type(math.atan2) == "function" then
    return math.atan2(y, x)
  end
  if x > 0 then
    return math.atan(y / x)
  end
  if x < 0 and y >= 0 then
    return math.atan(y / x) + math.pi
  end
  if x < 0 and y < 0 then
    return math.atan(y / x) - math.pi
  end
  if x == 0 and y > 0 then
    return math.pi / 2
  end
  if x == 0 and y < 0 then
    return -math.pi / 2
  end
  return 0
end

local function headingDegrees(fromVec2, toVec2)
  local degrees = math.deg(atan2(toVec2.x - fromVec2.x, toVec2.y - fromVec2.y))
  while degrees < 0 do
    degrees = degrees + 360
  end
  while degrees >= 360 do
    degrees = degrees - 360
  end
  return degrees
end

local function parseRuntimeIndex(unitName)
  if type(unitName) ~= "string" then
    return nil
  end
  local suffix = string.match(unitName, "%-(%d+)$")
  return suffix and tonumber(suffix) or nil
end

function ConvoyProxyController.new(options)
  local config = options.config
  local logger = options.logger
  local campaignState = options.campaignState
  local entity = campaignState:getEntity(config.scenarioId)
  if type(entity) ~= "table" then
    error("CampaignState entity is unavailable")
  end

  local controller = {
    entity = entity,
    campaignState = campaignState,
    routePlan = nil,
    runtimeGroup = nil,
    spawner = nil,
    marker = nil,
    markerLastUpdate = nil,
    schedulerId = nil,
    halted = false,
    lastError = nil,
    pendingUnpack = nil,
    arrivalRequested = false,
  }

  local schedulerTick
  local pollUnpackDestroy

  local function announce(text)
    options.announce(text)
  end

  local function updateEntity(changes)
    controller.entity = campaignState:updateEntity(config.scenarioId, changes)
    return controller.entity
  end

  local function commonFields()
    return {
      entityId = controller.entity.entityId,
      routeId = controller.entity.routeId,
      representationState = controller.entity.representationState,
      transitionState = controller.entity.transitionState,
      movementState = controller.entity.movementState,
      runtimeGroupName = controller.entity.runtimeGroupName or "none",
      runtimeGeneration = controller.entity.runtimeGeneration,
      survivingVehicleSlotsRearToFront = joinNumbers(
        controller.entity.survivingVehicleSlotsRearToFront
      ),
      currentLeadSlot = controller.entity.currentLeadSlot or "none",
      currentLeadUnitType = controller.entity.currentLeadUnitType or "unknown",
      routeProgressMeters = controller.entity.routeProgressMeters or 0,
      revision = controller.entity.revision,
    }
  end

  local function logInfo(event, extra)
    local fields = commonFields()
    for key, value in pairs(extra or {}) do
      fields[key] = value
    end
    fields.missionTimeSeconds = timer.getTime()
    logger:info(event, fields)
  end

  local function logError(event, reason, extra)
    local fields = commonFields()
    for key, value in pairs(extra or {}) do
      fields[key] = value
    end
    fields.reason = tostring(reason)
    fields.missionTimeSeconds = timer.getTime()
    logger:error(event, fields)
  end

  local function reject(action, reason)
    logInfo("convoy_proxy_command_rejected", {
      action = action,
      reason = reason,
    })
    announce(action .. " rejected: " .. reason)
    return false
  end

  local function halt(event, reason)
    controller.halted = true
    controller.lastError = tostring(reason)
    updateEntity({
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_FAILED,
    })
    logError(event, reason)
    announce("TM01C halted: " .. tostring(reason))
    return false
  end

  local function ensureReady(action)
    if options.getBootstrapOutcome() ~= "READY" then
      return reject(action, "bootstrap outcome is not READY")
    end
    if controller.halted then
      return reject(action, "controller is halted: " .. tostring(controller.lastError))
    end
    return true
  end

  local function groupIsAlive(group)
    local ok, alive = pcall(function()
      return group and group:IsAlive() == true
    end)
    return ok and alive == true
  end

  local function nativeGroupExists(runtimeName)
    local ok, result = pcall(function()
      local group = Group.getByName(runtimeName)
      return group ~= nil and group:isExist() == true
    end)
    return ok, result
  end

