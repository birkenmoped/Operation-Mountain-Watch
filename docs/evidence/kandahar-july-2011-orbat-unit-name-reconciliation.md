---
document_id: OMW-EVIDENCE-KANDAHAR-ORBAT-2011-07-RECONCILIATION
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reported July 2011 unit names at Kandahar Airfield
  - separation of historical Kandahar Airfield basing from the DCS Kandahar Heliport mapping
  - Kandahar AIRWING and SQUADRON naming corrections
  - active Kandahar 74th EFS alignment
  - exclusion of Tarin Kowt and FOB Wolverine aviation units from Kandahar inventories
scenario_period: 2011-07-01/2011-07-31
source_branch: agent/kandahar-airwing-baseline-contract
source_documents:
  - docs/64-afghanistan-order-of-battle-july-2011.md
  - docs/19-active-air-orbat-decisions.md
  - docs/33-kandahar-air-operations-manifest.md
  - docs/36-kandahar-mustang-ramp-army-aviation-baseline.md
validated_in_dcs: false
---

# Kandahar – Abgleich der Einheitsnamen mit der ORBAT Juli 2011

## 1. Zweck und Autoritätsgrenze

Dieses Dokument korrigiert die Einheitszuordnung und die geplanten technischen Bezeichner für Kandahar Airfield und den in DCS separat modellierten `Kandahar Heliport`.

Historische Primärreferenz innerhalb der Projektdokumentation ist:

```text
OMW-HIST-AFGHANISTAN-ORBAT-2011-07
Wesley Morgan: Afghanistan Order of Battle, Juli 2011
```

Die Quelle erfasst westliche Kampfkräfte bis auf Bataillonsebene einschließlich Aviation, Artillerie, Engineer, EOD, Military Police und offen benennbarer SOF. Sie ist ausdrücklich nicht vollständig für Black SOF, Logistik, Transport, Sanität, Intelligence und Provincial Reconstruction Teams.

Daher gilt:

```text
ALLE UNTEN AUFGEFUEHRTEN EINHEITEN = alle durch diese Juli-2011-Quelle am Standort gemeldeten Einheiten
NICHT = vollständige Personal- und Unterstützungsbelegung des gesamten Flugplatzes
```

Die historische Juli-2011-Liste erzeugt nicht automatisch aktive MOOSE-SQUADRONs oder Bestände. Die aktive A-10C-Auswahl wurde jedoch durch ausdrückliche Projektentscheidung an den belegten Juli-2011-Verband angeglichen.

## 2. Durch die Juli-2011-ORBAT am Kandahar Airfield gemeldete Aviation-Einheiten

### 2.1 U.S. Air Force – 451st Air Expeditionary Wing

```text
451st Air Expeditionary Wing
├── 26th Expeditionary Rescue Squadron
│   └── HH-60G; Medical Evacuation Support
├── 46th Expeditionary Rescue Squadron
│   └── Guardian Angel rescue/medical specialists
│       Standort: Camp Bastion und Kandahar Airfield
├── 74th Expeditionary Fighter Squadron
│   └── A-10C; Close Air Support
├── 361st Expeditionary Reconnaissance Squadron
│   └── MC-12, MQ-1 und MQ-9; Surveillance Support
└── 772nd Expeditionary Airlift Squadron
    └── C-130; Transport Support
```

Die 74th EFS ist die historisch gemeldete A-10C-Einheit des Juli-2011-Snapshots und mit Projektentscheidung vom 31.07.2026 zugleich die aktive OMW-Kandahar-A-10C-SQUADRON:

```text
SQ_US_KAF_A10C_74_EFS
16 A-10C
```

Die früheren aktiven Arbeitsstände `75th EFS` und `107th EFS` sind superseded. Sie bleiben ausschließlich historischer Rotationskontext und dürfen nicht als parallele aktive SQUADRONs registriert werden.

Die 46th ERQS stellt Guardian-Angel-Personal und keinen eigenen HH-60G-Airframepool. Sie wird daher als Unterstützungsverband dokumentiert, nicht als separate MOOSE-Flugzeug-SQUADRON.

