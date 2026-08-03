---
document_id: OMW-AIR-TKOT-MANIFEST
status: DRAFT
owning_policy: OMW-GOV-001
document_class: AIR_OPERATIONS_MANIFEST
authoritative_for:
  - accepted Tarinkot AIRWING and SQUADRON object contract on the active branch
  - Tarinkot unit and technical object naming derived from the safest available sources
  - accepted Tarinkot local aircraft inventory and representation limits
  - exact Tarinkot Mission Editor names for the audited source mission
  - Tarinkot warehouse-anchor, client-reservation, seed-template, static, parking, and zone contract
  - accepted G5 read-only runtime basis and G6A parking-candidate dataset
  - G6B controlled placement gate before AIRWING and SQUADRON implementation
not_authoritative_for:
  - final operational parking suitability or productive parking allowlists
  - engine start, taxi, takeoff, mission, return, landing or recovery acceptance
  - historical subordinate identities not explicitly supported by cited evidence
  - exact 2011 aircraft quantities beyond the documented OMW reconstruction
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G6_PARKING_CALIBRATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
validated_in_dcs: true
object_contract_state: OWNER_ACCEPTED_BRANCH
moose_source_review_state: PASS_SOURCE_REVIEW
g5_state: PASS_DCS
g6_state: G6A_PASS_DCS_G6B_IMPLEMENTED_AWAITING_DCS
supersedes_on_merge:
  - Tarinkot object assumptions from docs/tarinkot-air-operations-baseline PR 40
  - Tarinkot Mission Editor assumptions based on OMW_Template(3).miz
  - generic Tarinkot AIRWING and SQUADRON names not derived from historical evidence
  - provisional UH-60 and CH-47 TF_ATTACK_ATTACHED names
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations Manifest and Object Contract

## 1. Zweck und Freigabegrenze

Dieses Dokument ist die aktive Tarinkot-Arbeitsbaseline auf Draft PR #53. Es konsolidiert:

- den Eigentümerentscheid für März bis Dezember 2011;
- die Juli-2011-ORBAT und zeitgenössische U.S.-Army-/DVIDS-Evidenz;
- Satellitenbeobachtungen und Mission-Editor-Audits;
- den angenommenen G2-Objektvertrag;
- die G4-Prüfung der exakt eingebetteten MOOSE-Version 2.9.18;
- den akzeptierten G5-Runtime-Befund;
- den akzeptierten G6A-Parking-Datensatz;
- den noch ausstehenden G6B-Platzierungsnachweis.

Nicht autorisiert sind weiterhin:

```text
Merge
Ready for Review
produktive AIRWING-/SQUADRON-Aktivierung
positive SQUADRON-Parking-Listen
operative AUFTRAG- oder OPSTRANSPORT-Ausführung
MIZ-Änderungen außerhalb des festgelegten Testworkflows
```

## 2. Provenienz

```yaml
OMW_branch: agent/tarinkot-object-contract-reconciliation
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
mission_date: 2011-01-14
mission_date_controls_ORBAT: false
embedded_moose_path: l10n/DEFAULT/Moose.lua
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE_release: 2.9.18
G5_DCS_version: 2.9.28.26385
G6A_DCS_version: 2.9.28.26385
```

Das Missionsdatum `14.01.2011` bleibt technische Kulisse. Die aktive Tarinkot-ORBAT wird durch den Eigentümerentscheid März bis Dezember 2011 bestimmt.

Der G6A-Debrief führte weiterhin den Quellmissionsnamen `OMW_Template_v5_Salerno.miz`. Diese Ablageabweichung ist als Provenienz-Warnung dokumentiert; der Lauf bleibt wegen eindeutiger Builder-, Commit-, Airbase-, Parking- und Ergebnismarker verwertbar.

## 3. Historische Baseline

```text
Lokaler Aviation-Knoten:
Task Force Attack / 3-101 Attack Aviation

Übergeordnet:
Task Force Thunder / 159th Combat Aviation Brigade

AH-64:
Task Force Attack / 3-101 Attack Aviation

UH-60:
Task-Force-Attack-Komponente
administrative Company weiterhin offen

CH-47:
B Company, 1-52 Aviation Regiment
historisches Muster CH-47D
```

