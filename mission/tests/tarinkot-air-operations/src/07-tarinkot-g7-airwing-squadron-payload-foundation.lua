-- Operation Mountain Watch - Tarinkot G7 AIRWING/SQUADRON/payload foundation.
--
-- This is one combined airport-level acceptance bundle. It constructs the
-- Tarinkot AIRWING, registers all three SQUADRONs, applies the G6-accepted
-- parking pools, registers capabilities and payloads, enables the MOOSE
-- vertical-helicopter policy before AIRWING start, and proves a stable idle
-- node without creating any AUFTRAG, COMMANDER, OPSTRANSPORT or SPAWN object.

OMW = OMW or {}
OMW.AirOps = OMW.AirOps or {}

local TAG = "[OMW][AirOps.TKOT.G7.Foundation]"
local function log(message)
  env.info(TAG .. " " .. tostring(message))
end

local build = OMW_TKOT_G7_BUILD or {}

local EXPECTED = {
  AirbaseName = "Tarinkot",
  AirbaseID = 9,
  ParkingCount = 33,
  HelicopterOnly = 40,
  WarehouseName = "WH_AIR_US_TARINKOT",
  AirwingName = "AW_US_TKOT_TF_ATTACK_3_101_AVN",
  MooseRelease = "2.9.18",
  MooseCommit = "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54",
  MooseSHA256 = "e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915",
  ClientTerminalIDs = {
    [3] = "CLIENT_US_TKOT_CH47F_01",
    [8] = "CLIENT_US_TKOT_AH64D_02",
    [20] = "CLIENT_US_TKOT_AH64D_01"
  },
  ClientUnits = {
    "CLIENT_US_TKOT_AH64D_01_UNIT_01",
    "CLIENT_US_TKOT_AH64D_02_UNIT_01",
    "CLIENT_US_TKOT_CH47F_01_UNIT_01"
  },
  Statics = {
    AH64 = {
      "STATIC_AIR_US_TKOT_AH64_01",
      "STATIC_AIR_US_TKOT_AH64_02",
      "STATIC_AIR_US_TKOT_AH64_03",
      "STATIC_AIR_US_TKOT_AH64_04",
      "STATIC_AIR_US_TKOT_AH64_05",
      "STATIC_AIR_US_TKOT_AH64_06",
      "STATIC_AIR_US_TKOT_AH64_07",
      "STATIC_AIR_US_TKOT_AH64_08"
    },
    UH60 = {
      "STATIC_AIR_US_TKOT_UH60_UTILITY_01",
      "STATIC_AIR_US_TKOT_UH60_UTILITY_02",
      "STATIC_AIR_US_TKOT_UH60_UTILITY_03",
      "STATIC_AIR_US_TKOT_UH60_MEDEVAC_01"
    },
    CH47 = {}
  },
  Squadrons = {
    {
      Key = "AH64",
      Name = "SQ_US_TKOT_AH64D_3_101_AVN",
      Template = "TPL_AIR_US_TKOT_AH64D_CAS_2SHIP",
      ExpectedType = "AH-64D_BLK_II",
      TemplateUnits = 2,
      Ngroups = 2,
      Grouping = 2,
      LogicalAircraft = 14,
      StaticAircraft = 8,
      ClientAircraft = 2,
      ParkingIDs = { 21, 4 },
      MissionTypeNames = { "CAS" }
    },
    {
      Key = "UH60",
      Name = "SQ_US_TKOT_UH60_TF_ATTACK",
      Template = "TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP",
      ExpectedType = "UH-60A",
      TemplateUnits = 1,
      Ngroups = 2,
      Grouping = 1,
      LogicalAircraft = 6,
      StaticAircraft = 4,
      ClientAircraft = 0,
      ParkingIDs = { 30, 27, 23 },
      MissionTypeNames = {
        "TROOPTRANSPORT",
        "CARGOTRANSPORT",
        "LANDATCOORDINATE",
        "GROUNDESCORT"
      }
    },
    {
      Key = "CH47",
      Name = "SQ_US_TKOT_CH47_B_1_52_AVN",
      Template = "TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP",
      ExpectedType = "CH-47Fbl1",
      TemplateUnits = 1,
      Ngroups = 1,
      Grouping = 1,
      LogicalAircraft = 2,
      StaticAircraft = 0,
      ClientAircraft = 1,
      ParkingIDs = { 32, 29, 10 },
      MissionTypeNames = {
        "TROOPTRANSPORT",
        "CARGOTRANSPORT",
        "LANDATCOORDINATE"
      }
    }
  },
  ExpectedSquadrons = 3,
  ExpectedRegisteredGroups = 5,
  ExpectedRegisteredAircraft = 7,
  ExpectedRolePayloads = 3,
  ExpectedAutomaticRelocationPayloads = 3,
  ExpectedTotalPayloads = 6,
  ExpectedParkingIDs = 8
}

