---
document_id: OMW-MOOSE-AWACS-FUEL-DRIVEN-AAR
status: DRAFT
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS fuel-state driven AAR design
  - AWACS production-bundle design on main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: 837ce24aee76c85efa008cd404afc3e4e5aed383
supersedes:
superseded_by:
validated_in_dcs: true
---

# AWACS Fuel-Driven AAR Lifecycle

## 1. Geltungsbereich

Dieses Dokument beschreibt den funktional in DCS bestätigten WIZARD-Lifecycle sowie dessen Produktivisierung als `OMW_AWACS_Base.lua`.

Architekturgrenzen:

```text
CampaignState = strategische Ressourcenautorität
DCS groups = temporäre physische Repräsentationen
MOOSE = primäres Framework
kein MIST
kein Native-DCS-Refuel-Ersatz
kein Live-Retask mit ClearWaypoints
```

Gepinnter Framework-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Validierter WIZARD-Lifecycle

Der erfolgreiche Abschlusslauf vom 24.08.2026 bestätigt funktional:

```text
OFFMAP_AL_DHAFRA
-> visible materialization
-> ROSIE ingress
-> FL350 / 270 KIAS transit
-> APOC FL320 / 250 KIAS persistent racetrack
-> scheduled sensor/service activation
-> first planned AAR with LISA
-> Refueled
-> APOC physical rejoin / sensor restore
-> second planned AAR with MOE
-> Refueled
-> APOC physical rejoin / sensor restore
-> service-end egress
-> ROSIE outbound
-> external handoff
-> despawn / strategic recredit
```

Getesteter Source-Stand:

```text
branch: agent/awacs-external-lifecycle-foundation
commit: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
controller: OMW_AWACS_Controller_FullLifecycle_V3.lua
MOE extension: OMW_AWACS_MOE_Relief.lua
DCS: 2.9.28.26385 MT
mission file reported by DCS/debrief: OMW_Template_v20.miz
```

Die exakten MIZ- und internal-`mission`-SHA-256-Werte dieses vollständigen LISA-/MOE-Laufs wurden nicht nachträglich gebunden. Deshalb bleibt dieses Dokument `DRAFT` und wird nicht zu `ACCEPTED_TECHNICAL_BASELINE` erhoben.

## 3. Flight- und Performance-Baseline

Acceptance 5 hat 15 E-3A-Profile mit 20 NM Stabilisierung und 200 NM Messstrecke geflogen. Ergebnis:

```text
15/15 complete
14 STABLE
FL350 / 310 KIAS MARGINAL
```

Produktionswerte:

```text
WIZARD normal transit: FL350 / 270 KIAS
WIZARD optional fast:  FL350 / 290 KIAS
APOC racetrack:        FL320 / 250 KIAS / 017T / 30 NM
LISA AAR track:        FL250 / 270 KIAS / 340T / 20 NM
MOE AAR track:         FL250 / 270 KIAS / 340T / 20 NM
WIZARD LISA RV target: FL250 / 290 KIAS
```

Gemeinsamer dedizierter AWACS-AAR-Anker:

```text
33.6233926368 N
68.6395554105 E
```

## 4. AAR-Zyklen

### Erster geplanter Zyklus – LISA

```text
65 % WIZARD fuel
-> LISA pre-dispatch
-> LISA on dedicated AWACS track
-> LISA_READY
-> Controller.RequestRefuel()
-> FLIGHTGROUP:Refuel()
-> Refueled
-> APOC rejoin
```

LISA:

```text
Template: OMW_AAR_KC135_LISA
Source: AL_UDEID
FIR: DAVER
FuelLow: 38 %
Track: FL250 / 270 KIAS / 340T / 20 NM
```

### Zweiter geplanter Zyklus – MOE

```text
first AAR complete
-> arm MOE second cycle
-> next 65 % crossing
-> MOE materialize
-> same dedicated AWACS track
-> MOE_READY
-> Controller.RequestRefuel()
-> FLIGHTGROUP:Refuel()
-> Refueled
-> MOE egress
-> APOC rejoin
```

MOE:

```text
Template: OMW_AAR_KC135_MOE
Source: MANAS
FIR: PINAX
FuelLow: 31 %
Track: FL250 / 270 KIAS / 340T / 20 NM
```

Der Abschlusslauf bestätigt `AAR_REFUELED` mit `OMW_AAR_KC135_MOE#001`, `SECOND_CYCLE_COMPLETE` und den anschließenden APOC-Rejoin.

## 5. Fuel-Policy

```text
65 % -> planned dedicated tanker pre-dispatch
40 % -> fallback AAR trigger
25 % -> visible off-map contingency floor
```

Die 40-%-Schwelle ist keine normale geplante AAR-Startschwelle. Die 25-%-Schwelle bleibt eine OMW-DCS-Contingency-Grenze und ist keine reale E-3A-Landing-Fuel-Aussage.

