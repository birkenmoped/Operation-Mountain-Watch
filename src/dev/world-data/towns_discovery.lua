-- Operation Mountain Watch: Afghanistan TOWNS discovery.
-- Load Moose.lua first. Run only in a dedicated development mission.

OMW_TOWNS_DISCOVERY_CONFIG = OMW_TOWNS_DISCOVERY_CONFIG or {}

local defaults = {
  terrainName = "Afghanistan",
  townsFile = nil,
  outputBaseName = "OMW-Towns-Afghanistan",
  showMarkersOnStart = true,
  createF10Menu = true,
  writeFiles = true,
  logEachTown = true,
  markerLimit = 0,             -- 0 = all
  markerTextMode = "INDEX_NAME", -- NAME, INDEX_NAME, FULL
  nearestNeighborMaxCount = 2500,
}

local cfg = {}
for key, value in pairs(defaults) do cfg[key] = value end
for key, value in pairs(OMW_TOWNS_DISCOVERY_CONFIG) do cfg[key] = value end

local PREFIX = "[OMW-TOWNS]"
local state = { rows = {}, markerIDs = {}, summary = nil, sourceFile = nil }

local function info(text) env.info(PREFIX .. " " .. tostring(text)) end
local function warn(text) env.warning(PREFIX .. " " .. tostring(text)) end
local function fail(text) env.error(PREFIX .. " " .. tostring(text)) end
local function message(text, seconds)
  trigger.action.outText("OMW TOWNS Discovery\n" .. tostring(text), seconds or 15)
end

local function call(object, methodName, ...)
  if not object or type(object[methodName]) ~= "function" then return nil end
  local ok, result = pcall(object[methodName], object, ...)
  if ok then return result end
  return nil
end

local function vec3(coordinate)
  if not coordinate then return nil end
  local value = call(coordinate, "GetVec3")
  if value then return value end
  if coordinate.x and coordinate.z then
    return { x = coordinate.x, y = coordinate.y or 0, z = coordinate.z }
  end
  return nil
end

local function distance(a, b)
  if not a or not b then return nil end
  local value = call(a, "Get2DDistance", b)
  if type(value) == "number" then return value end
  local av, bv = vec3(a), vec3(b)
  if not av or not bv then return nil end
  local dx, dz = av.x - bv.x, av.z - bv.z
  return math.sqrt(dx * dx + dz * dz)
end

local function number(value, decimals)
  if type(value) ~= "number" then return "" end
  return string.format("%." .. tostring(decimals or 3) .. "f", value)
end

local function csv(value)
  if value == nil then return "" end
  local text = tostring(value)
  if text:find('[,\r\n"]') then text = '"' .. text:gsub('"', '""') .. '"' end
  return text
end

local function quote(value) return string.format("%q", tostring(value)) end

local function fileExists(path)
  if not path then return false end
  if UTILS and UTILS.FileExists then
    local ok, exists = pcall(UTILS.FileExists, path)
    if ok then return exists == true end
  end
  if io and io.open then
    local file = io.open(path, "r")
    if file then file:close(); return true end
  end
  return false
end

local function findTownsFile()
  local candidates, seen = {}, {}
  local function add(path)
    if path and path ~= "" and not seen[path] then
      seen[path] = true
      table.insert(candidates, path)
    end
  end

  add(cfg.townsFile)
  if lfs and lfs.currentdir then
    local ok, cwd = pcall(lfs.currentdir)
    if ok and cwd then
      cwd = cwd:gsub("[\\/]+$", "")
      local suffix = string.format("Mods\\terrains\\%s\\Map\\towns.lua", cfg.terrainName)
      add(cwd .. "\\" .. suffix)
      add(cwd .. "\\..\\" .. suffix)
      add(cwd .. "\\..\\..\\" .. suffix)
      add(cwd .. "\\..\\..\\..\\" .. suffix)
    end
  end

  for _, path in ipairs(candidates) do
    info("Pruefe towns.lua: " .. path)
    if fileExists(path) then return path, candidates end
  end
  return nil, candidates
end

local DERIVED = { name=true, coordinate=true, coordRoad=true, coordRail=true, markerID=true }

local function sourceFields(town)
  local fields = {}
  for key, value in pairs(town) do
    local kind = type(value)
    if not DERIVED[key] and (kind == "string" or kind == "number" or kind == "boolean") then
      fields[key] = value
    end
  end
  return fields
