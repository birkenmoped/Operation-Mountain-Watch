---
document_id: OMW-AWACS-ACCEPTANCE-4
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS full fuel-driven AAR acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: PENDING_MERGE
supersedes:
superseded_by:
validated_in_dcs: true
---

# AWACS Acceptance 4 – vollständiger Fuel-/AAR-Lifecycle

## 1. Ergebnis des Abschlusslaufs vom 24.08.2026

Der zuletzt ausgeführte DCS-Lauf bestätigt den funktionalen WIZARD-Lifecycle des wiederhergestellten V3-Pfads mit minimaler MOE-Erweiterung.

Ausgeführter Entwicklungsstand vor dem Lauf:

```text
Branch: agent/awacs-external-lifecycle-foundation
Source commit: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
Controller: OMW_AWACS_Controller_FullLifecycle_V3.lua
MOE extension: OMW_AWACS_MOE_Relief.lua
Foundation bundle SHA-256 from local build:
66f6b33e694098fed0727d7d9b8c72ab32285cc3c608de97ff9d1c6850dcd7dc
Acceptance-4 bundle SHA-256 from local build:
23da975a90816569bc7b4269bb7977b2b3e878f9b784005e0993aaaa638cc747
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Mission file reported by DCS/debrief: OMW_Template_v20.miz
```

Die funktionale DCS-Evidenz bestätigt insbesondere:

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

Beim zweiten AAR zeigt die Laufzeitevidenz WIZARD im aktiven Refuelling mit `OMW_AAR_KC135_MOE#001`, anschließend `AAR_REFUELED` bei praktisch vollem Fuel, `SECOND_CYCLE_COMPLETE`, MOE-Egress und danach den erfolgreichen APOC-Rejoin mit erneuter Sensoraktivierung.

## 2. Architektur des getesteten Stands

Der getestete Stand verwendet bewusst wieder den zuvor funktionierenden AWACS-eigenen AAR-Pfad und ergänzt nur den zweiten geplanten Tankerzyklus.

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

Der verworfene V4-/Live-Retask-Ansatz mit `ClearWaypoints()` gehört ausdrücklich **nicht** zum erfolgreichen Stand.

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
65 % -> planned LISA pre-dispatch
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

## 5. PASS-Kriterien

Funktional erfüllt:

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

## 6. Noch fehlende Provenienz für `ACCEPTED_TECHNICAL_BASELINE`

Dieses Dokument bleibt trotz funktionalem DCS-PASS `DRAFT`, weil für den exakt ausgeführten `OMW_Template_v20.miz`-Stand noch nicht in diesem Dokument gebunden sind:

```text
final MIZ SHA-256
final internal mission SHA-256
```

Diese Werte werden nicht rekonstruiert oder geraten. Erst wenn sie real erhoben und mit dem ausgeführten Teststand gebunden sind, darf eine Statusanhebung nach `docs/DOCUMENT-METADATA-POLICY.md` geprüft werden.

## 7. Produktivisierung

Der erfolgreiche Source-Lifecycle wird nach diesem Acceptance-Lauf ohne fachliche Änderung als Produktionsbundle ausgerollt:

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

`OMW_AWACS_Acceptance_4.lua` bleibt ausschließlich Test-/Observer-Code und ist kein Bestandteil der Produktions-Base.

Die Umbenennung `Foundation -> Base` erzeugt wegen Header/Commit einen neuen Bundle-Hash. Daher gilt der neue `OMW_AWACS_Base.lua`-Artefaktstand erst nach lokalem Build/Hash und einem kurzen DCS-Load-/Smoke-Nachweis als exakt artefaktvalidiert; die zugrunde liegende Lifecycle-Logik selbst ist durch den oben dokumentierten Lauf DCS-validiert.
