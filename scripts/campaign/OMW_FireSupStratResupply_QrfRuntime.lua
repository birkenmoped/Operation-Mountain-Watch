-- Operation Mountain Watch - local QRF runtime assembly.
local Runtime = {}
local Instance = {}
Instance.__index = Instance
Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13"
local TAG = "[OMW][FireSupStratResupply.QrfRuntime]"
local QRF_TACTICAL_RADIUS_NM = 5
local QRF_ENGAGE_SPEED_KNOTS = 20
local QRF_ENGAGE_FORMATION = "On Road"
local ROAD_SPAWN_VEHICLE_SPACING_M = 18
local HOME_SPAWN_ZONE_MAX_DIST_M = 1000
local function fail(message) error(TAG .. " " .. tostring(message), 2) end
local function needTable(value, label) if type(value) ~= "table" then fail(label .. " must be a table") end return value end
local function needFunction(container, name, label) if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end return container[name] end
local function needCallable(value, label) if type(value) ~= "function" then fail(label .. " must be a function") end return value end
local function packagedRoadSpawnAdapter()
  local p = OMW and OMW.FireSupStratResupply
  local modules = p and p.Modules
  local adapter = modules and modules.roadSpawnAdapter
  if type(adapter) ~= "table" or type(adapter.Install) ~= "function" then fail("packaged GroundRoadSpawnAdapter.Install() is required") end
  return adapter
end
local function mobileVehicle(asset)
  return type(asset) == "table" and type(Group) == "table" and type(Group.Category) == "table" and type(WAREHOUSE) == "table" and type(WAREHOUSE.Attribute) == "table" and asset.category == Group.Category.GROUND and type(asset.speedmax) == "number" and asset.speedmax > 0 and asset.attribute ~= WAREHOUSE.Attribute.GROUND_INFANTRY
