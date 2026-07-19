-- OMW_SETTLEMENT_ZONES_TEST.lua
-- Operation Mountain Watch - manual settlement-zone operational prototype.
-- Load Moose.lua before this script.
--
-- Purpose:
--   1. Detect manually placed settlement trigger zones by naming convention.
--   2. Reduce convoy speed while the configured convoy is inside a settlement zone.
--   3. Route infantry to an in-settlement target mainly by road.
--   4. Route infantry around a settlement when it only blocks the direct path.
--
-- This prototype intentionally does not modify convoy spacing. It proves zone
-- discovery, profile transitions, speed control and coarse infantry routing.

OMW_SETTLEMENT_ZONES_TEST = OMW_SETTLEMENT_ZONES_TEST or {}
local MODULE = OMW_SETTLEMENT_ZONES_TEST

local DEFAULTS = {
  version = "SETTLEMENT-ZONES-TEST-01",

  convoyGroupName = "TEST_SETTLEMENT_CONVOY_01",
  infantryGroupName = "TEST_SETTLEMENT_INFANTRY_01",
  infantryTargetZoneName = "ZONE_SETTLEMENT_INFANTRY_TARGET",

  zonePrefix = "OMW_SETTLEMENT_",
  zoneIndexMax = 99,

  convoyMonitorIntervalSeconds = 1.0,
  convoyMonitorStartDelaySeconds = 2.0,

  convoySpeedKmh = {
    OUTSIDE = 50,
    SPARSE = 35,
    VILLAGE = 25,
    URBAN = 18,
    CITY = 12,
  },

  infantryDirectSpeedKmh = 6,
  infantryRoadSpeedKmh = 8,
  infantryDetourBufferM = 300,

  markerBaseId = 880000,
  showReadyMessage = true,
}

local function copyDefaults(target, defaults)
  for key, value in pairs(defaults) do
    if target[key] == nil then
      if type(value) == "table" then
        target[key] = {}
        copyDefaults(target[key], value)
      else
        target[key] = value
      end
    elseif type(value) == "table" and type(target[key]) == "table" then
      copyDefaults(target[key], value)
    end
  end
end

MODULE.config = MODULE.config or {}
copyDefaults(MODULE.config, DEFAULTS)

MODULE.state = MODULE.state or {
  zones = {},
  convoyProfile = nil,
  convoyZoneName = nil,
  convoyMissingReported = false,
  markerIds = {},
  menuRoot = nil,
  menuTest = nil,
}

local PREFIX = "[OMW][SETTLEMENT-ZONES]"

local CLASS_DEFINITIONS = {
  { class = "SPARSE", priority = 1 },
  { class = "VILLAGE", priority = 2 },
  { class = "URBAN", priority = 3 },
  { class = "CITY", priority = 4 },
}

local function logInfo(message)
  if env and env.info then
    env.info(PREFIX .. " " .. tostring(message))
  end
end

local function logWarning(message)
  if env and env.warning then
    env.warning(PREFIX .. " " .. tostring(message))
  elseif env and env.info then
    env.info(PREFIX .. " WARNING " .. tostring(message))
  end
end

local function logError(message)
  if env and env.error then
    env.error(PREFIX .. " " .. tostring(message))
  elseif env and env.info then
    env.info(PREFIX .. " ERROR " .. tostring(message))
  end
end

local function showMessage(message, duration)
  if trigger and trigger.action and trigger.action.outText then
    trigger.action.outText("OMW Settlement Zones\n" .. tostring(message), duration or 12)
  end
end

local function countByClass()
  local counts = {
    SPARSE = 0,
    VILLAGE = 0,
    URBAN = 0,
    CITY = 0,
  }

  for _, record in ipairs(MODULE.state.zones) do
    counts[record.class] = (counts[record.class] or 0) + 1
  end

  return counts
end

