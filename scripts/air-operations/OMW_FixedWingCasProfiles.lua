-- Explicit A5 test profiles and read-only MOOSE geometry/capacity adapters.
-- No claim of historical SID/holding clearance or DCS-validated terrain separation.
local Profiles = { SchemaVersion = "OMW-FIXED-WING-CAS-PROFILES-1" }
local NM = 1852
local function finite(x) return type(x) == "number" and x == x and math.abs(x) < math.huge end
local function coordinate(object)
  if not object then return nil end
  if object.x and object.z then return object end
  if object.GetCoordinate then return object:GetCoordinate() end
end

-- Read-only public UNIT telemetry. A phase gate, not an engine-state detector.
-- This deliberately excludes departure holding, climb and changing airspeed.
function Profiles.RecoverySample(profile, unit, timeS, previous)
  if previous and previous.timeS == timeS then return previous.qualified, previous end
  local c = unit:GetCoordinate()
  local speed = unit:GetAirspeedTrue()
  local altitude = c and c.y
  local sample = { timeS = timeS, altitude = altitude, speed = speed, qualified = false }
  if not previous or not finite(altitude) or not finite(speed)
      or not finite(previous.altitude) or not finite(previous.speed) then return false, sample end
  local dt = timeS - previous.timeS
  if dt <= 0 or dt > 2 * profile.observerPeriodS then return false, sample end
  sample.qualified = math.abs(altitude - UTILS.FeetToMeters(profile.cruiseAltitudeFt)) <= UTILS.FeetToMeters(1000)
    and math.abs(altitude - previous.altitude) / dt <= UTILS.FeetToMeters(500) / 60
    and math.abs(speed - previous.speed) / dt <= UTILS.KnotsToMps(20) / 60
  return sample.qualified, sample
end

function Profiles.Get(id)
  local p = {
    reserveS = 45 * 60, cruiseAltitudeFt = 22000, observerPeriodS = 15,
    terrainClearanceFt = 2500, expectedElements = 2,
  }
  if id == "CAS_F16" then
    p.cruiseKtas, p.casKias, p.holdKtas = 450, 250, 230
    p.referenceFractionPerS = (0.29535192251205 - 0.00084401242202148) / (59136 - 57906)
    p.sortie = { stationS = 150 * 60, plannedS = 4 * 3600, absoluteS = 5 * 3600 }
    p.areas, p.receiver = { "NELSON", "LISA", "MOE" }, "FAST"
    p.departure = { offsetHeading = 270, offsetNm = 3, heading = 0, legNm = 4, floorFt = 8500 }
  elseif id == "CAS_F15E" then
    p.cruiseKtas, p.casKias, p.holdKtas = 460, 250, 230
    p.referenceFractionPerS = (0.38249319791794 - 0.22443883121014) / (64836 - 63336)
    p.sortie = { stationS = 180 * 60, plannedS = 5 * 3600, absoluteS = 6 * 3600 }
    p.areas, p.receiver = { "NELSON", "LISA", "MOE" }, "FAST"
    p.departure = { offsetHeading = 270, offsetNm = 3, heading = 0, legNm = 4, floorFt = 8500 }
  elseif id == "CAS_A10" then
    p.cruiseKtas, p.casKias, p.holdKtas = 260, 180, 195
    p.referenceFractionPerS = (0.2966793179512 - 0.000700454111211) / (81517 - 76972)
    p.sortie = { stationS = 240 * 60, plannedS = 8 * 3600, absoluteS = 10 * 3600 }
    p.areas, p.receiver = { "PATTY", "KRUSTY", "MILHOUSE" }, "SLOW"
    p.departure = { offsetHeading = 315, offsetNm = 3, legNm = 3, floorFt = 6500 }
  else error("unknown fixed-wing profile " .. tostring(id)) end
  return p
end

