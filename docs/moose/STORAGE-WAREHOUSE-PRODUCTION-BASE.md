---
document_id: OMW-AIROPS-WAREHOUSE-PRODUCTION-BASE
status: PLANNED
document_class: RUNTIME_INTEGRATION_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - permanent AirOps Warehouse production runtime composition
  - Warehouse production-versus-acceptance boundary
  - OMW_WAREHOUSE_READY production gate
  - single CampaignState context creation before AAR startup
  - productive JP-8 v0.3-RELEASE composition for Issue #105
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/warehouse-production-base
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# STORAGE / Warehouse Production Base

## 1. Zweck

Die Warehouse Production Base verpackt den akzeptierten AirOps-Warehouse-/STORAGE-Stack als dauerhaften, testfreien Produktionsstart. Für Issue #105 ergänzt sie die vom Projektinhaber am 16.08.2026 freigegebene produktive JP-8-Baseline `v0.3-RELEASE`. CampaignState bleibt alleinige strategische Ressourcenhoheit.

Produktiver Einstieg:

```text
mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
```

Builder:

```text
tools/build-air-ops-warehouse-production-base.ps1
```

Der vollständige fachliche JP-8-Entscheidungs-, Zahlen- und Quellenstand liegt in:

- [`AirOps JP-8 Baseline v0.3-RELEASE`](../air-ops-jp8-baseline-v03.md)

Der historische Acceptance-Builder bleibt ausschließlich Testinfrastruktur:

```text
tools/build-air-ops-warehouse-bootstrap.ps1
-> mission/tests/air-ops-warehouse-bootstrap/dist/OMW_AirOps_Warehouse_Bootstrap.lua
```

## 2. Produktionskomposition

Quellkomponenten:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AirOpsResourceManifest.lua
scripts/logistics/OMW_AirOpsInitialStock.lua
scripts/logistics/OMW_AirOpsInitialJP8Stock.lua
scripts/logistics/OMW_AirOpsInitialFuelSupplement.lua
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/logistics/OMW_AirOpsStorageInitializer.lua
scripts/logistics/OMW_AirOpsTechnicalAvailability.lua
scripts/logistics/OMW_AirOpsTechnicalAvailabilityInitializer.lua
scripts/logistics/OMW_StorageFuelAdapter.lua
scripts/logistics/OMW_CampaignStateStorageSync.lua
scripts/logistics/OMW_AirOpsWarehouseBootstrap.lua
scripts/logistics/OMW_AirOpsWarehouseProduction.lua
```

Produktiver Startpfad:

```text
Moose.lua
-> OMW_AirOps_Warehouse_Base.lua
-> OMW_WAREHOUSE_READY == 1
-> OMW_AAR_Base.lua
-> AIR-OPS Foundations
```

Zeitliche Staffelung im Mission Editor ist nur organisatorisch. Das verbindliche Freigabekriterium bleibt `OMW_WAREHOUSE_READY == 1`.

## 3. CampaignState-Kontext

Die Base verwendet genau einen `OMW.AirOps.CampaignContext`.

```text
wenn OMW.AirOps.CampaignContext bereits existiert
-> vorhandenen NEW-/RESTORE-Kontext wiederverwenden

wenn kein Context existiert
-> genau einen NEW-Context erzeugen aus:
   OMW_AirOpsInitialStock
   + OMW_AirOpsInitialJP8Stock
   + OMW_AirOpsInitialFuelSupplement
   + OMW_AARStrategicStock
