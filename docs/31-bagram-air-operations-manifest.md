---
document_id: OMW-AIR-BAGRAM-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram historical fighter evidence
  - Bagram active air ORBAT
  - Bagram dual-AIRWING foundation structure
  - Bagram logical aircraft inventories
  - Bagram F-15E CAS and STRIKE role-seed authoring baseline
not_authoritative_for:
  - current Mission Editor parking state
  - final client parking IDs
  - DCS runtime acceptance of the rebuilt dual-AIRWING foundation
  - tactical tasking, COMMANDER, AUFTRAG or OPSTRANSPORT acceptance
  - final saved F-15E store and fuze configuration until .miz audit
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/28-bagram-air-operations-manifest.md
  - single-AIRWING Bagram runtime structure AW_US_BAGRAM
superseded_by:
source_branch: agent/bagram-f15e-payload-baseline
source_commit: PENDING_MERGE
validated_in_dcs: false
document_class: HISTORICAL_EVIDENCE_ACTIVE_ORBAT_AND_FOUNDATION_CONTRACT
---

# 31 – Bagram Air Operations Manifest

## 1. Dokumentstatus

Dieses Dokument ist verbindlich für die historische Bagram-Fighter-Evidenz, die aktive Bagram-ORBAT und den dualen AIRWING-Foundation-Vertrag.

Der frühere technische Sammelknoten

```text
AW_US_BAGRAM
```

ist durch ausdrückliche Entscheidung des Projektinhabers vom 10.08.2026 superseded. Die verbindliche Architekturentscheidung ist zusätzlich in [`OMW-ADR-0006-BAGRAM-DUAL-AIRWING`](adr/0006-bagram-dual-airwing-structure.md) dokumentiert.

Konkrete ParkingIDs, Mission-Editor-Positionen und DCS-Runtime-Verhalten benötigen weiterhin eine eigene, exakt dokumentierte Acceptance.

## 2. Historische Evidenz Ende 2011

Eine projektseitig ausgewertete Maxar-/Google-Earth-Aufnahme mit Datumsangabe `12/2011` zeigt auf dem östlichen Fighter Apron mindestens:

```text
13 F-15E Strike Eagle
11 F-16 Fighting Falcon
```

Die Aufnahme belegt Mindestpräsenz und Rampbelegung, nicht automatisch den vollständigen administrativen Gesamtbestand. Nicht sichtbar können Flugzeuge im Einsatz, in Wartung, in Hallen, auf anderen Flächen oder temporär verlegt gewesen sein.

### 2.1 F-16-Einheit

```text
121st Expeditionary Fighter Squadron
Lead-Verband: 113th Wing, District of Columbia ANG
historisches Muster: F-16C Block 30
Einsatzzeitraum: 13.10.2011 bis 14.04.2012
```

Das ANG-`Rainbow Deployment` umfasste Flugzeuge und Personal mindestens aus:

- 119th Fighter Squadron – New Jersey ANG;
- 121st Fighter Squadron – District of Columbia ANG;
- 124th Fighter Squadron – Iowa ANG.

Mindestens 13 F-16C Block 30 sind durch Seriennummern beziehungsweise Fotobelege dokumentiert; elf sind auf der Satellitenaufnahme sichtbar.

### 2.2 F-15E-Einheit

```text
335th Expeditionary Fighter Squadron
Muster: F-15E Strike Eagle
Standort: Bagram Airfield
```

Offizielle USAF-/AFCENT-Belege nennen die 335th EFS im November 2011 in Bagram. Sie operierte gemeinsam mit der 121st EFS. Die frühere aktive Zuordnung zur 336th EFS ist für die OMW-Baseline ersetzt; 336th und 494th EFS bleiben historischer Rotationskontext.

### 2.3 Weitere aktive Bagram-Komponenten

Die ältere Bagram-Fach- und Testdokumentation trennt folgende zusätzlichen Pools:

```text
774th Expeditionary Airlift Squadron | C-130
83rd Expeditionary Rescue Squadron   | HH-60G
A Company, 1-169 GSAB / TF Phoenix   | UH-60 Utility
B Company, 7-158 Aviation Regiment   | CH-47
```

USAF Personnel Recovery und Army UH-60 Utility werden ausdrücklich nicht zusammengelegt. Die Army-Komponenten gehören organisatorisch nicht in die USAF-AIRWING-Domäne.

### 2.4 Quellenbasis

