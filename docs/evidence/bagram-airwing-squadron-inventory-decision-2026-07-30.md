---
document_id: OMW-AIR-BAGRAM-SQUADRON-INVENTORY-DECISION
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram active AIRWING scope
  - Bagram non-fighter SQUADRON identities
  - Bagram initial logical aircraft inventories
  - Bagram one-ship asset-group mapping
scenario_period: 2010-08-01/2011-12-31
reference_snapshot: 2011-07
satellite_context: 2011-12-15
source_branch: docs/bagram-air-operations-manifest
validated_in_dcs: false
supersedes_subject_values:
  - open C-130 inventory in OMW-AIR-BAGRAM-ME-BASELINE
  - open HH-60G inventory in OMW-AIR-BAGRAM-ME-BASELINE
  - open UH-60 Utility inventory in OMW-AIR-BAGRAM-ME-BASELINE
  - generic non-fighter SQUADRON identifiers in OMW-AIR-BAGRAM-ME-BASELINE
---

# Bagram AIRWING-/SQUADRON-Bestandsentscheidung – 30.07.2026

## 1. Zweck

Dieses Dokument schließt die bislang offenen Bagram-Bestandsentscheidungen für C-130, HH-60G und UH-60 Utility und führt die bereits beschlossene CH-47-Zahl in die konkrete AIRWING-/SQUADRON-Zielstruktur über.

Die Zahlen sind verbindliche OMW-Kampagnenbestände. Sie unterscheiden sich ausdrücklich von:

- auf einer einzelnen Satellitenaufnahme sichtbaren Luftfahrzeugen;
- gleichzeitig aktiven KI-Gruppen;
- Client-Slots;
- Mission-Editor-Templates;
- Statics;
- Gesamtbeständen der jeweiligen Teilstreitkraft in Afghanistan.

## 2. Verbindlicher aktiver Bagram-AIRWING-Umfang

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS       13 F-15E
├── SQ_US_BGRM_F16C_121_EFS       13 F-16C
├── SQ_US_BGRM_C130_774_EAS       20 C-130
├── SQ_US_BGRM_HH60G_83_ERQS       6 HH-60G
├── SQ_US_BGRM_UH60_A_1_169       10 UH-60 Utility
└── SQ_US_BGRM_CH47_B_7_158       13 CH-47

