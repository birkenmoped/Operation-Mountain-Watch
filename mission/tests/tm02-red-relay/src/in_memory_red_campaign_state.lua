local InMemoryRedCampaignState = {}

local TERMINAL_MOVEMENT_STATES = {
  ARRIVED = true,
  DESTROYED = true,
}

local function copyTable(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "table" then
      result[key] = copyTable(value)
    else
      result[key] = value
    end
  end
  return result
end

local function requireNumber(value, name)
  if type(value) ~= "number" then
    error(name .. " must be a number")
  end
end

function InMemoryRedCampaignState.new(options)
  local config = options.config
  local logger = options.logger
  local state = {
    nodes = {},
    movements = {},
    activeMovementId = nil,
    transferAttempted = false,
    initialPersonnelTotal = 0,
  }

  local function movementFields(movement)
    return {
      destinationNodeId = movement.destinationNodeId,
      fighterCount = movement.fighterCount,
      movementId = movement.movementId,
      movementState = movement.movementState,
      representationState = movement.representationState,
      runtimeGroupName = movement.runtimeGroupName or "none",
      sourceNodeId = movement.sourceNodeId,
      survivorCount = movement.survivorCount,
    }
  end

  local function validateNodeDefinition(node)
    if type(node.nodeId) ~= "string" or node.nodeId == "" then
      error("nodeId is required")
    end
    if state.nodes[node.nodeId] then
      error("duplicate nodeId: " .. node.nodeId)
    end
    requireNumber(node.garrisonAlive, node.nodeId .. ".garrisonAlive")
    requireNumber(node.minimumGarrison, node.nodeId .. ".minimumGarrison")
    if node.garrisonAlive < 0 or node.minimumGarrison < 0 then
      error("node personnel values must not be negative: " .. node.nodeId)
    end
  end

  for _, nodeDefinition in ipairs(config.nodes or {}) do
    validateNodeDefinition(nodeDefinition)
    local node = copyTable(nodeDefinition)
    node.availableSurplus = math.max(0, node.garrisonAlive - node.minimumGarrison)
    state.nodes[node.nodeId] = node
    state.initialPersonnelTotal = state.initialPersonnelTotal + node.garrisonAlive
  end

  local sourceNode = state.nodes[config.transfer.sourceNodeId]
  local destinationNode = state.nodes[config.transfer.destinationNodeId]
  if not sourceNode or not destinationNode then
    error("configured source or destination node is unavailable")
  end
  if sourceNode.successorNodeId ~= destinationNode.nodeId then
    error("destination is not the direct successor of the source node")
  end
  if config.policy.allowNodeSkipping ~= false then
    error("TM02A requires allowNodeSkipping=false")
  end
  if config.policy.allowVirtualRepresentation ~= false then
    error("TM02A requires allowVirtualRepresentation=false")
  end
  if config.movement.maxActiveMovements ~= 1 then
    error("TM02A requires exactly one active movement slot")
  end
  if config.movement.fighterCount ~= config.template.expectedFighterCount then
    error("movement and template fighter counts differ")
  end

  local function refreshSurplus(node)
    node.availableSurplus = math.max(0, node.garrisonAlive - node.minimumGarrison)
  end

  local function getMovement()
    return state.movements[config.movement.movementId]
  end

  local function countDomainPersonnel()
    local total = 0
    for _, node in pairs(state.nodes) do
      total = total + node.garrisonAlive
    end
    local movement = getMovement()
    if movement and not TERMINAL_MOVEMENT_STATES[movement.movementState] then
      total = total + movement.survivorCount
    end
    return total
  end

  function state:validatePersonnelAccounting()
    local currentTotal = countDomainPersonnel()
    local expectedMaximum = self.initialPersonnelTotal
    return currentTotal <= expectedMaximum, currentTotal, expectedMaximum
  end

  function state:reserveTransfer()
    if self.transferAttempted then
      return false, "transfer command has already been consumed"
    end
    if self.activeMovementId then
      return false, "an active movement already exists"
    end

    self.transferAttempted = true
    local source = self.nodes[config.transfer.sourceNodeId]
    local destination = self.nodes[config.transfer.destinationNodeId]
    local fighterCount = config.movement.fighterCount

    refreshSurplus(source)
    if source.successorNodeId ~= destination.nodeId then
      return false, "destination is no longer the direct successor"
    end
    if source.availableSurplus < fighterCount then
      return false, "source node has insufficient surplus"
    end
    if source.garrisonAlive - fighterCount < source.minimumGarrison then
      return false, "reservation would violate the source minimum garrison"
    end

    source.garrisonAlive = source.garrisonAlive - fighterCount
    refreshSurplus(source)

    local movement = {
      movementId = config.movement.movementId,
      sourceNodeId = source.nodeId,
      destinationNodeId = destination.nodeId,
      fighterCount = fighterCount,
      survivorCount = fighterCount,
      movementState = "RESERVED",
      representationState = "STAGED",
      runtimeGroupName = nil,
      routeAssigned = false,
      arrivalCredited = false,
      failureReason = nil,
      ownershipNodeId = nil,
    }
    self.movements[movement.movementId] = movement
    self.activeMovementId = movement.movementId

    local fields = movementFields(movement)
    fields.sourceGarrisonAlive = source.garrisonAlive
    fields.sourceMinimumGarrison = source.minimumGarrison
    fields.sourceAvailableSurplus = source.availableSurplus
    logger:info("red_relay_reserved", fields)
    return true, movement
  end

  function state:markPhysical(runtimeGroupName)
    local movement = getMovement()
    if not movement then
      return false, "movement is unavailable"
    end
    if movement.movementState ~= "RESERVED" or movement.representationState ~= "STAGED" then
      return false, "movement is not staged for physical creation"
    end
    if type(runtimeGroupName) ~= "string" or runtimeGroupName == "" then
      return false, "runtime group name is unavailable"
    end

    movement.runtimeGroupName = runtimeGroupName
    movement.representationState = "PHYSICAL"
    movement.movementState = "PHYSICAL_READY"
    logger:info("red_relay_physical", movementFields(movement))
    return true, movement
  end

  function state:markEnRoute()
    local movement = getMovement()
    if not movement then
      return false, "movement is unavailable"
    end
    if movement.movementState ~= "PHYSICAL_READY"
      or movement.representationState ~= "PHYSICAL" then
      return false, "movement is not ready for routing"
    end

    movement.routeAssigned = true
    movement.movementState = "EN_ROUTE"
    logger:info("red_relay_en_route", movementFields(movement))
    return true, movement
  end

  function state:syncSurvivors(observedSurvivorCount)
    local movement = getMovement()
    if not movement then
      return false, "movement is unavailable"
    end
    requireNumber(observedSurvivorCount, "observedSurvivorCount")
    if observedSurvivorCount < 0 then
      return false, "observed survivor count is negative"
    end
    if observedSurvivorCount > movement.survivorCount then
      return false, "survivor count increased; resurrection is forbidden"
    end

    if observedSurvivorCount < movement.survivorCount then
      local previous = movement.survivorCount
      movement.survivorCount = observedSurvivorCount
      logger:info("red_relay_losses_recorded", {
        movementId = movement.movementId,
        previousSurvivorCount = previous,
        survivorCount = observedSurvivorCount,
        totalLosses = movement.fighterCount - observedSurvivorCount,
      })
    end
    return true, movement
  end

  function state:markDestroyed()
    local movement = getMovement()
    if not movement then
      return false, "movement is unavailable"
    end
    if movement.movementState == "ARRIVED" then
      return false, "arrived movement cannot be destroyed by transit reconciliation"
    end

    movement.survivorCount = 0
    movement.movementState = "DESTROYED"
    movement.representationState = "DESTROYED"
    self.activeMovementId = nil
    logger:info("red_relay_destroyed", movementFields(movement))
    return true, movement
  end

  function state:completeArrival()
    local movement = getMovement()
    if not movement then
      return false, "movement is unavailable"
    end
    if movement.arrivalCredited or movement.movementState == "ARRIVED" then
      return false, "arrival has already been credited"
    end
    if movement.movementState ~= "EN_ROUTE" then
      return false, "movement is not en route"
    end
    if movement.representationState ~= "PHYSICAL" then
      return false, "movement is not physically represented"
    end
    if movement.survivorCount < 1 then
      return false, "destroyed movement cannot be credited"
    end

    local destination = self.nodes[movement.destinationNodeId]
    destination.garrisonAlive = destination.garrisonAlive + movement.survivorCount
    refreshSurplus(destination)

    movement.arrivalCredited = true
    movement.movementState = "ARRIVED"
    movement.ownershipNodeId = destination.nodeId
    self.activeMovementId = nil

    local fields = movementFields(movement)
    fields.destinationGarrisonAlive = destination.garrisonAlive
    fields.destinationMinimumGarrison = destination.minimumGarrison
    fields.destinationAvailableSurplus = destination.availableSurplus
    logger:info("red_relay_arrival_credited", fields)
    return true, movement
  end

  function state:failMovement(reason)
    local movement = getMovement()
    if not movement then
      return false, "movement is unavailable"
    end
    if movement.movementState == "ARRIVED" or movement.movementState == "DESTROYED" then
      return false, "terminal movement cannot be failed"
    end

    movement.movementState = "FAILED"
    movement.failureReason = tostring(reason)
    self.activeMovementId = nil
    logger:error("red_relay_failed", movementFields(movement))
    return true, movement
  end

  function state:getMovementSnapshot()
    local movement = getMovement()
    if not movement then
      return nil
    end
    return copyTable(movement)
  end

  function state:getStatusSnapshot()
    local nodes = {}
    for nodeId, node in pairs(self.nodes) do
      nodes[nodeId] = copyTable(node)
    end
    return {
      activeMovementId = self.activeMovementId,
      initialPersonnelTotal = self.initialPersonnelTotal,
      movement = self:getMovementSnapshot(),
      nodes = nodes,
      transferAttempted = self.transferAttempted,
    }
  end

  return state
end

return InMemoryRedCampaignState
