-- Operation Mountain Watch - Stage 2B MissionDemand -> MOOSE AIRWING CAS adapter.
--
-- MissionDemand remains the assignment/status authority. AIRWING/SQUADRON/AUFTRAG
-- remain the operational execution path. This adapter owns no strategic resources.

local Adapter = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobAttackCasDispatchAdapter]"
Adapter.SchemaVersion = "OMW-FOB-ATTACK-CAS-DISPATCH-ADAPTER-2"

local function fail(message)
  error(TAG .. " " .. tostring(message), 2)
end
local function requireTable(value, label)
  if type(value) ~= "table" then fail(label .. " must be a table") end
  return value
end
local function requireFunction(container, name, label)
  if type(container) ~= "table" or type(container[name]) ~= "function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end
local function requireNonEmptyString(value, label)
  if type(value) ~= "string" or value == "" then fail(label .. " requires non-empty string") end
  return value
end
local function isFinite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function Adapter.New(spec)
  requireTable(spec, "spec")
  local missionDemand = requireTable(spec.missionDemand, "missionDemand")
  local registry = requireTable(spec.registry, "registry")
  local airwing = requireTable(spec.airwing, "airwing")
  if type(missionDemand.Type) ~= "table" or missionDemand.Type.CAS_IMMEDIATE == nil then fail("missionDemand.Type.CAS_IMMEDIATE is required") end
  if type(missionDemand.Status) ~= "table" then fail("missionDemand.Status is required") end
  for _, name in ipairs({ "Get", "AssignAI", "Activate", "Succeed", "Fail" }) do requireFunction(registry, name, "registry") end
  requireFunction(airwing, "AddMission", "airwing")
  requireNonEmptyString(spec.assigneeId, "assigneeId")
  if spec.casAltitudeFt ~= nil and (not isFinite(spec.casAltitudeFt) or spec.casAltitudeFt <= 0) then fail("casAltitudeFt must be positive finite") end
  if spec.casSpeedKts ~= nil and (not isFinite(spec.casSpeedKts) or spec.casSpeedKts <= 0) then fail("casSpeedKts must be positive finite") end
  if spec.auftragFactory ~= nil and type(spec.auftragFactory) ~= "function" then fail("auftragFactory must be a function when provided") end

  return setmetatable({
    missionDemand = missionDemand,
    registry = registry,
    airwing = airwing,
    assigneeId = spec.assigneeId,
    casAltitudeFt = spec.casAltitudeFt,
    casSpeedKts = spec.casSpeedKts,
    auftragFactory = spec.auftragFactory,
    missionsByDemandId = {},
    closureRequestedByDemandId = {},
  }, Instance)
end

function Instance:_log(message)
  if type(self.airwing.I) == "function" then self.airwing:I(TAG .. " " .. tostring(message)) end
end

function Instance:_newCasMission(targetZone)
  if self.auftragFactory then return self.auftragFactory(targetZone, self.casAltitudeFt, self.casSpeedKts) end
  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewCAS) ~= "function" then fail("MOOSE AUFTRAG:NewCAS() is required") end
  return AUFTRAG:NewCAS(targetZone, self.casAltitudeFt, self.casSpeedKts)
end

function Instance:Dispatch(demand, targetZone)
  requireTable(demand, "demand")
  requireNonEmptyString(demand.id, "demand.id")
  requireTable(targetZone, "targetZone")
  if demand.missionType ~= self.missionDemand.Type.CAS_IMMEDIATE then return nil, false, "UNSUPPORTED_MISSION_TYPE" end
  if demand.aiCapable ~= true then return nil, false, "DEMAND_NOT_AI_CAPABLE" end
  if demand.status ~= self.missionDemand.Status.OPEN then
    local existing = self.missionsByDemandId[demand.id]
    if existing then return existing, false, "ALREADY_DISPATCHED" end
    return nil, false, "DEMAND_NOT_OPEN"
  end
  local existing = self.missionsByDemandId[demand.id]
  if existing then return existing, false, "ALREADY_DISPATCHED" end

  local mission = requireTable(self:_newCasMission(targetZone), "CAS AUFTRAG")
  local adapter, demandId = self, demand.id

  function mission:OnAfterExecuting(From, Event, To)
    local current = adapter.registry:Get(demandId)
    if current and current.status == adapter.missionDemand.Status.AI_ASSIGNED then
      adapter.registry:Activate(demandId)
      adapter:_log("demand activated from AUFTRAG Executing demandId=" .. tostring(demandId))
    end
  end
  function mission:OnAfterSuccess(From, Event, To)
    local current = adapter.registry:Get(demandId)
    if current and current.status == adapter.missionDemand.Status.ACTIVE then
      adapter.registry:Succeed(demandId, {
        executor = adapter.assigneeId,
        auftrag = mission.GetName and mission:GetName() or nil,
        closureRequested = adapter.closureRequestedByDemandId[demandId] == true,
      })
      adapter:_log("demand succeeded from AUFTRAG Success demandId=" .. tostring(demandId))
    end
  end
  function mission:OnAfterFailed(From, Event, To)
    local current = adapter.registry:Get(demandId)
    if current and (current.status == adapter.missionDemand.Status.AI_ASSIGNED or current.status == adapter.missionDemand.Status.ACTIVE) then
      adapter.registry:Fail(demandId, "MOOSE_AUFTRAG_FAILED")
      adapter:_log("demand failed from AUFTRAG Failed demandId=" .. tostring(demandId))
    end
  end

  self.airwing:AddMission(mission)
  self.registry:AssignAI(demand.id, self.assigneeId)
  self.missionsByDemandId[demand.id] = mission
  self:_log(string.format("CAS queued demandId=%s installationId=%s assigneeId=%s altitudeFt=%s speedKts=%s",
    tostring(demand.id), tostring(demand.origin), tostring(self.assigneeId), tostring(self.casAltitudeFt), tostring(self.casSpeedKts)))
  return mission, true, nil
end

function Instance:RequestMissionClosure(demandId, reason)
  requireNonEmptyString(demandId, "demandId")
  local mission = self.missionsByDemandId[demandId]
  if not mission then return nil, false, "MISSION_NOT_FOUND" end
  local current = self.registry:Get(demandId)
  if not current then return mission, false, "DEMAND_NOT_FOUND" end
  if current.status ~= self.missionDemand.Status.AI_ASSIGNED and current.status ~= self.missionDemand.Status.ACTIVE then
    return mission, false, "DEMAND_NOT_ACTIVE"
  end
  if self.closureRequestedByDemandId[demandId] then return mission, false, "CLOSURE_ALREADY_REQUESTED" end
  if type(mission.Cancel) ~= "function" then fail("MOOSE AUFTRAG:Cancel() is required for CAS closure") end

  self.closureRequestedByDemandId[demandId] = true
  mission:Cancel()
  self:_log("CAS closure requested via AUFTRAG Cancel demandId=" .. tostring(demandId) .. " reason=" .. tostring(reason))
  return mission, true, nil
end

function Instance:GetMission(demandId)
  requireNonEmptyString(demandId, "demandId")
  return self.missionsByDemandId[demandId]
end

return Adapter
