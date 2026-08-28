-- Operation Mountain Watch - bundled Bostick M1083 / L118 ammunition rearm acceptance.
-- Test-ID: GROUND-AMMO-REARM-ACCEPTANCE-1
--
-- Preconditions in the owner-provided mission:
--   WH_BLUE_GND_BOSTICK
--   ZON_BLUE_GND_BOSTICK_ACCESS
--   ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
--   TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2 (mission-start present)
--   TPL_BLUE_GND_SUP_M1083 (late-activated stock template)
--   OMW_GROUND_READY == 1 and OMW.Ground.Base attached to the authoritative store.

local TEST_ID = "GROUND-AMMO-REARM-ACCEPTANCE-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local WAREHOUSE_NAME = "WH_BLUE_GND_BOSTICK"
local BRIGADE_NAME = "BDE_BLUE_GND_BOSTICK_AMMO_ACCEPTANCE"
local BATTERY_NAME = "TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2"
local SUPPORT_TEMPLATE = "TPL_BLUE_GND_SUP_M1083"
local ACCESS_ZONE_NAME = "ZON_BLUE_GND_BOSTICK_ACCESS"
local TARGET_ZONE_NAME = "ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET"
local TRANSACTION_ID = "GROUND-REARM-BOSTICK-ACCEPTANCE-001"
local RESOURCE_ID = "GROUND_AMMO_PACKAGE"
local NODE_ID = "GROUND_NODE_BOSTICK"
local FIRE_SHELLS = 4
local TIMEOUT_SEC = 600

