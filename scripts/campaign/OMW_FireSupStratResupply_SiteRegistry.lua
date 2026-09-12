-- Operation Mountain Watch - Fire Support / Strategic Resupply site registry.
-- Pure campaign-domain data. No MOOSE/DCS calls and no asset selection.

local SiteRegistry = {}

SiteRegistry.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-4"
SiteRegistry.GuardTemplateName = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"

local function guardRouteContract(pathlineName)
  return {
    pathlineName = pathlineName,
    status = "PRESENT_IN_V23_MIZ_REQUIRES_SITE_RUNTIME_VALIDATION",
  }
end

local function localSupport(status)
  return { status = status }
end

SiteRegistry.Sites = {
  JALALABAD_FENTY = {
    siteId = "JALALABAD_FENTY",
    installationId = "BLUE_GROUND_HUB_JALALABAD_FENTY",
    campaignNodeId = "GROUND_NODE_JALALABAD",
    supplyParentNodeId = "OFF_MAP",
    supportProfileId = "GROUND_INSTALLATION_STANDARD",
    warehouseName = "WH_BLUE_GND_FENTY",
    accessZoneName = "ZON_BLUE_GND_FENTY_ACCESS",
    guardTemplateName = SiteRegistry.GuardTemplateName,
    guardRoute = guardRouteContract("OMW_RTE_BLUE_GUARD_FENTY_01"),
    localSupport = localSupport("NOT_ESTABLISHED_BY_CURRENT_BASELINE"),
  },
  COP_FORTRESS = {
    siteId = "COP_FORTRESS",
    installationId = "BLUE_GROUND_COP_FORTRESS",
    campaignNodeId = "GROUND_NODE_FORTRESS",
    supplyParentNodeId = "GROUND_NODE_JALALABAD",
    supportProfileId = "GROUND_INSTALLATION_STANDARD",
    warehouseName = "WH_BLUE_GND_FORTRESS",
    accessZoneName = "ZON_BLUE_GND_FORTRESS_ACCESS",
    guardTemplateName = SiteRegistry.GuardTemplateName,
    guardRoute = guardRouteContract("OMW_RTE_BLUE_GUARD_FORTRESS_01"),
    localSupport = localSupport("CONFIGURED_IN_GROUND_BASELINE"),
  },
  FOB_JOYCE = {
    siteId = "FOB_JOYCE",
    installationId = "BLUE_GROUND_FOB_JOYCE",
    campaignNodeId = "GROUND_NODE_JOYCE",
    supplyParentNodeId = "GROUND_NODE_JALALABAD",
    supportProfileId = "GROUND_INSTALLATION_STANDARD",
    warehouseName = "WH_BLUE_GND_JOYCE",
    accessZoneName = "ZON_BLUE_GND_JOYCE_ACCESS",
    guardTemplateName = SiteRegistry.GuardTemplateName,
    guardRoute = guardRouteContract("OMW_RTE_BLUE_GUARD_JOYCE_01"),
    localSupport = localSupport("NOT_ESTABLISHED_BY_CURRENT_BASELINE"),
  },
  FOB_WRIGHT = {
    siteId = "FOB_WRIGHT",
    installationId = "BLUE_GROUND_FOB_WRIGHT",
    campaignNodeId = "GROUND_NODE_WRIGHT",
    supplyParentNodeId = "GROUND_NODE_JALALABAD",
    supportProfileId = "GROUND_INSTALLATION_STANDARD",
    warehouseName = "WH_BLUE_GND_WRIGHT",
    accessZoneName = "ZON_BLUE_GND_WRIGHT_ACCESS",
    guardTemplateName = SiteRegistry.GuardTemplateName,
    guardRoute = guardRouteContract("OMW_RTE_BLUE_GUARD_WRIGHT_01"),
    localSupport = localSupport("UNRESOLVED_CURRENT_ASSIGNMENT"),
  },
  COP_HONAKER = {
    siteId = "COP_HONAKER",
    installationId = "BLUE_GROUND_COP_HONAKER_MIRACLE",
    campaignNodeId = "GROUND_NODE_HONAKER",
    supplyParentNodeId = "GROUND_NODE_JOYCE",
    supportProfileId = "GROUND_INSTALLATION_STANDARD",
    warehouseName = "WH_BLUE_GND_HONAKER",
    accessZoneName = "ZON_BLUE_GND_HONAKER_ACCESS",
    guardTemplateName = SiteRegistry.GuardTemplateName,
    guardRoute = guardRouteContract("OMW_RTE_BLUE_GUARD_HONAKER_01"),
    localSupport = localSupport("CONFIGURED_IN_GROUND_BASELINE"),
    historicalStage3ProviderNodeId = "GROUND_NODE_WRIGHT",
  },
  FOB_BOSTICK = {
    siteId = "FOB_BOSTICK",
    installationId = "BLUE_GROUND_FOB_BOSTICK",
    campaignNodeId = "GROUND_NODE_BOSTICK",
    supplyParentNodeId = "GROUND_NODE_JALALABAD",
    supportProfileId = "GROUND_INSTALLATION_STANDARD",
    warehouseName = "WH_BLUE_GND_BOSTICK",
    accessZoneName = "ZON_BLUE_GND_BOSTICK_ACCESS",
    guardTemplateName = SiteRegistry.GuardTemplateName,
    guardRoute = guardRouteContract("OMW_RTE_BLUE_GUARD_BOSTICK_01"),
    localSupport = localSupport("CONFIGURED_IN_GROUND_BASELINE"),
  },
}

return SiteRegistry
