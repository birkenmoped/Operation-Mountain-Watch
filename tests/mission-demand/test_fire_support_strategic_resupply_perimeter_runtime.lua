local SiteRegistry = dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local Runtime = dofile("scripts/campaign/OMW_FireSupStratResupply_PerimeterRuntime.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end
local function assertNil(value, label) if value ~= nil then error(label .. " expected=nil actual=" .. tostring(value)) end end

local bridgeThreatCalls, bridgeClearCalls = 0, 0
local bridge = {}
function bridge:HandleThreat(_, _, incident)
  bridgeThreatCalls = bridgeThreatCalls + 1
  return { incidentId = "BASE|" .. incident.incidentId }, true, nil
end
function bridge:HandleClear(_, _, defeatedCoalition, incident)
  bridgeClearCalls = bridgeClearCalls + 1
  assertEqual(defeatedCoalition, 1, "clear coalition")
  return incident, false, "PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT"
end

local adapterSpecs, adapterInstances = {}, {}
local ThreatAdapter = {}
function ThreatAdapter.New(spec)
  local siteId = nil
  for key, site in pairs(SiteRegistry.Sites) do
    if site.installationId == spec.installationId then siteId = key break end
  end
  if not siteId then error("unexpected installationId " .. tostring(spec.installationId)) end
  adapterSpecs[siteId] = spec
  local instance = { started=false, stopped=false }
  function instance:Start() self.started=true return self, true end
  function instance:Stop() self.stopped=true return self, true end
  adapterInstances[siteId] = instance
  return instance
end

local perimeters = {}
local expectedCount = 0
for siteId, site in pairs(SiteRegistry.Sites) do
  expectedCount = expectedCount + 1
  local anchor = {}
  function anchor:GetVec2() return { x = expectedCount * 100, y = expectedCount * 200 } end
  perimeters[siteId] = {
    anchorCoordinate = anchor,
    radiusM = 900 + expectedCount,
    priority = 80 + expectedCount,
    updateSeconds = 10,
    captureThreatlevel = 0,
    captureNunits = 1,
  }
end
assertEqual(expectedCount, 6, "registry site count")

local runtime = Runtime.New({
  siteRegistry = SiteRegistry,
  perimeterBridge = bridge,
  threatAdapter = ThreatAdapter,
  perimeters = perimeters,
  blueCoalition = 2,
  redCoalition = 1,
})

local states, started, reason = runtime:StartAll()
assertTrue(started, "start all")
assertNil(reason, "start all reason")

local startedCount = 0
for siteId, site in pairs(SiteRegistry.Sites) do
  startedCount = startedCount + 1
  local state = states[siteId]
  local spec = adapterSpecs[siteId]
  assertTrue(state ~= nil, siteId .. " state")
  assertTrue(adapterInstances[siteId].started, siteId .. " adapter started")
  assertEqual(spec.installationId, site.installationId, siteId .. " installation id")
  assertEqual(spec.zoneName, "OMW_SECURITY_" .. site.installationId, siteId .. " generated zone name")
  assertEqual(spec.radiusM, perimeters[siteId].radiusM, siteId .. " radius")
  assertEqual(spec.priority, perimeters[siteId].priority, siteId .. " priority")
  assertEqual(spec.blueCoalition, 2, siteId .. " blue coalition")
  assertEqual(spec.redCoalition, 1, siteId .. " red coalition")
  assertNil(spec.accessZoneName, siteId .. " no convoy access dependency")

  local handled, created = spec.threatHandler(nil, nil, {
    incidentId = "THREAT|" .. siteId,
    installationId = site.installationId,
  })
  assertTrue(created, siteId .. " bridge threat created")
  assertEqual(handled.incidentId, "BASE|THREAT|" .. siteId, siteId .. " bridge threat result")

  local _, clearCreated, clearReason = spec.onThreatCleared(nil, nil, 1, {
    incidentId = "THREAT|" .. siteId,
    installationId = site.installationId,
  })
  assertEqual(clearCreated, false, siteId .. " clear does not close")
  assertEqual(clearReason, "PERIMETER_CLEAR_DOES_NOT_CLOSE_INCIDENT", siteId .. " clear reason")
end
assertEqual(startedCount, 6, "started site count")
assertEqual(bridgeThreatCalls, 6, "bridge threat calls")
assertEqual(bridgeClearCalls, 6, "bridge clear calls")

local duplicate, duplicateCreated, duplicateReason = runtime:StartSite("FOB_BOSTICK")
assertTrue(duplicate ~= nil, "duplicate returns state")
assertEqual(duplicateCreated, false, "duplicate not created")
assertEqual(duplicateReason, "ALREADY_STARTED", "duplicate reason")

local _, stopped = runtime:StopAll()
assertTrue(stopped, "stop all")
for siteId in pairs(SiteRegistry.Sites) do
  assertTrue(adapterInstances[siteId].stopped, siteId .. " adapter stopped")
  assertNil(runtime:GetSiteRuntime(siteId), siteId .. " runtime cleared")
end

print("PASS test_fire_support_strategic_resupply_perimeter_runtime")
