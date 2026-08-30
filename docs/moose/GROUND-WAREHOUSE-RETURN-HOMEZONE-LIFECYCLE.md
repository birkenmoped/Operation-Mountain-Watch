---
document_id: OMW-MOOSE-GROUND-WAREHOUSE-RETURN-HOMEZONE-LIFECYCLE
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first Ground return-to-origin lifecycle
  - Warehouse spawnzone, ARMYGROUP homezone and ReturnToLegion design order
  - origin-bound Ground recovery boundary
not_authoritative_for:
  - removal of existing ZON_BLUE_GND_*_ACCESS zones
  - guarantee that default Warehouse geometry works for every installation
  - observed Guard return completion in the Stage 2B final run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
validated_in_dcs: true
---

# MOOSE Ground Warehouse Return / Homezone Lifecycle

## MOOSE-first rule

For a normal Ground asset created by a Legion/Warehouse path, MOOSE retains the origin Legion and assigns the origin spawnzone as ARMYGROUP homezone.

Default non-ship Warehouse geometry in the pinned MOOSE source:

```text
warehouse zone radius: 500 m
warehouse spawnzone radius: 250 m
```

Normal return order:

```text
1. native ReturnToLegion with origin Warehouse spawnzone/homezone
2. if installation geometry proves unsuitable, configure public WAREHOUSE:SetSpawnZone(origin ACCESS, ...)
3. explicit ARMYGROUP:RTZ(...) only when mission semantics require it
4. custom/native fallback only after proven MOOSE gap and owner approval
```

`SetReturnToLegion(false)` is not a neutral default; it deliberately keeps the group in the field after mission completion.

## Native return lifecycle

Pinned source semantics:

```text
MissionDone
-> if legionReturn true
-> ARMYGROUP:RTZ(origin legion spawnzone)
-> if already inside zone: Returned immediately
-> otherwise route to a coordinate in the zone
-> Returned
-> origin Legion/Warehouse AddAsset
```

CampaignState does not calculate the physical route. It settles the original deployment after confirmed MOOSE return/loss evidence.

## Stage 2B DCS evidence

Final Fortress Acceptance 2 used:

```text
Warehouse: WH_BLUE_GND_FORTRESS
spawnzone override: false
SetReturnToLegion(false): false
explicit OMW RTZ: false
```

All three QRF groups reached native origin recovery:

```text
QRF-2: 4 survivors / 5 casualties
QRF-3: 1 survivor / 8 casualties
QRF-1: 2 survivors / 7 casualties
```

Each logged:

```text
QRF_RETURNED_ORIGIN
warehouse=WH_BLUE_GND_FORTRESS
homezone=Warehouse WH_BLUE_GND_FORTRESS spawn zone
```

This validates the native default-homezone path for the tested Fortress QRF survivors.

## Guard boundary

The same final run did not log `GUARD_RETURNED_ORIGIN` before shutdown after the Guard mission was closed. The owner accepted this residual Guard/HESCO observation as non-blocking for Stage 2B. Therefore the document does **not** generalize default Warehouse geometry as universally sufficient for every Guard position or installation.

Existing `ZON_BLUE_GND_*_ACCESS` zones remain available as validated safe Ground geometry where later DCS evidence shows a need; they are not silently removed or redefined.

Exact Stage 2B provenance: `../../mission/tests/fob-attack-support-demand/RESULT-2.md`.