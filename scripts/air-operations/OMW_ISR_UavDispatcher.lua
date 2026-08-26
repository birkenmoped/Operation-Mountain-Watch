-- Operation Mountain Watch - MOOSE-only player ISR UAV dispatch adapter.
--
-- This adapter selects a preconfigured ISR Cell profile, reserves exactly one
-- CampaignState aircraft, registers the existing Mission Editor payload with
-- AIRWING and submits AUFTRAG:NewRECON. It intentionally contains no native
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

function Dispatcher.New(config)
  config = requireTable(config, "config")
  local moose = config.moose or _G
  requireTable(moose.ZONE_RADIUS, "MOOSE ZONE_RADIUS")
  requireTable(moose.AUFTRAG, "MOOSE AUFTRAG")
  if type(config.campaignAdapter) ~= "table" then
    fail("config.campaignAdapter is required")
  end
  requireFunction(config.campaignAdapter.Reserve, "campaignAdapter.Reserve")
  requireFunction(config.campaignAdapter.ConsumeAtPhysicalStart, "campaignAdapter.ConsumeAtPhysicalStart")

  return setmetatable({
    moose = moose,
    campaignAdapter = config.campaignAdapter,
    kandahar = requireTable(config.kandahar, "config.kandahar"),
    profiles = requireTable(config.profiles, "config.profiles"),
    registeredPayloadProfileIds = {},
    missionsByRequestId = {},
  }, Dispatcher)
end

function Dispatcher:_Airwing()
  local airwing = self.kandahar.Airwings and self.kandahar.Airwings.Main or nil
  if not airwing or type(airwing.NewPayload) ~= "function" or type(airwing.AddMission) ~= "function" then
    fail("Kandahar main AIRWING is not available")
  end
  return airwing
end

function Dispatcher:_RegisterPayload(airwing, profile)
  if self.registeredPayloadProfileIds[profile.id] then
    return
  end
  -- The template is the existing Mission Editor template, including its fixed
  -- loadout. NewPayload only makes that template operationally selectable.
  airwing:NewPayload(profile.template, -1, { self.moose.AUFTRAG.Type.RECON }, profile.performance)
  self.registeredPayloadProfileIds[profile.id] = true
  log("PAYLOAD_REGISTERED profile=" .. profile.id .. " template=" .. profile.template)
end

function Dispatcher:_BuildMission(request, profile)
  local zone = self.moose.ZONE_RADIUS:New(
    "ISR_RECON_" .. request.id,
    request.coordinate:GetVec2(),
    profile.reconRadiusMeters
  )
  local mission = self.moose.AUFTRAG:NewRECON(
    zone,
    profile.reconSpeedKnots,
    profile.reconAltitudeFeet,
    false,
    false
  )
  mission:SetName("ISR " .. request.id .. " " .. profile.platformId)
  mission:SetTime(0)
  mission:SetDuration(profile.onStationSeconds)
  mission:SetTeleport(false)
  mission.OnAfterStarted = function(_, _, _, _, _, _)
    self.campaignAdapter:ConsumeAtPhysicalStart(request.id)
    log("MISSION_STARTED requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
  end
  return mission
end

function Dispatcher:Dispatch(request)
  requireTable(request, "request")
  if self.missionsByRequestId[request.id] then
    return nil, "REQUEST_ALREADY_DISPATCHED"
  end
  local airwing = self:_Airwing()

  for _, profile in ipairs(self.profiles) do
    local reservation, reason = self.campaignAdapter:Reserve(request.id, profile)
    if reservation then
      self:_RegisterPayload(airwing, profile)
      local mission = self:_BuildMission(request, profile)
      airwing:AddMission(mission)
      log("MISSION_QUEUED requestId=" .. request.id .. " mission=" .. mission.name .. " platform=" .. profile.platformId)
      self.missionsByRequestId[request.id] = {        profileId = profile.id,
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
