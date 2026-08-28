local TAG = "[OMW][AAR-PRODUCTION-FINAL-ACCEPTANCE-5][CycleControl]"
local POLL_SEC = 10
local HOLD_SEC = 24 * 60 * 60
local PRESERVE_NEAR_TRIGGER_SEC = 300

local tracks = {
  { area = "NELSON", profile = "FAST" },
  { area = "PATTY", profile = "SLOW" },
  { area = "KRUSTY", profile = "SLOW" },
  { area = "MILHOUSE", profile = "SLOW" },
}

local heldRuntime = {}

SCHEDULER:New(nil, function()
  local timestamp = timer.getAbsTime()
  for _, spec in ipairs(tracks) do
    local station = OMW.AAR.GetStation(spec.area, spec.profile)
    local active = station and station.activeRuntime or nil
    if station and active and active.onStationAt and not active.egressOrdered and not active.lossHandled
        and not station.reliefRuntime and not station.reliefQueued and station.reliefLaunchAt
        and station.reliefLaunchAt > timestamp + PRESERVE_NEAR_TRIGGER_SEC then
      station.reliefLaunchAt = timestamp + HOLD_SEC
      station.nextPlannedHandoverAt = timestamp + HOLD_SEC + OMW.AAR.GetConfig().reliefHandoverEtaSec
      if heldRuntime[active.runtimeId] ~= true then
        heldRuntime[active.runtimeId] = true
        env.info(string.format("%s HOLD_BACKGROUND_SCHEDULED_RELIEF runtime=%s area=%s reason=TEST_ISOLATION",
          TAG, active.runtimeId, spec.area))
      end
    end
  end
end, {}, 0, POLL_SEC)