local function discoverZones()
  MODULE.state.zones = {}

  for _, definition in ipairs(CLASS_DEFINITIONS) do
    for index = 1, MODULE.config.zoneIndexMax do
      local zoneName = string.format(
        "%s%s_%03d",
        MODULE.config.zonePrefix,
        definition.class,
        index
      )

      local zone = ZONE:FindByName(zoneName)
      if zone then
        local x1, x2, y1, y2 = zone:GetBoundingSquare()
        MODULE.state.zones[#MODULE.state.zones + 1] = {
          name = zoneName,
          class = definition.class,
          priority = definition.priority,
          zone = zone,
          bounds = {
            x1 = math.min(x1, x2),
            x2 = math.max(x1, x2),
            y1 = math.min(y1, y2),
            y2 = math.max(y1, y2),
          },
        }
      end
    end
  end

  table.sort(MODULE.state.zones, function(a, b)
    if a.priority == b.priority then
      return a.name < b.name
    end
    return a.priority > b.priority
  end)

  local counts = countByClass()
  logInfo(string.format(
    "zone_discovery_complete version=%s total=%d sparse=%d village=%d urban=%d city=%d",
    MODULE.config.version,
    #MODULE.state.zones,
    counts.SPARSE,
    counts.VILLAGE,
    counts.URBAN,
    counts.CITY
  ))
end

local function findGroup(groupName)
  local group = GROUP:FindByName(groupName)
  if not group or not group:IsAlive() then
    return nil
  end
  return group
end

local function findContainingZone(group)
  local selected = nil

  for _, record in ipairs(MODULE.state.zones) do
    local ok, inside = pcall(group.IsInZone, group, record.zone)
    if ok and inside then
      if not selected or record.priority > selected.priority then
        selected = record
      end
    end
  end

  return selected
end

local function setConvoyProfile(group, profile, zoneName)
  local speedKmh = MODULE.config.convoySpeedKmh[profile]
  if not speedKmh then
    logError("No convoy speed configured for profile " .. tostring(profile))
    return false
  end

  local ok, result = pcall(group.SetSpeed, group, speedKmh / 3.6, true)
  if not ok then
    logError(string.format(
      "convoy_speed_failed group=%s profile=%s speed_kmh=%s error=%s",
      MODULE.config.convoyGroupName,
      tostring(profile),
      tostring(speedKmh),
      tostring(result)
    ))
    return false
  end

  MODULE.state.convoyProfile = profile
  MODULE.state.convoyZoneName = zoneName

  local zoneText = zoneName or "NONE"
  logInfo(string.format(
    "convoy_profile_changed group=%s profile=%s speed_kmh=%d zone=%s",
    MODULE.config.convoyGroupName,
    profile,
    speedKmh,
    zoneText
  ))
  showMessage(string.format(
    "Convoy: %s | %d km/h | Zone: %s",
    profile,
    speedKmh,
    zoneText
  ), 8)

  return true
end

function MODULE.UpdateConvoy()
  local group = findGroup(MODULE.config.convoyGroupName)
  if not group then
    if not MODULE.state.convoyMissingReported then
      MODULE.state.convoyMissingReported = true
      logWarning("Convoy group not active: " .. MODULE.config.convoyGroupName)
    end
    return
  end

  if MODULE.state.convoyMissingReported then
    MODULE.state.convoyMissingReported = false
    logInfo("Convoy group became active: " .. MODULE.config.convoyGroupName)
  end

  local record = findContainingZone(group)
  local profile = record and record.class or "OUTSIDE"
  local zoneName = record and record.name or nil

  if profile ~= MODULE.state.convoyProfile or zoneName ~= MODULE.state.convoyZoneName then
    setConvoyProfile(group, profile, zoneName)
  end
end

local function convoyMonitor(_, now)
  local ok, errorMessage = pcall(MODULE.UpdateConvoy)
  if not ok then
    logError("convoy_monitor_error " .. tostring(errorMessage))
  end
  return now + MODULE.config.convoyMonitorIntervalSeconds
end

local function vec2FromCoordinate(coordinate)
  if not coordinate then
    return nil
  end

  local ok, value = pcall(coordinate.GetVec2, coordinate)
  if ok and type(value) == "table" and value.x and value.y then
    return { x = value.x, y = value.y }
  end

  local okVec3, vec3 = pcall(coordinate.GetVec3, coordinate)
  if okVec3 and type(vec3) == "table" and vec3.x and vec3.z then
    return { x = vec3.x, y = vec3.z }
  end

  return nil
end

local function pointInsideBounds(point, bounds)
  return point.x >= bounds.x1 and point.x <= bounds.x2
    and point.y >= bounds.y1 and point.y <= bounds.y2
end

local function expandedBounds(bounds, bufferM)
  return {
    x1 = bounds.x1 - bufferM,
    x2 = bounds.x2 + bufferM,
    y1 = bounds.y1 - bufferM,
    y2 = bounds.y2 + bufferM,
  }
end

