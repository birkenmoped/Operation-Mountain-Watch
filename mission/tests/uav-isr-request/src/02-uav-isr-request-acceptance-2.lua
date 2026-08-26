-- Acceptance 2: physical Kandahar UAV RECON dispatch.
-- Test-only profile. It does not certify a production terrain corridor.

local Acceptance = {}

function Acceptance.Start()
  OMW = OMW or {}
  OMW.Campaign = OMW.Campaign or {}

  local kandahar = OMW.AirOps and OMW.AirOps.Kandahar or nil
  if not kandahar or kandahar.Status ~= "RUNNING" then
    error("Kandahar AIRWING foundation is not running")
  end

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
    kandahar = kandahar,
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
    onRequestCancelled = function(request)
      if request.transactionId then adapter:CancelBeforePhysicalStart(request.id) end
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

function Acceptance.StartWhenKandaharReady()
  local attempts = 0
  local maximumAttempts = 18
  local scheduler = nil

  local function kandaharIsReady()
    local kandahar = OMW and OMW.AirOps and OMW.AirOps.Kandahar or nil
    return kandahar
      and kandahar.Status == "RUNNING"
      and kandahar.Airwings
      and kandahar.Airwings.Main
  end

  local function beginWhenReady()
    attempts = attempts + 1
    if kandaharIsReady() then
      scheduler:Stop()
      Acceptance.Start()
      return
    end

    if attempts >= maximumAttempts then
      scheduler:Stop()
      env.error("[OMW][ISR.Acceptance2] Kandahar AIRWING foundation did not reach RUNNING state", false)
      MESSAGE:New(
        "OMW UAV ISR Acceptance 2: Kandahar AIRWING is unavailable; dispatch test stopped.",
        30,
        "OMW"
      ):ToAll()
    end
  end

  scheduler = SCHEDULER:New(nil, beginWhenReady, {}, 1, 5)
end

return Acceptance
