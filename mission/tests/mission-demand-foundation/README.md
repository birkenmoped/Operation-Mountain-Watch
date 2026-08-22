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
source_commit: c8d1cad4ce7469f350b6a3d6e10fee955348620c
validated_in_dcs: false
---

# MissionDemand Foundation – Reconciliation-Status

## Ziel

Der Branch `agent/mission-demand-reconciliation` übernahm aus dem alten Branch `agent/mission-demand-resupply-cas-concept` ausschließlich die noch fehlende Campaign-Domain-Foundation und reconciliierte sie gegen den damaligen `main`-Stand. PR #114 wurde nach finaler lokaler Readback-Prüfung nach `main` gemergt.

## Integration

```text
source branch:
agent/mission-demand-reconciliation

final source head:
c8d1cad4ce7469f350b6a3d6e10fee955348620c

PR:
114

merge commit:
341a65105c24807de3ac289bb18d80339111cbd1
```

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
docs/SUBPROJECT-REGISTRY.md
```

## Bewusst nicht aus dem Legacy-Branch übernommen

```text
Ground ammo rearm implementation
Ground initial-stock implementation
AirOps CampaignState initializer changes
Ground production builder changes
older MissionDemand MOOSE source review
```

Diese Bereiche besitzen auf `main` neuere beziehungsweise DCS-validierte Nachfolger.

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

GitHub-Actions-Nachweis auf dem finalen Merge-Kandidaten:

```text
workflow: MissionDemand validation
run: 32582675460
source head: c8d1cad4ce7469f350b6a3d6e10fee955348620c
result: PASS
```

Zusätzlich wurde der vollständige Testlauf zuvor unter Lua 5.4.6 protokolliert:

```text
PASS test_mission_demand
PASS test_resource_demand_policy
PASS mission-demand test suite
```

Es handelt sich um Domain-/Unit-Evidenz und nicht um DCS-Runtime-Acceptance.

## Dokumentationsvalidator

Der erste PR-Lauf meldete 19 Fehler. Davon war genau ein Fehler durch diesen Branch verursacht:

```text
docs/DOCUMENT-REGISTRY.md:
numbered document is not registered:
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md
```

Dokument 90 wurde daraufhin im zentralen Dokumentregister ergänzt.

Die späteren Wiederholungsläufe meldeten:

```text
documentation validation: 18 error(s), 0 warning(s)
```

Alle 18 verbleibenden Fehler liegen in bereits vor PR #114 auf `main` vorhandenen Army-Ground-/Ground-Dokumenten. Für die in PR #114 neu hinzugefügten beziehungsweise geänderten MissionDemand-Dokumente meldete der Validator keinen verbleibenden branchspezifischen Fehler.

## Finale lokale Readback-Prüfung

Der Projektinhaber hat für den finalen Merge-Kandidaten

```text
c8d1cad4ce7469f350b6a3d6e10fee955348620c
```

real ausgeführt und zurückgemeldet:

```text
git pull --ff-only origin agent/mission-demand-reconciliation
git rev-parse HEAD
git diff --stat origin/main...HEAD
git diff --check origin/main...HEAD
PENDING_MERGE check
SHA-256 readback der zehn Merge-Kandidaten-Dateien
```

Ergebnisse:

```text
HEAD MATCH
PASS git diff --check
PASS no PENDING_MERGE in MissionDemand documents
10 files changed, 1492 insertions(+), 3 deletions(-)
```

Die real zurückgemeldeten SHA-256-Werte des finalen Merge-Kandidaten sind im zugehörigen Projekt-Chat protokolliert. Sie werden hier nicht nachträglich neu berechnet oder simuliert.

## Aktueller Status

```text
SOURCE RECONCILIATION MERGED TO MAIN VIA PR #114
FINAL SOURCE HEAD c8d1cad4ce7469f350b6a3d6e10fee955348620c
MERGE COMMIT 341a65105c24807de3ac289bb18d80339111cbd1
MISSIONDEMAND CONTRACT TESTS PASS
BRANCH-SPECIFIC DOCUMENTATION VALIDATION PASS
FINAL LOCAL DIFF CHECK PASS
DCS TEST NOT REQUIRED FOR THIS DOMAIN-ONLY STEP
```

## Nächste Gates

```text
GATE 1  Lua contract tests                         PASS
GATE 2  Branch-specific documentation validation  PASS
        repository-wide workflow remains red due to 18 inherited main errors
GATE 3  Complete branch diff / local readback      PASS at c8d1cad4ce7469f350b6a3d6e10fee955348620c
GATE 4  Owner decision: target/reorder/critical    OPEN
GATE 5  First physical RESUPPLY vertical slice     BLOCKED BY GATE 4
GATE 6  BLUE COMMANDER reconciliation              SEPARATE DEPENDENCY
GATE 7  Hit -> Incident -> CAS_IMMEDIATE            LATER
```

Keine DCS-Runtime-Aussage dieses Dokuments ist `VALIDATED`. Die PASS-Aussagen gelten ausschließlich für die dokumentierten Lua-Contract-, Source-, Diff- und Readback-Prüfungen.