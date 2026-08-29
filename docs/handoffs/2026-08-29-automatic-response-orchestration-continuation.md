---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION-CONTINUATION-2026-08-29
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local continuation order after accepted Ground RESUPPLY orchestration scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
validated_in_dcs: partial
base_branch: main
base_commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
---

# Automatic Response Orchestration – Continuation

## 1. Ausgangspunkt

Der Nachfolgebranch basiert auf dem nach `main` integrierten Ground-RESUPPLY-Parent-Scope:

```text
main merge PR: #135
main merge commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
```

Akzeptierter Parent-Scope:

```text
Stage 1A  AMMO RESUPPLY                ACCEPTED_TECHNICAL_BASELINE
Stage 1C  meta RESUPPLY via NOTHING    ACCEPTED_TECHNICAL_BASELINE
Stage 1B2 one-shot FUELSUPPLY          ACCEPTED_TECHNICAL_BASELINE
Stage 1D-S SUPPLY via NOTHING          ACCEPTED_TECHNICAL_BASELINE
```

## 2. Stage 1D-S – abgeschlossen und technisch akzeptiert

```text
status: ACCEPTED_TECHNICAL_BASELINE
runtime_result: PASS
branch: agent/automatic-response-orchestration-continuation
build_commit: 4771420480a994ce7356abc618ae0a3189dc105e
builder_version: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
bundle_sha256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
mission: OMW_Template_v20_GroundWorks.miz
mission_sha256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
dcs: 2.9.29.27278 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Akzeptierter Lifecycle:

```text
MissionDemand RESUPPLY(resource=GROUND_SUPPLY_PACKAGE)
-> CampaignState reserve / transfer Joyce -> Honaker
-> existing Ground logistics PLATOON / TPL_BLUE_CONVOY_LIGHT_06
-> AUFTRAG:NewNOTHING(ZON_BLUE_GND_HONAKER_ACCESS)
-> SetReturnToLegion(false)
-> physical destination-zone proof
-> exact-once CampaignState SUPPLY settlement
-> MissionDemand SUCCESS
-> mission cancel / MissionDone
-> 30 s delayed ARMYGROUP:RTZ(ZON_BLUE_GND_JOYCE_ACCESS, OnRoad)
-> physical return
-> Returned
-> Warehouse AddAsset
-> PASS
```

Evidenz:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-5.md
mission/tests/ground-resupply-execution/results/2026-08-29-ground-supply-resupply-nothing-acceptance-1-pass-1.md
docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md
```

## 3. Regressionserkenntnis aus Stage 1D-S

Der erste Stage-1D-S-Harness wich unnötig vom bereits in Stage 1C bestandenen `AUFTRAG NOTHING`-Lifecycle ab. Die erfolgreiche Korrektur bestand aus der Rückkehr auf die technisch akzeptierte Stage-1C-Mechanik, nicht aus neuer Routinglogik oder einer neuen Zielzone.

Für Folgearbeiten gilt:

```text
vorhandene ACCEPTED_TECHNICAL_BASELINE
-> exakt als Referenz vergleichen
-> bewiesenen Lifecycle nicht ohne fachlich zwingenden Grund verändern
-> nur kleinstes erforderliches Delta implementieren
```

## 4. Stage 1D-P – owner-approved PERSONNEL contract

PERSONNEL bleibt strategischer CampaignState-Headcount und wird für gewöhnlichen Resupply **nicht** als reale Infantry-GROUP-Cargo modelliert.

Owner-Entscheidung:

```text
shared resourceId: GROUND_PERSONNEL
reorder trigger: strictly below 80% of target
exactly 80%: no demand
resupply quantity: refill to 100% target
PERSONNEL critical threshold: not defined in this stage
```

Die vorhandene Supply-Parent-Kette gilt:

```text
Jalalabad -> Fortress
Jalalabad -> Joyce
Jalalabad -> Wright
Jalalabad -> Bostick
Joyce     -> Honaker
```

FOB/COP -> OP oder AO mit physisch laufender Infanterie bleibt ein separater späterer Deployment-Scope.

## 5. Stage 1D-P – kombinierter Acceptance-Scope

Status:

```text
SOURCE_REVIEWED / STAGED
validated_in_dcs: false
```

### Ground leg

```text
Joyce PERSONNEL 180
Honaker PERSONNEL 120 -> simulated shortage 95
80% floor Honaker: 96
Demand: 25
Transfer: Joyce -> Honaker 25
Expected final: Joyce 155 / Honaker 120
Carrier: TPL_BLUE_CONVOY_LIGHT_06
Mission: AUFTRAG NOTHING
Return: accepted delayed explicit ARMYGROUP RTZ OnRoad
```

Der Ground-Lifecycle wird gegenüber Stage 1D-S nicht neu erfunden.

### Air leg

```text
Jalalabad PERSONNEL 480
Fortress PERSONNEL 160 -> simulated shortage 127
80% floor Fortress: 128
Demand: 33
Transfer: Jalalabad -> Fortress 33
Expected final: Jalalabad 447 / Fortress 160
Carrier owner: Jalalabad AIRWING
Squadron: SQ_US_JBAD_CH47_HEAVYLIFT
Template: TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
Mission: AUFTRAG LANDATCOORDINATE
Target: existing OMW_BLUE_LZ_FORTRESS_01 invisible FARP
```

