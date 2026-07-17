  -- An enemy-triggered unpack deliberately spawns the expanded convoy inside
  -- the configured enemy relevance radius. DCS ground AI can accept its route
  -- and still hold position while engaging. Physical movement is therefore not
  -- a valid mandatory route-activation proof for this specific context.
  --
  -- The normal movement proof remains unchanged for initial spawn, manual
  -- unpack, player-only unpack, rollback and all other spawned representations.
  local originalAssignRouteForEnemyContact = assignRoute
  assignRoute = function(group, fromDistance)
    local pendingUnpack = controller.pendingUnpack
    local enemyTriggeredUnpack = pendingUnpack
      and pendingUnpack.automaticEnemyInterest == true
    local allowStationaryEnemyUnpack = config.transitions
      and config.transitions.allowStationaryEnemyTriggeredUnpack == true

    local routeOk, routeOrError = originalAssignRouteForEnemyContact(group, fromDistance)
    if routeOk
      and enemyTriggeredUnpack
      and allowStationaryEnemyUnpack
      and controller.pendingRouteActivation then
      local active = controller.pendingRouteActivation
      active.movementRequired = false
      active.confirmationPolicy = "ROUTE_ASSIGNED_DAMAGE_VERIFIED_ENEMY_RELEVANCE"
      active.enemyTriggeredUnpack = true
      logInfo("convoy_route_activation_policy_adjusted", {
        confirmationPolicy = active.confirmationPolicy,
        movementRequired = false,
        automaticEnemyInterest = true,
        reason = "enemy-triggered unpack may hold position while engaging",
      })
    end

    return routeOk, routeOrError
  end
