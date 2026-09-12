-- Operation Mountain Watch - external Fire Support runtime assembly.
--
-- Builds ARTY/CAS Base adapters on the public MOOSE COMMANDER mission queue.
-- Tactical target geometry is injected. COMMANDER remains the provider aggregator
-- and MOOSE selects/recruits operational assets from its legions.

local Runtime = {}
local Instance = {}
Instance.__index = Instance

Runtime.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-EXTERNAL-SUPPORT-RUNTIME-1"
local TAG = "[OMW][FireSupStratResupply.ExternalSupportRuntime]"

local function fail(message) error(TAG .. " " .. tostring(message),2) end
local function needTable(value,label) if type(value)~="table" then fail(label .. " must be a table") end return value end
local function needFunction(container,name,label)
  if type(container)~="table" or type(container[name])~="function" then fail(label .. "." .. name .. "() is required") end
  return container[name]
end

function Runtime.New(spec)
  needTable(spec,"spec")
  local commander=needTable(spec.commander,"commander")
  local commanderBridge=needTable(spec.commanderBridge,"commanderBridge")
  local artyMissionFactory=needTable(spec.artyMissionFactory,"artyMissionFactory")
  local casMissionFactory=needTable(spec.casMissionFactory,"casMissionFactory")
  needFunction(commander,"AddMission","commander")
  needFunction(commanderBridge,"New","commanderBridge")
  needFunction(artyMissionFactory,"New","artyMissionFactory")
  needFunction(casMissionFactory,"New","casMissionFactory")
  if type(spec.resolveArtyTarget)~="function" then fail("resolveArtyTarget must be a function") end
  if type(spec.resolveCasGeometry)~="function" then fail("resolveCasGeometry must be a function") end
  if spec.logger~=nil and type(spec.logger)~="function" then fail("logger must be a function when provided") end

  local artyFactory=artyMissionFactory.New({
    resolveTarget=spec.resolveArtyTarget,
    requiredAssetsMin=spec.artyRequiredAssetsMin or 1,
    requiredAssetsMax=spec.artyRequiredAssetsMax or (spec.artyRequiredAssetsMin or 1),
    logger=spec.logger,
  })
  local casFactory=casMissionFactory.New({
    resolveGeometry=spec.resolveCasGeometry,
    requiredAssetsMin=spec.casRequiredAssetsMin or 1,
    requiredAssetsMax=spec.casRequiredAssetsMax or (spec.casRequiredAssetsMin or 1),
    logger=spec.logger,
  })
  local arty=commanderBridge.New({
    commander=commander,
    kind=commanderBridge.Kind and commanderBridge.Kind.MISSION or "MISSION",
    factory=function(demand,context) return artyFactory:Create(demand,context) end,
    logger=spec.logger,
  })
  local cas=commanderBridge.New({
    commander=commander,
    kind=commanderBridge.Kind and commanderBridge.Kind.MISSION or "MISSION",
    factory=function(demand,context) return casFactory:Create(demand,context) end,
    logger=spec.logger,
  })

  return setmetatable({
    commander=commander,
    arty=arty,
    cas=cas,
    artyFactory=artyFactory,
    casFactory=casFactory,
    logger=spec.logger,
  },Instance)
end

function Instance:_log(message)
  if self.logger then self.logger(TAG .. " " .. tostring(message)) end
end

function Instance:GetAdapters()
  return { ARTY=self.arty, CAS=self.cas }
end

function Instance:GetAdapter(supportType)
  if supportType=="ARTY" then return self.arty end
  if supportType=="CAS" then return self.cas end
  return nil
end

return Runtime
