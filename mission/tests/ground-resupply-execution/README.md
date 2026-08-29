---
document_id: OMW-TEST-GROUND-RESUPPLY-EXECUTION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local test package for physical MissionDemand-driven Ground RESUPPLY execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
source_commit: 4771420480a994ce7356abc618ae0a3189dc105e
validated_in_dcs: partial
---

# Ground RESUPPLY Execution

## Zweck

Dieses Testpaket prüft MissionDemand-/CampaignState-gekoppelte physische Ground-RESUPPLY-Pfade. CampaignState bleibt strategische Ressourcenautorität; MOOSE übernimmt die physische Ausführung.

## Stage 1A – AMMO / akzeptiert

```text
GROUND_NODE_HONAKER
GROUND_AMMO_PACKAGE
40 -> 20 -> 40
CampaignState TRANSFER 20 from GROUND_NODE_JOYCE
TPL_BLUE_CONVOY_LIGHT_06
AUFTRAG AMMOSUPPLY
OnRoad 27 kt
30 s MissionDone -> RTZ settlement
same ARMYGROUP return
Returned -> Warehouse AddAsset -> physical cleanup
```

Status: `ACCEPTED_TECHNICAL_BASELINE`.

```text
src/01-ground-ammo-resupply-acceptance.lua
ACCEPTANCE-1.md
results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
tools/build-ground-ammo-resupply-acceptance-1.ps1
```

## Stage 1B – historischer FUELSUPPLY-Pfad

Der erste Versuch, die abstrakte CampaignState-Meta-Ware `GROUND_FUEL_PACKAGE` mit `AUFTRAG:NewFUELSUPPLY(...)` als Warehouse-to-Warehouse-Roundtrip auszuführen, bleibt historischer Testkontext. Der spätere Stage-1B2-One-Shot-FUELSUPPLY-Pfad ist die akzeptierte Fuel-Baseline.

```text
src/02-ground-fuel-resupply-acceptance.lua
ACCEPTANCE-2.md
results/2026-08-22-ground-fuel-resupply-acceptance-1-fail-1.md
tools/build-ground-fuel-resupply-acceptance-1.ps1
```

## Stage 1C – generischer Meta-RESUPPLY / AUFTRAG NOTHING

Technisch akzeptierter Vertrag:

```text
CampaignState meta-resource shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER
-> existing resource-appropriate convoy template
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewNOTHING(destination ACCESS zone)
-> SetReturnToLegion(false)
-> destination-zone proof
-> CampaignState DELIVERED / MissionDemand SUCCESS
-> mission cancel / MissionDone
-> delayed explicit ARMYGROUP:RTZ(origin ACCESS, OnRoad)
-> Returned -> Warehouse AddAsset
```

Status: `ACCEPTED_TECHNICAL_BASELINE`.

```text
src/03-ground-meta-resupply-nothing-acceptance.lua
ACCEPTANCE-3.md
results/2026-08-23-ground-meta-resupply-nothing-acceptance-1-pass-1.md
tools/build-ground-meta-resupply-nothing-acceptance-1.ps1
```

Keine harten Outbound-/Return-Travel-Timeouts gehören zum akzeptierten Stage-1C-Build.

## Stage 1B2 – one-shot FUELSUPPLY / akzeptiert

Für `GROUND_FUEL_PACKAGE` ist der spezialisierte one-shot MOOSE-Pfad akzeptiert:

```text
AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(...)
-> destination-zone proof
-> exact-once CampaignState delivery
-> mission cancel
-> normal MOOSE ReturnToLegion
-> Returned
-> Warehouse AddAsset
```

Status: `ACCEPTED_TECHNICAL_BASELINE`.

```text
src/04-ground-fuel-refuelling-zone-acceptance.lua
ACCEPTANCE-4.md
```

## Stage 1D-S – SUPPLY / akzeptiert

Stage 1D-S verwendet für normalisierte allgemeine Sustainment-Einheiten den bereits akzeptierten neutralen NOTHING-Pfad und lässt CampaignState alleinige strategische SUPPLY-Autorität bleiben.

```text
GROUND_NODE_HONAKER
GROUND_SUPPLY_PACKAGE
resourceClass=GROUND_SUPPLY
JOYCE   48 -> 28
HONAKER 40 -> 20 -> 40
TPL_BLUE_CONVOY_LIGHT_06
AUFTRAG:NewNOTHING(Honaker ACCESS)
OnRoad 27 kt
SetReturnToLegion(false)
destination-zone proof
CampaignState DELIVERED / MissionDemand SUCCESS
mission cancel / MissionDone
30 s delay
ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
Returned -> Warehouse AddAsset -> physical cleanup
```

DCS-PASS-Provenienz:

```text
Branch: agent/automatic-response-orchestration-continuation
Build commit: 4771420480a994ce7356abc618ae0a3189dc105e
BuilderVersion: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
Bundle SHA-256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
Mission: OMW_Template_v20_GroundWorks.miz
Mission SHA-256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
DCS: 2.9.29.27278 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Runtime result: PASS
```

Dateien:

```text
src/05-ground-supply-resupply-nothing-acceptance.lua
ACCEPTANCE-5.md
results/2026-08-29-ground-supply-resupply-nothing-acceptance-1-pass-1.md
tools/build-ground-supply-resupply-nothing-acceptance-1.ps1
```

Wichtige Regressionserkenntnis: Der erste Stage-1D-S-Build wich unnötig vom bereits bestandenen Stage-1C-NOTHING-Lifecycle ab. Der erfolgreiche Build 1-2 stellt den Stage-1C-Vertrag wieder her; keine neue Zielzone und keine eigene Routinglogik wurden eingeführt.

## Nächster Scope

```text
Stage 1D-P PERSONNEL
-> Source-/Design-Reconciliation
-> TROOPTRANSPORT nur mit realer physischer Cargo-Gruppe bewerten

Stage 1D-V VEHICLE
-> quantity transfer vs. whole-cohort relocation getrennt bewerten
```

## MOOSE-First

Pinned MOOSE:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Technische Reviews:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md
```

Kein eigener Convoy-Dispatcher, kein MIST, kein nativer DCS-Eventlayer, keine zweite Ressourcenautorität und keine `.miz`-Mutation durch ChatGPT.
