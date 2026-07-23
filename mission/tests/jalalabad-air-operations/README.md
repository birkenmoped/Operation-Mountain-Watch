# Jalalabad Air Operations Test

## Ziel und Status

Dieser Test bereitet die erste MOOSE-AIRWING-/SQUADRON-Umsetzung für Jalalabad / FOB Fenty vor.

Abgeschlossen und als PASS dokumentiert sind:

- Diagnose des leeren Ausgangszustands,
- Erkennung des Warehouse-Ankers,
- Konstruktion des nicht gestarteten Jalalabad-AIRWING,
- explizite Zuordnung des AIRWING zu Jalalabad.

Die aktuelle Stufe ergänzt genau ein zweischiffiges OH-58D-KI-Template und prüft die Konstruktion und Verknüpfung eines `SQUADRON`. Das AIRWING wird weiterhin nicht gestartet; es werden keine Aufträge erzeugt und keine Luftfahrzeuge gespawnt.

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

1. vorhandenen Trigger mit `DO SCRIPT FILE` öffnen,
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
06-construct-oh58d-squadron.lua
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
| OH-58D Spieler/KI | `OH58D` | bestätigt |
| AH-64D Spieler/KI | `AH-64D_BLK_II` | im DCS-Test bestätigen |
| UH-60 KI | `UH-60A` | im DCS-Test bestätigen |
| UH-60 Spieler | UH-60L Community Mod | optional; Typname noch offen |

KI-`UH-60A` und Spieler-UH-60L bilden denselben konzeptionellen Bestand von sechs UH-60 ab.

## Asset-Gruppen statt Einzelmaschinen

`SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)` erwartet bei `Ngroups` die Zahl der Asset-Gruppen. Ein zweischiffiges Template repräsentiert deshalb zwei Luftfahrzeuge je Asset-Gruppe.

Für den OH-58D-Bestand gilt:

```text
24 Luftfahrzeuge / 2 je Gruppe = 12 Asset-Gruppen
```

Die Obergrenze von vier gleichzeitig lokalen KI-Luftfahrzeugen wird später durch Missionsanforderungen und Dispatch-Limits gesteuert; sie entspricht nicht dem Gesamtbestand im SQUADRON.

## Abgeschlossene Ergebnisse

```text
results/2026-07-23-jalalabad-air-operations-diagnostics-v1-partial.md
results/2026-07-23-jalalabad-air-operations-diagnostics-v2-pass.md
results/2026-07-23-jalalabad-airwing-anchor-construction-pass.md
```

Bestätigt sind:

- Jalalabad als MOOSE-Airbase ID 19,
- 50 auslesbare Parking-Einträge,
- natives DCS-Warehouse verfügbar,
- MOOSE-Storage verfügbar,
- Warehouse-Anker `WH_AIR_US_JALALABAD` als BLUE-/USA-Static erkannt,
- `AIRWING:New()` und `SetAirbase()` ohne Lua-Fehler,
- AIRWING `AW_US_JALALABAD` bleibt in der Validierungsstufe ungestartet.

## Aktueller nächster Schritt

Mission-Editor- und Abnahmevorgabe:

```text
expected/jalalabad-oh58d-squadron-construction-acceptance.md
```

Es wird genau eine spät aktivierte BLUE-/USA-Gruppe mit zwei OH-58D angelegt:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
```

Das neue Bundle prüft Typ, Gruppenstärke, Umrechnung von 24 Luftfahrzeugen in 12 Asset-Gruppen, `SQUADRON:New()`, `SetGrouping(2)`, RECON-Capability und `AIRWING:AddSquadron()`. Ein AIRWING-Start, Spieler-Slots, Payload-Pools, AUFTRAG-Missionen und tatsächliche Spawns bleiben außerhalb dieser Stufe.
