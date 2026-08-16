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

Datengenese:

- Bagram: historisch gemessene Infrastruktur-/Throughput-Anker; strategischer Bestand bleibt OMW-Designwert.
- Kandahar Heli / Mustang Ramp: historisch dokumentierte Ausgabegröße und 50,000-gal-Bladder-Typ; strategischer Bestand bleibt OMW-Designwert.
- Kandahar Main, Jalalabad, Salerno, Tarinkot und Shindand: tägliche Sizing-Werte beziehungsweise Reichweiten sind prozedurale OMW-Interpolationen und keine historischen Messdaten.
- Historische Kapazitäten werden als Sizing-Evidence dokumentiert, aber nicht als neue CampaignState-Eigenschaft eingeführt.

Die maschinenlesbare Quelle ist:

```text
scripts/logistics/OMW_AirOpsInitialJP8Stock.lua
```

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

Der Builder schreibt keinen aktuellen Build-Zeitstempel. Er prüft erforderliche Source-Dateien und Marker, verbotene Acceptance-/Native-Marker, Scheduler-Freiheit sowie die gepinnte MOOSE-Provenienz und gibt SHA-256 für jede Source-Datei sowie das Bundle aus. Zwei Builds desselben Commits müssen denselben Bundle-SHA-256 ergeben.

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

## 10. Verifikationsgrenze

Die erste Production-Base-Version scheiterte im realen Smoke-Test fail-closed, weil `KANDAHAR_MAIN/FUEL_JP8` im produktiven CampaignState fehlte. `OMW_WAREHOUSE_READY` blieb korrekt `0`; AAR und AIR-OPS starteten nicht. Dieser Befund ist keine erfolgreiche DCS-Validation.

Nach Einbindung von `v0.3-RELEASE` ist erneut erforderlich:

```text
Production-Builder erfolgreich
zwei Builds desselben Commits mit identischem SHA-256
keine Acceptance-/Testmarker im Bundle
realer kleiner DCS-Smoke-Test:
  alle sieben JP-8-Mirrors verifiziert
  Kandahar AVGAS verifiziert
  Warehouse READY
  -> AAR Production Base
  -> AIR-OPS Foundations
  -> keine Lua-/Bootstrap-Fehler
```

Bis zu diesem dokumentierten Lauf gilt:

```text
validated_in_dcs: false
```

Eine `.miz` wird durch ChatGPT oder den Builder nicht automatisch verändert.
