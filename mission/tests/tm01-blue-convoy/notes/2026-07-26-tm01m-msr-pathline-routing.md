# TM01M – Umstellung auf MSR-PATHLINE-Routing und straßengerechten Spawn

Datum: 26. Juli 2026  
Status: `30-km/h-Baseline DCS PASS`; `40-km/h-Regressionslauf AUSSTEHEND`

## Ausgangslage

Der DCS-Lauf mit `TM01M-moose-native-physical-3` war nur technisch teilweise erfolgreich:

```text
event=convoy_spawned
spawnZoneName=ZONE_TM01_START_BAGRAM
spawnX=124758
spawnY=271265

event=convoy_route_started
routeMode=MOOSE_TaskGroundOnRoad
anchorCount=7
waypointCount=21
```

Damit waren Spawnaufruf und Routenzuweisung nachweisbar. Das sichtbare Verhalten erfüllte die fachlichen Anforderungen jedoch nicht:

1. Der erste Unit-Slot erschien am Mittelpunkt der Startzone; die unveränderte Templateformation wurde ohne Anpassung an Straße und lokale Marschrichtung versetzt. Weitere Fahrzeuge standen deshalb neben der Straße oder kollidierten mit Szenerieobjekten. Ein Fahrzeug erschien auf einem Hallendach.
2. Der Konvoi fuhr nur bis in den Bereich der historischen `ZONE_TM01_ROUTE_01` und setzte die Gesamtfahrt nach Jalalabad nicht fort.

Im selben Lauf registrierte die gepinnte MOOSE-Fassung bereits die vorhandenen Mission-Editor-Zeichnungen:

```text
MSR_EAST_E03: 100 Punkte
MSR_EAST_E02: 541 Punkte
```

Die Route-Anchor-Zonen waren deshalb keine notwendige Routenquelle mehr.

## Ursachenbewertung

### Spawn

`SPAWN:SpawnFromCoordinate()` verschiebt das vorhandene Gruppentemplate an eine neue Koordinate. Die Methode erzeugt jedoch keine individuelle Straßenposition und kein lokales Heading für jeden Unit-Slot. Die räumliche Templateanordnung bleibt damit für einen beliebigen Startpunkt ungeprüft.

Das Problem war im TM01C-Strang bereits belastbar gelöst worden: Jeder überlebende Slot erhielt eine eigene Position auf dem kompilierten Straßenpfad und ein eigenes lokales Heading. Die frühere Lösung verwendete dafür bereits MOOSE-Straßenkoordinaten und `SPAWN:InitSetUnitAbsolutePositions()`.

### Route

`TaskGroundOnRoad()` wurde siebenmal unabhängig zwischen den historischen Route-Anchor-Zonen aufgerufen. Die zurückgegebenen Teilrouten wurden anschließend zu einer gemeinsamen DCS-Route zusammengefügt.

Diese Konstruktion hatte zwei fachliche Mängel:

- sie verwendete nicht die im Mission Editor gezeichneten MSR-Strecken als autoritative Route;
- sie verband mehrere jeweils eigenständig berechnete DCS-Straßenteilrouten mit eigenen Start-, Straßen- und Endpunkten.

Der Logeintrag mit 21 Wegpunkten bewies deshalb nur, dass eine Tabelle zugewiesen wurde. Er bewies weder die Verwendung der MSR noch eine durchgehend fahrbare Route bis Jalalabad.

## MOOSE-First-Prüfung

Vor einer Eigenentwicklung wurden die Möglichkeiten der gepinnten MOOSE-Fassung 2.9.18 geprüft.

Verwendete MOOSE-Funktionen:

```text
PATHLINE:FindByName()
PATHLINE:GetNumberOfPoints()
PATHLINE:GetPoint2DFromIndex()
COORDINATE:GetClosestPointToRoad()
COORDINATE:GetPathOnRoad()
COORDINATE:WaypointGround()
SPAWN:InitSetUnitAbsolutePositions()
SPAWN:Spawn()
GROUP:Route()
```

Damit ist weder ein nativer `coalition.addGroup()`-Spawn noch eine eigene DCS-Straßenwegfindung erforderlich. Projekteigener Code bleibt auf die fachliche Verkettung der vorhandenen MSR-Abschnitte, Distanzinterpolation, Validierung und Diagnostik begrenzt.

## Neuer Aufbau

### Verbindliche Eingaben

```text
Startzone:  ZONE_TM01_START_BAGRAM
MSR 1:      MSR_EAST_E03
MSR 2:      MSR_EAST_E02
Zielzone:   ZONE_TM01_TARGET_JALALABAD
```

Die Zonen `ZONE_TM01_ROUTE_01` bis `ZONE_TM01_ROUTE_07` werden von TM01M nicht mehr aufgelöst.

### Routenkompilierung

1. Start- und Zielzone werden mit MOOSE auf die jeweils nächste DCS-Straße projiziert.
2. `MSR_EAST_E03` und `MSR_EAST_E02` werden über `PATHLINE` aus der MOOSE-Datenbank gelesen.
3. Jeder PATHLINE-Abschnitt wird automatisch so orientiert, dass seine nächstgelegene Seite an den vorherigen Abschnitt anschließt.
4. Für die vorliegende Mission werden beide Zeichnungen umgekehrt verwendet:

```text
MSR_EAST_E03: Bagram → Kabul
MSR_EAST_E02: Kabul → Jalalabad
```

