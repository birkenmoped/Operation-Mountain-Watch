-- Operation Mountain Watch - Fire Support / Strategic Resupply site registry.
-- Gate 2: pure campaign-domain data. No MOOSE/DCS calls and no asset selection.

local SiteRegistry = {}

SiteRegistry.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-1"

SiteRegistry.Sites = {
  COP_HONAKER = {
    siteId = "COP_HONAKER",
    installationId = "BLUE_GROUND_COP_HONAKER_MIRACLE",
    campaignNodeId = "GROUND_NODE_HONAKER",
    supplyParentNodeId = "GROUND_NODE_JOYCE",
    supportProfileId = "HONAKER_WRIGHT_STAGE3",
    missionObjectContractStatus = "STAGE3_FIXTURE",
    alarmZoneName = "BLUE_GROUND_COP_HONAKER",
    tacticalZoneName = nil,
    fireSupportNodeId = "GROUND_NODE_WRIGHT",
  },

  FOB_JOYCE = {
    siteId = "FOB_JOYCE",
    installationId = "BLUE_GROUND_FOB_JOYCE",
    campaignNodeId = "GROUND_NODE_JOYCE",
    supplyParentNodeId = "GROUND_NODE_JALALABAD",
    supportProfileId = "JOYCE_STANDARD",
    missionObjectContractStatus = "PLANNED_SECOND_SITE",
    alarmZoneName = "BLUE_GROUND_FOB_JOYCE",
    tacticalZoneName = "OMW_FOB_JOYCE_C2",
    fireSupportNodeId = nil,
  },
}

return SiteRegistry
