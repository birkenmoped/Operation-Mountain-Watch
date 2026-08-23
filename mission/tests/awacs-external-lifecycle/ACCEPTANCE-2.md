---
document_id: OMW-AWACS-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS flight-profile telemetry acceptance
  - 30-minute APOC fuel-burn capture
  - manual player-side WIZARD radio-service check
not_authoritative_for:
  - six-hour relief lifecycle
  - loss and restart reconciliation
  - AWACS aerial-refuelling dispatch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# AWACS Acceptance 2 – Flight Profile, Track, Radio and Fuel Telemetry

## 1. Zweck

Acceptance 1 hat den grundlegenden Routing-Lifecycle praktisch bestätigt:

```text
External Spawn
-> ROSIE inbound
-> Late Approach
-> AUFTRAG:NewAWACS
-> APOC ON_STATION
-> controlled egress
-> ROSIE outbound
-> External Handoff
```

Acceptance 2 erfasst die noch fehlende physische Telemetrie, ohne den Produktionscontroller umzubauen.

## 2. MOOSE-first Testgrenze

Der Harness ist ein reiner Testobserver und verwendet ausschließlich öffentliche MOOSE-Pfade:

```text
SCHEDULER:New(...)
FLIGHTGROUP:IsAlive()
FLIGHTGROUP:GetAltitude()
FLIGHTGROUP:GetVelocity()
FLIGHTGROUP:GetHeading()
FLIGHTGROUP:GetFuelMin()
OPSGROUP:GetGroup()
OPSGROUP:GetCoordinate()
GROUP:GetUnit(1)
UNIT:GetCurrentFuelKgs()
UNIT:GetFuelMassMax()
COORDINATE:GetLLDDM()
UTILS.MpsToKnots(...)
UTILS.SecondsOfToday()
```

Der Harness verwendet keine `_DATABASE`-Interna, keinen Native-DCS-Scheduler, keinen eigenen Spawn-/Routingpfad und keine alternative AWACS-Mission.

`FLIGHTGROUP:GetFuelMin()`, `UNIT:GetCurrentFuelKgs()` und `UNIT:GetFuelMassMax()` sind bereits im dokumentierten AAR-Scope praktisch verwendet. `OPSGROUP:GetAltitude()`, `GetVelocity()` und `GetHeading()` wurden im gepinnten `Moose.lua` mit den verwendeten Signaturen source-seitig geprüft. `COORDINATE:GetLLDDM()` wurde im tatsächlich verwendeten `Moose.lua` geprüft und liefert über `coord.LOtoLL(self:GetVec3())` die geodätischen Latitude-/Longitude-Werte. Die zunächst erwogenen Methoden `COORDINATE:GetLat()` / `GetLon()` wurden ausdrücklich verworfen, weil sie im gepinnten Source lediglich die internen lokalen `x`-/`z`-Koordinaten zurückgeben und daher für die geodätische Racetrack-Auswertung ungeeignet sind. Für diese read-only Telemetrie ist kein eigenes offizielles Demo-Konstrukt erforderlich; es wird keine neue Lifecycle-Semantik daraus abgeleitet.

## 3. Testartefakte

```text
Source:
mission/tests/awacs-external-lifecycle/src/02-awacs-flight-profile-acceptance.lua

Builder:
tools/build-awacs-acceptance-2.ps1

Generated bundle:
mission/tests/awacs-external-lifecycle/dist/OMW_AWACS_Acceptance_2.lua
```

## 4. Testkonfiguration

```text
Telemetry interval:       15 s
Required station dwell:   1800 s / 30 min
Egress trigger:           relative to observed APOC ON_STATION
Egress reason:            ACCEPTANCE_2_PROFILE_FUEL_EGRESS
Radio check:              manual player observation required
Callsign:                 WIZARD
Frequency:                357.300 MHz AM
```

Die 30 Minuten Station Time werden bewusst relativ zu `ON_STATION` gemessen. Damit hängt der Test nicht von der absoluten Missionszeit ab und wiederholt nicht das Acceptance-1-Problem eines bereits weit fortgeschrittenen `TIME MORE`-Triggers.

## 5. Mission-Editor-Voraussetzungen

Die Mission muss in dieser Reihenfolge laden:

```text
1. Moose.lua
2. OMW_AirOps_Warehouse_Base.lua
3. OMW_AWACS_Foundation.lua
4. OMW_AWACS_Acceptance_2.lua
```

Der alte Acceptance-1-Trigger, der nach absolut `TIME MORE 1800` `RequestEgress("ACCEPTANCE_1_ROUTING_EGRESS")` auslöst, muss für Acceptance 2 deaktiviert werden. Andernfalls wird die E-3 vor Abschluss der 30-minütigen Station-Telemetrie wieder aus APOC herausgeschickt.

Das Produktions-AWACS-Bundle selbst wird für Acceptance 2 nicht test-only verändert.

## 6. Automatisch protokollierte Telemetrie

Jede Probe schreibt:

```text
runtime ID
phase
simulation time
altitude ft
speed kt
heading deg
fuel percent
fuel kg
max internal fuel kg
latitude
longitude
```

Latitude/Longitude stammen aus `COORDINATE:GetLLDDM()` und sind damit geodätische Koordinaten, nicht die internen DCS-Lokalkoordinaten `x`/`z`.

Phasen:

```text
INBOUND_EXTERNAL
INBOUND_AFG
AWACS_APPROACH
ON_STATION
EGRESS
```

Wichtige Marker:

```text
[OMW][AWACS.Acceptance2] START
[OMW][AWACS.Acceptance2] TELEMETRY
[OMW][AWACS.Acceptance2] PHASE_CHANGE
[OMW][AWACS.Acceptance2] STATION_BASELINE
[OMW][AWACS.Acceptance2] STATION_MIDPOINT
[OMW][AWACS.Acceptance2] STATION_30MIN_COMPLETE
[OMW][AWACS.Acceptance2] EGRESS_REQUESTED
[OMW][AWACS.Acceptance2] AUTOMATED_CAPTURE_COMPLETE
```

## 7. Auswertungskriterien

### Transitprofil

Zu prüfen:

```text
External Spawn / ROSIE inbound:
planned FL340 / approx. 300 kt after initial stabilization

ROSIE -> late approach:
planned transition to FL350 / approx. 300 kt

Late Approach -> APOC:
natural transition toward FL320 / 300 kt
```

Die Werte werden nicht aus der Sollkonfiguration als PASS angenommen. Maßgeblich sind die realen Telemetriedaten.

### APOC-Racetrack

Die 15-s-Positions- und Heading-Proben müssen nach dem Lauf geodätisch ausgewertet werden. Zielbild:

```text
primary axis approximately 017T / 197T
leg length approximately 30 NM
track altitude approximately FL320
track speed approximately 300 kt
```

Acceptance 2 behauptet den Racetrack erst nach Auswertung der realen Positionen als bestätigt.

### Fuel

Zu erfassen:

```text
spawn fuel
ROSIE fuel
first APOC station fuel
15-minute station fuel
30-minute station fuel
ROSIE outbound fuel
external-handoff fuel
```

Der Harness berechnet zusätzlich aus der 30-Minuten-Stationphase:

```text
fuelBurnKg
fuelBurnPct
projectedHourlyBurnKg = 2 * observed 30-minute burn
```

Die Projektion ist eine Kalibrierhilfe und kein Ersatz für spätere Langzeit-/Relief-Evidenz.

### Radio / native AWACS service

Während `ON_STATION` muss der Projektinhaber mit einem geeigneten Client prüfen:

```text
WIZARD ist als AWACS-Ansprechpartner verfügbar
357.300 MHz AM ist die verwendete Frequenz
mindestens eine native AWACS-Abfrage erhält eine plausible Antwort
```

Der Harness kann diese Spieler-Radiointeraktion nicht aus dem internen Controllerstatus ableiten. Das Ergebnis muss deshalb als reale Beobachtung dokumentiert werden.

## 8. PASS-Grenze

Acceptance 2 kann nach Log-/Trackauswertung und manueller Radio-Beobachtung bestätigen:

```text
physical cruise profile
APOC racetrack geometry
native WIZARD radio service
baseline DCS fuel burn
normal egress after measured station dwell
```

Nicht Bestandteil:

```text
6-hour station cycle
scheduled relief launch and handover
loss settlement
restart reconciliation
AAR / tanker rendezvous
```

Diese bleiben nachfolgende Acceptance-Blöcke.
