---
document_id: OMW-DECISION-TARINKOT-G2-OBJECT-CONTRACT-2026-08-03
status: DRAFT
document_class: OBJECT_CONTRACT_ACCEPTANCE_CHECKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - consolidated Tarinkot G2 acceptance checklist
  - distinction between already accepted historical naming and pending technical object-contract decisions
  - Tarinkot functional-zone gate dependencies including the historically supported FARP
  - implementation lock before MOOSE source review
not_authoritative_for:
  - project-wide binding effect before explicit owner acceptance and merge to main
  - MOOSE 2.9.18 API behavior
  - DCS runtime acceptance
  - final AI parking allowlists
scenario_period: 2010-08-01/2011-12-31
decision_date: 2026-08-03
source_branch: agent/tarinkot-object-contract-reconciliation
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
decision_state: PROPOSED_OWNER_ACCEPTANCE
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_commit: PENDING_MERGE
supersedes: []
superseded_by: []
---

# Tarinkot – G2-Objektvertrag und Abnahmeliste

## 1. Zweck

Dieses Dokument fasst den vollständigen Tarinkot-G2-Entscheidungsstand zusammen. Es trennt:

1. bereits ausdrücklich angenommene historische Entscheidungen;
2. noch als Gesamtvertrag anzunehmende technische Entscheidungen;
3. erst in späteren Gates zu prüfende Laufzeitfragen.

Bis zur ausdrücklichen Annahme des vollständigen Abschnitts 3 und zum Abschluss von G4 gilt:

```text
KEINE TARINKOT-LUA-IMPLEMENTIERUNG
```

## 2. Bereits ausdrücklich angenommen

### 2.1 Historischer Arbeitszeitraum

```text
März bis Dezember 2011
```

Das in der aktuellen MIZ eingetragene Datum `14.01.2011` ist für die aktive Tarinkot-ORBAT und Benennung nicht steuernd.

### 2.2 Historische Organisationsstruktur

```text
Lokaler Aviation-Knoten:
Task Force Attack / 3-101 Attack Aviation

Übergeordnet:
Task Force Thunder / 159th Combat Aviation Brigade

UH-60:
Task-Force-Attack-Komponente
administrative Company weiterhin offen

CH-47:
B Company, 1-52 Aviation Regiment
historisches Muster CH-47D
```

### 2.3 Technische Namen

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

## 3. Vollständiger technischer G2-Vertrag zur Annahme

### 3.1 Standort und Warehouse

```yaml
locationCode: TKOT
dcsAirdromeId: 9
runtimeAirbaseName: READ_ONLY_DIAGNOSTIC_REQUIRED
warehouseAnchor: WH_AIR_US_TARINKOT
warehouseObjectType: container_20ft
warehouseUnitId: 1608
```

Vertrag:

- der Runtime-Airbase-Name wird nicht geraten;
- Airbase-ID und MOOSE-Name werden in G5 read-only protokolliert;
- exakt ein Warehouse-Anker muss vorhanden sein;
- bei fehlendem oder mehrfach vorhandenem Anker erfolgt später Fail-fast;
- das native unbegrenzte DCS-Warehouse erzeugt keinen unbegrenzten CampaignState-Bestand.

### 3.2 Nominaler lokaler OMW-Bestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Evidenzgrenze:

- AH-64-, UH-60- und CH-47-Präsenz 2011 ist bestätigt;
- B/1-52 als lokales CH-47D-Detachment ist bestätigt;
- die exakten Werte `14/6/2/0` sind eine quellennahe OMW-Rekonstruktion;
- die Werte dürfen nicht zusätzlich in Kandahar oder einem anderen RC-South-Pool gezählt werden.

### 3.3 Darstellungsledger

| Musterfamilie | Statics | aktive Clients maximal | aktive KI maximal | maximale gleichzeitige Darstellung |
|---|---:|---:|---:|---:|
| AH-64 | 8 | 2 | 4 | 14 |
| UH-60 | 4 | 0 | 2 | 6 |
| CH-47 | 0 | 1 | 1 | 2 |
| OH-58D | 0 | 0 | 0 | 0 |

Invariante:

```text
Statics
+ aktive Clients
+ aktive KI
+ bestätigte Wartungs-/Stranded-Zustände
<= verbleibender lokaler Bestand je Musterfamilie
```

Late-Activation-Seeds und unbelegte Client-Slots erhöhen den Bestand nicht.

### 3.4 Mission-Editor-Seeds

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
2 × AH-64D_BLK_II

TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
1 × UH-60A

TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
1 × CH-47Fbl1
```

Historische Abweichung:

```text
B/1-52 setzte 2011 CH-47D ein.
CH-47Fbl1 ist ein dokumentierter DCS-Ersatz.
```

### 3.5 Geplanter registrierter KI-Bestand

```yaml
AH64:
  templateAircraftPerGroup: 2
  registeredGroups: 2
  maximumRegisteredAIAircraft: 4

UH60:
  templateAircraftPerGroup: 1
  registeredGroups: 2
  maximumRegisteredAIAircraft: 2
  seedReuse: SAME_ONE_SHIP_TEMPLATE

CH47:
  templateAircraftPerGroup: 1
  registeredGroups: 1
  maximumRegisteredAIAircraft: 1
