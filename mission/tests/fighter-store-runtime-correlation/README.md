# Fighter Store Runtime Correlation

Status: `ACCEPTED_TECHNICAL_BASELINE`

## Ziel

Dieser Test schließt die drei nach der finalisierten Initial-Stock-Entscheidung verbliebenen technischen Fighter-Store-Mappings:

```text
F-15E STRIKE GBU-31(V)1/B -> exact STORAGE item
F-15E STRIKE GBU-31(V)3/B -> exact STORAGE item
F-16 deployment AIM-9     -> exact DCS/MOOSE STORAGE item
```

Die strategischen Initialmengen werden durch diesen Test nicht neu berechnet.

## Basis

```text
Base branch: agent/warehouse-resource-final-acceptance
Base commit: 1c74146641bc8ca21e0f39240754391cf7ce28b7
Source/Builder commit: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
Internal mission SHA-256: 0f38447dade1934d63baa8e08ac536edd7865f47897f734450a8575594a19a2c
dcs.log SHA-256: ec0238a8211d5804b1d1152190497b5e46ee8af45946e723abbe629efa22683f
debrief.log SHA-256: 89bca4398de33df36dffdbe67dca27b0e19a6ba330b02e5b0d927b28824f2fc5
DCS: 2.9.28.26385 MT
```

## MOOSE-First

Der Gate implementiert keine eigene Warehouse-, Spawn-, Return- oder Rearm-Mechanik. F-15E STRIKE wird über die bestehende Bagram-AIRWING/SQUADRON-Foundation materialisiert. F-16 AIM-9 wird über den normalen DCS-Ground-Crew-Rearm beobachtet. STORAGE und CampaignState bleiben read-only.

## Akzeptiertes Ergebnis

### F-15E STRIKE

```text
weapons.bombs.GBU_31       100 -> 98  delta -2
weapons.bombs.GBU_31_V_3B  100 -> 98  delta -2
```

Harness:

```text
F15_STRIKE_MAPPING_PASS
gbu31v1Item=weapons.bombs.GBU_31
gbu31v1Delta=-2.000
gbu31v3Item=weapons.bombs.GBU_31_V_3B
gbu31v3Delta=-2.000
grouping=2
```

### F-16 Deployment AIM-9

```text
weapons.missiles.AIM_9  98 -> 97 -> 96
cumulative STORAGE delta = -2

AIM_9 aircraft ammo  0 -> 1 -> 2
cumulative aircraft delta = +2
```

Harness:

```text
F16_AIM9_MAPPING_PASS
storageItem=weapons.missiles.AIM_9
storageDelta=-2.000
aircraftAmmoType=AIM_9
aircraftAmmoDelta=2.000
```

### Gesamtresultat

```text
RESULT testId=FIGHTER-STORE-RUNTIME-CORRELATION-1
status=PASS
reason=F15_STRIKE_AND_F16_AIM9_CORRELATED
f15StrikeMapping=true
f16Aim9Mapping=true
storageMutation=false
campaignStateMutation=false
nativeDcs=false
```

## Finales Mapping

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
AMMUNITION_AIM9     -> weapons.missiles.AIM_9
```

## Acceptance-Grenze

Dieser Lauf validiert die drei konkreten Runtime-Mappings für die dokumentierte Provenienz. Er validiert keine zukünftige schreibende CampaignState-to-STORAGE-Initialisierung und keinen neuen strategischen Equipment-Reservation-/Result-Adapter.

Ausführliche Acceptance-Evidenz:

```text
docs/evidence/fighter-store-runtime-correlation-acceptance-2026-08-13.md
```
