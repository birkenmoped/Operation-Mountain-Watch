local Acceptance = dofile("mission/tests/uav-isr-request/src/03-uav-isr-request-acceptance-3.lua")

local turnover = nil
local dispatcherConfig = nil

OMW = {
  AirOps = {
    Kandahar = {
      Status = "RUNNING",
      Airwings = {
        Main = {
          AddMission = function() end,
          NewPayload = function() end,
        },
      },
      Squadrons = {
        MQ9 = {
          SetTurnoverTime = function(_, maintenanceMinutes, repairMinutes)
            turnover = { maintenanceMinutes, repairMinutes }
          end,
        },
      },
    },
  },
}

CampaignState = {
  New = function(config)
    assert(config.nodes[1].resources.AIRCRAFT_MQ9.quantity == 2)
    return {}
  end,
}

RequestCoordinator = {
  New = function()
    return {}
  end,
}

UavCampaignStateAdapter = {
  New = function()
    return {}
  end,
}

UavDispatcher = {
  New = function(config)
    dispatcherConfig = config
    return {
      Dispatch = function() end,
      CancelRequest = function() end,
    }
  end,
}

RequestMenu = {
  New = function()
    return {
      RegisterBlueClients = function() end,
    }
  end,
}

coalition = { side = { BLUE = 2 } }

MESSAGE = {
  New = function()
    return {
      ToAll = function() end,
    }
  end,
}

Acceptance.Start()

assert(turnover[1] == 0)
assert(turnover[2] == 0)
assert(dispatcherConfig.source == OMW.AirOps.Kandahar)
assert(dispatcherConfig.profiles[1].squadronKey == "MQ9")

print("PASS test_isr_uav_acceptance_3")
