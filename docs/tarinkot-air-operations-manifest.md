---
document_id: OMW-AIR-TKOT-MANIFEST
status: DRAFT
owning_policy: OMW-GOV-001
document_class: AIR_OPERATIONS_MANIFEST
authoritative_for:
  - accepted Tarinkot AIRWING and SQUADRON object contract on the active branch
  - Tarinkot unit and technical object naming derived from the safest available sources
  - accepted Tarinkot local aircraft inventory and representation limits
  - exact Tarinkot Mission Editor names for the audited working mission
  - Tarinkot warehouse, client, seed-template and static contract
  - accepted G5 runtime basis and G6 parking mapping and placement
  - accepted G7 AIRWING, SQUADRON, capability and payload foundation
  - Tarinkot dependency on central AirOps lifecycle and test governance
not_authoritative_for:
  - actual vertical departure
  - tactical AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - final loss, return, recovery, stranded-state or persistence behavior
  - historical subordinate identities not explicitly supported by cited evidence
  - exact 2011 aircraft quantities beyond the documented OMW reconstruction
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G7_ACCEPTED_G8_BLOCKED
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
original_source_mission: OMW_Template_v5_Salerno.miz
original_source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
current_working_mission: OMW_Template_v6_Tarinkot.miz
accepted_g7_mission_sha256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
accepted_g7_internal_mission_sha256: babaaee09f38ecbacb0c564b1686e20ee5b18ccf9b8abd920f32952d4a8f54a8
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
validated_in_dcs: partial
object_contract_state: OWNER_ACCEPTED_BRANCH
moose_source_review_state: PASS_SOURCE_REVIEW
g5_state: PASS_DCS
g6_state: PASS_DCS_OWNER_VISUAL_ACCEPTED
g7_state: PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION
g8_state: BLOCKED_BY_CENTRAL_CONSOLIDATION_AND_STATIC_GATE
supersedes_on_merge:
  - Tarinkot object assumptions from docs/tarinkot-air-operations-baseline PR 40
  - Tarinkot Mission Editor assumptions based on OMW_Template(3).miz
  - generic Tarinkot AIRWING and SQUADRON names not derived from historical evidence
  - provisional UH-60 and CH-47 TF_ATTACK_ATTACHED names
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations Manifest und Objektvertrag

## 1. Zweck und Freigabegrenze

Dieses Dokument ist die aktive Tarinkot-Arbeitsbaseline auf Draft PR #53. Es konsolidiert:

- den Eigentümerentscheid für März bis Dezember 2011;
- Juli-2011-ORBAT und zeitgenössische U.S.-Army-/DVIDS-Evidenz;
- Satellitenbeobachtung und Mission-Editor-Audits;
- den angenommenen G2-Objektvertrag;
- die Prüfung der exakt eingebetteten MOOSE-Version 2.9.18;
- G5-Strukturdiagnose;
- G6-Parking-Kalibrierung und visuell akzeptierte Platzierung;
- den am 4. August 2026 akzeptierten G7-Foundation-Lauf;
- die zentrale Lifecycle- und Testgovernance aus Draft PR #55.

Nicht autorisiert:

```text
Merge
Ready for Review
G8-AUFTRAG-Dispatch vor Abschluss der zentralen Konsolidierung
Behauptung eines tatsächlichen vertikalen Starts
COMMANDER- oder OPSTRANSPORT-Ausführung
Lifecycle-, Recovery- oder Persistenzbehauptungen außerhalb des getesteten Scopes
weitere lange DCS-Läufe ohne statischen Builder-, Dokumentations- und Hashketten-PASS
```

## 2. Provenienz

