---
document_id: OMW-MOOSE-ISR-FAC-CAS-AAR
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE-based ISR, contact, FAC/JTAC, CAS, strike, BDA and AAR integration
  - separation of sensing, decision, tasking, designation and effects
not_authoritative_for:
  - DCS runtime acceptance
  - active ORBAT or mission-specific ROE
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - PLANNED used only as prose status without governance metadata
superseded_by:
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status

```text
PLANNED – noch nicht als vollständige Laufzeitkette in DCS akzeptiert
```

Der vollständige frühere Architekturentwurf mit Klassenmatrix bleibt erhalten:

- [`Legacy-ISR-/FAC-/CAS-/AAR-Architektur`](../evidence/source-records/legacy-moose-isr-fac-cas-aar.md)

Fachliche Grundlage:

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](../45-air-c2-cas-afghanistan.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](../48-afghanistan-no-strike-list.md)
- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md)

## 2. Funktionsschichten

```text
Sensor und Beobachtung
→ Kontakt-/Intelligence-Modell
→ Zielentwicklung und Entscheidung
→ Spieler- oder KI-Auftrag
→ Markierung / Koordinatenübergabe
→ Wirkung
→ Battle Damage Assessment
→ CampaignState-Folge
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
- Tanker-/AAR-Funktionen gemäß gepinntem MOOSE-Stand.

## 4. Verbindliche Architekturgrenzen

- Sensor, Entscheidung und Shooter besitzen getrennte Zustände.
- Spieler und KI arbeiten auf demselben Kontakt-, Ziel- und MissionDemand-Objekt.
- Unzureichende Identifikation, NSL-Konflikt oder fehlende Autorität blockieren Tasking beziehungsweise Wirkung.
- Zielbewegung und neue Koordinaten lösen eine erneute Targeting-Prüfung aus.
- BDA verändert CampaignState erst nach validierter Wirkung.
- Bewaffnete UAVs dürfen Aufklärung und Wirkung nur nach expliziter Rollen- und Freigabeentscheidung verbinden.

## 5. AAR – source-reviewed MOOSE-Stand

Geprüfter MOOSE-Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Status: SOURCE_REVIEWED, nicht DCS-validiert für OMW-Tankerbetrieb
```

Der tatsächlich verwendete `Moose.lua` enthält die für die OMW-Tankerfoundation benötigten öffentlichen Pfade:

- `AUFTRAG:NewTANKER(Coordinate, Altitude, Speed, Heading, Leg, RefuelSystem)` erzeugt eine Tankermission mit Racetrack- oder Circle-Orbit; `RefuelSystem` dient der AIRWING-Auswahl des passenden Tankertyps.
- `AUFTRAG:SetRadio(Frequency, Modulation)` setzt missionsbezogene Frequenz und Modulation; ohne explizite Modulation ist der dokumentierte Standard AM.
- `AUFTRAG:SetTACAN(Channel, Morse, UnitName, Band)` setzt den missionsbezogenen TACAN-Beacon; bei Aircraft ist laut API-Dokumentation Y der Standardbandpfad, sofern kein Band explizit gesetzt wird.
- `AIRWING:CheckTANKER()` trennt Boom- und Probe/Drogue-Missionen anhand des `RefuelSystem` und erzeugt entsprechende `AUFTRAG:NewTANKER()`-Missionen.
- `AIRWING:GetTankerForFlight()` filtert verfügbare Tanker nach kompatiblem Refuelling-System und Entfernung.
- `COMMANDER:AddTankerZone(...)` ist vorhanden, erzeugt jedoch ein eigenes zonenbasiertes Tanker-Management. Für OMW bleibt offen, ob dieses automatische Zonenmodell gegenüber den bereits festgelegten AAR-Areas und dem CampaignState-/MissionDemand-gesteuerten Aktivierungsmodell verwendet werden soll.
- `CALLSIGN.Tanker` enthält im gepinnten Quellstand mindestens `Texaco`, `Arco`, `Shell`, `Navy_One`, `Mauler` und `Bloodhound`. Für den aktuellen KC-135-Plan werden zunächst DCS-native Projektzuweisungen aus `Texaco`, `Arco` und `Shell` verwendet; sie sind keine historischen Callsign-Behauptungen.

Für den aktuellen OMW-Runtime-Scope sind in `data/air-operations/aar/omw-2011-aar-tanker-planning.csv` die aktiven Boom-Netze mit `AM` als **Projektzuweisung** eingetragen. Das beweist noch nicht das tatsächliche DCS-Funk-/TACAN-Verhalten; Multiplayer-, Empfänger-, Frequenz- und TACAN-Verhalten bleiben Acceptance-Punkte.

Der MOOSE-First-Befund spricht damit gegen eine eigene parallele Orbit-, Funk- oder TACAN-Implementierung. Eigene OMW-Logik soll sich auf die noch projektspezifischen Teile beschränken: Auswahl der AAR-Area, External-Origin-/Gate-Modell, initialer Fuelzustand, CampaignState-/MissionDemand-Entscheidung sowie der sichere RTB-/Egress-Zeitpunkt.

## 6. Acceptance-Bedarf

- Kontaktentstehung, Trackverlust und Wiedererkennung;
- Spieler-Recon und KI-ISR;
- FAC/JTAC/AFAC-Markierung und Übergabe;
- Spieler-/KI-Tasking ohne Doppelauftrag;
- CAS, Strike und bewaffnete UAV-Ausführung;
- NSL-, ROE- und C2-Abbruch;
- BDA und CampaignState-Rückmeldung;
- AAR-Orbits, Tankerzuweisung und Funk/TACAN;
- AAR-Initialfuel, Track-Exit-/RTB-Schwelle und off-map Origin/Gate-Modell;
- Multiplayer-, Persistenz- und Missionsneustarttests.