- U.S. Air Forces Central, `Coalition Forces 70, Taliban 0`, 14.11.2011;
- U.S. Air Force, `Close air support protects coalition forces, kills 70 insurgents`, 14.11.2011;
- 113th Wing, `113th Wing initiates first ANG F-16 deployment to Afghanistan`, 11.10.2011;
- F-16.net, `Bagram AB Deployment 2011-12`;
- Juli-2011 Coalition ORBAT;
- zeitgenössische 10th-CAB-/TF-Phoenix-Publikationen;
- projektseitig ausgewertete Maxar-/Google-Earth-Satellitenaufnahme `12/2011`.

## 3. Verbindliche aktive Bagram-ORBAT

```text
AW_US_BGRM_455_AEW
├── SQ_US_BGRM_F15E_335_EFS       13 F-15E
├── SQ_US_BGRM_F16C_121_EFS       13 F-16C
├── SQ_US_BGRM_C130_774_EAS       20 C-130
└── SQ_US_BGRM_HH60G_83_ERQS       6 HH-60G

AW_US_BGRM_TF_FALCON_10_CAB
├── SQ_US_BGRM_UH60_A_1_169       10 UH-60 Utility
└── SQ_US_BGRM_CH47_B_7_158       13 CH-47
```

Gesamtbestand:

```text
75 logische Luftfahrzeuge
```

Die Werte sind OMW-Kampagnenbestände und keine Behauptung über eine vollständige USAF-/Army-TOE an einem einzigen Stichtag.

## 4. DCS-Abbildung

### F-15E

```text
DCS-Spielertyp: F-15E Strike Eagle
Status: THIRD_PARTY_AT_RISK
```

Clientobjekte, Templates und Payloadregistrierungen müssen deaktivierbar bleiben, ohne den verbleibenden Bagram-Knoten strukturell neu aufzubauen.

### F-16C

```text
historisches Muster: F-16C Block 30
native DCS-Spielerabbildung: F-16C Block 50
```

Der Block 50 ist ein ausdrücklich gekennzeichneter technischer Ersatz für das historisch belegte Block-30-Muster.

### HH-60G und CH-47

Die im historischen Mission-Editor-Zweig verwendeten DCS-Ersatzmuster bleiben technische Repräsentationen und sind keine historische Typbehauptung. Der finale Mission-Editor-Stand ist vor DCS-Acceptance erneut zu auditieren.

## 5. Foundation-Warehouse-Vertrag

Der gepinnte MOOSE-Stand erzeugt je `AIRWING:New(warehouseName, airwingName)` eine eigene LEGION/WAREHOUSE-Instanz. Die beiden Bagram-AIRWINGs erhalten deshalb getrennte physische Warehouse-Anker, obwohl beide an derselben DCS-Airbase gebunden werden:

```text
AW_US_BGRM_455_AEW
  Airbase: Bagram
  Warehouse: WH_AIR_US_BAGRAM

AW_US_BGRM_TF_FALCON_10_CAB
  Airbase: Bagram
  Warehouse: WH_AIR_US_BAGRAM_ARMY
```

`WH_AIR_US_BAGRAM_ARMY` ist im Mission Editor als zusätzlicher Anchor anzulegen. Die Missionsdatei wird nicht automatisiert verändert.

## 6. SQUADRON-Bestandsmodell

Client-Slots, Statics, Late-Activation-Templates und aktive KI sind Repräsentationen desselben logischen Bestands und dürfen ihn nicht erhöhen.

Für die beiden ungeraden Fighterbestände gilt im Foundation-Schritt:

```text
SQ_US_BGRM_F15E_335_EFS
  6 Two-Ship-Assetgruppen = 12 repräsentierbare Airframes
  1 logischer Reserve-Airframe

SQ_US_BGRM_F16C_121_EFS
  6 Two-Ship-Assetgruppen = 12 repräsentierbare Airframes
  1 logischer Reserve-Airframe
```

Die vier 1-Ship-SQUADRONs werden vollständig als MOOSE-Assetgruppen registriert:

```text
C-130:  20 x 1
HH-60G:  6 x 1
UH-60:  10 x 1
CH-47:  13 x 1
```

Damit ergeben sich:

```text
61 Assetgruppen
73 MOOSE-repräsentierbare Airframes
75 logische Airframes
 2 logische Reserve-Airframes
```

Eine spätere Materialisierung der Fighter-Reserve benötigt eine eigene CampaignState-/Runtime-Acceptance.

## 7. Verbindliche Foundation-Templates

Der bereinigte Foundation-Vertrag verwendet:

```text
SQ_US_BGRM_F15E_335_EFS
  TPL_AIR_US_BGRM_F15E_CAS_2SHIP
  TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP

SQ_US_BGRM_F16C_121_EFS
  TPL_AIR_US_BGRM_F16C_CAS_2SHIP

SQ_US_BGRM_C130_774_EAS
  TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP

SQ_US_BGRM_HH60G_83_ERQS
  TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP

SQ_US_BGRM_UH60_A_1_169
  TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP

SQ_US_BGRM_CH47_B_7_158
  TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

Physisch identische Hubschrauber-Konfigurationen erhalten keine separaten rollenbezogenen Mission-Editor-Templates. Lead/Cover beziehungsweise Utility/Transport werden über MOOSE-Mission-Capabilities und späteres Tasking unterschieden. Zusätzliche Templates sind erst erforderlich, wenn sich die reale Mission-Editor-Konfiguration des Assets unterscheidet.

Der frühere `F16`-Template-Identifier wird für den Neubau auf `F16C` normalisiert. Templates sind Authoring-Seeds und kein zusätzlicher Bestand.

Die Foundation registriert damit sieben Role-Payload-Seeds: zwei für F-15E sowie je einen für F-16C, C-130, HH-60G, UH-60 und CH-47.

### 7.1 F-15E CAS-/STRIKE-Role-Seeds

Die beiden F-15E-Templates gehören zur selben logischen `SQ_US_BGRM_F15E_335_EFS` und bilden unterschiedliche Mission-Editor-Authoring-Seeds derselben Staffel ab. Sie erhöhen den logischen Flugzeugbestand nicht.

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
  Mission Editor task: CAS
  role: CAS payload seed

TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
  Mission Editor task: Ground Attack / Bodenangriff
  MOOSE mission type: AUFTRAG.Type.STRIKE
  role: STRIKE payload seed
```

Für den gepinnten MOOSE-Stand `2.9.18` / Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` ist die Zuordnung im tatsächlich verwendeten `Moose.lua` eindeutig:

```text
AUFTRAG.Type.STRIKE
-> ENUMS.MissionTask.GROUNDATTACK
-> DCS/ME Ground Attack / Bodenangriff
```

`Pinpoint Strike / Präzisionsangriff` ist ein eigener DCS-Mission-Task, aber nicht die von `AUFTRAG.Type.STRIKE` verwendete Zuordnung dieses gepinnten MOOSE-Stands.

Der DCS-Foundation-Lauf vom 10.08.2026 bestätigte für den exakt dokumentierten Acceptance-Stand sieben Role-Payload-Registrierungen; taktische CAS-/STRIKE-Ausführung wurde dort ausdrücklich nicht getestet. Der Fighter-Store-Runtime-Korrelationstest vom 13.08.2026 bestätigte zusätzlich die materielle Registrierung des vorhandenen STRIKE-Two-Ships im dokumentierten STORAGE-Testscope.

Die im aktuellen Mission-Editor-Arbeitsstand gewählten konkreten Store-, Pod- und Zündereinstellungen werden erst nach einem Audit der final gespeicherten `.miz` als verbindliche Detailbaseline in `main` übernommen. Draft-Branch- oder Chatwerte ersetzen diesen `.miz`-Nachweis nicht.

## 8. Foundation-Runtime-Grenze

Der produktionsnahe Foundation-Bundle darf zunächst nur AIRWING-/SQUADRON-Konfiguration, Capabilities, Payloadregistrierung, Warehouse-/Airbase-Bindung, AIRWING-Start und Idle-Diagnose enthalten.

Nicht Bestandteil dieses Schrittes sind:

- Bagram→Jalalabad-Testbewegungen;
- erzwungene Spawn-/Despawn-Tests;
- COMMANDER;
- konkrete AUFTRAG-Instanzen;
- OPSTRANSPORT-Instanzen;
- F10-Teststeuerung;
- Parking-Override;
- Persistenz oder CampaignState-Mutation.

## 9. Acceptance-Ziel

Der nächste DCS-Foundation-Lauf muss mindestens bestätigen:

```text
airwings=2
squadrons=6
registeredGroups=61
representedAirframes=73
logicalAirframes=75
logicalReserve=2
rolePayloads=7
usafRunning=true
armyRunning=true
missionsCreated=0
transportsCreated=0
commanderCreated=false
f10Controls=false
```

Bis zu diesem Lauf bleibt `validated_in_dcs: false`.

## 10. Autoritätsgrenze

Verbindlich aus diesem Dokument sind:

- aktive Bagram-ORBAT;
- duale AIRWING-Struktur;
- logische Bestände;
- Warehouse- und Foundation-Vertrag;
- Foundation-Template-Namen;
- F-15E CAS-/STRIKE-Role-Seed- und Task-Zuordnung nach Abschnitt 7.1.

Nicht aus diesem Dokument abzuleiten sind finale ParkingIDs, taktische Missionen, Recovery, Persistenz, Multiplayer-Endurance oder nicht durch `.miz`-Audit bestätigte Store-, Pod- oder Zündereinstellungen.