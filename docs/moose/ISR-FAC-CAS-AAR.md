---
document_id: OMW-MOOSE-ISR-FAC-CAS-AAR
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE-based ISR, contact, FAC/JTAC, CAS, strike, BDA and AAR integration
  - separation of sensing, decision, tasking, designation and effects
  - current MOOSE AAR runtime boundaries and integration rules
not_authoritative_for:
  - active ORBAT or mission-specific ROE
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier AAR section without current runtime evidence
superseded_by:
source_branch: main
source_commit: 413b26377c0175abffde72aad03ea55f1d3e80d3
validated_in_dcs: partial
---

# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status

```text
PLANNED – vollständige ISR/FAC/CAS-Kette noch nicht akzeptiert
AAR – Kernmechanik für den dokumentierten DCS-/MOOSE-Stand praktisch bestätigt
```

Fachliche Grundlagen:

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](../45-air-c2-cas-afghanistan.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](../48-afghanistan-no-strike-list.md)
- [`OMW-AAR-ISAF-ACO`](../29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md)

## 2. Funktionsschichten

```text
Sensor und Beobachtung
-> Kontakt-/Intelligence-Modell
-> Zielentwicklung und Entscheidung
-> Spieler- oder KI-Auftrag
-> Markierung / Koordinatenübergabe
-> Wirkung
-> Battle Damage Assessment
-> CampaignState-Folge
```

Kein einzelner FAC-, FACA-, CAS- oder AUFTRAG-Typ bildet automatisch die gesamte Kette ab.

## 3. Vorrangige MOOSE-Bausteine

- `INTEL`, `DETECTION` und Sets für Kontakte und Lagebild;
- `TARGET` für standardisierte Zielobjekte;
- `PLAYERRECCE` für Spieleraufklärung;
- `DESIGNATE` für Laser, Rauch, IR und Koordinatenübergabe;
- `PLAYERTASK` für Spieleraufträge;
- `AUFTRAG` für KI-Missionen;
- `COMMANDER`, `AIRWING`, `SQUADRON` und `FLIGHTGROUP` für Assetauswahl und Ausführung;
- für AAR insbesondere `AUFTRAG:NewTANKER`, `AIRWING`, `FLIGHTGROUP`, `COORDINATE`, `SPAWN` und `OPSGROUP`.

## 4. Verbindliche Architekturgrenzen

- Sensor, Entscheidung und Shooter besitzen getrennte Zustände.
- Spieler und KI arbeiten auf demselben Kontakt-, Ziel- und MissionDemand-Objekt.
- Unzureichende Identifikation, NSL-Konflikt oder fehlende Autorität blockieren Tasking beziehungsweise Wirkung.
- Zielbewegung und neue Koordinaten lösen eine erneute Targeting-Prüfung aus.
- BDA verändert CampaignState erst nach validierter Wirkung.
- Bewaffnete UAVs dürfen Aufklärung und Wirkung nur nach expliziter Rollen- und Freigabeentscheidung verbinden.
- `CampaignState` bleibt strategische Ressourcenautorität; AIRWING/AUFTRAG materialisieren nur physische Missionsrepräsentationen.

## 5. AAR – gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsächlich verwendeten `Moose.lua` source-reviewed:

- `AUFTRAG:NewTANKER(Coordinate, Altitude, Speed, Heading, Leg, RefuelSystem)`;
- `AUFTRAG:SetRadio(...)`;
- `AUFTRAG:SetTACAN(...)`;
- `AUFTRAG:SetMissionEgressCoord(...)`;
- `AIRWING:AddMission(...)`;
- `AIRWING:GetTankerForFlight(...)`;
- `FLIGHTGROUP:Refuel(Coordinate)`;
- `FLIGHTGROUP:GetFuelMin()`;
- `FLIGHTGROUP:SetFuelLowThreshold(...)`;
- `FLIGHTGROUP:SetFuelLowRTB(...)`;
- `COORDINATE:Get2DDistance(...)`;
- `COORDINATE:Get3DDistance(...)`;
- `OPSGROUP:Despawn(...)`.

## 6. Receiver-zu-Tanker-Auswahl

`AIRWING:GetTankerForFlight(flightgroup)` filtert aktive Tanker zunächst nach kompatiblem Refuelling-System und sortiert anschließend nach 2D-Distanz. Eine OMW-spezifische FAST/SLOW-Klasse ist dort nicht vorhanden.

`FLIGHTGROUP:Refuel(Coordinate)` pausiert die aktuelle Mission, erzeugt `TaskRefueling()` und routet den Receiver zu einem Refuel-Waypoint. Dieser öffentliche Pfad bindet keine konkrete Tanker-ID. Die DCS-Aufgabe refuelt beim nächstgelegenen kompatiblen Tanker.

Daraus folgt MOOSE-first:

