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
  if not aar or not aar.GetActive or not aar.GetStation then return nil end
  local choice
  for _, area in ipairs(profile.areas) do
    local r, station = aar.GetActive(area, profile.receiver), aar.GetStation(area, profile.receiver)
    if r and r.onStationAt and not r.egressOrdered and not r.lossHandled
        and r.group and r.group:IsAlive() and r.flightGroup and station then
      local donor = r.group:GetUnit(1)
      local tanker, system
      if donor then tanker, system = donor:IsTanker() end
      if tanker and system == adapter.flight.refueltype then
        local target = r.group:GetCoordinate()
        local times = Profiles.RouteTimes(profile, adapter.airborneUnits, target, ao, false)
        local budget = times and adapter.policy:Assess(times)
        local _, donorInternal = donor:GetFuelMassMax()
        local donorFuel = donor:GetCurrentFuelKgs()
        local threshold = r.areaSpec and r.areaSpec.fuelLowPct
        if budget and budget.valid and budget.safe and finite(donorInternal) and donorInternal > 0
            and finite(donorFuel) and finite(threshold) and finite(station.nextPlannedHandoverAt) then
          local remainingWindow = station.nextPlannedHandoverAt - timer.getAbsTime()
          local accessAndService = budget.maxTimeS + profile.reserveS
          local intake, postAarUnits = 0, {}
          for id in pairs(budget.elements) do
            postAarUnits[id] = { GetCoordinate = function() return target end }
          end
          local home = adapter.flight.destbase or adapter.flight.homebase
          local postTimes = home and Profiles.RouteTimes(profile, postAarUnits, home, ao, false)
          local postSafe = postTimes ~= nil
          for id, e in pairs(budget.elements) do
            -- Fill internal tanks after spending access fuel; do not assume external-tank refill.
            local internal = adapter.policy.elements[id].internalKg
            local arrivalFuel = math.max(0, e.availableKg - e.tripKg - e.allowanceKg)
            intake = intake + math.max(0, internal - arrivalFuel)
            local postFuel = math.max(internal, arrivalFuel)
            if not postTimes or not postTimes[id]
                or postFuel <= (postTimes[id] + profile.reserveS) * e.rateKgS then
              postSafe = false
            end
          end
          local predictedDonorBurn = donorInternal * donorReservePct[area] / 100 / (45 * 60) * accessAndService
          local excess = donorFuel - donorInternal * threshold / 100 - predictedDonorBurn - intake
          if postSafe and remainingWindow > accessAndService and excess > 0 then
            local candidate = { area = area, coordinate = target, runtime = r, marginKg = budget.marginKg,
              donorExcessKg = excess, accessS = budget.maxTimeS }
            if not choice or candidate.accessS < choice.accessS then choice = candidate end
          end
        end
      end
    end
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
