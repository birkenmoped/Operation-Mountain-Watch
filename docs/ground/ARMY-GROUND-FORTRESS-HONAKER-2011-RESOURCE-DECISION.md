---
document_id: OMW-ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW 2011 working installation classification for COP Fortress and COP Honaker-Miracle
  - OMW CampaignState initial resource quantities for Fortress and Honaker-Miracle
  - evidence-to-design boundary for their personnel and vehicle quantities
  - correction of earlier Honaker fixed-artillery assumptions inside the 2010-08-01/2011-12-31 scenario period
not_authoritative_for:
  - exact historical daily property-book inventories
  - exact historical daily personnel rosters
  - final Mission Editor physical object counts
  - DCS runtime acceptance beyond cited acceptance results
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - Fortress/Honaker quantity-open clauses in OMW-ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION
  - Fortress/Honaker vehicle quantity clauses in OMW-ARMY-GROUND-VEHICLE-BASELINE
  - Honaker dependent-only resource clauses in OMW-ARMY-GROUND-RESOURCE-QUANTITY-SETTLEMENT
  - Honaker 2 x M777A2 July-2011 fixed-fire-support assumption in current Ground Foundation documents
---

# Fortress / Honaker-Miracle 2011 Resource Decision

## 1. Decision scope

This decision closes the remaining permanent resource-property-book gap for the two Kunar operational domains that were already technically validated as independent MOOSE materialization domains:

```text
COP Fortress
COP Honaker-Miracle
```

The decision does not claim exact historical property-book numbers. It converts the best available in-period evidence into explicit OMW CampaignState design quantities.

The authority boundary remains:

```text
historical evidence
-> supported role / scale / observed minimum
-> OMW design quantity
-> CampaignState strategic authority
-> MOOSE/DCS temporary physical representation
```

## 2. Evidence handling

Evidence classes used for this decision:

```text
PRIMARY_RECORD
  official Army/DoD/DVIDS/NARA material and declassified operational records

DATED_VISUAL_PRIMARY
  contemporaneous dated photo/video/satellite evidence for visible physical state

SUPPORTED_INFERENCE
  bounded inference from multiple primary records and physical footprint

OMW_DESIGN_VALUE
  explicit project quantity selected from the supported range; not claimed as an exact historical inventory
```

Social-media comments and Wikipedia-style compilations may support discovery only. They are not sole authority for hard facts.

## 3. COP Fortress

### 3.1 Classification and 2011 role

For the OMW scenario period the canonical installation class is corrected to:

```text
canonical display name: COP Fortress
canonical installation class: COP
historical source variants: Combat Outpost Fortress / COP Fortress / FOB Fortress
location: Chawkay/Chowkay District, Kunar
```

The historical naming variance does not change the resource model.

Confirmed 2011 operational evidence includes:

```text
64th Military Police Company contingent assigned/based at COP Fortress in January 2011
~9 months assignment duration reported by January 2011
~100 enemy contacts reported for that contingent over that period
B Company, 2-327 Infantry / TF No Slack operational presence in March 2011
hostile mortar attacks on COP Fortress in March 2011
protected/armored wheeled mobility
105-mm howitzer capability physically based/assigned at Fortress
mortar capability
rotary-wing/CH-47 access
local support/logistics function
```

The exact friendly mortar caliber/model and exact 105-mm howitzer model are not asserted here.

### 3.2 Vehicle evidence

The September-2011 satellite image shows approximately sixteen or more vehicle-sized objects distributed through the installation. Individual objects cannot all be typed reliably from satellite resolution.

Therefore:

```text
historically observed physical footprint: approximately >=16 vehicle-sized objects
exact historical property-book inventory: unknown
OMW strategic VEHICLE value: 18
```

The OMW value includes protected patrol vehicles, utility/command vehicles and local support/logistics vehicles. It must not be read as `18 x M-ATV`.

### 3.3 Personnel evidence

Earlier direct reporting documents an installation occupancy on the order of 150-200 personnel. 2011 sources also show overlapping infantry and MP components. No exact daily July-2011 roster is available.

`PERSONNEL` is the OMW taskable Ground pool, not total historical base population.

```text
OMW strategic PERSONNEL value: 160
```

### 3.4 Fortress CampaignState initial stock

```yaml
groundNodeId: GROUND_NODE_FORTRESS
supplyParent: GROUND_NODE_JALALABAD
resources:
  PERSONNEL: 160
  VEHICLE: 18
  SUPPLY: 44
  AMMO: 48
  FUEL: 40
```

