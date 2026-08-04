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
  - Tarinkot warehouse-anchor, client-reservation, seed-template and static contract
  - accepted G5 runtime basis and G6 parking mapping and placement results
  - current G7 AIRWING/SQUADRON/capability/payload implementation contract
not_authoritative_for:
  - G7 runtime acceptance before a documented DCS PASS
  - tactical AUFTRAG, vertical departure, COMMANDER or OPSTRANSPORT acceptance
  - final lifecycle, loss, return, recovery or stranded-state behavior
  - historical subordinate identities not explicitly supported by cited evidence
  - exact 2011 aircraft quantities beyond the documented OMW reconstruction
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G7_FOUNDATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
original_source_mission: OMW_Template_v5_Salerno.miz
original_source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
current_working_mission: OMW_Template_v6_Tarinkot.miz
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
validated_in_dcs: partial
object_contract_state: OWNER_ACCEPTED_BRANCH
moose_source_review_state: PASS_SOURCE_REVIEW
g5_state: PASS_DCS
g6_state: PASS_DCS_OWNER_VISUAL_ACCEPTED
g7_state: IMPLEMENTED_AWAITING_DCS
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
- die Prüfung der exakt eingebetteten MOOSE-Version 2.9.18;
- den akzeptierten G5-Strukturstand;
- die abgeschlossene G6-Parking-Kalibrierung und Platzierungsabnahme;
- den implementierten, noch nicht in DCS abgenommenen G7-Grundknoten.

Nicht autorisiert sind weiterhin:

```text
Merge
Ready for Review
positive G7-Runtimebehauptung vor DCS-PASS
operativer AUFTRAG-Dispatch
COMMANDER- oder OPSTRANSPORT-Ausführung
Lifecycle-, Recovery- oder Persistenzbehauptungen
MIZ-Änderungen außerhalb des festgelegten Testworkflows
```

## 2. Provenienz

```yaml
OMW_branch: agent/tarinkot-object-contract-reconciliation
original_source_mission: OMW_Template_v5_Salerno.miz
original_source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
current_working_mission: OMW_Template_v6_Tarinkot.miz
mission_date: 2011-01-14
mission_date_controls_ORBAT: false
embedded_moose_path: l10n/DEFAULT/Moose.lua
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE_release: 2.9.18
G5_DCS_version: 2.9.28.26385
G6_DCS_version: 2.9.28.26385
```

Das Missionsdatum `14.01.2011` bleibt technische Kulisse. Die aktive Tarinkot-ORBAT wird durch den Eigentümerentscheid März bis Dezember 2011 bestimmt.

Die aktuelle Arbeitsmission ist aus dem geprüften Ausgangsstand hervorgegangen. Jeder neue DCS-Lauf muss trotzdem durch Builder-Version, Git-Commit und Bundle-Hash eindeutig zugeordnet werden.

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

## 6. Darstellungs- und Registrierungsledger

| Musterfamilie | Statics | aktive Clients maximal | G7 registrierte KI | maximale Repräsentation |
|---|---:|---:|---:|---:|
| AH-64 | 8 | 2 | 4 | 14 |
| UH-60 | 4 | 0 | 2 | 6 |
| CH-47 | 0 | 1 | 1 | 2 |
| OH-58D | 0 | 0 | 0 | 0 |

Invariante:

```text
Statics
+ aktive Clients
+ registrierte beziehungsweise aktive KI
+ bestätigte Wartungs-/Stranded-Zustände
<= lokaler Bestand je Musterfamilie
```

Late-Activation-Seeds und unbelegte Client-Slots erhöhen den Bestand nicht.

Wichtig: Registrierung ist nicht gleich gleichzeitige Bodenbereitstellung. Der akzeptierte AH-64-Pool besitzt zwei Positionen und trägt damit eine Two-Ship-Gruppe gleichzeitig. Die zweite registrierte Two-Ship-Asset-Gruppe bleibt Reserve, bis Positionen frei sind oder ein späterer, separat abgenommener Pool ergänzt wird.

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

Der Stringwert `"20"` wird für Vergleiche numerisch normalisiert; die Mission wird nicht stillschweigend umgeschrieben.

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

`STATIC_AIR_US_TKOT_AH64_07` ist bereits als `AH-64D_BLK_II` korrigiert und wurde im erfolgreichen G5-Retest sowie in nachfolgenden Läufen bestätigt. Es besteht kein weiterer Static-Korrekturauftrag.

