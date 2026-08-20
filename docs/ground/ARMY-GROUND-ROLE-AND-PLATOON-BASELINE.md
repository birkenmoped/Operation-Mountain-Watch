---
document_id: OMW-ARMY-GROUND-ROLE-PLATOON-BASELINE
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned assignment of current Ground vehicle baselines to operational roles
  - current six-domain MOOSE BRIGADE topology
  - reusable mobile Ground template and PLATOON role planning
not_authoritative_for:
  - exact Fortress/Honaker internal vehicle-family split
  - final Mission Editor placement
  - Ground-order generation
  - fixed Honaker artillery proxy
  - accepted DCS runtime behavior beyond cited acceptance results
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - four-BRIGADE-only topology
  - Honaker no-BRIGADE/fixed-artillery-only planning
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# ARMY Ground Foundation – Rollen- und PLATOON-Baseline

## 1. Architekturgrenze

```text
CampaignState
= sole strategic resource authority

MOOSE BRIGADE / PLATOON / ARMYGROUP / WAREHOUSE
= operational selection, materialization and lifecycle

DCS GROUP / UNIT
= temporary physical representation
```

`BDE_` names represent MOOSE operational domains and do not assert historical brigade formations.

## 2. Pinned MOOSE basis

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Relevant source-verified mechanisms include:

```lua
COMMANDER:AddBrigade(...)
BRIGADE:New(...)
BRIGADE:AddPlatoon(...)
PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:SetMissionRange(...)
COHORT:CanMission(...)
AUFTRAG:SetReturnToLegion(false)
```

Physical Ground lifecycle behavior is accepted through Acceptance 7; Acceptance 9 adds no new MOOSE behavior.

## 3. Six operational BRIGADE domains

```text
BLUE COMMANDER
|
+-- BDE_BLUE_GND_JALALABAD
|   `-- WH_BLUE_GND_FENTY
|
+-- BDE_BLUE_GND_FORTRESS
|   `-- WH_BLUE_GND_FORTRESS
|
+-- BDE_BLUE_GND_JOYCE
|   `-- WH_BLUE_GND_JOYCE
|
+-- BDE_BLUE_GND_WRIGHT
|   `-- WH_BLUE_GND_WRIGHT
|
+-- BDE_BLUE_GND_HONAKER
|   `-- WH_BLUE_GND_HONAKER
|
`-- BDE_BLUE_GND_BOSTICK
    `-- WH_BLUE_GND_BOSTICK
```

Each domain may materialize operational assets only after CampaignState authorization. MOOSE warehouse counts do not become strategic stock.

## 4. Reusable mobile templates

```text
TPL_BLUE_GND_PATROL_MATV_4
  4 x CHAP_MATV

TPL_BLUE_GND_PATROL_MRAP_4
  4 x MaxxPro_MRAP

TPL_BLUE_GND_QRF_MIXED_4
  2 x CHAP_MATV
  2 x MaxxPro_MRAP

TPL_BLUE_GND_SECURITY_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_LOG_M1083_2
  2 x CHAP_M1083

TPL_BLUE_GND_FUEL_M978_2
  2 x M978 HEMTT Tanker

TPL_BLUE_GND_UTILITY_HMMWV_2
  2 x Hummer

TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3
  3 x MaxxPro_MRAP
```

The previous `TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2` is not part of the current production Foundation contract.

## 5. Jalalabad / FOB Fenty

Vehicle baseline: `48`.

```text
PATROL / MOBILE SECURITY
  2 x TPL_BLUE_GND_PATROL_MATV_4
  1 x TPL_BLUE_GND_PATROL_MRAP_4

QRF
  4 x TPL_BLUE_GND_QRF_MIXED_4

LOCAL SECURITY RESERVE
  1 x TPL_BLUE_GND_SECURITY_MRAP_2

LOGISTICS
  6 x TPL_BLUE_GND_LOG_M1083_2

FUEL SUPPORT
  1 x TPL_BLUE_GND_FUEL_M978_2

UTILITY / COMMAND / LOCAL SUPPORT
  4 HMMWV held outside an autonomous mission PLATOON
