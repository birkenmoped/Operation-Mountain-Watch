-- Receiver policy adapter, not a flight FSM. Only public MOOSE actions are used,
-- except the explicitly approved post-RTB/Refueled currbase reset below.
local Recovery = { SchemaVersion = "OMW-FIXED-WING-CAS-RECOVERY-1" }
local Adapter = {}
Adapter.__index = Adapter

local function hook(object, name, fn)
  local previous = object[name]
  object[name] = function(self, ...)
    if previous then previous(self, ...) end
    return fn(self, ...)
  end
end

function Recovery.Bind(spec)
  assert(spec.flight and spec.mission and spec.policy and spec.now and spec.routes and spec.tankers and spec.log)
  local a = setmetatable({ spec = spec, flight = spec.flight, mission = spec.mission,
    policy = spec.policy, landed = {}, returned = false, aarCount = 0,
    firstTakeoffS = nil, stationS = 0, finalReason = nil }, Adapter)
  local f = a.flight
  local beforeStart = f.OnBeforeMissionStart
  f.OnBeforeMissionStart = function(self, from, event, to, mission)
    if a.finalReason and mission and (mission.type == AUFTRAG.Type.CAS
        or mission.type == AUFTRAG.Type.CASENHANCED) then
      a:Log("CAS_RESTART_REJECTED", { reason = a.finalReason })
      return false
    end
    if beforeStart then return beforeStart(self, from, event, to, mission) end
  end
  f:SetReturnToLegion(true)
  f:SetFuelLowRTB(false)
  f:SetFuelLowRefuel(false)
  f:SetFuelLowThreshold(30) -- contingency event only; dynamic budgets decide earlier.
  -- Public before-event veto prevents a pending MOOSE RTB retry interrupting AAR.
  local beforeRtb = f.OnBeforeRTB
  f.OnBeforeRTB = function(self, ...)
    if a.aarRequested or self:IsGoing4Fuel() then return false end
    if beforeRtb then return beforeRtb(self, ...) end
  end
  hook(f, "OnAfterElementTakeoff", function(_, from, event, to, element)
    if not a.firstTakeoffS then
      a.firstTakeoffS = spec.now()
      a:Log("SORTIE_CLOCK_STARTED", { firstTakeoffS = a.firstTakeoffS, element = element and element.name })
    end
  end)
  hook(f, "OnAfterRefuel", function()
    a.aarStartedS = spec.now()
    a.aarAfterRtb = a.rtbAtS ~= nil
    a:Log("AAR_TASK_STARTED", { recovery = a.finalReason ~= nil, postRtb = a.aarAfterRtb })
  end)
  hook(f, "OnAfterRefueled", function()
    a.aarRequested, a.aarStartedS = false, nil
    a:Log("AAR_REFUELED", { count = a.aarCount, recovery = a.finalReason ~= nil })
    if a.finalReason then
      a.postRtbAarCompleted = a.aarAfterRtb == true
      a.aarAfterRtb, a.rtbRequestedS, a.aarTarget, a.aarRuntime = false, nil, nil, nil
      a:CheckFuel("REFUELED")
    end
  end)
  hook(f, "OnAfterRTB", function(_, from, event, to, base)
    a.finalReason = a.finalReason or "MOOSE_RTB_EVENT"
    a.finalAtS = a.finalAtS or spec.now()
    a.rtbAtS = spec.now()
    a:Log("MOOSE_RTB", { destination = base and base:GetName(),
      requestDelayS = a.rtbRequestedS and a.rtbAtS - a.rtbRequestedS })
  end)
  hook(f, "OnAfterFuelLow", function()
    a:Log("MOOSE_FUEL_LOW", {}); a:CheckFuel("FUEL_LOW")
  end)
  hook(f, "OnAfterFuelCritical", function()
    a:Log("MOOSE_FUEL_CRITICAL", {}); a:CheckFuel("FUEL_CRITICAL")
  end)
  hook(f, "OnAfterMissionDone", function()
    a:Log("MOOSE_MISSION_DONE", { finalRecovery = a.finalReason ~= nil })
  end)
  hook(f, "OnAfterElementLanded", function(_, from, event, to, element, base)
    local destination = a:Destination()
    local atHome = base and destination and base:GetName() == destination:GetName()
    if element then a.landed[element.name] = atHome == true end
    if a.firstTakeoffS and spec.now() - a.firstTakeoffS > spec.sortie.plannedS then
      a:Fail("LANDING_AFTER_PLANNED_SORTIE_LIMIT")
    end
    a:Log("ELEMENT_LANDED", { element = element and element.name,
      base = base and base:GetName(), expectedBase = atHome == true })
  end)
  hook(f, "OnAfterElementDead", function(_, from, event, to, element)
    a:Log("ELEMENT_DEAD", { element = element and element.name, returned = a.returned })
    if not a.returned and element and not a.landed[element.name] then
      a:Fail("ELEMENT_LOST_BEFORE_HOME_LANDING")
    end
  end)
  local wing = f:GetAirwing()
  if wing then
    hook(wing, "OnAfterLegionAssetReturned", function(_, from, event, to, cohort, asset)
      if asset and asset.flightgroup == f then
        a.returned = true
        local n = 0
        for _, home in pairs(a.landed) do if home then n = n + 1 end end
        a:Log("EXACT_ASSET_RETURNED", { assetUid = asset.uid,
          landedAtHome = n, physicalRecovery = n == 2, recoveryComplete = n == 2 and not a.failure })
        if n ~= 2 then a:Fail("ASSET_RETURN_WITHOUT_TWO_HOME_LANDINGS") end
      end
    end)
  else a:Fail("AIRWING_RETURN_HOOK_UNAVAILABLE") end
  return a
