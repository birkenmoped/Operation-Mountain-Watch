-- Operation Mountain Watch - Jalalabad Air Operations
-- First guarded MOOSE AIRWING/SQUADRON bootstrap.
-- Do not load until ValidateMissionTemplates.lua reports PASS.

local PREFIX = "[OMW-AIROPS-JBAD][BOOTSTRAP] "

local function log(message)
  env.info(PREFIX .. tostring(message))
end

local function fail(message)
  env.error(PREFIX .. tostring(message))
end

if not AIRWING or not SQUADRON or not AIRBASE or not AUFTRAG then
  fail("Required MOOSE OPS classes are unavailable. Load the pinned Moose.lua first.")
  return
end

local warehouseName = "WH_AIR_US_JALALABAD"
local airbase = AIRBASE:FindByName(AIRBASE.Afghanistan.Jalalabad)
if not airbase then
  fail("Jalalabad AIRBASE wrapper was not found.")
  return
end

local airwing = AIRWING:New(warehouseName, "AW_US_JALALABAD")
if not airwing then
  fail("AIRWING creation failed. Verify the named warehouse STATIC/UNIT.")
  return
end

airwing:SetAirbase(airbase)

local oh58 = SQUADRON:New(
  "TPL_AIR_US_JBAD_OH58D_RECON_2SHIP",
  2,
  "SQ_6_6_CAV_OH58D"
)
oh58:SetGrouping(2)
oh58:SetTakeoffCold()
oh58:SetDespawnAfterLanding(true)
oh58:AddMissionCapability({
  AUFTRAG.Type.RECON,
  AUFTRAG.Type.BAI,
  AUFTRAG.Type.ESCORT,
})

local ah64 = SQUADRON:New(
  "TPL_AIR_US_JBAD_AH64D_CAS_2SHIP",
  2,
  "SQ_B_1_10_AVN_AH64D"
)
ah64:SetGrouping(2)
ah64:SetTakeoffCold()
ah64:SetDespawnAfterLanding(true)
ah64:AddMissionCapability({
  AUFTRAG.Type.CAS,
  AUFTRAG.Type.BAI,
  AUFTRAG.Type.ESCORT,
})

local uh60Lead = SQUADRON:New(
  "TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP",
  2,
  "SQ_JBAD_UH60_MEDEVAC_LEAD"
)
uh60Lead:SetGrouping(1)
uh60Lead:SetTakeoffCold()
uh60Lead:SetDespawnAfterLanding(true)
uh60Lead:AddMissionCapability({
  AUFTRAG.Type.TROOPTRANSPORT,
  AUFTRAG.Type.OPSTRANSPORT,
})

local uh60Cover = SQUADRON:New(
  "TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP",
  2,
  "SQ_JBAD_UH60_MEDEVAC_COVER"
)
uh60Cover:SetGrouping(1)
uh60Cover:SetTakeoffCold()
uh60Cover:SetDespawnAfterLanding(true)
uh60Cover:AddMissionCapability({
  AUFTRAG.Type.ESCORT,
  AUFTRAG.Type.ORBIT,
})

airwing:AddSquadron(oh58)
airwing:AddSquadron(ah64)
airwing:AddSquadron(uh60Lead)
airwing:AddSquadron(uh60Cover)

airwing:Start()

_G.OMW_AIR_OPS = _G.OMW_AIR_OPS or {}
_G.OMW_AIR_OPS.Jalalabad = {
  airwing = airwing,
  airbase = airbase,
  squadrons = {
    oh58 = oh58,
    ah64 = ah64,
    uh60Lead = uh60Lead,
    uh60Cover = uh60Cover,
  },
}

log("AIRWING and four technical SQUADRON pools started.")
log("No AUFTRAG is created automatically by this bootstrap.")
