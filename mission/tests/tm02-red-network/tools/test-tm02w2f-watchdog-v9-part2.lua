local proxyTask = addTask("STATIC-PROXY", 0, 1, false, 4)
initialize(proxyTask)
for expected = 1, config.watchdog.routeRefreshAttempts do
  local group = proxyTask.proxyGroup
  triggerConfirmedStall(proxyTask)
  assert(proxyTask.proxyGroup == group,
    "route refresh must retain the same proxy")
  assert(proxyTask.w2fProgressWatchdog.routeRefreshes == expected,
    "route refresh count mismatch")
  assert(proxyTask.navigationState == "RECOVERING_ROUTE_REFRESH",
    "route refresh state missing")
end
for expected = 1, config.watchdog.localDetourAttempts do
  local group = proxyTask.proxyGroup
  triggerConfirmedStall(proxyTask)
  assert(proxyTask.proxyGroup == group,
    "local detour must retain the same proxy")
  assert(proxyTask.w2fProgressWatchdog.localDetours == expected,
    "local detour count mismatch")
  assert(group.lastWaypoints and #group.lastWaypoints == 3,
    "local detour must use three waypoints")
  assert(proxyTask.navigationState == "RECOVERING_LOCAL_DETOUR",
    "local detour state missing")
end

local oldProxy = proxyTask.proxyGroup
triggerConfirmedStall(proxyTask)
assert(proxyTask.proxyGroup ~= oldProxy,
  "clear unobserved proxy must relocate after route and detour attempts")
assert(oldProxy.destroyed == true, "old proxy was not removed")
assert(proxyTask.proxyGroup:CountAliveUnits() == 1,
  "packed recovery must remain one-man proxy")
assert(math.abs(proxyTask.proxyGroup:GetCoordinate().x
    - config.watchdog.proxyRelocationAdvanceMeters) < 0.01,
  "proxy relocation distance mismatch")
assert(proxyTask.w2fProgressWatchdog.episodeRelocations == 1,
  "proxy episode relocation count mismatch")
assert(proxyTask.w2fProgressWatchdog.legRelocations == 1,
  "proxy leg relocation count mismatch")

proxyTask.proxyGroup.coordinate.x = proxyTask.proxyGroup.coordinate.x
  + config.watchdog.recoveryCreditProgressMeters
now = now + 1
watchdog.tick()
assert(proxyTask.w2fProgressWatchdog.episodeRelocations == 0,
  "150 m real progress must restore one episode recovery credit")
assert(proxyTask.w2fProgressWatchdog.legRelocations == 1,
  "real progress must not reset the hard leg relocation count")
proxyTask.movementState = "ARRIVED"

local exposedTask = addTask("STATIC-EXPOSED", 0, 1, false, 2)
exposureMode = "PLAYER_AIR"
initialize(exposedTask)
local exposedMonitor = exposedTask.w2fProgressWatchdog
exposedMonitor.routeRefreshes = config.watchdog.routeRefreshAttempts
exposedMonitor.localDetours = config.watchdog.localDetourAttempts
exposedMonitor.graceUntil = now
exposedMonitor.nextRecoveryAt = now
local exposedGroup = exposedTask.proxyGroup
triggerConfirmedStall(exposedTask)
assert(exposedTask.proxyGroup == exposedGroup,
  "exposed proxy must not be relocated")
assert(exposedMonitor.episodeRelocations == 0,
  "deferred exposure must not consume relocation credit")
assert(exposedTask.navigationState == "RECOVERY_DEFERRED_EXPOSED",
  "exposure defer state missing")

exposureMode = "CLEAR"
exposedMonitor.exposureLastScan = -math.huge
now = now + config.watchdog.exposureScanIntervalSeconds
watchdog.tick()
exposedMonitor.exposureClearSince = now - config.watchdog.exposureClearSeconds
exposedMonitor.graceUntil = now
exposedMonitor.nextRecoveryAt = now
triggerConfirmedStall(exposedTask)
assert(exposedTask.proxyGroup ~= exposedGroup,
  "proxy must relocate after the exposure-clear interval")
assert(exposedMonitor.episodeRelocations == 1,
  "clear relocation must consume one episode credit")
exposedTask.movementState = "ARRIVED"

local fullTask = addTask("STATIC-FULL", 0, 3, true, 4)
exposureMode = "CLEAR"
initialize(fullTask)
local fullMonitor = fullTask.w2fProgressWatchdog
fullMonitor.routeRefreshes = config.watchdog.routeRefreshAttempts
fullMonitor.localDetours = config.watchdog.localDetourAttempts
fullMonitor.exposureClearSince = now - config.watchdog.exposureClearSeconds
fullMonitor.exposed = false
fullMonitor.graceUntil = now
fullMonitor.nextRecoveryAt = now
local oldFullGroup = fullTask.proxyGroup
triggerConfirmedStall(fullTask)
assert(fullTask.survivorCount == 3,
  "full-group losses must be recorded before relocation")
assert(executionState.totalLosses == 1,
  "full-group loss accounting mismatch")
assert(fullTask.proxyGroup ~= oldFullGroup,
  "clear full group must receive bounded relocation")
assert(fullTask.proxyGroup:CountAliveUnits() == 3,
  "full-group relocation must preserve surviving strength")
