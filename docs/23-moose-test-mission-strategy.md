# 23 – Strategie für MOOSE-Testmissionen

## Ziel

Operation Mountain Watch verwendet eigenständige Testmissionen, um technische Risiken isoliert zu untersuchen, bevor die Mechaniken in die Kampagnenmission übernommen werden.

MOOSE wird bereits in der einfachsten physischen Teststufe als Orchestrierungs-, Routing-, Beobachtungs- und Debugschicht eingesetzt. Dadurch entstehen keine parallelen Vanilla- und MOOSE-Implementierungen derselben Mechanik.

Die DCS-KI bleibt für die tatsächliche Bewegung, Kollisionsbehandlung und Wegfindung physischer Gruppen verantwortlich. MOOSE weist Aufgaben zu, verwaltet Wrapper und Zustände, beobachtet den Ablauf und stellt reproduzierbare Teststeuerung bereit.

## Grundsatz

Jede zweistufige Testmission verwendet dieselbe physische Controllerlogik.

```text
Stufe A
MOOSE-gesteuert
vollständig physisch
keine Virtualisierung
fachlich minimal

Stufe B
identische physische Controller
plus virtueller Zustand
plus Materialisierung und Dematerialisierung
```

Stufe A ist keine skriptfreie Vanilla-Mission. Sie reduziert lediglich den Funktionsumfang:

- MOOSE ist geladen;
- Gruppen werden über MOOSE gefunden oder aus Mission-Editor-Templates erzeugt;
- Routen und Aufgaben werden über MOOSE zugewiesen;
- Zonen, Scheduler, Events, Logging und Debugmenüs werden über MOOSE verwaltet;
- CampaignState-Persistenz, Warehouses, Cargo Units, CTLD, CSAR und produktive Director-Logik bleiben deaktiviert.

## Gepinnte Framework-Baseline

Alle Testmissionen verwenden zunächst exakt dieselbe Frameworkbasis:

```text
MOOSE-Version: 2.9.18
Bezugsart: offizieller Release
Upstream-Tag: 2.9.18
Stable-Branch-Familie: master-ng
Include-Familie: Moose_Include_Static
Runtime-Datei: vendor/moose/Moose.lua
Build-Variante: lesbar und nicht komprimiert
```

Die Auswahl ist in `docs/24-moose-version-and-build-policy.md` und ADR 0010 dokumentiert.

Für diese Baseline gilt:

- kein automatischer Upstream-Download;
- kein direkter Laufzeitbezug auf `master-ng` oder `develop`;
- keine Dynamic Includes;
- keine gleichzeitige Einbindung von `Moose.lua` und `Moose_.lua`;
- keine lokale Bearbeitung der Vendor-Datei;
- Versions- und Buildprüfung beim Missionsstart;
- vollständige Regression aller Testmissionen nach einem MOOSE-Update.

Die komprimierte `Moose_.lua` ist kein anderer Funktionszweig. Sie darf später nur als alternative Distributionsfassung desselben Releases nach erneuter Testausführung eingeführt werden.

## Warum MOOSE ab Stufe A

- das Team lernt die später produktiv verwendeten Wrapper und Kontrollmuster;
- Mission-Editor-Templates, MOOSE-Namen und Laufzeitnamen werden früh validiert;
- Routing- und Zustandsbeobachtung entstehen nur einmal;
- die physische Referenzlogik kann in Stufe B unverändert wiederverwendet werden;
- Fehler lassen sich zwischen physischem Controller und Virtualisierungsschicht trennen;
- Debug- und Abnahmewerkzeuge werden von Beginn an standardisiert.

## Verwendete MOOSE-Bausteine

Abhängig vom Test werden insbesondere folgende MOOSE-Bereiche verwendet:

- `SPAWN` für Late-Activation-Templates;
- `GROUP` und `CONTROLLABLE` für physische Gruppen und Aufgaben;
- `SET_GROUP` für aktive Testgruppen;
- `ZONE` und verwandte Zonenkonzepte für Start, Ziel, Knoten und Reveal-Bereiche;
- `COORDINATE` für Straßenanker und geprüfte Pfade;
- `SCHEDULER` für Watchdogs, Dispatcher und Zustandsprüfungen;
- MOOSE-Eventbehandlung für Verluste und Gruppenende;
- `MENU_*` für reproduzierbare Testaktionen;
- `MESSAGE` sowie Projektlogging für sichtbare Zustandsmeldungen.

Die exakte API wird gegen die im Repository versionierte MOOSE-Fassung geprüft. Testcode verwendet keine aus Erinnerungen abgeleiteten oder ungeprüften Methodennamen.

Die vendorte `Moose.lua` ist die genaue Implementierungsreferenz. Die offizielle stabile Dokumentation ergänzt diese Referenz. Dokumentation des Entwicklungszweigs darf nicht ohne Quellprüfung für den gepinnten Release verwendet werden.

## Testreihen