local state = {
  failed = false,
  passed = false,
  fireComplete = false,
  initialAmmo = nil,
  postFireAmmo = nil,
  finalAmmo = nil,
  resourceBefore = nil,
  service = nil,
  arty = nil,
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(reason)
  if state.failed or state.passed then
    return
  end
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

local function ammoTotal(arty)
  local total, shells, rockets, missiles, artilleryShells = arty:GetAmmo(false)
  log("AMMO total=" .. tostring(total)
    .. " shells=" .. tostring(shells)
    .. " rockets=" .. tostring(rockets)
    .. " missiles=" .. tostring(missiles)
    .. " artilleryShells=" .. tostring(artilleryShells))
  return total
end

local function finishPass(context)
  if state.failed or state.passed then
    return
  end

  state.finalAmmo = ammoTotal(context.arty)
  local resourceAfter = context and context.nodeId and context.resourceId
    and OMW.Ground.Base.GetContext().store:GetResource(context.nodeId, context.resourceId)
    or nil
  local transaction = OMW.Ground.Base.GetContext().store:GetTransaction(TRANSACTION_ID)
  local supportGroup = state.service:GetSupport():GetMaterializedGroup()

  if not supportGroup or not supportGroup:IsAlive() then
    fail("SUPPORT_GROUP_NOT_ALIVE")
    return
  end
  if context.status ~= "REARMED" then
    fail("CONTEXT_STATUS expected=REARMED actual=" .. tostring(context.status))
    return
  end
  if not transaction or transaction.status ~= "CONSUMED" then
    fail("TRANSACTION_STATUS expected=CONSUMED actual=" .. tostring(transaction and transaction.status))
    return
  end
  if not resourceAfter then
    fail("RESOURCE_AFTER_UNAVAILABLE")
    return
  end
  if resourceAfter.available ~= state.resourceBefore.available - 1 then
    fail("RESOURCE_DEBIT expected=" .. tostring(state.resourceBefore.available - 1)
      .. " actual=" .. tostring(resourceAfter.available))
    return
  end
  if not state.postFireAmmo or not state.initialAmmo or state.postFireAmmo >= state.initialAmmo then
    fail("AMMO_DID_NOT_DECREASE initial=" .. tostring(state.initialAmmo)
      .. " postFire=" .. tostring(state.postFireAmmo))
    return
  end
  if not state.finalAmmo or state.finalAmmo < state.initialAmmo then
    fail("AMMO_NOT_RESTORED initial=" .. tostring(state.initialAmmo)
      .. " final=" .. tostring(state.finalAmmo))
    return
  end

  state.passed = true
  log("SUPPORT_MATERIALIZED name=" .. tostring(supportGroup:GetName())
    .. " type=" .. tostring(supportGroup:GetTypeName()))
  log("CONSUMPTION_COMMITTED resource=" .. RESOURCE_ID
    .. " before=" .. tostring(state.resourceBefore.available)
    .. " after=" .. tostring(resourceAfter.available))
  log("REARMED initialAmmo=" .. tostring(state.initialAmmo)
    .. " postFireAmmo=" .. tostring(state.postFireAmmo)
    .. " finalAmmo=" .. tostring(state.finalAmmo))
  log("PASS M1083_REARM_CONFIRMED=true")
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

  local batteryGroup = requireObject(GROUP:FindByName(BATTERY_NAME), BATTERY_NAME)
  local accessZone = requireObject(ZONE:FindByName(ACCESS_ZONE_NAME), ACCESS_ZONE_NAME)
  local targetZone = requireObject(ZONE:FindByName(TARGET_ZONE_NAME), TARGET_ZONE_NAME)
  local warehouseHost = UNIT:FindByName(WAREHOUSE_NAME)
  if not warehouseHost then
    warehouseHost = STATIC:FindByName(WAREHOUSE_NAME, false)
  end
  requireObject(warehouseHost, WAREHOUSE_NAME)
  requireObject(GROUP:FindByName(SUPPORT_TEMPLATE), SUPPORT_TEMPLATE)
  if state.failed then
    return
  end

  local brigade = BRIGADE:New(WAREHOUSE_NAME, BRIGADE_NAME)
  if not requireObject(brigade, BRIGADE_NAME) then
    return
  end
  brigade:SetSpawnZone(accessZone, 1000)

  local arty = ARTY:New(batteryGroup, "Bostick L118 Acceptance")
  if not requireObject(arty, "ARTY " .. BATTERY_NAME) then
    return
  end
  arty:SetReportOFF()
  arty:SetWaitForShotTime(120)
  state.arty = arty

  state.service = BostickAmmoRearmService.New({
    brigade = brigade,
    accessZone = accessZone,
    forwardCoordinate = batteryGroup:GetCoordinate(),
    roadSpawnAdapter = GroundRoadSpawnAdapter,
    materializerModule = GroundSupportMaterializer,
    bostickAmmoSupportModule = BostickAmmoSupport,
    groundAmmoRearmAdapterModule = GroundAmmoRearmAdapter,
    store = groundContext.store,
    campaignState = groundContext.campaignState,
    descriptorGroupName = WAREHOUSE.Descriptor.GROUPNAME,
    platoonFactory = function(templateName, count, platoonName)
      return PLATOON:New(templateName, count, platoonName)
    end,
    artyFactory = function(group, alias)
      if group ~= batteryGroup then
        error(TAG .. " ARTY factory received unexpected battery group", 2)
      end
      return arty
    end,
    log = function(level, message)
      log(tostring(level) .. " " .. tostring(message))
    end,
    onRearmed = function(context)
      finishPass(context)
    end,
  })

  brigade:Start()

  arty.OnAfterCeaseFire = function(_, Controllable, From, Event, To, target)
    if state.failed or state.passed or state.fireComplete then
      return
    end
    state.fireComplete = true
    state.postFireAmmo = ammoTotal(arty)
    log("FIRE_COMPLETE target=" .. tostring(target and target.name)
      .. " initialAmmo=" .. tostring(state.initialAmmo)
      .. " postFireAmmo=" .. tostring(state.postFireAmmo))

    if not state.initialAmmo or state.postFireAmmo >= state.initialAmmo then
      fail("FIRE_DID_NOT_CONSUME_AMMO")
      return
    end

    state.resourceBefore = groundContext.store:GetResource(NODE_ID, RESOURCE_ID)
    local waiting = state.service:Request({
      transactionId = TRANSACTION_ID,
      nodeId = NODE_ID,
      resourceId = RESOURCE_ID,
      quantity = 1,
      artilleryGroup = batteryGroup,
      alias = "Bostick L118 Acceptance",
      onRoad = true,
      startArty = false,
    })
    log("REARM_REQUEST status=" .. tostring(waiting and waiting.status)
      .. " resourceBefore=" .. tostring(state.resourceBefore.available))
  end

  local targetName = arty:AssignTargetCoord(
    targetZone:GetCoordinate(),
    10,
    50,
    FIRE_SHELLS,
    1,
    nil,
    ARTY.WeaponType.Auto,
    "OMW-BOSTICK-AMMO-ACCEPTANCE-TARGET",
    true
  )
  if not targetName then
    fail("ARTY_TARGET_ASSIGNMENT_REJECTED")
    return
  end

  arty:Start()
  state.initialAmmo = ammoTotal(arty)
  if not state.initialAmmo or state.initialAmmo <= 0 then
    fail("INITIAL_AMMO_INVALID value=" .. tostring(state.initialAmmo))
    return
  end

  log("START target=" .. tostring(targetName)
    .. " shellsRequested=" .. tostring(FIRE_SHELLS)
    .. " initialAmmo=" .. tostring(state.initialAmmo))

  SCHEDULER:New(nil, function()
    if not state.failed and not state.passed then
      fail("TIMEOUT seconds=" .. tostring(TIMEOUT_SEC)
        .. " fireComplete=" .. tostring(state.fireComplete)
        .. " contextStatus=" .. tostring(state.service and state.service:Get(TRANSACTION_ID)
          and state.service:Get(TRANSACTION_ID).status))
    end
  end, {}, TIMEOUT_SEC)
end

startAcceptance()