end

local function buildRows(towns)
  local rows = {}
  for sourceIndex, town in ipairs(towns) do
    local point, road, rail = vec3(town.coordinate), vec3(town.coordRoad), vec3(town.coordRail)
    local elevation, surfaceType = nil, nil
    if point and land then
      local p2 = { x = point.x, y = point.z }
      if land.getHeight then
        local ok, value = pcall(land.getHeight, p2); if ok then elevation = value end
      end
      if land.getSurfaceType then
        local ok, value = pcall(land.getSurfaceType, p2); if ok then surfaceType = value end
      end
    end

    table.insert(rows, {
      sourceIndex = sourceIndex,
      town = town,
      name = town.name or "",
      displayName = town.display_name or town.name or "",
      latitude = town.latitude,
      longitude = town.longitude,
      x = point and point.x or nil,
      y = point and point.y or nil,
      z = point and point.z or nil,
      elevation = elevation,
      surfaceType = surfaceType,
      mgrs = call(town.coordinate, "ToStringMGRS") or "",
      llDdm = call(town.coordinate, "ToStringLLDDM") or "",
      roadX = road and road.x or nil,
      roadY = road and road.y or nil,
      roadZ = road and road.z or nil,
      roadDistance = distance(town.coordinate, town.coordRoad),
      railX = rail and rail.x or nil,
      railY = rail and rail.y or nil,
      railZ = rail and rail.z or nil,
      railDistance = distance(town.coordinate, town.coordRail),
      nearestName = "",
      nearestDistance = nil,
      fields = sourceFields(town),
    })
  end

  table.sort(rows, function(a, b)
    local an, bn = string.lower(a.displayName), string.lower(b.displayName)
    if an == bn then return a.sourceIndex < b.sourceIndex end
    return an < bn
  end)
  for index, row in ipairs(rows) do row.index = index end
  return rows
end

local function addNearestNeighbors(rows)
  if #rows > cfg.nearestNeighborMaxCount then
    return "uebersprungen: zu viele Eintraege"
  end
  for i, row in ipairs(rows) do
    local bestDistance, bestName = math.huge, ""
    for j, other in ipairs(rows) do
      if i ~= j then
        local value = distance(row.town.coordinate, other.town.coordinate)
        if value and value < bestDistance then
          bestDistance = value
          bestName = other.displayName
        end
      end
    end
    if bestDistance < math.huge then
      row.nearestDistance, row.nearestName = bestDistance, bestName
    end
  end
  return "berechnet"
end

local function fieldInventory(rows)
  local map = {}
  for _, row in ipairs(rows) do
    for key, value in pairs(row.fields) do
      local item = map[key]
      if not item then
        item = { field=key, count=0, types={}, samples={}, sampleSeen={} }
        map[key] = item
      end
      item.count = item.count + 1
      item.types[type(value)] = true
      local sample = tostring(value)
      if #item.samples < 5 and not item.sampleSeen[sample] then
        item.sampleSeen[sample] = true
        table.insert(item.samples, sample)
      end
    end
  end

  local result = {}
  for _, item in pairs(map) do
    local types = {}
    for kind, _ in pairs(item.types) do table.insert(types, kind) end
    table.sort(types)
    item.typeList = table.concat(types, "|")
    table.insert(result, item)
  end
  table.sort(result, function(a, b) return a.field < b.field end)
  return result
end

