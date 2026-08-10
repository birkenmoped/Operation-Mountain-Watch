---
document_id: OMW-TEST-SHINDAND-G3-AH64-CONTROLLED-PARKING-FAIL
status: VALIDATED
document_class: DCS_ACCEPTANCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Shindand G3 AH-64 controlled-parking runtime result documented below
  - AIRWING:SetParkingIDs configuration persistence before request
  - physical terminal attribution for the spawned AH-64 two-ship in this run
not_authoritative_for:
  - corrected Shindand parking enforcement
  - general behavior of all HELIPAD airbases
  - taxi, takeoff, recovery, persistence or COMMANDER integration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: f308d2f540f6f1df05dc06718b59104e58534e01
validated_in_dcs: true
---

# Shindand G3 AH-64 Controlled Parking – FAIL

## Zweck

G3 uebertraegt den bereits im Kandahar-AirOps-Strang verwendeten nativen MOOSE-Controlled-Parking-Pfad auf Shindand, ohne AUFTRAG, COMMANDER, OPSTRANSPORT, direkten SPAWN oder MOOSE-Override.

Der Test begrenzt vor dem Request den AIRWING-Parking-Pool auf den Owner-definierten AH-64-Pool und fordert danach genau eine AH-64-Assetgruppe ueber den nativen WAREHOUSE-Self-Request an.

## Build-Provenienz

```text
Source commit: f308d2f540f6f1df05dc06718b59104e58534e01
BuilderVersion: SHND-G3-AH64-CONTROLLED-PARKING-1
Bundle SHA-256: acf6385ee69a78fee10fceb2ce40f8cbf5cd62d72e718343fb1a1f293590c62a
Scope: SHINDAND_G3_AH64_CONTROLLED_PARKING_ONLY
RequestPath: AIRWING_WAREHOUSE_SELF_REQUEST
```

Builder-Gates:

```text
Commander: ABSENT
AUFTRAG: ABSENT
OPSTRANSPORT: ABSENT
DirectSpawn: ABSENT
MOOSEOverride: ABSENT
CampaignStateMutation: ABSENT
```

## DCS-Runtime

DCS:

```text
2.9.28.26385 MT
```

Die Foundation blieb gueltig:

```text
SQUADRON_POSTSTART name=SQ_US_SHND_AH64D_ATTACK expectedAssets=4 actualAssets=4 parkingIDs=21,3,34,15 parkingSync=true
SQUADRON_POSTSTART name=SQ_US_SHND_UH60_UTILITY_MEDEVAC expectedAssets=8 actualAssets=8 parkingIDs=41,18,13,20,19 parkingSync=true
SQUADRON_POSTSTART name=SQ_US_SHND_CH47_HEAVYLIFT expectedAssets=4 actualAssets=4 parkingIDs=30,10,23 parkingSync=true
RESULT status=RUNNING airbase=Shindand Heliport airbaseID=14 airwings=1 squadrons=3 registeredGroups=16 representedAirframes=20 logicalAirframes=20 logicalReserve=0 rolePayloads=3 running=true postStartAssetParkingSync=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Vor dem Request wurde der AIRWING-Pool korrekt auf den AH-64-Pool gesetzt:

```text
AIRWING_PARKING_IDS_UPDATED terminalIDs=21,3,34,15
REQUEST_ISSUED template=TPL_AIR_US_SHND_AH64D_CAS_2SHIP assetGroups=1 expectedUnits=2 assignment=OMW_SHND_G3_AH64_CONTROLLED_PARKING commander=false auftrag=false opstransport=false directSpawn=false campaignStateMutation=false
```

Der native WAREHOUSE-Self-Request wurde erfuellt und erzeugte genau eine AH-64-Zweiergruppe:

```text
SELF_REQUEST_FULFILLED assignment=OMW_SHND_G3_AH64_CONTROLLED_PARKING
GROUP_SPAWNED group=SQ_US_SHND_AH64D_ATTACK_AID-195 units=2 alive=true airborne=false allOnGround=true
```

Die physische Platzierung lag jedoch ausserhalb des AH-64-Pools:

```text
SQ_US_SHND_AH64D_ATTACK_AID-195-01 -> TerminalID 41, distanceM=1.643, parkingAllowed=false
SQ_US_SHND_AH64D_ATTACK_AID-195-02 -> TerminalID 30, distanceM=1.593, parkingAllowed=false
```

TerminalID 41 gehoert zum Owner-definierten UH-60-Pool. TerminalID 30 gehoert zum Owner-definierten CH-47-Pool.

Finaler Testmarker:

```text
RESULT status=FAIL_CONTROLLED_PARKING violations=2 requestIssued=true spawnedGroups=1 spawnedUnits=2 terminalIDs=30,41
```

## Bewertung

```yaml
foundation_state: PASS
squadron_asset_parking_inheritance: PASS
airwing_parking_ids_configuration: PASS
native_warehouse_self_request: PASS
expected_asset_group_count: PASS
expected_unit_count: PASS
physical_type_specific_parking: FAIL
```

Damit ist fuer diesen dokumentierten Shindand-Lauf nachgewiesen, dass `AIRWING:SetParkingIDs({21,3,34,15})` allein die physische DCS-Platzierung am `Shindand Heliport` nicht auf diesen Pool begrenzt.

Dieser Befund widerlegt nicht die bereits dokumentierten Kandahar-Ergebnisse; er zeigt eine Shindand-spezifische Abweichung, die vor einem Architektur- oder Override-Entscheid zunaechst gegen den vollstaendigen Kandahar-Parking-Contract (`AIRBASE:SetParkingSpotBlacklist` + `AIRWING:SetParkingIDs` + nativer Self-Request) isoliert nachgetestet werden muss.

## Nicht als Ursache werten

Der nach Missionsende auftretende bekannte externe Saved-Games-Hookfehler

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

ist nicht dem OMW-Shindand-Bundle zugeordnet.
