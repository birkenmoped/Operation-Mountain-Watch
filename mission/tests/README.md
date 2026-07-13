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
- Ausgabe der erwarteten MOOSE-Provenienz, des Prüfmodus und der Test-ID beim Szenariostart.

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

## TM01A-Testbündel

Der TM01A-Bootstrap prüft beim Build den Hash der gepinnten MOOSE-Datei und validiert zur Laufzeit die benötigte API-Oberfläche sowie die Pflichtobjekte aus dem Mission Editor. Der nächste Meilenstein ergänzt ausschließlich das manuell ausgelöste, einmalige Erzeugen des physischen Testkonvois in der Bagram-Startzone. Er weist keine Route, Aufgabe oder Bewegung an. Das reproduzierbare Projekt-Skriptbündel wird mit

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-test-bundle.ps1
```

als `mission/tests/tm01-blue-convoy/dist/TM01A.lua` erzeugt. In der Mission wird zuerst `vendor/moose/Moose.lua` und danach genau dieses Bündel geladen.

TM01A kann die exakte Provenienz der tatsächlich von DCS geladenen MOOSE-Datei unter dieser Zwei-Dateien-Ladearchitektur nicht programmgesteuert bestimmen. Der Modus `BUILD_HASH_PLUS_RUNTIME_API_CHECK` bedeutet: Der Build bricht bei abweichendem Vendor-Hash ab, und die Laufzeit prüft die zehn verwendeten MOOSE-APIs. Commit und Zeitstempel der geladenen Datei werden manuell anhand des MOOSE-eigenen DCS-Log-Banners bestätigt.

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

Fehlende MOOSE-Laufzeit-APIs führen zu `FAIL_SCRIPT`. Eine fehlende Templategruppe oder Pflichtzone führt zu `FAIL_CONFIGURATION`. Eine exakte geladene MOOSE-Version oder Dateiprüfsumme wird in TM01A nicht automatisch verglichen.

## Startprotokoll

Jede Testmission protokolliert beim Start mindestens:

```text
Test-ID
Teststufe
DCS-Version, soweit verfügbar
Erwartete MOOSE-Version, Build-Commit und Build-Zeitstempel
Erwartete MOOSE-Include-Familie und Komprimierung
MOOSE-Prüfmodus
Konfigurationsversion
Startzeit
```

Ein abweichender lokaler `Moose.lua`-Hash verhindert bereits den Bundle-Build. Fehlende benötigte MOOSE-APIs ergeben zur Laufzeit `FAIL_SCRIPT`. Die exakte Provenienz der geladenen Datei wird in diesem Meilenstein manuell über das MOOSE-Log-Banner bestätigt.

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
