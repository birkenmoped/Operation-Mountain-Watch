---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-FAIL-1
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Stage-1C Ground meta-RESUPPLY timeout-contaminated runtime evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
source_branch: agent/automatic-response-orchestration
source_commit: cb32f23886e68371bf45ab4f7a1394200f542c29
validated_in_dcs: true
---

# Ground Meta RESUPPLY Acceptance 1 – Historical FAIL 1

## Klassifikation

```text
HARNESS_FALSE_FAIL_OUTBOUND_TIMEOUT_TOO_SHORT
```

Der DCS-Lauf ist als historische Runtime-Evidenz gültig. Seine ursprüngliche Interpretation als Routing-FAIL wurde durch die spätere Acceptance korrigiert: Der Harness setzte nach 600 Simulationssekunden `state.failed=true`, obwohl die konfigurierte Fahrt physikalisch länger benötigte.

## Provenienz

```text
Branch: agent/automatic-response-orchestration
Source/build commit: cb32f23886e68371bf45ab4f7a1394200f542c29
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-1
Bundle SHA-256: BC9A70327A456FC8718907B9701E83194303B0A5816F0EA0C309310D7118B8FE
Builder SHA-256: 68A58E3F2C0C05D79B0FFC642CEDEB70008748FE81EE56D31BE9437CDB070E37
Acceptance source SHA-256: 7B91D5DD74C874C03CB36FAF6CF9231201D45CB51FD749644EDA857A9FFD137E
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v19.miz
Uploaded MIZ SHA-256: A4D04484584A04C092AAFF31981A477F9179203944B7DAAD4C7CF2D2DD8A63FF
Internal mission SHA-256: B68EDC033D9C8E2FE0F8F93C81A063425F019F1C7A38A30710833AD367BCA90A
dcs.log SHA-256: 23E2D0B31B66464A57D3BC5F45F92A75D4EF913413833311042CD4BC74F1AAA3
debrief.log SHA-256: 2574F8746F6D4A88E6D6F038AFC33DB5600DC4D52CC6A0E946A8E2155B0D8922
```

## Runtime-Grenze

Beobachtet bis zum Harness-Abbruch:

```text
START
DEMAND_RESERVED quantity=18
PHYSICAL_EXECUTION_READY physicalMission=NOTHING
BRIGADE_STARTED
MISSION_QUEUED type=NOTHING formation=OnRoad speedKt=27
ROAD_ALIGNED_WAREHOUSE_SPAWN units=6
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=NOTHING transferStatus=IN_TRANSIT demandStatus=ACTIVE
FAIL reason=OUTBOUND_TIMEOUT seconds=600
```

Die Owner-Beobachtung bestätigte anschließend, dass der Convoy Honaker physisch erreichte. Wegen `state.failed=true` wurden spätere Acceptance-Callbacks absichtlich nicht mehr verarbeitet.

## Root Cause

Die ACCESS-Zentren liegen rund 16,9 km Luftlinie auseinander. Bereits die theoretische Mindestfahrt bei 27 kt liegt deutlich über 600 Sekunden. Der Outbound-Timeout war damit als Harness-Gate ungeeignet.

Der spätere Build 1-4 entfernte harte Travel-Timeouts vollständig und bestätigte den vollständigen Joyce-Honaker-Joyce-Lifecycle über `AUFTRAG:NewNOTHING(...)`.

Maßgebliche supersedierende Acceptance:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
```