Frühere niederländische AH-64, C/5-101 „Phantoms“ und spätere 2012/2013-Rotationen bleiben Kontext, sind aber keine aktiven SQUADRON-Namen dieses Vertrags.

## 4. Technische Namen

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Veraltete oder verworfene Namen:

```text
AW_US_TARINKOT
SQ_US_TKOT_AH64D_ATTACK_DET
SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
SQ_US_TKOT_UH60_TF_ATTACK_ATTACHED
SQ_US_TKOT_CH47_HEAVYLIFT_DET
SQ_US_TKOT_CH47_TF_ATTACK_ATTACHED
```

## 5. Lokaler OMW-Nominalbestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Evidenzgrenze:

- AH-64-, UH-60- und CH-47-Präsenz 2011 ist bestätigt;
- B/1-52 als lokales CH-47D-Detachment ist bestätigt;
- die exakten Werte `14/6/2/0` bleiben eine quellennahe OMW-Rekonstruktion;
- die Werte werden aus dem RC-South-/Kandahar-Parent-Pool abgezogen und nicht doppelt gezählt.

## 6. Darstellungsledger

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

## 7. Mission-Editor-Vertrag

### 7.1 Airbase und Warehouse

```yaml
dcsAirdromeId: 9
runtimeAirbaseName: Tarinkot
runtimeParkingCount: 33
warehouseAnchor: WH_AIR_US_TARINKOT
warehouseObjectType: container_20ft
warehouseUnitId: 1608
warehouseWrapperCount: 1
```

### 7.2 Clients

```text
CLIENT_US_TKOT_AH64D_01
C01-H / interner Parking-Wert "20" / Runtime-TerminalID 20

CLIENT_US_TKOT_AH64D_02
C05-H / interner Parking-Wert 8 / Runtime-TerminalID 8

CLIENT_US_TKOT_CH47F_01
C07-H / interner Parking-Wert 3 / Runtime-TerminalID 3
```

Der Stringwert `"20"` wird nur für Vergleiche numerisch normalisiert; die Mission wird nicht stillschweigend umgeschrieben.

### 7.3 AI-Seeds

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
CH-47Fbl1 ist der dokumentierte DCS-Ersatz.
```

### 7.4 Statics

G5 bestätigte alle zwölf erwarteten Luftfahrzeug-Statics:

```yaml
AH64_statics: 8
UH60_statics: 4
missing_statics: 0
```

`STATIC_AIR_US_TKOT_AH64_07` ist bereits als `AH-64D_BLK_II` korrigiert und wurde im erfolgreichen G5-Retest sowie im nachfolgenden Debrief bestätigt. Es besteht kein weiterer Static-Korrekturauftrag.

### 7.5 Geplanter registrierter KI-Bestand

```yaml
AH64:
  templateAircraftPerGroup: 2
  registeredGroups: 2
  grouping: 2
  maximumRegisteredAIAircraft: 4
UH60:
  templateAircraftPerGroup: 1
  registeredGroups: 2
  grouping: 1
  maximumRegisteredAIAircraft: 2
  seedReuse: SAME_ONE_SHIP_TEMPLATE_SOURCE_CONFIRMED
CH47:
  templateAircraftPerGroup: 1
  registeredGroups: 1
  grouping: 1
  maximumRegisteredAIAircraft: 1
