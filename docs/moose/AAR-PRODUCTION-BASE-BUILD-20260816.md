---
document_id: OMW-AIROPS-AAR-PRODUCTION-BASE-BUILD-20260816
status: HISTORICAL_TEST_FIXTURE
document_class: BUILD_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-run deterministic AAR production-base build and hash evidence for the documented pre-merge commits
  - distinction between source/build verification and DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: d1677afb0e754e0b901c0319714148471f1c6936
validated_in_dcs: false
---

# AAR Production Base – lokaler Buildnachweis 16.08.2026

## 1. Zweck

Dieser Datensatz hält die realen lokalen Build-/Hash-Ausgaben des produktiven AAR-Grundgerüsts fest. Er ist kein neuer DCS-Acceptance-Lauf. Die zugrunde liegende Controller-/Routing-/Fuel-Logik wurde mit Acceptance 7 für dessen dokumentierten Scope in DCS bestätigt. Dieser Buildnachweis belegt, dass daraus ein testfreies und deterministisch reproduzierbares Produktionsbundle erzeugt werden kann.

## 2. Historie der ersten V1-Builds

Der erste lokale Produktionsbuild auf Commit `065212b6b31ab907b2d6cde75c78e8009cf05ebd` meldete:

```text
BuilderVersion: OMW-AIROPS-AAR-BASE-1
GeneratedUtc: 2026-08-16T12:09:25Z
BundleSHA256: 39a1094580db00537f2eba26c7c393d12876bf5ec5c7e7235bca0289909e3c05
```

Nach Synchronisierung auf Commit `882f5c0a5ca3ff97b045d38d55942158487b1021` wurde erneut gebaut:

```text
BuilderVersion: OMW-AIROPS-AAR-BASE-1
GeneratedUtc: 2026-08-16T12:10:28Z
BundleSHA256: 9508cab33be4a941af16bcbcc928c1bf31d7f66220f7c924034c933d88bc3668
```

Der Vergleich beider Hashes war als Reproduzierbarkeitsnachweis ungeeignet, weil Builder V1 `GeneratedUtc` mit der aktuellen Uhrzeit direkt in den Bundle-Header schrieb. Damit war jeder Build desselben Quellstands zwangsläufig byteverschieden. Dies war ein Fehler im Verifikationsverfahren, nicht im AAR-Controller.

## 3. Korrektur: deterministisches Bundle pro Commit

Builder V2 (`OMW-AIROPS-AAR-BASE-2`) entfernt die aktuelle Buildzeit aus dem Bundle und verwendet stattdessen den stabilen Git-Commit-Zeitstempel:

```text
GitCommit
SourceCommitUtc
```

Damit gilt für denselben Commit und identische Quelldateien:

```text
Build 1 bytes == Build 2 bytes
-> SHA-256 identisch
```

## 4. Reale lokale Determinismus-Verifikation

### 4.1 Erster V2-Nachweis

Der Projektbesitzer synchronisierte auf:

```text
GitCommit: 8a8e2422a6770b5185ad815f7ad94df3f3c3e363
BuilderVersion: OMW-AIROPS-AAR-BASE-2
SourceCommitUtc: 2026-08-16T14:11:42+02:00
DeterministicBundleForCommit: true
```

Zwei unmittelbar aufeinanderfolgende Builds ergaben:

```text
FirstBundleSHA256:
3273d24363d5ddaa11bd3d9f91f17778919d4a04d9ca4447ea3d3766ac10e595

SecondBundleSHA256:
3273d24363d5ddaa11bd3d9f91f17778919d4a04d9ca4447ea3d3766ac10e595

DeterministicBundle: PASS
```

### 4.2 Finaler Pre-Merge-Nachweis

Nach Dokumentationsfortschreibung wurde der Branch auf Commit `d1677afb0e754e0b901c0319714148471f1c6936` synchronisiert und der Produktionsbuild erneut zweimal ausgeführt.

```text
GitCommit: d1677afb0e754e0b901c0319714148471f1c6936
BuilderVersion: OMW-AIROPS-AAR-BASE-2
SourceCommitUtc: 2026-08-16T14:13:37+02:00
DeterministicBundleForCommit: true
```

Beide Builds ergaben byte-identisch:

```text
FirstBundleSHA256:
5c3a56e7bf53b214e75de4843963bc6a41b8cd7cbc350aa3ee7353737f84ce08

SecondBundleSHA256:
5c3a56e7bf53b214e75de4843963bc6a41b8cd7cbc350aa3ee7353737f84ce08

DeterministicBundle: PASS
```

Der Source-Gate meldete in beiden Läufen PASS. Damit ist die Production Base für den final geprüften Pre-Merge-Commit deterministisch reproduzierbar.

Der lokale Branchvergleich gegen `origin/main` ergab:

```text
git rev-list --left-right --count origin/main...HEAD
0       6
```

Damit war der geprüfte Branch gegenüber dem zu diesem Zeitpunkt lokal bekannten `origin/main` nicht hinterher und sechs Commits voraus.

## 5. Bestätigter Source-Gate-/Produktionsumfang

Die reale lokale Ausgabe meldete:

```text
AAR production finalization source gate: PASS
MizMutation: false
CampaignStateAuthority: true
StrategicTurnaroundTimer: false
LossRecredit: false
RestoreReconciliation: true
StandardTracks: 4
ReserveTracks: 2
LISAProfile: FAST
LISAAvailability: RESERVE
LISASourceDomain: AL_UDEID
LISAFIRFix: DAVER
MOEProfile: FAST
MOEAvailability: RESERVE
StableSortieCallsign: true
FIRFixRouting: true
LateApproachNm: 60
LateApproachMode: FIR_THEN_LATE_APPROACH_THEN_AUFTRAG
ExternalSpawnHandoffSeparated: true
AirwaysRouting: false
MissionDemandClosesStandardTrack: false
MissionDemandClosesReserveAfterLastDemand: true
GlobalAarMissionLimit: false
GlobalAarAircraftLimit: false
MaxAircraftPerTrack: 2
MooseManagedSpawnSTN: true
SpawnInitialSpeedKt: 480
TransitRouteSpeedKt: 300
ManasIngressFt: 34000
ManasEgressFt: 35000
AlUdeidIngressFt: 35000
AlUdeidEgressFt: 34000
MissionAltitudeMode: EXACT_TRACK_ALTITUDE
InitialFuelManasPct: 91.4067
InitialFuelAlUdeidPct: 79.4558
FuelLowNelsonPct: 24
FuelLowPattyPct: 26
FuelLowLisaPct: 38
FuelLowMoePct: 31
FuelLowMilhousePct: 36
FuelLowKrustyPct: 36
```

Produktionsumfang:

```text
Scope: PRODUCTION_AAR_BASE
ContinuousCoverage: NELSON,PATTY,MILHOUSE,KRUSTY
ReserveDemandOnly: LISA,MOE
StationCycleSec: 10800
ReliefHandoverArmSec: 300
SameSourceMaterializationSpacingSec: 60
RealFuelLowLifecycle: true
RealLossReplacementLifecycle: true
ArtificialFuelLow: false
ArtificialLoss: false
AcceleratedRelief: false
AcceptanceHarness: false
MissionDemandFacade: OMW.AirOps.AAR.SubmitDemand/EndDemand
CampaignStateAuthority: OMW.AirOps.CampaignContext
MizMutation: false
```

## 6. MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 7. Reale Source-SHA-256-Werte des finalen Pre-Merge-Builds

```text
CampaignStateSHA256:
576b622c593dcaf43f0a5c1a0fa0682de24381bd7ace2d8477e3c072d7963c7e

InitialStockSHA256:
cf3c85b82b2e9531d277a185f496d6dca77a0c0d0b5c810d59e139740fb6b718

AARStrategicStockSHA256:
5221959a21c03f6d40de326d210cd6bf58b0b862b84f1112225ff6b9f561cdf1

CampaignStateInitializerSHA256:
6ff1bf960f655a477df84e5887b21715696a34b2b8e9cd74d49feaa62b659c92

AdapterSHA256:
80f5ccc25a2112ca42727c4e20edf5e7e630804a664d4cd661f435af80729d63

RuntimeIntegrationSHA256:
598aa378d95f9dcde9aa982222d40070006c3c892ffa66668576c64ff07aa91b

ControllerSHA256:
547f0336b954b116e43e8a09ca0f001d893ea81d2394025891be5ff078388438

BootstrapSHA256:
3441d2b771976702aa71fd2e5fce1d699c8969a71cb8f9749ea343beb27e1f19

Accepted deterministic production bundle SHA256 for commit d1677afb0e754e0b901c0319714148471f1c6936:
5c3a56e7bf53b214e75de4843963bc6a41b8cd7cbc350aa3ee7353737f84ce08
```

## 8. Acceptance-Grenze

```text
Source/build gate: PASS
Production bundle generated: YES
Deterministic rebuild: PASS
Acceptance harness in production bundle: NO
Artificial FuelLow: NO
Artificial Loss: NO
Accelerated Relief: NO
MIZ mutation: NO
New DCS validation of production wrapper: NOT YET PERFORMED
```

Die Integration des produktiven Bundles in die Basismission erfolgt nach `Moose.lua`. Das Acceptance-7-Bundle wird dort nicht mehr verwendet. Die Mission-Editor-Integration selbst bleibt Eigentümerarbeit; ChatGPT verändert keine `.miz`.
