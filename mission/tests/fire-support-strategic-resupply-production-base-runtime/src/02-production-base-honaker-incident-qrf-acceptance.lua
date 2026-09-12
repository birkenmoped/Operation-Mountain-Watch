-- Operation Mountain Watch - Production Base Acceptance 2.
--
-- Combined regression: six persistent Guards plus authoritative installation
-- incident -> local QRF. Guard/QRF capability needs are expressed through MOOSE
-- AUFTRAG recruitment filters; OMW does not preselect concrete operational assets.
-- The attack evidence is injected by the acceptance harness; physical detection
-- qualification is deliberately outside this test.

local ID = "FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2"
local TAG = "[OMW][" .. ID .. "]"
local HONAKER = "COP_HONAKER"
local INSTALLATION_ID = "BLUE_GROUND_COP_HONAKER_MIRACLE"
local GUARD_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"
local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"
local ATTACKER_GROUP = "BadGuys1"
local OBSERVATION_SECONDS = 300
local TELEMETRY_SECONDS = 20
local MIN_PROGRESS_M = 25
local SITE_KEYS = {
  "JALALABAD_FENTY", "COP_FORTRESS", "FOB_JOYCE",
  "FOB_WRIGHT", "COP_HONAKER", "FOB_BOSTICK",
}

