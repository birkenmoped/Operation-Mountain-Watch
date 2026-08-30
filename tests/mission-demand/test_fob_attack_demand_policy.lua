local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Policy = dofile("scripts/campaign/OMW_FobAttackDemandPolicy.lua")

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

local function incident(id, installationId, priority)
  return {
    incidentId = id,
    installationId = installationId,
    priority = priority,
    position = { x = 100, y = 200 },
    reportedTarget = { groupName = "TEST_RED_GROUP" },
  }
end

local registry = MissionDemand.New()
local first = incident("INC-FORTRESS-001", "BLUE_GROUND_COP_FORTRESS", 90)
local demand, created, reason = Policy.CreateDemand(MissionDemand, registry, first)

assertTrue(created, "first qualified attack creates demand")
assertEqual(reason, nil, "first create reason")
assertEqual(demand.missionType, MissionDemand.Type.CAS_IMMEDIATE, "CAS demand type")
assertEqual(demand.origin, first.installationId, "installation origin")
assertEqual(demand.target.installationId, first.installationId, "target installation")
assertEqual(demand.target.incidentId, first.incidentId, "target incident")
assertEqual(demand.priority, 90, "incident priority preserved")
assertEqual(demand.playerCapable, true, "player capable")
assertEqual(demand.aiCapable, true, "AI capable")
assertEqual(demand.createdReason, Policy.CreatedReason, "created reason")
assertEqual(demand.dedupeKey, "CAS_IMMEDIATE|FOB_ATTACK|BLUE_GROUND_COP_FORTRESS", "site dedupe key")

local same, sameCreated, sameReason = Policy.CreateDemand(MissionDemand, registry, first)
assertEqual(sameCreated, false, "same incident idempotent")
assertEqual(sameReason, "idempotent_existing", "same incident reason")
assertEqual(same.id, demand.id, "same incident demand id")

local repeatedHitIncident = incident("INC-FORTRESS-002", "BLUE_GROUND_COP_FORTRESS", 95)
local duplicate, duplicateCreated, duplicateReason = Policy.CreateDemand(MissionDemand, registry, repeatedHitIncident)
assertEqual(duplicateCreated, false, "second incident while active is deduped")
assertEqual(duplicateReason, "active_duplicate", "active site duplicate reason")
assertEqual(duplicate.id, demand.id, "active site duplicate retains first demand")

local otherSite = incident("INC-BOSTICK-001", "BLUE_GROUND_FOB_BOSTICK", 80)
local otherDemand, otherCreated = Policy.CreateDemand(MissionDemand, registry, otherSite)
assertTrue(otherCreated, "different installation may create concurrent demand")
assertEqual(otherDemand.dedupeKey, "CAS_IMMEDIATE|FOB_ATTACK|BLUE_GROUND_FOB_BOSTICK", "other site dedupe")

registry:AssignAI(demand.id, "BLUE-COMMANDER")
registry:Activate(demand.id)
registry:Succeed(demand.id, { incidentResolved = true })

local successor, successorCreated, successorReason = Policy.CreateDemand(MissionDemand, registry, repeatedHitIncident)
assertTrue(successorCreated, "new incident after terminal demand creates successor")
assertEqual(successorReason, nil, "successor create reason")
assertEqual(successor.id, "MD-CAS-FOB-ATTACK|INC-FORTRESS-002", "successor incident id")

assertError(function()
  Policy.CreateDemand(MissionDemand, registry, {
    incidentId = "INC-BAD-001",
    installationId = "BLUE_GROUND_FOB_WRIGHT",
  })
end, "missing priority rejected")

assertError(function()
  Policy.CreateDemand(MissionDemand, registry, {
    incidentId = "",
    installationId = "BLUE_GROUND_FOB_WRIGHT",
    priority = 50,
  })
end, "empty incident ID rejected")

print("PASS test_fob_attack_demand_policy")
