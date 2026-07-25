# Jalalabad AirOps – validierte vollständige Acceptance- und Regression-Baseline

## 1. Status

```text
Initialer vollständiger Acceptance-Lauf: PASS
Lokaler Jalalabad-Air-Ops-Knoten: OPERATIONAL / ACCEPTED
Finaler Builder: JBAD-AIR-OPS-COMPLETE-5
Finaler Source-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
```

Dieses Dokument ist keine noch offene Aufbauanweisung mehr. Es beschreibt den validierten Sollzustand und die Abnahmekriterien für spätere Regressionstests.

Detaillierte Namen und Platzierungen:

```text
jalalabad-mission-editor-unit-placement-list.md
jalalabad-zone-placement-list.md
```

## 2. Autoritative Nachweise

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
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
GitCommit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
Bundlegröße: 50273 Bytes
Bundle SHA-256: 13f6ef2235a8d1abd13924c0e6bc297515039795766e98d7e15572c1f06ea18a
```

## 3. Verbindlicher logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

Der logische Bestand wird nicht 1:1 physisch dargestellt.

Verbindliche Ebenen:

1. logischer CampaignState-/MOOSE-Bestand,
2. aktive Spieler- und KI-Luftfahrzeuge,
3. sichtbare Statics,
4. virtuelle Reserve.

Endgültige Verluste reduzieren den logischen Bestand. Eine andere bislang virtuelle Bestandsmaschine darf später nachrücken; sie ist kein externer Ersatz.

## 4. Validierter Missionseditor-Sollzustand

```text
6 verpflichtende Clientgruppen
5 Late-Activation-KI-Templategruppen mit 7 Luftfahrzeugen
20 Luftfahrzeug-Statics
11 Funktionszonen
1 Warehouse-Anker
0 oder 2 optionale UH-60L-Clientgruppen
```

Der modfreie validierte Kernstand verwendet `0` UH-60L-Gruppen.

Validierte DCS-Typen:

```text
OH-58D: OH58D
AH-64D: AH-64D_BLK_II
UH-60A: UH-60A
CH-47F: CH-47Fbl1
```

Beide UH-60-MEDEVAC-Templates müssen verwenden:

```text
Livery: standard
```

## 5. Spielergruppen

Je Gruppe genau ein Luftfahrzeug, Skill `Client`, Cold Start:

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02
CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02
CLIENT_US_JBAD_CH47_01
CLIENT_US_JBAD_CH47_02
```

Einheitennamen jeweils mit Suffix `-1`.

Lokales Limit:

```text
maximal 2 Spielerluftfahrzeuge je nutzbarem Typ in Jalalabad
```

## 6. KI-Templates

BLUE/USA, Skill `High`, Late Activation, nicht `Uncontrolled`, Cold Start:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP          2 OH-58D
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP            2 AH-64D
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP    1 UH-60A
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP   1 UH-60A
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP       1 CH-47F
```

Diese sieben Template-Luftfahrzeuge sind Authoring-Seeds und werden nicht als dauerhaft belegte Runtime-Parkplätze gezählt.

## 7. Sichtbare Statics

```text
7 OH-58D-Statics
4 AH-64D-Statics
4 UH-60A-Statics
5 CH-47F-Statics
----------------
20 Statics
```

Statics sind Teil des logischen Bestands und keine zusätzlichen Luftfahrzeuge.

## 8. Validiertes Runtime-Parkplatzmodell

```text
6 Kern-Clientpositionen
4 dynamische KI-Reservepositionen
--------------------------------
10 Runtime-Positionen im modfreien Kernstand

+ 2 optionale UH-60L-Clientpositionen
= 12 Runtime-Positionen mit Modvariante
```

Die frühere Rechnung mit 13 beziehungsweise 15 reservierten Operationspositionen ist aufgehoben.

## 9. Validierte CH-47-Parking-Ausnahme

Vier CH-47-Statics belegen absichtlich echte DCS-Parking-Nodes:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

Blacklist:

```text
23,35,37,49
```

`STATIC_AIR_US_JBAD_CH47_05` steht frei.

Zusätzlich muss `AIRWING:SetSafeParkingOn()` die Clientpositionen schützen.

Erwartetes Parking-Ergebnis:

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false
```

## 10. Zonen

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Alle elf Zonen müssen gefunden werden. Ihre operative Folgelogik ist nicht Teil dieses Grundaufbau-Regressionstests.

## 11. Technische SQUADRON-Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
│   24 Luftfahrzeuge / 12 Two-Ship-Asset-Gruppen / RECON
├── SQ_US_JBAD_AH64D_B_1_10_AVN
│   8 Luftfahrzeuge / 4 Two-Ship-Asset-Gruppen / CAS
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
│   8 Luftfahrzeuge / 8 Single-Ship-Asset-Gruppen
└── SQ_US_JBAD_CH47_HEAVYLIFT
    8 Luftfahrzeuge / 8 Single-Ship-Asset-Gruppen
```

## 12. MEDEVAC-Grundmodell

```text
1 Lead-Single-Ship
+
1 Cover-Single-Ship
=
1 logisches MEDEVAC-Two-Ship-Paket
```

```text
PackageSize = 2
LeadAircraft = 1
CoverAircraft = 1
AllowSingleShip = false
DCSGroupModel = TWO_INDEPENDENT_SINGLE_SHIP_GROUPS
CoordinationModel = ONE_LOGICAL_MEDEVAC_PACKAGE
```

Der vollständige operative Koordinator ist eine Folgestufe und nicht Gegenstand dieses Regressionstests.

## 13. Repository- und Buildworkflow

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

Get-FileHash `
  .\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua `
  -Algorithm SHA256
```

Danach:

1. `OMW_AirOps_Jalalabad.lua` im Missionseditor erneut über `DO SCRIPT FILE` auswählen.
2. `.miz` speichern.
3. Mission mindestens 60 Sekunden laufen lassen.
4. Nach AIRWING-/COMMANDER-Start noch mindestens 45 Sekunden beobachten.
5. standardmäßig nur die aktuelle `dcs.log` bereitstellen.
6. `.miz` zusätzlich nur bei Einbettungs-, Parking- oder Missionseditor-Unklarheiten.

## 14. PASS-Kriterien

- alle sechs Kern-Clientgruppen korrekt,
- alle fünf Templates korrekt,
- alle 20 Statics korrekt,
- alle elf Zonen korrekt,
- Warehouse-Anker vorhanden,
- vier SQUADRONs konstruiert,
- Parking-Reservierungen PASS,
- MEDEVAC-Modell PASS,
- Ramp-Modell PASS,
- AIRWING gestartet,
- COMMANDER verknüpft und gestartet,
- keine spontane Jalalabad-KI-Mission,
- kein relevanter OMW-Lua-/Timerfehler.

Erwartetes Endergebnis:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Erwartete Zusammenfassung:

```text
inventory=OH58D:24/AH64D:8/UH60:8/CH47:8
corePlayerSlots=6
optionalUH60L=0or2
dynamicAIReserve=4
runtimeParking=10or12
templateAircraft=7nonRuntime
staticCaps=OH58D:7/AH64D:4/UH60:4/CH47:5
zones=11
templates=5
squadrons=4
medevac=twoIndependentSinglesAsOnePackage
virtualReserve=true
```

## 15. Abgrenzung

Dieser Test validiert den lokalen Grundknoten. Nicht enthalten sind:

- taktische AUFTRAG-Missionen,
- OPSTRANSPORT,
- operative Lade-/Entladezonen,
- vollständige 1+1-MEDEVAC-Laufzeitkoordination,
- persistente Verluste und Ramp-Neuverteilung.
