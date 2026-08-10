---
document_id: OMW-TEST-STORAGE-FUEL-ADAPTER-FOUNDATION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted technical baseline for STORAGE fuel adapter foundation
  - required runtime markers for separate JP-8 and AVGAS mirroring
  - explicit non-acceptance boundaries of the foundation test
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

# STORAGE Fuel Adapter Foundation – Acceptance

## 1. Gate

```text
Gate: STORAGE-FUEL-ADAPTER-FOUNDATION-1
Status: ACCEPTED_TECHNICAL_BASELINE / PASS
Test date: 2026-08-10
```

Die technische Acceptance gilt ausschließlich für den dokumentierten Branch-, Commit-, MIZ-, Bundle-, DCS- und MOOSE-Stand. Sie macht `STORAGE` nicht zur strategischen Ressourcenhoheit und validiert keine automatische CampaignState-Synchronisation.

## 2. Statische Provenienz

```text
Branch: agent/storage-fuel-adapter-foundation
Source commit: 0e5992f96a37b7400d7859fbcd3e98829f935d68
Builder version: STORAGE-FUEL-ADAPTER-FOUNDATION-1
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 54e9bd5d1d841a6c22980e59e07b463aef580032813f3441f1030b221fec66e9
Internal mission SHA-256: 27cdcff0ccda6299c07c853c9bdc16897523db8e8d8b6b6dc5d7caa751c570ad
Embedded bundle: l10n/DEFAULT/OMW_StorageFuelAdapter_Foundation_Test.lua
Embedded bundle SHA-256: 16faa7da140334ddd3a001480e6f2677842b3dcc3cff64626796e039cd0769db
DCS log SHA-256: 7c14b2718a655b4868d8a4c03078b82f0c75798191a50c91b75f38960c066a50
Debrief SHA-256: 7969969a5e1a69013fcd5b2fedd68d7c3a90ab70de80b28c7d1c487019153d1e
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
```

Der Builder bestätigte für den getesteten Bundle-Stand:

```text
FuelResources: FUEL_JP8,FUEL_AVGAS
CanonicalUnit: kg
AutomaticAircraftDebit: ABSENT
CampaignStateMutation: ABSENT
Persistence: ABSENT
Transport: ABSENT
```

## 3. Testbedingung: Limited Liquids

Der erste Lauf mit im Mission Editor aktivierter Option `Unlimited Liquids` war erwartungsgemäß kein gültiger Limited-Inventory-Test: `GetLiquidAmount()` lieferte für beide Fuel-Typen einen unveränderlichen Wert von `1000000`, der anschließende `SetLiquid()`-Readback bestätigte den Sollwert nicht und der Test endete mit `status=FAIL`.

Für den akzeptierten Lauf wurde Kandahar auf begrenzte Flüssigkeiten umgestellt. Der Mission Editor führte für JETFUEL und GASOLINE jeweils `100 t`; der Runtime-Readback ergab:

```text
ORIGINAL jp8Kg=100000 avgasKg=100000
```

Damit ist für diesen getesteten Pfad praktisch bestätigt:

```text
100 t Mission Editor liquid
-> 100000 kg DCS/MOOSE STORAGE readback
```

Für OMW folgt daraus als technische Voraussetzung des CampaignState-Fuel-Mirrors:

```text
CampaignState-managed DCS STORAGE node
-> Unlimited Liquids must be OFF
```

Diese Voraussetzung gilt nur für durch OMW/CampaignState verwaltete Fuel-Nodes; sie ist keine projektweite Anweisung, sämtliche Afghanistan-Airports auf Limited Liquids umzustellen.

## 4. Positive Runtime-Kriterien

Der akzeptierte Rohlog enthält:

```text
BEGIN testId=STORAGE-FUEL-ADAPTER-FOUNDATION-1
ORIGINAL jp8Kg=100000 avgasKg=100000
PLAN_PASS changes=2
WRITE_READBACK_PASS
IDEMPOTENCY_PASS
RESTORE_PASS
RESULT testId=STORAGE-FUEL-ADAPTER-FOUNDATION-1 status=PASS
```

Der Endmarker bestätigt zusätzlich:

```text
nodeId=HUB_KANDAHAR
airbaseName=Kandahar
jp8Separated=true
avgasSeparated=true
canonicalUnit=kg
automaticAircraftDebit=false
persistence=false
campaignStateMutation=false
```

## 5. Akzeptierter Methoden-/Verhaltensumfang

Für exakt diesen Stand sind praktisch bestätigt:

```text
STORAGE:FindByName("Kandahar")
STORAGE:GetLiquidAmount(STORAGE.Liquid.JETFUEL)
STORAGE:GetLiquidAmount(STORAGE.Liquid.GASOLINE)
STORAGE:SetLiquid(STORAGE.Liquid.JETFUEL, amountKg)
STORAGE:SetLiquid(STORAGE.Liquid.GASOLINE, amountKg)
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
canonical unit: kg
```

Der Adapter konnte einen Soll-Snapshot schreiben, exakt zurücklesen, denselben Soll-Snapshot ein zweites Mal mit `changeCount=0` behandeln und anschließend die beiden Ausgangswerte erfolgreich wiederherstellen.

## 6. Nicht durch PASS belegt

Ein PASS belegt ausdrücklich nicht:

```text
CampaignState persistence
CampaignState transaction lifecycle
production stock quantities
automatic aircraft consumption
player refuel accounting
AI refuel accounting
AAR accounting
weapon inventory synchronization
multiplayer reconciliation
mission restart reconciliation
OPSTRANSPORT or CTLD delivery
STORAGE file persistence
reverse overwrite of CampaignState from DCS telemetry
```

Das vorhandene MOOSE-`WAREHOUSE`/`AIRWING`-Assetmodell bleibt vom getesteten `STORAGE`-Liquidpfad getrennt. Der Test validiert keine gemeinsame Fuel-Hoheit von `WAREHOUSE` und `STORAGE`.

## 7. Acceptance-Status

```text
status: ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
runtime_status: PASS
```

Die technische Baseline darf nur mit der oben dokumentierten Provenienz zitiert werden. Ein anderer MOOSE-Hash, DCS-Stand, Bundle-Stand oder eine andere Warehouse-Konfiguration benötigt eine neue Bewertung.