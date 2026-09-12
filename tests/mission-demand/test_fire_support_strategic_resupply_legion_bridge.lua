local Bridge = dofile("scripts/campaign/OMW_FireSupStratResupply_LegionBridge.lua")

local function eq(actual, expected, label)
  if actual ~= expected then error(string.format("%s expected=%s actual=%s", label, tostring(expected), tostring(actual))) end
end
local function yes(value, label) if value ~= true then error(label .. " expected=true") end end
local function no(value, label) if value ~= false then error(label .. " expected=false") end end

local legions = {
  FOB_JOYCE = { alias="BDE_BLUE_GND_JOYCE", missions={} },
  COP_HONAKER = { alias="BDE_BLUE_GND_HONAKER", missions={} },
}
for _, legion in pairs(legions) do
  function legion:AddMission(mission)
    self.missions[#self.missions + 1] = mission
    return self
  end
end

local resolved = {}
local created = {}
local bridge = Bridge.New({
  resolveLegion = function(siteId, demand, context)
    resolved[#resolved + 1] = { siteId=siteId, demand=demand, context=context }
    local legion = legions[siteId]
    if not legion then return nil, "SITE_LEGION_NOT_CONFIGURED" end
    return legion
  end,
  factory = function(demand, context, legion)
    if demand.requestKey == "REFUSE" then return nil, false, "TACTICAL_PREREQUISITE_MISSING" end
    local mission = { demandId=demand.demandId, context=context, legion=legion, cancelCount=0 }
    function mission:Cancel() self.cancelCount = self.cancelCount + 1 end
    created[#created + 1] = mission
    return mission, true, nil
  end,
})

local demand = { demandId="DEMAND|FOB_JOYCE|QRF|1", siteId="FOB_JOYCE", supportType="QRF" }
local context = { marker="incident-context" }
local handle, dispatched, reason = bridge:Dispatch(demand, context)
yes(dispatched, "local QRF dispatched")
eq(reason, nil, "first dispatch reason")
eq(resolved[1].siteId, "FOB_JOYCE", "resolver site")
eq(resolved[1].demand, demand, "resolver demand")
eq(resolved[1].context, context, "resolver context")
eq(created[1].legion, legions.FOB_JOYCE, "factory receives resolved legion")
eq(#legions.FOB_JOYCE.missions, 1, "one local MOOSE mission queued")
eq(legions.FOB_JOYCE.missions[1], handle.mission, "queued mission is handle mission")
eq(#legions.COP_HONAKER.missions, 0, "other site legion untouched")

local duplicate, duplicateCreated, duplicateReason = bridge:Dispatch(demand, context)
eq(duplicate, handle, "duplicate returns existing handle")
no(duplicateCreated, "duplicate not redispatched")
eq(duplicateReason, "ALREADY_DISPATCHED", "duplicate reason")
eq(#legions.FOB_JOYCE.missions, 1, "duplicate did not add mission")

yes(handle:Cancel(), "first cancel forwarded")
no(handle:Cancel(), "second cancel idempotent")
eq(handle.mission.cancelCount, 1, "MOOSE Cancel called once")

local refused, refusedCreated, refusedReason = bridge:Dispatch({
  demandId="DEMAND|COP_HONAKER|QRF|REFUSE", siteId="COP_HONAKER", supportType="QRF", requestKey="REFUSE"
}, {})
eq(refused, nil, "factory refusal has no handle")
no(refusedCreated, "factory refusal not dispatched")
eq(refusedReason, "TACTICAL_PREREQUISITE_MISSING", "factory refusal reason propagated")
eq(#legions.COP_HONAKER.missions, 0, "factory refusal does not queue mission")

local unavailable, unavailableCreated, unavailableReason = bridge:Dispatch({
  demandId="DEMAND|FOB_BOSTICK|QRF|1", siteId="FOB_BOSTICK", supportType="QRF"
}, {})
eq(unavailable, nil, "unconfigured site has no handle")
no(unavailableCreated, "unconfigured site not dispatched")
eq(unavailableReason, "SITE_LEGION_NOT_CONFIGURED", "resolver reason propagated")

-- Contract guard: the bridge receives no cohort/asset candidate list and performs no
-- selection itself. The only operational submission is LEGION:AddMission().
eq(#created, 1, "only successful dispatch created mission")

print("PASS test_fire_support_strategic_resupply_legion_bridge")
