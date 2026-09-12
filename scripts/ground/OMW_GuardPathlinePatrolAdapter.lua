-- Operation Mountain Watch - Guard PATHLINE patrol adapter.
-- Uses public MOOSE CONTROLLABLE APIs only. The adapter closes the owner-authored
-- Guard PATHLINE explicitly because MOOSE PATHLINE registration imports drawing
-- points but does not preserve the Mission Editor drawing's closed flag.
local Adapter = {}
local Instance = {}
Instance.__index = Instance

Adapter.SchemaVersion = "OMW-GUARD-PATHLINE-PATROL-ADAPTER-1"
local TAG = "[OMW][GuardPathlinePatrolAdapter]"

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

local function needString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end

local function needPositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then
    fail(label .. " must be a positive finite number")
  end
  return value
end

function Adapter.New(spec)
  needTable(spec, "spec")
  local pathline = needTable(spec.pathline, "pathline")
  needFunction(pathline, "GetCoordinates", "pathline")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function") end
  return setmetatable({
    siteId = needString(spec.siteId, "siteId"),
    pathline = pathline,
    speedKmh = needPositive(spec.speedKmh or 5, "speedKmh"),
    formation = spec.formation or "Off Road",
    loopDelaySeconds = needPositive(spec.loopDelaySeconds or 2, "loopDelaySeconds"),
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:BuildRoute(group, leadCoordinate)
  needTable(group, "group")
  needTable(leadCoordinate, "leadCoordinate")
  needFunction(leadCoordinate, "WaypointGround", "leadCoordinate")
  local coordinates = self.pathline:GetCoordinates()
  if type(coordinates) ~= "table" or #coordinates < 2 then fail("Guard PATHLINE requires at least two coordinates") end

  local route = { leadCoordinate:WaypointGround(self.speedKmh, self.formation) }
  for index = 2, #coordinates do
    needFunction(coordinates[index], "WaypointGround", "PATHLINE coordinate")
    route[#route + 1] = coordinates[index]:WaypointGround(self.speedKmh, self.formation)
  end

  -- DCS drawing closed=true is not retained by MOOSE PATHLINE registration.
  -- Re-add the owner-authored closing segment explicitly before looping.
  needFunction(coordinates[1], "WaypointGround", "PATHLINE first coordinate")
  route[#route + 1] = coordinates[1]:WaypointGround(self.speedKmh, self.formation)
  return route
end

function Instance:Start(group, leadCoordinate)
  needTable(group, "group")
  for _, name in ipairs({ "SetTaskWaypoint", "TaskFunction", "WayPointInitialize", "WayPointExecute" }) do
    needFunction(group, name, "group")
  end

  local route = self:BuildRoute(group, leadCoordinate)
  local restartTask = group:TaskFunction("CONTROLLABLE.WayPointExecute", 1, self.loopDelaySeconds)
  group:SetTaskWaypoint(route[#route], restartTask)
  group:WayPointInitialize(route)
  group:WayPointExecute(1, self.loopDelaySeconds)
  self:_log(string.format(
    "started siteId=%s pathPoints=%d routePoints=%d closeMode=PATHLINE_FIRST_POINT loop=MOOSE_WAYPOINT_EXECUTE",
    self.siteId, #self.pathline:GetCoordinates(), #route))
  return self, route
end

return Adapter
