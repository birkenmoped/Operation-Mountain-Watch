---
document_id: OMW-TEST-AIR-TASKING-AAR-VERTICAL
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Air Tasking to AAR vertical DCS evidence for the exact documented VERTICAL-2 provenance
  - branch-local build and test fixture for the MissionDemand-reconciled Air Tasking AAR bridge
not_authoritative_for:
  - Acceptance-7 replacement
  - DCS validation of the reconciled VERTICAL-3 source
  - permanent Mission Editor load-chain requirements
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-main-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Air Tasking AAR Vertical Integration Test

## 1. Zweck

Dieses Verzeichnis bewahrt den reproduzierbaren Air-Tasking-to-AAR-Vertical-Test. Der Test-Harness ist **keine dauerhafte Missionskomponente**.

Produktionsgrenze:

```text
canonical MissionDemand record (read-only)
-> Air Tasking ASR / ATM / EXE correlation
-> AAR runtime-demand translation
-> existing accepted AAR Controller
-> existing CampaignState strategic adapter
-> existing MOOSE AAR execution
```

Nicht ersetzt oder mutiert werden:

```text
OMW_AAR_Base.lua
OMW_AAR_Controller.lua
OMW_AAR_CampaignStateAdapter.lua
OMW_AAR_RuntimeIntegration.lua
OMW_MissionDemand.lua
CampaignState settlement
```

## 2. Testartefakte

```text
mission/tests/air-tasking-aar-vertical/test_bridge.lua
mission/tests/air-tasking-aar-vertical/src/01-air-tasking-aar-vertical-acceptance.lua
tools/build-air-tasking-aar-additive-test.ps1
.github/workflows/air-tasking-validation.yml
```

Buildausgabe:

```text
mission/tests/air-tasking-aar-vertical/dist/OMW_AirTasking_AAR_Vertical_Test.lua
```

`dist/` ist lokales Buildartefakt und keine Quelle.

## 3. Historische VERTICAL-2 Acceptance

Der reale DCS-Lauf `AIR-TASKING-AAR-VERTICAL-2` erreichte für seinen exakt dokumentierten Stand PASS:

```text
branch: agent/air-tasking-plan-foundation
executable source commit: 1e52a9a685a58d54d0ebc6321d9b1aa81ab4427d
mission artifact: OMW_Template_v16(6).miz
mission SHA-256: 5bc2382cf6ea30a77297b4ff3b36b65488dbcb34429d02c9618f1f449814dada
bundle SHA-256: 30701722eb739fb17b1f827fc681729a6ee781dedd223eab3b03fc72e78ab8a0
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
result: PASS
```

Der Lauf bestätigte unter anderem:

```text
existing AAR facade retained
four STANDARD tracks stable
LISA reserve materialization
ASR / ATM / EXE correlation
natural FIR ingress and track arrival
OFFMAP_HANDOFF
ATM COMPLETED
ASR FULFILLED
AL_UDEID exact-once recredit
runtime_id excluded from persisted Air Tasking snapshot
```

Diese Acceptance bleibt ausschließlich für die damalige Provenienz gültig.

## 4. MissionDemand-reconciled VERTICAL-3 fixture

Der spätere Source-Stand wurde an den produktiven `main`-MissionDemand-Vertrag angepasst:

```text
MissionDemand.id -> runtimeDemand.missionDemandId
MissionDemand.priority -> runtimeDemand.priority
Air Tasking planning -> receiverProfile / operationsArea / supportMode
```

Lokale Build-Provenienz:

```text
executable source commit: 93cae7cee601f2af242cfcc963accf499ddea7d8
BuilderVersion: OMW-AIR-TASKING-AAR-ADDITIVE-TEST-3
TestId: AIR-TASKING-AAR-VERTICAL-3
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
LegacyAdapterProxyPath: false
MizMutation: false
```

Reale lokale Hashes:

```text
AirTaskingBridgeSHA256: 7054d2a88262dba5546e13fe3dd51f01cdbd1a9efcabc41031b063c5336bb66f
AirTaskingBootstrapSHA256: 81876fed138533d667aa1f6bcbde2d232cd1bf49a54b83b54464cefb2da5f12a
HarnessSHA256: 01ab6f5d5bf65c9d64a656d338a39eac67b063afa38ec02f95325c1974f1cb11
BundleSHA256: dc840397ca311802cee99cf98f7448c0371ce40388f324b31dd01de7bf1c82f3
```

Der unabhängige lokale `Get-FileHash` bestätigte denselben Bundle-Hash. Lokal war kein Lua-Interpreter vorhanden; deshalb wurde lokal kein Lua-Contract-PASS behauptet.

## 5. GitHub-Actions Contract-/Build-Nachweis

PR #117 führt zusätzlich `.github/workflows/air-tasking-validation.yml` aus. Der reale Workflow-Lauf auf dem PR-Merge-Ref erreichte PASS:

```text
Lua 5.1 contract test: AIR_TASKING_AAR_BRIDGE_TEST_PASS
PowerShell bundle build: PASS
MissionDemandContract: CANONICAL_MAIN_SHAPE_READ_ONLY
AARRuntimeDemandTranslation: true
MizMutation: false
ExistingAARBaseEmbedded: false
ExistingAARBaseRecreated: false
ExistingAARAdapterRecreated: false
ExistingAARAdapterMutated: false
LegacyAdapterProxyPath: false
```

Der Workflow prüft den erzeugten Bundle-Hash anschließend unabhängig mit `sha256sum`; der Wert stimmte mit dem Builder-Output überein.

Dieser CI-Nachweis ist ein Lua-/Buildvertrag und **kein** DCS-Runtime-PASS.

## 6. Owner decision: kein erneuter LISA-Retest

Der Projektinhaber hat den LISA-Harness aus der Arbeitsmission entfernt und am 22.08.2026 entschieden, den VERTICAL-3-DCS-Lauf nicht erneut als Reconciliation-/Merge-Gate auszuführen.

Daraus folgt:

```text
VERTICAL-2: historical DCS PASS retained for exact provenance
VERTICAL-3 local build/hash: PASS
VERTICAL-3 Lua contract in CI: PASS
VERTICAL-3 DCS runtime: NOT RUN BY OWNER DECISION
current reconciled implementation validated_in_dcs: false
```

Der Test-Harness darf im Repository als reproduzierbares Fixture erhalten bleiben, muss aber nicht in einer normalen OMW-Mission geladen werden.

## 7. Sicherheitsgrenzen des Builders

Der Builder prüft unter anderem:

```text
MissionDemand canonical-shape markers
AAR runtime-demand translation markers
no automated .miz mutation
no embedded accepted AAR base/controller/adapter
no replacement StrategicAdapter
no adapter callback monkey-patching
no GetAdapterModule legacy proxy path
no baseAdapterModule legacy dependency
```

Der Builder beweist keine DCS-Runtime-Funktion; er prüft Buildvertrag und verbotene Integrationspfade.

## 8. Bekannte Testgrenze

Die aktuelle Bridge führt pro AAR `runtimeId` eine einzelne Air-Tasking-Korrelation. Der Vertical-Test verwendet deshalb bewusst einen einzelnen Demand. Mehrere logisch getrennte Demands auf demselben bereits laufenden Tanker sind nicht durch diesen Test abgedeckt.
