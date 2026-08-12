---
document_id: OMW-MOOSE-STORAGE-RESOURCE-RECONCILIATION
status: ACCEPTED_TECHNICAL_BASELINE
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
source_commit: 70ce4c7900927728b3e415a3929ee4b155fe71d0
validated_in_dcs: true
acceptance_branch: agent/storage-resource-integration-final
acceptance_commit: 70ce4c7900927728b3e415a3929ee4b155fe71d0
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: cf80b3edc4e500716e1704da2409df3123f43e78f75c343651b991360f5174ae
dcs_version: 2.9.28.26385 MT
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
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

## 8. DCS-Acceptance 2026-08-12

Test:

```text
STORAGE-RESOURCE-INTEGRATION-FINAL-1
Source/Builder commit: 70ce4c7900927728b3e415a3929ee4b155fe71d0
DCS: 2.9.28.26385 MT
Executed mission path from debrief: OMW_Template_v8_AirOps_rdy.miz
Owner-supplied artifact SHA-256: cf80b3edc4e500716e1704da2409df3123f43e78f75c343651b991360f5174ae
Internal mission SHA-256: acf4b381fc683e52dccd8addea70acaa01f67abb47f587d9ff2cc284cf8a2b4c
Embedded bundle SHA-256: d814c2f63b5d3959efe5cf1d4e7f36a22712afc2d3d2c716a536194d0c565a07
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: 7d04e32e50ef969fddbd8b911a5c030c1aca0f7c8483018d1be2ea5d675922d7
debrief.log SHA-256: 0e731c97c2f0a8cd4e9361ba85797285ebaedc0af91cb4acce4e11130681ab68
```

Beobachtete Marker:

```text
OBSERVED node=Bagram jp8Kg=538018.328 avgasKg=100000.000 f16TankCount=100.000
OBSERVED node=ShindandHeliport jp8Kg=100000.000 avgasKg=100000.000 agm114k=100.000 m151=100.000 iafs=100.000
BASELINE_RECONCILIATION_PASS nodes=2 resourcesPerNode=2
DRIFT_GUARD_PASS resourceId=FUEL_JP8 delta=-100.000 campaignStateMutation=false
DELTA_MEASUREMENT_PASS jp8Delta=-125 agm114kDelta=-4
MAPPING_SCOPE_PASS completeResource=FUEL_JP8,FUEL_AVGAS variantOnly=AGM_114K,HYDRA_70_M151 technicalNonStrategic=IAFS
RESULT status=PASS storageMutation=false campaignStateMutationByObserver=false schedulerBounded=true nativeDcs=false
```

Damit ist der Observer für genau diesen Scope DCS-validiert:

```text
STORAGE:FindByName / AIRBASE:GetStorage resolution path works for tested nodes
STORAGE:GetLiquidAmount works for JETFUEL/GASOLINE at tested nodes
STORAGE:GetItemAmount works for tested variant telemetry
baseline CampaignState comparison works
intentional isolated strategic mismatch is detected as DRIFT
observer does not reverse-overwrite CampaignState
observer does not mutate STORAGE
pure delta calculation works
```

Der Test führt keine neue physische Verbrauchs-, Rearm-, Refuel-, Return- oder Loss-Sequenz aus. Diese Grundlagen werden aus ihren jeweiligen dokumentierten Acceptance-Ständen geerbt.

Der nach `Dispatcher Stop` protokollierte `bhHook.lua`-Fehler stammt aus dem externen Saved-Games-Hook und ist kein Fehler des OMW-Testbundles.

Nicht validiert sind Persistenz, Restart-Reconciliation, Multiplayer-Fehlerverhalten oder zusätzliche Weapon-Familien-Mappings.
