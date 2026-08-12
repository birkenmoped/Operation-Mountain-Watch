---
document_id: OMW-TEST-STORAGE-RESOURCE-INTEGRATION-FINAL
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - final read-only STORAGE resource reconciliation gate
  - AirOps strategic-resource mapping consolidation
  - CampaignState drift detection without reverse overwrite
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-resource-integration-final
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-client-fuel-exchange
base_commit: 6a9332aae2334efbcace4226147eb6d0a83dd5a6
base_status: DRAFT_WITH_ACCEPTED_CHILD_SCOPES
merged_to_main: false
inherited_risk:
  - stacked parent branches remain unmerged
---

# Finaler STORAGE-Resource-Integration-Gate

## 1. Ziel

Dieser Gate testet **nicht erneut** die bereits bestätigten physischen DCS-Warehouse-Lifecycles. Er prüft ausschließlich die neu ergänzte, kleinste MOOSE-First-Integrationsschicht:

```text
AirOps Resource Manifest
-> public MOOSE STORAGE read paths
-> read-only resource/variant observation
-> CampaignState comparison
-> drift detection without reverse overwrite
```

Der Gate führt keine `STORAGE`-Mutation und keine CampaignState-Mutation durch.

## 2. Bereits geerbte Evidenz – kein Retest

Für die jeweiligen exakt dokumentierten Acceptance-Stände gelten bereits als praktisch belegt:

```text
limited STORAGE liquids read/write
seven AirOps fuel nodes in a quiet sync window
AI materialization debit
AI normal return/recredit for documented store classes
physical total loss without aircraft/fuel/store recredit
F-16 client weapon rearm/exchange
F-16 client fuel exchange 1:1 kg
F-16 370-gal tank native return
AH-64D M151 / AGM-114K debit and unused-store return
AH-64D IAFS debit without native recredit
AH-64D M230 expenditure observation
F-16C M61 expenditure observation
F-15E M61 expenditure observation
OH-58D M3P documented behavior
CH-47F M60D container debit/recredit without round conversion
Kandahar ME parking -> MOOSE TerminalID 376/376
```

Der A-10/GAU-8-Gate ist für die aktuelle Warehouse-Ressourcenfrage durch Owner-Entscheidung geschlossen. Die fehlende MOOSE-`Arrived`-/Despawn-Sequenz bleibt als separate Lifecycle-Anomalie dokumentiert und wird hier nicht erneut getestet.

## 3. Konsolidiertes Resource Mapping

### 3.1 Vollständig reconciliation-fähige Ressourcen

| CampaignState Resource | MOOSE STORAGE | Einheit | Klasse | Status |
|---|---|---:|---|---|
| `FUEL_JP8` | `STORAGE.Liquid.JETFUEL` | kg | `CONSUMABLE_STRATEGIC` | vollständiger Resource-Mirror für den dokumentierten AirOps-Fuel-Scope |
| `FUEL_AVGAS` | `STORAGE.Liquid.GASOLINE` | kg | `CONSUMABLE_STRATEGIC` | vollständiger Resource-Mirror für den dokumentierten AirOps-Fuel-Scope |

### 3.2 DCS-validierte Varianten, aber kein vollständiger Familien-Mirror

| Strategic Resource | DCS/MOOSE Item | Klasse | Grenze |
|---|---|---|---|
| `AMMUNITION_HELLFIRE` | `weapons.missiles.AGM_114K` | `RETURNABLE_STRATEGIC` | nur getestete AH-64D-Payloadvariante; kein generischer Hellfire-Familien-Mirror |
| `AMMUNITION_ROCKETS_70MM` | `weapons.nurs.HYDRA_70_M151` | `RETURNABLE_STRATEGIC` | nur getestete AH-64D-Payloadvariante; kein generischer 70-mm-Familien-Mirror |

Diese beiden Varianten werden read-only beobachtet, aber nicht automatisch mit dem gesamten strategischen Familienbestand gleichgesetzt.

### 3.3 Kein direkter Round-Mirror

```text
AMMUNITION_30MM_M230 -> TELEMETRY_ONLY
AMMUNITION_30MM_GAU8 -> TELEMETRY_ONLY
AMMUNITION_50CAL_M3P -> STORE_WITHOUT_ROUND_CONVERSION
F-16C M61            -> TELEMETRY_ONLY, kein freigegebener Strategic Resource ID
F-15E M61            -> TELEMETRY_ONLY, kein freigegebener Strategic Resource ID
CH-47F M60D          -> STORE_WITHOUT_ROUND_CONVERSION, kein freigegebener Strategic Resource ID
UH-60 door guns      -> TELEMETRY_ONLY; dokumentierter Test lieferte GetAmmoTot=0
```

Für diese Pfade werden keine Shell-/Container-zu-Runden-Faktoren erfunden.

