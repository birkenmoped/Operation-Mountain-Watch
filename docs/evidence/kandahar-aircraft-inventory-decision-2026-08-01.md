---
document_id: OMW-EVIDENCE-KANDAHAR-AIRCRAFT-INVENTORY-2026-08-01
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar local OMW aircraft inventory decisions
  - Kandahar TF Thunder inventory values
  - Kandahar 451st AEW inventory values
  - separation of selected squadron inventories from unattributed aircraft visible on the 19 October 2011 satellite imagery
not_authoritative_for:
  - historical proof of exact real-world squadron strength
  - mission-ready or simultaneously active limits
  - DCS parking acceptance
  - AIRWING or SQUADRON runtime validation
scenario_period: 2010-08-01/2011-12-31
decision_date: 2026-08-01
source_branch: agent/kandahar-airwing-baseline-contract
source_documents:
  - docs/64-afghanistan-order-of-battle-july-2011.md
  - docs/evidence/kandahar-july-2011-orbat-unit-name-reconciliation.md
  - docs/19-active-air-orbat-decisions.md
  - docs/33-kandahar-air-operations-manifest.md
  - docs/36-kandahar-mustang-ramp-army-aviation-baseline.md
source_evidence:
  - project-owner supplied Google Earth / Maxar imagery dated 2011-10-19
approved_by_project_owner: true
validated_in_dcs: false
---

# Kandahar – verbindliche OMW-Luftfahrzeugbestände

## 1. Entscheidungsgrundlage

Die Juli-2011-ORBAT belegt die am Kandahar Airfield gemeldeten Verbände und Hauptmuster, nennt jedoch keine belastbaren lokalen Stückzahlen. Die Google-Earth-/Maxar-Aufnahmen vom 19.10.2011 liefern einen räumlich gegliederten Sichtbestand, aber keine vollständige Einheitszuordnung und keine mission-ready Stärke.

Die folgenden Werte sind daher eine ausdrückliche OMW-Kampagnenentscheidung aus:

```text
Juli-2011-ORBAT
+
Satelliten-Sichtbestand vom 19.10.2011
+
konservative Reserve für Einsatz, Wartung oder nicht sichtbare Abstellung
```

Sie sind keine Behauptung, dass die reale historische Sollstärke exakt diesen Zahlen entsprach.

## 2. Task Force Thunder / 159th Combat Aviation Brigade

Verbindlicher Kandahar-Stammknoten:

```text
AW_US_KAF_159_CAB_TF_THUNDER
AIRBASE.Afghanistan.Kandahar_Heliport
DCS ID 15
WH_AIR_US_KANDAHAR_HELI
```

### 2.1 Verbindliche SQUADRON-Bestände

```text
SQ_US_KAF_AH64_4_227_AVN
Task Force Guns / 4-227 Attack Aviation
8 x AH-64D

SQ_US_KAF_OH58D_7_17_CAV
Task Force Palehorse / 7-17 Air Cavalry
16 x OH-58D

SQ_US_KAF_CH47_7_101_GSAB
Task Force Lift / 7-101 General Support Aviation
16 x CH-47

SQ_US_KAF_UH60_7_101_GSAB
Task Force Lift / 7-101 General Support Aviation
32 x UH-60
```

### 2.2 Ableitung aus der Mustang-Ramp-Aufnahme

```text
AH-64D:
6 sichtbar
+ 2 Einsatz, Wartung oder Reserve
= 8 OMW-Bestand

OH-58D:
12 am Boden sichtbar
+ 2 airborne sichtbar
+ 2 Wartung oder Reserve
= 16 OMW-Bestand

CH-47:
13 auf der Mustang Ramp sichtbar
+ 3 Einsatz, Wartung oder Reserve
= 16 OMW-Bestand

UH-60:
28 auf der Mustang Ramp sichtbar
+ 4 Einsatz, Wartung oder Reserve
= 32 OMW-Bestand
```

Nur die Mustang-Ramp-Zählung wird für die TF-Thunder-Bestände verwendet. Auf dem eigentlichen Main Airfield sichtbare CH-47- und H-60-Familienmaschinen werden nicht automatisch TF Thunder zugerechnet.

### 2.3 RC-South-Verwaltungswerte einschließlich Tarinkot

Tarinkot bleibt mit folgenden lokalen Beständen festgelegt:

```text
14 x AH-64D
 6 x UH-60
 2 x CH-47
 0 x OH-58D
```

Daraus ergeben sich für die OMW-Verwaltung:

| Muster | Kandahar | Tarinkot | RC-South-Regionalpool |
|---|---:|---:|---:|
| AH-64D | 8 | 14 | 22 |
| OH-58D | 16 | 0 | 16 |
| CH-47 | 16 | 2 | 18 |
| UH-60 | 32 | 6 | 38 |

Diese Regionalwerte verhindern eine doppelte Bestandszählung zwischen Kandahar und Tarinkot.

## 3. 451st Air Expeditionary Wing

Verbindlicher Main-Airfield-Knoten:

```text
AW_US_KAF_451_AEW
AIRBASE.Afghanistan.Kandahar
DCS ID 7
WH_AIR_US_KANDAHAR
```

### 3.1 26th Expeditionary Rescue Squadron

```text
SQ_US_KAF_HH60G_26_ERQS
6 x HH-60G
DCS-Repräsentation: UH-60A
```