```

Diese SQUADRON-Registrierung ist noch nicht implementiert; sie bleibt bis zum vollständigen G6B-Ergebnis gesperrt.

## 8. Parking-Vertrag

### 8.1 Produktive Listen

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

### 8.2 Quellenbestätigte MOOSE-Grenzen

- Parking-Listen verwenden interne `TerminalID`, nicht sichtbare ME-Labels;
- `allowSpawnOnClientSpots` ist im Warehouse standardmäßig `false`;
- Client-Template-Koordinaten werden bei der Parkplatzsuche als Hindernisse behandelt;
- `SetSafeParkingOn()` ist verfügbar;
- `SQUADRON:SetParkingIDs()` aktiviert einen asset-spezifischen Zweig, der normale Terminaltyp- und Airbase-Black-/Whitelist-Prüfungen umgeht.

Daraus folgt:

```text
keine positive SQUADRON-Parking-Liste vor abgeschlossenem G6B
SetAllowSpawnOnClientParking() bleibt verboten
Client-, Static- und Rotorkonflikte müssen vor jeder positiven Liste ausgeschlossen sein
```

### 8.3 Akzeptierter G6A-Datensatz

```yaml
AH64_candidates: [0, 1, 6, 11, 13, 14, 18, 22, 24, 25, 28, 33]
AH64_valid_pairs: 66
UH60_candidates: [0, 1, 6, 11, 13, 14, 18, 22, 24, 25, 28, 33]
UH60_valid_pairs: 66
CH47_candidates: [0, 1, 6, 11, 13, 14, 18, 22, 24, 25, 28, 29, 33]
```

Modellradien:

```yaml
AH64_radius_m: 9.967
UH60_radius_m: 10.020
CH47_radius_m: 7.910
```

Die CH-47-DCS-Abmessungen bilden die vollständige Rotorfläche nicht ab. G6B benötigt deshalb eine visuelle Rotorprüfung.

### 8.4 G6B-Probe-Sets

```yaml
AH64:
  terminal_ids: [0, 25]
  runtime_shape: one two-ship group
UH60:
  terminal_ids: [13, 22]
  runtime_shape: two independent one-ship groups
CH47:
  terminal_ids: [14]
  runtime_shape: one one-ship group
```

Terminal `29` wird im ersten CH-47-Test wegen der geringen geometrischen Reserve nicht verwendet.

## 9. Funktionszonen

Bereits vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Erforderlich, aber noch nicht angelegt:

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

Regeln:

- keine Zone wird durch Lua-Fallback-Koordinaten erfunden;
- G5, G6A und G6B benötigen keine neue Funktionszone;
- zonenabhängige Tests bleiben bis zur jeweiligen ME-Anlage gesperrt;
- `ZONE_AIR_US_TKOT_FARP` ist durch die September-2011-Evidenz zu Hot Refueling und Rapid Turnaround fachlich begründet.

## 10. Bestätigte MOOSE-Semantik

### 10.1 SQUADRON und Asset-Gruppen

```lua
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

`Ngroups` zählt Asset-Gruppen. `SetGrouping(n)` bestimmt getrennt die Einheiten pro Asset-Gruppe. Ein One-Ship-UH-60-Template kann zwei unabhängige One-Ship-Asset-Gruppen registrieren.

### 10.2 G6B-SPAWN-Pfad

Im exakten Quellstand ist vorhanden:

```lua
SPAWN:SpawnAtParkingSpot(Airbase, TerminalIDs, SPAWN.Takeoff.Cold)
```

Die Methode erwartet interne Parking-Spot-IDs, löst nur freie Parking-Datensätze auf und übergibt die exakten Datensätze an den Airbase-Spawnpfad. G6B verwendet zusätzlich `InitAIOff()`, damit ausschließlich die anfängliche Platzierung geprüft wird.

### 10.3 UH-60

Im exakten Artefakt existiert kein eigener landgestützter `MEDEVAC`-AUFTRAG. `AUFTRAG:NewRESCUEHELO(Carrier)` ist trägerbezogen und darf nicht als Tarinkot-MEDEVAC verwendet werden.

Geeignete getrennt zu testende Primitive sind:

```text
LANDATCOORDINATE
TROOPTRANSPORT
CARGOTRANSPORT
FREIGHTTRANSPORT
GROUNDESCORT
```

Die Bezeichnung MEDEVAC Lead/Support ist OMW-Paketlogik, keine native MOOSE-MEDEVAC-Automatik.

### 10.4 CH-47 und OPSTRANSPORT

`AUFTRAG:NewOPSTRANSPORT(...)` ist in MOOSE 2.9.18 auskommentiert und nicht aufrufbar. Der gültige spätere Pfad lautet:

```lua
local transport = OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
commander:AddOpsTransport(transport)
```

Pickup- und Deploy-Zone müssen reale ZONE-Objekte sein. Cargo wird nur berücksichtigt, wenn es sich beim Laden in der Pickup-Zone befindet.

### 10.5 COMMANDER

Quellenbestätigt:

```text
COMMANDER:New
AddAirwing
AddMission
AddOpsTransport
CanMission
Start
```

