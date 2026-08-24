---
document_id: OMW-AWACS-ACCEPTANCE-4
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS full fuel-driven AAR acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: 837ce24aee76c85efa008cd404afc3e4e5aed383
supersedes:
superseded_by:
validated_in_dcs: true
---

# AWACS Acceptance 4 – vollständiger Fuel-/AAR-Lifecycle

## 1. Funktionaler Abschlusslauf vom 24.08.2026

Der vollständige DCS-Lauf bestätigt den funktionalen WIZARD-Lifecycle des wiederhergestellten V3-Pfads mit minimaler MOE-Erweiterung.

Ausgeführter Entwicklungsstand:

```text
Branch: agent/awacs-external-lifecycle-foundation
Source commit: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
Controller: OMW_AWACS_Controller_FullLifecycle_V3.lua
MOE extension: OMW_AWACS_MOE_Relief.lua
Foundation bundle SHA-256:
66f6b33e694098fed0727d7d9b8c72ab32285cc3c608de97ff9d1c6850dcd7dc
Acceptance-4 bundle SHA-256:
23da975a90816569bc7b4269bb7977b2b3e878f9b784005e0993aaaa638cc747
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Mission reported by DCS/debrief: OMW_Template_v20.miz
```

Die funktionale DCS-Evidenz bestätigt:

```text
WIZARD external lifecycle / ROSIE ingress
FL350 / 270 KIAS normal transit
APOC FL320 / 250 KIAS
service/sensor separation
first planned AAR with LISA
MOOSE Refueled after LISA
physical APOC rejoin and sensor restore
second planned AAR with MOE
MOOSE Refueled after MOE
physical APOC rejoin and sensor restore
final ROSIE egress
external handoff / despawn and strategic recredit
```

Beim zweiten AAR zeigt die Laufzeitevidenz WIZARD im aktiven Refuelling mit `OMW_AAR_KC135_MOE#001`, anschließend `AAR_REFUELED`, `SECOND_CYCLE_COMPLETE`, MOE-Egress und danach den erfolgreichen APOC-Rejoin mit erneuter Sensoraktivierung.

Die exakten MIZ- und internal-`mission`-SHA-256-Werte dieses vollständigen LISA-/MOE-Laufs wurden nicht nachträglich gebunden. Deshalb bleibt dieses Acceptance-Dokument trotz `validated_in_dcs: true` im Status `DRAFT` und wird nicht zu `ACCEPTED_TECHNICAL_BASELINE` erhoben.

## 2. Architektur des getesteten Stands

```text
AAR cycle 1:
LISA
-> AWACS_APOC dedicated tanker track
-> Controller.RequestRefuel()
-> FLIGHTGROUP:Refuel()
-> APOC rejoin

AAR cycle 2:
MOE
-> same AWACS_APOC dedicated tanker track
-> Controller.RequestRefuel()
-> FLIGHTGROUP:Refuel()
-> APOC rejoin
```

Gemeinsamer dedizierter AAR-Track:

```text
33.6233926368 N
68.6395554105 E
FL250
270 KIAS
340°T
20 NM
```

Der verworfene V4-/Live-Retask-Ansatz mit `ClearWaypoints()` gehört ausdrücklich nicht zum erfolgreichen Stand.

## 3. Flug- und Fuelprofil

```text
WIZARD normal transit: FL350 / 270 KIAS
APOC racetrack:        FL320 / 250 KIAS / 017T / 30 NM
LISA AAR track:        FL250 / 270 KIAS / 340T / 20 NM
MOE AAR track:         FL250 / 270 KIAS / 340T / 20 NM
WIZARD LISA RV target: FL250 / 290 KIAS
```

Fuel-Policy:

```text
65 % -> planned LISA/MOE pre-dispatch
40 % -> fallback AAR trigger
25 % -> visible off-map contingency floor
LISA FuelLow -> 38 %
MOE FuelLow  -> 31 %
```

## 4. MOOSE-First-Vertrag

Der Receiver-Pfad bleibt:

```text
FLIGHTGROUP:Refuel(Coordinate)
-> PauseMission()
-> DCS TaskRefueling()
-> Refueled FSM
-> persistent APOC mission rejoin
```

Für die physischen Tankertracks bleibt `AUFTRAG:NewTANKER(...)` maßgeblich. Es gibt keinen Native-DCS-Refuel-Ersatz, keinen parallelen Contact-Controller und keine `MissionScripting.lua`-Änderung.

## 5. Funktionale PASS-Kriterien