local function summarize(rows, nearestStatus)
  local summary = {
    total=#rows, uniqueNames=0, duplicateNames=0, duplicateCoordinates=0,
    missingDisplayName=0, missingLatitude=0, missingLongitude=0,
    missingRoad=0, missingRail=0, nearestStatus=nearestStatus,
    roadMin=nil, roadMax=nil, roadAverage=nil,
    railMin=nil, railMax=nil, railAverage=nil,
    latMin=nil, latMax=nil, lonMin=nil, lonMax=nil,
  }
  local names, coordinates = {}, {}
  local roadTotal, roadCount, railTotal, railCount = 0, 0, 0, 0

  for _, row in ipairs(rows) do
    local key = string.lower(row.name ~= "" and row.name or row.displayName)
    names[key] = (names[key] or 0) + 1
    if row.latitude and row.longitude then
      local ckey = string.format("%.7f|%.7f", row.latitude, row.longitude)
      coordinates[ckey] = (coordinates[ckey] or 0) + 1
    end

    if row.displayName == "" then summary.missingDisplayName = summary.missingDisplayName + 1 end
    if type(row.latitude) == "number" then
      summary.latMin = math.min(summary.latMin or row.latitude, row.latitude)
      summary.latMax = math.max(summary.latMax or row.latitude, row.latitude)
    else summary.missingLatitude = summary.missingLatitude + 1 end
    if type(row.longitude) == "number" then
      summary.lonMin = math.min(summary.lonMin or row.longitude, row.longitude)
      summary.lonMax = math.max(summary.lonMax or row.longitude, row.longitude)
    else summary.missingLongitude = summary.missingLongitude + 1 end

    if not row.roadX or not row.roadZ then summary.missingRoad = summary.missingRoad + 1 end
    if not row.railX or not row.railZ then summary.missingRail = summary.missingRail + 1 end

    if row.roadDistance then
      roadTotal, roadCount = roadTotal + row.roadDistance, roadCount + 1
      summary.roadMin = math.min(summary.roadMin or row.roadDistance, row.roadDistance)
      summary.roadMax = math.max(summary.roadMax or row.roadDistance, row.roadDistance)
    end
    if row.railDistance then
      railTotal, railCount = railTotal + row.railDistance, railCount + 1
      summary.railMin = math.min(summary.railMin or row.railDistance, row.railDistance)
      summary.railMax = math.max(summary.railMax or row.railDistance, row.railDistance)
    end
  end

  for _, count in pairs(names) do
    summary.uniqueNames = summary.uniqueNames + 1
    if count > 1 then summary.duplicateNames = summary.duplicateNames + count - 1 end
  end
  for _, count in pairs(coordinates) do
    if count > 1 then summary.duplicateCoordinates = summary.duplicateCoordinates + count - 1 end
  end
  if roadCount > 0 then summary.roadAverage = roadTotal / roadCount end
  if railCount > 0 then summary.railAverage = railTotal / railCount end
  return summary
end

local function markerText(row)
  if cfg.markerTextMode == "NAME" then return row.displayName end
  if cfg.markerTextMode == "FULL" then
    return string.format("%04d | %s\nLL %.6f %.6f\nRoad %.0f m",
      row.index, row.displayName, row.latitude or 0, row.longitude or 0, row.roadDistance or -1)
  end
  return string.format("%04d | %s", row.index, row.displayName)
end

local function removeMarkers(silent)
  for _, markerID in ipairs(state.markerIDs) do
    if UTILS and UTILS.RemoveMark then pcall(UTILS.RemoveMark, markerID)
    elseif trigger.action.removeMark then pcall(trigger.action.removeMark, markerID) end
  end
  state.markerIDs = {}
  info("Alle Discovery-Marker entfernt")
  if not silent then message("Alle TOWNS-Marker wurden entfernt.", 10) end
end