local function clipAxis(position, delta, minimum, maximum, tMinimum, tMaximum)
  local epsilon = 0.000001
  if math.abs(delta) < epsilon then
    if position < minimum or position > maximum then
      return nil, nil
    end
    return tMinimum, tMaximum
  end

  local t1 = (minimum - position) / delta
  local t2 = (maximum - position) / delta
  if t1 > t2 then
    t1, t2 = t2, t1
  end

  tMinimum = math.max(tMinimum, t1)
  tMaximum = math.min(tMaximum, t2)
  if tMinimum > tMaximum then
    return nil, nil
  end

  return tMinimum, tMaximum
end

local function segmentIntersectsBounds(startPoint, endPoint, bounds)
  if pointInsideBounds(startPoint, bounds) or pointInsideBounds(endPoint, bounds) then
    return true
  end

  local deltaX = endPoint.x - startPoint.x
  local deltaY = endPoint.y - startPoint.y
  local tMinimum, tMaximum = 0, 1

  tMinimum, tMaximum = clipAxis(
    startPoint.x,
    deltaX,
    bounds.x1,
    bounds.x2,
    tMinimum,
    tMaximum
  )
  if not tMinimum then
    return false
  end

  tMinimum, tMaximum = clipAxis(
    startPoint.y,
    deltaY,
    bounds.y1,
    bounds.y2,
    tMinimum,
    tMaximum
  )

  return tMinimum ~= nil
end

local function squaredDistance(a, b)
  local deltaX = b.x - a.x
  local deltaY = b.y - a.y
  return deltaX * deltaX + deltaY * deltaY
end

local function findTargetContainingZone(targetPoint)
  for _, record in ipairs(MODULE.state.zones) do
    local bounds = record.bounds
    if pointInsideBounds(targetPoint, bounds) then
      return record
    end
  end
  return nil
end

local function findFirstBlockingZone(startPoint, targetPoint)
  local selected = nil
  local selectedDistance = nil

  for _, record in ipairs(MODULE.state.zones) do
    local bounds = expandedBounds(record.bounds, MODULE.config.infantryDetourBufferM)
    if segmentIntersectsBounds(startPoint, targetPoint, bounds)
      and not pointInsideBounds(targetPoint, bounds) then
      local center = {
        x = (bounds.x1 + bounds.x2) / 2,
        y = (bounds.y1 + bounds.y2) / 2,
      }
      local distance = squaredDistance(startPoint, center)
      if not selected or distance < selectedDistance then
        selected = record
        selectedDistance = distance
      end
    end
  end

  return selected
end

local function candidateIsClear(startPoint, targetPoint, candidate, bounds)
  return not segmentIntersectsBounds(startPoint, candidate, bounds)
    and not segmentIntersectsBounds(candidate, targetPoint, bounds)
end

local function chooseDetourPoint(startPoint, targetPoint, record)
  local margin = MODULE.config.infantryDetourBufferM
  local bounds = expandedBounds(record.bounds, margin)
  local extra = 25

  local candidates = {
    { x = bounds.x1 - extra, y = bounds.y1 - extra },
    { x = bounds.x1 - extra, y = bounds.y2 + extra },
    { x = bounds.x2 + extra, y = bounds.y1 - extra },
    { x = bounds.x2 + extra, y = bounds.y2 + extra },
  }

  local best = nil
  local bestCost = nil

  for _, candidate in ipairs(candidates) do
    if candidateIsClear(startPoint, targetPoint, candidate, bounds) then
      local cost = math.sqrt(squaredDistance(startPoint, candidate))
        + math.sqrt(squaredDistance(candidate, targetPoint))
      if not best or cost < bestCost then
        best = candidate
        bestCost = cost
      end
    end
  end

  if best then
    return best
  end

  -- Conservative fallback: use the shortest outer corner even when the simple
  -- rectangle test cannot prove two clear legs. This still places the waypoint
  -- outside the operational settlement buffer and is reported explicitly.
  for _, candidate in ipairs(candidates) do
    local cost = math.sqrt(squaredDistance(startPoint, candidate))
      + math.sqrt(squaredDistance(candidate, targetPoint))
    if not best or cost < bestCost then
      best = candidate
      bestCost = cost
    end
  end

  logWarning("Detour fallback used for zone " .. record.name)
  return best
end

