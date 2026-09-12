---
document_id: OMW-RESULT-PRODUCTION-BASE-ACCEPTANCE1-LOCAL-BUILD
status: ACCEPTED_TECHNICAL_BASELINE
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-local build evidence for production-base Acceptance 1
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 7f69d0ca532e328f67a88b2948d61bbd456a19e6
validated_in_dcs: false
---

# Production Base Acceptance 1 - lokaler Buildnachweis

Der Projektinhaber hat den Acceptance-1-Builder auf Commit `7f69d0ca532e328f67a88b2948d61bbd456a19e6` lokal ausgefuehrt.

```text
ProductionBuilderSHA256: D12E7F545B3BE0CD425B2AC26A9998C998A7AE7E3AC5887E53DFF99F1BDC248C
ProductionBundleSHA256: B88935BCE655726D3E7BE10ECE2013E0A3E87761E3241F7CCED2C6BB27D7831C
AcceptanceSourceSHA256: 7101E4A3B15441A0CDD841C3F98C7CC82A4B6E36E8615066D8A1DF16D16491B8
AcceptanceBuilderSHA256: E43B516205E4132CC56442E9666643E014D132B46DD1EAF0D155187EAFF631B2
AcceptanceBundleSHA256: 5B6E7CCECCA143CB93A5B5158EEEB53B8D6D93E382DDC1A7458FAF09A6E25EDF
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
MizMutation: false
```

Die unabhaengigen `Get-FileHash`-Pruefungen stimmen mit der Builder-Ausgabe ueberein. Nach dem Build waren nur generierte, untracked `dist/`-Verzeichnisse vorhanden; versionierte Source-Dateien und `.miz` wurden nicht veraendert.

Erzeugtes Acceptance-Artefakt:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_1.lua
```

Dieser Nachweis belegt Build und Hash-Provenienz, nicht DCS-Runtime-Verhalten.
