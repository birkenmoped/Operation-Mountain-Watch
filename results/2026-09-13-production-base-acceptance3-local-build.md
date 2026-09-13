---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-LOCAL-BUILD
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local Production Base Acceptance 3 build provenance
  - exact hashes for the Acceptance 3 DCS test artifact
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 1ea9ac12bd07ae11a4aa02babb4b7b074c959c84
validated_in_dcs: false
---

# Production Base Acceptance 3 – lokaler Buildnachweis

## Ergebnis

Der Projektinhaber hat den Acceptance-3-Builder lokal auf folgendem exakten Git-Stand ausgeführt:

```text
1ea9ac12bd07ae11a4aa02babb4b7b074c959c84
```

`git pull` führte lokal einen Fast-Forward von `e5773c99` auf `1ea9ac12`; `git rev-parse HEAD` bestätigte anschließend exakt den oben dokumentierten Commit.

Der Build lief ohne gemeldeten Fehler durch. Die Produktions- und Acceptance-Bundle-Hashes aus der Builder-Ausgabe stimmen jeweils exakt mit den anschließend separat per `Get-FileHash -Algorithm SHA256` ermittelten Hashes überein.

## Builder-Ausgabe – Production Base

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-6
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
SiteRegistrySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-5
PerimeterRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME-2
ThreatAdapterSchema: OMW-FOB-THREAT-OPSZONE-ADAPTER-5
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OperationalAssetSelectionAuthority: MOOSE
GuardQRFRecruitmentConstraintAuthority: MOOSE AUFTRAG/LEGION
PhysicalAlarmEvidence: MOOSE OPSZONE perimeter qualification plus optional MOOSE EVENTHANDLER/WEAPON evidence
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
PerimeterAccessZoneDependency: none
PerimeterClearClosesIncident: false
MissionSpecificGeometryInjected: true
MOOSEOverride: Guard materialization exact-geometry exception only
MizMutation: false
Encoding: UTF-8 without BOM
BuilderSHA256: 86C890A8903E969255BDB339BA08B437F63F42077BDF5810C7496A2FC58D5BE4
BundleSHA256: CEF9C47E24E31AA951E88BFB312C2E0AF00E72653D590F0035D58A078F509E3D
GitCommit: 1ea9ac12bd07ae11a4aa02babb4b7b074c959c84
```

## Builder-Ausgabe – Acceptance 3

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-3
GitCommit: 1ea9ac12bd07ae11a4aa02babb4b7b074c959c84
ProductionBuilderSHA256: 86C890A8903E969255BDB339BA08B437F63F42077BDF5810C7496A2FC58D5BE4
ProductionBundleSHA256: CEF9C47E24E31AA951E88BFB312C2E0AF00E72653D590F0035D58A078F509E3D
AcceptanceSourceSHA256: 69B201B371B7B43EA428C89D620F2CC490716285A03ADC1938CE9F2358B6A86D
AcceptanceBuilderSHA256: 4F90CE1CC5D047C9297F48526EAA3EA55A035C1FBE23C99E737BB51DDC150764
AcceptanceBundleSHA256: C4ED2FA514744526D6479145392A7EF41BABE2AA8108E402B3C5C69F95B3EAF9
PrimaryAlarmEvidenceSource: MOOSE OPSZONE proximity qualification
JalalabadAlarmZoneSource: existing MOOSE ZONE OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
OtherAlarmZoneSource: MOOSE WAREHOUSE coordinate + runtime ZONE_RADIUS
MissionEditorAdditionalAlarmZonesRequired: false
MizMutation: false
```

## Separat verifizierte SHA-256-Werte

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
CEF9C47E24E31AA951E88BFB312C2E0AF00E72653D590F0035D58A078F509E3D

mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua
C4ED2FA514744526D6479145392A7EF41BABE2AA8108E402B3C5C69F95B3EAF9
```

Damit sind Produktionsbundle und Acceptance-Bundle für den dokumentierten lokalen Stand eindeutig identifiziert.

## Alarmgeometrie dieses Builds

```text
JALALABAD_FENTY:
  existing MOOSE ZONE OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
  radius 6000 ft / 1828.8 m

COP_FORTRESS:
  WH_BLUE_GND_FORTRESS coordinate
  runtime MOOSE ZONE_RADIUS 5000 ft / 1524.0 m

FOB_JOYCE:
  WH_BLUE_GND_JOYCE coordinate
  runtime MOOSE ZONE_RADIUS 9000 ft / 2743.2 m

FOB_WRIGHT:
  WH_BLUE_GND_WRIGHT coordinate
  runtime MOOSE ZONE_RADIUS 4000 ft / 1219.2 m

COP_HONAKER:
  WH_BLUE_GND_HONAKER coordinate
  runtime MOOSE ZONE_RADIUS 9000 ft / 2743.2 m

FOB_BOSTICK:
  WH_BLUE_GND_BOSTICK coordinate
  runtime MOOSE ZONE_RADIUS 5000 ft / 1524.0 m
```

Es werden keine zusätzlichen Mission-Editor-Alarmzonen benötigt. `ACCESS`-Zonen und Guard-PATHLINEs bleiben von der Alarmgeometrie getrennt.

## Acceptance-Testfixture

Der zu testende DCS-Lauf setzt sechs ausschließlich für Acceptance 3 vorgesehene late-activated RED-Gruppen voraus:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Diese Gruppen sind reine Testfixtures. Sie sind keine produktive RED-ORBAT und keine produktive RED-C2-Quelle.

## Statusgrenze

```text
Local pull / exact Git HEAD: VERIFIED
Production build: VERIFIED_LOCAL_BUILD
Acceptance 3 build: VERIFIED_LOCAL_BUILD
Production bundle hash match: VERIFIED
Acceptance bundle hash match: VERIFIED
DCS runtime acceptance: OPEN
```

Ein späterer DCS-PASS gilt ausschließlich für den exakt dokumentierten Commit-, Bundle-, Missions-, DCS- und MOOSE-Stand. Dieser Buildnachweis allein ist ausdrücklich kein DCS-Runtime-PASS.
