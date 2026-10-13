-- Operation Mountain Watch - generic CAS release policy.
--
-- This module owns qualification of a configured CAS release profile. It does not
-- select providers, inspect DCS/MOOSE objects directly, cancel missions or perform
-- recovery. The caller supplies the supported-element status and the qualified
-- own CAS contact count.
--
-- A stable-no-contact duration is profile configuration, not a project-wide law.

local Policy={}
local Instance={}
Instance.__index=Instance

Policy.SchemaVersion="OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-RELEASE-POLICY-1"
Policy.Mode={
  SUPPORTED_ELEMENT_STABLE_NO_CONTACT="SUPPORTED_ELEMENT_STABLE_NO_CONTACT",
}

local TAG="[OMW][FireSupStratResupply.CasReleasePolicy]"

local function fail(message) error(TAG.." "..tostring(message),2) end
local function needPositive(value,label)
  if type(value)~="number" or value~=value or value<=0 or value==math.huge then
    fail(label.." must be a positive finite number")
  end
  return value
end
local function needString(value,label)
  if type(value)~="string" or value=="" then fail(label.." requires non-empty string") end
  return value
end

function Policy.New(spec)
  if type(spec)~="table" then fail("spec must be a table") end
  local mode=spec.mode or Policy.Mode.SUPPORTED_ELEMENT_STABLE_NO_CONTACT
  if mode~=Policy.Mode.SUPPORTED_ELEMENT_STABLE_NO_CONTACT then
    fail("unsupported release policy mode: "..tostring(mode))
  end
  if spec.logger~=nil and type(spec.logger)~="function" then
    fail("logger must be a function when provided")
  end
  return setmetatable({
    mode=mode,
    stableNoContactSec=needPositive(spec.stableNoContactSec,"stableNoContactSec"),
    logger=spec.logger,
    states={},
  },Instance)
end

function Instance:_state(demandId)
  needString(demandId,"demandId")
  local state=self.states[demandId]
  if not state then
    state={
      demandId=demandId,
      noContactSince=nil,
      noContactReported=false,
      lastEligibleCount=nil,
      release=false,
      releaseReason=nil,
    }
    self.states[demandId]=state
  end
  return state
end

function Instance:Observe(demandId,spec)
  if type(spec)~="table" then fail("spec must be a table") end
  local state=self:_state(demandId)
  local now=spec.now
  if type(now)~="number" then fail("spec.now must be a number") end
  if spec.supportedElementClear~=true and spec.supportedElementClear~=false then
    fail("spec.supportedElementClear must be boolean")
  end

  if spec.sensorReady~=true then
    return state,false,"SENSOR_NOT_READY"
  end

  local eligible=spec.eligibleCount
  if type(eligible)~="number" or eligible<0 then fail("spec.eligibleCount must be >= 0") end

  local changed=false
  if eligible>0 then
    if state.noContactSince~=nil or state.noContactReported then changed=true end
    state.noContactSince=nil
    state.noContactReported=false
  else
    if state.noContactSince==nil then
      state.noContactSince=now
      changed=true
    end
    if not state.noContactReported and now-state.noContactSince>=self.stableNoContactSec then
      state.noContactReported=true
      changed=true
    end
  end
  state.lastEligibleCount=eligible

  if spec.supportedElementClear and state.noContactReported and not state.release then
    state.release=true
    state.releaseReason="SUPPORTED_ELEMENT_RELEASE_NO_CONTACT"
    changed=true
  end

  return state,changed,state.release and "RELEASE" or "HOLD"
end

function Instance:GetState(demandId)
  return self.states[demandId]
end

return Policy
