-- Operation Mountain Watch - Stage 2 FOB/COP Hit Acceptance 1.
--
-- Runtime scope:
--   real MOOSE EVENTS.Hit events against one explicitly registered BLUE test group
--   -> OMW_FobAttackHitAdapter
--   -> OMW_FobAttackDemandPolicy
--   -> existing MissionDemand CAS_IMMEDIATE registry
--   -> repeated real hit at the same installation remains one active demand.

local TEST_ID = "FOB-ATTACK-HIT-ACCEPTANCE-1"
local TARGET_GROUP_NAME = "TST_BLUE_GND_FORTRESS_HIT_TARGET"
local INSTALLATION_ID = "BLUE_GROUND_COP_FORTRESS"
local PRIORITY = 90

local MissionDemand = OMW_STAGE2_MISSION_DEMAND
local DemandPolicy = OMW_STAGE2_FOB_ATTACK_DEMAND_POLICY
local HitAdapter = OMW_STAGE2_FOB_ATTACK_HIT_ADAPTER

local logger = BASE:New()
local registry = MissionDemand.New()
local state = {
  qualifiedHitCount = 0,
  demandResults = {},
  passed = false,
}

local function log(message)
  logger:I(string.format("[OMW][%s] %s", TEST_ID, tostring(message)))
end

local observedPolicy = {}
function observedPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  local demand, created, reason = DemandPolicy.CreateDemand(missionDemand, demandRegistry, incident)
  state.demandResults[#state.demandResults + 1] = {
    incidentId = incident.incidentId,
    demandId = demand and demand.id or nil,
    created = created,
    reason = reason,
  }
  log(string.format(
    "DEMAND_RESULT hit=%d incidentId=%s demandId=%s created=%s reason=%s",
    state.qualifiedHitCount,
    tostring(incident.incidentId),
    tostring(demand and demand.id),
    tostring(created),
    tostring(reason)
  ))
  return demand, created, reason
end

local adapter = HitAdapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  policy = observedPolicy,
  blueCoalition = coalition.side.BLUE,
  redCoalition = coalition.side.RED,
  incidentIdFactory = function(eventData, registration)
    state.qualifiedHitCount = state.qualifiedHitCount + 1
    local eventTime = tonumber(eventData.time) or 0
    local incidentId = string.format(
      "INC-STAGE2-A1|%s|%.3f|%d",
      registration.installationId,
      eventTime,
      state.qualifiedHitCount
    )
    log(string.format(
      "QUALIFIED_HIT count=%d targetGroup=%s targetUnit=%s initiatorGroup=%s initiatorUnit=%s weapon=%s time=%.3f",
      state.qualifiedHitCount,
      tostring(eventData.TgtGroupName),
      tostring(eventData.TgtUnitName),
      tostring(eventData.IniGroupName),
      tostring(eventData.IniUnitName),
      tostring(eventData.WeaponName),
      eventTime
    ))
    return incidentId
  end,
  targetGroups = {
    [TARGET_GROUP_NAME] = {
      installationId = INSTALLATION_ID,
      priority = PRIORITY,
    },
  },
})

local _, started = adapter:Start()
if started ~= true then
  error(string.format("[OMW][%s] adapter failed to start", TEST_ID))
end

log(string.format(
  "READY targetGroup=%s installationId=%s priority=%d requirement=at_least_two_real_RED_on_BLUE_hits",
  TARGET_GROUP_NAME,
  INSTALLATION_ID,
  PRIORITY
))

SCHEDULER:New(nil, function()
  if state.passed or state.qualifiedHitCount < 2 or #state.demandResults < 2 then
    return
  end

  local active = registry:ListActive()
  local first = state.demandResults[1]
  local second = state.demandResults[2]
  local demand = active[1]

  local ok = #active == 1
    and first.created == true
    and first.reason == nil
    and second.created == false
    and second.reason == "active_duplicate"
    and first.demandId == second.demandId
    and demand ~= nil
    and demand.missionType == MissionDemand.Type.CAS_IMMEDIATE
    and demand.origin == INSTALLATION_ID
    and demand.dedupeKey == ("CAS_IMMEDIATE|FOB_ATTACK|" .. INSTALLATION_ID)

  if not ok then
    error(string.format(
      "[OMW][%s] FAIL qualifiedHits=%d active=%d firstCreated=%s firstReason=%s secondCreated=%s secondReason=%s firstDemand=%s secondDemand=%s",
      TEST_ID,
      state.qualifiedHitCount,
      #active,
      tostring(first.created),
      tostring(first.reason),
      tostring(second.created),
      tostring(second.reason),
      tostring(first.demandId),
      tostring(second.demandId)
    ))
  end

  state.passed = true
  log(string.format(
    "PASS qualifiedHits=%d activeDemands=%d demandId=%s missionType=%s installationId=%s dedupeKey=%s",
    state.qualifiedHitCount,
    #active,
    tostring(demand.id),
    tostring(demand.missionType),
    tostring(demand.origin),
    tostring(demand.dedupeKey)
  ))
  adapter:Stop()
end, {}, 2, 2)
