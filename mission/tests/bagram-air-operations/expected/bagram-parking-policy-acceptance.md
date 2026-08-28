---
document_id: OMW-TEST-BAGRAM-PARKING-POLICY-ACCEPTANCE
status: HISTORICAL_TEST_FIXTURE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - historical 2026-08-28 NewAsset lifecycle timing evidence
not_authoritative_for:
  - current production parking allocation
  - current merge acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/bagram-parking-policy-integration
source_commit: 64bce3494cde458636788c208039e9f12278e6a9
acceptance_branch: agent/bagram-parking-policy-integration
acceptance_commit: 64bce3494cde458636788c208039e9f12278e6a9
acceptance_mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
acceptance_mission_sha256: e254cc4e07e1ef1c0c8a46387fa3af27eb9bed6a81cb8a925e39ab25697a7906
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
supersedes:
superseded_by:
---

# Historical Bagram Parking Policy Lifecycle Fixture

This result is retained only for the MOOSE lifecycle timing evidence it actually established.

Exact historical provenance:

```text
Branch: agent/bagram-parking-policy-integration
Source commit: 64bce3494cde458636788c208039e9f12278e6a9
BuilderVersion: BGRAM-AIR-OPS-DUAL-FOUNDATION-5
Generated / embedded bundle SHA-256: AFCBB41CBDB341FD39D2FBD324D6132B02472137650E10FD735FD02866053F3F
Source Lua SHA-256: C6C28EE1805758EB0D48DA0C11028792E3A870C5F8C05C943ABE0D0128E54258
Builder SHA-256: 890BE30E5ADFFC640DBC18ADB14F4A923A87B009F705ABE1C66A777E7DD7545B
Mission SHA-256: E254CC4E07E1EF1C0C8A46387FA3AF27EB9BED6A81CB8A925E39AB25697A7906
Internal mission SHA-256: 0308FBE509E4192FDDAECFA59D8AFD23D0EE7637CE258C36F42739E08A93FC36
Embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.29.27278 MT
DCS log artifact SHA-256: 0802C377CB2EFD5880B4237143AD5D3F2EAE0C36BF27ACB3834AE67AD84D7FE4
Debrief artifact SHA-256: 3A41B46C62FC982010EBBA0C16CA715E9E4A0A966EA8B56CE57B963859BC7F32
```

The run showed that synchronous inspection immediately after `AIRWING:Start()` was too early. The pinned MOOSE path is:

```text
AIRWING:AddSquadron
-> WAREHOUSE:AddAsset
-> delayed WAREHOUSE NewAsset
-> LEGION:onafterNewAsset
-> asset.parkingIDs assignment
-> public AIRWING:OnAfterNewAsset
```

That lifecycle finding remains useful and led to the later `OnAfterNewAsset` validation hook.

However, the parking allocation used by this fixture was later proven incorrect because it had replaced the project owner's per-row CSV allocation with unauthorized contiguous blocks. Therefore this result is not evidence that the old aircraft-to-parking pools were correct.

Current production authority is:

```text
docs/data/bagram-parking-policy.csv
scripts/air-operations/OMW_AirOps_Bagram.lua
tools/build-bagram-air-operations-foundation.ps1
```

The corrected production base is statically reconciled to the owner CSV. No additional DCS parking test is planned by explicit owner decision.
