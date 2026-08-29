-- Operation Mountain Watch - resource shortage demand policy.
--
-- Campaign-domain only. This module evaluates CampaignState resource snapshots
-- against existing target/reorder/critical metadata. It does not create MOOSE
-- missions, mutate CampaignState, reserve resources, or invent threshold values.

local Policy = {}

local TAG = "[OMW][ResourceDemandPolicy]"

Policy.SchemaVersion = "OMW-RESOURCE-DEMAND-POLICY-2"

Policy.Level = {
  REORDER = "REORDER",
  CRITICAL = "CRITICAL",
}

Policy.ReorderComparison = {
  AT_OR_BELOW = "AT_OR_BELOW",
  BELOW = "BELOW",
  DISABLED = "DISABLED",
}

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

local function requireNonNegativeNumber(value, label)
  if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
    fail(label .. " requires non-negative finite number")
  end
  return value
end

local function copy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for key, item in pairs(value) do
    result[key] = copy(item)
  end
  return result
end

local function normalizeReorderComparison(value)
  value = value or Policy.ReorderComparison.AT_OR_BELOW
  if value ~= Policy.ReorderComparison.AT_OR_BELOW
      and value ~= Policy.ReorderComparison.BELOW
      and value ~= Policy.ReorderComparison.DISABLED then
    fail("row.reorderComparison requires AT_OR_BELOW, BELOW, or DISABLED")
  end
  return value
end

local function normalizeRow(row)
  if type(row) ~= "table" then
    fail("resource policy row must be a table")
  end

  local normalized = {
    nodeId = requireNonEmptyString(row.nodeId, "row.nodeId"),
    resourceId = requireNonEmptyString(row.resourceId, "row.resourceId"),
    resourceClass = requireNonEmptyString(row.resourceClass, "row.resourceClass"),
    unit = requireNonEmptyString(row.unit or "count", "row.unit"),
    target = requireNonNegativeNumber(row.target, "row.target"),
    reorder = requireNonNegativeNumber(row.reorder, "row.reorder"),
    critical = requireNonNegativeNumber(row.critical, "row.critical"),
    reorderComparison = normalizeReorderComparison(row.reorderComparison),
    supplyParent = requireNonEmptyString(row.supplyParent, "row.supplyParent"),
  }

  if normalized.critical > normalized.reorder
      or normalized.reorder > normalized.target then
    fail(string.format(
      "invalid thresholds nodeId=%s resourceId=%s critical=%s reorder=%s target=%s",
      normalized.nodeId,
      normalized.resourceId,
      tostring(normalized.critical),
      tostring(normalized.reorder),
      tostring(normalized.target)
    ))
  end

  if normalized.reorderComparison == Policy.ReorderComparison.DISABLED
      and (normalized.reorder ~= 0 or normalized.critical ~= 0) then
    fail(string.format(
      "disabled reorder comparison requires zero thresholds nodeId=%s resourceId=%s",
      normalized.nodeId,
      normalized.resourceId
    ))
  end

  return normalized
end

local function dedupeKey(row)
  return table.concat({ "RESUPPLY", row.nodeId, row.resourceId }, "|")
end

local function isAtReorder(row, available)
  if row.reorderComparison == Policy.ReorderComparison.DISABLED or row.reorder <= 0 then
    return false
  end
  if row.reorderComparison == Policy.ReorderComparison.BELOW then
    return available < row.reorder
  end
  return available <= row.reorder
end

function Policy.BuildIndex(rows)
  if type(rows) ~= "table" then
    fail("rows must be a table")
  end

  local index = {}
  for _, source in ipairs(rows) do
    local row = normalizeRow(source)
    local key = row.nodeId .. "\0" .. row.resourceId
    if index[key] then
      fail("duplicate resource policy row nodeId=" .. row.nodeId .. " resourceId=" .. row.resourceId)
    end
    index[key] = row
  end
  return index
end

function Policy.Evaluate(row, resourceSnapshot)
  row = normalizeRow(row)
  if type(resourceSnapshot) ~= "table" then
    fail("resourceSnapshot must be a table")
  end

  if resourceSnapshot.nodeId ~= row.nodeId
      or resourceSnapshot.resourceId ~= row.resourceId then
    fail(string.format(
      "resource snapshot mismatch expected=%s/%s actual=%s/%s",
      row.nodeId,
      row.resourceId,
      tostring(resourceSnapshot.nodeId),
      tostring(resourceSnapshot.resourceId)
    ))
  end

  local available = requireNonNegativeNumber(resourceSnapshot.available, "resourceSnapshot.available")
  local canonicalUnit = requireNonEmptyString(resourceSnapshot.canonicalUnit, "resourceSnapshot.canonicalUnit")
  if canonicalUnit ~= row.unit then
    fail(string.format(
      "resource unit mismatch nodeId=%s resourceId=%s expected=%s actual=%s",
      row.nodeId,
      row.resourceId,
      row.unit,
      canonicalUnit
    ))
  end

  if row.reorderComparison == Policy.ReorderComparison.DISABLED or row.reorder <= 0 then
    return nil
  end

  local level = nil
  if row.critical > 0 and available <= row.critical then
    level = Policy.Level.CRITICAL
  elseif isAtReorder(row, available) then
    level = Policy.Level.REORDER
  end

  if not level then
    return nil
  end

  local requestedQuantity = row.target - available
  if requestedQuantity <= 0 then
    return nil
  end

  return {
    missionType = "RESUPPLY",
    level = level,
    destinationNodeId = row.nodeId,
    destinationResourceId = row.resourceId,
    resourceClass = row.resourceClass,
    canonicalUnit = canonicalUnit,
    supplyParent = row.supplyParent,
    available = available,
    target = row.target,
    reorder = row.reorder,
    critical = row.critical,
    reorderComparison = row.reorderComparison,
    requestedQuantity = requestedQuantity,
    dedupeKey = dedupeKey(row),
  }
end

function Policy.EvaluateAll(store, rows)
  if type(store) ~= "table" or type(store.GetResource) ~= "function" then
    fail("CampaignState store with GetResource() is required")
  end
  if type(rows) ~= "table" then
    fail("rows must be a table")
  end

  local candidates = {}
  for _, source in ipairs(rows) do
    local row = normalizeRow(source)
    local snapshot = store:GetResource(row.nodeId, row.resourceId)
    local candidate = Policy.Evaluate(row, snapshot)
    if candidate then
      candidates[#candidates + 1] = candidate
    end
  end
  return candidates
end

function Policy.CopyCandidate(candidate)
  return copy(candidate)
end

return Policy
