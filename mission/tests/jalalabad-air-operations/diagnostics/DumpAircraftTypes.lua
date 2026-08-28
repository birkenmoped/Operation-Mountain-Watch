-- Operation Mountain Watch - Jalalabad Air Operations
-- Lists MOOSE-known air groups and statics used by the Jalalabad test.

local PREFIX = "[OMW-AIROPS-JBAD][TYPES] "

local function log(message)
  env.info(PREFIX .. tostring(message))
end

local function fail(message)
  env.error(PREFIX .. tostring(message))
end

if not SET_GROUP or not SET_STATIC then
  fail("MOOSE SET_GROUP/SET_STATIC is unavailable. Load Moose.lua before this script.")
  return
end

local groupPrefixes = {
  "CLIENT_US_JBAD_",
  "TPL_AIR_US_JBAD_",
}

local staticPrefixes = {
  "STATIC_AIR_US_JBAD_",
  "WH_AIR_US_JALALABAD",
}

local groupCount = 0
local unitCount = 0

local airGroups = SET_GROUP:New()
airGroups:FilterPrefixes(groupPrefixes)
airGroups:FilterOnce()

airGroups:ForEachGroup(function(group)
  groupCount = groupCount + 1
  local template = group:GetTemplate() or {}
  local units = template.units or {}
  log(string.format(
    "GROUP name=%s category=%s lateActivation=%s templateUnits=%d",
    tostring(group:GetName()),
    tostring(group:GetCategoryName()),
    tostring(template.lateActivation),
    #units
  ))

  for index, unitTemplate in ipairs(units) do
    unitCount = unitCount + 1
    log(string.format(
      "UNIT group=%s index=%d name=%s type=%s skill=%s parking=%s parking_id=%s livery=%s",
      tostring(group:GetName()),
      index,
      tostring(unitTemplate.name),
      tostring(unitTemplate.type),
      tostring(unitTemplate.skill),
      tostring(unitTemplate.parking),
      tostring(unitTemplate.parking_id),
      tostring(unitTemplate.livery_id)
    ))
  end
end)

local staticCount = 0
local statics = SET_STATIC:New()
statics:FilterPrefixes(staticPrefixes)
statics:FilterOnce()

statics:ForEachStatic(function(staticObject)
  staticCount = staticCount + 1
  log(string.format(
    "STATIC name=%s type=%s alive=%s",
    tostring(staticObject:GetName()),
    tostring(staticObject:GetTypeName()),
    tostring(staticObject:IsAlive())
  ))
end)

log(string.format(
  "SUMMARY groups=%d templateUnits=%d statics=%d",
  groupCount,
  unitCount,
  staticCount
))
