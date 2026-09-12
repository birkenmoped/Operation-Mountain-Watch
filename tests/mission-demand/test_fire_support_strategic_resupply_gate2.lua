local Profiles = dofile("scripts/campaign/OMW_FireSupStratResupply_SupportProfiles.lua")
local Sites = dofile("scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua")
local Ids = dofile("scripts/campaign/OMW_FireSupStratResupply_IdContract.lua")
local InitialStock = dofile("scripts/logistics/OMW_GroundInitialStock.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function assertTrue(value, label)
  if value ~= true then
    error(label .. " expected=true actual=" .. tostring(value))
  end
end

local function assertError(fn, label)
  local ok = pcall(fn)
  if ok then
    error(label .. " expected error")
  end
end

local function assertNoOperationalAssetSelection(value, path)
  if type(value) ~= "table" then return end
  local forbidden = {
    aircraftId = true,
    assetId = true,
    squadron = true,
    squadronName = true,
    cohort = true,
    cohortName = true,
    battery = true,
    batteryName = true,
    carrierId = true,
    airwing = true,
    airwingName = true,
    brigade = true,
    brigadeName = true,
  }
  for key, item in pairs(value) do
    if forbidden[key] then
      error(string.format("operational asset preselection forbidden path=%s.%s", path, tostring(key)))
    end
    assertNoOperationalAssetSelection(item, path .. "." .. tostring(key))
  end
end

assertEqual(Profiles.ResourceId.PERSONNEL, InitialStock.ResourceId.PERSONNEL, "PERSONNEL resource ID")
assertEqual(Profiles.ResourceId.SUPPLY, InitialStock.ResourceId.SUPPLY, "SUPPLY resource ID")
assertEqual(Profiles.ResourceId.AMMO, InitialStock.ResourceId.AMMO, "AMMO resource ID")
assertEqual(Profiles.ResourceId.FUEL, InitialStock.ResourceId.FUEL, "FUEL resource ID")

local honaker = Sites.Sites.COP_HONAKER
local joyce = Sites.Sites.FOB_JOYCE
assertTrue(type(honaker) == "table", "Honaker site exists")
assertTrue(type(joyce) == "table", "Joyce site exists")
assertEqual(honaker.campaignNodeId, "GROUND_NODE_HONAKER", "Honaker campaign node")
assertEqual(honaker.supplyParentNodeId, "GROUND_NODE_JOYCE", "Honaker supply parent")
assertEqual(honaker.fireSupportNodeId, "GROUND_NODE_WRIGHT", "Honaker Stage 3 fire-support node")
assertEqual(honaker.supportProfileId, "HONAKER_WRIGHT_STAGE3", "Honaker profile")
assertEqual(joyce.campaignNodeId, "GROUND_NODE_JOYCE", "Joyce campaign node")
assertEqual(joyce.supplyParentNodeId, "GROUND_NODE_JALALABAD", "Joyce supply parent")
assertEqual(joyce.supportProfileId, "JOYCE_STANDARD", "Joyce profile")

local honakerProfile = Profiles.Profiles[honaker.supportProfileId]
local joyceProfile = Profiles.Profiles[joyce.supportProfileId]
assertTrue(type(honakerProfile) == "table", "Honaker profile resolves")
assertTrue(type(joyceProfile) == "table", "Joyce profile resolves")
assertEqual(honakerProfile.contractStatus, "HISTORICAL_STAGE3_FIXTURE", "Honaker fixture status")
assertEqual(joyceProfile.contractStatus, "PLANNED_SECOND_SITE", "Joyce second-site status")
assertTrue(joyceProfile.support.guards.enabled, "Joyce Guard enabled")
assertTrue(joyceProfile.support.qrf.enabled, "Joyce QRF enabled")
assertTrue(joyceProfile.support.artillery.enabled, "Joyce ARTY enabled")
assertTrue(joyceProfile.support.cas.enabled, "Joyce CAS enabled")
assertTrue(joyceProfile.support.resupply.ground, "Joyce Ground Resupply enabled")
assertTrue(joyceProfile.support.resupply.air, "Joyce Air Resupply enabled")
assertEqual(joyceProfile.support.guards.activation, Profiles.Activation.SITE_PERSISTENT, "Guard activation")
assertEqual(joyceProfile.support.qrf.activation, Profiles.Activation.INCIDENT_LOCAL_DEFENSE, "QRF activation")
assertEqual(joyceProfile.support.artillery.activation, Profiles.Activation.C2_ESCALATION_EXTERNAL, "ARTY activation")
assertEqual(joyceProfile.support.cas.activation, Profiles.Activation.C2_ESCALATION_EXTERNAL, "CAS activation")
assertEqual(joyceProfile.support.resupply.activation, Profiles.Activation.RESOURCE_THRESHOLD, "Resupply activation")

assertNoOperationalAssetSelection(Profiles, "Profiles")
assertNoOperationalAssetSelection(Sites, "Sites")

local siteId = Ids.Site("FOB_JOYCE")
local incidentId = Ids.Incident("FOB_JOYCE", "000123")
local demandId = Ids.Demand(incidentId, Profiles.SupportType.CAS)
local guardDemandId = Ids.SiteDemand("FOB_JOYCE", Profiles.SupportType.GUARD, "PERSISTENT")
local resupplyDemandId = Ids.SiteDemand("FOB_JOYCE", Profiles.SupportType.AIR_RESUPPLY, "AMMO-REORDER-0001")
local settlementId = Ids.Settlement(demandId, "DELIVERED", "MOOSE-EVENT-0007")
assertEqual(siteId, "SITE:FOB_JOYCE", "site ID")
assertEqual(incidentId, "INCIDENT:FOB_JOYCE:000123", "incident ID")
assertEqual(demandId, "DEMAND:INCIDENT:FOB_JOYCE:000123:CAS", "incident demand ID")
assertEqual(guardDemandId, "DEMAND:SITE:FOB_JOYCE:GUARD:PERSISTENT", "persistent Guard demand ID")
assertEqual(resupplyDemandId, "DEMAND:SITE:FOB_JOYCE:AIR_RESUPPLY:AMMO-REORDER-0001", "site resupply demand ID")
assertEqual(settlementId, "SETTLEMENT:DEMAND:INCIDENT:FOB_JOYCE:000123:CAS:DELIVERED:MOOSE-EVENT-0007", "settlement ID")
assertEqual(Ids.Settlement(demandId, "DELIVERED", "MOOSE-EVENT-0007"), settlementId, "settlement ID deterministic")

assertError(function() Ids.Site("") end, "empty site ID")
assertError(function() Ids.Incident("FOB_JOYCE", "") end, "empty incident key")
assertError(function() Ids.Demand(incidentId, "") end, "empty support type")
assertError(function() Ids.SiteDemand("FOB_JOYCE", "", "X") end, "empty site support type")
assertError(function() Ids.Settlement(demandId, "DELIVERED", "") end, "empty source event ID")

assertTrue(string.find(joyceProfile.routes.groundProfile, "HONAKER", 1, true) == nil, "Joyce ground route independent of Honaker")
assertTrue(string.find(joyceProfile.routes.helicopterProfile, "HONAKER", 1, true) == nil, "Joyce helicopter route independent of Honaker")
assertTrue(string.find(joyceProfile.routes.groundProfile, "WRIGHT", 1, true) == nil, "Joyce ground route independent of Wright")
assertTrue(string.find(joyceProfile.routes.helicopterProfile, "WRIGHT", 1, true) == nil, "Joyce helicopter route independent of Wright")

print("PASS test_fire_support_strategic_resupply_gate2")