### 2.1 Ausgangs- und Arbeitsmission

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
DCS_version: 2.9.28.26385 MT
```

Das Missionsdatum ist technische Kulisse. Die aktive Tarinkot-ORBAT wird durch den Eigentümerentscheid März bis Dezember 2011 bestimmt.

### 2.2 Akzeptierter G7-Stand

```text
Source commit: add569fb3231a5563d9c89f865cce7bd764bc0bb
BuilderVersion: TKOT-G7-AIRWING-FOUNDATION-3
Bundle SHA-256: 7018f4e388a349f91bc4169e6200226a32c001e3c4afdbd4daf69b538de2dea8
MIZ SHA-256: 86ba08f46c78a94cdf6eb54f7abe85145bdabe2817e7a2a89f2cec34932866bb
Internal mission SHA-256: babaaee09f38ecbacb0c564b1686e20ee5b18ccf9b8abd920f32952d4a8f54a8
DCS log SHA-256: aeacc9fc9270dc033ed49a41eb1b3264880710265386f1d21e0c787a22739e52
Debrief SHA-256: 8a33b90efdf57f92a95ff2b07d0c016555d79776da3b708367f63ef09a284588
```

Jedes Speichern, Neuverpacken, Überschreiben oder Übertragen der MIZ erzeugt ein neues Artefakt. Der frühere Struktur-PASS bleibt historische Evidenz für seine Hashkette, ist aber nicht automatisch auf die geänderte Datei übertragbar.

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

Frühere niederländische AH-64, C/5-101 „Phantoms“ und spätere 2012/2013-Rotationen sind Kontext, aber keine aktiven SQUADRON-Namen dieses Vertrags.

## 4. Technische Namen

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Verworfene Namen:

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
- `14/6/2/0` ist eine quellennahe OMW-Rekonstruktion;
- Tarinkot-Bestände werden aus dem RC-South-/Kandahar-Parent-Pool abgezogen und nicht doppelt gezählt.

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

Registrierung ist keine gleichzeitige Bodenbereitstellung. Der AH-64-Pool trägt eine Two-Ship-Gruppe gleichzeitig. Die zweite registrierte Two-Ship-Gruppe bleibt Warehouse-Reserve, bis Positionen frei sind oder ein weiterer Pool separat akzeptiert wird.

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
Unit: CLIENT_US_TKOT_AH64D_01_UNIT_01
C01-H / interner Parking-Wert "20" / Runtime-TerminalID 20

CLIENT_US_TKOT_AH64D_02
C05-H / interner Parking-Wert 8 / Runtime-TerminalID 8

CLIENT_US_TKOT_CH47F_01
C07-H / interner Parking-Wert 3 / Runtime-TerminalID 3
```

Der Stringwert `"20"` wird für Vergleiche numerisch normalisiert; die Mission wird nicht stillschweigend umgeschrieben.

### 7.3 KI-Seeds

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

Der akzeptierte G7-Lauf bestätigte alle zwölf Luftfahrzeug-Statics:

```yaml
AH64_statics: 8
UH60_statics: 4
missing_statics: 0
```

`STATIC_AIR_US_TKOT_AH64_07` war vorhanden und als `AH-64D_BLK_II` typisiert.

## 8. Abgeschlossener Parking-Vertrag

### 8.1 Client-Ausschlüsse

```yaml
client_terminal_ids: [3, 8, 20]
```

Diese Positionen dürfen nicht in einen KI-Pool aufgenommen werden.

### 8.2 Mapping

G6A2 bestand:

```text
RESULT G6A2_ME_PARKING_MAP
status=PASS_MAP
anchors=30
mapped=30
rejected=0
ambiguous=0
duplicates=0
parkingCount=33
clientReferences=3
```

### 8.3 Historischer Fehlversuch

Der erste kombinierte G6B-Lauf verwendete type-104/OpenBig-Positionen und scheiterte visuell:

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

Finaler G6B-Lauf:

```text
expectedGroups=7
groupsFound=7
expectedUnits=8
unitsFound=8
placementFailures=0
familyFailures=0
spawnCalls=7
expectedTerminalType=HelicopterOnly
```

Der Lauf bestand technisch und wurde vom Projektinhaber visuell akzeptiert.

Interne `SQUADRON.parkingIDs` und geerbte `asset.parkingIDs` beweisen keine tatsächliche spätere DCS-Platzierung. Runtime-Unitpositionen bleiben bei operativen Spawn-/Dispatch-Tests separat zu prüfen.

## 9. Funktionszonen

Vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Ausstehend:

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
- ein isolierter G8-CAS-Dispatch darf nur vorhandene, fachlich geeignete Ziel-/Missionsobjekte verwenden;
- MEDEVAC-, Transport-, Logistics- und Recovery-Tests bleiben bis zur Anlage ihrer realen Zonen gesperrt;
- `ZONE_AIR_US_TKOT_FARP` ist durch September-2011-Evidenz zu Hot Refueling und Rapid Turnaround fachlich begründet.

## 10. MOOSE-Semantik und Lifecycle

### 10.1 SQUADRON-Gruppen

```lua
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

`Ngroups` zählt Assetgruppen. `SetGrouping(n)` legt die Units pro Assetgruppe fest.

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

### 10.2 Pre-Start und Post-Start

Verbindlicher Lifecycle für den gepinnten MOOSE-Stand:

```text
SQUADRON:New()
  -> Konfiguration vorhanden
  -> squadron.assets noch kein positiver Runtime-Bestand

AIRWING:AddSquadron()
  -> SQUADRON in airwing.cohorts
  -> Assetgruppen synchron in airwing.stock
  -> automatisches RELOCATECOHORT-Payload
  -> squadron.assets weiterhin deferred

AIRWING:Start() plus WAREHOUSE-/LEGION-Initialisierung
  -> Assets an COHORT/SQUADRON gebunden
  -> squadron.assets post-start prüfbar
```

G7 bestätigte:

```text
Pre-Start:
  stock 2 -> 4 -> 5
  squadron.assets 0/0/0

Post-Start:
  AIRWING Running
  stock 5
  squadron.assets 2/2/1
```

Ein Pre-Start-Fail auf `squadron.assets ~= Ngroups` ist verboten.

### 10.3 Payloads

`AIRWING:AddSquadron()` erzeugt je SQUADRON ein unbegrenztes `RELOCATECOHORT`-Payload. G7 registriert zusätzlich ein Rollen-Payload je Familie:

```text
3 automatische RELOCATECOHORT-Payloads
3 Rollen-Payloads
6 Payloadtabellen gesamt
```

### 10.4 Vertikaloption

Verbindlicher AIRWING-Pfad:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

Im nativen `FlightOnMission`-Pfad überträgt MOOSE diese Option auf die verwaltete FLIGHTGROUP über:

```lua
FlightGroup:SetOptionPreferVertical()
```

G7 beweist ausschließlich, dass das AIRWING-Flag vor Start gesetzt war. Raw-SPAWN-, direkte UNIT- und standalone-FLIGHTGROUP-Experimente sind kein akzeptierter Produktionspfad.

Tatsächlicher Vertikalstart gehört in den isolierten G8-AIRWING-/AUFTRAG-Dispatch.

### 10.5 UH-60

Im Artefakt existiert kein eigener landgestützter `MEDEVAC`-AUFTRAG. Geeignete Primitive sind:

```text
LANDATCOORDINATE
TROOPTRANSPORT
CARGOTRANSPORT
GROUNDESCORT
```

MEDEVAC Lead/Support ist OMW-Paketlogik, keine native MOOSE-MEDEVAC-Automatik.

### 10.6 CH-47 und OPSTRANSPORT

`AUFTRAG:NewOPSTRANSPORT(...)` ist in MOOSE 2.9.18 auskommentiert. Der spätere Pfad lautet:

```lua
local transport = OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
commander:AddOpsTransport(transport)
```

G7 enthält kein OPSTRANSPORT-Payload und keine OPSTRANSPORT-Instanz. Transport wird erst mit realen Pickup-/Deploy-Zonen separat getestet.

## 11. G7-Grundknoten

### 11.1 AIRWING

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
Warehouse: WH_AIR_US_TARINKOT
Airbase: Tarinkot / ID 9
Takeoff: Cold
Safe Parking: On
Prefer Vertical: On before Start
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

### 11.3 Akzeptiertes G7-Ergebnis

```text
status=PASS
violations=0
airwingRunning=true
squadrons=3
registeredGroups=5
registeredAircraft=7
stock=5
rolePayloads=3
totalPayloads=6
parkingPools=3
parkingIDs=8
missionQueue=0
transportQueue=0
requestQueue=0
opsGroups=0
safeParking=true
verticalPolicy=true
takeoffCold=true
observerClientsDetected=1
observerClientsAllowed=1
observerClientsBlocking=0
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```

Der akzeptierte Builder v3 protokollierte im Endmarker fälschlich `activePlayerClients=0`, nachdem der gleiche Lauf zuvor einen Client erkannt hatte. Dieses einzelne Feld ist verworfen. Die korrekte Semantik lautet `detected=1`, `allowed=1`, `blocking=0`.

### 11.4 Observer-Client

Zulässig war:

```text
CLIENT_US_TKOT_AH64D_01_UNIT_01
TerminalID 20
Player Neues Rufz.
```

TerminalID 20 ist hart aus sämtlichen KI-Pools ausgeschlossen. G7 erzeugt keine Flugbewegung. Künftige Tests dürfen den tatsächlichen Detektionswert nicht auf null maskieren.

## 12. Statischer Folgestand

```text
Builder:
tools/build-tarinkot-air-operations-g7-foundation.ps1

