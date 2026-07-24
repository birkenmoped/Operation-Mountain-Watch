# 26 – Air Operations: verbindlicher Vier-Phasen-Validierungsplan

## 1. Status und Zweck

Dieses Dokument hält den verbindlichen Ausbau- und Validierungsplan für die MOOSE-AIRWING-/COMMANDER-Architektur von **Operation Mountain Watch** fest.

```text
Jalalabad-Grundknoten: OPERATIONAL / ACCEPTED
Phase 1 Testpaket: IMPLEMENTED / DCS VALIDATION PENDING
Implementierungsbranch: feature/jalalabad-airwing-phase1-functional-tests
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
```

Der frühere Phase-1-Lauf hat zwei Architekturfehler nachgewiesen:

- type-only-Zuordnung konnte eine Client-/Testgruppe als AIRWING-Missionsgruppe übernehmen;
- eine gemeinsame Two-Ship-DCS-Gruppe führte bei Hubschraubern zu einer blockierten Recovery, weil nur der Lead landete.

## 2. Verbindliche Aufgabentrennung und Bereitstellung

Für alle vier Phasen gilt:

```text
Codeentwicklung:
- Lua-Quellen, Builder und Repository-Dokumentation ändern
- Änderungen auf den vorgesehenen Entwicklungsbranch schreiben
- erwarteten Commit und lokale Buildbefehle nennen

Missionsdesigner:
- Branch lokal abrufen
- Commit prüfen
- Bundle lokal bauen und prüfen
- Bundle im DCS-Missionseditor in die eigene .miz einbetten
- Missionsdatei speichern oder umbenennen
- DCS-Test durchführen
```

Eine `.miz` wird durch ChatGPT nicht erstellt oder verändert, sofern der Missionsdesigner dies nicht ausdrücklich beauftragt.

Verbindlicher lokaler Abruf:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
```

Branch lokal noch nicht vorhanden:

```powershell
git switch --track origin/feature/jalalabad-airwing-phase1-functional-tests
```

Branch lokal vorhanden:

```powershell
git switch feature/jalalabad-airwing-phase1-functional-tests
git pull --ff-only
```

Commit prüfen:

```powershell
git rev-parse HEAD
```

Bundle bauen:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Bundle unabhängig prüfen:

```powershell
Get-Item `
  ".\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua" |
  Select-Object FullName, Length, LastWriteTime

Get-FileHash `
  ".\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua" `
  -Algorithm SHA256
```

Der erwartete Commit wird mit jeder Testübergabe ausdrücklich genannt.

## 3. Phase 1 – Jalalabad AIRWING und SQUADRONs

Jalalabad bleibt der einzige operative Testknoten. Die Aufträge werden kontrolliert und direkt an `AW_US_JALALABAD` übergeben. Der COMMANDER bleibt gestartet, erzeugt und verteilt in dieser Phase jedoch keine eigenen Aufträge.

Verbindliche Reihenfolge:

```text
1. OH-58D logisches Two-Ship -> RECON
2. AH-64D logisches Two-Ship -> CAS
3. UH-60A Single-Ship -> TROOPTRANSPORT
4. CH-47F Single-Ship -> CARGOTRANSPORT
5. UH-60A -> definierter Abbruch nach Spawn
```

### Physisches Gruppenmodell

Alle SQUADRON-Assets werden als Single-Ship-DCS-Gruppen erzeugt:

```text
OH-58D RECON: 2 unabhängige Gruppen mit je 1 Luftfahrzeug
AH-64D CAS:   2 unabhängige Gruppen mit je 1 Luftfahrzeug
UH-60A:       1 Gruppe mit 1 Luftfahrzeug
CH-47F:       1 Gruppe mit 1 Luftfahrzeug
```

OH-58D und AH-64D bleiben fachlich Two-Ship-Pakete, besitzen aber zwei unabhängige Spawn-, Anflug-, Lande- und Despawn-Lebenszyklen.

### Exakte Laufzeitidentität

Eine Runtimegruppe wird nur akzeptiert, wenn ihr Name exakt zum zugewiesenen SQUADRON passt:

```text
Gruppe:  <SQUADRON-NAME>_AID-<Nummer>
Einheit: <GRUPPENNAME>-01
```

Der DCS-Typ allein darf niemals eine Missionsgruppe identifizieren. Client-, Player-, Template- und sonstige Missionseditorgruppen werden über ihre eindeutigen Gruppen- und Einheitennamen ausgeschlossen.

### SQUADRON-Konfiguration

```lua
squadron:SetGrouping(1)
squadron:SetParkingIDs(...)
squadron:SetTakeoffCold()
squadron:SetDespawnAfterLanding(true)
```

### Verbindliche Spawnpools

