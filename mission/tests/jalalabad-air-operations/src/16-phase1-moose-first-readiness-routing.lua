-- Operation Mountain Watch - MOOSE-first readiness, routing and telemetry
local TAG = "[OMW][AirOps.JBAD.PH1.ROUTING]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Observer then
  log("ERROR: Phase-1 dependencies unavailable.")
else
  local routing = ph1.Routing or {}
  ph1.Routing = routing

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx, dz = (a.x or 0) - (b.x or 0), az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function landHeight(coordinate)
    if not coordinate or not coordinate.GetLandHeight then return nil end
    local ok, value = pcall(function() return coordinate:GetLandHeight() end)
    return ok and tonumber(value) or nil
  end

  local function sampleLeg(first, second, spacing)
    local a, b = first and first:GetVec3() or nil, second and second:GetVec3() or nil
    if not a or not b then return nil, nil, "coordinate-unavailable" end
    local length = distance2D(a, b)
    if not length then return nil, nil, "distance-unavailable" end
    local steps = math.max(1, math.ceil(length / math.max(100, spacing or 750)))
    local maximum = -math.huge
    for index = 0, steps do
      local fraction = index / steps
      local coordinate = COORDINATE:NewFromVec3({ x = a.x + (b.x - a.x) * fraction, y = 0, z = a.z + (b.z - a.z) * fraction })
      local height = landHeight(coordinate)
      if not height then return nil, nil, "terrain-height-unavailable" end
      maximum = math.max(maximum, height)
    end
    return maximum, length
  end

  function routing:BuildReconProfile(logResult)
    local airbase = cfg.Airbase or (AIRBASE and AIRBASE:FindByName(cfg.AirbaseName))
    if not airbase then return false, "Jalalabad airbase unavailable" end
    local coordinates = { airbase:GetCoordinate() }
    for _, name in ipairs(ph1.Objects.ReconZones) do
      local zone = ZONE and ZONE:FindByName(name) or nil
      if not zone then return false, "missing RECON zone: " .. tostring(name) end
      coordinates[#coordinates + 1] = zone:GetCoordinate()
    end
    coordinates[#coordinates + 1] = ZONE:FindByName(ph1.Objects.ReconZones[2]):GetCoordinate()
    coordinates[#coordinates + 1] = ZONE:FindByName(ph1.Objects.ReconZones[1]):GetCoordinate()
    coordinates[#coordinates + 1] = airbase:GetCoordinate()

    local profile = { TotalRouteMeters = 0, MaximumTerrainMeters = -math.huge, LegDistances = {}, LegTerrain = {}, SpeedKnots = 80 }
    for index = 1, #coordinates - 1 do
      local terrain, length, err = sampleLeg(coordinates[index], coordinates[index + 1], ph1.Limits.TerrainSampleSpacingMeters)
      if not terrain then return false, "RECON terrain scan failed: " .. tostring(err) end
      profile.LegDistances[index], profile.LegTerrain[index] = length, terrain
      profile.TotalRouteMeters = profile.TotalRouteMeters + length
      profile.MaximumTerrainMeters = math.max(profile.MaximumTerrainMeters, terrain)
    end
    profile.AltitudeFeet = math.ceil(((profile.MaximumTerrainMeters + ph1.Limits.ReconClearanceAGLMeters) * 3.280839895) / 100) * 100
    profile.MissionRangeNM = math.max(20, math.ceil(profile.TotalRouteMeters / 2 / 1852) + 5)
    self.ReconProfile = profile
    ph1.Tests.OH58D_RECON.MissionRangeNM = profile.MissionRangeNM
    if logResult then
      log(string.format("RECON_PROFILE READY route=%.0fm maxTerrain=%.0fm altitude=%dft_ASL missionRange=%dNM recovery=03->02->01->Jalalabad fuelLimit=telemetry-only",
        profile.TotalRouteMeters, profile.MaximumTerrainMeters, profile.AltitudeFeet, profile.MissionRangeNM))
    end
    return true, nil, profile
  end

  local function templateRoutePointCount(group)
    if not group then return nil end
    if group.GetTemplateRoutePoints then
      local ok, points = pcall(function() return group:GetTemplateRoutePoints() end)
      if ok and type(points) == "table" then return #points end
    end
    if group.GetTaskRoute then
      local ok, points = pcall(function() return group:GetTaskRoute() end)
      if ok and type(points) == "table" then return #points end
    end
    return nil
  end

  function routing:ValidateTestReady(testId, logResult)
    if testId == "OH58D_RECON" then return self:BuildReconProfile(logResult) end
    if testId == "UH60_TROOP" or testId == "UH60_ABORT" then
      local pickup, deploy = ZONE:FindByName(ph1.Objects.UHLoadZone), ZONE:FindByName(ph1.Objects.UHUnloadZone)
      if not pickup or not deploy then return false, "UH-60 pickup/deploy zones unavailable" end
      local centerDistance = distance2D(pickup:GetCoordinate(), deploy:GetCoordinate())
      local edgeGap = centerDistance - pickup:GetRadius() - deploy:GetRadius()
      if edgeGap <= 0 then return false, string.format("UH-60 pickup/deploy zones overlap by %.0fm", math.abs(edgeGap)) end
      local template = GROUP:FindByName(ph1.Objects.UHTroopTemplate)
      local routePoints = templateRoutePointCount(template)
      if routePoints and routePoints > 1 then return false, "troop cargo template has autonomous route points=" .. tostring(routePoints) end
      if logResult then log(string.format("GROUP_TRANSPORT_PROFILE READY distance=%.0fm edgeGap=%.0fm templateRoutePoints=%s authority=OPSTRANSPORT", centerDistance, edgeGap, tostring(routePoints or "unknown"))) end
      return true
    end
    if testId == "CH47_CARGO" then
      local cargo, pickup, drop = STATIC:FindByName(ph1.Objects.CH47Cargo, false), ZONE:FindByName(ph1.Objects.CH47PickupZone), ZONE:FindByName(ph1.Objects.CH47DropZone)
      if not cargo or not pickup or not drop then return false, "CH-47 cargo objects unavailable" end
      if not cargo:IsInZone(pickup) then return false, "CH-47 static cargo not inside pickup zone" end
      if cargo:IsInZone(drop) then return false, "CH-47 static cargo already inside drop zone" end
      if logResult then log("SLING_CARGO_PROFILE READY authority=AUFTRAG:NewCARGOTRANSPORT physicalSuccess=STATIC:IsInZone") end
      return true
    end
    if logResult then log("TEST_READINESS READY testId=" .. tostring(testId) .. " additionalChecks=none") end
    return true
  end

  local function fuelTelemetry(groupName)
    if not ph1.Runtime or not ph1.Runtime.BoundGroupNames[groupName] then return false end
    local group = GROUP and GROUP:FindByName(groupName) or nil
    if not group then return false end
    for _, unit in ipairs(group:GetUnits() or {}) do
      local fuel = nil
      local dcs = unit.GetDCSObject and unit:GetDCSObject() or nil
      if dcs and dcs.getFuel then
        local ok, value = pcall(function() return dcs:getFuel() end)
        if ok then fuel = value end
      end
      local coordinate = unit:GetCoordinate()
      log(string.format("FUEL testId=%s group=%s unit=%s fuel=%s altitudeMSL=%.0fm terrainMSL=%.0fm",
        tostring(ph1.ActiveTestId), groupName, unit:GetName(), fuel and string.format("%.1f%%", fuel * 100) or "unknown",
        coordinate and coordinate.y or -1, coordinate and (landHeight(coordinate) or -1) or -1))
    end
    return true
  end

  function routing:OnFlightGroupBound(flightgroup, owner)
    if not ph1.Runtime or not ph1.ActiveDefinition then return end
    local groupName = flightgroup:GetName()
    if ph1.ActiveTestId == "OH58D_RECON" and ph1.ActiveKind == "AUFTRAG" then
      local zone1 = ZONE:FindByName(ph1.Objects.ReconZones[1])
      local profile = self.ReconProfile
      local egressUID = owner.GetGroupEgressWaypointUID and owner:GetGroupEgressWaypointUID(flightgroup) or nil
      if not zone1 or not profile or not egressUID or not flightgroup.AddWaypoint then
        ph1.Runtime.HardFailure = "recovery-corridor-MOOSE-waypoint-unavailable"
        return
      end
      local ok, waypoint = pcall(function()
        return flightgroup:AddWaypoint(zone1:GetCoordinate(), profile.SpeedKnots, egressUID, profile.AltitudeFeet, false)
      end)
      if not ok or not waypoint then
        ph1.Runtime.HardFailure = "recovery-corridor-add-waypoint-failed"
        return
      end
      if flightgroup.UpdateRoute then flightgroup:UpdateRoute() end
      ph1.Runtime.RecoveryCorridorApplied = true
      log("RECOVERY_CORRIDOR_APPLIED group=" .. groupName .. " route=RECON_03->RECON_02->RECON_01->Jalalabad MOOSE=SetMissionEgressCoord/AddWaypoint/UpdateRoute")
    end

    if SCHEDULER then
      local telemetryScheduler
      telemetryScheduler = SCHEDULER:New(nil, function()
        if not fuelTelemetry(groupName) then
          if telemetryScheduler and telemetryScheduler.Stop then telemetryScheduler:Stop() end
        end
      end, {}, 30, ph1.Limits.FuelTelemetryIntervalSeconds)
    end
  end

  log("READY publicMOOSE=true routeAuthority=AUFTRAG+FLIGHTGROUP terrainPolicy=project-specific-advisory fuel=empirical-telemetry selfStoppingSchedulers=true")
end
