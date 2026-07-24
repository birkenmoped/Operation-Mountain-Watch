-- Operation Mountain Watch - Phase 1 corrected sequence finalization for single-ship assets
local TAG = "[OMW][AirOps.JBAD.PH1.SEQUENCE]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
local controller = ph1 and ph1.Controller
if not cfg or not ph1 or not controller then
  log("ERROR: Phase 1 controller unavailable.")
else
  local expectedAssetGroups = { OH58D = 24, AH64D = 8, UH60 = 8, CH47 = 8 }

  local function queueCount()
    local count = 0
    for _ in pairs((cfg.Airwing and cfg.Airwing.missionqueue) or {}) do count = count + 1 end
    return count
  end

  local function inventoryReady(snapshots)
    for key, expected in pairs(expectedAssetGroups) do
      local item = snapshots and snapshots[key]
      if not item or item.total ~= expected or item.available ~= expected or item.busy ~= 0 then return false end
    end
    return true
  end

  local function coalitionMessage(text, seconds)
    if trigger and trigger.action and trigger.action.outTextForCoalition then
      trigger.action.outTextForCoalition(coalition.side.BLUE, "OMW Jalalabad Phase 1\n" .. tostring(text), seconds or 20)
    end
  end

  function controller:StartNextSequenceTest()
    if not ph1.AutoSequence then return false end
    ph1.SequenceIndex = ph1.SequenceIndex + 1
    local testId = ph1.Sequence[ph1.SequenceIndex]
    if testId then return self:StartTest(testId) end

    ph1.AutoSequence = false
    local inventoryOK = inventoryReady(ph1.Observer:SnapshotAllSquadrons())
    local allPassed = true
    for _, completedId in ipairs(ph1.Sequence) do
      local result = ph1.Results[completedId]
      if not result or result.Classification ~= "PASS" or result.Released ~= true then allPassed = false break end
    end
    local cleanCounters = (ph1.Counters.unexpectedSpawns or 0) == 0 and
                          (ph1.Counters.parkingViolations or 0) == 0 and
                          (ph1.Counters.losses or 0) == 0 and
                          (ph1.Counters.timeouts or 0) == 0
    local finalPass = allPassed and inventoryOK and queueCount() == 0 and cleanCounters
    ph1.Classification = finalPass and "PASS" or "FAIL"
    if finalPass then
      log("RESULT: PASS testsPassed=5/5 abortRelease=PASS unexpectedSpawns=0 parkingViolations=0 losses=0 blockedAssets=0 finalInventoryRestored=true")
    else
      log(string.format("RESULT: FAIL testsPassed=%s abortRelease=%s unexpectedSpawns=%d parkingViolations=%d losses=%d timeouts=%d blockedAssets=%s finalInventoryRestored=%s",
        allPassed and "5/5" or "incomplete",
        ph1.Results.UH60_ABORT and ph1.Results.UH60_ABORT.Classification or "NOT_RUN",
        ph1.Counters.unexpectedSpawns or 0,
        ph1.Counters.parkingViolations or 0,
        ph1.Counters.losses or 0,
        ph1.Counters.timeouts or 0,
        inventoryOK and "0" or "nonzero",
        tostring(inventoryOK and queueCount() == 0)))
    end
    coalitionMessage(finalPass and "GESAMTERGEBNIS: PASS\n5/5 Tests bestanden." or "GESAMTERGEBNIS: FAIL\nStatus und dcs.log prüfen.", 25)
    return finalPass
  end

  log("READY finalInventory=24/8/8/8 sequenceFinalizationOverride=true")
end