```

Family checksum:

```text
16 MATV
14 MRAP
12 M1083
2 M978 HEMTT Tanker
4 HMMWV
= 48
```

## 6. FOB Joyce

Vehicle baseline: `20`.

```text
PATROL
  1 x TPL_BLUE_GND_PATROL_MATV_4

QRF
  2 x TPL_BLUE_GND_QRF_MIXED_4

LOCAL SECURITY
  1 x TPL_BLUE_GND_SECURITY_MRAP_2

LOGISTICS
  2 x TPL_BLUE_GND_LOG_M1083_2

UTILITY / COMMAND
  2 HMMWV held outside an autonomous mission PLATOON
```

Family checksum:

```text
8 MATV
6 MRAP
4 M1083
2 HMMWV
= 20
```

Joyce remains the strategic support parent for Honaker but does not own Honaker's local stock.

## 7. FOB Wright

Vehicle baseline: `22`.

```text
PATROL / SECFOR
  1 x TPL_BLUE_GND_PATROL_MATV_4

QRF
  2 x TPL_BLUE_GND_QRF_MIXED_4

ENGINEER / ROUTE SUPPORT SECURITY
  2 x TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2

LOGISTICS
  2 x TPL_BLUE_GND_LOG_M1083_2

UTILITY / COMMAND
  2 HMMWV held outside an autonomous mission PLATOON
```

Family checksum:

```text
8 MATV
8 MRAP
4 M1083
2 HMMWV
= 22
```

No mine-clearing capability is asserted by the engineer-support abstraction.

## 8. FOB Bostick

Vehicle baseline: `26`.

```text
PATROL
  2 x TPL_BLUE_GND_PATROL_MATV_4

QRF
  1 x TPL_BLUE_GND_QRF_MIXED_4

OP REINFORCEMENT / MOBILE SECURITY
  2 x TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3

LOGISTICS / RECOVERY SUPPORT
  3 x TPL_BLUE_GND_LOG_M1083_2

UTILITY / COMMAND
  2 HMMWV held outside an autonomous mission PLATOON
```

Family checksum:

```text
10 MATV
8 MRAP
6 M1083
2 HMMWV
= 26
```

DCS towing/recovery mechanics are not asserted.

## 9. COP Fortress

Strategic vehicle baseline:

```text
GROUND_NODE_FORTRESS VEHICLE = 18
```

The exact internal M-ATV/MRAP/HMMWV/logistics split is not yet fixed by current evidence and is not invented here.

Current operational contract:

```text
own BRIGADE/WAREHOUSE operational domain
CampaignState reservation before materialization
validated M-ATV patrol template may be used where the mission contract requests that representation
exact production PLATOON multiplicities = later role-allocation decision
```

Fortress can therefore participate in the production Ground Foundation without pretending that the validated four-M-ATV patrol test defines its complete property book.

## 10. COP Honaker-Miracle

Strategic vehicle baseline:

```text
GROUND_NODE_HONAKER VEHICLE = 18
```

The exact internal vehicle-family split is not fixed by current evidence.

Current operational contract:

```text
own BRIGADE/WAREHOUSE operational domain
CampaignState reservation before materialization
validated mobile Ground lifecycle available
exact production PLATOON multiplicities = later role-allocation decision
```

The old fixed-fire-support contract is superseded:

```text
no production requirement for 2 x M777A2
no production requirement for 2 x L118_Unit proxy
2011 local mortar capability remains historically confirmed
```

## 11. Mission-role boundary

Potential MOOSE mission-role mapping remains subject to the later Ground-order design:

```text
PATROL
QRF
SECURITY
ENGINEER SUPPORT SECURITY
LOGISTICS
OP REINFORCEMENT
```

No new mission-generation layer is introduced by this Foundation document.

## 12. Accepted technical evidence

Acceptance 7 proves the physical MOOSE Ground lifecycle. Acceptance 8 proves production-shaped CampaignState integration. Acceptance 9-2 proves all six Ground stock nodes and Fortress/Honaker settlement behavior.

Acceptance 9-2:

```text
acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
result: PASS
```

## 13. Later scope

```text
exact Fortress vehicle-family split and PLATOON multiplicities
exact Honaker vehicle-family split and PLATOON multiplicities
Ground-order generation
exact Joyce/Bostick formation distribution
exact Wright artillery assignment
any future source-backed artillery mapping
```