assert(math.abs(fullTask.proxyGroup:GetCoordinate().x
    - config.watchdog.fullGroupRelocationAdvanceMeters) < 0.01,
  "full-group relocation distance mismatch")
assert(fullTask.transitExpanded == true,
  "watchdog must preserve full-group representation")
fullTask.movementState = "ARRIVED"

local roadTask = addTask("STATIC-ROAD-FAIL", 0, 1, false, 2, 500)
initialize(roadTask)
local roadMonitor = roadTask.w2fProgressWatchdog
roadMonitor.routeRefreshes = config.watchdog.routeRefreshAttempts
roadMonitor.localDetours = config.watchdog.localDetourAttempts
roadMonitor.episodeRelocations = config.watchdog.proxyMaxRelocationsPerEpisode
roadMonitor.legRelocations = config.watchdog.proxyMaxRelocationsPerEpisode
roadMonitor.exposureClearSince = now - config.watchdog.exposureClearSeconds
roadMonitor.exposed = false
roadMonitor.graceUntil = now
roadMonitor.nextRecoveryAt = now
triggerConfirmedStall(roadTask)
assert(roadTask.navigationState == "RECOVERY_EXHAUSTED_WAIT",
  "unavailable road recovery must enter retry wait")
assert(roadMonitor.roadRecoveryUsed == false,
  "failed road lookup must not consume road recovery")
assert(roadMonitor.waitUntil > now,
  "retry wait deadline missing")
local previousEpisode = roadMonitor.episode
now = roadMonitor.waitUntil + 1
watchdog.tick()
assert(roadMonitor.episode == previousEpisode + 1,
  "exhausted recovery must reopen after backoff")
assert(roadMonitor.routeRefreshes == 0 and roadMonitor.localDetours == 0,
  "new episode must restart non-teleport recovery stages")
assert(roadTask.navigationState == "DIRECT_OFFROAD",
  "reopened episode must leave wait state")
roadTask.movementState = "ARRIVED"

local offRouteTerminalTask = addTaskAt(
  "STATIC-TERMINAL-OFF-ROUTE", 1950, 500, 1, false, 2)
initialize(offRouteTerminalTask)
local offRouteMonitor = offRouteTerminalTask.w2fProgressWatchdog
offRouteMonitor.routeRefreshes = config.watchdog.routeRefreshAttempts
offRouteMonitor.localDetours = config.watchdog.localDetourAttempts
offRouteMonitor.exposureClearSince = now - config.watchdog.exposureClearSeconds
offRouteMonitor.exposed = false
offRouteMonitor.graceUntil = now
offRouteMonitor.nextRecoveryAt = now
triggerConfirmedStall(offRouteTerminalTask)
assert(offRouteMonitor.terminalRecoveryUsed == false,
  "projected remaining distance must not authorize terminal relocation")
assert(offRouteTerminalTask.navigationState == "RECOVERING_DIRECT_OFFROAD_RELOCATION",
  "off-route task must use normal bounded relocation instead of terminal relocation")
offRouteTerminalTask.movementState = "ARRIVED"

local trueTerminalTask = addTaskAt(
  "STATIC-TERMINAL-PHYSICAL", 1930, 0, 1, false, 2)
initialize(trueTerminalTask)
local trueTerminalMonitor = trueTerminalTask.w2fProgressWatchdog
trueTerminalMonitor.routeRefreshes = config.watchdog.routeRefreshAttempts
trueTerminalMonitor.localDetours = config.watchdog.localDetourAttempts
trueTerminalMonitor.exposureClearSince = now - config.watchdog.exposureClearSeconds
trueTerminalMonitor.exposed = false
trueTerminalMonitor.graceUntil = now
trueTerminalMonitor.nextRecoveryAt = now
triggerConfirmedStall(trueTerminalTask)
assert(trueTerminalMonitor.terminalRecoveryUsed == true,
  "physical distance inside 100 m must authorize terminal relocation")
assert(math.abs(trueTerminalTask.proxyGroup:GetCoordinate().x - 1975) < 0.01,
  "terminal relocation must stop 25 m before the target")
trueTerminalTask.movementState = "ARRIVED"

now = 5000
local nextAt = scheduledCallback(nil, 0)
assert(nextAt == now + config.watchdog.sampleIntervalSeconds,
  "watchdog timer must schedule from current mission time")

local watchdogSource = assert(io.open(
  repositoryRoot .. "/mission/tests/tm02-red-network/src/tm02w2f-progress-watchdog-v9.lua",
  "rb"
)):read("*a")
assert(not watchdogSource:find("scheduledTime%s*%+", 1),
  "stale scheduledTime catch-up scheduling is forbidden")
assert(not watchdogSource:find("convertTaskForRecovery", 1, true),
  "watchdog must never call pack/unpack recovery APIs")
assert(not watchdogSource:find("transitRepresentation", 1, true),
  "watchdog must be independent of manual representation controls")
assert(not watchdogSource:find("NAVIGATION_BLOCKED", 1, true),
  "permanent NAVIGATION_BLOCKED is forbidden")
assert(watchdogSource:find("RECOVERY_EXHAUSTED_WAIT", 1, true),
  "retryable exhausted recovery state missing")
assert(watchdogSource:find("recovery_deferred_exposed", 1, true),
  "exposure guard logging missing")

print("TM02W2F watchdog 9 PASS: refresh=2 detour=4 proxy=75m full=40m exposure-defer credits wait-retry physical-terminal-gate")
