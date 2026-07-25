-- Executable pre-DCS initialization smoke test for Jalalabad Phase 1.
-- This does not simulate DCS flight operations. It verifies that the canonical
-- Phase-1 modules load in order, tolerate a not-yet-constructed AIRWING, attach
-- the AIRWING callback later, and create the F10 menu immediately.

local logs = {}
local scheduled = {}
local menuCount = 0
local commandCount = 0

local function fail(message)
  error("PHASE1_INIT_SMOKE_FAIL: " .. tostring(message), 2)
end

local function assertTrue(value, message)
  if value ~= true then fail(message) end
end

local function assertEqual(actual, expected, message)
  if actual ~= expected then
    fail(string.format("%s actual=%s expected=%s", tostring(message), tostring(actual), tostring(expected)))
  end
end

local function logContains(fragment)
  for _, line in ipairs(logs) do
    if string.find(line, fragment, 1, true) then return true end
  end
  return false
end

env = {
  info = function(message)
    logs[#logs + 1] = tostring(message)
  end
}

coalition = { side = { BLUE = 2 } }
trigger = { action = { outTextForCoalition = function() end } }
timer = {
  getTime = function() return 100 end,
  scheduleFunction = function(fn, arg, at)
    scheduled[#scheduled + 1] = { fn = fn, arg = arg, at = at }
    return #scheduled
  end
}

SCHEDULER = {}
function SCHEDULER:New(owner, fn, args, startDelay, interval)
  local scheduler = {
    Owner = owner,
    Function = fn,
    Arguments = args,
    StartDelay = startDelay,
    Interval = interval,
    Stopped = false
  }
  function scheduler:Stop() self.Stopped = true end
  scheduled[#scheduled + 1] = scheduler
  return scheduler
end

EVENTS = {
  EngineStartup = 1,
  Takeoff = 2,
  Land = 3,
  EngineShutdown = 4,
  Crash = 5,
  Dead = 6,
  DynamicCargoLoaded = 7,
  DynamicCargoUnloaded = 8,
  DynamicCargoRemoved = 9
}

EVENTHANDLER = {}
function EVENTHANDLER:New()
  local handler = { Events = {} }
  function handler:HandleEvent(event) self.Events[#self.Events + 1] = event end
  return handler
end

MENU_COALITION = {}
function MENU_COALITION:New(side, text, parent)
  menuCount = menuCount + 1
  return { Side = side, Text = text, Parent = parent }
end

MENU_COALITION_COMMAND = {}
function MENU_COALITION_COMMAND:New(side, text, parent, callback)
  commandCount = commandCount + 1
  return { Side = side, Text = text, Parent = parent, Callback = callback }
end

OPSTRANSPORT = {}
LEGION = {}
GROUP = { FindByName = function() return nil end }
STATIC = { FindByName = function() return nil end }
ZONE = { FindByName = function() return nil end }
COORDINATE = {}
SET_ZONE = {}
SPAWN = {}
AUFTRAG = { Type = { RECON = "RECON" } }

local squadronContracts = {
  OH58D = { Grouping = 2, RuntimeUnitSuffixes = { "-01", "-02" }, AssetGroups = 12 },
  AH64D = { Grouping = 2, RuntimeUnitSuffixes = { "-01", "-02" }, AssetGroups = 4 },
  UH60 = { Grouping = 1, RuntimeUnitSuffixes = { "-01" }, AssetGroups = 8 },
  CH47 = { Grouping = 1, RuntimeUnitSuffixes = { "-01" }, AssetGroups = 8 }
}

local testPackages = {
  OH58D_RECON = {
    SquadronKey = "OH58D", PackageModel = "PHYSICAL_TWO_SHIP",
    OperationKind = "AUFTRAG", RequiredGroups = 1, RequiredAircraft = 2
  },
  AH64D_CAS = {
    SquadronKey = "AH64D", PackageModel = "PHYSICAL_TWO_SHIP",
    OperationKind = "AUFTRAG", RequiredGroups = 1, RequiredAircraft = 2
  },
  UH60_TROOP = {
    SquadronKey = "UH60", PackageModel = "INDEPENDENT_SINGLE_SHIP_ASSETS",
    OperationKind = "OPSTRANSPORT", LogisticsProfile = "GROUP_CARGO",
    RequiredGroups = 2, RequiredAircraft = 2
  },
  CH47_CARGO = {
    SquadronKey = "CH47", PackageModel = "SINGLE_SHIP",
    OperationKind = "AUFTRAG", LogisticsProfile = "STATIC_SLING_CARGO",
    RequiredGroups = 1, RequiredAircraft = 1
  },
  UH60_ABORT = {
    SquadronKey = "UH60", PackageModel = "INDEPENDENT_SINGLE_SHIP_ASSETS",
    OperationKind = "OPSTRANSPORT", LogisticsProfile = "GROUP_CARGO",
    RequiredGroups = 2, RequiredAircraft = 2
  }
}

local cfg = {
  PackageContractsOK = true,
  NameContractInitialized = true,
  NameContractOK = true,
  ParkingReservationsOK = true,
  ParkingPoolsOK = true,
  Status = "ASSEMBLING",
  AirbaseName = "Jalalabad",
  Airwing = nil,
  RuntimeGroupPrefixes = {
    OH58D = "SQ_US_JBAD_OH58D_6_6_CAV_AID-",
    AH64D = "SQ_US_JBAD_AH64D_B_1_10_AVN_AID-",
    UH60 = "SQ_US_JBAD_UH60_UTILITY_MEDEVAC_AID-",
    CH47 = "SQ_US_JBAD_CH47_HEAVYLIFT_AID-"
  },
  DetectedTypes = {
    OH58D = "OH58D", AH64D = "AH-64D_BLK_II",
    UH60 = "UH-60A", CH47 = "CH-47Fbl1"
  },
  PackageContracts = { Squadrons = squadronContracts },
  PlayerGroups = { Required = { OH58D = {}, AH64D = {}, CH47 = {} } },
  Statics = { OH58D = {}, AH64D = {}, UH60 = {}, CH47 = {} },
  Squadrons = {}
}

function cfg:GetTestPackageContract(testId) return testPackages[testId] end
function cfg:GetSquadronContract(key) return squadronContracts[key] end
function cfg:GetLogisticsProfile(name) return name and { Name = name } or nil end

OMW = { AirOps = { Jalalabad = cfg } }

local sourceRoot = "mission/tests/jalalabad-air-operations/src/"
local sources = {
  "11-phase1-test-manifest.lua",
  "12-phase1-runtime-observer.lua",
  "12a-phase1-moose-logistics.lua",
  "13-phase1-mission-factory.lua",
  "14-phase1-test-controller.lua",
  "15-phase1-f10-and-acceptance.lua",
  "16-phase1-moose-first-readiness-routing.lua"
}

for _, fileName in ipairs(sources) do
  local path = sourceRoot .. fileName
  local chunk, loadError = loadfile(path)
  if not chunk then fail("loadfile " .. path .. ": " .. tostring(loadError)) end
  local ok, runtimeError = xpcall(chunk, debug.traceback)
  if not ok then fail("runtime " .. path .. ": " .. tostring(runtimeError)) end
end

local ph1 = cfg.Phase1
assertTrue(ph1 ~= nil, "Phase1 table was not created")
assertTrue(ph1.ManifestOK == true, "manifest did not validate")
assertTrue(ph1.Observer ~= nil, "observer was not created")
assertTrue(ph1.Logistics ~= nil, "logistics adapter was not created")
assertTrue(ph1.Factory ~= nil, "factory was not created")
assertTrue(ph1.Controller ~= nil, "controller was not created")
assertTrue(ph1.Routing ~= nil, "routing module was not created")
assertTrue(ph1.MenuCreated == true, "F10 menu was not created immediately")
assertEqual(menuCount, 2, "F10 menu count")
assertEqual(commandCount, 8, "F10 command count")
assertTrue(ph1.Observer.AirwingHookAttached ~= true, "AIRWING hook attached before AIRWING existed")

local previousCallbackCount = 0
local airwing = {
  OnAfterFlightOnMission = function() previousCallbackCount = previousCallbackCount + 1 end
}
cfg.Airwing = airwing

assertTrue(ph1.Observer:AttachAirwing(airwing), "deferred AIRWING hook attachment failed")
assertTrue(ph1.Observer.AirwingHookAttached == true, "AIRWING hook flag missing")
assertTrue(ph1.Observer.AttachedAirwing == airwing, "wrong AIRWING object attached")
assertTrue(type(airwing.OnAfterFlightOnMission) == "function", "AIRWING callback missing")
assertTrue(ph1.Observer:AttachAirwing(airwing), "idempotent AIRWING hook attachment failed")

airwing:OnAfterFlightOnMission("FROM", "FlightOnMission", "TO", nil, {})
assertEqual(previousCallbackCount, 1, "previous AIRWING callback was not preserved")

assertTrue(logContains("PH1.MANIFEST] READY"), "manifest READY marker missing")
assertTrue(logContains("PH1.OBS] READY"), "observer READY marker missing")
assertTrue(logContains("AIRWING_HOOK READY"), "AIRWING hook READY marker missing")
assertTrue(logContains("PH1.LOGISTICS] READY"), "logistics READY marker missing")
assertTrue(logContains("PH1.FACTORY] READY"), "factory READY marker missing")
assertTrue(logContains("PH1] READY controllerRole="), "controller READY marker missing")
assertTrue(logContains("PH1.MENU] READY F10="), "F10 READY marker missing")
assertTrue(logContains("commands=8 availability=IMMEDIATE baselineIndependent=true"), "immediate F10 contract marker missing")
assertTrue(logContains("PH1.ROUTING] READY"), "routing READY marker missing")

print(string.format("PHASE1_INIT_SMOKE_PASS menus=%d commands=%d scheduled=%d", menuCount, commandCount, #scheduled))
