---
document_id: OMW-AWACS-ACCEPTANCE-3
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS persistent-racetrack service-transition acceptance
  - AWACS emission/radar-option acceptance
  - no-detour verification at 15:30 service activation
  - manual player-side RWR observation
  - explicit direct ROSIE egress after service observation
not_authoritative_for:
  - full-duration AWACS endurance
  - production fuel-triggered AAR policy
  - DCS datalink contribution before explicit acceptance evidence
  - fighter-control or DCS AWACS voice-service requirements
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# AWACS Acceptance 3 – persistenter Racetrack und Sensor-/Emissionsumschaltung

## 1. Anlass

Acceptance 2 hat zwei unerwünschte Detours Richtung ROSIE sichtbar gemacht. Der erste trat beim Wechsel vom Standby-Orbit zur AWACS-Mission auf, der zweite beim AAR-Übergang. Die bisherige Controller-Struktur ersetzte dazu jeweils eine vollständige `AUFTRAG`-Mission und hatte für Standby- und AWACS-Mission `ROSIE` als Mission-Egress hinterlegt.

Für den aktuellen OMW-Scope ist die E-3 zunächst ein realistischer physischer AEW-/C2-Akteur. DCS-Fighter-Control, Bogey-Dope und eine vollständige DCS-AWACS-Funkrolle sind nicht erforderlich. Spieler sollen insbesondere die physische E-3 und – soweit DCS dies im verwendeten Stand abbildet – den aktiven Radar-Emitter auf RWR beziehungsweise optional im Datalink wahrnehmen.

Deshalb trennt Acceptance 3 erstmals verbindlich im Test:

```text
physischer Flugweg
!=
Sensor-/Emissionszustand
```

## 2. MOOSE-First-Prüfung

Gepinnter MOOSE-Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-geprüft und für diesen Test verwendet:

```text
AUFTRAG:NewORBIT_RACETRACK(...)
AUFTRAG:SetMissionAltitude(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:MissionCancel(...)
FLIGHTGROUP:AddWaypoint(...)
OPSGROUP:SwitchEmission(...)
CONTROLLABLE:SetOptionRadarUsingNever()
CONTROLLABLE:SetOptionRadarUsingForContinousSearch()
SCHEDULER:New(...)
UTILS.SecondsOfToday()
```

Die offizielle MOOSE-Dokumentation und der gepinnte Quellcode bestätigen außerdem `CONTROLLABLE:EnRouteTaskAWACS()`. Diese Funktion wird hier bewusst **nicht** verwendet, weil die aktuelle OMW-Anforderung keine DCS-Fighter-Control-/AWACS-Task-Funktion benötigt.

Offizielle MOOSE-Beispiele wurden auf AWACS-/OPSGROUP-/CONTROLLABLE-Anwendung geprüft. Ein direktes offizielles Beispiel für exakt `persistenter Racetrack + SwitchEmission(false/true) + kein AWACS-Task` wurde nicht gefunden. Daher bleibt das konkrete Laufzeitverhalten bis zum DCS-Test `SOURCE_REVIEWED / PLANNED`.

## 3. Neue Controllergrenze

Der Produktionscontroller verwendet für APOC nur noch einen persistenten physischen Racetrack:

```text
AUFTRAG:NewORBIT_RACETRACK
FL320
300 kt
017T
30 NM
```

Nicht mehr verwendet werden:

```text
AUFTRAG:NewAWACS
EnRouteTaskAWACS
MissionEgressCoord auf dem normalen APOC-Racetrack
```

Die Dienstumschaltung erfolgt ohne Missionsersatz:

```text
vor 15:30
persistent racetrack
SwitchEmission(false)
SetOptionRadarUsingNever()
serviceState = STANDBY
sensorState = SILENT

15:30
persistent racetrack bleibt unverändert
SetOptionRadarUsingForContinousSearch()
SwitchEmission(true)
serviceState = ACTIVE
sensorState = EMITTING
```

ROSIE wird nur noch durch einen expliziten physischen Egress-Wegpunkt angeflogen.

## 4. Acceptance-3-Testprofil

Missionsstart:

```text
15:05 local
```

Ablauf:

```text
15:05
WIZARD external materialization
FL340 / 440 kt
sensor SILENT

-> ROSIE inbound
-> FL350 / 440 kt late approach
-> APOC
-> persistent FL320 / 300 kt racetrack

before 15:30
serviceState STANDBY
sensorState SILENT
no ROSIE detour

15:30
serviceState ACTIVE
sensorState EMITTING
same persistent racetrack mission
NO mission replacement
NO ROSIE egress

15:30-15:40
observe stable APOC orbit
manual RWR comparison

15:40
Acceptance 3 requests explicit egress
sensor SILENT
persistent orbit is cancelled only now
FL340 / 440 kt direct ROSIE egress
-> external handoff
```

## 5. Lua-Bundle

Source:

```text
mission/tests/awacs-external-lifecycle/src/03-awacs-persistent-orbit-emission-acceptance.lua
```

Builder:

```text
tools/build-awacs-acceptance-3.ps1
```

Generated bundle:

```text
mission/tests/awacs-external-lifecycle/dist/OMW_AWACS_Acceptance_3.lua
```

Der Harness steuert den Flug nicht parallel. Er beobachtet den Controller aus `OMW_AWACS_Foundation.lua`, protokolliert Service-/Sensor-/Missionzustand und fordert erst um 15:40 einen kontrollierten Egress an.

## 6. Manuelle DCS-Prüfungen

### A. Standby vor 15:30

Erwartet:

```text
WIZARD auf APOC
serviceState=STANDBY
sensorState=SILENT
missionKind=PERSISTENT_RACETRACK
```

Mit geeignetem Spielerflugzeug und geeigneter Geometrie prüfen:

```text
kein AWACS-Radaremitter auf RWR, soweit DCS das E-3-Modell entsprechend abbildet
```

Fehlt ein RWR-Eintrag, ist das nur dann PASS-Evidenz für `SILENT`, wenn dasselbe Empfängerflugzeug nach Aktivierung unter vergleichbarer Geometrie einen Emitter erkennt.

### B. Aktivierung 15:30

Erwartet:

```text
serviceState=ACTIVE
sensorState=EMITTING
missionKind bleibt PERSISTENT_RACETRACK
```

WIZARD darf nicht:

```text
Richtung ROSIE ausbrechen
auf FL340/FL350 Transitprofil wechseln
seinen APOC-Racetrack wegen der Dienstaktivierung verlassen
```

### C. RWR nach 15:30

Mit demselben geeigneten Spielerflugzeug prüfen:

```text
AWACS-Radaremitter sichtbar, sofern DCS/RWR/Entfernung/Geometrie dies unterstützen
```

Ein positiver Unterschied `vor 15:30 nicht sichtbar / nach 15:30 sichtbar` bestätigt den vorgesehenen Emissionspfad für den konkreten DCS-/Flugzeug-Scope.

Datalink ist Beobachtungswert, aber kein PASS-Kriterium dieser Acceptance.

### D. Expliziter Egress 15:40

Erst ab der Acceptance-Anforderung um 15:40 darf WIZARD:

```text
APOC verlassen
auf FL340 / 440 kt Transferprofil wechseln
ROSIE outbound anfliegen
```

Damit wird nachgewiesen, dass ROSIE nicht länger ein Seiteneffekt eines internen Service-State-Wechsels ist.

## 7. Automatische Log-Evidenz

Erforderliche Marker:

```text
[OMW][AWACS.Controller] PERSISTENT_ORBIT
[OMW][AWACS.Controller] SENSOR_STATE ... SILENT
[OMW][AWACS.Controller] SERVICE_ACTIVE ... mode=PERSISTENT_ORBIT_SENSOR_TOGGLE
[OMW][AWACS.Controller] SENSOR_STATE ... EMITTING
[OMW][AWACS.Acceptance3] SERVICE_ACTIVATION_OBSERVED
[OMW][AWACS.Acceptance3] CONTROLLED_EGRESS_REQUESTED
[OMW][AWACS.Controller] EGRESS_ORDERED ... mode=DIRECT_WAYPOINT
[OMW][AWACS.Controller] EXTERNAL_HANDOFF
[OMW][AWACS.Acceptance3] AUTOMATED_CAPTURE_COMPLETE
```

Telemetry alle 30 Sekunden:

```text
serviceState
sensorState
serviceMissionKind
physicalOnTrack
egressOrdered
altitude
speed
heading
fuel
position
```

## 8. PASS-Kriterien

PASS nur, wenn alle Punkte erfüllt sind:

```text
1. WIZARD materialisiert und erreicht APOC.
2. Vor 15:30 läuft PERSISTENT_RACETRACK mit SILENT sensor state.
3. Um 15:30 wechselt nur der Sensor-/Servicezustand auf EMITTING/ACTIVE.
4. serviceMissionKind bleibt PERSISTENT_RACETRACK.
5. Kein ROSIE-Detour beim 15:30-Wechsel.
6. RWR-Verhalten wird mit demselben Empfänger vor/nach Aktivierung dokumentiert.
7. Erst der explizite Acceptance-Egress um 15:40 erzeugt ROSIE outbound.
8. Externer Handoff/Despawn/strategischer Recredit funktioniert weiterhin.
9. Keine Lua-Fehler oder unerwartete MOOSE-RTB-/MissionCancel-Nebenwirkung.
```

`VALIDATED` beziehungsweise `ACCEPTED_TECHNICAL_BASELINE` wird erst nach realem DCS-Lauf mit dokumentierter Mission, Hashes, DCS-Version, Bundle-Hashes und Log-Evidenz gesetzt.

## 9. Ausdrücklich offen nach Acceptance 3

Acceptance 3 entscheidet noch nicht über:

```text
fuel-state-basierten AAR-Trigger
LISA-vs-nearest-compatible-tanker selection
MOOSE FuelLow RTB suppression/replacement
vollständigen 8-h-Burn
Datalink-Nutzung
23:30 production egress under AAR conditions
```

Diese Punkte werden erst nach erfolgreicher Beseitigung des Detour-Problems weiterentwickelt.
