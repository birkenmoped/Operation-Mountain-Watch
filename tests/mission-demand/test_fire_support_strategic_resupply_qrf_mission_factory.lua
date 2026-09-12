local Factory = dofile("scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua")

local function eq(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function yes(value, label) if value ~= true then error(label .. " expected=true") end end
local function no(value, label) if value ~= false then error(label .. " expected=false") end end

local previousAuftrag = AUFTRAG
local created = {}
AUFTRAG = {}
function AUFTRAG:NewONGUARD(coordinate)
  local mission = { coordinate=coordinate, cancelCount=0 }
  function mission:SetTeleport(value) self.teleport=value return self end
  function mission:SetRequiredAssets(minimum, maximum) self.requiredMin=minimum; self.requiredMax=maximum; return self end
  function mission:SetPriority(priority, urgent) self.priority=priority; self.urgent=urgent; return self end
  function mission:Cancel() self.cancelCount=self.cancelCount+1 end
  created[#created + 1] = mission
  return mission
end

local resolvedDemand, resolvedContext, resolvedLegion
local coordinate = { marker="QRF_RESPONSE_COORDINATE" }
local factory = Factory.New({
  resolveCoordinate = function(demand, context, legion)
    resolvedDemand=demand; resolvedContext=context; resolvedLegion=legion
    return coordinate
  end,
  requiredAssetsMin = 1,
  requiredAssetsMax = 1,
})

local demand = { demandId="DEMAND|FOB_JOYCE|QRF|1", siteId="FOB_JOYCE", supportType="QRF", priority=17 }
local context = { marker="INCIDENT" }
local legion = { alias="BDE_BLUE_GND_JOYCE" }
local mission, made, reason = factory:Create(demand, context, legion)
yes(made, "QRF mission created")
eq(reason, nil, "QRF create reason")
eq(resolvedDemand, demand, "resolver demand")
eq(resolvedContext, context, "resolver context")
eq(resolvedLegion, legion, "resolver legion")
eq(mission.coordinate, coordinate, "ONGUARD coordinate")
eq(mission.teleport, false, "visible teleport disabled")
eq(mission.requiredMin, 1, "required assets min")
eq(mission.requiredMax, 1, "required assets max")
eq(mission.priority, 17, "demand priority forwarded")
eq(mission.urgent, false, "QRF does not preempt by default")

local unavailableFactory = Factory.New({
  resolveCoordinate = function() return nil, "QRF_RESPONSE_ANCHOR_NOT_CONFIGURED" end,
})
local unavailable, unavailableCreated, unavailableReason = unavailableFactory:Create({
  demandId="DEMAND|FOB_BOSTICK|QRF|1", siteId="FOB_BOSTICK", supportType="QRF"
}, {}, {})
eq(unavailable, nil, "missing coordinate returns no mission")
no(unavailableCreated, "missing coordinate not created")
eq(unavailableReason, "QRF_RESPONSE_ANCHOR_NOT_CONFIGURED", "missing coordinate reason")
eq(#created, 1, "no MOOSE mission built when coordinate missing")

local ok, err = pcall(function()
  factory:Create({ demandId="DEMAND|FOB_JOYCE|CAS|1", siteId="FOB_JOYCE", supportType="CAS" }, context, legion)
end)
no(ok, "non-QRF demand rejected")
yes(type(err)=="string" and string.find(err, "supportType QRF is required", 1, true) ~= nil, "non-QRF error text")

AUFTRAG = previousAuftrag
print("PASS test_fire_support_strategic_resupply_qrf_mission_factory")
