local RuntimeGuard = {}

local REQUIRED_NATIVE_APIS = {
  { path = "env.info", value = function() return env and env.info end },
  { path = "trigger.action.outText", value = function() return trigger and trigger.action and trigger.action.outText end },
  { path = "timer.getTime", value = function() return timer and timer.getTime end },
}

-- Verified against vendor/moose/Moose.lua from pinned release 2.9.18:
-- GROUP:FindByName, ZONE:FindByName, MENU_MISSION:New, and
-- MENU_MISSION_COMMAND:New support the bootstrap. SPAWN:NewWithAlias,
-- SPAWN:SpawnInZone, IDENTIFIABLE:GetName, GROUP:IsAlive,
-- GROUP:CountAliveUnits, and GROUP:IsCompletelyInZone support physical spawn.
local REQUIRED_MOOSE_APIS = {
  { path = "GROUP.FindByName", value = function() return GROUP and GROUP.FindByName end },
  { path = "ZONE.FindByName", value = function() return ZONE and ZONE.FindByName end },
  { path = "MENU_MISSION.New", value = function() return MENU_MISSION and MENU_MISSION.New end },
  { path = "MENU_MISSION_COMMAND.New", value = function() return MENU_MISSION_COMMAND and MENU_MISSION_COMMAND.New end },
  { path = "SPAWN.NewWithAlias", value = function() return SPAWN and SPAWN.NewWithAlias end },
  { path = "SPAWN.SpawnInZone", value = function() return SPAWN and SPAWN.SpawnInZone end },
  { path = "IDENTIFIABLE.GetName", value = function() return IDENTIFIABLE and IDENTIFIABLE.GetName end },
  { path = "GROUP.IsAlive", value = function() return GROUP and GROUP.IsAlive end },
  { path = "GROUP.CountAliveUnits", value = function() return GROUP and GROUP.CountAliveUnits end },
  { path = "GROUP.IsCompletelyInZone", value = function() return GROUP and GROUP.IsCompletelyInZone end },
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
