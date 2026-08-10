-- Operation Mountain Watch - read-only MOOSE STORAGE weapon/item matrix diagnostic.
--
-- Intended load order:
--   1. pinned Moose.lua
--   2. OMW_Storage_Weapon_Item_Matrix_Test.lua
--
-- This harness does not mutate STORAGE, CampaignState, AIRWING, CTLD or OPSTRANSPORT.

local TAG = "[OMW][StorageWeaponItemMatrix]"
local TEST_ID = "STORAGE-WEAPON-ITEM-MATRIX-1"

local NODES = {
  { nodeId = "BAGRAM", airbaseName = "Bagram" },
  { nodeId = "JALALABAD", airbaseName = "Jalalabad" },
  { nodeId = "KANDAHAR", airbaseName = "Kandahar" },
  { nodeId = "KANDAHAR_HELIPORT", airbaseName = "Kandahar Heliport" },
  { nodeId = "SALERNO", airbaseName = "FOB Salerno" },
  { nodeId = "TARINKOT", airbaseName = "Tarinkot" },
  { nodeId = "SHINDAND_HELIPORT", airbaseName = "Shindand Heliport" },
}

local CANDIDATES = {
  { family = "HELLFIRE", enumPath = "missiles.AGM_114", item = "weapons.missiles.AGM_114" },
  { family = "HELLFIRE", enumPath = "missiles.AGM_114K", item = "weapons.missiles.AGM_114K" },

  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_M151", item = "weapons.nurs.HYDRA_70_M151" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_M151_M433", item = "weapons.nurs.HYDRA_70_M151_M433" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_M229", item = "weapons.nurs.HYDRA_70_M229" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_M259", item = "weapons.nurs.HYDRA_70_M259" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_M274", item = "weapons.nurs.HYDRA_70_M274" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_M282", item = "weapons.nurs.HYDRA_70_M282" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_MK1", item = "weapons.nurs.HYDRA_70_MK1" },
  { family = "HYDRA_70", enumPath = "nurs.HYDRA_70_MK61", item = "weapons.nurs.HYDRA_70_MK61" },

  { family = "AH64_M230_30MM", enumPath = "gunmounts.M230", item = "weapons.gunmounts.M230" },
  { family = "AH64_M230_30MM", enumPath = "shells.M230_30", item = "weapons.shells.M230_30" },
  { family = "AH64_M230_30MM", enumPath = "shells.M230_HEDPM789", item = "weapons.shells.M230_HEDP M789" },
  { family = "AH64_M230_30MM", enumPath = "shells.M230_HEIM799", item = "weapons.shells.M230_HEI M799" },
  { family = "AH64_M230_30MM", enumPath = "shells.M230_TPM788", item = "weapons.shells.M230_TP M788" },

  { family = "A10_GAU8_30MM", enumPath = "shells.GAU8_30_AP", item = "weapons.shells.GAU8_30_AP" },
  { family = "A10_GAU8_30MM", enumPath = "shells.GAU8_30_TP", item = "weapons.shells.GAU8_30_TP" },

  { family = "OH58_M3P_50CAL", enumPath = "gunmounts.OH58D_M3P_L100", item = "weapons.gunmounts.OH58D_M3P_L100" },
  { family = "OH58_M3P_50CAL", enumPath = "gunmounts.OH58D_M3P_L200", item = "weapons.gunmounts.OH58D_M3P_L200" },
  { family = "OH58_M3P_50CAL", enumPath = "gunmounts.OH58D_M3P_L300", item = "weapons.gunmounts.OH58D_M3P_L300" },
  { family = "OH58_M3P_50CAL", enumPath = "gunmounts.OH58D_M3P_L500", item = "weapons.gunmounts.OH58D_M3P_L500" },
  { family = "OH58_M3P_50CAL", enumPath = "shells.M2_12_7", item = "weapons.shells.M2_12_7" },
  { family = "OH58_M3P_50CAL", enumPath = "shells.M2_12_7_T", item = "weapons.shells.M2_12_7_T" },
  { family = "OH58_M3P_50CAL", enumPath = "shells._50Browning_Ball_M2", item = "weapons.shells.50Browning_Ball_M2" },
  { family = "OH58_M3P_50CAL", enumPath = "shells._50Browning_AP_M2", item = "weapons.shells.50Browning_AP_M2" },
  { family = "OH58_M3P_50CAL", enumPath = "shells._50Browning_API_M8", item = "weapons.shells.50Browning_API_M8" },
  { family = "OH58_M3P_50CAL", enumPath = "shells._50Browning_APIT_M20", item = "weapons.shells.50Browning_APIT_M20" },
}

local INVENTORY_PATTERNS = {
  "AGM_114",
  "HYDRA_70",
  "AGR_20",
  "M230",
  "GAU8_30",
  "OH58D_M3P",
  "50Browning",
  "M2_12_7",
}

local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local function fail(message)
  env.error(TAG .. " FAIL " .. tostring(message), false)
end

local function countTable(value)
  local count = 0
  if type(value) == "table" then
    for _ in pairs(value) do
      count = count + 1
    end
  end
  return count
end

local function matchesRelevantPattern(value)
  local text = tostring(value or "")
  for _, pattern in ipairs(INVENTORY_PATTERNS) do
    if string.find(text, pattern, 1, true) then
      return true
    end
  end
  return false
end

