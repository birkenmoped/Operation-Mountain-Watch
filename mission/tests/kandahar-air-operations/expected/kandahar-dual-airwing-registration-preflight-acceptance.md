# Kandahar Dual-AIRWING Registration Preflight – Acceptance Contract

## Scope

This test validates construction and registration of the approved Kandahar AIRWING and SQUADRON objects against:

```text
OMW_Template_v4_Kandahar(4).miz
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

Builder:

```text
tools/build-kandahar-dual-airwing-registration-preflight.ps1
BuilderVersion: KAF-DUAL-AIRWING-REGISTRATION-PREFLIGHT-1
```

The test is deliberately limited to object construction and SQUADRON registration. It does not authorize productive runtime operation.

## Required AIRWING bindings

```text
AW_US_KAF_451_AEW
Warehouse: WH_AIR_US_KANDAHAR
Airbase: AIRBASE.Afghanistan.Kandahar
Expected DCS ID: 7

AW_US_KAF_159_CAB_TF_THUNDER
Warehouse: WH_AIR_US_KANDAHAR_HELI
Airbase: AIRBASE.Afghanistan.Kandahar_Heliport
Expected DCS ID: 15
```

## Required SQUADRON registrations

### AW_US_KAF_451_AEW

```text
SQ_US_KAF_A10C_74_EFS
Template: TPL_AIR_US_KAF_A10C_CAS_2SHIP
8 asset groups x 2 = 16 A-10C_2

SQ_US_KAF_HH60G_26_ERQS
Template: TPL_AIR_US_KAF_HH60G_CSAR_1SHIP
6 asset groups x 1 = 6 UH-60A representations of HH-60G

SQ_US_KAF_C130_772_EAS
Template: TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP
12 asset groups x 1 = 12 C-130J-30

SQ_US_KAF_MQ1_361_ERS
Template: TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
4 asset groups x 1 = 4 RQ-1A Predator representations of MQ-1

SQ_US_KAF_MQ9_361_ERS
Template: TPL_AIR_US_KAF_MQ9_RECON_1SHIP
2 asset groups x 1 = 2 MQ-9 Reaper
```

### AW_US_KAF_159_CAB_TF_THUNDER

```text
SQ_US_KAF_AH64_4_227_AVN
Template: TPL_AIR_US_KAF_AH64D_CAS_2SHIP
4 asset groups x 2 = 8 AH-64D_BLK_II

SQ_US_KAF_OH58D_7_17_CAV
Template: TPL_AIR_US_KAF_OH58D_RECON_2SHIP
8 asset groups x 2 = 16 OH58D

SQ_US_KAF_CH47_7_101_GSAB
Template: TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP
16 asset groups x 1 = 16 CH-47Fbl1

SQ_US_KAF_UH60_7_101_GSAB
Template: TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP
32 asset groups x 1 = 32 UH-60A
```

The one-aircraft UH-60 template is intentionally used as the common asset seed. Future mission packaging may request multiple aircraft without splitting the 32-airframe pool into separate transport and MEDEVAC inventories.

## Deferred component

```text
361st ERS MC-12 component: 6 airframes
Status: logical/historical only
Reason: no approved DCS template or SQUADRON identifier
```

The expected registered physical inventory is therefore:

```text
112 airframes registered through MOOSE SQUADRON objects
6 MC-12 deferred
118 total approved Kandahar inventory
```

## Required log evidence

The log must contain exactly two successful AIRWING construction lines:

```text
AIRWING_CONSTRUCTED key=Main name=AW_US_KAF_451_AEW ... airbaseID=7 running=false
AIRWING_CONSTRUCTED key=Heliport name=AW_US_KAF_159_CAB_TF_THUNDER ... airbaseID=15 running=false
```

The log must contain one `SQUADRON_REGISTERED` line for each of the nine approved physical SQUADRONs.

The log must contain:

```text
DEFERRED unit=361st Expeditionary Reconnaissance Squadron type=MC-12 airframes=6 reason=NO_APPROVED_DCS_TEMPLATE_OR_SQUADRON_IDENTIFIER
```

Final required result:

```text
RESULT: PASS airwings=2 squadrons=9 registeredAirframes=112 deferredMC12=6 noStart=true noSpawn=true noMission=true noTransport=true noPayloadMutation=true noParkingMutation=true
```

## Mandatory negative evidence

During the test run there must be no evidence of:

```text
AIRWING start transition
SQUADRON/Cohort start transition
warehouse request or asset spawn
Birth event caused by this test
AUFTRAG construction or queueing
OPSTRANSPORT construction or queueing
COMMANDER or CHIEF construction
payload-stock creation or mutation
parking allowlist, blocklist, or safe-parking mutation
```

No `VIOLATION` line may be emitted by the preflight script.

## Pass boundary

A PASS proves only:

```text
warehouse names resolve;
airbases resolve with the expected IDs;
AIRWING constructors bind to the intended warehouses and airbases;
all nine physical SQUADRON objects can be created from the approved templates;
asset-group arithmetic matches the approved inventory decision;
all SQUADRONs register under the correct AIRWING;
none of the constructed AIRWINGs is running.
```

A PASS does not authorize:

```text
AIRWING:Start();
payload registration;
mission capability registration;
AUFTRAG or OPSTRANSPORT;
spawning;
safe-parking configuration;
COMMANDER integration;
productive loss, return, repair, or persistence logic.
```
