  -- rollbackProxy can halt after both the expanded spawn and proxy restoration
  -- fail. Ensure no stale transition object survives that terminal failure.
  local rollbackProxyWithCleanup = rollbackProxy
  rollbackProxy = function(pending, reason)
    local result = rollbackProxyWithCleanup(pending, reason)
    if controller.halted and controller.pendingUnpack ~= nil then
      controller.pendingUnpack = nil
      controller.arrivalRequested = false
      updateEntity({ transitionState = TRANSITION_IDLE })
    end
    return result
  end
