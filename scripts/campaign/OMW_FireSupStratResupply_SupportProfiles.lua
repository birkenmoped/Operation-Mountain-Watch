-- Operation Mountain Watch - Fire Support / Strategic Resupply support profiles.
-- Pure campaign-domain data. No MOOSE/DCS calls and no asset selection.

local SupportProfiles = {}

SupportProfiles.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SUPPORT-PROFILES-2"

SupportProfiles.SupportType = {
  GUARD = "GUARD",
  QRF = "QRF",
  ARTY = "ARTY",
  CAS = "CAS",
  GROUND_RESUPPLY = "GROUND_RESUPPLY",
  AIR_RESUPPLY = "AIR_RESUPPLY",
}

SupportProfiles.Activation = {
  SITE_PERSISTENT = "SITE_PERSISTENT",
  INCIDENT_LOCAL_DEFENSE = "INCIDENT_LOCAL_DEFENSE",
  C2_ESCALATION_EXTERNAL = "C2_ESCALATION_EXTERNAL",
  RESOURCE_THRESHOLD = "RESOURCE_THRESHOLD",
}

SupportProfiles.ResourceId = {
  PERSONNEL = "GROUND_PERSONNEL",
  SUPPLY = "GROUND_SUPPLY_PACKAGE",
  AMMO = "GROUND_AMMO_PACKAGE",
  FUEL = "GROUND_FUEL_PACKAGE",
}

SupportProfiles.Profiles = {
  HONAKER_WRIGHT_STAGE3 = {
    profileId = "HONAKER_WRIGHT_STAGE3",
    contractStatus = "HISTORICAL_STAGE3_FIXTURE",
    support = {
      guards = { enabled = true, activation = "SITE_PERSISTENT" },
      qrf = { enabled = true, activation = "INCIDENT_LOCAL_DEFENSE" },
      artillery = { enabled = true, activation = "C2_ESCALATION_EXTERNAL" },
      cas = { enabled = true, activation = "C2_ESCALATION_EXTERNAL", corridorProfile = "HONAKER_ROTARY_STAGE3" },
      resupply = {
        enabled = true,
        activation = "RESOURCE_THRESHOLD",
        ground = true,
        air = true,
        resourceIds = {
          "GROUND_PERSONNEL",
          "GROUND_SUPPLY_PACKAGE",
          "GROUND_AMMO_PACKAGE",
          "GROUND_FUEL_PACKAGE",
        },
      },
    },
    routes = {
      groundProfile = "HONAKER_GROUND_STAGE3",
      helicopterProfile = "HONAKER_ROTARY_STAGE3",
      fixedWingProfile = nil,
    },
  },

  JOYCE_STANDARD = {
    profileId = "JOYCE_STANDARD",
    contractStatus = "PLANNED_SECOND_SITE",
    support = {
      guards = { enabled = true, activation = "SITE_PERSISTENT" },
      qrf = { enabled = true, activation = "INCIDENT_LOCAL_DEFENSE" },
      artillery = { enabled = true, activation = "C2_ESCALATION_EXTERNAL" },
      cas = { enabled = true, activation = "C2_ESCALATION_EXTERNAL", corridorProfile = "JOYCE_HELICOPTER" },
      resupply = {
        enabled = true,
        activation = "RESOURCE_THRESHOLD",
        ground = true,
        air = true,
        resourceIds = {
          "GROUND_PERSONNEL",
          "GROUND_SUPPLY_PACKAGE",
          "GROUND_AMMO_PACKAGE",
          "GROUND_FUEL_PACKAGE",
        },
      },
    },
    routes = {
      groundProfile = "JOYCE_GROUND",
      helicopterProfile = "JOYCE_HELICOPTER",
      fixedWingProfile = nil,
    },
  },
}

return SupportProfiles