```text
MissionDemand
-> Operationsraum + Receiver-Profil
-> OMW wählt AAR-Area und FAST/SLOW-Profil
-> AIRWING/AUFTRAG materialisiert den dafür vorgesehenen Tanker
-> FLIGHTGROUP:Refuel() routet den Receiver zum vorgesehenen Refuel-Waypoint
```

Der COMMANDER darf die OMW-Rollenentscheidung nicht durch eine implizite Near-Tanker-Auswahl ersetzen. Die produktive Steuerung erfolgt durch Area-/Profilwahl und räumliche Trennung. Ein nativer DCS-Donor-Override ist nicht genehmigt.

Acceptance-6 zeigte zugleich die Grenze der nachträglichen Donor-Inferenz: A-10 und F-16 lieferten die erwartete räumliche Zuordnung, die F-15E-Proximity-Inferenz dagegen nicht. Der F-15E wurde dennoch tatsächlich betankt. Eine 3D-Nähe ist deshalb keine belastbare Donor-ID.

## 7. FuelLow und externer Egress

`FLIGHTGROUP:New()` setzt im gepinnten Stand standardmäßig:

```text
FuelLow threshold = 25 %
FuelLow RTB = true
```

`FLIGHTGROUP` prüft den minimalen Gruppenfuel und löst bei Unterschreiten der Schwelle `FuelLow` aus. `onafterFuelLow` kann anschließend RTB auslösen, falls `fuellowrtb` aktiv ist.

Für externe OMW-Tanker gilt deshalb:

```text
SetFuelLowRTB(false)
```

Der Tanker soll nicht zu einer nicht existierenden externen DCS-Homebase zurückkehren, sondern:

```text
realer produktiver Low-Fuel-/Bingo-Schwellwert
-> FuelLow
-> AUFTRAG Cancel / Egress
-> hoher Transit zum External Gate
-> kontrollierter Off-map-Handoff
```

Die in Acceptance-1 bis -6 verwendeten beschleunigten Schwellen bis 99 % waren ausschließlich Testmechanik. Sie dürfen nicht in produktiven Code übernommen werden.

Die endgültige produktive Schwelle wird aus benötigter Egress-/Off-map-Reserve abgeleitet. Bis diese Berechnung abgeschlossen ist, wird kein neuer künstlicher Schwellenwert erfunden.

## 8. Acceptance-6 – bestätigter AAR-Kernpfad

```text
Testdatum: 2026-08-14
Branch: agent/aar-rc-east-runtime-scope
Source/Builder commit: 29dbcd377603405292a2f37a682d6f6b5b19dcf8
Bundle SHA-256: 354433730acd0fc1eee4a3fe817cfaa870a054f3374dfab85f9814edfd29b091
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: 39da8370753e3ece055f0fd9f9dcc5dbeed2aa2eebe4540756931944f200963b
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Praktisch bestätigt:

- fünf KC-135 gleichzeitig als isolierte Stress-Test-Ausnahme;
- alle fünf Tanker `EXECUTING`;
- SLOW/FAST Same-area mit 3.000 ft vertikaler Staffelung;
- A-10C Boom-AAR;
- F-15E Boom-AAR;
- F-16C Boom-AAR;
- Post-Refuel-Dwell;
- FuelLow/Cancel/Egress/Off-map-Handoff als Mechanik.

Nicht bestätigt bzw. verworfen:

- C-130J als AAR-Receiver; die Annahme war fachlich falsch und wird aus der Receiver-Matrix entfernt;
- deterministische Donor-ID über Proximity-Telemetrie.

Die fünf Tanker bleiben eine Testausnahme. Produktiv gilt weiterhin:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

## 9. Keine weiteren isolierten AAR-Mechaniktests

Für denselben gepinnten DCS-/MOOSE-Stand besteht kein zusätzlicher allgemeiner Acceptance-Bedarf für Spawn, Orbit, Boom-AAR, FAST/SLOW, Funk/TACAN, Five-tanker-Stress oder Egress-Mechanik.

Erneute DCS-Prüfung wird erst erforderlich, wenn:

- produktive MissionDemand-/COMMANDER-Integration erstmals ausgeführt wird;
- relevante Lifecycle-Logik geändert wird;
- MOOSE/DCS-Version oder Missionsbaseline wechselt;
- neue Receiver-/Tanker-Systeme hinzukommen.

Das ist Integrations-/Regressionstest, kein weiterer AAR-Grundlagentest.

## 10. Noch offene produktive Integration

- MissionDemand-Felder und Area-/FAST-/SLOW-Mapping;
- sechs Core-Areas gemäß Dokument 29;
- hohe Ingress-/Egress-Transitprofile mit ausreichender Terrainreserve;
- produktive Low-Fuel-/Bingo-Reserve je Origin/Area;
- CampaignState-/Off-map-Recovery-Abrechnung;
- Multiplayer-/Persistenzprüfung erst zusammen mit der produktiven Integration.