-> als OMW.AirOps.CampaignContext veröffentlichen
```

`OMW_AARStrategicStock` bleibt CampaignState-only. Die Off-map-Knoten werden nicht an DCS-Airbase-, STORAGE-, WAREHOUSE- oder AIRWING-APIs übergeben.

## 4. JP-8 v0.3-RELEASE

Verbindliche Owner-Entscheidung für Issue #105:

| Node | Initial/Target kg | Reorder kg | Critical kg | Supply Parent | Designklasse |
|---|---:|---:|---:|---|---|
| BAGRAM | 5,000,000 | 2,140,000 | 750,000 | OFF_MAP | PROJECT_DESIGN_VALUE_CAPACITY_THROUGHPUT_CONSTRAINED |
| KANDAHAR_MAIN | 3,500,000 | 1,500,000 | 525,000 | OFF_MAP | PROJECT_DESIGN_VALUE_HUB_RELATION_INTERPOLATED |
| JALALABAD | 575,000 | 320,000 | 120,000 | BAGRAM | PROJECT_DESIGN_VALUE_CAPACITY_CONSTRAINED |
| KANDAHAR_HELI | 180,000 | 90,000 | 45,000 | KANDAHAR_MAIN | PROJECT_DESIGN_VALUE_THROUGHPUT_CONSTRAINED |
| SALERNO | 1,200,000 | 640,000 | 240,000 | KANDAHAR_MAIN | PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED |
| TARINKOT | 950,000 | 540,000 | 202,500 | KANDAHAR_MAIN | PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED |
| SHINDAND_HELI | 450,000 | 195,000 | 65,000 | KANDAHAR_MAIN | PROJECT_DESIGN_VALUE_OPERATIONAL_INTERPOLATED |

Gesamt-Initial-/Targetbestand:

```text
11,855,000 kg FUEL_JP8
```

Die maschinenlesbare Quelle ist:

```text
scripts/logistics/OMW_AirOpsInitialJP8Stock.lua
```

Historische Kapazitäten, Throughput-Anker, DoS-Herleitung, verworfene Werte und Primärquellen werden ausschließlich quellenkritisch im JP-8-Baseline-Dokument geführt. Physische `storageCapacityKg` oder `issueCapacityKgPerDay` werden nicht als neue CampaignState-Eigenschaften eingeführt.

## 5. Warehouse-/STORAGE-Vertrag

Der zentrale Koordinator bleibt:

```text
OMW_AirOpsWarehouseBootstrap
```

Einmaliger Ablauf:

```text
CampaignState
-> strategische Item-Preflight/Apply/Readback
-> Fuel-Preflight/Apply/Readback
-> Technical-Availability-Preflight/Apply/Readback
-> READY
```

Fuel-Mappings:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
```

Produktiver Fuel-Scope:

```text
BAGRAM          FUEL_JP8
JALALABAD       FUEL_JP8
KANDAHAR_MAIN   FUEL_JP8 + FUEL_AVGAS
KANDAHAR_HELI   FUEL_JP8
SALERNO         FUEL_JP8
SHINDAND_HELI   FUEL_JP8
TARINKOT        FUEL_JP8
```

`OMW_CampaignStateStorageSync` unterstützt dafür eine node-spezifische Auswahl vorhandener CampaignState-Fuel-Ressourcen. Andere Nodes erhalten keinen künstlichen AVGAS-Nullbestand. Der Adapter liest ausschließlich CampaignState und führt kein STORAGE -> CampaignState Reverse-Overwrite aus.

Die `0.5 kg`-Readback-Toleranz von `OMW_StorageFuelAdapter` bleibt unverändert.

## 6. Fail-closed READY-Gate

`OMW_AirOpsWarehouseProduction.Start(...)` setzt zunächst:

```text
OMW_WAREHOUSE_READY = 0
```

Nur nach `status=READY` und `airOpsStartAllowed=true` wird gesetzt und zurückgelesen:

```text
OMW_WAREHOUSE_READY = 1
```

Bei Fehlern wird das Flag auf `0` gehalten beziehungsweise zurückgesetzt. Es existiert kein Production-Scheduler.

## 7. Production-vs-Acceptance-Grenze

Nicht Bestandteil der Production Base:

```text
Acceptance harness
OMW-TEST Marker
JP8_PRESERVATION_FIXTURE
TEST_PRESERVE_EXISTING_CLOSED_JP8
NEW_PREFLIGHT_PASS / NEW_APPLY_PASS / RESTORE_PASS
AIR_OPS_START_GATE_PASS
RESULT status=PASS Assertions
Acceptance Scheduler
künstliche Preservation-Hooks
aktuelle Buildzeit im Bundle
```

Der frühere `100000 kg`-JP-8-Testwert wird nicht produktiv übernommen.

## 8. Deterministischer Builder

BuilderVersion:

```text
OMW-AIROPS-WAREHOUSE-BASE-2
```

Owner-run Buildnachweis für Branch-Head `635cd87d8946dad0fc0e6ad3b89bb1fbc7b86c22`:

