---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-1-PREFLIGHT-2026-08-18
status: PLANNED
document_class: TEST_RESULT_PRECHECK
owning_policy: OMW-GOV-001
authoritative_for:
  - real local source/build/hash provenance before ARMY Ground Acceptance 1 DCS execution
  - read-only object-contract provenance for the supplied v13 test mission
not_authoritative_for:
  - DCS runtime acceptance
  - ground pathfinding behavior
  - MissionDone persistence behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Acceptance 1 – Preflight 2026-08-18

## Status

```text
PREFLIGHT SOURCE/BUILD PASS
DCS RUNTIME NOT RUN
```

## Remote/local source identity

Vom Projektinhaber real lokal ausgeführt und zurückgemeldet:

```text
branch: agent/army-ground-foundation-reconciliation
Git HEAD: 72d8cc5bf1fee15a053618bdec1cd9de67106ef7
expected remote HEAD: 72d8cc5bf1fee15a053618bdec1cd9de67106ef7
result: exact match
```

## Builder result

```text
Builder: tools/build-army-ground-acceptance-1.ps1
BuilderVersion: ARMY-GROUND-ACCEPTANCE-1-1
TestId: ARMY-GROUND-ACCEPTANCE-1-1
Bundle: mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_1.lua
GeneratedUtc: 2026-08-18T18:53:36Z
```

Der reale Builder-Lauf meldete:

```text
GroundNode: GROUND_NODE_JOYCE
Warehouse: WH_BLUE_GND_JOYCE
Brigade: BDE_BLUE_GND_JOYCE
Platoon: PLT_BLUE_GND_JOYCE_PATROL
Template: TPL_BLUE_GND_PATROL_MATV_4
AccessZone: ZON_BLUE_GND_JOYCE_ACCESS
PatrolZone: ZON_BLUE_GND_JOYCE_PATROL_TEST_01
MissionType: PATROLZONE
ReturnToLegion: false
CampaignStateAuthority: PRESERVED_TEST_BOOKKEEPING_ONLY
MizMutation: false
```

## Bundle hash

Builder-Ausgabe und unabhängiger lokaler `Get-FileHash` stimmen exakt überein:

```text
SHA-256: e49c02e5a6dcc31304d81be00e0a1fa2ec2c3f15bd1d9a3094afd274d53f3279
```

Damit ist die Source -> Builder -> Bundle-Identität für diesen Teststand reproduzierbar bestätigt.

## MOOSE provenance

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der Builder meldete exakt diese gepinnte Provenienz.

## Owner test mission – read-only pre-embed state

Bereitgestelltes Artefakt:

```text
OMW_Template_v13_ground_test.miz
MIZ SHA-256: 6d12a55affc971de1de4d5e463c956fcb2e08a0d2de478ff13419747a825e7e8
internal mission SHA-256: 22d13cb7b0da0a6fb9ddc02bf9b99c4da50d2c96b31bdc6a353616a4188c6b80
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Read-only object-contract smoke confirms:

```text
WH_BLUE_GND_JOYCE
  STATIC / HESCO_generator

TPL_BLUE_GND_PATROL_MATV_4
  lateActivation=true
  4 x CHAP_MATV

ZON_BLUE_GND_JOYCE_ACCESS
  present
  radius=152.4 m

ZON_BLUE_GND_JOYCE_PATROL_TEST_01
  present
  radius=182.88 m
```

Diese Hashkette ist nur für die **pre-embed** Mission gültig. Jedes Speichern oder Einbetten des Testbundles erzeugt ein neues MIZ-Artefakt und verlangt neue Hashes.

## Remaining gate before DCS

```text
1. embed OMW_Army_Ground_Acceptance_1.lua in the owner mission after Moose.lua
2. save as a new test artifact
3. record final MIZ SHA-256
4. record embedded bundle SHA-256
5. record embedded Moose.lua SHA-256
6. run Acceptance 1 in DCS
7. return dcs.log/debrief and visual observations
```

Kein `VALIDATED`-Status ist aus diesem Preflight abzuleiten.
