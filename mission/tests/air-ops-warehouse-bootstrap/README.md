---
document_id: OMW-TEST-AIROPS-WAREHOUSE-BOOTSTRAP-INDEX
status: BINDING
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AirOps Warehouse bootstrap acceptance test layout
  - Warehouse bootstrap build, Mission Editor and READY-gate prerequisites
not_authoritative_for:
  - strategic stock recalculation
  - persistence transport
  - reverse STORAGE authority
  - technical acceptance outside the linked exact DCS-tested baseline
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# AirOps Warehouse Bootstrap Acceptance

## Ziel

Dieser Test prueft den zentralen produktiven Warehouse-Bootstrap gegen die aktuelle AirOps-Stock-Baseline. Abgeschlossene Bestandsentscheidungen werden nicht neu berechnet.

Der exakte bestandene DCS-Stand ist dokumentiert in:

- [`OMW-TEST-AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE`](expected/air-ops-warehouse-bootstrap-acceptance-2026-08-13.md)

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

## Triggerfolge fuer den akzeptierten Lauf

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

## Akzeptierter Stand vom 13.08.2026

```text
Acceptance branch:
agent/air-ops-initial-stock-runtime-data

Acceptance commit:
2502516fe130b908e500117142399b3e2ca74007

Generated / embedded bundle SHA-256:
025855c07896ee396b545ae2b131c2f4181e6eed88c412580288d644f4d311ac

MIZ SHA-256:
dd25f68a7361c36fa121a581022a9535f55372ad1f32a7992d4013e9c6f0c0d8

Embedded mission SHA-256:
b8b739ce82aea204ba72f6f6d9d8cf1fb22ac693fb0ea4f06158a0188fd61296

Warehouses SHA-256:
3831fcfe50c1fb61553dba26356f2840d917cd0cb6009137467100a46483e171

DCS:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Result:
PASS / OMW_WAREHOUSE_READY = 1
```

## Status

```text
Source/Builder: IMPLEMENTED
Fuel quantization correction: DCS VALIDATED
AirOps READY gate: DCS VALIDATED
NEW bootstrap: DCS VALIDATED
RESTORE/idempotence: DCS VALIDATED
Acceptance: ACCEPTED_TECHNICAL_BASELINE
```

## Repository-Integrationsstand vom 13.08.2026

Der Acceptance-Nachweis bleibt an Commit `2502516fe130b908e500117142399b3e2ca74007` gebunden. Die nachfolgenden Commits auf diesem Branch dokumentieren den bestandenen Lauf und aendern dessen technische Provenienz nicht.

GitHub-Stand zum Dokumentationszeitpunkt:

```text
PR: #86
Branch: agent/air-ops-initial-stock-runtime-data
PR status: OPEN / DRAFT / NOT MERGED
Accepted technical baseline: commit 2502516fe130b908e500117142399b3e2ca74007
PR #85: MERGED to main as 3b4d2470639409e9a82ceed0fee85aa0627c0b3c
Current main at merge assessment: 3223db1f7eb130ae2070a926b6f476e6a010f515
Branch relationship to current main: DIVERGED
GitHub mergeable: false
```

Damit ist der Warehouse-Bootstrap technisch akzeptiert, aber PR #86 kann in seinem aktuellen Git-Zustand nicht direkt nach `main` gemergt werden. Vor einer Mergefreigabe muss der Branch gegen den aktuellen `main` reconciliert werden; dabei duerfen die exakte Acceptance-Provenienz und die abgeschlossenen Warehouse-Entscheidungen nicht stillschweigend veraendert werden.
