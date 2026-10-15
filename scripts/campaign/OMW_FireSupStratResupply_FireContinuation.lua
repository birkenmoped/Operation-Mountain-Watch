-- Operation Mountain Watch - C2 fire continuation composition.
-- One-shot event deferral only; MOOSE retains recruitment, ARTY fire and rearm.
-- No independent target detection, mission ownership or resource settlement.

local Continuation = {}
local Instance = {}
Instance.__index = Instance
Continuation.SchemaVersion = "OMW-FSSR-FIRE-CONTINUATION-2"

local function requireFunction(spec, key)
  if type(spec[key]) ~= "function" then
    error("FSSR FireContinuation requires " .. key .. "()", 2)
  end
end

local function scheduleOnce(callback)
  if type(SCHEDULER) ~= "table" or type(SCHEDULER.New) ~= "function" then
    error("FSSR FireContinuation requires MOOSE SCHEDULER:New()", 2)
  end
  return SCHEDULER:New(nil, callback, {}, 1)
end

function Continuation.New(spec)
  if type(spec) ~= "table" then error("FireContinuation spec table required", 2) end
  for _, key in ipairs({
    "getIncident", "getCandidates", "resolveCasPresence",
    "getPhysicalAmmo", "requestFire", "requestRearm",
  }) do
    requireFunction(spec, key)
  end
  if spec.schedule ~= nil then requireFunction(spec, "schedule") end
  if spec.log ~= nil then requireFunction(spec, "log") end
  return setmetatable({
    getIncident = spec.getIncident,
    getCandidates = spec.getCandidates,
    resolveCasPresence = spec.resolveCasPresence,
    getPhysicalAmmo = spec.getPhysicalAmmo,
    requestFire = spec.requestFire,
    requestRearm = spec.requestRearm,
    schedule = spec.schedule or scheduleOnce,
    log = spec.log or function() end,
    waiting = {},
    seen = {},
    queued = {},
    serial = {},
    lastTargetByIncident = {},
  }, Instance)
end

function Instance:_defer(incidentId)
  if self.queued[incidentId] then return end
  self.queued[incidentId] = true
  self.schedule(function()
    self.queued[incidentId] = nil
    self:_evaluate(incidentId)
  end)
end

function Instance:_evaluate(incidentId)
  local pending = self.waiting[incidentId]
  if not pending then return end
  local incident = self.getIncident(incidentId)
  if not incident then
    self.waiting[incidentId] = nil
    self.log("C2_FIRE_INCIDENT_NOT_FOUND incidentId=" .. tostring(incidentId))
    return
  end

  -- Participants come from the existing installation incident coordinator.
  -- No world scan and no secondary tactical contact registry is maintained.
  local candidates = self.getCandidates(pending.context)
  if type(candidates) ~= "table" or #candidates == 0 then
    self.waiting[incidentId] = nil
    self.log("C2_FIRE_NO_LIVE_TARGET incidentId=" .. tostring(incidentId))
    return
  end
  local target = candidates[1]
  if #candidates > 1 and pending.lastTargetName then
    for _, candidate in ipairs(candidates) do
      if candidate:GetName() ~= pending.lastTargetName then
        target = candidate
        break
      end
    end
  end
  local coordinate = target:GetCoordinate()
  if not coordinate then
    self.log("C2_FIRE_TARGET_COORDINATE_UNKNOWN incidentId=" .. tostring(incidentId))
    return
  end
  local casPresent, casReason = self.resolveCasPresence(coordinate)
  if casPresent ~= false then
    self.log("C2_FIRE_WAIT_CAS incidentId=" .. tostring(incidentId)
      .. " reason=" .. tostring(casReason))
    return
  end

  local ammo = self.getPhysicalAmmo(pending.entry)
  if type(ammo) ~= "number" then
    self.log("C2_FIRE_AMMO_UNKNOWN incidentId=" .. tostring(incidentId))
    return
  end
  if ammo < pending.requiredShots then
    if pending.rearmCompleted then
      self.log("C2_FIRE_AMMO_STILL_LOW_AFTER_REARM incidentId=" .. tostring(incidentId))
      return
    end
    if not pending.rearmRequested then
      local accepted, reason = self.requestRearm(pending.entry, pending.demand)
      if accepted then
        pending.rearmRequested = true
        self.log("C2_FIRE_REARM_REQUESTED incidentId=" .. tostring(incidentId))
      else
        self.log("C2_FIRE_REARM_UNAVAILABLE incidentId=" .. tostring(incidentId)
          .. " reason=" .. tostring(reason))
      end
    end
    return
  end

  local nextSerial = (self.serial[incidentId] or 0) + 1
  local requestKey = "INSTALLATION_ATTACK_C2_ARTY_CYCLE_" .. tostring(nextSerial)
  -- Advance serial only after a real Base demand is created. Never enqueue
  -- a new demand while the previous MOOSE selection is still reserved.
  local demand, created, reason = self.requestFire(
    incident, pending.context, target, requestKey, pending.demand
  )
  if created == true and demand and demand.status == "DISPATCHED" then
    self.serial[incidentId] = nextSerial
    self.lastTargetByIncident[incidentId] = target:GetName()
    self.waiting[incidentId] = nil
    self.log("C2_FIRE_CONTINUED incidentId=" .. tostring(incidentId)
      .. " demandId=" .. tostring(demand.demandId)
      .. " target=" .. tostring(target:GetName()))
  else
    -- Do not spin or create successive failed demands: another accepted
    -- MOOSE completion/rearm/CAS event may re-evaluate the pending incident.
    if created == true then self.serial[incidentId] = nextSerial end
    self.log("C2_FIRE_DISPATCH_PENDING incidentId=" .. tostring(incidentId)
      .. " reason=" .. tostring(reason))
  end
