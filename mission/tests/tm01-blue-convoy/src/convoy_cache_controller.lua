local ConvoyCacheController = {}

local REPRESENTATION_VIRTUAL = "VIRTUAL"
local REPRESENTATION_PHYSICAL = "PHYSICAL"

local TRANSITION_IDLE = "IDLE"
local TRANSITION_MATERIALIZING = "MATERIALIZING"
local TRANSITION_DEMATERIALIZING = "DEMATERIALIZING"

local MOVEMENT_NOT_STARTED = "NOT_STARTED"
local MOVEMENT_PHYSICAL_READY = "PHYSICAL_READY"
local MOVEMENT_PHYSICAL_MOVING = "PHYSICAL_MOVING"
local MOVEMENT_VIRTUAL_MOVING = "VIRTUAL_MOVING"
local MOVEMENT_ARRIVED = "ARRIVED"
local MOVEMENT_MATERIALIZATION_FAILED = "MATERIALIZATION_FAILED"
local MOVEMENT_DEMATERIALIZATION_FAILED = "DEMATERIALIZATION_FAILED"
local MOVEMENT_ROUTE_FAILED = "ROUTE_FAILED"
local MOVEMENT_DESTROYED = "DESTROYED"

local MOOSE_FORMATIONS = {
  ON_ROAD = "On Road",
}

local function displayValue(value)
  if value == nil then
    return "none"
  end
  return tostring(value)
end

local function copyArray(values)
  local copy = {}
  for index, value in ipairs(values or {}) do
    copy[index] = value
  end
  return copy
end

local function joinNumbers(values)
  local text = {}
  for index, value in ipairs(values or {}) do
    text[index] = tostring(value)
  end
  return table.concat(text, ",")
end

local function makeSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[value] = true
  end
  return result
end

local function parseSpawnSlot(unitName)
  if type(unitName) ~= "string" then
    return nil
  end

  local suffix = string.match(unitName, "%-(%d+)$")
  if not suffix then
    return nil
  end

  return tonumber(suffix)
end

