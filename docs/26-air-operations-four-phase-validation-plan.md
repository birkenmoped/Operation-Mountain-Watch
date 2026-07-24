# 26 – Air Operations: verbindlicher Vier-Phasen-Validierungsplan

## 1. Status und Zweck

Dieses Dokument hält den verbindlichen Ausbau- und Validierungsplan für die MOOSE-AIRWING-/COMMANDER-Architektur von **Operation Mountain Watch** fest.

```text
Jalalabad-Grundknoten: OPERATIONAL / ACCEPTED
Phase 1 Testpaket: IMPLEMENTED / DCS VALIDATION PENDING
Implementierungsbranch: feature/jalalabad-airwing-phase1-functional-tests
```

Der validierte Grundknoten wird durch die Folgetests nicht erneut geöffnet, solange keine Regression nachgewiesen wird.

## 2. Phase 1 – Jalalabad AIRWING und SQUADRONs

Jalalabad bleibt der einzige operative Testknoten. Aufträge werden kontrolliert und direkt an `AW_US_JALALABAD` übergeben. Der COMMANDER bleibt gestartet, erzeugt und verteilt in dieser Phase aber keine Aufträge.

Verbindliche Reihenfolge:

```text
1. OH-58D Two-Ship -> RECON
2. AH-64D Two-Ship -> CAS
3. UH-60A Single-Ship -> TROOPTRANSPORT
4. CH-47F Single-Ship -> CARGOTRANSPORT
5. UH-60A -> definierter Abbruch nach Spawn
```

Für jeden regulären Auftrag werden geprüft:

- Auftragserzeugung und AIRWING-Queue,
- Auswahl des festgelegten SQUADRONs und Payloads,
- Reservierung genau einer Asset-Gruppe,
- korrekte Gruppengröße und korrekter DCS-Typ,
- Spawn außerhalb der CH-47-Blacklist und der Clientpositionen,
- Engine Start, Takeoff und Missionsausführung,
- fachliches Missionsziel,
- RTB und Landung in Jalalabad,
- Despawn beziehungsweise Rücklagerung,
- vollständige Bestandsfreigabe.

Der Abbruchtest muss nachweisen, dass eine bereits reservierte und gespawnte UH-60-Asset-Gruppe ohne Start dauerhaft freigegeben wird.

Phase 1 verwendet ein gemeinsames F10-gesteuertes Testpaket und keine Folge isolierter Einzelbundles.

## 3. Phase 2 – COMMANDER und Jalalabad-Gesamtbetrieb

Nach Phase-1-PASS werden Aufträge über die echte Befehlskette übergeben:

```text
Auftragsbedarf -> COMMANDER -> AW_US_JALALABAD -> SQUADRON -> Assets
```

Zu testen sind insbesondere:

- fachlich korrektes SQUADRON,
- Ablehnung ungeeigneter Typen,
- Queue- und Bestandsverhalten,
- mindestens zwei parallele Aufträge,
- maximal zwei Unterstützungsmissionen,
- maximal vier aktive Unterstützungs-Luftfahrzeuge,
- vollständiger atomarer 1+1-MEDEVAC-Koordinator.

## 4. Phase 3 – Zweites AIRWING

Genau ein zweiter, funktional anderer Knoten wird vollständig aufgebaut. Kandidaten sind Bagram, Kandahar oder Camp Bastion.

Zu validieren sind:

- Fähigkeit und räumliche Eignung,
- getrennte lokale Bestände,
- getrennte Parkressourcen,
- parallele Missionen an zwei Basen,
- nachvollziehbarer Fallback bei fehlenden Fähigkeiten oder Beständen.

## 5. Phase 4 – Rollout und Gesamtsystem

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

## 6. Phase-1-Implementierungsdateien

```text
mission/tests/jalalabad-air-operations/src/11-phase1-test-manifest.lua
mission/tests/jalalabad-air-operations/src/12-phase1-runtime-observer.lua
mission/tests/jalalabad-air-operations/src/13-phase1-mission-factory.lua
mission/tests/jalalabad-air-operations/src/14-phase1-test-controller.lua
mission/tests/jalalabad-air-operations/src/15-phase1-f10-and-acceptance.lua
mission/tests/jalalabad-air-operations/src/16-phase1-moose-compatibility.lua
```

Builder:

```text
tools/build-jalalabad-air-operations-bundle.ps1
BuilderVersion: JBAD-AIR-OPS-PHASE1-1
```

Acceptance- und Missionseditorvorgaben:

```text
mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-airwing-functional-acceptance.md
mission/tests/jalalabad-air-operations/expected/jalalabad-phase1-mission-editor-worklist.md
```

## 7. Freigaberegel

Phase 1 ist erst abgeschlossen, wenn alle fünf Testfälle in einem dokumentierten DCS-Lauf PASS sind. Eine erfolgreiche Lua-Syntaxprüfung oder Bundle-Erzeugung ersetzt keinen DCS-Acceptance-Test.
