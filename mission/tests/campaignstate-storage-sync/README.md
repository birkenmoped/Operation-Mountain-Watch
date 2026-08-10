---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SYNC-INDEX
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState to STORAGE fuel sync foundation test scope
  - one-way synchronization boundary
  - builder and source paths for the sync test bundle
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

# CampaignState → STORAGE Sync Foundation Test

## 1. Ausgangslage

Die Repository-Prüfung hat keinen produktiven CampaignState-Lua-Store ergeben. `CampaignState` war verbindlich als strategische Domäne dokumentiert, während unter `scripts/logistics/` der bereits akzeptierte `OMW_StorageFuelAdapter.lua` existierte.

Dieser Folgebranch baut auf der akzeptierten STORAGE-Fuel-Adapter-Foundation auf und ergänzt nur den kleinsten notwendigen strategischen Read-Pfad sowie einen expliziten one-way Sync-Koordinator.

## 2. MOOSE-First-Grenze

MOOSE bleibt für die operative DCS-Warehouse-Abbildung zuständig. Der strategische CampaignState ist projektspezifische Kampagnendomäne und darf gemäß Governance nicht durch MOOSE `WAREHOUSE` oder `STORAGE` ersetzt werden.

Der neue Code implementiert deshalb keine Warehouse-Funktion parallel zu MOOSE. Er liefert lediglich einen autoritativen Snapshot an den bereits DCS-validierten `STORAGE`-Adapter.

## 3. Source-Pfade

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_StorageFuelAdapter.lua
scripts/logistics/OMW_CampaignStateStorageSync.lua
mission/tests/campaignstate-storage-sync/src/01-campaignstate-storage-sync-foundation.lua
tools/build-campaignstate-storage-sync-foundation.ps1
mission/tests/campaignstate-storage-sync/dist/OMW_CampaignState_StorageSync_Foundation_Test.lua
```

## 4. Foundation-Vertrag

`OMW_CampaignState.lua` besitzt in dieser Foundation ausschließlich:

```text
CampaignState.New(initialState)
Store:GetResourceKg(nodeId, resourceId)
Store:GetFuelSnapshot(nodeId)
```

Der Fuel-Snapshot entspricht exakt dem akzeptierten Adaptervertrag:

```text
nodeId
airbaseName
resourcesKg.FUEL_JP8
resourcesKg.FUEL_AVGAS
```

Der Store besitzt absichtlich noch keine Runtime-Mutations-, Transaktions- oder Persistenzmethoden. Diese gehören in einen späteren eigenen CampaignState-Transaktionsvertrag.

`OMW_CampaignStateStorageSync.lua` besitzt ausschließlich:

```text
CampaignStateStorageSync.New(campaignStateStore, storageFuelAdapter)
Sync:PlanNode(nodeId)
Sync:ApplyNode(nodeId)
```

Synchronisationsrichtung:

```text
CampaignState -> StorageFuelAdapter -> MOOSE STORAGE / DCS warehouse
```

Es existiert kein Reverse-Overwrite von DCS/MOOSE nach CampaignState.

## 5. Testknoten

```text
nodeId: HUB_KANDAHAR
airbaseName: Kandahar
resources: FUEL_JP8, FUEL_AVGAS
canonical unit: kg
Unlimited Liquids: OFF
Mission Editor JETFUEL: 100 t
Mission Editor GASOLINE: 100 t
Runtime original JETFUEL: 100000 kg
Runtime original GASOLINE: 100000 kg
```

## 6. Akzeptierter Runtime-Test

```text
Test date: 2026-08-10
DCS: 2.9.28.26385 MT
Source/Builder commit: 94ce64365e5bd3836030cdfd8a3e5049b2b477a8
BuilderVersion: CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1
MIZ SHA-256: 1d8824b7849d01e6b63a9d51d819fb8da39cdc85eda2c7426b393cb78bf5cd91
Internal mission SHA-256: a0f6ef17c57d318ff095c81dd098264acb87ea826292ab81bf459d5486b98256
Embedded bundle SHA-256: 6f2678c853d27f273e73fab51eb39921e7d658d1b6cb3c13f857afdee4f2c4a7
DCS log SHA-256: 940f548b4ad0fc6a54f9e698e353792db63c412334de22332ccd7f7187cb61da
Debrief SHA-256: 82d61abb24f1209a0bcd57b14186de172c6b0e29ffd44caf4d300d2d6ac72c95
```

Der Test erzeugte einen autoritativen CampaignState-Testzustand mit `+1000 kg` JP-8 und `+500 kg` AVGAS gegenüber dem gelesenen Kandahar-Ausgangsbestand.

Bestätigte Runtime-Kette:

```text
CAMPAIGNSTATE_SNAPSHOT_PASS
SYNC_PLAN_PASS changes=2
SYNC_WRITE_READBACK_PASS
SYNC_IDEMPOTENCY_PASS
NO_REVERSE_MUTATION_PASS
RESTORE_PASS
RESULT testId=CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1 status=PASS
```

Der zweite identische Sync ergab `changeCount=0`. CampaignState blieb unverändert; der DCS-Warehouse-Ausgangsbestand wurde anschließend verifiziert wiederhergestellt. Der Debrief enthielt `graveyard = {}`.

## 7. Ausgeschlossen

```text
CampaignState runtime mutation
resource transaction lifecycle
persistence
automatic aircraft fuel debit
player/AI refuel accounting
AAR accounting
weapon synchronization
OPSTRANSPORT
CTLD
multiplayer reconciliation
mission restart reconciliation
scheduler-based continuous sync
reverse overwrite from DCS telemetry
```

Aktueller Status:

```text
runtime_status: PASS
status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
```

Die Acceptance gilt ausschließlich für die dokumentierte Branch-/Commit-/MIZ-/Bundle-/DCS-/MOOSE-Provenienz.