Trennung:

```text
AUFTRAG → AddMission
OPSTRANSPORT → AddOpsTransport
```

Der vorhandene Jalalabad- und Salerno-Nachweis bestätigt technische Grundpfade, nicht taktische Tarinkot-Missionen oder Tarinkot-OPSTRANSPORT.

## 11. Gate-Matrix

| Gate/Test | Erforderliche Zone | Regel |
|---|---|---|
| G5 read-only Diagnose | keine | abgeschlossen; keine Runtime-Objekte erzeugt |
| G6A Kandidatenanalyse | keine | abgeschlossen; geometrischer Datensatz ohne Spawn |
| G6B kontrollierte Platzierung | keine | isolierter `SpawnAtParkingSpot`, AI aus, je Musterfamilie getrennt |
| G7 AIRWING-/SQUADRON-Grundlage | keine | keine operative Mission auslösen |
| G8 AH-64-CAS | separat festgelegter Ziel-/Testbereich | kein Transport/FARP erforderlich |
| G8 UH-60 Utility | `UH60_RAMP` oder `ROTARY_STAGING` | Testvertrag vorher festlegen |
| G8 UH-60 MEDEVAC-Paket | `MEDEVAC_READY`, `HELO_RECOVERY` | OMW-Paketlogik, kein nativer MEDEVAC-AUFTRAG |
| G8 CH-47 Direct Transport | `CH47_READY`, `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | direkten AUFTRAG-Pfad isoliert prüfen |
| G8 CH-47 OPSTRANSPORT | `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | `OPSTRANSPORT:New` plus `AddOpsTransport` |
| FARP-/Hot-Refuel-Test | `FARP` | eigene spätere Acceptance |
| Fixed-Wing-Transient-Test | `TRANSIENT_FIXED_WING` | zurückgestellt |

## 12. G0-bis-G10-Status

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | MIZ, Hash und eingebetteter MOOSE-Commit festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | aktive Baseline und Quellenkritik konsolidiert |
| G2 Objektvertrag | `OWNER_ACCEPTED_BRANCH` | vollständiger G2-Vertrag angenommen |
| G3 Mission Editor | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `PASS_SOURCE_REVIEW` | exaktes Artefakt und relevante API-Pfade geprüft |
| G5 Read-only Diagnose | `PASS_DCS` | Struktur, Parking, Objekte und Mutationsfreiheit bestätigt |
| G6 Parking-Kalibrierung | `G6A_PASS_DCS_G6B_IMPLEMENTED_AWAITING_DCS` | Kandidaten akzeptiert; drei isolierte Platzierungsläufe ausstehend |
| G7 AIRWING/SQUADRON/Payload | `BLOCKED_BY_G6B` | keine Implementierung vor G6B-Auswertung |
| G8 direkter Dispatch/Transport | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/Operational Parking | `NOT_STARTED` | gesperrt |
| G10 Lifecycle/Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 13. Akzeptierte und ausstehende Teststände

### 13.1 G5

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

Bestätigt:

```yaml
runtime_airbase: Tarinkot
runtime_airbase_id: 9
parking_count: 33
warehouse_wrappers: 1
clients: 3/3
AI_seeds: 3/3
statics: 12/12
zones_present: 1
zones_missing: 10
name_duplicates: 0
mutations: 0
```

### 13.2 G6A

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET reason=none parkingCount=33 modelMissing=0 candidateSetFailures=0 activePlayerClients=0 parkingMutation=0 spawns=0
```

### 13.3 G6B

Implementiert sind drei getrennte Bundles:

```text
OMW_AirOps_Tarinkot_G6B_AH64_Placement.lua
OMW_AirOps_Tarinkot_G6B_UH60_Placement.lua
OMW_AirOps_Tarinkot_G6B_CH47_Placement.lua
```

Erwarteter Marker je Lauf:

```text
RESULT G6B_<FAMILY>_CONTROLLED_PLACEMENT status=PASS_RUNTIME_PLACEMENT
```

Ein automatischer PASS benötigt zusätzlich eine visuelle Bestätigung von Modell-, Static-, Terrain- und Rotorfreiheit, bevor G6B insgesamt abgeschlossen wird.