-- Native RTB uses a random point inside the airbase zone, then a 10-NM final
-- and 5-NM landing point. Bound its horizontal travel by center distance,
-- twice the airbase-zone radius, and 20 NM for the approach/landing geometry.
-- The additional 45 minutes are time/fuel allowance, counted once by Policy.
function Profiles.RouteTimes(profile, units, destination, ao, viaAo)
  local dest = coordinate(destination)
  if not dest then return nil, "DESTINATION_COORDINATE_MISSING" end
  local airbase = destination.GetZone ~= nil
  local times = {}
  local function leg(a, b)
    local distance = a:Get2DDistance(b)
    if not finite(distance) then return nil end
    if distance == 0 then return 0 end
    local wind = a:GetWindVec3(UTILS.FeetToMeters(profile.cruiseAltitudeFt), false)
    if not wind or not finite(wind.x) or not finite(wind.z) then return nil end
    local along = (wind.x * (b.x - a.x) + wind.z * (b.z - a.z)) / distance
    local speed = math.min(UTILS.KnotsToMps(profile.cruiseKtas),
      UTILS.KnotsToMps(profile.cruiseKtas) + along) -- no unearned tailwind credit.
    if speed <= 0 then return nil end
    return distance / speed
  end
  for id, unit in pairs(units) do
    local origin = unit:GetCoordinate()
    if not origin then return nil, "ELEMENT_COORDINATE_MISSING" end
    local routeS
    if viaAo then
      local target = coordinate(ao)
      if not target then return nil, "AO_COORDINATE_MISSING" end
      local out, back = leg(origin, target), leg(target, dest)
      if out and back then routeS = out + back end
    else routeS = leg(origin, dest) end
    if not routeS then return nil, "INVALID_WIND_OR_ROUTE" end
    if airbase then
      local zone = destination:GetZone()
      local radius = zone and zone:GetRadius()
      if not finite(radius) then return nil, "AIRBASE_ZONE_BOUND_UNAVAILABLE" end
      routeS = routeS + 2 * radius / UTILS.KnotsToMps(profile.cruiseKtas)
        + 20 * NM / UTILS.KnotsToMps(170)
    else
      -- AAR coordinates are a rendezvous area, not a stationary tanker lock.
      -- All six operational tracks have a published 35-NM leg.
      routeS = routeS + 35 * NM / UTILS.KnotsToMps(profile.cruiseKtas)
      local distance = origin:Get2DDistance(dest)
      local steps = math.max(2, math.ceil(distance / (5 * NM)))
      for i = 1, steps - 1 do
        local fraction = i / steps
        local point = origin:GetIntermediateCoordinate(dest, fraction)
        local terrain = point:GetLandHeight()
        local altitude = origin.y + (dest.y - origin.y) * fraction
        if not finite(terrain) or altitude - terrain < UTILS.FeetToMeters(profile.terrainClearanceFt) then
          return nil, "AAR_ACCESS_TERRAIN_MARGIN_UNPROVEN"
        end
      end
    end
    times[id] = routeS
  end
  return times
end

-- Capacity extrapolation uses the accepted KC-135 track reserve burn rates,
-- not receiver consumption. It does not reserve donor fuel or lock DCS targeting.
local donorReservePct = { NELSON = 9.5482, PATTY = 7.9209, KRUSTY = 6.6384,
  MILHOUSE = 6.6748, LISA = 7.6182, MOE = 8.4708 }

