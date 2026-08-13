---
document_id: OMW-ARCH-AMMUNITION-ITEM-MAPPING-CONTRACT
status: BINDING
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - current strategic-ammunition to MOOSE STORAGE item mapping status
  - accepted weapon-item correlations
  - prohibition of unverified direct STORAGE mirrors for gun ammunition
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unresolved F-15E STRIKE GBU-31 mapping status
  - unresolved F-16 deployment AIM-9 mapping status
  - unresolved external-tank production-policy status
superseded_by:
source_branch: agent/fighter-store-runtime-correlation
source_commit: PENDING_MERGE
validated_in_dcs: partial
base_branch: agent/warehouse-resource-final-acceptance
base_commit: 1c74146641bc8ca21e0f39240754391cf7ce28b7
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
---

# Ammunition Item-Mapping Contract

## 1. Zweck

Dieses Dokument trennt verbindlich:

```text
CampaignState strategic resource identity
MOOSE STORAGE / DCS warehouse item identity
AIRWING payload identity and availability
```

CampaignState bleibt strategische Ressourcenhoheit. Ein DCS-/MOOSE-Item wird nur dann als operativer Mirror verwendet, wenn die Zuordnung praktisch belegt ist oder der Vertrag ausdrücklich eine Nicht-Spiegelbarkeit festlegt.

## 2. MOOSE-First-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Verwendete STORAGE-Schnittstelle:

```text
STORAGE:GetInventory()
STORAGE:GetItemAmount(Name)
STORAGE:SetItem(Name, Amount)
STORAGE:AddItem(Name, Amount)
STORAGE:RemoveItem(Name, Amount)
ENUMS.Storage.weapons
```

Source-Verfügbarkeit allein ersetzt keinen Runtime-Nachweis eines konkreten Aircraft-/Payload-Debits.

## 3. Mapping-Matrix

| Strategic Resource ID | DCS/MOOSE item / technical path | Status |
|---|---|---|
| `AMMUNITION_HELLFIRE` | `weapons.missiles.AGM_114K` für getestete OMW-AH-64D-CAS-Payload | `PAYLOAD_VARIANT_DEBIT_VALIDATED` |
| `AMMUNITION_ROCKETS_70MM` | `weapons.nurs.HYDRA_70_M151` für AH-64D/OH-58D; `weapons.nurs.HYDRA_70_M156` für A-10C | `PAYLOAD_VARIANT_DEBIT_VALIDATED` |
| `AMMUNITION_30MM_M230` | Onboard/debrief telemetry; kein positiver direct STORAGE round mirror | `TELEMETRY_ONLY_NO_DIRECT_STORAGE_MIRROR` |
| `AMMUNITION_30MM_GAU8` | Onboard/debrief telemetry; kein positiver direct STORAGE round mirror | `TELEMETRY_ONLY_NO_DIRECT_STORAGE_MIRROR` |
| `AMMUNITION_50CAL_M3P` | `weapons.containers.OH58D_M3P_L500` für aktuelle Payload; keine Round-Conversion | `STORE_WITHOUT_ROUND_CONVERSION` |
| `AMMUNITION_GBU12` | `weapons.bombs.GBU_12` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_GBU38` | `weapons.bombs.GBU_38` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_GBU54` | `weapons.bombs.GBU_54_V_1B` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_GBU31_V1` | `weapons.bombs.GBU_31` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_GBU31_V3` | `weapons.bombs.GBU_31_V_3B` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_AGM65D` | `weapons.missiles.AGM_65D` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_LUU2B` | `weapons.bombs.LUU_2B` | `RUNTIME_MAPPING_VALIDATED` |
| `AMMUNITION_AIM120` | `weapons.missiles.AIM_120C` for tested Bagram fighter payloads | `RUNTIME_MAPPING_VALIDATED_FOR_CURRENT_PAYLOADS` |
| `AMMUNITION_AIM9` | `weapons.missiles.AIM_9` | `RUNTIME_MAPPING_VALIDATED` |
| `EQUIPMENT_AAQ13` | `weapons.containers.F-15E_AAQ-13_LANTIRN` | `RUNTIME_MAPPING_VALIDATED` |
| `EQUIPMENT_AAQ14` | `weapons.containers.F-15E_AAQ-14_LANTIRN` | `RUNTIME_MAPPING_VALIDATED` |
| `EQUIPMENT_AAQ33` | `weapons.containers.AN_AAQ_33` | `RUNTIME_MAPPING_VALIDATED` |
| `EQUIPMENT_AAQ28` | `weapons.containers.AAQ-28_LITENING` | `RUNTIME_MAPPING_VALIDATED` |

`FLARES_CHAFF` bleibt eine strategische Planungsressource mit eigener Countermeasure-Matrix; dieser Vertrag erfindet keinen einzelnen DCS-STORAGE-Key für die aggregierte Planungsressource.

## 4. F-15E STRIKE – finales Mapping

`FIGHTER-STORE-RUNTIME-CORRELATION-1` beobachtete beim vorhandenen F-15E-STRIKE-Two-Ship:

```text
weapons.bombs.GBU_31       100 -> 98  delta -2
weapons.bombs.GBU_31_V_3B  100 -> 98  delta -2
```

