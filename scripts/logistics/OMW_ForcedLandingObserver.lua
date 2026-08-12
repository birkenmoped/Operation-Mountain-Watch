-- Operation Mountain Watch - MOOSE-first forced landing observation adapter.
--
-- The observer is deliberately read-only. It does not mutate CampaignState,
-- STORAGE, AIRWING, WAREHOUSE or physical DCS objects. It observes tracked
-- FLIGHTGROUP lifecycle signals and tracked client GROUP signals and delegates
-- classification to the pure ForcedLandingRecoveryPolicy module.

local ForcedLandingObserver = {}
ForcedLandingObserver.__index = ForcedLandingObserver

local TAG = "[OMW][ForcedLandingObserver]"
local CLIENT_RETURN_PARKING_DISTANCE_METERS = 5

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireTable(value, label)
  if type(value) ~= "table" then
    fail(label .. " must be a table")
  end
  return value
end

local function nearestRecoveryNode(unit, recoveryNodes)
  local unitCoordinate = unit:GetCoordinate()
  local nearest = nil

  for _, node in ipairs(recoveryNodes) do
    local airbase = AIRBASE:FindByName(node.airbaseName)
    if airbase then
      local distance = unitCoordinate:Get2DDistance(airbase:GetCoordinate())
      if nearest == nil or distance < nearest.distanceMeters then
        nearest = {
          nodeId = node.nodeId,
          airbaseName = node.airbaseName,
          distanceMeters = distance,
          recoveryCapable = node.recoveryCapable == true,
        }
      end
    end
  end

  return nearest
end

local function missionType(flightGroup)
  local mission = flightGroup:GetMissionCurrent()
  return mission and mission.type or nil
end

local function isPlannedLanding(flightGroup)
  local currentMissionType = missionType(flightGroup)
  return flightGroup:IsLandingAt()
    or flightGroup:IsLandedAt()
    or flightGroup:IsPickingup()
    or flightGroup:IsTransporting()
    or currentMissionType == AUFTRAG.Type.LANDATCOORDINATE
end

local function getFuelFraction(unit)
  local fuel = unit:GetFuel()
  if type(fuel) ~= "number" then
    return nil
  end
  return fuel
end

local function isAtRecoveryParking(unit, recoveryNodes)
  local unitCoordinate = unit:GetCoordinate()

  for _, node in ipairs(recoveryNodes) do
    if node.recoveryCapable == true then
      local airbase = AIRBASE:FindByName(node.airbaseName)
      if airbase then
        local parkingSpots = airbase:GetParkingSpotsTable() or {}
        for _, parkingSpot in pairs(parkingSpots) do
          if parkingSpot.Coordinate then
            local distance = unitCoordinate:Get2DDistance(parkingSpot.Coordinate)
            if distance <= CLIENT_RETURN_PARKING_DISTANCE_METERS then
              return true, node, parkingSpot, distance
            end
          end
        end
      end
    end
  end

  return false, nil, nil, nil
end

function ForcedLandingObserver.New(policy, config)
  requireTable(policy, "policy")
  config = requireTable(config, "config")
  requireTable(config.recoveryNodes, "config.recoveryNodes")

  local self = setmetatable({
    policy = policy,
    recoveryNodes = config.recoveryNodes,
    trackedByGroupName = {},
    observations = {},
    handler = EVENTHANDLER:New(),
  }, ForcedLandingObserver)

  self.handler:HandleEvent(EVENTS.Land)
  self.handler:HandleEvent(EVENTS.EngineShutdown)

  function self.handler:OnEventLand(eventData)
    self._owner:_OnLand(eventData)
  end

  function self.handler:OnEventEngineShutdown(eventData)
    self._owner:_OnEngineShutdown(eventData)
  end

  self.handler._owner = self
  return self
end

function ForcedLandingObserver:TrackFlight(flightGroup, metadata)
  if type(flightGroup) ~= "table" or type(flightGroup.GetGroup) ~= "function" then
    fail("TrackFlight requires FLIGHTGROUP")
  end

  local group = flightGroup:GetGroup()
  if not group then
    fail("tracked FLIGHTGROUP has no GROUP")
  end

  local groupName = group:GetName()
  self.trackedByGroupName[groupName] = {
    mode = "FLIGHTGROUP",
    flightGroup = flightGroup,
    group = group,
    metadata = metadata or {},
    landed = false,
  }

  return groupName
end

function ForcedLandingObserver:TrackClientGroup(group, metadata)
  if type(group) ~= "table" or type(group.GetName) ~= "function" then
    fail("TrackClientGroup requires MOOSE GROUP")
  end

  local groupName = group:GetName()
  self.trackedByGroupName[groupName] = {
    mode = "CLIENT_GROUP",
    group = group,
    metadata = metadata or {},
    landed = false,
  }

  return groupName
end

function ForcedLandingObserver:UntrackFlight(flightGroup)
  if type(flightGroup) ~= "table" or type(flightGroup.GetGroup) ~= "function" then
    return false
  end
  local group = flightGroup:GetGroup()
  if not group then
    return false
  end
  local groupName = group:GetName()
  local existed = self.trackedByGroupName[groupName] ~= nil
  self.trackedByGroupName[groupName] = nil
  return existed
end

function ForcedLandingObserver:UntrackGroup(group)
  if type(group) ~= "table" or type(group.GetName) ~= "function" then
    return false
  end
  local groupName = group:GetName()
  local existed = self.trackedByGroupName[groupName] ~= nil
  self.trackedByGroupName[groupName] = nil
  return existed
end

