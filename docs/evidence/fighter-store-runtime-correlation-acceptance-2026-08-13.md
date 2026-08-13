---
document_id: OMW-ACC-FIGHTER-STORE-RUNTIME-CORRELATION-2026-08-13
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - exact F-15E STRIKE GBU-31(V)1/B STORAGE runtime mapping
  - exact F-15E STRIKE GBU-31(V)3/B STORAGE runtime mapping
  - exact F-16 deployment AIM-9 STORAGE runtime mapping
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unresolved fighter-store mapping status in OMW-LOG-AIROPS-INITIAL-STOCK-FINALIZATION-2026-08-13
  - unresolved F-15E STRIKE and F-16 deployment AIM-9 mapping status in OMW-ARCH-AMMUNITION-RESOURCE-ID-CONTRACT
superseded_by:
source_branch: agent/fighter-store-runtime-correlation
source_commit: d95a15275f148cba02a9a2728dfbf825c274e366
validated_in_dcs: true
base_branch: agent/warehouse-resource-final-acceptance
base_commit: 1c74146641bc8ca21e0f39240754391cf7ce28b7
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
---

# Fighter Store Runtime Correlation – Acceptance 13.08.2026

## 1. Provenienz

```text
DCS: 2.9.28.26385 MT
Source/Builder commit: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
Internal mission SHA-256: 0f38447dade1934d63baa8e08ac536edd7865f47897f734450a8575594a19a2c
Embedded test bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: ec0238a8211d5804b1d1152190497b5e46ee8af45946e723abbe629efa22683f
debrief.log SHA-256: 89bca4398de33df36dffdbe67dca27b0e19a6ba330b02e5b0d927b28824f2fc5
```

## 2. F-15E STRIKE

Der produktive Bagram-F-15E-SQUADRON-Pfad materialisierte das vorhandene Two-Ship-STRIKE-Template. Beobachtet wurden exakt:

```text
weapons.bombs.GBU_31       100 -> 98  delta -2
weapons.bombs.GBU_31_V_3B  100 -> 98  delta -2
```

Der Harness meldete:

```text
F15_STRIKE_MAPPING_PASS
gbu31v1Item=weapons.bombs.GBU_31
gbu31v1Delta=-2.000
gbu31v3Item=weapons.bombs.GBU_31_V_3B
gbu31v3Delta=-2.000
grouping=2
```

Damit gelten für den getesteten OMW-F-15E-STRIKE-Payload:

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
```

Status: `RUNTIME_MAPPING_VALIDATED`.

## 3. F-16 Deployment AIM-9

Nach Freigabe der F-16-Phase wurde ein Bagram-F-16-Client über den normalen DCS-Ground-Crew-Rearm-Pfad um genau zwei AIM-9M ergänzt. Beobachtet wurden zwei Einzelschritte und anschließend die kumulative Korrelation:

```text
STORAGE:
weapons.missiles.AIM_9  98 -> 97 -> 96
cumulative delta = -2

Aircraft ammo:
AIM_9  0 -> 1 -> 2
cumulative delta = +2
```

Der Harness meldete:

```text
F16_AIM9_MAPPING_PASS
storageItem=weapons.missiles.AIM_9
storageDelta=-2.000
aircraftAmmoType=AIM_9
aircraftAmmoDelta=2.000
```

Damit gilt für den getesteten Bagram-F-16-Deployment-AIM-9-Pfad:

```text
AMMUNITION_AIM9 -> weapons.missiles.AIM_9
```

Status: `RUNTIME_MAPPING_VALIDATED`.

## 4. Gesamtergebnis

Der Harness meldete:

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

Damit sind die letzten drei offenen Fighter-Store-Runtime-Mappings des Warehouse-/Resource-Finalisierungsblocks geschlossen.

## 5. Acceptance-Grenze

Dieser Lauf validiert exakt die oben genannten Store-Korrelationen für die dokumentierte Provenienz. Er validiert nicht automatisch eine zukünftige schreibende CampaignState-to-STORAGE-Initialisierung oder einen neuen Reservation-/Result-Adapter. Solche Implementierungen bleiben separate produktive Entwicklungsarbeit und dürfen nicht als bereits DCS-validiert bezeichnet werden.

Für den abgeschlossenen Foundation-Scope gilt jedoch:

```text
strategic initial-stock planning = CLOSED
resource ownership contract = CLOSED
fighter exact item mapping = CLOSED
warehouse/resource foundation decision block = CLOSED
```
