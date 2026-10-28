-- Pure receiver fuel accounting. MOOSE retains every physical flight operation.
-- Owner-approved A5 correction; observed burn floors are test calibration, not POH data.
local Policy = { SchemaVersion = "OMW-FIXED-WING-CAS-FUEL-1" }
local Tracker = {}
Tracker.__index = Tracker

local function finite(x)
  return type(x) == "number" and x == x and x > -math.huge and x < math.huge
end
Policy.IsFinite = finite

function Policy.New(spec)
  assert(spec and finite(spec.referenceFractionPerS) and spec.referenceFractionPerS > 0,
    "positive, evidence-bound receiver burn floor required")
  assert(finite(spec.reserveS) and spec.reserveS >= 0, "explicit reserveS required")
  return setmetatable({ spec = spec, elements = {} }, Tracker)
end

function Tracker:Observe(id, timeS, fuelKg, internalKg, airborne, qualifying)
  if not id or not finite(timeS) or not finite(fuelKg) or fuelKg < 0
      or not finite(internalKg) or internalKg <= 0 then
    if id then self.elements[id] = nil end
    return false
  end
  local e = self.elements[id] or { points = {} }
  self.elements[id] = e
  e.fuelKg, e.internalKg, e.airborne = fuelKg, internalKg, airborne == true
  local last = e.points[#e.points]
  if last and timeS == last.t and fuelKg == last.f then return true end
  -- Refuelling, shutdown, non-monotonic time and invalid phases are not low burn.
  if not airborne or not qualifying or (last and (timeS <= last.t or fuelKg > last.f)) then
    e.points = {}
    e.rateKgS = internalKg * self.spec.referenceFractionPerS
    return true
  end
  e.points[#e.points + 1] = { t = timeS, f = fuelKg }
  while #e.points > 2 and e.points[2].t <= timeS - 300 do table.remove(e.points, 1) end
  e.rateKgS = internalKg * self.spec.referenceFractionPerS
  local first = e.points[1]
  if first and timeS - first.t >= 60 then
    e.rateKgS = math.max(e.rateKgS, (first.f - fuelKg) / (timeS - first.t))
  end
  return true
end

-- routeTimes maps exact element IDs to predicted flight seconds. Reserve includes
-- approach/holding/landing allowance once, not another hidden fixed fuel threshold.
function Tracker:Assess(routeTimes, extraS)
  local result = { valid = true, safe = true, marginKg = math.huge, elements = {}, maxTimeS = 0 }
  if not finite(extraS or 0) or (extraS or 0) < 0 then
    return { valid = false, safe = false, reason = "INVALID_EXTRA_TIME" }
  end
  local n = 0
  for id, travelS in pairs(routeTimes or {}) do
    n = n + 1
    local e = self.elements[id]
    if not e or not e.airborne or not finite(travelS) or travelS < 0
        or not finite(e.rateKgS) or e.rateKgS <= 0 then
      return { valid = false, safe = false, reason = "INVALID_ELEMENT_OR_ROUTE", element = id }
    end
    local trip = travelS * e.rateKgS
    local allowance = (self.spec.reserveS + (extraS or 0)) * e.rateKgS
    local margin = e.fuelKg - trip - allowance
    result.elements[id] = { availableKg = e.fuelKg, tripKg = trip,
      allowanceKg = allowance, rateKgS = e.rateKgS, marginKg = margin }
    result.marginKg = math.min(result.marginKg, margin)
    result.maxTimeS = math.max(result.maxTimeS, travelS)
    if margin <= 0 then result.safe = false end
  end
  if n == 0 then return { valid = false, safe = false, reason = "NO_AIRBORNE_ELEMENTS" } end
  return result
end

return Policy
