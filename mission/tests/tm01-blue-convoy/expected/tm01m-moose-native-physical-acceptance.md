# TM01M – MOOSE-native MSR-Konvoi: DCS-Abnahme

Status: DCS-REGRESSION AUSSTEHEND

## Zweck

TM01M ist die saubere MOOSE-native physische Baseline für einen blauen Konvoi von Bagram nach Jalalabad. Die Teststufe enthält keine Virtualisierung, keinen CampaignState, kein Pack/Unpack und keinen Unstuck- oder Teleport-Mechanismus.

Die Route wird nicht mehr aus den historischen Zonen `ZONE_TM01_ROUTE_01` bis `ZONE_TM01_ROUTE_07` zusammengesetzt. Verbindliche Routenquelle sind die im Mission Editor gezeichneten und von MOOSE als `PATHLINE` registrierten MSR-Abschnitte:

```text
ZONE_TM01_START_BAGRAM
→ MSR_EAST_E03
→ MSR_EAST_E02
→ ZONE_TM01_TARGET_JALALABAD
```

## Verbindliche Mission-Editor-Objekte

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_TARGET_JALALABAD
MSR_EAST_E03
MSR_EAST_E02
```

Die bisherigen Route-Anchor-Zonen dürfen in der Mission verbleiben, werden von TM01M jedoch nicht mehr aufgelöst oder für die Routenerzeugung verwendet.

## Scriptreihenfolge

1. `vendor/moose/Moose.lua`
2. erzeugtes `mission/tests/tm01-blue-convoy/dist/TM01M.lua`

## Vorbereitungen

1. Branch aktualisieren und sicherstellen, dass die Konfigurationsversion `TM01M-moose-native-msr-pathline-1` eingebettet ist.
2. Bundle neu bauen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tm01m-bundle.ps1"
```

3. Die Mission ausschließlich im DCS Mission Editor öffnen.
4. Im vorhandenen `DO SCRIPT FILE`-Trigger die neu erzeugte `dist/TM01M.lua` erneut auswählen, damit keine ältere eingebettete Kopie verwendet wird.
5. `Moose.lua` weiterhin vor `TM01M.lua` laden.
6. DCS-Log vor dem Lauf leeren oder den Laufbeginn eindeutig markieren.

## Erwarteter Bootstrap

Vor einer F10-Aktion müssen folgende Ereignisse erscheinen:

```text
event=msr_route_plan_compiled
routeMode=MOOSE_PATHLINE_MSR
msrPathlines=MSR_EAST_E03,MSR_EAST_E02
msrPathlineCount=2
sourcePointCount=641
pathlineDirections=MSR_EAST_E03:reversed,MSR_EAST_E02:reversed
routeLengthMeters=...
startConnectorMeters=...
targetConnectorMeters=...

event=bootstrap_outcome
outcome=READY

event=startup
configurationVersion=TM01M-moose-native-msr-pathline-1
routeMode=MOOSE_PATHLINE_MSR
msrPathlineCount=2
```

Die konkrete Gesamtlänge hängt von den durch DCS berechneten Straßenverbindungen zwischen Startzone, MSR und Zielzone ab. Sie muss numerisch und größer als null sein.

## Spawn-Abnahme

1. `F10 > Other > OMW Tests > TM01M MOOSE Native MSR Convoy > Spawn convoy` genau einmal ausführen.
2. Genau eine Laufzeitgruppe mit sechs Fahrzeugen prüfen.
3. Jedes Fahrzeug einzeln kontrollieren:
   - vollständig innerhalb `ZONE_TM01_START_BAGRAM`;
   - auf einer befahrbaren Straße;
   - ausreichender Abstand zum vorherigen Fahrzeug;
   - Front in lokaler Marschrichtung;
   - kein Fahrzeug in einem Gebäude, auf einem Dach, in einer Mauer oder quer zur Straße.
4. Ohne Routenstart mindestens 30 Sekunden prüfen, dass der Konvoi stationär bleibt.
5. Einen zweiten Spawnversuch ausführen und dessen Ablehnung prüfen.

Erwartetes Spawnereignis:

