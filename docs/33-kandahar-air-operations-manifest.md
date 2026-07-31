---
document_id: OMW-AIR-KANDAHAR-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Mission Editor air-operations baseline
  - Kandahar July 2011 source-reported unit roster
  - Kandahar active A-10C unit and inventory
  - Kandahar dual-airbase AIRWING and warehouse architecture
  - Kandahar SQUADRON identifiers
  - Kandahar-wide runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: AIRWING_OBJECT_CONTRACT
supersedes:
  - docs/30-kandahar-air-operations-manifest.md
  - Kandahar 75th EFS active baseline
  - single-AIRWING assumption across Kandahar and Kandahar Heliport
  - generic AW_US_KANDAHAR AIRWING name
  - Kandahar assignment of 3-101 Attack Aviation
  - Kandahar Heliport warehouse missing/unapproved state
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(4).miz
source_mission_sha256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
validated_in_dcs: false
object_contract_validated_in_dcs: true
heliport_warehouse_validated_in_dcs: true
---

# 33 – Kandahar Air Operations Manifest

## 1. Dokumentstatus

Die Kandahar-Mission-Editor-Baseline, beide nativen Airbases, die Parkingtabellen und beide Warehouse-Anker sind strukturell sowie read-only in DCS/MOOSE validiert. Eine produktive AIRWING-/SQUADRON-Laufzeitimplementierung ist noch nicht freigegeben.

Verbindliche Mission:

```text
OMW_Template_v4_Kandahar(4).miz
2,183,450 bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

Maßgebliche Dokumente:

- [`Kandahar Juli-2011 ORBAT Unit Name Reconciliation`](evidence/kandahar-july-2011-orbat-unit-name-reconciliation.md)
- [`Kandahar Heliport Warehouse and AIRWING Contract`](kandahar-heliport-warehouse-contract.md)
- [`Kandahar Mustang Ramp Army Aviation Baseline`](36-kandahar-mustang-ramp-army-aviation-baseline.md)
- `OMW-AIR-KANDAHAR-ISR-POLICY` für MQ-1/MQ-9
- `OMW-AIR-ACTIVE-ORBAT` für aktive Verbände und Bestände

## 2. Autoritäts- und Quellenregel

Die Juli-2011-ORBAT ist die historische Stichtagsreferenz für Einheitsnamen und Standorte. Sie ist nicht vollständig für Black SOF, Logistik, Transport, Sanität, Intelligence und Provincial Reconstruction Teams.

```text
HISTORICAL JULY 2011 ROSTER != ACTIVE OMW RUNTIME ORBAT
SOURCE-REPORTED UNIT != AUTOMATIC MOOSE SQUADRON
KANDAHAR AIRFIELD IN SOURCE != SEPARATE DCS KANDAHAR HELIPORT NAME
```

Die aktive OMW-Luft-ORBAT bleibt eine quellenbasierte, spielbare Auswahl innerhalb des Gesamtzeitraums 01.08.2010 bis 31.12.2011.

## 3. Historische Juli-2011-Einheiten am Kandahar Airfield

### 3.1 U.S. Air Force

```text
451st Air Expeditionary Wing
├── 26th Expeditionary Rescue Squadron
│   HH-60G; Medical Evacuation Support
├── 46th Expeditionary Rescue Squadron
│   Guardian Angel rescue/medical specialists
│   Camp Bastion und Kandahar Airfield
├── 74th Expeditionary Fighter Squadron
│   A-10C; Close Air Support
├── 361st Expeditionary Reconnaissance Squadron
│   MC-12, MQ-1, MQ-9; Surveillance Support
└── 772nd Expeditionary Airlift Squadron
    C-130; Transport Support
```

### 3.2 U.S. Army Aviation

```text
Task Force Thunder / 159th Combat Aviation Brigade
├── Task Force Guns / 4-227 Attack Aviation
│   Attack Aviation Support in Kandahar Province
├── Task Force Palehorse / 7-17 Air Cavalry
│   Scout Aviation Support in Kandahar Province
└── Task Force Lift / 7-101 General Support Aviation
    Transport Aviation Support in Kandahar Province
```

Nicht in Kandahar stationiert:

```text
Task Force Attack / 3-101 Attack Aviation
FOB Tarin Kowt; Aviation Support Uruzgan

Task Force Wings / 4-101 Assault Aviation
FOB Wolverine, Zabul; Aviation Support Zabul
```

### 3.3 Weitere historische Aviation-Verbände

```text
Task Force Silver Dart
Canadian Aviation Headquarters

