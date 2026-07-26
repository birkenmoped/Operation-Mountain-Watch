# MOOSE-Testmissionen

## Verbindliche Governance

Alle Dateien und Testreihen unter `mission/tests/` unterliegen [`mission/tests/GOVERNANCE.md`](GOVERNANCE.md) und der projektweiten Regel [`GOV-001`](../../docs/00-project-governance.md).

Operation Mountain Watch ist MOOSE-first. Jede Testmechanik muss zuerst alle verfügbaren und anwendbaren MOOSE-Funktionen, Klassen und Framework-Muster als technischen Grundstock verwenden. Mehrere MOOSE-Mechanismen werden kombiniert, wenn eine einzelne Funktion nicht vollständig ausreicht.

MOOSE-Grenzen, Nachteile und Alternativen dürfen jederzeit untersucht und diskutiert werden. Eine native DCS-, Eigen- oder Hybridlösung darf jedoch nur nach dokumentierter MOOSE-Prüfung und ausdrücklicher Genehmigung durch den Projektinhaber als akzeptierte Implementierung verwendet werden. Diese Entscheidung kann nicht aus einem Testergebnis oder einer technischen Empfehlung abgeleitet werden.

## Zweck

Dieses Verzeichnis sammelt isolierte DCS-Testmissionen, ihre Konfigurationen, Missionsbriefe, erwarteten Ergebnisse und Testprotokolle.

Die Testmissionen sind keine Kampagnenreleases. Sie untersuchen einzelne technische und spielmechanische Risiken mit reproduzierbaren Eingaben.

## Grundregel

Alle projektbezogenen Testmissionen verwenden MOOSE bereits in der ersten physischen Stufe.

```text
Stufe A
- MOOSE aktiv
- vollständig physische Laufzeitrepräsentation
- keine Virtualisierung
- keine Persistenz
- keine Warehouse- oder Cargo-Logik

Stufe B
- flüchtiger CampaignState im Arbeitsspeicher
- kontrollierte Dematerialisierung
- keine physische Gruppe während der virtuellen Phase
- kontrollierte Materialisierung
- keine Persistenz über Missions- oder Serverneustart

spätere Persistenzstufe
- versionierter Snapshot
- Backup-Recovery
- Wiederherstellung stabiler IDs nach Neustart
- idempotente Transaktionen
```

Persistenz wird erst Bestandteil einer Teststufe, wenn Neustartwiederherstellung oder dauerhafte Transaktionen zu deren Abnahmekriterien gehören.

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

- `docs/00-project-governance.md`;
- `docs/23-moose-test-mission-strategy.md`;
- `docs/24-moose-version-and-build-policy.md`;
- `docs/adr/0009-use-moose-from-first-test-stage.md`;
- `docs/adr/0010-pin-moose-release-and-readable-static-build.md`;
- `vendor/moose/VERSION.md`.

Für Testmissionen gilt:

- kein automatischer Download von MOOSE;
- kein direkter Bezug auf den jeweils aktuellen Stand von `master-ng` oder `develop`;
- keine Dynamic Includes;
- keine gleichzeitige Einbindung von `Moose.lua` und `Moose_.lua`;
- keine lokale Änderung der vendorten MOOSE-Datei;
- eindeutiger Abbruch, wenn MOOSE nicht geladen werden kann;
- Ausgabe der erwarteten MOOSE-Provenienz, des Prüfmodus und der Test-ID beim Szenariostart;
- keine stille Umgehung einer verfügbaren MOOSE-Funktion;
- keine akzeptierte native DCS- oder Eigenlösung ohne ausdrückliche Projektinhaberentscheidung.

`Moose_.lua` darf erst nach einer getrennten Entscheidung und vollständiger Regression als alternative Distributionsfassung desselben Releases verwendet werden.

## Aktuelle Testreihen

```text
mission/tests/
├── README.md
├── GOVERNANCE.md
├── tm01-blue-convoy/
│   ├── README.md
│   ├── config.lua
│   ├── expected/
│   └── results/
├── tm02-red-relay/
│   ├── README.md
│   └── config.lua
└── tm02-red-network/
    ├── README.md
    ├── expected/
    └── results/
```

### TM01 – Blauer Straßenkonvoi

TM01 verwendet Bagram–Jalalabad als technische Stress- und Regressionsteststrecke.

```text
TM01A
- kontrollierter MOOSE-Bootstrap: PASS
- kontrollierter physischer Spawn: PASS
- kontrollierte physische Gesamtroute bis Jalalabad: PASS
- dokumentierte Einschränkung: erheblicher DCS-Straßenumweg

TM01B.1
- nächster Meilenstein
- kontrollierter Cache-Zyklus
- flüchtiger In-Memory-CampaignState
- manuelle Dematerialisierung und Materialisierung
- keine Neustartpersistenz
```

Die erfolgreiche physische Gesamtfahrt ist abgeschlossen. Die ungewöhnliche konkrete Routenführung ist eine dokumentierte DCS-Pathfinding-Grenze und kein fehlender TM01A-Test.

### TM02 – Rote Relais- und Netzwerkbewegung

TM02 untersucht die Verteilung roter Personengruppen von einem zentralen Hauptquartier über Zwischenquartiere und später über ein kostenbewertetes Netzwerk.

- Stufe A: vollständig physische Marschgruppen;
- Stufe B: virtueller Marsch mit kontrollierter Zwischenmaterialisierung und Materialisierung im Zielraum;
- spätere TM02W-Stufen: getrennte Kommando-, Bewegungs- und Personalnetze sowie begrenzte Commander-Entscheidungen.

Jede TM02-Recovery-, Pack-/Unpack-, Materialisierungs-, Spawn-, Respawn-, Teleport- und Routingentscheidung muss die verfügbaren MOOSE-Mechanismen zuerst prüfen und verwenden.

