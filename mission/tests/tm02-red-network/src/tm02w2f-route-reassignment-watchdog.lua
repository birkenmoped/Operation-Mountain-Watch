local TM02W2FRouteReassignmentWatchdog = {}

function TM02W2FRouteReassignmentWatchdog.install()
  error("TM02W2F legacy route-reassignment watchdog is disabled; direct off-road canary runs permit no automatic recovery")
end

return TM02W2FRouteReassignmentWatchdog