local function buildDetourRoute(group, startCoordinate, detourPoint, targetCoordinate)
  local detourCoordinate = COORDINATE:NewFromVec2(detourPoint)
  local route = {
    startCoordinate:WaypointGround(MODULE.config.infantryDirectSpeedKmh, "Off Road"),
    detourCoordinate:WaypointGround(MODULE.config.infantryDirectSpeedKmh, "Off Road"),
    targetCoordinate:WaypointGround(MODULE.config.infantryDirectSpeedKmh, "Off Road"),
  }

  group:Route(route, 1)
end

function MODULE.RouteInfantry()
  local group = findGroup(MODULE.config.infantryGroupName)
  if not group then
    local message = "Infanteriegruppe fehlt oder ist nicht aktiv: "
      .. MODULE.config.infantryGroupName
    logWarning(message)
    showMessage(message, 15)
    return
  end

  local targetZone = ZONE:FindByName(MODULE.config.infantryTargetZoneName)
  if not targetZone then
    local message = "Zielzone fehlt: " .. MODULE.config.infantryTargetZoneName
    logWarning(message)
    showMessage(message, 15)
    return
  end

  local startCoordinate = group:GetCoordinate()
  local targetCoordinate = targetZone:GetCoordinate()
  local startPoint = vec2FromCoordinate(startCoordinate)
  local targetPoint = vec2FromCoordinate(targetCoordinate)

  if not startPoint or not targetPoint then
    local message = "Start- oder Zielkoordinate konnte nicht gelesen werden."
    logError(message)
    showMessage(message, 15)
    return
  end

  local targetRecord = findTargetContainingZone(targetPoint)
  if targetRecord then
    local ok, errorMessage = pcall(
      group.RouteGroundOnRoad,
      group,
      targetCoordinate,
      MODULE.config.infantryRoadSpeedKmh,
      1,
      "Off Road"
    )

    if not ok then
      logError("infantry_route_on_road_failed " .. tostring(errorMessage))
      showMessage("Straßenroute konnte nicht gesetzt werden.", 15)
      return
    end

    logInfo(string.format(
      "infantry_route_set mode=ROAD_TO_TARGET group=%s target=%s settlement=%s speed_kmh=%d",
      MODULE.config.infantryGroupName,
      MODULE.config.infantryTargetZoneName,
      targetRecord.name,
      MODULE.config.infantryRoadSpeedKmh
    ))
    showMessage(string.format(
      "Infanterie: Ziel liegt in %s. Straßenroute zum Ziel gesetzt.",
      targetRecord.name
    ), 15)
    return
  end

  local blockingRecord = findFirstBlockingZone(startPoint, targetPoint)
  if blockingRecord then
    local detourPoint = chooseDetourPoint(startPoint, targetPoint, blockingRecord)
    local ok, errorMessage = pcall(
      buildDetourRoute,
      group,
      startCoordinate,
      detourPoint,
      targetCoordinate
    )

    if not ok then
      logError("infantry_detour_route_failed " .. tostring(errorMessage))
      showMessage("Umgehungsroute konnte nicht gesetzt werden.", 15)
      return
    end

    logInfo(string.format(
      "infantry_route_set mode=DETOUR group=%s target=%s settlement=%s buffer_m=%d detour_x=%.1f detour_y=%.1f speed_kmh=%d",
      MODULE.config.infantryGroupName,
      MODULE.config.infantryTargetZoneName,
      blockingRecord.name,
      MODULE.config.infantryDetourBufferM,
      detourPoint.x,
      detourPoint.y,
      MODULE.config.infantryDirectSpeedKmh
    ))
    showMessage(string.format(
      "Infanterie: %s wird mit %d m Puffer umgangen.",
      blockingRecord.name,
      MODULE.config.infantryDetourBufferM
    ), 15)
    return
  end

  local ok, errorMessage = pcall(
    group.RouteGroundTo,
    group,
    targetCoordinate,
    MODULE.config.infantryDirectSpeedKmh,
    "Off Road",
    1
  )

  if not ok then
    logError("infantry_direct_route_failed " .. tostring(errorMessage))
    showMessage("Direktroute konnte nicht gesetzt werden.", 15)
    return
  end

  logInfo(string.format(
    "infantry_route_set mode=DIRECT group=%s target=%s speed_kmh=%d",
    MODULE.config.infantryGroupName,
    MODULE.config.infantryTargetZoneName,
    MODULE.config.infantryDirectSpeedKmh
  ))
  showMessage("Infanterie: Keine Siedlung blockiert die Direktroute.", 15)
end

