# Jalalabad AirOps – vollständiger Abschlusslauf

## Ziel

Jalalabad / FOB Fenty wird in **einem einzigen Missionseditor-Arbeitsgang** als vollständiger lokaler Air-Ops-Knoten aufgebaut und danach mit einem Gesamttest abgenommen.

Dieser Abschluss umfasst:

- Warehouse-Anker und Airbase-Bezug,
- vollständige lokale ORBAT 24 OH-58D / 8 AH-64D / 6 UH-60,
- drei typreine MOOSE-SQUADRONs,
- vier KI-Templates,
- acht verpflichtende Kern-Spielergruppen,
- optional vier UH-60L-Spielergruppen,
- 14 gepoolte Luftfahrzeug-Statics,
- acht Funktionszonen,
- RECON-, CAS-, Transport- und MEDEVAC-Payloadregistrierung,
- Start des Jalalabad-AIRWING,
- Verknüpfung mit dem BLUE-COMMANDER,
- keine automatisch erzeugten Missionen und keine spontanen Spawns.

## Bereits vorhanden und unverändert zu erhalten

```text
WH_AIR_US_JALALABAD
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
```

## 1. Noch anzulegende KI-Templates

Beide Gruppen:

```text
Koalition: BLUE
Land: USA
Typ: UH-60A
Anzahl: 1
Skill: High
Late Activation: aktiviert
Uncontrolled: deaktiviert
Start: Takeoff from parking cold
```

### MEDEVAC Lead

```text
Gruppenname: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
Einheitenname: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP-1
```

Grundkonfiguration: Transport-/MEDEVAC-Ausführung, keine unnötige Außenlast.

### MEDEVAC Cover

```text
Gruppenname: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
Einheitenname: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP-1
```

Grundkonfiguration: bewaffnete Sicherungsausführung, soweit für den DCS-UH-60A verfügbar.

Lead und Cover müssen getrennte Ein-Schiff-Gruppen bleiben.

## 2. Verpflichtende Kern-Spielergruppen

Jede Gruppe enthält genau ein Luftfahrzeug, Skill `Client`, Start `Takeoff from parking cold`.

