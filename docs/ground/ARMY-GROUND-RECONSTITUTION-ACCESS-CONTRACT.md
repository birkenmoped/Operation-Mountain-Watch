---
document_id: OMW-ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - current ACCESS-zone, road-anchor and return/handoff rules for mobile Ground assets
  - current restart settlement boundary for open Ground commitments
  - separation between live-session physical state and cross-session strategic state
not_authoritative_for:
  - final Mission Editor coordinates
  - final production route geometry
  - general cross-domain persistence architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - physical cross-session FIELD_DEPLOYED continuation/reconstitution model for Ground assets
  - fixed Honaker fire-support reconstitution example
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# ARMY Ground Foundation – Restart and ACCESS Boundary Contract

## 1. Current authority boundary

```text
CampaignState = strategic authority
MOOSE = operational lifecycle
DCS = temporary physical representation
```

The validated Ground settlement decision intentionally does **not** persist physical Ground groups across mission/server restarts.

## 2. Pinned MOOSE basis

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Relevant validated/used MOOSE Ground mechanisms are documented in the Ground MOOSE project documentation and Acceptance 7. This contract introduces no new MOOSE behavior.

## 3. Live-session mobile lifecycle

During a live session a mobile Ground asset remains correlated to its strategic commitment.

```text
CampaignState reservation
-> MOOSE materialization at controlled ACCESS boundary
-> physical mission
-> terminal return/loss OR still-open commitment
```

The physical DCS group is temporary and does not itself own the strategic resource.

## 4. Return settlement

Confirmed return, including a damaged surviving vehicle/group member covered by the mission correlation:

```text
confirmed return
-> one-time CampaignState availability credit
-> physical return handling/removal only after settlement boundary
-> duplicate callback/event cannot credit again
```

Acceptance 7 validates the return path and exactly-once behavior.

## 5. Loss settlement

```text
confirmed loss
-> permanent strategic loss
-> loss audit entry exactly once
-> no strategic return credit
```

A destroyed resource is not recreated merely because a new DCS session starts.

## 6. Server stop / crash settlement

This is the binding Ground restart rule:

```text
open nonterminal commitment at server stop/crash
-> no attempt to continue the old physical DCS/MOOSE group
-> no respawn of that group at its last field position
-> one-time strategic recredit at the next startup
-> commitment/reconciliation record marked settled exactly once
```

The purpose is to avoid both arbitrary resource loss and purposeless orphaned units after restart.

This supersedes the earlier model that tried to reconstruct `FIELD_DEPLOYED` Ground groups across sessions.

## 7. No physical continuation contract

Forbidden for the current Ground Foundation:

```text
persist last DCS coordinate
-> spawn same convoy/patrol there after restart

persist MOOSE ARMYGROUP physical state
-> recreate it as continuation after restart

server crash
-> leave strategic resource permanently committed without terminal settlement
```

A future project-wide persistence architecture may revisit this only through a separate owner decision and acceptance.

## 8. ACCESS zones

Current six operational-domain handoff identities:

```text
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

ACCESS zones are operational boundaries, not the installation geometry itself.

Rules:

```text
road-side or directly adjacent to a validated usable road
outside active base geometry where practical
materialization/departure/return/handoff boundary
no visible teleport/spawn/despawn transition
```

## 9. Ground pathfinding boundary

Ground AI pathfinding remains unreliable by project policy.

Production Ground movement must use:

```text
validated road anchors
validated routes where required
ACCESS boundaries
assembly/return points where required
bounded mission geometry
```

Acceptance of one route/site does not prove all future routes.

## 10. Fixed mission-start assets

Fixed installation defense may still exist physically from mission start, but it is separate from mobile Ground commitments.

There is no current Foundation requirement for a fixed Honaker M777/L118 pair.

```text
2011 Honaker local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
```

## 11. Validated motorized correlation

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
4-vehicle patrol = 4 VEHICLE + 12 PERSONNEL
```

This is the current accepted motorized patrol resource correlation, not a universal property-book composition rule for every Ground vehicle type.

## 12. Acceptance evidence

Acceptance 7 validates the physical MOOSE return/loss/restart settlement contract. Acceptance 8 validates production-shaped CampaignState integration. Acceptance 9-2 confirms the same settlement adapter on Fortress and Honaker within the six-node stock composition.

Acceptance 9-2 provenance:

```text
acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
result: PASS
```

## 13. Later scope

The current Ground Foundation deliberately leaves these separate:

```text
general cross-domain persistence architecture
Ground-order generation
production route/observation geometry
OPSTRANSPORT
```
