-- Operation Mountain Watch - Bagram parking final retest ALERT5 preparation.
-- Test-only augmentation. It intentionally does NOT change the production
-- Bagram foundation capabilities. The purpose is to make the existing final
-- parking materialization harness recruitable through the public MOOSE ALERT5
-- path.
--
-- Verified MOOSE invariant for the pinned artifact:
--   * ALERT5 recruitment checks the SQUADRON/COHORT for AUFTRAG.Type.ALERT5.
--   * Stock recruitment also needs a payload that is usable for ALERT5.
--   * Official MOOSE examples register ALERT5 on both the squadron capability
--     set and the payload capability set.

local TEST_ID = "BAGRAM-PARKING-FINAL-ACCEPTANCE-1-RETEST-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local EXPECTED_SQUADRONS = 7

local alert5MissionTypes = {
  F15E = AUFTRAG.Type.CAS,
  F16C = AUFTRAG.Type.CAS,
  MQ1A = AUFTRAG.Type.RECON,
  C130 = AUFTRAG.Type.TROOPTRANSPORT,
  HH60G = AUFTRAG.Type.RESCUEHELO,
  UH60 = AUFTRAG.Type.TROOPTRANSPORT,
  CH47 = AUFTRAG.Type.TROOPTRANSPORT,
}

local function fail(state, reason)
  if state then
    state.Status = "ERROR"
    state.Error = reason
  end
  env.error(TAG .. " ALERT5_TEST_PREP status=FAIL reason=" .. tostring(reason), false)
end

local function prepareAlert5Recruitment()
  local state = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  if not state or not state.Config or not state.Squadrons or not state.Airwings then
    fail(state, "BAGRAM_FOUNDATION_STATE_UNAVAILABLE")
    return
  end

  local preparedSquadrons = 0
  local preparedPayloads = 0

  for _, key in ipairs({ "F15E", "F16C", "MQ1A", "C130", "HH60G", "UH60", "CH47" }) do
    local definition = state.Config.squadrons[key]
    local squadron = state.Squadrons[key]
    local missionType = alert5MissionTypes[key]
    local airwing = definition and definition.wing == "usaf" and state.Airwings.USAF or state.Airwings.Army
    local seed = definition and GROUP:FindByName(definition.template) or nil

    if not definition or not squadron or not missionType or not airwing or not seed then
      fail(state, "ALERT5_TEST_PREP_OBJECT_MISSING_" .. tostring(key))
      return
    end

    -- MOOSE public API. ALERT5 is added only for this acceptance bundle.
    squadron:AddMissionCapability({ AUFTRAG.Type.ALERT5 })
    preparedSquadrons = preparedSquadrons + 1

    -- MOOSE stock recruitment requires an ALERT5-capable payload. Keep the
    -- operational mission type on the payload as well because NewALERT5 uses
    -- it as alert5MissionType for asset optimization/selection.
    local payload = airwing:NewPayload(seed, -1, { AUFTRAG.Type.ALERT5, missionType }, 100)
    if not payload then
      fail(state, "ALERT5_TEST_PAYLOAD_REGISTRATION_FAILED_" .. tostring(key))
      return
    end
    preparedPayloads = preparedPayloads + 1

    env.info(string.format(
      "%s ALERT5_TEST_PREP_ENTRY status=PASS key=%s squadron=%s template=%s alert5MissionType=%s",
      TAG,
      key,
      definition.name,
      definition.template,
      tostring(missionType)
    ))
  end

  if preparedSquadrons ~= EXPECTED_SQUADRONS or preparedPayloads ~= EXPECTED_SQUADRONS then
    fail(state, string.format("ALERT5_TEST_PREP_COUNT_MISMATCH squadrons=%d payloads=%d", preparedSquadrons, preparedPayloads))
    return
  end

  env.info(string.format(
    "%s ALERT5_TEST_PREP status=PASS squadrons=%d payloads=%d mode=TEST_ONLY_PUBLIC_MOOSE_API",
    TAG,
    preparedSquadrons,
    preparedPayloads
  ))
end

-- Run after the foundation NewAsset initialization but before the existing
-- final harness dispatch scheduler (2 s).
SCHEDULER:New(nil, prepareAlert5Recruitment, {}, 1)