end

function Instance:OnFinished(demand, context, entry, reason)
  if type(demand) ~= "table" or type(demand.demandId) ~= "string" then return end
  if self.seen[demand.demandId] then return end
  self.seen[demand.demandId] = true
  -- Selection release may free a real MOOSE provider for another incident.
  -- Wake only waiting incidents on this terminal event; no retry poller.
  if entry and entry.released then
    for otherId, pending in pairs(self.waiting) do
      if otherId ~= demand.incidentId and not pending.rearmRequested then
        self:_defer(otherId)
      end
    end
  end
  if reason ~= "CEASE_FIRE" or not entry or (entry.physicalShots or 0) < 1 then
    self.log("C2_FIRE_NOT_CONTINUED demandId=" .. demand.demandId
      .. " reason=" .. tostring(reason))
    return
  end
  if not entry.released or type(demand.incidentId) ~= "string" then
    self.log("C2_FIRE_NOT_RELEASED demandId=" .. demand.demandId)
    return
  end
  local shots = entry.owner and entry.owner.acceptedShots or entry.target and entry.target.shots
  if type(shots) ~= "number" or shots <= 0 then
    self.log("C2_FIRE_SHOT_REQUIREMENT_UNKNOWN demandId=" .. demand.demandId)
    return
  end
  local priorSource = context and context.requestContext and context.requestContext.sourceTargetGroup
  if not priorSource then
    priorSource = context and context.incident and context.incident.context
      and context.incident.context.physicalTargetGroup
  end
  if not self.lastTargetByIncident[demand.incidentId] and priorSource
    and type(priorSource.GetName) == "function" then
    self.lastTargetByIncident[demand.incidentId] = priorSource:GetName()
  end
  self.waiting[demand.incidentId] = {
    demand = demand,
    context = context,
    entry = entry,
    requiredShots = shots,
    lastTargetName = self.lastTargetByIncident[demand.incidentId],
    rearmRequested = false,
    rearmCompleted = false,
  }
  self:_defer(demand.incidentId)
end

function Instance:OnRearmed(assetId)
  for incidentId, pending in pairs(self.waiting) do
    if pending.rearmRequested and pending.entry.owner
      and pending.entry.owner.realAssetId == assetId then
      pending.rearmRequested = false
      pending.rearmCompleted = true
      self:_defer(incidentId)
    end
  end
end

function Instance:OnCasEvidence()
  for incidentId, pending in pairs(self.waiting) do
    if pending and not pending.rearmRequested then self:_defer(incidentId) end
  end
end

function Instance:GetWaiting(incidentId)
  return self.waiting[incidentId]
end

return Continuation
