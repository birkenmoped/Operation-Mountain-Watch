-- Operation Mountain Watch - Gate 4 Stage-3 regression preflight.
-- Pure contract check executed before the unchanged historical Stage-3 runtime fixture.

local TAG = "[OMW][GATE4-STAGE3-REGRESSION]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function expect(value, expected, label)
  if value ~= expected then
    fail(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(value)))
  end
end

local base = OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_BASE.New({
  siteRegistry = OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_SITES,
  supportProfiles = OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_PROFILES,
  idContract = OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_IDS,
  lifecycleAdapter = OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_LIFECYCLE.New(),
  adapters = {},
})

local incident, created, reason = base:OpenIncident({
  siteId = "COP_HONAKER",
  incidentKey = "GATE4-PREFLIGHT",
})
if created ~= true or not incident then
  fail("Honaker incident preflight failed: " .. tostring(reason))
end
expect(#incident.demandIds, 0, "OpenIncident automatic demand count")

local qrf, qrfCreated = base:RequestSupport(incident.incidentId, "QRF", {})
expect(qrfCreated, true, "QRF request created")
expect(qrf.status, "NO_ADAPTER", "QRF preflight status")

local cas, casCreated = base:RequestSupport(incident.incidentId, "CAS", {})
expect(casCreated, true, "CAS request created")
expect(cas.status, "NO_ADAPTER", "CAS preflight status")

local arty, artyCreated = base:RequestSupport(incident.incidentId, "ARTY", {})
expect(artyCreated, true, "ARTY request created")
expect(arty.status, "NO_ADAPTER", "ARTY preflight status")

local resupply, resupplyCreated = base:RequestSupport(incident.incidentId, "AIR_RESUPPLY", {
  resourceId = OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_PROFILES.ResourceId.AMMO,
  quantity = 15,
})
expect(resupplyCreated, true, "Air AMMO request created")
expect(resupply.resourceId, "GROUND_AMMO_PACKAGE", "Air AMMO resource ID")

local followOn, followOnCreated = base:RequestSupport(incident.incidentId, "ARTY", {
  requestKey = "FOLLOWON-1",
})
expect(followOnCreated, true, "follow-on ARTY request created")
expect(followOn.demandId, OMW_GATE4_FIRE_SUP_STRAT_RESUPPLY_IDS.Demand(incident.incidentId, "ARTY", "FOLLOWON-1"), "follow-on ARTY demand ID")

if env and type(env.info) == "function" then
  env.info(TAG .. " PREFLIGHT_PASS incidentId=" .. tostring(incident.incidentId) .. " explicitDemands=" .. tostring(#incident.demandIds), false)
end
