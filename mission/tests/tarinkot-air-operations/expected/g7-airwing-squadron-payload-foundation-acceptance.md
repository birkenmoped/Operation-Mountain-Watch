---
document_id: OMW-TEST-TKOT-G7-AIRWING-SQUADRON-PAYLOAD-FOUNDATION-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G7 combined AIRWING, SQUADRON, capability and payload acceptance
  - application of G6-accepted SQUADRON parking pools
  - AIRWING vertical-helicopter policy order before AIRWING start
  - stable idle-node PASS and FAIL criteria
not_authoritative_for:
  - tactical AUFTRAG dispatch
  - vertical takeoff runtime acceptance
  - COMMANDER or OPSTRANSPORT acceptance
  - return, landing, recovery, loss or persistence acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_G7_FOUNDATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G7 – AIRWING/SQUADRON/Payload Foundation Acceptance

## 1. Testziel

Ein kombinierter DCS-Lauf muss den vollständigen Tarinkot-Grundknoten ohne operativen Auftrag aufbauen und stabil betreiben:

```text
1 AIRWING
3 SQUADRONs
5 registrierte Asset-Gruppen
7 registrierte KI-Luftfahrzeuge
3 rollenbezogene Payloads
3 automatisch durch AIRWING:AddSquadron erzeugte RELOCATECOHORT-Payloads
8 akzeptierte HelicopterOnly-ParkingIDs
0 COMMANDER
0 AUFTRAG-Instanzen
0 OPSTRANSPORT
0 absichtliche Spawns
```

Dieser Lauf bündelt sämtliche technisch zusammengehörigen G7-Prüfungen. Familienweise Einzelläufe sind nur bei einer nicht eindeutig isolierbaren Störung zulässig.

## 2. Provenienzvertrag

```yaml
branch: agent/tarinkot-object-contract-reconciliation
mission: OMW_Template_v6_Tarinkot.miz
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
builder: tools/build-tarinkot-air-operations-g7-foundation.ps1
builder_version: TKOT-G7-AIRWING-FOUNDATION-1
bundle: mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G7_Foundation.lua
```

Der konkrete Git-Commit und Bundle-SHA-256 werden beim lokalen Build ermittelt und mit dem Lauf protokolliert.

## 3. Objektvertrag

### AIRWING

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
Warehouse: WH_AIR_US_TARINKOT
Airbase: Tarinkot
DCS Airbase ID: 9
Takeoff baseline: Cold
Safe Parking: enabled
Vertical helicopter policy: enabled before AIRWING:Start()
```

### SQUADRONs

```yaml
AH64:
  name: SQ_US_TKOT_AH64D_3_101_AVN
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  type: AH-64D_BLK_II
  Ngroups: 2
  grouping: 2
  registered_aircraft: 4
  parking_ids: [21, 4]
  capabilities: [CAS]
UH60:
  name: SQ_US_TKOT_UH60_TF_ATTACK
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  type: UH-60A
  Ngroups: 2
  grouping: 1
  registered_aircraft: 2
  parking_ids: [30, 27, 23]
  capabilities: [TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE, GROUNDESCORT]
CH47:
  name: SQ_US_TKOT_CH47_B_1_52_AVN
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  type: CH-47Fbl1
  Ngroups: 1
  grouping: 1
  registered_aircraft: 1
  parking_ids: [32, 29, 10]
  capabilities: [TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE]
