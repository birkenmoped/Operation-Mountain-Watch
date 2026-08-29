local MissionDemand = dofile("scripts/campaign/OMW_MissionDemand.lua")
local Policy = dofile("scripts/campaign/OMW_FobAttackDemandPolicy.lua")
local ThreatAdapter = dofile("scripts/ground/OMW_FobThreatOpsZoneAdapter.lua")

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

local previousObject = Object
local previousUnit = Unit
Object = { Category = { UNIT = 1 } }
Unit = { Category = { GROUND_UNIT = 2 } }

local anchor = {}
function anchor:GetVec2()
  return { x = 111, y = 222 }
end
function anchor:GetVec3()
  return { x = 111, y = 333, z = 222 }
end

local createdZone = nil
local fakeOpsZone = {
  started = false,
  stopped = false,
  objectCategories = nil,
  unitCategories = nil,
  captureThreatlevel = nil,
  captureNunits = nil,
  drawZone = nil,
  markZone = nil,
  UpdateSeconds = 120,
}

function fakeOpsZone:SetObjectCategories(value)
  self.objectCategories = value
  return self
end
function fakeOpsZone:SetUnitCategories(value)
  self.unitCategories = value
  return self
end
function fakeOpsZone:SetCaptureThreatlevel(value)
  self.captureThreatlevel = value
  return self
end
function fakeOpsZone:SetCaptureNunits(value)
  self.captureNunits = value
  return self
end
function fakeOpsZone:SetDrawZone(value)
  self.drawZone = value
  return self
end
function fakeOpsZone:SetMarkZone(value)
  self.markZone = value
  return self
end
function fakeOpsZone:Start()
  self.started = true
  return self
end
function fakeOpsZone:Stop()
  self.stopped = true
  return self
end
function fakeOpsZone:I(_)
  return self
end

local registry = MissionDemand.New()
local sequence = 0
local adapter = ThreatAdapter.New({
  missionDemand = MissionDemand,
  registry = registry,
  policy = Policy,
  anchorCoordinate = anchor,
  installationId = "BLUE_GROUND_COP_FORTRESS",
  zoneName = "OMW_SECURITY_BLUE_GROUND_COP_FORTRESS",
  priority = 90,
  radiusM = 1000,
  blueCoalition = 2,
  redCoalition = 1,
  updateSeconds = 5,
  captureThreatlevel = 0,
  captureNunits = 1,
  zoneRadiusFactory = function(name, vec2, radiusM)
    createdZone = {
      name = name,
      vec2 = vec2,
      radiusM = radiusM,
    }
    return createdZone
  end,
  opsZoneFactory = function(zone, owner)
    assertEqual(zone, createdZone, "opszone receives created runtime zone")
    assertEqual(owner, 2, "opszone owner")
    return fakeOpsZone
  end,
  incidentIdFactory = function(_, incidentSequence)
    sequence = sequence + 1
    assertEqual(incidentSequence, sequence, "incident sequence")
    return string.format("INC-PERIMETER|FORTRESS|%d", incidentSequence)
  end,
})

local ignored, ignoredCreated, ignoredReason = adapter:ProcessThreat(2)
assertNil(ignored, "non-red threat ignored")
assertFalse(ignoredCreated, "non-red threat not created")
assertEqual(ignoredReason, "ATTACKER_NOT_RED", "non-red threat reason")

local demand, created, reason = adapter:ProcessThreat(1)
assertTrue(created, "red perimeter threat creates demand")
assertEqual(reason, nil, "first threat create reason")
assertEqual(demand.missionType, MissionDemand.Type.CAS_IMMEDIATE, "threat demand type")
assertEqual(demand.origin, "BLUE_GROUND_COP_FORTRESS", "threat installation")
assertEqual(demand.priority, 90, "threat priority")
assertEqual(demand.target.position.x, 111, "threat position x")
assertEqual(demand.target.position.z, 222, "threat position z")
assertEqual(demand.target.reportedTarget.targetKind, "INSTALLATION_SECURITY_PERIMETER", "target kind")
assertEqual(demand.target.reportedTarget.targetName, "OMW_SECURITY_BLUE_GROUND_COP_FORTRESS", "target zone name")
assertEqual(demand.target.reportedTarget.radiusM, 1000, "target radius")
assertEqual(demand.target.reportedTarget.evidence, "OPSZONE_ATTACKED", "target evidence")

local duplicate, duplicateCreated, duplicateReason = adapter:ProcessThreat(1)
assertFalse(duplicateCreated, "repeated perimeter threat does not create second active demand")
assertEqual(duplicateReason, "active_duplicate", "repeated perimeter threat uses active dedupe")
assertEqual(duplicate.id, demand.id, "repeated perimeter threat returns active demand")

local startedAdapter, started = adapter:Start()
assertEqual(startedAdapter, adapter, "start returns adapter")
assertTrue(started, "first start changes state")
assertEqual(createdZone.name, "OMW_SECURITY_BLUE_GROUND_COP_FORTRESS", "runtime zone name")
assertEqual(createdZone.vec2.x, 111, "runtime zone center x")
assertEqual(createdZone.vec2.y, 222, "runtime zone center y")
assertEqual(createdZone.radiusM, 1000, "runtime zone radius")
assertEqual(fakeOpsZone.objectCategories[1], Object.Category.UNIT, "opszone scans units only")
assertEqual(fakeOpsZone.unitCategories[1], Unit.Category.GROUND_UNIT, "opszone scans ground units")
assertEqual(fakeOpsZone.captureThreatlevel, 0, "sighting threshold permits any red ground unit")
assertEqual(fakeOpsZone.captureNunits, 1, "one red ground unit is sufficient")
assertEqual(fakeOpsZone.drawZone, false, "security perimeter not drawn")
assertEqual(fakeOpsZone.markZone, false, "security perimeter not marked")
assertEqual(fakeOpsZone.UpdateSeconds, 5, "acceptance update interval")
assertTrue(fakeOpsZone.started, "MOOSE OPSZONE started")
assertTrue(type(fakeOpsZone.OnAfterAttacked) == "function", "MOOSE OnAfterAttacked callback installed")

local callbackDemandCount = #registry:ListActive()
fakeOpsZone:OnAfterAttacked("Guarded", "Attacked", "Attacked", 1)
assertEqual(#registry:ListActive(), callbackDemandCount, "MOOSE attack callback preserves one active demand")

local _, startedAgain = adapter:Start()
assertFalse(startedAgain, "second start idempotent")

local _, stopped = adapter:Stop()
assertTrue(stopped, "first stop changes state")
assertTrue(fakeOpsZone.stopped, "MOOSE OPSZONE stopped")

local _, stoppedAgain = adapter:Stop()
assertFalse(stoppedAgain, "second stop idempotent")

Object = previousObject
Unit = previousUnit

print("PASS test_fob_threat_opszone_adapter")
