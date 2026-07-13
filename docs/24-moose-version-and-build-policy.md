# 24 – MOOSE-Version und Build-Variante

## Ziel

Dieses Dokument legt fest, aus welchem Upstream-Stand und in welcher Build-Variante Operation Mountain Watch das MOOSE-Framework verwendet.

Die Entscheidung soll gleichzeitig erreichen:

- reproduzierbare Test- und Produktionsmissionen;
- nachvollziehbare API-Dokumentation;
- gute Fehlersuche während der Entwicklung;
- kontrollierte Framework-Updates;
- keine unbemerkte Abhängigkeit von einem beweglichen Upstream-Branch.

## Offizieller Upstream-Aufbau

MOOSE unterscheidet drei relevante Bezugsarten:

### Release

Ein Release ist ein versionierter, unveränderlicher Stand. Releases werden aus dem stabilen Branch erzeugt und sind die bevorzugte Grundlage für reproduzierbare Missionen.

### `master-ng`

`master-ng` ist der aktuelle stabile Upstream-Branch und zugleich der Default-Branch des MOOSE-Repositorys.

Der Branch kann sich nach jedem neuen Commit ändern. Ein direkter Bezug auf den jeweils aktuellen Branchzustand ist deshalb weniger reproduzierbar als ein Release.

### `develop`

`develop` ist der sekundäre Entwicklungszweig. Neue Klassen und Änderungen können dort vor einer Übernahme in den stabilen Branch verfügbar sein.

Der Entwicklungszweig wird nicht regulär für Operation Mountain Watch verwendet.

## Projektentscheidung

Operation Mountain Watch verwendet zunächst:

```text
Framework: MOOSE
Version: 2.9.18
Bezugsart: Release
Upstream-Tag: 2.9.18
Upstream-Stable-Branch: master-ng
Build-Familie: Moose_Include_Static
Ausgewählte Datei: Moose.lua
Komprimierung: keine
```

Die Entscheidung ist in ADR 0010 festgehalten.

## Warum ein Release

Ein gepinnter Release verhindert, dass sich das Framework ohne Änderung im Projekt-Repository verändert.

Damit gelten für alle Entwickler, Testmissionen und Server dieselben:

- Klassen und Methoden;
- Funktionssignaturen;
- Bugfixes und bekannte Einschränkungen;
- Logmeldungen;
- CTLD- und CSAR-Verhaltensstände;
- Spawn-, Routing- und Eventimplementierungen.

Ein Update von MOOSE ist eine bewusste Projektänderung und kein automatischer Downloadvorgang.

## Statische Include-Dateien

Das offizielle `MOOSE_INCLUDE`-Repository stellt unter `Moose_Include_Static` zwei erzeugte Ein-Datei-Fassungen bereit:

```text
Moose.lua
Moose_.lua
```

### `Moose.lua`

`Moose.lua` ist die statische, lesbare Ausgabe des MOOSE-Builds.

Eigenschaften:

- Kommentare und LuaDoc-Inhalte bleiben im erzeugten Code erhalten;
- Klassen, Methoden und Logstellen können direkt durchsucht werden;
- Stacktraces und Fehlermeldungen lassen sich leichter gegen den Frameworkcode prüfen;
- die Datei ist größer als die komprimierte Variante;
- der Funktionsumfang entspricht dem Buildstand des gewählten Releases.

Operation Mountain Watch verwendet diese Variante zunächst für Entwicklung, Testmissionen und Serverbetrieb.

### `Moose_.lua`

`Moose_.lua` wird im offiziellen Buildprozess mit LuaSrcDiet aus der erzeugten MOOSE-Fassung komprimiert.

Dabei werden insbesondere nicht erforderliche Kommentare, Formatierung und Leerraum reduziert. Die Datei ist für eine kleinere Distributionsgröße vorgesehen, enthält aber keinen zusätzlichen Frameworkumfang.

`Moose_.lua` darf später nur verwendet werden, wenn:

1. sie aus genau demselben Release wie die getestete `Moose.lua` stammt;
2. ihre Herkunft und SHA-256-Prüfsumme dokumentiert sind;
3. alle relevanten Testmissionen erneut ausgeführt wurden;
4. nur die Include-Variante und nicht gleichzeitig die MOOSE-Version geändert wird.

## Keine doppelte Einbindung

Eine Mission lädt genau eine statische MOOSE-Include-Datei:

```text
erlaubt: Moose.lua
oder:    Moose_.lua

verboten: beide Dateien in derselben Mission
```

Eine doppelte Einbindung kann globale Klassen, Tabellen, Scheduler und Frameworkzustände mehrfach initialisieren und ist deshalb nicht zulässig.

## Dynamic Includes

Der offizielle Build erzeugt zusätzlich eine dynamische Include-Variante, die einzelne MOOSE-Klassendateien lädt.

