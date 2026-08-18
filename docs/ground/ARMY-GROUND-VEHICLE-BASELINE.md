---
document_id: OMW-ARMY-GROUND-VEHICLE-BASELINE
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working OMW design quantities for physically represented ground vehicles at the current Jalalabad/Kunar Ground Foundation nodes
  - evidence-to-design reconstruction method used where exact July-2011 local inventories are unavailable
  - separation between historical minimum evidence, inferred quantity range and explicit OMW design value
not_authoritative_for:
  - exact historical July-2011 property-book inventories
  - final DCS type/proxy mapping
  - final MOOSE BRIGADE or PLATOON topology
  - final Mission Editor object state
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Working Vehicle Baseline

## 1. Purpose

Exact July-2011 vehicle property-book inventories for FOB Fenty/Jalalabad, FOB Joyce, FOB Wright and FOB Bostick are not available in the current evidence base. OMW nevertheless requires concrete physical and strategic vehicle quantities.

The project therefore uses an explicit reconstruction method instead of treating unknown values as zero and instead of presenting estimates as historical fact.

```text
historical evidence
-> confirmed minimum / confirmed capability
-> role and formation demand
-> site capacity and operational demand
-> inferred range
-> explicit OMW design value
```

The selected `OMW_DESIGN_VALUE` is a campaign-design decision. It is not an assertion that a historical property book contained exactly that quantity on a particular day.

## 2. Evidence classes

```text
CONFIRMED_MINIMUM
  directly counted, explicitly reported or physically documented minimum

STRONGLY_SUPPORTED
  repeated direct evidence for the local capability or vehicle family

INFERRED_RANGE
  bounded reconstruction from site role, formation context, physical capacity and operational demand

OMW_DESIGN_VALUE
  explicit working project quantity selected inside the supported range
```

Older OMW-period or pre-OMW evidence may support a capability or lower bound only where the document explicitly says so. It does not silently become a July-2011 inventory.

## 3. Reconstruction inputs

### 3.1 Jalalabad / FOB Fenty

Supported characteristics:

- regional brigade/HQ and logistics hub;
- continuous cargo reception, yard handling and onward distribution documented in spring 2011;
- MRAP gun-truck and up-armored medium-truck logistics traffic documented on Fenty-bound logistics patrols;
- vehicle throughput is substantially larger than a local infantry FOB;
- transient convoy vehicles are excluded from the working organic/representative fleet.

### 3.2 FOB Joyce

Supported characteristics:

- TF Cacti / 2-35 Infantry regional ground node;
- local patrol/QRF requirement;
- fuel-blivet and onward-resupply handling documented in 2011;
- older site-bound SIGACT evidence demonstrates recurring MRAP patrol, EOD/CIED and vehicle-recovery activity;
- older patrol evidence includes a four-MRAP patrol and a Joyce-origin EOD/vehicle-recovery team. These records support capability and scale, not July-2011 ownership of the exact vehicles.

### 3.3 FOB Wright

Supported characteristics:

- July-2011 1-14th Illinois ADT Security Force Platoon;
- PRT/security/FARP/support role;
- substantial protected-vehicle activity across the OMW period;
- older site-bound evidence documents QRF/recovery activity and a convoy associated with Wright in which three MRAPs and one wrecker were damaged;
- the November-2010 attack evidence establishes a substantial protected-vehicle presence but is not converted 1:1 into July-2011 stock;
- historical M777 capability is confirmed for 2010; exact July-2011 artillery assignment remains open.

### 3.4 FOB Bostick

Supported characteristics:

- TF No Fear / 2-27 Infantry battalion/task-force node;
- local patrol/QRF and support requirement for the northern Kunar sector;
- 2011 support personnel from C/277th Aviation Support Battalion are documented at the site;
- older site-bound SIGACT evidence explicitly documents Bostick-origin QRF/recovery activity using a water truck, flatbed/recovery capability, HEMTT wrecker and crane support;
- separate older evidence includes a five-US-vehicle plus two-ETT-vehicle site-bound element and MRAP recovery back to Bostick.

These records demonstrate that recovery and support vehicles were part of the local operational ecosystem; they do not establish an exact July-2011 property-book count.

### 3.5 COP Honaker-Miracle

Supported characteristics:

- two M777A2 of C Battery / 3-321 Field Artillery are directly documented on 30 July 2011;
- vehicles demonstrably reached the COP for operations/recovery/resupply, but no permanent July-2011 wheeled motor pool is established;
- the working baseline therefore does not invent a permanent wheeled fleet merely to populate the COP.

## 4. Working quantity baseline

The following quantities are the current OMW working values for the Ground Foundation. They intentionally remain conservative and are lower than many broad TO&E-based estimates.

