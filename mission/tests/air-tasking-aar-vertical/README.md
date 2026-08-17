---
document_id: OMW-TEST-AIR-TASKING-AAR-VERTICAL
status: DRAFT
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test scope for the first Air Tasking to AAR vertical integration
  - expected pure-Lua bridge behavior before DCS integration
not_authoritative_for:
  - DCS runtime acceptance
  - Acceptance-7 replacement
  - repository-wide architecture beyond merged BINDING documents on main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking AAR Vertical Integration Test

## 1. Scope

Dieses Testprojekt prüft ausschließlich die neue Domain-/Korrelationsschicht

```text
MissionDemand
-> approved AIR_SUPPORT_REQUEST
-> AIR_TASKING_MISSION
-> existing OMW AAR Controller
-> existing OMW AAR CampaignState adapter
-> stable EXECUTION_ATTEMPT correlation
```

Die Fixture erzeugt keine DCS-Gruppe und ruft keine MOOSE-API auf. MOOSE-/AAR-Laufzeitverhalten bleibt durch die bestehende Acceptance-7-Provenienz begrenzt und muss für Gate 3 zusätzlich in DCS als kompletter Vertical Slice getestet werden.

## 2. Production module under test

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
```

Die Bridge:

```text
- requires externally supplied stable ASR-/ATM-/EXE-IDs;
- requires requestStatus=APPROVED instead of auto-approving authority decisions;
- calls the existing Controller.SelectArea(...) policy;
- calls the existing Controller.SubmitDemand(...) / EndDemand(...) path;
- decorates the existing AAR CampaignState adapter instead of replacing it;
- creates no tanker inventory and performs no resource settlement itself;
- maps AAR runtime materialization/handoff/loss to EXE correlation;
- never persists the AAR runtimeId or any MOOSE/DCS object.
```

## 3. Pure-Lua fixture

```text
mission/tests/air-tasking-aar-vertical/test_bridge.lua
```

The fixture uses fake controller/adapter boundaries only and covers:

```text
1. approved WEST/FAST AAR request
2. reserve track queued
3. materialization -> EXE STARTED -> ATM/ASR EXECUTING
4. explicit COMPLETE -> controller EndDemand(COMPLETE)
5. handoff -> EXE ENDED -> ATM COMPLETED -> ASR FULFILLED
6. exported snapshot omits runtime_id
7. tanker loss -> EXE FAILED
8. accepted AAR replacement lifecycle -> new EXE PENDING
9. replacement materialization reuses the pending EXE
10. cancellation during execution -> controller ABORTED -> final ATM/ASR ABORTED after handoff
```

Expected terminal output when executed with a compatible Lua interpreter:

```text
AIR_TASKING_AAR_BRIDGE_TEST_PASS
```

## 4. Evidence boundary

At creation time this fixture has **not** been executed in DCS and is not a Gate-3 acceptance result.

The repository execution environment used for this remote change does not provide a Lua/luac interpreter, therefore no fabricated syntax/test PASS is recorded here. A later available test environment must execute the fixture or an equivalent checked-in static/unit test before Gate 3 can pass.

## 5. Required DCS vertical test

Gate 3 still requires a reproducible real DCS run with at least one RESERVE demand, preferably LISA or MOE:

```text
MD-...
-> approved ASR-...
-> ATM-...
-> Controller.SubmitDemand(...)
-> CampaignState materialization transaction
-> EXE-... / AAR runtime correlation
-> natural MOOSE SPAWN / FLIGHTGROUP / AUFTRAG lifecycle
-> real track operation
-> explicit mission outcome
-> Controller.EndDemand(...)
-> FIR egress / external handoff
-> exact-once CampaignState settlement
-> ATM / ASR terminal state
```

Required log evidence must contain the stable `MD-`, `ASR-`, `ATM-`, `EXE-` correlation together with the existing AAR runtime ID without treating the runtime ID as persistent domain identity.
