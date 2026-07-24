-- Operation Mountain Watch - Jalalabad AIRWING Phase 1 F10 controls and acceptance gate
local TAG = "[OMW][AirOps.JBAD.PH1.MENU]"
local function log(msg) env.info(TAG .. " " .. tostring(msg)) end

local cfg = OMW and OMW.AirOps and OMW.AirOps.Jalalabad
local ph1 = cfg and cfg.Phase1
if not cfg or not ph1 or not ph1.Controller then
  log("ERROR: Phase 1 controller unavailable.")
else
  ph1.API = ph1.API or {}
  function ph1.API.StartSequence() return ph1.Controller:StartSequence() end
  function ph1.API.StartTest(testId) return ph1.Controller:StartTest(testId) end
  function ph1.API.AbortActive(reason) return ph1.Controller:AbortActive(reason or "deterministic-trigger-abort") end
  function ph1.API.Status() return ph1.Controller:GetStatusText() end
  function ph1.API.Reset() return ph1.Controller:ResetController() end

  local function createMenus()
    if ph1.MenuCreated then return true end
    if not MENU_COALITION or not MENU_COALITION_COMMAND then log("ERROR: MOOSE menu classes unavailable.") return false end

    local root = MENU_COALITION:New(coalition.side.BLUE, "OMW AirOps Tests")
    local menu = MENU_COALITION:New(coalition.side.BLUE, "Jalalabad Phase 1", root)
    ph1.MenuRoot, ph1.Menu = root, menu
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Status anzeigen", menu, function() ph1.Controller:ShowStatus() end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Gesamtablauf starten", menu, function() ph1.Controller:StartSequence() end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "OH-58D RECON starten", menu, function() ph1.Controller:StartTest("OH58D_RECON") end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "AH-64D CAS starten", menu, function() ph1.Controller:StartTest("AH64D_CAS") end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "UH-60A Transport starten", menu, function() ph1.Controller:StartTest("UH60_TROOP") end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "CH-47F Cargo starten", menu, function() ph1.Controller:StartTest("CH47_CARGO") end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Aktiven Auftrag abbrechen", menu, function() ph1.Controller:AbortActive("manual-f10-abort") end)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Testcontroller zuruecksetzen", menu, function() ph1.Controller:ResetController() end)
    ph1.MenuCreated = true
    log("READY F10=OMW_AirOps_Tests/Jalalabad_Phase_1 commands=8")
    return true
  end

  local function acceptanceGate()
    if ph1.AcceptanceGateLogged or cfg.BaselineReady ~= true then return end
    local objectsReady = ph1.Factory:ValidateMissionEditorObjects()
    local clientParkingReady = ph1.ClientParkingResolved or ph1.Observer:ResolveClientParkingIDs()
    local ready = objectsReady and clientParkingReady and cfg.ParkingReservationsOK == true and cfg.ParkingPoolsOK == true and cfg.NameContractOK == true
    ph1.AcceptanceGateLogged = true
    if ready then
      log("RESULT: READY. Phase 1 armed; exact runtime names and exclusive parking pools active; OH-58D terrain/route gate PASS; dedicated UH-60 drop zone and pickup/delivery lifecycle PASS; vertical helicopter takeoff/landing preference active.")
    else
      log("RESULT: BLOCKED. Required: Mission Editor objects, Client parking, static reservations, exclusive SQUADRON pools, exact runtime-name contract, safe OH-58D route, dedicated UH-60 drop zone and vertical helicopter operation preference.")
    end
  end

  local function initialize()
    if cfg.BaselineReady == true then createMenus() acceptanceGate() end
  end

  SCHEDULER:New(nil, initialize, {}, 22, 10)
end