```

`OPSTRANSPORT` und `FREIGHTTRANSPORT` werden in G7 nicht vorsorglich ergänzt. Der spätere Transporttest legt deren konkreten Carrier-, Cargo-, Zonen- und Payloadvertrag separat fest.

## 4. Bestandsledger

```text
AH-64: 8 Statics + 2 Clients + 4 registrierte KI = 14
UH-60: 4 Statics + 0 Clients + 2 registrierte KI = 6
CH-47: 0 Statics + 1 Client  + 1 registrierte KI = 2
```

Der Test prüft diese Rechnung explizit. Late-Activation-Templates sind keine zusätzlichen Luftfahrzeuge.

Die zwei akzeptierten AH-64-ParkingIDs tragen jeweils genau einen Two-Ship-Start. Damit ist ohne spätere Poolerweiterung nur eine AH-64-Two-Ship-Gruppe gleichzeitig am Boden startfähig. G7 akzeptiert die Registrierung zweier Asset-Gruppen, behauptet aber keine gleichzeitige Bodenbereitstellung beider Gruppen.

## 5. Parking-Vertrag

Alle acht IDs müssen im Lauf:

```text
vorhanden
TerminalType 40 / HelicopterOnly
Free=true
TOAC nicht true
keine Client-TerminalID
untereinander eindeutig
```

sein.

Hard Client Exclusions:

```text
TerminalID 3
TerminalID 8
TerminalID 20
```

Nach `AIRWING:AddSquadron()` muss jedes registrierte Asset die ParkingIDs seines SQUADRON übernommen haben. Dies folgt dem MOOSE-Pfad `asset.parkingIDs = cohort.parkingIDs` und wird für jede Asset-Gruppe protokolliert.

## 6. MOOSE-Vertrag

Verwendet werden ausschließlich vorhandene MOOSE-Primitive:

```lua
AIRWING:New()
AIRWING:SetAirbase()
AIRWING:SetTakeoffCold()
AIRWING:SetSafeParkingOn()
AIRWING:SetOptionPreferVerticalLanding()
SQUADRON:New()
SQUADRON:SetGrouping()
SQUADRON:SetParkingIDs()
SQUADRON:AddMissionCapability()
AIRWING:AddSquadron()
AIRWING:GetSquadron()
AIRWING:NewPayload()
AIRWING:GetOpsGroups()
AIRWING:Start()
```

Verbindliche Reihenfolge:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

G7 prüft das gesetzte Policy-Flag. Ein tatsächlicher vertikaler Abflug wird erst mit einem nativen AIRWING-/AUFTRAG-Dispatch in G8 abgenommen.

## 7. Verbotene Inhalte

Das Bundle darf keine dieser Laufzeitaktionen enthalten:

```text
COMMANDER:New
AUFTRAG-Konstruktor
OPSTRANSPORT:New
SPAWN
FLIGHTGROUP:New
SetAIOn
StartUncontrolled
Despawn
Destroy
coalition.addGroup
synthetische Testzone
CampaignState-Mutation
AIRWING:AddMission
```

## 8. Ausführung

Testbedingungen:

```text
Tarinkot-Client-Slots unbesetzt
MOOSE zuerst laden
nur das G7-Bundle als aktuelles Tarinkot-Testbundle laden
Mission mindestens 45 Sekunden laufen lassen
keinen Auftrag oder F10-Testbefehl auslösen
```

Es ist keine Sichtprüfung gespawnter Luftfahrzeuge erforderlich, weil G7 ausdrücklich null Spawns verlangt.

## 9. Erwartete Zwischenmarker

```text
PARKING_POOL_SUMMARY accepted=8 expected=8
STATIC_CONTRACT_SUMMARY found=12 expected=12
OPS_GROUPS_PRESTART=0
AIRWING_START_CALLED verticalPolicySetBeforeStart=true missionsCreated=0 commanderCreated=0 transportCreated=0 deliberateSpawns=0
```

Erwartete Idle-Prüfung:

```text
IDLE_INSPECTION
airwingRunning=true
stock=5
missionQueue=0
transportQueue=0
requestQueue=0
opsGroups=0
activePlayerClients=0
```

## 10. PASS-Kriterium

Der Abschlussmarker muss enthalten:

```text
RESULT G7_AIRWING_SQUADRON_PAYLOAD_FOUNDATION
status=PASS
reason=none
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
activePlayerClients=0
commanderCreated=0
auftragCreated=0
opsTransportCreated=0
deliberateSpawns=0
```

Zusätzlich dürfen im relevanten Laufzeitfenster keine Lua-, Scheduler-, MOOSE- oder Tarinkot-G7-Fehler auftreten.

## 11. FAIL- und INVALID-Kriterien

`INVALID`:

- Tarinkot-Client während des Tests besetzt;
- Bundle doppelt geladen;
- falscher oder nicht eindeutig zuordenbarer Teststand.

`FAIL`:

- Objekt-, Template-, Static-, Airbase-, Warehouse- oder Parkingvertrag verletzt;
- SQUADRON-/Asset-/Payloadanzahl abweichend;
- AIRWING nicht `Running`;
- Mission-, Transport- oder Warehouse-Request-Queue nicht leer;
- gespawnte OPSGROUP vorhanden;
- Vertical-, Safe-Parking- oder Cold-Takeoff-Policy nicht gesetzt;
- relevanter Lua-/MOOSE-Fehler.

## 12. Gate-Wirkung

Ein vollständiger PASS setzt:

```yaml
G7_airwing_squadron_payload: PASS_DCS
G8_direct_dispatch_vertical_departure: AUTHORIZED
G9_commander: BLOCKED_BY_G8
G10_lifecycle: NOT_STARTED
```

Ein FAIL hält G8 gesperrt. Die Fehlerisolierung erfolgt zunächst aus dem kombinierten Log; ein weiterer DCS-Lauf wird nur für den kleinstmöglichen betroffenen Teilbereich erstellt.
