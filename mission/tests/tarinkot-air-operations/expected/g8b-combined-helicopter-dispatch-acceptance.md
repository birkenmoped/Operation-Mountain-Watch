---
document_id: OMW-TEST-TKOT-G8B-COMBINED-HELICOPTER-DISPATCH-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - combined Tarinkot dispatch of every G7-registered AI helicopter group
  - batched vertical-departure, parking and landing telemetry
not_authoritative_for:
  - tactical CAS effectiveness
  - COMMANDER or OPSTRANSPORT acceptance
  - persistent inventory or campaign behavior
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-revised-parking-layout
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G8B – gebündelter KI-Hubschrauberdispatch

## 1. Ziel und Bündelungsgrenze

Ein einzelner DCS-Lauf prüft alle in G7 registrierten Tarinkot-KI-Gruppen:

```yaml
AH64:
  groups: 2
  aircraft_per_group: 2
  runtime_aircraft: 4
  mission: CAS
UH60:
  groups: 2
  aircraft_per_group: 1
  runtime_aircraft: 2
  mission: LANDATCOORDINATE
CH47:
  groups: 1
  aircraft_per_group: 1
  runtime_aircraft: 1
  mission: LANDATCOORDINATE
total_groups: 5
total_runtime_aircraft: 7
total_missions: 5
```

Es folgen keine separaten Musterläufe, sofern der kombinierte Lauf eindeutige
gruppenbezogene Marker liefert. Einzelläufe sind nur noch zur Isolation eines
konkreten kombinierten Fehlers zulässig.

## 2. MOOSE-First-Pfad

Der Test verwendet ausschließlich:

```text
AUFTRAG:NewCAS()
AUFTRAG:NewLANDATCOORDINATE()
AUFTRAG:AssignSquadrons()
AUFTRAG:AddRequiredPayload()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission()
FLIGHTGROUP:OnAfterTakeoff()
```

Verboten bleiben COMMANDER, OPSTRANSPORT, Raw-SPAWN, standalone FLIGHTGROUP,
synthetische Zonen, direkte KI-Aktivierung und CampaignState-Mutation.

## 3. Zielgeometrie

Die vorhandene Mission-Editor-Zone
`ZONE_AIR_US_TKOT_ROTARY_STAGING` besitzt einen Radius von 91,44 Metern. Die drei
Landemissionen erhalten feste MOOSE-`COORDINATE:Translate()`-Zielpunkte in jeweils
50 Metern Abstand vom Zentrum bei 0, 120 und 240 Grad. Der Abstand zwischen den
Zielpunkten beträgt rund 86,6 Meter.

Die AH-64-CAS-Aufträge nutzen dieselbe Zone als technische Einsatz-/Orbitzone,
aber getrennte Orbitpunkte und Höhen. Der Test bewertet keine Zielbekämpfung.

## 4. Timeoutvertrag

```yaml
assignment_timeout_seconds: 720
takeoff_timeout_after_flight_on_mission_seconds: 360
aggregate_timeout_seconds: 1200
poll_interval_seconds: 2
log_interval_seconds: 10
max_ground_displacement_before_airborne_m: 75
```

Das lange Zuweisungsfenster ist erforderlich, weil der AH-64-Pool mit zwei
Parkplätzen nur eine Zweiergruppe gleichzeitig aufnehmen kann. Die zweite Gruppe
darf nativ warten, bis MOOSE die Parkplätze nach dem ersten Abflug freigibt.

## 5. Runtime-Acceptance

Für jede der fünf Gruppen müssen vorhanden sein:

```text
MISSION_ADDED key=<key>
FLIGHT_ON_MISSION key=<key>
optionPreferVertical=true
erwartete Unitanzahl
FLIGHTGROUP_TAKEOFF oder DCS_ALL_UNITS_IN_AIR_POLL
maxGroundDisplacementM <= 75
kein AUFTRAG Failed/Cancel
```

Für `UH60_1`, `UH60_2` und `CH47_1` ist zusätzlich `MISSION_STATE ... Success`
mit `landingSuccess=true` erforderlich.

Aggregatmarker:

```text
RESULT G8B_COMBINED_HELICOPTER_DISPATCH
status=PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL
missions=5
assigned=5
takeoffGroups=5
landingMissionsComplete=3
failedGroups=0
runtimeUnits=7
```

## 6. Visuelle Acceptance

Der Projektinhaber bestätigt im selben Lauf:

```text
zwei AH-64-Zweiergruppen erscheinen nacheinander auf 20,19
zwei UH-60 erscheinen auf zwei Positionen aus 23,27,30
eine CH-47 erscheint auf einer Position aus 32,29,10
keine Nutzung der Clientpositionen 21,8,3
keine Kollision mit Clients, Statics oder anderen KI-Gruppen
kein Taxi- oder Runway-Abflug
alle fünf Gruppen heben vertikal ab
beide UH-60 und die CH-47 landen an getrennten Außenlandepunkten
```

Telemetrie-PASS plus diese Sichtprüfung ergeben
`PASS_DCS_OWNER_VISUAL_ACCEPTED`.

## 7. Provenienz

```yaml
branch: agent/tarinkot-revised-parking-layout
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
builder: tools/build-tarinkot-air-operations-g8b-combined-helicopter-dispatch.ps1
builder_version: TKOT-G8B-COMBINED-HELICOPTER-DISPATCH-1
bundle: mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G8B_CombinedHelicopterDispatch.lua
mission: OMW_Template_v6_Tarinkot.miz
```

Nach Einbindung sind MIZ-, interner Mission-, Bundle- und Moose-Hash erneut zu
erfassen. G9 bleibt bis zum kombinierten Ergebnis blockiert.
