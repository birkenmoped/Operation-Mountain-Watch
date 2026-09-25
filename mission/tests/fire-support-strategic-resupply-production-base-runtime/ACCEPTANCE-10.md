---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-10
status: DRAFT
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - ARTY selection-only DCS acceptance preflight
  - Functional ARTY ownership preservation gate
  - MOOSE recruitment representation blocker
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# Production Base Acceptance 10 – Functional ARTY Selection / Rearm

## 1. Zweck

A10 soll die neue FSSR-ARTY-Grenze gezielt in DCS pruefen, ohne den bereits akzeptierten Functional-ARTY-/M1083-Lifecycle neu zu implementieren.

Beabsichtigte Kette:

```text
qualified C2 ARTY demand
-> AUFTRAG:NewARTY as selection descriptor only
-> COMMANDER:CanMission
-> COMMANDER:RecruitAssetsForMission
-> MOOSE-selected provider/asset
-> identity-only handoff
-> existing long-lived Functional ARTY owner
-> AssignTargetCoord
-> OpenFire / CeaseFire
-> selection reservation release
-> accepted M1083 rearm service on the same ARTY owner
-> CampaignState consumption/completion
-> MOOSE ARTY support return
-> Warehouse return-to-stock
```

Der Selection-`AUFTRAG` darf nicht ueber `COMMANDER:AddMission` gequeued werden und darf keinen zweiten `FireAtPoint`-Owner erzeugen.

## 2. Lifecycle-Inheritance-Gate

| Feld | A10-Vertrag |
|---|---|
| inherited_contract | Functional ARTY + Fixed Fire Support Rearm Acceptance 2-11 |
| accepted_source_paths | `scripts/ground/OMW_FobAttackFunctionalArtyDispatchAdapter.lua`; `scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua`; `scripts/ground/OMW_FixedFireSupportAmmoSupport.lua`; `scripts/ground/OMW_GroundAmmoRearmAdapter.lua` |
| evidence | source/build `d52a47a418fe3a1a996a5b68198b8dc033ff86c4`; bundle `CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B`; mission `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620`; DCS `2.9.28.26385 MT`; pinned MOOSE |
| invariants | one long-lived Functional ARTY fire/rearm owner; no parallel AUFTRAG FireAtPoint owner; `startArty=false` for rearm after firing; CampaignState remains strategic resource authority; MOOSE ARTY owns physical M1083 rearm/return movement |
| reuse_mode | DIRECT_REUSE + MINIMAL_ADAPTER |
| harness_role | trigger demand/rearm stimulus, observe events/state, correlate IDs, assert; no fire/rearm state machine |
| changed_boundary | MOOSE COMMANDER/LEGION selection-only recruitment -> exact existing Functional ARTY identity |
| owner_approval | owner approved the selection -> existing Functional ARTY architecture on 22.09.2026; no further representation choice is inferred here |
| revalidation_scope | selection reservation, exact identity handoff, physical fire, reservation release, and unchanged accepted M1083 compatibility |
 
## 3. Testmission-Provenienz fuer den Preflight

Owner-provided artifact:

```text
OMW_Template_v25_GroundWorks_base(1).miz
SHA-256:
8C989DC531D1CCE30EF183F59874A6809B5C11D11932D893CD55ADAC3191D247
```

Embedded MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Relevante vorhandene Mission-Editor-Gruppen:

```text
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2

TPL_BLUE_GND_SUP_M1083

WH_BLUE_GND_BOSTICK
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_HONAKER

ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY

BadGuys_A3_BOSTICK
BadGuys_A3_WRIGHT
BadGuys_A3_FORTRESS
BadGuys_A3_HONAKER
```

Diese Namen belegen vorhandene physische Fixtures in genau diesem Artefakt; sie begruenden noch keine neue Production-Konfiguration.

## 4. Gepinnter MOOSE-Source-Check

Fuer die neue Selection-Grenze sind source-verifiziert:

```text
AUFTRAG:NewARTY(...)
COMMANDER:CanMission(...)
COMMANDER:RecruitAssetsForMission(...)
LEGION.RecruitCohortAssets(...)
LEGION.UnRecruitAssets(...)
ARTY:AssignTargetCoord(...)
ARTY:RemoveTarget(...)
ARTY OnAfterOpenFire
ARTY OnAfterCeaseFire
ARTY OnAfterDead
```

Zusatzbefund des A10-Preflights:

```text
BRIGADE:AddPlatoon(...)
-> BRIGADE:AddAssetToPlatoon(...)
-> WAREHOUSE:AddAsset(...)

WAREHOUSE:onafterAddAsset:
"If the group is alive, it is destroyed."
```

