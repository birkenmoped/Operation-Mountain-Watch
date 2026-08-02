# Kandahar Controlled Parking – OH-58D PASS

Date: 2026-08-01

Status: `PASS_ISOLATED_CASE`

This result records the isolated OH-58D debug case that was generated before the automatic one-run matrix decision.

Runtime result:

```text
case=OH58D
airwingKey=Heliport
squadron=SQ_US_KAF_OH58D_7_17_CAV
template=TPL_AIR_US_KAF_OH58D_RECON_2SHIP
assetGroups=1
units=2
terminalIDs=66,82
cold=true
uncontrolled=true
noAUFTRAG=true
noTransport=true
noPayloadMutation=true
noClientParking=true
```

Observed units:

```text
SQ_US_KAF_OH58D_7_17_CAV_AID-37-01 -> TerminalID 82, type 40, node distance 1.77 m
SQ_US_KAF_OH58D_7_17_CAV_AID-37-02 -> TerminalID 66, type 40, node distance 1.77 m
```

Both units were alive, on the ground, on AIRWING-allowed and non-blocked parking positions. The registration and parking-contract preflights also passed in the same mission run.

This PASS proves the isolated OH-58D physical parking case only. The later matrix-v1 run demonstrated that unchanged parking-ID lists allow subsequent requests to reuse TerminalIDs 66 and 82. Dynamic multi-request reservation therefore requires the matrix-v2 `AIRWING:SetParkingIDs(remainingAllowedIDs)` update and remains pending runtime acceptance.
