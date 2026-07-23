# Jalalabad Air Operations Test

## Ziel und Status

Dieser Test bereitet die erste MOOSE-AIRWING-/SQUADRON-Umsetzung für Jalalabad / FOB Fenty vor.

Die aktuelle Stufe ist ausschließlich diagnostisch. Das Bundle startet keine AIRWING-Operationen, erzeugt keine Aufträge, verändert keine Bestände und schreibt keinen Kampagnenzustand.

Verbindlicher lokaler Bestand:

```text
24 OH-58D – 6-6 Cavalry / Task Force Six Shooters
 8 AH-64D – B Company, 1-10 Aviation
 6 UH-60-Familie – Utility-/MEDEVAC-Element
```

## Festgeschriebene MOOSE-Version

```text
Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Build: 2026-06-14T16:11:05+02:00
SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Ausgangsmission

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
SHA-256: 898703f5b738a632492e514f8943327634a0d094716fd7f4c971c9b2582fb50b
```

Die Ausgangsmission enthält noch keine Jalalabad-Air-Ops-Gruppen oder -Statics. Sie lädt neben MOOSE weiterhin das TM02W2F-Testbundle.

## Verbindlicher Repository-Workflow

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git fetch origin
git switch feature/jalalabad-air-operations-diagnostics
git pull --ff-only

git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\tools\build-jalalabad-air-operations-bundle.ps1
```

Erzeugte Datei:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua
```

Die Datei unter `dist` wird nicht manuell bearbeitet. Änderungen erfolgen ausschließlich in `src` und werden danach neu gebaut.

## Mission aktualisieren

Im DCS-Missionseditor:

1. vorhandenen Trigger mit `DO SCRIPT FILE` öffnen oder einen neuen Trigger nach `Moose.lua` anlegen,
2. diese Datei erneut auswählen:

```text
mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua
```

3. Mission speichern.

Das erneute Auswählen ist nach jedem lokalen Build erforderlich, weil DCS die Lua-Datei beim Speichern in die `.miz` einbettet. Ein späteres Neubauen der externen Datei aktualisiert die bereits gespeicherte Mission nicht automatisch.

## Build-Reihenfolge

Der Builder fügt diese Quellen in fester Reihenfolge zusammen:

```text
01-jalalabad-bootstrap.lua
02-dump-airbase-parking.lua
03-probe-warehouse-anchor.lua
04-dump-aircraft-types.lua
05-validate-mission-templates.lua
```

## Erstes Air Operations Manifest

| Pool | Bestand | Spieler maximal | KI maximal lokal | anfänglich sichtbare Statics |
|---|---:|---:|---:|---:|
| OH-58D | 24 | 4 | 4 | 8 |
| AH-64D | 8 | 4 | 4 | 4 |
| UH-60-Familie | 6 | 4 optional | 4 | 2 |

Die Static-Zahlen sind Zielwerte für den initialen Ramp-Zustand und kein zusätzlicher Bestand.

Erwartete DCS-Typen:

| Rolle | erwarteter DCS-Typ | Status |
|---|---|---|
| OH-58D Spieler/KI | `OH58D` | in Ausgangsmission bestätigt |
| AH-64D Spieler/KI | `AH-64D_BLK_II` | im DCS-Test bestätigen |
| UH-60 KI | `UH-60A` | im DCS-Test bestätigen |
| UH-60 Spieler | UH-60L Community Mod | optional; Typname noch offen |

KI-`UH-60A` und Spieler-UH-60L bilden denselben konzeptionellen Bestand von sechs UH-60 ab.

## Erwarteter erster Lauf

Da die Missionseditorobjekte noch nicht angelegt wurden, sind Meldungen über fehlende Gruppen, Statics, Zonen und den Warehouse-Anker zunächst korrekt.

Der Lauf soll belastbar liefern:

- DCS-/MOOSE-Name und ID von Jalalabad,
- Parking-IDs und Terminaltypen,
- Warehouse-/Storage-Verfügbarkeit,
- interne Typnamen bereits angelegter Testgruppen,
- vollständige Liste der noch fehlenden Air-Ops-Objekte,
- mögliche Lua- oder DCS-API-Fehler.

Nach dem Lauf werden benötigt:

- aktualisierte `.miz`,
- `dcs.log`,
- Screenshots der vorgesehenen Parking-, Warehouse-, MEDEVAC-, Logistik- und Static-Bereiche.