### OH-58D

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02
CLIENT_US_JBAD_OH58D_03
CLIENT_US_JBAD_OH58D_04
```

Einheitenname jeweils identisch zum Gruppennamen mit Suffix `-1`.

### AH-64D BLK II

```text
CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02
CLIENT_US_JBAD_AH64D_03
CLIENT_US_JBAD_AH64D_04
```

Einheitenname jeweils identisch zum Gruppennamen mit Suffix `-1`.

## 3. Optionale UH-60L-Spielergruppen

Die Kernmission wird ohne Community-Mod abgeschlossen. Daher gilt verbindlich:

- entweder keine dieser Gruppen anlegen,
- oder alle vier Gruppen anlegen,
- niemals nur einen Teil der vier Gruppen.

```text
CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
CLIENT_US_JBAD_UH60L_03
CLIENT_US_JBAD_UH60L_04
```

Für den ersten vollständigen Kernabschluss werden sie **nicht benötigt**.

## 4. Gepoolte Luftfahrzeug-Statics

### Acht OH-58D

```text
STATIC_AIR_US_JBAD_OH58D_01
STATIC_AIR_US_JBAD_OH58D_02
STATIC_AIR_US_JBAD_OH58D_03
STATIC_AIR_US_JBAD_OH58D_04
STATIC_AIR_US_JBAD_OH58D_05
STATIC_AIR_US_JBAD_OH58D_06
STATIC_AIR_US_JBAD_OH58D_07
STATIC_AIR_US_JBAD_OH58D_08
```

### Vier AH-64D BLK II

```text
STATIC_AIR_US_JBAD_AH64D_01
STATIC_AIR_US_JBAD_AH64D_02
STATIC_AIR_US_JBAD_AH64D_03
STATIC_AIR_US_JBAD_AH64D_04
```

### Zwei UH-60A

```text
STATIC_AIR_US_JBAD_UH60_01
STATIC_AIR_US_JBAD_UH60_02
```

Regeln:

- BLUE / USA,
- als statische Luftfahrzeuge,
- nicht auf den für Spieler oder KI benötigten Spawnpositionen,
- ausreichender Rotorabstand,
- die 14 Statics sind Teil des lokalen Bestands und kein zusätzlicher Bestand.

## 5. Funktionszonen

Alle acht Zonen als normale Triggerzonen anlegen:

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

Empfohlene Mindestgrößen:

| Zone | Zweck | Richtwert Radius |
|---|---|---:|
| `...STATIC_OH58D` | OH-58D-Static-Abstellbereich | 120 m |
| `...STATIC_AH64D` | AH-64D-Static-Abstellbereich | 120 m |
| `...STATIC_UH60` | UH-60-Static-Abstellbereich | 120 m |
| `...MEDEVAC_READY` | Bereitschaft Lead/Cover | 100 m |
| `...LOGISTICS_LOAD` | interne Beladung | 100 m |
| `...LOGISTICS_UNLOAD` | interne Entladung | 100 m |
| `...SLING_PICKUP` | Außenlastaufnahme | 150 m |
| `...C130_UNLOAD` | C-130-Entladefläche | 150 m |

Zonen dürfen sich nur dann überschneiden, wenn die Flächen tatsächlich dieselbe physische Funktion erfüllen. Die C-130-Zone muss Rollweg und Flächenbedarf eines C-130 berücksichtigen.

## 6. Park- und Kollisionsregeln

- bestehende OH-58D- und AH-64D-Templates unverändert erhalten,
- zwei freie Hubschrauberpositionen für die UH-60-Templates verwenden,
- acht getrennte Kern-Spielerpositionen bereitstellen,
- keine Spielerposition mit einer KI-Templateposition oder einem Static überlagern,
- Two-Ship-Templates müssen ohne Rotorkollision erscheinen,
- Spieler- und KI-Flächen müssen eine freie Abflugrichtung besitzen.

Die Diagnose hat in Jalalabad 50 Parking-Einträge bestätigt. Die konkrete Auswahl erfolgt visuell im Mission Editor; die Abnahme erfolgt über den Gesamttest und die Kollisionskontrolle.

## 7. Technischer Abschluss

Das vollständige Bundle konstruiert:

```text
AW_US_JALALABAD
SQ_US_JBAD_OH58D_6_6_CAV
SQ_US_JBAD_AH64D_B_1_10_AVN
SQ_US_JBAD_UH60_UTILITY_MEDEVAC
OMW_BLUE_COMMANDER
```

Bestandsabbildung:

```text
OH-58D: 24 Luftfahrzeuge / 2 je Asset-Gruppe = 12 Gruppen
AH-64D:  8 Luftfahrzeuge / 2 je Asset-Gruppe =  4 Gruppen
UH-60:   6 Luftfahrzeuge / 1 je Asset-Gruppe =  6 Gruppen
```

MEDEVAC bleibt verbindlich:

```text
1 Lead + 1 Cover
kein Single-Ship-Fallback
```

## 8. Gesamttest

Nach Einbettung des neu gebauten Bundles Mission mindestens 30 Sekunden laufen lassen.

Erwartete Abschlussmeldungen:

```text
[OMW][AirOps.JBAD.OH58D] SQUADRON ready.
[OMW][AirOps.JBAD.AH64D] SQUADRON ready.
[OMW][AirOps.JBAD.UH60] SQUADRON ready.
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
[OMW][AirOps.JBAD.COMPLETE] SUMMARY inventory=OH58D:24/AH64D:8/UH60:6 corePlayerSlots=8 optionalUH60L=0or4 statics=14 zones=8 templates=4 squadrons=3 medevac=1+1.
```

Nicht zulässig:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: INCOMPLETE
[OMW][AirOps.JBAD.COMPLETE] ERROR
Error in timer function
spontan gespawnte OMW-Luftfahrzeuge ohne Auftrag
```

## 9. Abschlusskriterium

Jalalabad gilt als lokaler Air-Ops-Knoten abgeschlossen, sobald:

1. der Gesamttest `RESULT: COMPLETE` meldet,
2. keine OMW-Lua-Fehler auftreten,
3. keine spontanen Luftfahrzeuge erscheinen,
4. Spieler-, KI- und Static-Flächen visuell kollisionsfrei sind.

Globale Kampagnenadapter für Persistenz, Verlustbuchung und spätere Auftragserzeugung verwenden anschließend diesen abgeschlossenen Jalalabad-Knoten; sie ändern die lokale ORBAT und die Missionseditor-Namensstruktur nicht mehr.