Prepared BuilderVersion:
TKOT-G7-AIRWING-FOUNDATION-4

Lifecycle Guard:
tools/Test-AirOpsLifecycleGuards.ps1

CI Workflow:
.github/workflows/tarinkot-g7-static-validation.yml
```

Der Guard blockiert:

- positive Pre-Start-Sollprüfung von `squadron.assets`;
- Pre-Start-Prüfung geerbter `asset.parkingIDs`;
- Vertikaloption nach `AIRWING:Start()`;
- Observer-Count-Maskierung;
- COMMANDER-, AUFTRAG-, OPSTRANSPORT- und SPAWN-Pfade im G7-Scope.

Diese Harnesskorrektur benötigt keinen erneuten langen G7-DCS-Lauf. Sie muss statisch bestehen, bevor G8 vorbereitet wird.

## 13. Gate-Matrix

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | MIZ, Hash und eingebetteter MOOSE-Commit festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | aktive Baseline und Quellenkritik konsolidiert |
| G2 Objektvertrag | `OWNER_ACCEPTED_BRANCH` | vollständiger G2-Vertrag angenommen |
| G3 Mission Editor | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `PASS_SOURCE_REVIEW` | exaktes Artefakt und relevante API-/Lifecycle-Pfade geprüft |
| G5 Read-only Diagnose | `PASS_DCS` | Struktur, Parking, Objekte und Mutationsfreiheit bestätigt |
| G6A Geometrie | `PASS_DCS_SCOPE_TOO_BROAD` | type-104-Scope nicht produktiv |
| G6A2 Mapping | `PASS_DCS` | 33/33 ME-/MOOSE-Zuordnung vollständig |
| G6B Parking/Placement | `PASS_DCS_OWNER_VISUAL_ACCEPTED` | acht type-40-Positionen angenommen |
| G7 AIRWING/SQUADRON/Payload | `PASS_DCS_WITH_TELEMETRY_FIELD_CORRECTION` | Idle-Foundation und Lifecycle akzeptiert |
| G7 statischer Guard | `IMPLEMENTED_AWAITING_CI` | Builder v4 und gemeinsamer Guard vorhanden |
| zentrale Konsolidierung | `DRAFT_PR_55_NOT_ON_MAIN` | G8 bleibt gesperrt |
| G8 direkter Dispatch/Vertikalstart | `BLOCKED` | erst nach PR #55 und statischem PASS |
| G9 COMMANDER | `BLOCKED_BY_G8` | nicht begonnen |
| G10 Lifecycle/Handoff | `NOT_STARTED` | nicht begonnen |

## 14. Verbindliche nächste Grenze

Vor dem nächsten DCS-Lauf müssen PASS sein:

```yaml
central_lifecycle_governance_on_main: true
canonical_document_22_on_main: true
mission_test_governance_on_main: true
tarinkot_builder_v4_static_ci: true
observer_policy_non_masking: true
prestart_poststart_guards: true
next_miz_hash_known: true
embedded_bundle_hash_known: true
embedded_moose_hash_known: true
acceptance_documents_synchronized: true
```

Der nächste DCS-Lauf ist danach genau ein isolierter G8-AIRWING-/AUFTRAG-Dispatch zur Prüfung der realen Vertikalabflugkette. Kein Merge und kein Ready for Review ohne ausdrückliche Freigabe des Projektinhabers.
