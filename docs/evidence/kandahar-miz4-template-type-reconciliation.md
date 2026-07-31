---
document_id: OMW-EVIDENCE-KANDAHAR-MIZ4-TEMPLATE-TYPE-RECONCILIATION
status: BINDING_CORRECTION
owning_policy: OMW-GOV-001
authoritative_for:
  - current A-10C and C-130 template types in OMW_Template_v4_Kandahar(4).miz
  - semantic delta from Kandahar revision (3) to revision (4)
  - removal of obsolete A-10C and C-130 template mismatch blockers
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(4).miz
source_mission_size_bytes: 2183450
source_mission_sha256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
comparison_mission: OMW_Template_v4_Kandahar(3).miz
comparison_mission_sha256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
validated_in_dcs: false
---

# Kandahar revision (4) – correction of the template-type baseline

## 1. Reason for this correction

The earlier Kandahar structural audit and the broad no-spawn diagnostic were based on:

```text
OMW_Template_v4_Kandahar.miz / revision (1)
SHA-256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
```

That older source contained the following type differences:

```text
A-10 clients/statics: A-10C_2
A-10 template: A-10C

C-130 clients/statics: C-130J-30
C-130 template: C-130
```

Those statements are not valid for the current revision `(4)`.

## 2. Current revision (4) contract

Direct inspection of the internal `mission` table in:

```text
OMW_Template_v4_Kandahar(4).miz
Size: 2,183,450 bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

confirms:

### A-10C II

```text
CLIENT_US_KAF_A10C_01: A-10C_2
CLIENT_US_KAF_A10C_02: A-10C_2

TPL_AIR_US_KAF_A10C_CAS_2SHIP_UNIT_01: A-10C_2
TPL_AIR_US_KAF_A10C_CAS_2SHIP_UNIT_02: A-10C_2

STATIC_AIR_US_KAF_A10C_01 ... _06: A-10C_2
```

Binding result:

```text
A-10 client type = template type = static type = A-10C_2
```

There is no current A-10C/A-10C_2 type mismatch.

### C-130J-30

```text
CLIENT_US_KAF_C130_01: C-130J-30
CLIENT_US_KAF_C130_02: C-130J-30

TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP_UNIT_01: C-130J-30

STATIC_AIR_US_KAF_C130_01 ... _02: C-130J-30
```

Binding result:

```text
C-130 client type = template type = static type = C-130J-30
```

There is no current C-130/C-130J-30 type mismatch.

## 3. Semantic delta from revision (3) to revision (4)

Revision `(4)` retained the same named groups, unit IDs and group IDs, but the object contract was not semantically unchanged.

Confirmed type changes:

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP_UNIT_01
A-10C -> A-10C_2

TPL_AIR_US_KAF_A10C_CAS_2SHIP_UNIT_02
A-10C -> A-10C_2

TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP_UNIT_01
C-130 -> C-130J-30
```

The A-10 payload table was also regenerated for the A-10C II type. Revision `(4)` additionally replaced the broad Kandahar diagnostic resource with the isolated Heliport warehouse diagnostic.

Therefore, equality of names and IDs was insufficient to establish an unchanged Mission Editor object contract.

## 4. Superseded statements

This correction supersedes the following claims wherever they still appear:

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP is A-10C in the current mission
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP is C-130 in the current mission
A-10-/C-130-template type alignment remains an open decision
revision (3) and revision (4) have an unchanged Mission Editor object contract
```

The old claims remain historically correct only for revisions `(1)` through `(3)`.

## 5. Consequence for the next preflight

The Kandahar Dual-AIRWING Registration Preflight must use and validate:

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP
2 x A-10C_2

TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP
1 x C-130J-30
```

No project-owner decision or Mission Editor correction is required for these two type alignments. They are already implemented in the current revision `(4)`.

Future mission comparisons must inspect semantic fields including at least:

```text
unit type
payload
skill
lateActivation
uncontrolled
route/start action
airdromeId
parking/parking_id
```

Matching names, group IDs and unit IDs alone are not sufficient.