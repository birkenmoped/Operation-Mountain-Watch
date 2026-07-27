# MOOSE-Testmissionen

## Zweck

Dieses Verzeichnis sammelt isolierte DCS-Testmissionen, ihre Konfigurationen, Missionsbriefe, erwarteten Ergebnisse und spätere Testprotokolle.

Die Testmissionen sind keine Kampagnenreleases. Sie dienen dazu, einzelne technische und spielmechanische Risiken mit reproduzierbaren Eingaben zu untersuchen.

## Grundregel

Alle projektbezogenen Testmissionen verwenden MOOSE bereits in der ersten physischen Stufe.

```text
Stufe A
- MOOSE aktiv
- vollständig physisch
- keine Virtualisierung
- keine Persistenz
- keine Warehouse- oder Cargo-Logik

Stufe B
- identischer PhysicalController
- zusätzliche virtuelle Bewegung
- geplante Materialisierung und Dematerialisierung
```

## Verbindliche MOOSE-Baseline

Alle Testmissionen verwenden denselben gepinnten Frameworkstand:

```text
MOOSE-Version: 2.9.18
Bezugsart: Release
Upstream-Tag: 2.9.18
Upstream-Stable-Branch: master-ng
Include-Familie: Moose_Include_Static
Runtime-Datei: vendor/moose/Moose.lua
Komprimierung: keine
```

Maßgeblich sind:

- `docs/24-moose-version-and-build-policy.md`;
- `docs/adr/0010-pin-moose-release-and-readable-static-build.md`;
- `vendor/moose/VERSION.md`.

Für Testmissionen gilt:

- kein automatischer Download von MOOSE;
- kein direkter Bezug auf den aktuellen Stand von `master-ng` oder `develop`;
- keine Dynamic Includes;
- keine gleichzeitige Einbindung von `Moose.lua` und `Moose_.lua`;
- keine lokale Änderung der vendorten MOOSE-Datei;
- eindeutiger Abbruch, wenn MOOSE nicht geladen werden kann;
- Ausgabe der MOOSE-Version und Test-ID beim Szenariostart.

`Moose_.lua` darf erst nach einer getrennten Entscheidung und vollständiger Regression als alternative Distributionsfassung desselben Releases verwendet werden.

## Aktuelle Testreihen

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

### TM01 – Blauer Straßenkonvoi

Prüft die Führung eines blauen KI-Konvois von Bagram nach Jalalabad.

- Stufe A: vollständig physischer MOOSE-Konvoi;
- Stufe B: virtuelle Bewegung mit zwei geplanten Reveal-Abschnitten.

### TM02 – Rote Relaisbewegung

Prüft die Verteilung roter Personengruppen von einem zentralen Hauptquartier über Zwischenquartiere bis Bagram.

- Stufe A: vollständig physische Marschgruppen;
- Stufe B: virtueller Marsch mit einer Zwischenmaterialisierung und Materialisierung im Zielraum.

## Benennung

Missionsdateien:

```text
TM01A-MOOSE-Blue-Convoy-Physical.miz
TM01B-MOOSE-Blue-Convoy-Virtualized.miz
TM02A-MOOSE-Red-Relay-Physical.miz
TM02B-MOOSE-Red-Relay-Virtualized.miz
```

Mission-Editor-Gruppen:

```text
TPL_TEST_<COALITION>_<ROLE>_<VARIANT>
```

Beispiele:

```text
TPL_TEST_BLUE_CONVOY_STANDARD_01
TPL_TEST_RED_GARRISON_12_01
TPL_TEST_RED_PACKET_06_01
```

Zonen:

```text
ZONE_TM<NN>_<PURPOSE>_<INDEX>
```

Beispiele:

```text
ZONE_TM01_START_BAGRAM
ZONE_TM01_REVEAL_01
ZONE_TM02_NODE_03
ZONE_TM02_TARGET_BAGRAM
```

Stabile Testentitäten:

```text
TEST.<test-id>.<entity-role>.<sequence>
```

Beispiel:

```text
TEST.TM01.CONVOY.001
TEST.TM02.PACKET.014
```

## Erwartete Unterstruktur je Test

Sobald die Mission implementiert wird, kann der jeweilige Ordner erweitert werden:

```text
<test>/
├── README.md
├── config.lua
├── editor/
│   ├── <physical>.miz
│   └── <virtualized>.miz
├── src/
│   ├── controller.lua
│   └── virtualizer.lua
├── expected/
│   └── acceptance.md
└── results/
    └── YYYY-MM-DD-<dcs-version>.md
```

Leere Verzeichnisse werden nicht über `.gitkeep` angelegt. Sie entstehen, sobald echte Dateien vorhanden sind.

## Ladefolge

```text
1. vendor/moose/Moose.lua
2. Projekt-Bootstrap
3. gemeinsame Testunterstützung
4. Konfiguration des Tests
5. Controller des Tests
6. Start des Szenarios
```

Die Groß- und Kleinschreibung des Upstream-Dateinamens `Moose.lua` wird im Repository beibehalten.

Kein Projektskript darf MOOSE-Klassen verwenden, bevor Schritt 1 erfolgreich abgeschlossen wurde.

Ein fehlendes MOOSE-Skript, eine falsche Version, eine fehlende Templategruppe oder eine fehlende Pflichtzone führt zu einem eindeutigen Testabbruch.

## Startprotokoll

Jede Testmission protokolliert beim Start mindestens:

```text
Test-ID
Teststufe
DCS-Version, soweit verfügbar
MOOSE-Version
MOOSE-Buildvariante
Konfigurationsversion
Startzeit
```

Stimmt die geladene Frameworkversion nicht mit der Testbaseline überein, lautet das Ergebnis `FAIL_CONFIGURATION`.

## Gemeinsame Testfunktionen

Späterer gemeinsamer Testcode soll mindestens bereitstellen:

- Start, Pause und Reset über F10;
- strukturierte Logausgabe mit Test-ID;
- Zustandsanzeige und Fortschrittsmeldungen;
- Gruppen-, Zonen- und Templatevalidierung;
- MOOSE-Versions- und Ladeprüfung;
- Watchdog für Stillstand und fehlende Gruppen;
- Abschlussbericht für Abnahmekriterien;
- Erkennung doppelter physischer Instanzen.

## Testdisziplin

- Jede Mission prüft nur die in ihrem Missionsbrief genannten Systeme.
- Neue Systeme werden erst nach bestandener Baseline zugeschaltet.
- `.miz`-Dateien werden ausschließlich im DCS Mission Editor bearbeitet.
- Vendor-MOOSE wird für Testzwecke nicht verändert.
- Externe Lua-Dateien bleiben die bevorzugte Implementierungsform.
- Jede verwendete MOOSE-API wird gegen Release 2.9.18 beziehungsweise die vendorte Datei geprüft.
- Die `develop`-Dokumentation wird nicht als alleiniger Nachweis für eine Release-API verwendet.
- Eine bekannte DCS-Einschränkung wird dokumentiert und nicht durch stilles Teleportieren verborgen.
- Nach jedem MOOSE-Update werden alle vorhandenen MOOSE-Testmissionen erneut ausgeführt.

## Ergebnisstatus

Jeder Testlauf endet mit einem der folgenden Statuswerte:

```text
PASS
PASS_WITH_LIMITATION
FAIL_SCRIPT
FAIL_DCS_PATHFINDING
FAIL_CONFIGURATION
ABORTED
```

`PASS_WITH_LIMITATION` ist nur zulässig, wenn die Einschränkung reproduzierbar dokumentiert ist.
