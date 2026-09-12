-- Operation Mountain Watch - Guard PATHLINE routing adapter.
--
-- Applies the already accepted Guard PATHLINE route after MOOSE has recruited and
-- materialized the Guard ARMYGROUP. It does not select cohorts/assets and uses only
-- public MOOSE group/AUFTRAG lifecycle callbacks for routing.
local Adapter = {}
local Instance = {}
Instance.__index = Instance

Adapter.SchemaVersion = "OMW-GUARD-PATHLINE-ROUTE-ADAPTER-1"
local TAG = "[OMW][GuardPathlineRouteAdapter]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needString(value, label) if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end return value end
local function finitePositive(value, label)
  if type(value) ~= "number" or value ~= value or value <= 0 or value == math.huge then fail(label .. " must be a positive finite number") end
  return value
end

function Adapter.New(spec)
  needTable(spec, "spec")
  local pathline = needTable(spec.pathline, "pathline")
  local materializer = needTable(spec.materializer, "materializer")
  needFunction(pathline, "GetCoordinates", "pathline")
  needFunction(materializer, "GetLeadCoordinate", "materializer")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function") end
  return setmetatable({
    siteId = needString(spec.siteId, "siteId"),
    pathline = pathline,
    materializer = materializer,
    speedKmph = finitePositive(spec.speedKmph or 5, "speedKmph"),
    formation = spec.formation or "Off Road",
    formationIntervalM = finitePositive(spec.formationIntervalM or 2, "formationIntervalM"),
    trackedMissions = {},
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:TrackMission(mission)
  needTable(mission, "mission")
  self.trackedMissions[mission] = true
  return self
end

function Instance:_buildRoute(group)
  local coordinates = self.pathline:GetCoordinates()
  if type(coordinates) ~= "table" or #coordinates < 2 then fail("Guard PATHLINE requires at least two coordinates") end
  local lead = self.materializer:GetLeadCoordinate()
  needFunction(lead, "WaypointGround", "materializer lead coordinate")
  local route = { lead:WaypointGround(self.speedKmph, self.formation) }
  for index = 2, #coordinates do
    needFunction(coordinates[index], "WaypointGround", "PATHLINE coordinate")
    route[#route + 1] = coordinates[index]:WaypointGround(self.speedKmph, self.formation)
  end
  return route
end

function Instance:Apply(armyGroup, mission)
  if not self.trackedMissions[mission] then return nil, false, "MISSION_NOT_TRACKED" end
  needTable(armyGroup, "armyGroup")
  local getGroup = needFunction(armyGroup, "GetGroup", "armyGroup")
  local group = getGroup(armyGroup)
  needTable(group, "Guard GROUP")
  needFunction(group, "OptionFormationInterval", "Guard GROUP")
  needFunction(group, "SetTaskWaypoint", "Guard GROUP")
  needFunction(group, "TaskFunction", "Guard GROUP")
  needFunction(group, "Route", "Guard GROUP")

  local route = self:_buildRoute(group)
  group:OptionFormationInterval(self.formationIntervalM)
  group:SetTaskWaypoint(route[#route], group:TaskFunction("CONTROLLABLE.Route", route, 2))
  group:Route(route, 2)
  self:_log(string.format("route started siteId=%s waypoints=%d speedKmph=%s formation=%s intervalM=%s",
    self.siteId, #route, tostring(self.speedKmph), tostring(self.formation), tostring(self.formationIntervalM)))
  return group, true, nil
end

function Instance:Install(brigade)
  needTable(brigade, "brigade")
  if self.installedBrigade then
    if self.installedBrigade == brigade then return self, false end
    fail("Adapter instance is already installed on another BRIGADE")
  end

  local previous = brigade.OnAfterArmyOnMission
  if previous ~= nil and type(previous) ~= "function" then fail("BRIGADE.OnAfterArmyOnMission must be a function when present") end
  local adapter = self
  brigade.OnAfterArmyOnMission = function(self, From, Event, To, ArmyGroup, Mission)
    if previous then previous(self, From, Event, To, ArmyGroup, Mission) end
    if adapter.trackedMissions[Mission] then adapter:Apply(ArmyGroup, Mission) end
  end
  self.installedBrigade = brigade
  self.previousOnAfterArmyOnMission = previous
  self:_log("installed siteId=" .. self.siteId)
  return self, true
end

return Adapter