```text
event=convoy_spawned
spawnZoneName=ZONE_TM01_START_BAGRAM
spawnPositionMode=MOOSE_InitSetUnitAbsolutePositions
msrFirstPathline=MSR_EAST_E03
aliveUnits=6
spawnX=...
spawnY=...
spawnHeadingDeg=...
spawnLeadRouteDistanceMeters=...
spawnRearRouteDistanceMeters=...
maximumSpawnRoadSnapMeters=...
```

## Routen-Abnahme

1. `Start MSR route` genau einmal ausführen.
2. Prüfen, dass der erste erzeugte Wegpunkt vor dem Führungsfahrzeug liegt und kein Nullwegpunkt auf der aktuellen Position zugewiesen wird.
3. Im Log prüfen:

```text
event=convoy_route_started
routeMode=MOOSE_PATHLINE_MSR
msrPathlineCount=2
msrPathlines=MSR_EAST_E03,MSR_EAST_E02
formation=On Road
speedKph=30
waypointCount=...
routeLengthMeters=...
maximumWaypointRoadSnapMeters=...
```

4. Der Konvoi muss zunächst den Straßenanschluss von Bagram zur `MSR_EAST_E03` verwenden.
5. Danach muss er der `MSR_EAST_E03` in Richtung Kabul folgen.
6. Am gemeinsamen Knoten muss er auf `MSR_EAST_E02` wechseln und dieser in Richtung Jalalabad folgen.
7. Die Fahrt darf nicht an der Position der historischen `ZONE_TM01_ROUTE_01` enden.
8. Einen zweiten Routenstart ausführen und dessen Ablehnung prüfen.
9. Den Konvoi bis vollständig in `ZONE_TM01_TARGET_JALALABAD` beobachten.

## PASS-Kriterien

- Bootstrap endet mit `READY`.
- Beide MSR-Zeichnungen werden als MOOSE-`PATHLINE` gefunden und in Fahrtrichtung orientiert.
- Es werden keine historischen Route-Anchor-Zonen benötigt.
- Genau sechs Fahrzeuge werden über MOOSE `SPAWN` erzeugt.
- Die einzelnen absoluten Positionen und Headings werden über `SPAWN:InitSetUnitAbsolutePositions()` gesetzt.
- Alle Fahrzeuge stehen beim Spawn auf der Straße und vollständig in der Startzone.
- Die Route wird einmal als durchgehende, MSR-gebundene Wegpunktliste erzeugt und über den MOOSE-Wrapper `GROUP:Route()` zugewiesen.
- Die Formation lautet `On Road`, die Sollgeschwindigkeit 30 km/h.
- Der Konvoi fährt über `MSR_EAST_E03` und `MSR_EAST_E02` bis Jalalabad.
- Die Ankunft wird genau einmal erkannt, wenn die vollständige lebende Gruppe in der Zielzone steht.
- Es tritt kein TM01M-Lua-Fehler auf.
- Es wird keine alte TM01B-/TM01C-Runtime, keine Virtualisierung und keine Recovery-/Teleportlogik geladen.

## FAIL-Kriterien

- ein Fahrzeug erscheint abseits der Straße, in einem Objekt oder auf einem Dach;
- ein Fahrzeug zeigt beim Spawn erkennbar in die falsche Marschrichtung;
- `MSR_EAST_E03` oder `MSR_EAST_E02` fehlt oder kann nicht kompiliert werden;
- TM01M verwendet weiterhin `ZONE_TM01_ROUTE_01` bis `ZONE_TM01_ROUTE_07`;
- die Route endet am ersten historischen Route-Anchor;
- die Gruppe bleibt vor Jalalabad dauerhaft stehen;
- Routen- oder Spawnzuweisung wird doppelt ausgeführt;
- ein benutzerdefinierter Teleport, Respawn oder Unstuck-Vorgang greift ein;
- ein TM01M-Lua-Fehler tritt auf.

## Nachweis

Nach dem Lauf sind mindestens zu sichern:

```text
dcs.log
debrief.log
Screenshots der vollständigen Spawnaufstellung
Screenshot oder Track des Übergangs E03 → E02
Screenshot der vollständigen Zielankunft
```

Der Test gilt erst nach dokumentiertem DCS-Lauf als bestanden. Der statische Harness belegt nur API-Verträge, Routenstruktur und Codeausschlüsse; er belegt nicht das tatsächliche Verhalten der DCS-Ground-AI.
