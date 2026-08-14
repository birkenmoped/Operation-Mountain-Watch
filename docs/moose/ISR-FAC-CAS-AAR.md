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

### 5.1 Fuel-Überwachung und RTB

Der gepinnte Quellstand enthält bereits die wesentlichen öffentlichen FLIGHTGROUP-Funktionen für eine fuel-gesteuerte Rückzugsentscheidung:

- `FLIGHTGROUP:GetFuelMin()` liefert den relativen Fuelbestand des Gruppenmitglieds mit dem niedrigsten Fuelwert in Prozent.
- `FLIGHTGROUP:SetFuelLowThreshold(percent)` setzt eine prozentuale Low-Fuel-Schwelle und löst das MOOSE-Event `FuelLow` aus.
- `FLIGHTGROUP:SetFuelLowRTB(true)` veranlasst bei `FuelLow` den normalen MOOSE-RTB-Pfad zur Destination-/Home-Airbase.
- `FLIGHTGROUP:IsFuelLow()` und `IsFuelCritical()` stellen den FSM-Zustand lesbar bereit.

Damit muss OMW **keinen eigenen Fuel-Polling- oder Schwellenmechanismus** parallel zu MOOSE bauen. Der normale `SetFuelLowRTB()`-Pfad ist für externe Tanker jedoch nicht direkt das gewünschte Endmodell: Manas beziehungsweise Al Udeid liegen außerhalb der DCS-Afghanistan-Kartenmission. Der OMW-Lifecycle soll den Tanker deshalb bei Erreichen der planungsabhängigen Schwelle zunächst aus der AAR-Area zu seinem festgelegten Egress-Gate führen und dort kontrolliert aus der physischen Simulation entfernen; der restliche Heimflug wird off-map simuliert. Der passende öffentliche MOOSE-Routing-/Mission-Ende-Pfad für diesen Gate-Egress ist noch separat source-review-pflichtig.

Die aktuellen Schwellen von 20–27 Prozent sind area- und originabhängige OMW-Planungswerte. Sie dürfen über `SetFuelLowThreshold()` genutzt werden, sobald das tatsächliche DCS-KC-135-Fuelverhalten den Planungsansatz bestätigt hat.

### 5.2 Initial Fuel beim Air-Spawn

Der gepinnte `SPAWN`-Quellstand zeigt, dass Air-Spawns aus dem Mission-Editor-/Spawn-Template erzeugt werden und dass das DCS-Unit-Template den Fuelbestand als `payload.fuel` trägt. Im geprüften öffentlichen SPAWN-API-Pfad wurde **kein separater `SPAWN:InitFuel(percent)`-Setter nachgewiesen**.

Daraus folgt noch keine Freigabe für eine direkte Template-Manipulation. Vor Implementierung ist zu klären, wie der produktive AIRWING-/WAREHOUSE-Assetpfad den im Seed-Template gespeicherten Fuelwert beim Air-Spawn übernimmt und ob die benötigten zwei Initialzustände von aktuell 96 Prozent (Manas/NE) beziehungsweise 90 Prozent (Southwest Asia/S) ohne parallele native DCS-Spawnlogik abgebildet werden können.

Bis dieser Pfad geklärt und in DCS geprüft ist, bleiben `initial_fuel_pct` und `initial_fuel_lb` **Planungsdaten** und keine behauptete Runtime-Garantie.

### 5.3 Offizielle MOOSE-Demos

Die offizielle MOOSE-Demonstrationssammlung `MOOSE_MISSIONS_UNPACKED` wurde für den Tankerpfad geprüft. Sie enthält einen eigenen Bereich `OPS - Recovery Tanker`; dieser demonstriert MOOSE-Spawning, Funk, TACAN, Callsign und fuel-gesteuertes RTB/Respawn für den carrierbezogenen `RECOVERYTANKER`.

`RECOVERYTANKER` ist für den landbasierten OMW-Theater-Tanker **keine Zielarchitektur**, weil OMW bereits AIRWING/AUFTRAG und externe Origins/Gates verwendet. Die Demo ist nur zusätzlicher Framework-Nachweis für die vorhandenen MOOSE-Muster. Eine gezielte Suche in der offiziellen Demo-Sammlung hat bislang keinen gleichwertigen landbasierten OMW-artigen `AIRWING + AUFTRAG:NewTANKER + external gate`-Beispielpfad ergeben; deshalb wird daraus keine Runtime-Validierung abgeleitet.

Für den aktuellen OMW-Runtime-Scope sind in `data/air-operations/aar/omw-2011-aar-tanker-planning.csv` die aktiven Boom-Netze mit `AM` als **Projektzuweisung** eingetragen. Das beweist noch nicht das tatsächliche DCS-Funk-/TACAN-Verhalten; Multiplayer-, Empfänger-, Frequenz- und TACAN-Verhalten bleiben Acceptance-Punkte.

Der MOOSE-First-Befund spricht damit gegen eine eigene parallele Orbit-, Funk-, TACAN- oder Fuel-Schwellenimplementierung. Eigene OMW-Logik soll sich auf die noch projektspezifischen Teile beschränken: Auswahl der AAR-Area, External-Origin-/Gate-Modell, initialer Fuelzustand, CampaignState-/MissionDemand-Entscheidung sowie der sichere Egress-Zeitpunkt und die off-map Recovery-Bilanz.

### 5.4 Acceptance-Concurrency

Die verbindliche Air-Ops-Architektur setzt missionsweit:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der AAR-Acceptance-Harness prueft deshalb drei Tankerpfade gestaffelt in einem DCS-Lauf statt drei gleichzeitige Tankermissionen zu starten:

```text
initial: CLANCY + NELSON
CLANCY FuelLow/CANCEL -> HOMER start
```

Damit bleiben maximal zwei Tanker-`AUFTRAG` gleichzeitig ausfuehrend. Ein bereits abgebrochener Clancy-Auftrag darf waehrend des Egress noch ein physisch aktives Flugzeug hinterlassen; mit Nelson und dem danach gestarteten Homer bleiben dabei maximal drei Supportluftfahrzeuge physisch vorhanden und damit unter der globalen Vier-Luftfahrzeug-Obergrenze. Dieses Verhalten ist noch im Owner-DCS-Test zu bestaetigen.

## 6. Acceptance-Bedarf

- Kontaktentstehung, Trackverlust und Wiedererkennung;
- Spieler-Recon und KI-ISR;
- FAC/JTAC/AFAC-Markierung und Übergabe;
- Spieler-/KI-Tasking ohne Doppelauftrag;
- CAS, Strike und bewaffnete UAV-Ausführung;
- NSL-, ROE- und C2-Abbruch;
- BDA und CampaignState-Rückmeldung;
- AAR-Orbits, Tankerzuweisung und Funk/TACAN;
- AIRWING-/WAREHOUSE-Übernahme des geplanten Initial-Fuelwerts beim Air-Spawn;
- `GetFuelMin()`-/`FuelLow`-Verhalten des KC-135 unter tatsächlichem Offload;
- Track-Exit-/Egress-Verhalten bei area-spezifischer Fuel-Schwelle;
- gestaffelte Clancy/Nelson/Homer-Aktivierung innerhalb der Support-Concurrency-Grenze;
- off-map Origin-/Recovery-Bilanz;
- Multiplayer-, Persistenz- und Missionsneustarttests.
