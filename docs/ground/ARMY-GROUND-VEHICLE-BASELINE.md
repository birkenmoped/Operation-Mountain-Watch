---
document_id: OMW-ARMY-GROUND-VEHICLE-BASELINE
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working OMW vehicle design quantities for the current Jalalabad/Kunar Ground Foundation nodes
  - evidence-to-design reconstruction method where exact local inventories are unavailable
  - family-level composition for Jalalabad, Joyce, Wright and Bostick
not_authoritative_for:
  - exact historical daily property-book inventories
  - exact Fortress/Honaker vehicle-family split
  - fixed artillery inventories
  - final Mission Editor object state
  - accepted DCS runtime behavior beyond cited acceptance documents
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - zero-vehicle Honaker working baseline
  - fixed 2 x M777A2 Honaker vehicle-baseline assumption
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
---

# ARMY Ground Foundation – Working Vehicle Baseline

## 1. Zweck und Autoritätsgrenze

OMW benötigt konkrete strategische Fahrzeugmengen, obwohl für die Forward Sites keine vollständigen tagesgenauen Property Books verfügbar sind.

```text
historical evidence
-> confirmed minimum / supported physical footprint
-> role and operational demand
-> explicit OMW design value
-> CampaignState VEHICLE authority
```

`OMW_DESIGN_VALUE` ist eine Kampagnendesignentscheidung und keine Behauptung eines historisch exakt gezählten Tagesbestands.

Für Fortress und Honaker ist die maßgebliche Mengenentscheidung:

```text
docs/ground/ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION.md
```

## 2. Reconciled six-node vehicle baseline

| Installation | OMW VEHICLE | Evidence/design boundary | Status |
|---|---:|---|---|
| Jalalabad / FOB Fenty | **48** | regional hub, logistics and security demand | `OMW_DESIGN_VALUE` |
| COP Fortress | **18** | Sep-2011 ~16+ vehicle-sized physical footprint plus 2011 protected mobility | `OMW_DESIGN_VALUE` |
| FOB Joyce | **20** | TF Cacti node, patrol/QRF/logistics evidence | `OMW_DESIGN_VALUE` |
| FOB Wright | **22** | SECFOR/PRT/support role and protected mobility | `OMW_DESIGN_VALUE` |
| COP Honaker-Miracle | **18** | Jan-2010 ~17 vehicle-sized footprint plus 2011 protected/mounted/recovery evidence | `OMW_DESIGN_VALUE` |
| FOB Bostick | **26** | battalion/task-force node, patrol/QRF/OP support | `OMW_DESIGN_VALUE` |

For Fortress and Honaker the exact historical vehicle-family composition remains unknown. `18 VEHICLE` must not be read as `18 x M-ATV`.

## 3. Existing family-level composition

### Jalalabad / FOB Fenty – 48

```text
16 protected light mobility / M-ATV class
14 protected MRAP / MaxxPro class
12 medium logistics / FMTV-M1083 class
 2 M978 HEMTT fuel-support
 4 utility / HMMWV class
--
48 total
```

Foundation mapping:

```text
16 CHAP_MATV
14 MaxxPro_MRAP
12 CHAP_M1083
 2 M978 HEMTT Tanker
 4 Hummer
```

### FOB Joyce – 20

```text
8 protected light mobility / M-ATV class
6 protected MRAP / MaxxPro class
4 medium logistics / FMTV-M1083 class
2 utility / HMMWV class
--
20 total
```

Foundation mapping:

```text
8 CHAP_MATV
6 MaxxPro_MRAP
4 CHAP_M1083
2 Hummer
```

### FOB Wright – 22

```text
8 protected light mobility / M-ATV class
8 protected MRAP / MaxxPro class
4 medium logistics / FMTV-M1083 class
2 utility / HMMWV class
--
22 total
```

Four MaxxPro slots remain assigned to `ENGINEER / ROUTE SUPPORT SECURITY`; this does not assert a DCS mine-clearing capability.

### FOB Bostick – 26

```text
10 protected light mobility / M-ATV class
 8 protected MRAP / MaxxPro class
 6 medium logistics / FMTV-M1083 class
 2 utility / HMMWV class
--
26 total
```

The recovery/support role remains abstracted through the M1083 family; DCS towing is not asserted.

## 4. Fortress and Honaker family split

The strategic quantity is decided, but the exact internal family split is not.

### COP Fortress

Confirmed/supported evidence includes protected/armored wheeled mobility, documented HMMWV-class use in the wider Fortress/MP context, and a Sep-2011 physical footprint of approximately sixteen or more vehicle-sized objects.

```text
CampaignState VEHICLE = 18
exact M-ATV / MRAP / HMMWV / logistics split = OPEN
```

### COP Honaker-Miracle

Confirmed/supported evidence includes protected tactical vehicles visible in May 2011 media, MRAP/recovery activity tied back to Honaker and the larger site vehicle footprint visible in Jan-2010 imagery.

```text
CampaignState VEHICLE = 18
exact M-ATV / MRAP / utility / recovery split = OPEN
```

No fixed artillery asset is counted as `VEHICLE` for either node.

## 5. Honaker artillery correction

The previous vehicle-baseline claim

```text
0 permanent wheeled vehicles
2 x M777A2 fixed artillery pieces historically confirmed on 30.07.2011
2 x L118_Unit planned proxy
```

is superseded.

Current contract:

```text
Honaker VEHICLE = 18 OMW design value
2011 local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside OMW scenario period
no fixed M777/L118 production requirement
```

## 6. Strategic versus physical representation

```text
CampaignState VEHICLE stock
!= all vehicles visible simultaneously
!= parked decorative vehicles
!= MOOSE Warehouse asset count
```

A node stock may later be represented as:

```text
fixed/local physical representation
operational reserve
active mission commitment
maintenance/unavailable fraction
virtual strategic reserve
```

No representation category may create additional strategic vehicles outside CampaignState.

## 7. Transient convoys

An arriving parent/theater convoy does not automatically become local organic stock.

```text
transient transport vehicle
-> remains bound to transfer / parent contract
-> delivers cargo
-> returns or is explicitly reassigned
```

Only explicit CampaignState settlement changes strategic ownership.

## 8. Acceptance state

Acceptance 9-2 validates the six-node CampaignState vehicle quantities and settlement path for Fortress/Honaker:

```text
acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
result: PASS
```

The exact Fortress/Honaker family split and additional specialized vehicle mappings remain separate later decisions.
