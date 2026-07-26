# TM01M – MOOSE-native MSR-Konvoi: DCS-Abnahme

Status: `30-km/h-Baseline PASS`; `40-km/h-Geschwindigkeitsregression AUSSTEHEND`

## Zweck

TM01M ist die saubere MOOSE-native physische Baseline für einen blauen Konvoi von Bagram nach Jalalabad. Die Teststufe enthält keine Virtualisierung, keinen CampaignState, kein Pack/Unpack und keinen Unstuck- oder Teleport-Mechanismus.

Verbindliche Routenquelle sind die im Mission Editor gezeichneten und von MOOSE als `PATHLINE` registrierten MSR-Abschnitte:

```text
ZONE_TM01_START_BAGRAM
→ MSR_EAST_E03
→ MSR_EAST_E02
→ ZONE_TM01_TARGET_JALALABAD
```

Die historischen Zonen `ZONE_TM01_ROUTE_01` bis `ZONE_TM01_ROUTE_07` werden nicht aufgelöst und nicht für die Routenerzeugung verwendet.

## Verbindliche Mission-Editor-Objekte

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_TARGET_JALALABAD
MSR_EAST_E03
MSR_EAST_E02
```

## Scriptreihenfolge

1. `vendor/moose/Moose.lua`
2. erzeugtes `mission/tests/tm01-blue-convoy/dist/TM01M.lua`

## Validierte 30-km/h-Baseline

Der DCS-Lauf mit

```text
Commit:               0db10501f81c160cd5818088e760af181b33d86d
Konfiguration:        TM01M-moose-native-msr-pathline-1
Sollgeschwindigkeit:  30 km/h
```

bestand die vollständige Fahrt von Bagram nach Jalalabad.

Nachgewiesen wurden:

```text
routeLengthMeters=213189
waypointCount=89
maximumSpawnRoadSnapMeters=2
maximumWaypointRoadSnapMeters=19
survivingVehicles=6
```

Die simulierte Fahrt dauerte ungefähr von `08:00` bis `15:11`. Daraus ergibt sich eine Durchschnittsgeschwindigkeit von ungefähr `29,7 km/h` beziehungsweise `16,0 kn`; dies entspricht der vorgegebenen Geschwindigkeit von `30 km/h`.

Autoritativer Ergebnisbericht:

```text
mission/tests/tm01-blue-convoy/results/2026-07-26-tm01m-msr-pathline-v1-pass.md
```

## Aktuelles Testinkrement

```text
Konfigurationsversion: TM01M-moose-native-msr-pathline-2
Sollgeschwindigkeit:   40 km/h
Formation:             On Road
```

Die Erhöhung von `30 km/h` auf `40 km/h` ist ein kontrollierter nächster Schritt. Sie ist nicht als bereits nachgewiesene Höchstgeschwindigkeit des Verbands zu verstehen.

Der Testkonvoi besteht aus:

```text
3 × M1043 HMMWV Armament
3 × CHAP_M1083
```

Da die konkrete fahrdynamische Begrenzung des verwendeten CHAP-M1083-Modells nicht aus den bisherigen Logs hervorgeht, muss die gemeinsame Marschfähigkeit bei `40 km/h` erneut in DCS geprüft werden.

## Vorbereitungen

1. Branch aktualisieren und den erwarteten HEAD prüfen.
2. Bundle neu bauen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

3. Die Mission ausschließlich im DCS Mission Editor öffnen.
4. Im vorhandenen `DO SCRIPT FILE`-Trigger die neu erzeugte `dist/TM01M.lua` erneut auswählen.
5. `Moose.lua` weiterhin vor `TM01M.lua` laden.
6. Mission speichern.
7. DCS-Log vor dem Lauf leeren oder den Laufbeginn eindeutig markieren.

## Erwarteter Bootstrap

```text
event=msr_route_plan_compiled
routeMode=MOOSE_PATHLINE_MSR
msrPathlines=MSR_EAST_E03,MSR_EAST_E02
msrPathlineCount=2
sourcePointCount=641
pathlineDirections=MSR_EAST_E03:reversed,MSR_EAST_E02:reversed
routeLengthMeters=...

event=bootstrap_outcome
outcome=READY

