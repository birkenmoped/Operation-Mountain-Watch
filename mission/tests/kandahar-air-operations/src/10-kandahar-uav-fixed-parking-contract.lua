-- Operation Mountain Watch - Kandahar fixed UAV parking contract.
-- Applies the runtime TerminalIDs accepted by the 2026-08-01 G-apron calibration.
-- The contract is SQUADRON-specific and filtered through the current Main AIRWING
-- allowlist so statics and client reservations remain authoritative.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.UAVParkingContract]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local EXPECTED_AIRBASE_ID = 7
local EXPECTED_TERMINAL_TYPE = 104
local CALIBRATION_ARTIFACT = "OMW_Template_v4_Kandahar(9).miz"
local CALIBRATION_SHA256 = "47657b2ae532f98185a9f7c33b04f1ec9fc99ee1264496b44e93184d5ac39f1c"
local CALIBRATION_DCS_BUILD = "2.9.28.26385"

local POOLS = {
  MQ1 = {
    Squadron = "SQ_US_KAF_MQ1_361_ERS",
    Type = "RQ-1A Predator",
    Entries = {
      { Label = "G01", TerminalID = 189 },
      { Label = "G02", TerminalID = 303 },
      { Label = "G03", TerminalID = 202 },
      { Label = "G04", TerminalID = 224 },
      { Label = "G05", TerminalID = 46 },
      { Label = "G06", TerminalID = 291 },
      { Label = "G07", TerminalID = 129 },
      { Label = "G08", TerminalID = 143 }
    }
  },
  MQ9 = {
    Squadron = "SQ_US_KAF_MQ9_361_ERS",
    Type = "MQ-9 Reaper",
    Entries = {
      { Label = "G09", TerminalID = 27 },
      { Label = "G10", TerminalID = 54 },
      { Label = "G11", TerminalID = 263 }
    }
  }
}

local violations = 0

