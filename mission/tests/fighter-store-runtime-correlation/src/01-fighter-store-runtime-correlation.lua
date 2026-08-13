-- Operation Mountain Watch - Bagram fighter store runtime correlation gate.
-- MOOSE-first. F-15E STRIKE materialization is automated through the productive
-- AIRWING/SQUADRON path; F-16 AIM-9 correlation uses normal client rearm.
-- STORAGE and CampaignState remain read-only / untouched by this harness.

local TAG = "[OMW][FighterStoreRuntimeCorrelation]"
local TEST_ID = "FIGHTER-STORE-RUNTIME-CORRELATION-1"
local START_DELAY_S = 20
local ASSIGN_TIMEOUT_S = 600
local GLOBAL_TIMEOUT_S = 4200
local F15_ORBIT_DURATION_S = 3600
local F16_POLL_INTERVAL_S = 2
local F16_SETTLE_SECONDS = 15
local MESSAGE_DURATION_S = 15
local STORAGE_NAME = "Bagram"
local F15_TEMPLATE = "TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP"
local F16_CLIENT_TYPE = "F-16C_50"
local F15_GBU31_V1_CANDIDATE = "weapons.bombs.GBU_31"
local F15_GBU31_V3_CANDIDATE = "weapons.bombs.GBU_31_V_3B"

local runtime = {
  startedAt = timer.getTime(),
  finished = false,
  storage = nil,
  f15 = { assigned = false, passed = false },
  f16 = {
    phaseReady = false,
    clientSet = nil,
    clientName = nil,
    playerName = nil,
    baselineWeapons = nil,
    baselineAmmo = nil,
    lastWeapons = nil,
    lastAmmo = nil,
    lastChangeAt = nil,
    evaluated = false,
    rearmEvents = 0,
  },
}

local function log(message)
  env.info(TAG .. " " .. tostring(message), false)
end