`SUPPLY`, `AMMO` and `FUEL` are normalized OMW logistics units, not historical tonnage/liter claims. Fortress receives a comparatively strong AMMO value because its 2011 role includes sustained combat, mortar capability and confirmed local 105-mm artillery capability.

## 4. COP Honaker-Miracle

### 4.1 Classification and 2011 role

```text
canonical display name: COP Honaker-Miracle
canonical installation class: COP
location: Dara-I-Pech / Pech River Valley, Kunar
```

Confirmed 2011 operational evidence includes:

```text
D Company, 2-35 Infantry / TF Cacti presence
retained U.S. position through the Pech realignment
staging-ground role for Operation Hammer Down
local mounted operations
MRAP/recovery vehicle activity tied back to Honaker
local mortar capability visible in 2011 media
>=3 protected tactical vehicles simultaneously visible in May 2011 media
```

The January-2010 satellite image shows approximately seventeen vehicle-sized objects and two objects consistent with a prepared gun position. This supports site scale and vehicle-footprint reconstruction but does not prove continuation of a specific artillery system into 2011.

### 4.2 Correction of the earlier M777 assumption

Earlier Ground Foundation documents treated `2 x M777A2 at Honaker on 30.07.2011` as confirmed. The current reconciliation does not support that date-specific claim.

Accordingly:

```text
2 x M777A2 at Honaker in July 2011: NOT A CURRENT OMW HARD FACT
Jan-2010 possible two-gun position: OBSERVED, TYPE/CONTINUITY UNRESOLVED
2012 M777 imagery/evidence: OUTSIDE OMW SCENARIO PERIOD
2011 local mortar capability: CONFIRMED
2011 external regional artillery support: CONFIRMED IN PRINCIPLE
exact Honaker-specific external firing base: NOT FIXED BY THIS DECISION
```

No fixed M777/L118 CampaignState or Mission Editor requirement may be derived from the superseded July-2011 assumption.

### 4.3 Honaker CampaignState initial stock

The 2010 physical vehicle footprint, 2011 protected-vehicle media, D Company operational presence, staging role and mounted/recovery activity support an independent local strategic pool.

```yaml
groundNodeId: GROUND_NODE_HONAKER
supplyParent: GROUND_NODE_JOYCE
resources:
  PERSONNEL: 120
  VEHICLE: 18
  SUPPLY: 40
  AMMO: 40
  FUEL: 36
```

Interpretation:

```text
PERSONNEL 120 = OMW taskable Ground pool; not an asserted daily historical headcount
VEHICLE 18   = OMW design value supported by site footprint and 2011 local vehicle operations
SUPPLY 40    = normalized sustained-COP support capacity
AMMO 40      = normalized high-contact / mortar-capable COP ammunition capacity
FUEL 36      = normalized mounted-operations fuel capacity
```

Honaker remains strategically supported by Joyce but is no longer modeled as a zero-vehicle dependent-only installation.

## 5. Parent/support semantics

```text
GROUND_NODE_FORTRESS
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_HONAKER
  supplyParent = GROUND_NODE_JOYCE
```

A supply parent is not a second resource authority and does not force every physical convoy to originate there.

Both nodes now own their local CampaignState resource pools. MOOSE WAREHOUSE/BRIGADE remains operational only.

## 6. Settlement contract

The validated Ground settlement rules apply unchanged to both new root-stock nodes:

```text
1 M-ATV test/mission correlation = 1 VEHICLE + 3 PERSONNEL
confirmed return, including damaged survivor -> immediate one-time availability credit
confirmed loss -> permanent loss
open nonterminal commitment at server stop/crash -> one-time strategic recredit at next start
no physical DCS/MOOSE continuation or respawn
```

No new resource authority is introduced.

## 7. Production gate

The production stock may be extended with `GROUND_NODE_FORTRESS` and `GROUND_NODE_HONAKER` only together with a dedicated acceptance that proves:

```text
single CampaignState composition remains intact
all six Ground root-stock nodes materialize in CampaignState
Fortress and Honaker initial values match this decision
existing AirOps/AAR/Ground values remain unchanged
existing exactly-once Ground settlement adapter works on both new nodes
no new MOOSE behavior or private override is introduced
```

DCS validation remains required before the new six-node production baseline is marked `VALIDATED`.