end

function Adapter:Log(event, values) self.spec.log(event, values or {}) end
function Adapter:Fail(reason)
  self.failureReasons = self.failureReasons or {}
  if not self.failureReasons[reason] then self:Log("SAFETY_FAIL_STOP", { reason = reason }) end
  self.failureReasons[reason] = true
  self.failure = self.failure or reason -- diagnostic; never stops physical recovery observation.
end
function Adapter:DepartureComplete()
  if self.departureComplete then return end
  self.departureComplete = true
  self.mission:SetAllowAfterburner()
  self.flight:SetAllowAfterburner()
  self:Log("DEPARTURE_AFTERBURNER_RESTRICTION_RELEASED", {})
end
function Adapter:Destination() return self.flight.destbase or self.flight.homebase end

function Adapter:Sample(joined)
  local units, ids, n = self.flight:GetGroup():GetUnits() or {}, {}, 0
  for _, u in pairs(units) do
    if u and u:IsAlive() then
      local id, airborne = u:GetName(), u:InAir()
      local _, internalKg = u:GetFuelMassMax()
      self.policy:Observe(id, self.spec.now(), u:GetCurrentFuelKgs(), internalKg,
        airborne, joined and not self.aarRequested and not self.flight:IsGoing4Fuel())
      if airborne then ids[id] = u; n = n + 1 end
    end
  end
  self.airborneUnits, self.airborneCount = ids, n
  return ids, n
end

function Adapter:Budget(destination, viaAo)
  local times, reason = self.spec.routes(self.airborneUnits or {}, destination, viaAo)
  if not times then return { valid = false, safe = false, reason = reason } end
  return self.policy:Assess(times)
end

function Adapter:CloseCas(reason)
  if self.finalReason then return end
  self.finalReason, self.finalAtS = reason, self.spec.now()
  self:Log("FINAL_RECOVERY_INTENT", { reason = reason })
  self.flight:SetReturnToLegion(true)
  if not self.mission:IsOver() then
    self:Log("CAS_CLOSURE_REQUESTED", { reason = reason })
    self.flight:MissionCancel(self.mission)
  end
end

function Adapter:RequestRtb()
  if self.returned or self.rtbRequestedS or (self.rtbAtS and not self.postRtbAarCompleted)
      or self.aarRequested or self.flight:IsGoing4Fuel()
      or self.flight:IsLanded() then return end
  local dest = self:Destination()
  if not dest then self:Fail("NO_RECOVERY_DESTINATION"); return end
  self.rtbRequestedS = self.spec.now()
  self.rtbAtS = nil
  self:Log("MOOSE_RTB_REQUESTED", { destination = dest:GetName() })
  local f = self.flight
  if self.postRtbAarCompleted and self.finalReason and not self.returned
      and not f:IsLanded() and f:GetGroup():IsAirborne(true) and next(self.landed) == nil
      and f.currbase and f.currbase:GetName() == dest:GetName() then
    -- Owner-approved exception: one field, immediately before public RTB,
    -- once per actual completed post-RTB recovery AAR cycle.
    f.currbase = nil
    self:Log("RECOVERY_AAR_CURRBASE_RESET", { destination = dest:GetName(), cycle = self.aarCount })
  end
  self.postRtbAarCompleted = nil
  self.flight:RTB(dest)
end

function Adapter:RequestAar(reason, final, candidate)
  if self.returned or self.aarRequested or self.flight:IsGoing4Fuel() then return false end
  candidate = candidate or self.spec.tankers(self)
  if not candidate then self:Log("AAR_NOT_AVAILABLE", { reason = reason }); return false end
  self.aarRequested = true -- set before cancellation; no RTB retry during the handoff.
  self.aarTarget = candidate.coordinate
  self.aarRuntime = candidate.runtime
  if final then self:CloseCas(reason) end
  self.aarCount = self.aarCount + 1
  self:Log("AAR_SELECTED", { area = candidate.area, reason = reason,
    recovery = self.finalReason ~= nil, receiverMarginKg = candidate.marginKg,
    estimatedDonorExcessKg = candidate.donorExcessKg })
  self.flight:Refuel(candidate.coordinate)
  return true
end

