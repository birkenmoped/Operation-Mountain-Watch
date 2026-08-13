-- Operation Mountain Watch - AirOps strategic fuel initial-stock supplement.
--
-- Contains only the owner-approved Kandahar MQ-1 AVGAS stock that was missing
-- from the productive AirOps resource baseline. It does not redefine, recalculate,
-- or replace previously closed FUEL_JP8 stock.
--
-- CampaignState fuel is stored in kg. Conversion basis:
-- 665 lb / 100 US gal = 6.65 lb/US gal;
-- 6.65 * 0.45359237 = 3.0163892605 kg/US gal.
--
-- This supplement is not a complete standalone fuel snapshot. Productive fuel
-- synchronization must combine it with the approved JP-8 baseline source.

local InitialFuelSupplement = {}

InitialFuelSupplement.SchemaVersion = "OMW-AIROPS-INITIAL-FUEL-SUPPLEMENT-1"
InitialFuelSupplement.SourceDecision = "OMW owner decision 2026-08-13"
InitialFuelSupplement.Mq1FuelReference = {
  pounds = 665,
  usGallons = 100,
  poundsPerUsGallon = 6.65,
  kgPerPound = 0.45359237,
  kgPerUsGallon = 3.0163892605,
}

InitialFuelSupplement.Rows = {
  {
    nodeId = "KANDAHAR_MAIN",
    resourceId = "FUEL_AVGAS",
    resourceClass = "CONSUMABLE_STRATEGIC",
    unit = "kg",
    initial = 20270.13583056,
    target = 20270.13583056,
    reorder = 12065.557042,
    critical = 6032.778521,
    supplyParent = "OFF_MAP",
    mappingStatus = "STORAGE_LIQUID_GASOLINE",
  },
}

InitialFuelSupplement.Planning = {
  KANDAHAR_MAIN = {
    FUEL_AVGAS = {
      aircraft = 4,
      hoursPerAircraftDay = 24,
      proxyUsGallonsPerHour = 4.1667,
      adoptedDailyUsGallons = 400,
      targetDays = 14,
      reorderDays = 10,
      criticalDays = 5,
      reserveFactor = 0.20,
      targetUsGallons = 6720,
      reorderUsGallons = 4000,
      criticalUsGallons = 2000,
      farpBufferDays = 2,
      farpBufferUsGallons = 800,
      dailyKg = 1206.5557042,
      farpBufferKg = 2413.1114084,
    },
  },
}

return InitialFuelSupplement