end
local function incidentUnits(context)
  local incident = context and context.incident
  local incidentContext = incident and incident.context
  local coordinator = incidentContext and incidentContext.sourceIncidentCoordinator
  if type(coordinator) ~= "table" or type(coordinator.GetParticipants) ~= "function" then return nil, "QRF_INCIDENT_COORDINATOR_UNAVAILABLE" end
  local units = {}
  for _, group in ipairs(coordinator:GetParticipants(true) or {}) do
    if type(group) == "table" and type(group.GetUnits) == "function" then
      for _, unit in pairs(group:GetUnits() or {}) do
        if type(unit) == "table" and type(unit.IsAlive) == "function" and unit:IsAlive() == true then units[#units + 1] = unit end
      end
    end
  end
  return units, nil
end
local function wrapQrfReleaseHandle(handle)
  if type(handle) ~= "table" or type(handle.mission) ~= "table" or handle._OMWQrfReleaseWrapped then return handle end
  local mission = handle.mission
  handle._OMWQrfReleaseWrapped = true
  function handle:Cancel()
    if self.cancelRequested then return false end
    self.cancelRequested = true
    mission._OMWQrfCompleting = true
    local over = type(mission.IsOver) == "function" and mission:IsOver() or false
    if not over then mission:Cancel() end
    return true
  end
  return handle
end
local function installBrigadeBinding(brigade, logger)
  if brigade._OMWQrfDirectTargetBindingInstalled then return end
  brigade._OMWQrfDirectTargetBindingInstalled = true
  local previous = brigade.OnAfterArmyOnMission
  function brigade:OnAfterArmyOnMission(From, Event, To, armyGroup, mission)
    if previous then previous(self, From, Event, To, armyGroup, mission) end
    if type(mission) == "table" and type(mission._OMWQrfBindArmyGroup) == "function" then
      mission:_OMWQrfBindArmyGroup(armyGroup)
      if logger then logger(TAG .. " bound QRF ARMYGROUP to concrete incident-target cycle group=" .. tostring(armyGroup and (armyGroup.groupname or armyGroup.alias or armyGroup.ClassName))) end
    end
  end
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
  local resolveTarget = needCallable(spec.resolveTarget or spec.resolveCoordinate, "resolveTarget")
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end
  if type(ZONE) ~= "table" or type(ZONE.FindByName) ~= "function" then fail("MOOSE ZONE:FindByName() is required") end
  if type(ZONE_RADIUS) ~= "table" or type(ZONE_RADIUS.New) ~= "function" then fail("MOOSE ZONE_RADIUS:New() is required") end
  if type(UTILS) ~= "table" or type(UTILS.NMToMeters) ~= "function" then fail("MOOSE UTILS.NMToMeters() is required") end
  local roadSpawnAdapter = packagedRoadSpawnAdapter()
  local targetCoordinates = {}
  local accessZones = {}
  local engageZones = {}
  for siteId, site in pairs(siteRegistry.Sites) do
    local brigade = needTable(brigades[siteId], "brigades[" .. tostring(siteId) .. "]")
    if type(site.accessZoneName) ~= "string" or site.accessZoneName == "" then fail("accessZoneName is required siteId=" .. tostring(siteId)) end
    if type(brigade.SetSpawnZone) ~= "function" then fail("BRIGADE/WAREHOUSE SetSpawnZone() is required siteId=" .. tostring(siteId)) end
    if type(brigade.GetCoordinate) ~= "function" then fail("BRIGADE GetCoordinate() is required siteId=" .. tostring(siteId)) end
    local accessZone = ZONE:FindByName(site.accessZoneName)
    if accessZone == nil then fail("ACCESS zone unavailable siteId=" .. tostring(siteId) .. " zone=" .. tostring(site.accessZoneName)) end
    accessZones[siteId] = accessZone
    local brigadeCoordinate = brigade:GetCoordinate()
    if type(brigadeCoordinate) ~= "table" or type(brigadeCoordinate.GetVec2) ~= "function" then fail("BRIGADE coordinate unavailable siteId=" .. tostring(siteId)) end
    engageZones[siteId] = ZONE_RADIUS:New("OMW_QRF_TACTICAL_" .. tostring(siteId), brigadeCoordinate:GetVec2(), UTILS.NMToMeters(QRF_TACTICAL_RADIUS_NM))
    brigade:SetSpawnZone(accessZone, HOME_SPAWN_ZONE_MAX_DIST_M)
    installBrigadeBinding(brigade, spec.logger)
    roadSpawnAdapter.Install(brigade, {
      resolveRoadSpawn = function(_, asset)
        if not mobileVehicle(asset) then return nil end
        local targetCoordinate = targetCoordinates[siteId]
        if targetCoordinate == nil then return nil end
        return { accessZone = accessZone, forwardCoordinate = targetCoordinate, entityId = tostring(site.installationId) .. "|QRF" }
      end,
      vehicleSpacingM = ROAD_SPAWN_VEHICLE_SPACING_M,
      log = function(message) if spec.logger then spec.logger(message) end end,
    })
  end
  local factory = qrfMissionFactory.New({
    resolveTarget = function(demand, context, legion)
      local target, reason = resolveTarget(demand, context, legion)
      if target ~= nil and type(target.GetCoordinate) == "function" then targetCoordinates[demand.siteId] = target:GetCoordinate() end
      return target, reason
    end,
    resolveTargets = function(_, context) return incidentUnits(context) end,
    resolveEngageZone = function(demand) local zone=engageZones[demand.siteId]; if zone==nil then return nil,"QRF_ENGAGE_ZONE_UNAVAILABLE" end; return zone end,
    engageSpeedKnots=QRF_ENGAGE_SPEED_KNOTS,
    engageFormation=QRF_ENGAGE_FORMATION,
    requiredAssetsMin=spec.requiredAssetsMin or 1,
    requiredAssetsMax=spec.requiredAssetsMax or (spec.requiredAssetsMin or 1),
    requiredAttributes=spec.requiredAttributes,
    requiredProperties=spec.requiredProperties,
    logger=spec.logger,
  })
  local bridge = legionBridge.New({ resolveLegion=function(siteId) local brigade=brigades[siteId]; if not brigade then return nil,"SITE_LEGION_NOT_CONFIGURED" end; return brigade end, factory=function(demand,context,legion) return factory:Create(demand,context,legion) end, logger=spec.logger })
  return setmetatable({siteRegistry=siteRegistry,brigades=brigades,factory=factory,dispatchBridge=bridge,targetCoordinates=targetCoordinates,accessZones=accessZones,engageZones=engageZones,logger=spec.logger}, Instance)
end
function Instance:_log(message) if self.logger then self.logger(TAG .. " " .. tostring(message)) end end
function Instance:Dispatch(demand, context)
  if type(demand) ~= "table" then fail("demand must be a table") end
  if demand.supportType ~= "QRF" then fail("supportType QRF is required") end
  if not self.siteRegistry.Sites[demand.siteId] then return nil,false,"SITE_NOT_FOUND" end
  local handle, created, reason = self.dispatchBridge:Dispatch(demand, context)
  if handle ~= nil then wrapQrfReleaseHandle(handle) end
  return handle, created, reason
end
return Runtime
