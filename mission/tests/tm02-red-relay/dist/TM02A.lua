local OMWBuild = {
testId = "TM02",
stageId = "TM02A",
configurationVersion = "TM02A-red-relay-foundation-1",
expectedMooseVersion = "2.9.18",
expectedMooseFileSha256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915",
expectedMooseBuildCommit = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54",
expectedMooseBuildTimestamp = "2026-06-14T16:11:05+02:00",
expectedMooseIncludeFamily = "Moose_Include_Static",
expectedMooseCompression = "none",
mooseVerificationMode = "BUILD_HASH_PLUS_RUNTIME_API_CHECK",
buildTimestamp = "2026-07-17T15:32:45Z",
}
local TM02AConfig = (function()
local config = {
configurationVersion = "TM02A-red-relay-foundation-1",
testId = "TM02",
stageId = "TM02A",
networkId = "TEST.TM02.RELAY.001",
template = {
groupName = "TPL_TEST_RED_PACKET_06_01",
runtimeAlias = "TM02A_RED_RELAY_001",
expectedFighterCount = 6,
},
movement = {
movementId = "TEST.TM02.MOVEMENT.001",
fighterCount = 6,
maxActiveMovements = 1,
},
nodes = {
{
nodeId = "RED_NODE_TM02A_SOURCE",
nodeType = "RED_RELAY_SOURCE",
zoneName = "ZONE_TM02A_SOURCE",
garrisonAlive = 24,
minimumGarrison = 18,
successorNodeId = "RED_NODE_TM02A_DESTINATION",
representationState = "DOMAIN_ONLY",
},
{
nodeId = "RED_NODE_TM02A_DESTINATION",
nodeType = "RED_RELAY_DESTINATION",
zoneName = "ZONE_TM02A_DESTINATION",
garrisonAlive = 6,
minimumGarrison = 12,
successorNodeId = nil,
representationState = "DOMAIN_ONLY",
},
},
transfer = {
sourceNodeId = "RED_NODE_TM02A_SOURCE",
destinationNodeId = "RED_NODE_TM02A_DESTINATION",
},
zones = {
start = "ZONE_TM02A_SOURCE",
routeAnchors = {
"ZONE_TM02A_ROUTE_01",
},
target = "ZONE_TM02A_DESTINATION",
},
routing = {
speedKph = 5,
formation = "ON_ROAD",
roadOnly = true,
},
policy = {
allowNodeSkipping = false,
allowRespawn = false,
allowTeleport = false,
allowAutomaticUnstuck = false,
allowAutomaticReroute = false,
allowVirtualRepresentation = false,
allowHiddenBlueData = false,
},
debug = {
enabled = true,
showMessages = true,
enableF10Menu = true,
},
}
return config
end)()
local SafeReporter = (function()
local SafeReporter = {}
local function sanitize(value)
local ok, text = pcall(tostring, value)
if not ok then
text = "unprintable error"
end
text = string.gsub(text, "[%c]", " ")
return text
end
function SafeReporter.report(event, outcome, detail, prefix)
if type(env) ~= "table" or type(env.info) ~= "function" then
return false
end
local reportPrefix = prefix or "[OMW][TM01A]"
local line = sanitize(reportPrefix) .. " level=ERROR event=" .. sanitize(event)
.. " outcome=" .. sanitize(outcome)
.. " error=" .. sanitize(detail)
env.info(line)
return true
end
return SafeReporter
end)()
local StructuredLogger = (function()
local StructuredLogger = {}
local function formatValue(value)
local text = tostring(value)
text = string.gsub(text, "[\r\n]", " ")
return text
end
local function formatFields(fields)
local keys = {}
local parts = {}
for key in pairs(fields or {}) do
keys[#keys + 1] = key
end
table.sort(keys)
for _, key in ipairs(keys) do
parts[#parts + 1] = tostring(key) .. "=" .. formatValue(fields[key])
end
return table.concat(parts, " ")
end
function StructuredLogger.new(prefix)
local logger = {
prefix = prefix,
}
function logger:write(level, event, fields)
local suffix = formatFields(fields)
local line = self.prefix .. " level=" .. level .. " event=" .. event
if suffix ~= "" then
line = line .. " " .. suffix
end
env.info(line)
end
function logger:info(event, fields)
self:write("INFO", event, fields)
end
function logger:error(event, fields)
self:write("ERROR", event, fields)
end
return logger
end
return StructuredLogger
end)()
local RuntimeGuard = (function()
local RuntimeGuard = {}
local REQUIRED_NATIVE_APIS = {
{ path = "env.info", value = function() return env and env.info end },
{ path = "trigger.action.outText", value = function() return trigger and trigger.action and trigger.action.outText end },
{ path = "timer.getTime", value = function() return timer and timer.getTime end },
}
local REQUIRED_MOOSE_APIS = {
{ path = "GROUP.FindByName", value = function() return GROUP and GROUP.FindByName end },
{ path = "ZONE.FindByName", value = function() return ZONE and ZONE.FindByName end },
{ path = "MENU_MISSION.New", value = function() return MENU_MISSION and MENU_MISSION.New end },
{ path = "MENU_MISSION_COMMAND.New", value = function() return MENU_MISSION_COMMAND and MENU_MISSION_COMMAND.New end },
{ path = "SPAWN.NewWithAlias", value = function() return SPAWN and SPAWN.NewWithAlias end },
{ path = "SPAWN.NewFromTemplate", value = function() return SPAWN and SPAWN.NewFromTemplate end },
{ path = "SPAWN.InitCategory", value = function() return SPAWN and SPAWN.InitCategory end },
{ path = "SPAWN.InitCountry", value = function() return SPAWN and SPAWN.InitCountry end },
{ path = "SPAWN.InitCoalition", value = function() return SPAWN and SPAWN.InitCoalition end },
{ path = "SPAWN.InitSetUnitAbsolutePositions", value = function() return SPAWN and SPAWN.InitSetUnitAbsolutePositions end },
{ path = "SPAWN.Spawn", value = function() return SPAWN and SPAWN.Spawn end },
{ path = "SPAWN.SpawnInZone", value = function() return SPAWN and SPAWN.SpawnInZone end },
{ path = "IDENTIFIABLE.GetName", value = function() return IDENTIFIABLE and IDENTIFIABLE.GetName end },
{ path = "GROUP.IsAlive", value = function() return GROUP and GROUP.IsAlive end },
{ path = "GROUP.CountAliveUnits", value = function() return GROUP and GROUP.CountAliveUnits end },
{ path = "GROUP.IsCompletelyInZone", value = function() return GROUP and GROUP.IsCompletelyInZone end },
{ path = "ZONE_BASE.GetCoordinate", value = function() return ZONE_BASE and ZONE_BASE.GetCoordinate end },
{ path = "COORDINATE.WaypointGround", value = function() return COORDINATE and COORDINATE.WaypointGround end },
{ path = "CONTROLLABLE.Route", value = function() return CONTROLLABLE and CONTROLLABLE.Route end },
}
local function validate(requiredApis)
local missing = {}
for _, api in ipairs(requiredApis) do
local ok, value = pcall(api.value)
if not ok or type(value) ~= "function" then
missing[#missing + 1] = api.path
end
end
return #missing == 0, missing
end
function RuntimeGuard.validateNative()
return validate(REQUIRED_NATIVE_APIS)
end
function RuntimeGuard.validateMoose()
return validate(REQUIRED_MOOSE_APIS)
end
return RuntimeGuard
end)()
local ConfigurationValidator = (function()
local ConfigurationValidator = {}
local function findObject(finder, name)
local ok, object = pcall(finder, name)
if not ok then
return false, object
end
return object ~= nil, nil
end
function ConfigurationValidator.validate(config)
local missing = {}
local errors = {}
local groupFound, groupError = findObject(function(name)
return GROUP:FindByName(name)
end, config.template.groupName)
if not groupFound then
missing[#missing + 1] = config.template.groupName
end
if groupError then
errors[#errors + 1] = config.template.groupName .. ": " .. tostring(groupError)
end
local requiredZones = {
config.zones.start,
config.zones.target,
}
for _, zoneName in ipairs(config.zones.routeAnchors) do
requiredZones[#requiredZones + 1] = zoneName
end
for _, zoneName in ipairs(requiredZones) do
local zoneFound, zoneError = findObject(function(name)
return ZONE:FindByName(name)
end, zoneName)
if not zoneFound then
missing[#missing + 1] = zoneName
end
if zoneError then
errors[#errors + 1] = zoneName .. ": " .. tostring(zoneError)
end
end
return {
valid = #missing == 0 and #errors == 0,
missing = missing,
errors = errors,
checkedObjectCount = 1 + #requiredZones,
}
end
return ConfigurationValidator
end)()
local InMemoryRedCampaignState = (function()
local InMemoryRedCampaignState = {}
local TERMINAL_MOVEMENT_STATES = {
ARRIVED = true,
DESTROYED = true,
}
local function copyTable(source)
local result = {}
for key, value in pairs(source or {}) do
if type(value) == "table" then
result[key] = copyTable(value)
else
result[key] = value
end
end
return result
end
local function requireNumber(value, name)
if type(value) ~= "number" then
error(name .. " must be a number")
end
end
function InMemoryRedCampaignState.new(options)
local config = options.config
local logger = options.logger
local state = {
nodes = {},
movements = {},
activeMovementId = nil,
transferAttempted = false,
initialPersonnelTotal = 0,
}
local function movementFields(movement)
return {
destinationNodeId = movement.destinationNodeId,
fighterCount = movement.fighterCount,
movementId = movement.movementId,
movementState = movement.movementState,
representationState = movement.representationState,
runtimeGroupName = movement.runtimeGroupName or "none",
sourceNodeId = movement.sourceNodeId,
survivorCount = movement.survivorCount,
}
end
local function validateNodeDefinition(node)
if type(node.nodeId) ~= "string" or node.nodeId == "" then
error("nodeId is required")
end
if state.nodes[node.nodeId] then
error("duplicate nodeId: " .. node.nodeId)
end
requireNumber(node.garrisonAlive, node.nodeId .. ".garrisonAlive")
requireNumber(node.minimumGarrison, node.nodeId .. ".minimumGarrison")
if node.garrisonAlive < 0 or node.minimumGarrison < 0 then
error("node personnel values must not be negative: " .. node.nodeId)
end
end
for _, nodeDefinition in ipairs(config.nodes or {}) do
validateNodeDefinition(nodeDefinition)
local node = copyTable(nodeDefinition)
node.availableSurplus = math.max(0, node.garrisonAlive - node.minimumGarrison)
state.nodes[node.nodeId] = node
state.initialPersonnelTotal = state.initialPersonnelTotal + node.garrisonAlive
end
local sourceNode = state.nodes[config.transfer.sourceNodeId]
local destinationNode = state.nodes[config.transfer.destinationNodeId]
if not sourceNode or not destinationNode then
error("configured source or destination node is unavailable")
end
if sourceNode.successorNodeId ~= destinationNode.nodeId then
error("destination is not the direct successor of the source node")
end
if config.policy.allowNodeSkipping ~= false then
error("TM02A requires allowNodeSkipping=false")
end
if config.policy.allowVirtualRepresentation ~= false then
error("TM02A requires allowVirtualRepresentation=false")
end
if config.movement.maxActiveMovements ~= 1 then
error("TM02A requires exactly one active movement slot")
end
if config.movement.fighterCount ~= config.template.expectedFighterCount then
error("movement and template fighter counts differ")
end
local function refreshSurplus(node)
node.availableSurplus = math.max(0, node.garrisonAlive - node.minimumGarrison)
end
local function getMovement()
return state.movements[config.movement.movementId]
end
local function countDomainPersonnel()
local total = 0
for _, node in pairs(state.nodes) do
total = total + node.garrisonAlive
end
local movement = getMovement()
if movement and not TERMINAL_MOVEMENT_STATES[movement.movementState] then
total = total + movement.survivorCount
end
return total
end
function state:validatePersonnelAccounting()
local currentTotal = countDomainPersonnel()
local expectedMaximum = self.initialPersonnelTotal
return currentTotal <= expectedMaximum, currentTotal, expectedMaximum
end
function state:reserveTransfer()
if self.transferAttempted then
return false, "transfer command has already been consumed"
end
if self.activeMovementId then
return false, "an active movement already exists"
end
self.transferAttempted = true
local source = self.nodes[config.transfer.sourceNodeId]
local destination = self.nodes[config.transfer.destinationNodeId]
local fighterCount = config.movement.fighterCount
refreshSurplus(source)
if source.successorNodeId ~= destination.nodeId then
return false, "destination is no longer the direct successor"
end
if source.availableSurplus < fighterCount then
return false, "source node has insufficient surplus"
end
if source.garrisonAlive - fighterCount < source.minimumGarrison then
return false, "reservation would violate the source minimum garrison"
end
source.garrisonAlive = source.garrisonAlive - fighterCount
refreshSurplus(source)
local movement = {
movementId = config.movement.movementId,
sourceNodeId = source.nodeId,
destinationNodeId = destination.nodeId,
fighterCount = fighterCount,
survivorCount = fighterCount,
movementState = "RESERVED",
representationState = "STAGED",
runtimeGroupName = nil,
routeAssigned = false,
arrivalCredited = false,
failureReason = nil,
ownershipNodeId = nil,
}
self.movements[movement.movementId] = movement
self.activeMovementId = movement.movementId
local fields = movementFields(movement)
fields.sourceGarrisonAlive = source.garrisonAlive
fields.sourceMinimumGarrison = source.minimumGarrison
fields.sourceAvailableSurplus = source.availableSurplus
logger:info("red_relay_reserved", fields)
return true, movement
end
function state:markPhysical(runtimeGroupName)
local movement = getMovement()
if not movement then
return false, "movement is unavailable"
end
if movement.movementState ~= "RESERVED" or movement.representationState ~= "STAGED" then
return false, "movement is not staged for physical creation"
end
if type(runtimeGroupName) ~= "string" or runtimeGroupName == "" then
return false, "runtime group name is unavailable"
end
movement.runtimeGroupName = runtimeGroupName
movement.representationState = "PHYSICAL"
movement.movementState = "PHYSICAL_READY"
logger:info("red_relay_physical", movementFields(movement))
return true, movement
end
function state:markEnRoute()
local movement = getMovement()
if not movement then
return false, "movement is unavailable"
end
if movement.movementState ~= "PHYSICAL_READY"
or movement.representationState ~= "PHYSICAL" then
return false, "movement is not ready for routing"
end
movement.routeAssigned = true
movement.movementState = "EN_ROUTE"
logger:info("red_relay_en_route", movementFields(movement))
return true, movement
end
function state:syncSurvivors(observedSurvivorCount)
local movement = getMovement()
if not movement then
return false, "movement is unavailable"
end
requireNumber(observedSurvivorCount, "observedSurvivorCount")
if observedSurvivorCount < 0 then
return false, "observed survivor count is negative"
end
if observedSurvivorCount > movement.survivorCount then
return false, "survivor count increased; resurrection is forbidden"
end
if observedSurvivorCount < movement.survivorCount then
local previous = movement.survivorCount
movement.survivorCount = observedSurvivorCount
logger:info("red_relay_losses_recorded", {
movementId = movement.movementId,
previousSurvivorCount = previous,
survivorCount = observedSurvivorCount,
totalLosses = movement.fighterCount - observedSurvivorCount,
})
end
return true, movement
end
function state:markDestroyed()
local movement = getMovement()
if not movement then
return false, "movement is unavailable"
end
if movement.movementState == "ARRIVED" then
return false, "arrived movement cannot be destroyed by transit reconciliation"
end
movement.survivorCount = 0
movement.movementState = "DESTROYED"
movement.representationState = "DESTROYED"
self.activeMovementId = nil
logger:info("red_relay_destroyed", movementFields(movement))
return true, movement
end
function state:completeArrival()
local movement = getMovement()
if not movement then
return false, "movement is unavailable"
end
if movement.arrivalCredited or movement.movementState == "ARRIVED" then
return false, "arrival has already been credited"
end
if movement.movementState ~= "EN_ROUTE" then
return false, "movement is not en route"
end
if movement.representationState ~= "PHYSICAL" then
return false, "movement is not physically represented"
end
if movement.survivorCount < 1 then
return false, "destroyed movement cannot be credited"
end
local destination = self.nodes[movement.destinationNodeId]
destination.garrisonAlive = destination.garrisonAlive + movement.survivorCount
refreshSurplus(destination)
movement.arrivalCredited = true
movement.movementState = "ARRIVED"
movement.ownershipNodeId = destination.nodeId
self.activeMovementId = nil
local fields = movementFields(movement)
fields.destinationGarrisonAlive = destination.garrisonAlive
fields.destinationMinimumGarrison = destination.minimumGarrison
fields.destinationAvailableSurplus = destination.availableSurplus
logger:info("red_relay_arrival_credited", fields)
return true, movement
end
function state:failMovement(reason)
local movement = getMovement()
if not movement then
return false, "movement is unavailable"
end
if movement.movementState == "ARRIVED" or movement.movementState == "DESTROYED" then
return false, "terminal movement cannot be failed"
end
movement.movementState = "FAILED"
movement.failureReason = tostring(reason)
self.activeMovementId = nil
logger:error("red_relay_failed", movementFields(movement))
return true, movement
end
function state:getMovementSnapshot()
local movement = getMovement()
if not movement then
return nil
end
return copyTable(movement)
end
function state:getStatusSnapshot()
local nodes = {}
for nodeId, node in pairs(self.nodes) do
nodes[nodeId] = copyTable(node)
end
return {
activeMovementId = self.activeMovementId,
initialPersonnelTotal = self.initialPersonnelTotal,
movement = self:getMovementSnapshot(),
nodes = nodes,
transferAttempted = self.transferAttempted,
}
end
return state
end
return InMemoryRedCampaignState
end)()
local PhysicalRelayController = (function()
local PhysicalRelayController = {}
local MOOSE_FORMATIONS = {
ON_ROAD = "On Road",
}
local function display(value)
if value == nil then
return "none"
end
return tostring(value)
end
function PhysicalRelayController.new(options)
local config = options.config
local logger = options.logger
local controller = {
runtimeGroup = nil,
runtimeGroupName = nil,
spawnAttempted = false,
routeAssignmentAttempted = false,
arrivalEventLogged = false,
}
local function announce(text)
options.announce(text)
end
local function commonFields()
local movement = options.campaignState:getMovementSnapshot()
return {
destinationNodeId = config.transfer.destinationNodeId,
movementId = config.movement.movementId,
movementState = movement and movement.movementState or "NONE",
representationState = movement and movement.representationState or "NONE",
runtimeGroupName = controller.runtimeGroupName or "none",
sourceNodeId = config.transfer.sourceNodeId,
}
end
local function fail(reason, event)
local reasonText = tostring(reason)
options.campaignState:failMovement(reasonText)
local fields = commonFields()
fields.reason = reasonText
fields.missionTimeSeconds = timer.getTime()
logger:error(event or "red_relay_start_failed", fields)
announce("RED relay failed: " .. reasonText)
end
local function inspectGroup(group, sourceZone, destinationZone, templateGroup)
return pcall(function()
local destinationZoneMembership = nil
local sourceZoneMembership = nil
local templateAlive = nil
if destinationZone then
destinationZoneMembership = group:IsCompletelyInZone(destinationZone) == true
end
if sourceZone then
sourceZoneMembership = group:IsCompletelyInZone(sourceZone) == true
end
if templateGroup then
templateAlive = templateGroup:IsAlive() == true
end
return {
alive = group:IsAlive() == true,
destinationZoneMembership = destinationZoneMembership,
runtimeGroupName = group:GetName(),
sourceZoneMembership = sourceZoneMembership,
survivorCount = group:CountAliveUnits(),
templateAlive = templateAlive,
}
end)
end
local function buildRoute()
return pcall(function()
local formation = MOOSE_FORMATIONS[config.routing.formation]
if config.routing.roadOnly ~= true or not formation then
error("road-only ON_ROAD routing is required")
end
local zoneNames = {}
for index, zoneName in ipairs(config.zones.routeAnchors) do
zoneNames[index] = zoneName
end
zoneNames[#zoneNames + 1] = config.zones.target
local waypoints = {}
for index, zoneName in ipairs(zoneNames) do
local zone = ZONE:FindByName(zoneName)
if not zone then
error("route zone is unavailable: " .. zoneName)
end
local coordinate = zone:GetCoordinate()
if not coordinate then
error("route-zone coordinate is unavailable: " .. zoneName)
end
local waypoint = coordinate:WaypointGround(
config.routing.speedKph,
formation
)
if type(waypoint) ~= "table" then
error("ground waypoint construction failed: " .. zoneName)
end
waypoints[index] = waypoint
end
return waypoints
end)
end
function controller:startOneTransfer()
local requestFields = commonFields()
requestFields.bootstrapOutcome = options.getBootstrapOutcome()
requestFields.missionTimeSeconds = timer.getTime()
logger:info("red_relay_start_requested", requestFields)
if options.getBootstrapOutcome() ~= "READY" then
announce("RED relay start rejected: bootstrap is not READY")
logger:info("red_relay_start_rejected", {
movementId = config.movement.movementId,
reason = "bootstrap outcome is not READY",
})
return
end
if self.spawnAttempted then
announce("RED relay start rejected: transfer already attempted")
logger:info("red_relay_start_rejected", {
movementId = config.movement.movementId,
reason = "spawn was already attempted",
})
return
end
local reserved, movementOrReason = options.campaignState:reserveTransfer()
if not reserved then
announce("RED relay start rejected: " .. tostring(movementOrReason))
logger:info("red_relay_start_rejected", {
movementId = config.movement.movementId,
reason = movementOrReason,
})
return
end
local lookupOk, lookup = pcall(function()
return {
sourceZone = ZONE:FindByName(config.zones.start),
destinationZone = ZONE:FindByName(config.zones.target),
templateGroup = GROUP:FindByName(config.template.groupName),
}
end)
if not lookupOk then
fail(lookup, "red_relay_object_lookup_failed")
return
end
if not lookup.sourceZone or not lookup.destinationZone or not lookup.templateGroup then
fail("required template or node zone is unavailable", "red_relay_object_lookup_failed")
return
end
local templateCheckOk, templateCheck = pcall(function()
return lookup.templateGroup:IsAlive() == true
end)
if not templateCheckOk then
fail(templateCheck, "red_relay_template_check_failed")
return
end
if templateCheck then
fail("Late Activation template is already active", "red_relay_template_check_failed")
return
end
local spawnerOk, spawnerOrError = pcall(function()
return SPAWN:NewWithAlias(config.template.groupName, config.template.runtimeAlias)
end)
if not spawnerOk or not spawnerOrError then
fail(spawnerOk and "SPAWN construction returned nil" or spawnerOrError)
return
end
self.spawnAttempted = true
local spawnOk, groupOrError = pcall(function()
return spawnerOrError:SpawnInZone(lookup.sourceZone, false)
end)
if not spawnOk or type(groupOrError) ~= "table" then
fail(spawnOk and "SpawnInZone did not return a GROUP wrapper" or groupOrError)
return
end
self.runtimeGroup = groupOrError
local inspectionOk, inspection = inspectGroup(
self.runtimeGroup,
lookup.sourceZone,
lookup.destinationZone,
lookup.templateGroup
)
if not inspectionOk then
fail(inspection, "red_relay_spawn_inspection_failed")
return
end
self.runtimeGroupName = inspection.runtimeGroupName
local physicalMarked, physicalReason = options.campaignState:markPhysical(
self.runtimeGroupName
)
if not physicalMarked then
fail(physicalReason, "red_relay_physical_registration_failed")
return
end
local survivorSynced, survivorReason = options.campaignState:syncSurvivors(
inspection.survivorCount
)
if not survivorSynced then
fail(survivorReason, "red_relay_survivor_sync_failed")
return
end
local failures = {}
if not inspection.alive then
failures[#failures + 1] = "runtime group is not alive"
end
if inspection.survivorCount ~= config.template.expectedFighterCount then
failures[#failures + 1] = "runtime group does not contain exactly six fighters"
end
if inspection.sourceZoneMembership ~= true then
failures[#failures + 1] = "runtime group is not completely inside the source zone"
end
if inspection.templateAlive == true then
failures[#failures + 1] = "original template became active"
end
if type(inspection.runtimeGroupName) ~= "string"
or inspection.runtimeGroupName == ""
or inspection.runtimeGroupName == config.template.groupName then
failures[#failures + 1] = "runtime group name is invalid"
end
if #failures > 0 then
fail(table.concat(failures, ", "), "red_relay_spawn_validation_failed")
return
end
local routeOk, waypointsOrError = buildRoute()
if not routeOk then
fail(waypointsOrError, "red_relay_route_build_failed")
return
end
self.routeAssignmentAttempted = true
local assignmentOk, assignmentResult = pcall(function()
return self.runtimeGroup:Route(waypointsOrError, 0)
end)
if not assignmentOk or not assignmentResult then
fail(
assignmentOk and "route assignment returned nil" or assignmentResult,
"red_relay_route_assignment_failed"
)
return
end
local routeMarked, routeReason = options.campaignState:markEnRoute()
if not routeMarked then
fail(routeReason, "red_relay_route_state_failed")
return
end
local fields = commonFields()
fields.missionTimeSeconds = timer.getTime()
fields.routeAnchorCount = #config.zones.routeAnchors
fields.totalWaypointCount = #waypointsOrError
fields.speedKph = config.routing.speedKph
logger:info("red_relay_started", fields)
announce(
"RED relay started"
.. "\nMovement: " .. config.movement.movementId
.. "\nRuntime group: " .. self.runtimeGroupName
.. "\nFighters: " .. config.movement.fighterCount
.. "\nDestination: " .. config.transfer.destinationNodeId
)
end
function controller:showActiveMovement()
local movement = options.campaignState:getMovementSnapshot()
if not movement then
logger:info("red_relay_movement_status", {
movementId = config.movement.movementId,
movementState = "NONE",
})
announce("No TM02A movement has been created")
return
end
local destinationMembership = nil
local inspectionError = nil
if self.runtimeGroup then
local destinationZone = ZONE:FindByName(config.zones.target)
local inspectionOk, inspection = inspectGroup(
self.runtimeGroup,
nil,
destinationZone,
nil
)
if inspectionOk then
self.runtimeGroupName = inspection.runtimeGroupName or self.runtimeGroupName
destinationMembership = inspection.destinationZoneMembership
local synced = true
local syncReason = nil
if movement.movementState ~= "ARRIVED"
and movement.movementState ~= "DESTROYED" then
synced, syncReason = options.campaignState:syncSurvivors(
inspection.survivorCount
)
end
if not synced then
fail(syncReason, "red_relay_survivor_sync_failed")
elseif inspection.survivorCount < 1
and movement.movementState ~= "ARRIVED"
and movement.movementState ~= "DESTROYED" then
options.campaignState:markDestroyed()
elseif destinationMembership == true
and movement.movementState == "EN_ROUTE" then
local completed, completionReason = options.campaignState:completeArrival()
if completed and not self.arrivalEventLogged then
self.arrivalEventLogged = true
local arrival = options.campaignState:getMovementSnapshot()
logger:info("red_relay_arrived", {
destinationNodeId = arrival.destinationNodeId,
movementId = arrival.movementId,
missionTimeSeconds = timer.getTime(),
runtimeGroupName = arrival.runtimeGroupName,
survivorCount = arrival.survivorCount,
targetZoneMembership = true,
})
elseif not completed then
inspectionError = completionReason
end
end
else
inspectionError = inspection
end
end
movement = options.campaignState:getMovementSnapshot()
local fields = commonFields()
fields.arrivalCredited = movement.arrivalCredited
fields.destinationZoneMembership = destinationMembership == nil
and "unavailable" or destinationMembership
fields.failureReason = movement.failureReason or "none"
fields.missionTimeSeconds = timer.getTime()
fields.routeAssigned = movement.routeAssigned
fields.survivorCount = movement.survivorCount
if inspectionError then
fields.inspectionError = inspectionError
end
logger:info("red_relay_movement_status", fields)
announce(
"Movement: " .. movement.movementId
.. "\nState: " .. movement.movementState
.. "\nRepresentation: " .. movement.representationState
.. "\nRuntime group: " .. display(movement.runtimeGroupName)
.. "\nSurvivors: " .. movement.survivorCount
.. "\nInside destination: " .. display(destinationMembership)
.. "\nArrival credited: " .. tostring(movement.arrivalCredited)
)
end
return controller
end
return PhysicalRelayController
end)()
local TM02AMenu = (function()
local TM02AMenu = {}
function TM02AMenu.create(options)
local rootMenu = MENU_MISSION:New("OMW Tests")
local testMenu = MENU_MISSION:New("TM02A", rootMenu)
MENU_MISSION_COMMAND:New(
"Validate configuration",
testMenu,
options.onValidateConfiguration
)
MENU_MISSION_COMMAND:New(
"Show RED relay status",
testMenu,
options.onShowRelayStatus
)
MENU_MISSION_COMMAND:New(
"Start one relay transfer",
testMenu,
options.onStartTransfer
)
MENU_MISSION_COMMAND:New(
"Show active movement",
testMenu,
options.onShowActiveMovement
)
return {
root = rootMenu,
test = testMenu,
}
end
return TM02AMenu
end)()
local TM02A = (function()
local TM02A = {}
local OUTCOME_READY = "READY"
local OUTCOME_FAIL_CONFIGURATION = "FAIL_CONFIGURATION"
local OUTCOME_FAIL_SCRIPT = "FAIL_SCRIPT"
local function join(values)
if #values == 0 then
return "none"
end
return table.concat(values, ",")
end
function TM02A.start(dependencies)
local build = dependencies.build
local config = dependencies.config
local state = {
outcome = OUTCOME_FAIL_SCRIPT,
detail = "bootstrap not completed",
checkedObjectCount = 0,
}
local nativeValid, missingNativeApis = dependencies.runtimeGuard.validateNative()
if not nativeValid then
state.detail = "required native DCS APIs are unavailable"
dependencies.safeReporter.report(
"native_api_validation_failed",
OUTCOME_FAIL_SCRIPT,
"missing=" .. join(missingNativeApis),
"[OMW][TM02A]"
)
return state
end
local logger = dependencies.structuredLogger.new("[OMW][TM02A]")
local function announce(text)
trigger.action.outText("[OMW][TM02A] " .. text, 20, false)
end
local function setOutcome(outcome, detail)
state.outcome = outcome
state.detail = detail
logger:info("bootstrap_outcome", {
detail = detail,
outcome = outcome,
})
end
local function validateConfiguration()
local ok, result = pcall(dependencies.configurationValidator.validate, config)
if not ok then
setOutcome(OUTCOME_FAIL_SCRIPT, "configuration validation raised an error")
logger:error("configuration_validation_error", { error = result })
return false
end
state.checkedObjectCount = result.checkedObjectCount
if #result.errors > 0 then
setOutcome(OUTCOME_FAIL_SCRIPT, "Mission Editor object lookup failed")
logger:error("configuration_lookup_error", { errors = join(result.errors) })
return false
end
if not result.valid then
setOutcome(OUTCOME_FAIL_CONFIGURATION, "required Mission Editor objects are missing")
logger:error("configuration_invalid", {
checkedObjectCount = result.checkedObjectCount,
missing = join(result.missing),
})
return false
end
logger:info("configuration_valid", {
checkedObjectCount = result.checkedObjectCount,
destinationNodeId = config.transfer.destinationNodeId,
fighterCount = config.movement.fighterCount,
routeAnchorCount = #config.zones.routeAnchors,
sourceNodeId = config.transfer.sourceNodeId,
virtualRepresentationAllowed = config.policy.allowVirtualRepresentation,
})
setOutcome(OUTCOME_READY, "TM02A configuration validation completed")
return true
end
local function protectMenuCallback(commandName, callback)
return function()
local ok, callbackError = pcall(callback)
if not ok then
logger:error("menu_callback_failed", {
command = commandName,
error = callbackError,
outcome = OUTCOME_FAIL_SCRIPT,
})
announce("Menu command failed: " .. commandName)
end
end
end
logger:info("startup", {
buildTimestamp = build.buildTimestamp,
configurationVersion = build.configurationVersion,
dcsVersion = tostring(_G.DCS_VERSION or _G._DCS_VERSION or "unavailable"),
expectedMooseBuildCommit = build.expectedMooseBuildCommit,
expectedMooseBuildTimestamp = build.expectedMooseBuildTimestamp,
expectedMooseCompression = build.expectedMooseCompression,
expectedMooseFileSha256 = build.expectedMooseFileSha256,
expectedMooseIncludeFamily = build.expectedMooseIncludeFamily,
expectedMooseVersion = build.expectedMooseVersion,
missionTimeSeconds = timer.getTime(),
mooseVerificationMode = build.mooseVerificationMode,
stageId = build.stageId,
testId = build.testId,
})
logger:info("native_api_validation_passed", { nativeApiCount = 3 })
local mooseValid, missingMooseApis = dependencies.runtimeGuard.validateMoose()
if not mooseValid then
setOutcome(OUTCOME_FAIL_SCRIPT, "required MOOSE APIs are unavailable")
logger:error("moose_api_validation_failed", { missing = join(missingMooseApis) })
return state
end
logger:info("moose_api_validation_passed", { mooseApiCount = 19 })
local campaignStateOk, campaignStateOrError = pcall(
dependencies.inMemoryRedCampaignState.new,
{
config = config,
logger = logger,
}
)
if not campaignStateOk then
setOutcome(OUTCOME_FAIL_SCRIPT, "CampaignState initialization failed")
logger:error("campaign_state_initialization_failed", {
error = campaignStateOrError,
})
return state
end
local campaignState = campaignStateOrError
local relayController = dependencies.physicalRelayController.new({
announce = announce,
campaignState = campaignState,
config = config,
getBootstrapOutcome = function()
return state.outcome
end,
logger = logger,
})
local function showRelayStatus()
local snapshot = campaignState:getStatusSnapshot()
local source = snapshot.nodes[config.transfer.sourceNodeId]
local destination = snapshot.nodes[config.transfer.destinationNodeId]
local movement = snapshot.movement
local accountingValid, accountedPersonnel, initialPersonnel =
campaignState:validatePersonnelAccounting()
logger:info("red_relay_status", {
accountedPersonnel = accountedPersonnel,
accountingValid = accountingValid,
activeMovementId = snapshot.activeMovementId or "none",
destinationAvailableSurplus = destination.availableSurplus,
destinationGarrisonAlive = destination.garrisonAlive,
destinationMinimumGarrison = destination.minimumGarrison,
initialPersonnel = initialPersonnel,
movementState = movement and movement.movementState or "NONE",
sourceAvailableSurplus = source.availableSurplus,
sourceGarrisonAlive = source.garrisonAlive,
sourceMinimumGarrison = source.minimumGarrison,
transferAttempted = snapshot.transferAttempted,
})
announce(
"Source " .. source.nodeId
.. ": " .. source.garrisonAlive
.. " alive, minimum " .. source.minimumGarrison
.. ", surplus " .. source.availableSurplus
.. "\nDestination " .. destination.nodeId
.. ": " .. destination.garrisonAlive
.. " alive, minimum " .. destination.minimumGarrison
.. ", surplus " .. destination.availableSurplus
.. "\nMovement: " .. (movement and movement.movementState or "NONE")
.. "\nPersonnel accounting valid: " .. tostring(accountingValid)
)
end
local function validateFromMenu()
validateConfiguration()
announce("Outcome: " .. state.outcome .. "\nDetail: " .. state.detail)
end
local menuOk, menuOrError = pcall(dependencies.tm02aMenu.create, {
onShowActiveMovement = protectMenuCallback(
"Show active movement",
function()
relayController:showActiveMovement()
end
),
onShowRelayStatus = protectMenuCallback(
"Show RED relay status",
showRelayStatus
),
onStartTransfer = protectMenuCallback(
"Start one relay transfer",
function()
relayController:startOneTransfer()
end
),
onValidateConfiguration = protectMenuCallback(
"Validate configuration",
validateFromMenu
),
})
if not menuOk then
setOutcome(OUTCOME_FAIL_SCRIPT, "F10 menu creation failed")
logger:error("menu_creation_failed", { error = menuOrError })
return state
end
state.menu = menuOrError
state.campaignState = campaignState
state.relayController = relayController
logger:info("menu_ready", { path = "OMW Tests / TM02A" })
validateConfiguration()
return state
end
return TM02A
end)()
local entryOk, entryResult = pcall(function()
return TM02A.start({
build = OMWBuild,
config = TM02AConfig,
safeReporter = SafeReporter,
structuredLogger = StructuredLogger,
runtimeGuard = RuntimeGuard,
configurationValidator = ConfigurationValidator,
inMemoryRedCampaignState = InMemoryRedCampaignState,
physicalRelayController = PhysicalRelayController,
tm02aMenu = TM02AMenu,
})
end)
local TM02AState = entryResult
if not entryOk then
SafeReporter.report("bootstrap_uncaught_error", "FAIL_SCRIPT", entryResult, "[OMW][TM02A]")
TM02AState = {
outcome = "FAIL_SCRIPT",
detail = "bootstrap raised an uncaught error",
}
end