| Installation | Inferred wheeled range | OMW working wheeled value | Fixed artillery | Evidence/design status |
|---|---:|---:|---:|---|
| Jalalabad / FOB Fenty | 40–55 | **48** | separate fire-support contract | `OMW_DESIGN_VALUE` |
| FOB Joyce | 16–24 | **20** | none assigned at Joyce by this contract | `OMW_DESIGN_VALUE` |
| FOB Wright | 18–26 | **22** | July assignment still open | `OMW_DESIGN_VALUE` |
| FOB Bostick | 22–30 | **26** | July assignment still open | `OMW_DESIGN_VALUE` |
| COP Honaker-Miracle | 0–2 permanent wheeled | **0** | **2 x M777A2** | wheeled `OMW_DESIGN_VALUE`; artillery `CONFIRMED_MINIMUM` |

These values are not final DCS object counts. A strategic vehicle pool may be larger than the simultaneously physical representation, especially at Jalalabad/Fenty.

## 5. Working vehicle-family composition

Until a stronger July-2011 local type census is available, the working composition uses vehicle families that are historically plausible for the role and already relevant to the current mission/tooling. Exact DCS type/proxy mapping remains a separate acceptance step.

### 5.1 FOB Joyce – 20 wheeled vehicles

```text
8  protected light mobility / M-ATV class
6  protected MRAP / MaxxPro class
4  medium logistics / FMTV-M1083 class
2  utility / HMMWV class
--
20 total
```

### 5.2 FOB Wright – 22 wheeled vehicles

```text
8  protected light mobility / M-ATV class
6  protected MRAP / MaxxPro class
4  medium logistics / FMTV-M1083 class
2  utility / HMMWV class
2  protected engineer / route-support allocation
--
22 total
```

The two engineer/route-support vehicles are a functional allocation only. Specific Buffalo/Husky/Cougar mapping is not approved by this document and requires a stronger site/type evidence review plus DCS availability confirmation.

### 5.3 FOB Bostick – 26 wheeled vehicles

```text
10 protected light mobility / M-ATV class
8  protected MRAP / MaxxPro class
5  medium logistics / FMTV-M1083 class
1  recovery/support allocation
2  utility / HMMWV class
--
26 total
```

The recovery allocation reflects the repeatedly documented local recovery requirement. It is not yet a final DCS HEMTT-wrecker proxy decision.

### 5.4 Jalalabad / FOB Fenty – 48 physically represented wheeled vehicles

```text
16 protected light mobility / M-ATV class
14 protected MRAP / MaxxPro class
10 medium logistics / FMTV-M1083 class
4  heavy logistics / fuel-support allocation
4  utility / HMMWV class
--
48 total
```

`48` is the planned physically represented operational fleet, not the total strategic theater stock associated with Jalalabad. Additional stock may remain virtual in `CampaignState` and may be materialized only when required by a valid mission/resource reservation.

### 5.5 COP Honaker-Miracle

```text
0  permanent wheeled vehicles in the working baseline
2  M777A2 fixed artillery pieces
```

Transient vehicles arriving from Joyce or another valid parent flow do not become Honaker-owned strategic stock merely by entering the COP.

## 6. HMMWV boundary

The current evidence does not support a blanket statement that HMMWV were absent or categorically prohibited at all of these installations in July 2011. OMW therefore retains a small utility/HMMWV allocation at major FOBs while keeping external high-threat patrol roles centered on protected MRAP/M-ATV-class mobility.

This is a design reconstruction, not a claim that the listed HMMWV quantities are historically counted values.

## 7. Strategic versus physical quantity

The working values above primarily describe the maximum local fleet that the Ground Foundation must be able to represent and consume strategically. They do not require every vehicle to be active as a DCS group at mission start.

```text
CampaignState VEHICLE stock
!= all vehicles visible simultaneously
!= parked decorative vehicles
!= MOOSE Warehouse asset count
```

The later runtime contract may divide a node's vehicle allocation into:

```text
fixed/local physical representation
operational reserve
active mission commitment
maintenance/unavailable fraction
virtual strategic reserve
```

No category may create additional strategic vehicles outside `CampaignState`.

## 8. Relationship to transient convoys

A convoy arriving from a parent or theater logistics flow is not automatically added to the destination node's organic fleet.

```text
transient transport vehicle
-> remains bound to transfer / parent contract
-> delivers cargo
-> returns or is reassigned by explicit settlement
```

Only an explicit CampaignState transfer can move a vehicle from one node's strategic pool to another.

## 9. Open verification items

Before final Mission Editor/template acceptance:

- verify the strongest available April–December 2011 visual evidence for M-ATV, MaxxPro, FMTV and HMMWV at Joyce, Wright and Bostick;
- verify whether Wright warrants specific Buffalo/Husky/Cougar route-clearance templates in the July-2011 design baseline;
- verify the best DCS proxy/type for recovery/wrecker capability at Bostick;
- keep Wright and Bostick July-2011 artillery assignments open unless stronger evidence is found;
- map approved historical vehicle families only to DCS type names confirmed in the actually used DCS/mod environment;
- DCS-test road-spawn, pathfinding, mission execution and return behavior before any `VALIDATED` status.

## 10. Current decision boundary

The values in this document are the current working reconstruction for further Ground Foundation design. They can be revised by stronger evidence or an explicit owner design decision without rewriting historical evidence records.

```text
historical evidence remains historical evidence
OMW_DESIGN_VALUE remains a project design decision
DCS runtime acceptance remains a separate test gate
```
