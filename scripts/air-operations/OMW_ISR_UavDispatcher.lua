-- Operation Mountain Watch - MOOSE-only player ISR UAV dispatch adapter.
--
-- This adapter selects a preconfigured ISR Cell profile, reserves exactly one
-- CampaignState aircraft, registers the existing Mission Editor payload with
-- AIRWING and submits an AUFTRAG. It intentionally contains no native
-- DCS spawn, route or target-marker path.

local Dispatcher = {}
Dispatcher.__index = Dispatcher

local TAG = "[OMW][ISR.UavDispatcher]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function requireFunction(value, label)
  if type(value) ~= "function" then
    fail(label .. " must be a function")
  end
  return value
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " must be a non-empty string")
  end
  return value
end

function Dispatcher.New(config)
  config = requireTable(config, "config")
  local moose = config.moose or _G
  requireTable(moose.ZONE_RADIUS, "MOOSE ZONE_RADIUS")
  requireTable(moose.AUFTRAG, "MOOSE AUFTRAG")
  requireTable(moose.ENUMS, "MOOSE ENUMS")
  if type(config.campaignAdapter) ~= "table" then
    fail("config.campaignAdapter is required")
  end
  requireFunction(config.campaignAdapter.Reserve, "campaignAdapter.Reserve")
  requireFunction(config.campaignAdapter.ConsumeAtPhysicalStart, "campaignAdapter.ConsumeAtPhysicalStart")

  if config.onMissionStarted ~= nil then requireFunction(config.onMissionStarted, "config.onMissionStarted") end
  if config.onMissionExecuting ~= nil then requireFunction(config.onMissionExecuting, "config.onMissionExecuting") end
  if config.onMissionCancelled ~= nil then requireFunction(config.onMissionCancelled, "config.onMissionCancelled") end
  if config.onMissionDone ~= nil then requireFunction(config.onMissionDone, "config.onMissionDone") end

  return setmetatable({
    moose = moose,
    campaignAdapter = config.campaignAdapter,
    source = requireTable(config.source or config.kandahar, "config.source"),
    profiles = requireTable(config.profiles, "config.profiles"),
    registeredPayloadProfileIds = {},
    missionsByRequestId = {},
    onMissionStarted = config.onMissionStarted,
    onMissionExecuting = config.onMissionExecuting,
    onMissionCancelled = config.onMissionCancelled,
    onMissionDone = config.onMissionDone,
  }, Dispatcher)
end

function Dispatcher:_Airwing(profile)
  local airwingKey = requireNonEmptyString(profile.airwingKey or "Main", "profile.airwingKey")
  local airwing = self.source.Airwings and self.source.Airwings[airwingKey] or nil
  if not airwing or type(airwing.NewPayload) ~= "function" or type(airwing.AddMission) ~= "function" then
    fail("configured source AIRWING is not available key=" .. airwingKey)
  end
  return airwing
end

function Dispatcher:_Squadron(profile)
  local squadronKey = requireNonEmptyString(profile.squadronKey, "profile.squadronKey")
  local squadron = self.source.Squadrons and self.source.Squadrons[squadronKey] or nil
  if type(squadron) ~= "table" then
    fail("configured source squadron is not available key=" .. squadronKey)
  end
  return squadron
end

function Dispatcher:_RegisterPayload(airwing, profile)
  if self.registeredPayloadProfileIds[profile.id] then
    return
  end
  -- The template is the existing Mission Editor template, including its fixed
  -- loadout. NewPayload only makes that template operationally selectable.
  local missionTypes = { self.moose.AUFTRAG.Type.RECON }
  if profile.missionKind == "ORBIT_RACETRACK" then
    missionTypes[#missionTypes + 1] = self.moose.AUFTRAG.Type.ORBIT
  end
  airwing:NewPayload(profile.template, -1, missionTypes, profile.performance)
  self.registeredPayloadProfileIds[profile.id] = true
  log("PAYLOAD_REGISTERED profile=" .. profile.id .. " template=" .. profile.template)
end

function Dispatcher:_BuildMission(request, profile, squadron)
  local mission

  if profile.missionKind == "ORBIT_RACETRACK" then
    -- NewORBIT_RACETRACK enters Executing only at the orbit waypoint. Therefore
    -- SetDuration governs the approved on-station time, not outbound transit.
    mission = self.moose.AUFTRAG:NewORBIT_RACETRACK(
      request.coordinate,
      profile.reconAltitudeFeet,
      profile.reconSpeedKnots,
      profile.orbitHeadingDegrees,
      profile.orbitLegNm
    )
    mission.optionROE = self.moose.ENUMS.ROE.WeaponHold
  else
    local zone = self.moose.ZONE_RADIUS:New(
      "ISR_RECON_" .. request.id,
      request.coordinate:GetVec2(),
      profile.reconRadiusMeters
    )
    mission = self.moose.AUFTRAG:NewRECON(
      zone,
      profile.reconSpeedKnots,
      profile.reconAltitudeFeet,
      false,
      false
    )
  end

  requireFunction(mission.AssignSquadrons, "MOOSE AUFTRAG.AssignSquadrons")
  mission:AssignSquadrons({ squadron })
  mission:SetName("ISR " .. request.id .. " " .. profile.platformId)
  mission:SetTime(0)
  mission:SetDuration(profile.onStationSeconds)
  mission:SetTeleport(false)
  mission.OnAfterStarted = function(_, _, _, _, _, _)
    self.campaignAdapter:ConsumeAtPhysicalStart(request.id)
    log("MISSION_STARTED requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
    if self.onMissionStarted then self.onMissionStarted(request, mission) end
  end
  mission.OnAfterExecuting = function(_, _, _, _, _, _)
    log("MISSION_ON_STATION requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
    if self.onMissionExecuting then self.onMissionExecuting(request, mission) end
  end
  mission.OnAfterCancel = function(_, _, _, _, _, _)
    log("MISSION_RETURNING requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
    if self.onMissionCancelled then self.onMissionCancelled(request, mission) end
  end
  mission.OnAfterDone = function(_, _, _, _, _, _)
    log("MISSION_DONE requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
    if self.onMissionDone then self.onMissionDone(request, mission) end
  end
  return mission
end

function Dispatcher:Dispatch(request)
  requireTable(request, "request")
  if self.missionsByRequestId[request.id] then
    return nil, "REQUEST_ALREADY_DISPATCHED"
  end
  for _, profile in ipairs(self.profiles) do
    -- Validate the complete physical dispatch target before creating the
    -- CampaignState reservation, so a profile wiring error cannot strand one.
    local airwing = self:_Airwing(profile)
    local squadron = self:_Squadron(profile)
    local reservation, reason = self.campaignAdapter:Reserve(request.id, profile)
    if reservation then
      self:_RegisterPayload(airwing, profile)
      local mission = self:_BuildMission(request, profile, squadron)
      airwing:AddMission(mission)
      log("MISSION_QUEUED requestId=" .. request.id .. " mission=" .. mission.name
        .. " platform=" .. profile.platformId .. " airwing=" .. tostring(profile.airwingKey or "Main")
        .. " squadron=" .. profile.squadronKey)
      self.missionsByRequestId[request.id] = {
        profileId = profile.id,
        platformId = profile.platformId,
        transactionId = reservation.transactionId,
        mission = mission,
      }
      return self.missionsByRequestId[request.id]
    end
    if reason ~= "RESOURCE_UNAVAILABLE" then
      return nil, reason
    end
  end
  return nil, "NO_AVAILABLE_ISR_ASSET"
end

return Dispatcher
