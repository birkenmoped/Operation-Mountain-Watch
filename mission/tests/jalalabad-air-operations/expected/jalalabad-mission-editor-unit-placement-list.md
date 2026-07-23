# Jalalabad AirOps – verbindliche Missionseditor-Einheitenliste

## 1. Zweck und Status

Diese Liste ist die verbindliche Arbeitsanweisung für die aktuell zu platzierenden Jalalabad-Luftfahrzeuge im DCS Mission Editor.

Sie ersetzt alle älteren Angaben mit:

```text
4 Spielergruppen je Typ
6 UH-60
keinem CH-47-Bestand
14 sichtbaren Statics
```

Verbindlicher logischer Bestand:

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

Der logische Bestand wird nicht 1:1 physisch platziert. Im Mission Editor werden nur Spielergruppen, Late-Activation-KI-Templates und ein begrenzter sichtbarer Static-Ausschnitt angelegt.

## 2. Mengenzusammenfassung

### Verpflichtender Kernstand

| Kategorie | Gruppen/Objekte | Luftfahrzeuge |
|---|---:|---:|
| KI-Templates, Late Activation | 5 Gruppen | 7 |
| Spielergruppen, Client | 6 Gruppen | 6 |
| sichtbare Luftfahrzeug-Statics | 20 Objekte | 20 |
| **Summe physisch vorbereitete Luftfahrzeuge** | **31 Gruppen/Objekte** | **33** |

Zusätzlich bereits vorhanden:

```text
1 Warehouse-Static: WH_AIR_US_JALALABAD
```

Optional können zwei UH-60L-Spielergruppen ergänzt werden. Für den modfreien Kernabschluss werden sie zunächst nicht gesetzt.

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

Für Statics:

```text
Kategorie: statisches Luftfahrzeug
kein Cargo-/Slingload-Objekt
keine aktive Gruppe
kein eigener zusätzlicher ORBAT-Bestand
```

Gruppen- und Einheitennamen müssen exakt übernommen werden. Keine Leerzeichen, keine zusätzlichen Suffixe und keine automatisch beibehaltenen Standardnamen.

## 4. Verpflichtende KI-Templates

Die KI-Templates bleiben beim Missionsstart unsichtbar, weil `Late Activation` aktiviert ist. Sie dienen MOOSE als Vorlagen; der vollständige SQUADRON-Bestand wird nicht als einzelne Gruppen im Mission Editor angelegt.

### 4.1 OH-58D – Armed Reconnaissance

```text
Typ: OH-58D
Gruppe: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Anzahl: 2

Einheit 1: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP-1
Einheit 2: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP-2
```

Logische MOOSE-Abbildung:

```text
24 Luftfahrzeuge / 2 je Templategruppe = 12 Asset-Gruppen
```

### 4.2 AH-64D – CAS

```text
Typ: AH-64D BLK II
Gruppe: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
Anzahl: 2

Einheit 1: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP-1
Einheit 2: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP-2
```

Logische MOOSE-Abbildung:

```text
8 Luftfahrzeuge / 2 je Templategruppe = 4 Asset-Gruppen
```

### 4.3 UH-60A – MEDEVAC Lead

```text
Typ: UH-60A
Gruppe: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
Anzahl: 1

Einheit 1: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP-1
```

### 4.4 UH-60A – MEDEVAC Cover

```text
Typ: UH-60A
Gruppe: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
Anzahl: 1

Einheit 1: TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP-1
```

Lead und Cover bleiben zwei getrennte Single-Ship-Gruppen. Beide stammen später aus demselben logischen UH-60-SQUADRON-Bestand von acht Luftfahrzeugen.

### 4.5 CH-47 – Heavy Lift

```text
Typ: verfügbares DCS-CH-47F-Modell
Gruppe: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
Anzahl: 1

Einheit 1: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP-1
```

Der interne DCS-Typname wird aus diesem Template erkannt und für CH-47-Spielergruppen und Statics validiert.

## 5. Verpflichtende Spielergruppen

### 5.1 OH-58D – zwei Spielergruppen

```text
Typ: OH-58D

Gruppe: CLIENT_US_JBAD_OH58D_01
Einheit: CLIENT_US_JBAD_OH58D_01-1

Gruppe: CLIENT_US_JBAD_OH58D_02
Einheit: CLIENT_US_JBAD_OH58D_02-1
```

### 5.2 AH-64D – zwei Spielergruppen

```text
Typ: AH-64D BLK II

Gruppe: CLIENT_US_JBAD_AH64D_01
Einheit: CLIENT_US_JBAD_AH64D_01-1

Gruppe: CLIENT_US_JBAD_AH64D_02
Einheit: CLIENT_US_JBAD_AH64D_02-1
```

Multicrew-Sitze des AH-64D zählen nicht als zusätzliche Luftfahrzeuge.

### 5.3 CH-47 – zwei Spielergruppen

```text
Typ: dasselbe DCS-CH-47F-Modell wie das KI-Template

Gruppe: CLIENT_US_JBAD_CH47_01
Einheit: CLIENT_US_JBAD_CH47_01-1

Gruppe: CLIENT_US_JBAD_CH47_02
Einheit: CLIENT_US_JBAD_CH47_02-1
```

Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge.

## 6. Optionale UH-60L-Spielergruppen

Für den aktuellen modfreien Kernabschluss nicht anlegen.

Falls später die UH-60L-Modvariante gebaut wird, müssen entweder beide Gruppen vorhanden sein oder beide fehlen:

```text
Typ: UH-60L Community Mod

Gruppe: CLIENT_US_JBAD_UH60L_01
Einheit: CLIENT_US_JBAD_UH60L_01-1

Gruppe: CLIENT_US_JBAD_UH60L_02
Einheit: CLIENT_US_JBAD_UH60L_02-1
```

Ein einzelner UH-60L-Slot ist nicht zulässig.

## 7. Verpflichtende sichtbare Luftfahrzeug-Statics

Statics besitzen keinen separaten MOOSE-Gruppennamen. Der nachfolgende Name wird als eindeutiger Static-/Einheitenname im Mission Editor eingetragen.

### 7.1 OH-58D – sieben Statics

```text
STATIC_AIR_US_JBAD_OH58D_01
STATIC_AIR_US_JBAD_OH58D_02
STATIC_AIR_US_JBAD_OH58D_03
STATIC_AIR_US_JBAD_OH58D_04
STATIC_AIR_US_JBAD_OH58D_05
STATIC_AIR_US_JBAD_OH58D_06
STATIC_AIR_US_JBAD_OH58D_07
```

Typ jeweils:

```text
OH-58D
```

### 7.2 AH-64D – vier Statics

```text
STATIC_AIR_US_JBAD_AH64D_01
STATIC_AIR_US_JBAD_AH64D_02
STATIC_AIR_US_JBAD_AH64D_03
STATIC_AIR_US_JBAD_AH64D_04
```

Typ jeweils:

```text
AH-64D BLK II
```

### 7.3 UH-60A – vier Statics

```text
STATIC_AIR_US_JBAD_UH60_01
STATIC_AIR_US_JBAD_UH60_02
STATIC_AIR_US_JBAD_UH60_03
STATIC_AIR_US_JBAD_UH60_04
```

Typ jeweils:

```text
UH-60A
```

### 7.4 CH-47 – fünf Statics

```text
STATIC_AIR_US_JBAD_CH47_01
STATIC_AIR_US_JBAD_CH47_02
STATIC_AIR_US_JBAD_CH47_03
STATIC_AIR_US_JBAD_CH47_04
STATIC_AIR_US_JBAD_CH47_05
```

Typ jeweils:

```text
dasselbe DCS-CH-47F-Modell wie das KI-Template
```

## 8. Bereits vorhandener Warehouse-Anker

Nicht erneut anlegen, sofern in der aktuellen Testmission weiterhin vorhanden:

```text
Static-/Einheitenname: WH_AIR_US_JALALABAD
Koalition: BLUE
Land: USA
```

Das Warehouse-Static ist kein Luftfahrzeug und zählt nicht zu den 20 Luftfahrzeug-Statics.

## 9. Empfohlene Flächenverteilung

### OH-58D

```text
G01-G07: bevorzugt die sieben sichtbaren OH-58D-Statics
```

Spieler- und KI-Templatepositionen dürfen diese Flächen nicht überlagern.

### CH-47

```text
C01-C14: bevorzugter Heavy-Lift-Bereich
```

Dort unterbringen:

```text
5 CH-47-Statics
2 CH-47-Spielergruppen
1 CH-47-KI-Templateposition
```

Mindestens weitere freie CH-47-taugliche Positionen für spätere KI-Spawns und Rückkehr freihalten.

### AH-64D und UH-60

Südliche und westliche Aprons für:

```text
4 AH-64D-Statics
4 UH-60A-Statics
2 AH-64D-Spielergruppen
2 AH-64D-KI-Templateeinheiten
2 UH-60A-KI-Templateeinheiten
```

Statics können frei auf geeigneten Apronflächen stehen. Sie dürfen keine DCS-Parkingposition, Rollroute, Startfläche, Rückkehrposition oder Rotorscheibe blockieren.

## 10. Was ausdrücklich nicht zusätzlich gesetzt wird

```text
keine 24 einzelnen OH-58D-Gruppen
keine 8 einzelnen AH-64D-Gruppen
keine 8 einzelnen UH-60-Gruppen
keine 8 einzelnen CH-47-Gruppen
keine zusätzlichen sichtbaren Reserveflugzeuge über die Static-Obergrenzen hinaus
keine Mi-8-SQUADRON
keine UH-1-SQUADRON
```

Die nicht physisch dargestellten Bestandsflugzeuge bleiben virtuelle Reserve.

## 11. Kontrollsumme vor dem Test

Ohne optionalen UH-60L-Mod müssen im Mission Editor für Jalalabad vorbereitet sein:

```text
KI-Templates:              5 Gruppen / 7 Luftfahrzeuge
Spielergruppen:            6 Gruppen / 6 Luftfahrzeuge
Luftfahrzeug-Statics:     20 Objekte
Warehouse-Static:          1 Objekt
```

Nach Typen, nur Luftfahrzeuge:

```text
OH-58D:  2 KI + 2 Spieler + 7 Statics = 11 physisch vorbereitete Luftfahrzeuge
AH-64D:  2 KI + 2 Spieler + 4 Statics =  8 physisch vorbereitete Luftfahrzeuge
UH-60A:  2 KI + 0 Spieler + 4 Statics =  6 physisch vorbereitete Luftfahrzeuge
CH-47:   1 KI + 2 Spieler + 5 Statics =  8 physisch vorbereitete Luftfahrzeuge
---------------------------------------------------------------
Gesamt:                                33 physisch vorbereitete Luftfahrzeuge
```

Diese 33 physisch vorbereiteten Luftfahrzeuge repräsentieren einen logischen Gesamtbestand von 48 Luftfahrzeugen. Die Differenz ist virtuelle Reserve; zusätzlich sind die Late-Activation-KI-Templates beim Missionsstart nicht sichtbar.