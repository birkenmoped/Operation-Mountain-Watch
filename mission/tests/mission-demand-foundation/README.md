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
source_commit: 59222ad8e673d5e2cd72f4ee7cd5b8e3b7e012bf
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

## Threshold-Branch

```text
branch:
agent/mission-demand-resupply-thresholds

base main:
732e76fd4d17eb17242fea3c422a961a57e0a523

verified source head:
59222ad8e673d5e2cd72f4ee7cd5b8e3b7e012bf

PR:
115
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

GitHub-Actions-Nachweis:

```text
workflow: MissionDemand validation
run: 32583205475
source head: 59222ad8e673d5e2cd72f4ee7cd5b8e3b7e012bf
result: PASS
```

## Dokumentationsvalidator

GitHub-Actions-Nachweis:

```text
workflow: Documentation validation
run: 32583205479
result: 18 error(s), 0 warning(s)
```

Alle 18 Fehler liegen in bereits vor PR #115 auf `main` vorhandenen Army-Ground-/Ground-Dokumenten. Der Threshold-Branch fügte keinen MissionDemand-spezifischen Validatorfehler hinzu.

## Finale lokale Readback-Prüfung

Der Projektinhaber hat für den Source-Head

```text
59222ad8e673d5e2cd72f4ee7cd5b8e3b7e012bf
```

real zurückgemeldet:

```text
HEAD MATCH
PASS git diff --check
5 files changed, 181 insertions(+), 160 deletions(-)
```

Reale SHA-256-Werte:

```text
7F73F489D7E896C815D57FAD54A62B2185932539E44471087C2826729B6FEE66
scripts/logistics/OMW_GroundInitialStock.lua

0C20680E9D2A7AF55857CC04BF1737EB8E3B5FDF2AE86D2532E79CDBEAB9C1BD
tests/mission-demand/test_resource_demand_policy.lua

B5980E05C207AEACECC33ED318C6664BCD5DE4700FF941CB02786D9970DD3C6C
.github/workflows/mission-demand-validation.yml

E5B3242995358DB683B295BB87DF646B24DC3C05D36941BED971132BAB61C873
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md

CF654D7563C399147A551805966321933C7457419699C274D30044864A66A16C
mission/tests/mission-demand-foundation/README.md
```

Die sichtbaren lokalen `??`-Einträge sind untracked Build-/Testartefakte. Es wurden keine tracked modifications gemeldet.

## Aktueller Status

```text
FOUNDATION MERGED TO MAIN VIA PR #114
GROUND RESUPPLY THRESHOLD OWNER DECISION COMPLETE
THRESHOLD IMPLEMENTATION PUBLISHED
THRESHOLD LUA CONTRACT TESTS PASS
THRESHOLD BRANCH-SPECIFIC DOCUMENTATION REVIEW PASS
THRESHOLD SOURCE DIFF / LOCAL READBACK PASS
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
GATE 5  First physical RESUPPLY vertical slice     OPEN
GATE 6  BLUE COMMANDER reconciliation              SEPARATE DEPENDENCY
GATE 7  Hit -> Incident -> CAS_IMMEDIATE            LATER
```

Keine DCS-Runtime-Aussage dieses Dokuments ist `VALIDATED`. Der Schwellen-Gate ist geschlossen; die spätere physische MOOSE-/DCS-Ausführung bleibt ein eigener Entwicklungsschritt.