### TM01 – Blauer Straßenkonvoi Bagram–Jalalabad

Stufe A prüft einen vollständig physischen, von MOOSE gestarteten und überwachten Konvoi auf einer validierten Hauptstraßenroute.

Stufe B führt denselben Konvoi im Metaraum und materialisiert ihn an zwei vorbereiteten Streckenabschnitten. Gruppenzusammensetzung, Verluste und Fortschritt müssen zwischen physischem und virtuellem Zustand erhalten bleiben.

### TM02 – Rote Relaisbewegung

Stufe A prüft eine vollständig physische Verteilung roter Personengruppen von einem zentralen Hauptquartier über mehrere Zwischenquartiere bis zum Zielraum Bagram.

Jeder Knoten behält eine Mindestbesatzung. Nur Überschüsse werden zum unmittelbar folgenden Knoten weitergeleitet. Höchstens drei Gruppen dürfen gleichzeitig marschieren.

Stufe B verwendet dieselbe Relaislogik, führt Bewegungen jedoch überwiegend virtuell aus. Eine Zwischenstelle sowie der Zielraum Bagram werden absichtlich materialisiert.

## Gemeinsame Architektur

```text
TestMissionController
├── TestMenu
├── DebugReporter
├── RouteRegistry
├── RouteMonitor
└── szenariospezifischer Controller
    ├── PhysicalMovementAdapter
    └── VirtualMovementAdapter, nur Stufe B
```

Der szenariospezifische Controller entscheidet über fachliche Zustände. Der physische Adapter übersetzt diese in MOOSE- und DCS-Gruppen. Der virtuelle Adapter berechnet Fortschritt, Zeit und Verluste ohne physische Gruppe.

## Verzeichnisstruktur

```text
mission/tests/
├── README.md
├── tm01-blue-convoy/
│   ├── README.md
│   └── config.lua
└── tm02-red-relay/
    ├── README.md
    └── config.lua
```

Später können je Test ergänzt werden:

```text
├── editor/
│   ├── TM01A-....miz
│   └── TM01B-....miz
├── src/
├── expected/
└── results/
```

`.miz`-Dateien werden ausschließlich über den DCS Mission Editor bearbeitet. Repository-Werkzeuge verändern ihre internen Archivdateien nicht direkt.

## Ladefolge

Jede Testmission verwendet eine deterministische Ladefolge:

```text
1. vendor/moose/Moose.lua
2. gemeinsames Projekt-Bootstrap
3. Testunterstützung
4. Testkonfiguration
5. szenariospezifischer Controller
6. Start des TestMissionController
```

Die Groß- und Kleinschreibung von `Moose.lua` wird beibehalten.

Fehlt MOOSE, stimmt die Frameworkversion nicht oder fehlt eine benötigte Templategruppe, muss die Mission mit einer eindeutigen Fehlermeldung abbrechen, statt stillschweigend auf andere Logik auszuweichen.

## Start- und Versionsprüfung

Beim Start protokolliert jede Testmission mindestens:

- Test-ID;
- Teststufe;
- geladene MOOSE-Version;
- geladene MOOSE-Buildvariante;
- Konfigurationsversion;
- verfügbare Pflichttemplates und Pflichtzonen.

Eine falsche oder nicht bestimmbare MOOSE-Version führt zu `FAIL_CONFIGURATION`.

## Debuganforderungen

Jede Testmission bietet mindestens:

- Test-ID und Versionskennung beim Start;
- sichtbaren aktuellen Szenariozustand;
- F10-Befehl zum Starten oder Zurücksetzen;
- Logging jedes Zustandswechsels;
- Kennzeichnung von Spawn-, Reveal-, Ziel- und Fehlerzonen;
- Erkennung doppelter physischer Gruppen;
- Zusammenfassung der Abnahmekriterien am Testende.

Stufe B darf Materialisierung für Beobachtungszwecke absichtlich sichtbar durchführen. Produktionsvirtualisierung muss später direkte Spielerbeobachtung vermeiden.

## Abgrenzung

Nicht Bestandteil der ersten Entwürfe:

- Cargo Units und tatsächliche Ladung;
- Warehouse-Transaktionen;
- Persistenz über Missionsneustarts;
- dynamische Feindkontakte;
- CTLD oder CSAR;
- automatische Reparatur festgefahrener Gruppen;
- produktive Spielerentfernungs- oder Sichtlinienlogik;
- vollständige CampaignState-Integration.

Diese Systeme werden erst nach stabiler physischer und virtueller Bewegungslogik zugeschaltet.

## Qualitätsregel

Stufe B darf keine zweite unabhängige Bewegungsimplementierung enthalten. Jede materialisierte Gruppe wird durch denselben physischen Controller geführt, der in Stufe A validiert wurde.

Ein Frameworkupdate gilt nicht als abgeschlossen, bevor die vorhandenen physischen und virtualisierten Teststufen mit dem neuen MOOSE-Stand erneut ausgeführt und dokumentiert wurden.
