local PhysicalConvoyController = {}

local STATE_NOT_SPAWNED = "NOT_SPAWNED"
local STATE_SPAWNING = "SPAWNING"
local STATE_SPAWNED = "SPAWNED"
local STATE_SPAWN_FAILED = "SPAWN_FAILED"
local STATE_DESTROYED = "DESTROYED"

local function displayValue(value)
  if value == nil then
    return "none"
  end
  return tostring(value)
end

function PhysicalConvoyController.new(options)
  local config = options.config
  local logger = options.logger
  local convoy = {
    state = STATE_NOT_SPAWNED,
    spawner = nil,
    runtimeGroup = nil,
    runtimeGroupName = nil,
    currentUnitCount = nil,
    startZoneMembership = nil,
    spawnExecutionAttempted = false,
  }

  local function commonFields()
    return {
      entityId = config.scenarioId,
      templateName = config.template.groupName,
      requestedAlias = config.template.runtimeAlias,
      runtimeGroupName = convoy.runtimeGroupName or "none",
      startZoneName = config.zones.start,
      expectedUnitCount = config.template.expectedVehicleCount,
      convoyState = convoy.state,
    }
  end

  local function announce(text)
    options.announce(text)
  end

  local function logRejected(reason)
    local fields = commonFields()
    fields.reason = reason
    fields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_spawn_rejected", fields)
    announce(
      "Convoy spawn rejected: " .. reason
        .. "\nState: " .. convoy.state
        .. "\nRuntime group: " .. displayValue(convoy.runtimeGroupName)
    )
  end

  local function logFailed(reason)
    local reasonText = tostring(reason)
    convoy.state = STATE_SPAWN_FAILED
    local fields = commonFields()
    fields.reason = reasonText
    fields.missionTimeSeconds = timer.getTime()
    logger:error("convoy_spawn_failed", fields)
    announce("Convoy spawn failed: " .. reasonText)
  end

  local function inspectRuntimeGroup(startZone, templateGroup)
    return pcall(function()
      return {
        runtimeGroupName = convoy.runtimeGroup:GetName(),
        alive = convoy.runtimeGroup:IsAlive() == true,
        unitCount = convoy.runtimeGroup:CountAliveUnits(),
        startZoneMembership = convoy.runtimeGroup:IsCompletelyInZone(startZone) == true,
        templateAlive = templateGroup:IsAlive() == true,
      }
    end)
  end

  local function refreshRuntimeStatus()
    if not convoy.runtimeGroup then
      return true, nil
    end

    local lookupOk, startZone, templateGroup = pcall(function()
      return ZONE:FindByName(config.zones.start), GROUP:FindByName(config.template.groupName)
    end)
    if not lookupOk then
      return false, startZone
    end

    if not startZone or not templateGroup then
      return false, "required group or zone wrapper is unavailable"
    end

    local inspectionOk, inspection = inspectRuntimeGroup(startZone, templateGroup)
    if not inspectionOk then
      return false, inspection
    end

    convoy.runtimeGroupName = inspection.runtimeGroupName or convoy.runtimeGroupName
    convoy.currentUnitCount = inspection.unitCount
    convoy.startZoneMembership = inspection.startZoneMembership

    if not inspection.alive
      and (convoy.state == STATE_SPAWNED or convoy.state == STATE_SPAWN_FAILED) then
      convoy.state = STATE_DESTROYED
    end

    return true, inspection
  end

  function convoy:requestSpawn()
    local requestedFields = commonFields()
    requestedFields.bootstrapOutcome = options.getBootstrapOutcome()
    requestedFields.missionTimeSeconds = timer.getTime()
    logger:info("convoy_spawn_requested", requestedFields)

    if options.getBootstrapOutcome() ~= "READY" then
      logRejected("bootstrap outcome is not READY")
      return
    end

    if self.state == STATE_SPAWNING then
      logRejected("spawn is already in progress")
      return
    end

    if self.runtimeGroup or self.spawnExecutionAttempted then
      local refreshOk, refreshResult = refreshRuntimeStatus()
      if not refreshOk then
        logger:error("convoy_status", {
          convoyState = self.state,
          entityId = config.scenarioId,
          inspectionError = refreshResult,
          runtimeGroupName = self.runtimeGroupName or "none",
        })
      end
      if refreshOk and refreshResult and refreshResult.alive then
        logRejected("live runtime group already exists")
      else
        logRejected("a convoy spawn has already been executed")
      end
      return
    end

    self.state = STATE_SPAWNING

    local preparationOk, preparation = pcall(function()
      local templateGroup = GROUP:FindByName(config.template.groupName)
      local startZone = ZONE:FindByName(config.zones.start)
      if not templateGroup then
        error("template wrapper is unavailable")
      end
      if not startZone then
        error("start zone wrapper is unavailable")
      end
      if templateGroup:IsAlive() == true then
        error("original Late Activation template is already active")
      end
      return {
        templateGroup = templateGroup,
        startZone = startZone,
      }
    end)
    if not preparationOk then
      logFailed(preparation)
      return
    end

    local constructionOk, spawnerOrError = pcall(function()
      return SPAWN:NewWithAlias(config.template.groupName, config.template.runtimeAlias)
    end)
    if not constructionOk or not spawnerOrError then
      logFailed(constructionOk and "SPAWN construction returned nil" or spawnerOrError)
      return
    end
    self.spawner = spawnerOrError

    self.spawnExecutionAttempted = true
    local spawnOk, groupOrError = pcall(function()
      return self.spawner:SpawnInZone(preparation.startZone, false)
    end)
    if not spawnOk or type(groupOrError) ~= "table" then
      logFailed(spawnOk and "SpawnInZone did not return a GROUP wrapper" or groupOrError)
      return
    end
    self.runtimeGroup = groupOrError

    local inspectionOk, inspection = inspectRuntimeGroup(
      preparation.startZone,
      preparation.templateGroup
    )
    if not inspectionOk then
      logFailed(inspection)
      return
    end

    self.runtimeGroupName = inspection.runtimeGroupName
    self.currentUnitCount = inspection.unitCount
    self.startZoneMembership = inspection.startZoneMembership

    local failures = {}
    if type(inspection.runtimeGroupName) ~= "string" or inspection.runtimeGroupName == "" then
      failures[#failures + 1] = "runtime group name is unavailable"
    elseif inspection.runtimeGroupName == config.template.groupName then
      failures[#failures + 1] = "runtime group reused the template name"
    elseif string.sub(inspection.runtimeGroupName, 1, #config.template.runtimeAlias)
      ~= config.template.runtimeAlias then
      failures[#failures + 1] = "runtime group name does not use the requested alias"
    end
    if not inspection.alive then
      failures[#failures + 1] = "runtime group is not alive"
    end
    if inspection.unitCount ~= config.template.expectedVehicleCount then
      failures[#failures + 1] = "runtime group unit count is not six"
    end
    if not inspection.startZoneMembership then
      failures[#failures + 1] = "runtime group is not completely inside the start zone"
    end
    if inspection.templateAlive then
      failures[#failures + 1] = "original template became active"
    end

    if #failures > 0 then
      logFailed(table.concat(failures, ", "))
      return
    end

    self.state = STATE_SPAWNED
    local successFields = commonFields()
    successFields.actualUnitCount = inspection.unitCount
    successFields.missionTimeSeconds = timer.getTime()
    successFields.startZoneMembership = inspection.startZoneMembership
    successFields.templateRemainsInactive = not inspection.templateAlive
    logger:info("convoy_spawn_succeeded", successFields)
    announce(
      "Convoy spawned\nRuntime group: " .. inspection.runtimeGroupName
        .. "\nUnits: " .. inspection.unitCount
        .. "\nState: " .. self.state
    )
  end

  function convoy:showStatus()
    local inspectionOk, inspectionError = refreshRuntimeStatus()
    local fields = commonFields()
    fields.currentUnitCount = self.currentUnitCount or "unavailable"
    fields.missionTimeSeconds = timer.getTime()
    fields.startZoneMembership = self.startZoneMembership == nil
      and "unavailable" or self.startZoneMembership
    if not inspectionOk then
      fields.inspectionError = inspectionError
    end
    logger:info("convoy_status", fields)

    announce(
      "Entity: " .. config.scenarioId
        .. "\nConvoy state: " .. self.state
        .. "\nRuntime group: " .. displayValue(self.runtimeGroupName)
        .. "\nExpected units: " .. config.template.expectedVehicleCount
        .. "\nCurrent units: " .. displayValue(self.currentUnitCount)
    )
  end

  return convoy
end

return PhysicalConvoyController
