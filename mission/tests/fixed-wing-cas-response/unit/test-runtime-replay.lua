-- Policy replay of recorded telemetry, never a simulation of DCS flight physics.
local Fuel = dofile('scripts/air-operations/OMW_FixedWingCasFuelPolicy.lua')
local Profiles = dofile('scripts/air-operations/OMW_FixedWingCasProfiles.lua')
UTILS = { FeetToMeters=function(v) return v*0.3048 end, KnotsToMps=function(v) return v*1852/3600 end }
local records = dofile('mission/tests/fixed-wing-cas-response/unit/runtime-fuel-samples.lua')
local trackers, histories, last = {}, {}, {}
for _, r in ipairs(records) do
  local run, profile, id, timeS, fuel, internal, altFt, tas = unpack(r)
  local key = run .. ':' .. profile
  trackers[key] = trackers[key] or Fuel.New(Profiles.Get(profile))
  histories[key] = histories[key] or {}
  local u = {GetCoordinate=function() return { y=altFt*0.3048 } end,
    GetAirspeedTrue=function() return tas*1852/3600 end}
  local q, sample = Profiles.RecoverySample(Profiles.Get(profile),u,timeS,histories[key][id])
  histories[key][id] = sample
  trackers[key]:Observe(id,timeS,fuel,internal,true,q)
  last[key] = timeS
end
local count = 0
for _, profile in ipairs({'CAS_F16','CAS_A10','CAS_F15E'}) do
  local t = assert(trackers['A5_5:'..profile])
  local routes = {}
  -- Conservative upper bounds of the logged home route at the failed decision:
  -- F16 493 s, A10 518 s, F15E 454 s. No synthetic flight is run.
  local homeS = ({CAS_F16=494,CAS_A10=519,CAS_F15E=455})[profile]
  for id in pairs(t.elements) do routes[id]=homeS end
  local b = t:Assess(routes)
  assert(b.valid and b.safe, profile .. ': departure/climb consumption polluted recovery rate')
  for _, e in pairs(b.elements) do assert(e.rateBasis=='A5_4_RECOVERY_REFERENCE') end
  count=count+1;print('PASS recorded A5-5 '..profile..' retains home reserve at premature-RTB timestamp')
end
local t=assert(trackers['A5_4:CAS_F16'])
local routes={};for id in pairs(t.elements) do routes[id]=0 end
assert(not t:Assess(routes).safe, 'A5-4 FuelLow must not be mistaken for safe recovery')
count=count+1;print('PASS recorded A5-4 F16 FuelLow violates reserve even before return-trip fuel')
-- The recorded join and AO evidence is kept distinct: 42m35s join-to-RTB,
-- 26m05s first-AO-to-RTB, only 45.003 seconds jointly inside the narrow AO circle.
print('Runtime fuel replay: '..count..' passed; DCS runtime NOT tested')
