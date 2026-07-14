local ConvoyCacheController = {}

local REPRESENTATION_VIRTUAL = "VIRTUAL"
local REPRESENTATION_PHYSICAL = "PHYSICAL"

local TRANSITION_IDLE = "IDLE"
local TRANSITION_MATERIALIZING = "MATERIALIZING"
local TRANSITION_DEMATERIALIZING = "DEMATERIALIZING"

local MOVEMENT_NOT_STARTED = "NOT_STARTED"
local MOVEMENT_VIRTUAL_MOVING = "VIRTUAL_MOVING"
local MOVEMENT_PHYSICAL_MOVING = "PHYSICAL_MOVING"
local MOVEMENT_ARRIVED = "ARRIVED"
local MOVEMENT_DESTROYED = "DESTROYED"
local MOVEMENT_AUTOMATION_FAILED = "AUTOMATION_FAILED"

local MOOSE_FORMATIONS = {
  ON_ROAD = "On Road",
}

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

local function isInteger(value)
  return type(value) == "number" and value >= 0 and value == math.floor(value)
end

local function parseSpawnSlot(unitName)
  if type(unitName) ~= "string" then
    return nil
  end
  local suffix = string.match(unitName, "%-(%d+)$")
  return suffix and tonumber(suffix) or nil
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
    pendingDematerialization = nil,
    virtualLeg = nil,
    exitSeenSlots = {},
    schedulerId = nil,
    halted = false,
    arrivalLogged = false,
    lastError = nil,
  }

  local automationTick
  local pollPendingDematerialization
  local beginVirtualLeg
  local materializeCurrentSection
  local beginDematerialization
  local finalizeDematerialization

  local function updateEntity(changes)
    controller.entity = controller.campaignState:updateEntity(config.scenarioId, changes)
    return controller.entity
  end

  local function currentSection()
    return config.zones.revealSections[controller.entity.currentSectionIndex]
  end

  local function finalSegmentIndex()
    return #config.zones.routeAnchors + 1
  end

  local function routeZoneNameAt(segmentIndex)
    if segmentIndex == 0 then
      return config.zones.start
    end
    if segmentIndex >= 1 and segmentIndex <= #config.zones.routeAnchors then
      return config.zones.routeAnchors[segmentIndex]
    end
    if segmentIndex == finalSegmentIndex() then
      return config.zones.target
    end
    return nil
  end

  local function countSeenLiveSlots(liveSlots)
    local count = 0
    for _, slot in ipairs(liveSlots or {}) do
      if controller.exitSeenSlots[slot] then
        count = count + 1
      end
    end
    return count
  end

  local function commonFields()
    local section = currentSection()
    local leg = controller.virtualLeg
    local liveSlots = controller.entity.survivingVehicleSlots or {}
    return {
      entityId = controller.entity.entityId,
      routeId = controller.entity.routeId,
      automationStarted = controller.entity.automationStarted == true,
      automationHalted = controller.halted,
      representationState = controller.entity.representationState,
      transitionState = controller.entity.transitionState,
      movementState = controller.entity.movementState,
      currentSectionIndex = controller.entity.currentSectionIndex,
      currentSectionId = section and section.id or "none",
      segmentIndex = controller.entity.segmentIndex,
      segmentProgress = controller.entity.segmentProgress,
      physicalGeneration = controller.entity.physicalGeneration,
      runtimeGroupName = controller.entity.runtimeGroupName or "none",
      survivingVehicleSlots = joinNumbers(liveSlots),
      exitSeenSlotCount = countSeenLiveSlots(liveSlots),
      exitRequiredSlotCount = #liveSlots,
      pendingDematerialization = controller.pendingDematerialization ~= nil,
      virtualLegFrom = leg and leg.fromZoneName or "none",
      virtualLegTo = leg and leg.toZoneName or "none",
      virtualLegArrivalKind = leg and leg.arrivalKind or "none",
      revision = controller.entity.revision,
    }
  end

  local function announce(text)
    options.announce(text)
  end

  local function logInfo(event, extra)
    local fields = commonFields()
    for key, value in pairs(extra or {}) do
      fields[key] = value
    end
    fields.missionTimeSeconds = timer.getTime()
    logger:info(event, fields)
  end

  local function reject(action, reason)
    logInfo("convoy_automation_command_rejected", {
      action = action,
      reason = reason,
    })
    announce(action .. " rejected: " .. reason)
    return false
  end

  local function haltAutomation(event, reason, movementState)
    controller.halted = true
    controller.lastError = tostring(reason)
    updateEntity({
      movementState = movementState or MOVEMENT_AUTOMATION_FAILED,
      transitionState = TRANSITION_IDLE,
    })
    local fields = commonFields()
    fields.reason = controller.lastError
    fields.missionTimeSeconds = timer.getTime()
    logger:error(event, fields)
    announce("Convoy automation halted: " .. controller.lastError)
    return false
  end

  local function ensureBootstrapReady(action)
    if options.getBootstrapOutcome() ~= "READY" then
      return reject(action, "bootstrap outcome is not READY")
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
    return pcall(function()
      local nativeGroup = Group.getByName(runtimeName)
      if not nativeGroup then
        return false
      end
      return nativeGroup:isExist() == true
    end)
  end

  local function ensureRetiredGroupsAreAbsent()
    for _, runtimeName in ipairs(controller.retiredRuntimeGroupNames) do
      local lookupOk, existsOrError = nativeGroupExists(runtimeName)
      if not lookupOk then
        return false, existsOrError
      end
      if existsOrError then
        return false, "retired runtime group still exists: " .. runtimeName
      end
    end
    return true
  end

  local function validateRepresentationInvariant()
    if controller.entity.representationState == REPRESENTATION_VIRTUAL then
      if controller.entity.runtimeGroupName ~= nil then
        return false, "virtual entity still has an authoritative runtime group name"
      end
      if controller.runtimeGroup and groupIsAlive(controller.runtimeGroup) then
        return false, "virtual entity still has a live physical group"
      end
      return true
    end

    if controller.entity.representationState == REPRESENTATION_PHYSICAL then
      if controller.entity.transitionState == TRANSITION_DEMATERIALIZING then
        if not controller.pendingDematerialization then
          return false, "dematerializing entity has no pending transition record"
        end
        return true
      end
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

  local function zoneByName(zoneName)
    local ok, zoneOrError = pcall(function()
      return ZONE:FindByName(zoneName)
    end)
    if not ok then
      return nil, zoneOrError
    end
    if not zoneOrError then
      return nil, "zone is unavailable: " .. tostring(zoneName)
    end
    return zoneOrError, nil
  end

  local function distanceBetweenZones(fromZoneName, toZoneName)
    local fromZone, fromError = zoneByName(fromZoneName)
    if not fromZone then
      return nil, fromError
    end
    local toZone, toError = zoneByName(toZoneName)
    if not toZone then
      return nil, toError
    end

    local fromVec2 = fromZone:GetVec2()
    local toVec2 = toZone:GetVec2()
    if type(fromVec2) ~= "table" or type(toVec2) ~= "table" then
      return nil, "virtual leg zone coordinates are unavailable"
    end

    local dx = toVec2.x - fromVec2.x
    local dy = toVec2.y - fromVec2.y
    return math.sqrt(dx * dx + dy * dy), nil
  end

  local function captureLiveUnits(group)
    return pcall(function()
      local units = group:GetUnits()
      if type(units) ~= "table" then
        error("runtime group units are unavailable")
      end

      local result = {}
      local seen = {}
      for _, unit in pairs(units) do
        if unit and unit:IsAlive() == true then
          local unitName = unit:GetName()
          local slot = parseSpawnSlot(unitName)
          if not slot then
            error("cannot parse vehicle slot from unit name: " .. tostring(unitName))
          end
          if slot < 1 or slot > config.template.expectedVehicleCount then
            error("parsed vehicle slot is outside configured range: " .. tostring(slot))
          end
          if seen[slot] then
            error("duplicate vehicle slot detected: " .. tostring(slot))
          end
          seen[slot] = true
          result[#result + 1] = {
            slot = slot,
            unit = unit,
          }
        end
      end

      table.sort(result, function(left, right)
        return left.slot < right.slot
      end)
      return result
    end)
  end

  local function slotsFromLiveUnits(liveUnits)
    local slots = {}
    for _, item in ipairs(liveUnits or {}) do
      slots[#slots + 1] = item.slot
    end
    return slots
  end

  local function captureSurvivingSlots(group)
    local ok, liveUnitsOrError = captureLiveUnits(group)
    if not ok then
      return false, liveUnitsOrError
    end
    local slots = slotsFromLiveUnits(liveUnitsOrError)
    if #slots < 1 then
      return false, "no surviving vehicle slots remain"
    end
    return true, slots
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
          local slot = parseSpawnSlot(unit:GetName())
          if not slot then
            error("cannot parse spawned vehicle slot")
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
      return #survivingSlots
    end)
  end

  local function buildPhysicalWindowRoute(section)
    return pcall(function()
      local formation = MOOSE_FORMATIONS[config.routing.formation]
      if config.routing.roadOnly ~= true or not formation then
        error("road-only ON_ROAD routing configuration is required")
      end

      local waypoints = {}
      local routeZoneNames = {}

      for segmentIndex = section.entrySegmentIndex + 1, section.exitSegmentIndex do
        local zoneName = routeZoneNameAt(segmentIndex)
        if not zoneName or zoneName == config.zones.target then
          error("invalid physical-window route segment: " .. tostring(segmentIndex))
        end
        local zone, zoneError = zoneByName(zoneName)
        if not zone then
          error(zoneError)
        end
        local waypoint = zone:GetCoordinate():WaypointGround(config.routing.speedKph, formation)
        if type(waypoint) ~= "table" then
          error("ground waypoint construction failed: " .. zoneName)
        end
        waypoints[#waypoints + 1] = waypoint
        routeZoneNames[#routeZoneNames + 1] = zoneName
      end

      local exitZone, exitError = zoneByName(section.exit)
      if not exitZone then
        error(exitError)
      end
      local exitWaypoint = exitZone:GetCoordinate():WaypointGround(config.routing.speedKph, formation)
      if type(exitWaypoint) ~= "table" then
        error("exit-zone waypoint construction failed: " .. section.exit)
      end
      waypoints[#waypoints + 1] = exitWaypoint
      routeZoneNames[#routeZoneNames + 1] = section.exit

      return {
        waypoints = waypoints,
        routeZoneNames = routeZoneNames,
      }
    end)
  end

  local function destroyGroupSilently(group)
    return pcall(function()
      group:Destroy(false)
    end)
  end

  beginVirtualLeg = function(fromZoneName, toZoneName, arrivalKind, sectionIndex)
    local distanceMeters, distanceError = distanceBetweenZones(fromZoneName, toZoneName)
    if not distanceMeters then
      return haltAutomation("convoy_virtual_leg_failed", distanceError)
    end

    local speedMetersPerSecond = config.virtualization.effectiveSpeedKph / 3.6
    local durationSeconds = math.max(
      config.virtualization.minimumVirtualLegSeconds,
      distanceMeters / speedMetersPerSecond
    )
    local now = timer.getTime()

    controller.virtualLeg = {
      fromZoneName = fromZoneName,
      toZoneName = toZoneName,
      arrivalKind = arrivalKind,
      sectionIndex = sectionIndex,
      distanceMeters = distanceMeters,
      durationSeconds = durationSeconds,
      startedAt = now,
    }

    updateEntity({
      clearFields = { "runtimeGroupName" },
      representationState = REPRESENTATION_VIRTUAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_VIRTUAL_MOVING,
      segmentProgress = 0,
      lastMovementUpdateCampaignTime = now,
    })

    logInfo("convoy_virtual_leg_started", {
      fromZoneName = fromZoneName,
      toZoneName = toZoneName,
      arrivalKind = arrivalKind,
      distanceMeters = distanceMeters,
      durationSeconds = durationSeconds,
      effectiveSpeedKph = config.virtualization.effectiveSpeedKph,
    })
    return true
  end

  local function tickVirtual()
    local leg = controller.virtualLeg
    if not leg then
      return haltAutomation("convoy_virtual_tick_failed", "virtual entity has no active virtual leg")
    end

    local now = timer.getTime()
    local progress = clamp((now - leg.startedAt) / leg.durationSeconds, 0, 1)
    updateEntity({
      segmentProgress = progress,
      lastMovementUpdateCampaignTime = now,
    })

    if progress < 1 then
      return true
    end

    controller.virtualLeg = nil
    updateEntity({
      routeDistanceMeters = controller.entity.routeDistanceMeters + leg.distanceMeters,
      segmentProgress = 1,
      lastMovementUpdateCampaignTime = now,
    })

    if leg.arrivalKind == "ENTRY" then
      local section = config.zones.revealSections[leg.sectionIndex]
      if not section then
        return haltAutomation("convoy_virtual_arrival_failed", "reveal section is unavailable")
      end
      updateEntity({
        currentSectionIndex = leg.sectionIndex,
        segmentIndex = section.entrySegmentIndex,
        segmentProgress = 0,
      })
      logInfo("convoy_reveal_entry_reached", {
        entryZoneName = section.entry,
        sectionId = section.id,
      })
      return materializeCurrentSection()
    end

    if leg.arrivalKind == "TARGET" then
      updateEntity({
        segmentIndex = finalSegmentIndex(),
        segmentProgress = 1,
        movementState = MOVEMENT_ARRIVED,
      })
      if not controller.arrivalLogged then
        controller.arrivalLogged = true
        logInfo("convoy_route_arrived", {
          targetZoneName = config.zones.target,
        })
      end
      announce("Convoy arrived virtually at " .. config.zones.target)
      return true
    end

    return haltAutomation("convoy_virtual_arrival_failed", "unknown virtual arrival kind")
  end

  materializeCurrentSection = function()
    local section = currentSection()
    if not section then
      return haltAutomation("convoy_materialization_failed", "current reveal section is unavailable")
    end

    local retiredOk, retiredError = ensureRetiredGroupsAreAbsent()
    if not retiredOk then
      return haltAutomation("convoy_materialization_failed", retiredError)
    end

    local entryZone, entryError = zoneByName(section.entry)
    if not entryZone then
      return haltAutomation("convoy_materialization_failed", entryError)
    end

    updateEntity({ transitionState = TRANSITION_MATERIALIZING })
    local nextGeneration = controller.entity.physicalGeneration + 1
    local alias = config.template.runtimeAliasPrefix
      .. "_G" .. string.format("%02d", nextGeneration)

    local constructionOk, spawnerOrError = pcall(function()
      local spawner = SPAWN:NewWithAlias(config.template.groupName, alias)
      return spawner:InitPositionCoordinate(entryZone:GetCoordinate())
    end)
    if not constructionOk or type(spawnerOrError) ~= "table" then
      return haltAutomation(
        "convoy_materialization_failed",
        constructionOk and "SPAWN position initialization returned no spawner" or spawnerOrError
      )
    end

    local spawnOk, groupOrError = pcall(function()
      return spawnerOrError:Spawn()
    end)
    if not spawnOk or type(groupOrError) ~= "table" then
      return haltAutomation(
        "convoy_materialization_failed",
        spawnOk and "SPAWN:Spawn did not return a GROUP wrapper" or groupOrError
      )
    end

    local runtimeGroup = groupOrError
    local pruneOk, livingCountOrError = pruneSpawnedGroupToSlots(
      runtimeGroup,
      controller.entity.survivingVehicleSlots
    )
    if not pruneOk then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation("convoy_materialization_failed", livingCountOrError)
    end

    local routeOk, routeOrError = buildPhysicalWindowRoute(section)
    if not routeOk then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation("convoy_physical_route_failed", routeOrError)
    end

    local assignmentOk, assignmentResult = pcall(function()
      return runtimeGroup:Route(routeOrError.waypoints, 0)
    end)
    if not assignmentOk or not assignmentResult then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation(
        "convoy_physical_route_failed",
        assignmentOk and "route assignment returned nil" or assignmentResult
      )
    end

    local inspectionOk, runtimeNameOrError = pcall(function()
      return runtimeGroup:GetName()
    end)
    if not inspectionOk or type(runtimeNameOrError) ~= "string" then
      destroyGroupSilently(runtimeGroup)
      return haltAutomation("convoy_materialization_failed", runtimeNameOrError)
    end

    controller.spawner = spawnerOrError
    controller.runtimeGroup = runtimeGroup
    controller.routeAssignedGeneration = nextGeneration
    controller.exitSeenSlots = {}
    controller.lastError = nil

    updateEntity({
      physicalGeneration = nextGeneration,
      runtimeGroupName = runtimeNameOrError,
      representationState = REPRESENTATION_PHYSICAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_PHYSICAL_MOVING,
      segmentProgress = 0,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })

    local invariantOk, invariantError = validateRepresentationInvariant()
    if not invariantOk then
      destroyGroupSilently(runtimeGroup)
      controller.runtimeGroup = nil
      controller.spawner = nil
      return haltAutomation("convoy_materialization_failed", invariantError)
    end

    logInfo("convoy_automatically_materialized", {
      sectionId = section.id,
      entryZoneName = section.entry,
      exitZoneName = section.exit,
      runtimeGroupName = runtimeNameOrError,
      livingUnitCount = livingCountOrError,
      physicalWaypointCount = #routeOrError.waypoints,
      physicalRouteZones = table.concat(routeOrError.routeZoneNames, ","),
    })
    announce(
      "Convoy visible in " .. section.id
        .. "\nEntry: " .. section.entry
        .. "\nExit: " .. section.exit
    )
    return true
  end

  local function tickPhysical()
    if not controller.runtimeGroup or not groupIsAlive(controller.runtimeGroup) then
      updateEntity({ movementState = MOVEMENT_DESTROYED })
      controller.halted = true
      logInfo("convoy_destroyed", {})
      announce("Convoy destroyed; automation stopped")
      return false
    end

    local section = currentSection()
    if not section then
      return haltAutomation("convoy_exit_monitor_failed", "current reveal section is unavailable")
    end
    local exitZone, exitError = zoneByName(section.exit)
    if not exitZone then
      return haltAutomation("convoy_exit_monitor_failed", exitError)
    end

    local liveOk, liveUnitsOrError = captureLiveUnits(controller.runtimeGroup)
    if not liveOk then
      return haltAutomation("convoy_exit_monitor_failed", liveUnitsOrError)
    end
    local liveSlots = slotsFromLiveUnits(liveUnitsOrError)
    if #liveSlots < 1 then
      updateEntity({ movementState = MOVEMENT_DESTROYED })
      controller.halted = true
      logInfo("convoy_destroyed", {})
      announce("Convoy destroyed; automation stopped")
      return false
    end

    if not arraysEqual(liveSlots, controller.entity.survivingVehicleSlots) then
      updateEntity({ survivingVehicleSlots = copyArray(liveSlots) })
      logInfo("convoy_losses_observed", {
        survivingVehicleSlots = joinNumbers(liveSlots),
      })
    end

    local newlySeen = {}
    for _, item in ipairs(liveUnitsOrError) do
      if not controller.exitSeenSlots[item.slot] then
        local vec2Ok, vec2OrError = pcall(function()
          return item.unit:GetVec2()
        end)
        if not vec2Ok then
          return haltAutomation("convoy_exit_monitor_failed", vec2OrError)
        end
        if exitZone:IsVec2InZone(vec2OrError) == true then
          controller.exitSeenSlots[item.slot] = true
          newlySeen[#newlySeen + 1] = item.slot
        end
      end
    end

    if #newlySeen > 0 then
      table.sort(newlySeen)
      logInfo("convoy_exit_gate_progress", {
        exitZoneName = section.exit,
        newlySeenSlots = joinNumbers(newlySeen),
        seenSlotCount = countSeenLiveSlots(liveSlots),
        requiredSlotCount = #liveSlots,
      })
    end

    for _, slot in ipairs(liveSlots) do
      if not controller.exitSeenSlots[slot] then
        return true
      end
    end

    return beginDematerialization(section)
  end

  beginDematerialization = function(section)
    if controller.pendingDematerialization then
      return true
    end

    local slotsOk, survivingSlotsOrError = captureSurvivingSlots(controller.runtimeGroup)
    if not slotsOk then
      return haltAutomation("convoy_dematerialization_failed", survivingSlotsOrError)
    end

    local pending = {
      runtimeGroupName = controller.entity.runtimeGroupName,
      sectionId = section.id,
      sectionIndex = controller.entity.currentSectionIndex,
      exitZoneName = section.exit,
      startedAt = timer.getTime(),
      attempts = 0,
    }
    controller.pendingDematerialization = pending

    updateEntity({
      transitionState = TRANSITION_DEMATERIALIZING,
      survivingVehicleSlots = copyArray(survivingSlotsOrError),
      segmentIndex = section.exitSegmentIndex,
      segmentProgress = 1,
      lastMovementUpdateCampaignTime = timer.getTime(),
    })

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        pollPendingDematerialization,
        nil,
        timer.getTime() + config.virtualization.destroyConfirmationPollSeconds
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      return haltAutomation(
        "convoy_dematerialization_failed",
        scheduleOk and "destruction confirmation scheduler returned nil" or scheduleResult
      )
    end

    local destructionOk, destructionError = destroyGroupSilently(controller.runtimeGroup)
    if not destructionOk then
      return haltAutomation("convoy_dematerialization_failed", destructionError)
    end

    logInfo("convoy_automatic_dematerialization_started", {
      sectionId = section.id,
      exitZoneName = section.exit,
      survivingVehicleSlots = joinNumbers(survivingSlotsOrError),
    })
    return true
  end

  finalizeDematerialization = function(pending)
    if controller.pendingDematerialization ~= pending then
      return false
    end

    controller.retiredRuntimeGroupNames[#controller.retiredRuntimeGroupNames + 1] = pending.runtimeGroupName
    controller.pendingDematerialization = nil
    controller.runtimeGroup = nil
    controller.spawner = nil
    controller.routeAssignedGeneration = nil
    controller.exitSeenSlots = {}

    updateEntity({
      clearFields = { "runtimeGroupName" },
      representationState = REPRESENTATION_VIRTUAL,
      transitionState = TRANSITION_IDLE,
      movementState = MOVEMENT_VIRTUAL_MOVING,
      segmentProgress = 0,
    })

    logInfo("convoy_automatically_dematerialized", {
      sectionId = pending.sectionId,
      exitZoneName = pending.exitZoneName,
      retiredRuntimeGroupName = pending.runtimeGroupName,
      destroyConfirmationAttempts = pending.attempts,
    })
    announce("Convoy virtual after " .. pending.sectionId)

    local nextSectionIndex = pending.sectionIndex + 1
    local nextSection = config.zones.revealSections[nextSectionIndex]
    if nextSection then
      return beginVirtualLeg(
        pending.exitZoneName,
        nextSection.entry,
        "ENTRY",
        nextSectionIndex
      )
    end

    return beginVirtualLeg(
      pending.exitZoneName,
      config.zones.target,
      "TARGET",
      nil
    )
  end

  pollPendingDematerialization = function(_, scheduledTime)
    local pending = controller.pendingDematerialization
    if not pending then
      return nil
    end

    pending.attempts = pending.attempts + 1
    local lookupOk, existsOrError = nativeGroupExists(pending.runtimeGroupName)
    if lookupOk and existsOrError == false then
      finalizeDematerialization(pending)
      return nil
    end

    local elapsed = timer.getTime() - pending.startedAt
    if elapsed >= config.virtualization.destroyConfirmationTimeoutSeconds then
      local reason = lookupOk
        and "native runtime group still exists after destruction timeout"
        or "native destruction confirmation failed: " .. tostring(existsOrError)
      haltAutomation("convoy_dematerialization_failed", reason)
      return nil
    end

    return scheduledTime + config.virtualization.destroyConfirmationPollSeconds
  end

  function controller:tick()
    if self.halted then
      return false
    end
    if self.entity.transitionState ~= TRANSITION_IDLE then
      return true
    end
    if self.entity.representationState == REPRESENTATION_VIRTUAL
      and self.entity.movementState == MOVEMENT_VIRTUAL_MOVING then
      return tickVirtual()
    end
    if self.entity.representationState == REPRESENTATION_PHYSICAL
      and self.entity.movementState == MOVEMENT_PHYSICAL_MOVING then
      return tickPhysical()
    end
    return true
  end

  automationTick = function(_, scheduledTime)
    if controller.halted
      or controller.entity.movementState == MOVEMENT_ARRIVED
      or controller.entity.movementState == MOVEMENT_DESTROYED then
      return nil
    end

    local ok, resultOrError = pcall(function()
      return controller:tick()
    end)
    if not ok then
      haltAutomation("convoy_automation_tick_failed", resultOrError)
      return nil
    end
    if resultOrError == false or controller.halted then
      return nil
    end

    return scheduledTime + config.virtualization.automationPollSeconds
  end

  function controller:start()
    local action = "Start convoy"
    if not ensureBootstrapReady(action) then
      return false
    end
    if self.entity.automationStarted == true then
      return reject(action, "automation has already been started")
    end
    if self.entity.movementState ~= MOVEMENT_NOT_STARTED then
      return reject(action, "convoy is not in NOT_STARTED state")
    end

    local firstSection = config.zones.revealSections[config.virtualization.initialSectionIndex]
    if not firstSection then
      return haltAutomation("convoy_automation_start_failed", "initial reveal section is unavailable")
    end

    updateEntity({ automationStarted = true })
    local legOk = beginVirtualLeg(
      config.zones.start,
      firstSection.entry,
      "ENTRY",
      config.virtualization.initialSectionIndex
    )
    if not legOk then
      return false
    end

    local scheduleOk, scheduleResult = pcall(function()
      return timer.scheduleFunction(
        automationTick,
        nil,
        timer.getTime() + 0.1
      )
    end)
    if not scheduleOk or scheduleResult == nil then
      return haltAutomation(
        "convoy_automation_start_failed",
        scheduleOk and "automation scheduler returned nil" or scheduleResult
      )
    end

    self.schedulerId = scheduleResult
    logInfo("convoy_automation_started", {
      schedulerId = scheduleResult,
      startZoneName = config.zones.start,
      firstRevealEntryZoneName = firstSection.entry,
    })
    announce(
      "Convoy automation started"
        .. "\nVirtual from: " .. config.zones.start
        .. "\nFirst reveal: " .. firstSection.entry
    )
    return true
  end

  function controller:showStatus()
    local invariantOk, invariantError = validateRepresentationInvariant()
    local fields = commonFields()
    fields.invariantOk = invariantOk
    fields.lastError = controller.lastError or "none"
    fields.missionTimeSeconds = timer.getTime()
    if not invariantOk then
      fields.invariantError = invariantError
    end
    logger:info("convoy_cache_status", fields)

    local leg = controller.virtualLeg
    announce(
      "Entity: " .. controller.entity.entityId
        .. "\nStarted: " .. tostring(controller.entity.automationStarted == true)
        .. "\nRepresentation: " .. controller.entity.representationState
        .. "\nMovement: " .. controller.entity.movementState
        .. "\nTransition: " .. controller.entity.transitionState
        .. "\nSection: " .. tostring(currentSection() and currentSection().id or "none")
        .. "\nRuntime group: " .. tostring(controller.entity.runtimeGroupName or "none")
        .. "\nVehicle slots: " .. joinNumbers(controller.entity.survivingVehicleSlots)
        .. "\nExit gate: " .. tostring(countSeenLiveSlots(controller.entity.survivingVehicleSlots))
        .. "/" .. tostring(#controller.entity.survivingVehicleSlots)
        .. "\nVirtual leg: " .. tostring(leg and (leg.fromZoneName .. " -> " .. leg.toZoneName) or "none")
        .. "\nInvariant: " .. tostring(invariantOk)
        .. "\nError: " .. tostring(controller.lastError or "none")
    )
  end

  function controller:getState()
    return self.campaignState:getEntitySnapshot(config.scenarioId)
  end

  return controller
end

return ConvoyCacheController
