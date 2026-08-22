---
document_id: OMW-GROUND-FUEL-RESUPPLY-ACCEPTANCE-1
status: FAILED
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 1B Ground FUEL RESUPPLY FUELSUPPLY acceptance result
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground FUEL RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ergebnis

```text
TestId: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1
Overall: FAIL
FailureClass: OUTBOUND_MISSION_EXECUTION_NOT_REACHED
FUELSUPPLY as OMW meta-resupply executor: REJECTED_FOR_CURRENT_SCOPE
```

Der Test hat nicht den Return-Pfad erreicht. Der Fuel-Convoy wurde materialisiert und `ARMY_ON_MISSION` wurde ausgelöst, aber `OnAfterMissionExecute` blieb aus. Deshalb wurden `MarkDelivered`, `MissionDemand SUCCESS`, `MissionDone`, Cancel und RTZ nie ausgeführt.

Detailergebnis:

```text
results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
```

## 2. Strategische Grenze

```text
GROUND_FUEL_PACKAGE = CampaignState meta resource / unit=count
```

Dieser Acceptance-Lauf hat keine reale DCS-Fuel-Menge in Litern oder Gallonen in M978 geladen. Der physische Tankerkonvoi war ausschließlich operative Repräsentation. Daraus folgt keine Kapazitätsrelation zwischen M978 und `GROUND_FUEL_PACKAGE`.

## 3. Build-Provenienz

```text
Build Git HEAD: 4f651829e975f42d4aba44a9bd0813969a2f2d8b
GeneratedUtc: 2026-08-22T19:25:35Z
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Independent bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Builder SHA-256: 3A8CFA93058C8595CE48E9BBE102D8F020BDC69B8D36F74DAF20E9CC439E18E4
Acceptance source SHA-256: 38FF22AE66FB5B85BFDD4096AAF4AE05D4B0E53436AD5DB4DBC882FA2D93AA1A
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission path: OMW_Template_v19.miz
```

## 4. Physisches Fixture

```text
TPL_BLUE_CONVOY_FUEL_LIGHT_06
1 CHAP_MATV
2 M978 HEMTT Tanker
3 MaxxPro_MRAP
4 M978 HEMTT Tanker
5 MaxxPro_MRAP
6 CHAP_MATV
```

Das Template bleibt als physische Fuel-Convoy-Repräsentation verwendbar. Der fehlgeschlagene Test verwirft nicht das Template, sondern die Verwendung von `AUFTRAG:NewFUELSUPPLY(Zone)` für den OMW-Warehouse-zu-Warehouse-Meta-Warenpfad.

## 5. Runtime-Evidenz

Erreicht:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY transferStatus=IN_TRANSIT demandStatus=ACTIVE
```

Terminal:

```text
FAIL reason=OUTBOUND_TIMEOUT seconds=1800 spawnCount=1 armyOnMissionCount=1 missionExecuteCount=0 missionDoneCount=0
```

Nicht erreicht:

```text
DELIVERY_CONFIRMED
MISSION_DONE
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS
```

## 6. MOOSE-first Neubewertung

`AUFTRAG:NewFUELSUPPLY(Zone)` existiert im gepinnten Source. Der BRIGADE-Source nutzt den Missionstyp jedoch im Kontext von `AddRefuellingZone(...)`. Eine offizielle Demo für den von OMW versuchten Warehouse-zu-Warehouse-Meta-Waren-Roundtrip wurde nicht gefunden.

Dagegen dokumentiert derselbe gepinnte MOOSE-Source einen nativen Warehouse-Transferpfad:

```text
WAREHOUSE:AddRequest(...)
WAREHOUSE.TransportType.SELFPROPELLED
```

Für Ground-Assets routet `WAREHOUSE:onafterRequestSpawned()` das Asset selbständig zum anfordernden Warehouse. MOOSE Example 15 verwendet ausdrücklich `M978` und `M818` als selbstfahrende Warehouse-Assets zwischen zwei Warehouses.

Wichtige Grenze: Nach `Arrived` routet MOOSE die Ground-Group zum Ziel-Warehouse und plant `warehouse:__AddAsset(60, group)`. Ein späterer Rücktransport würde deshalb eine erneute Warehouse-Materialisierung erfordern. Vor OMW-Adoption muss geprüft werden, ob dieses Framework-Handoff mit der Projektregel gegen beobachtbare Spawn-/Despawn-Vorgänge vereinbar ist.

## 7. Mission-Editor-Status

Das fehlgeschlagene Acceptance-Bundle ist nicht mehr erforderlich. Der Projektinhaber kann den Trigger/`DO SCRIPT FILE` für

```text
OMW_Ground_Fuel_Resupply_Acceptance_1.lua
```

aus der Mission entfernen oder deaktivieren. Die neuen `TPL_BLUE_CONVOY_FUEL_*`- und `TPL_BLUE_CONVOY_MIXED_*`-Templates bleiben bestehen.

## 8. Nächster Schritt

```text
1. FUELSUPPLY acceptance path closed as FAIL.
2. Keep GROUND_FUEL_PACKAGE as CampaignState meta resource.
3. Complete WAREHOUSE SELFPROPELLED source/lifecycle review.
4. Resolve observable warehouse handoff boundary before a replacement acceptance is staged.
5. No further DCS test until that source review is complete.
```
