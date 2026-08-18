---
document_id: OMW-TEST-AIR-TASKING-AAR-VERTICAL
status: DRAFT
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test scope for the first Air Tasking to AAR vertical integration
  - additive attachment contract to the already running accepted AAR base
  - expected DCS acceptance sequence before Gate 3
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

Die bestehende `OMW_AAR_Base.lua`, der AAR-Controller, der CampaignState-Adapter und die bestehende Mission-Editor-Ladekette werden nicht ersetzt, neu gebaut oder in das Air-Tasking-Testbundle eingebettet.

## 2. Production modules under test

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
```

Der Bootstrap verlangt eine bereits laufende `OMW.AirOps.AAR`-Facade. Er erzeugt keinen zweiten AAR-Stack. Die bestehende `StrategicAdapter`-Instanz bleibt identisch; ihre öffentlichen Settlement-Callbacks werden additiv beobachtet und rufen immer zuerst den bestehenden Callback auf.

Die Bridge bleibt auf ASR-/ATM-/EXE-Korrelation begrenzt. Area-/Profile-Auswahl, Tanker-Lifecycle und Ressourcenabrechnung bleiben beim bestehenden AAR-/CampaignState-Pfad.

## 3. DCS Acceptance

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

Diese Lua-Datei wird vom Projektinhaber als **zusätzliche** Mission-Editor-`DO SCRIPT FILE`-Aktion eingefügt. Die bestehende `OMW_AAR_Base.lua` bleibt unverändert.

Der Test wartet selbst auf:

```text
OMW.AirOps.AAR.Status == RUNNING
```

Danach:

```text
existing AAR facade
-> additive Air Tasking attach
-> four STANDARD tracks on station
-> MD-000001
-> ASR-000001 APPROVED
-> ATM-000001 AAR
-> WEST / FAST / SUPPORT
-> LISA / AL_UDEID / DAVER
-> EXE-* correlation
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

Erwartete Schluessellogs:

```text
WAITING_FOR_EXISTING_AAR_BASE
EXISTING_AAR_ATTACH_PASS
STANDARD_BASELINE_PASS
DEMAND_SUBMITTED
EXECUTION_STARTED_PASS
NATURAL_LISA_ON_STATION_PASS
MISSION_END_REQUESTED_PASS
CORRELATION_PASS
SETTLEMENT_PASS
RESULT PASS
```

## 4. Sicherheitsgrenzen des Builders

Der additive Builder prueft unter anderem, dass das Testbundle **keine** bestehende AAR-Production-Base einbettet. Verbotene Marker umfassen die bisherigen kombinierten AAR-Test-/Base-Symbole und die alten nicht-additiven Builderpfade.

```text
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
MissionEditorAdditionalScriptRequired: true
```

Die frueheren kombinierten Builder

```text
tools/build-air-tasking-aar-vertical-base.ps1
tools/build-air-tasking-aar-vertical-acceptance.ps1
```

wurden entfernt, damit sie nicht versehentlich erneut als Integrationsweg verwendet werden.

## 5. Evidence boundary

Es liegt noch kein DCS-Runtime-PASS fuer diesen additiven Pfad vor. Gate 3 bleibt offen.

Ein Gate-3-PASS erfordert mindestens:

```text
branch / commit
built additive Lua hash
Mission SHA-256 nach manueller Einfuegung
DCS version
embedded MOOSE commit / Moose.lua hash
required correlation / settlement logs
RESULT PASS
```
