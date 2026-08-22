---
document_id: OMW-TEST-MISSION-DEMAND-FOUNDATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current MissionDemand domain reconciliation status
  - current test and validation boundary for the MissionDemand foundation
  - current Ground resupply threshold-gate status
not_authoritative_for:
  - DCS runtime acceptance
  - ROAD_CONVOY runtime implementation
  - CAS runtime implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-resupply-thresholds
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MissionDemand Foundation – Reconciliation-Status

## Ziel

Der Branch `agent/mission-demand-reconciliation` übernahm aus dem alten Branch `agent/mission-demand-resupply-cas-concept` ausschließlich die noch fehlende Campaign-Domain-Foundation und reconciliierte sie gegen den damaligen `main`-Stand. PR #114 wurde nach finaler lokaler Readback-Prüfung nach `main` gemergt.

Der Folgebranch `agent/mission-demand-resupply-thresholds` schließt den danach noch offenen Schwellen-Gate für automatische Ground-RESUPPLY-Bedarfe.

## Integration der Foundation

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

## Threshold-Branch

```text
branch:
agent/mission-demand-resupply-thresholds

base main:
732e76fd4d17eb17242fea3c422a961a57e0a523
```

## Domain-Vertrag

```text
CampaignState = strategic resource authority
MissionDemand = demand identity / assignment state
MOOSE         = later operational execution
```

`OMW_MissionDemand.lua` besitzt keine MOOSE-/DCS-Abhängigkeit.

`OMW_ResourceDemandPolicy.lua` liest ausschließlich vorhandene Policy-Felder und CampaignState-Snapshots. Es verändert weder CampaignState noch MOOSE.

## Freigegebene Ground-Resupply-Schwellen

Projektinhaberentscheidung vom 22. August 2026:

```text
reorder  = 50% of target
critical = 25% of target
```

Geltungsbereich:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

Nicht automatisch über diese Policy disponiert werden:

```text
PERSONNEL
VEHICLE
Loss-Audit resources
```

Die produktive Konfiguration liegt in:

```text
scripts/logistics/OMW_GroundInitialStock.lua
```

und berechnet die Schwellen direkt aus dem jeweiligen `target`. Es wird keine zusätzliche Rundungsregel eingeführt.

## Erwartete aktuelle Schwellenwerte

```text
GROUND_NODE_JALALABAD
SUPPLY  target 120  reorder 60  critical 30
AMMO    target 100  reorder 50  critical 25
FUEL    target 120  reorder 60  critical 30

GROUND_NODE_FORTRESS
SUPPLY  target 44   reorder 22  critical 11
AMMO    target 48   reorder 24  critical 12
FUEL    target 40   reorder 20  critical 10

GROUND_NODE_JOYCE
SUPPLY  target 48   reorder 24  critical 12
AMMO    target 44   reorder 22  critical 11
FUEL    target 40   reorder 20  critical 10

GROUND_NODE_WRIGHT
SUPPLY  target 36   reorder 18  critical 9
AMMO    target 30   reorder 15  critical 7.5
FUEL    target 36   reorder 18  critical 9

GROUND_NODE_HONAKER
SUPPLY  target 40   reorder 20  critical 10
AMMO    target 40   reorder 20  critical 10
FUEL    target 36   reorder 18  critical 9

GROUND_NODE_BOSTICK
SUPPLY  target 56   reorder 28  critical 14
AMMO    target 52   reorder 26  critical 13
FUEL    target 48   reorder 24  critical 12
```

## Lua-Contract-Tests

Runner:

```text
tests/mission-demand/run.lua
```

Der bestehende `test_resource_demand_policy.lua` prüft auf diesem Branch zusätzlich:

```text
InitialStock.ResupplyThresholds.reorderRatio == 0.50
InitialStock.ResupplyThresholds.criticalRatio == 0.25
transferable Ground rows use target * 0.50 / target * 0.25
non-transferable and audit rows remain 0 / 0
```

Der MissionDemand-GitHub-Workflow wurde so erweitert, dass eine Änderung an `OMW_GroundInitialStock.lua` den Contract-Test ebenfalls auslöst.

## Foundation-Nachweis

Der finale Foundation-Merge-Kandidat hatte bereits folgenden GitHub-Actions-Nachweis:

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

Diese Evidenz gilt nur für den genannten Foundation-Stand. Der neue Threshold-Branch benötigt einen eigenen realen Workflow-PASS.

## Dokumentationsvalidator

Die Foundation-Reconciliation hinterließ keinen MissionDemand-spezifischen Validatorfehler. Repositoryweit bestehen weiterhin 18 bereits vorher vorhandene Army-Ground-/Ground-Metadatenfehler. Der Threshold-Branch darf keine neuen branchspezifischen Fehler hinzufügen.

## Aktueller Status

```text
FOUNDATION MERGED TO MAIN VIA PR #114
GROUND RESUPPLY THRESHOLD OWNER DECISION COMPLETE
THRESHOLD IMPLEMENTATION PUBLISHED ON agent/mission-demand-resupply-thresholds
DCS TEST NOT REQUIRED FOR THIS DOMAIN/CONFIGURATION STEP
```

## Nächste Gates

```text
GATE 1  Foundation Lua contract tests              PASS
GATE 2  Foundation branch-specific docs validation PASS
GATE 3  Foundation merge/readback                  PASS
GATE 4  Owner decision: target/reorder/critical    PASS
        target unchanged
        reorder = 50% of target
        critical = 25% of target
GATE 4A Threshold-branch Lua contract tests        OPEN
GATE 4B Threshold-branch documentation review      OPEN
GATE 4C Threshold-branch diff/local readback       OPEN
GATE 5  First physical RESUPPLY vertical slice     OPEN AFTER 4A-4C
GATE 6  BLUE COMMANDER reconciliation              SEPARATE DEPENDENCY
GATE 7  Hit -> Incident -> CAS_IMMEDIATE            LATER
```

Keine DCS-Runtime-Aussage dieses Dokuments ist `VALIDATED`. Die Schwellenentscheidung und ihre Domain-/Konfigurationsprüfung sind vom späteren physischen MOOSE-/DCS-RESUPPLY-Lifecycle getrennt.
