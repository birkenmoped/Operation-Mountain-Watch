---
document_id: OMW-MOOSE-AWACS-EXTERNAL-LIFECYCLE
status: SOURCE_REVIEWED_STAGED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - staged MOOSE-first external E-3 physical lifecycle
  - source-reviewed method boundary for AWACS ingress, orbit, egress and later AAR integration
not_authoritative_for:
  - DCS runtime validation
  - historical 964th EAACS routing details not explicitly sourced
  - production AAR dispatch before dedicated acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
validated_in_dcs: false
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

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Source-verifizierte Methoden

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

## 5. Verbindliche Staging-Konfiguration

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

`300 kt`, der 30-NM-Late-Approach und der 6-h-Stationszyklus sind OMW-Planungswerte und müssen in DCS validiert werden.

## 6. Relief

Die AAR-Acceptance-7-Grundsätze werden übernommen:

- maximal `1 ACTIVE + 1 RELIEF` physisch;
- Relief wird anhand sichtbarer Transitzeit rechtzeitig materialisiert;
- ETA armt keine vorzeitige Übergabe;
- Stationsbesitz wechselt erst bei physischer Ankunft am APOC-Track;
- der ausgehende E-3 erhält erst danach Egress;
- Verlust wird nicht recredited;
- External Handoff recredited genau einmal.

## 7. AAR-Grenze

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

## 8. Fuel-Grenze

Das aktuelle Mission-Editor-Template enthält 65.000 kg Fuel. Eine öffentliche `SPAWN:InitFuel(...)`-Methode wird nicht angenommen. Wie bei AAR muss der reale DCS-Burn per Telemetrie kalibriert werden.

Vor Produktionsfreigabe fehlen mindestens:

- Burn External Spawn -> APOC;
- hourly station burn;
- Burn APOC -> External Handoff;
- Reservekomponente;
- FuelLow/AAR-Schwelle;
- Entscheidung, ob geplantes AAR oder Relief die reguläre Stationsdauer begrenzt.

## 9. Acceptance

Verbindlicher Testplan für diesen Staging-Scope:

- [`AWACS External Lifecycle Acceptance`](../../mission/tests/awacs-external-lifecycle/ACCEPTANCE.md)

Kein `VALIDATED` ohne dokumentierten DCS-Lauf mit Mission-, Bundle-, Commit- und MOOSE-Provenienz.