```text
OH-58D: G01-G05 / TerminalIDs 19,43,6,5,48
AH-64D: F04-F06 / TerminalIDs 26,51,11
UH-60A: F01-F03 / TerminalIDs 10,8,1
CH-47F: C03-C10 / TerminalIDs 28,44,0,41,9,25,18,42
```

### Bestandsmodell

Da jedes Asset eine Single-Ship-Gruppe ist, werden folgende vollständige Bestände erwartet:

```text
OH-58D: 24 Assetgruppen
AH-64D: 8 Assetgruppen
UH-60A: 8 Assetgruppen
CH-47F: 8 Assetgruppen
```

### Getrennte Zeitfenster

Die Teststeuerung verwendet getrennte Fristen:

```text
SpawnTimeout
ExecutionTimeout
RecoveryTimeout
ReleaseTimeout
```

Ein erfolgreicher Auftrag darf nicht mehr während einer noch laufenden ordnungsgemäßen RTB-/Recovery-Phase durch einen gemeinsamen Gesamt-Timeout beendet werden.

### Phase-1-Prüfpunkte

- Auftragserzeugung und AIRWING-Queue;
- Auswahl des festgelegten SQUADRONs und Payloads;
- exakte Runtime-Gruppen- und Einheitennamen;
- korrekte Anzahl unabhängiger Assetgruppen;
- korrekter DCS-Typ;
- Spawn ausschließlich im typbezogenen Parkplatzpool;
- Engine Start, Takeoff und Missionsausführung;
- fachliches Missionsziel;
- SUCCESS;
- RTB und unabhängige Landung aller Gruppen;
- Despawn nach jedem einzelnen Land-Ereignis;
- vollständige Bestandsfreigabe.

Phase 1 wird erst nach Einzel-PASS für OH-58D und AH-64D erneut als Gesamtablauf gestartet.

## 4. Phase 2 – COMMANDER und Jalalabad-Gesamtbetrieb

Nach Phase-1-PASS werden Aufträge über die echte Befehlskette übergeben:

```text
Auftragsbedarf -> COMMANDER -> AW_US_JALALABAD -> SQUADRON -> Assets
```

Zu testen sind insbesondere:

- fachlich korrektes SQUADRON;
- Ablehnung ungeeigneter Typen;
- Queue- und Bestandsverhalten;
- mindestens zwei parallele Aufträge;
- maximal zwei Unterstützungsmissionen;
- maximal vier aktive Unterstützungs-Luftfahrzeuge;
- vollständiger atomarer 1+1-MEDEVAC-Koordinator.

## 5. Phase 3 – Zweites AIRWING

Genau ein zweiter, funktional anderer Knoten wird vollständig aufgebaut. Kandidaten sind Bagram, Kandahar oder Camp Bastion.

Zu validieren sind:

- Fähigkeit und räumliche Eignung;
- getrennte lokale Bestände;
- getrennte typbezogene Parkressourcen;
- parallele Missionen an zwei Basen;
- nachvollziehbarer Fallback bei fehlenden Fähigkeiten oder Beständen.

## 6. Phase 4 – Rollout und Gesamtsystem

Nach dem Zwei-AIRWING-PASS werden die übrigen Basen jeweils mit eigenem Manifest umgesetzt:

```text
Bagram
Kandahar
Camp Bastion
Camp Dwyer
Khost
Tarinkot
Shindand
```

Der abschließende Systemtest umfasst mehrere AIRWINGs, lange Multiplayer-Laufzeiten, Verluste, erschöpfte Bestände, beschädigte Basen, Persistenz, Ramp-Neuverteilung, Combat Damage, Recovery und Replacement State.

## 7. Phase-1-Implementierungsdateien

```text
mission/tests/jalalabad-air-operations/src/05a-validate-squadron-parking-pools.lua
mission/tests/jalalabad-air-operations/src/05b-validate-runtime-name-contract.lua
mission/tests/jalalabad-air-operations/src/11-phase1-test-manifest.lua
mission/tests/jalalabad-air-operations/src/12-phase1-runtime-observer.lua
mission/tests/jalalabad-air-operations/src/13-phase1-mission-factory.lua
mission/tests/jalalabad-air-operations/src/14-phase1-test-controller.lua
mission/tests/jalalabad-air-operations/src/14a-phase1-lifecycle-corrections.lua
mission/tests/jalalabad-air-operations/src/14b-phase1-sequence-finalization.lua
mission/tests/jalalabad-air-operations/src/15-phase1-f10-and-acceptance.lua
mission/tests/jalalabad-air-operations/src/16-phase1-moose-compatibility.lua
```

Builder:

```text
tools/build-jalalabad-air-operations-bundle.ps1
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
```

## 8. Freigaberegel

Phase 1 ist erst abgeschlossen, wenn alle fünf Testfälle in einem dokumentierten DCS-Lauf PASS sind. Lua-Syntaxprüfung und statische Bundleprüfung ersetzen keinen DCS-Acceptance-Test.
