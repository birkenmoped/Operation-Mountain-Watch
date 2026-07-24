# Jalalabad Air Operations

## Status

Der lokale Air-Ops-Grundknoten Jalalabad / FOB Fenty ist vollständig aufgebaut und im DCS-Gesamttest validiert.

```text
Grundknoten: OPERATIONAL / ACCEPTED
Taktische Phase-1-Funktionstests: IMPLEMENTED / DCS VALIDATION PENDING
Finaler akzeptierter Grundknoten-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
Grundknoten-BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
Aktueller funktionaler Paketvertrag: JBAD-AIR-OPS-PHASE1-7
```

Die Grundknoten-Abnahme belegt AIRWING-/SQUADRON-Aufbau, Parking, Warehouse, COMMANDER und fehlerfreien Leerlauf. Sie belegt nicht automatisch die korrekte taktische Ausführung von RECON, CAS, TROOPTRANSPORT, CARGOTRANSPORT oder MEDEVAC.

Die späteren taktischen Tests deckten mehrere Architektur- und Testfehler auf. Deren Ursachen, Fehlannahmen und verbindliche Schutzregeln sind hier dokumentiert:

```text
../../../docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md
expected/jalalabad-phase1-package-contract.md
expected/jalalabad-phase1-architecture-regression-checklist.md
```

Diese drei Dokumente sind vor jeder weiteren Air-Operations-Implementierung und vor der Übertragung auf einen anderen Flugplatz verbindlich zu lesen.

Finales Ergebnis des akzeptierten Grundknotens:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Autoritative Dokumente:

```text
../../../docs/21-jalalabad-air-operations-manifest.md
../../../docs/23-jalalabad-parking-template-and-medevac-model.md
../../../docs/24-jalalabad-ch47-static-parking-reservations.md
../../../docs/25-jalalabad-final-validation-and-operational-baseline.md
../../../docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md
expected/jalalabad-complete-node-acceptance.md
expected/jalalabad-phase1-package-contract.md
expected/jalalabad-phase1-architecture-regression-checklist.md
results/2026-07-24-jalalabad-complete-node-pass.md
```

## Verbindliche Ebenentrennung

Folgende Dinge sind getrennte Ebenen und dürfen weder in Code, Logs noch Dokumentation vermischt werden:

```text
logischer Flugzeugbestand
MOOSE-Templates als technische Kopiervorlagen
physische dynamische DCS-Gruppen / MOOSE-Assets
sichtbare statische Bestandsmaschinen
Client-Gruppen und deren Parkpositionen
taktische Pakete aus einer oder mehreren Gruppen
```

Insbesondere gilt:

```text
Two-Ship-Template + SetGrouping(2) = eine physische DCS-Gruppe mit zwei Luftfahrzeugen
zwei Single-Ship-Assets = zwei unabhängige DCS-Gruppen, kein physisches Two-Ship
sichtbares Static = keine AIRWING-Bestandsgruppe
Template = Authoring-Seed, keine dauerhaft aktive Ramp-Maschine
```

## Verbindlicher Paketvertrag

```text
OH-58D RECON
  24 Luftfahrzeuge
  12 MOOSE-Asset-Gruppen
  1 physische DCS-Gruppe je Auftrag
  2 Luftfahrzeuge je Gruppe
  Runtime-Einheiten: <group>-01 und <group>-02

AH-64D CAS
  8 Luftfahrzeuge
  4 MOOSE-Asset-Gruppen
  1 physische DCS-Gruppe je Auftrag
  2 Luftfahrzeuge je Gruppe
  Runtime-Einheiten: <group>-01 und <group>-02

UH-60
  8 Luftfahrzeuge
  8 Single-Ship-Asset-Gruppen
  TROOPTRANSPORT-Test: ein Single-Ship
  späteres MEDEVAC: getrennte Lead- und Guard-Single-Ships als ein koordiniertes Paket

CH-47
  8 Luftfahrzeuge
  8 Single-Ship-Asset-Gruppen
  1 Gruppe / 1 Luftfahrzeug je Auftrag
```

Zwingend:

```text
AssetGroups × Grouping = InventoryAircraft
RequiredGroups × Grouping = RequiredAircraft
```

Paketmodell, Grouping, erwartete Gruppen, erwartete Luftfahrzeuge und Runtime-Suffixe werden zentral definiert. Sie dürfen nicht durch nachgelagerte Lua-Dateien still überschrieben werden.

## Finaler Nachweisstand des Grundknotens

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
SHA-256: 16c607a9ffe9157779c09ad0e7557287697f91239c60e53fa33fd91d22396e8f

dcs(57).log
SHA-256: 1460c11af132a29421b091496702f8a1da70636c9303e4c72c82513b4e58a836

debrief(14).log
SHA-256: 2ae6f3e48cd0adea313b5c622226f6e965adf9b1ed51c51abcc33642d4ca12e4
```

Eingebettetes Bundle des akzeptierten Grundknotens:

```text
Datei: l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
Größe: 50273 Bytes
SHA-256: 13f6ef2235a8d1abd13924c0e6bc297515039795766e98d7e15572c1f06ea18a
GeneratedUtc: 2026-07-23T22:48:46.2604962Z
```

## Darstellungsmodell

Die lokale ORBAT wird nicht 1:1 durch sichtbare Statics oder DCS-Parkpositionen abgebildet.

```text
logischer Bestand = CampaignState-/MOOSE-Reserve
sichtbare Statics = begrenzte visuelle Ramp-Darstellung
aktive Spieler/KI = aktuell verwendete oder reservierte Luftfahrzeuge
virtuelle Reserve = Hallen, Wartung und nicht dargestellte Abstellflächen
```

Ein endgültiger Verlust reduziert den logischen Bestand dauerhaft. Eine andere überlebende, bislang unsichtbare Bestandsmaschine darf später eingesetzt werden; sie ist kein externer Ersatz.

## 2011er Ramp-Momentaufnahme

Mindestens sichtbar gezählt:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Mi-8 und UH-1 bleiben als externe oder transiente Luftfahrzeuge dokumentiert und werden nicht dem US-Task-Force-Shooter-Bestand zugerechnet.

## Validierter logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

## Validierte Missionseditor-Baseline

```text
6 verpflichtende Clientgruppen
5 Late-Activation-KI-Templategruppen
20 sichtbare Luftfahrzeug-Statics
11 Funktionszonen
1 Warehouse-Anker
0 optionale UH-60L-Clientgruppen im modfreien Kernstand
```

Spielerplätze:

```text
2 OH-58D
2 AH-64D
2 CH-47
```

Optionale Modvariante:

```text
0 oder 2 UH-60L-Clientgruppen
```

Static-Obergrenzen:

```text
7 OH-58D
4 AH-64D
4 UH-60A
5 CH-47F
```

## Validierte DCS-Typen

```text
OH58D
AH-64D_BLK_II
UH-60A
CH-47Fbl1
```

Beide UH-60-MEDEVAC-Templates verwenden die Livery `standard`.

## Parkplatzmodell

```text
6 Clientpositionen
4 dynamische KI-Reservepositionen
= 10 Runtime-Positionen