```text
[PASS] WIZARD materialization and ROSIE ingress
[PASS] FL350 / 270 KIAS transit
[PASS] APOC FL320 / 250 KIAS persistent orbit
[PASS] scheduled service/sensor state
[PASS] LISA planned AAR
[PASS] LISA Refueled
[PASS] first APOC rejoin / sensor restore
[PASS] MOE second planned AAR
[PASS] MOE Refueled
[PASS] second APOC rejoin / sensor restore
[PASS] final ROSIE outbound
[PASS] external handoff / despawn / recredit
```

## 6. Produktivisierung zu `OMW_AWACS_Base.lua`

Der erfolgreiche Source-Lifecycle wurde ohne fachliche Änderung als eigenes Produktionsbundle paketiert:

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

Real lokal gebauter Base-Stand vor Merge:

```text
BuilderVersion: OMW-AIROPS-AWACS-BASE-1
Source commit: c738052037c741f4b52cc6d2f0c818a6b24babc5
Base SHA-256:
c4e2ab13c2a3be9165993bb4f92bb1b81e34cddfd9dee0e0e7139a12a97ca213
Controller SHA-256:
19da3f455fd01d9a46b20fd748a094873d20bac0c3a8b937976f362e8d06e71a
MOE Relief SHA-256:
8ad43e871980eff4aec4bf9ac8674f3cef763dd35cf78bf5e00592ac5c403d34
```

`OMW_AWACS_Acceptance_4.lua` bleibt Test-/Observer-Code und ist nicht Bestandteil der Produktions-Base.

## 7. Base-Packaging-Smoke-Test

Nach der Umstellung des Mission-Editor-DO-SCRIPT-FILE-Triggers von `OMW_AWACS_Foundation.lua` auf `OMW_AWACS_Base.lua` wurde ein eigener DCS-Smoke-Lauf durchgeführt.

Gebundene Mission vor diesem Lauf:

```text
Mission: OMW_Template_v20.miz
MIZ SHA-256:
22220f7c7686228897ac6e7fc0f7bb34ce068cc929a6b7fcf08213f8f5b2be0c
internal mission SHA-256:
ed02eab1ffc4c353ee16f929d44f3c55fe28093b78ea80508f2fa71fd692775f
embedded OMW_AWACS_Base.lua SHA-256:
c4e2ab13c2a3be9165993bb4f92bb1b81e34cddfd9dee0e0e7139a12a97ca213
DCS: 2.9.28.26385 MT
```

Der Smoke-Lauf bestätigt die Packaging-/Load-Grenze:

```text
[PASS] AWACS production bundle loads without AWACS Lua failure
[PASS] OMW_AWACS_Controller_FullLifecycle_V3 starts
[PASS] AWACS bootstrap reports RUNNING
[PASS] OMW_AWACS_MOE_Relief starts
[PASS] WIZARD materializes as AWACS-0001
[PASS] ROSIE/APOC lifecycle executes
[PASS] persistent APOC orbit is added
[PASS] Acceptance-4 observer receives live telemetry
```

Damit ist `OMW_AWACS_Base.lua` als DCS-geladenes Produktionsartefakt für die Packaging-/Load-Grenze praktisch bestätigt. Dieser Smoke-Test ersetzt nicht den separat ausgeführten vollständigen LISA-/MOE-Lifecycle-Test.

## 8. Merge und post-merge Build

Nach Owner-Freigabe wurde PR #121 auf `main` gemerged:

```text
Main merge commit:
837ce24aee76c85efa008cd404afc3e4e5aed383
```

Der reale lokale post-merge Build aus dem `main`-Worktree ergab:

```text
Worktree: P:\DCS-DEV\Operation-Mountain-Watch-main
Branch: main
HEAD: 837ce24aee76c85efa008cd404afc3e4e5aed383
BuilderVersion: OMW-AIROPS-AWACS-BASE-1
Base SHA-256:
510c876ff132d0ec612bb6e719529836fe21b4163ab9143d9e27495a6c4d4be3
```

Die eingebundenen Source-Komponenten-Hashes sind gegenüber dem DCS-gesmoketesteten Build unverändert, insbesondere Controller, MOE Relief und Bootstrap. Der neue Base-Bundle-Hash entsteht durch die Build-Provenienz im generierten Header (`GitCommit` und `SourceCommitUtc`) des post-merge Builds.

## 9. Statusgrenze

`validated_in_dcs: true` ist für die dokumentierten funktionalen und Packaging-/Load-Befunde erfüllt. Das Dokument bleibt `DRAFT`, weil die vollständige Acceptance-Provenienz des langen LISA-/MOE-Laufs keine nachträglich rekonstruierte MIZ-/internal-`mission`-Hashbindung enthält. Der Merge nach `main` ändert diese Evidenzgrenze nicht.
