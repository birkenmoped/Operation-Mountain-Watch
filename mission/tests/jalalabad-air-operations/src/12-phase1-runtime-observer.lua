-- Operation Mountain Watch - Jalalabad AIRWING Phase 1 runtime observer
-- Exact runtime identity is derived from the active package contract. A physical
-- two-ship is one DCS group with the exact unit names <group>-01 and <group>-02.
local TAG = "[OMW][AirOps.JBAD.PH1.OBS]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 then
  log("ERROR: Phase 1 manifest unavailable.")
else
  local observer = ph1.Observer or {}
  ph1.Observer = observer

  local managedTypes = { OH58D = true, ["AH-64D_BLK_II"] = true, ["UH-60A"] = true, ["CH-47Fbl1"] = true }

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
  end

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx = (a.x or 0) - (b.x or 0)
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

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

  local function getUnitName(eventData)
    if eventData.IniUnitName then return eventData.IniUnitName end
    if eventData.IniUnit and eventData.IniUnit.GetName then
      local ok, value = pcall(function() return eventData.IniUnit:GetName() end)
      if ok then return value end
    end
    return nil
  end

  local function getTypeName(eventData)
    if eventData.IniTypeName then return eventData.IniTypeName end
    if eventData.IniUnit and eventData.IniUnit.GetTypeName then
      local ok, value = pcall(function() return eventData.IniUnit:GetTypeName() end)
      if ok then return value end
    end
    return nil
  end

  local function getCoordinate(eventData)
    if eventData.IniUnit and eventData.IniUnit.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniUnit:GetCoordinate() end)
      if ok then return value end
    end
    if eventData.IniGroup and eventData.IniGroup.GetCoordinate then
      local ok, value = pcall(function() return eventData.IniGroup:GetCoordinate() end)
      if ok then return value end
    end
    return nil
  end

  local function expectedSuffixes(definition)
    if definition and definition.ExpectedUnitSuffixes and #definition.ExpectedUnitSuffixes > 0 then
      return definition.ExpectedUnitSuffixes
    end
    return { definition and definition.ExpectedUnitSuffix or "-01" }
  end

  local function isAuthoringName(groupName, unitName)
    return (groupName and cfg.AuthoringGroupNames and cfg.AuthoringGroupNames[groupName] == true) or
           (unitName and cfg.AuthoringUnitNames and cfg.AuthoringUnitNames[unitName] ~= nil)
  end

  local function belongsToAnyManagedSquadron(groupName)
    for key, prefix in pairs(cfg.RuntimeGroupPrefixes or {}) do
      if startsWith(groupName, prefix) then return true, key end
    end
    return false, nil
  end

  local function exactRuntimeName(definition, groupName, unitName)
    if not definition or not groupName or not unitName then return false, "missing-name" end
    if not startsWith(groupName, definition.ExpectedGroupPrefix) then return false, "wrong-group-prefix" end
    for _, suffix in ipairs(expectedSuffixes(definition)) do
      if unitName == groupName .. suffix then return true end
    end
    return false, "wrong-unit-name"
  end

  local function registerMissionGroup(groupName, source)
    local runtime = ph1.Runtime
    local definition = ph1.ActiveDefinition
    if not runtime or not definition or not groupName then return false end
    if not startsWith(groupName, definition.ExpectedGroupPrefix) then return false end
    if runtime.ExpectedGroupNames[groupName] then return true end
    if countKeys(runtime.ExpectedGroupNames) >= definition.ExpectedGroups then
      runtime.HardFailure = "too-many-exact-runtime-groups"
      log("ERROR TOO_MANY_RUNTIME_GROUPS testId=" .. tostring(ph1.ActiveTestId) .. " group=" .. tostring(groupName))
      return false
    end
    runtime.ExpectedGroupNames[groupName] = true
    runtime.ExpectedUnitNames = runtime.ExpectedUnitNames or {}
    local names = {}
    for _, suffix in ipairs(expectedSuffixes(definition)) do
      local unitName = groupName .. suffix
      runtime.ExpectedUnitNames[unitName] = groupName
      names[#names + 1] = unitName
    end
    log("MISSION_GROUP testId=" .. tostring(ph1.ActiveTestId) .. " group=" .. groupName .. " units=" .. table.concat(names, ",") .. " source=" .. tostring(source))
    return true
  end

  local function setUnitEvent(bucket, unitName)
    if not ph1.Runtime or not unitName then return false end
    ph1.Runtime[bucket] = ph1.Runtime[bucket] or {}
    if ph1.Runtime[bucket][unitName] then return false end
    ph1.Runtime[bucket][unitName] = true
    return true
  end

  local function nearestParking(coordinate)
    if not cfg.Airbase or not coordinate then return nil, nil end
    local nearestId, nearestDistance
    for _, spot in ipairs(cfg.Airbase:GetParkingSpotsTable() or {}) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then
        nearestId, nearestDistance = spot.TerminalID, distance
      end
    end
    return nearestId, nearestDistance
  end

  local function nearestStatic(coordinate)
    if not coordinate then return nil, nil end
    local nearestName, nearestDistance
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      for _, name in ipairs((cfg.Statics and cfg.Statics[key]) or {}) do
        local static = STATIC and STATIC:FindByName(name, false) or nil
        if static then
          local distance = distance2D(coordinate, static:GetCoordinate())
          if distance and (not nearestDistance or distance < nearestDistance) then
            nearestName, nearestDistance = name, distance
          end
        end
      end
    end
    return nearestName, nearestDistance
  end

  function observer:IsNearJalalabad(coordinate, radius)
    local base = cfg.Airbase and cfg.Airbase:GetCoordinate() or nil
    local distance = distance2D(coordinate, base)
    return distance and distance <= (radius or ph1.Limits.JalalabadBirthRadiusMeters), distance
  end

  function observer:ResolveClientParkingIDs()
    ph1.ClientParkingIDs = {}
    ph1.ClientParkingMappings = {}
    local spots = cfg.Airbase and cfg.Airbase:GetParkingSpotsTable() or {}
    local groups = {}
    for _, key in ipairs({ "OH58D", "AH64D", "CH47" }) do
      for _, name in ipairs((cfg.PlayerGroups.Required and cfg.PlayerGroups.Required[key]) or {}) do groups[#groups + 1] = name end
    end
    local ok = true
    for _, groupName in ipairs(groups) do
      local entry = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[groupName] or nil
      local unit = entry and entry.Template and entry.Template.units and entry.Template.units[1] or nil
      local terminalId, nearestDistance
      if unit then
        local point = { x = unit.x or 0, z = unit.y or unit.z or 0 }
        for _, spot in ipairs(spots) do
          local distance = distance2D(point, spot.Coordinate)
          if distance and (not nearestDistance or distance < nearestDistance) then terminalId, nearestDistance = spot.TerminalID, distance end
        end
      end
      if terminalId and nearestDistance and nearestDistance <= ph1.Limits.ClientParkingMatchMeters then
        ph1.ClientParkingIDs[terminalId] = true
        ph1.ClientParkingMappings[groupName] = terminalId
        log(string.format("CLIENT_PARKING group=%s TerminalID=%s distance=%.1fm protected=true", groupName, tostring(terminalId), nearestDistance))
      else
        ok = false
        log(string.format("ERROR CLIENT_PARKING_UNRESOLVED group=%s nearestTerminalID=%s distance=%s", groupName, tostring(terminalId), nearestDistance and string.format("%.1fm", nearestDistance) or "unknown"))
      end
    end
    ph1.ClientParkingResolved = ok and #groups == 6
    return ph1.ClientParkingResolved
  end

  function observer:SnapshotSquadron(squadron)
    local snapshot = { total = 0, available = 0, requested = 0, spawned = 0, reserved = 0, busy = 0 }
    if not squadron then return snapshot end
    for _, asset in ipairs(squadron.assets or {}) do
      snapshot.total = snapshot.total + 1
      if asset.requested then snapshot.requested = snapshot.requested + 1 end
      if asset.spawned then snapshot.spawned = snapshot.spawned + 1 end
      if asset.isReserved then snapshot.reserved = snapshot.reserved + 1 end
      if asset.requested or asset.spawned or asset.isReserved then snapshot.busy = snapshot.busy + 1 else snapshot.available = snapshot.available + 1 end
    end
    return snapshot
  end

  function observer:SnapshotAllSquadrons()
    local result = {}
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do result[key] = self:SnapshotSquadron(cfg.Squadrons and cfg.Squadrons[key]) end
    return result
  end

  function observer:LogSnapshot(label, snapshots)
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      local item = snapshots and snapshots[key] or {}
      log(string.format("INVENTORY label=%s squadron=%s total=%s available=%s busy=%s requested=%s spawned=%s reserved=%s", tostring(label), key, tostring(item.total), tostring(item.available), tostring(item.busy), tostring(item.requested), tostring(item.spawned), tostring(item.reserved)))
    end
  end

  function observer:IsInventoryRestored(baseline)
    if not baseline then return false, "baseline-missing" end
    local current = self:SnapshotAllSquadrons()
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      local before, after = baseline[key], current[key]
      if not before or not after then return false, "snapshot-missing-" .. key end
      if after.total ~= before.total then return false, "total-changed-" .. key end
      if after.available ~= before.available or after.busy ~= before.busy then return false, "asset-not-released-" .. key end
    end
    return true, current
  end

  function observer:RefreshMissionGroups()
    if not ph1.Runtime or not ph1.ActiveMission then return 0 end
    local found = 0
    local ok, groups = pcall(function() return ph1.ActiveMission:GetOpsGroups() end)
    if ok then
      for _, opsgroup in pairs(groups or {}) do
        local name = opsgroup.groupname
        if not name and opsgroup.GetName then
          local nameOK, value = pcall(function() return opsgroup:GetName() end)
          if nameOK then name = value end
        end
        if not name and opsgroup.group and opsgroup.group.GetName then
          local nameOK, value = pcall(function() return opsgroup.group:GetName() end)
          if nameOK then name = value end
        end
        if registerMissionGroup(name, "mission:GetOpsGroups") then found = found + 1 end
      end
    end
    for groupName in pairs((ph1.ActiveMission and ph1.ActiveMission.groupdata) or {}) do
      if registerMissionGroup(groupName, "mission.groupdata") then found = found + 1 end
    end
    return found
  end

  function observer:GetRuntimeGroupCoordinates()
    local result = {}
    local mission = ph1.ActiveMission
    if not mission then return result end
    local ok, groups = pcall(function() return mission:GetOpsGroups() end)
    if not ok then return result end
    for _, opsgroup in pairs(groups or {}) do
      local group = opsgroup.group
      if group and group.GetCoordinate then
        local coordinateOK, coordinate = pcall(function() return group:GetCoordinate() end)
        if coordinateOK and coordinate then result[#result + 1] = { OpsGroup = opsgroup, Group = group, Coordinate = coordinate } end
      end
    end
    return result
  end

  function observer:UpdateDistanceTracking()
    if not ph1.ActiveMission or not ph1.Runtime then return end
    local base = cfg.Airbase and cfg.Airbase:GetCoordinate() or nil
    if not base then return end
    for _, item in ipairs(self:GetRuntimeGroupCoordinates()) do
      local distance = distance2D(item.Coordinate, base)
      if distance then
        ph1.Runtime.MaxDistanceFromBase = math.max(ph1.Runtime.MaxDistanceFromBase or 0, distance)
        if ph1.Runtime.MissionTerminal and (ph1.Runtime.MaxDistanceFromBase or 0) >= ph1.Limits.MissionAreaDistanceMeters and distance <= ph1.Limits.RTBDetectionRadiusMeters and not ph1.Runtime.RTBObserved then
          ph1.Runtime.RTBObserved = true
          log(string.format("EVENT testId=%s stage=RTB distance=%.0fm", tostring(ph1.ActiveTestId), distance))
        end
      end
    end
  end

  local function expectedEvent(groupName, unitName, typeName)
    if not ph1.ActiveMission or not ph1.Runtime or not ph1.ActiveDefinition then return false end
    if isAuthoringName(groupName, unitName) then return false end
    observer:RefreshMissionGroups()
    local exact = exactRuntimeName(ph1.ActiveDefinition, groupName, unitName)
    if not exact then return false end
    if typeName ~= ph1.ActiveDefinition.ExpectedType then return false end
    if not ph1.Runtime.ExpectedGroupNames[groupName] and not registerMissionGroup(groupName, "exact-birth-name") then return false end
    return ph1.Runtime.ExpectedUnitNames[unitName] == groupName
  end

  local function registerExpectedEvent(stage, bucket, counter, eventData)
    local groupName, unitName, typeName = getGroupName(eventData), getUnitName(eventData), getTypeName(eventData)
    if not expectedEvent(groupName, unitName, typeName) then return false end
    if setUnitEvent(bucket, unitName) then
      increment(counter)
      ph1.Runtime[stage .. "Count"] = (ph1.Runtime[stage .. "Count"] or 0) + 1
      log(string.format("EVENT testId=%s stage=%s group=%s unit=%s type=%s count=%d expected=%d", tostring(ph1.ActiveTestId), stage, groupName, unitName, typeName, ph1.Runtime[stage .. "Count"], ph1.ActiveDefinition.ExpectedAircraft))
    end
    return true
  end

  local handler = EVENTHANDLER:New()
  ph1.EventHandler = handler
  for _, event in ipairs({ EVENTS.Birth, EVENTS.EngineStartup, EVENTS.Takeoff, EVENTS.Land, EVENTS.EngineShutdown, EVENTS.Crash, EVENTS.Dead }) do handler:HandleEvent(event) end

  function handler:OnEventBirth(eventData)
    local groupName, unitName, typeName = getGroupName(eventData), getUnitName(eventData), getTypeName(eventData)
    local coordinate = getCoordinate(eventData)
    if expectedEvent(groupName, unitName, typeName) then
      if setUnitEvent("BornUnits", unitName) then
        increment("aircraftSpawned")
        ph1.Runtime.BirthCount = (ph1.Runtime.BirthCount or 0) + 1
      end
      local newGroup = not ph1.Runtime.BornGroupNames[groupName]
      ph1.Runtime.BornGroupNames[groupName] = true
      if newGroup then increment("groupsSpawned") end
      local definition = ph1.ActiveDefinition
      if ph1.Runtime.BirthCount > definition.ExpectedAircraft then ph1.Runtime.HardFailure = "unexpected-aircraft-count-" .. tostring(ph1.Runtime.BirthCount) end
      if countKeys(ph1.Runtime.BornGroupNames) > definition.ExpectedGroups then ph1.Runtime.HardFailure = "unexpected-group-count-" .. tostring(countKeys(ph1.Runtime.BornGroupNames)) end

      local terminalId, parkingDistance = nearestParking(coordinate)
      local staticName, staticDistance = nearestStatic(coordinate)
      local poolKey = definition.ParkingPoolKey or definition.SquadronKey
      local allowed = cfg.ParkingPoolTerminalIDs and cfg.ParkingPoolTerminalIDs[poolKey] or nil
      log(string.format("EVENT testId=%s stage=SPAWN group=%s unit=%s type=%s TerminalID=%s parkingDistance=%s", tostring(ph1.ActiveTestId), groupName, unitName, typeName, tostring(terminalId), parkingDistance and string.format("%.1fm", parkingDistance) or "unknown"))
      if not terminalId or not parkingDistance or parkingDistance > ph1.Limits.ParkingBirthMatchMeters or not allowed or not allowed[terminalId] then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-outside-squadron-pool-" .. tostring(terminalId)
      else
        log(string.format("SPAWN_POOL_CONFIRMED group=%s unit=%s label=%s TerminalID=%s", groupName, unitName, tostring(cfg:GetSquadronParkingLabel(poolKey, terminalId)), tostring(terminalId)))
      end
      if terminalId and ph1.ClientParkingIDs and ph1.ClientParkingIDs[terminalId] then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-on-client-terminal-" .. tostring(terminalId)
      end
      if staticDistance and staticDistance < ph1.Limits.StaticSpawnClearanceMeters then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-too-close-to-static-" .. tostring(staticName)
      end
      if ph1.Controller and ph1.Controller.OnExpectedBirth then ph1.Controller:OnExpectedBirth(groupName, unitName, typeName) end
      return
    end

    if isAuthoringName(groupName, unitName) then return end
    local managed, owner = belongsToAnyManagedSquadron(groupName)
    local nearBase = observer:IsNearJalalabad(coordinate)
    if ph1.ActiveMission and nearBase and managedTypes[typeName] and managed then
      increment("unexpectedSpawns")
      ph1.Runtime.HardFailure = "unexpected-managed-spawn-" .. tostring(groupName)
      log(string.format("ERROR UNEXPECTED_MANAGED_SPAWN group=%s unit=%s type=%s owner=%s activeSquadron=%s", tostring(groupName), tostring(unitName), tostring(typeName), tostring(owner), tostring(ph1.ActiveDefinition and ph1.ActiveDefinition.SquadronKey)))
    end
  end

  function handler:OnEventEngineStartup(eventData) registerExpectedEvent("EngineStart", "EngineUnits", "engineStarts", eventData) end
  function handler:OnEventTakeoff(eventData) registerExpectedEvent("Takeoff", "TakeoffUnits", "takeoffs", eventData) end

  function handler:OnEventLand(eventData)
    local groupName, unitName, typeName = getGroupName(eventData), getUnitName(eventData), getTypeName(eventData)
    if not expectedEvent(groupName, unitName, typeName) then return end
    local nearBase, distance = observer:IsNearJalalabad(getCoordinate(eventData), ph1.Limits.RTBDetectionRadiusMeters)
    if nearBase then
      if setUnitEvent("LandedUnits", unitName) then
        increment("landings")
        ph1.Runtime.LandingCount = (ph1.Runtime.LandingCount or 0) + 1
      end
      ph1.Runtime.RTBObserved = true
      log(string.format("EVENT testId=%s stage=LAND_AT_JALALABAD group=%s unit=%s distance=%.0fm count=%d expected=%d", tostring(ph1.ActiveTestId), groupName, unitName, distance or -1, ph1.Runtime.LandingCount or 0, ph1.ActiveDefinition.ExpectedAircraft))
    else
      ph1.Runtime.RemoteLandingCount = (ph1.Runtime.RemoteLandingCount or 0) + 1
      increment("remoteLandings")
      log(string.format("EVENT testId=%s stage=REMOTE_LANDING group=%s unit=%s distance=%s", tostring(ph1.ActiveTestId), groupName, unitName, distance and string.format("%.0fm", distance) or "unknown"))
    end
  end

  function handler:OnEventEngineShutdown(eventData) registerExpectedEvent("EngineShutdown", "ShutdownUnits", "engineShutdowns", eventData) end

  local function handleLoss(stage, eventData)
    local groupName, unitName, typeName = getGroupName(eventData), getUnitName(eventData), getTypeName(eventData)
    if expectedEvent(groupName, unitName, typeName) then
      increment("losses")
      ph1.Runtime.HardFailure = string.lower(stage) .. "-" .. tostring(unitName)
      log(string.format("ERROR EVENT testId=%s stage=%s group=%s unit=%s type=%s", tostring(ph1.ActiveTestId), stage, groupName, unitName, typeName))
    end
  end
  function handler:OnEventCrash(eventData) handleLoss("CRASH", eventData) end
  function handler:OnEventDead(eventData) handleLoss("DEAD", eventData) end

  log("READY packageAware=true exactGroupPrefix=true exactUnitSuffixes=true typeOnlyMatching=false physicalTwoShips=OH58D,AH64D")
end
