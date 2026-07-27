---
document_id: OMW-AIR-KANDAHAR-MUSTANG-RAMP
status: PLANNED
authoritative_for:
  - Kandahar Mustang Ramp Army Aviation baseline
  - Kandahar Army Aviation clients templates and statics
  - 159th CAB organizational representation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/33-kandahar-mustang-ramp-army-aviation-baseline.md
  - prior blanket deferral of Kandahar AH-64 OH-58D CH-47 and Army UH-60
source_branch: docs/bagram-air-operations-manifest
validated_in_dcs: false
---

# 36 – Kandahar Mustang Ramp Army Aviation Baseline

## 1. Dokumentstatus

Die historische Stationierung ist ausreichend bestätigt. Die erste Missionseditor-Baseline ist festgelegt; Parking-, Performance- und Runtime-Validierung stehen noch aus.

Dieses Dokument ergänzt `OMW-AIR-KANDAHAR-MANIFEST` um den US-Army-Rotary-Wing-Knoten auf der Mustang Ramp. Die Zahlen sind eine konservative OMW-Arbeitsbaseline und keine Behauptung über den vollständigen administrativen Sollbestand der 159th Combat Aviation Brigade.

## 2. Historische Einordnung

Im März 2011 übernahm die 159th Combat Aviation Brigade / Task Force Thunder die Rotary-Wing-Mission für Regional Command South. Einrichtungen und Angehörige der Brigade auf der Mustang Ramp sind bis Dezember 2011 dokumentiert.

Kategorie-A-Struktur:

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

Die genaue Unterverbandszuordnung des gesamten UH-60-Bestands bleibt zu präzisieren. Der UH-60-Bestand als Teil der Brigade ist für die OMW-Rampbaseline ausreichend belegt.

Die USAF-HH-60G-Komponente der 26th Expeditionary Rescue Squadron bleibt organisatorisch und bestandsseitig getrennt.

## 3. DCS-Abbildungsregel

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
Client = keiner in der modfreien Basismission
KI/Static = UH-60A

HH-60G:
separater USAF-CSAR-Verband
KI/Static = UH-60A als technischer Ersatz
```

Community-Mods bleiben optional.

## 4. Client-Assets

Projektweit:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
1 Luftfahrzeug je Clientgruppe
```

### AH-64D

```text
CLIENT_US_KAF_AH64D_01
CLIENT_US_KAF_AH64D_02
```

### OH-58D

```text
CLIENT_US_KAF_OH58D_01
CLIENT_US_KAF_OH58D_02
```

### CH-47F

```text
CLIENT_US_KAF_CH47F_01
CLIENT_US_KAF_CH47F_02
```

### UH-60

```text
UH-60-Clientgruppen in der modfreien Basismission: 0
```

Gesamt:

```text
6 Clientgruppen / 6 Spielerluftfahrzeuge
```

## 5. KI-Templates

Alle Templates sind BLUE / USA, Late Activation, nicht `Uncontrolled` und keine zusätzlichen logischen Luftfahrzeuge.

### AH-64D

```text
TPL_AIR_US_KAF_AH64D_CAS_2SHIP
  2 Units
TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP
  2 Units
```

### OH-58D

```text
TPL_AIR_US_KAF_OH58D_RECON_2SHIP
  2 Units
TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
  2 Units
```

### CH-47

```text
TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP
  1 Unit
TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP
  1 Unit
```

Vor einer Doppelregistrierung ist MOOSE-first zu prüfen, ob Transport und Slingload über ein gemeinsames Template mit unterschiedlichen Payloads beziehungsweise Aufträgen vollständig abgebildet werden können.

### UH-60

```text
TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP
  2 Units
TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP
  1 Unit
```

Das Army-MEDEVAC-Template bleibt vom USAF-HH-60G-CSAR-Lead-/Cover-Paar getrennt.

Template-Summe:

```text
AH-64D: 2 Gruppen / 4 Flugzeuge
OH-58D: 2 Gruppen / 4 Flugzeuge
CH-47: 2 Gruppen / 2 Flugzeuge
UH-60: 2 Gruppen / 3 Flugzeuge
Gesamt: 8 Gruppen / 13 Templateflugzeuge
```

