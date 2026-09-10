-- Operation Mountain Watch - MissionDemand domain registry.
--
-- Campaign-domain only. This module has no MOOSE or DCS dependency and owns no
-- strategic resources. Resource reservations remain owned by CampaignState;
-- MOOSE remains the operational mission execution framework.

local MissionDemand = {}

local Registry = {}
Registry.__index = Registry

local TAG = "[OMW][MissionDemand]"

MissionDemand.SchemaVersion = "OMW-MISSION-DEMAND-1"
MissionDemand.SnapshotVersion = "OMW-MISSION-DEMAND-SNAPSHOT-1"

MissionDemand.Type = {
  RESUPPLY = "RESUPPLY",
  CAS_IMMEDIATE = "CAS_IMMEDIATE",
  FIRE_SUPPORT_IMMEDIATE = "FIRE_SUPPORT_IMMEDIATE",
}

MissionDemand.Status = {
  OPEN = "OPEN",
  PLAYER_ASSIGNED = "PLAYER_ASSIGNED",
  AI_ASSIGNED = "AI_ASSIGNED",
  ACTIVE = "ACTIVE",
  SUCCESS = "SUCCESS",
  FAILED = "FAILED",
  EXPIRED = "EXPIRED",
}

local TERMINAL = {
  [MissionDemand.Status.SUCCESS] = true,
  [MissionDemand.Status.FAILED] = true,
  [MissionDemand.Status.EXPIRED] = true,
}

local ALLOWED_TRANSITIONS = {
  [MissionDemand.Status.OPEN] = {
    [MissionDemand.Status.PLAYER_ASSIGNED] = true,
    [MissionDemand.Status.AI_ASSIGNED] = true,
    [MissionDemand.Status.EXPIRED] = true,
  },
  [MissionDemand.Status.PLAYER_ASSIGNED] = {
    [MissionDemand.Status.ACTIVE] = true,
    [MissionDemand.Status.FAILED] = true,
    [MissionDemand.Status.EXPIRED] = true,
  },
  [MissionDemand.Status.AI_ASSIGNED] = {
    [MissionDemand.Status.ACTIVE] = true,
    [MissionDemand.Status.FAILED] = true,
    [MissionDemand.Status.EXPIRED] = true,
  },
  [MissionDemand.Status.ACTIVE] = {
    [MissionDemand.Status.SUCCESS] = true,
    [MissionDemand.Status.FAILED] = true,
  },
}

