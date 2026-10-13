---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-GROUND-A3-REUSE-LOCAL-BUILD
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local build provenance for corrected Production Base Acceptance 3 after Honaker/Ground reuse reconciliation
  - exact Production and Acceptance bundle hashes for the next DCS runtime test
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: e3260dbaa575328c7dd4b4ff1c2ae60b93d744b8
validated_in_dcs: false
---

# Production Base Acceptance 3 – Ground A3 reuse local build

## Result

The project owner executed the local pull/build/hash gate on the exact source commit:

```text
e3260dbaa575328c7dd4b4ff1c2ae60b93d744b8
```

`git rev-parse HEAD` matched that commit exactly. Both generated bundle hashes from the builders matched the subsequent independent `Get-FileHash -Algorithm SHA256` results.

This is `VERIFIED_LOCAL_BUILD` only. No DCS runtime result is implied.

## Production builder

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-12
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
SiteRegistrySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-6
QrfRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-9
QrfMissionFactorySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-5
InstallationIncidentBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-3
PerimeterBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-3
QrfMissionType: accepted Honaker MOOSE AUFTRAG ONGUARD + SetEngageDetected in site-local 5 NM tactical zone
QrfVehicleMaterialization: approved GroundRoadSpawnAdapter via site ACCESS zone; fixed 18 m spacing; road-forward geometry supplied by composition resolver
QrfRoadAnchorPolicy: no production target-derived heuristic; resolver must supply validated site geometry
QrfReturnLifecycle: AUFTRAG SetReturnToLegion(true) -> ARMYGROUP RTZ to BRIGADE ACCESS homezone -> Returned -> LEGION/Warehouse AddAsset
QrfReleaseAuthority: explicit supported-element/C2 release only; movement/perimeter/incident state has no mission-end authority
QrfIncidentClosePolicy: local incident/perimeter clear does not auto-cancel dispatched QRF
JalalabadAlarmRadius: 8000 ft / 2438.4 m
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OperationalAssetSelectionAuthority: MOOSE
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
QrfVehicleAccessZoneDependency: required and reused as MOOSE QRF homezone
PerimeterAccessZoneDependency: none
MizMutation: false
Encoding: UTF-8 without BOM
BuilderSHA256: 5C96E05A989FFCC21818DD50CF519ACA490846F15FC53251784C372AE93D7B6A
BundleSHA256: 2C6D0E87091F426E6270A06C0AE281681B444756254854D3338AE49987CFA14A
GitCommit: e3260dbaa575328c7dd4b4ff1c2ae60b93d744b8
```

## Acceptance 3 builder

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-8
GitCommit: e3260dbaa575328c7dd4b4ff1c2ae60b93d744b8
ProductionBuilderSHA256: 5C96E05A989FFCC21818DD50CF519ACA490846F15FC53251784C372AE93D7B6A
ProductionBundleSHA256: 2C6D0E87091F426E6270A06C0AE281681B444756254854D3338AE49987CFA14A
AcceptanceSourceSHA256: CF14C5C23026C4522349606DCEBF8A90A22B80B820CB5FC7254FAD9AC0917486
AcceptanceBuilderSHA256: E88AA4B0348749EAB3435D629E71E0FD25F4E1CFC3BF49E38F8FCF98D21218C4
AcceptanceBundleSHA256: 43295957D31C7A141E2770161AF90C20EBC3F05638F33787821059C6A3A3751E
PrimaryAlarmEvidenceSource: MOOSE OPSZONE proximity qualification with physical hostile GROUP binding
QrfMissionType: accepted Honaker MOOSE AUFTRAG ONGUARD + SetEngageDetected in site-local 5 NM tactical zone
QrfRelease: none in Acceptance 3; movement/perimeter/incident state has no QRF mission-end authority
QrfReturnLifecycle: inherited accepted MOOSE SetReturnToLegion(true) lifecycle; not driven by this harness
QrfRoadAnchorSource: exact Ground Acceptance-3-2 six-site PATROL_TEST approach geometry; 1500 m standoff; acceptance-only reference fixtures
JalalabadAlarmZoneSource: existing MOOSE ZONE center OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT + runtime ZONE_RADIUS 8000 ft / 2438.4 m
OtherAlarmZoneSource: MOOSE WAREHOUSE coordinate + runtime ZONE_RADIUS
QrfVehicleMaterialization: site ACCESS zone + approved road-aligned adapter + fixed 18 m vehicle spacing
MissionEditorAdditionalAlarmZonesRequired: false
MizMutation: false
```

## Independently verified SHA-256

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
2C6D0E87091F426E6270A06C0AE281681B444756254854D3338AE49987CFA14A

mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua
43295957D31C7A141E2770161AF90C20EBC3F05638F33787821059C6A3A3751E
```

## Reuse contract represented by this build

```text
Installation alarm / PROXIMITY_INTRUSION
-> authoritative incident
-> exactly one initial local QRF demand
-> accepted Honaker AUFTRAG:NewONGUARD(...)
-> SetEngageDetected(5 NM, {"Ground Units"}, site-local tactical zone)
-> SetReturnToLegion(true)
-> existing site ACCESS zone
-> approved GroundRoadSpawnAdapter
-> fixed 18 m road-aligned materialization
-> Acceptance-only road direction from exact Ground Acceptance-3-2 PATROL_TEST approach geometry
-> physical QRF response observation
```

Acceptance 3 does not issue `ExpireDemand`, `Cancel`, RTZ, or any movement-driven release. The already accepted Ground/Honaker return semantics remain the reusable lifecycle contract and are not redefined by this harness.

## Status boundary

```text
Exact local Git HEAD: VERIFIED
Production builder: VERIFIED_LOCAL_BUILD
Acceptance 3 builder: VERIFIED_LOCAL_BUILD
Production bundle independent hash match: VERIFIED
Acceptance bundle independent hash match: VERIFIED
GitHub Documentation validation on source commit: PASS
GitHub MissionDemand validation on source commit: PASS
DCS runtime acceptance: OPEN
validated_in_dcs: false
```

A later DCS result is valid only for the exact source commit, generated Acceptance bundle SHA-256, mission artifact, DCS build and pinned MOOSE state documented with that run.