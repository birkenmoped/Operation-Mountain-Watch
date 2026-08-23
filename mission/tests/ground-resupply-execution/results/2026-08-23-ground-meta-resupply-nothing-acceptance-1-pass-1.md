---
document_id: OMW-GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-PASS-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local accepted runtime evidence for Ground meta-resource RESUPPLY via AUFTRAG NOTHING
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
acceptance_branch: agent/automatic-response-orchestration
acceptance_commit: 8803505edf07120bc6d1673b41f69067e8db0211
acceptance_mission: OMW_Template_v19.miz
acceptance_mission_sha256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
---

# Ground Meta RESUPPLY Acceptance 1 – Runtime PASS 1

## 1. Ergebnis

```text
TestId: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-4
Runtime result: PASS
Formal ACCEPTED_TECHNICAL_BASELINE: YES
```

Der DCS-Lauf erreichte den vollständigen Stage-1C-Lifecycle von Joyce nach Honaker und mit demselben `ARMYGROUP` zurück nach Joyce.

## 2. Build-Provenienz

```text
Branch: agent/automatic-response-orchestration
Build Git HEAD: 8803505edf07120bc6d1673b41f69067e8db0211
BuilderVersion: GROUND-META-RESUPPLY-NOTHING-ACCEPTANCE-1-4
GeneratedUtc: 2026-08-23T15:24:27Z
Bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Independent bundle SHA-256: C881C82C3F699914E18FFE64DE73E650E20AF82B55B3F486154C40059F44CB65
Builder SHA-256: 9F7E3DFAE967BA39C373190A11495EC5AFD39357B0C1001A12F952606816B636
Acceptance source SHA-256: 21A54365C6138425CF5CDF4965F9E6F3396889477708B37A23BCBCFD77897C0C
GroundRoadSpawnAdapter SHA-256: 1A81FB2E5270C493373CF5BF6EC01F5AFED47004BF25C4225524121155D983E8
MissionDemand source SHA-256: E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848
ResourceDemandPolicy source SHA-256: BDC20ACEDAB60F662093077B8320220EBB71C6C641CC604C4356231B8405913C
```

## 3. MOOSE-/DCS-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.28.26385 MT
Executed mission path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v19.miz
Executed MIZ SHA-256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
```

Diese Provenienz erfüllt die dokumentierte technische Acceptance-Grenze. Der Status gilt ausschließlich für den exakt dokumentierten Branch-, Commit-, Missions-, DCS- und MOOSE-Stand.

## 4. Acceptance-Konfiguration

```text
Origin: GROUND_NODE_JOYCE
Destination: GROUND_NODE_HONAKER
Resource: GROUND_FUEL_PACKAGE
TransferQuantity: 18
PhysicalMission: MOOSE AUFTRAG NOTHING
PhysicalTemplate: TPL_BLUE_CONVOY_FUEL_LIGHT_06
PhysicalCargoAuthority: false
DcsFuelQuantityDefined: false
PackagePerTankerCapacityDefined: false
OutboundTravelTimeoutSec: none
DestinationCheckIntervalSec: 15
DestinationExecutionGraceSec: 90
ReturnTravelTimeoutSec: none
ReturnIssueDelaySec: 30
ReturnSettlementDelaySec: 12
AcceptanceCompletion: event-driven
FUELSUPPLY: false
OPSTRANSPORT: false
MizMutation: false
```

## 5. Runtime-Sequenz

```text
START
DEMAND_RESERVED
ROAD_ALIGNED_WAREHOUSE_SPAWN
GROUP_MATERIALIZED
ARMY_ON_MISSION
DESTINATION_ZONE_ENTERED
DELIVERY_CONFIRMED
MISSION_DONE
AUFTRAG success
RETURN_RTZ_ACTIVE
RETURN_RTZ_ISSUED
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS
```

Der terminale Acceptance-Marker lautet:

```text
PASS originFinal=22 destinationFinal=36 transferQuantity=18 template=TPL_BLUE_CONVOY_FUEL_LIGHT_06 physicalMission=NOTHING demandStatus=SUCCESS spawnCount=1 returnedCount=1 warehouseAddAssetCount=1
```

Damit sind im beobachteten Lauf bestätigt:

```text
Joyce final GROUND_FUEL_PACKAGE = 22
Honaker final GROUND_FUEL_PACKAGE = 36
MissionDemand = SUCCESS
spawnCount = 1
returnedCount = 1
warehouseAddAssetCount = 1
```

## 6. Log-Provenienz

SHA-256 der hochgeladenen Testlogs:

```text
dcs(20260823-153336).log
7F89D79C10C8C61BB7994CE762C2554124212501FC019E83F5A34C87C54A67DD

debrief(20260823-153334).log
21D917BC43A00F429A22B1EE697E64A62EC9B487254D330F5A7B1F574A253FA2
```

Am Missionsende erscheint ein `bhHook.lua`-Fehler beim DCS-Shutdown. Er tritt nach dem Stage-1C-`PASS` auf und ist nicht als Ursache oder Teil des OMW-RESUPPLY-Lifecycles belegt.

## 7. Architekturgrenze

Dieser PASS bestätigt ausschließlich den getesteten strategischen Meta-Ressourcenpfad:

```text
CampaignState / MissionDemand
-> AUFTRAG NOTHING as neutral physical movement executor
-> same ARMYGROUP roundtrip
-> CampaignState delivery settlement
```

Er bestätigt ausdrücklich nicht:

```text
real DCS fuel quantity ownership
M978 package capacity
FUELSUPPLY operational refuelling semantics
production generic RESUPPLY executor outside this fixture
loss/interruption/restart behavior
```

Der frühere Stage-1B-FUELSUPPLY-Lauf bleibt separat als `HARNESS_TIMEOUT_CONTAMINATED / INCONCLUSIVE` dokumentiert.

## 8. Technische Baseline

```text
Acceptance branch: agent/automatic-response-orchestration
Acceptance commit: 8803505edf07120bc6d1673b41f69067e8db0211
Acceptance mission: OMW_Template_v19.miz
Acceptance mission SHA-256: D788AF36535D3ACD1866D15FFB5D354B2C44B5F8EE40D4BAF6FD1D97B7C0F8A5
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Resultat: `ACCEPTED_TECHNICAL_BASELINE` für genau diesen dokumentierten Stage-1C-Scope. Vor einem Merge nach `main` entsteht daraus keine repository-weite normative Wirkung.
