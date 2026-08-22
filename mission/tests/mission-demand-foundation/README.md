---
document_id: OMW-TEST-MISSION-DEMAND-FOUNDATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current MissionDemand domain reconciliation status
  - current test and validation boundary for the MissionDemand foundation
not_authoritative_for:
  - DCS runtime acceptance
  - final Ground resupply threshold values
  - ROAD_CONVOY runtime implementation
  - CAS runtime implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MissionDemand Foundation – Reconciliation-Status

## Ziel

Der Branch `agent/mission-demand-reconciliation` übernimmt aus dem alten Branch `agent/mission-demand-resupply-cas-concept` ausschließlich die noch fehlende Campaign-Domain-Foundation und reconciliert sie gegen den aktuellen `main`-Stand.

## Base

```text
main base commit:
96b11739708c298ff00d8d9964c97f8e444b15bf
```

## Enthaltener Scope

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
tests/mission-demand/test_mission_demand.lua
tests/mission-demand/test_resource_demand_policy.lua
tests/mission-demand/run.lua
.github/workflows/mission-demand-validation.yml
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md
docs/DOCUMENT-REGISTRY.md
```

## Bewusst nicht aus dem Legacy-Branch übernommen

```text
Ground ammo rearm implementation
Ground initial-stock implementation
AirOps CampaignState initializer changes
Ground production builder changes
older MissionDemand MOOSE source review
```

Diese Bereiche besitzen auf `main` inzwischen neuere beziehungsweise DCS-validierte Nachfolger.

## Domain-Vertrag

```text
CampaignState = strategic resource authority
MissionDemand = demand identity / assignment state
MOOSE         = later operational execution
```

`OMW_MissionDemand.lua` besitzt keine MOOSE-/DCS-Abhängigkeit.

`OMW_ResourceDemandPolicy.lua` liest ausschließlich vorhandene Policy-Felder und CampaignState-Snapshots. Es verändert weder CampaignState noch MOOSE.

## Aktuelle Ground-Resupply-Grenze

Die produktive Ground-Stock-Baseline auf `main` verwendet:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

und weiterhin:

```text
reorder  = 0
critical = 0
```

Damit erzeugt die Policy aus dem aktuellen produktiven Ground-Bestand noch keinen automatischen RESUPPLY-Bedarf. Schwellenwerte werden nicht erfunden.

## Lua-Contract-Tests

Runner:

```text
tests/mission-demand/run.lua
```

GitHub-Actions-Nachweis:

```text
workflow: MissionDemand validation
run: 32582386144
source head: ec92b8128cf097895983eaebf807a7e160863665
runner: ubuntu-24.04
Lua: 5.4.6
result: PASS
```

Reale Testausgabe:

```text
PASS test_mission_demand
PASS test_resource_demand_policy
PASS mission-demand test suite
```

Der lokale Windows-Entwicklungsrechner besitzt weiterhin keinen separaten Lua-Interpreter. Der Contract-Test wurde daher reproduzierbar im PR-Workflow gegen den dokumentierten Branch-Head ausgeführt. Es handelt sich um Domain-/Unit-Evidenz und nicht um DCS-Runtime-Acceptance.

## Dokumentationsvalidator

Der erste PR-Lauf meldete 19 Fehler. Davon war genau ein Fehler durch diesen Branch verursacht:

```text
docs/DOCUMENT-REGISTRY.md:
numbered document is not registered:
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md
```

Dokument 90 wurde daraufhin im zentralen Dokumentregister ergänzt.

Der Wiederholungslauf gegen Commit

```text
9f77718cd669c524b95dfd15c53ace751b198ddb
```

meldete danach:

```text
documentation validation: 18 error(s), 0 warning(s)
```

Alle 18 verbleibenden Fehler liegen in bereits auf `main` vorhandenen Army-Ground-/Ground-Dokumenten und werden in diesem MissionDemand-Reconciliation-PR nicht fachfremd korrigiert. Für die in diesem Branch neu hinzugefügten beziehungsweise geänderten MissionDemand-Dokumente meldete der Validator keinen verbleibenden Fehler.

## Diff-Prüfung

Der Projektinhaber hat für den zuvor veröffentlichten Reconciliation-Stand real ausgeführt:

```text
git diff --check origin/main...HEAD
```

ohne Ausgabe und damit ohne Whitespace-Fehler. Nach den beiden nachfolgenden Dokumentations-/CI-Commits ist vor einer Mergefreigabe erneut ein finaler `git diff --check` gegen den dann aktuellen Branch-Head erforderlich.

## Aktueller Status

```text
SOURCE RECONCILED AGAINST CURRENT MAIN
MISSIONDEMAND CONTRACT TESTS PASS ON LUA 5.4.6
DOCUMENT 90 REGISTRY ERROR FIXED
DOCUMENTATION VALIDATOR: 18 INHERITED MAIN ERRORS / 0 BRANCH-SPECIFIC ERRORS
DCS TEST NOT REQUIRED FOR THIS DOMAIN-ONLY STEP
```

## Nächste Gates

```text
GATE 1  Lua contract tests                         PASS
GATE 2  Branch-specific documentation validation  PASS
        repository-wide workflow remains red due to 18 inherited main errors
GATE 3  Final complete branch diff review          OPEN
GATE 4  Owner decision: target/reorder/critical    NOT YET REQUESTED
GATE 5  First physical RESUPPLY vertical slice     BLOCKED BY GATE 4
GATE 6  BLUE COMMANDER reconciliation              SEPARATE DEPENDENCY
GATE 7  Hit -> Incident -> CAS_IMMEDIATE            LATER
```

Keine DCS-Runtime-Aussage dieses Dokuments ist `VALIDATED`. Die aktuelle PASS-Aussage gilt ausschließlich für die Lua-Contract-Tests des dokumentierten Branch-Stands.
