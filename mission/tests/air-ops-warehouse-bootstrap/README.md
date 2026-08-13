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

JP-8 wird nicht neu berechnet. Kandahar Main uebernimmt fuer dieses Gate den vor Testbeginn vorhandenen JETFUEL-Wert einmalig als Test-Preservation-Fixture. Diese Fixture ist nur Testaufbau und keine produktive Rueckautoritaet.

Der neue AVGAS-Wert bleibt:

```text
KANDAHAR_MAIN / FUEL_AVGAS
Initial/Target: 20,270.13583056 kg
Reorder:        12,065.557042 kg
Critical:        6,032.778521 kg
```

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

`NEW_APPLY_PASS` verlangt verifizierte strategische Item-, Fuel- und Technical-Availability-Readbacks sowie `status=READY`. AVGAS wird auf den freigegebenen Wert gesetzt; der erhaltene Kandahar-JP-8-Wert darf sich nicht aendern.

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

## Gepruefte Ausgangs-MIZ fuer diesen Gate

Vom Projektinhaber bereitgestellte Arbeitsdatei:

```text
OMW_Template_v8_AirOps_rdy(20260813-162436).miz
MIZ SHA-256: a4d0bf355fcabe25a1786c72f09d215b259ec90f258341dd5f88a755de3165a9
internal mission SHA-256: 99673d37979ae026f43f602190f3f3c41b7f0cb0a1bac3e0d054d9d6d635154f
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Beobachtete Ausgangs-Triggerfolge:

```text
mission startup: Moose.lua
T+5:  TM01M.lua
T+8:  OMW_AirOps_Bagram.lua
T+11: OMW_AirOps_Kandahar.lua
T+14: OMW_AirOps_Jalalabad.lua
T+17: OMW_AirOps_Salerno.lua
T+20: OMW_AirOps_Tarinkot.lua
T+24: OMW_AirOps_Shindand.lua
```

Der fruehere Harness-Delay von 10 Sekunden war fuer diese konkrete MIZ ungeeignet, weil Bagram bereits bei T+8 starten konnte. Der Harness startet deshalb jetzt nach 1 Sekunde und die AirOps-Trigger werden fuer die Acceptance-MIZ zusaetzlich durch `OMW_WAREHOUSE_READY` gesperrt.

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
Source MIZ structure/hash: VERIFIED
Local build/hash after readiness-gate correction: PENDING
Acceptance MIZ integration/hash: PENDING
DCS runtime: NOT_RUN
Acceptance: NOT_VALIDATED
```
