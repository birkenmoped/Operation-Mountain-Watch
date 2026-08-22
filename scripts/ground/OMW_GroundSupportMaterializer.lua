-- Operation Mountain Watch - Ground support asset materialization coordinator.
--
-- This module uses the public MOOSE BRIGADE/PLATOON/WAREHOUSE self-request
-- lifecycle to materialize one already-registered Ground support asset and
-- hand the resulting MOOSE GROUP to the caller. A materialized support group
-- can be returned through public WAREHOUSE:AddAsset(group), which restores the
-- known asset to stock and lets MOOSE remove the physical representation.
-- It does not own strategic resources, spawn via SPAWN, route the group, or
-- create an operational FSM.

local GroundSupportMaterializer = {}

local Service = {}
Service.__index = Service

local TAG = "[OMW][Ground.SupportMaterializer]"

GroundSupportMaterializer.SchemaVersion = "OMW-GROUND-SUPPORT-MATERIALIZER-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then
    fail(label .. " must be a function")
  end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requirePositiveInteger(value, label)
  if type(value) ~= "number" or value < 1 or value % 1 ~= 0 then
    fail(label .. " requires positive integer")
  end
  return value
end

local function noop() end

function GroundSupportMaterializer.New(spec)
  requireTable(spec, "spec")

  local brigade = requireTable(spec.brigade, "spec.brigade")
  local platoonFactory = requireFunction(spec.platoonFactory, "spec.platoonFactory")
  local templateName = requireNonEmptyString(spec.templateName, "spec.templateName")
  local platoonName = requireNonEmptyString(spec.platoonName, "spec.platoonName")
  local assignment = requireNonEmptyString(spec.assignment, "spec.assignment")

  if type(brigade.AddPlatoon) ~= "function"
      or type(brigade.AddRequest) ~= "function"
      or type(brigade.GetAssignment) ~= "function"
      or type(brigade.AddAsset) ~= "function" then
    fail("spec.brigade requires AddPlatoon(), AddRequest(), GetAssignment(), and AddAsset()")
  end

  local descriptorGroupName = spec.descriptorGroupName
  if descriptorGroupName == nil then
    fail("spec.descriptorGroupName is required")
  end

  local platoon = platoonFactory(templateName, requirePositiveInteger(spec.stockCount or 1, "spec.stockCount"), platoonName)
  if type(platoon) ~= "table" then
    fail("platoonFactory returned no PLATOON")
  end

  brigade:AddPlatoon(platoon)

  local service = setmetatable({
    brigade = brigade,
    platoon = platoon,
    templateName = templateName,
    platoonName = platoonName,
    assignment = assignment,
    descriptorGroupName = descriptorGroupName,
    priority = spec.priority or 50,
    onMaterialized = spec.onMaterialized or noop,
    log = spec.log or noop,
    pending = false,
    materializedGroup = nil,
    request = nil,
  }, Service)

  local previousOnAfterSelfRequest = brigade.OnAfterSelfRequest
  brigade.OnAfterSelfRequest = function(self, From, Event, To, groupset, request)
    if type(previousOnAfterSelfRequest) == "function" then
      previousOnAfterSelfRequest(self, From, Event, To, groupset, request)
    end

    local requestAssignment = self:GetAssignment(request)
    if requestAssignment ~= service.assignment then
      return
    end

    if not service.pending then
      fail("unexpected self request callback assignment=" .. service.assignment)
    end
    if type(groupset) ~= "table" or type(groupset.GetSetObjects) ~= "function" then
      fail("self request callback requires SET_GROUP:GetSetObjects()")
    end

    local objects = groupset:GetSetObjects()
    if type(objects) ~= "table" then
      fail("self request callback returned invalid group set")
    end

    local group = nil
    local count = 0
    for _, candidate in pairs(objects) do
      count = count + 1
      group = candidate
    end
    if count ~= 1 or type(group) ~= "table" then
      fail("self request expected exactly one materialized GROUP count=" .. tostring(count))
    end

    service.pending = false
    service.materializedGroup = group
    service.request = request
    service.log("INFO", TAG .. " materialized template=" .. service.templateName .. " assignment=" .. service.assignment)
    service.onMaterialized(group, request, service)
  end

  return service
end

function Service:Request()
  if self.materializedGroup ~= nil then
    return self.materializedGroup, false
  end
  if self.pending then
    return nil, false
  end

  self.pending = true
  self.brigade:AddRequest(
    self.brigade,
    self.descriptorGroupName,
    self.templateName,
    1,
    nil,
    nil,
    self.priority,
    self.assignment
  )

  self.log("INFO", TAG .. " requested template=" .. self.templateName .. " assignment=" .. self.assignment)
  return nil, true
end

function Service:ReturnToStock(group)
  local target = group or self.materializedGroup
  if type(target) ~= "table" then
    fail("ReturnToStock requires materialized GROUP")
  end
  if self.materializedGroup ~= nil and target ~= self.materializedGroup then
    fail("ReturnToStock group does not match current materialized GROUP")
  end

  self.brigade:AddAsset(target)
  self.materializedGroup = nil
  self.request = nil
  self.pending = false
  self.log("INFO", TAG .. " returned to Warehouse stock template=" .. self.templateName .. " assignment=" .. self.assignment)
  return true
end

function Service:GetMaterializedGroup()
  return self.materializedGroup
end

function Service:GetPlatoon()
  return self.platoon
end

function Service:GetConfig()
  return {
    schemaVersion = GroundSupportMaterializer.SchemaVersion,
    templateName = self.templateName,
    platoonName = self.platoonName,
    assignment = self.assignment,
    priority = self.priority,
  }
end

return GroundSupportMaterializer
