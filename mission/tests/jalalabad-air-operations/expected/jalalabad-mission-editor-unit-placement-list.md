# Jalalabad AirOps – validierte Missionseditor-Einheiten- und Platzierungsliste

## 1. Status

```text
Status: VALIDATED / PASS
Finaler Source-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
```

Diese Liste dokumentiert den im vollständigen DCS-Abschlusslauf bestätigten Missionseditor-Sollzustand. Sie ist zugleich die verbindliche Wiederaufbau- und Regression-Referenz.

Sie ersetzt ältere Angaben mit:

```text
4 Spielergruppen je Typ
6 UH-60
keinem CH-47-Bestand
14 sichtbaren Statics
13 oder 15 dauerhaft reservierten Runtime-Parkpositionen
keinen Statics auf echten Parking-Nodes
```

## 2. Logischer Bestand und physischer ME-Bestand

Logischer Bestand:

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

Physisch im Mission Editor vorbereitet:

| Kategorie | Gruppen/Objekte | Luftfahrzeuge |
|---|---:|---:|
| KI-Templates, Late Activation | 5 Gruppen | 7 |
| Spielergruppen, Client | 6 Gruppen | 6 |
| sichtbare Luftfahrzeug-Statics | 20 Objekte | 20 |
| **Summe** | **31 Gruppen/Objekte** | **33** |

Zusätzlich:

```text
1 Warehouse-Static: WH_AIR_US_JALALABAD
11 Funktionszonen
```

Die Differenz zwischen 48 logischen und 33 physisch vorbereiteten Luftfahrzeugen ist virtuelle Reserve. Die sieben Template-Luftfahrzeuge sind beim Missionsstart wegen `Late Activation` nicht sichtbar.

## 3. Allgemeine Missionseditor-Regeln

Für alle Luftfahrzeuge:

```text
Koalition: BLUE
Land: USA
```

Für alle KI-Templates:

```text
Skill: High
Late Activation: aktiviert
Uncontrolled: deaktiviert
Start: Takeoff from parking cold
```

Für alle Spielergruppen:

```text
Skill: Client
Start: Takeoff from parking cold
je Gruppe genau 1 Luftfahrzeug
```

Gruppen- und Einheitennamen müssen exakt übernommen werden.

## 4. Verpflichtende KI-Templates

### 4.1 OH-58D RECON

```text
DCS-Typ: OH58D
Gruppe: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Einheit 1: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP-1
Einheit 2: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP-2
Anzahl: 2
```

MOOSE:

```text
24 Luftfahrzeuge / 2 = 12 Asset-Gruppen
Capability: RECON
```

### 4.2 AH-64D CAS

```text
DCS-Typ: AH-64D_BLK_II
Gruppe: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
Einheit 1: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP-1
Einheit 2: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP-2
Anzahl: 2
```

MOOSE:

```text
8 Luftfahrzeuge / 2 = 4 Asset-Gruppen
Capability: CAS
```

### 4.3 UH-60A MEDEVAC Lead

```text
DCS-Typ: UH-60A
Livery: standard
Gruppe: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
Einheit: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP-1
Anzahl: 1
```

### 4.4 UH-60A MEDEVAC Cover

```text
DCS-Typ: UH-60A
Livery: standard
Gruppe: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
Einheit: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP-1
Anzahl: 1
```

Lead und Cover sind zwei unabhängige Single-Ship-DCS-Gruppen aus demselben Bestand. Gemeinsam bilden sie ein logisches 1+1-MEDEVAC-Paket.

### 4.5 CH-47 Heavy Lift

```text
DCS-Typ: CH-47Fbl1
Gruppe: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
Einheit: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP-1
Anzahl: 1
```

MOOSE:

```text
8 Luftfahrzeuge / 1 = 8 Asset-Gruppen
Capabilities: TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE
```

## 5. Verpflichtende Spielergruppen

### 5.1 OH-58D

```text
DCS-Typ: OH58D

Gruppe: CLIENT_US_JBAD_OH58D_01
Einheit: CLIENT_US_JBAD_OH58D_01-1

Gruppe: CLIENT_US_JBAD_OH58D_02
Einheit: CLIENT_US_JBAD_OH58D_02-1
```

### 5.2 AH-64D

```text
DCS-Typ: AH-64D_BLK_II

Gruppe: CLIENT_US_JBAD_AH64D_01
Einheit: CLIENT_US_JBAD_AH64D_01-1

Gruppe: CLIENT_US_JBAD_AH64D_02
Einheit: CLIENT_US_JBAD_AH64D_02-1
```

Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge.

### 5.3 CH-47F

```text
DCS-Typ: CH-47Fbl1

Gruppe: CLIENT_US_JBAD_CH47_01
Einheit: CLIENT_US_JBAD_CH47_01-1

Gruppe: CLIENT_US_JBAD_CH47_02
Einheit: CLIENT_US_JBAD_CH47_02-1
```

Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge.

## 6. Optionale UH-60L-Spielergruppen

Im validierten modfreien Kernstand nicht vorhanden.

Zulässige spätere Modvariante:

```text
Gruppe: CLIENT_US_JBAD_UH60L_01
Einheit: CLIENT_US_JBAD_UH60L_01-1

Gruppe: CLIENT_US_JBAD_UH60L_02
Einheit: CLIENT_US_JBAD_UH60L_02-1
```

Zulässig sind nur `0` oder `2` Gruppen. Ein einzelner UH-60L-Slot ist nicht zulässig.

## 7. Sichtbare Luftfahrzeug-Statics

Statics besitzen keinen separaten Gruppennamen. Der jeweilige Name ist der Static-/Einheitenname.

### 7.1 OH-58D – sieben

