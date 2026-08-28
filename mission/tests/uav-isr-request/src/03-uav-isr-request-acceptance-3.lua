-- Acceptance 3: physical Kandahar UAV orbit with an on-station contract.
-- Test-only profile. It verifies MOOSE lifecycle events and is not a production
-- terrain, holding, recovery-credit or multi-sortie clearance.

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
  local menu = nil
  local dispatcher = UavDispatcher.New({
    campaignAdapter = adapter,
    source = kandahar,
    profiles = {
      {
        id = "KAF_MQ9_ORBIT_ACCEPTANCE",
        platformId = "MQ-9",
        resourceId = "AIRCRAFT_MQ9",
        template = "TPL_AIR_US_KAF_MQ9_RECON_1SHIP",
        airwingKey = "Main",
        squadronKey = "MQ9",
        missionKind = "ORBIT_CIRCLE",
        reconAltitudeFeet = 25000,
        reconSpeedKnots = 180,
        onStationSeconds = 2700,
        performance = nil,
      },
    },
    onMissionStarted = function(request)
      assert(coordinator:MarkLaunching(request.id))
    end,
    onMissionExecuting = function(request)
      assert(coordinator:MarkOnStation(request.id))
    end,
    onMissionCancelled = function(request)
      assert(coordinator:MarkReturning(request.id))
    end,
    onMissionCancelledBeforeStart = function()
      -- The menu atomically cancels the coordinator request and releases the
      -- CampaignState reservation after MOOSE removes the queued mission.
    end,
    onMissionDone = function(request)
      assert(coordinator:MarkCompleted(request.id))
    end,
    onMissionRecovered = function(request, _, recovery)
      local seconds = recovery and recovery.turnoverSeconds or nil
      if menu and type(seconds) == "number" and seconds > 0 then
        local minutes = math.ceil(seconds / 60)
        menu:NotifyGroupId(
          request.ownerGroupId,
          string.format(
            "ISR Cell: %s recovered. MQ-9 is in MOOSE turnaround; next availability in about %d min.",
            tostring(request.id),
            minutes
          )
        )
      end
    end,
  })

  menu = RequestMenu.New({
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
    onRequestCancellation = function(group, request)
      local outcome, reason = dispatcher:CancelRequest(request.id)
      if not outcome then return nil, reason end

      if outcome == "CANCELLED_BEFORE_START" then
        local cancelled, cancelReason = coordinator:CancelOwnRequest(group:GetID())
        if not cancelled then return nil, cancelReason end
        local transaction, releaseReason = adapter:CancelBeforePhysicalStart(request.id)
        if not transaction then return nil, releaseReason end
        return "CANCELLED"
      end

      return outcome
    end,
  })
  menu:RegisterBlueClients()

  OMW.ISR = OMW.ISR or {}
  OMW.ISR.Acceptance3 = {
    coordinator = coordinator,
    campaignState = state,
    dispatcher = dispatcher,
    menu = menu,
  }
  MESSAGE:New(
    "OMW UAV ISR Acceptance 3: ISR Cell ready. BLUE: set exact marker UAV RECON, then F10 > Command > ISR Cell. MQ-9 will orbit on station for 45 minutes.",
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
      env.error("[OMW][ISR.Acceptance3] Kandahar AIRWING foundation did not reach RUNNING state", false)
      MESSAGE:New(
        "OMW UAV ISR Acceptance 3: Kandahar AIRWING is unavailable; dispatch test stopped.",
        30,
        "OMW"
      ):ToAll()
    end
  end

  scheduler = SCHEDULER:New(nil, beginWhenReady, {}, 1, 5)
end

return Acceptance
