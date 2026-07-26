# 33 – Kandahar Mustang Ramp Army Aviation Baseline

## 1. Dokumentstatus

**Historische Stationierung bestätigt; erste Missionseditor-Baseline festgelegt; Parking- und Runtime-Validierung noch offen**

Dieses Dokument ergänzt das Kandahar Air Operations Manifest um den bislang fehlenden US-Army-Rotary-Wing-Knoten auf der Mustang Ramp von Kandahar Airfield für November/Dezember 2011.

Die nachstehenden Zahlen sind keine Behauptung über den vollständigen administrativen Sollbestand der 159th Combat Aviation Brigade. Sie definieren eine konservative, im Missionseditor handhabbare erste OMW-Baseline, die den historischen Großverband und die auf den Satellitenbildern erkennbare Größenordnung sichtbar macht, ohne vor der Parking- und Performanceprüfung die gesamte Ramp maximal zu belegen.

## 2. Historische Einordnung

Im März 2011 übernahm die 159th Combat Aviation Brigade, Task Force Thunder, die Rotary-Wing-Mission für Regional Command South. Noch am 21. Dezember 2011 werden die Einrichtungen der Brigade auf der Mustang Ramp in Kandahar sowie Angehörige des 563rd Aviation Support Battalion, des 7th Squadron, 17th Cavalry Regiment und des 7th Battalion, 101st Aviation Regiment ausdrücklich dokumentiert.

Für Kandahar sind damit folgende Muster und Verbände als Kategorie A – stationierter Verband – zu behandeln:

```text
159th Combat Aviation Brigade – Task Force Thunder
├── 3rd Battalion, 101st Aviation Regiment / Task Force Attack
│   └── AH-64 Apache
├── 7th Squadron, 17th Cavalry Regiment / Task Force Palehorse
│   └── OH-58D Kiowa Warrior
├── 7th Battalion, 101st Aviation Regiment / Task Force Lift
│   └── CH-47F Chinook
├── Brigade-UH-60-Element
│   └── UH-60 Black Hawk
└── 563rd Aviation Support Battalion / Task Force Fighting
    └── Wartung und Instandsetzung
```

Die genaue Company-/Battalion-Zuordnung des gesamten auf Kandahar sichtbaren UH-60-Bestands bleibt noch zu präzisieren. Der UH-60-Bestand als Teil der Brigade auf der Mustang Ramp ist jedoch ausreichend belegt.

Die USAF-HH-60G-Komponente der 26th Expeditionary Rescue Squadron bleibt ein separater Air-Force-CSAR-Verband und wird nicht in die Army-Mustang-Ramp-Bestände eingerechnet.

## 3. Verbindliche DCS-Abbildungsregel

```text
AH-64:
Client = AH-64D-Spielermodul
KI/Static = native DCS-AH-64-Variante

OH-58D:
Client = OH-58D-Spielermodul
KI/Static = native DCS-OH-58D-Variante

CH-47:
Client = CH-47F-Spielermodul
KI/Static = CH-47D

UH-60:
Client = keiner in der Basismission
KI/Static = UH-60A

HH-60G:
separater USAF-CSAR-Verband
KI/Static = UH-60A als technischer Ersatz
```

Community-Mods bleiben optional und dürfen nicht Voraussetzung der Basismission werden.

## 4. Spieler-/Client-Assets

Projektweit gelten weiterhin:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Flugplatz
1 Luftfahrzeug je Client-Gruppe
```

### 4.1 AH-64D

```text
CLIENT_US_KAF_AH64D_01
  CLIENT_US_KAF_AH64D_01_UNIT_01

CLIENT_US_KAF_AH64D_02
  CLIENT_US_KAF_AH64D_02_UNIT_01
```

Anzahl:

```text
2 Clientgruppen
2 spielbare AH-64D insgesamt
```

### 4.2 OH-58D

```text
CLIENT_US_KAF_OH58D_01
  CLIENT_US_KAF_OH58D_01_UNIT_01

CLIENT_US_KAF_OH58D_02
  CLIENT_US_KAF_OH58D_02_UNIT_01
```

Anzahl:

```text
2 Clientgruppen
2 spielbare OH-58D insgesamt
```

### 4.3 CH-47F

```text
CLIENT_US_KAF_CH47F_01
  CLIENT_US_KAF_CH47F_01_UNIT_01

CLIENT_US_KAF_CH47F_02
  CLIENT_US_KAF_CH47F_02_UNIT_01
