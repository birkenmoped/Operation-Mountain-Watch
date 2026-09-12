-- Operation Mountain Watch - Production Base Acceptance 2.
--
-- Validates the authoritative installation-incident -> Base -> local QRF path.
-- The attack evidence record is deliberately injected by the acceptance harness;
-- physical detection/perimeter qualification is not part of this test.

local ID = "FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2"
local TAG = "[OMW][" .. ID .. "]"
local HONAKER = "COP_HONAKER"
local INSTALLATION_ID = "BLUE_GROUND_COP_HONAKER_MIRACLE"
local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"
local ATTACKER_GROUP = "BadGuys1"
local OBSERVATION_SECONDS = 300
local TELEMETRY_SECONDS = 20
local MIN_PROGRESS_M = 25

local state = {
  failed=false,
  passed=false,
  runtime=nil,
  brigades={},
  qrfGroup=nil,
  qrfStart=nil,
  target=nil,
  initialDistance=nil,
  currentDistance=nil,
  qrfMissionObserved=false,
  qrfAttribute=nil,
  sourceIncidentId=nil,
  baseIncidentId=nil,
  demandCountAfterRefresh=nil,
}

local function log(message) env.info(TAG .. " " .. tostring(message), false) end
local function announce(kind, message, duration)
  local text = "[PRODUCTION BASE A2][" .. tostring(kind) .. "] " .. tostring(message)
  log(text)
  MESSAGE:New(text, duration or 10):ToAll()
end
local function fail(message)
  if state.failed or state.passed then return end
  state.failed=true
  announce("FAIL", message, 25)
end

local function createBrigades(package)
  for siteId, site in pairs(package.SiteRegistry.Sites) do
    local brigade = BRIGADE:New(site.warehouseName, "BDE_FSSR_PROD_A2_" .. siteId)
    if siteId == HONAKER then
      local qrf = PLATOON:New(QRF_TEMPLATE, 1, "PLT_FSSR_PROD_A2_HONAKER_QRF")
      if not qrf then fail("QRF_PLATOON_CREATE_FAILED"); return false end
      qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
      brigade:AddPlatoon(qrf)
    end

    local previous = brigade.OnAfterArmyOnMission
    brigade.OnAfterArmyOnMission = function(self, From, Event, To, armyGroup, mission)
      if previous then previous(self, From, Event, To, armyGroup, mission) end
      if siteId ~= HONAKER then return end
      local group = armyGroup and armyGroup:GetGroup() or nil
      if not group then return end
      local attribute = group:GetAttribute()
      log("ARMY_ON_MISSION siteId=" .. siteId .. " group=" .. tostring(group:GetName()) .. " attribute=" .. tostring(attribute))
      if attribute == GROUP.Attribute.GROUND_APC then
        state.qrfGroup = group
        state.qrfStart = group:GetCoordinate()
        state.qrfAttribute = attribute
        state.qrfMissionObserved = true
        if state.qrfStart and state.target then
          state.initialDistance = state.qrfStart:Get2DDistance(state.target)
        end
      end
    end
    state.brigades[siteId] = brigade
  end
  return true
end

local function telemetry()
  if state.qrfGroup and state.qrfGroup:IsAlive() and state.target then
    local coordinate = state.qrfGroup:GetCoordinate()
    if coordinate then state.currentDistance = coordinate:Get2DDistance(state.target) end
  end
  local progress = 0
  if state.initialDistance and state.currentDistance then progress = state.initialDistance - state.currentDistance end
  log(string.format(
    "TELEMETRY qrfObserved=%s qrfAlive=%s attribute=%s initialDistanceM=%s currentDistanceM=%s progressM=%.1f baseIncidentId=%s demandCountAfterRefresh=%s",
    tostring(state.qrfMissionObserved),
    tostring(state.qrfGroup ~= nil and state.qrfGroup:IsAlive()),
    tostring(state.qrfAttribute),
    state.initialDistance and string.format("%.1f",state.initialDistance) or "nil",
    state.currentDistance and string.format("%.1f",state.currentDistance) or "nil",
    progress,
    tostring(state.baseIncidentId),
    tostring(state.demandCountAfterRefresh)
  ))
end

local function finish()
  if state.failed or state.passed then return end
  telemetry()
  if not state.qrfMissionObserved then fail("QRF_MISSION_NOT_OBSERVED"); return end
  if not state.qrfGroup or not state.qrfGroup:IsAlive() then fail("QRF_GROUP_NOT_ALIVE"); return end
  if state.qrfAttribute ~= GROUP.Attribute.GROUND_APC then fail("QRF_ATTRIBUTE_NOT_GROUND_APC"); return end
  if not state.initialDistance or not state.currentDistance then fail("QRF_DISTANCE_TELEMETRY_MISSING"); return end
  local progress = state.initialDistance - state.currentDistance
  if progress < MIN_PROGRESS_M then fail(string.format("QRF_PROGRESS_%.1f_LT_%d",progress,MIN_PROGRESS_M)); return end
  if state.demandCountAfterRefresh ~= 1 then fail("INCIDENT_REFRESH_CREATED_DUPLICATE_DEMAND"); return end
  state.passed=true
  announce("PASS",string.format("Honaker incident opened once; MOOSE recruited Ground_APC QRF; target-distance progress %.1f m; refresh kept one response demand",progress),30)