event=startup
configurationVersion=TM01M-moose-native-msr-pathline-2
routeMode=MOOSE_PATHLINE_MSR
msrPathlineCount=2
```

## Spawn-Abnahme

1. `F10 > Other > OMW Tests > TM01M MOOSE Native MSR Convoy > Spawn convoy` genau einmal ausführen.
2. Genau eine Laufzeitgruppe mit sechs Fahrzeugen prüfen.
3. Jedes Fahrzeug muss:
   - vollständig innerhalb `ZONE_TM01_START_BAGRAM` stehen;
   - auf einer befahrbaren Straße stehen;
   - ausreichenden Abstand zum vorherigen Fahrzeug besitzen;
   - in lokaler Marschrichtung ausgerichtet sein;
   - frei von Gebäuden, Dächern, Mauern und anderen Hindernissen sein.
4. Ohne Routenstart mindestens 30 Sekunden Stillstand prüfen.
5. Einen zweiten Spawnversuch ausführen und dessen Ablehnung prüfen.

Erwartetes Ereignis:

```text
event=convoy_spawned
spawnZoneName=ZONE_TM01_START_BAGRAM
spawnPositionMode=MOOSE_InitSetUnitAbsolutePositions
msrFirstPathline=MSR_EAST_E03
aliveUnits=6
spawnX=...
spawnY=...
spawnHeadingDeg=...
maximumSpawnRoadSnapMeters=...
```

## 40-km/h-Routenabnahme

1. `Start MSR route` genau einmal ausführen.
2. Im Log prüfen:

```text
event=convoy_route_started
routeMode=MOOSE_PATHLINE_MSR
msrPathlineCount=2
msrPathlines=MSR_EAST_E03,MSR_EAST_E02
formation=On Road
speedKph=40
waypointCount=...
routeLengthMeters=...
maximumWaypointRoadSnapMeters=...
```

3. Der Verband muss den Straßenanschluss von Bagram zur `MSR_EAST_E03` verwenden.
4. Er muss über `MSR_EAST_E03` nach Kabul und anschließend über `MSR_EAST_E02` nach Jalalabad fahren.
5. Alle sechs Fahrzeuge müssen als zusammenhängender Verband weiterfahren. Kurzfristige Abstandsänderungen sind zulässig; ein dauerhaft zurückbleibendes oder verlorenes Fahrzeug ist nicht zulässig.
6. Besondere Beobachtungspunkte sind enge Kurven, Steigungen, Brücken und der Übergang E03 → E02.
7. Einen zweiten Routenstart ausführen und dessen Ablehnung prüfen.
8. Den Konvoi bis vollständig in `ZONE_TM01_TARGET_JALALABAD` beobachten.

Die rechnerische Mindestfahrzeit für `213.189 km` bei konstanten `40 km/h` beträgt ungefähr `5 h 20 min`. Dies ist kein hartes PASS-Kriterium, da die DCS-Ground-AI in Kurven, an Steigungen und bei Verbandskorrekturen langsamer fahren darf.

## PASS-Kriterien

- Bootstrap endet mit `READY` und meldet Version 2.
- Beide MSR-PATHLINEs werden gefunden und korrekt orientiert.
- Genau sechs Fahrzeuge werden über MOOSE `SPAWN` erzeugt.
- Alle Fahrzeuge stehen beim Spawn korrekt auf der Straße.
- Die Route wird einmalig über `GROUP:Route()` zugewiesen.
- Das Routenereignis meldet `speedKph=40` und `formation=On Road`.
- Drei M1043 und drei CHAP M1083 bleiben marschfähig.
- Kein Fahrzeug fällt dauerhaft zurück oder verlässt die Route.
- Der vollständige Verband erreicht Jalalabad.
- Die Ankunft wird genau einmal mit `survivingVehicles=6` erkannt.
- Es tritt kein TM01M-Lua-Fehler auf.
- Es greift keine Virtualisierungs-, Recovery-, Teleport- oder Unstuck-Logik ein.

## FAIL-Kriterien

- die eingebettete Konfiguration meldet weiterhin Version 1 oder `speedKph=30`;
- ein Fahrzeug erscheint abseits der Straße oder in einem Objekt;
- ein M1043 oder CHAP M1083 kann die Marschgruppe dauerhaft nicht halten;
- der Verband reißt dauerhaft auseinander;
- ein Fahrzeug bleibt an Kurve, Steigung, Brücke oder MSR-Übergang zurück;
- die Gruppe bleibt vor Jalalabad dauerhaft stehen;
- Spawn oder Routenzuweisung wird doppelt ausgeführt;
- ein benutzerdefinierter Teleport, Respawn oder Unstuck-Vorgang greift ein;
- ein TM01M-Lua-Fehler tritt auf.

## Nachweis

Nach dem Lauf sind mindestens zu sichern:

```text
dcs.log
debrief.log
Screenshot der vollständigen Spawnaufstellung
Nachweis eines repräsentativen Fahrtabschnitts mit allen sechs Fahrzeugen
Screenshot der vollständigen Zielankunft
beobachtete Simulationszeit von Routenstart bis Ankunft
```

Die 30-km/h-Baseline ist akzeptiert. Die 40-km/h-Erhöhung gilt erst nach einem dokumentierten DCS-Lauf als bestanden.
