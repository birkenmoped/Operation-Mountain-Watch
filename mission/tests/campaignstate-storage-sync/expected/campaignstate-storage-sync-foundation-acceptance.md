---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted CampaignState to STORAGE fuel sync foundation scope
  - one-way synchronization runtime markers
  - explicit non-acceptance boundaries of the sync foundation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-storage-sync-foundation
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/campaignstate-storage-sync-foundation
acceptance_commit: 94ce64365e5bd3836030cdfd8a3e5049b2b477a8
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 1d8824b7849d01e6b63a9d51d819fb8da39cdc85eda2c7426b393cb78bf5cd91
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
base_branch: agent/storage-fuel-adapter-foundation
base_commit: e79ed1ae7bbe62160b3a4dce83e1dd25028ce0fb
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# CampaignState → STORAGE Sync Foundation – Acceptance

## 1. Gate

```text
Gate: CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
Status: ACCEPTED_TECHNICAL_BASELINE
Test date: 2026-08-10
DCS: 2.9.28.26385 MT
Branch: agent/campaignstate-storage-sync-foundation
Source/Builder commit: 94ce64365e5bd3836030cdfd8a3e5049b2b477a8
BuilderVersion: CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
```

## 2. Provenienz

```text
Parent branch: agent/storage-fuel-adapter-foundation
Parent commit: e79ed1ae7bbe62160b3a4dce83e1dd25028ce0fb
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 1d8824b7849d01e6b63a9d51d819fb8da39cdc85eda2c7426b393cb78bf5cd91
Internal mission SHA-256: a0f6ef17c57d318ff095c81dd098264acb87ea826292ab81bf459d5486b98256
Embedded bundle SHA-256: 6f2678c853d27f273e73fab51eb39921e7d658d1b6cb3c13f857afdee4f2c4a7
DCS log SHA-256: 940f548b4ad0fc6a54f9e698e353792db63c412334de22332ccd7f7187cb61da
Debrief SHA-256: 82d61abb24f1209a0bcd57b14186de172c6b0e29ffd44caf4d300d2d6ac72c95
```

Kandahar-Testbedingung:

```text
Unlimited Liquids: OFF
Mission Editor JETFUEL: 100 t
Mission Editor GASOLINE: 100 t
Runtime original JETFUEL: 100000 kg
Runtime original GASOLINE: 100000 kg
```

Der Debrief enthielt `graveyard = {}`.

## 3. Builder-Grenze

Der lokal reproduzierte Builder bestätigte:

```text
Direction: CampaignState-to-STORAGE
FuelResources: FUEL_JP8,FUEL_AVGAS
CanonicalUnit: kg
CampaignStateRuntimeMutation: ABSENT
ReverseOverwrite: ABSENT
Persistence: ABSENT
Transport: ABSENT
AutomaticAircraftDebit: ABSENT
```

## 4. Runtime-Ergebnis

Der DCS-Rohlog enthält die vollständige erwartete Kette:

```text
BEGIN testId=CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
ORIGINAL jp8Kg=100000 avgasKg=100000
CAMPAIGNSTATE_SNAPSHOT_PASS
SYNC_PLAN_PASS changes=2
SYNC_WRITE_READBACK_PASS
SYNC_IDEMPOTENCY_PASS
NO_REVERSE_MUTATION_PASS
RESTORE_PASS
RESULT testId=CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1 status=PASS direction=CampaignState-to-STORAGE campaignStateMutation=false reverseOverwrite=false persistence=false automaticAircraftDebit=false
```

Praktisch bestätigt:

| Pfad | Ergebnis |
|---|---|
| CampaignState liefert getrennten Fuel-Snapshot für `HUB_KANDAHAR` | PASS |
| `FUEL_JP8` und `FUEL_AVGAS` werden getrennt in kg geführt | PASS |
| `Sync:PlanNode()` erkennt beide Abweichungen | PASS |
| `Sync:ApplyNode()` delegiert an den akzeptierten STORAGE-Adapter | PASS |
| STORAGE-Write und exakter Readback | PASS |
| zweite identische Synchronisation erzeugt `changeCount=0` | PASS |
| DCS-/STORAGE-Telemetrie mutiert CampaignState nicht | PASS |
| ursprüngliche DCS-Warehouse-Werte werden wiederhergestellt | PASS |
| Test-Harness Endmarker | PASS |
| Debrief graveyard | leer |

## 5. Acceptance-Grenze

Dieser PASS belegt ausschließlich den getesteten one-way Foundation-Pfad:

```text
CampaignState read-only fuel snapshot
-> OMW_CampaignStateStorageSync
-> OMW_StorageFuelAdapter
-> MOOSE STORAGE
-> DCS Kandahar warehouse
```

Er belegt ausdrücklich nicht:

```text
CampaignState runtime transaction semantics
CampaignState persistence
resource reservations
resource delivery accounting
automatic aircraft consumption
player or AI refuel accounting
AAR accounting
weapon/item synchronization
multiplayer reconciliation
mission restart reconciliation
continuous scheduler-based synchronization
OPSTRANSPORT or CTLD delivery
reverse reconciliation into CampaignState
```

`MOOSE WAREHOUSE`/`AIRWING`-Assetstock bleibt eine getrennte operative Domäne und wurde durch diesen Test nicht zur Fuel-Ressourcenhoheit.

## 6. Acceptance-Status

```text
status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
scope: exact branch/commit/MIZ/bundle/DCS/MOOSE provenance above
```

Jede Änderung an CampaignState-Transaktionen, Persistenz, Verbrauchsbuchung, Reconciliation oder Transport benötigt einen eigenen Vertrag und eine eigene DCS-Acceptance.