Task Force Freedom / Canadian Helicopter Force Afghanistan
Aviation Support central Kandahar

Marine Attack Squadron 513
AV-8B; Fixed-wing Close Air Support

No. 617 Squadron RAF
Tornado GR4; Close Air Support für Task Force Helmand
```

Diese Verbände gehören zum historischen Standortbild, sind aber ohne aktive Projektentscheidung keine OMW-SQUADRONs.

### 3.4 Weitere durch die Juli-2011-Quelle am Kandahar Airfield gemeldete Einheiten

```text
Regional Command South / 10th Mountain Division
Task Force Kandahar
Task Force Automatic / 2-8 Field Artillery
Task Force Paladin South / 63rd EOD Battalion
Task Force Overlord / 25th Naval Construction Regiment
Naval Mobile Construction Battalion 26
Task Force Packhorse / 368th Engineer Battalion
Task Force Linebacker / 863rd Engineer Battalion
```

Diese Verbände sind in der basisweiten historischen Dokumentation zu führen, nicht in Aircraft-Inventories.

## 4. Aktive OMW-Auswahl versus Juli-2011-Snapshot

Die Juli-2011-ORBAT meldet die `74th Expeditionary Fighter Squadron` als A-10C-Verband. Die verbindliche aktive OMW-Entscheidung verwendet jedoch:

```text
107th Expeditionary Fighter Squadron
16 A-10C
```

Das ist eine bewusste Kampagnenauswahl innerhalb des Gesamtzeitraums und kein behaupteter exakter Juli-2011-Gleichzeitstand.

Verbindlich:

```text
nur eine aktive A-10C-SQUADRON
keine parallele 74th und 107th EFS
historische 74th EFS bleibt dokumentiert
aktive Runtime-SQUADRON bleibt 107th EFS
```

Die 46th ERQS stellt Guardian-Angel-Personal und keinen eigenen Flugzeugbestand. Sie wird nicht als separate MOOSE-Aircraft-SQUADRON registriert.

## 5. Dual-Airbase-Architektur

DCS modelliert zwei native Airbases:

```text
AIRBASE.Afghanistan.Kandahar
DCS ID 7
Main Airfield

AIRBASE.Afghanistan.Kandahar_Heliport
DCS ID 15
Mustang Ramp / Army Aviation
```

MOOSE 2.9.18 bindet ein AIRWING über sein Warehouse an genau eine Airbase. Daher sind zwei technische AIRWINGs zwingend.

### 5.1 Main Airfield / 451st AEW

```text
Historical owner: 451st Air Expeditionary Wing
Technical AIRWING: AW_US_KAF_451_AEW
Warehouse: WH_AIR_US_KANDAHAR
Warehouse type: container_40ft
Native airbase: AIRBASE.Afghanistan.Kandahar / ID 7
```

### 5.2 Kandahar Heliport / TF Thunder

```text
Historical owner: Task Force Thunder / 159th Combat Aviation Brigade
Technical AIRWING: AW_US_KAF_159_CAB_TF_THUNDER
Warehouse: WH_AIR_US_KANDAHAR_HELI
Warehouse type: container_20ft
Native airbase: AIRBASE.Afghanistan.Kandahar_Heliport / ID 15
```

Der Quellenname für beide Bereiche ist `Kandahar Airfield`. Die Trennung des Army-Ramp-Bereichs in `Kandahar Heliport` ist eine DCS-/MOOSE-technische Abbildung.

## 6. Verbindliche SQUADRON-Kennungen

### 6.1 AW_US_KAF_451_AEW

```text
SQ_US_KAF_A10C_107_EFS
107th Expeditionary Fighter Squadron
16 A-10C; aktive OMW-Entscheidung

SQ_US_KAF_HH60G_26_ERQS
26th Expeditionary Rescue Squadron
HH-60G; DCS-Repräsentation UH-60A

SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
361st Expeditionary Reconnaissance Squadron

SQ_US_KAF_C130_772_EAS
772nd Expeditionary Airlift Squadron
```

### 6.2 AW_US_KAF_159_CAB_TF_THUNDER

```text
SQ_US_KAF_AH64_4_227_AVN
Task Force Guns / 4-227 Attack Aviation

SQ_US_KAF_OH58D_7_17_CAV
Task Force Palehorse / 7-17 Air Cavalry

SQ_US_KAF_CH47_7_101_GSAB
Task Force Lift / 7-101 General Support Aviation

