---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-FAIL-3
status: HISTORICAL_TEST_FIXTURE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical DCS evidence for Stage-1A protected-convoy return-timing failure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Lauf 3 – Historical FAIL

## Ergebnis

```text
Classification: FAIL
TPL_BLUE_CONVOY_LIGHT_06 materialization: PASS
AMMOSUPPLY outbound execution: PASS
Honaker destination-zone proof: PASS
CampaignState DELIVERED: PASS
MissionDemand SUCCESS: PASS
RTZ FSM accepted: PASS
physical return departure: not observed
Returned: not reached
Warehouse AddAsset: not reached
```

## Provenienz

```text
Mission: OMW_Template_v18.miz
Exact post-save MIZ SHA-256: NOT CAPTURED / NOT CLAIMED
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Acceptance build commit: 0c082407c6d35f094037ecdf118f84c29bacf2bc
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-4
Acceptance bundle SHA-256: 3B42E2D3B302B489BBB567B2DC4AD6DEA393C0867ECE73C8107F856A1E016854
```

## Finding

Der Harness löste RTZ nur zwei Sekunden nach `MissionDone` aus, während die AUFTRAG-Abschlussauswertung noch lief. Der Folgelauf übernahm deshalb die bereits in der Ground-Foundation bewährte 30-Sekunden-Settlement-Grenze vor RTZ. Damit wurde der vollständige Return-Lifecycle anschließend erfolgreich bestätigt.

Die spätere Stage-1A-Acceptance ersetzt diesen historischen Fehlversuch als technische Aussage.
