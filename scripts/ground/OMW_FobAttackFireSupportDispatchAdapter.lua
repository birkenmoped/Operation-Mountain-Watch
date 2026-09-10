-- Operation Mountain Watch - immediate fire-support MissionDemand -> MOOSE ARMYGROUP/AUFTRAG adapter.
--
-- MissionDemand remains assignment/status authority. The fixed battery is an
-- existing physical DCS group represented by MOOSE ARMYGROUP. AUFTRAG owns the
-- operational Fire-at-point mission. This adapter owns no CampaignState stock.

local Adapter = {}
local Instance = {}
Instance.__index = Instance

local TAG = "[OMW][FobAttackFireSupportDispatchAdapter]"
Adapter.SchemaVersion = "OMW-FOB-ATTACK-FIRE-SUPPORT-DISPATCH-ADAPTER-1"

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
  local armyGroup = requireTable(spec.armyGroup, "armyGroup")

  if type(missionDemand.Type) ~= "table" or missionDemand.Type.FIRE_SUPPORT_IMMEDIATE == nil then
    fail("missionDemand.Type.FIRE_SUPPORT_IMMEDIATE is required")
  end
  if type(missionDemand.Status) ~= "table" then fail("missionDemand.Status is required") end
  for _, name in ipairs({ "Get", "AssignAI", "Activate", "Succeed", "Fail" }) do requireFunction(registry, name, "registry") end
  requireFunction(armyGroup, "AddMission", "armyGroup")
  requireNonEmptyString(spec.assigneeId, "assigneeId")

  if spec.shots ~= nil and (not isFinite(spec.shots) or spec.shots <= 0) then fail("shots must be positive finite when provided") end
  if spec.radiusM ~= nil and (not isFinite(spec.radiusM) or spec.radiusM <= 0) then fail("radiusM must be positive finite when provided") end
  if spec.isTargetInRange ~= nil and type(spec.isTargetInRange) ~= "function" then fail("isTargetInRange must be a function when provided") end
  if spec.auftragFactory ~= nil and type(spec.auftragFactory) ~= "function" then fail("auftragFactory must be a function when provided") end

  return setmetatable({
    missionDemand = missionDemand,
    registry = registry,
    armyGroup = armyGroup,
    assigneeId = spec.assigneeId,
    shots = spec.shots,
    radiusM = spec.radiusM or 100,
    isTargetInRange = spec.isTargetInRange,
    auftragFactory = spec.auftragFactory,
    missionsByDemandId = {},
  }, Instance)
end

function Instance:_log(message)
  if type(self.armyGroup.I) == "function" then self.armyGroup:I(TAG .. " " .. tostring(message)) end
end

function Instance:_newMission(targetCoordinate)
  if self.auftragFactory then return self.auftragFactory(targetCoordinate, self.shots, self.radiusM) end
  if type(AUFTRAG) ~= "table" or type(AUFTRAG.NewARTY) ~= "function" then fail("MOOSE AUFTRAG:NewARTY() is required") end
  return AUFTRAG:NewARTY(targetCoordinate, self.shots, self.radiusM)
end

function Instance:Dispatch(demand, targetCoordinate)
  requireTable(demand, "demand")
  requireNonEmptyString(demand.id, "demand.id")
  requireTable(targetCoordinate, "targetCoordinate")

  if demand.missionType ~= self.missionDemand.Type.FIRE_SUPPORT_IMMEDIATE then return nil, false, "UNSUPPORTED_MISSION_TYPE" end
  if demand.aiCapable ~= true then return nil, false, "DEMAND_NOT_AI_CAPABLE" end
  if demand.status ~= self.missionDemand.Status.OPEN then
    local existing = self.missionsByDemandId[demand.id]
    if existing then return existing, false, "ALREADY_DISPATCHED" end
    return nil, false, "DEMAND_NOT_OPEN"
  end
  if self.missionsByDemandId[demand.id] then return self.missionsByDemandId[demand.id], false, "ALREADY_DISPATCHED" end

  if self.isTargetInRange and self.isTargetInRange(self.armyGroup, targetCoordinate) ~= true then
    return nil, false, "TARGET_OUT_OF_RANGE"
  end

  local mission = requireTable(self:_newMission(targetCoordinate), "ARTY AUFTRAG")
  local adapter, demandId = self, demand.id

  function mission:OnAfterExecuting(From, Event, To)
    local current = adapter.registry:Get(demandId)
    if current and current.status == adapter.missionDemand.Status.AI_ASSIGNED then
      adapter.registry:Activate(demandId)
      adapter:_log("fire-support demand activated from AUFTRAG Executing demandId=" .. tostring(demandId))
    end
  end

  function mission:OnAfterSuccess(From, Event, To)
    local current = adapter.registry:Get(demandId)
    if current and current.status == adapter.missionDemand.Status.ACTIVE then
      adapter.registry:Succeed(demandId, {
        executor = adapter.assigneeId,
        auftrag = mission.GetName and mission:GetName() or nil,
        fireMissionExecuted = true,
      })
      adapter:_log("fire-support demand succeeded from AUFTRAG Success demandId=" .. tostring(demandId))
    end
  end

  function mission:OnAfterFailed(From, Event, To)
    local current = adapter.registry:Get(demandId)
    if current and (current.status == adapter.missionDemand.Status.AI_ASSIGNED or current.status == adapter.missionDemand.Status.ACTIVE) then
      adapter.registry:Fail(demandId, "MOOSE_AUFTRAG_FAILED")
      adapter:_log("fire-support demand failed from AUFTRAG Failed demandId=" .. tostring(demandId))
    end
  end

  self.armyGroup:AddMission(mission)
  self.registry:AssignAI(demand.id, self.assigneeId)
  self.missionsByDemandId[demand.id] = mission
  self:_log(string.format("ARTY queued demandId=%s requester=%s assigneeId=%s shots=%s radiusM=%s",
    tostring(demand.id), tostring(demand.origin), tostring(self.assigneeId), tostring(self.shots), tostring(self.radiusM)))
  return mission, true, nil
end

function Instance:GetMission(demandId)
  requireNonEmptyString(demandId, "demandId")
  return self.missionsByDemandId[demandId]
end

return Adapter
