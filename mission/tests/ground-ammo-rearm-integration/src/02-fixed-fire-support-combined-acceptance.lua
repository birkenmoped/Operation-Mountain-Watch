-- Operation Mountain Watch - combined fixed fire-support rearm acceptance.
-- Test-ID: GROUND-FIRE-SUPPORT-ACCEPTANCE-2
--
-- Purpose:
--   Exercise the same MOOSE-first rearm composition concurrently for the four
--   current Kunar fixed fire-support consumers in one DCS run. All four sites
--   use the normal M1083 support contract and a bounded four-round fire leg.
--   The earlier Honaker M939/full-depletion variant is retained only as
--   diagnostic evidence in Acceptance documentation, not as production logic.
--
-- Required owner-provided Mission Editor objects are declared in SITE_SPECS.

local TEST_ID = "GROUND-FIRE-SUPPORT-ACCEPTANCE-2"
local TAG = "[OMW][" .. TEST_ID .. "]"
local RESOURCE_ID = "GROUND_AMMO_PACKAGE"
local DEFAULT_FIRE_SHELLS = 4
local TIMEOUT_SEC = 1200

local SITE_SPECS = {
  {
    id = "BOSTICK",
    warehouse = "WH_BLUE_GND_BOSTICK",
    battery = "TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2",
    supportTemplate = "TPL_BLUE_GND_SUP_M1083",
    supportSpawnZone = "ZON_BLUE_GND_BOSTICK_RESUPPLY",
    targetZone = "ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET",
    nodeId = "GROUND_NODE_BOSTICK",
    brigade = "BDE_BLUE_GND_BOSTICK_FIRE_SUPPORT_ACCEPTANCE",
    platoon = "PLT_BLUE_GND_BOSTICK_AMMO_SUPPORT_ACCEPTANCE",
    assignment = "OMW:BOSTICK:AMMO-SUPPORT:ACCEPTANCE-2",
    carrierEntityId = "BOSTICK-AMMO-SUPPORT-M1083-ACCEPTANCE-2",
    alias = "Bostick L118 Acceptance 2",
    fireShells = DEFAULT_FIRE_SHELLS,
  },
  {
    id = "WRIGHT",
    warehouse = "WH_BLUE_GND_WRIGHT",
    battery = "TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2",
    supportTemplate = "TPL_BLUE_GND_SUP_M1083",
    supportSpawnZone = "ZON_BLUE_GND_WRIGHT_RESUPPLY",
    targetZone = "ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET",
    nodeId = "GROUND_NODE_WRIGHT",
    brigade = "BDE_BLUE_GND_WRIGHT_FIRE_SUPPORT_ACCEPTANCE",
    platoon = "PLT_BLUE_GND_WRIGHT_AMMO_SUPPORT_ACCEPTANCE",
    assignment = "OMW:WRIGHT:AMMO-SUPPORT:ACCEPTANCE-2",
    carrierEntityId = "WRIGHT-AMMO-SUPPORT-M1083-ACCEPTANCE-2",
    alias = "Wright L118 Acceptance 2",
    fireShells = DEFAULT_FIRE_SHELLS,
  },
  {
    id = "FORTRESS",
    warehouse = "WH_BLUE_GND_FORTRESS",
    battery = "TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1",
    supportTemplate = "TPL_BLUE_GND_SUP_M1083",
    supportSpawnZone = "ZON_BLUE_GND_FORTRESS_RESUPPLY",
    targetZone = "ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET",
    nodeId = "GROUND_NODE_FORTRESS",
    brigade = "BDE_BLUE_GND_FORTRESS_FIRE_SUPPORT_ACCEPTANCE",
    platoon = "PLT_BLUE_GND_FORTRESS_AMMO_SUPPORT_ACCEPTANCE",
    assignment = "OMW:FORTRESS:AMMO-SUPPORT:ACCEPTANCE-2",
    carrierEntityId = "FORTRESS-AMMO-SUPPORT-M1083-ACCEPTANCE-2",
    alias = "Fortress L118 Acceptance 2",
    fireShells = DEFAULT_FIRE_SHELLS,
  },
  {
    id = "HONAKER",
    warehouse = "WH_BLUE_GND_HONAKER",
    battery = "TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2",
    supportTemplate = "TPL_BLUE_GND_SUP_M1083",
    supportSpawnZone = "ZON_BLUE_GND_HONAKER_RESUPPLY",
    targetZone = "ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET",
    nodeId = "GROUND_NODE_HONAKER",
    brigade = "BDE_BLUE_GND_HONAKER_FIRE_SUPPORT_ACCEPTANCE",
    platoon = "PLT_BLUE_GND_HONAKER_AMMO_SUPPORT_ACCEPTANCE",
    assignment = "OMW:HONAKER:AMMO-SUPPORT:ACCEPTANCE-2",
    carrierEntityId = "HONAKER-AMMO-SUPPORT-M1083-ACCEPTANCE-2",
    alias = "Honaker 2B11 Acceptance 2",
    fireShells = DEFAULT_FIRE_SHELLS,
  },
}

