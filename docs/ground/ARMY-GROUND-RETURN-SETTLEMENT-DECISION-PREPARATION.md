---
document_id: OMW-PLAN-ARMY-GROUND-RETURN-SETTLEMENT
status: PLANNED
document_class: DECISION_PREPARATION
owning_policy: OMW-GOV-001
authoritative_for:
  - recorded owner decisions and mandatory gates for the ARMY Ground CampaignState settlement adapter
not_authoritative_for:
  - exact historical property-book inventories
  - Ground-order generation
  - production activation outside cited source and acceptance documents
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
supersedes:
  - four-node-only production-stock description in the earlier settlement preparation
  - Fortress no-root-pool and Honaker child-only stock clauses
superseded_by:
---

# ARMY Ground – CampaignState-Settlement: festgelegte Regeln und Produktionsgate

## 1. Geltungsbereich

Acceptance 4-2 und Acceptance 6 bestätigten den operativen MOOSE-Return-Lifecycle. Acceptance 7 validierte anschließend den Ground-CampaignState-Settlement-Adapter gegen den realen MOOSE-Ground-Lifecycle. Acceptance 8 und Acceptance 9-2 bestätigten die produktionsnahe Single-CampaignState-Integration bis zum vollständigen sechs-Node-Ground-Stock.

Die strategische Buchung bleibt strikt von der MOOSE-/DCS-Lifecycle-Führung getrennt.

## 2. Festgelegte Eigentümerentscheidungen

| Thema | Festgelegte Regel |
|---|---|
| Strategische Einheit | Jede korrelierte physische Unit zählt einzeln. Eine DCS-Gruppe ist keine strategische Einheit. |
| Materialisierung | Vor der MOOSE-Materialisierung reserviert/konsumiert der Adapter die Ressourcen der tatsächlich materialisierten, vertraglich korrelierten Gruppe. |
| Bestätigte Rückkehr | Nur der bestätigte Return-/Handoff-Pfad darf die tatsächlich zurückgekehrten Einheiten genau einmal strategisch gutschreiben. |
| Teilverlust | Nicht zurückgekehrte, als Verlust bestätigte Einheiten bleiben permanente Verluste. |
| Beschädigter Rückkehrer | Ein bestätigter beschädigter Rückkehrer wird wie ein intakter Rückkehrer sofort wieder verfügbar. |
| Wartung | Kein Maintenance-Mode, keine Reparaturwartezeit, keine Werkstattbuchhaltung. |
| Genau-einmal | Rückgabe, Verlustaudit und Restart-Reconciliation sind pro Runtime-Commitment idempotent. |
| Servercrash / erzwungener Stopp | Jeder nichtterminal offene Commitment wird beim nächsten Start strategisch genau einmal zurückgebucht. Die physische DCS-/MOOSE-Gruppe wird nicht fortgesetzt oder nachgespawnt. |

## 3. Verbindliche Zustandswirkung

```text
confirmed return
-> returned correlated resources credited once

confirmed loss
-> permanent loss; no availability credit

damaged return
-> credited once; immediately available

open at interruption
-> consumed resources recredited once at next startup

previous physical DCS/MOOSE group
-> never resumed or respawned by this rule
```

## 4. MOOSE-First-Abgrenzung

MOOSE bleibt verantwortlich für Materialisierung, AUFTRAG-/ARMYGROUP-Lifecycle, Routing, Return und Warehouse-Handoff.

CampaignState bleibt allein verantwortlich für strategische Verfügbarkeit, Commitments und deren einmalige Abrechnung. `OMW_GroundCampaignStateAdapter.lua` ist die kleine projektspezifische Korrelation/Settlement-Brücke; er ersetzt keine MOOSE-Funktion und erzeugt keine zweite Warehouse-Ressourcenhoheit.

Acceptance 7 bestätigte diese Grenze für den gepinnten MOOSE-Stand. Die bereits genehmigte road-aligned Warehouse-Materialisierungs-Ausnahme aus Acceptance 3-2 blieb unverändert.

## 5. Aktueller sechs-Node-Produktionsbestand

Order: `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_FORTRESS  160 / 18 / 44  / 48  / 40
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_HONAKER   120 / 18 / 40  / 40  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

Resource-ID-Schema:

```text
GROUND:<groundNodeId>:<resourceClass>
```

Support parents:

```text
FORTRESS -> JALALABAD
JOYCE    -> JALALABAD
WRIGHT   -> JALALABAD
HONAKER  -> JOYCE
BOSTICK  -> JALALABAD
```

Fortress und Honaker besitzen eigene strategische Root-Stock-Nodes. Das ältere Modell `Fortress ohne Root-Pool / Honaker nur als Joyce-Child-Bindung` ist superseded.

## 6. Unit-zu-Ressourcen-Korrelation

Für den validierten motorisierten Patrol-Vertrag gilt:

```text
1 physical M-ATV = 1 VEHICLE + 3 PERSONNEL
4 M-ATV          = 4 VEHICLE + 12 PERSONNEL
```

Diese Korrelation ist ein expliziter Adaptervertrag und keine aus DCS-Gruppengröße abgeleitete pauschale Regel für sämtliche Fahrzeugtypen.

## 7. Acceptance 7 – Settlement-Gate

Validierter physischer MOOSE-Ground-Lifecycle und Settlement-Vertrag:

```text
Source commit: e049e34fe8e6de878fd390486888f3912bb179d8
Bundle SHA-256: b591ccd746896c90064fa93d9b3d42626384f55e605efc748bf304ffccb86ec7
MIZ: OMW_Template_v14_ground_test.miz
MIZ SHA-256: 88184ec180837044ff4dcef7cca264fe7ee5fcf5d55a8af19b11125c41eab94d
DCS: 2.9.28.26385 MT
Result: PASS / owner visual acceptance
```

Evidence:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-7-runtime.md
```

## 8. Acceptance 8 / 9 – Produktionsintegration

Acceptance 8 validierte die produktionsnahe Single-CampaignState-Komposition für AirOps + AAR + die damaligen vier Ground-Nodes.

Acceptance 9-2 erweiterte und validierte denselben Pfad auf den vollständigen sechs-Node-Ground-Stock einschließlich Fortress und Honaker.

```text
Acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
Test-ID: ARMY-GROUND-ACCEPTANCE-9-2
Bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ: OMW_Template_v14_ground_test.miz
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

## 9. Produktionsquellen

```text
scripts/logistics/OMW_GroundInitialStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
```

Invariants:

```text
CampaignState = sole strategic resource authority
MOOSE = operational Ground lifecycle
GroundCampaignStateAdapter = correlation/settlement bridge
no parallel strategic inventory in MOOSE Warehouse
no physical restart continuation or respawn
```

## 10. Ausgeschlossen / späterer Scope

```text
DCS group continuation across restart
automatic group respawn at former map position
maintenance timers or workshop queues
parallel strategic inventories in DCS or MOOSE WAREHOUSE
Ground-order generation / ATO-equivalent Ground tasking structure
OPSTRANSPORT
general cross-domain persistence architecture
```
