# TM01A – kontrolliertes Straßenrouting – manuelle DCS-Abnahme

## Voraussetzungen

1. Das aktuelle Bündel erzeugen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-test-bundle.ps1
```

2. Den erfolgreichen SHA-256-Abgleich für `vendor/moose/Moose.lua` prüfen.
3. Die Mission ausschließlich im DCS Mission Editor öffnen; keine `.miz`-Interna bearbeiten oder entpacken.
4. Im `DO SCRIPT FILE`-Trigger die neu erzeugte Datei `mission/tests/tm01-blue-convoy/dist/TM01A.lua` erneut auswählen. Eine bereits eingebettete ältere Kopie wird nicht automatisch ersetzt.
5. `vendor/moose/Moose.lua` weiterhin vor `TM01A.lua` laden.
6. Vor dem Lauf das DCS-Log leeren oder den Laufbeginn eindeutig markieren.

## Start und manueller Spawn

1. Die Mission als Multiplayer-Server starten und einen Beobachter- oder Spielerslot betreten.
2. Prüfen, dass der Bootstrap dreizehn MOOSE-APIs und zehn Pflichtobjekte validiert und `outcome=READY` meldet.
3. Vor dem manuellen Spawn prüfen, dass kein Testkonvoi sichtbar ist.
4. `F10 Other > OMW Tests > TM01A > Show route status` auswählen.
5. Route-ID `ROUTE_TM01_BAGRAM_JALALABAD`, Zustand `NOT_READY`, Laufzeitgruppe `none` und `routeAssigned=false` prüfen.
6. `Spawn convoy` einmal auswählen und genau eine Gruppe `TM01A_BLUE_CONVOY_001#001` mit sechs Fahrzeugen in `ZONE_TM01_START_BAGRAM` prüfen.
7. Prüfen, dass `TPL_TEST_BLUE_CONVOY_STANDARD_01` weiterhin inaktiv bleibt.
8. `Show route status` auswählen und Zustand `READY`, sechs lebende Units und `routeAssigned=false` prüfen.
9. Positionen der Fahrzeuge notieren und mindestens 30 Sekunden beobachten. Der Konvoi muss ohne Routenbefehl stationär bleiben.

## Einmalige Routenzuweisung

1. `F10 Other > OMW Tests > TM01A > Start convoy route` genau einmal auswählen.
2. Prüfen, dass genau ein `convoy_route_requested` und danach genau ein `convoy_route_started` protokolliert wird.
3. Prüfen, dass der Konvoi erst nach diesem Befehl zu fahren beginnt.
4. Im Start-Ereignis folgende Werte prüfen:

```text
entityId=TEST.TM01.CONVOY.001
routeId=ROUTE_TM01_BAGRAM_JALALABAD
runtimeGroupName=TM01A_BLUE_CONVOY_001#001
routeState=EN_ROUTE
configuredSpeedKph=30
formation=ON_ROAD
roadOnly=true
anchorCount=7
totalWaypointCount=8
firstRouteZoneName=ZONE_TM01_ROUTE_01
finalTargetZoneName=ZONE_TM01_TARGET_JALALABAD
routeAssigned=true
missionTimeSeconds=<numerischer Wert>
```

5. Route und Log visuell kontrollieren. Die Gruppe muss diese Zonen in exakt dieser Reihenfolge anfahren:

```text
ZONE_TM01_ROUTE_01
ZONE_TM01_ROUTE_02
ZONE_TM01_ROUTE_03
ZONE_TM01_ROUTE_04
ZONE_TM01_ROUTE_05
ZONE_TM01_ROUTE_06
ZONE_TM01_ROUTE_07
ZONE_TM01_TARGET_JALALABAD
```

6. Straßenverhalten und konfigurierte Geschwindigkeit von 30 km/h beobachten. Abweichungen der DCS-KI dokumentieren; TM01A darf keine zufälligen Punkte oder alternative Route erzeugen.
7. `Start convoy route` ein zweites Mal auswählen. Genau ein `convoy_route_rejected` und kein zweites `convoy_route_started` prüfen.
8. Prüfen, dass weiterhin genau eine Laufzeitgruppe existiert und das Originaltemplate inaktiv bleibt.
9. Während der Fahrt `Show route status` auswählen und Zustand `EN_ROUTE`, tatsächlichen Laufzeitnamen, lebende Unit-Anzahl, Zielzonenmitgliedschaft und `routeAssigned=true` prüfen.

## Ankunft

1. Den Konvoi ohne Skripteingriff bis vollständig in `ZONE_TM01_TARGET_JALALABAD` fahren lassen.
2. `Show route status` auswählen.
3. Zustand `ARRIVED` und `targetZoneMembership=true` prüfen.
4. `Show route status` mindestens ein zweites Mal auswählen und bestätigen, dass `convoy_route_arrived` insgesamt genau einmal protokolliert wurde.

## Erwartete Ereignisse und Ausschlüsse

Mindestens folgende `[OMW][TM01A]`-Ereignisse müssen vorhanden sein:

```text
event=convoy_route_status routeState=NOT_READY
event=convoy_route_status routeState=READY
event=convoy_route_requested
event=convoy_route_started routeState=EN_ROUTE
event=convoy_route_requested
event=convoy_route_rejected
event=convoy_route_status routeState=EN_ROUTE
event=convoy_route_arrived routeState=ARRIVED
event=convoy_route_status routeState=ARRIVED
```

Es darf kein `convoy_route_failed` auftreten. TM01A darf keine Route neu berechnen, keinen Anker überspringen und keine automatische Unstuck-, Recovery-, Reset-, Despawn-, Respawn-, Cargo-, Warehouse-, Manifest-, Persistenz-, Virtualisierungs- oder Feindkräfte-Logik ausführen.

## Ergebnis

Das Straßenrouting bleibt bis zur dokumentierten In-Game-Ausführung offen. Pfadfindung, tatsächliche Ankerreihenfolge, 30-km/h-Verhalten, Multiplayer-Synchronisierung und vollständige Zielzonenankunft müssen unter `mission/tests/tm01-blue-convoy/results/` protokolliert werden.