## 6. Sichtbare Static-Baseline

```text
AH-64:   8 Statics
OH-58D:  8 Statics
CH-47D: 10 Statics
UH-60A:  8 Statics
Gesamt: 34 Army-Aviation-Statics
```

Diese 34 Objekte kommen zusätzlich zu den zwei USAF-HH-60G-/CSAR-Statics. Sie sind keine zusätzlichen Airframes im logischen Bestand.

Benennung:

```text
STATIC_AIR_US_KAF_AH64_01 ... _08
STATIC_AIR_US_KAF_OH58D_01 ... _08
STATIC_AIR_US_KAF_CH47_01 ... _10
STATIC_AIR_US_KAF_UH60_01 ... _08
```

## 7. Platzierungsprinzip

1. Clientpositionen zuerst reservieren.
2. Dynamische KI-Start-/Landepositionen freihalten.
3. Statics in verbleibenden Revettements und plausiblen Rampständen verteilen.
4. CH-47 nur auf ausreichend großen Ständen platzieren.
5. AH-64 und OH-58D in erkennbaren Teilbereichen oder Reihen aufstellen.
6. UH-60 und CH-47 dürfen im Wartungs-/Supportbereich plausibel gemischt sein.
7. Keine künstlichen Zonen zur rein optischen Gruppierung anlegen.
8. Durch Statics belegte Parking-Nodes per Laufzeitdiagnose erfassen und für dynamische KI sperren.

## 8. Bestands- und Architekturregel

Getrennt zu führen:

```text
historischer / logischer SQUADRON-Bestand
sichtbare Statics
Client-Reservierungen
Missionseditor-Templates
aktive KI-Luftfahrzeuge
virtuelle Reserve
verlorene oder beschädigte Luftfahrzeuge
```

Die statische Rampbaseline definiert keine automatische logische SQUADRON-Stärke. Diese wird vor AIRWING-Integration gesondert und quellenbezogen festgelegt.

## 9. MOOSE-First-Anforderung

Vor eigener Implementierung sind mindestens zu prüfen:

- `AIRWING` und getrennte `SQUADRON`-Strukturen;
- `AUFTRAG` für CAS, ESCORT, RECONNAISSANCE, TRANSPORT und MEDEVAC;
- `OPSTRANSPORT` für CH-47 und UH-60;
- Cargo- und Slingload-Unterstützung;
- Parking, Safe Parking und TerminalIDs;
- Assetbestand, Verlust und Wiederverfügbarkeit;
- Formationseinstellungen;
- Payload- und ROE-Steuerung.

Eine verbleibende Eigenentwicklung benötigt eine dokumentierte MOOSE-Lücke und ausdrückliche Projektinhaberfreigabe.

## 10. Offene Punkte

- genaue DCS-Typnamen aller Client-, KI- und Static-Varianten;
- konkrete Mustang-Ramp-Parking- und Spawnpositionen;
- Liveries für 159th CAB und Unterverbände;
- Payloads und ROE für AH-64D und OH-58D;
- Cargo-/Slingload-Konfiguration für CH-47;
- Rollenaufteilung des UH-60-Bestands;
- logischer SQUADRON-Bestand je Verband;
- Persistenz und Verlustrechnung;
- Zusammenspiel mit USAF-HH-60G-CSAR;
- Performance bei 34 zusätzlichen Statics.

## 11. Autoritative Festlegung

```text
AH-64D, OH-58D, CH-47 und UH-60 sind stationierte Kategorie-A-Muster.
Die Mustang Ramp wird als eigener Army-Aviation-Knoten aufgebaut.
Vorbereitet werden 6 Clientgruppen, 8 KI-Templategruppen und 34 Army-Statics.
UH-60 erhält in der modfreien Basismission keine Clientgruppen.
USAF-HH-60G-CSAR bleibt organisatorisch und technisch getrennt.
Runtime-Registrierung und Rollen werden MOOSE-first entwickelt.
```
