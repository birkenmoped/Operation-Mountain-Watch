---
document_id: OMW-TEST-AIR-TASKING-AAR-VERTICAL
status: DRAFT
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test scope for the first Air Tasking to AAR vertical integration
  - expected pure-Lua bridge behavior before DCS integration
  - exact local vertical-base and acceptance-bundle build evidence for the documented commit
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

Dieses Testprojekt prueft ausschliesslich die neue Domain-/Korrelationsschicht

```text
MissionDemand
-> approved AIR_SUPPORT_REQUEST
-> AIR_TASKING_MISSION
-> existing OMW AAR Controller
-> existing OMW AAR CampaignState adapter
-> stable EXECUTION_ATTEMPT correlation
```

Die Pure-Lua-Fixture erzeugt keine DCS-Gruppe und ruft keine MOOSE-API auf. MOOSE-/AAR-Laufzeitverhalten bleibt durch die bestehende Acceptance-7-Provenienz begrenzt und muss fuer Gate 3 zusaetzlich in DCS als kompletter Vertical Slice getestet werden.

## 2. Production module under test

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
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

Diese Fixture ist weiterhin nicht als ausgefuehrter Test markiert, weil fuer den dokumentierten Remote-Schritt kein Lua-/luac-Interpreter als belastbare Testumgebung vorlag.

## 4. Lokal bestaetigter Vertical-/Acceptance-Build

Der Projektinhaber hat den Vertical-Base- und Acceptance-Builder lokal auf dem exakten Branch-Stand ausgefuehrt.

```text
Testdatum: 2026-08-18
Branch: agent/air-tasking-plan-foundation
Commit: 3aea46a1cbfa1f62136bd932f0f48e67d332d680
Base Builder: tools/build-air-tasking-aar-vertical-base.ps1
Base BuilderVersion: OMW-AIR-TASKING-AAR-VERTICAL-BASE-1
Acceptance Builder: tools/build-air-tasking-aar-vertical-acceptance.ps1
Acceptance BuilderVersion: OMW-AIR-TASKING-AAR-VERTICAL-ACCEPTANCE-1
Acceptance TestId: AIR-TASKING-AAR-VERTICAL-1
Result: PASS
```

Der vorgeschaltete AAR-Produktionsgate meldete dabei unter anderem:

```text
AAR production finalization source gate: PASS
MizMutation: false
CampaignStateAuthority: true
RestoreReconciliation: true
StandardTracks: 4
ReserveTracks: 2
LISAProfile: FAST
LISAAvailability: RESERVE
LISASourceDomain: AL_UDEID
LISAFIRFix: DAVER
LateApproachMode: FIR_THEN_LATE_APPROACH_THEN_AUFTRAG
MissionDemandClosesStandardTrack: false
MissionDemandClosesReserveAfterLastDemand: true
MaxAircraftPerTrack: 2
```

Reale lokale SHA-256-Evidenz am Commit `3aea46a1cbfa1f62136bd932f0f48e67d332d680`:

```text
MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

CampaignState:
576b622c593dcaf43f0a5c1a0fa0682de24381bd7ace2d8477e3c072d7963c7e

InitialStock:
cf3c85b82b2e9531d277a185f496d6dca77a0c0d0b5c810d59e139740fb6b718

AARStrategicStock:
5221959a21c03f6d40de326d210cd6bf58b0b862b84f1112225ff6b9f561cdf1

CampaignStateInitializer:
6ff1bf960f655a477df84e5887b21715696a34b2b8e9cd74d49feaa62b659c92

BaseAdapter:
80f5ccc25a2112ca42727c4e20edf5e7e630804a664d4cd661f435af80729d63

RuntimeIntegration:
598aa378d95f9dcde9aa982222d40070006c3c892ffa66668576c64ff07aa91b

Controller:
547f0336b954b116e43e8a09ca0f001d893ea81d2394025891be5ff078388438

AARBootstrap:
3441d2b771976702aa71fd2e5fce1d699c8969a71cb8f9749ea343beb27e1f19

AirTaskingBridge:
f582f8646f86dc1ccc0264abdb4dcd4271f225ca2bc6bd4ff8f3705ab1ec782a

AirTaskingBootstrap:
615e3a39157a0059d010218b61474ee1763332da690ce7ab9d01da648ed3da5e

Vertical Base Bundle:
87ba3dcae93c242090502d6176ff6e0308ada7392e6e78578862fadf55c4a17a

Acceptance Harness:
fa6432d20aa17cd3af3aa006f4030f6dbbe6d6c9d585e6fbd81e645de6e32006

Acceptance Bundle:
42bb4846be27ae2cff4d6f2634ebca6ff7d0628de7541071bb38ff2d940e7079
```

