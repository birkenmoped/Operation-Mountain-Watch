local InMemoryCampaignState = {}

local REPRESENTATION_VIRTUAL = "VIRTUAL"
local TRANSITION_IDLE = "IDLE"
local MOVEMENT_NOT_STARTED = "NOT_STARTED"

local function copyArray(values)
  local result = {}
  for index, value in ipairs(values or {}) do
    result[index] = value
  end
  return result
end

function InMemoryCampaignState.new(config)
  local initialSlots = {}
  for slot = 1, config.template.expectedVehicleCount do
    initialSlots[#initialSlots + 1] = slot
  end

  local firstSection = config.zones.revealSections[config.virtualization.initialSectionIndex]
  if type(firstSection) ~= "table" then
    error("initial reveal section is unavailable")
  end

  local entity = {
    entityId = config.scenarioId,
    representationState = REPRESENTATION_VIRTUAL,
    transitionState = TRANSITION_IDLE,
    movementState = MOVEMENT_NOT_STARTED,
    routeId = config.routeId,
    currentSectionIndex = config.virtualization.initialSectionIndex,
    segmentIndex = firstSection.entrySegmentIndex,
    segmentProgress = 0,
    routeDistanceMeters = 0,
    configuredSpeedKph = config.virtualization.configuredSpeedKph,
    effectiveSpeedKph = config.virtualization.effectiveSpeedKph,
    lastMovementUpdateCampaignTime = timer.getTime(),
    lastStateChangeCampaignTime = timer.getTime(),
    survivingVehicleSlots = initialSlots,
    physicalGeneration = 0,
    runtimeGroupName = nil,
    revision = 0,
  }

  local campaignState = {
    entities = {
      [config.scenarioId] = entity,
    },
  }

  function campaignState:getEntity(entityId)
    return self.entities[entityId]
  end

  function campaignState:updateEntity(entityId, changes)
    local current = self.entities[entityId]
    if not current then
      error("unknown strategic entity: " .. tostring(entityId))
    end
    if type(changes) ~= "table" then
      error("entity changes must be a table")
    end

    for key, value in pairs(changes) do
      if key ~= "clearFields" then
        if key == "survivingVehicleSlots" then
          current[key] = copyArray(value)
        else
          current[key] = value
        end
      end
    end

    for _, key in ipairs(changes.clearFields or {}) do
      current[key] = nil
    end

    current.revision = current.revision + 1
    current.lastStateChangeCampaignTime = timer.getTime()
    return current
  end

  function campaignState:getEntitySnapshot(entityId)
    local current = self.entities[entityId]
    if not current then
      return nil
    end

    local snapshot = {}
    for key, value in pairs(current) do
      if key == "survivingVehicleSlots" then
        snapshot[key] = copyArray(value)
      else
        snapshot[key] = value
      end
    end
    return snapshot
  end

  return campaignState
end

return InMemoryCampaignState
