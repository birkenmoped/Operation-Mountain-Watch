---
document_id: OMW-TEST-AIR-TASKING-AAR-VERTICAL
status: DRAFT
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test scope for Air Tasking to accepted AAR vertical integration
  - additive attachment contract to the already running accepted AAR base
  - current MissionDemand-to-AAR translation build evidence
  - retained historical DCS acceptance evidence for the previous exact source provenance
not_authoritative_for:
  - Acceptance-7 replacement
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS acceptance of the current reconciled source head
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

Der Testpfad ist strikt additiv:

```text
canonical MissionDemand record (read-only)
-> Air Tasking ASR / ATM / EXE domain
-> AAR runtime-demand translation
-> existing OMW_AAR_Base.lua
-> existing OMW.AirOps.AAR facade RUNNING
-> existing Controller.SelectArea / SubmitDemand / EndDemand
-> existing CampaignState strategic adapter
-> existing MOOSE AAR execution
```

Nicht veraendert werden:

```text
OMW_AAR_Base.lua
OMW_AAR_Controller.lua
OMW_AAR_CampaignStateAdapter.lua
OMW_AAR_RuntimeIntegration.lua
OMW_MissionDemand.lua on main
CampaignState resource settlement
mission .miz by ChatGPT
```

## 2. Current-main MissionDemand reconciliation

`main` enthaelt inzwischen den produktiven Campaign-Domain-Vertrag aus `scripts/campaign/OMW_MissionDemand.lua`.

Der kanonische Datensatz verwendet insbesondere:

```text
id
missionType
priority
status
```

und nicht den AAR-spezifischen Runtime-Vertrag:

```text
missionDemandId
receiverProfile
operationsArea
supportMode
priority
```

Die Air-Tasking-Bridge wurde deshalb so angepasst, dass sie den kanonischen MissionDemand read-only konsumiert und daraus zusammen mit AAR-Planungsfeldern ausschliesslich fuer den bestehenden AAR-Controller einen kleinen Runtime-Demand erzeugt:

```text
MissionDemand.id
-> runtimeDemand.missionDemandId

Air Tasking AAR planning fields
-> receiverProfile
-> operationsArea
-> supportMode

MissionDemand.priority
-> runtimeDemand.priority
```

Die Bridge mutiert den MissionDemand-Status nicht und erzeugt keinen zweiten MissionDemand-Store.

## 3. Entfernte Legacy-Grenze

Der fruehere, nicht mehr verwendete `GetAdapterModule()`-Proxy wurde aus der Air-Tasking-Bridge entfernt. Der Bootstrap benoetigt keine `baseAdapterModule`-Abhaengigkeit mehr.

Damit existiert im aktuellen Air-Tasking-Code kein vorgesehener Pfad mehr, der den akzeptierten AAR Strategic Adapter neu erzeugt, proxied oder dessen `OnMaterialized`/`OnHandoff`/`OnLost`-Callbacks dekoriert.

Die Runtime-Beobachtung bleibt ausschliesslich:

```text
Controller.GetStation(...)
+ MOOSE SCHEDULER
+ Air-Tasking-interne Korrelation
```

## 4. Reconciled test artifact

Test-ID:

```text
AIR-TASKING-AAR-VERTICAL-3
```

Builder:

```text
tools/build-air-tasking-aar-additive-test.ps1
```

Ausgabedatei:

```text
mission/tests/air-tasking-aar-vertical/dist/OMW_AirTasking_AAR_Vertical_Test.lua
```

Builder-Sicherheitsgrenzen umfassen:

```text
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
LegacyAdapterProxyPath: false
GetAdapterModule forbidden
baseAdapterModule forbidden
SetStrategicAdapter(...) forbidden
adapter callback mutation forbidden
```

## 5. Reale lokale Build-Evidenz fuer den reconcilierten Stand

Der Projektinhaber hat am 22.08.2026 auf folgendem exakten Source-Stand gebaut:

```text
GitCommit: 93cae7cee601f2af242cfcc963accf499ddea7d8
SourceCommitUtc: 2026-08-22T19:06:02+02:00
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3
TestId: AIR-TASKING-AAR-VERTICAL-3
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
LegacyAdapterProxyPath: false
RuntimeObservation: CONTROLLER_GETSTATION_PLUS_MOOSE_SCHEDULER
ObserverIntervalSec: 5
WaitsForExistingAARFacade: true
MissionEditorAdditionalScriptRequired: true
```

Reale SHA-256-Evidenz:

```text
MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

AirTaskingBridge:
7054d2a88262dba5546e13fe3dd51f01cdbd1a9efcabc41031b063c5336bb66f

AirTaskingBootstrap:
81876fed138533d667aa1f6bcbde2d232cd1bf49a54b83b54464cefb2da5f12a

Harness:
01ab6f5d5bf65c9d64a656d338a39eac67b063afa38ec02f95325c1974f1cb11

Additive Test Bundle:
dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
```

Ein anschliessender unabhaengiger `Get-FileHash` bestaetigte denselben Bundle-Hash. Damit gilt:

```text
BUILD PASS
BUNDLE HASH CROSS-CHECK PASS
LOCAL LUA CONTRACT TEST NOT RUN - no local Lua interpreter available
CURRENT SOURCE HEAD DCS RETEST NOT RUN
```

Der fehlende lokale Lua-Interpreter wird nicht durch angenommene oder simulierte Testevidenz ersetzt.

## 6. Vorherige technische Acceptance bleibt gueltige historische Evidenz

`AIR-TASKING-AAR-VERTICAL-2` wurde am 22.08.2026 erfolgreich in DCS getestet:

```text
Executable source commit:
1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d

Mission:
OMW_Template_v16(6).miz

Mission SHA-256:
5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada

Bundle SHA-256:
30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0

DCS:
2.9.28.26385 MT

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Result:
PASS
```

Der damalige Lauf bestaetigte unter anderem:

```text
EXISTING_AAR_ATTACH_PASS
STANDARD_BASELINE_PASS
LISA reserve materialization
EXE correlation
NATURAL_LISA_ON_STATION_PASS
OFFMAP_HANDOFF
ATM COMPLETED
ASR FULFILLED
AL_UDEID exact-once recredit to 38
runtime_id not persisted
CORRELATION_PASS
SETTLEMENT_PASS
RESULT PASS
```

Diese Acceptance bleibt fuer exakt den damaligen Stand gueltig. Sie wird nicht auf die MissionDemand-reconciled Bridge uebertragen. Sie bleibt jedoch Teil-Evidenz fuer den unveraendert gebliebenen physischen AAR-/LISA-/Handoff-/Settlement-Pfad.

## 7. Projektinhaberentscheidung zum erneuten LISA-Test

Der Projektinhaber hat am 22.08.2026 entschieden, den `AIR-TASKING-AAR-VERTICAL-3`-LISA-DCS-Retest nicht erneut durchzufuehren. Der Test-Harness wurde bereits aus der Arbeitsmission entfernt.

Damit gilt:

```text
historical VERTICAL-2 DCS PASS: retained for exact provenance
reconciled VERTICAL-3 build: PASS
reconciled VERTICAL-3 DCS runtime: NOT RUN
current reconciled source head validated_in_dcs: false
```

Diese Entscheidung ist kein stillschweigender Runtime-PASS fuer den aktuellen Source-Head. Sie entfernt lediglich den erneuten LISA-Lauf als Branch-Reconciliation-Gate.

## 8. Gate 3 current head

```text
GATE 3 HISTORICAL VERTICAL-2: PASS FOR EXACT DOCUMENTED PROVENANCE
GATE 3 CURRENT RECONCILED HEAD: BUILD PASS / NOT REVALIDATED IN DCS
validated_in_dcs: false
```

Fuer die weitere Branch-Reconciliation sind damit noch Repository-/Dokumentationspruefungen erforderlich, aber kein erneuter LISA-Test.
