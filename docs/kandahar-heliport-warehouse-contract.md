---
document_id: OMW-AIR-KANDAHAR-HELIPORT-WAREHOUSE
status: BINDING_STRUCTURALLY_PRESENT_UNVALIDATED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Heliport warehouse name
  - Kandahar Heliport warehouse Mission Editor anchor
  - Heliport warehouse runtime validation boundary
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(3).miz
source_mission_sha256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
validated_in_dcs: false
supersedes:
  - Kandahar Heliport warehouse name unapproved
  - Kandahar Heliport warehouse anchor missing
---

# Kandahar Heliport Warehouse Contract

## 1. Binding identifier

The project-owner supplied Mission Editor revision establishes the following warehouse identifier:

```text
WH_AIR_US_KANDAHAR_HELI
```

This name is approved for the technical warehouse anchor assigned to:

```text
AIRBASE.Afghanistan.Kandahar_Heliport
DCS airbase ID: 15
Operational area: Mustang Ramp / Army Aviation
```

The corresponding AIRWING identifier remains unresolved. This document does not invent or approve an AIRWING name.

## 2. Mission Editor object

```text
Mission: OMW_Template_v4_Kandahar(3).miz
Size: 2,187,128 bytes
SHA-256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc

Object name: WH_AIR_US_KANDAHAR_HELI
Object type: container_20ft
Coalition: Blue
Country: USA
Mission x: -269017.36991617
Mission y: -30083.822007576
```

The anchor is a technical AIRWING/WAREHOUSE object. Its physical container size does not define inventory capacity.

## 3. Dual-airbase boundary

The Kandahar architecture remains:

```text
Kandahar Main Airfield
AIRBASE.Afghanistan.Kandahar
WH_AIR_US_KANDAHAR
AW_US_KANDAHAR

Kandahar Heliport / Mustang Ramp
AIRBASE.Afghanistan.Kandahar_Heliport
WH_AIR_US_KANDAHAR_HELI
AIRWING name: still to be approved
```

The two warehouse anchors must never be bound to the wrong native airbase.

## 4. Runtime acceptance required

Before any Heliport AIRWING is constructed, DCS/MOOSE must confirm:

```text
exactly one WH_AIR_US_KANDAHAR_HELI object
object resolves as a STATIC object
DCS type container_20ft
coalition Blue / 2
Kandahar Heliport resolves as ID 15
anchor is closer to Heliport parking than Main-Airfield parking
anchor does not overlap a Heliport parking node
nearest Heliport TerminalID and distance are logged
no AIRWING, SQUADRON, SPAWN, AUFTRAG or OPSTRANSPORT object is created
```

Failure is fail-closed. No Heliport AIRWING may start if the anchor is missing, duplicated, has the wrong type or coalition, or is assigned to the wrong airbase area.

## 5. Remaining blockers

The following decisions remain open after this warehouse addition:

```text
Kandahar Heliport AIRWING name
regional Kandahar/RC-South Army Aviation parent inventory
Tarinkot and other forward-detachment deductions
productive AH-64D, OH-58D, CH-47F and UH-60A inventories
OH-58D APKWS period decision
Safe-Parking allow-/blocklists
controlled-spawn acceptance
```

The warehouse addition resolves only the Heliport warehouse-name and missing-anchor blockers.