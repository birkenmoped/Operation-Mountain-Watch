---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-MULTINODE-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - combined CampaignState to STORAGE multi-node fuel synchronization test scope
  - seven-node AirOps STORAGE mirror matrix
  - builder and source paths for the multi-node sync test bundle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-storage-multinode-sync
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/campaignstate-storage-special-cases
base_commit: a6b791c4e835a8a39990c13c58b189e024414239
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# CampaignState -> STORAGE Multi-Node Sync Test

## 1. Ziel

Dieser Test führt den bereits akzeptierten CampaignState-zu-STORAGE-Foundationpfad und die anschließend bestätigte STORAGE-Sonderfalltopologie in einem gemeinsamen DCS-Lauf zusammen.

Geprüft werden alle aktuell bestätigten OMW-AirOps-Fuel-STORAGE-Endpunkte:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

Der vorherige Sonderfalltest hat für Kandahar/Main-Heliport, Shindand/Main-Heliport sowie FOB Salerno/Khost unabhängige Liquid-Bestände bestätigt. Dadurch kann die Multi-Node-Matrix die OMW-relevanten Endpunkte ohne Alias-Annahme als sieben getrennte operative Fuel-Mirror-Nodes prüfen.

`Shindand` und `Khost` selbst gehören nicht zur Multi-Node-Matrix. Sie dienten ausschließlich als Vergleichsendpunkte des Sonderfalltests.

## 2. Architekturgrenze

Synchronisationsrichtung:

```text
CampaignState
  -> OMW_CampaignStateStorageSync
  -> OMW_StorageFuelAdapter
  -> MOOSE STORAGE
  -> DCS Airbase Warehouse
```

`CampaignState` bleibt strategische Ressourcenhoheit. Der Test führt keinen Reverse-Overwrite aus DCS/MOOSE nach CampaignState aus.

Ausgeschlossen bleiben:

```text
CampaignState runtime mutation
resource transaction lifecycle
persistence
automatic aircraft fuel debit
player/AI refuel accounting
AAR accounting
weapon synchronization
CTLD
OPSTRANSPORT
scheduler-based continuous sync
mission restart reconciliation
multiplayer reconciliation
```

## 3. MOOSE-First

Der Test führt keine neue MOOSE-Klasse und keine neue MOOSE-Methode ein. Er verwendet ausschließlich den bereits source-reviewed und im Kandahar-Foundationpfad praktisch bestätigten STORAGE-Vertrag:

```text
STORAGE:FindByName()
AIRBASE:FindByName() / AIRBASE:GetStorage() als Adapter-Fallback
STORAGE:GetLiquidAmount()
STORAGE:SetLiquid()
STORAGE.Liquid.JETFUEL
STORAGE.Liquid.GASOLINE
```

MOOSE-Baseline:

```text
Release: 2.9.18
Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 4. Testknoten

Die Harness-IDs sind bewusst als Test-Fixtures gekennzeichnet und legen kein produktives CampaignState-Node-ID-Schema fest:

```text
TEST_NODE_BAGRAM             -> Bagram
TEST_NODE_JALALABAD          -> Jalalabad
TEST_NODE_KANDAHAR           -> Kandahar
TEST_NODE_KANDAHAR_HELIPORT  -> Kandahar Heliport
TEST_NODE_SALERNO            -> FOB Salerno
TEST_NODE_TARINKOT           -> Tarinkot
TEST_NODE_SHINDAND_HELIPORT  -> Shindand Heliport
```

Für jeden Knoten werden die vorhandenen `FUEL_JP8`- und `FUEL_AVGAS`-Werte zuerst gelesen. Der gewünschte CampaignState-Testwert liegt je Knoten mit einem unterschiedlichen positiven Delta über dem gelesenen Ausgangswert. Dadurch entsteht für beide Fuel-Ressourcen deterministisch ein initialer Sync-Plan mit `changeCount=2`.

## 5. Ablauf pro Knoten

Der Harness arbeitet als gemeinsame Matrix und bricht nicht beim ersten Knotenfehler ab.

Für jeden erfolgreich aufgelösten Knoten gilt:

```text
NODE_BEGIN
-> Ausgangsbestand lesen
-> CampaignState-Snapshot prüfen
-> PlanNode(): changeCount=2
-> ApplyNode()
-> exakter JETFUEL/GASOLINE-Readback
-> zweiter PlanNode(): changeCount=0
-> zweiter ApplyNode(): changeCount=0
-> CampaignState-Werte unverändert prüfen
-> ursprünglichen STORAGE-Snapshot wiederherstellen
-> Restore-Readback prüfen
-> NODE_PASS oder NODE_FAIL
```

Eine fehlgeschlagene Preflight-Auflösung wird als `NODE_FAIL ... stage=PREFLIGHT` protokolliert. Andere auflösbare Knoten werden dennoch weiter geprüft.

## 6. Acceptance-Kriterien

Ein vollständiger PASS benötigt:

```text
nodesExpected=7
nodesPassed=7
nodesFailed=0
status=PASS
```

Zusätzlich muss jeder Knoten folgende Marker erfolgreich erzeugen:

```text
CAMPAIGNSTATE_SNAPSHOT_PASS
SYNC_PLAN_PASS changes=2
SYNC_WRITE_READBACK_PASS
SYNC_IDEMPOTENCY_PASS
NO_REVERSE_MUTATION_PASS
RESTORE_PASS
NODE_PASS
```

Für jeden durchgeführten Restore müssen JP-8 und AVGAS exakt den vor dem Test gelesenen Ausgangswerten entsprechen.

Mission-Editor-Voraussetzung für alle sieben verwalteten nativen Fuel-STORAGE-Knoten:

```text
Unlimited Liquids = OFF
finite starting JETFUEL stock
finite starting GASOLINE stock
```

Ein Status `ACCEPTED_TECHNICAL_BASELINE` ist erst nach dokumentiertem DCS-Lauf mit Branch-, Commit-, Mission-, Bundle-, DCS- und MOOSE-Provenienz zulässig.

## 7. Source- und Build-Pfade

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_StorageFuelAdapter.lua
scripts/logistics/OMW_CampaignStateStorageSync.lua
mission/tests/campaignstate-storage-multinode-sync/src/01-campaignstate-storage-multinode-sync.lua
tools/build-campaignstate-storage-multinode-sync.ps1
mission/tests/campaignstate-storage-multinode-sync/dist/OMW_CampaignState_Storage_MultiNode_Test.lua
```

Builder-Version:

```text
CAMPAIGNSTATE-STORAGE-MULTINODE-1
```