### 3.4 Technische und noch nicht strategisch benannte Items

```text
weapons.droptanks.{IAFS_ComboPak_100}
-> TECHNICAL_NON_STRATEGIC
-> kein CampaignState Resource ID

weapons.droptanks.fuel_tank_370gal
-> native Debit-/Return-Semantik beobachtet
-> noch kein Owner-approved Strategic Resource ID
-> MAPPING_OBSERVED_NO_STRATEGIC_ID
```

## 4. MOOSE-First

Der neue Adapter verwendet ausschließlich vorhandene öffentliche MOOSE-Pfade:

```text
STORAGE:FindByName()
AIRBASE:FindByName() / AIRBASE:GetStorage() fallback
STORAGE:GetLiquidAmount()
STORAGE:GetItemAmount()
SCHEDULER:New() for one bounded test start delay only
```

Es werden ausdrücklich nicht implementiert:

```text
custom spawn controller
custom normal-return controller
custom client rearm
custom client refuel
custom fuel-consumption simulator
custom weapon-return simulator
continuous STORAGE overwrite
native DCS fallback
universal shadow transaction ledger
```

## 5. Neue Runtime-Komponenten

```text
scripts/logistics/OMW_AirOpsResourceManifest.lua
scripts/logistics/OMW_StorageResourceObserver.lua
```

`OMW_AirOpsResourceManifest` enthält ausschließlich bestätigte Resource IDs, technische Mappings, Klassifikation und Scope-Grenzen.

`OMW_StorageResourceObserver`:

```text
ReadNode()
-> read-only STORAGE snapshot

CompareNode()
-> compare only complete reconciliation-eligible mappings
-> MATCH / DRIFT / UNAVAILABLE
-> no CampaignState mutation

MeasureDelta()
-> pure before/after delta calculation
-> no physical mutation
```

## 6. Reconciliation-Regel V1

Für die Foundation gilt:

```text
CampaignState remains strategic authority.
STORAGE remains the operational DCS warehouse mirror.

quiet bootstrap / explicit reset:
  CampaignState -> existing STORAGE mirror write path may be used

active operations:
  no continuous SetLiquid/SetItem overwrite

lifecycle/checkpoint observation:
  read STORAGE
  compare only mappings that are complete for the strategic resource
  MATCH -> no action
  DRIFT -> report reconciliation fault / require recognized lifecycle settlement
  never silently overwrite CampaignState from unexplained STORAGE drift
```

Variant-only weapon mappings bleiben Telemetrie beziehungsweise korrelierbare Einzelvarianten und werden nicht als vollständiger Strategic-Family-Bestand ausgegeben.

## 7. Testablauf

Der DCS-Gate benötigt keine Spieleraktion und keine neue physische Verbrauchssequenz. Zehn Sekunden nach Start werden Bagram und Shindand Heliport read-only geprüft.

Erwartete Marker:

```text
OBSERVED node=Bagram ...
OBSERVED node=ShindandHeliport ...
BASELINE_RECONCILIATION_PASS
DRIFT_GUARD_PASS
DELTA_MEASUREMENT_PASS
MAPPING_SCOPE_PASS
RESULT status=PASS
```

Der Drift-Test erzeugt **keinen DCS/STORAGE-Drift**. Er konstruiert absichtlich einen abweichenden isolierten CampaignState-Testbestand und bestätigt, dass der Observer die Differenz erkennt, ohne CampaignState oder STORAGE zu verändern.

## 8. Build

```text
Source:
mission/tests/storage-resource-integration-final/src/01-storage-resource-integration-final.lua

Builder:
tools/build-storage-resource-integration-final.ps1

Bundle:
mission/tests/storage-resource-integration-final/dist/OMW_Storage_Resource_Integration_Final.lua

BuilderVersion:
STORAGE-RESOURCE-INTEGRATION-FINAL-1
```

Der Builder verbietet mutierende STORAGE-Pfade, Native-DCS-Fallbacks, direkten `_DATABASE`-Zugriff, eigenen ReturnToLegion-Aufruf und direkten Zugriff des Harness auf CampaignState-Interna.

## 9. Acceptance-Grenze

Vor dem DCS-Lauf ist dieser Gate `PLANNED`. Ein PASS bestätigt ausschließlich:

```text
manifest load
public MOOSE STORAGE read paths used by the observer
complete fuel-resource comparison at Bagram and Shindand Heliport
variant-scoped weapon telemetry
read-only drift detection
pure delta measurement
absence of observer-driven CampaignState/STORAGE mutation
```

Er wiederholt oder erweitert nicht automatisch die bereits bestehenden physischen Lifecycle-Acceptances und validiert keine Persistenz, kein Restart-Reconciliation und kein Multiplayer-Fehlerverhalten.