```text
InitialJP8StockSHA256: a49465ab24fed33df975651f8ba79735449228fde6064d74e87c541f31018dca
BundleSHA256 build 1: 15a87820de91cb220516fd5aded343c76ffbc09263559e730f65e0161eeeb42a
BundleSHA256 build 2: 15a87820de91cb220516fd5aded343c76ffbc09263559e730f65e0161eeeb42a
Deterministic: true
```

Der Builder schreibt keinen aktuellen Build-Zeitstempel. Er prüft erforderliche Source-Dateien und Marker, verbotene Acceptance-/Native-Marker, Scheduler-Freiheit sowie die gepinnte MOOSE-Provenienz und gibt SHA-256 für jede Source-Datei sowie das Bundle aus.

## 9. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Verwendete bereits geprüfte öffentliche Pfade umfassen weiterhin:

```text
STORAGE:FindByName()
STORAGE:GetItemAmount()
STORAGE:SetItem()
STORAGE:IsLimitedWeapons()
STORAGE:GetLiquidAmount()
STORAGE:SetLiquid()
AIRBASE:FindByName()
AIRBASE:GetStorage()
USERFLAG:New()
USERFLAG:Set()
USERFLAG:Get()
```

Die JP-8-Datenbaseline und node-spezifische Fuel-Auswahl sind OMW-Domain-/Adapterlogik. Es wird keine MOOSE-Funktion parallel neu implementiert.

## 10. DCS-Smoke 16.08.2026

Das vom Projektinhaber gelieferte `dcs.log` enthält zwei unterschiedliche Warehouse-Läufe. Der frühere Lauf enthält den bereits bekannten Altstandfehler:

```text
START_FAILED ... fuel resource unavailable nodeId=KANDAHAR_MAIN resourceId=FUEL_JP8
```

Der spätere Lauf zeigt dagegen für den neuen v0.3-Pfad:

```text
AirOpsStorageInitializer PLAN blockers=0
AirOpsStorageInitializer APPLY verified=true

StorageFuelAdapter APPLY verified=true:
  BAGRAM          entries=1
  JALALABAD       entries=1
  KANDAHAR_HELI   entries=1
  KANDAHAR_MAIN   entries=2
  SALERNO         entries=1
  SHINDAND_HELI   entries=1
  TARINKOT        entries=1

AirOpsTechnicalAvailabilityInitializer APPLY verified=true
AirOpsWarehouseProduction READY mode=NEW campaignContextCreated=true
campaignStateAuthority=true reverseOverwrite=false scheduler=false readyFlag=1
```

Nach READY wurde der AAR-Controller geladen und danach liefen die Bagram-, Kandahar-, Jalalabad-, Salerno-, Tarinkot- und Shindand-Foundations an. Für den späteren Lauf ist kein OMW-Lua-/Warehouse-/Fuel-Bootstrapfehler im gelieferten Log erkennbar.

Die Runtime-Funktion ist damit positiv beobachtet. Die formale Acceptance-Provenienz bleibt jedoch noch offen, weil das `debrief.log` den ausgeführten Missionspfad als `OMW_Template_v11_AirOps_rdy.miz` ausweist, während das separat read-only geprüfte aktuelle Upload-Artefakt `OMW_Template_v11_AirOps_rdy(2).miz` mit SHA-256 `e10cf353b09944c872a15cd6d1253722caea3e46ec9d754fb698234b60e8f71c` vorliegt. Bis diese Identität explizit bestätigt ist, bleibt `validated_in_dcs: false` und der PR darf nicht als vollständig akzeptiert markiert werden.

## 11. Merge-Grenze

Vor `Ready for Review`/Merge müssen weiterhin erfüllt sein:

```text
1. Dokumentationsstand und Links auf dem finalen Branch-Head prüfen.
2. Documentation validator bewerten; bestehende main-fremde AAR-Fehler nicht Issue #105 zurechnen.
3. Diff gegen main vollständig prüfen.
4. Exakten ausgeführten MIZ-Hash/Artefaktbezug des positiven Smoke-Laufs bestätigen.
5. Erst danach validated_in_dcs / Acceptance-Provenienz finalisieren.
```

Eine `.miz` wird durch ChatGPT oder den Builder nicht automatisch verändert.
