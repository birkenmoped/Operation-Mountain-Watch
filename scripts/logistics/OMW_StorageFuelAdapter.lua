-- Operation Mountain Watch - CampaignState to MOOSE STORAGE fuel mirror adapter.
--
-- This module does not own strategic resources. The caller supplies an authoritative
-- CampaignState-compatible snapshot and explicitly chooses whether to apply it to
-- the operational DCS warehouse mirror.

local StorageFuelAdapter = {}

local TAG = "[OMW][Logistics.StorageFuelAdapter]"

StorageFuelAdapter.ResourceId = {
  JP8 = "FUEL_JP8",
  AVGAS = "FUEL_AVGAS",
}

local function log(message)
  if env and env.info then
    env.info(TAG .. " " .. tostring(message))
  end
end

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function isFiniteNonNegative(value)
  return type(value) == "number"
    and value == value
    and value >= 0
    and value < math.huge
end

local function requireMooseStorageApi()
  if type(STORAGE) ~= "table" then
    fail("MOOSE STORAGE class is unavailable")
  end
  if type(STORAGE.FindByName) ~= "function" then
    fail("STORAGE:FindByName() is unavailable")
  end
  if type(STORAGE.Liquid) ~= "table"
    or STORAGE.Liquid.JETFUEL == nil
    or STORAGE.Liquid.GASOLINE == nil then
    fail("Required STORAGE liquid enumerators are unavailable")
  end
end

local function resourceMapping()
  requireMooseStorageApi()
  return {
    [StorageFuelAdapter.ResourceId.JP8] = STORAGE.Liquid.JETFUEL,
    [StorageFuelAdapter.ResourceId.AVGAS] = STORAGE.Liquid.GASOLINE,
  }
end

local function validateSnapshot(snapshot)
  if type(snapshot) ~= "table" then
    fail("Authoritative snapshot must be a table")
  end
  if type(snapshot.nodeId) ~= "string" or snapshot.nodeId == "" then
    fail("Authoritative snapshot requires nodeId")
  end
  if type(snapshot.airbaseName) ~= "string" or snapshot.airbaseName == "" then
    fail("Authoritative snapshot requires airbaseName")
  end
  if type(snapshot.resourcesKg) ~= "table" then
    fail("Authoritative snapshot requires resourcesKg")
  end

  local mapping = resourceMapping()
  local count = 0
  for resourceId, quantityKg in pairs(snapshot.resourcesKg) do
    if mapping[resourceId] == nil then
      fail("Unsupported strategic resourceId=" .. tostring(resourceId))
    end
    if not isFiniteNonNegative(quantityKg) then
      fail("Invalid non-negative kg quantity for resourceId=" .. tostring(resourceId))
    end
    count = count + 1
  end

  if count == 0 then
    fail("Authoritative snapshot contains no supported fuel resources")
  end

  return mapping
end

local function resolveStorage(airbaseName)
  requireMooseStorageApi()

  local storage = STORAGE:FindByName(airbaseName)
  if not storage and AIRBASE and AIRBASE.FindByName then
    local airbase = AIRBASE:FindByName(airbaseName)
    if airbase and airbase.GetStorage then
      storage = airbase:GetStorage()
    end
  end

  if not storage then
    fail("No MOOSE STORAGE wrapper found for airbaseName=" .. tostring(airbaseName))
  end
  if type(storage.GetLiquidAmount) ~= "function" or type(storage.SetLiquid) ~= "function" then
    fail("Resolved STORAGE wrapper lacks required liquid read/write methods")
  end

  return storage
end

local function readAmount(storage, liquidType, nodeId, resourceId)
  local ok, amount = pcall(function()
    return storage:GetLiquidAmount(liquidType)
  end)
  if not ok then
    fail(string.format(
      "STORAGE read failed nodeId=%s resourceId=%s error=%s",
      tostring(nodeId),
      tostring(resourceId),
      tostring(amount)
    ))
  end
  if not isFiniteNonNegative(amount) then
    fail(string.format(
      "STORAGE returned invalid quantity nodeId=%s resourceId=%s value=%s",
      tostring(nodeId),
      tostring(resourceId),
      tostring(amount)
    ))
  end
  return amount
