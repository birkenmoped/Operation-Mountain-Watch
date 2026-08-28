---
document_id: OMW-GROUND-AMMO-RESUPPLY-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_PLAN_AND_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local DCS acceptance baseline for MissionDemand-driven physical Ground AMMO RESUPPLY
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
acceptance_branch: agent/automatic-response-orchestration
acceptance_commit: 2d72bcdfc113342a2180b6cd9c84486da790052c
acceptance_mission: OMW_Template_v18.miz
acceptance_mission_sha256: 2fdf31a2e07409cf392d45bff5fc69750958c670ae3e12ff28d0b4fd8aecc90d
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Ground AMMO RESUPPLY Acceptance 1 – Joyce nach Honaker

## 1. Ergebnis

```text
status: ACCEPTED_TECHNICAL_BASELINE
runtime_result: PASS
```

Belegter Lifecycle:

```text
Honaker AMMO shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER Joyce -> Honaker / 20
-> TPL_BLUE_CONVOY_LIGHT_06
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewAMMOSUPPLY
-> OnRoad 27 kt
-> physical arrival in Honaker ACCESS zone
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> MissionDone
-> delayed RTZ Joyce ACCESS / OnRoad
-> Returned
-> Warehouse AddAsset
-> physical cleanup
-> PASS
```

Strategischer Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

## 2. Autoritätsgrenze

```text
CampaignState = alleinige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE = physische Ausführung
DCS group = temporäre physische Repräsentation
```

Der physische Convoy definiert keine strategische Package-Kapazität.

## 3. Physischer MOOSE-Vertrag

```text
BRIGADE:New(...)
PLATOON:New(TPL_BLUE_CONVOY_LIGHT_06, 1, ...)
PLATOON:AddMissionCapability(AUFTRAG.Type.AMMOSUPPLY, 100)
BRIGADE:AddPlatoon(...)
AUFTRAG:NewAMMOSUPPLY(destinationZone)
AUFTRAG:SetMissionSpeed(27)
AUFTRAG:SetFormation(ENUMS.Formation.Vehicle.OnRoad)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:AddMission(...)
ARMYGROUP:RTZ(originZone, ENUMS.Formation.Vehicle.OnRoad)
```

Die owner-approved `OMW_GroundRoadSpawnAdapter`-Ausnahme wird ausschließlich für road-aligned Materialisierung verwendet.

## 4. Build-Provenienz

```text
Build Git HEAD: 2d72bcdfc113342a2180b6cd9c84486da790052c
BuilderVersion: GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-5
GeneratedUtc: 2026-08-22T18:27:19Z
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
Builder SHA-256: A55103F0DF919365EF40DF4DB459E4E6AB96D858CF973D9F92B59BB48A75ACFD
Acceptance source SHA-256: 794CA80C717586A796154F605074AC9AB61B27668B216C5A5A8718B772FD76F4
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
GroundRoadSpawnAdapter source SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 5. DCS-PASS-Provenienz

```text
DCS: 2.9.28.26385 MT
Executed mission: OMW_Template_v18.miz
MIZ SHA-256: 2FDF31A2E07409CF392D45BFF5FC69750958C670AE3E12FF28D0B4FD8AECC90D
internal mission SHA-256: 38B207278365CD977E74FF3C9000C6A7C5B13EEE3E5B1BB154F1775055D02AF6
Acceptance bundle SHA-256: 752B3E6F0B77D1B62C750421DDE36202C81B98632FEFBF6A273F913202DF8339
Ground production bundle SHA-256: E616D35F5EBDBDDD4275785091D47F57445348D1FF4BB4CFBE7DEE0F0B12D78E
dcs.log SHA-256: 0C0B5784A0AA1C67E0BE57CEEF90006FBEEE40805D7A589D8EF8DC6DC3BFDFDF
debrief.log SHA-256: C9EA7398241DEA3323B39FAD8F28D97D27B5A1CB1EE05A79433BA26896666DEB
```

## 6. Laufhistorie

```text
Run 1: FAIL / stale embedded Ground production thresholds
Run 2: FAIL / delivery and RTZ acceptance confirmed; global timeout cut return window
Run 3: FAIL / early post-MissionDone RTZ race reproduced
Run 4: PASS / full Joyce-Honaker-Joyce lifecycle
```

Detaildateien:

```text
results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-1.md
results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-2.md
results/2026-08-22-ground-ammo-resupply-acceptance-1-fail-3.md
results/2026-08-22-ground-ammo-resupply-acceptance-1-pass-1.md
```

## 7. Grenzen

Nicht durch diese Acceptance validiert:

```text
generic package-per-truck capacity
automatic convoy-size selection
FUEL RESUPPLY
generic non-AMMO RESUPPLY
multiple concurrent demands
convoy-under-attack reaction
loss/abort settlement
external process/server persistence
CAS / CSAR
```
