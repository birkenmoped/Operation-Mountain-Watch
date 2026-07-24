-- Operation Mountain Watch - Final OH-58D two-ship runtime registration and route activation
local TAG = "[OMW][AirOps.JBAD.PH1.OH58FINAL]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local controller = ph1 and ph1.Controller
local observer = ph1 and ph1.Observer
local handler = ph1 and ph1.EventHandler

if not cfg or not ph1 or not controller or not observer or not handler then
  log("ERROR: Phase 1 runtime components unavailable.")
else
  local function startsWith(value, prefix)
    return value and prefix and string.sub(value, 1, #prefix) == prefix
  end

  local function getGroupName(eventData)
    if eventData.IniGroupName then return eventData.IniGroupName end
    if eventData.IniGroup and eventData.IniGroup.GetName then
      local ok, value = pcall(function() return eventData.IniGroup:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
  end

  local function populateExpectedUnits(groupName)
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition or not groupName then return false end
    if not startsWith(groupName, definition.ExpectedGroupPrefix) then return false end

    runtime.ExpectedGroupNames = runtime.ExpectedGroupNames or {}
    runtime.ExpectedUnitNames = runtime.ExpectedUnitNames or {}
    if not runtime.ExpectedGroupNames[groupName] then
      if countKeys(runtime.ExpectedGroupNames) >= definition.ExpectedGroups then return false end
      runtime.ExpectedGroupNames[groupName] = true
    end
    for _, suffix in ipairs(definition.ExpectedUnitSuffixes or { definition.ExpectedUnitSuffix or "-01" }) do
      runtime.ExpectedUnitNames[groupName .. suffix] = groupName
    end
    return true
  end

  local previousRefreshMissionGroups = observer.RefreshMissionGroups
  function observer:RefreshMissionGroups()
    local found = previousRefreshMissionGroups(self)
    if ph1.ActiveTestId == "OH58D_RECON" and ph1.Runtime then
      for groupName in pairs(ph1.Runtime.ExpectedGroupNames or {}) do populateExpectedUnits(groupName) end
    end
    return found
  end

  local previousBirth = handler.OnEventBirth
  function handler:OnEventBirth(eventData)
    if ph1.ActiveTestId == "OH58D_RECON" and ph1.ActiveDefinition then
      populateExpectedUnits(getGroupName(eventData))
    end
    return previousBirth(self, eventData)
  end

  -- The final event handler already increments groupsSpawned exactly once when
  -- a new exact runtime group is first observed. Do not increment it again here.
  function controller:OnExpectedBirth(groupName, unitName, typeName)
    local definition = ph1.ActiveDefinition
    local runtime = ph1.Runtime
    if not definition or not runtime then return end
    if typeName ~= definition.ExpectedType then
      runtime.HardFailure = "wrong-aircraft-type-" .. tostring(typeName)
      log("ERROR WRONG_TYPE expected=" .. tostring(definition.ExpectedType) .. " actual=" .. tostring(typeName))
    end

    if definition.AbortOnBirth and not runtime.AbortScheduled then
      runtime.AbortScheduled = true
      local delay = ph1.Limits.AbortDelayAfterBirthSeconds
      log("ABORT_SCHEDULED testId=" .. tostring(ph1.ActiveTestId) .. " delay=" .. tostring(delay) .. "s")
      SCHEDULER:New(nil, function()
        if ph1.ActiveTestId == definition.Id and ph1.ActiveMission then
          controller:AbortActive("defined-abort-after-birth")
        end
      end, {}, delay)
    end
  end

  local function pushRecoveryRoute(mission, attempt)
    local runtime = ph1.Runtime
    if ph1.ActiveMission ~= mission or ph1.ActiveTestId ~= "OH58D_RECON" or not runtime then return end
    if not runtime.RecoveryCorridorApplied then
      if (attempt or 1) < 30 then
        SCHEDULER:New(nil, function() pushRecoveryRoute(mission, (attempt or 1) + 1) end, {}, 2)
      end
      return
    end
    if runtime.RecoveryRoutePushed then return end

    local ok, groups = pcall(function() return mission:GetOpsGroups() end)
    local updated = 0
    if ok then
      for _, opsgroup in pairs(groups or {}) do
        if opsgroup.UpdateRoute then
          local updateOK = pcall(function() opsgroup:UpdateRoute() end)
          if updateOK then updated = updated + 1 end
        end
      end
    end
    if updated >= (ph1.ActiveDefinition and ph1.ActiveDefinition.ExpectedGroups or 1) then
      runtime.RecoveryRoutePushed = true
      log("RECOVERY_ROUTE_PUSHED groups=" .. tostring(updated) .. " route=RECON_03->RECON_02->RECON_01->Jalalabad")
    elseif (attempt or 1) < 30 then
      SCHEDULER:New(nil, function() pushRecoveryRoute(mission, (attempt or 1) + 1) end, {}, 2)
    else
      runtime.HardFailure = "recovery-route-update-failed"
      log("ERROR RECOVERY_ROUTE_UPDATE_FAILED updated=" .. tostring(updated))
    end
  end

  local previousOnMissionState = controller.OnMissionState
  function controller:OnMissionState(state, mission, from, event, to)
    local result = previousOnMissionState(self, state, mission, from, event, to)
    if mission == ph1.ActiveMission and ph1.ActiveTestId == "OH58D_RECON" and (state == "SCHEDULED" or state == "STARTED") then
      SCHEDULER:New(nil, function() pushRecoveryRoute(mission, 1) end, {}, 2)
    end
    return result
  end

  log("READY exactTwoShipUnitsRegistered=true duplicateGroupCounterRemoved=true explicitRecoveryRouteUpdate=true")
end
