---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-8000FT-QRF-ROAD-LOCAL-BUILD
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local Production Base Acceptance 3 build provenance after Jalalabad 8000 ft and QRF road-materialization correction
  - exact hashes for the next Acceptance 3 DCS test artifact
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: a2eb177ff7038befceeb55275bbb7c4aac25c1ff
validated_in_dcs: false
---

# Production Base Acceptance 3 – lokaler Buildnachweis nach 8000-ft-/QRF-Road-Korrektur

## Verifizierter lokaler Stand

Der Projektinhaber hat lokal auf folgendem exakten Git-Stand gebaut:

```text
a2eb177ff7038befceeb55275bbb7c4aac25c1ff
```

`git pull` führte einen Fast-Forward von `f834e3b5` auf `a2eb177f` aus. `git rev-parse HEAD` bestätigte anschließend exakt den oben dokumentierten Commit.

## Production Base

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-8
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
SiteRegistrySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-6
QrfRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-4
QrfVehicleMaterialization: accepted GroundRoadSpawnAdapter via site ACCESS zone, fixed 18 m spacing, MOOSE road-qualified outbound anchor
JalalabadAlarmRadius: 8000 ft / 2438.4 m
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
BuilderSHA256: 6119FDDBAED7FBDB9837BCEBEDF456E69D47AC3BB2000CCC8AE615370CDD6F88
BundleSHA256: C1A31887538D8E35DBAEA31E206354AD5B76A9DBBA5763A5A384F234D1927943
GitCommit: a2eb177ff7038befceeb55275bbb7c4aac25c1ff
```

## Acceptance 3

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-4
GitCommit: a2eb177ff7038befceeb55275bbb7c4aac25c1ff
ProductionBuilderSHA256: 6119FDDBAED7FBDB9837BCEBEDF456E69D47AC3BB2000CCC8AE615370CDD6F88
ProductionBundleSHA256: C1A31887538D8E35DBAEA31E206354AD5B76A9DBBA5763A5A384F234D1927943
AcceptanceSourceSHA256: 4EDA85409A1A9D1208C84C83EC713B8C966C7907BAEEC51A3B27A716504ED157
AcceptanceBuilderSHA256: 772ABE5D611D00C0CD21DCD8ACE1CDD8C941B1ED13F51EF7803815FB757AA5BC
AcceptanceBundleSHA256: 471C9065A6E278E28CFE31D5499808BAE51BD033C466ECD12910EFFD791907BD
PrimaryAlarmEvidenceSource: MOOSE OPSZONE proximity qualification
JalalabadAlarmZoneSource: existing MOOSE ZONE center OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT + runtime ZONE_RADIUS 8000 ft / 2438.4 m
OtherAlarmZoneSource: MOOSE WAREHOUSE coordinate + runtime ZONE_RADIUS
QrfVehicleMaterialization: site ACCESS zone + accepted road-aligned adapter + fixed 18 m vehicle spacing
MissionEditorAdditionalAlarmZonesRequired: false
MizMutation: false
```

## Unabhängige Hash-Prüfung

Die anschließend separat ausgeführten `Get-FileHash -Algorithm SHA256`-Prüfungen ergaben exakt dieselben Bundle-Hashes:

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
C1A31887538D8E35DBAEA31E206354AD5B76A9DBBA5763A5A384F234D1927943

mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua
471C9065A6E278E28CFE31D5499808BAE51BD033C466ECD12910EFFD791907BD
```

## Statusgrenze

```text
Local pull / exact Git HEAD: VERIFIED
Production build: VERIFIED_LOCAL_BUILD
Acceptance 3 build: VERIFIED_LOCAL_BUILD
Production bundle hash match: VERIFIED
Acceptance bundle hash match: VERIFIED
Jalalabad 8000 ft alarm implementation: BUILT, DCS verification OPEN
QRF ACCESS/road materialization correction: BUILT, DCS verification OPEN
DCS runtime acceptance: OPEN
```

Dieser Buildnachweis ist kein DCS-Runtime-PASS. Ein späterer Acceptance-PASS gilt ausschließlich für den exakt dokumentierten Commit-, Bundle-, Missions-, DCS- und MOOSE-Stand.
