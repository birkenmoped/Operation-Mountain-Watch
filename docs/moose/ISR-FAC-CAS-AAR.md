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

Damit muss OMW **keinen eigenen Fuel-Polling- oder Schwellenmechanismus** parallel zu MOOSE bauen. Der normale `SetFuelLowRTB()`-Pfad ist für externe Tanker jedoch nicht direkt das gewünschte Endmodell: Manas beziehungsweise Al Udeid liegen außerhalb der DCS-Afghanistan-Kartenmission. Der OMW-Lifecycle soll den Tanker deshalb bei Erreichen der planungsabhängigen Schwelle zunächst aus der AAR-Area zu seinem festgelegten Egress-Gate führen und dort kontrolliert aus der physischen Simulation entfernen; der restliche Heimflug wird off-map simuliert.

Für diesen Gate-Egress sind im gepinnten Quellstand zusätzlich source-reviewed:

- `FLIGHTGROUP:GetCoordinate()` beziehungsweise der geerbte OPSGROUP-Koordinatenpfad für die aktuelle Gruppenposition;
- `COORDINATE:Get2DDistance(...)` für die Distanz zum Egress-Gate;
- `OPSGROUP:Despawn(Delay, NoEventRemoveUnit)` für die physische Entfernung nach bestätigtem Gate-Eintritt. Mit `NoEventRemoveUnit=true` werden dabei keine normalen `Remove Unit`-Events erzeugt; damit wird im isolierten Acceptance-Harness kein Warehouse-/Legion-Rücklauf vorgetäuscht.

Die aktuellen produktiven Schwellen von 20–27 Prozent sind area- und originabhängige OMW-Planungswerte. Sie dürfen über `SetFuelLowThreshold()` genutzt werden, sobald das tatsächliche DCS-KC-135-Fuelverhalten den Planungsansatz bestätigt hat.

### 5.2 Initial Fuel beim Air-Spawn

Der gepinnte `SPAWN`-Quellstand zeigt, dass Air-Spawns aus dem Mission-Editor-/Spawn-Template erzeugt werden und dass das DCS-Unit-Template den Fuelbestand als `payload.fuel` trägt. Im geprüften öffentlichen SPAWN-API-Pfad wurde **kein separater `SPAWN:InitFuel(percent)`-Setter nachgewiesen**.

Der erste AAR-Runtime-Lauf am 14.08.2026 zeigte nach abgeschlossener FLIGHTGROUP-Initialisierung plausible 90-/96-Prozent-Werte; ein unmittelbar nach `FLIGHTGROUP:New()` vorgenommener Readback lieferte dagegen `inf`. Das ist für die Seed-Fuel-Bewertung ein Timingproblem des Acceptance-Harness. `AAR-KC135-RUNTIME-ACCEPTANCE-2` verschiebt den positiven Seed-Fuel-Nachweis deshalb in die zyklische MOOSE-Telemetrie und akzeptiert keinen nichtendlichen Wert als PASS.

Der produktive AIRWING-/WAREHOUSE-Assetpfad für diese Seed-Fuelwerte bleibt gesondert zu validieren. Die bisherigen SPAWN-Ergebnisse ersetzen diese Prüfung nicht.

### 5.3 Offizielle MOOSE-Demos

Die offizielle MOOSE-Demonstrationssammlung `MOOSE_MISSIONS_UNPACKED` wurde für den Tankerpfad geprüft. Sie enthält einen eigenen Bereich `OPS - Recovery Tanker`; dieser demonstriert MOOSE-Spawning, Funk, TACAN, Callsign und fuel-gesteuertes RTB/Respawn für den carrierbezogenen `RECOVERYTANKER`.

`RECOVERYTANKER` ist für den landbasierten OMW-Theater-Tanker **keine Zielarchitektur**, weil OMW bereits AIRWING/AUFTRAG und externe Origins/Gates verwendet. Die Demo ist nur zusätzlicher Framework-Nachweis für die vorhandenen MOOSE-Muster. Eine gezielte Suche in der offiziellen Demo-Sammlung hat bislang keinen gleichwertigen landbasierten OMW-artigen `AIRWING + AUFTRAG:NewTANKER + external gate`-Beispielpfad ergeben; deshalb wird daraus keine Runtime-Validierung abgeleitet.

Für den aktuellen OMW-Runtime-Scope sind in `data/air-operations/aar/omw-2011-aar-tanker-planning.csv` die aktiven Boom-Netze mit `AM` als **Projektzuweisung** eingetragen. Das beweist noch nicht das tatsächliche DCS-Funk-/TACAN-Verhalten; Multiplayer-, Empfänger-, Frequenz- und TACAN-Verhalten bleiben Acceptance-Punkte.

Der MOOSE-First-Befund spricht damit gegen eine eigene parallele Orbit-, Funk-, TACAN- oder Fuel-Schwellenimplementierung. Eigene OMW-Logik soll sich auf die noch projektspezifischen Teile beschränken: Auswahl der AAR-Area, External-Origin-/Gate-Modell, initialer Fuelzustand, CampaignState-/MissionDemand-Entscheidung sowie der sichere Egress-Zeitpunkt und die off-map Recovery-Bilanz.

### 5.4 Acceptance-Concurrency und Retest

Die verbindliche Air-Ops-Architektur setzt missionsweit:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der erste AAR-Acceptance-Lauf vom 14.08.2026 verwendete nur Clancy/Nelson gleichzeitig und schaltete Homer später zu. Seine beschleunigten FuelLow-Schwellen lagen jedoch bereits während des Transits nur einen Prozentpunkt unter dem Seed-Fuel. Dadurch wurden die Aufträge vor `EXECUTING` abgebrochen; die fehlenden Racetracks sind daher **kein negativer MOOSE-Nachweis**, sondern eine ungültige Testbedingung für diesen Teil der Acceptance.

Für `AAR-KC135-RUNTIME-ACCEPTANCE-2` hat der Projektinhaber am 14.08.2026 ausdrücklich einen **isolierten Test mit allen fünf vorbereiteten Tankern gleichzeitig** freigegeben. Diese Freigabe ist eine Testausnahme für Concurrency-/Performance- und AAR-Lifecycle-Evidenz. Sie ändert die produktive Grenze von zwei Supportmissionen nicht.

Der Retest hält FuelLow während des Transits auf 20 Prozent, verlangt zunächst `EXECUTING` für alle fünf Tanker und anschließend 180 Sekunden gemeinsame `EXECUTING`-Zeit. Erst danach wird für den Acceptance-Zweck die Schwelle auf 99 Prozent angehoben. Nach `FuelLow -> AUFTRAG:Cancel()` wird die Distanz zum zugewiesenen Egress-Gate beobachtet; innerhalb von 10 NM erfolgt der testweise `OPSGROUP:Despawn(1, true)` als physischer Off-map-Handoff. CampaignState wird dabei noch nicht verändert.

Die dabei geloggten Fuelwerte an Track-Entry, FuelLow und Egress-Gate sowie die Zeitstempel sollen die nächste belastbare Grundlage für die spätere Off-map-/CampaignState-Fuelbilanz liefern.

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
- kontrollierter physischer Off-map-Handoff am Egress-Gate;
- Five-tanker Concurrency-/Performancebefund als isolierte Testevidenz, nicht als Produktionsgrenze;
- off-map Origin-/Recovery-Bilanz und spätere CampaignState-Abrechnung;
- Multiplayer-, Persistenz- und Missionsneustarttests.
