---
document_id: OMW-AIROPS-AAR-PRODUCTION-BASE-BUILD-20260816
status: ACCEPTED_TECHNICAL_EVIDENCE
document_class: BUILD_EVIDENCE
owning_policy: OMW-GOV-001
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 065212b6b31ab907b2d6cde75c78e8009cf05ebd
validated_in_dcs: false
---

# AAR Production Base – lokaler Buildnachweis 16.08.2026

## 1. Zweck

Dieser Datensatz hält ausschließlich die reale lokale Build-/Hash-Ausgabe des produktiven AAR-Grundgerüsts fest. Er ist kein neuer DCS-Acceptance-Lauf. Die zugrunde liegende Controller-/Routing-/Fuel-Logik wurde mit Acceptance 7 für dessen dokumentierten Scope in DCS bestätigt; dieser Build weist nach, dass daraus ein testfreies Produktionsbundle erzeugt werden kann.

## 2. Git-/Build-Provenienz

```text
Branch: agent/aar-fuel-telemetry-calibration
Git commit: 065212b6b31ab907b2d6cde75c78e8009cf05ebd
Builder: tools/build-aar-production-base.ps1
BuilderVersion: OMW-AIROPS-AAR-BASE-1
GeneratedUtc: 2026-08-16T12:09:25Z
Output: mission/runtime/air-operations/OMW_AAR_Base.lua
MizMutation: false
```

## 3. Source Gate

Die reale Build-Ausgabe meldete:

```text
AAR production finalization source gate: PASS
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

## 4. Produktionsumfang

Der Builder meldete für das erzeugte Bundle:

```text
Scope: PRODUCTION_AAR_BASE
StandardTracks: 4
ReserveTracks: 2
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
```

Damit ist der beabsichtigte Produktionsvertrag im Builder nachgewiesen: vier kontinuierliche STANDARD-Tracks, zwei MissionDemand-gesteuerte RESERVE-Tracks, normaler 3-h-Zyklus, reale FuelLow- und Loss-Replacement-Pfade sowie keine Acceptance-spezifischen künstlichen Trigger.

## 5. MOOSE-Provenienz

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 6. Reale SHA-256-Werte

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

BundleSHA256:
39a1094580db00537f2eba26c7c393d12876bf5ec5c7e7235bca0289909e3c05
```

## 7. Acceptance-Grenze

```text
Source/build gate: PASS
Production bundle generated: YES
Acceptance harness in production bundle: NO
Artificial FuelLow: NO
Artificial Loss: NO
Accelerated Relief: NO
MIZ mutation: NO
New DCS validation of production wrapper: NOT YET PERFORMED
```

Die Integration des produktiven Bundles in die Basismission erfolgt nach `Moose.lua`. Das Acceptance-7-Bundle wird dort nicht mehr verwendet. Die Mission-Editor-Integration selbst bleibt Eigentümerarbeit; ChatGPT verändert keine `.miz`.