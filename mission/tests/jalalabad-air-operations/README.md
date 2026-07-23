# Jalalabad Air Operations – vollständiger Knotenabschluss

## Status

Die isolierten Vorprüfungen sind abgeschlossen:

- Jalalabad als MOOSE-Airbase ID 19 erkannt,
- 50 Parking-Einträge ausgelesen,
- Warehouse-Anker `WH_AIR_US_JALALABAD` als BLUE-/USA-Static bestätigt,
- natives DCS-Warehouse und MOOSE-Storage verfügbar,
- `AW_US_JALALABAD` erfolgreich konstruiert und Jalalabad explizit zugeordnet,
- OH-58D-Template `OH58D`, Gruppengröße 2, 12 Asset-Gruppen aus 24 Luftfahrzeugen bestätigt,
- AH-64D-Template `AH-64D_BLK_II`, Gruppengröße 2, 4 Asset-Gruppen aus 8 Luftfahrzeugen bestätigt.

Ab jetzt gibt es keine weiteren Einzelfreigaben pro Objekt. Die Mission wird in einem einzigen Arbeitsgang zum vollständigen Jalalabad-Air-Ops-Knoten ergänzt und anschließend mit einem Gesamttest abgenommen.

## Verbindliche lokale ORBAT

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

## Repository-Workflow

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

Nach jedem Build im DCS-Missionseditor:

1. vorhandenen Trigger `DO SCRIPT FILE -> OMW_AirOps_Jalalabad.lua` öffnen,
2. die neu gebaute Datei erneut auswählen,
3. Mission speichern.

DCS bettet den Inhalt beim Speichern in die `.miz` ein; ein späterer externer Build aktualisiert die Mission nicht automatisch.

## Build-Reihenfolge

```text
01-jalalabad-bootstrap.lua
02-dump-airbase-parking.lua
03-probe-warehouse-anchor.lua
04-dump-aircraft-types.lua
05-validate-mission-templates.lua
06-construct-oh58d-squadron.lua
07-construct-ah64d-squadron.lua
08-construct-uh60-squadron.lua
09-finalize-jalalabad-node.lua
```

Builder-Version:

```text
JBAD-AIR-OPS-COMPLETE-1
```

## Vollständiges lokales Manifest

### AIRWING und SQUADRONs

```text
AW_US_JALALABAD
SQ_US_JBAD_OH58D_6_6_CAV
SQ_US_JBAD_AH64D_B_1_10_AVN
SQ_US_JBAD_UH60_UTILITY_MEDEVAC
```

### KI-Templates

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
```

### Verpflichtende Kern-Spielergruppen

```text
CLIENT_US_JBAD_OH58D_01 bis _04
CLIENT_US_JBAD_AH64D_01 bis _04
```

### Optionale Community-Mod-Spielergruppen

```text
CLIENT_US_JBAD_UH60L_01 bis _04
```

Die UH-60L-Gruppen sind entweder vollständig mit vier Gruppen vorhanden oder vollständig abwesend. Sie sind keine Voraussetzung für die Kernmission.

### Gepoolte Statics

```text
STATIC_AIR_US_JBAD_OH58D_01 bis _08
STATIC_AIR_US_JBAD_AH64D_01 bis _04
STATIC_AIR_US_JBAD_UH60_01 bis _02
```

### Zonen

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

## Bestands- und Einsatzregeln

```text
maximale Spieler-Luftfahrzeuge je Typ und Basis: 4
maximale gleichzeitig aktive KI-Luftfahrzeuge je Typ und Basis: 4
maximale parallele Unterstützungsmissionen: 2
maximale Luftfahrzeuge je Unterstützungsmission: 2
maximale gleichzeitig aktive Unterstützungs-Luftfahrzeuge: 4
```

MEDEVAC:

```text
1 Lead + 1 Cover
kein Single-Ship-Fallback
```

Die UH-60-Umsetzung verwendet ein gemeinsames sechs Luftfahrzeuge umfassendes SQUADRON und zwei getrennte Ein-Schiff-Payloadtemplates. Dadurch wird der lokale Bestand nicht doppelt gezählt.

## Abgeschlossene Ergebnisberichte

```text
results/2026-07-23-jalalabad-air-operations-diagnostics-v1-partial.md
results/2026-07-23-jalalabad-air-operations-diagnostics-v2-pass.md
results/2026-07-23-jalalabad-airwing-anchor-construction-pass.md
results/2026-07-23-jalalabad-oh58d-squadron-construction-pass.md
results/2026-07-23-jalalabad-ah64d-squadron-construction-pass.md
```

## Aktueller Arbeitsauftrag

Die vollständige Missionseditor- und Abnahmevorgabe steht in:

```text
expected/jalalabad-complete-node-acceptance.md
```

Nach Umsetzung aller dort genannten Objekte läuft genau ein Gesamttest. Das Bundle startet das AIRWING und verknüpft es mit `OMW_BLUE_COMMANDER` nur dann, wenn sämtliche verpflichtenden Gruppen, Templates, Statics, Zonen, Payloads und Policy-Werte vollständig validiert wurden.

Erwartetes Abschlussresultat:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Globale Kampagnenadapter für Persistenz, Verlustbuchung und spätere Auftragserzeugung bauen anschließend auf diesem abgeschlossenen lokalen Knoten auf; die Jalalabad-ORBAT und Missionseditor-Namensstruktur werden danach nicht erneut stufenweise erweitert.
