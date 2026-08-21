-- Operation Mountain Watch - Ground execution request contract.
--
-- Domain contract only. This module contains no MOOSE or DCS calls and does
-- not execute missions. It validates the handoff from campaign tasking into a
-- later MOOSE-backed Ground execution adapter.

local GroundExecutionContract = {}

local TAG = "[OMW][Ground.ExecutionContract]"

GroundExecutionContract.SchemaVersion = "OMW-GROUND-EXECUTION-CONTRACT-1"

GroundExecutionContract.MissionType = {
  PATROL = "PATROL",
  ROAD_CONVOY = "ROAD_CONVOY",
  QRF = "QRF",
  OP_RELIEF = "OP_RELIEF",
}

local KNOWN_MISSION_TYPES = {}
for _, value in pairs(GroundExecutionContract.MissionType) do
  KNOWN_MISSION_TYPES[value] = true
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function copyMap(value, label)
  if value == nil then
    return nil
  end
  if type(value) ~= "table" then
    fail(label .. " must be table when provided")
  end
  local result = {}
  for key, item in pairs(value) do
    result[key] = item
  end
  return result
end

function GroundExecutionContract.Normalize(spec)
  if type(spec) ~= "table" then
    fail("execution spec must be table")
  end

  local missionType = requireString(spec.missionType, "missionType")
  if not KNOWN_MISSION_TYPES[missionType] then
    fail("unsupported missionType=" .. missionType)
  end

  local request = {
    executionId = requireString(spec.executionId, "executionId"),
    entityId = requireString(spec.entityId, "entityId"),
    missionDemandId = spec.missionDemandId,
    missionType = missionType,
    originNodeId = requireString(spec.originNodeId, "originNodeId"),
    objectiveId = requireString(spec.objectiveId, "objectiveId"),
    routeId = requireString(spec.routeId, "routeId"),
    brigadeId = requireString(spec.brigadeId, "brigadeId"),
    platoonId = requireString(spec.platoonId, "platoonId"),
    templateId = requireString(spec.templateId, "templateId"),
    settlement = copyMap(spec.settlement, "settlement"),
    metadata = copyMap(spec.metadata, "metadata"),
  }

  if request.missionDemandId ~= nil then
    requireString(request.missionDemandId, "missionDemandId")
  end

  return request
end

function GroundExecutionContract.ValidateRoute(request, routeCatalog)
  if type(request) ~= "table" then
    fail("normalized request table required")
  end
  if type(routeCatalog) ~= "table" or type(routeCatalog.Require) ~= "function"
      or type(routeCatalog.IsMissionAllowed) ~= "function" then
    fail("routeCatalog with Require/IsMissionAllowed is required")
  end

  local route = routeCatalog:Require(request.routeId)
  if route.originNodeId ~= request.originNodeId then
    fail(string.format(
      "route origin mismatch executionId=%s route=%s request=%s",
      tostring(request.executionId), tostring(route.originNodeId), tostring(request.originNodeId)
    ))
  end

  if not routeCatalog:IsMissionAllowed(request.routeId, request.missionType) then
    fail(string.format(
      "missionType not allowed on route executionId=%s routeId=%s missionType=%s",
      tostring(request.executionId), tostring(request.routeId), tostring(request.missionType)
    ))
  end

  return route
end

return GroundExecutionContract
