# Jalalabad Phase 1 – Missionseditor-Arbeitsliste

## 1. Verbindliche Aufgabentrennung

Für dieses Projekt gilt:

```text
ChatGPT / Codeentwicklung:
- Lua-Quellcode im Repository ändern
- Builder und technische Dokumentation ändern
- Änderungen auf den bestehenden Entwicklungsbranch schreiben
- erwarteten Commit und die lokalen Buildbefehle nennen

Missionsdesigner:
- Repository lokal abrufen
- Bundle lokal bauen und prüfen
- Missionsdatei im DCS-Missionseditor öffnen
- Bundle in die Missionsdatei einbetten
- Missionsdatei speichern oder umbenennen
- DCS-Testlauf durchführen
```

ChatGPT erstellt, verändert, entpackt, packt oder ersetzt keine `.miz`-Datei, sofern der Missionsdesigner dies nicht ausdrücklich beauftragt.

Automatisch erzeugte oder bereitgestellte Testmissionen sind kein Bestandteil des normalen Arbeitsablaufs. Die Missionsdatei bleibt vollständig unter Kontrolle des Missionsdesigners.

## 2. Missionsdatei

Für den nächsten Test wird die vorhandene Arbeitsmission des Missionsdesigners weiterverwendet. Eine Umbenennung erfolgt nur nach ausdrücklicher Festlegung durch den Missionsdesigner oder nach einer konkreten gemeinsamen Anweisung.

An den Missionseditorobjekten sind für den aktuellen Codefix keine weiteren Änderungen erforderlich.

## 3. Lokaler Abruf des Entwicklungsstands

PowerShell:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
```

Existiert der Branch lokal noch nicht:

```powershell
git switch --track origin/feature/jalalabad-airwing-phase1-functional-tests
```

Existiert er bereits:

```powershell
git switch feature/jalalabad-airwing-phase1-functional-tests
git pull --ff-only
```

Danach:

```powershell
git rev-parse HEAD
```

Der erwartete Commit wird für jeden Testlauf ausdrücklich in der jeweiligen Übergabe genannt. Bei einem abweichenden Commit wird das Bundle nicht gebaut und der Test nicht gestartet.

## 4. Bundle lokal bauen

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Der Builder erzeugt lokal:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua
```

## 5. Bundle unabhängig prüfen

```powershell
Get-Item `
  ".\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua" |
  Select-Object FullName, Length, LastWriteTime

Get-FileHash `
  ".\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua" `
  -Algorithm SHA256
```

Im Dateikopf muss für diesen Entwicklungsstand stehen:

```text
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
GitCommit: <derselbe Commit wie git rev-parse HEAD>
```

## 6. Bundle durch den Missionsdesigner einbetten

Im DCS-Missionseditor:

1. die vorhandene Arbeitsmission öffnen;
2. die Triggeraktion mit `OMW_AirOps_Jalalabad.lua` öffnen;
3. die lokal gebaute Datei erneut auswählen;
4. Mission unter dem vom Missionsdesigner festgelegten Namen speichern;
5. keine weiteren Missionseditorobjekte verändern, sofern dies nicht ausdrücklich angeordnet wurde.

Ladereihenfolge bei `MISSION START`:

```text
1. Moose.lua
2. OMW_AirOps_Jalalabad.lua
```

## 7. Technische AIRWING-Templates

Diese Gruppen bleiben unverändert:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Verbindlich:

- Late Activation bleibt aktiviert;
- die Templates stehen außerhalb aller operativen DCS-Parkpositionen;
- Gruppen- und Einheitennamen bleiben eindeutig;
- die Two-Ship-Templates liefern Typ, Payload und Livery;
- MOOSE erzeugt daraus bei OH-58D und AH-64D zwei unabhängige Single-Ship-DCS-Gruppen.

## 8. Exklusive KI-Parkplatzpools

```text
OH-58D: G01-G05 / TerminalIDs 19,43,6,5,48
AH-64D: F04-F06 / TerminalIDs 26,51,11
UH-60A: F01-F03 / TerminalIDs 10,8,1
CH-47F: C03-C10 / TerminalIDs 28,44,0,41,9,25,18,42
```

F04 beziehungsweise TerminalID 26 ist frei und Bestandteil des AH-64D-Pools.

Weiterhin gesperrt:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

## 9. Eindeutige Laufzeitnamen

Die Teststeuerung identifiziert Runtimeeinheiten nicht allein über den Luftfahrzeugtyp.

```text
Gruppe:  <SQUADRON-NAME>_AID-<Nummer>
Einheit: <GRUPPENNAME>-01
```

Client-, Player-, Template- und sonstige Missionseditorgruppen werden über ihre festen Namen ausgeschlossen. Insbesondere:

```text
TEST_TM01A_CLIENT_01
```

## 10. Testreihenfolge

Nicht sofort den Gesamtablauf starten:

```text
1. Status anzeigen
2. OH-58D RECON als Einzeltest
3. Mission neu starten und dcs.log auswerten
4. AH-64D CAS als Einzeltest
5. Mission neu starten und dcs.log auswerten
6. erst nach beiden Einzel-PASS den Gesamtablauf starten
```

Der CH-47-Cargotest bleibt pro Missionsstart einmalig verwendbar.