local CREATION_FIELDS = {
  "id",
  "missionType",
  "origin",
  "objective",
  "target",
  "priority",
  "playerCapable",
  "aiCapable",
  "reservationState",
  "expiresAt",
  "successCriteria",
  "failureConsequences",
  "resourceReservation",
  "createdReason",
  "dedupeKey",
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function isFinite(value)
  return type(value) == "number"
    and value == value
    and value > -math.huge
    and value < math.huge
end

local function deepCopy(value, seen)
  if type(value) ~= "table" then
    return value
  end

  seen = seen or {}
  if seen[value] then
    fail("cyclic tables are not supported in MissionDemand data")
  end

  seen[value] = true
  local result = {}
  for key, item in pairs(value) do
    result[deepCopy(key, seen)] = deepCopy(item, seen)
  end
  seen[value] = nil
  return result
end

local function valuesEqual(a, b, seen)
  if type(a) ~= type(b) then
    return false
  end
  if type(a) ~= "table" then
    return a == b
  end

  seen = seen or {}
  seen[a] = seen[a] or {}
  if seen[a][b] then
    return true
  end
  seen[a][b] = true

  for key, value in pairs(a) do
    if not valuesEqual(value, b[key], seen) then
      return false
    end
  end
  for key in pairs(b) do
    if a[key] == nil then
      return false
    end
  end
  return true
end

local function copyDemand(demand)
  return demand and deepCopy(demand) or nil
end

local function sortedKeys(map)
  local keys = {}
  for key in pairs(map) do
    keys[#keys + 1] = key
  end
  table.sort(keys)
  return keys
end

local function validateBoolean(value, label)
  if value ~= nil and type(value) ~= "boolean" then
    fail(label .. " must be boolean when provided")
  end
end

local function isTerminalStatus(status)
  return TERMINAL[status] == true
end

local function isKnownStatus(status)
  return status == MissionDemand.Status.OPEN
    or status == MissionDemand.Status.PLAYER_ASSIGNED
    or status == MissionDemand.Status.AI_ASSIGNED
    or status == MissionDemand.Status.ACTIVE
    or isTerminalStatus(status)
end

local function validateDemandSpec(spec)
  if type(spec) ~= "table" then
    fail("demand spec must be a table")
  end

  requireNonEmptyString(spec.id, "id")
  requireNonEmptyString(spec.missionType, "missionType")
  requireNonEmptyString(spec.objective, "objective")
  requireNonEmptyString(spec.dedupeKey, "dedupeKey")

  if not isFinite(spec.priority) then
    fail("priority must be a finite number")
  end

  validateBoolean(spec.playerCapable, "playerCapable")
  validateBoolean(spec.aiCapable, "aiCapable")

  if spec.playerCapable ~= true and spec.aiCapable ~= true then
    fail("demand must be playerCapable and/or aiCapable")
  end

  if spec.expiresAt ~= nil and (not isFinite(spec.expiresAt) or spec.expiresAt < 0) then
    fail("expiresAt must be a non-negative finite number when provided")
  end
end

local function normalizeCreationSpec(spec)
  return {
    id = spec.id,
    missionType = spec.missionType,
    origin = spec.origin,
    objective = spec.objective,
    target = deepCopy(spec.target),
    priority = spec.priority,
    playerCapable = spec.playerCapable == true,
    aiCapable = spec.aiCapable == true,
    reservationState = spec.reservationState,
    expiresAt = spec.expiresAt,
    successCriteria = deepCopy(spec.successCriteria),
    failureConsequences = deepCopy(spec.failureConsequences),
    resourceReservation = deepCopy(spec.resourceReservation),
    createdReason = spec.createdReason,
    dedupeKey = spec.dedupeKey,
  }
end

local function creationSpecMatches(demand, spec)
  local normalized = normalizeCreationSpec(spec)
  for _, field in ipairs(CREATION_FIELDS) do
    if not valuesEqual(demand[field], normalized[field]) then
      return false
    end
  end
  return true
end

local function validateRestoredDemand(demand)
  validateDemandSpec(demand)

  local status = demand.status or MissionDemand.Status.OPEN
  if not isKnownStatus(status) then
    fail("unsupported restored status=" .. tostring(status))
  end

  if status == MissionDemand.Status.PLAYER_ASSIGNED
      or status == MissionDemand.Status.AI_ASSIGNED
      or status == MissionDemand.Status.ACTIVE then
    requireNonEmptyString(demand.assignedTo, "assignedTo")
  end

  return status
end

function MissionDemand.IsTerminalStatus(status)
  return isTerminalStatus(status)
end

function MissionDemand.New()
  return setmetatable({
    schemaVersion = MissionDemand.SchemaVersion,
    demandsById = {},
    activeByDedupeKey = {},
  }, Registry)
end

function MissionDemand.Restore(snapshot)
  if type(snapshot) ~= "table" then
    fail("snapshot must be a table")
  end
  if snapshot.snapshotVersion ~= MissionDemand.SnapshotVersion then
    fail("unsupported snapshotVersion=" .. tostring(snapshot.snapshotVersion))
  end

  local registry = MissionDemand.New()
  registry.schemaVersion = snapshot.schemaVersion or MissionDemand.SchemaVersion

  for _, source in ipairs(snapshot.demands or {}) do
    local status = validateRestoredDemand(source)

    if registry.demandsById[source.id] then
      fail("duplicate restored demand id=" .. tostring(source.id))
    end

    local demand = copyDemand(source)
    demand.status = status
    registry.demandsById[demand.id] = demand

    if not isTerminalStatus(status) then
      local existingId = registry.activeByDedupeKey[demand.dedupeKey]
      if existingId and existingId ~= demand.id then
        fail("duplicate active dedupeKey=" .. tostring(demand.dedupeKey))
      end
      registry.activeByDedupeKey[demand.dedupeKey] = demand.id
    end
  end

  return registry
end

function Registry:Create(spec)
  validateDemandSpec(spec)

  local existing = self.demandsById[spec.id]
  if existing then
    if creationSpecMatches(existing, spec) then
      return copyDemand(existing), false, "idempotent_existing"
    end
    fail("demand id already exists with different specification id=" .. tostring(spec.id))
  end

  local duplicateId = self.activeByDedupeKey[spec.dedupeKey]
  if duplicateId then
    return copyDemand(self.demandsById[duplicateId]), false, "active_duplicate"
  end

  local creation = normalizeCreationSpec(spec)
  local demand = {
    id = creation.id,
    missionType = creation.missionType,
    origin = creation.origin,
    objective = creation.objective,
    target = creation.target,
    priority = creation.priority,
    playerCapable = creation.playerCapable,
    aiCapable = creation.aiCapable,
    reservationState = creation.reservationState,
    expiresAt = creation.expiresAt,
    successCriteria = creation.successCriteria,
    failureConsequences = creation.failureConsequences,
    resourceReservation = creation.resourceReservation,
    status = MissionDemand.Status.OPEN,
    createdReason = creation.createdReason,
    dedupeKey = creation.dedupeKey,
    assignedTo = nil,
    result = nil,
    failureReason = nil,
  }

  self.demandsById[demand.id] = demand
  self.activeByDedupeKey[demand.dedupeKey] = demand.id

  return copyDemand(demand), true, nil
end

function Registry:Get(id)
  requireNonEmptyString(id, "id")
  return copyDemand(self.demandsById[id])
end

function Registry:GetActiveByDedupeKey(dedupeKey)
  requireNonEmptyString(dedupeKey, "dedupeKey")
  local id = self.activeByDedupeKey[dedupeKey]
  return id and copyDemand(self.demandsById[id]) or nil
end

local function getDemandOrFail(registry, id)
  requireNonEmptyString(id, "id")
  local demand = registry.demandsById[id]
  if not demand then
    fail("unknown demand id=" .. tostring(id))
  end
  return demand
end

local function transition(registry, demand, toStatus)
  if demand.status == toStatus then
    return false
  end

  local allowed = ALLOWED_TRANSITIONS[demand.status]
  if not allowed or allowed[toStatus] ~= true then
    fail(string.format(
      "invalid status transition id=%s from=%s to=%s",
      tostring(demand.id),
      tostring(demand.status),
      tostring(toStatus)
    ))
  end

  demand.status = toStatus

  if isTerminalStatus(toStatus)
      and registry.activeByDedupeKey[demand.dedupeKey] == demand.id then
    registry.activeByDedupeKey[demand.dedupeKey] = nil
  end

  return true
end

local function assign(registry, demand, targetStatus, assigneeId)
  requireNonEmptyString(assigneeId, "assigneeId")

  if demand.status == targetStatus then
    if demand.assignedTo == assigneeId then
      return copyDemand(demand), false
    end
    fail(string.format(
      "demand already assigned to different assignee id=%s current=%s requested=%s",
      tostring(demand.id),
      tostring(demand.assignedTo),
      tostring(assigneeId)
    ))
  end

  transition(registry, demand, targetStatus)
  demand.assignedTo = assigneeId
  return copyDemand(demand), true
end

function Registry:AssignPlayer(id, assigneeId)
  local demand = getDemandOrFail(self, id)
  if demand.playerCapable ~= true then
    fail("demand is not player capable id=" .. tostring(id))
  end
  return assign(self, demand, MissionDemand.Status.PLAYER_ASSIGNED, assigneeId)
end

function Registry:AssignAI(id, assigneeId)
  local demand = getDemandOrFail(self, id)
  if demand.aiCapable ~= true then
    fail("demand is not AI capable id=" .. tostring(id))
  end
  return assign(self, demand, MissionDemand.Status.AI_ASSIGNED, assigneeId)
end

function Registry:Activate(id)
  local demand = getDemandOrFail(self, id)
  local changed = transition(self, demand, MissionDemand.Status.ACTIVE)
  return copyDemand(demand), changed
end

function Registry:Succeed(id, result)
  local demand = getDemandOrFail(self, id)
  if demand.status == MissionDemand.Status.SUCCESS then
    return copyDemand(demand), false
  end

  transition(self, demand, MissionDemand.Status.SUCCESS)
  demand.result = deepCopy(result)
  return copyDemand(demand), true
end

function Registry:Fail(id, reason)
  local demand = getDemandOrFail(self, id)
  if demand.status == MissionDemand.Status.FAILED then
    return copyDemand(demand), false
  end

  transition(self, demand, MissionDemand.Status.FAILED)
  demand.failureReason = reason
  return copyDemand(demand), true
end

function Registry:Expire(id, reason)
  local demand = getDemandOrFail(self, id)
  if demand.status == MissionDemand.Status.EXPIRED then
    return copyDemand(demand), false
  end

  transition(self, demand, MissionDemand.Status.EXPIRED)
  demand.failureReason = reason
  return copyDemand(demand), true
end

function Registry:SetReservationState(id, reservationState, resourceReservation)
  local demand = getDemandOrFail(self, id)
  if isTerminalStatus(demand.status) then
    fail("cannot mutate reservation on terminal demand id=" .. tostring(id))
  end

  local nextReservation = resourceReservation ~= nil
    and deepCopy(resourceReservation)
    or demand.resourceReservation

  if demand.reservationState == reservationState
      and valuesEqual(demand.resourceReservation, nextReservation) then
    return copyDemand(demand), false
  end

  demand.reservationState = reservationState
  demand.resourceReservation = nextReservation
  return copyDemand(demand), true
end

function Registry:SetPriority(id, priority)
  local demand = getDemandOrFail(self, id)
  if isTerminalStatus(demand.status) then
    fail("cannot change priority on terminal demand id=" .. tostring(id))
  end
  if not isFinite(priority) then
    fail("priority must be a finite number")
  end
  if demand.priority == priority then
    return copyDemand(demand), false
  end
  demand.priority = priority
  return copyDemand(demand), true
end

function Registry:ListActive()
  local result = {}
  for _, id in ipairs(sortedKeys(self.demandsById)) do
    local demand = self.demandsById[id]
    if not isTerminalStatus(demand.status) then
      result[#result + 1] = copyDemand(demand)
    end
  end
  return result
end

function Registry:ExportSnapshot()
  local demands = {}
  for _, id in ipairs(sortedKeys(self.demandsById)) do
    demands[#demands + 1] = copyDemand(self.demandsById[id])
  end

  return {
    snapshotVersion = MissionDemand.SnapshotVersion,
    schemaVersion = self.schemaVersion,
    demands = demands,
  }
end

return MissionDemand
