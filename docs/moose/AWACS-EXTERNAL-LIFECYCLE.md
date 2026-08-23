---
document_id: OMW-MOOSE-AWACS-EXTERNAL-LIFECYCLE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - DCS-validated MOOSE-first external E-3 routing lifecycle for the exact Acceptance-1 provenance
  - source-reviewed method boundary for AWACS ingress, orbit, egress and later AAR integration
not_authoritative_for:
  - complete AWACS production validation beyond the documented Acceptance-1 routing scope
  - historical 964th EAACS routing details not explicitly sourced
  - production AAR dispatch before dedicated acceptance
  - six-hour relief lifecycle, fuel calibration, loss and restart behavior before dedicated acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: bde8a6e8d006b7c8d744b739510b08aa9812d48b
validated_in_dcs: true
supersedes:
superseded_by:
---

# MOOSE – External E-3 AWACS Lifecycle

## 1. Entscheidung

OMW bildet den USAF-E-3-Einsatz als extern basiertes strategisches Asset ab. Al Dhafra ist ein logischer `CampaignState`-Knoten und kein DCS-`AIRBASE`/`AIRWING`.

Der physische MOOSE-Pfad lautet:

```text
CampaignState OFFMAP_AL_DHAFRA
-> SPAWN from external coordinate
-> FLIGHTGROUP transit
-> ROSIE FIR ingress
-> 30-NM late approach
-> AUFTRAG:NewAWACS(...)
-> APOC racetrack
-> AUFTRAG Cancel / mission egress
-> ROSIE FIR egress
-> external handoff
-> Despawn / CampaignState recredit
```

Dieser Routing-Lifecycle ist seit Acceptance 1 für den exakt dokumentierten Branch-/Commit-/MIZ-/Bundle-/DCS-/MOOSE-Stand praktisch bestätigt. Fuel, sechs Stunden Station Time, Relief, Loss/Restart und AWACS-AAR bleiben getrennte offene Acceptance-Blöcke.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Source-verifizierte und praktisch bestätigte Methoden

Im tatsächlich gepinnten `Moose.lua` geprüft:

```text
SPAWN:New(...)
SPAWN:InitCallSign(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)

FLIGHTGROUP:New(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:Refuel(...)
FLIGHTGROUP PassingWaypoint FSM / OnAfterPassingWaypoint(...)
FLIGHTGROUP Dead / OnAfterDead(...)
OPSGROUP / FLIGHTGROUP Despawn(...)

AUFTRAG:NewAWACS(Coordinate, Altitude, Speed, Heading, Leg)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

COORDINATE:NewFromLLDD(...)
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)

SCHEDULER:New(...)
```

`AUFTRAG:NewAWACS(...)` erzeugt im gepinnten Source einen Racetrack und setzt den DCS-MissionTask auf `AWACS`, ROE auf `WeaponHold` und Reaction on Threat auf `PassiveDefense`.

Wie beim validierten AAR-Racetrack besitzt der zugrunde liegende ORBIT-Pfad ein Default-`missionAltitude`-Verhalten von 90 Prozent der Orbit-Höhe. OMW setzt deshalb explizit:

```lua
mission:SetMissionAltitude(TRACK_ALTITUDE_FT)
```

Acceptance 1 bestätigte praktisch die Kette:

```text
SPAWN:SpawnFromCoordinate(...)
-> FLIGHTGROUP:AddWaypoint(ROSIE)
-> PassingWaypoint / OnAfterPassingWaypoint
-> FLIGHTGROUP:AddMission(AUFTRAG:NewAWACS(...))
-> APOC ON_STATION
-> AUFTRAG:Cancel() / SetMissionEgressCoord(ROSIE)
-> ROSIE outbound PassingWaypoint
-> FLIGHTGROUP:AddWaypoint(external handoff)
-> Despawn / recredit path
```

`FLIGHTGROUP:Refuel(...)` bleibt für AWACS lediglich source-reviewed; Acceptance 1 testete keine Luftbetankung.

