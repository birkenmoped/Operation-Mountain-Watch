---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-5
status: DCS_PENDING
document_class: ACCEPTANCE_TEST_SPECIFICATION
source_branch: agent/army-ground-foundation-reconciliation
validated_in_dcs: false
---

# ARMY Ground Foundation – Acceptance 5: Fenty test-only strategic return settlement

## 1. Purpose and explicit boundary

Acceptance 5 proves exactly one normal-return accounting path without declaring a production
ground resource model.

The scope is only:

```text
isolated test CampaignState store: 4 test vehicles available
-> reserve 4
-> consume 4 before the existing MOOSE deployment
-> existing Fenty BRIGADE / PLATOON / WAREHOUSE lifecycle
-> existing public ARMYGROUP:RTZ to ZON_BLUE_GND_FENTY_ACCESS
-> Returned
-> MOOSE Warehouse AddAsset and controlled physical DCS-group removal
-> CreditResourceOnce exactly 4 to the same isolated test store
-> repeat of the same credit is a no-op
```

The MOOSE/DCS lifecycle remains the operational evidence source. CampaignState remains
the only strategic authority for the isolated test quantity.

This is not a production Fenty/Jalalabad resource definition. It does not modify the
documented 48 wheeled-vehicle baseline, any production CampaignState store, Fortress,
Honaker-Miracle, or any `.miz`.

## 2. Owner-approved test scope

Owner authorization on 2026-08-19 covers this narrowly bounded test-only adapter:

- isolated node: `TEST_BLUE_GROUND_FENTY`;
- isolated resource: `TEST_VEHICLE_WHEELED`;
- fixed normal-return quantity: `4`;
- a confirmed MOOSE Warehouse return is required before the credit;
- exact-once credit is proved by a second identical `CreditResourceOnce` call;
- existing A3-2 road-aligned Warehouse-spawn exception is reused unchanged.

It does **not** approve a production vehicle taxonomy, quantity, source parent, loss,
partial-loss, damage/repair, restart reconciliation, or cross-session settlement.

## 3. Mission-editor contract

The owner changes the mission file. ChatGPT does not change `.miz`.

The current A4 Fenty contract remains sufficient:

```text
WH_BLUE_GND_FENTY
TPL_BLUE_GND_PATROL_MATV_4
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FENTY_PATROL_TEST_01
```

`ZON_BLUE_GND_FENTY_ACCESS` remains the sole FOB/Warehouse marker: Warehouse spawn,
start and return/handoff use the same marker.

## 4. Runtime acceptance criteria

The DCS log must show, in this causal order:

1. `CAMPAIGNSTATE_DEPLOYMENT_COMMITTED` with quantity 4 and availability 0.
2. Exactly one `GROUP_MATERIALIZED` and one `MISSION1_ON_MISSION`.
3. `MISSION1_DONE`, `RETURN_RTZ_ISSUED`, `RETURN_RTZ_ACTIVE`, and
   `RETURN_IN_PROGRESS`.
4. Exactly one `RETURNED_HANDOFF` and one `WAREHOUSE_ADD_ASSET`.
5. The physical group is removed after Warehouse AddAsset.
6. `CAMPAIGNSTATE_RETURN_CREDIT` with quantity 4 and availability 4.
7. `CAMPAIGNSTATE_EXACTLY_ONCE` with `duplicateInserted=false`.
8. `SITE_RUNTIME_PASS` and `RUNTIME_PASS_VISUAL_PENDING`.
9. No `OMW_GND_A5 FAIL`, no DCS script error, no return timeout, and no
   duplicate Group/RTZ/Returned/Warehouse AddAsset marker.

Visual acceptance:

- road-aligned four-vehicle M-ATV materialization;
- no visible teleport while spawning, deploying, or returning;
- normal arrival at the Fenty ACCESS marker;
- controlled MOOSE removal after the confirmed Warehouse handoff is expected.

## 5. Required provenance before DCS

Record:

- source commit;
- Acceptance-5 bundle SHA-256;
- owner-provided final MIZ SHA-256;
- internal `mission` SHA-256;
- embedded `l10n/DEFAULT/OMW_Army_Ground_Acceptance_5.lua` SHA-256;
- pinned MOOSE commit and Moose.lua SHA-256;
- DCS/debrief logs and visual observation.

## 6. Deliberately deferred

- any production CampaignState vehicle resource and initial quantity;
- which strategic parent is debited/credited;
- partial losses, destroyed vehicles, damage/repair values;
- cancellation, spawn failure, restart, and idempotency across saved sessions;
- multi-site strategic settlement;
- production rollout.

A5 must be accepted or rejected strictly on its four-out/four-back normal-return scope.
