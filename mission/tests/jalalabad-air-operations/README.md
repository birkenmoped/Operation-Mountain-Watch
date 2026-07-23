# Jalalabad Air Operations

## Status

Der lokale Air-Ops-Knoten Jalalabad / FOB Fenty ist vollständig aufgebaut und im DCS-Gesamttest validiert.

```text
Status: OPERATIONAL / ACCEPTED
Finaler Source-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
```

Finales Ergebnis:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Autoritative Dokumente:

```text
../../../docs/21-jalalabad-air-operations-manifest.md
../../../docs/23-jalalabad-parking-template-and-medevac-model.md
../../../docs/24-jalalabad-ch47-static-parking-reservations.md
../../../docs/25-jalalabad-final-validation-and-operational-baseline.md
expected/jalalabad-complete-node-acceptance.md
results/2026-07-24-jalalabad-complete-node-pass.md
```

## Finaler Nachweisstand

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
SHA-256: 16c607a9ffe9157779c09ad0e7557287697f91239c60e53fa33fd91d22396e8f

dcs(57).log
SHA-256: 1460c11af132a29421b091496702f8a1da70636c9303e4c72c82513b4e58a836

debrief(14).log
SHA-256: 2ae6f3e48cd0adea313b5c622226f6e965adf9b1ed51c51abcc33642d4ca12e4
```

Eingebettetes Bundle:

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
OH-58D: 24 / 12 Two-Ship-Asset-Gruppen / RECON
AH-64D:  8 /  4 Two-Ship-Asset-Gruppen / CAS
UH-60:   8 /  8 Single-Ship-Asset-Gruppen / TRANSPORT, LAND, GROUNDESCORT
CH-47:   8 /  8 Single-Ship-Asset-Gruppen / TROOPTRANSPORT, CARGOTRANSPORT, LAND
```

MEDEVAC:

```text
1 unabhängige Lead-Single-Ship-Gruppe
+
1 unabhängige Cover-Single-Ship-Gruppe
=
1 logisches MEDEVAC-Two-Ship-Paket
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

## Repository-Workflow

Verbindlicher Gesamtworkflow:

```text
../../../docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Kernbefehle:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch feature/jalalabad-air-operations-diagnostics
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Nach jedem Neubau muss `OMW_AirOps_Jalalabad.lua` im Missionseditor erneut über `DO SCRIPT FILE` ausgewählt und die `.miz` gespeichert werden.

## Folgestufen

Der Grundaufbau ist abgeschlossen. Separat zu implementieren und zu validieren sind:

- taktische AUFTRAG-Erzeugung,
- OPSTRANSPORT-Logistik,
- operative Lade-/Entladezonen,
- vollständige 1+1-MEDEVAC-Ausführung,
- persistente Verlustrechnung,
- persistente Ramp-/Static-Neuverteilung.
