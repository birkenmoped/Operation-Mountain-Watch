# Kandahar Controlled Parking – OH-58D PASS

Date: 2026-08-01

Status: `PASS`

This result records the isolated OH-58D debug case that was already generated before the automatic one-run matrix decision.

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

This PASS is retained as targeted debug evidence. It does not require the remaining eight cases to be run separately. The primary follow-on is the automatic one-run controlled parking matrix.