```

Anzahl:

```text
2 Clientgruppen
2 spielbare CH-47F insgesamt
```

### 4.4 UH-60

In der modfreien Basismission werden keine UH-60-Clientgruppen angelegt, da kein natives DCS-UH-60-Spielermodul verfügbar ist.

```text
UH-60-Clientgruppen: 0
```

## 5. KI-Templates

Alle Templates:

- BLUE / USA;
- Late Activation;
- nicht `Uncontrolled`;
- eindeutige Gruppen- und Unitnamen;
- keine zusätzlichen logischen Luftfahrzeuge allein durch ihre Existenz im Missionseditor;
- spätere Registrierung über MOOSE AIRWING/SQUADRON nach MOOSE-First-Prüfung.

### 5.1 AH-64

```text
TPL_AIR_US_KAF_AH64D_CAS_2SHIP
  TPL_AIR_US_KAF_AH64D_CAS_2SHIP_UNIT_01
  TPL_AIR_US_KAF_AH64D_CAS_2SHIP_UNIT_02

TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP
  TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP_UNIT_01
  TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP_UNIT_02
```

Templateumfang:

```text
2 Gruppen
4 Templateflugzeuge
```

### 5.2 OH-58D

```text
TPL_AIR_US_KAF_OH58D_RECON_2SHIP
  TPL_AIR_US_KAF_OH58D_RECON_2SHIP_UNIT_01
  TPL_AIR_US_KAF_OH58D_RECON_2SHIP_UNIT_02

TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
  TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP_UNIT_01
  TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP_UNIT_02
```

Templateumfang:

```text
2 Gruppen
4 Templateflugzeuge
```

### 5.3 CH-47

```text
TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP
  TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP_UNIT_01

TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP
  TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP_UNIT_01
```

Templateumfang:

```text
2 Gruppen
2 Templateflugzeuge
```

Die Trennung erlaubt später unterschiedliche Payload-, Cargo-, OPSTRANSPORT- oder AUFTRAG-Konfigurationen. Falls MOOSE beide Rollen mit einem einzigen Template vollständig abbilden kann, ist vor einer Doppelregistrierung MOOSE-first zu prüfen, ob ein Template genügt.

### 5.4 UH-60

```text
TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP
  TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP_UNIT_01
  TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP_UNIT_02

TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP
  TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP_UNIT_01
