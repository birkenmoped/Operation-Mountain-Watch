-- Operation Mountain Watch - read-only STORAGE weapon consumption correlation harness.
--
-- Intended load order:
--   1. pinned Moose.lua
--   2. OMW_Storage_Weapon_Consumption_Correlation_Test.lua
--
-- The harness observes MOOSE STORAGE weapon inventory only. It performs no
-- STORAGE mutation and no CampaignState mutation.

local TAG = "[OMW][StorageWeaponConsumptionCorrelation]"
local TEST_ID = "STORAGE-WEAPON-CONSUMPTION-CORRELATION-1"
local BASELINE_DELAY_S = 10
local ACTION_OPEN_S = 20
local ACTION_CLOSE_S = 100
local FINAL_SNAPSHOT_S = 110
local POLL_INTERVAL_S = 2

local NODES = {
  { nodeId = "BAGRAM", airbaseName = "Bagram" },
  { nodeId = "JALALABAD", airbaseName = "Jalalabad" },
  { nodeId = "KANDAHAR", airbaseName = "Kandahar" },
  { nodeId = "KANDAHAR_HELIPORT", airbaseName = "Kandahar Heliport" },
  { nodeId = "SALERNO", airbaseName = "FOB Salerno" },
  { nodeId = "TARINKOT", airbaseName = "Tarinkot" },
  { nodeId = "SHINDAND_HELIPORT", airbaseName = "Shindand Heliport" },
}

