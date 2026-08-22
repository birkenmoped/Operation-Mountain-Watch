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
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md
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

## Tests

Runner:

```text
tests/mission-demand/run.lua
```

Erwartete Ausgabe bei Erfolg:

```text
PASS test_mission_demand
PASS test_resource_demand_policy
PASS mission-demand test suite
```

Aktueller Status:

```text
SOURCE RECONCILED AGAINST CURRENT MAIN
TEST SOURCE COMMITTED
LUA INTERPRETER EXECUTION PENDING
DCS TEST NOT REQUIRED FOR THIS DOMAIN-ONLY STEP
```

## Nächste Gates

```text
GATE 1  Lua contract tests                         OPEN
GATE 2  Documentation validator                    OPEN
GATE 3  Complete branch diff review                OPEN
GATE 4  Owner decision: target/reorder/critical    NOT YET REQUESTED
GATE 5  First physical RESUPPLY vertical slice     BLOCKED BY GATE 4
GATE 6  BLUE COMMANDER reconciliation              SEPARATE DEPENDENCY
GATE 7  Hit -> Incident -> CAS_IMMEDIATE            LATER
```

Keine Runtime-Aussage dieses Dokuments ist `VALIDATED`, solange der entsprechende reproduzierbare Test nicht dokumentiert ist.
