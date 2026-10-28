-- Run from repository root with Lua 5.1. No DCS flight behaviour is simulated.
local Fuel = dofile("scripts/air-operations/OMW_FixedWingCasFuelPolicy.lua")
local Recovery = dofile("scripts/air-operations/OMW_FixedWingCasRecovery.lua")
local Profiles = dofile("scripts/air-operations/OMW_FixedWingCasProfiles.lua")
local n = 0
local function test(name, fn)
  fn(); n = n + 1; print("PASS " .. name)
end
local function near(a, b) assert(math.abs(a - b) < 0.00001, tostring(a) .. " != " .. tostring(b)) end

test("worst element, not lead, controls the recovery margin", function()
  local t = Fuel.New({ referenceFractionPerS = 0.0001, reserveS = 2700 })
  t:Observe("lead", 0, 6000, 10000, true, true)
  t:Observe("wing", 0, 3000, 10000, true, true)
  local r = t:Assess({ lead = 1000, wing = 1000 })
  assert(r.valid and not r.safe); near(r.marginKg, -700)
end)

test("longer route and reserve each increase required fuel", function()
  local t = Fuel.New({ referenceFractionPerS = 0.0001, reserveS = 2700 })
  t:Observe("wing", 0, 5000, 10000, true, true)
  local a, b = t:Assess({ wing = 100 }), t:Assess({ wing = 1500 })
  assert(a.safe and b.safe); near(a.marginKg - b.marginKg, 1400)
end)

test("fuel above internal capacity is preserved", function()
  local t = Fuel.New({ referenceFractionPerS = 0.0001, reserveS = 2700 })
  t:Observe("wing", 0, 16910, 10000, true, true)
  near(t:Assess({ wing = 100 }).elements.wing.availableKg, 16910)
end)

test("burn observations survive duplicate sampling and refuel cannot become negative burn", function()
  local t = Fuel.New({ referenceFractionPerS = 0.0001, reserveS = 2700 })
  t:Observe("wing", 0, 5000, 10000, true, true)
  t:Observe("wing", 0, 5000, 10000, true, true)
  t:Observe("wing", 60, 4880, 10000, true, true)
  near(t:Assess({ wing = 100 }).elements.wing.rateKgS, 2)
  t:Observe("wing", 75, 10000, 10000, true, true)
  near(t:Assess({ wing = 100 }).elements.wing.rateKgS, 1)
end)

test("invalid, absent and landed element data never produce a safe budget", function()
  local t = Fuel.New({ referenceFractionPerS = 0.0001, reserveS = 2700 })
  assert(not t:Assess({}).valid)
  t:Observe("wing", 0, 5000, 10000, false, false)
  assert(not t:Assess({ wing = 100 }).safe)
  t:Observe("wing", 1, 0/0, 10000, true, true)
  assert(not t:Assess({ wing = 100 }).valid)
end)

test("A5-4 A10 return request fails a 45-minute fuel allowance before fuel low", function()
  local p = Profiles.Get("CAS_A10")
  local t = Fuel.New(p)
  t:Observe("lead", 75952, 0.39193770289421 * 10000, 10000, true, false)
  t:Observe("wing", 75952, 0.42208990454674 * 10000, 10000, true, false)
  -- Native test estimate was 7344 s including 2700 s arrival allowance.
  local r = t:Assess({ lead = 7344.3065970811 - 2700, wing = 7344.3065970811 - 2700 })
  assert(r.valid and not r.safe and r.elements.lead.marginKg < 0)
end)

