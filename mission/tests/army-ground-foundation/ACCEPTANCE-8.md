---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-8
status: PLANNED
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - ARMY Ground production CampaignState composition gate after Acceptance 7
  - validation of Ground stock, adapter attachment and restart reconciliation in the single CampaignState store
not_authoritative_for:
  - new MOOSE Ground lifecycle behavior
  - final Ground-order or ATO architecture
  - Fortress or Honaker production quantities
  - production activation before documented acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground Foundation – Acceptance 8

## 1. Ziel

Acceptance 8 ist der Produktionsintegrations-Gate nach dem technisch und visuell akzeptierten Acceptance-7-Settlement.

Der Test prüft ausschließlich die strategische Komposition:

```text
single CampaignState store
-> existing AirOps stock
-> existing AAR strategic stock
-> ARMY Ground initial stock
-> GroundRuntimeIntegration.Attach(...)
-> validated GroundCampaignStateAdapter
```

Es wird kein zweiter strategischer Store erzeugt und keine MOOSE-/DCS-Ressourcenhoheit eingeführt.

## 2. Verbindliche Ground-Baseline

Produktionsnahe Root-Nodes:

```text
GROUND_NODE_JALALABAD
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_BOSTICK
```

Initialbestände:

```text
Jalalabad / Fenty: PERSONNEL 480 / VEHICLE 48 / SUPPLY 120 / AMMO 100 / FUEL 120
Joyce:             PERSONNEL 180 / VEHICLE 20 / SUPPLY 48  / AMMO 44  / FUEL 40
Wright:            PERSONNEL 120 / VEHICLE 22 / SUPPLY 36  / AMMO 30  / FUEL 36
Bostick:           PERSONNEL 220 / VEHICLE 26 / SUPPLY 56  / AMMO 52  / FUEL 48
```

Motorized-Patrol-Korrelation:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
4 M-ATV = 4 VEHICLE + 12 PERSONNEL
```

Zusätzlich existieren pro Root-Node genau die für den validierten Settlement-Adapter benötigten Audit-Ressourcen:

```text
GROUND:<nodeId>:VEHICLE_LOST
GROUND:<nodeId>:PERSONNEL_LOST
```

Diese Audit-Zähler erzeugen keine Verfügbarkeit.

## 3. Produktionsmodule

```text
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
```

Die vorhandene CampaignState-Komposition wird erweitert über:

```text
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
```

Der Initializer akzeptiert nun die Ground-Node-IDs zusätzlich zu den bisherigen AirOps-/Off-map-Nodes. Die Ground-Nodes sind logische CampaignState-Knoten; das Legacy-Feld `airbaseName` macht sie nicht zu DCS-Airbases oder MOOSE-Warehouses.

## 4. MOOSE-first-Abgrenzung

Acceptance 8 führt keine neue MOOSE-Klasse, keinen neuen MOOSE-Callback und keinen MOOSE-Override ein.

Der operative Ground-Lifecycle bleibt durch Acceptance 7 belegt:

```text
BRIGADE / PLATOON / WAREHOUSE
-> AUFTRAG / ARMYGROUP
-> RTZ
-> Returned
-> Warehouse AddAsset
-> controlled physical group removal
```

Acceptance 8 prüft nur die strategische CampaignState-Seite dieses bereits akzeptierten Lifecycles. `OMW_GroundRuntimeIntegration.lua` enthält keine MOOSE- oder DCS-Aufrufe.

Damit wird keine vorhandene MOOSE-Funktion parallel neu implementiert.

## 5. Testartefakt

Runtime source:

```text
mission/tests/army-ground-foundation/src/08-army-ground-production-integration.lua
```

Builder:

```text
tools/build-army-ground-acceptance-8.ps1
```

Bundle:

```text
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_8.lua
```

BuilderVersion / Test-ID:

```text
ARMY-GROUND-ACCEPTANCE-8-1
```

## 6. Testumfang

Der Test baut einen einzigen CampaignState-Store aus:

```text
AirOpsInitialStock
+ AARStrategicStock
+ GroundInitialStock
```

Danach wird geprüft:

```text
AirOps-Ressource bleibt unverändert vorhanden
AAR-Ressource bleibt unverändert vorhanden
alle Ground-Ressourcen sind im selben Store vorhanden
GroundRuntimeIntegration akzeptiert den frischen Store
```

Settlement-Prüfung Joyce:

```text
4 M-ATV materialized commitment
-> consume 4 VEHICLE + 12 PERSONNEL
-> confirmed loss 1 VEHICLE + 3 PERSONNEL
-> return 3 VEHICLE + 9 PERSONNEL
-> duplicate return = no second credit
-> final available = VEHICLE 19 / PERSONNEL 177
-> loss audit = VEHICLE_LOST 1 / PERSONNEL_LOST 3
```

Restart-Prüfung Bostick:

```text
open commitment 4 VEHICLE + 12 PERSONNEL
-> snapshot
-> CampaignState.Restore(...)
-> GroundRuntimeIntegration.Attach(restored=true)
-> strategic recredit exactly once
-> second reconciliation produces no second credit
-> no physical DCS/MOOSE continuation or respawn
```

## 7. Erwartete Logmarker

```text
OMW_GND_A8 START
COMPOSITION_OK
SETTLEMENT_OK site=JOYCE
RESTART_OK
RUNTIME_PASS
```

Jeder `FAIL`-Marker verwirft den Lauf.

## 8. Statischer Builder-Gate

Der Builder prüft mindestens:

```text
required source files present
Ground stock schema present
Ground RuntimeIntegration present
all four production Root Ground Nodes present
loss-audit resource IDs present
single-store composition markers present
forbidden Native-DCS/MIST/private-MOOSE spawn patterns absent from new production integration
bundle SHA-256 emitted
Git commit emitted
```

Der Builder ersetzt keinen Laufzeitnachweis.

## 9. Ausgeschlossen

```text
new MOOSE Ground behavior
new private MOOSE override
Fortress production stock
Honaker production stock
Ground-order generation
OPSTRANSPORT
new route geometry
MIZ mutation by ChatGPT
production activation before acceptance
```

## 10. Acceptance-Bedeutung

Ein bestandener Acceptance-8-Lauf bestätigt ausschließlich:

```text
Ground production stock can coexist with AirOps/AAR in one CampaignState store
Ground adapter attaches to that authoritative store
accepted return/loss semantics work against production quantities
restart reconciliation remains exactly-once
```

Die bereits in Acceptance 7 bestätigte physische MOOSE-Rückgabe muss nicht erneut als neue Lifecycle-Funktion erfunden oder parallel implementiert werden.
