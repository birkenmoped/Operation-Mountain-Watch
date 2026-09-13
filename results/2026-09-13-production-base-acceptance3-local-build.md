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
source_commit: f834e3b5c0416f143585541e2dd17496d1bc3f95
validated_in_dcs: false
---

# Production Base Acceptance 3 – lokaler Buildnachweis

## Ergebnis

Der Projektinhaber hat den Acceptance-3-Builder lokal auf folgendem exakten Git-Stand ausgeführt:

```text
f834e3b5c0416f143585541e2dd17496d1bc3f95
```

`git pull` führte lokal einen Fast-Forward von `c1ab6ed0` auf `f834e3b5`; `git rev-parse HEAD` bestätigte anschließend exakt den oben dokumentierten Commit. Der Remote-Branch zeigte zum Zeitpunkt der Auswertung ebenfalls exakt `f834e3b5c0416f143585541e2dd17496d1bc3f95`.

Der Build lief ohne gemeldeten Fehler durch. Die Produktions- und Acceptance-Bundle-Hashes aus der Builder-Ausgabe stimmen jeweils exakt mit den anschließend separat per `Get-FileHash -Algorithm SHA256` ermittelten Hashes überein.

## Builder-Ausgabe – Production Base

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-7
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
QrfRuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-3
QrfVehicleMaterialization: accepted GroundRoadSpawnAdapter via site ACCESS zone
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OperationalAssetSelectionAuthority: MOOSE
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
QrfVehicleAccessZoneDependency: required
PerimeterAccessZoneDependency: none
MizMutation: false
Encoding: UTF-8 without BOM
BuilderSHA256: 29037E288C6EC2605BD5225D8261B70AB80FD06E8140437EDC31433169F4B22A
BundleSHA256: 83FD97FA8962CE835BE464B3536C27F5F0F309D6F5BA240D6AF4A71233D61B46
GitCommit: f834e3b5c0416f143585541e2dd17496d1bc3f95
```

## Builder-Ausgabe – Acceptance 3

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-3
GitCommit: f834e3b5c0416f143585541e2dd17496d1bc3f95
ProductionBuilderSHA256: 29037E288C6EC2605BD5225D8261B70AB80FD06E8140437EDC31433169F4B22A
ProductionBundleSHA256: 83FD97FA8962CE835BE464B3536C27F5F0F309D6F5BA240D6AF4A71233D61B46
AcceptanceSourceSHA256: FE68DC7D8D8190210C9D0E2980C9AF62BB39BC58E536863739B75EF19B060F4D
AcceptanceBuilderSHA256: 4F90CE1CC5D047C9297F48526EAA3EA55A035C1FBE23C99E737BB51DDC150764
AcceptanceBundleSHA256: 922467FD9803E25CE5C09B8E98BC41F8D9CFAE5668960FED8D8FE53ED89E8690
PrimaryAlarmEvidenceSource: MOOSE OPSZONE proximity qualification
JalalabadAlarmZoneSource: existing MOOSE ZONE OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
OtherAlarmZoneSource: MOOSE WAREHOUSE coordinate + runtime ZONE_RADIUS
MissionEditorAdditionalAlarmZonesRequired: false
MizMutation: false
```

## Separat verifizierte SHA-256-Werte

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
83FD97FA8962CE835BE464B3536C27F5F0F309D6F5BA240D6AF4A71233D61B46

mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua
922467FD9803E25CE5C09B8E98BC41F8D9CFAE5668960FED8D8FE53ED89E8690
```

Damit sind Produktionsbundle und Acceptance-Bundle für den dokumentierten lokalen Stand eindeutig identifiziert.

## QRF-Materialisierung dieses Builds

Für motorisierte QRFs gilt in diesem Build wieder der bereits abgenommene Ground-ACCESS-Vertrag:

```text
MOOSE recruitment / AUFTRAG
-> site-local BRIGADE / WAREHOUSE
-> accepted OMW_GroundRoadSpawnAdapter
-> ZON_BLUE_GND_XXX_ACCESS
-> road projection and road-axis alignment
-> outbound QRF mission
```

Die sechs verwendeten ACCESS-Zonen bleiben:

```text
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

Die ACCESS-Zonen sind dabei ausschließlich Materialisierungs-/Departure-/Return-/Handoff-Grenzen für mobile Ground-Assets. Sie definieren weiterhin weder die Alarmgeometrie noch den taktischen Wirkungsraum.

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

Es werden keine zusätzlichen Mission-Editor-Alarmzonen benötigt. Guard-PATHLINEs und Alarmgeometrie bleiben davon getrennt.

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
QRF ACCESS materialization implementation: BUILT, DCS verification OPEN
DCS runtime acceptance: OPEN
```

Ein späterer DCS-PASS gilt ausschließlich für den exakt dokumentierten Commit-, Bundle-, Missions-, DCS- und MOOSE-Stand. Dieser Buildnachweis allein ist ausdrücklich kein DCS-Runtime-PASS.
