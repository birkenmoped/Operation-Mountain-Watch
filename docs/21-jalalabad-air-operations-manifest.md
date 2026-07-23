# 21 – Jalalabad Air Operations Manifest

## Zweck und Status

Dieses Manifest definiert die erste konkrete Missionseditor- und MOOSE-Umsetzung der Luft-ORBAT für **Jalalabad Airfield / FOB Fenty**.

Es basiert auf der bereitgestellten Arbeitskopie:

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
SHA-256: 898703f5b738a632492e514f8943327634a0d094716fd7f4c971c9b2582fb50b
```

Der aktuelle Stand ist eine **Diagnose- und Platzierungsvorgabe**. Parking-IDs, nutzbare Warehouse-Anker, verfügbare DCS-Typen und konkrete Liveries werden erst nach dem ersten Diagnose-Testlauf endgültig eingetragen.

## 1. Technische Ausgangsbasis

### Mission

- Karte: DCS: Afghanistan
- Missionsdatum: 2. Mai 2011
- bestehendes Hauptskript: `TM02W2F.lua`
- bestehender Teststand bleibt unverändert erhalten
- Air-Ops-Code wird in getrennten Dateien ergänzt und nicht in das generierte `TM02W2F.lua` geschrieben

### Festgeschriebene MOOSE-Basis

```text
MOOSE Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Build: 2026-06-14T16:11:05+02:00
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die MOOSE-Datei wird während der Jalalabad-Prototypphase nicht stillschweigend ersetzt.

### Festgestellter Altbestand

Die Arbeitskopie enthält einen einzelnen Spieler-OH-58D:

```text
Gruppe: TEST_TM01A_CLIENT_01
Einheit: TEST_TM01A_CLIENT_UNIT_01
Typ: OH58D
Airdrome-ID: 16
Parking: 112 / C10
```

Dieser Slot befindet sich im Bereich Bagram und ist kein Jalalabad-Slot. Er wird nicht in die Jalalabad-Bestandsrechnung übernommen.

## 2. Verbindliche lokale ORBAT

| Verband | Typ | Lokaler Gesamtbestand |
|---|---|---:|
| 6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters | OH-58D | 24 |
| B Company, 1-10 Aviation | AH-64D | 8 |
| angegliedertes Utility-/MEDEVAC-Element | UH-60-Familie | 6 |

Gemeinsame Betriebsgrenzen:

```text
maximal 4 Spieler-Luftfahrzeuge je nutzbarem Typ
maximal 4 gleichzeitig aktive KI-Luftfahrzeuge je Typ
maximal 2 parallele KI-Unterstützungsmissionen
maximal 2 Luftfahrzeuge je Unterstützungsmission
endgültige Verluste ohne automatischen Ersatz
gepoolte Statics
```

## 3. Spieler-Slots

### 3.1 OH-58D

| Gruppe | Einheit | Typ | Skill |
|---|---|---|---|
| `CLIENT_US_JBAD_OH58D_01` | `CLIENT_US_JBAD_OH58D_01_UNIT_01` | `OH58D` | Client |
| `CLIENT_US_JBAD_OH58D_02` | `CLIENT_US_JBAD_OH58D_02_UNIT_01` | `OH58D` | Client |
| `CLIENT_US_JBAD_OH58D_03` | `CLIENT_US_JBAD_OH58D_03_UNIT_01` | `OH58D` | Client |
| `CLIENT_US_JBAD_OH58D_04` | `CLIENT_US_JBAD_OH58D_04_UNIT_01` | `OH58D` | Client |

### 3.2 AH-64D

| Gruppe | Einheit | Typ | Skill |
|---|---|---|---|
| `CLIENT_US_JBAD_AH64D_01` | `CLIENT_US_JBAD_AH64D_01_UNIT_01` | `AH-64D_BLK_II` | Client |
| `CLIENT_US_JBAD_AH64D_02` | `CLIENT_US_JBAD_AH64D_02_UNIT_01` | `AH-64D_BLK_II` | Client |
| `CLIENT_US_JBAD_AH64D_03` | `CLIENT_US_JBAD_AH64D_03_UNIT_01` | `AH-64D_BLK_II` | Client |
| `CLIENT_US_JBAD_AH64D_04` | `CLIENT_US_JBAD_AH64D_04_UNIT_01` | `AH-64D_BLK_II` | Client |

### 3.3 UH-60L Community Mod

Die UH-60L-Spielerplätze werden vorbereitet, aber noch nicht in die modfreie Diagnosemission eingesetzt:

| Gruppe | Einheit | vorgesehener Typ | Status |
|---|---|---|---|
| `CLIENT_US_JBAD_UH60L_01` | `CLIENT_US_JBAD_UH60L_01_UNIT_01` | `UH-60L` | optional, Test ausstehend |
| `CLIENT_US_JBAD_UH60L_02` | `CLIENT_US_JBAD_UH60L_02_UNIT_01` | `UH-60L` | optional, Test ausstehend |
| `CLIENT_US_JBAD_UH60L_03` | `CLIENT_US_JBAD_UH60L_03_UNIT_01` | `UH-60L` | optional, Test ausstehend |
| `CLIENT_US_JBAD_UH60L_04` | `CLIENT_US_JBAD_UH60L_04_UNIT_01` | `UH-60L` | optional, Test ausstehend |

Vor der endgültigen Aufnahme wird geprüft, ob eine Mission mit diesen Einheiten von Servern und Clients ohne installierten Community Mod geladen werden kann. Falls nicht, werden eine Kernmission und eine UH-60L-Modvariante getrennt geführt.

## 4. KI-Templates

Alle Vorlagen werden als **Late Activation** angelegt.

### 4.1 OH-58D Armed Reconnaissance

```text
Gruppenname: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Einheiten:
  TPL_AIR_US_JBAD_OH58D_RECON_2SHIP_UNIT_01
  TPL_AIR_US_JBAD_OH58D_RECON_2SHIP_UNIT_02
Typ: OH58D
Gruppengröße: 2
MOOSE Asset-Gruppen: 2
maximal gleichzeitig verfügbar: 4 Luftfahrzeuge
```

Vorgesehene Rollen:

- Reconnaissance
- Armed Reconnaissance
- Escort
- leichte CAS-Unterstützung

### 4.2 AH-64D CAS

```text
Gruppenname: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
Einheiten:
  TPL_AIR_US_JBAD_AH64D_CAS_2SHIP_UNIT_01
  TPL_AIR_US_JBAD_AH64D_CAS_2SHIP_UNIT_02
Typ: AH-64D_BLK_II
Gruppengröße: 2
MOOSE Asset-Gruppen: 2
maximal gleichzeitig verfügbar: 4 Luftfahrzeuge
```

Vorgesehene Rollen:

- CAS
- Escort
- Armed Reconnaissance
- Luft-QRF

### 4.3 UH-60 MEDEVAC Lead

```text
Gruppenname: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
Einheit: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP_UNIT_01
Typ: nach Diagnose UH-60A oder UH-60L
Gruppengröße: 1
MOOSE Asset-Gruppen: 3
```

### 4.4 UH-60 MEDEVAC Cover

```text
Gruppenname: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
Einheit: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP_UNIT_01
Typ: nach Diagnose UH-60A oder UH-60L
Gruppengröße: 1
MOOSE Asset-Gruppen: 3
```

Die zwei UH-60-SQUADRONs teilen den historischen Gesamtbestand funktional in drei Lead- und drei Cover-Luftfahrzeuge. Ein `MedevacPackageCoordinator` darf nur vollständige Pakete aus genau einem Lead und einem Cover freigeben. Die globale KI-Grenze verhindert mehr als vier gleichzeitig aktive UH-60.

Verbindliche Paketregel:

```text
1 Lead landet und übernimmt Verwundete oder Personal
1 Cover bleibt in der Luft und sichert den Landevorgang
kein regulärer Single-Ship-MEDEVAC
```

## 5. Geplante MOOSE-Struktur

```text
AW_US_JALALABAD
├── SQ_6_6_CAV_OH58D
├── SQ_B_1_10_AVN_AH64D
├── SQ_JBAD_MEDEVAC_LEAD_UH60
└── SQ_JBAD_MEDEVAC_COVER_UH60
```

Der AIRWING wird erst aktiviert, wenn Warehouse-Anker, Airbase-Bezug und alle vier KI-Templates validiert wurden.

## 6. Gepoolte Statics

Verbindliche anfängliche sichtbare Zielzahlen:

| Typ | Gesamtbestand | sichtbare Statics |
|---|---:|---:|
| OH-58D | 24 | 8 |
| AH-64D | 8 | 4 |
| UH-60-Familie | 6 | 2 |

Namen:

```text
STATIC_AIR_US_JBAD_OH58D_01 bis 08
STATIC_AIR_US_JBAD_AH64D_01 bis 04
STATIC_AIR_US_JBAD_UH60_01 bis 02
```

Regeln:

- Statics gehören zum lokalen Gesamtbestand und werden nicht addiert.
- Sie stehen außerhalb der operativen Spieler- und KI-Parkflächen.
- Sie werden keinem bestimmten Slot oder Template dauerhaft zugeordnet.
- Zerstörte Statics zählen später als endgültiger Verlust.
- Die konkrete Livery wird nach dem DCS-/Livery-Diagnoselauf festgelegt.

## 7. Warehouse und Airbase

### MOOSE-Airbase

```text
DCS-/MOOSE-Name: Jalalabad
MOOSE-Objekt: AIRBASE:FindByName("Jalalabad")
Airbase-ID: wird durch DumpAirbaseParking.lua bestätigt
```

### Warehouse-Anker

Erwarteter Name:

```text
WH_AIR_US_JALALABAD
```

Der Diagnose-Test prüft:

1. ob ein benanntes Missions-`STATIC` oder `UNIT` bereits vorhanden ist,
2. welche `STATIC`-, `UNIT`- und `SCENERY`-Objekte sich im Umfeld befinden,
3. ob lediglich DCS-Airbase-Storage vorhanden ist,
4. ob ein technisches Warehouse-Static gesetzt werden muss.

Solange kein benannter Missionsanker erkannt wird, wird kein AIRWING erzeugt.

## 8. Benötigte Zonen

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

Vorhandene übergeordnete Zonen wie `OMW_BLUE_OBJECTIVE_Airport` und `ZONE_TM01_TARGET_JALALABAD` bleiben bestehen, ersetzen aber keine der kleineren funktionsspezifischen Air-Ops-Zonen.

## 9. Parking-Anforderungen

Die endgültigen Parking-IDs werden erst nach `DumpAirbaseParking.lua` festgelegt.

Benötigt werden getrennte Flächen für:

- vier OH-58D-Spielerslots,
- vier AH-64D-Spielerslots,
- optional vier UH-60L-Spielerslots,
- mindestens zwei kollisionsfreie OH-58D-KI-Spots,
- mindestens zwei kollisionsfreie AH-64D-KI-Spots,
- mindestens zwei getrennte UH-60-MEDEVAC-Bereitschaftspositionen,
- 8 OH-58D-, 4 AH-64D- und 2 UH-60-Staticpositionen,
- C-130-Roll- und Entladebetrieb,
- Logistik- und Außenlastbetrieb.

KI-Spawnpositionen und Staticflächen dürfen sich nicht überschneiden.

## 10. Diagnosepaket

Das erste Diagnosepaket enthält:

```text
DumpAircraftTypes.lua
DumpAirbaseParking.lua
ProbeWarehouseAnchor.lua
ValidateMissionTemplates.lua
OMW_AirOps_Jalalabad_Bootstrap.lua
```

Der Bootstrap arbeitet zunächst mit:

```lua
enableRuntimeObjects = false
```

Er erzeugt daher noch keinen AIRWING und keine SQUADRONs, sondern bestätigt nur die Voraussetzungen.

## 11. Erwarteter erster Testlauf

Die Diagnosemission wird ohne Bearbeitung im Mission Editor gestartet und nach etwa 20 bis 30 Sekunden beendet.

Im `dcs.log` werden die Zeilen mit folgenden Präfixen benötigt:

```text
[OMW][AIR-OPS][AIRCRAFT-TYPES]
[OMW][AIR-OPS][PARKING]
[OMW][AIR-OPS][WAREHOUSE-PROBE]
[OMW][AIR-OPS][TEMPLATE-VALIDATION]
[OMW][AIR-OPS][JBAD-BOOTSTRAP]
```

Erwartete Ergebnisse im unveränderten Ausgangszustand:

- Typ- und Parking-Dump laufen vollständig durch.
- Warehouse-Probe empfiehlt voraussichtlich einen technischen Static-Anker.
- Template-Validierung meldet die noch nicht angelegten Gruppen, Statics und Zonen als fehlend.
- Bootstrap endet mit `PREREQUISITES_MISSING` und erzeugt keine Laufzeitobjekte.

Diese Fehler sind im ersten Testlauf erwartete Bestandsaufnahme und kein Fehlschlag der Diagnosemission.

## 12. Freigabekriterien für die Missionseditor-Platzierung

Die konkrete ME-Platzierung beginnt erst, wenn aus dem Diagnose-Log bestätigt sind:

1. exakter Airbase-Name und Airbase-ID,
2. vollständige Parking-Tabelle,
3. verfügbare Typnamen für OH-58D, AH-64D, UH-60A und UH-60L,
4. Warehouse-Ankerentscheidung,
5. keine Lua-Fehler in den fünf neuen Skripten.
