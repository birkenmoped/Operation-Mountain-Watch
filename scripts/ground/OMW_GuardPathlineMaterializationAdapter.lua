-- Operation Mountain Watch - Guard PATHLINE materialization adapter.
-- This module prepares compact PATHLINE-aligned unit geometry for Guard assets.
-- It preserves the MOOSE BRIGADE/WAREHOUSE lifecycle and only adapts the exact
-- unit positions/headings immediately before the configured Guard asset spawns.
local Adapter = {}
local Instance = {}
Instance.__index = Instance
Adapter.SchemaVersion = "OMW-GUARD-PATHLINE-MATERIALIZATION-ADAPTER-1"
local TAG = "[OMW][GuardPathlineMaterializationAdapter]"

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

local function distance(a, b)
  local dx, dy = b.x - a.x, b.y - a.y
  return math.sqrt(dx * dx + dy * dy)
end

local function headingDegrees(a, b)
  local h = math.deg(math.atan2(b.y - a.y, b.x - a.x))
  if h < 0 then h = h + 360 end
  return h
end

local function pointAlong(a, b, meters)
  local length = distance(a, b)
  if length <= 0 then return nil end
  local factor = meters / length
  return { x = a.x + (b.x - a.x) * factor, y = a.y + (b.y - a.y) * factor }
end

function Adapter.New(spec)
  needTable(spec, "spec")
  local pathline = needTable(spec.pathline, "pathline")
  local templateGroup = needTable(spec.templateGroup, "templateGroup")
  needFunction(pathline, "GetCoordinates", "pathline")
  needFunction(templateGroup, "GetInitialSize", "templateGroup")
  if spec.coordinateFactory ~= nil and type(spec.coordinateFactory) ~= "function" then fail("coordinateFactory must be a function") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function") end
  return setmetatable({
    siteId = needString(spec.siteId, "siteId"),
    guardTemplateName = needString(spec.guardTemplateName, "guardTemplateName"),
    pathline = pathline,
    templateGroup = templateGroup,
    targetSpacingM = needPositive(spec.targetSpacingM or 2, "targetSpacingM"),
    minimumSpacingM = needPositive(spec.minimumSpacingM or 0.75, "minimumSpacingM"),
    coordinateFactory = spec.coordinateFactory,
    logger = spec.logger,
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:_coordinate(vec2)
  if self.coordinateFactory then return self.coordinateFactory(vec2) end
  if type(COORDINATE) ~= "table" or type(COORDINATE.NewFromVec2) ~= "function" then fail("MOOSE COORDINATE:NewFromVec2() is required") end
  return COORDINATE:NewFromVec2(vec2)
end

function Instance:Prepare()
  local coordinates = self.pathline:GetCoordinates()
  if type(coordinates) ~= "table" or #coordinates < 2 then fail("Guard PATHLINE requires at least two coordinates") end
  if type(coordinates[1].GetVec2) ~= "function" or type(coordinates[2].GetVec2) ~= "function" then fail("Guard PATHLINE coordinates must expose GetVec2()") end
  local count = self.templateGroup:GetInitialSize()
  if type(count) ~= "number" or count < 1 then fail("Guard template initial size is invalid") end
  local a, b = coordinates[1]:GetVec2(), coordinates[2]:GetVec2()
  needTable(a, "PATHLINE first point")
  needTable(b, "PATHLINE second point")
  local length = distance(a, b)
  if length <= 0 then fail("Guard PATHLINE first segment has zero length") end
  local spacing = math.min(self.targetSpacingM, (length - 1) / math.max(1, count - 1))
  if spacing < self.minimumSpacingM then fail("Guard PATHLINE first segment is too short for compact spawn") end
  local heading = headingDegrees(a, b)
  local leadOffset = (count - 1) * spacing
  local positions = {}
  for index = 1, count do
    local point = pointAlong(a, b, leadOffset - (index - 1) * spacing)
    if not point then fail("Unable to build Guard spawn point " .. tostring(index)) end
    positions[index] = { x = point.x, y = point.y, heading = heading }
  end
  self.positions = positions
  self.spacingM = spacing
  self.headingDeg = heading
  self.leadCoordinate = self:_coordinate({ x = positions[1].x, y = positions[1].y })
  self:_log(string.format("prepared siteId=%s template=%s units=%d spacingM=%.2f headingDeg=%.1f anchor=PATHLINE_FIRST_SEGMENT", self.siteId, self.guardTemplateName, #positions, spacing, heading))
  return self
end

function Instance:GetLeadCoordinate()
  if not self.leadCoordinate then fail("Prepare() must be called before GetLeadCoordinate()") end
  return self.leadCoordinate
end

function Instance:GetSpawnGeometry()
  if not self.positions then fail("Prepare() must be called before GetSpawnGeometry()") end
  return self.positions, self.spacingM, self.headingDeg
end

function Instance:Install(brigade)
  needTable(brigade, "brigade")
  if not self.positions then fail("Prepare() must be called before Install()") end
  if self.installedBrigade then
    if self.installedBrigade == brigade then return self, false end
    fail("Adapter instance is already installed on another BRIGADE")
  end

  local original = needFunction(brigade, "_SpawnAssetGroundNaval", "BRIGADE/WAREHOUSE")
  needFunction(brigade, "_SpawnAssetPrepareTemplate", "BRIGADE/WAREHOUSE")
  if brigade.ValidateAndRepositionGroundUnits == true then
    fail("WAREHOUSE repositioning conflicts with exact Guard PATHLINE placement")
  end

  local adapter = self
  brigade._SpawnAssetGroundNaval = function(self, alias, asset, request, spawnzone, lateactivated)
    if not asset or asset.templatename ~= adapter.guardTemplateName then
      return original(self, alias, asset, request, spawnzone, lateactivated)
    end
    if type(Group) ~= "table" or type(Group.Category) ~= "table" or asset.category ~= Group.Category.GROUND then
      return original(self, alias, asset, request, spawnzone, lateactivated)
    end

    local template = self:_SpawnAssetPrepareTemplate(asset, alias)
    if type(template) ~= "table" or type(template.units) ~= "table" or #template.units ~= #adapter.positions then
      fail("Guard WAREHOUSE spawn template mismatch")
    end

    template.route = template.route or { points = {} }
    template.route.points = template.route.points or {}
    template.route.points[1] = template.route.points[1] or {}
    for index, position in ipairs(adapter.positions) do
      local unit = template.units[index]
      unit.x = position.x
      unit.y = position.y
      unit.heading = math.rad(position.heading)
      if asset.livery then unit.livery_id = asset.livery end
      if asset.skill then unit.skill = asset.skill end
    end

    local lead = adapter.positions[1]
    template.route.points[1].x = lead.x
    template.route.points[1].y = lead.y
    template.x = lead.x
    template.y = lead.y
    template.lateActivation = lateactivated

    adapter:_log(string.format("materializing siteId=%s template=%s units=%d spacingM=%.2f headingDeg=%.1f anchor=PATHLINE_FIRST_SEGMENT", adapter.siteId, adapter.guardTemplateName, #adapter.positions, adapter.spacingM, adapter.headingDeg))
    if type(_DATABASE) ~= "table" or type(_DATABASE.Spawn) ~= "function" then fail("MOOSE _DATABASE:Spawn() is required") end
    return _DATABASE:Spawn(template)
  end

  self.installedBrigade = brigade
  self.originalSpawn = original
  self:_log(string.format("installed siteId=%s template=%s", self.siteId, self.guardTemplateName))
  return self, true
end

return Adapter