WH_AIR_US_BAGRAM
```

Damit umfasst der aktive Bagram-Knoten sechs SQUADRONs unter genau einem AIRWING.

## 3. Verbindliche Bestände und Evidenzstatus

| SQUADRON | Einheit | Muster | Bestand | Status |
|---|---|---|---:|---|
| `SQ_US_BGRM_F15E_335_EFS` | 335th Expeditionary Fighter Squadron | F-15E | 13 | bereits bindend |
| `SQ_US_BGRM_F16C_121_EFS` | 121st Expeditionary Fighter Squadron | F-16C; DCS Block-50-Ersatz für historischen Block 30 | 13 | bereits bindend |
| `SQ_US_BGRM_C130_774_EAS` | 774th Expeditionary Airlift Squadron | C-130-Familie; DCS C-130J-30 | 20 | beschlossen; quellen- und satellitengestützte OMW-Ableitung |
| `SQ_US_BGRM_HH60G_83_ERQS` | 83rd Expeditionary Rescue Squadron | HH-60G; DCS-Ersatz gemäß Manifest | 6 | beschlossene OMW-Rekonstruktion |
| `SQ_US_BGRM_UH60_A_1_169` | A Company, 1-169 GSAB, attached to TF Phoenix | UH-60 Utility | 10 | beschlossene Company-/Satellitenbild-Ableitung |
| `SQ_US_BGRM_CH47_B_7_158` | B Company, 7-158 Aviation Regiment | CH-47 | 13 | bindender Bagram-Anteil des gesonderten 25er-Einsatzpools |

## 4. Quellen- und Ableitungsgrenzen

### 4.1 Juli-2011-ORBAT

`122362406-Afghanistan-order-of-battle-july-2011.pdf` bleibt die primäre Quelle für aktive Einheit, übergeordnete Formation, dokumentierten Standort und Rolle im Juli 2011.

Ergänzende zeitgenössische 10th-CAB-Publikationen und offizielle Einheitsberichte präzisieren Companies, Attachments, Muster, Aufgaben und Operationsräume. Satellitenbilder liefern sichtbare Mindestbestände und Rampenbelegung, aber keine vollständige administrative Stärke.

### 4.2 C-130

Die Satellitenaufnahme vom 15.12.2011 zeigt mindestens 17 Flugzeuge der C-130-Familie. Die Aufnahme erlaubt keine sichere Einzeltrennung zwischen Standardrumpf-, verlängerten Transport- und möglichen Spezialvarianten. Der aktive OMW-Transportbestand der 774th EAS wird deshalb nicht direkt mit der Bildzahl gleichgesetzt.

Der beschlossene logische Bestand lautet:

```text
20 C-130 für SQ_US_BGRM_C130_774_EAS
```

Historische Musterfamilie und DCS-Abbildung müssen getrennt dokumentiert bleiben. Die DCS-C-130J-30-Repräsentation behauptet nicht, jedes historische Luftfahrzeug sei eine J-30 gewesen.

### 4.3 HH-60G

Die 83rd ERQS ist für Bagram und HH-60G belegt. Ein westlicher Satellitenbildcluster mit Black-Hawk-artigen Maschinen unterstützt einen kleinen Rescue-Pool, erlaubt jedoch keine sichere Typidentifikation jedes einzelnen Luftfahrzeugs.

Der beschlossene logische Bestand lautet:

```text
6 HH-60G für SQ_US_BGRM_HH60G_83_ERQS
```

USAF Personnel Recovery und Army UH-60 Utility beziehungsweise Army MEDEVAC dürfen nicht zusammengelegt werden.

### 4.4 UH-60 Utility

A Company, 1-169 Aviation Regiment ist als UH-60-Komponente von Task Force Phoenix belegt. Die Satellitenaufnahme zeigt größere Army-Black-Hawk-Cluster, ohne Utility und MEDEVAC sicher für jedes Luftfahrzeug trennen zu können.

Der beschlossene aktive Bagram-Utility-Bestand lautet:

```text
10 UH-60 Utility für SQ_US_BGRM_UH60_A_1_169
```

Dieser Wert erzeugt keinen zusätzlichen separaten Army-MEDEVAC-Pool. Ein solcher Pool benötigt eine eigene spätere Projektentscheidung.

### 4.5 CH-47

Der Bestand von 13 gehört ausschließlich zum dokumentierten und rekonstruierten Einsatzpool von B Company, 7-158 Aviation Regiment:

```text
19 organische CH-47
+ 6 zusätzlich zugewiesene CH-47
= 25 CH-47 im betrachteten B/7-158-Einsatzpool

OMW-Verteilung dieses Pools:
Bagram 13
Salerno 6
Shank 6
```

Die Bagram-Aufnahme vom 15.12.2011 zeigt mindestens sieben CH-47. Diese sieben sind ein sichtbarer Mindestbestand und nicht die Obergrenze. Die 13 dürfen nicht als gesamter CH-47-Bestand Bagrams, der 10th CAB oder Afghanistans bezeichnet werden.

## 5. Ausdrücklich ausgeschlossene aktive Muster

Folgende historisch dokumentierten beziehungsweise visuell beobachteten Muster gehören nicht zum aktiven OMW-Bagram-AIRWING und erhalten keine SQUADRON, keinen logischen Bestand und keine Template-Anforderung:

```text
OH-58D
MC-12W
EC-130H
EA-6B
```

Begründungen:

- nicht Teil des bereits festgelegten OMW-Implementierungsumfangs;
- teilweise nicht im verwendeten DCS-Arsenal vorhanden;
- historische oder sichtbare Präsenz allein erzeugt keine aktive Projektanforderung;
- drei sichtbare OH-58D werden als physische Präsenz beziehungsweise möglicher Wartungs-/Transient-Kontext geführt, nicht als beweisbare vollständige lokale Scout-Einheit.

Ein separater Army-MEDEVAC-SQUADRONbestand ist ebenfalls nicht beschlossen.

## 6. Verbindliche Template-Zuordnung

Die vorhandenen Mission-Editor-Seeds werden wie folgt gebunden:

```text
SQ_US_BGRM_F15E_335_EFS
  TPL_AIR_US_BGRM_F15E_CAS_2SHIP
  TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP

SQ_US_BGRM_F16C_121_EFS
  TPL_AIR_US_BGRM_F16_CAS_2SHIP

SQ_US_BGRM_C130_774_EAS
  TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP

SQ_US_BGRM_CH47_B_7_158
  TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP

SQ_US_BGRM_UH60_A_1_169
  TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP
  TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP

SQ_US_BGRM_HH60G_83_ERQS
  TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP
  TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP
```

Templates sind Authoring-Seeds. Mehrere Templates derselben SQUADRON erzeugen keinen mehrfachen Bestand.

## 7. Exakte Asset-Gruppen-Abbildung für die 1-Ship-SQUADRONs

Die vier neu abgeschlossenen Bestände verwenden ausschließlich 1-Ship-Templates. Unter der Voraussetzung, dass der verwendete MOOSE-SQUADRON-Konstruktor Gruppen und nicht einzelne Luftfahrzeuge zählt, gilt als Testziel:

```text
SQ_US_BGRM_C130_774_EAS:   20 One-Ship-Asset-Gruppen = 20 Airframes
SQ_US_BGRM_HH60G_83_ERQS:   6 One-Ship-Asset-Gruppen =  6 Airframes
SQ_US_BGRM_UH60_A_1_169:   10 One-Ship-Asset-Gruppen = 10 Airframes
SQ_US_BGRM_CH47_B_7_158:   13 One-Ship-Asset-Gruppen = 13 Airframes
```

Vor Implementierung muss dies gegen die tatsächlich vendorte MOOSE-Version 2.9.18 und deren `SQUADRON`-API geprüft werden. Bei abweichender API-Semantik ist die Implementierung anzupassen; die beschlossenen Airframe-Bestände bleiben unverändert.

Für F-15E und F-16C bleibt die gesonderte ungerade 13-Airframe-Regel aus dem Manifest maßgeblich. Ein 2-Ship-Template darf niemals rechnerisch 14 Airframes erzeugen.

## 8. Client-, Static- und Bestandsgrenze

Clientgruppen, KI-Templates und Statics sind Repräsentationen desselben logischen Bestands.

```text
logical inventory
!= client count
!= template unit count
!= static count
!= simultaneously active AI
```

Insbesondere werden die vorhandenen Clients und Statics nicht zusätzlich zu den oben genannten Beständen addiert.

## 9. Implementierungsreihenfolge

Die erste MOOSE-Laufzeitintegration soll in dieser Reihenfolge erfolgen:

1. Warehouse-Anker `WH_AIR_US_BAGRAM` prüfen;
2. `AW_US_BAGRAM` erzeugen beziehungsweise binden;
3. C-130-, HH-60G-, UH-60- und CH-47-SQUADRONs mit den beschlossenen Beständen registrieren;
4. Fighter-SQUADRONs mit der bereits dokumentierten 13-Airframe-Sonderbehandlung registrieren;
5. Template-, Payload- und Mission-Capability-Zuordnung prüfen;
6. Safe Parking und Client-Blacklist diagnostizieren;
7. AIRWING erst nach bestandener Vorprüfung starten;
8. zunächst nur Bestands-, Spawn- und Rückkehrdiagnose durchführen;
9. AUFTRAG-/OPSTRANSPORT-/CSAR-Tests anschließend getrennt freigeben.

## 10. Noch offene technische Punkte

Die historischen Bestandsfragen für den aktiven Umfang sind geschlossen. Offen bleiben ausschließlich technische Implementierungs- und Acceptance-Fragen:

- genaue MOOSE-2.9.18-API-Semantik für `SQUADRON`-Assetgruppen;
- Payloadsets und Mission-Capabilities;
- TerminalID-basierte Parking-Allowlist beziehungsweise Blacklist;
- Safe-Parking-Verhalten je Größenklasse;
- Cooldown-, Wartungs-, Rückgabe- und Verlustzustände;
- CSAR- und OPSTRANSPORT-Ausführungsmodell;
- Persistenzübergabe an CampaignState;
- DCS-Laufzeitvalidierung.

## 11. Acceptance-Kern

Ein späterer Bagram-Basistest muss mindestens nachweisen:

```text
AIRWING: AW_US_BAGRAM genau einmal gestartet
SQUADRONs: genau 6 aktive SQUADRON-Registrierungen
Bestand:
  13 F-15E
  13 F-16C
  20 C-130
   6 HH-60G
  10 UH-60 Utility
  13 CH-47
keine zusätzliche OH-58-, MC-12W-, EC-130H-, EA-6B- oder Army-MEDEVAC-SQUADRON
keine Doppelzählung durch Clients, Templates oder Statics
keine spontane Mission ohne ausdrücklich freigegebenes Tasking
keine Registrierung vor erfolgreicher Warehouse-, Template- und Parking-Prüfung
```

## 12. Änderungsgrenze

Dieses Dokument beschließt Bestände und die AIRWING-/SQUADRON-Zielstruktur. Es ändert keine `.miz`, keine Lua-Laufzeitdatei, kein generiertes Bundle und keine vendorte MOOSE-Datei.
