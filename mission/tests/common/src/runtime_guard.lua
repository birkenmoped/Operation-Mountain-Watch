local RuntimeGuard = {}

local REQUIRED_NATIVE_APIS = {
  { path = "env.info", value = function() return env and env.info end },
  { path = "trigger.action.outText", value = function() return trigger and trigger.action and trigger.action.outText end },
  { path = "timer.getTime", value = function() return timer and timer.getTime end },
}

-- Verified against vendor/moose/Moose.lua from pinned release 2.9.18:
-- GROUP:FindByName, ZONE:FindByName, MENU_MISSION:New, and
-- MENU_MISSION_COMMAND:New are defined with the signatures used by TM01A.
local REQUIRED_MOOSE_APIS = {
  { path = "GROUP.FindByName", value = function() return GROUP and GROUP.FindByName end },
  { path = "ZONE.FindByName", value = function() return ZONE and ZONE.FindByName end },
  { path = "MENU_MISSION.New", value = function() return MENU_MISSION and MENU_MISSION.New end },
  { path = "MENU_MISSION_COMMAND.New", value = function() return MENU_MISSION_COMMAND and MENU_MISSION_COMMAND.New end },
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
