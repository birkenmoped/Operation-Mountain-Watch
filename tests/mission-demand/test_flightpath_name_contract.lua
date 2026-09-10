local Contract = dofile("scripts/air-operations/OMW_FlightPathNameContract.lua")

local function assertEqual(actual, expected, label)
  if actual ~= expected then
    error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual)))
  end
end

local function assertMatch(baseName, name, side, meters, signedRightM)
  local parsed = assert(Contract.Parse(baseName, name), "expected configured match for " .. name)
  assertEqual(parsed.side, side, name .. " side")
  assertEqual(parsed.meters, meters, name .. " meters")
  assertEqual(parsed.signedRightM, signedRightM, name .. " signed offset")
end

local base = "OMW_FlightPath"
assertMatch(base, "OMW_FlightPath_R200", "RIGHT", 200, 200)
assertMatch(base, "OMW_FlightPath_R500", "RIGHT", 500, 500)
assertMatch(base, "OMW_FlightPath_L350", "LEFT", 350, -350)
assertMatch(base, "OMW_FlightPath", "CENTER", 0, 0)

assert(Contract.Parse(base, "OMW_FlightPath_WEST") == nil, "WEST is a separate route segment, not a configurable base-path suffix")
assert(Contract.Parse(base, "OMW_Other_R200") == nil, "different logical route must not match")

local selected, reason = Contract.SelectFromRegistry(base, {
  OMW_FlightPath_R200 = { id = "r200" },
  OMW_FlightPath_WEST = { id = "west" },
})
assert(selected, reason)
assertEqual(selected.name, "OMW_FlightPath_R200", "selected configured route")
assertEqual(selected.offset.meters, 200, "selected offset")

local missing, missingReason = Contract.SelectFromRegistry(base, {
  OMW_FlightPath_WEST = { id = "west" },
})
assert(missing == nil and string.find(missingReason, "no configured PATHLINE", 1, true), "missing route must fail clearly")

local ambiguous, ambiguousReason = Contract.SelectFromRegistry(base, {
  OMW_FlightPath_R200 = { id = "r200" },
  OMW_FlightPath_L200 = { id = "l200" },
})
assert(ambiguous == nil and string.find(ambiguousReason, "ambiguous configured PATHLINEs", 1, true), "multiple configured base paths must fail clearly")

print("PASS test_flightpath_name_contract")