function ForcedLandingObserver:_GetTracked(eventData)
  if not eventData or not eventData.IniGroupName then
    return nil
  end
  return self.trackedByGroupName[eventData.IniGroupName]
end

function ForcedLandingObserver:_ResolveLandingSemantics(tracked, unit)
  if tracked.mode == "FLIGHTGROUP" then
    return isPlannedLanding(tracked.flightGroup), tracked.flightGroup:IsArrived(), missionType(tracked.flightGroup), nil
  end

  if tracked.mode == "CLIENT_GROUP" then
    local expectedReturn, node, parkingSpot, parkingDistance = isAtRecoveryParking(unit, self.recoveryNodes)
    return false, expectedReturn, nil, {
      returnNodeId = node and node.nodeId or nil,
      returnAirbaseName = node and node.airbaseName or nil,
      returnParkingTerminalId = parkingSpot and (parkingSpot.TerminalID or parkingSpot.Term_Index) or nil,
      returnParkingDistanceMeters = parkingDistance,
    }
  end

  fail("unknown tracking mode=" .. tostring(tracked.mode))
end

function ForcedLandingObserver:_OnLand(eventData)
  local tracked = self:_GetTracked(eventData)
  if not tracked or not eventData.IniUnit then
    return
  end

  tracked.landed = true
  tracked.landPlaceName = eventData.PlaceName
  tracked.landFuelFraction = getFuelFraction(eventData.IniUnit)

  local plannedLanding, expectedReturn, currentMissionType, clientReturn = self:_ResolveLandingSemantics(tracked, eventData.IniUnit)
  tracked.landMissionType = currentMissionType
  tracked.clientReturn = clientReturn

  env.info(string.format(
    "%s LAND_CANDIDATE mode=%s group=%s unit=%s place=%s planned=%s expectedReturn=%s returnParkingDistanceM=%s fuelFraction=%s",
    TAG,
    tostring(tracked.mode),
    tostring(eventData.IniGroupName),
    tostring(eventData.IniUnitName),
    tostring(eventData.PlaceName),
    tostring(plannedLanding),
    tostring(expectedReturn),
    tostring(clientReturn and clientReturn.returnParkingDistanceMeters or nil),
    tostring(tracked.landFuelFraction)
  ))
end

function ForcedLandingObserver:_OnEngineShutdown(eventData)
  local tracked = self:_GetTracked(eventData)
  if not tracked or not tracked.landed or not eventData.IniUnit then
    return
  end

  if not eventData.IniUnit:IsAlive() or eventData.IniUnit:InAir() then
    return
  end

  local plannedLanding, expectedReturn, currentMissionType, clientReturn = self:_ResolveLandingSemantics(tracked, eventData.IniUnit)
  local nearest = nearestRecoveryNode(eventData.IniUnit, self.recoveryNodes)
  local distance = nearest and nearest.distanceMeters or math.huge
  local recoveryCapable = nearest and nearest.recoveryCapable or false

  local context = {
    plannedLanding = plannedLanding,
    expectedReturn = expectedReturn,
    unexpectedLandingEvidence = not plannedLanding and not expectedReturn,
    recoveryCapable = recoveryCapable,
    distanceToRecoveryMeters = distance,
    fuelFraction = getFuelFraction(eventData.IniUnit),
  }

  local classification = self.policy.ClassifyLanding(context)
  local observation = {
    trackingMode = tracked.mode,
    groupName = eventData.IniGroupName,
    unitName = eventData.IniUnitName,
    placeName = eventData.PlaceName or tracked.landPlaceName,
    missionType = currentMissionType,
    plannedLanding = plannedLanding,
    expectedReturn = expectedReturn,
    lowFuelSignal = self.policy.IsLowFuelSignal(context.fuelFraction),
    fuelFraction = context.fuelFraction,
    nearestRecoveryNodeId = nearest and nearest.nodeId or nil,
    nearestRecoveryAirbaseName = nearest and nearest.airbaseName or nil,
    distanceToRecoveryMeters = nearest and nearest.distanceMeters or nil,
    recoveryCapable = recoveryCapable,
    returnNodeId = clientReturn and clientReturn.returnNodeId or nil,
    returnAirbaseName = clientReturn and clientReturn.returnAirbaseName or nil,
    returnParkingTerminalId = clientReturn and clientReturn.returnParkingTerminalId or nil,
    returnParkingDistanceMeters = clientReturn and clientReturn.returnParkingDistanceMeters or nil,
    classification = classification,
    metadata = tracked.metadata,
  }

  self.observations[#self.observations + 1] = observation

  env.info(string.format(
    "%s CLASSIFIED mode=%s group=%s unit=%s classification=%s planned=%s expectedReturn=%s lowFuel=%s recoveryNode=%s distanceM=%s returnParkingDistanceM=%s",
    TAG,
    tostring(observation.trackingMode),
    tostring(observation.groupName),
    tostring(observation.unitName),
    tostring(observation.classification),
    tostring(observation.plannedLanding),
    tostring(observation.expectedReturn),
    tostring(observation.lowFuelSignal),
    tostring(observation.nearestRecoveryNodeId),
    tostring(observation.distanceToRecoveryMeters),
    tostring(observation.returnParkingDistanceMeters)
  ))
end

function ForcedLandingObserver:GetObservations()
  local result = {}
  for index, observation in ipairs(self.observations) do
    local copy = {}
    for key, value in pairs(observation) do
      copy[key] = value
    end
    result[index] = copy
  end
  return result
end

function ForcedLandingObserver:Stop()
  if self.handler then
    self.handler:UnHandleEvent(EVENTS.Land)
    self.handler:UnHandleEvent(EVENTS.EngineShutdown)
  end
end

return ForcedLandingObserver