SQ_US_KAF_UH60_7_101_GSAB
Task Force Lift / 7-101 General Support Aviation
```

Die Juli-2011-ORBAT löst TF Lift nur bis zur Bataillonsebene auf. CH-47 und UH-60 werden deshalb als typreine technische Pools unter demselben belegten Parent geführt. Eine Company-Bezeichnung wird nicht erfunden.

Superseded beziehungsweise verboten:

```text
AW_US_KANDAHAR
SQ_US_KAF_AH64_3_101_AVN
SQ_US_KAF_UH60_159_CAB
```

## 7. Mission-Editor-Objektbestand

### 7.1 Main-Airfield-Clients

```text
CLIENT_US_KAF_A10C_01 | A-10C_2   | TerminalID 282 | Z20
CLIENT_US_KAF_A10C_02 | A-10C_2   | TerminalID 287 | Z19
CLIENT_US_KAF_C130_01 | C-130J-30 | TerminalID 294 | S01
CLIENT_US_KAF_C130_02 | C-130J-30 | TerminalID 92  | S02
```

### 7.2 Heliport-Clients

```text
CLIENT_US_KAF_AH64D_01 | AH-64D_BLK_II | TerminalID 30 | MST38-H
CLIENT_US_KAF_AH64D_02 | AH-64D_BLK_II | TerminalID 19 | MST30-H
CLIENT_US_KAF_OH58D_01 | OH58D          | TerminalID 80 | MST01-H
CLIENT_US_KAF_OH58D_02 | OH58D          | TerminalID 23 | MST11-H
CLIENT_US_KAF_CH47F_01 | CH-47Fbl1      | TerminalID 4  | MST75-H
CLIENT_US_KAF_CH47F_02 | CH-47Fbl1      | TerminalID 47 | MST82-H
```

Alle zehn Clientpositionen lagen im Runtime-Audit exakt auf ihren TerminalIDs und sind verbindliche Reservierungen.

### 7.3 KI-Templates

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP       | 2 x A-10C
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP | 1 x C-130
TPL_AIR_US_KAF_HH60G_CSAR_1SHIP     | 1 x UH-60A
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP     | 1 x RQ-1A Predator
TPL_AIR_US_KAF_MQ9_RECON_1SHIP      | 1 x MQ-9 Reaper
TPL_AIR_US_KAF_AH64D_CAS_2SHIP      | 2 x AH-64D_BLK_II
TPL_AIR_US_KAF_OH58D_RECON_2SHIP    | 2 x OH58D
TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP | 1 x CH-47Fbl1
TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP | 2 x UH-60A
TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP   | 1 x UH-60A
```

Alle Templates sind Late Activation, nicht Uncontrolled und reine Authoring-Seeds.

A-10- und C-130-Template-Typen weichen noch von Clients/Statics ab:

```text
A-10 template: A-10C
Clients/Statics: A-10C_2

C-130 template: C-130
Clients/Statics: C-130J-30
```

Diese Abweichungen müssen vor SQUADRON-Registrierung korrigiert oder ausdrücklich als technische Repräsentation genehmigt werden.

### 7.4 US-Statics

```text
6 x A-10C_2
2 x C-130J-30
10 x UH-60A, davon 2 als USAF-HH-60G-Repräsentation
2 x RQ-1A Predator
1 x MQ-9 Reaper
8 x AH-64D_BLK_II
8 x OH58D
10 x CH-47Fbl1
Gesamt: 47
```

### 7.5 UN-Statics

```text
2 x Mi-26
4 x UH-1H
```

Statics, Clients, Templates und aktive KI sind Darstellungen eines logischen Bestands und dürfen nicht addiert werden.

## 8. Parking- und Warehouse-Verträge

Runtime-bestätigt:

```text
Kandahar Main
316 Parking-Nodes
Client-reserviert: 282, 287, 294, 92
Warehouse: WH_AIR_US_KANDAHAR

Kandahar Heliport
86 Parking-Nodes
Client-reserviert: 30, 19, 80, 23, 4, 47
Warehouse: WH_AIR_US_KANDAHAR_HELI
Nearest warehouse TerminalID: 60
Warehouse distance: 149.63 m
```

Endgültige Safe-Parking-Allow-/Blocklists sind noch nicht freigegeben. Sie werden ausschließlich aus Runtime-Tests pro Muster abgeleitet.

## 9. Bestände

Verbindlich entschieden:

```text
SQ_US_KAF_A10C_107_EFS: 16 A-10C
```

Noch festzulegen:

```text
SQ_US_KAF_HH60G_26_ERQS
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
SQ_US_KAF_C130_772_EAS
SQ_US_KAF_AH64_4_227_AVN
SQ_US_KAF_OH58D_7_17_CAV
SQ_US_KAF_CH47_7_101_GSAB
SQ_US_KAF_UH60_7_101_GSAB
```

