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

Die Warehouse Production Base verpackt den bereits akzeptierten AirOps-Warehouse-/STORAGE-Stack als dauerhaften, testfreien Produktionsstart. Sie ändert weder strategische Bestände noch die bestehende Warehouse-Architektur.

Produktiver Einstieg:

```text
mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
```

Erzeugt durch:

```text
tools/build-air-ops-warehouse-production-base.ps1
```

Der bisherige Builder

```text
tools/build-air-ops-warehouse-bootstrap.ps1
```

bleibt ausschließlich für die historische Acceptance-Fixture unter `mission/tests/air-ops-warehouse-bootstrap/` erhalten.

## 2. Produktionskomposition

Quellkomponenten:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AirOpsResourceManifest.lua
scripts/logistics/OMW_AirOpsInitialStock.lua
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

Der produktive Startpfad lautet:

```text
Moose.lua
-> OMW_AirOps_Warehouse_Base.lua
-> OMW_WAREHOUSE_READY == 1
-> OMW_AAR_Base.lua
-> AIR-OPS Foundations
```

Zeitliche Staffelung im Mission Editor ist nur organisatorisch. Das verbindliche Freigabekriterium für nachgelagerte Module ist `OMW_WAREHOUSE_READY == 1`.

## 3. CampaignState-Kontext

Die Base verwendet genau einen `OMW.AirOps.CampaignContext`.

```text
wenn OMW.AirOps.CampaignContext bereits existiert
-> vorhandenen NEW-/RESTORE-Kontext wiederverwenden

wenn kein Context existiert
-> genau einen NEW-Context erzeugen aus:
   OMW_AirOpsInitialStock
   + OMW_AirOpsInitialFuelSupplement
   + OMW_AARStrategicStock
-> als OMW.AirOps.CampaignContext veröffentlichen
```

`OMW_AARStrategicStock` wird hier nicht als Warehouse-Bestand interpretiert. Die beiden Off-map-Knoten bleiben reine CampaignState-Domänenressourcen und werden nicht an DCS-Airbase-, STORAGE-, WAREHOUSE- oder AIRWING-APIs übergeben. Die Aufnahme ist erforderlich, weil die Warehouse Base vor der AAR Base startet und die AAR Base denselben bereits vorhandenen CampaignState-Kontext wiederverwendet.

Damit bleibt der in `OMW-ARCH-CAMPAIGN-STATE` festgelegte Einzelstore-Vertrag erhalten; es entsteht kein separater AAR- oder Warehouse-Ressourcenstore.

## 4. Warehouse-/STORAGE-Vertrag

Der vorhandene zentrale Koordinator bleibt unverändert:

```text
OMW_AirOpsWarehouseBootstrap
```

Er führt einmalig aus:

```text
CampaignState
-> strategische Item-Preflight/Apply/Readback
-> Fuel-Preflight/Apply/Readback
-> Technical-Availability-Preflight/Apply/Readback
-> READY
```

Verwendet werden weiterhin ausschließlich die bestehenden Adapter und Datenverträge. Es gibt keine Bestandsneuberechnung und keinen STORAGE-Readback, der CampaignState strategisch überschreibt.

Fuel-Scope der Production Base:

```text
KANDAHAR_MAIN
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
```

Der produktive NEW-Kontext enthält keinen künstlichen JP-8-Preservation-Wert. Dadurch wird der abgeschlossene, nicht in den Initial-Stock-Daten neu definierte JP-8-Bestand nicht überschrieben. Die `0.5 kg` Readback-Toleranz des bestehenden `OMW_StorageFuelAdapter` bleibt unverändert.

## 5. Fail-closed READY-Gate

`OMW_AirOpsWarehouseProduction.Start(...)` setzt zu Beginn über MOOSE `USERFLAG`:

```text
OMW_WAREHOUSE_READY = 0
```

Erst wenn der bestehende Warehouse-Bootstrap `status=READY` und `airOpsStartAllowed=true` zurückgibt, wird gesetzt und zurückgelesen:

```text
OMW_WAREHOUSE_READY = 1
```

Bei Fehlern wird das Flag erneut auf `0` gesetzt und der Fehler weitergegeben. Ein Fehler darf daher keinen nachgelagerten AIR-OPS-/AAR-Start freigeben.

Der Produktionspfad enthält keinen Scheduler. Die Mission-Editor-Reihenfolge entscheidet, wann das Bundle ausgeführt wird; das Flag entscheidet, ob nachgelagerte Module starten dürfen.

## 6. Production-vs-Acceptance-Grenze

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

Die historische Acceptance-Fixture bleibt unverändert unter:

```text
mission/tests/air-ops-warehouse-bootstrap/
```

und bleibt Evidenz für den exakt dokumentierten Teststand, aber kein Production-Einstiegspunkt.

## 7. Deterministischer Builder

Der Builder schreibt keinen aktuellen Build-Zeitstempel in das Bundle. Der Inhalt hängt von den versionierten Quellen und dem Git-Commit ab.

Er prüft vor dem Schreiben insbesondere:

```text
alle erforderlichen Source-Dateien vorhanden
verbindliche Source-Marker vorhanden
keine Acceptance-/Testmarker in den Production-Quellen
kein MissionScripting.lua / MIST / io / lfs / os.execute
Production-Bootstrap scheduler-frei
MOOSE-Provenienz gepinnt
```

Anschließend gibt er SHA-256 für jede beteiligte Source-Datei und für das erzeugte Bundle aus. Zwei Builds desselben Commits müssen denselben Bundle-SHA-256 ergeben.

## 8. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Gegen die tatsächlich verwendete `Moose.lua` wurden für diesen Packaging-Scope erneut nachgewiesen:

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

Die Production Base führt keine neue MOOSE-Abstraktion ein. Sie ergänzt ausschließlich die kleine OMW-Orchestrierung für CampaignContext, fail-closed READY und die bereits vorhandenen MOOSE-STORAGE-Adapter.

## 9. Verifikationsgrenze

Der neue Production-Packaging-/Startup-Pfad ist mit diesem Dokument **nicht DCS-validiert**.

Vor `VALIDATED` sind erforderlich:

```text
Production-Builder erfolgreich
zwei Builds desselben Commits mit identischem SHA-256
keine Acceptance-/Testmarker im Bundle
realer kleiner DCS-Smoke-Test:
  Warehouse READY
  -> AAR Production Base
  -> AIR-OPS Foundations
  -> keine Lua-/Bootstrap-Fehler
```

Ein vollständiger neuer Warehouse-Acceptance-Lauf ist nur erforderlich, wenn der Smoke-Test eine funktionale Regression zeigt oder die zugrunde liegenden Warehouse-Verträge geändert werden.
