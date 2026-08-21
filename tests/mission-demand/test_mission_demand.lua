local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function assertTrue(value, label)
  if value ~= true then
    error(label .. " expected=true actual=" .. tostring(value))
  end
end

local function assertError(fn, label)
  local ok = pcall(fn)
  if ok then
    error(label .. " expected error")
  end
end

local function makeResupply(id, dedupeKey)
  return {
    id = id,
    missionType = MissionDemand.Type.RESUPPLY,
    origin = "GROUND_NODE_JOYCE",
    objective = "Resupply Honaker ammunition",
    target = {
      nodeId = "GROUND_NODE_HONAKER",
      resourceId = "GROUND:GROUND_NODE_HONAKER:AMMO",
    },
    priority = 50,
    playerCapable = true,
    aiCapable = true,
    reservationState = "UNRESERVED",
    successCriteria = { delivered = true },
    failureConsequences = { noCredit = true },
    createdReason = "RESOURCE_BELOW_REORDER",
    dedupeKey = dedupeKey,
  }
end

local registry = MissionDemand.New()
local spec = makeResupply("MD-RESUPPLY-001", "RESUPPLY|GROUND_NODE_HONAKER|AMMO")

local demand, created, reason = registry:Create(spec)
assertTrue(created, "initial create")
assertEqual(reason, nil, "initial create reason")
assertEqual(demand.status, MissionDemand.Status.OPEN, "initial status")

local same, insertedAgain, sameReason = registry:Create(spec)
assertEqual(insertedAgain, false, "idempotent create inserted")
assertEqual(sameReason, "idempotent_existing", "idempotent create reason")
assertEqual(same.id, spec.id, "idempotent create id")

local duplicate = makeResupply("MD-RESUPPLY-002", spec.dedupeKey)
local activeDuplicate, duplicateCreated, duplicateReason = registry:Create(duplicate)
assertEqual(duplicateCreated, false, "active duplicate inserted")
assertEqual(duplicateReason, "active_duplicate", "active duplicate reason")
assertEqual(activeDuplicate.id, spec.id, "active duplicate existing id")

local changedSpec = makeResupply(spec.id, spec.dedupeKey)
changedSpec.origin = nil
assertError(function()
  registry:Create(changedSpec)
end, "same id with changed nil-valued field")

local assigned, assignedChanged = registry:AssignAI(spec.id, "BLUE-COMMANDER")
assertTrue(assignedChanged, "AI assignment changed")
assertEqual(assigned.status, MissionDemand.Status.AI_ASSIGNED, "AI assignment status")

local assignedAgain, assignedAgainChanged = registry:AssignAI(spec.id, "BLUE-COMMANDER")
assertEqual(assignedAgainChanged, false, "same AI assignment idempotent")
assertEqual(assignedAgain.assignedTo, "BLUE-COMMANDER", "same AI assignment assignee")

assertError(function()
  registry:AssignPlayer(spec.id, "PLAYER-1")
end, "AI-assigned demand cannot also be player-assigned")

local active = registry:Activate(spec.id)
assertEqual(active.status, MissionDemand.Status.ACTIVE, "active status")

local succeeded, successChanged = registry:Succeed(spec.id, { delivered = true })
assertTrue(successChanged, "success transition changed")
assertEqual(succeeded.status, MissionDemand.Status.SUCCESS, "success status")
assertEqual(registry:GetActiveByDedupeKey(spec.dedupeKey), nil, "terminal dedupe released")

local successor = makeResupply("MD-RESUPPLY-003", spec.dedupeKey)
local successorDemand, successorCreated = registry:Create(successor)
assertTrue(successorCreated, "successor after terminal created")
assertEqual(successorDemand.id, successor.id, "successor id")

local snapshot = registry:ExportSnapshot()
local restored = MissionDemand.Restore(snapshot)
assertEqual(restored:Get(successor.id).status, MissionDemand.Status.OPEN, "restored successor status")
assertEqual(restored:GetActiveByDedupeKey(spec.dedupeKey).id, successor.id, "restored dedupe index")
assertEqual(restored:Get(spec.id).status, MissionDemand.Status.SUCCESS, "restored terminal status")

print("PASS test_mission_demand")