function ConvoyCacheController.new(options)
  local config = options.config
  local logger = options.logger
  local campaignState = options.campaignState

  if type(campaignState) ~= "table"
    or type(campaignState.getEntity) ~= "function"
    or type(campaignState.updateEntity) ~= "function"
    or type(campaignState.getEntitySnapshot) ~= "function" then
    error("a valid InMemoryCampaignState is required")
  end

  local entity = campaignState:getEntity(config.scenarioId)
  if type(entity) ~= "table" then
    error("CampaignState entity is unavailable: " .. tostring(config.scenarioId))
  end

  local controller = {
    campaignState = campaignState,
    entity = entity,
    spawner = nil,
    runtimeGroup = nil,
    routeAssignedGeneration = nil,
    retiredRuntimeGroupNames = {},
    arrivalLogged = false,
    lastError = nil,
  }

  local function updateEntity(changes)
    controller.entity = controller.campaignState:updateEntity(
      config.scenarioId,
      changes
    )
    return controller.entity
  end

  local function currentSection()
    return config.zones.revealSections[controller.entity.currentSectionIndex]
  end

  local function commonFields()
    local section = currentSection()
    return {
      entityId = controller.entity.entityId,
      routeId = controller.entity.routeId,
      representationState = controller.entity.representationState,
      transitionState = controller.entity.transitionState,
      movementState = controller.entity.movementState,
      currentSectionIndex = controller.entity.currentSectionIndex,
      currentSectionId = section and section.id or "none",
      segmentIndex = controller.entity.segmentIndex,
      segmentProgress = controller.entity.segmentProgress,
      physicalGeneration = controller.entity.physicalGeneration,
      revision = controller.entity.revision,
      runtimeGroupName = controller.entity.runtimeGroupName or "none",
      survivingVehicleSlots = joinNumbers(controller.entity.survivingVehicleSlots),
    }
  end

  local function announce(text)
    options.announce(text)
  end

  local function reject(action, reason)
    local fields = commonFields()
    fields.action = action
    fields.reason = reason
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_cache_command_rejected", fields)
    announce(action .. " rejected: " .. reason)
    return false
  end

  local function logFailure(event, movementState, reason)
    controller.lastError = tostring(reason)
    updateEntity({
      movementState = movementState,
      transitionState = TRANSITION_IDLE,
    })
    local fields = commonFields()
    fields.reason = controller.lastError
    fields.missionTimeSeconds = timer.getTime()
    logger:error(event, fields)
    announce(event .. ": " .. controller.lastError)
    return false
  end

  local function ensureBootstrapReady(action)
    if options.getBootstrapOutcome() ~= "READY" then
      return reject(action, "bootstrap outcome is not READY")
    end
    return true
  end

  local function inspectGroup(group)
    return pcall(function()
      if type(group) ~= "table" then
        error("runtime group wrapper is unavailable")
      end

      return {
        name = group:GetName(),
        alive = group:IsAlive() == true,
        livingUnitCount = group:CountAliveUnits(),
      }
    end)
  end

  local function groupIsAlive(group)
    local ok, alive = pcall(function()
      return group and group:IsAlive() == true
    end)
    return ok and alive == true
  end

  local function validateRepresentationInvariant()
    if controller.entity.representationState == REPRESENTATION_VIRTUAL then
      if controller.runtimeGroup and groupIsAlive(controller.runtimeGroup) then
        return false, "virtual entity still has a live physical group"
      end
      return true
    end

    if controller.entity.representationState == REPRESENTATION_PHYSICAL then
      if not controller.runtimeGroup then
        return false, "physical entity has no runtime group wrapper"
      end
      if not groupIsAlive(controller.runtimeGroup) then
        return false, "physical entity runtime group is not alive"
      end
      return true
    end

    return false, "unknown representation state"
  end

  local function ensureRetiredGroupsAreNotAlive()
    for _, runtimeName in ipairs(controller.retiredRuntimeGroupNames) do
      local lookupOk, group = pcall(function()
        return GROUP:FindByName(runtimeName)
      end)
      if not lookupOk then
        return false, group
      end
      if group and groupIsAlive(group) then
        return false, "retired runtime group is still alive: " .. runtimeName
      end
    end
    return true
  end

  local function captureSurvivingSlots(group)
    return pcall(function()
      local units = group:GetUnits()
      if type(units) ~= "table" then
        error("runtime group units are unavailable")
      end

      local slots = {}
      local seen = {}
      for _, unit in pairs(units) do
        if unit and unit:IsAlive() == true then
          local unitName = unit:GetName()
          local slot = parseSpawnSlot(unitName)
          if not slot then
            error("cannot parse vehicle slot from unit name: " .. displayValue(unitName))
          end
          if slot < 1 or slot > config.template.expectedVehicleCount then
            error("parsed vehicle slot is outside configured range: " .. tostring(slot))
          end
          if seen[slot] then
            error("duplicate vehicle slot detected: " .. tostring(slot))
          end
          seen[slot] = true
          slots[#slots + 1] = slot
        end
      end

      table.sort(slots)
      if #slots < 1 then
        error("no surviving vehicle slots remain")
      end

      local livingUnitCount = group:CountAliveUnits()
      if livingUnitCount ~= #slots then
        error(
          "living unit count does not match parsed slots: count="
            .. tostring(livingUnitCount) .. " slots=" .. tostring(#slots)
        )
      end

      return slots
    end)
  end

  local function pruneSpawnedGroupToSlots(group, survivingSlots)
    return pcall(function()
      local allowed = makeSet(survivingSlots)
      local observed = {}
      local units = group:GetUnits()
      if type(units) ~= "table" then
        error("spawned group units are unavailable")
      end

      for _, unit in pairs(units) do
        if unit and unit:IsAlive() == true then
          local unitName = unit:GetName()
          local slot = parseSpawnSlot(unitName)
          if not slot then
            error("cannot parse spawned vehicle slot from unit name: " .. displayValue(unitName))
          end

          if allowed[slot] then
            observed[slot] = true
          else
            unit:Destroy(false)
          end
        end
      end

      for _, slot in ipairs(survivingSlots) do
        if not observed[slot] then
          error("required surviving slot was not spawned: " .. tostring(slot))
        end
      end

      local livingUnitCount = group:CountAliveUnits()
      if livingUnitCount ~= #survivingSlots then
        error(
          "spawned group count does not match surviving slots: count="
            .. tostring(livingUnitCount) .. " slots=" .. tostring(#survivingSlots)
        )
      end

      return livingUnitCount
    end)
  end

  local function buildSectionRoute(section)
    return pcall(function()
      local formation = MOOSE_FORMATIONS[config.routing.formation]
      if config.routing.roadOnly ~= true or not formation then
        error("road-only ON_ROAD routing configuration is required")
      end

      local waypoints = {}
      for index, zoneName in ipairs(section.physicalRouteZones) do
        local zone = ZONE:FindByName(zoneName)
        if not zone then
          error("physical route zone is unavailable: " .. zoneName)
        end
        local coordinate = zone:GetCoordinate()
        if not coordinate then
          error("physical route coordinate is unavailable: " .. zoneName)
        end
        local waypoint = coordinate:WaypointGround(config.routing.speedKph, formation)
        if type(waypoint) ~= "table" then
          error("ground waypoint construction failed: " .. zoneName)
        end
        waypoints[index] = waypoint
      end

      if #waypoints < 1 then
        error("physical route contains no waypoints")
      end

      return waypoints
    end)
  end

  local function destroyGroupSilently(group)
    return pcall(function()
      group:Destroy(false)
    end)
  end

  function controller:materialize()
    local action = "Materialize convoy"
    local requestedFields = commonFields()
    requestedFields.action = action
    requestedFields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_materialization_requested", requestedFields)

    if not ensureBootstrapReady(action) then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return reject(action, "another representation transition is active")
    end
    if self.entity.representationState ~= REPRESENTATION_VIRTUAL then
      return reject(action, "entity is not virtual")
    end
    if self.runtimeGroup and groupIsAlive(self.runtimeGroup) then
      return reject(action, "a live runtime group already exists")
    end
    if self.entity.movementState == MOVEMENT_ARRIVED then
      return reject(action, "entity has already arrived")
    end

    local retiredOk, retiredError = ensureRetiredGroupsAreNotAlive()
    if not retiredOk then
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        retiredError
      )
    end

    local section = currentSection()
    if not section then
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        "current reveal section is unavailable"
      )
    end

    local lookupOk, entryZone = pcall(function()
      return ZONE:FindByName(section.entry)
    end)
    if not lookupOk or not entryZone then
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        lookupOk and "entry zone is unavailable: " .. section.entry or entryZone
      )
    end

    updateEntity({ transitionState = TRANSITION_MATERIALIZING })
    local nextGeneration = self.entity.physicalGeneration + 1
    local alias = config.template.runtimeAliasPrefix
      .. "_G" .. string.format("%02d", nextGeneration)

    local constructionOk, spawnerOrError = pcall(function()
      return SPAWN:NewWithAlias(config.template.groupName, alias)
    end)
    if not constructionOk or not spawnerOrError then
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        constructionOk and "SPAWN construction returned nil" or spawnerOrError
      )
    end

    local spawnOk, groupOrError = pcall(function()
      return spawnerOrError:SpawnInZone(entryZone, false)
    end)
    if not spawnOk or type(groupOrError) ~= "table" then
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        spawnOk and "SpawnInZone did not return a GROUP wrapper" or groupOrError
      )
    end

    local runtimeGroup = groupOrError
    local pruneOk, livingUnitCount = pruneSpawnedGroupToSlots(
      runtimeGroup,
      self.entity.survivingVehicleSlots
    )
    if not pruneOk then
      destroyGroupSilently(runtimeGroup)
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        livingUnitCount
      )
    end

    local inspectionOk, inspection = inspectGroup(runtimeGroup)
    if not inspectionOk then
      destroyGroupSilently(runtimeGroup)
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        inspection
      )
    end
    if not inspection.alive then
      destroyGroupSilently(runtimeGroup)
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        "spawned runtime group is not alive"
      )
    end
    if inspection.livingUnitCount ~= livingUnitCount then
      destroyGroupSilently(runtimeGroup)
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        "runtime inspection count changed during materialization"
      )
    end

    local membershipOk, insideEntry = pcall(function()
      return runtimeGroup:IsCompletelyInZone(entryZone) == true
    end)
    if not membershipOk or not insideEntry then
      destroyGroupSilently(runtimeGroup)
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        membershipOk and "spawned group is not completely inside entry zone" or insideEntry
      )
    end

    self.spawner = spawnerOrError
    self.runtimeGroup = runtimeGroup
    updateEntity({
      physicalGeneration = nextGeneration,
      runtimeGroupName = inspection.name,
      representationState = REPRESENTATION_PHYSICAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_PHYSICAL_READY,
      segmentIndex = section.entrySegmentIndex,
      segmentProgress = 0,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })
    self.routeAssignedGeneration = nil
    self.lastError = nil

    local invariantOk, invariantError = validateRepresentationInvariant()
    if not invariantOk then
      destroyGroupSilently(runtimeGroup)
      self.runtimeGroup = nil
      self.spawner = nil
      updateEntity({
        runtimeGroupName = nil,
        representationState = REPRESENTATION_VIRTUAL,
      })
      return logFailure(
        "convoy_materialization_failed",
        MOVEMENT_MATERIALIZATION_FAILED,
        invariantError
      )
    end

    local fields = commonFields()
    fields.entryZoneName = section.entry
    fields.livingUnitCount = livingUnitCount
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_materialized", fields)
    announce(
      "Convoy materialized"
        .. "\nSection: " .. section.id
        .. "\nRuntime group: " .. inspection.name
        .. "\nGeneration: " .. nextGeneration
        .. "\nVehicle slots: " .. joinNumbers(self.entity.survivingVehicleSlots)
    )
    return true
  end

  function controller:startPhysicalRoute()
    local action = "Start physical route"
    local fields = commonFields()
    fields.action = action
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_cached_route_requested", fields)

    if not ensureBootstrapReady(action) then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return reject(action, "another representation transition is active")
    end
    if self.entity.representationState ~= REPRESENTATION_PHYSICAL then
      return reject(action, "entity is not physical")
    end
    if self.entity.movementState ~= MOVEMENT_PHYSICAL_READY then
      return reject(action, "physical representation is not ready for route assignment")
    end
    if self.routeAssignedGeneration == self.entity.physicalGeneration then
      return reject(action, "route is already assigned to this physical generation")
    end

    local invariantOk, invariantError = validateRepresentationInvariant()
    if not invariantOk then
      return logFailure("convoy_cached_route_failed", MOVEMENT_ROUTE_FAILED, invariantError)
    end

    local section = currentSection()
    local routeOk, waypoints = buildSectionRoute(section)
    if not routeOk then
      return logFailure("convoy_cached_route_failed", MOVEMENT_ROUTE_FAILED, waypoints)
    end

    local assignmentOk, assignmentResult = pcall(function()
      return self.runtimeGroup:Route(waypoints, 0)
    end)
    if not assignmentOk or not assignmentResult then
      return logFailure(
        "convoy_cached_route_failed",
        MOVEMENT_ROUTE_FAILED,
        assignmentOk and "route assignment returned nil" or assignmentResult
      )
    end

    self.routeAssignedGeneration = self.entity.physicalGeneration
    updateEntity({
      movementState = MOVEMENT_PHYSICAL_MOVING,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })
    self.lastError = nil

    local successFields = commonFields()
    successFields.totalWaypointCount = #waypoints
    successFields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_cached_route_started", successFields)
    announce(
      "Physical route started"
        .. "\nSection: " .. section.id
        .. "\nGeneration: " .. self.entity.physicalGeneration
        .. "\nWaypoints: " .. #waypoints
    )
    return true
  end

  function controller:dematerialize()
    local action = "Dematerialize convoy"
    local fields = commonFields()
    fields.action = action
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_dematerialization_requested", fields)

    if not ensureBootstrapReady(action) then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return reject(action, "another representation transition is active")
    end
    if self.entity.representationState ~= REPRESENTATION_PHYSICAL then
      return reject(action, "entity is not physical")
    end
    if self.entity.movementState ~= MOVEMENT_PHYSICAL_MOVING then
      return reject(action, "physical convoy is not moving on its assigned section")
    end

    local invariantOk, invariantError = validateRepresentationInvariant()
    if not invariantOk then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        invariantError
      )
    end

    local section = currentSection()
    local lookupOk, exitZone = pcall(function()
      return ZONE:FindByName(section.exit)
    end)
    if not lookupOk or not exitZone then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        lookupOk and "exit zone is unavailable: " .. section.exit or exitZone
      )
    end

    local membershipOk, insideExit = pcall(function()
      return self.runtimeGroup:IsCompletelyInZone(exitZone) == true
    end)
    if not membershipOk then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        insideExit
      )
    end
    if not insideExit then
      return reject(action, "runtime group is not completely inside the current exit zone")
    end

    local slotsOk, survivingSlots = captureSurvivingSlots(self.runtimeGroup)
    if not slotsOk then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        survivingSlots
      )
    end

    updateEntity({
      transitionState = TRANSITION_DEMATERIALIZING,
      survivingVehicleSlots = copyArray(survivingSlots),
      segmentIndex = section.exitSegmentIndex,
      segmentProgress = 1,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })

    local retiredName = self.entity.runtimeGroupName
    local destructionOk, destructionError = destroyGroupSilently(self.runtimeGroup)
    if not destructionOk then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        destructionError
      )
    end
    if groupIsAlive(self.runtimeGroup) then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        "runtime group is still alive after silent destruction"
      )
    end

    self.retiredRuntimeGroupNames[#self.retiredRuntimeGroupNames + 1] = retiredName
    self.runtimeGroup = nil
    self.spawner = nil
    updateEntity({
      runtimeGroupName = nil,
      representationState = REPRESENTATION_VIRTUAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_VIRTUAL_MOVING,
    })
    self.routeAssignedGeneration = nil
    self.lastError = nil

    local postInvariantOk, postInvariantError = validateRepresentationInvariant()
    if not postInvariantOk then
      return logFailure(
        "convoy_dematerialization_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        postInvariantError
      )
    end

    local successFields = commonFields()
    successFields.exitZoneName = section.exit
    successFields.retiredRuntimeGroupName = retiredName
    successFields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_dematerialized", successFields)
    announce(
      "Convoy dematerialized"
        .. "\nSection: " .. section.id
        .. "\nRetired group: " .. retiredName
        .. "\nVehicle slots: " .. joinNumbers(self.entity.survivingVehicleSlots)
    )
    return true
  end

  function controller:advanceVirtual()
    local action = "Advance virtual convoy"
    local fields = commonFields()
    fields.action = action
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_virtual_advance_requested", fields)

    if not ensureBootstrapReady(action) then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return reject(action, "another representation transition is active")
    end
    if self.entity.representationState ~= REPRESENTATION_VIRTUAL then
      return reject(action, "entity is not virtual")
    end
    if self.entity.movementState ~= MOVEMENT_VIRTUAL_MOVING then
      return reject(action, "virtual entity is not moving")
    end
    if self.entity.currentSectionIndex >= config.virtualization.finalSectionIndex then
      return reject(action, "entity is already at the final reveal section")
    end

    local retiredOk, retiredError = ensureRetiredGroupsAreNotAlive()
    if not retiredOk then
      return logFailure(
        "convoy_virtual_advance_failed",
        MOVEMENT_DEMATERIALIZATION_FAILED,
        retiredError
      )
    end

    local nextSectionIndex = self.entity.currentSectionIndex + 1
    local section = config.zones.revealSections[nextSectionIndex]
    updateEntity({
      currentSectionIndex = nextSectionIndex,
      segmentIndex = section.entrySegmentIndex,
      segmentProgress = 0,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })
    self.lastError = nil

    local successFields = commonFields()
    successFields.entryZoneName = section.entry
    successFields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_virtual_advanced", successFields)
    announce(
      "Virtual convoy advanced"
        .. "\nNext section: " .. section.id
        .. "\nEntry anchor: " .. section.entry
    )
    return true
  end

  function controller:showStatus()
    local section = currentSection()
    local inspectionError = nil
    local livingUnitCount = nil
    local targetZoneMembership = nil

    if self.entity.representationState == REPRESENTATION_PHYSICAL and self.runtimeGroup then
      local inspectionOk, inspection = inspectGroup(self.runtimeGroup)
      if inspectionOk then
        if inspection.name ~= self.entity.runtimeGroupName then
          updateEntity({ runtimeGroupName = inspection.name })
        end
        livingUnitCount = inspection.livingUnitCount
        if livingUnitCount < 1 then
          updateEntity({ movementState = MOVEMENT_DESTROYED })
        end
      else
        inspectionError = inspection
      end

      if self.entity.currentSectionIndex == config.virtualization.finalSectionIndex then
        local targetLookupOk, targetZone = pcall(function()
          return ZONE:FindByName(config.zones.target)
        end)
        if targetLookupOk and targetZone then
          local membershipOk, membership = pcall(function()
            return self.runtimeGroup:IsCompletelyInZone(targetZone) == true
          end)
          if membershipOk then
            targetZoneMembership = membership
            if membership
              and self.routeAssignedGeneration == self.entity.physicalGeneration
              and self.entity.movementState ~= MOVEMENT_DESTROYED then
              updateEntity({
                movementState = MOVEMENT_ARRIVED,
                segmentIndex = section.exitSegmentIndex,
                segmentProgress = 1,
                lastMovementUpdateCampaignTime = timer.getTime(),
              })
              if not self.arrivalLogged then
                self.arrivalLogged = true
                local arrivalFields = commonFields()
                arrivalFields.livingUnitCount = livingUnitCount
                arrivalFields.targetZoneMembership = true
                arrivalFields.targetZoneName = config.zones.target
                arrivalFields.missionTimeSeconds = timer.getTime()
                logger:info("convoy_route_arrived", arrivalFields)
              end
            end
          else
            inspectionError = membership
          end
        elseif not targetLookupOk then
          inspectionError = targetZone
        else
          inspectionError = "target zone is unavailable"
        end
      end
    end

    local invariantOk, invariantError = validateRepresentationInvariant()
    local fields = commonFields()
    fields.livingUnitCount = livingUnitCount or "unavailable"
    fields.targetZoneMembership = targetZoneMembership == nil
      and "unavailable" or targetZoneMembership
    fields.invariantOk = invariantOk
    fields.missionTimeSeconds = timer.getTime()
    if not invariantOk then
      fields.invariantError = invariantError
    end
    if inspectionError then
      fields.inspectionError = inspectionError
    end
    if self.lastError then
      fields.lastError = self.lastError
    end
    logger:info("convoy_cache_status", fields)

    announce(
      "Entity: " .. self.entity.entityId
        .. "\nRepresentation: " .. self.entity.representationState
        .. "\nTransition: " .. self.entity.transitionState
        .. "\nMovement: " .. self.entity.movementState
        .. "\nSection: " .. displayValue(section and section.id)
        .. "\nGeneration: " .. self.entity.physicalGeneration
        .. "\nRuntime group: " .. displayValue(self.entity.runtimeGroupName)
        .. "\nVehicle slots: " .. joinNumbers(self.entity.survivingVehicleSlots)
        .. "\nInvariant: " .. tostring(invariantOk)
    )
  end

  function controller:getState()
    return self.campaignState:getEntitySnapshot(config.scenarioId)
  end

  return controller
end

return ConvoyCacheController