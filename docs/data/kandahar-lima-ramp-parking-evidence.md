---
document_id: OMW-DATA-KANDAHAR-LIMA-RAMP-PARKING-EVIDENCE
status: BINDING
document_class: DATASET_DOCUMENTATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Lima Ramp parking static derivation for the documented source mission
  - extension of the validated Kandahar ME parking to MOOSE TerminalID dataset
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: GIT_HISTORY
validated_in_dcs: partial
---

# Kandahar Lima Ramp – ME parking_id to MOOSE TerminalID

## Status

This note extends the Kandahar parking baseline with the Mission Editor parking IDs `L01-H` through `L15-H` from `OMW_Template_v8_Kandahar_Parkplatz.miz`.

The values were extracted statically from the mission file as `unit.parking_id` and `unit.parking` pairs. They were not obtained from a second DCS runtime correlation.

That derivation is accepted for this unchanged DCS/Afghanistan/MOOSE parking schema because the documented 12.08.2026 Kandahar correlation test established `unit.parking == MOOSE TerminalID` for every prepared Kandahar Main and Kandahar Heliport marker in the tested set: 376/376 exact matches, 0 failures.

This evidence must not be generalized to another DCS version, Afghanistan map revision, or changed airbase parking schema without renewed verification.

## Source mission

```text
MIZ: OMW_Template_v8_Kandahar_Parkplatz.miz
SHA-256: bacf687b1fc300ee07ba6e29673728b223d75a6371acbf4ac279916397f93d82
Extraction date: 2026-08-12
Node: Kandahar Main
```

## Lima Ramp mapping

| ME parking_id | .miz unit.parking | Project MOOSE TerminalID |
|---|---:|---:|
| `L01-H` | 66 | 66 |
| `L02-H` | 190 | 190 |
| `L03-H` | 111 | 111 |
| `L04-H` | 158 | 158 |
| `L05-H` | 73 | 73 |
| `L06-H` | 14 | 14 |
| `L07-H` | 60 | 60 |
| `L08-H` | 274 | 274 |
| `L09-H` | 145 | 145 |
| `L10-H` | 191 | 191 |
| `L11-H` | 168 | 168 |
| `L12-H` | 125 | 125 |
| `L13-H` | 148 | 148 |
| `L14-H` | 176 | 176 |
| `L15-H` | 21 | 21 |

The suffix `-H` is part of the Mission Editor parking label. These parking positions belong to the Kandahar Main airbase node and are not part of the separate `Kandahar Heliport` DCS/MOOSE node.

The machine-readable project baseline is:

- `docs/data/kandahar-me-parking-to-moose-terminalid.csv`

Occupied CLIENT positions from the same source mission are documented separately in:

- `docs/data/kandahar-client-parking-evidence.md`

The combined CSV now contains 401 mappings total: 315 Kandahar Main entries and 86 Kandahar Heliport entries. Of these, the original 376 mappings are runtime-correlated evidence; the 15 Lima Ramp mappings and 10 occupied CLIENT mappings are static derivations from the same validated parking-number relationship.
