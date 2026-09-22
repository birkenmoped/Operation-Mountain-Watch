-- Operation Mountain Watch - MOOSE-selected Functional ARTY handoff runtime.
--
-- C2/OMW provides a qualified ARTY demand and target geometry. MOOSE COMMANDER
-- remains the operational selection authority through CanMission() and
-- RecruitAssetsForMission(). The resulting AUFTRAG is selection-only: it is never
-- queued with COMMANDER:AddMission() and never becomes a FireAtPoint owner.
--
-- The selected MOOSE asset is mapped to the already-running, caller-owned
-- Functional ARTY instance for that exact battery. That ARTY instance remains the
-- sole fire-control owner and therefore remains compatible with the accepted
-- M1083/CampaignState rearm lifecycle.
--
-- Selection reservations are held only for the duration of the selected fire
-- mission and are released through MOOSE LEGION.UnRecruitAssets().

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-RUNTIME-1"

local TAG = "[OMW][FireSupStratResupply.ArtySelectionRuntime]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function needTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end

local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then
    fail(label .. "." .. name .. "() is required")
  end
  return container[name]
end

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function selectedLegion(legions)
  local selected = nil
  local count = 0
  for _, legion in pairs(legions or {}) do
    selected = legion
    count = count + 1
  end
  if count ~= 1 then
    return nil, "EXPECTED_ONE_SELECTED_LEGION actual=" .. tostring(count)
  end
  return selected, nil
end

local function defaultReleaseAssets(assets)
  if type(LEGION) ~= "table" or type(LEGION.UnRecruitAssets) ~= "function" then
    fail("MOOSE LEGION.UnRecruitAssets() is required")
  end
  LEGION.UnRecruitAssets(assets)
end

