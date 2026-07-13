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
1. vendor/moose/MOOSE.lua
2. Projekt-Bootstrap
3. gemeinsame Testunterstützung
4. Konfiguration des Tests
5. Controller des Tests
6. Start des Szenarios
```

Ein fehlendes MOOSE-Skript, eine fehlende Templategruppe oder eine fehlende Pflichtzone führt zu einem eindeutigen Testabbruch.

## Gemeinsame Testfunktionen

Späterer gemeinsamer Testcode soll mindestens bereitstellen:

- Start, Pause und Reset über F10;
- strukturierte Logausgabe mit Test-ID;
- Zustandsanzeige und Fortschrittsmeldungen;
- Gruppen-, Zonen- und Templatevalidierung;
- Watchdog für Stillstand und fehlende Gruppen;
- Abschlussbericht für Abnahmekriterien;
- Erkennung doppelter physischer Instanzen.

## Testdisziplin

- Jede Mission prüft nur die in ihrem Missionsbrief genannten Systeme.
- Neue Systeme werden erst nach bestandener Baseline zugeschaltet.
- `.miz`-Dateien werden ausschließlich im DCS Mission Editor bearbeitet.
- Vendor-MOOSE wird für Testzwecke nicht verändert.
- Externe Lua-Dateien bleiben die bevorzugte Implementierungsform.
- Jede verwendete MOOSE-API wird gegen die versionierte Fassung geprüft.
- Eine bekannte DCS-Einschränkung wird dokumentiert und nicht durch stilles Teleportieren verborgen.

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
