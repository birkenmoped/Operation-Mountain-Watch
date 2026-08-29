local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Policy = dofile("scripts/campaign/OMW_FobAttackDemandPolicy.lua")
local HitAdapter = dofile("scripts/ground/OMW_FobAttackHitAdapter.lua")

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

local function assertFalse(value, label)
  if value ~= false then
    error(label .. " expected=false actual=" .. tostring(value))
  end
end

local function assertNil(value, label)
  if value ~= nil then
    error(label .. " expected=nil actual=" .. tostring(value))
  end
end

local function makeEvent(time, overrides)
  local event = {
    time = time,
    IniCoalition = 1,
    TgtCoalition = 2,
    IniUnitName = "RED_ATTACKER_1",
    IniGroupName = "RED_ATTACKER_GROUP",
    TgtUnitName = "BLUE_FORTRESS_TARGET_1",
    TgtGroupName = "BLUE_FORTRESS_TARGET_GROUP",
    WeaponName = "TEST_WEAPON",
  }
  for key, value in pairs(overrides or {}) do
    event[key] = value
  end
  return event
end

local registry = MissionDemand.New()
local sequence = 0
local fakeListener = {
  handleEventId = nil,
  handleFunction = nil,
  unhandledEventId = nil,
}

function fakeListener:HandleEvent(eventId, callback)
  self.handleEventId = eventId
  self.handleFunction = callback
  return self
end

function fakeListener:UnHandleEvent(eventId)
  self.unhandledEventId = eventId
  return self
end

function fakeListener:I(_)
  return self
end

local adapter = HitAdapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  policy = Policy,
  blueCoalition = 2,
  redCoalition = 1,
  eventsHit = 17,
  eventBaseFactory = function()
    return fakeListener
  end,
  incidentIdFactory = function(eventData, registration)
    sequence = sequence + 1
    return string.format(
      "INC-HIT|%s|%s|%d",
      registration.installationId,
      tostring(eventData.time),
      sequence
    )
  end,
  positionResolver = function(eventData)
    return {
      x = eventData.testX,
      y = eventData.testY,
      z = eventData.testZ,
    }
  end,
  targetGroups = {
    BLUE_FORTRESS_TARGET_GROUP = {
      installationId = "BLUE_GROUND_COP_FORTRESS",
      priority = 90,
    },
  },
  targetUnits = {
    BLUE_BOSTICK_STATIC = {
      installationId = "BLUE_GROUND_FOB_BOSTICK",
      priority = 80,
    },
  },
})

local demand, created, reason = adapter:ProcessHitEvent(makeEvent(100.25, {
  testX = 1000,
  testY = 2000,
  testZ = 3000,
}))
assertTrue(created, "registered red-on-blue hit creates demand")
assertEqual(reason, nil, "first hit create reason")
assertEqual(demand.missionType, MissionDemand.Type.CAS_IMMEDIATE, "first hit demand type")
assertEqual(demand.origin, "BLUE_GROUND_COP_FORTRESS", "first hit installation")
assertEqual(demand.priority, 90, "first hit priority")
assertEqual(demand.target.position.x, 1000, "first hit position x")
assertEqual(demand.target.reportedTarget.targetKind, "GROUP", "group registration selected")
assertEqual(demand.target.reportedTarget.targetName, "BLUE_FORTRESS_TARGET_GROUP", "group target name")
assertEqual(demand.target.reportedTarget.initiatorGroupName, "RED_ATTACKER_GROUP", "initiator group preserved")

local duplicate, duplicateCreated, duplicateReason = adapter:ProcessHitEvent(makeEvent(101.50))
assertFalse(duplicateCreated, "repeated hit same installation does not create second active demand")
assertEqual(duplicateReason, "active_duplicate", "repeated hit uses MissionDemand active dedupe")
assertEqual(duplicate.id, demand.id, "repeated hit returns active demand")

local ignoredFriendly, ignoredFriendlyCreated, ignoredFriendlyReason = adapter:ProcessHitEvent(makeEvent(102, {
  IniCoalition = 2,
}))
assertNil(ignoredFriendly, "blue initiator ignored")
assertFalse(ignoredFriendlyCreated, "blue initiator not created")
assertEqual(ignoredFriendlyReason, "INITIATOR_NOT_RED", "blue initiator reason")

local ignoredWrongTarget, ignoredWrongTargetCreated, ignoredWrongTargetReason = adapter:ProcessHitEvent(makeEvent(103, {
  TgtCoalition = 1,
}))
assertNil(ignoredWrongTarget, "red target ignored")
assertFalse(ignoredWrongTargetCreated, "red target not created")
assertEqual(ignoredWrongTargetReason, "TARGET_NOT_BLUE", "red target reason")

local ignoredUnregistered, ignoredUnregisteredCreated, ignoredUnregisteredReason = adapter:ProcessHitEvent(makeEvent(104, {
  TgtGroupName = "BLUE_OTHER_GROUP",
  TgtUnitName = "BLUE_OTHER_UNIT",
}))
assertNil(ignoredUnregistered, "unregistered blue target ignored")
assertFalse(ignoredUnregisteredCreated, "unregistered blue target not created")
assertEqual(ignoredUnregisteredReason, "TARGET_NOT_REGISTERED", "unregistered target reason")

local bostick, bostickCreated, bostickReason = adapter:ProcessHitEvent(makeEvent(105, {
  TgtGroupName = "",
  TgtUnitName = "BLUE_BOSTICK_STATIC",
}))
assertTrue(bostickCreated, "registered unit/static target creates separate site demand")
assertEqual(bostickReason, nil, "unit/static target create reason")
assertEqual(bostick.origin, "BLUE_GROUND_FOB_BOSTICK", "unit/static target installation")
assertEqual(bostick.target.reportedTarget.targetKind, "UNIT", "unit registration selected")

local startedAdapter, started = adapter:Start()
assertEqual(startedAdapter, adapter, "start returns adapter")
assertTrue(started, "first start changes state")
assertEqual(fakeListener.handleEventId, 17, "MOOSE Hit event id registered")
assertTrue(type(fakeListener.handleFunction) == "function", "MOOSE Hit callback registered")

local _, startedAgain = adapter:Start()
assertFalse(startedAgain, "second start idempotent")

local callbackBefore = sequence
fakeListener.handleFunction(fakeListener, makeEvent(106))
assertEqual(sequence, callbackBefore + 1, "registered MOOSE callback processes hit")

local _, stopped = adapter:Stop()
assertTrue(stopped, "first stop changes state")
assertEqual(fakeListener.unhandledEventId, 17, "MOOSE Hit event unsubscribed")

local _, stoppedAgain = adapter:Stop()
assertFalse(stoppedAgain, "second stop idempotent")

print("PASS test_fob_attack_hit_adapter")
