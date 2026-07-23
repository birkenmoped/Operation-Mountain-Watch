# Jalalabad Air Operations Test

## Ziel und Status

Dieser Test bereitet die erste MOOSE-AIRWING-/SQUADRON-Umsetzung für Jalalabad / FOB Fenty vor.

Die Diagnose des leeren Ausgangszustands ist mit Version 2 abgeschlossen und als PASS dokumentiert. Die aktuelle Stufe prüft ausschließlich einen benannten Mission-Editor-Warehouse-Anker und die Konstruktion eines nicht gestarteten AIRWING. Es werden weiterhin keine Aufträge erzeugt, keine Luftfahrzeuge gespawnt, keine Bestände verändert und keine Kampagnendaten geschrieben.

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
```

Die Mission lädt neben MOOSE weiterhin das TM02W2F-Testbundle. Die Jalalabad-Air-Ops-Objekte werden stufenweise und isoliert ergänzt.

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

Für die aktuelle Warehouse-Anker-Stufe ist kein Neubau erforderlich, solange das bereits validierte Bundle aus Quellcommit `95d7571a4806d1eea1e22bfe5372d26c14426cc9` weiterhin eingebettet ist.

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

## Abgeschlossene Diagnose

Ergebnisberichte:

```text
results/2026-07-23-jalalabad-air-operations-diagnostics-v1-partial.md
results/2026-07-23-jalalabad-air-operations-diagnostics-v2-pass.md
```

Bestätigt sind:

- Jalalabad als MOOSE-Airbase ID 19,
- 50 auslesbare Parking-Einträge,
- natives DCS-Warehouse verfügbar,
- MOOSE-Storage verfügbar,
- fehlender Warehouse-Anker wird ohne Lua-Fehler verarbeitet,
- leere Gruppen-, Static- und Zonenbasis wird korrekt protokolliert.

## Aktueller nächster Schritt

Mission-Editor- und Abnahmevorgabe:

```text
expected/jalalabad-airwing-anchor-construction-acceptance.md
```

Es wird genau ein BLUE-/USA-Static mit dem Unit-Namen `WH_AIR_US_JALALABAD` im Flugplatzbereich ergänzt. Das vorhandene Bundle prüft danach ausschließlich die Warehouse-Ankererkennung, `AIRWING:New()` und die explizite Jalalabad-Zuordnung. SQUADRONs, Templates, Spieler-Slots, Flugaufträge und Bestandslogik bleiben weiterhin außerhalb dieser Stufe.
