---
document_id: OMW-TEST-STORAGE-FUEL-ADAPTER-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - STORAGE fuel adapter foundation test scope
  - builder and source paths for the adapter test bundle
  - static and DCS test boundaries for FUEL_JP8 and FUEL_AVGAS mirroring
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-fuel-adapter-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
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

Die Auswahl dient nur dazu, beide getrennten Fuel-Ressourcen gegen einen realen Airbase-Warehouse-Wrapper zu prüfen. Sie legt keine neuen Bestandsmengen fest.

## 4. Ablauf

Der Runtime-Test muss in dieser Reihenfolge bestehen:

1. aktuellen JETFUEL- und GASOLINE-Bestand lesen;
2. einen kontrollierten Test-Snapshot mit `+1000 kg` JP-8 und `+500 kg` AVGAS planen;
3. beide Werte über `STORAGE:SetLiquid()` spiegeln;
4. Readback gegen den Soll-Snapshot prüfen;
5. denselben Snapshot erneut planen und `changeCount=0` nachweisen;
6. denselben Snapshot erneut anwenden und Idempotenz nachweisen;
7. die vor Testbeginn gelesenen Werte wiederherstellen;
8. Wiederherstellung per Readback bestätigen.

Der Test bricht ab, wenn die Liquid-Bestände wie ein unbegrenztes DCS-Warehouse erscheinen. `STORAGE:IsUnlimitedLiquids()` wird bewusst nicht verwendet, weil der geprüfte MOOSE-Quellpfad zur Unlimited-Prüfung temporär Bestand entfernt und wieder hinzufügt.

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

Source-reviewed sind `STORAGE:FindByName()`, `AIRBASE:GetStorage()`, `STORAGE:GetLiquidAmount()`, `STORAGE:SetLiquid()` sowie die getrennten Liquid-Typen `JETFUEL` und `GASOLINE`.

## 7. Acceptance

Die geplanten Kriterien stehen in [`storage-fuel-adapter-foundation-acceptance.md`](expected/storage-fuel-adapter-foundation-acceptance.md).

Bis zum dokumentierten DCS-Lauf gilt:

```text
runtime_status: NOT_RUN
validated_in_dcs: false
```
