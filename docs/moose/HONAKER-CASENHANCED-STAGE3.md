---
document_id: OMW-MOOSE-HONAKER-CASENHANCED-STAGE3
status: PLANNED
document_class: MOOSE_TECHNICAL_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE CASENHANCED path for Honaker Stage 3 acceptance
  - Stage 3 acceptance-only CAS tactical-area and altitude configuration
not_authoritative_for:
  - general OMW CAS doctrine
  - DCS runtime validation
  - production-wide CAS engagement geometry
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Honaker Stage 3 – MOOSE CASENHANCED

## 1. Zweck

Dieses Dokument haelt den MOOSE-first Source-Review und die vom Projektinhaber am 31.08.2026 freigegebene Acceptance-Konfiguration fuer den Honaker-AH-64-Response fest.

Die Konfiguration gilt fuer den Stage-3-Acceptance-Fall und ist keine pauschale Projektentscheidung fuer alle CAS-Einsaetze.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 3. Source-verifizierte Signatur

Die tatsaechlich gepinnte `Moose.lua` definiert:

```lua
AUFTRAG:NewCASENHANCED(CasZone, Altitude, Speed, RangeMax, NoEngageZoneSet, TargetTypes)
```

Source-Kommentar und Implementierung belegen:

```text
CasZone      = CAS patrol/engagement zone
Altitude     = feet ASL; default 2000 ft ASL when not supplied by later mission logic
Speed        = knots
RangeMax     = maximum detected-target engagement range in NM
NoEngageZoneSet = optional no-engage zones
TargetTypes  = DCS target attributes; Ground Units is supported
```

Die Methode erzeugt `AUFTRAG.Type.CASENHANCED`, setzt `mission.missionTask`, ruft selbst `SetEngageDetected(RangeMax, TargetTypes, CasZone, NoEngageZoneSet)` auf, setzt ROE `OpenFire`, ROT `EvadeFire`, Missionsgeschwindigkeit und Missionshoehe und laesst die Gruppe die CAS-Zone zufaellig patrouillieren.

Damit ist `CASENHANCED` fuer den Honaker-Test konzeptionell geeigneter als der bisherige generische `NewCAS`-Orbit, der im letzten DCS-Lauf mit `10000 ft ASL` und der 1000-m-Alarmzone verdrahtet war.

## 4. Genehmigte Honaker-Acceptance-Konfiguration

Der Projektinhaber hat am 31.08.2026 bestaetigt:

```text
Tactical CAS area radius:       5 NM around Honaker
Combat height at zone center:   2500 ft AGL
Detected-target range:          5 NM
Mission type:                   AUFTRAG:NewCASENHANCED
```

Die Alarmzone bleibt separat:

```text
1000-m Honaker OPSZONE
= alarm/proximity evidence only

5-NM Honaker CAS tactical zone
= CASENHANCED patrol/engagement area
```

`OPSZONE Defeated` besitzt keine CAS-Completion-Autoritaet.

## 5. AGL-zu-ASL-Umrechnung fuer MOOSE

Da `NewCASENHANCED` die Missionshoehe in feet ASL erwartet, wird fuer den Acceptance-Harness keine feste ASL-Hoehe erfunden.

Der MOOSE-first Pfad lautet:

```text
Honaker COORDINATE:GetLandHeight()
-> terrain height in meters ASL
-> UTILS.MetersToFeet(...)
-> + 2500 ft
-> NewCASENHANCED altitude argument in feet ASL
```

Die 2500 ft sind damit die gewuenschte Hoehe ueber dem Terrain am Zentrum der Honaker-Tactical-Zone. Das ist keine Garantie fuer konstante 2500 ft AGL an jedem Punkt innerhalb des 5-NM-Gebiets; das reale DCS-Flugverhalten ist Acceptance-Gegenstand.

## 6. CAS-Lifecycle

Ein einzelner Schuss ist nur Ausfuehrungsevidenz:

```text
EVENTS.Shot
-> ConfirmExecutionEvidence(...)
-> MissionDemand remains ACTIVE
```

Erst der MOOSE-AUFTRAG-Abschluss darf bei vorhandener Ausfuehrungsevidenz den CAS-Demand erfolgreich abschliessen.

Damit wird der im letzten Test vorhandene Fehlvertrag beseitigt, bei dem der erste AH-64-Schuss bereits als erfolgreicher CAS-Abschluss behandelt werden konnte.

## 7. Official-example review

Die offiziellen MOOSE-Missionsrepositories wurden fuer einen direkten aktuellen `NewCASENHANCED`-Demoaufruf durchsucht. Fuer diese konkrete Methode wurde bei der aktuellen Recherche kein belastbarer offizieller Beispieltreffer gefunden.

Das ist keine API-Luecke: Signatur und Verhalten sind in der tatsaechlich gepinnten `Moose.lua` vorhanden und wurden direkt source-geprueft. Die fehlende konkrete Demo wird als Evidenzgrenze dokumentiert; Runtime-Verhalten bleibt DCS-testpflichtig.

Historische MOOSE-Hubschrauber-CAS-Demos wie `CAS-010 - CAS in a Zone by Helicopter` belegen zwar grundsaetzlich niedrige helicopter-spezifische CAS-Profile, verwenden aber einen aelteren `AI_CAS_ZONE`-Pfad und werden nicht als API-Beweis fuer `AUFTRAG:NewCASENHANCED` verwendet.

## 8. WEST-Route und reale AGL-Telemetrie

Der gemeinsame `OMW_HelicopterFlightPathCorridor` bleibt fuer den Transit zustaendig:

```text
OMW_FlightPath       500 ft AGL
OMW_FlightPath_WEST  2500 ft AGL / RADIO / Column.D70
```

Ab Schema `OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-7` protokolliert der `OnAfterPassingWaypoint`-Pfad eventgebunden:

```text
uid
pathline
requestedAglFt
actualAglFt
actualAslFt
terrainFt
```

Verwendete MOOSE-Methoden:

```lua
OPSGROUP:GetCoordinate(true)
COORDINATE:GetLandHeight()
UTILS.MetersToFeet(...)
```

Es wird kein hochfrequenter Scheduler und kein nativer Frame-Scanner eingefuehrt.

## 9. DCS-Acceptance-Grenze

Noch nicht validiert:

```text
CASENHANCED physical dispatch with the actual Jalalabad AH-64 squadron
5-NM tactical-area patrol behavior
repeated attacks against surviving RED groups
weapon-selection/effectiveness against the Honaker infantry force
terrain+2500-ft mission-altitude behavior
actual WEST 2500-ft AGL adherence from waypoint telemetry
MOOSE CASENHANCED mission completion after tactical cleanup
```

Bis zum realen DCS-Lauf bleibt `validated_in_dcs: false`.