-- Minimal API doubles exercise command ordering/guards, not MOOSE or DCS physics.
AUFTRAG = { Type = { CAS = "CAS", CASENHANCED = "CASENHANCED" } }
local function fixture()
  local x = { time = 0, events = {}, calls = {}, fuel = { lead = 7000, wing = 7000 },
    airborne = { lead = true, wing = true }, homeTime = 1000 }
  local base = { GetName = function() return "HOME" end }
  local units = {}
  for _, id in ipairs({ "lead", "wing" }) do
    local key = id
    units[#units + 1] = { GetName = function() return key end, IsAlive = function() return true end,
      InAir = function() return x.airborne[key] end, GetFuelMassMax = function() return 10000, 10000 end,
      GetCurrentFuelKgs = function() return x.fuel[key] end }
  end
  local group = { GetUnits = function() return units end,
    IsAirborne = function() return x.airborne.lead and x.airborne.wing end }
  local mission = { over = false, IsOver = function(self) return self.over end }
  local wing = {}
  local f = { state = "Cruising", homebase = base }
  function f:GetGroup() return group end
  function f:GetAirwing() return wing end
  function f:IsLanded() return not x.airborne.lead and not x.airborne.wing end
  function f:IsGoing4Fuel() return self.state == "Going4Fuel" end
  function f:SetReturnToLegion() end
  function f:SetAllowAfterburner() x.flightAbReleased = true end
  function mission:SetAllowAfterburner() x.missionAbReleased = true end
  function f:SetFuelLowRTB() end
  function f:SetFuelLowRefuel() end
  function f:SetFuelLowThreshold() end
  function f:MissionCancel(m)
    x.calls[#x.calls + 1] = "CANCEL"; m.over = true
  end
  function f:RTB(destination)
    if self.OnBeforeRTB(self, self.state, "RTB", "Inbound", destination) == false then return end
    -- Matches the pinned native same-current-base rejection.
    if self.currbase == destination then x.rejected = true; return end
    x.calls[#x.calls + 1] = "RTB"; self.currbase = destination; self.state = "Inbound"
    self.OnAfterRTB(self, "Cruising", "RTB", "Inbound", destination)
  end
  function f:Refuel(target)
    x.calls[#x.calls + 1] = "REFUEL"; self.state = "Going4Fuel"
    self.OnAfterRefuel(self, "Cruising", "Refuel", "Going4Fuel", target)
  end
  local spec = { flight = f, mission = mission,
    policy = Fuel.New({ referenceFractionPerS = 0.0001, reserveS = 2700 }),
    now = function() return x.time end, reserveS = 2700, observerPeriodS = 15,
    sortie = { stationS = 9000, plannedS = 20000, absoluteS = 25000 },
    routes = function(ids)
      local times = {}; for id in pairs(ids) do times[id] = x.homeTime end; return times
    end,
    tankers = function() return x.candidate end,
    log = function(event, values) x.events[#x.events + 1] = { event = event, values = values } end }
  x.adapter = Recovery.Bind(spec)
  x.flight, x.mission, x.base, x.wing, x.spec = f, mission, base, wing, spec
  function x:refueled()
    self.flight.state = "Cruising"
    self.flight.OnAfterRefueled(self.flight, "Going4Fuel", "Refueled", "Cruising")
  end
  return x
end

test("closure precedes RTB and final recovery rejects new CAS", function()
  local x = fixture(); x.adapter:Tick(true, true)
  x.adapter:CloseCas("LIMIT"); x.adapter:RequestRtb()
  assert(x.calls[1] == "CANCEL" and x.calls[2] == "RTB")
  assert(x.flight:OnBeforeMissionStart("Cruising", "MissionStart", "Cruising", {type="CAS"}) == false)
end)

test("final intent never blocks emergency AAR after RTB; home route can be reissued", function()
  local x = fixture()
  x.flight:OnAfterElementTakeoff("Parking", "ElementTakeoff", "Airborne", {name="lead"})
  x.adapter:Tick(true, true)
  x.adapter:CloseCas("LIMIT"); x.adapter:RequestRtb()
  x.time = 10
  x.candidate = { area = "KRUSTY", coordinate = {}, marginKg = 500, donorExcessKg = 1000 }
  assert(x.adapter:RequestAar("SAFETY", true))
  local before = #x.calls
  x.flight:RTB(x.base) -- pending native retry must be vetoed during AAR.
  assert(#x.calls == before)
  x.time = 20; x.fuel.lead, x.fuel.wing = 10000, 10000
  x:refueled()
  assert(x.calls[#x.calls] == "RTB" and not x.rejected)
  assert(x.adapter.firstTakeoffS == 0 and x.mission.over)
  local reset = 0
  for _, e in ipairs(x.events) do if e.event == "RECOVERY_AAR_CURRBASE_RESET" then reset = reset + 1 end end
  assert(reset == 1)
end)

test("AAR completion does not authorize RTB without reassessing the new fuel", function()
  local x = fixture(); x.adapter:Tick(true, true); x.adapter:CloseCas("LIMIT")
  x.candidate = { area = "PATTY", coordinate = {}, marginKg = 1, donorExcessKg = 1 }
  assert(x.adapter:RequestAar("SAFETY", true))
  x.fuel.wing = 100; x.time = 20; x:refueled()
  assert(x.calls[#x.calls] == "REFUEL")
end)

test("currbase exception cannot run after physical landing evidence", function()
  local x = fixture(); x.adapter:Tick(true, true); x.adapter:CloseCas("LIMIT"); x.adapter:RequestRtb()
  x.candidate = { area = "KRUSTY", coordinate = {} }
  assert(x.adapter:RequestAar("SAFETY", true))
  x.airborne.wing = false
  x.flight:OnAfterElementLanded("Inbound", "ElementLanded", "Landed", {name="wing"}, x.base)
  x.time = 20; x:refueled()
  for _, e in ipairs(x.events) do assert(e.event ~= "RECOVERY_AAR_CURRBASE_RESET") end
  assert(x.flight.currbase == x.base)
end)

test("asset return is exact and requires both individual home landings", function()
  local x = fixture(); x.adapter:Tick(true, true)
  x.wing:OnAfterLegionAssetReturned("Running", "LegionAssetReturned", "Running", {}, { flightgroup = {} })
  assert(not x.adapter.returned)
  for _, id in ipairs({"lead", "wing"}) do
    x.flight:OnAfterElementLanded("Inbound", "ElementLanded", "Landed", {name=id}, x.base)
  end
  x.wing:OnAfterLegionAssetReturned("Running", "LegionAssetReturned", "Running", {}, { flightgroup = x.flight, uid = 17 })
  assert(x.adapter.returned)
  x.adapter:Tick(true, false)
  assert(not x.adapter.failure)
end)

test("missing return evidence cannot become a completed lifecycle", function()
  local x = fixture()
  x.flight:OnAfterElementLanded("Inbound", "ElementLanded", "Landed", {name="lead"}, x.base)
  assert(not x.adapter.returned)
end)

test("45-minute reserve is never mistaken for a new sortie clock", function()
  local x = fixture(); x.time = 100
  x.flight:OnAfterElementTakeoff("Parking", "ElementTakeoff", "Airborne", {name="lead"})
  x.time = 200
  x.flight:OnAfterElementTakeoff("Parking", "ElementTakeoff", "Airborne", {name="wing"})
  assert(x.adapter.firstTakeoffS == 100)
  local starts = 0
  for _, e in ipairs(x.events) do if e.event == "SORTIE_CLOCK_STARTED" then starts = starts + 1 end end
  assert(starts == 1)
end)

test("Joker starts reachable AAR while home still has reserve", function()
  local x = fixture(); x.fuel.wing = 4000
  x.candidate = { area = "KRUSTY", coordinate = {}, accessS = 400, marginKg = 900, donorExcessKg = 1000 }
  x.adapter:Tick(true, true)
  assert(x.adapter:Budget(x.base).safe and x.calls[1] == "REFUEL")
  assert(not x.adapter.finalReason)
end)

test("without reachable AAR the last positive recovery margin closes CAS", function()
  local x = fixture(); x.fuel.wing = 3720
  x.adapter:Tick(true, true)
  assert(x.adapter:Budget(x.base).safe)
  assert(x.calls[1] == "CANCEL" and x.calls[2] == "RTB")
  assert(not x.adapter.failure)
end)

test("afterburner restriction is released once after native departure completion", function()
  local x = fixture(); x.adapter:DepartureComplete(); x.adapter:DepartureComplete()
  assert(x.flightAbReleased and x.missionAbReleased)
  local count=0
  for _,e in ipairs(x.events) do
    if e.event=="DEPARTURE_AFTERBURNER_RESTRICTION_RELEASED" then count=count+1 end
  end
  assert(count==1)
end)

test("post-RTB AAR completion cannot reset currbase before a fuel-supported RTB", function()
  local x = fixture(); x.adapter:Tick(true, true)
  x.adapter:CloseCas("LIMIT"); x.adapter:RequestRtb()
  x.candidate = { area = "KRUSTY", coordinate = {}, accessS = 100, marginKg = 1, donorExcessKg = 1 }
  assert(x.adapter:RequestAar("SAFETY", true))
  x.fuel.wing = 100; x.time = 20; x:refueled()
  assert(x.calls[#x.calls] == "REFUEL" and x.flight.currbase == x.base)
  for _,e in ipairs(x.events) do assert(e.event ~= "RECOVERY_AAR_CURRBASE_RESET") end
end)

test("final recovery can request AAR before the remaining reserve is consumed", function()
  local x = fixture(); x.adapter:Tick(true, true)
  x.adapter:CloseCas("LIMIT"); x.adapter:RequestRtb()
  x.fuel.wing = 3720; x.time = 0
  x.candidate = { area = "KRUSTY", coordinate = {}, accessS = 100, marginKg = 1, donorExcessKg = 1 }
  x.adapter:CheckFuel("MONITOR")
  assert(x.adapter:Budget(x.base).safe and x.calls[#x.calls] == "REFUEL")
end)

test("A5-4 F16 wingman fuel cannot support even the reserve alone at FuelLow", function()
  local p = Profiles.Get("CAS_F16"); local t = Fuel.New(p)
  t:Observe("wing",57906,0.29535192251205*10000,10000,true,false)
  local r=t:Assess({wing=0})
  assert(r.valid and not r.safe)
end)

test("native RTB confirmation is preserved instead of requesting duplicate same-base RTB", function()
  local x = fixture(); x.adapter:Tick(true,true)
  x.time=10; x.flight:RTB(x.base)
  local count=#x.calls
  x.adapter:CheckFuel("FUEL_CRITICAL")
  assert(#x.calls==count and x.adapter.rtbAtS==10 and not x.rejected)
end)

-- MOOSE-style coordinates are read-only test data; no DCS task execution.
UTILS = { FeetToMeters = function(x) return x * 0.3048 end,
  KnotsToMps = function(x) return x * 1852 / 3600 end,
  MetersToFeet = function(x) return x / 0.3048 end }
timer = { getAbsTime = function() return 54000 end }
local function coord(x, z, wind)
  local c = { x = x, z = z, y = 6700 }
  function c:Get2DDistance(other) return math.sqrt((self.x-other.x)^2+(self.z-other.z)^2) end
  function c:GetWindVec3() return { x = wind or 0, z = 0 } end
  function c:GetIntermediateCoordinate(other, f)
    return coord(self.x+(other.x-self.x)*f, self.z+(other.z-self.z)*f, wind)
  end
  function c:Translate(d, angle)
    return coord(self.x+d*math.cos(math.rad(angle)), self.z+d*math.sin(math.rad(angle)), wind)
  end
  function c:HeadingTo() return 45 end
  function c:GetLandHeight() return 1000 end
  return c
end

test("route budget includes native approach geometry and adverse wind", function()
  local p = Profiles.Get("CAS_F16")
  local target = {GetCoordinate=function() return coord(100000,0) end,
    GetZone=function() return {GetRadius=function() return 1000 end} end}
  local calm = Profiles.RouteTimes(p,{wing={GetCoordinate=function() return coord(0,0,0) end}},target)
  local headwind = Profiles.RouteTimes(p,{wing={GetCoordinate=function() return coord(0,0,-50) end}},target)
  assert(calm.wing > 100000/UTILS.KnotsToMps(p.cruiseKtas))
  assert(headwind.wing > calm.wing)
  local tailwind = Profiles.RouteTimes(p,{wing={GetCoordinate=function() return coord(0,0,50) end}},target)
  near(tailwind.wing, calm.wing)
end)

test("A10 candidate includes KRUSTY even when tanker is farther than home", function()
  local p = Profiles.Get("CAS_A10")
  local policy = Fuel.New(p)
  policy:Observe("wing",0,10000,10000,true,true)
  local unit = {GetCoordinate=function() return coord(0,0) end}
  local donor = {IsTanker=function() return true,0 end,
    GetFuelMassMax=function() return 90000,90000 end,GetCurrentFuelKgs=function() return 90000 end}
  local r = {onStationAt=50000,areaSpec={fuelLowPct=36},flightGroup={},
    group={IsAlive=function() return true end,GetUnit=function() return donor end,
      GetCoordinate=function() return coord(15000,0) end}}
  local aar={GetActive=function(area) if area=="KRUSTY" then return r end end,
    GetStation=function() return {nextPlannedHandoverAt=64800} end}
  local home={GetCoordinate=function() return coord(2000,0) end,
    GetZone=function() return {GetRadius=function() return 1000 end} end}
  local a={airborneUnits={wing=unit},policy=policy,flight={refueltype=0,homebase=home}}
  local candidate=Profiles.SelectTanker(p,a,aar,coord(2000,0))
  assert(candidate and candidate.area=="KRUSTY")
  aar.GetStation=function() return {nextPlannedHandoverAt=54100} end
  assert(not Profiles.SelectTanker(p,a,aar,coord(2000,0)))
  aar.GetStation=function() return {nextPlannedHandoverAt=64800} end
  donor.GetCurrentFuelKgs=function() return 32400 end
  assert(not Profiles.SelectTanker(p,a,aar,coord(2000,0)))
  donor.GetCurrentFuelKgs=function() return 90000 end
  home.GetCoordinate=function() return coord(3000000,0) end
  assert(not Profiles.SelectTanker(p,a,aar,coord(2000,0))) -- full internal tanks cannot support return.
end)

test("departure geometry is fixed by base profile instead of lowest terrain heading", function()
  local b=Profiles.Departure(Profiles.Get("CAS_F16"),coord(0,0),coord(50000,50000))
  assert(b.angle==0 and b.startCoord.z<0 and b.endCoord.x>b.startCoord.x)
  local k=Profiles.Departure(Profiles.Get("CAS_A10"),coord(0,0),coord(50000,50000))
  assert(k.angle==45 and k.offsetHeading==315 and k.legNm==3)
end)

print("Fuel/recovery contract tests: " .. n .. " passed; DCS runtime NOT tested")
