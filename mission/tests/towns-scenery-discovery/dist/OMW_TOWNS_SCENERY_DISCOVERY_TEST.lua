-- OMW_TOWNS_SCENERY_DISCOVERY_TEST.lua
-- Operation Mountain Watch - one-time DCS scenery-density discovery prototype.
--
-- No MOOSE, io, lfs, require or MissionScripting.lua modification is required.
-- The script scans a small set of embedded towns.lua reference points plus
-- optional Mission Editor probe zones. It does not control or inspect units.

OMW_TOWNS_SCENERY_DISCOVERY = OMW_TOWNS_SCENERY_DISCOVERY or {}
local MODULE = OMW_TOWNS_SCENERY_DISCOVERY

local DEFAULTS = {
  version = "TOWNS-SCENERY-DISCOVERY-01",

  autoStart = true,
  startDelaySeconds = 1.0,
  pointIntervalSeconds = 0.25,

  radiiM = { 100, 250, 500, 1000 },
  searchVerticalMinM = -1000,
  searchVerticalMaxM = 5000,

  probeZonePrefix = "OMW_SCENERY_PROBE_",
  probeZoneIndexMax = 20,

  markerBaseId = 880000,
  showMarkersOnFinish = true,
  createF10Menu = true,
  markerReadOnly = true,

  -- Provisional density thresholds. They intentionally classify only the
  -- number of searchable SCENERY objects, not population or settlement type.
  densityThresholds500M = {
    isolatedMax = 8,
    lowMax = 30,
    mediumMax = 120,
    highMax = 400,
  },
}

local function copyTable(source)
  local target = {}
  for key, value in pairs(source or {}) do
    if type(value) == "table" then
      target[key] = copyTable(value)
    else
      target[key] = value
    end
  end
  return target
end

local function mergeTable(target, source)
  for key, value in pairs(source or {}) do
    if type(value) == "table" and type(target[key]) == "table" then
      mergeTable(target[key], value)
    else
      target[key] = value
    end
  end
end

MODULE.config = MODULE.config or copyTable(DEFAULTS)
mergeTable(MODULE.config, OMW_TOWNS_SCENERY_DISCOVERY_CONFIG or {})

MODULE.referencePoints = MODULE.referencePoints or {
  { id = "REF_KABUL", label = "Kabul", latitude = 34.526011, longitude = 69.177684 },
  { id = "REF_JALALABAD", label = "Jalalabad", latitude = 34.430195, longitude = 70.460128 },
  { id = "REF_BAGRAM", label = "Bagram", latitude = 34.933373, longitude = 69.234108 },
  { id = "REF_SULTANPUR", label = "Sultanpur", latitude = 34.418310, longitude = 70.323595 },
  { id = "REF_CHAPARHAR", label = "Chaparhar", latitude = 34.277373, longitude = 70.361795 },
  { id = "REF_ASADABAD", label = "Asadabad", latitude = 34.872795, longitude = 71.150833 },
  { id = "REF_PARUN", label = "Parun", latitude = 35.420644, longitude = 70.922612 },
  { id = "REF_KAMDESH", label = "Kamdesh", latitude = 35.409388, longitude = 71.339854 },
  { id = "REF_NARI", label = "Nari", latitude = 35.219953, longitude = 71.522839 },
}

MODULE.state = MODULE.state or {
  running = false,
  generation = 0,
  queue = {},
  nextIndex = 1,
  results = {},
  markerIds = {},
  errors = 0,
  menuRoot = nil,
}

local PREFIX = "[OMW-SCENERY-DISCOVERY]"

local function log(message)
  if env and env.info then
    env.info(PREFIX .. " " .. tostring(message))
  end
end

local function warn(message)
  if env and env.warning then
    env.warning(PREFIX .. " " .. tostring(message))
  else
    log("WARN " .. tostring(message))
  end
end

local function fail(message)
  if env and env.error then
    env.error(PREFIX .. " " .. tostring(message))
  else
    log("ERROR " .. tostring(message))
  end
end

local function message(text, seconds)
  if trigger and trigger.action and trigger.action.outText then
    trigger.action.outText("OMW Scenery Discovery\n" .. tostring(text), seconds or 12)
  end
end

local function sanitize(value)
  local text = tostring(value or "")
  text = text:gsub("[\r\n|]", " ")
  return text
end

local function getGroundHeight(x, z)
  if land and land.getHeight then
    local ok, height = pcall(land.getHeight, { x = x, y = z })
    if ok and type(height) == "number" then
      return height
    end
  end
  return 0
end

