# TM01A – kontrollierter physischer Spawn – manuelle DCS-Abnahme

## Voraussetzungen

1. Den aktuellen Bundle-Build ausführen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-test-bundle.ps1
```

2. Den erfolgreichen SHA-256-Abgleich von `vendor/moose/Moose.lua` prüfen.
3. Die Testmission ausschließlich im DCS Mission Editor öffnen; keine `.miz`-Interna direkt bearbeiten oder entpacken.
4. Im vorhandenen `DO SCRIPT FILE`-Trigger die neu erzeugte Datei `mission/tests/tm01-blue-convoy/dist/TM01A.lua` erneut auswählen. DCS kann sonst die bereits in der Mission eingebettete ältere Kopie weiterverwenden.
5. Prüfen, dass `TPL_TEST_BLUE_CONVOY_STANDARD_01` weiterhin auf Late Activation steht, genau sechs Fahrzeuge enthält und keine selbständig abzufahrende Route oder Bewegungsaufgabe besitzt.
6. `vendor/moose/Moose.lua` weiterhin vor `TM01A.lua` laden.
7. Vor dem Lauf das DCS-Log leeren oder den Beginn eindeutig markieren.

## Abnahmelauf

1. Die Mission als Multiplayer-Server starten und einen Beobachter- oder Spielerslot betreten.
2. Vor jeder F10-Aktion in Karte und Außenansicht prüfen, dass kein sichtbarer Testkonvoi vorhanden ist.
3. Im Log prüfen, dass der Bootstrap dreizehn MOOSE-APIs und zehn Mission-Editor-Objekte erfolgreich validiert und `outcome=READY` meldet.
4. Im MOOSE-eigenen Log-Banner weiterhin die erwartete Buildkennung prüfen:

```text
2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

5. `F10 Other > OMW Tests > TM01A > Show convoy status` auswählen.
6. Prüfen, dass `TEST.TM01.CONVOY.001`, Zustand `NOT_SPAWNED`, Laufzeitgruppe `none`, Sollstärke `6` und keine aktuelle Unit-Anzahl angezeigt werden.
7. `F10 Other > OMW Tests > TM01A > Spawn convoy` genau einmal auswählen.
8. Prüfen, dass genau eine neue blaue Laufzeitgruppe mit sechs Fahrzeugen innerhalb `ZONE_TM01_START_BAGRAM` erscheint.
9. Prüfen, dass der tatsächliche Gruppenname mit `TM01A_BLUE_CONVOY_001` beginnt und im Log getrennt von Entity-ID und Template-Name erscheint.
10. Prüfen, dass das Original `TPL_TEST_BLUE_CONVOY_STANDARD_01` inaktiv bleibt und keine zweite Gruppe unter dem Template-Namen sichtbar wird. Im Erfolgslog muss zusätzlich `templateRemainsInactive=true` stehen.
11. `Show convoy status` auswählen und Zustand `SPAWNED`, den tatsächlichen Laufzeitnamen, Sollstärke `6` und aktuelle Stärke `6` prüfen.
12. `Spawn convoy` ein zweites Mal auswählen.
13. Prüfen, dass die Anforderung sichtbar abgelehnt wird, der vorhandene Laufzeitname und Zustand gemeldet werden und weiterhin genau eine lebende Laufzeitgruppe existiert.
14. Position und Ausrichtung aller sechs Fahrzeuge dokumentieren, zwei Minuten warten und erneut vergleichen.
15. `Start convoy route` in diesem Spawn-Abnahmelauf nicht auswählen. Prüfen, dass die Gruppe während dieser zwei Minuten stationär bleibt und ohne diesen Befehl keine Route, Wegpunkte, Aufgabe, Geschwindigkeit, Controller-Anweisung oder sonstige Bewegungsanweisung durch TM01A erhält.
16. DCS-Log und sichtbares Verhalten prüfen: Es wird keine Cargo-, Warehouse-, Persistenz-, Virtualisierungs-, Feindkräfte- oder automatische Unstuck-Logik ausgeführt.

## Erwartete strukturierte Ereignisse

Alle Projektmeldungen verwenden das Präfix `[OMW][TM01A]`. Mindestens folgende Ereignisse müssen vorhanden sein:

```text
event=convoy_status convoyState=NOT_SPAWNED
event=convoy_spawn_requested
event=convoy_spawn_succeeded
event=convoy_status convoyState=SPAWNED
event=convoy_spawn_requested
event=convoy_spawn_rejected
```

Das erfolgreiche Spawnereignis muss mindestens enthalten:

```text
entityId=TEST.TM01.CONVOY.001
templateName=TPL_TEST_BLUE_CONVOY_STANDARD_01
requestedAlias=TM01A_BLUE_CONVOY_001
runtimeGroupName=<tatsächlicher DCS/MOOSE-Gruppenname>
startZoneName=ZONE_TM01_START_BAGRAM
expectedUnitCount=6
actualUnitCount=6
missionTimeSeconds=<numerischer Missionszeitwert>
startZoneMembership=true
templateRemainsInactive=true
```

Es darf kein `convoy_spawn_failed` auftreten. Die zweite Anforderung muss `convoy_spawn_rejected` protokollieren und darf kein zweites `convoy_spawn_succeeded` erzeugen.

## Ergebnis

Der Meilenstein ist erst bestanden, wenn Spawn, Duplikatschutz, Statusanzeige, vollständige Startzonenmitgliedschaft, inaktives Originaltemplate und zweiminütiger Stillstand in DCS bestätigt und unter `mission/tests/tm01-blue-convoy/results/` protokolliert wurden.
