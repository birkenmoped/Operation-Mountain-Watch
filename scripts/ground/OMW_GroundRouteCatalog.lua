-- Operation Mountain Watch - validated Ground route catalog contract.
--
-- Campaign/domain data only. This module contains no MOOSE or DCS calls.
-- It does not discover routes at runtime. It stores explicit references to
-- Mission Editor PATHLINE/zone names and direction metadata that a later
-- MOOSE execution adapter may resolve.

local GroundRouteCatalog = {}
local Catalog = {}
Catalog.__index = Catalog

local TAG = "[OMW][Ground.RouteCatalog]"

GroundRouteCatalog.SchemaVersion = "OMW-GROUND-ROUTE-CATALOG-1"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requirePositiveNumber(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
    fail(label .. " requires positive finite number")
  end
  return value
end

local function copyArray(values, label)
  if type(values) ~= "table" or #values == 0 then
    fail(label .. " requires non-empty array")
  end
  local result = {}
  for index, value in ipairs(values) do
    result[index] = requireString(value, label .. "[" .. tostring(index) .. "]")
  end
  return result
end

local function copyDirections(values, count)
  if type(values) ~= "table" or #values ~= count then
    fail("pathlineDirections must contain exactly one entry per pathline")
  end
  local result = {}
  for index, value in ipairs(values) do
    if value ~= "FORWARD" and value ~= "REVERSE" then
      fail("unsupported pathlineDirections[" .. tostring(index) .. "]=" .. tostring(value))
    end
    result[index] = value
  end
  return result
end

local function copyMissionTypes(values)
  return copyArray(values, "allowedMissionTypes")
end

local function copyRoute(route)
  if not route then
    return nil
  end
  local copy = {}
  for key, value in pairs(route) do
    if type(value) == "table" then
      local nested = {}
      for index, item in ipairs(value) do
        nested[index] = item
      end
      copy[key] = nested
    else
      copy[key] = value
    end
  end
  return copy
end

local function normalize(spec)
  if type(spec) ~= "table" then
    fail("route spec must be table")
  end

  local pathlineNames = copyArray(spec.pathlineNames, "pathlineNames")
  local pathlineDirections = copyDirections(spec.pathlineDirections, #pathlineNames)

  return {
    routeId = requireString(spec.routeId, "routeId"),
    originNodeId = requireString(spec.originNodeId, "originNodeId"),
    destinationId = requireString(spec.destinationId, "destinationId"),
    accessZoneName = requireString(spec.accessZoneName, "accessZoneName"),
    handoffZoneName = requireString(spec.handoffZoneName, "handoffZoneName"),
    pathlineNames = pathlineNames,
    pathlineDirections = pathlineDirections,
    speedKph = requirePositiveNumber(spec.speedKph, "speedKph"),
    formation = requireString(spec.formation, "formation"),
    allowedMissionTypes = copyMissionTypes(spec.allowedMissionTypes),
    status = spec.status or "PLANNED",
  }
end

function GroundRouteCatalog.New()
  return setmetatable({
    schemaVersion = GroundRouteCatalog.SchemaVersion,
    routesById = {},
  }, Catalog)
end

function Catalog:Register(spec)
  local route = normalize(spec)
  if self.routesById[route.routeId] then
    fail("duplicate routeId=" .. route.routeId)
  end
  self.routesById[route.routeId] = route
  return copyRoute(route)
end

function Catalog:Get(routeId)
  requireString(routeId, "routeId")
  return copyRoute(self.routesById[routeId])
end

function Catalog:Require(routeId)
  local route = self:Get(routeId)
  if not route then
    fail("unknown routeId=" .. tostring(routeId))
  end
  return route
end

function Catalog:IsMissionAllowed(routeId, missionType)
  local route = self:Require(routeId)
  requireString(missionType, "missionType")
  for _, value in ipairs(route.allowedMissionTypes) do
    if value == missionType then
      return true
    end
  end
  return false
end

function Catalog:List()
  local keys = {}
  for routeId in pairs(self.routesById) do
    keys[#keys + 1] = routeId
  end
  table.sort(keys)

  local result = {}
  for _, routeId in ipairs(keys) do
    result[#result + 1] = copyRoute(self.routesById[routeId])
  end
  return result
end

return GroundRouteCatalog