local state = { failed = false, passed = false, sites = {} }

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(reason)
  if state.failed or state.passed then return end
  state.failed = true
  log("FAIL reason=" .. tostring(reason))
end

local function requireObject(object, label)
  if object == nil then
    fail("MISSING_OBJECT name=" .. tostring(label))
    return nil
  end
  return object
end

local function ammoTotal(siteState)
  local total, shells, rockets, missiles, artilleryShells = siteState.arty:GetAmmo(false)
  log("SITE_AMMO site=" .. siteState.spec.id
    .. " total=" .. tostring(total)
    .. " shells=" .. tostring(shells)
    .. " rockets=" .. tostring(rockets)
    .. " missiles=" .. tostring(missiles)
    .. " artilleryShells=" .. tostring(artilleryShells))
  return total
end

local function allSitesPassed()
  for _, spec in ipairs(SITE_SPECS) do
    local siteState = state.sites[spec.id]
    if not siteState or not siteState.passed then return false end
  end
  return true
end

local function finishAggregateIfReady()
  if state.failed or state.passed or not allSitesPassed() then return end
  state.passed = true
  log("PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=" .. tostring(#SITE_SPECS))
end

local function finishSitePass(siteState, context, groundContext)
  if state.failed or siteState.passed then return end

  siteState.finalAmmo = ammoTotal(siteState)
  local resourceAfter = groundContext.store:GetResource(siteState.spec.nodeId, RESOURCE_ID)
  local transaction = groundContext.store:GetTransaction(siteState.transactionId)
  local activeSupportGroup = siteState.service:GetSupport():GetMaterializedGroup()
  local returnedGroup = context.supportGroup

  if activeSupportGroup ~= nil then
    fail("SUPPORT_GROUP_STILL_MATERIALIZED site=" .. siteState.spec.id)
    return
  end
  if returnedGroup and type(returnedGroup.IsAlive) == "function" and returnedGroup:IsAlive() == true then
    fail("SUPPORT_GROUP_STILL_ALIVE_AFTER_RETURN site=" .. siteState.spec.id)
    return
  end
  if context.status ~= "RETURNED_TO_STOCK" then
    fail("CONTEXT_STATUS site=" .. siteState.spec.id .. " expected=RETURNED_TO_STOCK actual=" .. tostring(context.status))
    return
  end
  if not transaction or transaction.status ~= "CONSUMED" then
    fail("TRANSACTION_STATUS site=" .. siteState.spec.id .. " expected=CONSUMED actual=" .. tostring(transaction and transaction.status))
    return
  end
  if not resourceAfter or not siteState.resourceBefore then
    fail("RESOURCE_UNAVAILABLE site=" .. siteState.spec.id)
    return
  end
  if resourceAfter.available ~= siteState.resourceBefore.available - 1 then
    fail("RESOURCE_DEBIT site=" .. siteState.spec.id .. " expected=" .. tostring(siteState.resourceBefore.available - 1) .. " actual=" .. tostring(resourceAfter.available))
    return
  end
  if siteState.postFireAmmo == nil or not siteState.initialAmmo or siteState.postFireAmmo >= siteState.initialAmmo then
    fail("AMMO_DID_NOT_DECREASE site=" .. siteState.spec.id .. " initial=" .. tostring(siteState.initialAmmo) .. " postFire=" .. tostring(siteState.postFireAmmo))
    return
  end
  if not siteState.finalAmmo or siteState.finalAmmo < siteState.initialAmmo then
    fail("AMMO_NOT_RESTORED site=" .. siteState.spec.id .. " initial=" .. tostring(siteState.initialAmmo) .. " final=" .. tostring(siteState.finalAmmo))
    return
  end

  siteState.passed = true
  log("SITE_SUPPORT_RETURNED site=" .. siteState.spec.id
    .. " template=" .. tostring(siteState.spec.supportTemplate)
    .. " name=" .. tostring(siteState.supportName)
    .. " type=" .. tostring(siteState.supportType)
    .. " returnDistanceM=" .. tostring(context.supportReturnDistanceM))
  log("SITE_PASS site=" .. siteState.spec.id)
  finishAggregateIfReady()
end

local function configureSite(spec, groundContext)
  local batteryGroup = requireObject(GROUP:FindByName(spec.battery), spec.battery)
  local supportSpawnZone = requireObject(ZONE:FindByName(spec.supportSpawnZone), spec.supportSpawnZone)
  local targetZone = requireObject(ZONE:FindByName(spec.targetZone), spec.targetZone)
  local warehouseHost = UNIT:FindByName(spec.warehouse)
  if not warehouseHost then warehouseHost = STATIC:FindByName(spec.warehouse, false) end
  requireObject(warehouseHost, spec.warehouse)
  requireObject(GROUP:FindByName(spec.supportTemplate), spec.supportTemplate)
  if state.failed then return nil end

  local brigade = BRIGADE:New(spec.warehouse, spec.brigade)
  if not requireObject(brigade, spec.brigade) then return nil end

  local arty = ARTY:New(batteryGroup, spec.alias)
  if not requireObject(arty, "ARTY " .. spec.battery) then return nil end
  arty:SetReportOFF()
  arty:SetWaitForShotTime(120)

  local siteState = {
    spec = spec,
    batteryGroup = batteryGroup,
    supportSpawnZone = supportSpawnZone,
    targetZone = targetZone,
    brigade = brigade,
    arty = arty,
    transactionId = "GROUND-FIRE-SUPPORT-ACCEPTANCE-2-" .. spec.id,
    fireComplete = false,
    rearmed = false,
    passed = false,
    initialAmmo = nil,
    postFireAmmo = nil,
    finalAmmo = nil,
    resourceBefore = nil,
    supportName = nil,
    supportType = nil,
  }

  siteState.service = FixedFireSupportAmmoRearmService.New({
    fixedFireSupportAmmoSupportModule = FixedFireSupportAmmoSupport,
    groundAmmoRearmAdapterModule = GroundAmmoRearmAdapter,
    store = groundContext.store,
    campaignState = groundContext.campaignState,
    artyFactory = function(group, alias)
      if group ~= batteryGroup then
        error(TAG .. " ARTY factory received unexpected battery group site=" .. spec.id, 2)
      end
      return arty
    end,
    brigade = brigade,
    spawnZone = supportSpawnZone,
    spawnZoneMaxDistanceM = 500,
    materializerModule = GroundSupportMaterializer,
    platoonFactory = function(templateName, count, platoonName)
      return PLATOON:New(templateName, count, platoonName)
    end,
    descriptorGroupName = WAREHOUSE.Descriptor.GROUPNAME,
    templateName = spec.supportTemplate,
    platoonName = spec.platoon,
    assignment = spec.assignment,
    carrierEntityId = spec.carrierEntityId,
    nodeId = spec.nodeId,
    alias = spec.alias,
    stockCount = 1,
    priority = 20,
    returnCheckIntervalSec = 5,
    returnTimeoutSec = 300,
    log = function(level, message)
      log("SITE_LOG site=" .. spec.id .. " level=" .. tostring(level) .. " " .. tostring(message))
    end,
    onRearmed = function(context)
      siteState.rearmed = true
      local supportGroup = context.supportGroup
      if supportGroup then
        siteState.supportName = supportGroup:GetName()
        siteState.supportType = supportGroup:GetTypeName()
      end
      local resourceAfter = groundContext.store:GetResource(spec.nodeId, RESOURCE_ID)
      log("SITE_SUPPORT_MATERIALIZED site=" .. spec.id
        .. " template=" .. tostring(spec.supportTemplate)
        .. " name=" .. tostring(siteState.supportName)
        .. " type=" .. tostring(siteState.supportType))
      log("SITE_CONSUMPTION_COMMITTED site=" .. spec.id .. " resource=" .. RESOURCE_ID .. " before=" .. tostring(siteState.resourceBefore and siteState.resourceBefore.available) .. " after=" .. tostring(resourceAfter and resourceAfter.available))
      log("SITE_REARMED site=" .. spec.id .. " initialAmmo=" .. tostring(siteState.initialAmmo) .. " postFireAmmo=" .. tostring(siteState.postFireAmmo) .. " currentAmmo=" .. tostring(ammoTotal(siteState)))
    end,
    onSupportReturned = function(context)
      SCHEDULER:New(nil, function()
        finishSitePass(siteState, context, groundContext)
      end, {}, 2)
    end,
    onSupportReturnFailed = function(_, reason)
      fail("SUPPORT_RETURN_FAILED site=" .. spec.id .. " reason=" .. tostring(reason))
    end,
  })

  state.sites[spec.id] = siteState
  return siteState
end

local function startSite(siteState, groundContext)
  siteState.brigade:Start()

  siteState.arty.OnAfterCeaseFire = function(_, Controllable, From, Event, To, target)
    if state.failed or siteState.passed or siteState.fireComplete then return end
    siteState.fireComplete = true
    siteState.postFireAmmo = ammoTotal(siteState)
    log("SITE_FIRE_COMPLETE site=" .. siteState.spec.id .. " target=" .. tostring(target and target.name) .. " initialAmmo=" .. tostring(siteState.initialAmmo) .. " postFire=" .. tostring(siteState.postFireAmmo))

    if not siteState.initialAmmo or siteState.postFireAmmo >= siteState.initialAmmo then
      fail("FIRE_DID_NOT_CONSUME_AMMO site=" .. siteState.spec.id)
      return
    end

    siteState.resourceBefore = groundContext.store:GetResource(siteState.spec.nodeId, RESOURCE_ID)
    if not siteState.resourceBefore then
      fail("RESOURCE_BEFORE_UNAVAILABLE site=" .. siteState.spec.id)
      return
    end

    local context = siteState.service:Request({
      transactionId = siteState.transactionId,
      nodeId = siteState.spec.nodeId,
      resourceId = RESOURCE_ID,
      quantity = 1,
      artilleryGroup = siteState.batteryGroup,
      alias = siteState.spec.alias,
      onRoad = false,
      rearmingDistance = 100,
      supportReturnRadiusM = 100,
      startArty = false,
    })
    log("SITE_REARM_REQUEST site=" .. siteState.spec.id
      .. " supportTemplate=" .. tostring(siteState.spec.supportTemplate)
      .. " status=" .. tostring(context and context.status)
      .. " resourceBefore=" .. tostring(siteState.resourceBefore.available))
  end

  local targetName = siteState.arty:AssignTargetCoord(
    siteState.targetZone:GetCoordinate(), 10, 50, siteState.spec.fireShells, 1, nil,
    ARTY.WeaponType.Auto,
    "OMW-FIRE-SUPPORT-ACCEPTANCE-2-" .. siteState.spec.id,
    true
  )
  if not targetName then
    fail("ARTY_TARGET_ASSIGNMENT_REJECTED site=" .. siteState.spec.id)
    return
  end

  siteState.arty:Start()
  siteState.initialAmmo = ammoTotal(siteState)
  if not siteState.initialAmmo or siteState.initialAmmo <= 0 then
    fail("INITIAL_AMMO_INVALID site=" .. siteState.spec.id .. " value=" .. tostring(siteState.initialAmmo))
    return
  end

  log("SITE_START site=" .. siteState.spec.id
    .. " battery=" .. siteState.spec.battery
    .. " supportTemplate=" .. siteState.spec.supportTemplate
    .. " supportSpawnZone=" .. siteState.spec.supportSpawnZone
    .. " target=" .. tostring(targetName)
    .. " shellsRequested=" .. tostring(siteState.spec.fireShells)
    .. " initialAmmo=" .. tostring(siteState.initialAmmo))
end

local function startAcceptance()
  if OMW_GROUND_READY ~= 1 then
    fail("GROUND_BASE_NOT_READY flag=" .. tostring(OMW_GROUND_READY))
    return
  end
  if type(OMW) ~= "table" or type(OMW.Ground) ~= "table"
      or type(OMW.Ground.Base) ~= "table"
      or type(OMW.Ground.Base.GetContext) ~= "function" then
    fail("GROUND_BASE_CONTEXT_UNAVAILABLE")
    return
  end

  local groundContext = OMW.Ground.Base.GetContext()
  if type(groundContext) ~= "table" or type(groundContext.store) ~= "table"
      or type(groundContext.campaignState) ~= "table" then
    fail("AUTHORITATIVE_CAMPAIGN_CONTEXT_UNAVAILABLE")
    return
  end

  for _, spec in ipairs(SITE_SPECS) do configureSite(spec, groundContext) end
  if state.failed then return end

  for _, spec in ipairs(SITE_SPECS) do
    startSite(state.sites[spec.id], groundContext)
    if state.failed then return end
  end

  SCHEDULER:New(nil, function()
    if state.failed or state.passed then return end
    local status = {}
    for _, spec in ipairs(SITE_SPECS) do
      local siteState = state.sites[spec.id]
      status[#status + 1] = spec.id
        .. "=passed:" .. tostring(siteState and siteState.passed)
        .. "/rearmed:" .. tostring(siteState and siteState.rearmed)
        .. "/postFireAmmo:" .. tostring(siteState and siteState.postFireAmmo)
    end
    fail("TIMEOUT seconds=" .. tostring(TIMEOUT_SEC) .. " sites=" .. table.concat(status, ","))
  end, {}, TIMEOUT_SEC)
end

SCHEDULER:New(nil, startAcceptance, {}, 5)
