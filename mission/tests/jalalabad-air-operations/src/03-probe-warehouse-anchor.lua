local TAG = "[OMW][ProbeWarehouseAnchor]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local function main()
  local anchorName = "WH_AIR_US_JALALABAD"
  local static = STATIC and STATIC:FindByName(anchorName) or nil
  local unit = UNIT and UNIT:FindByName(anchorName) or nil

  log("Anchor name=" .. anchorName)
  log("STATIC found=" .. tostring(static ~= nil))
  log("UNIT found=" .. tostring(unit ~= nil))

  if static then
    local vec3 = static:GetVec3() or {}
    log(string.format("STATIC coalition=%s country=%s x=%.1f y=%.1f z=%.1f",
      tostring(static:GetCoalitionName()), tostring(static:GetCountryName()),
      tonumber(vec3.x) or 0, tonumber(vec3.y) or 0, tonumber(vec3.z) or 0))
  end

  local airbaseName = AIRBASE.Afghanistan and AIRBASE.Afghanistan.Jalalabad or "Jalalabad"
  local airbase = AIRBASE and AIRBASE:FindByName(airbaseName) or nil
  log("Airbase found=" .. tostring(airbase ~= nil) .. " name=" .. tostring(airbaseName))

  if airbase then
    local okWarehouse, warehouse = pcall(function() return airbase:GetWarehouse() end)
    local okStorage, storage = pcall(function() return airbase:GetStorage() end)
    log("DCS warehouse call successful=" .. tostring(okWarehouse) .. " available=" .. tostring(warehouse ~= nil))
    log("MOOSE storage call successful=" .. tostring(okStorage) .. " available=" .. tostring(storage ~= nil))
  end

  if not static and not unit then
    log("RESULT: No named MOOSE warehouse anchor. Place one mission-editor static named " .. anchorName)
  else
    log("RESULT: Named anchor exists. AIRWING construction test may proceed.")
  end
end

if SCHEDULER then SCHEDULER:New(nil, main, {}, 4) else timer.scheduleFunction(function() main() return nil end, nil, timer.getTime() + 4) end
