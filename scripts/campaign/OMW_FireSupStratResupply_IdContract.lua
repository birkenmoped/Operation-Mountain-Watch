-- Operation Mountain Watch - Fire Support / Strategic Resupply stable ID contract.
-- Campaign-domain only. No MOOSE/DCS dependency.

local IdContract = {}

IdContract.SchemaVersion = "OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ID-CONTRACT-2"

local function requireToken(value, label)
  if type(value) ~= "string" or value == "" then
    error("[OMW][FireSupStratResupply.IdContract] " .. label .. " requires non-empty string", 2)
  end
  return value
end

function IdContract.Site(siteId)
  return "SITE:" .. requireToken(siteId, "siteId")
end

function IdContract.Incident(siteId, incidentKey)
  return "INCIDENT:" .. requireToken(siteId, "siteId") .. ":" .. requireToken(incidentKey, "incidentKey")
end

function IdContract.Demand(incidentId, supportType, requestKey)
  local id = "DEMAND:" .. requireToken(incidentId, "incidentId") .. ":" .. requireToken(supportType, "supportType")
  if requestKey ~= nil then
    id = id .. ":" .. requireToken(requestKey, "requestKey")
  end
  return id
end

function IdContract.Settlement(demandId, lifecycleEvent, sourceEventId)
  return table.concat({
    "SETTLEMENT",
    requireToken(demandId, "demandId"),
    requireToken(lifecycleEvent, "lifecycleEvent"),
    requireToken(sourceEventId, "sourceEventId"),
  }, ":")
end

return IdContract