Der Helikopter wird nicht Fortress zugeschlagen. Er startet als Jalalabad-AIRWING-Asset, repräsentiert die Aufnahme des PERSONNEL-Bestands am Source-Node Jalalabad, liefert nach physischem Landing-Nachweis bei Fortress und kehrt über den normalen MOOSE AIRWING/LEGION-Lifecycle nach Jalalabad zurück.

Kein `TROOPTRANSPORT`, da keine reale Infantry GROUP transportiert wird.

## 6. MOOSE-first evidence Stage 1D-P

Pinned MOOSE:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich gepinnten Source geprüft:

```text
AUFTRAG:NewLANDATCOORDINATE(...)
AUFTRAG:SetRequiredAssets(...)
AUFTRAG:AssignSquadrons(...)
AIRWING:onafterFlightOnMission(...)
FLIGHTGROUP:onafterTakeoff(...)
FLIGHTGROUP:IsAirborne(...)
OPSGROUP:onafterMissionDone(...)
OPSGROUP:Get2DDistance(...)
LEGION:onafterLegionAssetReturned(...)
```

Der Source bestätigt außerdem, dass `AUFTRAG:SetReturnToLegion(...)` nur Army/Navy betrifft und Aircraft immer über den Air-Lifecycle zurückkehren.

Details:

```text
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-SOURCE-REVIEW.md
```

## 7. Implementierte branch-lokale Änderungen

Strategische Daten/Policy:

```text
scripts/logistics/OMW_GroundInitialStock.lua
  -> schema OMW-GROUND-INITIAL-STOCK-3
  -> shared GROUND_PERSONNEL
  -> strict BELOW 80% PERSONNEL reorder rule
  -> legacy PERSONNEL-ID migration

scripts/campaign/OMW_ResourceDemandPolicy.lua
  -> optional reorderComparison
  -> default behavior backward compatible
  -> BELOW semantics for PERSONNEL
```

Tests:

```text
tests/mission-demand/test_resource_demand_policy.lua
tests/ground/test_ground_resource_normalization.lua
```

Production builders:

```text
tools/build-air-ops-warehouse-production-base.ps1
  -> must be rebuilt because Warehouse Base seeds the single CampaignState

tools/build-ground-production-base.ps1
  -> must be rebuilt because Ground Base exposes/attaches Ground stock v3
```

Acceptance:

```text
mission/tests/ground-resupply-execution/src/06-ground-air-personnel-resupply-acceptance.lua
tools/build-ground-air-personnel-resupply-acceptance-1.ps1
output: mission/tests/ground-resupply-execution/dist/OMW_Ground_Air_PERSONNEL_Resupply_Acceptance_1.lua
```

No `.miz` mutation was performed.

## 8. Local verification gate before Mission Editor work

The owner must pull the final remote commit and produce real output/hashes for all three bundles:

```text
1. OMW_AirOps_Warehouse_Base.lua
2. OMW_Ground_Base.lua
3. OMW_Ground_Air_PERSONNEL_Resupply_Acceptance_1.lua
```

Only after these real hashes are returned may the Mission Editor replacement instructions be issued.

## 9. Expected DCS lifecycle after build/ME gate

Ground:

```text
PERSONNEL shortage below 80%
-> demand/reservation
-> NOTHING convoy
-> Honaker destination proof
-> exact-once delivery
-> MissionDone
-> explicit RTZ Joyce
-> Returned
-> Warehouse AddAsset
```

Air:

```text
PERSONNEL shortage below 80%
-> demand/reservation
-> Jalalabad CH-47 FlightOnMission / loading
-> Takeoff / IN_TRANSIT
-> LANDATCOORDINATE Fortress FARP
-> grounded + <=100 m target proof
-> exact-once delivery / demand SUCCESS
-> normal MOOSE air return
-> LegionAssetReturned at Jalalabad
```

There is no hard Ground or Air travel-time timeout.

## 10. Verbleibende Entwicklungsreihenfolge

```text
Stage 1D-P  local build/hash -> Mission Editor -> DCS acceptance
Stage 1D-V  VEHICLE source/design reconciliation
Stage 2     FOB attacked -> support demand
Stage 3     fire support -> strategic resupply closure
Stage 4     convoy attacked -> support demand
Stage 5     BLUE/CAS automatic-response adapter
Stage 6     aircraft loss -> CSAR incident / MOOSE CSAR-first execution
Stage 7     complete end-to-end automatic response chain
Stage 8     restart / restore / idempotence
Stage 9     multiplayer / performance / failure acceptance
Stage 10    production reconciliation and merge readiness
```

## 11. Arbeitsgrenzen

```text
CampaignState = sole strategic authority
MissionDemand = demand/assignment authority
MOOSE = primary operational executor
DCS groups = temporary physical representations
```

Keine `.miz`-Mutation durch ChatGPT. Keine zweite Ressourcenautorität. Keine Native-DCS-/Nicht-MOOSE-Parallelimplementierung ohne ausdrückliche Eigentümerfreigabe. Kein `VALIDATED` ohne dokumentierten realen DCS-Test.