local function pointFromLatLon(latitude, longitude)
  if not coord or type(coord.LLtoLO) ~= "function" then
    return nil, "coord.LLtoLO unavailable"
  end

  local ok, point = pcall(coord.LLtoLO, latitude, longitude, 0)
  if not ok or type(point) ~= "table" or not point.x or not point.z then
    return nil, tostring(point)
  end

  point.y = getGroundHeight(point.x, point.z)
  return point, nil
end

local function latLonFromPoint(point)
  if not coord or type(coord.LOtoLL) ~= "function" then
    return nil, nil
  end

  local ok, latitude, longitude = pcall(coord.LOtoLL, point)
  if not ok then
    return nil, nil
  end

  return latitude, longitude
end

local function getTriggerZone(zoneName)
  if not trigger or not trigger.misc or type(trigger.misc.getZone) ~= "function" then
    return nil
  end

  local ok, zone = pcall(trigger.misc.getZone, zoneName)
  if ok and type(zone) == "table" and type(zone.point) == "table" then
    return zone
  end
  return nil
end

local function buildQueue()
  local queue = {}

  for _, reference in ipairs(MODULE.referencePoints) do
    local point, errorMessage = pointFromLatLon(reference.latitude, reference.longitude)
    if point then
      queue[#queue + 1] = {
        id = reference.id,
        label = reference.label,
        source = "TOWNS_LUA_REFERENCE",
        latitude = reference.latitude,
        longitude = reference.longitude,
        point = point,
      }
    else
      MODULE.state.errors = MODULE.state.errors + 1
      fail(string.format(
        "Reference conversion failed: id=%s label=%s error=%s",
        tostring(reference.id), tostring(reference.label), tostring(errorMessage)
      ))
    end
  end

  for index = 1, MODULE.config.probeZoneIndexMax do
    local zoneName = string.format("%s%02d", MODULE.config.probeZonePrefix, index)
    local zone = getTriggerZone(zoneName)
    if zone then
      local point = {
        x = zone.point.x,
        y = getGroundHeight(zone.point.x, zone.point.z),
        z = zone.point.z,
      }
      local latitude, longitude = latLonFromPoint(point)
      queue[#queue + 1] = {
        id = zoneName,
        label = zoneName,
        source = "MISSION_EDITOR_PROBE",
        latitude = latitude,
        longitude = longitude,
        zoneRadiusM = zone.radius,
        point = point,
      }
    end
  end

  return queue
end

local function getObjectPoint(object)
  if object and type(object.getPoint) == "function" then
    local ok, point = pcall(object.getPoint, object)
    if ok and type(point) == "table" and point.x and point.z then
      return point
    end
  end
  return nil
end

local function getObjectName(object)
  if object and type(object.getName) == "function" then
    local ok, value = pcall(object.getName, object)
    if ok and value ~= nil then
      return tostring(value)
    end
  end
  return ""
end

local function getObjectTypeName(object)
  if object and type(object.getTypeName) == "function" then
    local ok, value = pcall(object.getTypeName, object)
    if ok and value ~= nil and tostring(value) ~= "" then
      return tostring(value)
    end
  end
  return "<unknown>"
end

local function classify(count500)
  local thresholds = MODULE.config.densityThresholds500M
  if count500 <= 0 then
    return "SCENERY_NONE"
  elseif count500 <= thresholds.isolatedMax then
    return "SCENERY_ISOLATED"
  elseif count500 <= thresholds.lowMax then
    return "SCENERY_LOW"
  elseif count500 <= thresholds.mediumMax then
    return "SCENERY_MEDIUM"
  elseif count500 <= thresholds.highMax then
    return "SCENERY_HIGH"
  end
  return "SCENERY_VERY_HIGH"
end