Je SQUADRON getrennt zu führen:

```text
initialer Gesamtbestand
mission-ready Bestand
maximal gleichzeitig aktiv
Client-Reservierungen
aktive KI
virtuelle Reserve
Wartung/Cooldown
beschädigt
verloren
Reparatur- oder Ersatzregel
```

## 10. Tarinkot- und Outstation-Regel

Tarinkot besitzt verbindlich:

```text
14 AH-64D
6 UH-60
2 CH-47
0 OH-58D
```

Diese Airframes werden vom Kandahar-/RC-South-Regionalpool abgezogen.

Historische Zuordnung:

```text
Task Force Attack / 3-101 Attack Aviation
FOB Tarin Kowt
```

Damit ist ausgeschlossen, `3-101` gleichzeitig als Kandahar-Verband zu registrieren oder dessen Bestand am Kandahar-Stammknoten nochmals anzusetzen.

Weitere Forward Detachments, insbesondere FOB Wolverine / TF Wings, sind ebenfalls vor Bestandsfreigabe zu berücksichtigen.

## 11. ISR- und Payload-Grenzen

```text
MQ-1: aktuelles Template besitzt zwei belegte Waffenstationen
MQ-9: aktuelles Template besitzt vier AGM-114 und zwei Paveway-II-Bomben
OH-58D: aktuelles Template enthält APKWS und AGM-114
```

MQ-1/MQ-9 werden gemäß ISR-Policy behandelt. APKWS benötigt eine ausdrückliche Perioden-/Projektentscheidung. Keine dieser Konfigurationen wird allein durch vorhandene ME-Payloads automatisch freigegeben.

## 12. Verlust- und Rückgabelogik

```text
angefordert -> reserviert
aktiviert/gestartet -> aktiv
sicher gelandet/zurückgekehrt -> verfügbar oder Wartung/Cooldown
beschädigt zurück -> beschädigt/Wartung
abgebrochen und sicher zurück -> verfügbar oder Wartung/Cooldown
zerstört/Crash -> verloren
Despawn ohne bestätigte Rückkehr -> nicht automatisch verfügbar
```

Ein erfolgreicher Auftrag gibt einen anschließend verlorenen Airframe nicht zurück.

## 13. Nächster Runtime-Inkrement

Nächster Teststand:

```text
Kandahar Dual-AIRWING Registration Preflight
```

Zu konstruieren, aber zunächst nicht automatisch zu starten:

```text
AW_US_KAF_451_AEW
AW_US_KAF_159_CAB_TF_THUNDER
```

Der Preflight muss:

```text
beide Warehouse-/Airbase-Bindungen verifizieren
alle SQUADRON-Namen aus Abschnitt 6 prüfen
3-101 und 4-101 als Kandahar-SQUADRONs ausschließen
Templates und Gruppengrößen prüfen
Client-Terminals reservieren
Safe-Parking-Kandidaten getrennt je Airbase ausgeben
keinen produktiven Army-Bestand erfinden
keine Assets spawnen
keinen AUFTRAG oder OPSTRANSPORT erzeugen
```

## 14. Offene Entscheidungen

```text
logische Bestände außer 16 A-10C
regionaler 159-CAB-Gesamtbestand und alle Detachment-Abzüge
technische Zuordnung und Bestand der 26th ERQS
UAV-Warehouse- oder externes Kontingentmodell
A-10-/C-130-Template-Typangleichung
MQ-1-/MQ-9-Freigaben
OH-58D-APKWS-Entscheidung
Safe-Parking-Allow-/Blocklists
Wartung, Cooldown, Reparatur und Wiederbeschaffung
CampaignState-Schnittstelle
Performance- und Controlled-Spawn-Acceptance
```

## 15. Acceptance-Kriterien für die spätere Registrierung

```text
AIRWINGs entsprechen 451st AEW und TF Thunder / 159th CAB
genau ein Warehouse je nativer Airbase erkannt
alle SQUADRONs verwenden quellenbelegte Einheitsnamen
keine Kandahar-SQUADRON für 3-101 oder 4-101
keine Doppelzählung von Clients, Templates oder Statics
16 A-10C logisch registriert
weitere Bestände nur nach ausdrücklicher Entscheidung
keine Spawns auf Client- oder Static-Nodes
Late-Activation-Templates bleiben bis zur Zuweisung inaktiv
Verluste und beschädigte Rückkehr verändern Bestände korrekt
keine relevanten Lua-, Parking-, Timer- oder Eventfehler
```