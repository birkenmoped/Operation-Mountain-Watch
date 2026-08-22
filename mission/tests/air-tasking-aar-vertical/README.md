---
document_id: OMW-TEST-AIR-TASKING-AAR-VERTICAL
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local technical acceptance of the first Air Tasking to AAR vertical integration
  - additive attachment contract to the already running accepted AAR base
  - exact local additive build and DCS runtime evidence for the documented executable commit
not_authoritative_for:
  - Acceptance-7 replacement
  - repository-wide architecture beyond merged BINDING documents on main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/air-tasking-plan-foundation
acceptance_commit: 1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
acceptance_mission: OMW_Template_v16(6).miz
acceptance_mission_sha256: 5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# Air Tasking AAR Vertical Integration Test

## 1. Architekturgrenze

Der Test ist strikt additiv:

```text
existing OMW_AAR_Base.lua
-> existing OMW.AirOps.AAR facade RUNNING
-> additive OMW_AirTasking_AARBootstrap
-> OMW_AirTasking_AARBridge
-> existing Controller.SelectArea / SubmitDemand / EndDemand
-> existing CampaignState strategic adapter
-> existing MOOSE AAR execution
```

Die bestehende `OMW_AAR_Base.lua`, der AAR-Controller, der CampaignState-Adapter und die bestehende Mission-Editor-Ladekette werden nicht ersetzt, neu gebaut, mutiert oder in das Air-Tasking-Testbundle eingebettet.

## 2. Production modules under test

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
```

Der Bootstrap verlangt eine bereits laufende `OMW.AirOps.AAR`-Facade. Er erzeugt keinen zweiten AAR-Stack und mutiert keine Methoden des bestehenden Strategic Adapters.

Da der bestehende AAR-Controller keinen separaten Subscriber-Hook fuer Materialization/Handoff/Loss bereitstellt, beobachtet die Air-Tasking-Schicht ausschliesslich den bereits oeffentlich exponierten Runtime-Zustand ueber `Controller.GetStation(...)`. Die Beobachtung erfolgt mit einem MOOSE `SCHEDULER` im festen 5-Sekunden-Intervall. Der bestehende Controller und Strategic Adapter bleiben fuer physischen Lifecycle und Settlement allein zustaendig.

Die Bridge bleibt auf ASR-/ATM-/EXE-Korrelation begrenzt. Area-/Profile-Auswahl, Tanker-Lifecycle und Ressourcenabrechnung bleiben beim bestehenden AAR-/CampaignState-Pfad.

## 3. Testaufbau

Test-ID:

```text
AIR-TASKING-AAR-VERTICAL-2
```

Testquelle:

```text
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
```

Builder:

```text
tools/build-air-tasking-aar-additive-test.ps1
```

Ausgabedatei:

```text
mission/tests/air-tasking-aar-vertical/dist/OMW_AirTasking_AAR_Vertical_Test.lua
```

Die Lua-Datei wurde vom Projektinhaber als **zusaetzliche** Mission-Editor-`DO SCRIPT FILE`-Aktion hinter der bestehenden `OMW_AAR_Base.lua` eingefuegt. Die bestehende AAR-Base blieb unveraendert.

## 4. Build-Provenienz

Der Projektinhaber hat den additiven Builder auf folgendem exakten ausführbaren Stand lokal ausgefuehrt:

```text
Testdatum: 2026-08-22
Branch: agent/air-tasking-plan-foundation
Executable source commit: 1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-2
TestId: AIR-TASKING-AAR-VERTICAL-2
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
RuntimeObservation: CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER
ObserverIntervalSec: 5
```

Reale lokale SHA-256-Evidenz:

```text
MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

AirTaskingBridge:
f582f8646f86dc1ccc0264abdb4dcd4271f225ca2bc6bd4ff8f3705ab1ec782a

AirTaskingBootstrap:
d2e0d4bd1b75b5fcf60d0186623eb5eed876533c79b9c9a40c6f50176ce3cdf1

Harness:
0bde695d8b4b09e21494e6065d34afada76cac41ca299cc7f372c530d8c32f28

