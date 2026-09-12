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
  if ok then error(label .. " expected error") end
end

local function assertNoOperationalAssetSelection(value, path)
  if type(value) ~= "table" then return end
  local forbidden = {
    aircraftId = true, assetId = true, squadron = true, squadronName = true,
    cohort = true, cohortName = true, battery = true, batteryName = true,
    carrierId = true, airwing = true, airwingName = true,
    brigade = true, brigadeName = true,
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
assertEqual(Sites.GuardTemplateName, "TPL_BLUE_GND_INF_RIFLE_SQUAD_9", "shared Guard physical template")

local expectedSites = {
  JALALABAD_FENTY = {
    "BLUE_GROUND_HUB_JALALABAD_FENTY", "GROUND_NODE_JALALABAD", "OFF_MAP",
    "WH_BLUE_GND_FENTY", "ZON_BLUE_GND_FENTY_ACCESS",
    "OMW_RTE_BLUE_GUARD_FENTY_01", "ZON_BLUE_GND_FENTY_ALARM",
  },
  COP_FORTRESS = {
    "BLUE_GROUND_COP_FORTRESS", "GROUND_NODE_FORTRESS", "GROUND_NODE_JALALABAD",
    "WH_BLUE_GND_FORTRESS", "ZON_BLUE_GND_FORTRESS_ACCESS",
    "OMW_RTE_BLUE_GUARD_FORTRESS_01", "ZON_BLUE_GND_FORTRESS_ALARM",
  },
  FOB_JOYCE = {
    "BLUE_GROUND_FOB_JOYCE", "GROUND_NODE_JOYCE", "GROUND_NODE_JALALABAD",
    "WH_BLUE_GND_JOYCE", "ZON_BLUE_GND_JOYCE_ACCESS",
    "OMW_RTE_BLUE_GUARD_JOYCE_01", "ZON_BLUE_GND_JOYCE_ALARM",
  },
  FOB_WRIGHT = {
    "BLUE_GROUND_FOB_WRIGHT", "GROUND_NODE_WRIGHT", "GROUND_NODE_JALALABAD",
    "WH_BLUE_GND_WRIGHT", "ZON_BLUE_GND_WRIGHT_ACCESS",
    "OMW_RTE_BLUE_GUARD_WRIGHT_01", "ZON_BLUE_GND_WRIGHT_ALARM",
  },
  COP_HONAKER = {
    "BLUE_GROUND_COP_HONAKER_MIRACLE", "GROUND_NODE_HONAKER", "GROUND_NODE_JOYCE",
    "WH_BLUE_GND_HONAKER", "ZON_BLUE_GND_HONAKER_ACCESS",
    "OMW_RTE_BLUE_GUARD_HONAKER_01", "ZON_BLUE_GND_HONAKER_ALARM",
  },
  FOB_BOSTICK = {
    "BLUE_GROUND_FOB_BOSTICK", "GROUND_NODE_BOSTICK", "GROUND_NODE_JALALABAD",
    "WH_BLUE_GND_BOSTICK", "ZON_BLUE_GND_BOSTICK_ACCESS",
    "OMW_RTE_BLUE_GUARD_BOSTICK_01", "ZON_BLUE_GND_BOSTICK_ALARM",
  },
}

local siteCount = 0
for key, expected in pairs(expectedSites) do
  local site = Sites.Sites[key]
  assertTrue(type(site) == "table", key .. " site exists")
  assertEqual(site.installationId, expected[1], key .. " installation ID")
  assertEqual(site.campaignNodeId, expected[2], key .. " campaign node")
  assertEqual(site.supplyParentNodeId, expected[3], key .. " supply parent")
  assertEqual(site.warehouseName, expected[4], key .. " warehouse")
  assertEqual(site.accessZoneName, expected[5], key .. " access zone")
  assertEqual(site.guardRoute.pathlineName, expected[6], key .. " Guard PATHLINE")
  assertEqual(site.alarmZone.zoneName, expected[7], key .. " alarm zone")
  assertEqual(site.guardTemplateName, Sites.GuardTemplateName, key .. " Guard template")
  assertEqual(site.supportProfileId, "GROUND_INSTALLATION_STANDARD", key .. " profile")
  assertEqual(site.guardRoute.status, "OWNER_AUTHORED_ME_ROUTE_REQUIRED_DCS_VALIDATION", key .. " Guard route status")
  assertEqual(site.alarmZone.status, "OWNER_AUTHORED_ME_ZONE_REQUIRED_DCS_VALIDATION", key .. " alarm-zone status")
  siteCount = siteCount + 1
end
assertEqual(siteCount, 6, "Ground Foundation site count")

assertEqual(Sites.Sites.COP_FORTRESS.localSupport.status, "CONFIGURED_IN_GROUND_BASELINE", "Fortress local support")
assertEqual(Sites.Sites.COP_HONAKER.localSupport.status, "CONFIGURED_IN_GROUND_BASELINE", "Honaker local support")
assertEqual(Sites.Sites.FOB_BOSTICK.localSupport.status, "CONFIGURED_IN_GROUND_BASELINE", "Bostick local support")
assertEqual(Sites.Sites.FOB_WRIGHT.localSupport.status, "UNRESOLVED_CURRENT_ASSIGNMENT", "Wright local support boundary")
assertEqual(Sites.Sites.COP_HONAKER.historicalStage3ProviderNodeId, "GROUND_NODE_WRIGHT", "Stage-3 evidence retained")

local standard = Profiles.Profiles.GROUND_INSTALLATION_STANDARD
assertTrue(type(standard) == "table", "standard Ground installation profile resolves")
assertEqual(standard.contractStatus, "GROUND_FOUNDATION_RECONCILED", "standard profile status")
assertEqual(standard.support.guards.activation, Profiles.Activation.SITE_PERSISTENT, "Guard activation")
assertEqual(standard.support.qrf.activation, Profiles.Activation.INCIDENT_LOCAL_DEFENSE, "QRF activation")
assertEqual(standard.support.artillery.activation, Profiles.Activation.C2_ESCALATION_EXTERNAL, "external support activation")
assertEqual(standard.support.cas.activation, Profiles.Activation.C2_ESCALATION_EXTERNAL, "CAS activation")
assertEqual(standard.support.resupply.activation, Profiles.Activation.RESOURCE_THRESHOLD, "Resupply activation")
assertTrue(type(Profiles.Profiles.HONAKER_WRIGHT_STAGE3) == "table", "historical Stage-3 profile retained")
assertTrue(type(Profiles.Profiles.JOYCE_STANDARD) == "table", "historical Joyce planning profile retained")

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
assertEqual(Ids.Settlement(demandId, "DELIVERED", "MOOSE-EVENT-0007"), settlementId, "settlement ID deterministic")

assertError(function() Ids.Site("") end, "empty site ID")
assertError(function() Ids.Incident("FOB_JOYCE", "") end, "empty incident key")
assertError(function() Ids.Demand(incidentId, "") end, "empty support type")
assertError(function() Ids.SiteDemand("FOB_JOYCE", "", "X") end, "empty site support type")
assertError(function() Ids.Settlement(demandId, "DELIVERED", "") end, "empty source event ID")

print("PASS test_fire_support_strategic_resupply_gate2")
