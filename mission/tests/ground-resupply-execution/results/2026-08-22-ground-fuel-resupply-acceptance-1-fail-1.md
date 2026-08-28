---
document_id: OMW-RESULT-GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-FAIL-1
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Stage-1B Ground FUELSUPPLY runtime attempt and harness-timeout evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-FUEL-REFUELLING-ZONE-ACCEPTANCE-2
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground FUEL RESUPPLY Acceptance 1 – Historical FAIL

## Ergebnis

```text
TestId: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1
Result: FAIL
Historical classification: HARNESS_TIMEOUT_CONTAMINATED / INCONCLUSIVE
```

Der physische Fuel-Convoy wurde materialisiert und MOOSE meldete `ARMY_ON_MISSION`, aber der Harness beendete den Lauf nach einem harten Outbound-Timeout, bevor ein belastbarer vollständiger FUELSUPPLY-Lifecycle nachgewiesen werden konnte.

## Provenienz

```text
Build Git HEAD: 4f651829e975f42d4aba44a9bd0813969a2f2d8b
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Acceptance source SHA-256: 38FF22AE66FB5B85BFDD4096AAF4AE05D4B0E53436AD5DB4DBC882FA2D93AA1A
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v19.miz
```

## Runtime-Grenze

Beobachtet:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY transferStatus=IN_TRANSIT demandStatus=ACTIVE
FAIL reason=OUTBOUND_TIMEOUT seconds=1800
```

Nicht belastbar geprüft wurden Delivery, MissionDone, ReturnToLegion/RTZ, Returned und Warehouse AddAsset.

Die damalige Schlussfolgerung, FUELSUPPLY sei als OMW-Executor ungeeignet, ist durch Stage 1B2 superseded. Der spätere One-Shot-Pfad `AUFTRAG:NewFUELSUPPLY(...) -> BRIGADE:AddMission(...)` wurde vollständig in DCS bestätigt und technisch akzeptiert.