local function showMarkers()
  removeMarkers(true)
  local marked = 0
  for _, row in ipairs(state.rows) do
    if cfg.markerLimit == 0 or marked < cfg.markerLimit then
      local markerID = call(row.town.coordinate, "MarkToAll", markerText(row))
      if markerID then table.insert(state.markerIDs, markerID); marked = marked + 1 end
    end
  end
  info(string.format("%d von %d Ortsreferenzen markiert", marked, #state.rows))
  message(string.format("%d von %d Ortsreferenzen auf der F10-Karte markiert.", marked, #state.rows), 15)
end

local function outputDirectory()
  if not cfg.writeFiles or not lfs or not lfs.writedir then return nil end
  local ok, path = pcall(lfs.writedir)
  if not ok or not path then return nil end
  return path:gsub("[\\/]+$", "") .. "\\Logs\\"
end

local function write(path, content)
  if not io or not io.open then return false, "io.open nicht verfuegbar" end
  local file, errorMessage = io.open(path, "w")
  if not file then return false, errorMessage end
  file:write(content); file:close(); return true
end

local function renderRowsCsv(rows)
  local lines = { table.concat({
    "index","source_index","name","display_name","latitude","longitude",
    "x","y","z","elevation_m","surface_type","mgrs","ll_ddm",
    "road_x","road_y","road_z","road_distance_m",
    "rail_x","rail_y","rail_z","rail_distance_m",
    "nearest_town","nearest_town_distance_m"
  }, ",") }
  for _, row in ipairs(rows) do
    table.insert(lines, table.concat({
      csv(row.index), csv(row.sourceIndex), csv(row.name), csv(row.displayName),
      csv(number(row.latitude,8)), csv(number(row.longitude,8)),
      csv(number(row.x)), csv(number(row.y)), csv(number(row.z)),
      csv(number(row.elevation)), csv(row.surfaceType), csv(row.mgrs), csv(row.llDdm),
      csv(number(row.roadX)), csv(number(row.roadY)), csv(number(row.roadZ)), csv(number(row.roadDistance)),
      csv(number(row.railX)), csv(number(row.railY)), csv(number(row.railZ)), csv(number(row.railDistance)),
      csv(row.nearestName), csv(number(row.nearestDistance))
    }, ","))
  end
  return table.concat(lines, "\r\n") .. "\r\n"
end

local function renderFieldsCsv(inventory, total)
  local lines = { "field,lua_types,populated_count,total_count,populated_percent,samples" }
  for _, item in ipairs(inventory) do
    table.insert(lines, table.concat({
      csv(item.field), csv(item.typeList), csv(item.count), csv(total),
      csv(number(total > 0 and item.count * 100 / total or 0, 2)),
      csv(table.concat(item.samples, " | "))
    }, ","))
  end
  return table.concat(lines, "\r\n") .. "\r\n"
end

local function renderLua(rows)
  local lines = {
    "-- Generated by OMW TOWNS Discovery.",
    "-- Source: " .. tostring(state.sourceFile),
    "-- Review before production use.", "", "OMW_TOWNS_AFGHANISTAN = {"
  }
  local used = {}
  for _, row in ipairs(rows) do
    local base = row.name ~= "" and row.name or ("TOWN_" .. row.index)
    local key, suffix = base, 1
    while used[key] do suffix = suffix + 1; key = base .. "__" .. suffix end
    used[key] = true
    table.insert(lines, "  [" .. quote(key) .. "] = {")
    table.insert(lines, "    display_name = " .. quote(row.displayName) .. ",")
    if row.latitude then table.insert(lines, string.format("    latitude = %.10f,", row.latitude)) end
    if row.longitude then table.insert(lines, string.format("    longitude = %.10f,", row.longitude)) end
    table.insert(lines, "    source_name = " .. quote(row.name) .. ",")
    table.insert(lines, "    source_index = " .. row.sourceIndex .. ",")
    local keys = {}
    for field, _ in pairs(row.fields) do
      if field ~= "display_name" and field ~= "latitude" and field ~= "longitude" then table.insert(keys, field) end
    end
    table.sort(keys)
    for _, field in ipairs(keys) do
      local value = row.fields[field]
      if type(value) == "string" then table.insert(lines, "    [" .. quote(field) .. "] = " .. quote(value) .. ",")
      else table.insert(lines, "    [" .. quote(field) .. "] = " .. tostring(value) .. ",") end
    end
    table.insert(lines, "  },")
  end
  table.insert(lines, "}"); table.insert(lines, ""); table.insert(lines, "return OMW_TOWNS_AFGHANISTAN")
  return table.concat(lines, "\r\n") .. "\r\n"
end

local function renderSummary(summary, inventory)
  local lines = {
    "Operation Mountain Watch - TOWNS Discovery Summary",
    "=================================================", "",
    "Terrain: " .. cfg.terrainName,
    "Source: " .. tostring(state.sourceFile),
    "Total entries: " .. summary.total,
    "Unique names: " .. summary.uniqueNames,
    "Duplicate name entries: " .. summary.duplicateNames,
    "Duplicate coordinate entries: " .. summary.duplicateCoordinates,
    "Missing display_name: " .. summary.missingDisplayName,
    "Missing latitude: " .. summary.missingLatitude,
    "Missing longitude: " .. summary.missingLongitude,
    "Missing road point: " .. summary.missingRoad,
    "Missing rail point: " .. summary.missingRail,
    "Nearest-neighbor analysis: " .. summary.nearestStatus, "",
    "Latitude bounds: " .. number(summary.latMin,8) .. " .. " .. number(summary.latMax,8),
    "Longitude bounds: " .. number(summary.lonMin,8) .. " .. " .. number(summary.lonMax,8),
    "Road distance m (min/avg/max): " .. number(summary.roadMin,2) .. " / " .. number(summary.roadAverage,2) .. " / " .. number(summary.roadMax,2),
    "Rail distance m (min/avg/max): " .. number(summary.railMin,2) .. " / " .. number(summary.railAverage,2) .. " / " .. number(summary.railMax,2),
    "", "Source field inventory:"
  }
  for _, item in ipairs(inventory) do
    table.insert(lines, string.format("- %s | types=%s | populated=%d/%d | samples=%s",
      item.field, item.typeList, item.count, summary.total, table.concat(item.samples, " | ")))
  end
  return table.concat(lines, "\r\n") .. "\r\n"
end

local function exportFiles(rows, summary, inventory)
  local directory = outputDirectory()
  if not directory then warn("Dateiexport nicht verfuegbar; dcs.log bleibt als Fallback") return end
  local outputs = {
    [".csv"] = renderRowsCsv(rows),
    ["-fields.csv"] = renderFieldsCsv(inventory, #rows),
    [".lua"] = renderLua(rows),
    ["-summary.txt"] = renderSummary(summary, inventory),
  }
  for suffix, content in pairs(outputs) do
    local path = directory .. cfg.outputBaseName .. suffix
    local ok, errorMessage = write(path, content)
    if ok then info("Export geschrieben: " .. path)
    else fail("Export fehlgeschlagen: " .. path .. " | " .. tostring(errorMessage)) end
  end
end

local function printSummary()
  if not state.summary then message("Noch keine Daten geladen.", 10); return end
  local text = string.format("%d Eintraege | %d eindeutige Namen | %d Namensduplikate | Road avg %s m",
    state.summary.total, state.summary.uniqueNames, state.summary.duplicateNames, number(state.summary.roadAverage,1))
  info("SUMMARY " .. text); message(text, 20)
end

local function installMenu()
  if not cfg.createF10Menu or not missionCommands then return end
  local root = missionCommands.addSubMenu("OMW World Data")
  missionCommands.addCommand("TOWNS: Zusammenfassung", root, printSummary)
  missionCommands.addCommand("TOWNS: Marker anzeigen", root, showMarkers)
  missionCommands.addCommand("TOWNS: Marker entfernen", root, removeMarkers)
end

local function run()
  info("Starte TOWNS Discovery")
  if not TOWNS or type(TOWNS.NewFromFile) ~= "function" then
    fail("MOOSE TOWNS fehlt. Moose.lua zuerst laden."); message("MOOSE TOWNS fehlt.", 30); return
  end

  local townsFile, candidates = findTownsFile()
  if not townsFile then
    fail("Keine lesbare towns.lua gefunden.")
    for _, path in ipairs(candidates) do fail("Kandidat: " .. path) end
    message("towns.lua nicht gefunden. Pfad und MissionScripting.lua pruefen.", 30)
    return
  end

  state.sourceFile = townsFile
  local ok, townsObject = pcall(TOWNS.NewFromFile, TOWNS, townsFile)
  if not ok or not townsObject then
    fail("TOWNS:NewFromFile fehlgeschlagen: " .. tostring(townsObject)); message("Laden fehlgeschlagen.", 30); return
  end

  state.rows = buildRows(townsObject:GetTowns() or {})
  local nearestStatus = addNearestNeighbors(state.rows)
  local inventory = fieldInventory(state.rows)
  state.summary = summarize(state.rows, nearestStatus)

  info(string.format("Geladen: %d Eintraege, %d eindeutige Namen, %d Quelldatenfelder",
    state.summary.total, state.summary.uniqueNames, #inventory))

  if cfg.logEachTown then
    info("BEGIN TOWN DATA count=" .. #state.rows)
    for _, row in ipairs(state.rows) do
      info(string.format("TOWN|index=%d|source_index=%d|name=%s|display=%s|lat=%s|lon=%s|x=%s|z=%s|road_distance_m=%s|rail_distance_m=%s|nearest=%s|nearest_distance_m=%s",
        row.index, row.sourceIndex, row.name, row.displayName,
        number(row.latitude,8), number(row.longitude,8), number(row.x), number(row.z),
        number(row.roadDistance), number(row.railDistance), row.nearestName, number(row.nearestDistance)))
    end
    info("END TOWN DATA")
  end

  exportFiles(state.rows, state.summary, inventory)
  installMenu(); printSummary()
  if cfg.showMarkersOnStart then showMarkers() end
end

run()