Auf dem Main Airfield wurden neun H-60-artige Luftfahrzeuge gezählt. Sechs werden dem 26th ERQS zugeordnet. Drei bleiben ohne aktive OMW-SQUADRON-Zuordnung, da Army MEDEVAC, SOF, Transit oder andere nicht vollständig erfasste Elemente möglich sind.

Die 46th Expeditionary Rescue Squadron stellt Guardian-Angel-Personal und erhält keinen eigenen Airframepool.

### 3.2 772nd Expeditionary Airlift Squadron

```text
SQ_US_KAF_C130_772_EAS
12 x C-130J-30
```

Der größte zusammenhängende Satellitencluster enthält elf C-130-Familienmaschinen. Der OMW-Bestand wird mit einer zusätzlichen Maschine für Einsatz, Wartung oder Reserve auf zwölf festgelegt.

Von 19 flugplatzweit sichtbaren C-130-Familienmaschinen bleiben sieben außerhalb des 772nd-EAS-Bestands. Sie können kanadische CC-130J, transiente USAF-/Koalitionsmaschinen oder andere nicht aufgelöste Betreiber umfassen.

### 3.3 361st Expeditionary Reconnaissance Squadron

```text
SQ_US_KAF_MQ1_361_ERS
4 x MQ-1

SQ_US_KAF_MQ9_361_ERS
2 x MQ-9

361st ERS MC-12-Komponente
6 x MC-12
```

Fünf UAV waren im Satellitenbereich sichtbar. Die Verteilung auf vier MQ-1 und zwei MQ-9 ist eine OMW-Planungsentscheidung; die Aufnahme belegt diese Typaufteilung nicht zweifelsfrei.

Die sechs MC-12 werden als historischer/logischer Bestand geführt. Solange DCS-Repräsentation, technische SQUADRON-Kennung und Mission-Editor-Vertrag nicht freigegeben sind, erzeugen sie keine aktive Runtime-SQUADRON.

### 3.4 74th Expeditionary Fighter Squadron

```text
SQ_US_KAF_A10C_74_EFS
16 x A-10C
```

Zwölf A-10-Familienmaschinen waren sichtbar. Vier weitere Luftfahrzeuge werden für Einsatz, Wartung oder Reserve angesetzt. Die 74th EFS bleibt die einzige aktive Kandahar-A-10C-SQUADRON; 75th und 107th EFS bleiben ausschließlich historischer Rotationskontext.

## 4. Verbindliche Gesamtübersicht

### 4.1 TF Thunder

| SQUADRON | Muster | Bestand |
|---|---|---:|
| SQ_US_KAF_AH64_4_227_AVN | AH-64D | 8 |
| SQ_US_KAF_OH58D_7_17_CAV | OH-58D | 16 |
| SQ_US_KAF_CH47_7_101_GSAB | CH-47 | 16 |
| SQ_US_KAF_UH60_7_101_GSAB | UH-60 | 32 |

### 4.2 451st AEW

| SQUADRON / Komponente | Muster | Bestand |
|---|---|---:|
| SQ_US_KAF_HH60G_26_ERQS | HH-60G | 6 |
| SQ_US_KAF_C130_772_EAS | C-130J-30 | 12 |
| SQ_US_KAF_MQ1_361_ERS | MQ-1 | 4 |
| SQ_US_KAF_MQ9_361_ERS | MQ-9 | 2 |
| 361st ERS MC-12-Komponente | MC-12 | 6 |
| SQ_US_KAF_A10C_74_EFS | A-10C | 16 |

### 4.3 Modellierter Kandahar-Gesamtbestand

```text
AH-64D:   8
OH-58D:  16
CH-47:   16
UH-60:   32
HH-60G:   6
C-130:   12
MQ-1:     4
MQ-9:     2
MC-12:    6
A-10C:   16
----------------
Gesamt: 118 Luftfahrzeuge
```

## 5. Nicht zugeordnete oder ausgeschlossene Sichtungen

Nicht in die oben festgelegten SQUADRON-Bestände eingerechnet:

```text
12 x CH-47-Familie am Main Airfield
 3 x weitere H-60-Familie am Main Airfield
 7 x weitere C-130-Familie
 3 x MV-22
 2 x wahrscheinlich CH-46E
 3 x wahrscheinlich CH-53E
afghanische Mi-8/Mi-17- und UH-1-artige Luftfahrzeuge
weitere transiente oder nicht aufgelöste Starrflügler
```

Marine-Luftfahrzeuge und afghanische/Host-Nation-Luftfahrzeuge bleiben außerhalb des aktuellen Kandahar-USAF-/Army-AIRWING-Arbeitsblocks.

## 6. Technische Konsequenzen

Die Bestandsentscheidung hebt die bisherige Blockade `Bestände noch festzulegen` für die in Abschnitt 4 genannten Pools auf.

Vor produktiver Registrierung bleiben weiterhin erforderlich:

```text
AIRWING- und SQUADRON-Konstruktion im kontrollierten Preflight
Template- und DCS-Typprüfung
Safe Parking pro Muster
mission-ready und maximal gleichzeitig aktiv festlegen
Client-Reservierungen und KI-Verfügbarkeit getrennt abbilden
Verlust-, Wartungs-, Rückkehr- und Reserveverwaltung
MC-12-Repräsentation separat entscheiden
```

Clients, KI-Templates und Statics sind Darstellungen dieser Bestände und werden nicht addiert.
