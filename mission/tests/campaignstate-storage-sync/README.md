---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SYNC-INDEX
status: PLANNED
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
validated_in_dcs: false
base_branch: agent/storage-fuel-adapter-foundation
base_commit: e79ed1ae7bbe62160b3a4dce83e1dd25028ce0fb
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# CampaignState → STORAGE Sync Foundation Test

## 1. Ausgangslage

Die Repository-Prüfung hat keinen produktiven CampaignState-Lua-Store ergeben. `CampaignState` ist bislang verbindlich als strategische Domäne dokumentiert, während unter `scripts/logistics/` nur der bereits akzeptierte `OMW_StorageFuelAdapter.lua` existiert.

Dieser Folgebranch baut deshalb auf der akzeptierten STORAGE-Fuel-Adapter-Foundation auf und ergänzt nur den kleinsten notwendigen strategischen Read-Pfad sowie einen expliziten one-way Sync-Koordinator.

## 2. MOOSE-First-Grenze

MOOSE bleibt für die operative DCS-Warehouse-Abbildung zuständig. Der strategische CampaignState ist projektspezifische Kampagnendomäne und darf gemäß Governance nicht durch MOOSE `WAREHOUSE` oder `STORAGE` ersetzt werden.

Der neue Code implementiert deshalb keine Warehouse-Funktion parallel zu MOOSE. Er liefert lediglich einen autoritativen Snapshot an den bereits validierten `STORAGE`-Adapter.

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

Der Fuel-Snapshot entspricht exakt dem bereits akzeptierten Adaptervertrag:

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
```

Kandahar muss wie in der akzeptierten Parent-Baseline mit begrenzten Flüssigkeiten betrieben werden.

## 6. Runtime-Test

Der Test liest zunächst die realen Ausgangswerte über den akzeptierten STORAGE-Adapter. Daraus wird ein autoritativer CampaignState-Testzustand mit `+1000 kg` JP-8 und `+500 kg` AVGAS aufgebaut.

Danach muss gelten:

```text
CAMPAIGNSTATE_SNAPSHOT_PASS
SYNC_PLAN_PASS changes=2
SYNC_WRITE_READBACK_PASS
SYNC_IDEMPOTENCY_PASS
NO_REVERSE_MUTATION_PASS
RESTORE_PASS
RESULT testId=CAMPAIGNSTATE-STORAGE-SYNC-FOUNDATION-1 status=PASS
```

Der Restore erfolgt ausschließlich zur Testbereinigung über den bereits akzeptierten STORAGE-Adapter.

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

Bis zum dokumentierten DCS-Lauf gilt:

```text
runtime_status: NOT_RUN
validated_in_dcs: false
```