local function notify(message, duration)
  MESSAGE:New(tostring(message), duration or MESSAGE_DURATION_S, "OMW Fighter Store Gate"):ToAll()
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function copyNumericMap(source)
  local result = {}
  for key, value in pairs(source or {}) do
    if type(value) == "number" then
      result[tostring(key)] = value
    end
  end
  return result
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map or {}) do
    keys[#keys + 1] = tostring(key)
  end
  table.sort(keys)
  return keys
end

local function mapsEqual(a, b)
  for key, value in pairs(a or {}) do
    if (b and b[key] or 0) ~= value then return false end
  end
  for key, value in pairs(b or {}) do
    if (a and a[key] or 0) ~= value then return false end
  end
  return true
end

local function logMapDelta(phase, family, before, after)
  local seen = {}
  for key in pairs(before or {}) do seen[tostring(key)] = true end
  for key in pairs(after or {}) do seen[tostring(key)] = true end
  for _, key in ipairs(sortedKeys(seen)) do
    local oldValue = tonumber(before and before[key]) or 0
    local newValue = tonumber(after and after[key]) or 0
    if oldValue ~= newValue then
      log(string.format(
        "MAP_DELTA phase=%s family=%s item=%s before=%.3f after=%.3f delta=%.3f",
        tostring(phase), tostring(family), key, oldValue, newValue, newValue - oldValue
      ))
    end
  end
end

local function readStorageWeapons()
  local aircraft, liquids, weapons = runtime.storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    fail("STORAGE:GetInventory() returned invalid tuple")
  end
  return copyNumericMap(weapons)
end

local function readClientAmmo(client)
  local result = {}
  local ammo = client:GetAmmo()
  for _, item in ipairs(ammo or {}) do
    local descriptor = item and item.desc or nil
    local typeName = descriptor and descriptor.typeName or nil
    local count = item and item.count or nil
    if type(typeName) == "string" and type(count) == "number" then
      result[typeName] = (result[typeName] or 0) + count
    end
  end
  return result
end

local function resolveStorage()
  local airbase = AIRBASE:FindByName(STORAGE_NAME)
  if not airbase then fail("AIRBASE unresolved name=" .. STORAGE_NAME) end
  local fromAirbase = airbase:GetStorage()
  local fromRegistry = STORAGE:FindByName(STORAGE_NAME)
  if not fromAirbase or not fromRegistry or fromAirbase ~= fromRegistry then
    fail("STORAGE unresolved or wrapper identity mismatch name=" .. STORAGE_NAME)
  end
  runtime.storage = fromAirbase
end

local function finish(status, reason)
  if runtime.finished then return end
  runtime.finished = true
  log(string.format(
    "RESULT testId=%s status=%s reason=%s f15StrikeMapping=%s f16Aim9Mapping=%s storageMutation=false campaignStateMutation=false nativeDcs=false",
    TEST_ID,
    tostring(status),
    tostring(reason),
    tostring(runtime.f15.passed),
    tostring(runtime.f16.evaluated),
    tostring(false)
  ))
  notify("Fighter store correlation complete. Exit DCS and provide the tested MIZ, dcs.log and debrief.log.", 30)
end

local function evaluateF16Correlation(client)
  if runtime.finished or runtime.f16.evaluated then return end

  local weapons = readStorageWeapons()
  local ammo = readClientAmmo(client)
  logMapDelta("F16_AIM9_CUMULATIVE", "STORAGE_WEAPON", runtime.f16.baselineWeapons, weapons)
  logMapDelta("F16_AIM9_CUMULATIVE", "AIRCRAFT_AMMO", runtime.f16.baselineAmmo, ammo)

  local storageDebits = {}
  for key, before in pairs(runtime.f16.baselineWeapons or {}) do
    local after = tonumber(weapons[key]) or 0
    local delta = after - (tonumber(before) or 0)
    if delta < 0 then
      storageDebits[#storageDebits + 1] = { key = key, delta = delta }
    end
  end

  local ammoIncreases = {}
  local seenAmmo = {}
  for key in pairs(runtime.f16.baselineAmmo or {}) do seenAmmo[key] = true end
  for key in pairs(ammo or {}) do seenAmmo[key] = true end
  for key in pairs(seenAmmo) do
    local before = tonumber(runtime.f16.baselineAmmo and runtime.f16.baselineAmmo[key]) or 0
    local after = tonumber(ammo and ammo[key]) or 0
    local delta = after - before
    if delta > 0 then
      ammoIncreases[#ammoIncreases + 1] = { key = key, delta = delta }
    end
  end

  table.sort(storageDebits, function(a, b) return a.key < b.key end)
  table.sort(ammoIncreases, function(a, b) return a.key < b.key end)

  local exactStorage = #storageDebits == 1 and math.abs(storageDebits[1].delta + 2) < 0.001
  local exactAmmo = #ammoIncreases == 1 and math.abs(ammoIncreases[1].delta - 2) < 0.001

  if exactStorage and exactAmmo then
    runtime.f16.evaluated = true
    log(string.format(
      "F16_AIM9_MAPPING_PASS storageItem=%s storageDelta=%.3f aircraftAmmoType=%s aircraftAmmoDelta=%.3f rearmEvents=%d",
      storageDebits[1].key,
      storageDebits[1].delta,
      ammoIncreases[1].key,
      ammoIncreases[1].delta,
      runtime.f16.rearmEvents
    ))
    finish("PASS", "F15_STRIKE_AND_F16_AIM9_CORRELATED")
    return
  end

  runtime.f16.evaluated = true
  log(string.format(
    "F16_AIM9_MAPPING_REVIEW storageDebitKeys=%d ammoIncreaseKeys=%d exactTwoStoreDebit=%s exactTwoAmmoIncrease=%s rearmEvents=%d",
    #storageDebits,
    #ammoIncreases,
    tostring(exactStorage),
    tostring(exactAmmo),
    runtime.f16.rearmEvents
  ))
  finish("COMPLETE_WITH_GAPS", "F16_REARM_DELTAS_REQUIRE_LOG_REVIEW")
end

local function findActiveF16Client()
  local found = nil
  runtime.f16.clientSet:ForEachClient(function(client)
    if not found and client and client:IsAlive() then
      local playerName = client:GetPlayerName()
      if playerName and playerName ~= "" then found = client end
    end
  end)
  return found
end

local function bindF16Client(client)
  local clientName = client:GetName()
  if runtime.f16.clientName == clientName then return end

  runtime.f16.clientName = clientName
  runtime.f16.playerName = client:GetPlayerName() or "UNKNOWN"
  runtime.f16.baselineWeapons = readStorageWeapons()
  runtime.f16.baselineAmmo = readClientAmmo(client)
  runtime.f16.lastWeapons = runtime.f16.baselineWeapons
  runtime.f16.lastAmmo = runtime.f16.baselineAmmo
  runtime.f16.lastChangeAt = nil

  log(string.format(
    "F16_CLIENT_BASELINE unit=%s player=%s storageKeys=%d ammoKeys=%d",
    runtime.f16.clientName,
    runtime.f16.playerName,
    #sortedKeys(runtime.f16.baselineWeapons),
    #sortedKeys(runtime.f16.baselineAmmo)
  ))
  notify("F-16 phase: use normal ground crew rearm. Add exactly one AIM-9M on station 2 and one AIM-9M on station 8. Leave every other store unchanged.", 30)
end

local function pollF16()
  if runtime.finished or not runtime.f16.phaseReady or runtime.f16.evaluated then return end
  local client = findActiveF16Client()
  if not client then return end

  bindF16Client(client)
  local weapons = readStorageWeapons()
  local ammo = readClientAmmo(client)
  if not mapsEqual(runtime.f16.lastWeapons, weapons) or not mapsEqual(runtime.f16.lastAmmo, ammo) then
    logMapDelta("F16_AIM9_STEP", "STORAGE_WEAPON", runtime.f16.lastWeapons, weapons)
    logMapDelta("F16_AIM9_STEP", "AIRCRAFT_AMMO", runtime.f16.lastAmmo, ammo)
    runtime.f16.lastWeapons = weapons
    runtime.f16.lastAmmo = ammo
    runtime.f16.lastChangeAt = timer.getTime()
  elseif runtime.f16.lastChangeAt and timer.getTime() - runtime.f16.lastChangeAt >= F16_SETTLE_SECONDS then
    evaluateF16Correlation(client)
  end
end

local function startF16Phase()
  if runtime.finished or runtime.f16.phaseReady then return end
  runtime.f16.phaseReady = true
  runtime.f16.clientSet = SET_CLIENT:New():FilterCategories("plane"):FilterTypes(F16_CLIENT_TYPE):FilterStart()
  log("F16_PHASE_READY action=ENTER_BAGRAM_F16_THEN_ADD_AIM9M_STATIONS_2_AND_8 otherStoresUnchanged=true")
  notify("F-15E STRIKE mapping captured. Enter a Bagram F-16 client. Then add AIM-9M only on stations 2 and 8; change nothing else.", 30)
  SCHEDULER:New(nil, pollF16, {}, 0, F16_POLL_INTERVAL_S)
end

local eventHandler = EVENTHANDLER:New()
if EVENTS.WeaponRearm and EVENTS.WeaponRearm >= 0 then
  eventHandler:HandleEvent(EVENTS.WeaponRearm, function(_, eventData)
    local iniName = eventData and eventData.IniUnitName or nil
    if runtime.f16.clientName and iniName == runtime.f16.clientName then
      runtime.f16.rearmEvents = runtime.f16.rearmEvents + 1
      log(string.format("F16_WEAPON_REARM_EVENT unit=%s count=%d", iniName, runtime.f16.rearmEvents))
    end
  end)
else
  log("F16_WEAPON_REARM_EVENT_UNAVAILABLE fallback=STORAGE_AND_AMMO_POLLING")
end

local function startF15Phase()
  local state = OMW and OMW.AirOps and OMW.AirOps.Bagram or nil
  if not state or state.Status ~= "RUNNING" then fail("Bagram foundation is not RUNNING") end

  local airwing = state.Airwings and state.Airwings.USAF or nil
  local squadron = state.Squadrons and state.Squadrons.F15E or nil
  local airbase = state.Airbases and state.Airbases.USAF or nil
  local template = GROUP:FindByName(F15_TEMPLATE)
  if not airwing or not squadron or not airbase or not template then
    fail("F-15E STRIKE foundation dependency unresolved")
  end

  local before = readStorageWeapons()
  local testPayload = airwing:NewPayload(template, -1, { AUFTRAG.Type.ORBIT }, 100)
  if not testPayload then fail("AIRWING:NewPayload returned nil for F-15E STRIKE") end

  local orbitCoordinate = airbase:GetCoordinate():Translate(6000, 90)
  local mission = AUFTRAG:NewORBIT(orbitCoordinate, 12000, 250)
  mission:SetRequiredAssets(1, 1)
  mission:AssignSquadrons({ squadron })
  mission:AddRequiredPayload(testPayload)
  mission:SetTime(5)
  mission:SetDuration(F15_ORBIT_DURATION_S)
  mission:SetROE(ENUMS.ROE.WeaponHold)
  mission:SetROT(ENUMS.ROT.NoReaction)

  local previousFlightOnMission = airwing.OnAfterFlightOnMission
  airwing.OnAfterFlightOnMission = function(self, From, Event, To, FlightGroup, Mission)
    if previousFlightOnMission then previousFlightOnMission(self, From, Event, To, FlightGroup, Mission) end
    if runtime.finished or Mission ~= mission or runtime.f15.assigned then return end
    runtime.f15.assigned = true

    local after = readStorageWeapons()
    logMapDelta("F15_STRIKE_SPAWN", "STORAGE_WEAPON", before, after)

    local v1Delta = (tonumber(after[F15_GBU31_V1_CANDIDATE]) or 0) - (tonumber(before[F15_GBU31_V1_CANDIDATE]) or 0)
    local v3Delta = (tonumber(after[F15_GBU31_V3_CANDIDATE]) or 0) - (tonumber(before[F15_GBU31_V3_CANDIDATE]) or 0)

    if math.abs(v1Delta + 2) < 0.001 and math.abs(v3Delta + 2) < 0.001 then
      runtime.f15.passed = true
      log(string.format(
        "F15_STRIKE_MAPPING_PASS gbu31v1Item=%s gbu31v1Delta=%.3f gbu31v3Item=%s gbu31v3Delta=%.3f grouping=2",
        F15_GBU31_V1_CANDIDATE, v1Delta, F15_GBU31_V3_CANDIDATE, v3Delta
      ))
      startF16Phase()
    else
      log(string.format(
        "F15_STRIKE_MAPPING_FAIL gbu31v1Item=%s gbu31v1Delta=%.3f gbu31v3Item=%s gbu31v3Delta=%.3f expectedEach=-2",
        F15_GBU31_V1_CANDIDATE, v1Delta, F15_GBU31_V3_CANDIDATE, v3Delta
      ))
      finish("FAIL", "F15_STRIKE_GBU31_MAPPING")
    end
  end

  airwing:AddMission(mission)
  log(string.format(
    "F15_PHASE_DISPATCH template=%s candidateV1=%s candidateV3=%s mission=ORBIT noFire=true grouping=2",
    F15_TEMPLATE, F15_GBU31_V1_CANDIDATE, F15_GBU31_V3_CANDIDATE
  ))

  SCHEDULER:New(nil, function()
    if runtime.finished or runtime.f15.assigned then return end
    finish("FAIL", "F15_ASSIGN_TIMEOUT")
  end, {}, ASSIGN_TIMEOUT_S)
end

local function beginTest()
  local ok, err = pcall(function()
    resolveStorage()
    log("START storage=Bagram f15Mode=AIRWING_ORBIT f16Mode=CLIENT_REARM storageMutation=false campaignStateMutation=false nativeDcs=false")
    startF15Phase()
  end)
  if not ok then
    log("FATAL error=" .. tostring(err))
    finish("FATAL", "PRECONDITION")
  end
end

SCHEDULER:New(nil, beginTest, {}, START_DELAY_S)
SCHEDULER:New(nil, function()
  if not runtime.finished then finish("FAIL", "GLOBAL_TIMEOUT") end
end, {}, GLOBAL_TIMEOUT_S)