Additive Test Bundle:
30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
```

`Get-FileHash` bestaetigte den Bundle-Hash unabhaengig vom Builder-Output. Die spaeteren Branch-Commits bis `a7a5c8b43adaa32a7312a9e38a68b20b44e44868` aenderten vor dem DCS-Lauf nur Dokumentation; der getestete Bundle-Inhalt blieb der oben dokumentierte Stand von `1e52a9a...`.

## 5. Missions- und Runtime-Provenienz

Read-only geprueftes Acceptance-Artefakt:

```text
Mission artifact: OMW_Template_v16(6).miz
Mission SHA-256: 5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded additive bundle SHA-256: 30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
DCS runtime: 2.9.28.26385 MT
Runtime log: dcs(20260822-164658).log
Debrief log: debrief(20260822-164658).log
```

Der Debrief meldet den lokalen Missionspfad als `OMW_Template_v16.miz`; das fuer die Acceptance bereitgestellte und vor dem Lauf read-only gepruefte Upload-Artefakt ist oben mit seinem SHA-256 dokumentiert.

## 6. DCS Acceptance-Ergebnis

Der zweite Lauf erreichte den vollstaendigen vorgesehenen Vertical-Ablauf:

```text
existing AAR facade RUNNING
-> EXISTING_AAR_ATTACH_PASS
-> four STANDARD tracks on station
-> STANDARD_BASELINE_PASS
-> MD-000001 / ASR-000001 / ATM-000001
-> WEST / FAST / SUPPORT
-> LISA / AL_UDEID / DAVER
-> reserve runtime AAR-0005 materialized
-> EXE-000001 correlated and STARTED
-> natural FIR ingress
-> natural 60-NM late approach
-> NATURAL_LISA_ON_STATION_PASS
-> EndAAR(COMPLETE)
-> reserve egress via DAVER
-> OFFMAP_HANDOFF
-> EXE-000001 ENDED / HANDOFF
-> ATM-000001 COMPLETED
-> ASR-000001 FULFILLED
-> AL_UDEID exact-once recredit to 38
-> runtime_id excluded from persisted snapshot
-> CORRELATION_PASS
-> SETTLEMENT_PASS
-> RESULT PASS
```

Schluessellogs des realen DCS-Laufs:

```text
[OMW][AirTasking.AARBootstrap] RUNNING scope=AIR_TASKING_AAR_ADDITIVE existingAARBase=true adapterRecreated=false adapterMutated=false observerIntervalSec=5
[OMW][TEST][AirTaskingAARVertical] STANDARD_BASELINE_PASS tracks=4 aircraft=4 onStation=true
[OMW][AAR.Controller] MATERIALIZED runtime=AAR-0005 role=ACTIVE demand=MD-000001 area=LISA profile=FAST availability=RESERVE source=AL_UDEID firFix=DAVER
[OMW][TEST][AirTaskingAARVertical] NATURAL_LISA_ON_STATION_PASS runtime=AAR-0005 firIngress=true lateApproach=true
[OMW][AAR.Controller] OFFMAP_HANDOFF runtime=AAR-0005 demand=MD-000001 area=LISA
[OMW][AirTasking.AARBridge] event=EXECUTION_ENDED mission=ATM-000001 request=ASR-000001 demand=MD-000001 execution=EXE-000001 runtime=AAR-0005 result=HANDOFF
[OMW][AirTasking.AARBridge] event=MISSION_TERMINAL mission=ATM-000001 request=ASR-000001 demand=MD-000001 status=COMPLETED
[OMW][TEST][AirTaskingAARVertical] CORRELATION_PASS demand=MD-000001 request=ASR-000001 mission=ATM-000001 execution=EXE-000001 runtimePersisted=false
[OMW][TEST][AirTaskingAARVertical] SETTLEMENT_PASS source=AL_UDEID available=38
[OMW][TEST][AirTaskingAARVertical] RESULT PASS testId=AIR-TASKING-AAR-VERTICAL-2
```

## 7. Gate 3

```text
GATE 3: PASS
validated_in_dcs: true
```

Damit ist der exakt dokumentierte Air-Tasking-to-AAR-Vertical-Stand auf `agent/air-tasking-plan-foundation` eine `ACCEPTED_TECHNICAL_BASELINE` im Sinn von `OMW-GOV-001`. Dies ersetzt weder die bestehende AAR Acceptance-7 noch erzeugt es vor einem Merge nach `main` repository-weite normative Wirkung.
