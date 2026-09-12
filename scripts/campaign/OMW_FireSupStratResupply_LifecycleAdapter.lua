-- Operation Mountain Watch - Fire Support / Strategic Resupply lifecycle adapter.
--
-- Minimal event-bound coordinator. It owns no scheduler, retry loop, asset selection,
-- MOOSE queue or strategic resource state. Runtime handles must expose public Cancel().

local Adapter = {}
local Instance = {}
Instance.__index = Instance

Adapter.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-LIFECYCLE-ADAPTER-1"

local TAG = "[OMW][FireSupStratResupply.LifecycleAdapter]"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end

local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then
    fail(label .. " requires non-empty string")
  end
  return value
end

function Adapter.New(spec)
  spec = spec or {}
  if type(spec) ~= "table" then fail("spec must be a table") end
  if spec.logger ~= nil and type(spec.logger) ~= "function" then fail("logger must be a function when provided") end

  return setmetatable({
    logger = spec.logger,
    entries = {},
  }, Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:Register(demandId, runtimeHandle)
  requireNonEmptyString(demandId, "demandId")
  if type(runtimeHandle) ~= "table" or type(runtimeHandle.Cancel) ~= "function" then
    fail("runtimeHandle.Cancel() is required")
  end

  local existing = self.entries[demandId]
  if existing then
    if existing.runtimeHandle ~= runtimeHandle then
      fail("demandId already registered with a different runtime handle: " .. demandId)
    end
    return existing, false, "ALREADY_REGISTERED"
  end

  local entry = {
    demandId = demandId,
    runtimeHandle = runtimeHandle,
    cancelRequested = false,
    cancelReason = nil,
  }
  self.entries[demandId] = entry
  self:_log("registered demandId=" .. demandId)
  return entry, true, nil
end

function Instance:Cancel(demandId, reason)
  requireNonEmptyString(demandId, "demandId")
  local entry = self.entries[demandId]
  if not entry then return nil, false, "NOT_REGISTERED" end
  if entry.cancelRequested then return entry.runtimeHandle, false, "CANCEL_ALREADY_REQUESTED" end

  entry.cancelRequested = true
  entry.cancelReason = tostring(reason or "UNSPECIFIED")
  entry.runtimeHandle:Cancel(entry.cancelReason)
  self:_log("cancel forwarded demandId=" .. demandId .. " reason=" .. entry.cancelReason)
  return entry.runtimeHandle, true, nil
end

function Instance:Get(demandId)
  requireNonEmptyString(demandId, "demandId")
  return self.entries[demandId]
end

return Adapter
