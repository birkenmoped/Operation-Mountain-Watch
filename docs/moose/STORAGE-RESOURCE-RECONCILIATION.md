---
document_id: OMW-MOOSE-STORAGE-RESOURCE-RECONCILIATION
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE boundary for read-only AirOps STORAGE resource reconciliation
  - mapping-scope distinction between complete strategic resources and payload variants
  - prohibition of continuous active-operation STORAGE overwrite
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-resource-integration-final
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE STORAGE Resource Reconciliation

## 1. Zweck

Diese Notiz dokumentiert den kleinsten MOOSE-First-Pfad für die verbleibende CampaignState-/STORAGE-Kopplung nach den bereits abgeschlossenen Fuel-, Weapon-, Return-, Client-Rearm-, Client-Refuel- und Physical-Loss-Tests.

Sie führt **keinen neuen Warehouse-Lifecycle** ein. Der operative Aircraft-Lifecycle bleibt bei AIRWING/WAREHOUSE/FLIGHTGROUP; der physische Fuel-/Item-Bestand bleibt im DCS-Warehouse, gelesen über MOOSE `STORAGE`.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Verwendete öffentliche MOOSE-Pfade

Source-reviewed im tatsächlich verwendeten `Moose.lua`:

```text
STORAGE:FindByName(AirbaseName)
AIRBASE:FindByName(AirbaseName)
AIRBASE:GetStorage()
STORAGE:GetLiquidAmount(Type)
STORAGE:GetItemAmount(Name)
STORAGE.Liquid.JETFUEL
STORAGE.Liquid.GASOLINE
SCHEDULER:New(...)
```

Für die übergeordnete Lifecycle-Einordnung bereits source-reviewed beziehungsweise praktisch belegt:

```text
AIRWING:onafterFlightOnMission(...)
WAREHOUSE:onafterAssetSpawned(...)
WAREHOUSE:onafterAssetDead(...)
WAREHOUSE:onafterArrived(...)
WAREHOUSE:onafterDelivered(...)
FLIGHTGROUP:onafterArrived(...)
OPSGROUP:ReturnToLegion(...)
```

Die neue Observer-Komponente ruft keinen eigenen `ReturnToLegion()`-Pfad auf und registriert keinen parallelen Aircraft-Lifecycle.

## 4. MOOSE-Lücke und kleinste Ergänzung

MOOSE `STORAGE` stellt den DCS-Warehouse-Zugriff bereit, aber kein OMW-spezifisches strategisches Mapping zwischen CampaignState Resource IDs und DCS-Itemfamilien. Ebenso besitzt `STORAGE` kein CampaignState-Reconciliation-FSM.

Die kleinste OMW-Ergänzung besteht deshalb aus:

```text
OMW_AirOpsResourceManifest
-> mapping/classification metadata only

OMW_StorageResourceObserver
-> public STORAGE reads only
-> resource/variant snapshots
-> read-only CampaignState comparison
-> pure before/after delta calculation
```

Nicht Teil der Ergänzung:

```text
STORAGE writes
CampaignState writes
scheduler loop
spawn/despawn
return controller
client rearm/refuel implementation
native DCS warehouse access
shadow resource ledger
```

## 5. Mapping-Scope

Vollständig resource-reconciliation-fähig für den dokumentierten aktuellen AirOps-Scope:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL  -> kg
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE -> kg
```

Payload-variantenspezifisch DCS-validiert, aber nicht als vollständiger Familienbestand zu interpretieren:

```text
AMMUNITION_HELLFIRE
-> weapons.missiles.AGM_114K
-> tested AH-64D payload variant only

AMMUNITION_ROCKETS_70MM
-> weapons.nurs.HYDRA_70_M151
-> tested AH-64D payload variant only
```

Kein direkter Round-Mirror:

```text
AMMUNITION_30MM_M230
AMMUNITION_30MM_GAU8
AMMUNITION_50CAL_M3P
F-16C/F-15E M61
CH-47F M60D
UH-60 door guns
```

Technisch beobachtet, aber nicht strategisch gemappt:

```text
IAFS_ComboPak_100 -> TECHNICAL_NON_STRATEGIC
F-16 370-gal tank -> observed native return, no owner-approved strategic Resource ID
```

## 6. Reconciliation-Grenze

Der frühere sieben-Knoten-Fuel-Mirror zeigte praktisch, dass ein aktiver DCS-Verbrauch denselben Warehouse-Bestand innerhalb eines synchronen `SetLiquid()`-Write/Readback-Fensters verändern kann. Deshalb gilt für aktive Operationen:

```text
no continuous CampaignState -> STORAGE SetLiquid/SetItem overwrite
```

Der Observer verwendet stattdessen:

```text
known lifecycle/checkpoint
-> read current STORAGE state
-> compare only complete strategic mappings
-> MATCH or DRIFT
-> do not mutate CampaignState
-> do not mutate STORAGE
```

Ein späterer strategischer Settlement-Aufruf bleibt CampaignState-Domänenlogik. Ein unerklärter STORAGE-Drift darf CampaignState nicht automatisch überschreiben.

## 7. Implementierung

```text
scripts/logistics/OMW_AirOpsResourceManifest.lua
scripts/logistics/OMW_StorageResourceObserver.lua
```

Observer-API:

```text
StorageResourceObserver.New(manifest)
Observer:ReadNode(nodeId, airbaseName)
Observer:CompareNode(campaignStateStore, nodeId, airbaseName, tolerances)
Observer:MeasureDelta(beforeSnapshot, afterSnapshot)
```

`CompareNode()` berücksichtigt nur Manifest-Einträge mit `reconciliationEligible=true`. Variantenspezifische Waffenitems werden weiterhin in `ReadNode().variants` sichtbar, aber nicht stillschweigend dem vollständigen strategischen Familienbestand gleichgesetzt.

## 8. DCS-Acceptance

Geplanter Test:

```text
STORAGE-RESOURCE-INTEGRATION-FINAL-1
```

Er prüft read-only:

```text
Bagram JETFUEL/GASOLINE
Shindand Heliport JETFUEL/GASOLINE
AGM-114K / M151 / IAFS variant visibility
baseline MATCH
intentional isolated CampaignState mismatch -> DRIFT
no reverse overwrite
pure delta measurement
```

Der Test führt keine neue physische Verbrauchs-, Rearm-, Refuel-, Return- oder Loss-Sequenz aus. Diese Grundlagen werden aus ihren jeweiligen dokumentierten Acceptance-Ständen geerbt.

Bis zum DCS-Lauf bleibt der neue Observer-Scope `PLANNED` beziehungsweise source-reviewed; er ist nicht `VALIDATED`.
