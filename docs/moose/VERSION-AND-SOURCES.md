# MOOSE-Version und Quellen

## 1. Grundsatz

Die MOOSE-Dokumentation, der MOOSE-Quellcode und die tatsächlich in der DCS-Mission geladene `Moose.lua` müssen zueinander passen.

Eine Methode, die nur in der Develop-Dokumentation vorhanden ist, darf nicht als verfügbar vorausgesetzt werden, wenn die Mission einen älteren Master-/Release-Stand lädt.

## 2. Quellenhierarchie

Bei widersprüchlichen oder unvollständigen Angaben gilt folgende Prüf- und Entscheidungsreihenfolge:

1. tatsächlich in der Testmission geladene `Moose.lua`,
2. zugehöriger MOOSE-Branch und möglichst genauer Commit,
3. MOOSE-Quellcode dieses Commits,
4. dazu passende generierte Klassendokumentation,
5. offizielle Demo- und Testmissionen desselben oder eines nachweislich kompatiblen Stands,
6. ältere Guides, Forumseinträge und sonstige Beispiele nur als ergänzende Hinweise.

## 3. Offizielle Quellen

| Zweck | Quelle |
|---|---|
| Develop-Klassenreferenz | <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/index.html> |
| Stable-/Master-Klassenreferenz | <https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/> |
| MOOSE-Quellrepository | <https://github.com/FlightControl-Master/MOOSE> |
| Demo-Missionen | <https://github.com/FlightControl-Master/MOOSE_MISSIONS> |
| Ungepackte Demo-Missionen | <https://github.com/FlightControl-Master/MOOSE_MISSIONS_UNPACKED> |

## 4. Verbindlich zu erfassende Versionsdaten

Jeder neue MOOSE-basierte Acceptance-Bericht muss mindestens enthalten:

```text
MOOSE branch:        <master/develop/anderer Branch>
MOOSE commit:        <vollständiger Commit-SHA>
Moose.lua SHA-256:   <Hash der tatsächlich geladenen Datei>
Dokumentationsstand: <Stable oder Develop plus Abrufdatum>
OMW branch:          <Projektbranch>
OMW commit:          <vollständiger Commit-SHA>
Mission:             <Missionsdatei>
```

Ist ein Git-Commit der geladenen `Moose.lua` technisch nicht ermittelbar, müssen mindestens Dateihash, Bezugsquelle und Bezugsdatum festgehalten werden.

## 5. Aktueller Nachweisstand

### Jalalabad Air Operations Acceptance

Der bestehende PASS-Bericht bestätigt die Funktion der eingesetzten MOOSE-Klassen mit der während des Tests geladenen `Moose.lua`.

Der genaue MOOSE-Branch, MOOSE-Commit und Hash der geladenen `Moose.lua` wurden im ursprünglichen Acceptance-Bericht jedoch nicht festgehalten. Damit ist das Laufzeitverhalten nachgewiesen, die exakte Rückverfolgbarkeit auf einen MOOSE-Upstream-Stand aber noch offen.

Diese historische Nachweislücke darf nicht durch eine Vermutung oder durch den aktuellsten MOOSE-Stand ersetzt werden.

Für alle folgenden Teststufen ist die Erfassung der Versionsdaten verpflichtend.

Referenz:

- [`Jalalabad complete Air Operations node: PASS`](../../mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md)

## 6. Umgang mit Develop-Funktionen

Eine Funktion aus `MOOSE_DOCS_DEVELOP` darf verwendet werden, wenn:

1. die geladene MOOSE-Version die Methode tatsächlich enthält,
2. Signatur und Voraussetzungen im Quellcode geprüft wurden,
3. die Verwendung im Projekt dokumentiert ist,
4. ein reproduzierbarer DCS-Test durchgeführt wird.

Der bloße Umstand, dass eine Methode auf der Develop-Webseite dokumentiert ist, ist kein ausreichender Kompatibilitätsnachweis.

## 7. Aktualisierung

Bei einem Wechsel der MOOSE-Version oder des MOOSE-Branches sind mindestens zu prüfen:

- alle Einträge mit Status `VALIDATED` in `PROJECT-CLASS-INDEX.md`,
- alle Signaturen in `VERIFIED-METHODS.md`,
- FSM-Eventnamen und Callback-Signaturen,
- Konstruktoren und Startreihenfolgen,
- Warehouse-, Parking-, Transport- und Spawnverhalten,
- vorhandene Workarounds und direkte Zugriffe auf Interna.

Eine neue MOOSE-Version übernimmt nicht automatisch den Validierungsstatus der vorherigen Version.