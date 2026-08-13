---
document_id: OMW-DATA-KANDAHAR-CLIENT-PARKING-EVIDENCE
status: BINDING
document_class: DATASET_DOCUMENTATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar occupied CLIENT parking static derivation for the documented source mission
  - extension of the validated Kandahar ME parking to MOOSE TerminalID dataset
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: GIT_HISTORY
validated_in_dcs: partial
---

# Kandahar occupied CLIENT parking – ME parking_id to MOOSE TerminalID

## Status

This note extends the Kandahar parking baseline with parking positions occupied by OMW CLIENT aircraft in `OMW_Template_v8_Kandahar_Parkplatz.miz`.

The values were extracted statically from each CLIENT unit as the pair `unit.parking_id` and `unit.parking`. They were not obtained from a second DCS runtime correlation.

That derivation is accepted for this unchanged DCS/Afghanistan/MOOSE parking schema because the documented 12.08.2026 Kandahar correlation test established `unit.parking == MOOSE TerminalID` for every prepared Kandahar Main and Kandahar Heliport marker in the tested set: 376/376 exact matches, 0 failures.

This evidence must not be generalized to another DCS version, Afghanistan map revision, or changed airbase parking schema without renewed verification.

## Source mission

```text
MIZ: OMW_Template_v8_Kandahar_Parkplatz.miz
SHA-256: bacf687b1fc300ee07ba6e29673728b223d75a6371acbf4ac279916397f93d82
Extraction date: 2026-08-12
```

## Kandahar Main CLIENT parking

| CLIENT group | Type | ME parking_id | .miz unit.parking | Project MOOSE TerminalID |
|---|---|---|---:|---:|
| `CLIENT_US_KAF_A10C_01` | A-10C | `Z20` | 282 | 282 |
| `CLIENT_US_KAF_A10C_02` | A-10C | `Z19` | 287 | 287 |
| `CLIENT_US_KAF_C130_01` | C-130J-30 | `S01` | 294 | 294 |
| `CLIENT_US_KAF_C130_02` | C-130J-30 | `S02` | 92 | 92 |

## Kandahar Heliport CLIENT parking

| CLIENT group | Type | ME parking_id | .miz unit.parking | Project MOOSE TerminalID |
|---|---|---|---:|---:|
| `CLIENT_US_KAF_AH64D_01` | AH-64D | `MST38-H` | 30 | 30 |
| `CLIENT_US_KAF_AH64D_02` | AH-64D | `MST30-H` | 19 | 19 |
| `CLIENT_US_KAF_OH58D_01` | OH-58D | `MST01-H` | 80 | 80 |
| `CLIENT_US_KAF_OH58D_02` | OH-58D | `MST11-H` | 23 | 23 |
| `CLIENT_US_KAF_CH47F_01` | CH-47F | `MST75-H` | 4 | 4 |
| `CLIENT_US_KAF_CH47F_02` | CH-47F | `MST82-H` | 47 | 47 |

The machine-readable project baseline is:

- `docs/data/kandahar-me-parking-to-moose-terminalid.csv`

After adding the occupied CLIENT positions, the CSV contains 401 mappings total: 315 Kandahar Main entries and 86 Kandahar Heliport entries. The original 376 marker mappings are runtime-correlated evidence; the 15 Lima Ramp mappings and these 10 occupied CLIENT mappings are static derivations from the same validated parking-number relationship.
