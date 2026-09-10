-- Operation Mountain Watch - logical FlightPath name/option contract.
--
-- A mission-editor PATHLINE name carries both a stable logical route identity and
-- optional lateral-offset configuration. Example:
--   OMW_FlightPath_R200 -> logical route OMW_FlightPath, 200 m right offset.
-- This module is pure contract logic; runtime registry access remains in the caller.

local Contract = {}

Contract.SchemaVersion = "OMW-FLIGHTPATH-NAME-CONTRACT-1"

local function fail(message)
  error("[OMW][FlightPathNameContract] " .. tostring(message), 2)
end

local function escapePattern(value)
  return (value:gsub("([^%w])", "%%%1"))
end

function Contract.Parse(baseName, pathlineName)
  if type(baseName) ~= "string" or baseName == "" then fail("baseName requires non-empty string") end
  if type(pathlineName) ~= "string" or pathlineName == "" then fail("pathlineName requires non-empty string") end

  if pathlineName == baseName then
    return {
      baseName = baseName,
      pathlineName = pathlineName,
      side = "CENTER",
      meters = 0,
      signedRightM = 0,
      source = "NO_SUFFIX",
    }
  end

  local pattern = "^" .. escapePattern(baseName) .. "_([RL])(%d+)$"
  local side, meters = pathlineName:match(pattern)
  if not side then return nil end

  local value = tonumber(meters)
  if not value or value < 0 then fail("invalid configured PATHLINE suffix: " .. pathlineName) end

  return {
    baseName = baseName,
    pathlineName = pathlineName,
    side = side == "R" and "RIGHT" or "LEFT",
    meters = value,
    signedRightM = side == "R" and value or -value,
    source = "PATHLINE_SUFFIX",
  }
end

function Contract.SelectFromRegistry(baseName, registry)
  if type(registry) ~= "table" then fail("registry must be a table") end

  local matches = {}
  for name, pathline in pairs(registry) do
    local parsed = Contract.Parse(baseName, name)
    if parsed then
      matches[#matches + 1] = {
        name = name,
        pathline = pathline,
        offset = parsed,
      }
    end
  end

  table.sort(matches, function(left, right) return left.name < right.name end)

  if #matches == 0 then
    return nil, "no configured PATHLINE found for logical route " .. baseName
  end
  if #matches > 1 then
    local names = {}
    for _, match in ipairs(matches) do names[#names + 1] = match.name end
    return nil, "ambiguous configured PATHLINEs for logical route " .. baseName .. ": " .. table.concat(names, ", ")
  end

  return matches[1], nil
end

return Contract