`Get-FileHash` bestaetigte sowohl den Vertical-Base-Hash als auch den Acceptance-Bundle-Hash unabhaengig vom Builder-Output. Dieser Nachweis ist ein lokaler deterministischer Build-Nachweis, **kein DCS-Runtime-PASS**.

## 5. DCS Vertical Acceptance

Der naechste reale Testfall verwendet genau einen Reserve-Bedarf:

```text
MD-000001
-> ASR-000001 APPROVED
-> ATM-000001 AAR
-> WEST / FAST / SUPPORT
-> existing Controller.SelectArea(...)
-> LISA / AL_UDEID / DAVER
-> EXE-* runtime correlation
-> natural FIR ingress
-> natural 60-NM late approach
-> natural LISA track arrival
-> EndAAR(COMPLETE)
-> FIR egress
-> external handoff
-> exact-once CampaignState recredit
-> ATM COMPLETED
-> ASR FULFILLED
```

Testquellen:

```text
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
tools/build-air-tasking-aar-vertical-acceptance.ps1
tools/build-air-tasking-aar-vertical-miz.ps1
```

Der Acceptance-Harness wartet zuerst auf vier natuerlich aktive STANDARD-Tracks. Erst danach wird der LISA-Bedarf eingereicht. `EndAAR(COMPLETE)` wird erst nach natuerlicher LISA-On-Station-Bestaetigung angefordert. Es gibt keinen kuenstlichen FuelLow, keinen kuenstlichen Verlust, keinen Teleport und kein Umschreiben der AAR-Route.

Erwartete Schluessel-Logs:

```text
STANDARD_BASELINE_PASS
DEMAND_SUBMITTED
EXECUTION_STARTED_PASS
NATURAL_LISA_ON_STATION_PASS
MISSION_END_REQUESTED_PASS
CORRELATION_PASS
SETTLEMENT_PASS
RESULT PASS
```

## 6. Lokale Missions-Build-Grenze

ChatGPT mutiert keine `.miz`-Datei. Der lokale Missions-Build wird ausschliesslich durch den Projektinhaber mit `tools/build-air-tasking-aar-vertical-miz.ps1` ausgefuehrt.

Der Builder akzeptiert einen **explizit vom Projektinhaber angegebenen** `-InputMiz`-Pfad und erzeugt daraus eine separate Acceptance-Testmission. Es gibt keine automatische Suche nach Missionsdateien, keine Annahme eines lokalen Speicherorts und keine in-place-Aenderung der Quellmission.

Beim ersten lokalen Versuch am 18.08.2026 wurde kein `.miz`-Build ausgefuehrt, weil `OMW_Template_v12_groundworks.miz` nicht im Repository-Verzeichnis lag und kein expliziter lokaler Quellpfad vorlag. Dieser Versuch ist weder PASS noch FAIL fuer den Builder oder den DCS-Test.

Vor dem DCS-Lauf muessen aus dem realen lokalen Builderlauf mindestens vorliegen:

```text
InputMissionSHA256
AcceptanceBundleSHA256
EmbeddedAARBaseSHA256
MooseLuaSHA256
OutputMissionSHA256
```

## 7. Evidence boundary

Der lokale Vertical-Base-/Acceptance-Build fuer Commit `3aea46a1cbfa1f62136bd932f0f48e67d332d680` ist bestaetigt. Der lokale Acceptance-`.miz`-Build und der DCS-Vertical-Acceptance-Lauf sind noch nicht erfolgt.

Gate 3 darf erst nach einem realen DCS-Lauf mit dokumentierter Mission, Missions-Hash, Bundle-Hash, Branch/Commit, DCS-Version, eingebetteter MOOSE-Version/Hash sowie den erforderlichen Logs auf PASS gesetzt werden.