function Profiles.SelectTanker(profile, adapter, aar, ao)
  local function diagnostic(area, reason, values)
    adapter.tankerDiagnostics = adapter.tankerDiagnostics or {}
    if adapter.tankerDiagnostics[area] == reason then return end
    adapter.tankerDiagnostics[area] = reason
    if adapter.Log then
      values = values or {}; values.area, values.reason = area, reason
      adapter:Log("AAR_CANDIDATE_EVALUATED", values)
    end
  end
  if not aar or not aar.GetActive or not aar.GetStation then
    diagnostic("ALL", "AAR_INTERFACE_UNAVAILABLE"); return nil
  end
  local function evaluate(area)
    local r, station = aar.GetActive(area, profile.receiver), aar.GetStation(area, profile.receiver)
    if not r or not station then return nil, "NO_ACTIVE_RUNTIME" end
    if not r.onStationAt then return nil, "NOT_ON_STATION" end
    if r.egressOrdered or r.lossHandled or not r.group or not r.group:IsAlive() or not r.flightGroup then
      return nil, "RUNTIME_UNAVAILABLE"
    end
    local donor = r.group:GetUnit(1)
    if not donor then return nil, "DONOR_UNIT_UNAVAILABLE" end
    local tanker, system = donor:IsTanker()
    if not tanker or system ~= adapter.flight.refueltype then return nil, "INCOMPATIBLE_SYSTEM" end
    local target = r.group:GetCoordinate()
    if not target then return nil, "DONOR_COORDINATE_UNAVAILABLE" end
    local times, routeReason = Profiles.RouteTimes(profile, adapter.airborneUnits, target, ao, false)
    if not times then return nil, routeReason or "AAR_ROUTE_UNPROVEN" end
    local budget = adapter.policy:Assess(times)
    if not budget.valid or not budget.safe then return nil, "AAR_ACCESS_BUDGET_UNSAFE" end
    local _, donorInternal = donor:GetFuelMassMax()
    local donorFuel = donor:GetCurrentFuelKgs()
    local threshold = r.areaSpec and r.areaSpec.fuelLowPct
    if not finite(donorInternal) or donorInternal <= 0 or not finite(donorFuel)
        or not finite(threshold) or not finite(station.nextPlannedHandoverAt) then
      return nil, "DONOR_FUEL_OR_WINDOW_UNKNOWN"
    end
    local remainingWindow = station.nextPlannedHandoverAt - timer.getAbsTime()
    local accessAndService = budget.maxTimeS + profile.reserveS
    if remainingWindow <= accessAndService then return nil, "INSUFFICIENT_STATION_WINDOW" end
    local intake, postAarUnits = 0, {}
    for id in pairs(budget.elements) do
      postAarUnits[id] = { GetCoordinate = function() return target end }
    end
    local home = adapter.flight.destbase or adapter.flight.homebase
    local postTimes = home and Profiles.RouteTimes(profile, postAarUnits, home, ao, false)
    if not postTimes then return nil, "POST_AAR_HOME_ROUTE_UNKNOWN" end
    for id, e in pairs(budget.elements) do
      local internal = adapter.policy.elements[id].internalKg
      local arrivalFuel = math.max(0, e.availableKg - e.tripKg - e.allowanceKg)
      intake = intake + math.max(0, internal - arrivalFuel)
      if not postTimes[id] or math.max(internal, arrivalFuel) <= (postTimes[id] + profile.reserveS) * e.rateKgS then
        return nil, "POST_AAR_HOME_BUDGET_UNSAFE"
      end
    end
    local predictedDonorBurn = donorInternal * donorReservePct[area] / 100 / (45 * 60) * accessAndService
    local excess = donorFuel - donorInternal * threshold / 100 - predictedDonorBurn - intake
    if excess <= 0 then return nil, "INSUFFICIENT_DONOR_OFFLOAD" end
    return { area = area, coordinate = target, runtime = r, marginKg = budget.marginKg,
      donorExcessKg = excess, accessS = budget.maxTimeS }, "ELIGIBLE"
  end
  local choice
  for _, area in ipairs(profile.areas) do
    local candidate, reason = evaluate(area)
    diagnostic(area, reason, candidate and { accessS = candidate.accessS, marginKg = candidate.marginKg })
    if candidate and (not choice or candidate.accessS < choice.accessS) then choice = candidate end
  end
  return choice
end

function Profiles.Departure(profile, base, ao)
  local p = profile.departure
  local heading = p.heading or base:HeadingTo(ao)
  local first = base:Translate(p.offsetNm * NM, p.offsetHeading, true)
  local last = first:Translate(p.legNm * NM, heading, true)
  -- Include inbound corridor and a turn envelope, not only the centerline.
  local peak = -math.huge
  local function sample(c)
    local h = c:GetLandHeight()
    if not finite(h) then error("departure terrain unavailable") end
    peak = math.max(peak, h)
  end
  for i = 0, 8 do sample(base:GetIntermediateCoordinate(first, i / 8)) end
  for i = 0, 6 do
    local c = first:GetIntermediateCoordinate(last, i / 6)
    for _, bearing in ipairs({ 0, 45, 90, 135, 180, 225, 270, 315 }) do
      sample(c:Translate(2 * NM, bearing, true))
    end
    sample(c)
  end
  return { startCoord = first, endCoord = last, angle = heading, terrainM = peak,
    altitudeFt = math.max(p.floorFt, UTILS.MetersToFeet(peak) + profile.terrainClearanceFt),
    speedKts = profile.holdKtas, legNm = p.legNm, offsetHeading = p.offsetHeading, offsetNm = p.offsetNm }
end

return Profiles