```

Templateumfang:

```text
2 Gruppen
3 Templateflugzeuge
```

Das MEDEVAC-Template ist eine Army-MEDEVAC-/Utility-Abbildung und bleibt vom bereits vorhandenen USAF-HH-60G-CSAR-Lead-/Cover-Paar getrennt.

## 6. Sichtbare Static-Baseline

Die erste Baseline soll die Größe des Army-Aviation-Knotens sichtbar machen, ohne die Ramp vollständig mit statischen Objekten zu füllen.

```text
AH-64:   8 Statics
OH-58D:  8 Statics
CH-47D: 10 Statics
UH-60A:  8 Statics
Gesamt: 34 Army-Aviation-Statics
```

Diese 34 Objekte kommen zusätzlich zu den bereits vorhandenen zwei USAF-HH-60G-/CSAR-Statics hinzu. Die HH-60G-Darstellungen bleiben separat benannt und werden nicht in die Army-Zahl eingerechnet.

### 6.1 AH-64

```text
STATIC_AIR_US_KAF_AH64_01
STATIC_AIR_US_KAF_AH64_02
STATIC_AIR_US_KAF_AH64_03
STATIC_AIR_US_KAF_AH64_04
STATIC_AIR_US_KAF_AH64_05
STATIC_AIR_US_KAF_AH64_06
STATIC_AIR_US_KAF_AH64_07
STATIC_AIR_US_KAF_AH64_08
```

### 6.2 OH-58D

```text
STATIC_AIR_US_KAF_OH58D_01
STATIC_AIR_US_KAF_OH58D_02
STATIC_AIR_US_KAF_OH58D_03
STATIC_AIR_US_KAF_OH58D_04
STATIC_AIR_US_KAF_OH58D_05
STATIC_AIR_US_KAF_OH58D_06
STATIC_AIR_US_KAF_OH58D_07
STATIC_AIR_US_KAF_OH58D_08
```

### 6.3 CH-47D

```text
STATIC_AIR_US_KAF_CH47_01
STATIC_AIR_US_KAF_CH47_02
STATIC_AIR_US_KAF_CH47_03
STATIC_AIR_US_KAF_CH47_04
STATIC_AIR_US_KAF_CH47_05
STATIC_AIR_US_KAF_CH47_06
STATIC_AIR_US_KAF_CH47_07
STATIC_AIR_US_KAF_CH47_08
STATIC_AIR_US_KAF_CH47_09
STATIC_AIR_US_KAF_CH47_10
```

### 6.4 UH-60A

```text
STATIC_AIR_US_KAF_UH60_01
STATIC_AIR_US_KAF_UH60_02
STATIC_AIR_US_KAF_UH60_03
STATIC_AIR_US_KAF_UH60_04
STATIC_AIR_US_KAF_UH60_05
STATIC_AIR_US_KAF_UH60_06
STATIC_AIR_US_KAF_UH60_07
STATIC_AIR_US_KAF_UH60_08
```

## 7. Summen für den ersten Missionseditor-Ausbauschritt

### Spieler

```text
AH-64D: 2
OH-58D: 2
CH-47F: 2
UH-60:  0
Gesamt: 6 Clientgruppen / 6 Spielerluftfahrzeuge
```

### KI-Templates

```text
AH-64:  2 Gruppen / 4 Flugzeuge
OH-58D: 2 Gruppen / 4 Flugzeuge
CH-47:  2 Gruppen / 2 Flugzeuge
UH-60:  2 Gruppen / 3 Flugzeuge
Gesamt: 8 Templategruppen / 13 Templateflugzeuge
```

### Statics

```text
AH-64:   8
OH-58D:  8
CH-47D: 10
UH-60A:  8
Gesamt: 34 neue Army-Aviation-Statics
```

## 8. Platzierungsprinzip

- Clientpositionen zuerst reservieren.
- Danach für dynamische KI geeignete Start-/Landepositionen freihalten.
- Statics in den verbleibenden Revettements und auf optisch plausiblen Mustang-Ramp-Ständen verteilen.
- CH-47 wegen Rotordurchmesser und Tandemrotor-Geometrie nur auf ausreichend großen Ständen platzieren.
- AH-64 und OH-58D nicht wahllos mischen, sondern erkennbare Teilbereiche beziehungsweise Reihen bilden.
- UH-60 und CH-47 dürfen im Wartungs-/Supportbereich gemischt erscheinen, wenn dies dem Satellitenbild entspricht.
- Keine künstlichen Zonen nur zur optischen Gruppierung anlegen.
- Bewusst durch Statics belegte DCS-Parking-Nodes später per Laufzeitdiagnose erfassen und für dynamische KI sperren.

## 9. Noch offene Punkte

Vor der Runtime-Implementierung sind noch zu klären:

```text
genaue DCS-Typnamen aller Client-, KI- und Static-Varianten
genaue Mustang-Ramp-Parking- und Spawnpositionen
Liveries für 159th CAB und Unterverbände
Payloads und ROE für AH-64 und OH-58D
Cargo-/Slingload-Konfiguration für CH-47
Rollenaufteilung des UH-60-Bestands
logischer SQUADRON-Bestand je Verband
Persistenz und Verlustrechnung
Zusammenspiel mit USAF-HH-60G-CSAR
```

## 10. MOOSE-First-Anforderung

Vor eigener Implementierung sind insbesondere zu prüfen:

- AIRWING und SQUADRON für getrennte Army-Unterverbände;
- AUFTRAG-Rollen für CAS, ESCORT, RECONNAISSANCE, TRANSPORT und MEDEVAC;
- OPSTRANSPORT für CH-47 und UH-60;
- Cargo- und Slingload-Unterstützung;
- Parking-, Safe-Parking- und TerminalID-Mechanismen;
- Asset-Bestand, Verlust und Wiederverfügbarkeit;
- Formationseinstellungen für Kampf-, Aufklärungs- und Transporthubschrauber.

## 11. Autoritative Festlegung

Für den nächsten Kandahar-Missionseditor-Ausbauschritt gilt:

```text
AH-64, OH-58D, CH-47 und UH-60 sind stationierte Kategorie-A-Muster.
Die Mustang Ramp wird als eigener Army-Aviation-Knoten aufgebaut.
Es werden 6 Clientgruppen, 8 KI-Templategruppen und 34 Army-Statics vorbereitet.
UH-60 erhält in der modfreien Basismission keine Clientgruppen.
USAF-HH-60G-CSAR bleibt organisatorisch und technisch getrennt.
Alle Runtime-Registrierungen und Rollen werden MOOSE-first entwickelt.
```