```text
STATIC_AIR_US_JBAD_OH58D_01
STATIC_AIR_US_JBAD_OH58D_02
STATIC_AIR_US_JBAD_OH58D_03
STATIC_AIR_US_JBAD_OH58D_04
STATIC_AIR_US_JBAD_OH58D_05
STATIC_AIR_US_JBAD_OH58D_06
STATIC_AIR_US_JBAD_OH58D_07
```

DCS-Typ jeweils:

```text
OH58D
```

### 7.2 AH-64D – vier

```text
STATIC_AIR_US_JBAD_AH64D_01
STATIC_AIR_US_JBAD_AH64D_02
STATIC_AIR_US_JBAD_AH64D_03
STATIC_AIR_US_JBAD_AH64D_04
```

DCS-Typ jeweils:

```text
AH-64D_BLK_II
```

### 7.3 UH-60A – vier

```text
STATIC_AIR_US_JBAD_UH60_01
STATIC_AIR_US_JBAD_UH60_02
STATIC_AIR_US_JBAD_UH60_03
STATIC_AIR_US_JBAD_UH60_04
```

DCS-Typ jeweils:

```text
UH-60A
```

### 7.4 CH-47F – fünf

```text
STATIC_AIR_US_JBAD_CH47_01
STATIC_AIR_US_JBAD_CH47_02
STATIC_AIR_US_JBAD_CH47_03
STATIC_AIR_US_JBAD_CH47_04
STATIC_AIR_US_JBAD_CH47_05
```

DCS-Typ jeweils:

```text
CH-47Fbl1
```

## 8. Warehouse-Anker

```text
Static-/Einheitenname: WH_AIR_US_JALALABAD
Koalition: BLUE
Land: USA
```

Das Warehouse ist kein Luftfahrzeug und zählt nicht zu den 20 Aircraft-Statics.

## 9. Validierte Flächenverteilung

### 9.1 OH-58D-Bereich G01-G07

Die sieben OH-58D-Statics bilden den sichtbaren kleinen Hubschrauberbereich ab. Sie stehen frei und plausibel; es gibt keine dokumentierte Parking-Node-Reservierung für diese Statics.

### 9.2 CH-47-Bereich C01-C14

```text
14 visuelle Heavy-Lift-Positionen
5 CH-47-Statics
2 CH-47-Clientgruppen
7 verbleibende Positionen
```

Vier CH-47-Statics stehen absichtlich auf echten DCS-Parking-Nodes:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49 -> 4.1 m
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37 -> 4.4 m
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23 -> 4.7 m
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35 -> 5.4 m
```

Diese vier Statics werden nicht verschoben.

Blacklist:

```text
23,35,37,49
```

`STATIC_AIR_US_JBAD_CH47_05` steht frei; Abstand zum nächsten Parking-Mittelpunkt 33.5 m.

### 9.3 AH-64D- und UH-60-Bereiche

Südliche und westliche Aprons enthalten:

```text
4 AH-64D-Statics
4 UH-60A-Statics
2 AH-64D-Clientgruppen
2 AH-64D-Templateeinheiten
2 UH-60A-Templateeinheiten
```

Für diese Statics gilt weiterhin freie Apronplatzierung ohne unbeabsichtigte Parking-Überlagerung.

## 10. Runtime-Parkplatzmodell

```text
6 Clientpositionen
4 dynamische KI-Reservepositionen
--------------------------------
10 Runtime-Positionen im Kernstand

+ 2 optionale UH-60L-Clientpositionen
= 12 Runtime-Positionen mit Modvariante
```

Die sieben Template-Luftfahrzeuge sind Late-Activation-Authoring-Seeds und werden nicht als sieben dauerhaft belegte Runtime-Parkplätze gezählt.

Safe Parking schützt Clientpositionen. Die CH-47-Blacklist entfernt die vier Static-Parking-Nodes aus dem dynamischen MOOSE-Pool.

## 11. Funktionszonen

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

Alle elf Zonen wurden gefunden und im Grundaufbau akzeptiert.

## 12. Was ausdrücklich nicht zusätzlich gesetzt wird

```text
keine 24 einzelnen OH-58D-Gruppen
keine 8 einzelnen AH-64D-Gruppen
keine 8 einzelnen UH-60-Gruppen
keine 8 einzelnen CH-47-Gruppen
keine zusätzlichen Statics über die Obergrenzen hinaus
keine Mi-8-SQUADRON
keine UH-1-SQUADRON
```

Nicht physisch dargestellte Bestandsflugzeuge bleiben virtuelle Reserve.

## 13. Kontrollsumme

```text
KI-Templates:          5 Gruppen / 7 Luftfahrzeuge
Clientgruppen:         6 Gruppen / 6 Luftfahrzeuge
Aircraft-Statics:     20 Objekte
Warehouse-Static:      1 Objekt
Funktionszonen:       11
```

Nach Typen:

```text
OH-58D: 2 KI + 2 Spieler + 7 Statics = 11 physisch vorbereitete Luftfahrzeuge
AH-64D: 2 KI + 2 Spieler + 4 Statics =  8 physisch vorbereitete Luftfahrzeuge
UH-60A: 2 KI + 0 Spieler + 4 Statics =  6 physisch vorbereitete Luftfahrzeuge
CH-47F: 1 KI + 2 Spieler + 5 Statics =  8 physisch vorbereitete Luftfahrzeuge
--------------------------------------------------------------------------
Gesamt:                                   33 physisch vorbereitete Luftfahrzeuge
```

## 14. Finaler Validierungsnachweis

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS intentionalReservationsConfirmed=4 blacklistedTerminalIDs=23,35,37,49 ch47VisualPositionsRemaining=7 unexpectedOverlaps=0 AIRWING_START_BLOCKED=false

[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```