### 2.2 U.S. Army – Task Force Thunder / 159th Combat Aviation Brigade

```text
Task Force Thunder / 159th Combat Aviation Brigade
├── Task Force Guns / 4-227 Attack Aviation
│   └── Attack Aviation Support in Kandahar Province
├── Task Force Palehorse / 7-17 Air Cavalry
│   └── Scout Aviation Support in Kandahar Province
└── Task Force Lift / 7-101 General Support Aviation
    └── Transport Aviation Support in Kandahar Province
```

Die Juli-2011-ORBAT nennt diese drei unterstellten Aviation-Task-Forces ausdrücklich am Kandahar Airfield.

### 2.3 Weitere am Kandahar Airfield gemeldete Aviation-Verbände

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

Diese Verbände gehören zum vollständigen historischen Kandahar-Lagebild. Sie werden nicht automatisch als aktive OMW-AIRWINGs oder SQUADRONs umgesetzt, solange Dokument 19 und die Mission-Editor-Baseline keine entsprechende aktive Entscheidung enthalten.

## 3. Weitere durch die Juli-2011-ORBAT am Kandahar Airfield gemeldete Einheiten

Die folgenden nicht als OMW-AIRWING zu modellierenden Verbände sind ebenfalls am Kandahar Airfield genannt:

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

Diese Liste gehört in die basisweite historische Standortdokumentation. Sie darf nicht in Aircraft-Inventories oder MOOSE-SQUADRONs umgewandelt werden.

## 4. Einheiten, die im Juli 2011 nicht am Kandahar Airfield stationiert waren

Die bisherige Mustang-Ramp-Dokumentation ordnete den AH-64-Pool fälschlich `3-101 Attack Aviation / Task Force Attack` zu.

Die Juli-2011-ORBAT meldet stattdessen:

```text
Task Force Attack / 3-101 Attack Aviation
Standort: FOB Tarin Kowt
Auftrag: Aviation Support Uruzgan

Task Force Wings / 4-101 Assault Aviation
Standort: FOB Wolverine, Zabul
Auftrag: Aviation Support Zabul
```

Diese beiden Verbände dürfen nicht als Kandahar-SQUADRONs registriert oder in einen lokalen Kandahar-Bestand eingerechnet werden.

Verbindliche Korrektur:

```text
FALSCH fuer Kandahar:
3-101 Attack Aviation / Task Force Attack

RICHTIG fuer Kandahar-AH-64:
Task Force Guns / 4-227 Attack Aviation
```

## 5. DCS-Abbildung: Kandahar Airfield versus Kandahar Heliport

Die historische Quelle bezeichnet den Standort zusammenfassend als `Kandahar Airfield`. Sie verwendet keinen getrennten historischen Eintrag `Kandahar Heliport`.

DCS modelliert jedoch zwei native Airbases:

```text
AIRBASE.Afghanistan.Kandahar
DCS ID 7
technische Verwendung: Main Airfield / fixed-wing und ausgewählte USAF-Assets

AIRBASE.Afghanistan.Kandahar_Heliport
DCS ID 15
technische Verwendung: Mustang Ramp / TF Thunder Army Aviation
```

Die Zuordnung der Army-Aviation-Verbände zum DCS-Heliport ist daher eine technisch und räumlich validierte OMW-Abbildung der historischen Kandahar-Airfield-Stationierung. Sie ist keine Behauptung, die Juli-2011-Quelle habe einen eigenständigen Standortnamen `Kandahar Heliport` verwendet.

## 6. Verbindliche technische AIRWING-Namen

Die technischen Namen sollen sowohl den physischen DCS-Knoten als auch den historischen Führungsverband erkennen lassen:

```text
Main Airfield / USAF:
AW_US_KAF_451_AEW
Historical label: 451st Air Expeditionary Wing
Warehouse: WH_AIR_US_KANDAHAR
Native airbase: AIRBASE.Afghanistan.Kandahar / ID 7

Mustang Ramp / Army Aviation:
AW_US_KAF_159_CAB_TF_THUNDER
Historical label: Task Force Thunder / 159th Combat Aviation Brigade
Warehouse: WH_AIR_US_KANDAHAR_HELI
Native airbase: AIRBASE.Afghanistan.Kandahar_Heliport / ID 15
```

