-- Operation Mountain Watch - local QRF runtime assembly.
--
-- Wires incident-scoped QRF demands to the site-local MOOSE BRIGADE without
-- operational asset preselection. Tactical response coordinates remain injected.
-- Mobile vehicle QRF materialization reuses the accepted GroundRoadSpawnAdapter
-- at the site's ACCESS zone; MOOSE retains mission/recruitment lifecycle control.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-3"
local TAG = "[OMW][FireSupStratResupply.QrfRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function needCallable(value, label) if type(value) ~= "function" then fail(label .. " must be a function") end return value end

local function packagedRoadSpawnAdapter()
  local p = OMW and OMW.FireSupStratResupply
  local modules = p and p.Modules
  local adapter = modules and modules.roadSpawnAdapter
  if type(adapter) ~= "table" or type(adapter.Install) ~= "function" then
    fail("packaged GroundRoadSpawnAdapter.Install() is required")
  end
  return adapter
end

local function mobileVehicle(asset)
  return type(asset) == "table"
    and type(Group) == "table" and type(Group.Category) == "table"
    and type(WAREHOUSE) == "table" and type(WAREHOUSE.Attribute) == "table"
    and asset.category == Group.Category.GROUND
    and type(asset.speedmax) == "number" and asset.speedmax > 0
    and asset.attribute ~= WAREHOUSE.Attribute.GROUND_INFANTRY
end

function Runtime.New(spec)
  needTable(spec, "spec")
  local siteRegistry = needTable(spec.siteRegistry, "siteRegistry")
  local brigades = needTable(spec.brigades, "brigades")
  local qrfMissionFactory = needTable(spec.qrfMissionFactory, "qrfMissionFactory")
  local legionBridge = needTable(spec.legionBridge, "legionBridge")
  if type(siteRegistry.Sites) ~= "table" then fail("siteRegistry.Sites is required") end
  needFunction(qrfMissionFactory, "New", "qrfMissionFactory")
  needFunction(legionBridge, "New", "legionBridge")
  local resolveCoordinate = needCallable(spec.resolveCoordinate, "resolveCoordinate")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  local roadSpawnAdapter = packagedRoadSpawnAdapter()
  local targets = {}
  for siteId, site in pairs(siteRegistry.Sites) do
    local brigade = needTable(brigades[siteId], "brigades[" .. tostring(siteId) .. "]")
    if type(site.accessZoneName) ~= "string" or site.accessZoneName == "" then
      fail("accessZoneName is required siteId=" .. tostring(siteId))
    end
    roadSpawnAdapter.Install(brigade, {
      resolveRoadSpawn = function(_, asset)
        if not mobileVehicle(asset) then return nil end
        local target = targets[siteId]
        if target == nil then return nil end
        if type(ZONE) ~= "table" or type(ZONE.FindByName) ~= "function" then fail("MOOSE ZONE:FindByName() is required") end
        local accessZone = ZONE:FindByName(site.accessZoneName)
        if accessZone == nil then fail("ACCESS zone unavailable siteId=" .. tostring(siteId) .. " zone=" .. tostring(site.accessZoneName)) end
        return { accessZone=accessZone, forwardCoordinate=target, entityId=tostring(site.installationId).."|QRF" }
      end,
      log = function(message) if spec.logger then spec.logger(message) end end,
    })
  end

  local factory = qrfMissionFactory.New({
    resolveCoordinate = function(demand, context, legion)
      local coordinate, reason = resolveCoordinate(demand, context, legion)
      if coordinate ~= nil then targets[demand.siteId] = coordinate end
      return coordinate, reason
    end,
    requiredAssetsMin = spec.requiredAssetsMin or 1,
    requiredAssetsMax = spec.requiredAssetsMax or (spec.requiredAssetsMin or 1),
    requiredAttributes = spec.requiredAttributes,
    requiredProperties = spec.requiredProperties,
    logger = spec.logger,
  })
  local bridge = legionBridge.New({
    resolveLegion = function(siteId)
      local brigade = brigades[siteId]
      if not brigade then return nil, "SITE_LEGION_NOT_CONFIGURED" end
      return brigade
    end,
    factory = function(demand, context, legion) return factory:Create(demand, context, legion) end,
    logger = spec.logger,
  })

  return setmetatable({siteRegistry=siteRegistry,brigades=brigades,factory=factory,dispatchBridge=bridge,targets=targets,logger=spec.logger}, Instance)
end

function Instance:_log(message) if self.logger then self.logger(TAG .. " " .. tostring(message)) end end

function Instance:Dispatch(demand, context)
  if type(demand) ~= "table" then fail("demand must be a table") end
  if demand.supportType ~= "QRF" then fail("supportType QRF is required") end
  if not self.siteRegistry.Sites[demand.siteId] then return nil, false, "SITE_NOT_FOUND" end
  return self.dispatchBridge:Dispatch(demand, context)
end

return Runtime
