---
document_id: OMW-TEST-AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS-tested AirOps Warehouse bootstrap acceptance baseline
  - CampaignState-to-STORAGE initial mirror readback for the documented scope
  - AirOps READY start-gate behavior for the documented acceptance mission
not_authoritative_for:
  - persistence transport
  - reverse STORAGE authority
  - automatic concurrent fuel-consumption reconciliation
  - final production CampaignState NEW/RESTORE ownership
  - recalculation of closed strategic stock decisions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: 2502516fe130b908e500117142399b3e2ca74007
acceptance_branch: agent/air-ops-initial-stock-runtime-data
acceptance_commit: 2502516fe130b908e500117142399b3e2ca74007
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: dd25f68a7361c36fa121a581022a9535f55372ad1f32a7992d4013e9c6f0c0d8
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# AirOps Warehouse Bootstrap Acceptance – 13.08.2026

## Ergebnis

Der DCS-Lauf vom 13.08.2026 erfüllt den Acceptance-Gate für den exakt dokumentierten AirOps-Warehouse-Bootstrap-Stand.

```text
Test-ID: AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1
Result: PASS
READY flag: OMW_WAREHOUSE_READY = 1
```

Diese Acceptance gilt ausschließlich für den unten dokumentierten Branch-, Commit-, Bundle-, MIZ-, DCS- und MOOSE-Stand.

## Bestätigter Scope

Der Lauf bestätigt für den Acceptance-Aufbau:

```text
CampaignState authority                 PASS
Strategic item preflight/apply/readback PASS
Kandahar fuel preflight/apply/readback  PASS
AVGAS supplement                        PASS
0.5 kg liquid readback tolerance        PASS
Technical availability                  PASS
NEW bootstrap                           PASS
RESTORE bootstrap                       PASS
RESTORE idempotence                     PASS
AirOps READY flag                       PASS
AirOps start gate                       PASS
AirOps startup after READY              PASS
```

Der Test verändert keine abgeschlossenen strategischen Bestandsentscheidungen. Der Kandahar-JP-8-Wert wird im Acceptance-Harness einmalig aus dem vor Testbeginn vorhandenen DCS-STORAGE-Wert als Test-Preservation-Fixture übernommen. Diese Fixture ist keine produktive Rückautorität und keine Genehmigung für einen STORAGE-zu-CampaignState-Import.

## Fuel-Readback-Toleranz

Der vorausgehende integrierte Lauf zeigte nach `STORAGE:SetLiquid()` bei Kandahar AVGAS eine DCS-Repräsentationsabweichung:

```text
requested: 20270.13583056 kg
observed:  20270.13671875 kg
delta:         0.00088819 kg
```

Der akzeptierte Stand verwendet deshalb im `OMW_StorageFuelAdapter.lua` für Plan, Write-Entscheidung, Readback-Verifikation und Idempotenz ein einheitliches Fenster von:

```text
ReadbackToleranceKg = 0.5
```

Die strategische CampaignState-Menge wird dadurch nicht gerundet oder geändert. Abweichungen über 0.5 kg bleiben fail-closed.

Im bestandenen Lauf wurde der Kandahar-Fuel-Write als verifiziert protokolliert; der anschließende RESTORE-Plan ergab `fuelChanges=0`.

## AirOps-Startgate

Die Acceptance-MIZ verwendet folgende Reihenfolge:

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

Das Harness setzt `OMW_WAREHOUSE_READY` zu Beginn auf `0` und erst nach erfolgreichem NEW-, Readback- und RESTORE-Pfad auf `1`. Das Debrief des bestandenen Laufs bestätigt den Flag-Wert `1`. Die AirOps-Foundations starteten danach in der vorgesehenen zeitlichen Reihenfolge.

## Positive Runtime-Marker

```text
START mode=NEW_AND_RESTORE campaignStateAuthority=true closedStockRecalculation=false readyFlag=0
JP8_PRESERVATION_FIXTURE observedKg=100000.000 source=DCS_STORAGE testOnly=true strategicRecalculation=false
NEW_PREFLIGHT_PASS strategicChanges=27 fuelChanges=1 technicalChanges=7 blockers=0
NEW_APPLY_PASS status=READY
RESTORE_PASS strategicChanges=0 fuelChanges=0 technicalChanges=0 initialReset=false status=READY
AIR_OPS_START_GATE_PASS flag=OMW_WAREHOUSE_READY value=1
RESULT status=PASS
```

## Exakte Provenienz

```text
OMW branch:
agent/air-ops-initial-stock-runtime-data

OMW acceptance/source commit:
2502516fe130b908e500117142399b3e2ca74007

BuilderVersion / TestId:
AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1

Generated / embedded Warehouse bundle SHA-256:
025855c07896ee396b545ae2b131c2f4181e6eed88c412580288d644f4d311ac

Production bootstrap source SHA-256:
067e06894c82498bdb3d2b13a8edfdd9968ef1600e6636fe85e5c8fc4e6131e

Fuel adapter source SHA-256:
aa512609fc6fbdf4e865ad72777d55513c046446d4abc1331fcd8290644f1e54

Acceptance harness source SHA-256:
22b705895662a3817904a290cf934f578fefd447e7fd1787f42afa79b212c8db

DCS-tested mission source name:
OMW_Template_v8_AirOps_rdy.miz

Uploaded evidence copy:
OMW_Template_v8_AirOps_rdy(20260813-175446).miz

MIZ SHA-256:
dd25f68a7361c36fa121a581022a9535f55372ad1f32a7992d4013e9c6f0c0d8

Embedded mission SHA-256:
b8b739ce82aea204ba72f6f6d9d8cf1fb22ac693fb0ea4f06158a0188fd61296

Warehouses SHA-256:
3831fcfe50c1fb61553dba26356f2840d917cd0cb6009137467100a46483e171

DCS version:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

DCS log evidence copy:
dcs(20260813-175410).log

DCS log SHA-256:
b3192e600c3f3eea280c30c03ab5e6d50ee43b1557cb7e60b8ebb420099cbbdc

Debrief evidence copy:
debrief(20260813-175410).log

Debrief SHA-256:
0dc510f36dec54cb1293623e15f0f3317c8d2685d287d3e42dc1cd7d7d1eb6fa
```

## MOOSE-Methoden im Acceptance-Pfad

Der Acceptance-Pfad verwendet die im gepinnten MOOSE-Artefakt geprüften öffentlichen Methoden:

```text
STORAGE:FindByName()
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:GetLiquidAmount()
STORAGE:SetLiquid()
USERFLAG:New()
USERFLAG:Set()
USERFLAG:Get()
SCHEDULER:New()
```

Für den dokumentierten Stand ist praktisch bestätigt, dass `STORAGE:SetLiquid()` und `STORAGE:GetLiquidAmount()` den CampaignState-Fuel-Mirror innerhalb der dokumentierten 0.5-kg-Toleranz tragen und dass `USERFLAG` das fail-closed AirOps-Startgate abbildet.

## Grenzen der Acceptance

Nicht durch diesen Lauf validiert:

```text
persistence transport to/from disk
automatic concurrent fuel-consumption reconciliation
reverse STORAGE -> CampaignState authority
production ownership of CampaignState NEW/RESTORE lifecycle
rollback after a later bootstrap mutation failure
full productive mission lifecycle beyond the documented foundation startup
```

Der produktive Ressourcenvertrag bleibt:

```text
CampaignState = strategic authority
MOOSE STORAGE / DCS warehouse = operational physical representation
```
