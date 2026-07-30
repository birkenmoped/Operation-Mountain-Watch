# Bagram AIRWING/SQUADRON Construction Acceptance

Status: `PENDING_DCS_VALIDATION`

## Mission prerequisites

The mission must contain:

```text
WH_AIR_US_BAGRAM
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F16_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP
```

Every `TPL_*` group must be Late Activation and uncontrolled must remain false.

## Expected AIRWING structure

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
├── SQ_US_BGRM_F16C_121_EFS
├── SQ_US_BGRM_C130_774_EAS
├── SQ_US_BGRM_HH60G_83_ERQS
├── SQ_US_BGRM_UH60_A_1_169
└── SQ_US_BGRM_CH47_B_7_158
```

No additional Bagram squadron may be created for OH-58D, MC-12W, EC-130H, EA-6B or a separate Army MEDEVAC pool.

## Binding inventory accounting

```text
F-15E: 13 logical = 6 two-ship groups + 1 logical reserve
F-16C: 13 logical = 6 two-ship groups + 1 logical reserve
C-130: 20 logical = 20 one-ship groups
HH-60G: 6 logical = 6 one-ship groups
UH-60 Utility: 10 logical = 10 one-ship groups
CH-47: 13 logical = 13 one-ship groups
-----------------------------------------------
MOOSE-managed aircraft: 73
logical fighter reserve: 2
total logical inventory: 75
```

## PASS conditions

The DCS log must prove:

```text
AIRWING ready
SQUADRONS ready
PASS: AW_US_BAGRAM started with exactly 6 squadrons and 75 logical airframes
ACCOUNTING: MOOSE-managed=73 fighterLogicalReserve=2 total=75
```

Additional PASS requirements:

- every required template is found with the expected one-ship or two-ship size;
- every squadron is retrievable through `AIRWING:GetSquadron()`;
- Safe Parking is active;
- no client, static or authoring template is added to logical inventory;
- no spontaneous aircraft group is spawned during the observation window;
- no spontaneous AUFTRAG, OPSTRANSPORT or CSAR task is generated;
- repeated execution does not create a second AIRWING or duplicate SQUADRONs;
- no Lua error or MOOSE error attributable to the Bagram bundle occurs.

## Hard FAIL conditions

- warehouse anchor missing but AIRWING starts;
- fewer or more than six active squadrons;
- a fourteenth F-15E or F-16C is represented;
- C-130, HH-60G, UH-60 or CH-47 group count differs from `20/6/10/13`;
- excluded aircraft types receive a squadron or inventory;
- an unverified AUFTRAG mission type prevents construction;
- payload registration or AIRWING linkage fails;
- spontaneous tasking or spawning occurs.

## Not accepted by this test

- tactical CAS or strike execution;
- C-130 airlift mission execution;
- UH-60 or CH-47 OPSTRANSPORT execution;
- dedicated CSAR execution;
- parking terminal allowlist/blacklist completion;
- loss, return, repair or persistence behavior;
- CampaignState integration.
