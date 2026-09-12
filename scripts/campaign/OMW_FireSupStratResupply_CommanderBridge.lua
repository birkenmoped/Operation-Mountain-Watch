-- Operation Mountain Watch - Fire Support / Strategic Resupply COMMANDER bridge.

local Bridge = {}
local Instance = {}
Instance.__index = Instance

Bridge.Kind = { MISSION = "MISSION", TRANSPORT = "TRANSPORT" }

local function fail(message)
  error("[OMW][FireSupStratResupply.CommanderBridge] " .. tostring(message), 2)
end

function Bridge.New(spec)
  if type(spec) ~= "table" then fail("spec must be a table") end
  if type(spec.commander) ~= "table" then fail("commander must be a table") end
  if type(spec.factory) ~= "function" then fail("factory must be a function") end
  local kind = spec.kind or Bridge.Kind.MISSION
  if kind == Bridge.Kind.MISSION and type(spec.commander.AddMission) ~= "function" then fail("commander.AddMission() is required") end
  if kind == Bridge.Kind.TRANSPORT and type(spec.commander.AddOpsTransport) ~= "function" then fail("commander.AddOpsTransport() is required") end
  if kind ~= Bridge.Kind.MISSION and kind ~= Bridge.Kind.TRANSPORT then fail("invalid kind") end
  return setmetatable({ commander=spec.commander, factory=spec.factory, kind=kind, items={} }, Instance)
end

function Instance:Dispatch(demand, context)
  if type(demand) ~= "table" or type(demand.demandId) ~= "string" or demand.demandId == "" then fail("demandId is required") end
  if self.items[demand.demandId] then return self.items[demand.demandId], false, "ALREADY_DISPATCHED" end
  local runtime = self.factory(demand, context)
  if type(runtime) ~= "table" or type(runtime.Cancel) ~= "function" then fail("factory runtime must expose Cancel()") end
  if self.kind == Bridge.Kind.MISSION then self.commander:AddMission(runtime) else self.commander:AddOpsTransport(runtime) end
  local handle = { runtime=runtime, cancelRequested=false }
  function handle:Cancel()
    if self.cancelRequested then return false end
    self.cancelRequested=true
    self.runtime:Cancel()
    return true
  end
  self.items[demand.demandId]=handle
  return handle, true, nil
end

return Bridge