## 8. Abgeschlossener Parking-Vertrag

### 8.1 Client-Ausschlüsse

```yaml
client_terminal_ids: [3, 8, 20]
```

Diese Positionen dürfen nicht in einen KI-Pool aufgenommen werden.

### 8.2 Vollständige ME-/MOOSE-Zuordnung

G6A2 bestand:

```text
RESULT G6A2_ME_PARKING_MAP status=PASS_MAP anchors=30 mapped=30 rejected=0 ambiguous=0 duplicates=0 parkingCount=33 clientReferences=3
```

### 8.3 Historischer Fehlversuch

Der erste kombinierte G6B-Lauf verwendete type-104/OpenBig-Positionen. Der Lauf platzierte die Modelle technisch an den angeforderten Koordinaten, bestand aber die visuelle Flächenprüfung nicht:

```text
FAIL_VISUAL_WRONG_APRON
```

Diese Positionen sind keine akzeptierte Tarinkot-Hubschrauberplatte.

### 8.4 Akzeptierte Pools

```yaml
AH64:
  mission_editor_labels: [C04-H, C18-H]
  terminal_ids: [21, 4]
UH60:
  mission_editor_labels: [C14-H, C12-H, C11-H]
  terminal_ids: [30, 27, 23]
CH47:
  mission_editor_labels: [C08-H, C09-H, C10-H]
  terminal_ids: [32, 29, 10]
```

Alle acht Positionen wurden im finalen kombinierten G6B-Lauf als `TerminalType 40 / HelicopterOnly` verwendet. Der Lauf bestand technisch und wurde vom Eigentümer visuell akzeptiert:

```text
expectedGroups=7
groupsFound=7
expectedUnits=8
unitsFound=8
placementFailures=0
familyFailures=0
spawnCalls=7
```

Die Pools dürfen ab G7 über `SQUADRON:SetParkingIDs()` angewendet werden. Da dieser MOOSE-Zweig die normalen Airbase-Listenprüfungen umgeht, validiert G7 alle acht IDs nochmals vor der Registrierung und prüft anschließend die an jedes Asset vererbten `asset.parkingIDs`.

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
- G7 benötigt keine Funktionszone und erzeugt keine synthetische Zone;
- zonenabhängige G8-Transport- und MEDEVAC-Tests bleiben bis zur jeweiligen ME-Anlage gesperrt;
- `ZONE_AIR_US_TKOT_FARP` ist durch die September-2011-Evidenz zu Hot Refueling und Rapid Turnaround fachlich begründet.

## 10. Bestätigte MOOSE-Semantik

### 10.1 SQUADRON und Asset-Gruppen

```lua
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

`Ngroups` zählt Asset-Gruppen. `SetGrouping(n)` bestimmt getrennt die Einheiten pro Asset-Gruppe.

G7 verwendet:

```yaml
AH64:
  Ngroups: 2
  grouping: 2
UH60:
  Ngroups: 2
  grouping: 1
CH47:
  Ngroups: 1
  grouping: 1
```

### 10.2 Payloads

`AIRWING:AddSquadron()` erzeugt für jedes SQUADRON automatisch ein unbegrenztes `RELOCATECOHORT`-Payload. G7 registriert zusätzlich genau ein rollenbezogenes Payload je Musterfamilie.

Erwartung:

```text
3 automatische RELOCATECOHORT-Payloads
3 rollenbezogene Payloads
6 Payloadtabellen insgesamt
```

### 10.3 Vertikalflug-Policy

Der verbindliche MOOSE-Pfad lautet:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

MOOSE überträgt die Policy später im `FlightOnMission`-Pfad auf die von AIRWING verwaltete `FLIGHTGROUP`.

Die nach G6 ausgeführten direkten UNIT- und Standalone-FLIGHTGROUP-Experimente sind verworfen. G7 prüft nur das vor `Start()` gesetzte AIRWING-Policy-Flag und einen stabilen Idle-Knoten. Tatsächlicher Vertikalstart gehört zu G8.

### 10.4 UH-60

Im exakten Artefakt existiert kein eigener landgestützter `MEDEVAC`-AUFTRAG. Geeignete Primitive sind unter anderem:

```text
LANDATCOORDINATE
TROOPTRANSPORT
CARGOTRANSPORT
GROUNDESCORT
```

Die Bezeichnung MEDEVAC Lead/Support ist OMW-Paketlogik, keine native MOOSE-MEDEVAC-Automatik.

### 10.5 CH-47 und OPSTRANSPORT

`AUFTRAG:NewOPSTRANSPORT(...)` ist in MOOSE 2.9.18 auskommentiert. Der spätere gültige Pfad lautet:

```lua
local transport = OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
commander:AddOpsTransport(transport)
```

G7 registriert vorsätzlich noch keine OPSTRANSPORT-Capability und kein entsprechendes Payload. Der konkrete Transportvertrag folgt zusammen mit realen Pickup-/Deploy-Zonen in einem eigenen G8-Test.

## 11. G7-Grundknotenvertrag

### 11.1 AIRWING

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
Warehouse: WH_AIR_US_TARINKOT
Airbase: Tarinkot / ID 9
Takeoff: Cold
Safe Parking: On
Prefer Vertical Landing/Takeoff: On before Start
```