end

local function injectIncident()
  if state.failed then return end
  local badGuys = GROUP:FindByName(ATTACKER_GROUP)
  if not badGuys then fail("ATTACKER_GROUP_MISSING " .. ATTACKER_GROUP); return end
  if badGuys:IsAlive() ~= true then badGuys:Activate() end

  SCHEDULER:New(nil,function()
    if state.failed then return end
    if badGuys:IsAlive() ~= true then fail("ATTACKER_GROUP_NOT_ACTIVE"); return end
    state.target = badGuys:GetCoordinate()
    if not state.target then fail("ATTACKER_COORDINATE_MISSING"); return end

    local evidence = {
      installationId=INSTALLATION_ID,
      evidenceType="DIRECT_FIRE_ATTACK",
      source="ACCEPTANCE_FIXTURE",
      sourceId=ATTACKER_GROUP,
      position=state.target,
      initiatorGroup=badGuys,
      metadata={ physicalDetectionValidated=false, purpose="incident-qrf-integration" },
    }
    local incident, created, reason = state.runtime:ReportInstallationEvidence(evidence)
    if not incident or created ~= true then fail("INITIAL_INCIDENT_NOT_CREATED " .. tostring(reason)); return end
    state.sourceIncidentId = incident.incidentId
    state.baseIncidentId = OMW.FireSupStratResupply.IdContract.Incident(HONAKER, incident.incidentId)

    local refreshed, refreshCreated, refreshReason = state.runtime:ReportInstallationEvidence({
      installationId=INSTALLATION_ID,
      evidenceType="DIRECT_FIRE_ATTACK",
      source="ACCEPTANCE_FIXTURE_REFRESH",
      sourceId=ATTACKER_GROUP,
      position=state.target,
      initiatorGroup=badGuys,
    })
    if not refreshed or refreshCreated ~= false or refreshReason ~= "ACTIVE_INCIDENT_REFRESHED" then
      fail("INCIDENT_REFRESH_FAILED " .. tostring(refreshReason)); return
    end
    local baseIncident = state.runtime:GetBase():GetIncident(state.baseIncidentId)
    if not baseIncident then fail("BASE_INCIDENT_NOT_FOUND"); return end
    state.demandCountAfterRefresh = #baseIncident.demandIds
    if state.demandCountAfterRefresh ~= 1 then fail("INCIDENT_REFRESH_DEMAND_COUNT_" .. tostring(state.demandCountAfterRefresh)); return end

    announce("READY","Honaker integration evidence injected at live BadGuys1 coordinate; observing MOOSE QRF response",15)
    SCHEDULER:New(nil,telemetry,{},TELEMETRY_SECONDS,TELEMETRY_SECONDS)
    SCHEDULER:New(nil,finish,{},OBSERVATION_SECONDS)
  end,{},2)
end

local function start()
  if type(OMW)~="table" or type(OMW.FireSupStratResupply)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  local package=OMW.FireSupStratResupply
  if package.SchemaVersion~="OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1" then fail("PACKAGE_SCHEMA_MISMATCH"); return end
  if not GROUP:FindByName(QRF_TEMPLATE) then fail("QRF_TEMPLATE_MISSING " .. QRF_TEMPLATE); return end
  if not GROUP:FindByName(ATTACKER_GROUP) then fail("ATTACKER_TEMPLATE_MISSING " .. ATTACKER_GROUP); return end
  if not createBrigades(package) then return end

  local ok, runtimeOrError = pcall(function()
    return package.New({
      brigades=state.brigades,
      resolveGuardPathline=function(pathlineName) return PATHLINE:FindByName(pathlineName) end,
      resolveGuardTemplateGroup=function(templateName) return GROUP:FindByName(templateName) end,
      resolveQrfCoordinate=function(demand,context)
        local incident=context and context.incident
        local incidentContext=incident and incident.context
        return incidentContext and incidentContext.position or nil, "INCIDENT_POSITION_UNAVAILABLE"
      end,
      qrfRequiredAttributes=GROUP.Attribute.GROUND_APC,
      logger=log,
    }):Prepare()
  end)
  if not ok then fail("RUNTIME_PREPARE_FAILED " .. tostring(runtimeOrError)); return end
  state.runtime=runtimeOrError
  if not state.runtime then fail("RUNTIME_PREPARE_RETURNED_NIL"); return end

  for _,brigade in pairs(state.brigades) do brigade:Start() end
  SCHEDULER:New(nil,injectIncident,{},5)
end

SCHEDULER:New(nil,start,{},10)
