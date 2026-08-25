-- OMW UAV ISR Acceptance 1: marker/menu integration only.
-- This source is bundled by tools/build-uav-isr-request-acceptance-1.ps1.

local Acceptance = {}

local function fail(message)
  error("[OMW][UAV.ISR.Acceptance1] " .. message, 2)
end

local function requireTable(value, name)
  if type(value) ~= "table" then
    fail(name .. " is required")
  end
  return value
end

function Acceptance.Start(dependencies)
  dependencies = requireTable(dependencies, "dependencies")
  local coordinatorModule = requireTable(dependencies.coordinatorModule, "coordinatorModule")
  local menuModule = requireTable(dependencies.menuModule, "menuModule")
  local moose = requireTable(dependencies.moose, "moose")

  if _G.OMW_UAV_ISR_ACCEPTANCE_1 then
    fail("Acceptance 1 is already running")
  end

  local coordinator = coordinatorModule.New({
    blueCoalitionNumber = 2,
    submitRadiusMeters = 10000,
    requestIdPrefix = "ISR"
  })

  local requestMenu = menuModule.New({
    coordinator = coordinator,
    blueCoalitionNumber = 2,
    moose = moose
  })

  requestMenu:RegisterBlueClients()

  if moose.MESSAGE and moose.MESSAGE.New then
    moose.MESSAGE:New(
      "ISR Cell ready. Set a BLUE map marker exactly: UAV RECON. Then use F10 > Command > ISR Cell.",
      30,
      "OMW UAV ISR Acceptance 1",
      false
    ):ToAll()
  end

  local runtime = {
    coordinator = coordinator,
    requestMenu = requestMenu,
    testOnlySubmitRadiusMeters = 10000
  }

  _G.OMW_UAV_ISR_ACCEPTANCE_1 = runtime
  return runtime
end

return Acceptance
