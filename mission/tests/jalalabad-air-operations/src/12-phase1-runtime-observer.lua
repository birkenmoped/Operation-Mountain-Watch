-- Operation Mountain Watch - Jalalabad AIRWING Phase 1 runtime observer
local TAG = "[OMW][AirOps.JBAD.PH1.OBS]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 then
  log("ERROR: Phase 1 manifest is unavailable.")
else
  local observer = ph1.Observer or {}
  ph1.Observer = observer

  local managedTypes = {
    OH58D = true,
    ["AH-64D_BLK_II"] = true,
    ["UH-60A"] = true,
    ["CH-47Fbl1"] = true
  }

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local dx = (a.x or 0) - (b.x or 0)
    local az = a.z
    if az == nil then az = a.y or 0 end
    local bz = b.z
    if bz == nil then bz = b.y or 0 end
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
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

  local function increment(counter)
    ph1.Counters = ph1.Counters or {}
    ph1.Counters[counter] = (ph1.Counters[counter] or 0) + 1
  end

  local function countKeys(values)
    local count = 0
    for _ in pairs(values or {}) do count = count + 1 end
    return count
  end

  local function setUnitEvent(bucket, unitName)
    ph1.Runtime = ph1.Runtime or {}
    ph1.Runtime[bucket] = ph1.Runtime[bucket] or {}
    local key = unitName or (bucket .. "-unknown-" .. tostring(timer.getTime()))
    if not ph1.Runtime[bucket][key] then
      ph1.Runtime[bucket][key] = true
      return true
    end
    return false
  end

  local function nearestParking(coordinate)
    local airbase = cfg.Airbase
    if not airbase or not coordinate then return nil, nil end
    local nearestId, nearestDistance
    for _, spot in ipairs(airbase:GetParkingSpotsTable() or {}) do
      local distance = distance2D(coordinate, spot.Coordinate)
      if distance and (not nearestDistance or distance < nearestDistance) then
        nearestDistance = distance
        nearestId = spot.TerminalID
      end
    end
    return nearestId, nearestDistance
  end

  local function nearestStatic(coordinate)
    if not coordinate then return nil, nil end
    local names = {}
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      for _, name in ipairs((cfg.Statics and cfg.Statics[key]) or {}) do
        names[#names + 1] = name
      end
    end
    local nearestName, nearestDistance
    for _, name in ipairs(names) do
      local static = STATIC and STATIC:FindByName(name, false) or nil
      if static then
        local distance = distance2D(coordinate, static:GetCoordinate())
        if distance and (not nearestDistance or distance < nearestDistance) then
          nearestName = name
          nearestDistance = distance
        end
      end
    end
    return nearestName, nearestDistance
  end

  local function isExcludedAuthoringGroup(groupName)
    if not groupName then return false end
    return string.sub(groupName, 1, 15) == "CLIENT_US_JBAD_" or
           string.sub(groupName, 1, 16) == "TPL_AIR_US_JBAD_"
  end

  function observer:IsNearJalalabad(coordinate, radius)
    local airbaseCoordinate = cfg.Airbase and cfg.Airbase:GetCoordinate() or nil
    local distance = distance2D(coordinate, airbaseCoordinate)
    return distance and distance <= (radius or ph1.Limits.JalalabadBirthRadiusMeters), distance
  end

  function observer:ResolveClientParkingIDs()
    ph1.ClientParkingIDs = {}
    ph1.ClientParkingMappings = {}
    local spots = cfg.Airbase and cfg.Airbase:GetParkingSpotsTable() or {}
    local groups = {}
    for _, key in ipairs({ "OH58D", "AH64D", "CH47" }) do
      for _, name in ipairs((cfg.PlayerGroups.Required and cfg.PlayerGroups.Required[key]) or {}) do
        groups[#groups + 1] = name
      end
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
          if distance and (not nearestDistance or distance < nearestDistance) then
            nearestDistance = distance
            terminalId = spot.TerminalID
          end
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
    local snapshot = {
      total = 0,
      available = 0,
      requested = 0,
      spawned = 0,
      reserved = 0,
      busy = 0
    }
    if not squadron then return snapshot end
    for _, asset in ipairs(squadron.assets or {}) do
      snapshot.total = snapshot.total + 1
      if asset.requested then snapshot.requested = snapshot.requested + 1 end
      if asset.spawned then snapshot.spawned = snapshot.spawned + 1 end
      if asset.isReserved then snapshot.reserved = snapshot.reserved + 1 end
      if asset.requested or asset.spawned or asset.isReserved then
        snapshot.busy = snapshot.busy + 1
      else
        snapshot.available = snapshot.available + 1
      end
    end
    return snapshot
  end

  function observer:SnapshotAllSquadrons()
    local result = {}
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      result[key] = self:SnapshotSquadron(cfg.Squadrons and cfg.Squadrons[key])
    end
    return result
  end

  function observer:LogSnapshot(label, snapshots)
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      local item = snapshots and snapshots[key] or {}
      log(string.format(
        "INVENTORY label=%s squadron=%s total=%s available=%s busy=%s requested=%s spawned=%s reserved=%s",
        tostring(label), key, tostring(item.total), tostring(item.available), tostring(item.busy),
        tostring(item.requested), tostring(item.spawned), tostring(item.reserved)
      ))
    end
  end

  function observer:IsInventoryRestored(baseline)
    if not baseline then return false, "baseline-missing" end
    local current = self:SnapshotAllSquadrons()
    for _, key in ipairs({ "OH58D", "AH64D", "UH60", "CH47" }) do
      local before = baseline[key]
      local after = current[key]
      if not before or not after then return false, "snapshot-missing-" .. key end
      if after.total ~= before.total then return false, "total-changed-" .. key end
      if after.available ~= before.available or after.busy ~= before.busy then
        return false, "asset-not-released-" .. key
      end
    end
    return true, current
  end

  function observer:RefreshMissionGroups()
    ph1.Runtime = ph1.Runtime or {}
    ph1.Runtime.ExpectedGroupNames = ph1.Runtime.ExpectedGroupNames or {}
    local mission = ph1.ActiveMission
    if not mission then return 0 end

    local found = 0
    local ok, groups = pcall(function() return mission:GetOpsGroups() end)
    if ok then
      for _, opsgroup in pairs(groups or {}) do
        local names = {}
        if opsgroup.groupname then names[#names + 1] = opsgroup.groupname end
        if opsgroup.GetName then
          local nameOk, name = pcall(function() return opsgroup:GetName() end)
          if nameOk and name then names[#names + 1] = name end
        end
        if opsgroup.group and opsgroup.group.GetName then
          local nameOk, name = pcall(function() return opsgroup.group:GetName() end)
          if nameOk and name then names[#names + 1] = name end
        end
        for _, name in ipairs(names) do
          if not ph1.Runtime.ExpectedGroupNames[name] then
            ph1.Runtime.ExpectedGroupNames[name] = true
            log("MISSION_GROUP testId=" .. tostring(ph1.ActiveTestId) .. " group=" .. tostring(name))
          end
        end
        found = found + 1
      end
    end

    for groupName, _ in pairs(mission.groupdata or {}) do
      if not ph1.Runtime.ExpectedGroupNames[groupName] then
        ph1.Runtime.ExpectedGroupNames[groupName] = true
        log("MISSION_GROUP testId=" .. tostring(ph1.ActiveTestId) .. " group=" .. tostring(groupName) .. " source=groupdata")
      end
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
        local coordinateOk, coordinate = pcall(function() return group:GetCoordinate() end)
        if coordinateOk and coordinate then
          result[#result + 1] = { OpsGroup = opsgroup, Group = group, Coordinate = coordinate }
        end
      end
    end
    return result
  end

  function observer:UpdateDistanceTracking()
    if not ph1.ActiveMission or not ph1.Runtime then return end
    local airbaseCoordinate = cfg.Airbase and cfg.Airbase:GetCoordinate() or nil
    if not airbaseCoordinate then return end
    for _, item in ipairs(self:GetRuntimeGroupCoordinates()) do
      local distance = distance2D(item.Coordinate, airbaseCoordinate)
      if distance then
        ph1.Runtime.MaxDistanceFromBase = math.max(ph1.Runtime.MaxDistanceFromBase or 0, distance)
        if ph1.Runtime.MissionTerminal and
           (ph1.Runtime.MaxDistanceFromBase or 0) >= ph1.Limits.MissionAreaDistanceMeters and
           distance <= ph1.Limits.RTBDetectionRadiusMeters and
           not ph1.Runtime.RTBObserved then
          ph1.Runtime.RTBObserved = true
          log(string.format("EVENT testId=%s stage=RTB distance=%.0fm", tostring(ph1.ActiveTestId), distance))
        end
      end
    end
  end

  local function expectedEvent(groupName, typeName)
    observer:RefreshMissionGroups()
    local expectedNames = ph1.Runtime and ph1.Runtime.ExpectedGroupNames or {}
    if groupName and expectedNames[groupName] then return true end

    local definition = ph1.ActiveDefinition
    if definition and typeName == definition.ExpectedType then
      ph1.Runtime.ProvisionalGroupNames = ph1.Runtime.ProvisionalGroupNames or {}
      local count = 0
      for _ in pairs(ph1.Runtime.ProvisionalGroupNames) do count = count + 1 end
      if groupName and (ph1.Runtime.BirthCount or 0) < definition.ExpectedAircraft and count < definition.ExpectedGroups then
        ph1.Runtime.ProvisionalGroupNames[groupName] = true
        ph1.Runtime.ExpectedGroupNames[groupName] = true
        log("MISSION_GROUP testId=" .. tostring(ph1.ActiveTestId) .. " group=" .. tostring(groupName) .. " source=provisional-birth")
        return true
      end
    end
    return false
  end

  local function registerExpectedEvent(stage, bucket, counter, eventData)
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    if not ph1.ActiveMission or not expectedEvent(groupName, typeName) then return false end
    if setUnitEvent(bucket, unitName) then
      increment(counter)
      ph1.Runtime[stage .. "Count"] = (ph1.Runtime[stage .. "Count"] or 0) + 1
      log(string.format("EVENT testId=%s stage=%s group=%s unit=%s type=%s count=%d", tostring(ph1.ActiveTestId), stage, tostring(groupName), tostring(unitName), tostring(typeName), ph1.Runtime[stage .. "Count"]))
    end
    return true
  end

  local handler = EVENTHANDLER:New()
  ph1.EventHandler = handler

  handler:HandleEvent(EVENTS.Birth)
  handler:HandleEvent(EVENTS.EngineStartup)
  handler:HandleEvent(EVENTS.Takeoff)
  handler:HandleEvent(EVENTS.Land)
  handler:HandleEvent(EVENTS.EngineShutdown)
  handler:HandleEvent(EVENTS.Crash)
  handler:HandleEvent(EVENTS.Dead)

  function handler:OnEventBirth(eventData)
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    local coordinate = getCoordinate(eventData)
    local expected = ph1.ActiveMission and expectedEvent(groupName, typeName)

    if expected then
      if setUnitEvent("BornUnits", unitName) then
        increment("aircraftSpawned")
        ph1.Runtime.BirthCount = (ph1.Runtime.BirthCount or 0) + 1
      end
      ph1.Runtime.BornGroupNames = ph1.Runtime.BornGroupNames or {}
      if groupName then ph1.Runtime.BornGroupNames[groupName] = true end
      local definition = ph1.ActiveDefinition
      if definition and (ph1.Runtime.BirthCount or 0) > definition.ExpectedAircraft then
        ph1.Runtime.HardFailure = "unexpected-aircraft-count-" .. tostring(ph1.Runtime.BirthCount)
      end
      if definition and countKeys(ph1.Runtime.BornGroupNames) > definition.ExpectedGroups then
        ph1.Runtime.HardFailure = "unexpected-group-count-" .. tostring(countKeys(ph1.Runtime.BornGroupNames))
      end

      local terminalId, parkingDistance = nearestParking(coordinate)
      local staticName, staticDistance = nearestStatic(coordinate)
      log(string.format(
        "EVENT testId=%s stage=SPAWN group=%s unit=%s type=%s TerminalID=%s parkingDistance=%s nearestStatic=%s staticDistance=%s",
        tostring(ph1.ActiveTestId), tostring(groupName), tostring(unitName), tostring(typeName), tostring(terminalId),
        parkingDistance and string.format("%.1fm", parkingDistance) or "unknown", tostring(staticName),
        staticDistance and string.format("%.1fm", staticDistance) or "unknown"
      ))

      if terminalId and ph1.ParkingBlacklist[terminalId] then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-on-blacklisted-terminal-" .. tostring(terminalId)
        log("ERROR SPAWN_BLACKLIST_VIOLATION testId=" .. tostring(ph1.ActiveTestId) .. " TerminalID=" .. tostring(terminalId))
      end
      if terminalId and ph1.ClientParkingIDs and ph1.ClientParkingIDs[terminalId] then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-on-client-terminal-" .. tostring(terminalId)
        log("ERROR SPAWN_CLIENT_PARKING_VIOLATION testId=" .. tostring(ph1.ActiveTestId) .. " TerminalID=" .. tostring(terminalId))
      end
      if staticDistance and staticDistance < ph1.Limits.StaticSpawnClearanceMeters then
        increment("parkingViolations")
        ph1.Runtime.HardFailure = "spawn-too-close-to-static-" .. tostring(staticName)
        log(string.format("ERROR SPAWN_STATIC_CLEARANCE testId=%s static=%s distance=%.1fm minimum=%.1fm", tostring(ph1.ActiveTestId), tostring(staticName), staticDistance, ph1.Limits.StaticSpawnClearanceMeters))
      end

      if ph1.Controller and ph1.Controller.OnExpectedBirth then
        ph1.Controller:OnExpectedBirth(groupName, unitName, typeName)
      end
      return
    end

    local nearBase = observer:IsNearJalalabad(coordinate)
    if nearBase and managedTypes[typeName] and not isExcludedAuthoringGroup(groupName) then
      increment("unexpectedSpawns")
      log(string.format("ERROR UNEXPECTED_SPAWN group=%s unit=%s type=%s activeTest=%s", tostring(groupName), tostring(unitName), tostring(typeName), tostring(ph1.ActiveTestId)))
      if ph1.Runtime then ph1.Runtime.HardFailure = "unexpected-spawn-" .. tostring(groupName) end
    end
  end

  function handler:OnEventEngineStartup(eventData)
    registerExpectedEvent("EngineStart", "EngineUnits", "engineStarts", eventData)
  end

  function handler:OnEventTakeoff(eventData)
    registerExpectedEvent("Takeoff", "TakeoffUnits", "takeoffs", eventData)
  end

  function handler:OnEventLand(eventData)
    local expected = registerExpectedEvent("Landing", "LandedUnits", "landings", eventData)
    if expected then
      local coordinate = getCoordinate(eventData)
      local nearBase, distance = observer:IsNearJalalabad(coordinate, ph1.Limits.RTBDetectionRadiusMeters)
      if nearBase then
        ph1.Runtime.RTBObserved = true
        log(string.format("EVENT testId=%s stage=LAND_AT_JALALABAD distance=%.0fm", tostring(ph1.ActiveTestId), distance or -1))
      else
        ph1.Runtime.HardFailure = "landing-away-from-jalalabad"
        log("ERROR LANDING_AWAY_FROM_JALALABAD testId=" .. tostring(ph1.ActiveTestId))
      end
    end
  end

  function handler:OnEventEngineShutdown(eventData)
    registerExpectedEvent("EngineShutdown", "ShutdownUnits", "engineShutdowns", eventData)
  end

  local function handleLoss(stage, eventData)
    local groupName = getGroupName(eventData)
    local unitName = getUnitName(eventData)
    local typeName = getTypeName(eventData)
    if ph1.ActiveMission and expectedEvent(groupName, typeName) then
      increment("losses")
      ph1.Runtime.HardFailure = string.lower(stage) .. "-" .. tostring(unitName)
      log(string.format("ERROR EVENT testId=%s stage=%s group=%s unit=%s type=%s", tostring(ph1.ActiveTestId), stage, tostring(groupName), tostring(unitName), tostring(typeName)))
    end
  end

  function handler:OnEventCrash(eventData) handleLoss("CRASH", eventData) end
  function handler:OnEventDead(eventData) handleLoss("DEAD", eventData) end

  log("READY eventHandlers=Birth,EngineStartup,Takeoff,Land,EngineShutdown,Crash,Dead")
end