local state = {
  nodes = {},
  baselineCaptured = false,
  actionWindowOpen = false,
  actionWindowClosed = false,
  deltasObserved = 0,
  deltaKeys = {},
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function copyMap(source)
  local result = {}
  if type(source) == "table" then
    for key, value in pairs(source) do
      result[key] = value
    end
  end
  return result
end

local function readWeapons(storage, nodeId)
  local aircraft, liquids, weapons = storage:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error(string.format(
      "GetInventory returned invalid types nodeId=%s aircraft=%s liquids=%s weapons=%s",
      tostring(nodeId), type(aircraft), type(liquids), type(weapons)
    ))
  end
  return copyMap(weapons)
end

local function resolveNodes()
  local ready = 0
  for _, node in ipairs(NODES) do
    local airbase = AIRBASE:FindByName(node.airbaseName)
    if not airbase then
      error("AIRBASE not found nodeId=" .. tostring(node.nodeId) .. " airbase=" .. tostring(node.airbaseName))
    end
    local fromAirbase = airbase:GetStorage()
    local fromName = STORAGE:FindByName(node.airbaseName)
    if not fromAirbase or not fromName then
      error("STORAGE not found nodeId=" .. tostring(node.nodeId))
    end
    if fromAirbase ~= fromName then
      error("STORAGE wrapper identity mismatch nodeId=" .. tostring(node.nodeId))
    end
    state.nodes[node.nodeId] = {
      config = node,
      storage = fromName,
      previous = nil,
      baseline = nil,
      final = nil,
    }
    ready = ready + 1
    log(string.format("NODE_READY nodeId=%s airbase=%s airbaseId=%s", node.nodeId, node.airbaseName, tostring(airbase:GetID())))
  end
  log(string.format("NODES_READY_PASS nodesExpected=%d nodesReady=%d", #NODES, ready))
end

local function recordDelta(nodeId, item, before, after)
  local delta = after - before
  local key = nodeId .. "|" .. tostring(item) .. "|" .. tostring(before) .. "|" .. tostring(after)
  if not state.deltaKeys[key] then
    state.deltaKeys[key] = true
    state.deltasObserved = state.deltasObserved + 1
    log(string.format(
      "WEAPON_DELTA nodeId=%s item=%s before=%s after=%s delta=%s actionWindowOpen=%s",
      tostring(nodeId), tostring(item), tostring(before), tostring(after), tostring(delta), tostring(state.actionWindowOpen)
    ))
  end
end

local function compareMaps(nodeId, previous, current)
  local seen = {}
  for key, before in pairs(previous or {}) do
    local after = current[key] or 0
    if type(before) == "number" and type(after) == "number" and before ~= after then
      recordDelta(nodeId, key, before, after)
    end
    seen[key] = true
  end
  for key, after in pairs(current or {}) do
    if not seen[key] then
      local before = 0
      if type(after) == "number" and before ~= after then
        recordDelta(nodeId, key, before, after)
      end
    end
  end
end

local function captureBaseline()
  for nodeId, entry in pairs(state.nodes) do
    local weapons = readWeapons(entry.storage, nodeId)
    entry.baseline = weapons
    entry.previous = weapons
    local count = 0
    for _ in pairs(weapons) do count = count + 1 end
    log(string.format("BASELINE_CAPTURED nodeId=%s weaponKeys=%d", tostring(nodeId), count))
  end
  state.baselineCaptured = true
  log("BASELINE_PASS")
end

local function poll()
  if not state.baselineCaptured or state.actionWindowClosed then
    return false
  end
  for nodeId, entry in pairs(state.nodes) do
    local current = readWeapons(entry.storage, nodeId)
    compareMaps(nodeId, entry.previous, current)
    entry.previous = current
  end
  return true
end

local function closeActionWindow()
  state.actionWindowOpen = false
  state.actionWindowClosed = true
  log(string.format("ACTION_WINDOW_CLOSE elapsedS=%d deltasObserved=%d", ACTION_CLOSE_S, state.deltasObserved))
end

local function finalize()
  local nodesReady = 0
  for nodeId, entry in pairs(state.nodes) do
    local current = readWeapons(entry.storage, nodeId)
    compareMaps(nodeId, entry.previous, current)
    entry.final = current
    nodesReady = nodesReady + 1
    log(string.format("FINAL_SNAPSHOT nodeId=%s", tostring(nodeId)))
  end

  local status = nodesReady == #NODES and "PASS" or "FAIL"
  local result = string.format(
    "RESULT testId=%s status=%s nodesExpected=%d nodesReady=%d deltasObserved=%d mutation=false campaignStateMutation=false opstransport=false ctld=false",
    TEST_ID, status, #NODES, nodesReady, state.deltasObserved
  )
  if status == "PASS" then
    log(result)
  else
    fail(result)
  end
end

local function run()
  if not AIRBASE or not STORAGE or not SCHEDULER then
    error("required pinned MOOSE AIRBASE/STORAGE/SCHEDULER classes are unavailable")
  end
  if not AIRBASE.FindByName or not AIRBASE.GetStorage then
    error("required AIRBASE APIs are unavailable")
  end
  if not STORAGE.FindByName or not STORAGE.GetInventory then
    error("required STORAGE read APIs are unavailable")
  end

  log(string.format(
    "TEST_BEGIN testId=%s nodesExpected=%d readOnly=true mutation=false campaignStateMutation=false pollIntervalS=%d actionOpenS=%d actionCloseS=%d finalSnapshotS=%d",
    TEST_ID, #NODES, POLL_INTERVAL_S, ACTION_OPEN_S, ACTION_CLOSE_S, FINAL_SNAPSHOT_S
  ))

  resolveNodes()

  SCHEDULER:New(nil, captureBaseline, {}, BASELINE_DELAY_S)
  SCHEDULER:New(nil, function()
    state.actionWindowOpen = true
    log(string.format("ACTION_WINDOW_OPEN elapsedS=%d instruction=PERFORM_ONE_ISOLATED_APPROVED_AIRCRAFT_PAYLOAD_ACTION", ACTION_OPEN_S))
  end, {}, ACTION_OPEN_S)
  SCHEDULER:New(nil, poll, {}, ACTION_OPEN_S, POLL_INTERVAL_S)
  SCHEDULER:New(nil, closeActionWindow, {}, ACTION_CLOSE_S)
  SCHEDULER:New(nil, finalize, {}, FINAL_SNAPSHOT_S)
end

local ok, err = pcall(run)
if not ok then
  fail(string.format("RESULT testId=%s status=FAIL stage=HARNESS error=%s", TEST_ID, tostring(err)))
end
