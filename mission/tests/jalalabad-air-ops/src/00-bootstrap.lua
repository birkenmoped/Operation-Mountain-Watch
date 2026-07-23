-- Operation Mountain Watch - Jalalabad Air Operations diagnostic bootstrap
-- Load after Moose.lua. This file intentionally does not create AIRWINGs or start missions.

local PREFIX = "[OMW-AIROPS][BOOT] "
local function log(message)
  env.info(PREFIX .. tostring(message), false)
end

OMW_AIR_OPS = OMW_AIR_OPS or {}
OMW_AIR_OPS.configurationVersion = "JBAD-AIROPS-DIAG-01"
OMW_AIR_OPS.diagnosticsOnly = true
OMW_AIR_OPS.airbase = {
  expectedNameContains = "Jalalabad",
  expectedDcsId = 16,
  warehouseAnchor = "WH_AIR_US_JALALABAD"
}
OMW_AIR_OPS.inventory = {
  OH58D = { total = 24, playerMax = 4, aiActiveMax = 4, staticTarget = 8 },
  AH64D = { total = 8, playerMax = 4, aiActiveMax = 4, staticTarget = 4 },
  UH60 = { total = 6, playerMax = 4, aiActiveMax = 4, staticTarget = 2 }
}
OMW_AIR_OPS.globalLimits = {
  supportMissions = 2,
  aircraftPerMission = 2,
  supportAircraft = 4
}
OMW_AIR_OPS.medevac = {
  packageSize = 2,
  leadAircraft = 1,
  coverAircraft = 1,
  allowSingleShip = false
}

log("configurationVersion=" .. OMW_AIR_OPS.configurationVersion)
log("diagnosticsOnly=true; no AIRWING, SQUADRON, AUFTRAG or spawn operation is created")
log("inventory OH58D=24 AH64D=8 UH60=6")
log("limits playerPerType=4 aiPerType=4 supportMissions=2 aircraftPerMission=2")
log("MEDEVAC packageSize=2 lead=1 cover=1 allowSingleShip=false")
