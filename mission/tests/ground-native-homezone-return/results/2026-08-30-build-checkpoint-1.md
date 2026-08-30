---
document_id: OMW-GROUND-NATIVE-HOMEZONE-RETURN-BUILD-CHECKPOINT-1
status: BUILD_VERIFIED
document_class: TEST_PROVENANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - real local build provenance for Ground Native Homezone Return Acceptance 1
not_authoritative_for:
  - DCS runtime validation
  - geometric suitability of the native MOOSE Warehouse spawnzone
  - repository-wide Ground return architecture
source_branch: agent/fob-attack-support-demand
source_commit: 3f8dc517a0a5c4f589b34ae35ee6ac370e5ab9ac
validated_in_dcs: false
---

# Ground Native Homezone Return – Build Checkpoint 1

## Reale lokale Verifikation

Vom Projektinhaber am 30.08.2026 real ausgeführt und mit vollständiger Konsolenausgabe zurückgemeldet.

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

Der separat mit `Get-FileHash -Algorithm SHA256` ermittelte Bundle-Hash stimmt exakt mit dem Builder-Hash überein:

```text
14B204FA28963CBFD0207DCBA7C4679F438AFA731B75368ABA9471F5AFF9E035
```

Lokaler Build-Pfad:

```text
mission/tests/ground-native-homezone-return/dist/OMW_Ground_Native_Homezone_Return_Acceptance_1.lua
```

## Abgrenzung

Dieser Checkpoint beweist nur Build-/Provenienz-Konsistenz. Er beweist noch nicht:

```text
native RTZ execution in DCS
physical return to the Joyce 250 m MOOSE Warehouse spawnzone
Returned event
origin Warehouse AddAsset
physical cleanup
pathfinding / geometry suitability
absence of visible obstacle penetration
```

Diese Punkte bleiben bis zum realen DCS-Lauf `PENDING_DCS`.
