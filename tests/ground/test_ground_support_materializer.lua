local Materializer = dofile("scripts/ground/OMW_GroundSupportMaterializer.lua")

local function fail(message)
  error("GROUND_SUPPORT_MATERIALIZER_TEST " .. tostring(message), 2)
end

local function expectEqual(actual, expected, label)
  if actual ~= expected then
    fail(label .. " expected=" .. tostring(expected) .. " actual=" .. tostring(actual))
  end
end

local brigade = {
  platoons = {},
  requests = {},
}

function brigade:AddPlatoon(platoon)
  self.platoons[#self.platoons + 1] = platoon
  return self
end

function brigade:AddRequest(warehouse, descriptor, value, nasset, transportType, ntransport, prio, assignment)
  self.requests[#self.requests + 1] = {
    warehouse = warehouse,
    descriptor = descriptor,
    value = value,
    nasset = nasset,
    transportType = transportType,
    ntransport = ntransport,
    prio = prio,
    assignment = assignment,
  }
end

function brigade:GetAssignment(request)
  return request.assignment
end

local factoryCalls = 0
local materializedCount = 0
local materializedGroup = { name = "BOSTICK-M1083-001" }

local service = Materializer.New({
  brigade = brigade,
  platoonFactory = function(templateName, count, platoonName)
    factoryCalls = factoryCalls + 1
    return {
      templateName = templateName,
      count = count,
      platoonName = platoonName,
    }
  end,
  descriptorGroupName = "GROUPNAME",
  templateName = "TPL_BLUE_GND_SUP_M1083",
  platoonName = "PLT_BLUE_GND_BOSTICK_AMMO_SUPPORT",
  assignment = "OMW:BOSTICK:AMMO-SUPPORT:M1083",
  stockCount = 1,
  priority = 20,
  onMaterialized = function(group)
    materializedCount = materializedCount + 1
    expectEqual(group, materializedGroup, "MATERIALIZED_GROUP_CALLBACK")
  end,
})

expectEqual(factoryCalls, 1, "FACTORY_CALLS")
expectEqual(#brigade.platoons, 1, "PLATOON_REGISTERED")
expectEqual(service:GetPlatoon(), brigade.platoons[1], "PLATOON_HANDLE")

local groupBefore, requested = service:Request()
expectEqual(groupBefore, nil, "GROUP_BEFORE_CALLBACK")
expectEqual(requested, true, "FIRST_REQUEST_CREATED")
expectEqual(#brigade.requests, 1, "REQUEST_COUNT")
expectEqual(brigade.requests[1].warehouse, brigade, "SELF_REQUEST_WAREHOUSE")
expectEqual(brigade.requests[1].descriptor, "GROUPNAME", "REQUEST_DESCRIPTOR")
expectEqual(brigade.requests[1].value, "TPL_BLUE_GND_SUP_M1083", "REQUEST_TEMPLATE")
expectEqual(brigade.requests[1].nasset, 1, "REQUEST_ASSET_COUNT")
expectEqual(brigade.requests[1].prio, 20, "REQUEST_PRIORITY")
expectEqual(brigade.requests[1].assignment, "OMW:BOSTICK:AMMO-SUPPORT:M1083", "REQUEST_ASSIGNMENT")

local groupPending, requestedAgain = service:Request()
expectEqual(groupPending, nil, "GROUP_WHILE_PENDING")
expectEqual(requestedAgain, false, "NO_DUPLICATE_REQUEST")
expectEqual(#brigade.requests, 1, "NO_DUPLICATE_REQUEST_COUNT")

local request = brigade.requests[1]
local groupset = {
  GetSetObjects = function()
    return { materializedGroup }
  end,
}
brigade:OnAfterSelfRequest("Running", "SelfRequest", "Running", groupset, request)

expectEqual(materializedCount, 1, "MATERIALIZED_CALLBACK_COUNT")
expectEqual(service:GetMaterializedGroup(), materializedGroup, "MATERIALIZED_GROUP")

local existingGroup, createdAgain = service:Request()
expectEqual(existingGroup, materializedGroup, "IDEMPOTENT_GROUP")
expectEqual(createdAgain, false, "IDEMPOTENT_REQUEST")
expectEqual(#brigade.requests, 1, "IDEMPOTENT_REQUEST_COUNT")

print("PASS Ground MOOSE warehouse self-request support materializer contract")
