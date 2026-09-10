local AlarmAdapter = dofile("scripts/ground/OMW_GroundInstallationAlarmEvidenceAdapter.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function assertTrue(value, label) if value ~= true then error(label .. " expected=true actual=" .. tostring(value)) end end
local function assertFalse(value, label) if value ~= false then error(label .. " expected=false actual=" .. tostring(value)) end end

local previousEvents = EVENTS
EVENTS = { Hit="Hit", Shot="Shot", ShootingStart="ShootingStart" }

local zone = {}
function zone:IsCoordinateInZone(coord) return coord and coord.inside == true end

local function makeTarget(name, coalitionValue, inside)
  local target = { name=name, coalition=coalitionValue, inside=inside }
  function target:GetName() return self.name end
  function target:GetCoalition() return self.coalition end
  function target:IsInZone(_) return self.inside == true end
  return target
end

local handler = { handled={}, unhandled={} }
function handler:HandleEvent(event) self.handled[event]=true end
function handler:UnHandleEvent(event) self.unhandled[event]=true end

local evidence = {}
local weaponsByDcs = {}
local adapter = AlarmAdapter.New({
  installationId="BLUE_GROUND_COP_HONAKER_MIRACLE",
  alarmZone=zone,
  blueCoalition=2,
  redCoalition=1,
  weaponTrackStepSec=0.25,
  onEvidence=function(_, item) table.insert(evidence, item) end,
  eventHandlerFactory=function() return handler end,
  weaponFactory=function(dcsWeapon) return weaponsByDcs[dcsWeapon] end,
  shouldTrackWeapon=function(eventData, weapon)
    return eventData.allowTrack == true and weapon.allowTrack == true
  end,
})

local _, started = adapter:Start()
assertTrue(started, "adapter starts")
assertTrue(handler.handled.Hit, "Hit registered")
assertTrue(handler.handled.Shot, "Shot registered")
assertTrue(handler.handled.ShootingStart, "ShootingStart registered")

adapter:ProcessProximityIntrusion({ attackerCoalition=1 })
assertEqual(evidence[#evidence].evidenceType, AlarmAdapter.EvidenceType.PROXIMITY_INTRUSION, "proximity evidence")

local blueInside = makeTarget("BLUE-GUARD", 2, true)
local redInside = makeTarget("RED-OTHER", 1, true)
local blueOutside = makeTarget("BLUE-OUTSIDE", 2, false)

local direct, directReason = adapter:ProcessShootingStart({
  IniCoalition=1, TgtCoalition=2, IniUnitName="RED-RIFLE", TgtUnitName="BLUE-GUARD", TgtUnit=blueInside,
})
assertEqual(directReason, "EVIDENCE_EMITTED", "direct shooting reason")
assertEqual(direct.evidenceType, AlarmAdapter.EvidenceType.DIRECT_FIRE_ATTACK, "direct shooting evidence")

local ignoredDirect, ignoredDirectReason = adapter:ProcessShootingStart({
  IniCoalition=1, TgtCoalition=2, IniUnitName="RED-RIFLE", TgtUnitName="BLUE-OUTSIDE", TgtUnit=blueOutside,
})
assertEqual(ignoredDirect, nil, "outside direct ignored")
assertEqual(ignoredDirectReason, "TARGET_OUTSIDE_ALARM_ZONE", "outside direct reason")

local hit, hitReason = adapter:ProcessHit({
  IniCoalition=1, TgtCoalition=2, IniUnitName="RED-RIFLE", TgtUnitName="BLUE-GUARD", TgtUnit=blueInside,
})
assertEqual(hitReason, "EVIDENCE_EMITTED", "hit reason")
assertEqual(hit.evidenceType, AlarmAdapter.EvidenceType.CONFIRMED_HIT_ATTACK, "hit evidence")

local dcsDirectWeapon = {}
local directWeapon = { target=blueInside }
function directWeapon:GetTarget() return self.target end
function directWeapon:GetTypeName() return "RPG" end
function directWeapon:IsShell() return false end
function directWeapon:IsRocket() return true end
function directWeapon:IsMissile() return false end
weaponsByDcs[dcsDirectWeapon] = directWeapon

local _, shotReason = adapter:ProcessShot({ IniCoalition=1, weapon=dcsDirectWeapon, IniUnitName="RED-RPG" })
assertEqual(shotReason, "DIRECT_TARGET_EVIDENCE", "direct projectile uses target evidence without tracking")
assertEqual(evidence[#evidence].sourceEvent, "ShotTarget", "shot target source")
assertEqual(evidence[#evidence].evidenceType, AlarmAdapter.EvidenceType.DIRECT_FIRE_ATTACK, "shot target evidence")

local dcsWrongTargetWeapon = {}
local wrongTargetWeapon = { target=redInside }
function wrongTargetWeapon:GetTarget() return self.target end
function wrongTargetWeapon:GetTypeName() return "RPG" end
function wrongTargetWeapon:IsShell() return false end
function wrongTargetWeapon:IsRocket() return true end
function wrongTargetWeapon:IsMissile() return false end
function wrongTargetWeapon:SetTimeStepTrack(_) error("wrong-coalition target must not track without filter") end
weaponsByDcs[dcsWrongTargetWeapon] = wrongTargetWeapon
local beforeWrong = #evidence
local _, wrongReason = adapter:ProcessShot({ IniCoalition=1, weapon=dcsWrongTargetWeapon, IniUnitName="RED-RPG", allowTrack=false })
assertEqual(wrongReason, "TRACK_FILTER_REJECTED", "wrong target falls through to track filter")
assertEqual(#evidence, beforeWrong, "wrong coalition target emits no evidence")

local dcsShell = {}
local shell = { allowTrack=true, impact={inside=true}, started=false, step=nil, impactFunc=nil }
function shell:GetTarget() return nil end
function shell:GetTypeName() return "122mm shell" end
function shell:IsShell() return true end
function shell:IsRocket() return false end
function shell:IsMissile() return false end
function shell:SetTimeStepTrack(value) self.step=value return self end
function shell:SetFuncImpact(func) self.impactFunc=func return self end
function shell:StartTrack() self.started=true return self end
function shell:GetImpactCoordinate() return self.impact end
weaponsByDcs[dcsShell] = shell

local _, trackReason = adapter:ProcessShot({ IniCoalition=1, weapon=dcsShell, IniUnitName="RED-ARTY", allowTrack=true })
assertEqual(trackReason, "TRACKING_STARTED", "filtered shell tracking starts")
assertTrue(shell.started, "shell tracking started")
assertEqual(shell.step, 0.25, "configured non-default tracking step")
local beforeImpact = #evidence
shell.impactFunc(shell)
assertEqual(#evidence, beforeImpact + 1, "inside impact emits evidence")
assertEqual(evidence[#evidence].evidenceType, AlarmAdapter.EvidenceType.INDIRECT_FIRE_ATTACK, "inside impact evidence")
assertEqual(evidence[#evidence].sourceEvent, "WeaponImpact", "inside impact source")

local dcsRejectedShell = {}
local rejectedShell = { allowTrack=false }
function rejectedShell:GetTarget() return nil end
function rejectedShell:IsShell() return true end
function rejectedShell:IsRocket() return false end
function rejectedShell:IsMissile() return false end
function rejectedShell:SetTimeStepTrack(_) error("rejected shell must not start tracking") end
weaponsByDcs[dcsRejectedShell] = rejectedShell
local _, rejectReason = adapter:ProcessShot({ IniCoalition=1, weapon=dcsRejectedShell, IniUnitName="RED-ARTY", allowTrack=true })
assertEqual(rejectReason, "TRACK_FILTER_REJECTED", "filter blocks expensive weapon tracking")

local _, startedAgain = adapter:Start()
assertFalse(startedAgain, "second start idempotent")
local _, stopped = adapter:Stop()
assertTrue(stopped, "adapter stops")
assertTrue(handler.unhandled.Hit, "Hit unregistered")
assertTrue(handler.unhandled.Shot, "Shot unregistered")
assertTrue(handler.unhandled.ShootingStart, "ShootingStart unregistered")
local _, stoppedAgain = adapter:Stop()
assertFalse(stoppedAgain, "second stop idempotent")

EVENTS = previousEvents
print("PASS test_ground_installation_alarm_evidence_adapter")