local function resolveEnumPath(path)
  local current = ENUMS and ENUMS.Storage and ENUMS.Storage.weapons or nil
  if not current then
    return nil
  end
  for segment in string.gmatch(path, "[^%.]+") do
    if type(current) ~= "table" then
      return nil
    end
    current = current[segment]
    if current == nil then
      return nil
    end
  end
  return current
end

local function validateCandidateEnums()
  for _, candidate in ipairs(CANDIDATES) do
    local enumValue = resolveEnumPath(candidate.enumPath)
    if enumValue ~= candidate.item then
      error(string.format(
        "enum mismatch family=%s path=%s expected=%s actual=%s",
        tostring(candidate.family),
        tostring(candidate.enumPath),
        tostring(candidate.item),
        tostring(enumValue)
      ))
    end
  end
  log(string.format("ENUM_CANDIDATES_PASS count=%d", #CANDIDATES))
end

local function inspectNode(node)
  local airbase = AIRBASE:FindByName(node.airbaseName)
  if not airbase then
    error("AIRBASE not found nodeId=" .. tostring(node.nodeId) .. " airbase=" .. tostring(node.airbaseName))
  end

  local storageFromAirbase = airbase:GetStorage()
  local storageFromName = STORAGE:FindByName(node.airbaseName)
  if not storageFromAirbase or not storageFromName then
    error("STORAGE not found nodeId=" .. tostring(node.nodeId))
  end

  log(string.format("NODE_RESOLVE_PASS nodeId=%s airbase=%s airbaseId=%s", node.nodeId, node.airbaseName, tostring(airbase:GetID())))

  if storageFromAirbase ~= storageFromName then
    error("STORAGE wrapper identity mismatch nodeId=" .. tostring(node.nodeId))
  end
  log(string.format("STORAGE_IDENTITY_PASS nodeId=%s", node.nodeId))

  local aircraft, liquids, weapons = storageFromName:GetInventory()
  if type(aircraft) ~= "table" or type(liquids) ~= "table" or type(weapons) ~= "table" then
    error(string.format(
      "GetInventory returned invalid types nodeId=%s aircraft=%s liquids=%s weapons=%s",
      node.nodeId,
      type(aircraft),
      type(liquids),
      type(weapons)
    ))
  end

  local weaponKeyCount = countTable(weapons)
  log(string.format("INVENTORY_READ_PASS nodeId=%s weaponKeys=%d interpretation=RAW_ONLY", node.nodeId, weaponKeyCount))

  local relevantKeys = 0
  for key, amount in pairs(weapons) do
    if matchesRelevantPattern(key) then
      relevantKeys = relevantKeys + 1
      log(string.format("INVENTORY_MATCH nodeId=%s item=%s amount=%s", node.nodeId, tostring(key), tostring(amount)))
    end
  end
  log(string.format("INVENTORY_MATCH_SUMMARY nodeId=%s relevantKeys=%d", node.nodeId, relevantKeys))

  for _, candidate in ipairs(CANDIDATES) do
    local amount = storageFromName:GetItemAmount(candidate.item)
    if type(amount) ~= "number" then
      error(string.format(
        "candidate item returned non-number nodeId=%s family=%s item=%s actualType=%s",
        node.nodeId,
        candidate.family,
        candidate.item,
        type(amount)
      ))
    end
    log(string.format(
      "CANDIDATE_ITEM nodeId=%s family=%s item=%s amount=%s interpretation=RAW_ONLY",
      node.nodeId,
      candidate.family,
      candidate.item,
      tostring(amount)
    ))
  end
  log(string.format("CANDIDATE_READ_PASS nodeId=%s candidates=%d", node.nodeId, #CANDIDATES))
  log(string.format("NODE_PASS nodeId=%s mutation=false", node.nodeId))
end

local function run()
  if not AIRBASE or not STORAGE or not ENUMS or not ENUMS.Storage or not ENUMS.Storage.weapons then
    error("required pinned MOOSE AIRBASE/STORAGE/ENUMS APIs are unavailable")
  end
  if not AIRBASE.FindByName or not AIRBASE.GetStorage then
    error("required AIRBASE APIs are unavailable")
  end
  if not STORAGE.FindByName or not STORAGE.GetInventory or not STORAGE.GetItemAmount then
    error("required STORAGE read APIs are unavailable")
  end

  log(string.format(
    "TEST_BEGIN testId=%s nodesExpected=%d readOnly=true mutation=false campaignStateMutation=false opstransport=false ctld=false",
    TEST_ID,
    #NODES
  ))

  validateCandidateEnums()

  local nodesPassed = 0
  local nodesFailed = 0
  for _, node in ipairs(NODES) do
    local ok, err = pcall(inspectNode, node)
    if ok then
      nodesPassed = nodesPassed + 1
    else
      nodesFailed = nodesFailed + 1
      fail(string.format("NODE_FAIL nodeId=%s error=%s", node.nodeId, tostring(err)))
    end
  end

  local status = nodesFailed == 0 and "PASS" or "FAIL"
  local result = string.format(
    "RESULT testId=%s status=%s nodesExpected=%d nodesPassed=%d nodesFailed=%d mutation=false campaignStateMutation=false opstransport=false ctld=false",
    TEST_ID,
    status,
    #NODES,
    nodesPassed,
    nodesFailed
  )

  if nodesFailed == 0 then
    log(result)
  else
    fail(result)
  end
end

local ok, err = pcall(run)
if not ok then
  fail(string.format("RESULT testId=%s status=FAIL stage=HARNESS error=%s", TEST_ID, tostring(err)))
end