function Runtime.New(spec)
  needTable(spec, "spec")
  local commander = needTable(spec.commander, "commander")
  local artyMissionFactory = needTable(spec.artyMissionFactory, "artyMissionFactory")
  needFunction(commander, "CanMission", "commander")
  needFunction(commander, "RecruitAssetsForMission", "commander")
  needFunction(artyMissionFactory, "Create", "artyMissionFactory")
  if type(spec.resolveFunctionalArty) ~= "function" then
    fail("resolveFunctionalArty must be a function")
  end
  if spec.releaseAssets ~= nil and type(spec.releaseAssets) ~= "function" then
    fail("releaseAssets must be a function when provided")
  end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then
    fail("logger must be a function when provided")
  end
  local defaultPriority = spec.defaultPriority or 10
  local defaultMaxEngagements = spec.defaultMaxEngagements or 1
  if not finite(defaultPriority) or defaultPriority < 1 or defaultPriority > 100 then
    fail("defaultPriority must be finite in range 1..100")
  end
  if not finite(defaultMaxEngagements) or defaultMaxEngagements < 1 then
    fail("defaultMaxEngagements must be at least one")
  end

  return setmetatable({
    commander = commander,
    artyMissionFactory = artyMissionFactory,
    resolveFunctionalArty = spec.resolveFunctionalArty,
    releaseAssets = spec.releaseAssets or defaultReleaseAssets,
    defaultPriority = defaultPriority,
    defaultMaxEngagements = defaultMaxEngagements,
    logger = spec.logger,
    entries = {},
    entriesByTargetName = {},
    artyHooks = {},
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:_release(entry, reason)
  if entry.released then return false end
  self.releaseAssets({ entry.asset })
  entry.released = true
  entry.releaseReason = reason
  self:_log(string.format(
    "selection released demandId=%s provider=%s asset=%s reason=%s",
    tostring(entry.demand.demandId),
    tostring(entry.legion and (entry.legion.alias or entry.legion.name)),
    tostring(entry.asset and entry.asset.spawngroupname),
    tostring(reason)))
  return true
end

function Instance:_installArtyHooks(arty)
  if self.artyHooks[arty] then return end
  self.artyHooks[arty] = true

  local runtime = self

  local previousOpenFire = arty.OnAfterOpenFire
  arty.OnAfterOpenFire = function(selfArty, Controllable, From, Event, To, target)
    if previousOpenFire then
      previousOpenFire(selfArty, Controllable, From, Event, To, target)
    end
    local targetName = target and target.name or nil
    local entry = targetName and runtime.entriesByTargetName[targetName] or nil
    if not entry then return end
    entry.started = true
    runtime:_log(string.format(
      "functional ARTY fire started demandId=%s target=%s",
      tostring(entry.demand.demandId), tostring(targetName)))
  end

  local previousCeaseFire = arty.OnAfterCeaseFire
  arty.OnAfterCeaseFire = function(selfArty, Controllable, From, Event, To, target)
    if previousCeaseFire then
      previousCeaseFire(selfArty, Controllable, From, Event, To, target)
    end
    local targetName = target and target.name or nil
    local entry = targetName and runtime.entriesByTargetName[targetName] or nil
    if not entry then return end
    entry.completed = true
    entry.completedReason = entry.cancelRequested and "CANCELLED_AFTER_FIRE_START" or "CEASE_FIRE"
    runtime:_release(entry, entry.completedReason)
    runtime:_log(string.format(
      "functional ARTY fire complete demandId=%s target=%s cancelled=%s",
      tostring(entry.demand.demandId), tostring(targetName), tostring(entry.cancelRequested == true)))
  end

  local previousDead = arty.OnAfterDead
  arty.OnAfterDead = function(selfArty, Controllable, From, Event, To, Unitname)
    if previousDead then
      previousDead(selfArty, Controllable, From, Event, To, Unitname)
    end
    for _, entry in pairs(runtime.entries) do
      if entry.arty == selfArty and not entry.released then
        entry.failed = true
        entry.failureReason = "FUNCTIONAL_ARTY_DEAD"
        runtime:_release(entry, entry.failureReason)
      end
    end
  end
end

function Instance:_resolveOwner(asset, legion, demand, context, selectionMission)
  local ok, owner, reason = pcall(
    self.resolveFunctionalArty,
    asset,
    legion,
    demand,
    context,
    selectionMission
  )
  if not ok then
    return nil, "FUNCTIONAL_ARTY_OWNER_RESOLVE_ERROR " .. tostring(owner)
  end
  if owner == nil then
    return nil, reason or "SELECTED_ARTY_OWNER_UNAVAILABLE"
  end
  needTable(owner, "functional ARTY owner")
  local arty = needTable(owner.arty, "functional ARTY owner.arty")
  needFunction(arty, "AssignTargetCoord", "functional ARTY owner.arty")
  needFunction(arty, "RemoveTarget", "functional ARTY owner.arty")

  if owner.priority ~= nil and (not finite(owner.priority) or owner.priority < 1 or owner.priority > 100) then
    fail("functional ARTY owner.priority must be finite in range 1..100")
  end
  if owner.maxEngagements ~= nil and (not finite(owner.maxEngagements) or owner.maxEngagements < 1) then
    fail("functional ARTY owner.maxEngagements must be at least one")
  end
  if owner.acceptedShots ~= nil and (not finite(owner.acceptedShots) or owner.acceptedShots <= 0) then
    fail("functional ARTY owner.acceptedShots must be positive when provided")
  end
  if owner.acceptedRadiusM ~= nil and (not finite(owner.acceptedRadiusM) or owner.acceptedRadiusM <= 0) then
    fail("functional ARTY owner.acceptedRadiusM must be positive when provided")
  end

  return owner, nil
end

function Instance:Dispatch(demand, context)
  needTable(demand, "demand")
  if demand.supportType ~= "ARTY" then fail("supportType ARTY is required") end
  if type(demand.demandId) ~= "string" or demand.demandId == "" then
    fail("demand.demandId is required")
  end
  if self.entries[demand.demandId] then
    return self.entries[demand.demandId].handle, false, "ALREADY_DISPATCHED"
  end

  local selectionMission, created, createReason = self.artyMissionFactory:Create(demand, context)
  if not selectionMission then return nil, created, createReason end

  local target = selectionMission._omwFssrArtyTarget
  if type(target) ~= "table" or type(target.coordinate) ~= "table" then
    fail("selection mission requires _omwFssrArtyTarget.coordinate")
  end
  if target.altitudeM ~= nil then
    return nil, false, "FUNCTIONAL_ARTY_ALTITUDE_UNSUPPORTED"
  end

  if self.commander:CanMission(selectionMission) ~= true then
    return nil, false, "NO_CAPABLE_ARTY_PROVIDER"
  end

  local recruited, assets, legions = self.commander:RecruitAssetsForMission(selectionMission)
  if recruited ~= true then
    return nil, false, "NO_AVAILABLE_ARTY_PROVIDER"
  end
  assets = assets or {}
  if #assets ~= 1 then
    if #assets > 0 then self.releaseAssets(assets) end
    return nil, false, "ARTY_SELECTION_CARDINALITY_INVALID actual=" .. tostring(#assets)
  end

  local legion, legionReason = selectedLegion(legions)
  if not legion then
    self.releaseAssets(assets)
    return nil, false, "ARTY_SELECTED_LEGION_INVALID " .. tostring(legionReason)
  end

  local asset = assets[1]
  local ownerOk, owner, ownerReason = pcall(
    self._resolveOwner,
    self,
    asset,
    legion,
    demand,
    context,
    selectionMission
  )
  if not ownerOk then
    self.releaseAssets(assets)
    fail("functional ARTY owner validation failed after MOOSE selection: " .. tostring(owner))
  end
  if not owner then
    self.releaseAssets(assets)
    return nil, false, ownerReason
  end

  local arty = owner.arty
  self:_installArtyHooks(arty)

  local targetAlias = "OMW|FSSR|ARTY|" .. demand.demandId
  local assigned, targetName = pcall(
    arty.AssignTargetCoord,
    arty,
    target.coordinate,
    owner.priority or self.defaultPriority,
    owner.acceptedRadiusM or target.radiusM,
    owner.acceptedShots or target.shots,
    owner.maxEngagements or self.defaultMaxEngagements,
    nil,
    owner.weaponType,
    targetAlias,
    true
  )
  if not assigned then
    self.releaseAssets(assets)
    fail("Functional ARTY target assignment failed after MOOSE selection: " .. tostring(targetName))
  end
  if not targetName then
    self.releaseAssets(assets)
    return nil, false, "FUNCTIONAL_ARTY_TARGET_REJECTED"
  end

  local entry = {
    demand = demand,
    context = context,
    selectionMission = selectionMission,
    asset = asset,
    legion = legion,
    owner = owner,
    arty = arty,
    target = target,
    targetName = targetName,
    started = false,
    completed = false,
    failed = false,
    released = false,
    cancelRequested = false,
  }

  local runtime = self
  local handle = { entry = entry }
  function handle:Cancel(reason)
    if entry.completed or entry.released then return false end
    if entry.cancelRequested then return false end
    entry.cancelRequested = true
    entry.cancelReason = tostring(reason or "UNSPECIFIED")
    entry.arty:RemoveTarget(entry.targetName)
    if not entry.started then
      entry.completed = true
      entry.completedReason = "CANCELLED_BEFORE_FIRE_START"
      runtime:_release(entry, entry.completedReason)
    end
    return true
  end

  entry.handle = handle
  self.entries[demand.demandId] = entry
  self.entriesByTargetName[targetName] = entry

  self:_log(string.format(
    "MOOSE-selected Functional ARTY handoff demandId=%s provider=%s asset=%s target=%s shots=%s radiusM=%s",
    tostring(demand.demandId),
    tostring(legion.alias or legion.name),
    tostring(asset.spawngroupname),
    tostring(targetName),
    tostring(owner.acceptedShots or target.shots),
    tostring(owner.acceptedRadiusM or target.radiusM)))

  return handle, true, nil
end

function Instance:GetState(demandId)
  if type(demandId) ~= "string" or demandId == "" then fail("demandId is required") end
  return self.entries[demandId]
end

return Runtime
