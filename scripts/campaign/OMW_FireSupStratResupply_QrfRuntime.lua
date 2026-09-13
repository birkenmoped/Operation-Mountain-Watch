-- Operation Mountain Watch - local QRF runtime assembly.
--
-- Wires incident-scoped QRF demands to the site-local MOOSE BRIGADE without
-- operational asset preselection. The physical hostile target remains transient.
-- Mobile vehicle QRF materialization reuses the accepted GroundRoadSpawnAdapter
-- at the site's ACCESS zone; MOOSE retains mission/recruitment/attack lifecycle.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-5"
local TAG = "[OMW][FireSupStratResupply.QrfRuntime]"
local ROAD_SPAWN_VEHICLE_SPACING_M = 18
local ROAD_DIRECTION_SAMPLE_DISTANCES_M = { 500, 1000, 1500, 2000 }

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

local function validRoadPath(startRoad, candidate)
  if not startRoad or not candidate then return false end
  local roadPath, _, gotRoadPath = startRoad:GetPathOnRoad(candidate, true, false, false, false)
  return gotRoadPath == true and type(roadPath) == "table" and #roadPath >= 2
end

local function resolveOutboundRoadCoordinate(accessZone, targetCoordinate, entityId)
  if type(accessZone) ~= "table" or type(accessZone.GetCoordinate) ~= "function" then
    fail("QRF road direction requires MOOSE ACCESS zone entityId=" .. tostring(entityId))
  end
  if type(targetCoordinate) ~= "table" or type(targetCoordinate.Get2DDistance) ~= "function"
      or type(targetCoordinate.GetClosestPointToRoad) ~= "function" then
    fail("QRF road direction requires physical target COORDINATE entityId=" .. tostring(entityId))
  end

  local accessCoordinate = accessZone:GetCoordinate()
  local startRoad = accessCoordinate and accessCoordinate:GetClosestPointToRoad(false) or nil
  if not startRoad then
    fail("QRF ACCESS road unavailable entityId=" .. tostring(entityId))
  end

  local totalDistance = accessCoordinate:Get2DDistance(targetCoordinate)
  if type(totalDistance) ~= "number" or totalDistance <= 0 then
    fail("QRF target distance unavailable entityId=" .. tostring(entityId))
  end

  for _, sampleDistance in ipairs(ROAD_DIRECTION_SAMPLE_DISTANCES_M) do
    if sampleDistance < totalDistance then
      local fraction = sampleDistance / totalDistance
      local rawCandidate = accessCoordinate:GetIntermediateCoordinate(targetCoordinate, fraction)
      local roadCandidate = rawCandidate and rawCandidate:GetClosestPointToRoad(false) or nil
      if roadCandidate and validRoadPath(startRoad, roadCandidate) then
        return roadCandidate
      end
    end
  end

  local targetRoad = targetCoordinate:GetClosestPointToRoad(false)
  if targetRoad and validRoadPath(startRoad, targetRoad) then
    return targetRoad
  end

  fail("QRF outbound road anchor unavailable entityId=" .. tostring(entityId))
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
  local resolveTarget = needCallable(spec.resolveTarget, "resolveTarget")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  local roadSpawnAdapter = packagedRoadSpawnAdapter()
  local targetCoordinates = {}
  for siteId, site in pairs(siteRegistry.Sites) do
    local brigade = needTable(brigades[siteId], "brigades[" .. tostring(siteId) .. "]")
    if type(site.accessZoneName) ~= "string" or site.accessZoneName == "" then
      fail("accessZoneName is required siteId=" .. tostring(siteId))
    end
    roadSpawnAdapter.Install(brigade, {
      resolveRoadSpawn = function(_, asset)
        if not mobileVehicle(asset) then return nil end
        local targetCoordinate = targetCoordinates[siteId]
        if targetCoordinate == nil then return nil end
        if type(ZONE) ~= "table" or type(ZONE.FindByName) ~= "function" then fail("MOOSE ZONE:FindByName() is required") end
        local accessZone = ZONE:FindByName(site.accessZoneName)
        if accessZone == nil then fail("ACCESS zone unavailable siteId=" .. tostring(siteId) .. " zone=" .. tostring(site.accessZoneName)) end
        local entityId = tostring(site.installationId) .. "|QRF"
        local forwardCoordinate = resolveOutboundRoadCoordinate(accessZone, targetCoordinate, entityId)
        return {
          accessZone = accessZone,
          forwardCoordinate = forwardCoordinate,
          entityId = entityId,
        }
      end,
      vehicleSpacingM = ROAD_SPAWN_VEHICLE_SPACING_M,
      log = function(message) if spec.logger then spec.logger(message) end end,
    })
  end

  local factory = qrfMissionFactory.New({
    resolveTarget = function(demand, context, legion)
      local target, reason = resolveTarget(demand, context, legion)
      if target ~= nil and type(target.GetCoordinate) == "function" then
        targetCoordinates[demand.siteId] = target:GetCoordinate()
      end
      return target, reason
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

  return setmetatable({siteRegistry=siteRegistry,brigades=brigades,factory=factory,dispatchBridge=bridge,targetCoordinates=targetCoordinates,logger=spec.logger}, Instance)
end

function Instance:_log(message) if self.logger then self.logger(TAG .. " " .. tostring(message)) end end

function Instance:Dispatch(demand, context)
  if type(demand) ~= "table" then fail("demand must be a table") end
  if demand.supportType ~= "QRF" then fail("supportType QRF is required") end
  if not self.siteRegistry.Sites[demand.siteId] then return nil, false, "SITE_NOT_FOUND" end
  return self.dispatchBridge:Dispatch(demand, context)
end

return Runtime