```

Die Wiederverwendung eines UH-60-One-Ship-Seeds für zwei registrierte Gruppen ist noch keine bestätigte MOOSE-Funktion. Sie ist in G4 anhand der exakten MOOSE-2.9.18-Quelle zu prüfen.

### 3.6 Client-Reservierungen

```text
CLIENT_US_TKOT_AH64D_01
C01-H / interne Parking-ID "20"

CLIENT_US_TKOT_AH64D_02
C05-H / interne Parking-ID 8

CLIENT_US_TKOT_CH47F_01
C07-H / interne Parking-ID 3
```

Diese Positionen werden für KI-Initialspawns gesperrt. Der Stringwert `"20"` wird vor der Laufzeitdiagnose nicht stillschweigend normalisiert.

### 3.7 AI-Parking-Status

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

Eine leere Liste bedeutet:

- keine positive KI-Parking-Abnahme;
- keine Ableitung aus sichtbaren Parkplatzlabels;
- keine AIRWING-/SQUADRON-Spawnfreigabe vor G6.

## 4. Funktionszonen und Gate-Abhängigkeiten

### 4.1 Bereits vorhanden

```text
OMW_LOG_NODE_TARINKOT
```

Diese Logistikzone ersetzt keine Air-Ops-Funktionszone.

### 4.2 Erforderliche, noch nicht angelegte Zonen

```text
ZONE_AIR_US_TKOT_AH64_RAMP
ZONE_AIR_US_TKOT_UH60_RAMP
ZONE_AIR_US_TKOT_MEDEVAC_READY
ZONE_AIR_US_TKOT_CH47_READY
ZONE_AIR_US_TKOT_ROTARY_STAGING
ZONE_AIR_US_TKOT_LOGISTICS_LOAD
ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD
ZONE_AIR_US_TKOT_HELO_RECOVERY
ZONE_AIR_US_TKOT_TRANSIENT_FIXED_WING
ZONE_AIR_US_TKOT_FARP
```

`ZONE_AIR_US_TKOT_FARP` ist durch die offizielle September-2011-Evidenz zu Hot Refueling und Rapid Turnaround fachlich begründet.

### 4.3 Gate-Matrix

| Gate/Test | Erforderliche Zone | Regel |
|---|---|---|
| G5 read-only Diagnose | keine | vorhandene und fehlende Zonen nur protokollieren |
| G6 Parking-Kalibrierung | keine Funktionszone | Parking-Dump und isolierte Spawn-/Starttests verwenden |
| G7 AIRWING-/SQUADRON-Grundlage | keine Funktionszone | keine operative Mission auslösen |
| G8 AH-64-CAS | später separat festgelegter Ziel-/Testbereich | keine FARP- oder Transportzone erforderlich |
| G8 UH-60 MEDEVAC | `MEDEVAC_READY`, `HELO_RECOVERY` | vor dem MEDEVAC-Test im Mission Editor anlegen und auditieren |
| G8 UH-60 Utility | `UH60_RAMP` oder `ROTARY_STAGING` je Testvertrag | exakte Funktion vor Test festlegen |
| G8 CH-47 Transport | `CH47_READY`, `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | vor Direct-/OPSTRANSPORT-Test anlegen und auditieren |
| FARP-/Hot-Refuel-Test | `FARP` | eigene DCS-/MOOSE-Acceptance; nicht Teil des ersten AIRWING-Starts |
| Fixed-Wing-Transient-Test | `TRANSIENT_FIXED_WING` | vollständig zurückgestellt |

Keine Zone darf durch Lua-Fallback-Koordinaten erfunden werden.

## 5. G0-bis-G10-Status nach Konsolidierung

| Gate | Status | Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | Branch, MIZ, MIZ-Hash und MOOSE-Hash dokumentiert |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | aktive Baseline und Quellenkritik konsolidiert |
| G2 Objektvertrag | `PROPOSED_COMPLETE_PENDING_OWNER_ACCEPTANCE` | vollständige Liste liegt in diesem Dokument vor |
| G3 Mission Editor | `PARTIAL` | Kernobjekte vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `NOT_STARTED` | nach G2-Annahme nächster zulässiger Schritt |
| G5 Read-only Diagnose | `BLOCKED_BY_G2_G4` | kein Diagnose-Lua vorhanden |
| G6 Parking-Kalibrierung | `NOT_STARTED` | Allowlisten leer |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt |
| G8 direkter Dispatch | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/Operational Parking | `NOT_STARTED` | gesperrt |
| G10 Lifecycle/Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 6. Ablösung des älteren Tarinkot-Drafts

Draft-PR #40 und dessen auf `OMW_Template(3).miz` basierender Tarinkot-Vertrag werden durch PR #53 fachlich ersetzt.

Bis zu einer ausdrücklichen Merge-/Schließentscheidung gilt:

```text
PR #40: HISTORICAL_SUPERSEDED_DRAFT
PR #53: CURRENT_TARINKOT_RECONCILIATION_DRAFT
```

PR #40 darf nicht parallel als alternative aktive Tarinkot-Source-of-Truth verwendet werden.

## 7. Nächster Schritt nach Annahme

Nach ausdrücklicher Annahme des vollständigen Abschnitts 3 und der Zone-/Gate-Regeln aus Abschnitt 4 beginnt:

```text
G4 – exakte Prüfung der eingebundenen MOOSE-Version 2.9.18,
der zugehörigen Quellen, Dokumentation und Demos.
```

G4 enthält noch keine Tarinkot-Lua-Implementierung.
