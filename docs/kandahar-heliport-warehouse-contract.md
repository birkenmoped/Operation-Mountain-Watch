---
document_id: OMW-AIR-KANDAHAR-HELIPORT-WAREHOUSE
status: BINDING_RUNTIME_VALIDATED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Heliport warehouse name
  - Kandahar Heliport AIRWING identifier
  - Kandahar Heliport historical owner
  - Kandahar Heliport warehouse Mission Editor anchor
  - Kandahar Heliport warehouse runtime association
  - Kandahar dual-airbase warehouse boundary
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(4).miz
source_mission_sha256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
validated_in_dcs: true
validation_result: mission/tests/kandahar-air-operations/results/2026-07-31-kandahar-heliport-warehouse-pass.md
supersedes:
  - Kandahar Heliport warehouse name unapproved
  - Kandahar Heliport warehouse anchor missing
  - Kandahar Heliport warehouse structurally present but unvalidated
  - Kandahar Heliport AIRWING name unresolved
  - generic AW_US_KANDAHAR_HELI proposal
---

# Kandahar Heliport Warehouse and AIRWING Contract

## 1. Binding identifiers

The Mission Editor revision and DCS/MOOSE acceptance establish the warehouse identifier:

```text
WH_AIR_US_KANDAHAR_HELI
```

The July-2011 ORBAT establishes the Army-Aviation parent formation at Kandahar as:

```text
Task Force Thunder / 159th Combat Aviation Brigade
```

The binding technical AIRWING identifier is therefore:

```text
AW_US_KAF_159_CAB_TF_THUNDER
```

Assignment:

```text
Historical owner: Task Force Thunder / 159th Combat Aviation Brigade
Native airbase: AIRBASE.Afghanistan.Kandahar_Heliport
DCS airbase ID: 15
Operational area: Mustang Ramp / Army Aviation
Warehouse: WH_AIR_US_KANDAHAR_HELI
```

The historical July-2011 source calls the location `Kandahar Airfield`. `Kandahar Heliport` is the separate native DCS airbase used by OMW to represent the Mustang Ramp.

## 2. Accepted Mission Editor and runtime object

Structural introduction:

```text
Mission: OMW_Template_v4_Kandahar(3).miz
SHA-256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
```

Runtime acceptance mission:

```text
Mission: OMW_Template_v4_Kandahar(4).miz
Size: 2,183,450 bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

Accepted object contract:

```text
Object name: WH_AIR_US_KANDAHAR_HELI
Object type: container_20ft
Coalition: Blue / 2
Country: USA
Mission x: -269017.36991617
Mission y: -30083.822007576
Runtime x: -269017.4
Runtime y/altitude: 1016.0
Runtime z: -30083.8
```

The anchor is a technical AIRWING/WAREHOUSE object. Its physical container size does not define inventory capacity.

## 3. Accepted dual-airbase boundary

```text
Kandahar Main Airfield
AIRBASE.Afghanistan.Kandahar
DCS airbase ID: 7
Historical USAF parent: 451st Air Expeditionary Wing
Technical AIRWING: AW_US_KAF_451_AEW
Warehouse: WH_AIR_US_KANDAHAR
Warehouse type: container_40ft

Kandahar Heliport / Mustang Ramp
AIRBASE.Afghanistan.Kandahar_Heliport
DCS airbase ID: 15
Historical Army parent: Task Force Thunder / 159th Combat Aviation Brigade
Technical AIRWING: AW_US_KAF_159_CAB_TF_THUNDER
Warehouse: WH_AIR_US_KANDAHAR_HELI
Warehouse type: container_20ft
```

The two warehouse anchors must never be bound to the wrong native airbase.

Unit-name evidence and the active-versus-historical distinction are documented in:

- [`Kandahar Juli-2011 ORBAT Unit Name Reconciliation`](evidence/kandahar-july-2011-orbat-unit-name-reconciliation.md)

## 4. Runtime acceptance result

The dedicated read-only DCS/MOOSE diagnostic passed:

```text
BuilderVersion: KAF-HELIPORT-WAREHOUSE-NOSPAWN-1
Builder GitCommit: 6bdc92625e6fe92bc7b0c3b29bc27193c75bdfa7
Result: PASS
```

Confirmed in runtime:

```text
Kandahar Main resolves as ID 7 / Airdrome
Kandahar Heliport resolves as ID 15 / Helipad
exactly one WH_AIR_US_KANDAHAR object
exactly one WH_AIR_US_KANDAHAR_HELI object
Main warehouse type container_40ft / coalition 2
Heliport warehouse type container_20ft / coalition 2
```

Accepted Heliport association:

```text
Nearest Kandahar Heliport TerminalID: 60
TerminalType: 40
Distance: 149.63 m
Kandahar Heliport parking count: 86

Nearest Kandahar Main TerminalID: 90
TerminalType: 72
Distance: 722.85 m
Kandahar Main parking count: 316
```

The Heliport anchor is correctly associated with Kandahar Heliport, does not overlap a parking node, and is substantially farther from Main-Airfield parking.

No AIRWING, SQUADRON, SPAWN, AUFTRAG or OPSTRANSPORT object was constructed during this acceptance. No parking mutation occurred.

Full evidence:

- [`2026-07-31-kandahar-heliport-warehouse-pass.md`](../mission/tests/kandahar-air-operations/results/2026-07-31-kandahar-heliport-warehouse-pass.md)

## 5. Bound Heliport SQUADRON names

```text
SQ_US_KAF_AH64_4_227_AVN
Task Force Guns / 4-227 Attack Aviation

SQ_US_KAF_OH58D_7_17_CAV
Task Force Palehorse / 7-17 Air Cavalry

SQ_US_KAF_CH47_7_101_GSAB
Task Force Lift / 7-101 General Support Aviation

SQ_US_KAF_UH60_7_101_GSAB
Task Force Lift / 7-101 General Support Aviation
```

`3-101 Attack Aviation / Task Force Attack` is not a Kandahar Heliport SQUADRON. The July-2011 ORBAT places that unit at FOB Tarin Kowt.

## 6. Fail-closed rules for later runtime implementation

`AW_US_KAF_159_CAB_TF_THUNDER` may start only if:

```text
WH_AIR_US_KANDAHAR_HELI resolves exactly once
it resolves as a STATIC object
its type remains container_20ft
its coalition remains Blue / 2
Kandahar Heliport remains native airbase ID 15
warehouse-to-airbase association remains valid
all four bound SQUADRON names are configured
all required templates, inventories and parking contracts pass
```

Any missing, duplicate, mistyped or wrongly assigned warehouse, AIRWING, SQUADRON or airbase must block startup.

## 7. Remaining blockers

```text
regional Kandahar/RC-South Army Aviation parent inventory
Tarinkot and other forward-detachment deductions
productive AH-64D, OH-58D, CH-47F and UH-60A inventories
OH-58D APKWS period decision
Safe-Parking allow-/blocklists
controlled-spawn acceptance
```

The warehouse-name, missing-anchor and AIRWING-name blockers are closed. This contract does not by itself authorize an AIRWING start or SQUADRON inventory registration.