+ 2 optionale UH-60L-Positionen
= 12 Runtime-Positionen mit Modvariante
```

Die sieben Luftfahrzeuge der fünf Late-Activation-Templates sind Authoring-Seeds und belegen keine sieben dauerhaften Runtime-Parkplätze.

Vier CH-47-Statics belegen absichtlich echte DCS-Parking-Nodes:

```text
CH47_01 -> TerminalID 49
CH47_02 -> TerminalID 37
CH47_03 -> TerminalID 23
CH47_04 -> TerminalID 35
```

MOOSE-Blacklist:

```text
23,35,37,49
```

Der Validator bestätigte:

```text
4 absichtliche Reservierungen
7 verbleibende visuelle CH-47-Positionen
0 nicht deklarierte Static-Parking-Überlagerungen
```

Clientpositionen werden durch `AIRWING:SetSafeParkingOn()` geschützt.

## Technische Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Bestandsabbildung:

```text
OH-58D: 24 / 12 physische Two-Ship-Asset-Gruppen / RECON
AH-64D:  8 /  4 physische Two-Ship-Asset-Gruppen / CAS
UH-60:   8 /  8 Single-Ship-Asset-Gruppen / TRANSPORT, LAND, GROUNDESCORT
CH-47:   8 /  8 Single-Ship-Asset-Gruppen / TROOPTRANSPORT, CARGOTRANSPORT, LAND
```

MEDEVAC:

```text
1 unabhängige Lead-Single-Ship-Gruppe
+
1 unabhängige Cover-Single-Ship-Gruppe
=
1 logisch koordiniertes MEDEVAC-Paket
```

Der vollständige Laufzeitkoordinator bleibt eine separate Folgestufe.

## Bestätigte Infrastruktur

- Jalalabad als MOOSE-Airbase ID 19,
- 50 auslesbare Parking-Einträge,
- Warehouse-Anker `WH_AIR_US_JALALABAD`,
- natives DCS-Warehouse und MOOSE-Storage,
- explizite AIRWING-Zuordnung zu Jalalabad,
- Parking-Blacklist und Safe Parking,
- vier SQUADRONs,
- AIRWING-Start,
- COMMANDER-Verknüpfung und -Start,
- null eingereihte Missionen,
- keine spontane Jalalabad-KI-Mission im Abschlusslauf.

## Verzeichnisstruktur

```text
src/       einzelne Lua-Quellen
expected/  Acceptance-, Platzierungs- und Sollzustandsdokumente
results/   chronologische PASS-/PARTIAL-/FAIL-Berichte
dist/      lokal erzeugtes Bundle
```

`dist/OMW_AirOps_Jalalabad.lua` wird ausschließlich durch den Builder erzeugt und nicht manuell editiert.

## Repository- und Missionseditor-Workflow

Verbindlicher Gesamtworkflow:

```text
../../../docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Arbeitsgrenze:

```text
Assistent: Lua, Builder, Dokumentation, GitHub-Commit, Logauswertung
Projektinhaber: lokaler Pull, Bundle-Build, DO SCRIPT FILE, .miz, DCS-Test
```

Ohne ausdrücklichen Auftrag erstellt oder verändert der Assistent keine `.miz`.

Kernbefehle für die aktuelle taktische Testphase:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch feature/jalalabad-airwing-phase1-functional-tests
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Nach jedem Neubau muss `OMW_AirOps_Jalalabad.lua` im Missionseditor erneut über `DO SCRIPT FILE` ausgewählt und die `.miz` gespeichert werden.

## Taktische Abnahmereihenfolge

1. OH-58D als eine physische Two-Ship-Gruppe mit explizitem Rückkorridor.
2. AH-64D als eine physische Two-Ship-Gruppe mit gemeinsamer Rückkehr und zwei gezählten Landungen.
3. UH-60 als echter Single-Ship-TROOPTRANSPORT mit Pickup und Dropoff.
4. CH-47 als Single-Ship-CARGOTRANSPORT mit physisch belegter Frachtzustellung.
5. UH-60-Abbruch und Bestandsfreigabe.
6. Gesamtablauf erst nach den isolierten Einzeltests.
7. vollständiges 1+1-MEDEVAC-Paket als separate spätere Stufe.

Ein Build oder statischer Test ist kein DCS-PASS. Der aktuelle funktionale Paketvertrag bleibt bis zu neuen DCS-Logs `DCS VALIDATION PENDING`.

## Folgestufen

Der Grundaufbau ist abgeschlossen. Separat zu implementieren und zu validieren sind:

- taktische AUFTRAG-Erzeugung und robuste Missionsausführung,
- dynamische, spielergesteuerte Auftragsanforderungen,
- OPSTRANSPORT-Logistik,
- operative Lade-/Entladezonen,
- vollständige 1+1-MEDEVAC-Ausführung,
- persistente Verlustrechnung,
- persistente Ramp-/Static-Neuverteilung.

Die dynamische Spieleranforderung darf erst auf den in DCS abgenommenen Paketverträgen aufbauen. Der spätere Planner wählt einen Vertrag aus; er darf Grouping, TemplateUnits oder Paketmodell nicht verändern.
