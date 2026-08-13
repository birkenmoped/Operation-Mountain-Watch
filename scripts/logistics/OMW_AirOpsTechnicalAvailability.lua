-- Operation Mountain Watch - owner-approved technical non-strategic availability.
--
-- These quantities are operational DCS/MOOSE STORAGE availability only.
-- They are not CampaignState resources, do not participate in strategic
-- consumption/replenishment accounting, and are not automatically replenished
-- by this data module.

local TechnicalAvailability = {}

TechnicalAvailability.SchemaVersion = "OMW-AIROPS-TECHNICAL-AVAILABILITY-DATA-1"
TechnicalAvailability.QuantityPerStore = 1000

TechnicalAvailability.ByNode = {
  BAGRAM = {
    F16_370GAL_TANK = 1000,
    F15E_EXTERNAL_TANK = 1000,
  },
  JALALABAD = {
    AH64_IAFS_COMBOPAK_100 = 1000,
  },
  KANDAHAR_HELI = {
    AH64_IAFS_COMBOPAK_100 = 1000,
  },
  SALERNO = {
    AH64_IAFS_COMBOPAK_100 = 1000,
  },
  SHINDAND_HELI = {
    AH64_IAFS_COMBOPAK_100 = 1000,
  },
  TARINKOT = {
    AH64_IAFS_COMBOPAK_100 = 1000,
  },
}

return TechnicalAvailability
