---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-MULTINODE-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - combined CampaignState to STORAGE multi-node fuel synchronization test scope
  - seven-node AirOps STORAGE mirror matrix
  - builder and source paths for the multi-node sync test bundle
  - documented DCS runtime evidence for the seven-node matrix
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-storage-multinode-sync
source_commit: e54b6c4eba126979a57efdbc86f485cde03f69e5
validated_in_dcs: true
base_branch: agent/campaignstate-storage-special-cases
base_commit: a6b791c4e835a8a39990c13c58b189e024414239
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
  - formal ACCEPTED_TECHNICAL_BASELINE promotion remains blocked until the exact tested MIZ SHA-256 is captured
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

## 8. DCS-Runtime-Evidenz 2026-08-10

Getesteter Source-/Builder-Stand:

```text
Branch: agent/campaignstate-storage-multinode-sync
Commit: e54b6c4eba126979a57efdbc86f485cde03f69e5
BuilderVersion: CAMPAIGNSTATE-STORAGE-MULTINODE-1
Bundle SHA-256: 3de006db91bb2888b5e2dd67662eae39454df9a5d2258d57e5ce9008c9f7ff00
DCS: 2.9.28.26385 MT
Mission filename: OMW_Template_v8_AirOps_rdy.miz
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

### 8.1 Lauf A - mit Spieler-Spawn OH-58D auf Jalalabad

```text
nodesExpected=7
nodesPassed=6
nodesFailed=1
status=FAIL
```

Knotenresultate:

```text
Bagram              PASS
Jalalabad            FAIL
Kandahar             PASS
Kandahar Heliport    PASS
FOB Salerno          PASS
Tarinkot             PASS
Shindand Heliport    PASS
```

Jalalabad wurde vor dem Harness bereits mit `JETFUEL=99666.309997559 kg` statt `100000 kg` gelesen. Der anschließende `SetLiquid()`-Pfad lieferte dort keinen exakten Readback und auch der Restore konnte unter dieser aktiven Verbrauchssituation nicht exakt verifiziert werden.

Artifact-Hashes:

```text
DCS log SHA-256: bc21980d05fc08bf9ba91bc53a65d31807705c0b867e9306c29e34c40646cc5a
Debrief SHA-256: 2f91450a0698ed62a7e690186e40d0b8f0ca2e8659a9f45019e311f06554efd8
```

Dieser Lauf wird ausdrücklich nicht als Widerlegung des Sync-Pfads interpretiert. Er ist Runtime-Evidenz dafür, dass ein nativer DCS-Fuelverbraucher denselben Warehouse-Bestand parallel zu einem exakten `SetLiquid()`/Readback-Test verändern kann.

### 8.2 Lauf B - Wiederholung ohne Spieler-Spawn

Der unmittelbar folgende Wiederholungslauf ohne Spieler-Spawn bestätigte die komplette Matrix:

```text
nodesExpected=7
nodesPassed=7
nodesFailed=0
status=PASS
direction=CampaignState-to-STORAGE
campaignStateMutation=false
reverseOverwrite=false
persistence=false
automaticAircraftDebit=false
```

Alle sieben Knoten bestanden:

```text
CAMPAIGNSTATE_SNAPSHOT_PASS
SYNC_PLAN_PASS changes=2
SYNC_WRITE_READBACK_PASS
SYNC_IDEMPOTENCY_PASS
NO_REVERSE_MUTATION_PASS
RESTORE_PASS
NODE_PASS
```

Knotenresultate:

```text
Bagram              PASS
Jalalabad            PASS
Kandahar             PASS
Kandahar Heliport    PASS
FOB Salerno          PASS
Tarinkot             PASS
Shindand Heliport    PASS
```

Artifact-Hashes:

```text
DCS log SHA-256: 9f81fef5d283f1ca6b94b72e55e9b258e6cc8680ae01f016ad92e47aade8071b
Debrief SHA-256: 35c3eba64237b24e4210e210f58d7313169ee9da82b6a388bab5cebf39e87ab0
```

Der Debrief enthält `graveyard = {}`.

### 8.3 Schlussfolgerung und Grenze

Für den exakt dokumentierten Branch-/Commit-/DCS-/MOOSE-/Bundle-Stand ist damit praktisch bestätigt:

```text
CampaignState snapshot
-> OMW_CampaignStateStorageSync
-> OMW_StorageFuelAdapter
-> MOOSE STORAGE
-> DCS Airbase Warehouse
```

funktioniert für alle sieben vorgesehenen Fuel-Mirror-Endpunkte, sofern während des streng synchronen Testfensters kein konkurrierender nativer Fuelverbrauch denselben Warehouse-Bestand verändert.

Der A/B-Vergleich zeigt zusätzlich eine wichtige Produktionsrandbedingung:

```text
CampaignState mirror write
und
native DCS fuel consumption
können denselben STORAGE-Bestand zeitgleich verändern.
```

Daraus folgt noch keine automatische Produktionsstrategie für Locking, Retry, Toleranz, Event-Buchung oder Reconciliation. Diese Mechanismen bleiben eine gesonderte Architekturentscheidung.

### 8.4 Formaler Acceptance-Status

Der DCS-Runtime-PASS ist dokumentiert. Eine Hochstufung dieses Testprojekts auf `ACCEPTED_TECHNICAL_BASELINE` erfolgt noch nicht, weil für den tatsächlich wiederholten 7/7-Lauf der exakte SHA-256 der ausgeführten `.miz`-Datei in der vorliegenden Evidenz nicht erfasst wurde.

Nicht geraten oder aus einem älteren Lauf übernommen werden dürfen:

```text
MIZ SHA-256
embedded bundle SHA-256 inside the executed MIZ
```

Bis diese beiden Provenienzwerte aus der tatsächlich ausgeführten Mission nachgewiesen sind, bleibt der Teststatus `PLANNED` trotz `validated_in_dcs: true`.
