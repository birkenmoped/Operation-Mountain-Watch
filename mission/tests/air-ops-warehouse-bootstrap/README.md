# AirOps Warehouse Bootstrap Acceptance

## Ziel

Dieser Test prueft den zentralen produktiven Warehouse-Bootstrap gegen die aktuelle AirOps-Stock-Baseline. Abgeschlossene Bestandsentscheidungen werden nicht neu berechnet.

## Test-ID

```text
AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1
```

## Source / Builder / Dist

```text
mission/tests/air-ops-warehouse-bootstrap/src/01-air-ops-warehouse-bootstrap-acceptance.lua
tools/build-air-ops-warehouse-bootstrap.ps1
mission/tests/air-ops-warehouse-bootstrap/dist/OMW_AirOps_Warehouse_Bootstrap.lua
```

`dist/` wird ausschliesslich durch den Builder erzeugt.

## Fuel-Grenze

JP-8 wird nicht neu berechnet. Kandahar Main uebernimmt fuer dieses Gate den vor Testbeginn vorhandenen JETFUEL-Wert einmalig als Test-Preservation-Fixture. Diese Fixture ist ausschliesslich Bestandteil des Acceptance-Harness und keine produktive Rueckautoritaet. Der produktive `OMW_AirOpsWarehouseBootstrap` liest keinen DCS-Warehouse-Startwert in `CampaignState` zurueck.

Der neue AVGAS-Wert bleibt:

```text
KANDAHAR_MAIN / FUEL_AVGAS
Initial/Target: 20,270.13583056 kg
Reorder:        12,065.557042 kg
Critical:        6,032.778521 kg
```

### DCS-Liquid-Readback-Toleranz

Der erste integrierte DCS-Lauf am 13.08.2026 zeigte bei Kandahar AVGAS nach `STORAGE:SetLiquid()` folgende reale Quantisierung:

```text
requested: 20270.13583056 kg
observed:  20270.13671875 kg
delta:         0.00088819 kg
```

Eine exakte Lua-Float-Gleichheit ist fuer den DCS-Liquid-Readback damit nicht belastbar. `OMW_StorageFuelAdapter.lua` verwendet deshalb fuer Plan, Write-Entscheidung, Readback-Verifikation und Idempotenz ein einheitliches Fenster von:

```text
ReadbackToleranceKg = 0.5
```

Die Toleranz aendert keinen strategischen Bestand. `CampaignState` bleibt autoritativ; sie verhindert ausschliesslich Fehlalarme und wiederholte Mikro-Writes durch DCS-Quantisierung innerhalb von 0.5 kg. Abweichungen ueber 0.5 kg bleiben fail-closed.

## Erwartete Marker

```text
START
JP8_PRESERVATION_FIXTURE
NEW_PREFLIGHT_PASS
NEW_APPLY_PASS
RESTORE_PASS
AIR_OPS_START_GATE_PASS
RESULT status=PASS
```

`NEW_APPLY_PASS` verlangt verifizierte strategische Item-, Fuel- und Technical-Availability-Readbacks sowie `status=READY`. AVGAS wird auf den freigegebenen Wert gesetzt; der erhaltene Kandahar-JP-8-Wert darf sich im Acceptance-Fixture nicht ausserhalb der Fuel-Toleranz aendern.

`RESTORE_PASS` verlangt:

```text
strategicChanges=0
fuelChanges=0
technicalChanges=0
initialReset=false
status=READY
```

## AirOps-Startgate

Das Acceptance-Harness verwendet die im gepinnten `Moose.lua` vorhandene Klasse `USERFLAG`:

```lua
local readyFlag = USERFLAG:New("OMW_WAREHOUSE_READY")
readyFlag:Set(0)
-- Warehouse NEW + RESTORE acceptance
readyFlag:Set(1)
```

`USERFLAG:New()`, `USERFLAG:Set()` und `USERFLAG:Get()` wurden gegen das eingebettete MOOSE-Artefakt `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` geprueft. Das Gate wird zu Beginn auf `0` gesetzt und erst nach erfolgreichem NEW-, Readback- und RESTORE-Pfad auf `1` gesetzt. Bei Harness-Fehler bleibt beziehungsweise wird es `0`.

Die produktiven AirOps-DO-SCRIPT-FILE-Trigger der Acceptance-MIZ duerfen daher nicht nur zeitgesteuert starten. Sie muessen zusaetzlich auf `OMW_WAREHOUSE_READY == 1` warten. Damit ist ein Warehouse-Fehler fail-closed und AIRWING startet nicht vor erfolgreicher Ressourceninitialisierung.

## Triggerfolge fuer den aktuellen Acceptance-Lauf

```text
MISSION START: Moose.lua
T+1:  OMW_AirOps_Warehouse_Bootstrap.lua
T+5:  TM01M.lua
T+8:  OMW_AirOps_Bagram.lua      AND OMW_WAREHOUSE_READY == 1
T+11: OMW_AirOps_Kandahar.lua    AND OMW_WAREHOUSE_READY == 1
T+14: OMW_AirOps_Jalalabad.lua   AND OMW_WAREHOUSE_READY == 1
T+17: OMW_AirOps_Salerno.lua     AND OMW_WAREHOUSE_READY == 1
T+20: OMW_AirOps_Tarinkot.lua    AND OMW_WAREHOUSE_READY == 1
T+24: OMW_AirOps_Shindand.lua    AND OMW_WAREHOUSE_READY == 1
```

Das Bundle wird bei T+1 geladen. Der Harness startet intern nach `START_DELAY_SECONDS = 1`, also ungefaehr bei T+2. Die AirOps-Startzeiten bleiben zusaetzlich durch das READY-Flag gesperrt.

## MIZ-Einbindung

Gemaess `docs/22-test-mission-build-transfer-and-validation-workflow.md`:

```text
1. Moose.lua
2. OMW_AirOps_Warehouse_Bootstrap.lua
3. Warehouse READY
4. produktive AirOps Foundations
```

Vor dem DCS-Lauf muessen Branch/Commit, BuilderVersion, GeneratedUtc, Bundle-Hash, MIZ-Hash, interner mission-Hash, eingebetteter Bundle-Hash, eingebetteter Moose.lua-Hash und der Objektvertrag der sieben AirOps-STORAGE-Endpunkte feststehen.

## Status

```text
Source/Builder: IMPLEMENTED
Fuel quantization correction: IMPLEMENTED, DCS RETEST PENDING
AirOps READY gate in working MIZ: CONFIGURED
Updated local build/hash: PENDING
Updated Acceptance MIZ hash chain: PENDING
DCS runtime retest: NOT_RUN
Acceptance: NOT_VALIDATED
```