function MODULE.RemoveZoneMarkers()
  local removed = 0
  for _, markerId in ipairs(MODULE.state.markerIds) do
    local ok = pcall(trigger.action.removeMark, markerId)
    if ok then
      removed = removed + 1
    end
  end
  MODULE.state.markerIds = {}
  logInfo("zone_markers_removed count=" .. tostring(removed))
  showMessage(string.format("%d Zonenmarker entfernt.", removed), 8)
end

function MODULE.ShowZoneMarkers()
  MODULE.RemoveZoneMarkers()

  local created = 0
  for index, record in ipairs(MODULE.state.zones) do
    local coordinate = record.zone:GetCoordinate()
    local point = coordinate and coordinate:GetVec3() or nil
    if point then
      local markerId = MODULE.config.markerBaseId + index
      local text = string.format("%s\nKlasse: %s", record.name, record.class)
      local ok = pcall(
        trigger.action.markToAll,
        markerId,
        text,
        point,
        true,
        ""
      )
      if ok then
        MODULE.state.markerIds[#MODULE.state.markerIds + 1] = markerId
        created = created + 1
      end
    end
  end

  logInfo("zone_markers_created count=" .. tostring(created))
  showMessage(string.format("%d Siedlungszonen markiert.", created), 10)
end

function MODULE.ShowStatus()
  local counts = countByClass()
  local convoy = findGroup(MODULE.config.convoyGroupName)
  local infantry = findGroup(MODULE.config.infantryGroupName)
  local target = ZONE:FindByName(MODULE.config.infantryTargetZoneName)

  local text = string.format(
    "Version: %s\nZonen: %d (S:%d V:%d U:%d C:%d)\nConvoy: %s | Profil: %s\nInfanterie: %s | Zielzone: %s",
    MODULE.config.version,
    #MODULE.state.zones,
    counts.SPARSE,
    counts.VILLAGE,
    counts.URBAN,
    counts.CITY,
    convoy and "AKTIV" or "FEHLT",
    MODULE.state.convoyProfile or "UNBEKANNT",
    infantry and "AKTIV" or "FEHLT",
    target and "VORHANDEN" or "FEHLT"
  )

  logInfo("status_requested")
  showMessage(text, 20)
end

local function installMenu()
  if not missionCommands then
    logWarning("missionCommands unavailable; F10 menu not installed")
    return
  end

  MODULE.state.menuRoot = missionCommands.addSubMenu("OMW Tests")
  MODULE.state.menuTest = missionCommands.addSubMenu(
    "Settlement Zones",
    MODULE.state.menuRoot
  )

  missionCommands.addCommand(
    "Status anzeigen",
    MODULE.state.menuTest,
    MODULE.ShowStatus
  )
  missionCommands.addCommand(
    "Zonen markieren",
    MODULE.state.menuTest,
    MODULE.ShowZoneMarkers
  )
  missionCommands.addCommand(
    "Zonenmarker entfernen",
    MODULE.state.menuTest,
    MODULE.RemoveZoneMarkers
  )
  missionCommands.addCommand(
    "Infanterieroute berechnen",
    MODULE.state.menuTest,
    MODULE.RouteInfantry
  )
end

local function validateMoose()
  local required = {
    { name = "GROUP", value = GROUP },
    { name = "ZONE", value = ZONE },
    { name = "COORDINATE", value = COORDINATE },
  }

  local missing = {}
  for _, item in ipairs(required) do
    if type(item.value) ~= "table" then
      missing[#missing + 1] = item.name
    end
  end

  if #missing > 0 then
    local message = "MOOSE fehlt oder wurde zu spaet geladen: " .. table.concat(missing, ", ")
    logError(message)
    showMessage(message, 30)
    return false
  end

  return true
end

local function start()
  if not validateMoose() then
    return
  end

  discoverZones()
  installMenu()

  timer.scheduleFunction(
    convoyMonitor,
    nil,
    timer.getTime() + MODULE.config.convoyMonitorStartDelaySeconds
  )

  local counts = countByClass()
  local readyText = string.format(
    "Bereit: %d Zonen erkannt (S:%d V:%d U:%d C:%d).",
    #MODULE.state.zones,
    counts.SPARSE,
    counts.VILLAGE,
    counts.URBAN,
    counts.CITY
  )
  logInfo("startup_complete " .. readyText)

  if MODULE.config.showReadyMessage then
    showMessage(readyText, 15)
  end
end

start()