function Adapter:CheckFuel(reason)
  if self.returned then return end
  self:Sample(self.joined)
  if self.airborneCount == 0 then return end
  local home = self:Budget(self:Destination())
  if not home.valid then
    self:Fail(home.reason or "INVALID_RECOVERY_BUDGET")
    self:CloseCas("INVALID_RECOVERY_BUDGET")
    self:RequestRtb()
    return
  end
  self:Log("RECOVERY_BUDGET", { reason = reason, safe = home.safe, marginKg = home.marginKg,
    routeTimeS = home.maxTimeS, reserveS = self.spec.reserveS })
  for id, e in pairs(home.elements) do
    self:Log("ELEMENT_RECOVERY_BUDGET", { element = id, availableKg = e.availableKg,
      tripKg = e.tripKg, allowanceKg = e.allowanceKg, marginKg = e.marginKg, rateKgS = e.rateKgS })
  end
  if self.aarRequested or self.flight:IsGoing4Fuel() then
    -- An underway AAR is not interrupted by sortie ceilings. Access loss remains FAIL.
    if self.aarTarget then
      local r = self.aarRuntime
      if r then
        if r.egressOrdered or r.lossHandled or not r.group:IsAlive() then
          self:Fail("SELECTED_AAR_RUNTIME_UNAVAILABLE")
        else self.aarTarget = r.group:GetCoordinate() end
      end
      local access = self:Budget(self.aarTarget)
      if not access.valid or not access.safe then self:Fail("AAR_ACCESS_RESERVE_UNSAFE") end
    end
    return
  end
  if not home.safe then
    if self:RequestAar("RECOVERY_MARGIN", self.finalReason ~= nil) then return end
    self:Fail("NO_RESERVE_SAFE_HOME_OR_TANKER")
    self:CloseCas("NO_RESERVE_SAFE_HOME_OR_TANKER")
    self:RequestRtb() -- explicit best effort, never labelled safe or PASS.
    return
  end
  -- Preserve the next decision interval before Bingo; a safe home option must
  -- not be consumed while waiting for an inaccessible tanker.
  local reactionS = 2 * self.spec.observerPeriodS
  local imminent = false
  for _, e in pairs(home.elements) do
    if e.marginKg <= e.rateKgS * reactionS then imminent = true end
  end
  local candidate = self.joined and self.spec.tankers(self) or nil
  local joker = false
  if not self.finalReason and candidate and candidate.accessS then
    for _, e in pairs(home.elements) do
      if e.marginKg <= e.rateKgS * (candidate.accessS + reactionS) then joker = true end
    end
  end
  if joker then
    self:RequestAar("TANKER_ACCESS_JOKER", false, candidate)
    return
  elseif imminent then
    if not self:RequestAar("RECOVERY_DECISION_MARGIN", self.finalReason ~= nil, candidate) then
      self:CloseCas("BINGO_NO_SAFE_TANKER"); self:RequestRtb()
    end
    return
  end
  if self.finalReason then self:RequestRtb(); return end
  if reason == "FUEL_LOW" or reason == "FUEL_CRITICAL" then
    if not self:RequestAar(reason, false) then self:CloseCas(reason); self:RequestRtb() end
  elseif self.joined and not self.inAo then
    local onward = self:Budget(self:Destination(), true)
    if not onward.valid or not onward.safe then
      -- Before committing the remaining transit, refuel if safely accessible; else return.
      if not self:RequestAar("TRANSIT_AND_RECOVERY_MARGIN", false) then
        self:CloseCas("TRANSIT_NOT_FUEL_SUPPORTED"); self:RequestRtb()
      end
    end
  end
end

function Adapter:Tick(joined, inAo)
  if self.returned then return end
  self.joined, self.inAo = joined == true, inAo == true
  local now = self.spec.now()
  local _, n = self:Sample(self.joined)
  local onStation = inAo and n == 2 and not self.finalReason and not self.aarRequested and not self.flight:IsGoing4Fuel()
  if onStation and self.lastStationS then self.stationS = self.stationS + now - self.lastStationS end
  self.lastStationS = onStation and now or nil
  if n == 0 then
    if self.joined and next(self.landed) == nil then self:Fail("ALL_ELEMENTS_MISSING_BEFORE_LANDING") end
    return
  end
  local home = self:Budget(self:Destination())
  if self.firstTakeoffS and home.valid then
    local p = self.spec.sortie
    if now - self.firstTakeoffS + home.maxTimeS + self.spec.reserveS >= p.absoluteS then
      self:Fail("ABSOLUTE_RETURN_CEILING_AT_RISK")
    end
    if self.stationS >= p.stationS or now - self.firstTakeoffS + home.maxTimeS + self.spec.reserveS >= p.plannedS then
      self:CloseCas("SORTIE_OR_STATION_LIMIT")
    end
  end
  self:CheckFuel("MONITOR")
  if self.rtbRequestedS and not self.rtbAtS and not self.aarRequested
      and now - self.rtbRequestedS > 2 * self.spec.observerPeriodS then
    self:Fail("RTB_TRANSITION_NOT_CONFIRMED")
  end
  if n < 2 and self.joined and not self.returned and next(self.landed) == nil then
    self:Fail("TWO_SHIP_ELEMENT_MISSING")
  end
end

return Recovery
