# Jalalabad Air Operations Test

## Ziel

Dieser Test führt die erste MOOSE-AIRWING-/SQUADRON-Umsetzung für die aktive US-Luft-ORBAT in Jalalabad / FOB Fenty ein.

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

## Erstes Air Operations Manifest

### Bestands- und Aktivitätsgrenzen

| Pool | Bestand | Spieler maximal | KI maximal lokal | anfänglich sichtbare Statics |
|---|---:|---:|---:|---:|
| OH-58D | 24 | 4 | 4 | 8 |
| AH-64D | 8 | 4 | 4 | 4 |
| UH-60-Familie | 6 | 4 optional | 4, durch Gesamtpool begrenzt | 2 |

Die Static-Zahlen sind Zielwerte für den initialen Ramp-Zustand. Der spätere `StaticAirframeManager` reduziert sichtbare Statics, wenn der verbleibende inaktive Pool dafür nicht ausreicht.

### DCS-Typen

| Rolle | erwarteter DCS-Typ | Status |
|---|---|---|
| OH-58D Spieler/KI | `OH58D` | in Ausgangsmission bestätigt |
| AH-64D Spieler/KI | `AH-64D_BLK_II` | im DCS-Test bestätigen |
| UH-60 KI | `UH-60A` | im DCS-Test bestätigen |
| UH-60 Spieler | UH-60L Community Mod, erwarteter Typname noch offen | optional, Diagnose erforderlich |

KI-`UH-60A` und Spieler-UH-60L bilden denselben konzeptionellen Bestand von sechs UH-60 ab. Sie sind keine getrennten ORBAT-Pools.

### Spielergruppen

Je Spieler-Luftfahrzeug wird eine eigene DCS-Gruppe angelegt.

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02
CLIENT_US_JBAD_OH58D_03
CLIENT_US_JBAD_OH58D_04

CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02
CLIENT_US_JBAD_AH64D_03
CLIENT_US_JBAD_AH64D_04

CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
CLIENT_US_JBAD_UH60L_03
CLIENT_US_JBAD_UH60L_04
```

Die UH-60L-Gruppen werden nur angelegt, wenn bestätigt ist, dass die Mission ohne installierten Mod weiterhin für andere Spieler nutzbar bleibt.

### KI-Templates

Alle Gruppen werden als **Late Activation** angelegt.

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
```

Erste Gruppenzahlen für MOOSE:

```text
OH-58D: 4 KI-Luftfahrzeuge / 2 je Gruppe = 2 Asset-Gruppen
AH-64D: 4 KI-Luftfahrzeuge / 2 je Gruppe = 2 Asset-Gruppen
UH-60: 4 KI-Luftfahrzeuge / 1 je technische Gruppe = 4 Asset-Gruppen
```

Die vier UH-60-Asset-Gruppen stellen maximal zwei vollständige MEDEVAC-Pakete dar. Eine Mission reserviert immer genau einen Lead und einen Cover-Hubschrauber.

### Statische Luftfahrzeuge

```text
STATIC_AIR_US_JBAD_OH58D_01 bis _08
STATIC_AIR_US_JBAD_AH64D_01 bis _04
STATIC_AIR_US_JBAD_UH60_01 bis _02
```

Statics stehen auf getrennten Display-Abstellflächen und dürfen keine operativen Spawn- oder Rückkehrparkplätze blockieren.

### Warehouse

Bevorzugter technischer Name:

```text
WH_AIR_US_JALALABAD
```

Da in der Ausgangsmission kein benannter Missions-Static im Jalalabad-Bereich existiert, ist mit hoher Wahrscheinlichkeit ein zusätzlicher technischer Warehouse-Static im vorhandenen Lagerbereich erforderlich. Das Diagnosewerkzeug `ProbeWarehouseAnchor.lua` prüft den endgültigen Zustand.

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

Vorhandene Zonen dürfen wiederverwendet werden, wenn Name und Zweck eindeutig angepasst beziehungsweise dokumentiert sind. Es dürfen keine zwei Zonen mit identischer Funktion parallel bestehen.

## Diagnose-Reihenfolge

Nach `Moose.lua` werden zunächst diese Skripte geladen:

```text
1. diagnostics/DumpAircraftTypes.lua
2. diagnostics/DumpAirbaseParking.lua
3. diagnostics/ProbeWarehouseAnchor.lua
4. diagnostics/ValidateMissionTemplates.lua
```

Der operative AIRWING-Bootstrap wird erst aktiviert, wenn die Validierung keine blockierenden Fehler mehr meldet.

## Vom Missionsdesigner jetzt anzulegen

1. Weitere Arbeitskopie für die erste Platzierung erstellen.
2. Warehouse-Static `WH_AIR_US_JALALABAD` in einem plausiblen Lagerbereich platzieren.
3. Die vier KI-Templates mit den exakt vorgegebenen Namen als Late Activation anlegen.
4. Zunächst je Muster nur **einen** Spieler-Testslot anlegen:
   - `CLIENT_US_JBAD_OH58D_01`
   - `CLIENT_US_JBAD_AH64D_01`
   - optional `CLIENT_US_JBAD_UH60L_01`
5. Die acht, vier und zwei vorgesehenen Static-Abstellpunkte als Gruppenfamilien vorbereiten.
6. Die acht Air-Ops-Zonen anlegen beziehungsweise vorhandene Zonen eindeutig zuordnen.
7. Diagnose-Skripte nach MOOSE laden und einen kurzen Testlauf durchführen.
8. `.miz`, `dcs.log` und Screenshots der Park-/Static-Bereiche bereitstellen.

Die restlichen Spielerplätze werden erst dupliziert, nachdem ein Testslot des jeweiligen Musters kollisionsfrei funktioniert.