Damit ist die bereits aktive Functional-ARTY-Batterie nicht ohne Lifecycle-Aenderung als neuer Warehouse-Stock fuer COMMANDER/LEGION-Recruitment registrierbar.

`COHORT:GetMissionRange(WeaponTypes)` addiert `engageRange` und registrierte WeaponRange-Daten. `COHORT:SetMissionRange(...)` ist ein Missionsradius, kein automatisch aus DCS ausgelesener Waffenreichweitenbeweis. A10 darf deshalb keine angeblichen L118-/2B11-Waffenreichweiten erfinden.

## 5. Preflight-Blocker

Die aktuelle Mission hat eine physische Fixed-Fire-Support-Ebene. Fuer den Selection-only-Vertrag fehlt dagegen eine owner-approved MOOSE-Recruitment-Repräsentation, die

```text
MOOSE can reserve/select
AND
maps one-to-one to the existing physical Functional ARTY battery
AND
does not destroy, respawn or duplicate that battery
AND
does not become a second strategic/physical resource owner
```

erfuellt.

Eine A10-Harness-Implementierung jetzt waere daher entweder ein Lifecycle-Verstoss oder wuerde eine neue Architekturentscheidung stillschweigend treffen.

## 6. Nicht zulaessige Abkuerzungen

```text
active battery -> BRIGADE:AddPlatoon -> WAREHOUSE:AddAsset
  # destroys the live group

destroy -> respawn same battery
  # observable physical lifecycle mutation

unrelated dummy group -> claim exact ARTY asset identity
  # false identity / shadow resource

custom nearest-battery selector
  # bypasses approved COMMANDER/LEGION selection without owner exception

OPSGROUP:SetRearmOnOutOfAmmo
  # different rearm lifecycle; accepted M1083/CampaignState evidence does not transfer
```

## 7. Owner-Entscheidung und implementierte Option A

Owner decision 25.09.2026: **A**.

```text
one fixed physical battery
<-> one unspawned MOOSE selection descriptor asset
<-> one descriptor PLATOON
<-> one exact Functional ARTY owner
```

Implemented production source:

```text
scripts/campaign/OMW_FireSupStratResupply_ArtySelectionDescriptorRegistry.lua
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-DESCRIPTOR-REGISTRY-1
```

The registry uses an ARTY-only dedicated selection COMMANDER. It never queues the descriptor AUFTRAG and rejects any descriptor that is already physically spawned.

Mission Editor contract still required before the A10 runtime harness can be released:

```text
four separate late-activation/non-alive descriptor template groups
one per Bostick/Wright/Fortress/Honaker fixed battery
not the live battery groups themselves
```

The exact ARTY min/max selection ranges are also still configuration data and must be explicitly established; no L118/2B11 range is guessed by the Base.

## 8. Geplanter PASS nach Aufloesung des Blockers

PASS darf erst nach realer DCS-Evidenz fuer mindestens folgende Punkte entstehen:

```text
1. multiple eligible ARTY provider representations exist
2. MOOSE performs the operational selection/reservation
3. selected identity maps unambiguously to one existing Functional ARTY owner
4. no COMMANDER:AddMission / AUFTRAG FireAtPoint owner exists for that battery
5. Functional ARTY OpenFire occurs
6. real ammunition decreases
7. Functional ARTY CeaseFire occurs
8. selection reservation is released exactly at the terminal fire-selection state
9. accepted M1083 rearm is requested on the same ARTY instance
10. CampaignState GROUND_AMMO_PACKAGE consumption is committed exactly once
11. ARTY OnAfterRearmed completes the transaction
12. physical M1083 returns under the accepted MOOSE ARTY lifecycle
13. support is returned to Warehouse stock
14. restored artillery ammunition is observed
15. harness only triggers/observes/asserts
```

## 9. Status

```text
Production Base 26 local build: VERIFIED by owner output
ARTY selection-only source: SOURCE_IMPLEMENTED
unit/CI: PASS at d2d7c69491d175721b1c18ad3f419730fa7b31ba
A10 mission preflight: COMPLETE
A10 Option-A descriptor source: IMPLEMENTED / DCS_PENDING
A10 runtime harness: NOT RELEASED until ME descriptor templates + explicit range configuration exist
A10 DCS status: BLOCKED_ON_DESCRIPTOR_FIXTURE_AND_RANGE_CONFIG
Strategic Resupply: NOT STARTED; waits for ARTY closure
```
