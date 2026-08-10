---
document_id: OMW-TEST-STORAGE-FUEL-ADAPTER-INDEX
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - STORAGE fuel adapter foundation test scope
  - builder and source paths for the adapter test bundle
  - accepted DCS test boundary for FUEL_JP8 and FUEL_AVGAS mirroring
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-fuel-adapter-foundation
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/storage-fuel-adapter-foundation
acceptance_commit: 0e5992f96a37b7400d7859fbcd3e98829f935d68
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 54e9bd5d1d841a6c22980e59e07b463aef580032813f3441f1030b221fec66e9
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# STORAGE Fuel Adapter Foundation Test

## 1. Zweck

Dieser Test prüft ausschließlich die operative MOOSE-`STORAGE`-Spiegelung der beiden verbindlichen CampaignState-Fuel-Ressourcen:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
canonical unit: kg
```

Die strategische Ressourcenhoheit bleibt außerhalb des Testbundles bei `CampaignState`.

## 2. Testpfade

```text
scripts/logistics/OMW_StorageFuelAdapter.lua
mission/tests/storage-fuel-adapter/src/01-storage-fuel-adapter-foundation.lua
tools/build-storage-fuel-adapter-foundation.ps1
mission/tests/storage-fuel-adapter/dist/OMW_StorageFuelAdapter_Foundation_Test.lua
```

`dist/` wird ausschließlich durch den Builder erzeugt und nicht manuell bearbeitet.

## 3. Testknoten

Der Foundation-Test verwendet den DCS-/MOOSE-Airbase-Warehouse-Knoten `Kandahar` mit stabiler OMW-Knoten-ID:

```text
HUB_KANDAHAR
```

Die Auswahl dient nur dazu, beide getrennten Fuel-Ressourcen gegen einen realen Airbase-Warehouse-Wrapper zu prüfen. Sie legt keine produktiven Bestandsmengen fest.

Für den akzeptierten Lauf musste das native DCS-Airbase-Warehouse von Kandahar auf **Limited Liquids** stehen. Die Option `Unlimited Liquids` ist für einen CampaignState-verwalteten `STORAGE`-Fuel-Mirror nicht zulässig, weil dann kein begrenzter operativer Bestand gespiegelt wird.

## 4. Ablauf

Der Runtime-Test besteht in dieser Reihenfolge:

1. aktuellen JETFUEL- und GASOLINE-Bestand lesen;
2. einen kontrollierten Test-Snapshot mit `+1000 kg` JP-8 und `+500 kg` AVGAS planen;
3. beide Werte über `STORAGE:SetLiquid()` spiegeln;
4. Readback gegen den Soll-Snapshot prüfen;
5. denselben Snapshot erneut planen und `changeCount=0` nachweisen;
6. denselben Snapshot erneut anwenden und Idempotenz nachweisen;
7. die vor Testbeginn gelesenen Werte wiederherstellen;
8. Wiederherstellung per Readback bestätigen.

`STORAGE:IsUnlimitedLiquids()` wird bewusst nicht verwendet, weil der geprüfte MOOSE-Quellpfad zur Unlimited-Prüfung temporär Bestand entfernt und gegebenenfalls wieder hinzufügt. Die operative OMW-Voraussetzung wird stattdessen im Mission-Editor-/Node-Vertrag hergestellt: CampaignState-verwaltete Fuel-Nodes verwenden Limited Liquids.

## 5. Ausdrücklich ausgeschlossen

```text
CampaignState mutation
strategic resource creation
resource persistence
MOOSE STORAGE file persistence
automatic aircraft fuel debit
AAR accounting
weapon synchronization
OPSTRANSPORT
CTLD
COMMANDER/AUFTRAG mission generation
```

Ein PASS dieses Tests beweist daher nur den dokumentierten STORAGE-Liquid-Mirror-Pfad.

## 6. MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für den akzeptierten Kandahar-Lauf sind `STORAGE:FindByName()`, `STORAGE:GetLiquidAmount()` und `STORAGE:SetLiquid()` für `JETFUEL` und `GASOLINE` praktisch bestätigt. `AIRBASE:GetStorage()` bleibt als source-reviewed Fallbackpfad Bestandteil des Adapters, wurde durch diesen konkreten Lauf aber nicht als eigener Acceptance-Schritt isoliert geprüft.

## 7. Acceptance

Der vollständige Accepted-Technical-Baseline-Nachweis steht in [`storage-fuel-adapter-foundation-acceptance.md`](expected/storage-fuel-adapter-foundation-acceptance.md).

```text
runtime_status: PASS
validated_in_dcs: true
acceptance_commit: 0e5992f96a37b7400d7859fbcd3e98829f935d68
DCS: 2.9.28.26385 MT
MIZ SHA-256: 54e9bd5d1d841a6c22980e59e07b463aef580032813f3441f1030b221fec66e9
Bundle SHA-256: 16faa7da140334ddd3a001480e6f2677842b3dcc3cff64626796e039cd0769db
```