### 11.2 SQUADRONs, Capabilities und Parking

```yaml
AH64:
  squadron: SQ_US_TKOT_AH64D_3_101_AVN
  capabilities: [CAS]
  parking_ids: [21, 4]
UH60:
  squadron: SQ_US_TKOT_UH60_TF_ATTACK
  capabilities: [TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE, GROUNDESCORT]
  parking_ids: [30, 27, 23]
CH47:
  squadron: SQ_US_TKOT_CH47_B_1_52_AVN
  capabilities: [TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE]
  parking_ids: [32, 29, 10]
```

### 11.3 G7-Ausschlüsse

```text
COMMANDER: 0
AUFTRAG-Instanzen: 0
OPSTRANSPORT: 0
SPAWN: 0
synthetische Zonen: 0
absichtliche Spawns: 0
Missionqueue: 0
Transportqueue: 0
Warehouse-Request-Queue: 0
```

G7 besteht erst, wenn der AIRWING nach Start stabil `Running` bleibt und `AIRWING:GetOpsGroups()` weiterhin leer ist.

## 12. Gate-Matrix

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | MIZ, Hash und eingebetteter MOOSE-Commit festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | aktive Baseline und Quellenkritik konsolidiert |
| G2 Objektvertrag | `OWNER_ACCEPTED_BRANCH` | vollständiger G2-Vertrag angenommen |
| G3 Mission Editor | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `PASS_SOURCE_REVIEW` | exaktes Artefakt und relevante API-Pfade geprüft |
| G5 Read-only Diagnose | `PASS_DCS` | Struktur, Parking, Objekte und Mutationsfreiheit bestätigt |
| G6A Geometrie | `PASS_DCS_SCOPE_TOO_BROAD` | Datensatz technisch korrekt, type-104-Scope nicht produktiv |
| G6A2 Mapping | `PASS_DCS` | 33/33 ME-/MOOSE-Zuordnung vollständig |
| G6B Parking/Placement | `PASS_DCS_OWNER_VISUAL_ACCEPTED` | acht type-40-Positionen angenommen |
| G7 AIRWING/SQUADRON/Payload | `IMPLEMENTED_AWAITING_DCS` | kombiniertes Idle-Foundation-Bundle bereit |
| G8 direkter Dispatch | `BLOCKED_BY_G7` | erster nativer Vertikalstart folgt nach G7-PASS |
| G9 COMMANDER | `BLOCKED_BY_G8` | nicht begonnen |
| G10 Lifecycle/Handoff | `NOT_STARTED` | nicht begonnen |

## 13. Aktueller G7-Teststand

```text
Source:
mission/tests/tarinkot-air-operations/src/07-tarinkot-g7-airwing-squadron-payload-foundation.lua

Builder:
tools/build-tarinkot-air-operations-g7-foundation.ps1

BuilderVersion:
TKOT-G7-AIRWING-FOUNDATION-1

Bundle:
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G7_Foundation.lua

Acceptance:
mission/tests/tarinkot-air-operations/expected/g7-airwing-squadron-payload-foundation-acceptance.md
```

Ein PASS benötigt den vollständigen Abschlussmarker:

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION status=PASS
```

mit:

```text
violations=0
airwingRunning=true
squadrons=3
registeredGroups=5
registeredAircraft=7
stock=5
rolePayloads=3
totalPayloads=6
parkingIDs=8
missionQueue=0
transportQueue=0
requestQueue=0
opsGroups=0
safeParking=true
verticalPolicy=true
takeoffCold=true
activePlayerClients=0
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```
