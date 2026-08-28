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
source_branch: main
source_commit: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
validated_in_dcs: false
---

# MissionDemand Foundation – Reconciliation-Status

## Foundation

PR #114 integrierte die MissionDemand-Domain-Foundation nach `main`.

```text
final source head:
c8d1cad4ce7469f350b6a3d6e10fee955348620c

merge commit:
341a65105c24807de3ac289bb18d80339111cbd1
```

## Threshold-Integration

PR #115 integrierte die freigegebenen Ground-RESUPPLY-Schwellen nach `main`.

```text
branch:
agent/mission-demand-resupply-thresholds

base main:
732e76fd4d17eb17242fea3c422a961a57e0a523

final source head:
48e627eb3d61ab8e41d933d709d9f93cdc0a0273

PR:
115

merge commit:
34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
```

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

Die Schwellen werden direkt aus dem jeweiligen `target` berechnet. Es gibt keine zusätzliche Rundungsregel.

## Erwartete Schwellenwerte

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

Der bestehende Test prüft zusätzlich die produktive GroundInitialStock-Konfiguration:

```text
InitialStock.ResupplyThresholds.reorderRatio == 0.50
InitialStock.ResupplyThresholds.criticalRatio == 0.25
transferable Ground rows use target * 0.50 / target * 0.25
non-transferable and audit rows remain 0 / 0
```

Finaler GitHub-Actions-Nachweis für den Merge-Kandidaten:

```text
workflow: MissionDemand validation
run: 32583400735
source head: 48e627eb3d61ab8e41d933d709d9f93cdc0a0273
result: PASS
```

## Dokumentationsvalidator

Finaler GitHub-Actions-Nachweis für den Merge-Kandidaten:

```text
workflow: Documentation validation
run: 32583400737
result: 18 error(s), 0 warning(s)
```

Alle 18 Fehler liegen in bereits vor PR #115 auf `main` vorhandenen Army-Ground-/Ground-Dokumenten. Der Threshold-Branch fügte keinen MissionDemand-spezifischen Validatorfehler hinzu.

## Finale lokale Branch-Readback-Prüfung

Der Projektinhaber hat für den finalen Source-Head

```text
48e627eb3d61ab8e41d933d709d9f93cdc0a0273
```

real zurückgemeldet:

```text
HEAD MATCH
PASS git diff --check
PASS no unresolved merge placeholder
6 files changed, 247 insertions(+), 319 deletions(-)
```

Reale SHA-256-Werte dieses finalen Branch-Stands:

```text
7F73F489D7E896C815D57FAD54A62B2185932539E44471087C2826729B6FEE66
scripts/logistics/OMW_GroundInitialStock.lua

0C20680E9D2A7AF55857CC04BF1737EB8E3B5FDF2AE86D2532E79CDBEAB9C1BD
tests/mission-demand/test_resource_demand_policy.lua

B5980E05C207AEACECC33ED318C6664BCD5DE4700FF941CB02786D9970DD3C6C
.github/workflows/mission-demand-validation.yml

E2AA65B19E796F631900ABD988B91BA67CE07656A916B0702B738FBFB5B8CE37
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md

E174E9B7529035CC4B5CF4A1C001DCE5B044D15B570CA01C5CC6C5239EB70077
docs/SUBPROJECT-REGISTRY.md

DFCEA9D21298F30EE6C93D0FECF58854BAA94A834C09E2381F2131CC5B5CD3CB
mission/tests/mission-demand-foundation/README.md
```

## Post-Merge main-Readback

Der Projektinhaber hat nach dem Merge `main` auf den realen Merge-Commit aktualisiert:

```text
main head:
34b1f46120f951ca2a6308cf1d9fbbb4b0a17863

merge ancestry:
PASS PR #115 source head is in main
```

Die SHA-256-Werte der sechs integrierten Dateien entsprechen dem finalen Branch-Readback. Die sichtbaren lokalen `??`-Einträge sind untracked Build-/Testartefakte; es wurden keine tracked modifications gemeldet.

## Aktueller Status

```text
FOUNDATION MERGED TO MAIN VIA PR #114
GROUND RESUPPLY THRESHOLD OWNER DECISION COMPLETE
THRESHOLD IMPLEMENTATION MERGED TO MAIN VIA PR #115
THRESHOLD LUA CONTRACT TESTS PASS
THRESHOLD BRANCH-SPECIFIC DOCUMENTATION REVIEW PASS
THRESHOLD SOURCE DIFF / LOCAL READBACK PASS
THRESHOLD POST-MERGE MAIN READBACK PASS
DCS TEST NOT REQUIRED FOR THIS DOMAIN/CONFIGURATION STEP
```

## Gates

```text
GATE 1  Foundation Lua contract tests              PASS
GATE 2  Foundation branch-specific docs validation PASS
GATE 3  Foundation merge/readback                  PASS
GATE 4  Owner decision: target/reorder/critical    PASS
        target unchanged
        reorder = 50% of target
        critical = 25% of target
GATE 4A Threshold-branch Lua contract tests        PASS
GATE 4B Threshold-branch documentation review      PASS
GATE 4C Threshold-branch diff/local readback       PASS
GATE 4D Threshold merge/post-merge main readback   PASS
GATE 5  First physical RESUPPLY vertical slice     OPEN
GATE 6  BLUE COMMANDER reconciliation              SEPARATE DEPENDENCY
GATE 7  Hit -> Incident -> CAS_IMMEDIATE            LATER
```

Keine DCS-Runtime-Aussage dieses Dokuments ist `VALIDATED`. Der Schwellen-Gate ist geschlossen; die spätere physische MOOSE-/DCS-Ausführung bleibt ein eigener Entwicklungsschritt.