## 4. Warum nicht die MOOSE-Klasse `AWACS`

Die umfangreiche MOOSE-`AWACS`-Klasse ist im gepinnten Stand ein eigener Air-Controller mit FEZ, Fighter-Control, SRS/TTS, eigener Shift-Change-Logik und Home-Airbase-Annahmen. Diese Verantwortungen passen nicht zum OMW-Ziel, zunächst nur den historischen physischen Afghanistan-E-3-Lifecycle abzubilden.

MOOSE-first bedeutet hier daher:

```text
AUFTRAG:NewAWACS
+ FLIGHTGROUP
+ SPAWN
+ CampaignState adapter
```

und nicht die Aktivierung eines funktional größeren Framework-Subsystems, dessen zusätzliche Verantwortungen OMW nicht angefordert hat.

Acceptance 1 bestätigt, dass dieser kleinere MOOSE-first-Pfad für Materialisierung, FIR-Transit, AWACS-Mission, Egress und External Handoff im getesteten Scope funktioniert. Es besteht damit für diesen Routing-Scope kein Anlass für eine Native-DCS- oder parallele AWACS-Implementierung.

## 5. Verbindliche Konfiguration

```text
Template:                 OMW_C2_E3A_WIZARD
Strategic source:         OFFMAP_AL_DHAFRA
Campaign resource:        AIRCRAFT_E3A_AWACS
OMW design stock:         2 (1 ACTIVE + max. 1 RELIEF)
External spawn:           N31°30'42.29" E069°13'47.32" approximately
FIR ingress/egress:       ROSIE
Primary AEW area:         APOC
Callsign family:          WIZARD
Primary DCS frequency:    357.300 MHz AM
Spawn altitude:           FL340
ROSIE->late approach:     transition toward FL350
Late approach:            30 NM before APOC
Track altitude:           FL320
Track speed:              300 kt
Track heading:            017°T
Track leg:                30 NM
Outbound cruise:          FL340 / 300 kt
Planned station cycle:    6 h
```

Die `FL320`-Trackhöhe ist die OMW-Ableitung aus Graveyards vorgeschlagenem `FL310/FL330`-Block und dessen ausdrücklicher Vorgabe eines einzelnen Flight Levels mit 1.000 ft Puffer oben und unten. Sie ist kein historischer Nachweis für den 964th-EAACS-Flug vom 26.11.2010.

Acceptance 1 bestätigt die Routing-Übergänge und die AWACS-Missionseinbindung. Die tatsächliche Einhaltung von `300 kt`, FL340/FL350/FL320 während des gesamten Profils sowie die reale 017°T/30-NM-Racetrack-Geometrie müssen noch mit eigener Telemetrie beziehungsweise visueller Beobachtung abgenommen werden.

## 6. Acceptance 1 – Routing-Lifecycle

```text
Testdatum:                2026-08-23
Branch:                   agent/awacs-external-lifecycle-foundation
Tested source commit:     bde8a6e8d006b7c8d744b739510b08aa9812d48b
Mission:                  OMW_Template_v19(8).miz
Mission SHA-256:          d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
DCS:                      2.9.28.26385 MT
Embedded Moose.lua SHA:   e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Warehouse SHA:   01a9ca70988198ecbd76f4d1cab4304261f2cc56911584b44741c0d49c7b146c
Embedded AWACS bundle SHA:639841a552343f4d0f7180f657a4a0b3141fb0b9af3ed6f1d9915ec955444fc2
dcs.log SHA-256:          593d02d455db0cae04cfd0e7651671d3af1d76ab430ff3232da7b19dac391c2f
debrief.log SHA-256:      32df4af4943f5ca3d2a98dde61e452054b5183fd21fa9f6b78750894ec106eb7
Result:                    PASS for routing lifecycle scope
```

Runtime-Reihenfolge des erfolgreichen Laufs:

```text
MATERIALIZED
-> FIR_INGRESS_PASSED ROSIE
-> LATE_APPROACH_PASSED / ADD_AWACS_MISSION
-> ON_STATION APOC
-> EGRESS_ORDERED
-> FIR_EGRESS_PASSED ROSIE
-> MOOSE Mission 3 [AWACS] success
-> EXTERNAL_HANDOFF / DESPAWN_AND_RECREDIT
```

Der zugehörige `dcs.log` enthält zusätzlich einen früheren fehlgeschlagenen Versuch aus demselben DCS-Prozess. Dieser scheiterte vor Materialisierung mit `unknown nodeId=OFFMAP_AL_DHAFRA`, weil noch ein älteres Warehouse-Bundle eingebettet war. Der spätere Acceptance-1-Lauf verwendet nachweislich das korrigierte eingebettete Warehouse-Bundle `01a9ca...b146c`. Der frühere Versuch bleibt Diagnoseevidenz und ist nicht Teil des PASS.

Vollständige Evidenz:

- [`AWACS External Lifecycle Acceptance`](../../mission/tests/awacs-external-lifecycle/ACCEPTANCE.md)

## 7. Relief

Die AAR-Acceptance-7-Grundsätze werden übernommen:

- maximal `1 ACTIVE + 1 RELIEF` physisch;
- Relief wird anhand sichtbarer Transitzeit rechtzeitig materialisiert;
- ETA armt keine vorzeitige Übergabe;
- Stationsbesitz wechselt erst bei physischer Ankunft am APOC-Track;
- der ausgehende E-3 erhält erst danach Egress;
- Verlust wird nicht recredited;
- External Handoff recredited genau einmal.

Diese Relief-Semantik ist für AWACS noch nicht DCS-validiert. Acceptance 1 prüfte nur einen kontrolliert ausgelösten Egress des einzelnen ACTIVE-Flugzeugs.

## 8. AAR-Grenze

Der gepinnte Source enthält `FLIGHTGROUP:Refuel(...)`. Die Methode pausiert eine laufende Mission und verwendet den DCS-Refuelling-Task; sie enthält jedoch keine OMW-Policy für die Auswahl eines bestimmten STANDARD-/RESERVE-Tankers.

Daher ist produktiv noch nicht freigegeben:

```text
AWACS -> arbitrary nearest tanker
```

Die Runtime gibt bis zur eigenen Acceptance bewusst `AWACS_AAR_DCS_ACCEPTANCE_REQUIRED` zurück.

Zu testen sind zwei zulässige Zielmodelle:

```text
A) E-3 verlässt APOC, geht auf Cruise-Profil, fliegt zu einem vorher ausgewählten Rendezvous,
   betankt und kehrt anschließend zu APOC zurück.

B) AAR MissionDemand bringt einen geeigneten Reserve-Tanker zu einem Rendezvous in AWACS-Nähe,
   so dass der E-3 seinen C2-Footprint möglichst wenig verlassen muss.
```

## 9. Fuel-Grenze

Das aktuelle Mission-Editor-Template enthält 65.000 kg Fuel. Eine öffentliche `SPAWN:InitFuel(...)`-Methode wird nicht angenommen. Wie bei AAR muss der reale DCS-Burn per Telemetrie kalibriert werden.

Vor Produktionsfreigabe fehlen mindestens:

- Burn External Spawn -> APOC;
- hourly station burn;
- Burn APOC -> External Handoff;
- Reservekomponente;
- FuelLow/AAR-Schwelle;
- Entscheidung, ob geplantes AAR oder Relief die reguläre Stationsdauer begrenzt.

## 10. Noch offene DCS-Acceptance

Acceptance 1 validiert nicht die gesamte Foundation. Offen bleiben mindestens:

```text
cruise altitude/speed telemetry
APOC racetrack heading/leg geometry
player-side WIZARD / 357.300 MHz service
fuel calibration
six-hour station cycle
scheduled relief and physical handover
loss settlement
restart reconciliation
AWACS AAR / designated tanker coordination
```

`VALIDATED` ist daher immer scope-bezogen zu lesen. Eine vollständige Produktionsfreigabe erfolgt erst nach den noch ausstehenden Acceptance-Blöcken.