local function sortedTypeSummary(typeCounts, limit)
  local items = {}
  for typeName, count in pairs(typeCounts) do
    items[#items + 1] = { typeName = typeName, count = count }
  end

  table.sort(items, function(a, b)
    if a.count == b.count then
      return a.typeName < b.typeName
    end
    return a.count > b.count
  end)

  local parts = {}
  local maximum = math.min(limit or 5, #items)
  for index = 1, maximum do
    parts[#parts + 1] = string.format("%s:%d", sanitize(items[index].typeName), items[index].count)
  end
  return table.concat(parts, ";")
end

local function scanItem(item)
  local radii = MODULE.config.radiiM
  local maximumRadius = radii[#radii]
  local counts = {}
  for index = 1, #radii do counts[index] = 0 end

  local data = {
    center = item.point,
    radii = radii,
    maximumRadius = maximumRadius,
    counts = counts,
    nearestDistanceM = nil,
    typeCounts = {},
    seen = {},
    totalUnique = 0,
  }

  local volume = {
    id = world.VolumeType.BOX,
    params = {
      min = {
        x = item.point.x - maximumRadius,
        y = MODULE.config.searchVerticalMinM,
        z = item.point.z - maximumRadius,
      },
      max = {
        x = item.point.x + maximumRadius,
        y = MODULE.config.searchVerticalMaxM,
        z = item.point.z + maximumRadius,
      },
    },
  }

  local function handler(object, context)
    local objectPoint = getObjectPoint(object)
    if not objectPoint then
      return true
    end

    local dx = objectPoint.x - context.center.x
    local dz = objectPoint.z - context.center.z
    local distanceM = math.sqrt(dx * dx + dz * dz)
    if distanceM > context.maximumRadius then
      return true
    end

    local typeName = getObjectTypeName(object)
    local objectName = getObjectName(object)
    local key = string.format(
      "%s|%s|%.1f|%.1f",
      objectName,
      typeName,
      objectPoint.x,
      objectPoint.z
    )

    if context.seen[key] then
      return true
    end
    context.seen[key] = true

    context.totalUnique = context.totalUnique + 1
    context.typeCounts[typeName] = (context.typeCounts[typeName] or 0) + 1

    if not context.nearestDistanceM or distanceM < context.nearestDistanceM then
      context.nearestDistanceM = distanceM
    end

    for index, radiusM in ipairs(context.radii) do
      if distanceM <= radiusM then
        context.counts[index] = context.counts[index] + 1
      end
    end

    return true
  end

  local ok, searchResult = pcall(
    world.searchObjects,
    Object.Category.SCENERY,
    volume,
    handler,
    data
  )

  if not ok then
    return nil, tostring(searchResult)
  end

  local count500 = 0
  for index, radiusM in ipairs(radii) do
    if radiusM == 500 then
      count500 = counts[index]
      break
    end
  end

  return {
    id = item.id,
    label = item.label,
    source = item.source,
    latitude = item.latitude,
    longitude = item.longitude,
    point = item.point,
    zoneRadiusM = item.zoneRadiusM,
    radiiM = radii,
    counts = counts,
    totalUniqueWithinMaximumRadius = data.totalUnique,
    nearestDistanceM = data.nearestDistanceM,
    densityClass = classify(count500),
    typeSummary = sortedTypeSummary(data.typeCounts, 5),
    searchReturn = searchResult,
  }, nil
end

local function countsText(result)
  local parts = {}
  for index, radiusM in ipairs(result.radiiM) do
    parts[#parts + 1] = string.format("%dm=%d", radiusM, result.counts[index] or 0)
  end
  return table.concat(parts, " ")
end

local function resultLogLine(result)
  return string.format(
    "RESULT|id=%s|label=%s|source=%s|lat=%s|lon=%s|class=%s|counts=%s|nearest_m=%s|types=%s",
    sanitize(result.id),
    sanitize(result.label),
    sanitize(result.source),
    result.latitude and string.format("%.8f", result.latitude) or "",
    result.longitude and string.format("%.8f", result.longitude) or "",
    sanitize(result.densityClass),
    sanitize(countsText(result)),
    result.nearestDistanceM and string.format("%.1f", result.nearestDistanceM) or "",
    sanitize(result.typeSummary)
  )
end

local function markerText(result)
  return string.format(
    "%s | %s\n%s\nnearest=%s m\ntypes=%s",
    result.densityClass,
    result.label,
    countsText(result),
    result.nearestDistanceM and string.format("%.0f", result.nearestDistanceM) or "none",
    result.typeSummary ~= "" and result.typeSummary or "none"
  )
end

function MODULE.RemoveMarkers()
  local removed = 0
  for _, markerId in ipairs(MODULE.state.markerIds) do
    local ok = pcall(trigger.action.removeMark, markerId)
    if ok then removed = removed + 1 end
  end
  MODULE.state.markerIds = {}
  log(string.format("Removed %d result markers", removed))
end

function MODULE.ShowMarkers()
  MODULE.RemoveMarkers()
  local created = 0

  for index, result in ipairs(MODULE.state.results) do
    local markerId = MODULE.config.markerBaseId + index
    local ok, errorMessage = pcall(
      trigger.action.markToAll,
      markerId,
      markerText(result),
      result.point,
      MODULE.config.markerReadOnly,
      ""
    )
    if ok then
      MODULE.state.markerIds[#MODULE.state.markerIds + 1] = markerId
      created = created + 1
    else
      warn(string.format("Marker failed for %s: %s", result.id, tostring(errorMessage)))
    end
  end

  log(string.format("Created %d result markers", created))
  message(string.format("%d Scenery-Ergebnismarker angezeigt.", created), 10)
end

function MODULE.ShowSummary()
  local classCounts = {}
  for _, result in ipairs(MODULE.state.results) do
    classCounts[result.densityClass] = (classCounts[result.densityClass] or 0) + 1
  end

  local classes = {}
  for className, count in pairs(classCounts) do
    classes[#classes + 1] = string.format("%s=%d", className, count)
  end
  table.sort(classes)

  local summary = string.format(
    "version=%s | scanned=%d/%d | errors=%d | %s",
    MODULE.config.version,
    #MODULE.state.results,
    #MODULE.state.queue,
    MODULE.state.errors,
    table.concat(classes, " | ")
  )
  log("SUMMARY " .. summary)
  message(summary, 20)
end

local function processNext(generation, now)
  if generation ~= MODULE.state.generation or not MODULE.state.running then
    return nil
  end

  local item = MODULE.state.queue[MODULE.state.nextIndex]
  if not item then
    MODULE.state.running = false
    log(string.format(
      "COMPLETE version=%s scanned=%d errors=%d",
      MODULE.config.version,
      #MODULE.state.results,
      MODULE.state.errors
    ))
    MODULE.ShowSummary()
    if MODULE.config.showMarkersOnFinish then
      MODULE.ShowMarkers()
    end
    return nil
  end

  local result, errorMessage = scanItem(item)
  if result then
    MODULE.state.results[#MODULE.state.results + 1] = result
    log(resultLogLine(result))
  else
    MODULE.state.errors = MODULE.state.errors + 1
    fail(string.format(
      "SCAN_FAILED|id=%s|label=%s|error=%s",
      sanitize(item.id), sanitize(item.label), sanitize(errorMessage)
    ))
  end

  MODULE.state.nextIndex = MODULE.state.nextIndex + 1
  return now + MODULE.config.pointIntervalSeconds
end

function MODULE.Start()
  if MODULE.state.running then
    warn("Discovery is already running")
    return
  end

  if not world or type(world.searchObjects) ~= "function" then
    fail("world.searchObjects unavailable")
    message("world.searchObjects ist nicht verfügbar.", 20)
    return
  end
  if not Object or not Object.Category or Object.Category.SCENERY == nil then
    fail("Object.Category.SCENERY unavailable")
    message("Object.Category.SCENERY ist nicht verfügbar.", 20)
    return
  end
  if not world.VolumeType or world.VolumeType.BOX == nil then
    fail("world.VolumeType.BOX unavailable")
    message("world.VolumeType.BOX ist nicht verfügbar.", 20)
    return
  end

  MODULE.RemoveMarkers()
  MODULE.state.generation = MODULE.state.generation + 1
  MODULE.state.running = true
  MODULE.state.queue = {}
  MODULE.state.nextIndex = 1
  MODULE.state.results = {}
  MODULE.state.errors = 0
  MODULE.state.queue = buildQueue()

  if #MODULE.state.queue == 0 then
    MODULE.state.running = false
    fail("No scan points available")
    message("Keine Scanpunkte verfügbar.", 20)
    return
  end

  local generation = MODULE.state.generation
  log(string.format(
    "START version=%s points=%d radii=%s",
    MODULE.config.version,
    #MODULE.state.queue,
    table.concat(MODULE.config.radiiM, ",")
  ))
  message(string.format(
    "Einmaliger Scenery-Scan startet: %d Punkte.",
    #MODULE.state.queue
  ), 10)

  timer.scheduleFunction(
    processNext,
    generation,
    timer.getTime() + MODULE.config.startDelaySeconds
  )
end

local function installMenu()
  if not MODULE.config.createF10Menu or not missionCommands then
    return
  end
  if MODULE.state.menuRoot then
    return
  end

  local root = missionCommands.addSubMenu("OMW Tests")
  MODULE.state.menuRoot = missionCommands.addSubMenu("Scenery Discovery", root)
  missionCommands.addCommand("Scan starten", MODULE.state.menuRoot, MODULE.Start)
  missionCommands.addCommand("Zusammenfassung", MODULE.state.menuRoot, MODULE.ShowSummary)
  missionCommands.addCommand("Ergebnismarker anzeigen", MODULE.state.menuRoot, MODULE.ShowMarkers)
  missionCommands.addCommand("Ergebnismarker entfernen", MODULE.state.menuRoot, MODULE.RemoveMarkers)
end

installMenu()
log("Loaded " .. MODULE.config.version)

if MODULE.config.autoStart then
  MODULE.Start()
end
