local TEST_ID = "AAR-PRODUCTION-INTEGRATION-1"
local TAG = "[OMW][" .. TEST_ID .. "]"
local STATUS_INTERVAL_SEC = 10
local TIMEOUT_SEC = 900

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message))
end

if not OMW or not OMW.AAR then
  error(TAG .. " production AAR controller is not loaded")
end

local strategicEvents = {
  materialized = 0,
  handoffs = 0,
}

local TestStrategicAdapter = {}

function TestStrategicAdapter:CanMaterialize(selection)
  log(string.format(
    "STRATEGIC_ALLOW demand=%s area=%s profile=%s source=%s testAdapter=true",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain
  ))
  return true
end

function TestStrategicAdapter:OnMaterialized(selection, runtime)
  strategicEvents.materialized = strategicEvents.materialized + 1
  log(string.format(
    "STRATEGIC_MATERIALIZED demand=%s area=%s profile=%s group=%s count=%d testAdapter=true",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    runtime.group:GetName(),
    strategicEvents.materialized
  ))
end

function TestStrategicAdapter:OnHandoff(selection, runtime)
  strategicEvents.handoffs = strategicEvents.handoffs + 1
  log(string.format(
    "STRATEGIC_HANDOFF demand=%s area=%s profile=%s count=%d testAdapter=true",
    selection.missionDemandId,
    selection.area,
    selection.receiverProfile,
    strategicEvents.handoffs
  ))
end

OMW.AAR.SetStrategicAdapter(TestStrategicAdapter)

local DEMANDS = {
  {
    missionDemandId = "AAR-TEST-NELSON",
    receiverProfile = "FAST",
    operationsArea = "NORTHEAST",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "NELSON",
    expectedSource = "MANAS",
  },
  {
    missionDemandId = "AAR-TEST-KRUSTY",
    receiverProfile = "SLOW",
    operationsArea = "SOUTHEAST",
    supportMode = "RECOVERY",
    priority = "TEST",
    expectedArea = "KRUSTY",
    expectedSource = "AL_UDEID",
  },
  {
    missionDemandId = "AAR-TEST-PATTY",
    receiverProfile = "SLOW",
    operationsArea = "EAST",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "PATTY",
    expectedSource = "MANAS",
  },
  {
    missionDemandId = "AAR-TEST-MILHOUSE",
    receiverProfile = "SLOW",
    operationsArea = "SOUTH_CENTRAL",
    supportMode = "RECOVERY",
    priority = "TEST",
    expectedArea = "MILHOUSE",
    expectedSource = "AL_UDEID",
  },
  {
    missionDemandId = "AAR-TEST-MOE",
    receiverProfile = "FAST",
    operationsArea = "CENTRAL",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "MOE",
    expectedSource = "MANAS",
  },
  {
    missionDemandId = "AAR-TEST-LISA",
    receiverProfile = "SLOW",
    operationsArea = "WEST",
    supportMode = "SUPPORT",
    priority = "TEST",
    expectedArea = "LISA",
    expectedSource = "MANAS",
  },
}

local EXPECTED = {}
for _, demand in ipairs(DEMANDS) do
  local selection, reason = OMW.AAR.SelectArea(demand)
  if not selection then
    error(TAG .. " selection failed demand=" .. demand.missionDemandId .. " reason=" .. tostring(reason))
  end
  if selection.area ~= demand.expectedArea
      or selection.sourceDomain ~= demand.expectedSource
      or selection.receiverProfile ~= demand.receiverProfile then
    error(string.format(
      "%s selection mismatch demand=%s area=%s/%s source=%s/%s profile=%s/%s",
      TAG,
      demand.missionDemandId,
      tostring(selection.area),
      demand.expectedArea,
      tostring(selection.sourceDomain),
      demand.expectedSource,
      tostring(selection.receiverProfile),
      demand.receiverProfile
    ))
  end
  EXPECTED[demand.expectedArea .. ":" .. demand.receiverProfile] = demand
  log(string.format(
    "POLICY_PASS demand=%s area=%s profile=%s source=%s transit=%s",
    demand.missionDemandId,
    selection.area,
    selection.receiverProfile,
    selection.sourceDomain,
    selection.transitProfile
  ))
end

for _, demand in ipairs(DEMANDS) do
  local result, status = OMW.AAR.SubmitDemand(demand)
  if not result then
    error(TAG .. " submit failed demand=" .. demand.missionDemandId .. " status=" .. tostring(status))
  end
  log(string.format("SUBMIT_PASS demand=%s status=%s", demand.missionDemandId, tostring(status)))
end

local startedAt = timer.getAbsTime()
local executingLogged = {}
local completed = false

SCHEDULER:New(nil, function()
  if completed then
    return
  end

  local executingCount = 0
  local activeCount = 0

  for key, demand in pairs(EXPECTED) do
    local runtime = OMW.AAR.GetActive(demand.expectedArea, demand.receiverProfile)
    if runtime and runtime.flightGroup and runtime.flightGroup:IsAlive() then
      activeCount = activeCount + 1
      if runtime.mission and runtime.mission:IsExecuting() then
        executingCount = executingCount + 1
        if not executingLogged[key] then
          executingLogged[key] = true
          local fuelPct = runtime.flightGroup:GetFuelMin()
          log(string.format(
            "EXECUTING_PASS demand=%s area=%s profile=%s source=%s group=%s fuelPct=%.2f ingressFL=%d trackAltFt=%d egressFL=%d",
            demand.missionDemandId,
            demand.expectedArea,
            demand.receiverProfile,
            demand.expectedSource,
            runtime.group:GetName(),
            fuelPct or -1,
            runtime.transit.ingressFt / 100,
            runtime.profile.altitudeFt,
            runtime.transit.egressFt / 100
          ))
        end
      end
    end
  end

  if executingCount == #DEMANDS then
    completed = true
    log(string.format(
      "INTEGRATION_PASS demands=%d active=%d executing=%d materialized=%d sourceSpacingSec=%d artificialFuelLow=false",
      #DEMANDS,
      activeCount,
      executingCount,
      strategicEvents.materialized,
      OMW.AAR.GetConfig().sourceSpawnIntervalSec
    ))
    return
  end

  if timer.getAbsTime() - startedAt > TIMEOUT_SEC then
    completed = true
    fail(string.format(
      "TIMEOUT expected=%d active=%d executing=%d materialized=%d",
      #DEMANDS,
      activeCount,
      executingCount,
      strategicEvents.materialized
    ))
  end
end, {}, STATUS_INTERVAL_SEC, STATUS_INTERVAL_SEC)

log(string.format(
  "HARNESS_READY demands=%d sourceSpawnIntervalSec=%d timeoutSec=%d artificialFuelLow=false expectedNorthSpacing=true expectedSouthSpacing=true",
  #DEMANDS,
  OMW.AAR.GetConfig().sourceSpawnIntervalSec,
  TIMEOUT_SEC
))