Damit gilt:

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
```

Die beiden strategischen Ressourcen bleiben getrennt.

## 5. F-16 Deployment AIM-9 – finales Mapping

Der gleiche Lauf beobachtete bei normalem Ground-Crew-Rearm eines Bagram-F-16-Clients:

```text
weapons.missiles.AIM_9  98 -> 97 -> 96
cumulative STORAGE delta = -2

Aircraft ammo AIM_9  0 -> 1 -> 2
cumulative aircraft delta = +2
```

Damit gilt:

```text
AMMUNITION_AIM9 -> weapons.missiles.AIM_9
```

Der endliche Deploymentbestand und die Verlust-/Return-Semantik werden dadurch nicht verändert.

## 6. Fixed-Wing CAS Stores

### F-16C CAS Two-Ship

```text
weapons.bombs.GBU_12               -4
weapons.bombs.GBU_38               -4
weapons.containers.AN_AAQ_33       -2
weapons.droptanks.fuel_tank_370gal -4
weapons.missiles.AIM_120C          -4
```

Beim getesteten normalen Return wurden GBU-12, GBU-38, AAQ-33 und AIM-120C vollständig rückgebucht; der 370-gal-Tank wurde nicht beobachtet rückgebucht.

### F-15E CAS Two-Ship

```text
weapons.bombs.GBU_38                    -6
weapons.bombs.GBU_54_V_1B               -6
weapons.containers.F-15E_AAQ-13_LANTIRN -2
weapons.containers.F-15E_AAQ-14_LANTIRN -2
weapons.droptanks.F-15E_Drop_Tank       -4
weapons.missiles.AIM_120C                -2
weapons.missiles.AIM_9                   -2
```

Beim getesteten normalen Return wurden Bomben, Pods und A/A-Missiles vollständig rückgebucht; die externen Tanks nicht.

### Kandahar A-10C II CAS Two-Ship

```text
weapons.bombs.GBU_38               -8
weapons.bombs.LUU_2B               -16
weapons.containers.AAQ-28_LITENING -2
weapons.missiles.AGM_65D           -2
weapons.nurs.HYDRA_70_M156         -14
```

Diese fünf externen Stores wurden im dokumentierten normalen Return-Pfad vollständig rückgebucht, sofern nicht verbraucht.

## 7. Rotary-Wing Stores und Guns

### AH-64D

```text
weapons.nurs.HYDRA_70_M151            -76 per 2-ship
weapons.missiles.AGM_114K              -4 per 2-ship
weapons.droptanks.{IAFS_ComboPak_100}  -2 per 2-ship
```

IAFS ist `TECHNICAL_NON_STRATEGIC`, weil ein normaler Recredit nicht beobachtet wurde.

M230 hat keinen bestätigten direct STORAGE round mirror. Reale Abgabe ist über Onboard-/Debrief-Telemetrie belegbar.

### OH-58D

```text
weapons.containers.OH58D_M3P_L500 -1 per aircraft
weapons.nurs.HYDRA_70_M151        -7 per aircraft
```

`L500` wird nicht in strategische Einzelrunden umgerechnet.

### UH-60A / CH-47F

```text
UH-60A: no onboard weapon stock in tested template
CH-47F: weapons.containers.{CH47_PORT_M60D} and {CH47_STBD_M60D}
```

CH-47-Container wurden bei normalem Return rückgebucht. Ohne realen Schusstest wird keine Container-to-round-Konvertierung erfunden.

## 8. Externe Tanks

Owner-Entscheidung:

```text
F-15E external tank = TECHNICAL_NON_STRATEGIC
F-16 370-gal tank   = TECHNICAL_NON_STRATEGIC
```

Daraus folgt:

```text
no CampaignState stock
no strategic consumption
no artificial recredit
DCS/STORAGE operational availability only
```

## 9. Acceptance-Provenienz Fighter-Mapping

```text
Test: FIGHTER-STORE-RUNTIME-CORRELATION-1
Source/Builder commit: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
Internal mission SHA-256: 0f38447dade1934d63baa8e08ac536edd7865f47897f734450a8575594a19a2c
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: ec0238a8211d5804b1d1152190497b5e46ee8af45946e723abbe629efa22683f
debrief.log SHA-256: 89bca4398de33df36dffdbe67dca27b0e19a6ba330b02e5b0d927b28824f2fc5
Result: PASS
```

Vollständige Evidence:

```text
docs/evidence/fighter-store-runtime-correlation-acceptance-2026-08-13.md
```

## 10. Implementierungsgrenze

Verboten bleiben:

```text
automatic direct STORAGE round mirror for M230 or GAU-8 without evidence
invented shell-to-resource conversion factors
container-count == round-count assumptions
cross-use between M230 and GAU-8 resources
generic AMMUNITION_30MM fallback
generic AMMUNITION_50CAL fallback for OH-58 M3P
artificial external-tank recredit
```

Die konkreten Fighter-Mapping-Gates sind geschlossen. Ein zukünftiger schreibender CampaignState-to-STORAGE-Adapter oder ein strategischer Equipment-Reservation-/Result-Adapter bleibt separate Implementierungsarbeit und ist durch die Mapping-Tests nicht automatisch DCS-validiert.
