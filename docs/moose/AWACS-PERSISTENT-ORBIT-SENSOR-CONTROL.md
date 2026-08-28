---
document_id: OMW-MOOSE-AWACS-PERSISTENT-ORBIT-SENSOR-CONTROL
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed AWACS persistent-orbit sensor-control design
  - Acceptance-3 MOOSE method selection
not_authoritative_for:
  - DCS validation of RWR or datalink behavior
  - full-duration AWACS endurance or fuel-triggered AAR
  - replacement of Acceptance-1 validated routing provenance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# MOOSE – AWACS persistenter Racetrack und Sensorsteuerung

## 1. Ziel

Der aktuelle OMW-AWACS-Scope benötigt zunächst einen realistisch sichtbaren E-3-Akteur mit:

```text
realistischem Ingress/Egress
persistentem APOC-Racetrack
zeitgesteuertem Radar-/Emissionszustand
RWR-Wahrnehmbarkeit soweit DCS dies abbildet
AAR- und Fuel-Lifecycle in späterer Acceptance
```

Nicht erforderlich sind derzeit:

```text
DCS AWACS fighter control
Bogey-dope/vectoring gameplay
MOOSE AWACS text-to-speech controller
```

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Source-Prüfung

Im gepinnten Source verifiziert:

```text
AUFTRAG:NewORBIT_RACETRACK(...)
AUFTRAG:SetMissionAltitude(...)

OPSGROUP:SwitchEmission(Switch)
CONTROLLABLE:SetOptionRadarUsingNever()
CONTROLLABLE:SetOptionRadarUsingForContinousSearch()

CONTROLLABLE:EnRouteTaskAWACS()
```

`EnRouteTaskAWACS()` existiert und würde ein Flugzeug als AWACS für Friendly Units ausweisen. Diese Funktion ist für den aktuellen OMW-Statisten-/AEW-Scope nicht erforderlich und wird in Acceptance 3 bewusst nicht gesetzt.

Die MOOSE-Klasse `AWACS` ist ebenfalls vorhanden, stellt aber einen umfassenden Controller für Fighter-Control, FEZ/Ops-Zones, TTS/SRS und weitere C2-Funktionen dar. Sie ist für diesen abgegrenzten physischen E-3-Scope unverhältnismäßig.

## 4. Offizielle Dokumentation und Beispiele

Geprüft wurden:

```text
MOOSE develop/stable documentation
pinned MOOSE source
MOOSE_MISSIONS
MOOSE_MISSIONS_UNPACKED
```

Die offizielle Dokumentation bestätigt die genannten Wrapper-/OPSGROUP-Methoden. Ein offizielles Beispiel, das exakt folgenden Lifecycle demonstriert, wurde nicht gefunden:

```text
persistent AUFTRAG racetrack
+ SwitchEmission(false)
+ radar NEVER
-> same racetrack
+ radar CONTINUOUS SEARCH
+ SwitchEmission(true)
```

Daher ist das konkrete DCS-Verhalten bis Acceptance 3 `SOURCE_REVIEWED`, nicht `VALIDATED`.

## 5. Architekturentscheidung für Acceptance 3

Der physische Racetrack wird nicht mehr zum Dienstbeginn durch eine neue `AUFTRAG:NewAWACS(...)`-Mission ersetzt.

Stattdessen:

```text
APOC physical mission:
AUFTRAG:NewORBIT_RACETRACK(...)
FL320 / 300 kt / 017T / 30 NM
persistent through standby -> active transition
```

Vor Dienstbeginn:

```text
FLIGHTGROUP/OPSGROUP:SwitchEmission(false)
GROUP/CONTROLLABLE:SetOptionRadarUsingNever()
serviceState = STANDBY
sensorState = SILENT
```

Ab Dienstbeginn:

```text
GROUP/CONTROLLABLE:SetOptionRadarUsingForContinousSearch()
FLIGHTGROUP/OPSGROUP:SwitchEmission(true)
serviceState = ACTIVE
sensorState = EMITTING
```

Diese Umschaltung erzeugt keinen neuen Flugauftrag und besitzt keinen Mission-Egress-Punkt.

## 6. Egress-Grenze

`ROSIE` ist nicht länger `MissionEgressCoord` des APOC-Racetracks.

Nur ein echter physischer Abflug darf den Racetrack beenden:

```text
service sensor OFF
-> physical orbit MissionCancel
-> explicit FLIGHTGROUP:AddWaypoint(ROSIE, 440 kt, FL340)
-> external handoff
```

Damit wird verhindert, dass ein interner Dienstzustandswechsel unbeabsichtigt den Egress-Punkt anfliegt.

## 7. Acceptance-Grenze

Acceptance 3 muss in DCS belegen:

```text
- SILENT vor 15:30
- EMITTING ab 15:30
- derselbe PERSISTENT_RACETRACK vor/nach 15:30
- kein ROSIE-Detour bei Aktivierung
- RWR-Differenz vor/nach Aktivierung, soweit Empfänger/Geometrie dies unterstützen
- ROSIE erst nach explizitem Egress
```

Datalink bleibt Beobachtungswert und wird erst nach expliziter DCS-Evidenz als Funktion behauptet.

## 8. Nicht Teil dieser Änderung

Noch offen bleiben:

```text
fuel-state-basierter AAR-Trigger
Worst-case-Reichweite zum alternativen Tanker
nearest-compatible-tanker fallback
MOOSE FuelLow RTB policy für die E-3
vollständige 8-h-Abdeckung
```
