---
document_id: OMW-EVIDENCE-KANDAHAR-ME-AUDIT-V4-3
status: STRUCTURALLY_AUDITED_UNVALIDATED
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW_Template_v4_Kandahar(3).miz file identity
  - Kandahar Heliport warehouse Mission Editor object
  - structural delta from the accepted Kandahar no-spawn mission
source_branch: agent/kandahar-airwing-baseline-contract
validated_in_dcs: false
---

# Kandahar Mission Editor Audit – OMW_Template_v4_Kandahar(3)

## 1. File identity

```text
File: OMW_Template_v4_Kandahar(3).miz
Size: 2,187,128 bytes
SHA-256: 15e63ef55f260ba35fb07bb4c99cc23df7193b595fbdd5be13bc4b8a9b0af0cc
```

Comparison baseline:

```text
File: OMW_Template_v4_Kandahar(2).miz
Size: 2,187,049 bytes
SHA-256: 2d790ec62639037802200c6a8bfacd2a6ab6a2c8f44d8d4d8f64add3717aed81
Runtime result: Kandahar Dual-Airbase No-Spawn Diagnostic PASS
```

## 2. Archive comparison

Both `.miz` archives contain the same eleven archive entries. Only the internal `mission` entry changed. The embedded MOOSE, TM01M, Jalalabad, Bagram and Kandahar diagnostic Lua resources are byte-identical to revision `(2)`.

Structural counters changed by exactly one Mission Editor static group and one unit:

```text
Revision (2): 1,575 groupId entries / 1,614 unitId entries
Revision (3): 1,576 groupId entries / 1,615 unitId entries
Delta:        +1 group / +1 unit
```

The only new non-empty object name is:

```text
WH_AIR_US_KANDAHAR_HELI
```

DCS also rewrote table-key order and the saved Mission Editor map viewport. These serialization differences do not represent additional OMW objects.

## 3. New Heliport warehouse anchor

```text
Group name: WH_AIR_US_KANDAHAR_HELI
Unit name:  WH_AIR_US_KANDAHAR_HELI
Group ID:   1581
Unit ID:    1669
Country:    USA / country ID 2
Coalition:  Blue
Category:   Fortifications
DCS type:   container_20ft
Shape:      container_20ft
Heading:    0.99483767363677 rad
Mission x:  -269017.36991617
Mission y:  -30083.822007576
```

The object is placed on the Kandahar Heliport / Mustang Ramp side of the installation.

Using the previously accepted runtime parking table for `AIRBASE.Afghanistan.Kandahar_Heliport`, the structural coordinate is approximately:

```text
149.7 m from Heliport TerminalID 60
722.8 m from the nearest Kandahar Main parking node
```

This supports the intended Heliport assignment and keeps the technical anchor clear of an actual spawn node. The exact runtime coordinate, type, coalition and nearest terminal must still be confirmed in DCS with the dedicated warehouse no-spawn diagnostic.

## 4. Embedded script state

Revision `(3)` still embeds the previously accepted diagnostic bundle:

```text
BuilderVersion: KAF-DUAL-AIRBASE-NOSPAWN-1
GitCommit: 78031766819fff7f7d62020804a8378423e5ec42
SourceMission: OMW_Template_v4_Kandahar(1).miz
SourceMissionSha256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
```

That embedded bundle predates the new Heliport warehouse contract. It must not be used as acceptance evidence for the new anchor.

## 5. Structural conclusion

The new Mission Editor file is suitable as the next Kandahar source mission. The following contract is structurally present:

```text
Kandahar Main warehouse:
WH_AIR_US_KANDAHAR
container_40ft

Kandahar Heliport warehouse:
WH_AIR_US_KANDAHAR_HELI
container_20ft
```

No AIRWING or SQUADRON runtime acceptance is claimed. The next required proof is a read-only DCS validation of the new Heliport warehouse anchor.