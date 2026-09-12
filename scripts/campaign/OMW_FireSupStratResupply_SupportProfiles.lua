-- Operation Mountain Watch - Fire Support / Strategic Resupply support profiles.
-- Gate 2: pure campaign-domain data. No MOOSE/DCS calls and no asset selection.

local SupportProfiles = {}

SupportProfiles.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SUPPORT-PROFILES-1"

SupportProfiles.SupportType = {
  GUARD = "GUARD",
  QRF = "QRF",
  ARTY = "ARTY",
  CAS = "CAS",
  GROUND_RESUPPLY = "GROUND_RESUPPLY",
  AIR_RESUPPLY = "AIR_RESUPPLY",
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
      guards = { enabled = true },
      qrf = { enabled = true },
      artillery = { enabled = true },
      cas = { enabled = true, corridorProfile = "HONAKER_ROTARY_STAGE3" },
      resupply = {
        enabled = true,
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
      guards = { enabled = true },
      qrf = { enabled = true },
      artillery = { enabled = true },
      cas = { enabled = true, corridorProfile = "JOYCE_HELICOPTER" },
      resupply = {
        enabled = true,
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
