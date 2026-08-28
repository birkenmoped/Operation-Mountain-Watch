local Dispatcher = dofile("scripts/air-operations/OMW_ISR_UavDispatcher.lua")

env = { info = function() end }

local addedMission = nil
local lifecycle = {}
local opsGroup = {
  alive = true,
  airborne = false,
  IsAlive = function(self) return self.alive end,
  IsAirborne = function(self) return self.airborne end,
}
local asset = { flightgroup = opsGroup }
local mission = {
  AssignSquadrons = function(self, value) self.squadrons = value return self end,
  SetName = function(self, value) self.name = value return self end,
  SetTime = function(self, value) self.time = value return self end,
  SetDuration = function(self, value) self.duration = value return self end,
  SetTeleport = function(self, value) self.teleport = value return self end,
  Cancel = function(self) self.cancelled = true return self end,
  GetOpsGroups = function() return { opsGroup } end,
}
local fakeMoose = {
  SCHEDULER = { New = function() return { Stop = function() end }, "S" end },
  ZONE_RADIUS = { New = function() error("orbit must not create a recon zone") end },
  ENUMS = { ROE = { WeaponHold = "WEAPON_HOLD" } },
  AUFTRAG = {
    Type = { RECON = "RECON", ORBIT = "ORBIT" },
    NewORBIT_CIRCLE = function(_, coordinate, altitude, speed)
      lifecycle.orbit = { coordinate, altitude, speed }
      return mission
    end,
  },
}
local airwing = {
  NewPayload = function() end,
  AddMission = function(_, value) addedMission = value end,
}
local adapter = {
  BeginPhysicalStart = function(_, requestId, profile)
    lifecycle.physicalStart = { requestId, profile.resourceId }
    return { transactionId = "TX-" .. requestId }
  end,
  RecoverAfterPhysicalRecovery = function() return true end,
}
local dispatcher = Dispatcher.New({
  moose = fakeMoose,
  campaignAdapter = adapter,
  source = {
    Airwings = { Main = airwing },
    Squadrons = { MQ9 = { assets = { asset }, GetRepairTime = function() return 0 end } },
  },
  profiles = {{
    id = "MQ9_ORBIT", platformId = "MQ-9", resourceId = "AIRCRAFT_MQ9",
    template = "TPL_MQ9", airwingKey = "Main", squadronKey = "MQ9",
    missionKind = "ORBIT_CIRCLE", reconAltitudeFeet = 25000,
    reconSpeedKnots = 180, onStationSeconds = 2700,
  }},
  onMissionStarted = function(request, _, reservation)
    lifecycle.started = { request.id, reservation and reservation.transactionId }
  end,
})

local request = { id = "ISR-0099", coordinate = { marker = true } }
local assignment = assert(dispatcher:Dispatch(request))
assert(assignment.mission == mission)
assert(addedMission == mission, "AUFTRAG must enter AIRWING queue immediately")
assert(lifecycle.physicalStart == nil, "CampaignState must not settle before MOOSE start")
assert(mission.duration == 2700)
assert(mission.optionROE == "WEAPON_HOLD")
mission.OnAfterStarted()
assert(lifecycle.physicalStart[1] == "ISR-0099")
assert(lifecycle.physicalStart[2] == "AIRCRAFT_MQ9")
assert(lifecycle.started[2] == "TX-ISR-0099")
assert(dispatcher:CancelRequest("ISR-0099") == "RECALL_ORDERED")
assert(mission.cancelled == true)
print("PASS test_isr_uav_dispatcher")
