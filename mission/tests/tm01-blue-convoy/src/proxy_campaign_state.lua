local ProxyCampaignState = {}

local function copyArray(values)
  local result = {}
  for index, value in ipairs(values or {}) do
    result[index] = value
  end
  return result
end

local function copyTable(values)
  local result = {}
  for key, value in pairs(values or {}) do
    if type(value) == "table" then
      result[key] = copyTable(value)
    else
      result[key] = value
    end
  end
  return result
end

function ProxyCampaignState.new(config)
  local survivors = copyArray(config.template.slotOrderRearToFront)
  local leadSlot = survivors[#survivors]

  local entity = {
    entityId = config.scenarioId,
    routeId = config.routeId,
    representationState = "NOT_STARTED",
    transitionState = "IDLE",
    movementState = "NOT_STARTED",
    survivingVehicleSlotsRearToFront = survivors,
    currentLeadSlot = leadSlot,
    currentLeadUnitType = nil,
    routeProgressMeters = 0,
    runtimeGeneration = 0,
    runtimeGroupName = nil,
    runtimeIndexToStableSlot = {},
    revision = 0,
    lastStateChangeCampaignTime = timer.getTime(),
  }

  local state = {
    entities = {
      [config.scenarioId] = entity,
    },
  }

  function state:getEntity(entityId)
    return self.entities[entityId]
  end

  function state:updateEntity(entityId, changes)
    local current = self.entities[entityId]
    if not current then
      error("unknown strategic entity: " .. tostring(entityId))
    end
    for key, value in pairs(changes or {}) do
      if key ~= "clearFields" then
        if type(value) == "table" then
          current[key] = copyTable(value)
        else
          current[key] = value
        end
      end
    end
    for _, key in ipairs((changes and changes.clearFields) or {}) do
      current[key] = nil
    end
    current.revision = current.revision + 1
    current.lastStateChangeCampaignTime = timer.getTime()
    return current
  end

  function state:getEntitySnapshot(entityId)
    local current = self.entities[entityId]
    return current and copyTable(current) or nil
  end

  return state
end

return ProxyCampaignState