## 6. MOOSE-First-Vertrag

Source-verifizierte Kernpfade:

```text
SPAWN
FLIGHTGROUP
AUFTRAG
COORDINATE
SCHEDULER
UTILS.IasToTas
FLIGHTGROUP:SetDefaultSpeed
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:SetFuelLowThreshold
FLIGHTGROUP:SetFuelCriticalThreshold
FLIGHTGROUP:FindNearestTanker
FLIGHTGROUP:Refuel
FuelLow / FuelCritical / Refueled FSM callbacks
PauseMission / UnpauseMission lifecycle
AUFTRAG:NewTANKER
```

Receiver-Ablauf:

```text
FLIGHTGROUP:Refuel(Coordinate)
-> PauseMission()
-> DCS TaskRefueling()
-> Refueled FSM
-> persistent APOC mission rejoin
```

Nicht verwendet:

```text
MIST
Native-DCS-Refuel-Parallelimplementation
parallel contact controller
ClearWaypoints live route surgery
MissionScripting.lua changes
undocumented SPAWN fuel mutation
```

## 7. Verworfenes V4-/AAR-Base-Retask-Experiment

Der zwischenzeitliche Ansatz, LISA/MOE über ihre produktiven Standard-AAR-Tracks zu beziehen und anschließend live auf einen AWACS-Track umzurouten, ist verworfen. Der Base-Builder verhindert die Rückkehr dieses Pfads unter anderem durch das Verbot von `ClearWaypoints(`.

## 8. Produktionsbundle `OMW_AWACS_Base.lua`

Produktionsartefakt:

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

Enthaltene Source-Komponenten:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AirOpsInitialStock.lua
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/air-operations/OMW_AWACS_CampaignStateAdapter.lua
scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua
scripts/air-operations/OMW_AWACS_MOE_Relief.lua
scripts/air-operations/OMW_AirOps_AWACS_Bootstrap.lua
```

`OMW_AWACS_Acceptance_4.lua` ist nicht Bestandteil der Base. `tools/build-awacs-foundation.ps1` bleibt nur als Kompatibilitätseinstieg und delegiert an den Base-Builder.

## 9. DCS-Packaging-Smoke und Merge

Der vor dem Merge gebaute Base-Stand wurde in `OMW_Template_v20.miz` eingebettet und in DCS als Packaging-/Load-Smoke bestätigt:

```text
Base source commit: c738052037c741f4b52cc6d2f0c818a6b24babc5
Base SHA-256:
c4e2ab13c2a3be9165993bb4f92bb1b81e34cddfd9dee0e0e7139a12a97ca213
MIZ SHA-256:
22220f7c7686228897ac6e7fc0f7bb34ce068cc929a6b7fcf08213f8f5b2be0c
internal mission SHA-256:
ed02eab1ffc4c353ee16f929d44f3c55fe28093b78ea80508f2fa71fd692775f
DCS: 2.9.28.26385 MT
```

PR #121 wurde nach Owner-Freigabe auf `main` gemerged:

```text
Main merge commit:
837ce24aee76c85efa008cd404afc3e4e5aed383
```

Der reale lokale post-merge Build aus `main` ergab:

```text
BuilderVersion: OMW-AIROPS-AWACS-BASE-1
GitCommit: 837ce24aee76c85efa008cd404afc3e4e5aed383
Base SHA-256:
510c876ff132d0ec612bb6e719529836fe21b4163ab9143d9e27495a6c4d4be3
```

Die Source-Komponenten-Hashes sind gegenüber dem DCS-gesmoketesteten Build unverändert, darunter:

```text
Controller SHA-256:
19da3f455fd01d9a46b20fd748a094873d20bac0c3a8b937976f362e8d06e71a
MOE Relief SHA-256:
8ad43e871980eff4aec4bf9ac8674f3cef763dd35cf78bf5e00592ac5c403d34
Bootstrap SHA-256:
ea5d624c15f8aa2b07d8c41b877f57422f5163fc93263f5fe472d77b113578eb
```

Der neue Base-Bundle-Hash entsteht durch die Build-Provenienz im generierten Header (`GitCommit` und `SourceCommitUtc`), nicht durch eine fachliche Änderung der eingebundenen Lua-Source-Komponenten.

## 10. Statusgrenze

Die Source-Logik ist funktional in DCS validiert, und die Packaging-/Load-Grenze des vor dem Merge erzeugten Base-Artefakts ist in DCS bestätigt. Das Dokument bleibt `DRAFT`, weil die vollständige Acceptance-Provenienz des langen LISA-/MOE-Laufs keine nachträglich rekonstruierte MIZ-/internal-`mission`-Hashbindung enthält. Der Merge nach `main` ändert diese Evidenzgrenze nicht.
