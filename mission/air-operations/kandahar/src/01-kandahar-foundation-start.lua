-- Operation Mountain Watch - Kandahar normalized AirOps foundation start.
--
-- This is the production-facing boundary after the accepted Kandahar registration,
-- parking and UAV initial-spawn contracts. It starts both AIRWING instances and
-- exposes the constructed objects for later mission providers.
--
-- Deliberately not included here:
--   * AUFTRAG construction or assignment
--   * payload registration
--   * OPSTRANSPORT
--   * COMMANDER/CHIEF integration
--   * warehouse self-requests or direct spawn calls
--   * post-landing parking workarounds

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.KAF.Foundation]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local EXPECTED_SQUADRONS = {
  "SQ_US_KAF_A10C_74_EFS",
  "SQ_US_KAF_HH60G_26_ERQS",
  "SQ_US_KAF_C130_772_EAS",
  "SQ_US_KAF_MQ1_361_ERS",
  "SQ_US_KAF_MQ9_361_ERS",
  "SQ_US_KAF_AH64_4_227_AVN",
  "SQ_US_KAF_OH58D_7_17_CAV",
  "SQ_US_KAF_CH47_7_101_GSAB",
  "SQ_US_KAF_UH60_7_101_GSAB"
}

local INVENTORY = {
  A10C = 16,
  HH60G = 6,
  C130 = 12,
  MQ1 = 4,
  MQ9 = 2,
  AH64D = 8,
  OH58D = 16,
  CH47 = 16,
  UH60 = 32,
  MC12Deferred = 6,
  RegisteredPhysicalAirframes = 112
}

local function isRunning(airwing)
  if not airwing or not airwing.IsRunning then return false end
  local ok, value = pcall(function() return airwing:IsRunning() end)
  return ok and value == true
end

local function startAirwing(key, airwing)
  if not airwing then
    return false, "AIRWING_MISSING key=" .. tostring(key)
  end

  if isRunning(airwing) then
    log("AIRWING_ALREADY_RUNNING key=" .. tostring(key) .. " accepted=true")
    return true
  end

  local ok, result = pcall(function()
    return airwing:Start()
  end)
  if not ok then
    return false, "AIRWING_START_FAILED key=" .. tostring(key) .. " error=" .. tostring(result)
  end

  if not isRunning(airwing) then
    return false, "AIRWING_NOT_RUNNING_AFTER_START key=" .. tostring(key)
  end

  log(string.format(
    "AIRWING_STARTED key=%s alias=%s airbase=%s airbaseID=%s",
    tostring(key),
    tostring(airwing.alias),
    airwing.GetAirbase and airwing:GetAirbase() and tostring(airwing:GetAirbase():GetName()) or "unknown",
    airwing.GetAirbase and airwing:GetAirbase() and tostring(airwing:GetAirbase():GetID()) or "unknown"
  ))
  return true
end

local function main()
  log("BEGIN normalizedFoundation=true startAirwings=true createMissions=false registerPayloads=false commander=false transport=false directSpawn=false")

  if OMW.AirOps.Kandahar then
    log("RESULT: FAIL reason=KANDAHAR_FOUNDATION_ALREADY_INITIALIZED")
    return
  end

  local registration = OMW.AirOps.KandaharRegistrationPreflight
  local parking = OMW.AirOps.KandaharParkingContractPreflight
  local uavParking = OMW.AirOps.KandaharUAVParkingContract
  local uavAssetSync = OMW.AirOps.KandaharUAVAssetParkingSync

  if not registration or registration.Constructed ~= true or tonumber(registration.Violations) ~= 0 then
    log("RESULT: FAIL reason=REGISTRATION_NOT_READY")
    return
  end
  if not parking or parking.Applied ~= true or tonumber(parking.Violations) ~= 0 then
    log("RESULT: FAIL reason=PARKING_CONTRACT_NOT_READY")
    return
  end
  if not uavParking or uavParking.Applied ~= true or tonumber(uavParking.Violations) ~= 0 then
    log("RESULT: FAIL reason=UAV_INITIAL_PARKING_CONTRACT_NOT_READY")
    return
  end
  if not uavAssetSync or uavAssetSync.Applied ~= true or tonumber(uavAssetSync.Violations) ~= 0 then
    log("RESULT: FAIL reason=UAV_REGISTERED_ASSET_SYNC_NOT_READY")
    return
  end

  local missing = {}
  for _, name in ipairs(EXPECTED_SQUADRONS) do
    if not registration.Squadrons or not registration.Squadrons[name] then
      missing[#missing + 1] = name
    end
  end
  if #missing > 0 then
    log("RESULT: FAIL reason=SQUADRON_SET_INCOMPLETE missing=" .. table.concat(missing, ","))
    return
  end

  local mainAirwing = registration.Airwings and registration.Airwings.Main or nil
  local heliportAirwing = registration.Airwings and registration.Airwings.Heliport or nil

  local mainOK, mainError = startAirwing("Main", mainAirwing)
  if not mainOK then
    log("RESULT: FAIL reason=" .. tostring(mainError))
    return
  end

  local heliportOK, heliportError = startAirwing("Heliport", heliportAirwing)
  if not heliportOK then
    log("RESULT: FAIL reason=" .. tostring(heliportError))
    return
  end

  registration.Started = true
  parking.Started = true
  uavParking.Started = true
  uavAssetSync.Started = true

  local foundation = {
    Status = "READY_NO_TASKING",
    Airwings = {
      Main = mainAirwing,
      Heliport = heliportAirwing
    },
    Squadrons = registration.Squadrons,
    Parking = parking.Contracts,
    UAVParking = {
      MQ1 = uavParking.MQ1,
      MQ9 = uavParking.MQ9
    },
    Inventory = INVENTORY,
    Deferred = registration.Config and registration.Config.Deferred or {},
    Runtime = {
      MainRunning = true,
      HeliportRunning = true,
      MissionsCreated = 0,
      PayloadsRegistered = 0,
      CommanderAttached = false,
      TransportCreated = false,
      DirectSpawnRequested = false
    },
    KnownLimitations = {
      UAVFinalParkingTypePoolEnforced = false,
      UAVFinalParkingFinding = "DCS_NATIVE_POST_LANDING_SELECTION_NOT_CONSTRAINED_BY_SQUADRON_PARKING_IDS",
      WarehouseReturnAccepted = false,
      MC12PhysicalRepresentationApproved = false
    }
  }

  OMW.AirOps.Kandahar = foundation
  OMW.AirOps.KandaharFoundation = foundation

  log(string.format(
    "RESULT: READY airwings=2 squadrons=%d registeredAirframes=%d deferredMC12=%d mainRunning=%s heliportRunning=%s missionsCreated=0 payloadsRegistered=0 commanderAttached=false transportCreated=false directSpawnRequested=false uavInitialSpawnRestricted=true uavFinalParkingRestricted=false",
    #EXPECTED_SQUADRONS,
    INVENTORY.RegisteredPhysicalAirframes,
    INVENTORY.MC12Deferred,
    tostring(isRunning(mainAirwing)),
    tostring(isRunning(heliportAirwing))
  ))
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 32)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 32)
end
