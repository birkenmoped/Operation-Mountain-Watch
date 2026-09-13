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
source_commit: b4a6505248bf3371ca6b11adcd7f02374e519b84
validated_in_dcs: false
---

# Production Base Acceptance 3 – lokaler Buildnachweis

## Ergebnis

Der Projektinhaber hat den Acceptance-3-Builder lokal auf folgendem exakten Git-Stand ausgeführt:

```text
b4a6505248bf3371ca6b11adcd7f02374e519b84
```

`git rev-parse HEAD` bestätigte exakt diesen Commit. Der Build lief ohne gemeldeten Fehler durch. Die Produktions- und Acceptance-Bundle-Hashes aus der Builder-Ausgabe stimmen jeweils exakt mit den anschließend separat per `Get-FileHash -Algorithm SHA256` ermittelten Hashes überein.

## Builder-Ausgabe – Production Base

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-10
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
SiteRegistrySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-SITE-REGISTRY-6
QrfRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-6
QrfMissionFactorySchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-4
InstallationIncidentBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-3
PerimeterBridgeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-BRIDGE-3
QrfMissionType: MOOSE AUFTRAG GROUNDATTACK against OPSZONE-qualified physical hostile group
QrfVehicleMaterialization: accepted GroundRoadSpawnAdapter via site ACCESS zone, fixed 18 m spacing, MOOSE road-qualified outbound anchor
QrfReturnLifecycle: AUFTRAG SetReturnToLegion(true) -> ARMYGROUP RTZ to BRIGADE ACCESS homezone -> Returned -> LEGION/Warehouse AddAsset
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
BuilderSHA256: 928FC9C01CB5628641F8BF744AFCF046502D6CD3AC7E776557A8F5D655E5E51D
BundleSHA256: EB8DC2C5DD143DD0B4B8C951496499C9909A2A8DD38B1FA1D5334F1064293176
GitCommit: b4a6505248bf3371ca6b11adcd7f02374e519b84
```

## Builder-Ausgabe – Acceptance 3

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-6
GitCommit: b4a6505248bf3371ca6b11adcd7f02374e519b84
ProductionBuilderSHA256: 928FC9C01CB5628641F8BF744AFCF046502D6CD3AC7E776557A8F5D655E5E51D
ProductionBundleSHA256: EB8DC2C5DD143DD0B4B8C951496499C9909A2A8DD38B1FA1D5334F1064293176
AcceptanceSourceSHA256: 476321EC5BB7691C88FC8E7C53285E31E84DA64EA430EE1D01761DD793D7B7A0
AcceptanceBuilderSHA256: 19218F7ACD0A36ED378FFA20A83C4DE9E077C8101291093882886B0F42D2FA65
AcceptanceBundleSHA256: 0AA3448371CA23E8ED1400229D9C3CD5F179271476EAAF727829054A22CACCB8
PrimaryAlarmEvidenceSource: MOOSE OPSZONE proximity qualification with physical hostile GROUP binding
QrfMissionType: MOOSE AUFTRAG GROUNDATTACK against OPSZONE-qualified hostile GROUP
QrfRelease: acceptance-only explicit Base ExpireDemand after >=25 m physical response; not perimeter/incident clear
QrfReturnLifecycle: MOOSE mission Cancel -> SetReturnToLegion(true) -> ARMYGROUP RTZ to site ACCESS homezone -> Returned -> Warehouse AddAsset -> physical removal
JalalabadAlarmZoneSource: existing MOOSE ZONE center OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT + runtime ZONE_RADIUS 8000 ft / 2438.4 m
OtherAlarmZoneSource: MOOSE WAREHOUSE coordinate + runtime ZONE_RADIUS
QrfVehicleMaterialization: site ACCESS zone + accepted road-aligned adapter + fixed 18 m vehicle spacing
MissionEditorAdditionalAlarmZonesRequired: false
MizMutation: false
```

## Separat verifizierte SHA-256-Werte

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
EB8DC2C5DD143DD0B4B8C951496499C9909A2A8DD38B1FA1D5334F1064293176

mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua
0AA3448371CA23E8ED1400229D9C3CD5F179271476EAAF727829054A22CACCB8
```

Damit sind Produktionsbundle und Acceptance-Bundle für den dokumentierten lokalen Stand eindeutig identifiziert.

## Verifizierter QRF-Vertrag dieses Builds

```text
MOOSE OPSZONE physical hostile GROUP qualification
-> PROXIMITY_INTRUSION
-> authoritative installation incident
-> exactly one initial QRF demand
-> MOOSE AUFTRAG:NewGROUNDATTACK(physical hostile GROUP)
-> site-local BRIGADE / PLATOON recruitment
-> accepted GroundRoadSpawnAdapter at site ACCESS
-> fixed 18 m road-aligned vehicle materialization
-> physical QRF response
-> acceptance-only explicit Base:ExpireDemand after >=25 m progress
-> AUFTRAG Cancel with SetReturnToLegion(true)
-> ARMYGROUP RTZ to BRIGADE ACCESS homezone
-> Returned
-> LEGION / Warehouse AddAsset
-> physical removal
```

Alarm-/Perimeter-Clear und Incident-Close sind ausdrücklich keine produktive QRF-Endbedingung.

## Alarmgeometrie dieses Builds

```text
JALALABAD_FENTY:
  center of existing MOOSE zone OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
  runtime radius 8000 ft / 2438.4 m

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

Es werden keine zusätzlichen Mission-Editor-Alarmzonen benötigt und keine `.miz`-Änderungen durch den Build vorgenommen.

## Statusgrenze

```text
Local exact Git HEAD: VERIFIED
Production build: VERIFIED_LOCAL_BUILD
Acceptance 3 build: VERIFIED_LOCAL_BUILD
Production bundle hash match: VERIFIED
Acceptance bundle hash match: VERIFIED
MOOSE QRF physical-target contract: BUILT
QRF ACCESS road materialization: BUILT
QRF ReturnToLegion / RTZ acceptance path: BUILT
DCS runtime acceptance: OPEN
validated_in_dcs: false
```

Ein späterer DCS-PASS gilt ausschließlich für den exakt dokumentierten Commit-, Bundle-, Missions-, DCS- und MOOSE-Stand. Dieser Buildnachweis allein ist ausdrücklich kein DCS-Runtime-PASS.
