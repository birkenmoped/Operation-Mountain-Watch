# Kandahar Controlled Parking Matrix – Acceptance

## Scope

This test family follows the accepted dual-AIRWING parking contract.

Each mission run tests exactly one approved SQUADRON template by:

1. reconstructing the validated AIRWING/SQUADRON registration baseline;
2. rebuilding and applying the accepted parking allow-/blocklists;
3. starting only the AIRWING that owns the selected SQUADRON;
4. issuing one exact `WAREHOUSE.Descriptor.GROUPNAME` self-request;
5. leaving the spawned aircraft group cold and uncontrolled on the ground;
6. recording the native runtime TerminalID used by every spawned unit.

No AUFTRAG, OPSTRANSPORT, payload registration, taxi command, route, COMMANDER, CHIEF, or client-parking override is permitted.

## Important grouping rule

The test requests one warehouse asset group, not necessarily one individual airframe.

The approved two-ship templates therefore spawn two aircraft:

```text
OH58D:  1 asset group / 2 aircraft
AH64D:  1 asset group / 2 aircraft
A10C:   1 asset group / 2 aircraft
```

All other cases use one-ship templates and spawn one aircraft.

No temporary single-ship template is invented for this test.

## Cases and required order

### Kandahar Heliport

```text
1. OH58D
2. AH64D
3. UH60
4. CH47
```

### Kandahar Main

```text
5. MQ1
6. MQ9
7. HH60G
8. A10C
9. C130
```

Run only one case per mission load.

## Case matrix

| Case | AIRWING | SQUADRON | Template | Expected groups | Expected units |
|---|---|---|---|---:|---:|
| `OH58D` | `AW_US_KAF_159_CAB_TF_THUNDER` | `SQ_US_KAF_OH58D_7_17_CAV` | `TPL_AIR_US_KAF_OH58D_RECON_2SHIP` | 1 | 2 |
| `AH64D` | `AW_US_KAF_159_CAB_TF_THUNDER` | `SQ_US_KAF_AH64_4_227_AVN` | `TPL_AIR_US_KAF_AH64D_CAS_2SHIP` | 1 | 2 |
| `UH60` | `AW_US_KAF_159_CAB_TF_THUNDER` | `SQ_US_KAF_UH60_7_101_GSAB` | `TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP` | 1 | 1 |
| `CH47` | `AW_US_KAF_159_CAB_TF_THUNDER` | `SQ_US_KAF_CH47_7_101_GSAB` | `TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP` | 1 | 1 |
| `MQ1` | `AW_US_KAF_451_AEW` | `SQ_US_KAF_MQ1_361_ERS` | `TPL_AIR_US_KAF_MQ1A_RECON_1SHIP` | 1 | 1 |
| `MQ9` | `AW_US_KAF_451_AEW` | `SQ_US_KAF_MQ9_361_ERS` | `TPL_AIR_US_KAF_MQ9_RECON_1SHIP` | 1 | 1 |
| `HH60G` | `AW_US_KAF_451_AEW` | `SQ_US_KAF_HH60G_26_ERQS` | `TPL_AIR_US_KAF_HH60G_CSAR_1SHIP` | 1 | 1 |
| `A10C` | `AW_US_KAF_451_AEW` | `SQ_US_KAF_A10C_74_EFS` | `TPL_AIR_US_KAF_A10C_CAS_2SHIP` | 1 | 2 |
| `C130` | `AW_US_KAF_451_AEW` | `SQ_US_KAF_C130_772_EAS` | `TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP` | 1 | 1 |

## Required baseline results

Before the controlled request, the same mission run must contain:

```text
[OMW][AirOps.KAF.RegistrationPreflight] RESULT: PASS
[OMW][AirOps.KAF.ParkingContract] RESULT: PASS
```

The selected AIRWING may be started only after both passes.

The non-selected AIRWING must remain stopped.

## Required request evidence

The log must contain exactly one request marker:

```text
[OMW][AirOps.KAF.ControlledParking] REQUEST_ISSUED case=<case> ... expectedAssetGroups=1 expectedUnits=<n>
```

The request must use:

```text
WAREHOUSE.Descriptor.GROUPNAME
```

with the exact approved template name for the selected case.

## Required spawn evidence

For every spawned group:

```text
GROUP_SPAWNED case=<case> group=<runtime-name> units=<n> alive=true airborne=false allOnGround=true
```

For every spawned unit:

```text
UNIT_PARKED case=<case> group=<group> unit=<unit> type=<type> terminalID=<id> terminalType=<type> distance=<m> allowed=true blocked=false
```

Every unit must:

- match the expected DCS type;
- be on the ground;
- resolve to an AIRWING-allowed TerminalID;
- not resolve to a blocked or client-reserved TerminalID;
- be within 12 metres of its resolved native parking-node centre;
- use a unique TerminalID within the tested group.

## Required final result

```text
[OMW][AirOps.KAF.ControlledParking] RESULT: PASS case=<case> airwingKey=<Main|Heliport> squadron=<name> template=<name> type=<type> assetGroups=1 units=<n> terminalIDs=<ids> cold=true uncontrolled=true oneAirwingStarted=true noAUFTRAG=true noTransport=true noPayloadMutation=true noClientParking=true
```

The case fails on any:

```text
VIOLATION
RESULT: FAIL
SELF_REQUEST_TIMEOUT
SPAWNED_UNIT_NOT_ON_ALLOWLIST
SPAWNED_UNIT_ON_BLOCKED_TERMINAL
SPAWNED_UNIT_NODE_DISTANCE_EXCEEDED
DUPLICATE_TERMINAL_ASSIGNMENT
```

## Runtime duration

Allow at least 90 seconds after mission start.

The registration stage is scheduled at approximately 8 seconds, the parking contract at approximately 16 seconds, and the controlled case at approximately 28 seconds. The self-request timeout is 60 seconds after the controlled case begins.

## Runtime evidence to return

For every case return the current:

```text
dcs.log
debrief.log
```

The debrief is expected to contain physical births for exactly the selected asset group. No other Kandahar AIRWING asset may be spawned by the bundle.