Diese Variante richtet sich primär an MOOSE-Frameworkentwickler und wird nicht als Laufzeitabhängigkeit der Kampagnen- oder Testmissionen verwendet.

Für Operation Mountain Watch gilt:

```text
Moose_Include_Static: erlaubt
Moose_Include_Dynamic: nicht für Missionslaufzeit verwenden
```

## Repository-Struktur

Die vorgesehene Vendor-Struktur lautet:

```text
vendor/moose/
├── Moose.lua
├── VERSION.md
└── LICENSE
```

Die exakte Groß- und Kleinschreibung des Upstream-Dateinamens wird beibehalten:

```text
Moose.lua
```

Die Vendor-Datei wird nicht lokal verändert.

Eine optionale spätere Distributionsfassung darf ergänzen:

```text
vendor/moose/
├── Moose.lua
├── Moose_.lua
├── VERSION.md
└── LICENSE
```

## Versionsmetadaten

`vendor/moose/VERSION.md` enthält mindestens:

- Frameworkname;
- Releaseversion;
- Upstream-Tag;
- Upstream-Branch, aus dem der Release stammt;
- ausgewählte Include-Familie;
- ausgewählte Datei;
- Komprimierungsstatus;
- Abrufdatum;
- SHA-256-Prüfsumme jeder vendorten Datei;
- Upstream-Quellen;
- Import- und Lizenzstatus.

Fehlt die tatsächliche Vendor-Datei noch, wird die Prüfsumme als `PENDING_IMPORT` geführt. Es wird keine erfundene Prüfsumme eingetragen.

## Ladefolge

Alle Test- und Kampagnenmissionen verwenden eine deterministische Ladefolge:

```text
1. vendor/moose/Moose.lua
2. Projekt-Bootstrap
3. gemeinsame Infrastruktur und Adapter
4. Szenario- oder Testkonfiguration
5. Controller und Systeme
6. Szenariostart
```

Kein Projektskript darf MOOSE-Klassen verwenden, bevor die ausgewählte Include-Datei erfolgreich geladen wurde.

Ein fehlendes oder fehlerhaftes MOOSE-Include führt zu einem eindeutigen Abbruch mit Logmeldung. Es gibt keinen stillen Rückfall auf eine parallele Vanilla-Steuerung.

## Dokumentations- und API-Regel

Für die Entwicklung werden drei Quellen in dieser Reihenfolge verwendet:

1. die im Projekt vendorte `Moose.lua` als genaue Implementierungsreferenz;
2. die offizielle stabile MOOSE-Dokumentation;
3. offizielle MOOSE-Beispiele und Demo-Missionen für denselben oder einen kompatiblen Versionsstand.

Die `develop`-Dokumentation ist keine ausreichende Grundlage für einen API-Aufruf gegen Release 2.9.18.

Jede verwendete Methode wird gegen die gepinnte Frameworkdatei oder die passende stabile Dokumentation geprüft.

## Einsatz von `develop`

Ein Wechsel oder eine Teilübernahme aus `develop` ist nur als dokumentierte Ausnahme zulässig.

Erforderlich sind:

- eine konkrete fehlende Funktion oder Fehlerkorrektur;
- ein eigener ADR;
- der exakte vollständige Commit-SHA;
- eine dokumentierte Abweichung vom Release;
- ein Rückfallpfad auf den gepinnten Release;
- vollständige Regressionstests der betroffenen Test- und Kampagnenmechaniken.

Ein Bezug auf den unfixierten Branchnamen `develop` ist nicht zulässig.

## Updateverfahren

Ein MOOSE-Update wird als eigener Änderungsvorgang behandelt:

1. neuen offiziellen Release identifizieren;
2. Release Notes und entfernte oder geänderte APIs prüfen;
3. neue Include-Datei und Lizenz in einem separaten Branch aktualisieren;
4. `VERSION.md` und SHA-256-Prüfsummen aktualisieren;
5. Lua-Syntax- und statische Prüfungen ausführen;
6. TM01A und TM01B ausführen;
7. TM02A und TM02B ausführen;
8. CTLD-, CSAR-, Cargo-, Warehouse- und Virtualisierungstests ausführen, sobald vorhanden;
9. DCS-Logdateien auf neue Fehler und Warnungen prüfen;
10. erst nach erfolgreicher Regression in die Kampagnenbasis übernehmen.

Version und Build-Variante werden nicht gleichzeitig geändert, sofern dies für den Test nicht ausdrücklich erforderlich ist.

## Quellen

Offizielle Referenzen:

- https://github.com/FlightControl-Master/MOOSE/releases
- https://flightcontrol-master.github.io/MOOSE/
- https://github.com/FlightControl-Master/MOOSE_INCLUDE/tree/master/Moose_Include_Static
- https://flightcontrol-master.github.io/MOOSE/developer/buildsystem/build-includes.html