end

function StorageFuelAdapter.GetResourceMapping()
  local mapping = resourceMapping()
  return {
    [StorageFuelAdapter.ResourceId.JP8] = mapping[StorageFuelAdapter.ResourceId.JP8],
    [StorageFuelAdapter.ResourceId.AVGAS] = mapping[StorageFuelAdapter.ResourceId.AVGAS],
  }
end

function StorageFuelAdapter.ReadNode(nodeId, airbaseName)
  if type(nodeId) ~= "string" or nodeId == "" then
    fail("ReadNode requires nodeId")
  end
  if type(airbaseName) ~= "string" or airbaseName == "" then
    fail("ReadNode requires airbaseName")
  end

  local mapping = resourceMapping()
  local storage = resolveStorage(airbaseName)
  local observed = {
    nodeId = nodeId,
    airbaseName = airbaseName,
    resourcesKg = {},
  }

  for _, resourceId in ipairs({ StorageFuelAdapter.ResourceId.JP8, StorageFuelAdapter.ResourceId.AVGAS }) do
    observed.resourcesKg[resourceId] = readAmount(storage, mapping[resourceId], nodeId, resourceId)
  end

  return observed
end

function StorageFuelAdapter.PlanSnapshot(snapshot)
  local mapping = validateSnapshot(snapshot)
  local storage = resolveStorage(snapshot.airbaseName)
  local plan = {
    nodeId = snapshot.nodeId,
    airbaseName = snapshot.airbaseName,
    entries = {},
    changeCount = 0,
  }

  for _, resourceId in ipairs({ StorageFuelAdapter.ResourceId.JP8, StorageFuelAdapter.ResourceId.AVGAS }) do
    local desiredKg = snapshot.resourcesKg[resourceId]
    if desiredKg ~= nil then
      local observedKg = readAmount(storage, mapping[resourceId], snapshot.nodeId, resourceId)
      local deltaKg = desiredKg - observedKg
      if deltaKg ~= 0 then
        plan.changeCount = plan.changeCount + 1
      end
      plan.entries[#plan.entries + 1] = {
        resourceId = resourceId,
        liquidType = mapping[resourceId],
        desiredKg = desiredKg,
        observedKg = observedKg,
        deltaKg = deltaKg,
      }
    end
  end

  log(string.format(
    "PLAN nodeId=%s airbaseName=%s entries=%d changes=%d",
    tostring(plan.nodeId),
    tostring(plan.airbaseName),
    #plan.entries,
    plan.changeCount
  ))

  return plan
end

function StorageFuelAdapter.ApplySnapshot(snapshot)
  local plan = StorageFuelAdapter.PlanSnapshot(snapshot)
  local storage = resolveStorage(snapshot.airbaseName)

  for _, entry in ipairs(plan.entries) do
    if entry.deltaKg ~= 0 then
      local ok, result = pcall(function()
        return storage:SetLiquid(entry.liquidType, entry.desiredKg)
      end)
      if not ok then
        fail(string.format(
          "STORAGE write failed nodeId=%s resourceId=%s desiredKg=%s error=%s",
          tostring(snapshot.nodeId),
          tostring(entry.resourceId),
          tostring(entry.desiredKg),
          tostring(result)
        ))
      end
    end
  end

  local verified = true
  local readback = {}
  for _, entry in ipairs(plan.entries) do
    local actualKg = readAmount(storage, entry.liquidType, snapshot.nodeId, entry.resourceId)
    readback[entry.resourceId] = actualKg
    if actualKg ~= entry.desiredKg then
      verified = false
    end
  end

  log(string.format(
    "APPLY nodeId=%s airbaseName=%s changes=%d verified=%s",
    tostring(snapshot.nodeId),
    tostring(snapshot.airbaseName),
    plan.changeCount,
    tostring(verified)
  ))

  return {
    nodeId = snapshot.nodeId,
    airbaseName = snapshot.airbaseName,
    plan = plan,
    readbackKg = readback,
    verified = verified,
  }
end

return StorageFuelAdapter
