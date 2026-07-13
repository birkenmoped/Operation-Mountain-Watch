# TM01A-Bootstrap – manuelle DCS-Abnahme

## Statussemantik

- Weicht der lokale SHA-256-Hash von `vendor/moose/Moose.lua` vom Eintrag in `vendor/moose/VERSION.md` ab, bricht der Build ab.
- Fehlt eine benötigte MOOSE-Laufzeit-API, lautet der Bootstrap-Status `FAIL_SCRIPT`.
- Fehlt eines der zehn Pflichtobjekte im Mission Editor, lautet der Bootstrap-Status `FAIL_CONFIGURATION`.
- Die exakte Provenienz der tatsächlich von DCS geladenen MOOSE-Datei wird in diesem Meilenstein manuell anhand des MOOSE-eigenen DCS-Log-Banners bestätigt.

`mooseVerificationMode=BUILD_HASH_PLUS_RUNTIME_API_CHECK` behauptet keinen programmgesteuerten Vergleich der tatsächlich geladenen MOOSE-Version oder Datei-Prüfsumme.

## Voraussetzungen

1. Im Repository folgenden Befehl ausführen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-test-bundle.ps1
```

2. Sicherstellen, dass der Build mit `Verified Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915` endet.
3. Die TM01A-Testmission ausschließlich im DCS Mission Editor öffnen; keine `.miz`-Interna direkt bearbeiten.
4. Wenn die Mission bereits eine ältere eingebettete Kopie von `TM01A.lua` enthält, nach jedem Build den betreffenden `DO SCRIPT FILE`-Trigger prüfen und die neu erzeugte Datei `mission/tests/tm01-blue-convoy/dist/TM01A.lua` erneut auswählen.
5. Diese Mission-Editor-Objekte mit exakt diesen Namen bereitstellen:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
ZONE_TM01_START_BAGRAM
ZONE_TM01_TARGET_JALALABAD
ZONE_TM01_ROUTE_01
ZONE_TM01_ROUTE_02
ZONE_TM01_ROUTE_03
ZONE_TM01_ROUTE_04
ZONE_TM01_ROUTE_05
ZONE_TM01_ROUTE_06
ZONE_TM01_ROUTE_07
```

6. Das Gruppentemplate darf Late Activation verwenden. Es wird in diesem Meilenstein nicht aktiviert oder gespawnt.
7. Die vier TM01B-Reveal-Zonen dürfen für diesen Lauf fehlen.
8. Zwei Mission-Start-Trigger in genau dieser Reihenfolge konfigurieren:

```text
1. DO SCRIPT FILE: vendor/moose/Moose.lua
2. DO SCRIPT FILE: mission/tests/tm01-blue-convoy/dist/TM01A.lua
```

9. Vor jedem Abnahmelauf das DCS-Log leeren oder den Beginn des neuen Laufs eindeutig markieren.

## Nominallauf: `READY`

1. Die Mission als Multiplayer-Server starten und einen Beobachter- oder Spielerslot betreten.
2. Im DCS-Log das MOOSE-eigene Banner suchen und prüfen, dass es exakt folgende zusammenhängende Buildkennung enthält:

```text
2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

3. Diese Bannerprüfung als manuelle Bestätigung der tatsächlich geladenen MOOSE-Provenienz dokumentieren.
4. Im DCS-Log nach dem Präfix `[OMW][TM01A]` suchen.
5. Prüfen, dass genau eine strukturierte `event=startup`-Meldung folgende Werte enthält:

```text
testId=TM01
stageId=TM01A
configurationVersion=TM01A-physical-spawn-1
expectedMooseVersion=2.9.18
expectedMooseFileSha256=e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
expectedMooseBuildCommit=73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
expectedMooseBuildTimestamp=2026-06-14T16:11:05+02:00
expectedMooseIncludeFamily=Moose_Include_Static
expectedMooseCompression=none
mooseVerificationMode=BUILD_HASH_PLUS_RUNTIME_API_CHECK
```

6. Prüfen, dass `buildTimestamp` separat als Erzeugungszeit des Bündels protokolliert wird.
7. Prüfen, dass `missionTimeSeconds` als numerischer Wert protokolliert wird.
8. Prüfen, dass `event=native_api_validation_passed nativeApiCount=3` protokolliert wird.
9. Prüfen, dass `event=moose_api_validation_passed mooseApiCount=10` protokolliert wird.
10. Prüfen, dass `event=configuration_valid checkedObjectCount=10 revealZonesRequired=false` protokolliert wird.
11. Prüfen, dass der letzte Bootstrap-Status `event=bootstrap_outcome ... outcome=READY` lautet.
12. `F10 Other > OMW Tests > TM01A > Show status` auswählen.
13. Prüfen, dass die Bildschirmmeldung `Outcome: READY` und `Detail: bootstrap validation completed` zeigt.
14. `F10 Other > OMW Tests > TM01A > Validate configuration` auswählen.
15. Prüfen, dass erneut `configuration_valid`, danach `bootstrap_outcome ... outcome=READY` und eine sichtbare Statusmeldung erscheinen.
16. In der F10-Karte und in der Außenansicht prüfen, dass `TPL_TEST_BLUE_CONVOY_STANDARD_01` nicht durch das Skript aktiviert oder als neue Gruppe erzeugt wurde.
17. Prüfen, dass im Log keine TM01B-Reveal-Zone als fehlend gemeldet wird.

Erwartetes Ergebnis: `READY`.

## Negativlauf: `FAIL_CONFIGURATION`

1. Eine separate Arbeitskopie der Testmission im Mission Editor öffnen.
2. Genau eines der zehn Pflichtobjekte umbenennen, zum Beispiel `ZONE_TM01_ROUTE_07` in `ZONE_TM01_ROUTE_07_MISSING`.
3. Die Arbeitskopie starten; MOOSE und `TM01A.lua` weiterhin in der vorgeschriebenen Reihenfolge laden.
4. Prüfen, dass `event=configuration_invalid` das umbenannte Pflichtobjekt im Feld `missing` nennt.
5. Prüfen, dass `event=bootstrap_outcome ... outcome=FAIL_CONFIGURATION` protokolliert wird.
6. `Show status` auswählen und die sichtbare Meldung `Outcome: FAIL_CONFIGURATION` prüfen.
7. Den ursprünglichen Objektnamen in der Arbeitskopie wiederherstellen.

Erwartetes Ergebnis: `FAIL_CONFIGURATION` ohne Spawn oder Bewegung einer Gruppe.

## Negativlauf: `FAIL_SCRIPT`

1. Eine separate Arbeitskopie der Testmission im Mission Editor öffnen.
2. Nur in dieser Arbeitskopie den Trigger zum Laden von `vendor/moose/Moose.lua` deaktivieren; `TM01A.lua` weiterhin laden.
3. Die Arbeitskopie starten.
4. Prüfen, dass `event=moose_api_validation_failed` die fehlenden MOOSE-APIs nennt.
5. Prüfen, dass `event=bootstrap_outcome ... outcome=FAIL_SCRIPT` protokolliert wird.
6. Den MOOSE-Ladetrigger nach dem Lauf wieder aktivieren.

Erwartetes Ergebnis: `FAIL_SCRIPT`. Da die MOOSE-Menü-APIs fehlen, wird in diesem Negativlauf kein F10-Testmenü erwartet.

## Unerwarteter Bootstrap-Fehler

Falls der vollständige Aufruf von `TM01A.start(...)` einen nicht intern behandelten Fehler auslöst, muss der minimale sichere Reporter bei verfügbarem `env.info` eine strukturierte Zeile mit folgenden Feldern ausgeben:

```text
[OMW][TM01A]
level=ERROR
event=bootstrap_uncaught_error
outcome=FAIL_SCRIPT
```

Der Fehlertext muss bereinigt und ohne Zeilenumbruch im Feld `error` folgen.

## Zu protokollierendes Ergebnis

Für jeden Lauf DCS-Version, Missionsdatei, Bundle-Buildzeitstempel, Ergebnisstatus, MOOSE-Bannerprüfung und relevante `[OMW][TM01A]`-Logzeilen in `mission/tests/tm01-blue-convoy/results/` dokumentieren. Die Laufzeitabnahme gilt erst nach diesem In-Game-Test als erfolgt.