local function fail(reason)
  violations = violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function toNumericSet(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    local number = tonumber(value)
    if number then result[number] = true end
  end
  return result
end

local function sameNumericSet(actual, expected)
  if type(actual) ~= "table" or type(expected) ~= "table" then return false end
  local a = toNumericSet(actual)
  local e = toNumericSet(expected)
  for value in pairs(a) do if not e[value] then return false end end
  for value in pairs(e) do if not a[value] then return false end end
  return true
end

local function join(values)
  if not values or #values == 0 then return "none" end
  local text = {}
  for _, value in ipairs(values) do text[#text + 1] = tostring(value) end
  return table.concat(text, ",")
end

local function buildSpotIndex(spots)
  local index = {}
  for _, spot in ipairs(spots or {}) do
    local terminalID = tonumber(spot.TerminalID)
    if terminalID then index[terminalID] = spot end
  end
  return index
end

local function evaluatePool(key, definition, registration, mainContract, spotIndex, allowedSet, blockedSet)
  local squadron = registration.Squadrons and registration.Squadrons[definition.Squadron] or nil
  if not squadron then
    fail("SQUADRON_UNAVAILABLE pool=" .. key .. " squadron=" .. definition.Squadron)
    return {
      Definition = definition,
      AvailableIDs = {},
      AvailableLabels = {},
      UnavailableLabels = {},
      Applied = false
    }
  end

  local availableIDs = {}
  local availableLabels = {}
  local unavailableLabels = {}
  local labelToTerminal = {}

  for _, entry in ipairs(definition.Entries) do
    local terminalID = tonumber(entry.TerminalID)
    local spot = terminalID and spotIndex[terminalID] or nil
    local exists = spot ~= nil
    local terminalType = spot and tonumber(spot.TerminalType) or nil
    local allowed = terminalID and allowedSet[terminalID] == true or false
    local blocked = terminalID and blockedSet[terminalID] == true or false
    local available = exists and allowed and not blocked

    labelToTerminal[entry.Label] = terminalID

    if not exists then
      fail(string.format("RUNTIME_TERMINAL_MISSING pool=%s label=%s terminalID=%s", key, entry.Label, tostring(terminalID)))
    end
    if exists and terminalType ~= EXPECTED_TERMINAL_TYPE then
      fail(string.format(
        "TERMINAL_TYPE_MISMATCH pool=%s label=%s terminalID=%d expected=%d actual=%s",
        key,
        entry.Label,
        terminalID,
        EXPECTED_TERMINAL_TYPE,
        tostring(terminalType)
      ))
    end

    if available then
      availableIDs[#availableIDs + 1] = terminalID
      availableLabels[#availableLabels + 1] = entry.Label
    else
      unavailableLabels[#unavailableLabels + 1] = entry.Label
    end

    log(string.format(
      "ENTRY pool=%s label=%s type=%s terminalID=%s terminalType=%s exists=%s allowed=%s blocked=%s available=%s",
      key,
      entry.Label,
      definition.Type,
      tostring(terminalID),
      tostring(terminalType),
      tostring(exists),
      tostring(allowed),
      tostring(blocked),
      tostring(available)
    ))
  end

  table.sort(availableIDs)
  table.sort(availableLabels)
  table.sort(unavailableLabels)

  if #availableIDs == 0 then
    fail("NO_AVAILABLE_TERMINALS pool=" .. key)
  end

  local applied = false
  if violations == 0 or #availableIDs > 0 then
    local ok, result = pcall(function()
      return squadron:SetParkingIDs(availableIDs)
    end)
    if not ok then
      fail("SET_PARKING_IDS_FAILED pool=" .. key .. " error=" .. tostring(result))
    elseif not sameNumericSet(squadron.parkingIDs, availableIDs) then
      fail("SQUADRON_PARKING_IDS_MISMATCH pool=" .. key)
    else
      applied = true
    end
  end

  return {
    Definition = definition,
    Squadron = squadron,
    AvailableIDs = availableIDs,
    AvailableLabels = availableLabels,
    UnavailableLabels = unavailableLabels,
    LabelToTerminalID = labelToTerminal,
    Applied = applied
  }
end

local function main()
  log(string.format(
    "BEGIN fixedMapping=true calibrationArtifact=%s calibrationSha256=%s calibrationDcsBuild=%s noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
    CALIBRATION_ARTIFACT,
    CALIBRATION_SHA256,
    CALIBRATION_DCS_BUILD
  ))

  if OMW.AirOps.KandaharUAVParkingContract then
    log("RESULT: FAIL reason=UAV_PARKING_CONTRACT_ALREADY_EXECUTED noStart=true noSpawn=true")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  local parking = OMW.AirOps.KandaharParkingContractPreflight
  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_PREFLIGHT_NOT_PASSED noStart=true noSpawn=true")
    return
  end
  if not parking or parking.Applied ~= true or tonumber(parking.Violations) ~= 0 then
    log("RESULT: FAIL reason=PARKING_CONTRACT_NOT_PASSED noStart=true noSpawn=true")
    return
  end

  local mainContract = parking.Contracts and parking.Contracts.Main or nil
  local mainAirbase = mainContract and mainContract.Airbase or nil
  local mainAirwing = registration.Airwings and registration.Airwings.Main or nil
  if not mainContract or not mainAirbase or not mainAirwing then
    log("RESULT: FAIL reason=MAIN_RUNTIME_CONTRACT_UNAVAILABLE noStart=true noSpawn=true")
    return
  end

  if tonumber(mainAirbase:GetID()) ~= EXPECTED_AIRBASE_ID then
    log("RESULT: FAIL reason=MAIN_AIRBASE_ID_MISMATCH noStart=true noSpawn=true")
    return
  end

  if mainAirwing.IsRunning then
    local ok, running = pcall(function() return mainAirwing:IsRunning() end)
    if ok and running == true then
      log("RESULT: FAIL reason=MAIN_AIRWING_ALREADY_RUNNING noStart=true noSpawn=true")
      return
    end
  end

  local spotIndex = buildSpotIndex(mainContract.Spots)
  local allowedSet = toNumericSet(mainContract.AllowedIDs)
  local blockedSet = toNumericSet(mainContract.BlockedIDs)

  local mq1 = evaluatePool("MQ1", POOLS.MQ1, registration, mainContract, spotIndex, allowedSet, blockedSet)
  local mq9 = evaluatePool("MQ9", POOLS.MQ9, registration, mainContract, spotIndex, allowedSet, blockedSet)

  OMW.AirOps.KandaharUAVParkingContract = {
    CalibrationArtifact = CALIBRATION_ARTIFACT,
    CalibrationSHA256 = CALIBRATION_SHA256,
    CalibrationDCSBuild = CALIBRATION_DCS_BUILD,
    Airbase = mainAirbase,
    Airwing = mainAirwing,
    MQ1 = mq1,
    MQ9 = mq9,
    Violations = violations,
    Applied = violations == 0 and mq1.Applied == true and mq9.Applied == true,
    Started = false
  }

  if violations == 0 and mq1.Applied == true and mq9.Applied == true then
    log(string.format(
      "RESULT: PASS mq1Labels=8 mq1Available=%d mq1AvailableLabels=%s mq1TerminalIDs=%s mq1Unavailable=%s mq9Labels=3 mq9Available=%d mq9AvailableLabels=%s mq9TerminalIDs=%s mq9Unavailable=%s separatePools=true staticFiltered=true clientFiltered=true noFallback=true mq1Restricted=true mq9Restricted=true noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true",
      #mq1.AvailableIDs,
      join(mq1.AvailableLabels),
      join(mq1.AvailableIDs),
      join(mq1.UnavailableLabels),
      #mq9.AvailableIDs,
      join(mq9.AvailableLabels),
      join(mq9.AvailableIDs),
      join(mq9.UnavailableLabels)
    ))
  else
    log(string.format(
      "RESULT: FAIL violations=%d mq1Available=%d mq9Available=%d mq1Applied=%s mq9Applied=%s noStart=true noSpawn=true",
      violations,
      #mq1.AvailableIDs,
      #mq9.AvailableIDs,
      tostring(mq1.Applied),
      tostring(mq9.Applied)
    ))
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 24)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 24)
end
