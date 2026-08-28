---
document_id: OMW-RESULT-ARMY-GROUND-ACCEPTANCE-2-RUNTIME-2026-08-18
status: PLANNED
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Ground Acceptance 2 runtime evidence recorded from the 2026-08-18 DCS test
  - runtime confirmation of the Joyce ARMOREDGUARD On Road to Vee same-group lifecycle for the cited provenance
not_authoritative_for:
  - repository-wide production architecture before merge
  - final production road speed
  - full visual acceptance until all visual criteria are explicitly confirmed
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 5f72779d6230d805cd6ec5065c62d94c397709e0
validated_in_dcs: true
supersedes:
superseded_by:
---

# Ground Acceptance 2 – Runtime evidence 2026-08-18

## 1. Ergebnisgrenze

Der technische Runtime-Pfad von Acceptance 2 lief bis zum vorgesehenen Marker

```text
OMW_GND_A2 RUNTIME_PASS_VISUAL_PENDING
```

durch. Im ausgewerteten Acceptance-Pfad wurde kein `OMW_GND_A2 FAIL` gefunden.

Der Test bleibt hinsichtlich des **vollständigen visuellen Acceptance-Vertrags** bewusst noch nicht als `ACCEPTED_TECHNICAL_BASELINE` hochgestuft, weil die Owner-Rückmeldung zwar das deutlich bessere Fahrverhalten und die sichtbare Vee-Formation bestätigt, aber die Kriterien `kein sichtbarer Teleport/Despawn` und `keine sichtbare zweite Fahrzeuggruppe` in der Rückmeldung nicht separat ausdrücklich beantwortet wurden.

## 2. Provenienz

```text
Branch:
agent/army-ground-foundation-reconciliation

Embedded bundle GitCommit:
5f72779d6230d805cd6ec5065c62d94c397709e0

BuilderVersion / Test-ID:
ARMY-GROUND-ACCEPTANCE-2-1

DCS:
2.9.28.26385 MT

Mission artifact:
OMW_Template_v13_ground_test(3).miz

MIZ SHA-256:
A09CAD18EE5FD283622052773CB47929E2A0176C563D19CB39E52890EB6178DB

Internal mission SHA-256:
BCF82AEE012ABBE3B1DEDD69D246887541F060F9506D9E495DCF71742C281209

Embedded Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Acceptance-2 bundle SHA-256:
BA9E16AE88C271A31EFFA9E114592B8902D52680EB1AC76E1DF424365652C1C4
```

Die Hashes stammen aus der read-only Auswertung des tatsächlich hochgeladenen Testartefakts. Sie dürfen nicht auf spätere Builds übertragen werden.

## 3. Runtime-Sequenz

Der relevante Harness-Pfad bestätigte:

```text
START
GEOMETRY totalDistanceM=9447 tacticalLegM=1597
BRIGADE_STARTED
PLATOON_READY assets=1
MISSION1_QUEUED formation=On Road
GROUP_MATERIALIZED PLT_BLUE_GND_JOYCE_PATROL_AID-211
MISSION1_ON_MISSION

APPROACH_GUARD_EXECUTING distanceM=2 formation=On Road
MISSION1_DONE reservation=FIELD_DEPLOYED
GROUP_STILL_ALIVE PLT_BLUE_GND_JOYCE_PATROL_AID-211

MISSION2_QUEUED formation=Vee distanceM=1598
MISSION2_SAME_GROUP PLT_BLUE_GND_JOYCE_PATROL_AID-211
OBS_GUARD_EXECUTING distanceM=22 formation=Vee

GUARD_HOLD_STABLE movedM=0 targetDistanceM=22
RUNTIME_PASS_VISUAL_PENDING reservation=FIELD_DEPLOYED spawnCount=1 formation=Vee
```

Technisch bestätigt sind damit für diesen exakten Stand:

```text
- one Joyce BRIGADE/PLATOON asset selected
- exactly one materialization reported by the harness
- ARMOREDGUARD road approach executed
- Mission 1 ended while the physical ARMYGROUP remained alive
- the same ARMYGROUP was reused for Mission 2
- Vee ARMOREDGUARD reached the target area
- hold stability check measured 0 m movement
- final target distance was 22 m
- spawnCount remained 1
```

## 4. Owner visual observation

Der Projektinhaber berichtete nach dem Lauf:

```text
- das Verhalten sah deutlich besser aus als Acceptance 1
- im Zielgebiet ging die Fahrzeuggruppe sichtbar in eine Vee-Formation
- die Reisegeschwindigkeit war deutlich zu langsam
- deshalb wurde DCS-Zeitbeschleunigung verwendet
```

Die Zeitbeschleunigung erklärt, warum Wallclock-Zeitstempel nicht direkt als reale Fahrzeitkalibrierung verwendet werden dürfen.

## 5. Geschwindigkeitskorrektur für Folgearbeit

Acceptance 2 verwendete:

```text
ROAD_SPEED_KNOTS = 10
```

Das entspricht nur ungefähr 18.5 km/h und wurde visuell als zu langsam bewertet.

Die bereits vorhandene OMW-TM01M-Konvoi-Baseline verwendet:

```text
routing.speedKph = 50
```

Für den nächsten Ground-Integrationstest wird deshalb festgelegt:

```text
normal road transit:
27 kt ~= 50 km/h

final tactical leg:
8 kt

observation halt:
ARMOREDGUARD / Vee / FullStop
```

Die 27 kt sind ein Testwert zur Angleichung an die bestehende OMW-Konvoi-Baseline und müssen im nächsten DCS-Lauf erneut visuell/pathfinding-seitig bewertet werden.

## 6. Acceptance-Grenze

Aktueller Ergebnisstatus:

```text
RUNTIME PATH: PASS
SAME-GROUP REUSE: PASS
VEE VISUAL CONFIRMATION: PASS
ROAD SPEED CALIBRATION: REJECTED AS TOO SLOW AT 10 KT
FULL VISUAL ACCEPTANCE: PENDING EXPLICIT CONTINUITY CONFIRMATION
```

Damit ist der ARMOREDGUARD-basierte Verhaltenspfad ausreichend bestätigt, um ihn im nächsten Schritt **nicht weiter als Joyce-Einzeltest**, sondern gleichzeitig über die sechs geplanten operativen Kunar/Jalalabad-Domänen zu skalieren.
