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
  - accepted DCS runtime behavior beyond cited acceptance results
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - four-BRIGADE-only topology
  - Honaker no-BRIGADE/fixed-artillery-only planning
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
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

TPL_BLUE_GND_PATROL_MIXED_4
  3 x CHAP_MATV
  1 x MaxxPro_MRAP

TPL_BLUE_GND_PATROL_MIXED_3
  2 x CHAP_MATV
  1 x MaxxPro_MRAP

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

TPL_BLUE_GND_INF_RIFLE_SQUAD_9
  7 x Soldier M4
  2 x Soldier M249
```

The previous generic `TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2` is not part of the current production Foundation contract.

The nine-man infantry template is a reusable DCS abstraction suitable for foot patrol, local security, OP relief/return and later dismount tasks. It does not claim exact individual historical weapon-role fidelity.

## 5. Site-bound fire-support templates

```text
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
  1 x L118_Unit

TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
  2 x L118_Unit

TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
  2 x 2B11 mortar
```

These are local physical capability representations, not independent strategic stock authorities.

Evidence boundaries:

```text
FORTRESS
  one local 105-mm capability is supported
  L118_Unit is a DCS proxy
  exact historical gun model is not asserted

BOSTICK
  historical M777 capability is documented
  two L118_Unit represent the current OMW DCS proxy choice
  L118 is not asserted as the historical system

HONAKER
  2011 local mortar capability is confirmed
  two 2B11 mortar units are the current OMW DCS proxy choice
  exact historical model/caliber is not asserted
  no 2011 M777/L118 hard fact is claimed
```

`MLRS FDDM` is not required by the current owner-created fire-support templates and is not part of this baseline.

## 6. Jalalabad / FOB Fenty

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

## 7. FOB Joyce

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

## 8. FOB Wright

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

## 9. FOB Bostick

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

SITE-BOUND FIRE SUPPORT
  TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
```

Family checksum:

```text
10 MATV
8 MRAP
6 M1083
2 HMMWV
= 26
```

The fire-support proxy is not counted against the current `VEHICLE = 26` mobile vehicle family checksum unless a later CampaignState resource rule explicitly assigns that accounting. DCS towing/recovery mechanics are not asserted.

## 10. COP Fortress

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
mixed patrol and infantry templates are available as additional physical representations
site-bound TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1 represents the supported local 105-mm capability
exact production PLATOON multiplicities = later role-allocation decision
```

Fortress can therefore participate in the production Ground Foundation without pretending that the validated four-M-ATV patrol test defines its complete property book.

## 11. COP Honaker-Miracle

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
mixed patrol and infantry templates are available as additional physical representations
site-bound TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2 represents the confirmed local mortar capability
exact production PLATOON multiplicities = later role-allocation decision
```

The old fixed-fire-support contract remains superseded:

```text
no production requirement for 2 x M777A2
no production requirement for 2 x L118_Unit proxy at Honaker
2011 local mortar capability remains historically confirmed
```

## 12. Infantry and convoy boundary

The reusable infantry squad may later be combined with a vehicle element, for example:

```text
vehicle element
  3 x M-ATV + 1 x MRAP
or
  2 x M-ATV + 1 x MRAP

plus

1 x TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

This defines a package composition only. It does not yet define embark/disembark behavior.

Actual convoy halt -> infantry dismount -> independent movement -> re-embark behavior remains a later MOOSE-first OPSTRANSPORT/Ground-order concern and must not be implemented as ad-hoc native DCS logic.

## 13. Mission-role boundary

Potential MOOSE mission-role mapping remains subject to the later Ground-order design:

```text
PATROL
FOOT PATROL
QRF
SECURITY
ENGINEER SUPPORT SECURITY
LOGISTICS
OP REINFORCEMENT / RELIEF
FIRE SUPPORT
```

No new mission-generation layer is introduced by this Foundation document.

## 14. Accepted technical evidence

Acceptance 7 proves the physical MOOSE Ground lifecycle. Acceptance 8 proves production-shaped CampaignState integration. Acceptance 9-2 proves all six Ground stock nodes and Fortress/Honaker settlement behavior.

Acceptance 9-2:

```text
acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
result: PASS
```

The later owner-created template additions are Mission Editor data only. They do not alter the accepted Acceptance-7/8/9 lifecycle behavior and are not independently marked runtime-validated.

## 15. Remaining test policy

No further single-feature DCS acceptance missions are planned on this branch.

If new Ground runtime behavior still needs in-game proof, it must be bundled into a Ground integration/collection mission covering all remaining runtime checks together. Template creation or naming cleanup alone does not trigger such a test.

## 16. Later scope

```text
exact Fortress vehicle-family split and PLATOON multiplicities
exact Honaker vehicle-family split and PLATOON multiplicities
Ground-order generation
exact Joyce/Bostick formation distribution
exact Wright artillery assignment
OPSTRANSPORT-based infantry transport/dismount behavior
```
