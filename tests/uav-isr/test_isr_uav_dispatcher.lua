local Dispatcher = dofile("scripts/air-operations/OMW_ISR_UavDispatcher.lua")

env = { info = function() end }

local payloadCall = nil
local addedMission = nil
local consumedRequestId = nil
local lifecycle = {}

local mission = {
  AssignSquadrons = function(self, value) self.squadrons = value return self end,
  SetName = function(self, value) self.name = value return self end,
  SetTime = function(self, value) self.time = value return self end,
  SetDuration = function(self, value) self.duration = value return self end,
  SetTeleport = function(self, value) self.teleport = value return self end,
  Cancel = function(self) self.cancelCount = (self.cancelCount or 0) + 1 return self end,
  GetOpsGroups = function(self) return self.opsGroups end,
}

local opsGroup = {
  alive = true,
  IsAlive = function(self) return self.alive end,
}

local fakeScheduler = {
  Stop = function(self, scheduleId) self.stopped = scheduleId end,
}

local fakeMoose = {
  SCHEDULER = {
    New = function(_, _, callback, arguments, start, repeatInterval)
      lifecycle.recoveryCallback = callback
      lifecycle.recoveryArguments = arguments
      lifecycle.recoveryStart = start
      lifecycle.recoveryRepeat = repeatInterval
      return fakeScheduler, "RECOVERY-SCHEDULE"
    end,
  },
  ZONE_RADIUS = { New = function() error("orbit profile must not create a recon zone") end },
  ENUMS = { ROE = { WeaponHold = "WEAPON_HOLD" } },
  AUFTRAG = {
    Type = { RECON = "RECON", ORBIT = "ORBIT" },
    NewORBIT_CIRCLE = function(_, coordinate, altitude, speed)
      lifecycle.constructor = { coordinate, altitude, speed }
      return mission
    end,
  },
}

local airwing = {
  NewPayload = function(_, template, count, missionTypes, performance)
    payloadCall = { template, count, missionTypes, performance }
  end,
  AddMission = function(_, value)
    addedMission = value
  end,
}

local adapter = {
  Reserve = function(_, requestId, profile)
    lifecycle.reservation = { requestId, profile.id }
    return { transactionId = "TX-" .. requestId }
  end,
  ConsumeAtPhysicalStart = function(_, requestId)
    consumedRequestId = requestId
    return true
  end,
  RecoverAfterPhysicalRecovery = function(_, requestId)
    lifecycle.recovered = requestId
    return true
  end,
}

local mq9Squadron = {
  name = "SQ_US_KAF_MQ9_361_ERS",
  assets = {
    { flightgroup = opsGroup },
  },
  GetRepairTime = function(_, asset)
    assert(asset.flightgroup == opsGroup)
    return 1200
  end,
}

local dispatcher = Dispatcher.New({
  moose = fakeMoose,
  campaignAdapter = adapter,
  source = {
    Airwings = { Main = airwing },
    Squadrons = { MQ9 = mq9Squadron },
  },
  profiles = {
    {
      id = "KAF_MQ9_ORBIT_ACCEPTANCE",
      platformId = "MQ-9",
      resourceId = "AIRCRAFT_MQ9",
      template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
      airwingKey = "Main",
      squadronKey = "MQ9",
      missionKind = "ORBIT_CIRCLE",
      reconAltitudeFeet = 25000,
      reconSpeedKnots = 180,
      onStationSeconds = 2700,
    },
  },
  onMissionStarted = function(request) lifecycle.started = request.id end,
  onMissionExecuting = function(request) lifecycle.executing = request.id end,
  onMissionCancelled = function(request) lifecycle.cancelled = request.id end,
  onMissionCancelledBeforeStart = function(request) lifecycle.cancelledBeforeStart = request.id end,
  onMissionDone = function(request) lifecycle.done = request.id end,
  onMissionRecovered = function(request, _, recovery)
    lifecycle.recovery = { request.id, recovery.turnoverSeconds, recovery.turnoverReason }
  end,
})

local request = {
  id = "ISR-0099",
  coordinate = { sentinel = "marker-coordinate" },
}
local assignment = assert(dispatcher:Dispatch(request))

assert(payloadCall[1] == "TPL_AIR_US_KAF_MQ9_RECON_1SHIP")
assert(payloadCall[2] == -1)
assert(payloadCall[3][1] == "RECON")
assert(payloadCall[3][2] == "ORBIT")
assert(addedMission == mission)
assert(lifecycle.constructor[1] == request.coordinate)
assert(lifecycle.constructor[2] == 25000)
assert(lifecycle.constructor[3] == 180)
assert(lifecycle.constructor[4] == nil)
assert(lifecycle.constructor[5] == nil)
assert(mission.optionROE == "WEAPON_HOLD")
assert(mission.squadrons[1] == mq9Squadron)
assert(mission.duration == 2700)
assert(mission.teleport == false)
assert(assignment.platformId == "MQ-9")

mission.opsGroups = { opsGroup }
mission.OnAfterStarted()
assert(consumedRequestId == "ISR-0099")
assert(lifecycle.started == "ISR-0099")
mission.OnAfterExecuting()
assert(lifecycle.executing == "ISR-0099")
mission.OnAfterCancel()
assert(lifecycle.cancelled == "ISR-0099")
mission.OnAfterDone()
assert(lifecycle.done == nil)
assert(lifecycle.recoveryStart == 5)
assert(lifecycle.recoveryRepeat == 5)
opsGroup.alive = false
dispatcher:_ObservePhysicalRecovery("ISR-0099")
assert(lifecycle.done == "ISR-0099")
assert(lifecycle.recovered == "ISR-0099")
assert(lifecycle.recovery[1] == "ISR-0099")
assert(lifecycle.recovery[2] == 1200)
assert(lifecycle.recovery[3] == nil)
assert(fakeScheduler.stopped == "RECOVERY-SCHEDULE")
opsGroup.alive = true

local beforeStart = assert(dispatcher:Dispatch({
  id = "ISR-0100",
  coordinate = { sentinel = "marker-coordinate-2" },
}))
assert(beforeStart.platformId == "MQ-9")
assert(dispatcher:CancelRequest("ISR-0100") == "CANCELLED_BEFORE_START")
assert(mission.cancelCount == 1)
mission.OnAfterCancel()
assert(lifecycle.cancelledBeforeStart == "ISR-0100")
mission.OnAfterDone()
assert(lifecycle.done == "ISR-0099")

local recall = assert(dispatcher:Dispatch({
  id = "ISR-0101",
  coordinate = { sentinel = "marker-coordinate-3" },
}))
mission.opsGroups = { opsGroup }
mission.OnAfterStarted()
assert(dispatcher:CancelRequest("ISR-0101") == "RECALL_ORDERED")
assert(mission.cancelCount == 2)
mission.OnAfterDone()
assert(lifecycle.done == "ISR-0099")
mission.OnAfterCancel()
assert(lifecycle.cancelled == "ISR-0101")
assert(dispatcher:CancelRequest("ISR-0101") == "RECALL_ALREADY_ORDERED")
opsGroup.alive = false
dispatcher:_ObservePhysicalRecovery("ISR-0101")
assert(lifecycle.done == "ISR-0101")
assert(lifecycle.recovered == "ISR-0101")
assert(lifecycle.recovery[1] == "ISR-0101")
assert(lifecycle.recovery[2] == 1200)

print("PASS test_isr_uav_dispatcher")
