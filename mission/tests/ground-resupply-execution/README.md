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
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground RESUPPLY Execution

## Zweck

Dieses Testpaket prüft den ersten vollständigen vertikalen Ground-RESUPPLY-Pfad zwischen der auf `main` integrierten MissionDemand-/ResourceDemandPolicy und der bestehenden MOOSE-Ground-Ausführung.

Erster Scope:

```text
GROUND_NODE_HONAKER
GROUND_AMMO_PACKAGE
40 -> 20
-> ResourceDemandPolicy REORDER
-> RESUPPLY MissionDemand
-> CampaignState TRANSFER from GROUND_NODE_JOYCE, quantity 20
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG AMMOSUPPLY
-> TPL_BLUE_GND_SUP_M1083
-> Honaker ACCESS-zone delivery proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> RTZ Joyce ACCESS zone
-> Warehouse AddAsset / physical cleanup
```

## Dateien

```text
src/01-ground-ammo-resupply-acceptance.lua
ACCEPTANCE-1.md
dist/OMW_Ground_Ammo_Resupply_Acceptance_1.lua   # generated locally
```

Builder:

```text
tools/build-ground-ammo-resupply-acceptance-1.ps1
```

## MOOSE-First

Technische Source-Prüfung:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

Verwendeter MOOSE-Stand:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Kein eigener Convoy-Dispatcher, kein MIST, keine native DCS-Eventschicht, kein `OPSTRANSPORT` und keine zweite strategische Ressourcenhoheit werden eingeführt.

## Aktueller Status

```text
Source: STAGED ON BRANCH
Builder: STAGED ON BRANCH
Local owner build: NOT RUN
Bundle SHA-256: UNKNOWN UNTIL OWNER BUILD
MIZ integration: NOT STARTED
DCS runtime: NOT RUN
```

Vor MIZ-Arbeit muss der Projektinhaber zuerst den versionierten Builder lokal per PowerShell ausführen und die reale Ausgabe einschließlich unabhängig ermitteltem Bundle-Hash zurückgeben.
