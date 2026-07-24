-- Operation Mountain Watch - Phase 1 per-test readiness and empirical RECON telemetry
-- Removes unvalidated range/fuel heuristics as global blockers. Route distances,
-- terrain and altitude remain visible as warnings until DCS fuel data supports
-- a defensible operational limit.
local TAG = "[OMW][AirOps.JBAD.PH1.READINESS]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local factory = ph1 and ph1.Factory
local controller = ph1 and ph1.Controller
if not cfg or not ph1 or not factory or not controller then
  log("ERROR: Phase 1 runtime unavailable.")
else
  ph1.Version = "JBAD-PHASE1-5"

  local reconPolicy = ph1.OperationalPolicy and ph1.OperationalPolicy.Recon or {}
  local troopPolicy = ph1.OperationalPolicy and ph1.OperationalPolicy.Troop or {}

  -- These values are advisory only. They are retained so the log can flag a
  -- demanding route, but they are not a fuel model and must not block a test.
  ph1.AdvisoryPolicy = {
    Recon = {
      ZoneDistanceMeters = 18000,
      LegDistanceMeters = 11000,
      TotalRouteMeters = 42000,
      SampledTerrainMeters = 1300,
      MissionAltitudeFeet = 6500
    },
    FuelTelemetryIntervalSeconds = 60
  }

  -- Neutralize the former hard heuristic gates used inside the Phase-1-4
  -- factory. Missing objects, unavailable terrain data and practically
  -- identical zones remain hard errors; range and terrain magnitude do not.
  reconPolicy.MaxZoneDistanceFromBaseMeters = 1000000000
  reconPolicy.MaxLegDistanceMeters = 1000000000
  reconPolicy.MaxTotalRouteMeters = 1000000000
  reconPolicy.MaxSampledTerrainMeters = 100000
  reconPolicy.MaxMissionAltitudeFeet = 500000
  reconPolicy.MinZoneSeparationMeters = 250
  ph1.Tests.OH58D_RECON.MissionRangeNM = 50

  troopPolicy.MinimumLoadDropDistanceMeters = 0
  troopPolicy.MaximumLoadDropDistanceMeters = 1000000000
  troopPolicy.MinimumZoneEdgeGapMeters = 0
  troopPolicy.MaximumTerrainDifferenceMeters = 1000000000

  local function distance2D(first, second)
    if not first or not second then return nil end
    local a = first.GetVec3 and first:GetVec3() or first
    local b = second.GetVec3 and second:GetVec3() or second
    if not a or not b then return nil end
    local az = a.z == nil and (a.y or 0) or a.z
    local bz = b.z == nil and (b.y or 0) or b.z
    local dx = (a.x or 0) - (b.x or 0)
    local dz = az - bz
    return math.sqrt(dx * dx + dz * dz)
  end

  local function landHeight(coordinate)
    if not coordinate or not coordinate.GetLandHeight then return nil end
    local ok, height = pcall(function() return coordinate:GetLandHeight() end)
    return ok and tonumber(height) or nil
  end

  local function sampleLeg(first, second, spacing)
    local a = first and first:GetVec3() or nil
    local b = second and second:GetVec3() or nil
    if not a or not b then return nil, "coordinate-unavailable" end
    local length = distance2D(a, b)
    if not length then return nil, "distance-unavailable" end
    local steps = math.max(1, math.ceil(length / math.max(100, spacing or 750)))
    local maximum = -math.huge
    for index = 0, steps do
      local fraction = index / steps
      local coordinate = COORDINATE:NewFromVec3({
        x = a.x + (b.x - a.x) * fraction,
        y = 0,
        z = a.z + (b.z - a.z) * fraction
      })
      local height = landHeight(coordinate)
      if not height then return nil, "terrain-height-unavailable" end
      if height > maximum then maximum = height end
    end
    return maximum, nil, length
  end

  local function missionTemplate(name)
    return _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and _DATABASE.Templates.Groups[name] or nil
  end

  local function validateBaseObjects(logResult)
    local missing = {}
    for _, zoneName in ipairs(ph1.Objects.ReconZones or {}) do
      if not (ZONE and ZONE:FindByName(zoneName)) then missing[#missing + 1] = zoneName end
    end
    for _, zoneName in ipairs({
      ph1.Objects.CASZone,
      ph1.Objects.UHLoadZone,
      ph1.Objects.UHUnloadZone,
      ph1.Objects.CH47PickupZone,
      ph1.Objects.CH47DropZone
    }) do
      if zoneName and not (ZONE and ZONE:FindByName(zoneName)) then missing[#missing + 1] = zoneName end
    end
    for _, groupName in ipairs({ ph1.Objects.CASTargetTemplate, ph1.Objects.UHTroopTemplate }) do
      if groupName and not missionTemplate(groupName) then missing[#missing + 1] = groupName end
    end
    if not (STATIC and STATIC:FindByName(ph1.Objects.CH47Cargo, false)) then
      missing[#missing + 1] = ph1.Objects.CH47Cargo
    end

    ph1.MissingMissionEditorObjects = missing
    ph1.FactoryReady = #missing == 0
    if logResult then
      if ph1.FactoryReady then
        log("ME_OBJECTS PASS baseObjects=true routeSpecificChecks=DEFERRED_PER_TEST")
      else
        log("ME_OBJECTS BLOCKED missing=" .. table.concat(missing, ","))
      end
    end
    return ph1.FactoryReady, missing
  end

  local function reconProfile(logResult)
    local airbase = cfg.Airbase or (AIRBASE and AIRBASE:FindByName(cfg.AirbaseName))
    if not airbase then return false, "Jalalabad airbase unavailable" end

    local coordinates = { airbase:GetCoordinate() }
    local zones = {}
    for _, zoneName in ipairs(ph1.Objects.ReconZones or {}) do
      local zone = ZONE and ZONE:FindByName(zoneName) or nil
      if not zone then return false, "missing RECON zone: " .. tostring(zoneName) end
      zones[#zones + 1] = zone
      coordinates[#coordinates + 1] = zone:GetCoordinate()
    end
    coordinates[#coordinates + 1] = airbase:GetCoordinate()

    for index = 2, #coordinates - 2 do
      local separation = distance2D(coordinates[index], coordinates[index + 1])
      if not separation or separation < 250 then
        return false, string.format("RECON zones %d/%d are not distinct; separation=%.0fm minimum=250m", index - 1, index, separation or -1)
      end
    end

    local profile = {
      ZoneDistances = {},
      LegDistances = {},
      LegTerrain = {},
      TotalRouteMeters = 0,
      MaximumTerrainMeters = -math.huge,
      Warnings = {}
    }
    local advisory = ph1.AdvisoryPolicy.Recon

    for index = 2, #coordinates - 1 do
      local value = distance2D(coordinates[1], coordinates[index])
      if not value then return false, "RECON zone distance unavailable" end
      profile.ZoneDistances[index - 1] = value
      if value > advisory.ZoneDistanceMeters then
        profile.Warnings[#profile.Warnings + 1] = string.format("zone%dDistance=%.0fm advisory=%dm", index - 1, value, advisory.ZoneDistanceMeters)
      end
    end

    for index = 1, #coordinates - 1 do
      local terrain, err, length = sampleLeg(coordinates[index], coordinates[index + 1], reconPolicy.TerrainSampleSpacingMeters or 750)
      if not terrain then return false, "RECON leg terrain scan failed: " .. tostring(err) end
      profile.LegDistances[index] = length
      profile.LegTerrain[index] = terrain
      profile.TotalRouteMeters = profile.TotalRouteMeters + length
      profile.MaximumTerrainMeters = math.max(profile.MaximumTerrainMeters, terrain)
      if length > advisory.LegDistanceMeters then
        profile.Warnings[#profile.Warnings + 1] = string.format("leg%d=%.0fm advisory=%dm", index, length, advisory.LegDistanceMeters)
      end
      if terrain > advisory.SampledTerrainMeters then
        profile.Warnings[#profile.Warnings + 1] = string.format("leg%dTerrain=%.0fm advisory=%dm", index, terrain, advisory.SampledTerrainMeters)
      end
    end

    if profile.TotalRouteMeters > advisory.TotalRouteMeters then
      profile.Warnings[#profile.Warnings + 1] = string.format("route=%.0fm advisory=%dm", profile.TotalRouteMeters, advisory.TotalRouteMeters)
    end

    profile.AltitudeFeet = math.ceil(((profile.MaximumTerrainMeters + (reconPolicy.ClearanceAGLMeters or 350)) * 3.280839895) / 100) * 100
    if profile.AltitudeFeet > advisory.MissionAltitudeFeet then
      profile.Warnings[#profile.Warnings + 1] = string.format("altitude=%dft advisory=%dft", profile.AltitudeFeet, advisory.MissionAltitudeFeet)
    end

    local farthest = 0
    for _, value in ipairs(profile.ZoneDistances) do farthest = math.max(farthest, value) end
    ph1.Tests.OH58D_RECON.MissionRangeNM = math.max(20, math.min(50, math.ceil(farthest / 1852) + 5))
    ph1.ReconProfile = profile

    if logResult then
      local warningText = #profile.Warnings > 0 and table.concat(profile.Warnings, ";") or "none"
      log(string.format("RECON_PROFILE READY route=%.0fm maxTerrain=%.0fm computedAltitude=%dft_ASL missionRange=%dNM warnings=%s blockingFuelModel=false", profile.TotalRouteMeters, profile.MaximumTerrainMeters, profile.AltitudeFeet, ph1.Tests.OH58D_RECON.MissionRangeNM, warningText))
    end
    return true, nil, profile
  end

  local function troopTemplateRoutePoints()
    local entry = missionTemplate(ph1.Objects.UHTroopTemplate)
    local route = entry and entry.Template and entry.Template.route or nil
    return route and route.points and #route.points or 0
  end

  local function troopProfile(logResult)
    local loadZone = ZONE and ZONE:FindByName(ph1.Objects.UHLoadZone) or nil
    local dropZone = ZONE and ZONE:FindByName(ph1.Objects.UHUnloadZone) or nil
    if not loadZone then return false, "missing UH-60 load zone: " .. tostring(ph1.Objects.UHLoadZone) end
    if not dropZone then return false, "missing dedicated UH-60 drop zone: " .. tostring(ph1.Objects.UHUnloadZone) end

    local points = troopTemplateRoutePoints()
    if points > (troopPolicy.MaxTemplateRoutePoints or 1) then
      return false, string.format("troop template has %d route points; maximum=%d", points, troopPolicy.MaxTemplateRoutePoints or 1)
    end

    local centerDistance = distance2D(loadZone:GetCoordinate(), dropZone:GetCoordinate())
    if not centerDistance then return false, "UH-60 load/drop distance unavailable" end
    local edgeGap = centerDistance - loadZone:GetRadius() - dropZone:GetRadius()
    if edgeGap < 0 then
      return false, string.format("UH-60 load/drop zones overlap by %.0fm", math.abs(edgeGap))
    end

    local loadHeight = landHeight(loadZone:GetCoordinate())
    local dropHeight = landHeight(dropZone:GetCoordinate())
    if not loadHeight or not dropHeight then return false, "UH-60 load/drop terrain height unavailable" end

    ph1.TroopProfile = {
      DistanceMeters = centerDistance,
      EdgeGapMeters = edgeGap,
      TerrainDifferenceMeters = math.abs(loadHeight - dropHeight),
      TemplateRoutePoints = points
    }
    if logResult then
      log(string.format("TROOP_PROFILE READY distance=%.0fm edgeGap=%.0fm terrainDelta=%.0fm templateRoutePoints=%d heuristicDistanceBlocks=false", centerDistance, edgeGap, math.abs(loadHeight - dropHeight), points))
    end
    return true
  end

  function factory:ValidateMissionEditorObjects()
    return validateBaseObjects(true)
  end

  function factory:ValidateTestReady(testId, logResult)
    local baseOK, missing = validateBaseObjects(false)
    if not baseOK then return false, "missing Mission Editor objects: " .. table.concat(missing, ",") end

    if testId == "OH58D_RECON" then
      return reconProfile(logResult)
    elseif testId == "UH60_TROOP" or testId == "UH60_ABORT" then
      return troopProfile(logResult)
    elseif testId == "AH64D_CAS" or testId == "CH47_CARGO" then
      if logResult then log("TEST_READINESS READY testId=" .. tostring(testId) .. " routeSpecificChecks=none") end
      return true
    end
    return false, "unknown test: " .. tostring(testId)
  end

  local previousCreate = factory.Create
  function factory:Create(testId)
    local ready, reason = self:ValidateTestReady(testId, true)
    if not ready then return nil, "test-not-ready: " .. tostring(reason) end
    return previousCreate(self, testId)
  end

  local function queueCount()
    local count = 0
    for _ in pairs((cfg.Airwing and cfg.Airwing.missionqueue) or {}) do count = count + 1 end
    return count
  end

  local expectedAssetGroups = { OH58D = 24, AH64D = 8, UH60 = 8, CH47 = 8 }
  local function inventoryReady(snapshots)
    for key, expected in pairs(expectedAssetGroups) do
      local item = snapshots and snapshots[key]
      if not item or item.total ~= expected or item.busy ~= 0 or item.available ~= expected then
        return false, string.format("%s total=%s available=%s busy=%s expected=%d", key, item and item.total or "nil", item and item.available or "nil", item and item.busy or "nil", expected)
      end
    end
    return true
  end

  function controller:InitializeWhenReady()
    if ph1.State ~= "WAITING_FOR_BASELINE" and ph1.State ~= "BLOCKED" then return true end
    if cfg.Status ~= "OPERATIONAL" or not cfg.Airwing then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = "Jalalabad AIRWING baseline not operational"
      return false
    end
    cfg.BaselineReady = true

    if cfg.ParkingReservationsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-reservation-regression" return false end
    if cfg.ParkingPoolsOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "parking-pools-invalid" return false end
    if cfg.NameContractOK ~= true then ph1.State = "BLOCKED" ph1.BlockReason = "runtime-name-contract-invalid" return false end

    local objectsReady, missing = factory:ValidateMissionEditorObjects()
    if not objectsReady then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "missing Mission Editor objects: " .. table.concat(missing or {}, ",")
      return false
    end

    if not ph1.ClientParkingResolved and not ph1.Observer:ResolveClientParkingIDs() then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "client-parking-unresolved"
      return false
    end

    local snapshots = ph1.Observer:SnapshotAllSquadrons()
    local inventoryOK, inventoryReason = inventoryReady(snapshots)
    if not inventoryOK then
      ph1.State = "WAITING_FOR_BASELINE"
      ph1.BlockReason = inventoryReason
      return false
    end
    if queueCount() ~= 0 then
      ph1.State = "BLOCKED"
      ph1.BlockReason = "pre-existing-airwing-mission-queue"
      return false
    end

    ph1.State = "READY"
    ph1.BlockReason = nil
    ph1.Observer:LogSnapshot("PHASE1_READY", snapshots)
    if cfg.VerticalHelicopterOpsEnabled ~= true then
      log("WARNING vertical helicopter preference unavailable; tests remain runnable and DCS taxi behavior must be observed")
    end
    log("READY globalGate=BASELINE_ONLY perTestReadiness=true heuristicRangeFuelBlocks=false inventory=24/8/8/8")
    return true
  end

  local previousStartTest = controller.StartTest
  function controller:StartTest(testId)
    if not ph1.ActiveMission then
      local ready, reason = factory:ValidateTestReady(testId, true)
      if not ready then
        ph1.BlockReason = tostring(testId) .. ": " .. tostring(reason)
        log("TEST_START_BLOCKED testId=" .. tostring(testId) .. " reason=" .. tostring(reason))
        if trigger and trigger.action and trigger.action.outTextForCoalition then
          trigger.action.outTextForCoalition(coalition.side.BLUE, "OMW Jalalabad Phase 1\nNicht bereit: " .. tostring(ph1.BlockReason), 20)
        end
        return false
      end
    end
    return previousStartTest(self, testId)
  end

  local function unitFuel(unit)
    if not unit or not unit.GetDCSObject then return nil end
    local ok, dcsUnit = pcall(function() return unit:GetDCSObject() end)
    if not ok or not dcsUnit or not dcsUnit.getFuel then return nil end
    local fuelOK, fuel = pcall(function() return dcsUnit:getFuel() end)
    return fuelOK and tonumber(fuel) or nil
  end

  local function unitCoordinate(unit)
    if not unit or not unit.GetCoordinate then return nil end
    local ok, coordinate = pcall(function() return unit:GetCoordinate() end)
    return ok and coordinate or nil
  end

  local function coordinateInZone(coordinate, zone)
    local distance = coordinate and zone and distance2D(coordinate, zone:GetCoordinate()) or nil
    return distance and distance <= zone:GetRadius() or false
  end

  local function logFuelStage(runtime, unitName, unit, stage)
    local fuel = unitFuel(unit)
    local coordinate = unitCoordinate(unit)
    local terrain = landHeight(coordinate)
    local vec3 = coordinate and coordinate:GetVec3() or nil
    local altitude = vec3 and vec3.y or nil
    log(string.format("RECON_FUEL testId=OH58D_RECON groupUnit=%s stage=%s fuelPercent=%s altitudeMSL=%s terrainMSL=%s time=%.1f", tostring(unitName), tostring(stage), fuel and string.format("%.1f", fuel * 100) or "unknown", altitude and string.format("%.0f", altitude) or "unknown", terrain and string.format("%.0f", terrain) or "unknown", timer.getTime()))
  end

  local function pollReconFuel()
    local runtime = ph1.Runtime
    if ph1.ActiveTestId ~= "OH58D_RECON" or not runtime then return end
    runtime.ReconFuelZoneSeen = runtime.ReconFuelZoneSeen or {}
    runtime.ReconFuelRTBSeen = runtime.ReconFuelRTBSeen or {}

    for groupName in pairs(runtime.ExpectedGroupNames or {}) do
      local group = GROUP and GROUP:FindByName(groupName) or nil
      if group and group:IsAlive() then
        for _, unit in ipairs(group:GetUnits() or {}) do
          local unitName = unit:GetName()
          local coordinate = unitCoordinate(unit)
          for index, zoneName in ipairs(ph1.Objects.ReconZones or {}) do
            local key = unitName .. ":ZONE_" .. tostring(index)
            local zone = ZONE and ZONE:FindByName(zoneName) or nil
            if not runtime.ReconFuelZoneSeen[key] and coordinateInZone(coordinate, zone) then
              runtime.ReconFuelZoneSeen[key] = true
              logFuelStage(runtime, unitName, unit, "ZONE_" .. tostring(index))
            end
          end
          if runtime.RTBObserved and not runtime.ReconFuelRTBSeen[unitName] then
            runtime.ReconFuelRTBSeen[unitName] = true
            logFuelStage(runtime, unitName, unit, "RTB_OBSERVED")
          end
        end
      end
    end

    local now = timer.getTime()
    if not runtime.LastReconFuelPeriodicAt or now - runtime.LastReconFuelPeriodicAt >= ph1.AdvisoryPolicy.FuelTelemetryIntervalSeconds then
      runtime.LastReconFuelPeriodicAt = now
      for groupName in pairs(runtime.ExpectedGroupNames or {}) do
        local group = GROUP and GROUP:FindByName(groupName) or nil
        if group and group:IsAlive() then
          for _, unit in ipairs(group:GetUnits() or {}) do
            logFuelStage(runtime, unit:GetName(), unit, "PERIODIC")
          end
        end
      end
    end
  end

  SCHEDULER:New(nil, pollReconFuel, {}, 30, 15)

  log("READY version=JBAD-PHASE1-5 globalGate=baseline-only perTestReadiness=true rangeTerrainThresholds=advisory fuelLimits=empirical-pending reconFuelTelemetry=true")
end
