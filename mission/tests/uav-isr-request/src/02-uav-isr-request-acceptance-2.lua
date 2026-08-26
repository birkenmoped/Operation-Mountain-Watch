-- Acceptance 2: physical Kandahar UAV RECON dispatch.
-- Test-only profile. It does not certify a production terrain corridor.

local Acceptance = {}

function Acceptance.Start()
  OMW = OMW or {}
  OMW.Campaign = OMW.Campaign or {}

  local state = CampaignState.New({
    nodes = {
      {
        nodeId = "KANDAHAR_MAIN",
        airbaseName = "Kandahar",
        resources = {
          AIRCRAFT_MQ1A = { quantity = 4, unit = "count" },
          AIRCRAFT_MQ9 = { quantity = 2, unit = "count" },
        },
      },
    },
  })

  local coordinator = RequestCoordinator.New({
    blueCoalitionNumber = coalition.side.BLUE,
    submitRadiusMeters = 50000,
    requestIdPrefix = "ISR",
  })
  local adapter = UavCampaignStateAdapter.New({
    campaignState = state,
    nodeId = "KANDAHAR_MAIN",
  })
  local dispatcher = UavDispatcher.New({
    campaignAdapter = adapter,
    kandahar = OMW.AirOps.Kandahar,
    profiles = {
      {
        id = "KAF_MQ9_ACCEPTANCE",
        platformId = "MQ-9",
        resourceId = "AIRCRAFT_MQ9",
        template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
        reconAltitudeFeet = 25000,
        reconSpeedKnots = 180,
        reconRadiusMeters = 5000,
        onStationSeconds = 2700,
        performance = nil,
      },
    },
  })

  local menu = RequestMenu.New({
    coordinator = coordinator,
    blueCoalitionNumber = coalition.side.BLUE,
    now = function() return timer.getTime() end,
    onRequestQueued = function(request)
      local assignment, reason = dispatcher:Dispatch(request)
      if not assignment then
        return nil, reason
      end
      coordinator:MarkReserved(request.id, assignment.platformId, assignment.transactionId)
      coordinator:MarkAssigned(request.id, assignment.mission.name)
      return assignment
    end,
  })
  menu:RegisterBlueClients()

  OMW.ISR = OMW.ISR or {}
  OMW.ISR.Acceptance2 = {
    coordinator = coordinator,
    campaignState = state,
    dispatcher = dispatcher,
    menu = menu,
  }
  MESSAGE:New(
    "OMW UAV ISR Acceptance 2: ISR Cell ready. BLUE: set exact marker UAV RECON, then F10 > Command > ISR Cell. Kandahar MQ-9 dispatch is live.",
    30,
    "OMW"
  ):ToAll()
end

return Acceptance