## TM01A-Testbündel

Der TM01A-Bootstrap prüft beim Build den Hash der gepinnten MOOSE-Datei und validiert zur Laufzeit die benötigte API-Oberfläche sowie die Pflichtobjekte aus dem Mission Editor.

Die akzeptierte Stufe umfasst:

- manuell ausgelösten, einmaligen physischen Spawn;
- getrennten manuellen Routenstart;
- sieben geordnete Routenanker plus Jalalabad-Zielzone;
- genau eine Routenzuweisung;
- Erkennung der vollständigen Ankunft;
- Schutz gegen doppelte Spawn- und Routenbefehle.

Das reproduzierbare Projekt-Skriptbündel wird mit

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-test-bundle.ps1
```

als `mission/tests/tm01-blue-convoy/dist/TM01A.lua` erzeugt. In der Mission wird zuerst `vendor/moose/Moose.lua` und danach genau dieses Bündel geladen.

TM01A kann die exakte Provenienz der tatsächlich von DCS geladenen MOOSE-Datei unter dieser Zwei-Dateien-Ladearchitektur nicht programmgesteuert bestimmen. Der Modus `BUILD_HASH_PLUS_RUNTIME_API_CHECK` bedeutet:

- Der Build bricht bei abweichendem Vendor-Hash ab.
- Die Laufzeit prüft die verwendeten MOOSE-APIs.
- Commit und Zeitstempel der geladenen Datei werden manuell anhand des MOOSE-eigenen DCS-Log-Banners bestätigt.

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
ZONE_TM01_REVEAL_01_ENTRY
ZONE_TM01_REVEAL_01_EXIT
ZONE_TM02_NODE_03
ZONE_TM02_TARGET_BAGRAM
```

Stabile Testentitäten:

```text
TEST.<test-id>.<entity-role>.<sequence>
```

Beispiele:

```text
TEST.TM01.CONVOY.001
TEST.TM02.PACKET.014
```

## Erwartete Unterstruktur je Test

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
    └── YYYY-MM-DD-<stage>-<purpose>.md
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

Fehlende MOOSE-Laufzeit-APIs führen zu `FAIL_SCRIPT`. Eine fehlende Templategruppe oder Pflichtzone führt zu `FAIL_CONFIGURATION`. Eine exakte geladene MOOSE-Version oder Datei-Prüfsumme wird nicht automatisch mit dem Bundle verglichen.

Es gibt keinen automatischen Fallback auf native DCS- oder Eigenlogik. Ein solcher Pfad muss nach GOV-001 ausdrücklich entschieden und dokumentiert sein.

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

Ein abweichender lokaler `Moose.lua`-Hash verhindert bereits den Bundle-Build. Fehlende benötigte MOOSE-APIs ergeben zur Laufzeit `FAIL_SCRIPT`. Die exakte Provenienz der geladenen Datei wird manuell über das MOOSE-Log-Banner bestätigt.

## Gemeinsame Testfunktionen

Gemeinsamer Testcode stellt nur Funktionen bereit, die für die jeweilige Stufe tatsächlich implementiert und abgenommen sind.

Mögliche Bausteine:

- strukturierte Logausgabe mit Test-ID;
- Zustandsanzeige und Fortschrittsmeldungen;
- Gruppen-, Zonen- und Templatevalidierung;
- MOOSE-Versions- und Ladeprüfung;
- Erkennung doppelter physischer Instanzen;
- kontrollierte F10-Testbefehle;
- Abschlussbericht für Abnahmekriterien;
- Dokumentation der verwendeten MOOSE-Bausteine und jeder genehmigten Ausnahme.

Stop, Pause, Reset, Watchdog oder automatische Recovery sind keine impliziten Bestandteile. Sie benötigen einen eigenen Testvertrag, bevor sie implementiert werden. Der Testvertrag beginnt mit der Prüfung der dafür verfügbaren MOOSE-Funktionen.

## Testdisziplin

- Jede Mission prüft nur die in ihrem Missionsbrief genannten Systeme.
- Neue Systeme werden erst nach bestandener Baseline zugeschaltet.
- `.miz`-Dateien werden ausschließlich im DCS Mission Editor bearbeitet.
- Vendor-MOOSE wird für Testzwecke nicht verändert.
- Externe Lua-Dateien bleiben die bevorzugte Implementierungsform.
- Jede verwendete MOOSE-API wird gegen Release 2.9.18 beziehungsweise die vendorte Datei geprüft.
- Die `develop`-Dokumentation wird nicht als alleiniger Nachweis für eine Release-API verwendet.
- Eine bekannte DCS-Einschränkung wird dokumentiert und nicht durch stilles Teleportieren verborgen.
- Verfügbare MOOSE-Teleport-, Respawn-, Spawn-, Tasking-, Routing- oder Lifecycle-Funktionen werden vor einer eigenen Lösung getestet.
- `CampaignState` bleibt bei virtualisierten Entitäten autoritativ.
- Eine Entität darf nicht gleichzeitig virtuell und physisch autoritativ sein.
- Nach jedem MOOSE-Update werden alle vorhandenen MOOSE-Testmissionen erneut ausgeführt.
- Ein statischer Codecheck oder Bundle-Build ist kein DCS-Acceptance-Nachweis.
- Eine native DCS-, Eigen- oder Hybridlösung ohne dokumentierte MOOSE-Prüfung und Projektinhaberfreigabe ist ein Akzeptanzfehler.

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

`PASS_WITH_LIMITATION` ist nur zulässig, wenn die Einschränkung reproduzierbar dokumentiert ist. Eine dokumentierte Einschränkung erteilt keine Freigabe für eine Nicht-MOOSE-Lösung.