Diese Namen ersetzen die rein generischen beziehungsweise offenen Bezeichner:

```text
AW_US_KANDAHAR
Heliport AIRWING name unresolved
```

Die Warehouse-Namen bleiben unverändert, weil sie technische Mission-Editor-Anker und keine historischen Einheitsnamen sind.

## 7. Verbindliche technische SQUADRON-Kennungen

### 7.1 Main Airfield / 451st AEW

```text
SQ_US_KAF_A10C_74_EFS
Historical/runtime label: 74th Expeditionary Fighter Squadron
Status: aktive OMW-Auswahl; 16 A-10C; Juli-2011-belegt

SQ_US_KAF_HH60G_26_ERQS
Historical label: 26th Expeditionary Rescue Squadron

SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
Historical label: 361st Expeditionary Reconnaissance Squadron

SQ_US_KAF_C130_772_EAS
Historical label: 772nd Expeditionary Airlift Squadron
```

Nicht mehr zulässig:

```text
SQ_US_KAF_A10C_107_EFS
SQ_75_EFS_A10C
```

### 7.2 Kandahar Heliport / TF Thunder

```text
SQ_US_KAF_AH64_4_227_AVN
Historical label: Task Force Guns / 4-227 Attack Aviation

SQ_US_KAF_OH58D_7_17_CAV
Historical label: Task Force Palehorse / 7-17 Air Cavalry

SQ_US_KAF_CH47_7_101_GSAB
Historical label: Task Force Lift / 7-101 General Support Aviation

SQ_US_KAF_UH60_7_101_GSAB
Historical label: Task Force Lift / 7-101 General Support Aviation
```

Die Juli-2011-ORBAT löst die Transport-Task-Force nur bis zur Bataillonsebene `7-101 General Support Aviation` auf. Für CH-47 und UH-60 werden deshalb zwei typreine technische MOOSE-Pools unter demselben historisch belegten Parent geführt. Eine Company-Bezeichnung wird ohne zusätzliche Quelle nicht erfunden.

## 8. Nicht als Flug-SQUADRON zu modellierende Elemente

```text
46th Expeditionary Rescue Squadron
Guardian Angel personnel; kein eigener Aircraft-Pool

563rd Aviation Support Battalion / Task Force Fighting
in der bisherigen Mustang-Dokumentation genannt, aber nicht durch die ausgewertete Juli-2011-ORBAT als Kandahar-Eintrag bestätigt
```

Der 563rd-ASB-Eintrag bleibt bis zu einer gesonderten Quellenbestätigung ein Support-/Recherchepunkt und darf nicht zur Benennung eines Flugzeugbestands verwendet werden.

## 9. Konsequenzen für den nächsten Runtime-Inkrement

Vor Konstruktion der Kandahar-AIRWINGs sind zu verwenden:

```text
AW_US_KAF_451_AEW
AW_US_KAF_159_CAB_TF_THUNDER
```

Vor SQUADRON-Registrierung sind die in Abschnitt 7 festgelegten Kennungen zu verwenden. Insbesondere gilt:

```text
SQ_US_KAF_A10C_74_EFS ist die einzige aktive Kandahar-A-10C-SQUADRON
SQ_US_KAF_A10C_107_EFS ist verboten
SQ_75_EFS_A10C ist verboten
SQ_US_KAF_AH64_3_101_AVN ist verboten
```

Weiterhin offen bleiben:

```text
logische Bestände außer den verbindlichen 16 A-10C
regionale 159-CAB-Gesamtbestände
Tarinkot- und weitere Detachment-Abzüge
OH-58D-APKWS-Entscheidung
Safe-Parking-Allow-/Blocklists
controlled-spawn acceptance
```

Die Korrektur der Einheitsnamen autorisiert noch keinen AIRWING-Start und keine Bestandsregistrierung außerhalb der ausdrücklich beschlossenen 16 A-10C.