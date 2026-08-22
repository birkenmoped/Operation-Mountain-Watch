---
document_id: OMW-RESULT-GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-FAIL-1
status: TEST_EVIDENCE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 1B Ground FUEL RESUPPLY failed DCS runtime evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground FUEL RESUPPLY Acceptance 1 – FAIL 1

## Ergebnis

```text
TestId: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1
Result: FAIL
FailureClass: OUTBOUND_MISSION_EXECUTION_NOT_REACHED
```

Der physische Fuel-Convoy wurde materialisiert und MOOSE meldete `ARMY_ON_MISSION`, aber der FUELSUPPLY-Pfad erreichte `OnAfterMissionExecute` nicht. Dadurch wurden Delivery-Settlement, MissionDone, Cancel und RTZ nie ausgeführt.

## Build-Provenienz

```text
Build Git HEAD: 4f651829e975f42d4aba44a9bd0813969a2f2d8b
GeneratedUtc: 2026-08-22T19:25:35Z
BuilderVersion: GROUND-FUEL-RESUPPLY-ACCEPTANCE-1-1
Bundle SHA-256: A2C71E86244A2E6869E8A0A3D7384D917875064B11102CDA410A7DBD9C1C6922
Builder SHA-256: 3A8CFA93058C8595CE48E9BBE102D8F020BDC69B8D36F74DAF20E9CC439E18E4
Acceptance source SHA-256: 38FF22AE66FB5B85BFDD4096AAF4AE05D4B0E53436AD5DB4DBC882FA2D93AA1A
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission path: OMW_Template_v19.miz
```

Die unmittelbar vor dem Lauf read-only geprüfte Owner-Missionkopie enthielt exakt das gebaute Acceptance-Bundle. Ihr Preflight-Hash wird als Preflight-Evidenz geführt; er ist kein nachträglich direkt vom ausgeführten Pfad neu gelesener Hash.

## Runtime-Sequenz

Bestätigt:

```text
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION mission=FUELSUPPLY transferStatus=IN_TRANSIT demandStatus=ACTIVE
```

Terminaler Marker:

```text
FAIL reason=OUTBOUND_TIMEOUT seconds=1800 spawnCount=1 armyOnMissionCount=1 missionExecuteCount=0 missionDoneCount=0
```

Nicht erreicht:

```text
DELIVERY_CONFIRMED
MISSION_DONE
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS
```

## Bewertung

Der Fehler ist kein nachgewiesener RTZ-/Return-Fehler. Der Return-Code wurde nie erreicht. Die zuvor source-seitig angenommene Übertragbarkeit des Stage-1A-AMMOSUPPLY-Lifecycles auf `AUFTRAG:NewFUELSUPPLY(Zone)` ist damit für OMW widerlegt.

`GROUND_FUEL_PACKAGE` bleibt eine abstrakte CampaignState-Ressource. Der Acceptance-Lauf hat keine reale DCS-Fuel-Menge in Liter/Gallonen geladen oder übertragen.

## Architekturfolge

```text
AUFTRAG:NewFUELSUPPLY(Zone)
= REJECTED_FOR_CURRENT_OMW_META_RESUPPLY_EXECUTOR
```

Dies bedeutet nicht, dass die MOOSE-API generell fehlerhaft ist. Die Source-Prüfung zeigt, dass `FUELSUPPLY` im BRIGADE-Kontext für Refuelling-Zones verwendet wird. Ein Warehouse-zu-Warehouse-Meta-Warentransport mit anschließender Rückkehr ist durch die API-Dokumentation oder offizielle Demos nicht belegt.

Nächster MOOSE-first Kandidat ist der native `WAREHOUSE:AddRequest(...)`-Pfad mit `WAREHOUSE.TransportType.SELFPROPELLED`, weil der gepinnte MOOSE-Source ausdrücklich selbstfahrende Ground-Assets zwischen Warehouses routet und in Example 15 sogar `M978`/`M818` verwendet. Vor Implementierung muss jedoch die OMW-Regel gegen beobachtbare Spawn-/Despawn-Handoffs geprüft werden.