local state = {
  Finalized = false,
  Violations = 0,
  Airbase = nil,
  Airwing = nil,
  Squadrons = {},
  RolePayloads = {},
  ParkingByID = {},
  PreStartOpsGroups = -1
}

local function safe(label, callback)
  local ok, a, b, c = pcall(callback)
  if not ok then
    state.Violations = state.Violations + 1
    log("VIOLATION label=" .. tostring(label) .. " exception=" .. tostring(a))
    return nil, nil, nil, false
  end
  return a, b, c, true
end

local function violation(reason)
  state.Violations = state.Violations + 1
  log("VIOLATION reason=" .. tostring(reason))
end

local function countTable(value)
  if type(value) ~= "table" then return 0 end
  local count = 0
  for _ in pairs(value) do count = count + 1 end
  return count
end

local function join(values)
  local result = {}
  for _, value in ipairs(values or {}) do
    result[#result + 1] = tostring(value)
  end
  return #result > 0 and table.concat(result, ",") or "none"
end

local function numericListEqual(left, right)
  if type(left) ~= "table" or type(right) ~= "table" then return false end
  if #left ~= #right then return false end
  local counts = {}
  for _, value in ipairs(left) do
    local number = tonumber(value)
    if not number then return false end
    counts[number] = (counts[number] or 0) + 1
  end
  for _, value in ipairs(right) do
    local number = tonumber(value)
    if not number or not counts[number] or counts[number] == 0 then return false end
    counts[number] = counts[number] - 1
  end
  for _, remaining in pairs(counts) do
    if remaining ~= 0 then return false end
  end
  return true
end

local function activePlayerClientCount()
  local count = 0
  for _, unitName in ipairs(EXPECTED.ClientUnits) do
    local unit = UNIT and UNIT:FindByName(unitName) or nil
    if unit then
      local playerName = safe("CLIENT_PLAYER_NAME_" .. unitName, function()
        return unit:GetPlayerName()
      end)
      if playerName and tostring(playerName) ~= "" then
        count = count + 1
        log("ACTIVE_PLAYER_CLIENT unit=" .. unitName .. " player=" .. tostring(playerName))
      end
    end
  end
  log("ACTIVE_PLAYER_CLIENT_COUNT=" .. tostring(count))
  return count
end

local function getMissionTypes(contract)
  local values = {}
  for _, name in ipairs(contract.MissionTypeNames or {}) do
    local value = AUFTRAG and AUFTRAG.Type and AUFTRAG.Type[name] or nil
    if value == nil then
      violation("MISSION_TYPE_MISSING squadron=" .. contract.Name .. " name=" .. tostring(name))
    else
      values[#values + 1] = value
    end
  end
  return values
end

local function getOpsGroupCount(airwing)
  if not airwing or type(airwing.GetOpsGroups) ~= "function" then
    violation("AIRWING_GET_OPS_GROUPS_UNAVAILABLE")
    return -1
  end

  local set = safe("AIRWING_GET_OPS_GROUPS", function()
    return airwing:GetOpsGroups()
  end)
  if not set then return -1 end

  if type(set.Count) == "function" then
    local value = safe("OPS_GROUP_SET_COUNT", function() return set:Count() end)
    return tonumber(value) or -1
  end

  if type(set.GetSetObjects) == "function" then
    local objects = safe("OPS_GROUP_SET_OBJECTS", function() return set:GetSetObjects() end)
    return countTable(objects)
  end

  violation("OPS_GROUP_SET_COUNT_METHOD_UNAVAILABLE")
  return -1
end

local function getAirwingRunning(airwing)
  if not airwing or type(airwing.IsRunning) ~= "function" then
    return false
  end
  local value = safe("AIRWING_IS_RUNNING", function() return airwing:IsRunning() end)
  return value == true
end

local function validateWarehouse()
  local static = STATIC and STATIC:FindByName(EXPECTED.WarehouseName, false) or nil
  local unit = UNIT and UNIT:FindByName(EXPECTED.WarehouseName) or nil
  local wrappers = (static and 1 or 0) + (unit and 1 or 0)
  log(string.format(
    "WAREHOUSE_CONTRACT name=%s staticFound=%s unitFound=%s wrapperCount=%d",
    EXPECTED.WarehouseName, tostring(static ~= nil), tostring(unit ~= nil), wrappers
  ))
  if wrappers ~= 1 then
    violation("WAREHOUSE_WRAPPER_COUNT expected=1 actual=" .. tostring(wrappers))
    return false
  end
  return true
end

local function validateStatics()
  local found = 0
  for family, names in pairs(EXPECTED.Statics) do
    local expectedType = family == "AH64" and "AH-64D_BLK_II" or
      (family == "UH60" and "UH-60A" or "CH-47Fbl1")
    for _, name in ipairs(names) do
      local object = STATIC and STATIC:FindByName(name, false) or nil
      if not object then
        violation("STATIC_MISSING family=" .. family .. " name=" .. name)
      else
        found = found + 1
        local typeName = safe("STATIC_TYPE_" .. name, function() return object:GetTypeName() end)
        local accepted = tostring(typeName) == expectedType
        log(string.format(
          "STATIC_CONTRACT family=%s name=%s type=%s expectedType=%s accepted=%s",
          family, name, tostring(typeName), expectedType, tostring(accepted)
        ))
        if not accepted then
          violation("STATIC_TYPE_MISMATCH family=" .. family .. " name=" .. name)
        end
      end
    end
  end
  log("STATIC_CONTRACT_SUMMARY found=" .. tostring(found) .. " expected=12")
  if found ~= 12 then violation("STATIC_COUNT_MISMATCH expected=12 actual=" .. tostring(found)) end
end

local function validateAirbaseAndParking()
  local airbase = AIRBASE:FindByID(EXPECTED.AirbaseID)
  if not airbase then
    violation("AIRBASE_ID_NOT_FOUND id=" .. tostring(EXPECTED.AirbaseID))
    return false
  end

  state.Airbase = airbase
  local name = airbase:GetName()
  local id = airbase:GetID()
  log(string.format("AIRBASE_CONTRACT name=%s id=%s expectedName=%s expectedID=%d",
    tostring(name), tostring(id), EXPECTED.AirbaseName, EXPECTED.AirbaseID))
  if tostring(name) ~= EXPECTED.AirbaseName or tonumber(id) ~= EXPECTED.AirbaseID then
    violation("AIRBASE_IDENTITY_MISMATCH")
  end

  local helicopterOnly = AIRBASE.TerminalType and tonumber(AIRBASE.TerminalType.HelicopterOnly) or nil
  log("TERMINAL_TYPE_CONTRACT name=HelicopterOnly value=" .. tostring(helicopterOnly))
  if helicopterOnly ~= EXPECTED.HelicopterOnly then
    violation("HELICOPTER_ONLY_CONSTANT_MISMATCH expected=40 actual=" .. tostring(helicopterOnly))
  end

  local parking = safe("AIRBASE_GET_PARKING_TABLE", function()
    return airbase:GetParkingSpotsTable()
  end) or {}
  log("PARKING_COUNT actual=" .. tostring(#parking) .. " expected=" .. tostring(EXPECTED.ParkingCount))
  if #parking ~= EXPECTED.ParkingCount then
    violation("PARKING_COUNT_MISMATCH")
  end

  for _, spot in ipairs(parking) do
    state.ParkingByID[tonumber(spot.TerminalID)] = spot
  end

  local seen = {}
  local acceptedCount = 0
  for _, contract in ipairs(EXPECTED.Squadrons) do
    local concurrencyByParking = math.floor(#contract.ParkingIDs / contract.Grouping)
    log(string.format(
      "PARKING_POOL family=%s ids=%s count=%d grouping=%d simultaneousGroupsByParking=%d registeredGroups=%d",
      contract.Key, join(contract.ParkingIDs), #contract.ParkingIDs,
      contract.Grouping, concurrencyByParking, contract.Ngroups
    ))
    if concurrencyByParking < 1 then
      violation("PARKING_POOL_TOO_SMALL family=" .. contract.Key)
    end

    for _, value in ipairs(contract.ParkingIDs) do
      local idNumber = tonumber(value)
      local spot = idNumber and state.ParkingByID[idNumber] or nil
      if not idNumber or not spot then
        violation("PARKING_ID_NOT_FOUND family=" .. contract.Key .. " id=" .. tostring(value))
      elseif seen[idNumber] then
        violation("PARKING_ID_DUPLICATE id=" .. tostring(idNumber) .. " firstFamily=" .. seen[idNumber] .. " secondFamily=" .. contract.Key)
      elseif EXPECTED.ClientTerminalIDs[idNumber] then
        violation("PARKING_ID_IS_CLIENT_TERMINAL family=" .. contract.Key .. " id=" .. tostring(idNumber))
      else
        seen[idNumber] = contract.Key
        local accepted = tonumber(spot.TerminalType) == EXPECTED.HelicopterOnly and
          spot.Free == true and spot.TOAC ~= true
        log(string.format(
          "PARKING_ID_READY family=%s id=%d type=%s free=%s toac=%s accepted=%s",
          contract.Key, idNumber, tostring(spot.TerminalType),
          tostring(spot.Free), tostring(spot.TOAC), tostring(accepted)
        ))
        if accepted then
          acceptedCount = acceptedCount + 1
        else
          violation("PARKING_ID_NOT_READY family=" .. contract.Key .. " id=" .. tostring(idNumber))
        end
      end
    end
  end

  log("PARKING_POOL_SUMMARY accepted=" .. tostring(acceptedCount) .. " expected=" .. tostring(EXPECTED.ExpectedParkingIDs))
  if acceptedCount ~= EXPECTED.ExpectedParkingIDs then
    violation("PARKING_POOL_ACCEPTED_COUNT_MISMATCH")
  end
  return true
end

local function validateTemplate(contract)
  local template = GROUP:FindByName(contract.Template)
  if not template then
    violation("TEMPLATE_GROUP_MISSING squadron=" .. contract.Name .. " template=" .. contract.Template)
    return nil
  end

  local units = template:GetUnits() or {}
  local missionTemplate = _DATABASE and _DATABASE.Templates and _DATABASE.Templates.Groups and
    _DATABASE.Templates.Groups[contract.Template] and
    _DATABASE.Templates.Groups[contract.Template].Template or nil
  local lateActivation = missionTemplate and missionTemplate.lateActivation == true
  local uncontrolled = missionTemplate and (missionTemplate.uncontrolled == true or missionTemplate.uncontrollable == true) or false

  log(string.format(
    "TEMPLATE_CONTRACT squadron=%s template=%s units=%d expectedUnits=%d lateActivation=%s uncontrolled=%s",
    contract.Name, contract.Template, #units, contract.TemplateUnits,
    tostring(lateActivation), tostring(uncontrolled)
  ))

  if #units ~= contract.TemplateUnits then
    violation("TEMPLATE_UNIT_COUNT_MISMATCH squadron=" .. contract.Name)
  end
  if not lateActivation then
    violation("TEMPLATE_NOT_LATE_ACTIVATION squadron=" .. contract.Name)
  end
  if uncontrolled then
    violation("TEMPLATE_UNCONTROLLED squadron=" .. contract.Name)
  end

  for index, unit in ipairs(units) do
    local typeName = unit:GetTypeName()
    local accepted = tostring(typeName) == contract.ExpectedType
    log(string.format(
      "TEMPLATE_UNIT squadron=%s index=%d name=%s type=%s expectedType=%s accepted=%s",
      contract.Name, index, tostring(unit:GetName()), tostring(typeName),
      contract.ExpectedType, tostring(accepted)
    ))
    if not accepted then
      violation("TEMPLATE_TYPE_MISMATCH squadron=" .. contract.Name .. " index=" .. tostring(index))
    end
  end

  return template
end

local function validateInventoryLedger(contract)
  local registeredAircraft = contract.Ngroups * contract.Grouping
  local represented = contract.StaticAircraft + contract.ClientAircraft + registeredAircraft
  local accepted = represented == contract.LogicalAircraft and contract.TemplateUnits == contract.Grouping
  log(string.format(
    "INVENTORY_LEDGER family=%s logical=%d statics=%d clients=%d registeredGroups=%d grouping=%d registeredAircraft=%d represented=%d accepted=%s",
    contract.Key, contract.LogicalAircraft, contract.StaticAircraft, contract.ClientAircraft,
    contract.Ngroups, contract.Grouping, registeredAircraft, represented, tostring(accepted)
  ))
  if not accepted then
    violation("INVENTORY_LEDGER_MISMATCH family=" .. contract.Key)
  end
  return registeredAircraft
end

local function constructFoundation()
  if state.Violations > 0 then return false end

  local airwing = safe("AIRWING_CONSTRUCT", function()
    return AIRWING:New(EXPECTED.WarehouseName, EXPECTED.AirwingName)
  end)
  if not airwing then
    violation("AIRWING_CONSTRUCTION_FAILED")
    return false
  end

  state.Airwing = airwing

  safe("AIRWING_SET_AIRBASE", function() return airwing:SetAirbase(state.Airbase) end)
  safe("AIRWING_SET_TAKEOFF_COLD", function() return airwing:SetTakeoffCold() end)
  safe("AIRWING_SET_SAFE_PARKING", function() return airwing:SetSafeParkingOn() end)

  -- Binding rotary-wing policy. This must occur before AIRWING:Start().
  safe("AIRWING_SET_VERTICAL_POLICY", function()
    return airwing:SetOptionPreferVerticalLanding()
  end)

  local registeredGroups = 0
  local registeredAircraft = 0

  for _, contract in ipairs(EXPECTED.Squadrons) do
    local template = validateTemplate(contract)
    registeredAircraft = registeredAircraft + validateInventoryLedger(contract)
    local missionTypes = getMissionTypes(contract)

    if template and #missionTypes == #contract.MissionTypeNames and state.Violations == 0 then
      local squadron = safe("SQUADRON_CONSTRUCT_" .. contract.Key, function()
        return SQUADRON:New(contract.Template, contract.Ngroups, contract.Name)
      end)

      if not squadron then
        violation("SQUADRON_CONSTRUCTION_FAILED family=" .. contract.Key)
      else
        safe("SQUADRON_GROUPING_" .. contract.Key, function()
          return squadron:SetGrouping(contract.Grouping)
        end)
        safe("SQUADRON_PARKING_" .. contract.Key, function()
          return squadron:SetParkingIDs(contract.ParkingIDs)
        end)
        if AI and AI.Skill and AI.Skill.HIGH and type(squadron.SetSkill) == "function" then
          safe("SQUADRON_SKILL_" .. contract.Key, function()
            return squadron:SetSkill(AI.Skill.HIGH)
          end)
        end
        safe("SQUADRON_CAPABILITY_" .. contract.Key, function()
          return squadron:AddMissionCapability(missionTypes, 100)
        end)
        safe("AIRWING_ADD_SQUADRON_" .. contract.Key, function()
          return airwing:AddSquadron(squadron)
        end)

        local linked = airwing:GetSquadron(contract.Name)
        if linked ~= squadron then
          violation("AIRWING_SQUADRON_LINK_MISMATCH family=" .. contract.Key)
        end

        local assetCount = countTable(squadron.assets)
        if assetCount ~= contract.Ngroups then
          violation("SQUADRON_ASSET_COUNT_MISMATCH family=" .. contract.Key .. " expected=" .. tostring(contract.Ngroups) .. " actual=" .. tostring(assetCount))
        end

        for assetIndex, asset in pairs(squadron.assets or {}) do
          local parkingAccepted = numericListEqual(asset.parkingIDs, contract.ParkingIDs)
          log(string.format(
            "ASSET_CONTRACT family=%s assetIndex=%s squadron=%s parkingIDs=%s expectedParkingIDs=%s parkingAccepted=%s",
            contract.Key, tostring(assetIndex), tostring(asset.squadname),
            join(asset.parkingIDs), join(contract.ParkingIDs), tostring(parkingAccepted)
          ))
          if not parkingAccepted then
            violation("ASSET_PARKING_IDS_MISMATCH family=" .. contract.Key .. " assetIndex=" .. tostring(assetIndex))
          end
        end

        local payload = safe("AIRWING_NEW_PAYLOAD_" .. contract.Key, function()
          return airwing:NewPayload(template, -1, missionTypes, 100)
        end)
        if not payload then
          violation("ROLE_PAYLOAD_CREATION_FAILED family=" .. contract.Key)
        else
          local payloadAccepted = payload.unlimited == true and
            tostring(payload.aircrafttype) == contract.ExpectedType and
            countTable(payload.capabilities) >= #missionTypes
          log(string.format(
            "ROLE_PAYLOAD family=%s aircraftType=%s unlimited=%s navail=%s capabilities=%d expectedMissionTypes=%d accepted=%s",
            contract.Key, tostring(payload.aircrafttype), tostring(payload.unlimited),
            tostring(payload.navail), countTable(payload.capabilities), #missionTypes,
            tostring(payloadAccepted)
          ))
          if not payloadAccepted then
            violation("ROLE_PAYLOAD_CONTRACT_MISMATCH family=" .. contract.Key)
          end
          state.RolePayloads[contract.Key] = payload
        end

        state.Squadrons[contract.Key] = squadron
        registeredGroups = registeredGroups + contract.Ngroups
        log(string.format(
          "SQUADRON_REGISTERED family=%s name=%s template=%s ngroups=%d grouping=%d registeredAircraft=%d parkingIDs=%s missionTypes=%s state=%s",
          contract.Key, contract.Name, contract.Template, contract.Ngroups,
          contract.Grouping, contract.Ngroups * contract.Grouping,
          join(contract.ParkingIDs), join(contract.MissionTypeNames),
          tostring(squadron:GetState())
        ))
      end
    end
  end

  local cohortCount = countTable(airwing.cohorts)
  local rolePayloadCount = countTable(state.RolePayloads)
  local totalPayloadCount = countTable(airwing.payloads)
  local stockCount = countTable(airwing.stock)
  local missionQueueCount = countTable(airwing.missionqueue)
  local transportQueueCount = countTable(airwing.transportqueue)
  local requestQueueCount = countTable(airwing.queue)

  log(string.format(
    "FOUNDATION_PRESTART airwing=%s cohorts=%d expectedCohorts=%d registeredGroups=%d expectedRegisteredGroups=%d registeredAircraft=%d expectedRegisteredAircraft=%d rolePayloads=%d expectedRolePayloads=%d totalPayloads=%d expectedTotalPayloads=%d stock=%d missionQueue=%d transportQueue=%d requestQueue=%d takeoffType=%s safeParking=%s verticalPolicy=%s",
    EXPECTED.AirwingName, cohortCount, EXPECTED.ExpectedSquadrons,
    registeredGroups, EXPECTED.ExpectedRegisteredGroups,
    registeredAircraft, EXPECTED.ExpectedRegisteredAircraft,
    rolePayloadCount, EXPECTED.ExpectedRolePayloads,
    totalPayloadCount, EXPECTED.ExpectedTotalPayloads,
    stockCount, missionQueueCount, transportQueueCount, requestQueueCount,
    tostring(airwing.takeoffType), tostring(airwing.safeparking),
    tostring(airwing.OptionPreferVerticalLanding)
  ))

  if cohortCount ~= EXPECTED.ExpectedSquadrons then violation("AIRWING_COHORT_COUNT_MISMATCH") end
  if registeredGroups ~= EXPECTED.ExpectedRegisteredGroups then violation("REGISTERED_GROUP_COUNT_MISMATCH") end
  if registeredAircraft ~= EXPECTED.ExpectedRegisteredAircraft then violation("REGISTERED_AIRCRAFT_COUNT_MISMATCH") end
  if rolePayloadCount ~= EXPECTED.ExpectedRolePayloads then violation("ROLE_PAYLOAD_COUNT_MISMATCH") end
  if totalPayloadCount ~= EXPECTED.ExpectedTotalPayloads then violation("TOTAL_PAYLOAD_COUNT_MISMATCH") end
  if stockCount ~= EXPECTED.ExpectedRegisteredGroups then violation("WAREHOUSE_STOCK_COUNT_MISMATCH expected=5 actual=" .. tostring(stockCount)) end
  if missionQueueCount ~= 0 or transportQueueCount ~= 0 or requestQueueCount ~= 0 then
    violation("NONEMPTY_QUEUE_BEFORE_START")
  end
  if airwing.safeparking ~= true then violation("SAFE_PARKING_NOT_ENABLED") end
  if airwing.OptionPreferVerticalLanding ~= true then violation("VERTICAL_POLICY_NOT_ENABLED") end
  if COORDINATE and COORDINATE.WaypointType and
     airwing.takeoffType ~= COORDINATE.WaypointType.TakeOffParking then
    violation("TAKEOFF_TYPE_NOT_COLD")
  end

  state.PreStartOpsGroups = getOpsGroupCount(airwing)
  log("OPS_GROUPS_PRESTART=" .. tostring(state.PreStartOpsGroups))
  if state.PreStartOpsGroups ~= 0 then violation("OPS_GROUPS_PRESENT_BEFORE_START") end

  if state.Violations > 0 then return false end

  -- The vertical policy above is deliberately set before this start call.
  safe("AIRWING_START", function()
    return airwing:Start()
  end)

  OMW.AirOps.TarinkotG7 = {
    Status = "RUNNING_IDLE_VALIDATION",
    Airbase = state.Airbase,
    Airwing = airwing,
    Squadrons = state.Squadrons,
    RolePayloads = state.RolePayloads,
    ParkingPools = {
      AH64 = { 21, 4 },
      UH60 = { 30, 27, 23 },
      CH47 = { 32, 29, 10 }
    }
  }

  log("AIRWING_START_CALLED verticalPolicySetBeforeStart=true missionsCreated=0 commanderCreated=0 transportCreated=0 deliberateSpawns=0")
  return state.Violations == 0
end

local function finish(status, reason, airwingRunning, opsGroups)
  if state.Finalized then return end
  state.Finalized = true

  local airwing = state.Airwing
  local cohortCount = countTable(airwing and airwing.cohorts)
  local rolePayloadCount = countTable(state.RolePayloads)
  local totalPayloadCount = countTable(airwing and airwing.payloads)
  local stockCount = countTable(airwing and airwing.stock)
  local missionQueueCount = countTable(airwing and airwing.missionqueue)
  local transportQueueCount = countTable(airwing and airwing.transportqueue)
  local requestQueueCount = countTable(airwing and airwing.queue)
  local activeClients = activePlayerClientCount()

  log(string.format(
    "RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION status=%s reason=%s violations=%d airwingRunning=%s squadrons=%d registeredGroups=%d registeredAircraft=%d stock=%d rolePayloads=%d totalPayloads=%d parkingPools=3 parkingIDs=%d missionQueue=%d transportQueue=%d requestQueue=%d opsGroups=%d safeParking=%s verticalPolicy=%s takeoffCold=%s activePlayerClients=%d commanderCreated=0 auftragCreated=0 opsTransportCreated=0 deliberateSpawns=0",
    tostring(status), tostring(reason or "none"), state.Violations,
    tostring(airwingRunning), cohortCount,
    EXPECTED.ExpectedRegisteredGroups, EXPECTED.ExpectedRegisteredAircraft,
    stockCount, rolePayloadCount, totalPayloadCount,
    EXPECTED.ExpectedParkingIDs, missionQueueCount,
    transportQueueCount, requestQueueCount, tonumber(opsGroups) or -1,
    tostring(airwing and airwing.safeparking == true),
    tostring(airwing and airwing.OptionPreferVerticalLanding == true),
    tostring(airwing and COORDINATE and COORDINATE.WaypointType and airwing.takeoffType == COORDINATE.WaypointType.TakeOffParking),
    activeClients
  ))

  if OMW.AirOps.TarinkotG7 then
    OMW.AirOps.TarinkotG7.Status = status
  end
end

local function inspectIdleFoundation()
  if state.Finalized then return end

  local airwing = state.Airwing
  if not airwing then
    violation("AIRWING_MISSING_AT_IDLE_INSPECTION")
    finish("FAIL", "AIRWING_MISSING", false, -1)
    return
  end

  local running = getAirwingRunning(airwing)
  local airwingState = safe("AIRWING_GET_STATE", function() return airwing:GetState() end)
  local opsGroups = getOpsGroupCount(airwing)
  local missionQueueCount = countTable(airwing.missionqueue)
  local transportQueueCount = countTable(airwing.transportqueue)
  local requestQueueCount = countTable(airwing.queue)
  local stockCount = countTable(airwing.stock)
  local activeClients = activePlayerClientCount()

  log(string.format(
    "IDLE_INSPECTION airwingState=%s airwingRunning=%s stock=%d missionQueue=%d transportQueue=%d requestQueue=%d opsGroups=%d activePlayerClients=%d",
    tostring(airwingState), tostring(running), stockCount,
    missionQueueCount, transportQueueCount, requestQueueCount,
    opsGroups, activeClients
  ))

  if not running then violation("AIRWING_NOT_RUNNING_AFTER_START state=" .. tostring(airwingState)) end
  if missionQueueCount ~= 0 then violation("SPONTANEOUS_MISSION_QUEUE count=" .. tostring(missionQueueCount)) end
  if transportQueueCount ~= 0 then violation("SPONTANEOUS_TRANSPORT_QUEUE count=" .. tostring(transportQueueCount)) end
  if requestQueueCount ~= 0 then violation("SPONTANEOUS_WAREHOUSE_REQUEST count=" .. tostring(requestQueueCount)) end
  if opsGroups ~= 0 then violation("UNEXPECTED_SPAWNED_OPS_GROUPS count=" .. tostring(opsGroups)) end
  if stockCount ~= EXPECTED.ExpectedRegisteredGroups then violation("STOCK_COUNT_CHANGED expected=5 actual=" .. tostring(stockCount)) end
  if activeClients ~= 0 then violation("ACTIVE_PLAYER_CLIENT_DURING_G7") end

  for _, contract in ipairs(EXPECTED.Squadrons) do
    local squadron = state.Squadrons[contract.Key]
    if not squadron then
      violation("SQUADRON_MISSING_AT_IDLE_INSPECTION family=" .. contract.Key)
    else
      local squadronState = squadron:GetState()
      local assets = countTable(squadron.assets)
      local parkingAccepted = numericListEqual(squadron.parkingIDs, contract.ParkingIDs)
      log(string.format(
        "SQUADRON_IDLE family=%s name=%s state=%s assets=%d expectedAssets=%d grouping=%s parkingIDs=%s parkingAccepted=%s",
        contract.Key, contract.Name, tostring(squadronState), assets,
        contract.Ngroups, tostring(squadron.ngrouping),
        join(squadron.parkingIDs), tostring(parkingAccepted)
      ))
      if assets ~= contract.Ngroups then violation("SQUADRON_ASSET_COUNT_CHANGED family=" .. contract.Key) end
      if tonumber(squadron.ngrouping) ~= contract.Grouping then violation("SQUADRON_GROUPING_CHANGED family=" .. contract.Key) end
      if not parkingAccepted then violation("SQUADRON_PARKING_CHANGED family=" .. contract.Key) end
    end
  end

  local pass = state.Violations == 0
  finish(pass and "PASS" or "FAIL", pass and "none" or "CONTRACT_VIOLATION", running, opsGroups)
end

local function main()
  log("BEGIN Tarinkot G7 combined AIRWING/SQUADRON/payload foundation")
  log(string.format(
    "BUILD builder=%s version=%s gitCommit=%s generatedUtc=%s",
    tostring(build.Builder), tostring(build.BuilderVersion),
    tostring(build.GitCommit), tostring(build.GeneratedUtc)
  ))
  log(string.format(
    "PROVENANCE expectedMooseRelease=%s expectedMooseCommit=%s expectedMooseSHA256=%s mission=OMW_Template_v6_Tarinkot.miz",
    EXPECTED.MooseRelease, EXPECTED.MooseCommit, EXPECTED.MooseSHA256
  ))
  log("SCOPE airwing=1 squadrons=3 capabilities=3families rolePayloads=3 parkingPools=3 startAirwing=true commander=0 auftrag=0 opsTransport=0 spawn=0 functionalZones=0 campaignStateMutation=0 mizMutation=0")

  if OMW.AirOps.TarinkotG7 then
    violation("G7_ALREADY_INITIALIZED")
    finish("INVALID", "DUPLICATE_INITIALIZATION", false, -1)
    return
  end

  local requiredClasses = {
    AIRBASE = AIRBASE,
    AIRWING = AIRWING,
    SQUADRON = SQUADRON,
    GROUP = GROUP,
    UNIT = UNIT,
    STATIC = STATIC,
    AUFTRAG = AUFTRAG,
    COORDINATE = COORDINATE
  }
  for name, value in pairs(requiredClasses) do
    if not value then violation("MOOSE_CLASS_UNAVAILABLE name=" .. name) end
  end

  if AIRBASE and (not AIRBASE.TerminalType or tonumber(AIRBASE.TerminalType.HelicopterOnly) ~= EXPECTED.HelicopterOnly) then
    violation("MOOSE_TERMINAL_TYPE_CONTRACT_UNAVAILABLE")
  end

  if activePlayerClientCount() > 0 then
    finish("INVALID", "ACTIVE_PLAYER_CLIENT", false, -1)
    return
  end

  validateWarehouse()
  validateStatics()
  validateAirbaseAndParking()

  if state.Violations > 0 then
    finish("FAIL", "PREFLIGHT_CONTRACT_VIOLATION", false, -1)
    return
  end

  if not constructFoundation() then
    finish("FAIL", "FOUNDATION_CONSTRUCTION_VIOLATION", false, -1)
    return
  end

  if SCHEDULER then
    SCHEDULER:New(nil, inspectIdleFoundation, {}, 15)
  else
    timer.scheduleFunction(function()
      inspectIdleFoundation()
      return nil
    end, nil, timer.getTime() + 15)
  end
end

if SCHEDULER then
  SCHEDULER:New(nil, main, {}, 8)
else
  timer.scheduleFunction(function()
    main()
    return nil
  end, nil, timer.getTime() + 8)
end