local state = {
  failed=false,
  passed=false,
  runtime=nil,
  brigades={},
  guards={},
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
  for _,siteId in ipairs(SITE_KEYS) do
    local site=package.SiteRegistry.Sites[siteId]
    if not site then fail("SITE_REGISTRY_MISSING "..siteId); return false end
    local brigade = BRIGADE:New(site.warehouseName, "BDE_FSSR_PROD_A2_" .. siteId)

    local guard = PLATOON:New(site.guardTemplateName, 1, "PLT_FSSR_PROD_A2_GUARD_" .. siteId)
    if not guard then fail("GUARD_PLATOON_CREATE_FAILED "..siteId); return false end
    guard:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
    brigade:AddPlatoon(guard)
    state.guards[siteId]={group=nil,start=nil,movementM=0,missionObserved=false}

    if siteId == HONAKER then
      local qrf = PLATOON:New(QRF_TEMPLATE, 1, "PLT_FSSR_PROD_A2_HONAKER_QRF")
      if not qrf then fail("QRF_PLATOON_CREATE_FAILED"); return false end
      qrf:AddMissionCapability(AUFTRAG.Type.ONGUARD, 100)
      brigade:AddPlatoon(qrf)
    end

    local previous = brigade.OnAfterArmyOnMission
    brigade.OnAfterArmyOnMission = function(self, From, Event, To, armyGroup, mission)
      if previous then previous(self, From, Event, To, armyGroup, mission) end
      local group = armyGroup and armyGroup:GetGroup() or nil
      if not group then return end
      local attribute = group:GetAttribute()
      log("ARMY_ON_MISSION siteId=" .. siteId .. " group=" .. tostring(group:GetName()) .. " attribute=" .. tostring(attribute))
      if attribute == GROUP.Attribute.GROUND_INFANTRY then
        local guardState=state.guards[siteId]
        guardState.group=group
        guardState.start=group:GetCoordinate()
        guardState.missionObserved=true
      elseif siteId == HONAKER and attribute == GROUP.Attribute.GROUND_APC then
        state.qrfGroup = group
        state.qrfStart = group:GetCoordinate()
        state.qrfAttribute = attribute
        state.qrfMissionObserved = true
        if state.qrfStart and state.target then state.initialDistance = state.qrfStart:Get2DDistance(state.target) end
      end
    end
    state.brigades[siteId] = brigade
  end
  return true
end

local function telemetry()
  for _,siteId in ipairs(SITE_KEYS) do
    local guardState=state.guards[siteId]
    if guardState and guardState.group and guardState.group:IsAlive() and guardState.start then
      local c=guardState.group:GetCoordinate()
      if c then guardState.movementM=guardState.start:Get2DDistance(c) end
    end
    if guardState then
      log(string.format("GUARD_TELEMETRY siteId=%s observed=%s alive=%s movementM=%.1f",
        siteId,tostring(guardState.missionObserved),tostring(guardState.group~=nil and guardState.group:IsAlive()),guardState.movementM or 0))
    end
  end

  if state.qrfGroup and state.qrfGroup:IsAlive() and state.target then
    local coordinate = state.qrfGroup:GetCoordinate()
    if coordinate then state.currentDistance = coordinate:Get2DDistance(state.target) end
  end
  local progress = 0
  if state.initialDistance and state.currentDistance then progress = state.initialDistance - state.currentDistance end
  log(string.format(
    "QRF_TELEMETRY observed=%s alive=%s attribute=%s initialDistanceM=%s currentDistanceM=%s progressM=%.1f baseIncidentId=%s demandCountAfterRefresh=%s",
    tostring(state.qrfMissionObserved),
    tostring(state.qrfGroup ~= nil and state.qrfGroup:IsAlive()),
    tostring(state.qrfAttribute),
    state.initialDistance and string.format("%.1f",state.initialDistance) or "nil",
    state.currentDistance and string.format("%.1f",state.currentDistance) or "nil",
    progress,tostring(state.baseIncidentId),tostring(state.demandCountAfterRefresh)))
end

local function finish()
  if state.failed or state.passed then return end
  telemetry()
  local failures={}
  for _,siteId in ipairs(SITE_KEYS) do
    local g=state.guards[siteId]
    if not g or not g.missionObserved then failures[#failures+1]=siteId..":GUARD_NOT_OBSERVED"
    elseif not g.group or not g.group:IsAlive() then failures[#failures+1]=siteId..":GUARD_NOT_ALIVE"
    elseif (g.movementM or 0)<MIN_PROGRESS_M then failures[#failures+1]=string.format("%s:GUARD_MOVEMENT_%.1f_LT_%d",siteId,g.movementM or 0,MIN_PROGRESS_M) end
  end
  if #failures>0 then fail("GUARD_REGRESSION "..table.concat(failures,", ")); return end
  if not state.qrfMissionObserved then fail("QRF_MISSION_NOT_OBSERVED"); return end
  if not state.qrfGroup or not state.qrfGroup:IsAlive() then fail("QRF_GROUP_NOT_ALIVE"); return end
  if state.qrfAttribute ~= GROUP.Attribute.GROUND_APC then fail("QRF_ATTRIBUTE_NOT_GROUND_APC"); return end
  if not state.initialDistance or not state.currentDistance then fail("QRF_DISTANCE_TELEMETRY_MISSING"); return end
  local progress = state.initialDistance - state.currentDistance
  if progress < MIN_PROGRESS_M then fail(string.format("QRF_PROGRESS_%.1f_LT_%d",progress,MIN_PROGRESS_M)); return end
  if state.demandCountAfterRefresh ~= 1 then fail("INCIDENT_REFRESH_CREATED_DUPLICATE_DEMAND"); return end
  state.passed=true
  announce("PASS",string.format("6/6 Guards >=25 m; Honaker incident opened once; MOOSE recruited Ground_APC QRF; target-distance progress %.1f m; refresh kept one response demand",progress),30)
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

    announce("READY","six Guards active; Honaker integration evidence injected at live BadGuys1 coordinate; observing MOOSE QRF response",15)
    SCHEDULER:New(nil,telemetry,{},TELEMETRY_SECONDS,TELEMETRY_SECONDS)
    SCHEDULER:New(nil,finish,{},OBSERVATION_SECONDS)
  end,{},2)
end

local function startDemands()
  for _,siteId in ipairs(SITE_KEYS) do
    local _,created,reason=state.runtime:StartSite(siteId,{})
    if created==false then fail(siteId.." GUARD_START_FAILED "..tostring(reason)); return end
  end
  SCHEDULER:New(nil,injectIncident,{},5)
end

local function start()
  if type(OMW)~="table" or type(OMW.FireSupStratResupply)~="table" then fail("PRODUCTION_PACKAGE_UNAVAILABLE"); return end
  local package=OMW.FireSupStratResupply
  if package.SchemaVersion~="OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1" then fail("PACKAGE_SCHEMA_MISMATCH"); return end
  if not GROUP:FindByName(GUARD_TEMPLATE) then fail("GUARD_TEMPLATE_MISSING "..GUARD_TEMPLATE); return end
  if not GROUP:FindByName(QRF_TEMPLATE) then fail("QRF_TEMPLATE_MISSING " .. QRF_TEMPLATE); return end
  if not GROUP:FindByName(ATTACKER_GROUP) then fail("ATTACKER_TEMPLATE_MISSING " .. ATTACKER_GROUP); return end
  if not createBrigades(package) then return end

  local ok, runtimeOrError = pcall(function()
    return package.New({
      brigades=state.brigades,
      resolveGuardPathline=function(pathlineName) return PATHLINE:FindByName(pathlineName) end,
      resolveGuardTemplateGroup=function(templateName) return GROUP:FindByName(templateName) end,
      guardRequiredAttributes=GROUP.Attribute.GROUND_INFANTRY,
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
  SCHEDULER:New(nil,startDemands,{},3)
end

SCHEDULER:New(nil,start,{},10)
