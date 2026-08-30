---
document_id: OMW-GROUND-NATIVE-HOMEZONE-RETURN-BUILD-CHECKPOINT-1
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_PROVENANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - real local build provenance for the historical Ground Native Homezone Return fixture
not_authoritative_for:
  - DCS runtime validation
  - Fortress Stage 2B Ground return architecture
  - geometric suitability of the native MOOSE Warehouse spawnzone
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 3f8dc517a0a5c4f589b34ae35ee6ac370e5ab9ac
validated_in_dcs: false
---

# Ground Native Homezone Return – Build Checkpoint 1

Dieser historische Checkpoint dokumentiert ausschließlich den realen lokalen Build eines später als ungeeignet eingeordneten Joyce/MATV-Testfixtures. Er ist kein DCS-Runtime-PASS und keine Produktionsbaseline.

```text
GitCommit: 3f8dc517a0a5c4f589b34ae35ee6ac370e5ab9ac
BuilderVersion: GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1-2
TestId: GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1
GeneratedUtc: 2026-08-30T09:48:01Z
OriginWarehouse: WH_BLUE_GND_JOYCE
Template: TPL_BLUE_GND_PATROL_MATV_4
DestinationZone: ZON_BLUE_GND_JOYCE_PATROL_TEST_01
ExpectedDefaultHomezone: Warehouse WH_BLUE_GND_JOYCE spawn zone
MissionType: AUFTRAG.Type.NOTHING
MissionSpeedKts: 27
MissionDurationSec: 30
SpawnZoneOverride: false
SetReturnToLegionFalse: false
ExplicitRTZ: false
DirectSpawn: false
MizMutation: false
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
SourceSHA256: A198C557B9D4A696174A810639D6E7E174EE111B656926BBBD0290F77CEFA119
BundleSHA256: 14B204FA28963CBFD0207DCBA7C4679F438AFA731B75368ABA9471F5AFF9E035
```

Der unabhängige lokale `Get-FileHash`-Wert stimmte mit dem Builder-Hash überein. Der Test erreichte wegen falschem Standort/Asset und fehlender Destination-Zone keinen aussagefähigen DCS-Return-Nachweis und wurde durch den integrierten Fortress-Infantry-Stage-2B-Pfad ersetzt.