5. Der Anschluss von der Startzone zur E03 und von der E02 zur Zielzone wird über `COORDINATE:GetPathOnRoad()` erzeugt.
6. Aus dem vollständigen Pfad werden in begrenztem Abstand MSR-Stützwegpunkte erzeugt und erneut auf die DCS-Straße projiziert.
7. Die fertige Route wird einmalig über `GROUP:Route()` zugewiesen.

### Spawnaufstellung

1. Die ersten sechs Fahrzeugpositionen werden mit konfiguriertem Abstand entlang des bereits kompilierten Startanschlusses bestimmt.
2. Jede Position wird separat über MOOSE auf die Straße projiziert.
3. Für jedes Fahrzeug wird das lokale Heading aus dem Pfadverlauf berechnet.
4. Alle Positionen müssen innerhalb der Startzone liegen und Mindestabstände einhalten.
5. Der vorhandene Mission-Editor-Templateverbund wird mit `SPAWN:InitSetUnitAbsolutePositions()` und `SPAWN:Spawn()` erzeugt.

Damit wird die bereits im TM01C-Lauf nachgewiesene Grundidee übernommen, nun aber ohne die alte Proxy-, CampaignState- oder Pack-/Unpack-Architektur.

## DCS-Ergebnis der Version 1

Validierter Stand:

```text
Commit:               0db10501f81c160cd5818088e760af181b33d86d
Konfiguration:        TM01M-moose-native-msr-pathline-1
Sollgeschwindigkeit:  30 km/h
DCS:                  2.9.28.26283
```

Der Lauf war vollständig erfolgreich:

```text
routeLengthMeters=213189
waypointCount=89
maximumSpawnRoadSnapMeters=2
maximumWaypointRoadSnapMeters=19
survivingVehicles=6
```

Der Konvoi bestand aus drei `M1043 HMMWV Armament` und drei `CHAP_M1083`. Alle sechs Fahrzeuge erreichten Jalalabad und waren im Debrief mit `dead=false` enthalten.

Die simulierte Fahrt dauerte ungefähr von `08:00` bis `15:11`, also rund `7 h 11 min`. Aus `213,189 km` und dieser Fahrzeit ergibt sich eine Durchschnittsgeschwindigkeit von rund `29,7 km/h` beziehungsweise `16,0 kn`. Die beobachteten ungefähr 16 kn entsprechen damit nahezu exakt der konfigurierten Sollgeschwindigkeit von 30 km/h.

Autoritativer Ergebnisbericht:

```text
mission/tests/tm01-blue-convoy/results/2026-07-26-tm01m-msr-pathline-v1-pass.md
```

Damit sind nun auch die zuvor offenen Punkte in DCS nachgewiesen:

- tatsächliche Straßenprojektion auf der Afghanistan-Karte;
- kollisionsfreie Aufstellung aller sechs konkreten Fahrzeuge;
- durchgehendes DCS-Ground-AI-Verhalten über die vollständige Strecke;
- korrekter Übergang E03 → E02;
- vollständige Zielankunft aller sechs Fahrzeuge.

## Kontrollierte Geschwindigkeitserhöhung

Neue Konfigurationsversion:

```text
TM01M-moose-native-msr-pathline-2
```

Geänderter Parameter:

```text
speedKph: 30 → 40
```

Unverändert bleiben:

```text
formation:                       On Road
waypointSpacingMeters:           2500
vehicleSpacingMeters:            18
minimumVehicleSeparationMeters:  8
maximumZoneRoadSnapMeters:       175
maximumSpawnRoadSnapMeters:      30
maximumWaypointRoadSnapMeters:   250
```

Die Erhöhung auf `40 km/h` beziehungsweise ungefähr `21,6 kn` ist bewusst moderat. Die konkrete gemeinsame Höchstgeschwindigkeit der gemischten Gruppe ist nicht aus dem bisherigen Log ableitbar. Insbesondere muss das verwendete CHAP-M1083-Modell im Verband praktisch geprüft werden.

Für die validierte Strecke von `213,189 km` ergibt sich bei konstant 40 km/h eine theoretische Fahrzeit von ungefähr `5 h 20 min`. Das ist nur ein Orientierungswert, da DCS-Ground-AI in Kurven, an Steigungen, Brücken und bei Verbandskorrekturen langsamer fahren kann.

Der nächste DCS-Lauf muss deshalb nachweisen:

- alle sechs Fahrzeuge halten die Marschgruppe;
- kein Fahrzeug fällt dauerhaft zurück;
- der Übergang E03 → E02 bleibt störungsfrei;
- alle sechs Fahrzeuge erreichen erneut die Zielzone;
- es entstehen keine neuen Kurven-, Brücken- oder Stauprobleme.

## Statische Verifikation

Der statische Harness prüft weiterhin:

- Auflösung beider MSR-PATHLINE-Objekte;
- automatische Umkehr beider Testpfade in Fahrtrichtung;
- sechs individuelle absolute Spawnpositionen;
- lokale Headings und Fahrzeugabstände;
- vollständige Startzonenmitgliedschaft;
- ersten Routenwegpunkt vor dem Führungsfahrzeug;
- mehrere MSR-Stützwegpunkte bis zur Zielzone;
- Verwendung der konfigurierten Geschwindigkeit für jeden erzeugten Wegpunkt;
- ausschließliche MOOSE-Routen- und Spawn-APIs;
- Ausschluss von `TaskGroundOnRoad()` und historischen Route-Anchor-Zonen;
- Ausschluss der alten TM01B-/TM01C-Runtime.

Die statische Prüfung kann die praktische Marschfähigkeit bei 40 km/h nicht bestätigen. Diese bleibt Gegenstand des nächsten DCS-Regressionslaufs.
