---
document_id: OMW-AIR-KANDAHAR-OH58D-ARMAMENT-DECISION
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar OH-58D standard Mission Editor payload
  - interpretation of DCS H10 and H17 rocket presets
  - period-correct exclusion of APKWS from the active scenario
  - mission-specific OH-58D alternate payloads
  - provisional DCS fuel limit for the standard payload
scenario_period: 2010-08-01/2011-12-31
reference_date: 2026-08-01
source_branch: docs/bagram-air-operations-manifest
observed_mission_editor_artifact: OMW_Template_v4_Kandahar.miz screenshot dated 2026-08-01
historical_evidence_status: SUPPORTED_NO_UNIVERSAL_SORTIE_LOADOUT_PROVEN
validated_in_dcs: false
---

# Kandahar OH-58D Armament and Loadout Decision – 01.08.2026

## 1. Purpose and authority

This document records the current project decision for the OH-58D Kiowa Warrior assigned to the Kandahar Mustang Ramp node.

It distinguishes between:

- weapons technically available to the OH-58D;
- weapons demonstrably used by the type in Afghanistan;
- the meaning of the DCS payload labels;
- the binding Operation Mountain Watch default payload;
- mission-specific alternate payloads;
- weapons that are available in DCS but are outside the scenario period.

No reviewed source proves one universal loadout used on every OH-58D sortie. The term `standard payload` therefore means the binding OMW Mission Editor and runtime baseline, not a claim that every historical aircraft always flew with the same stores.

## 2. DCS H10 and H17 interpretation

The DCS OH-58D payload list uses abbreviated labels:

| DCS label | Historical warhead | Meaning | Launcher quantity |
|---|---|---|---:|
| `H10 Rockets` | M151 HE | 10-pound-class high-explosive fragmentation warhead | 7 rockets in one M260 launcher |
| `H17 Rockets` | M229 HE | heavier 17-pound-class high-explosive fragmentation warhead | 7 rockets in one M260 launcher |

`H10` and `H17` identify the approximate warhead weight class. They do not mean ten or seventeen rockets.

The observed DCS presets relevant to this decision are:

```text
H10 Rockets, Gun
  1 × seven-shot M260 rocket launcher with M151 HE
  1 × M3P .50-caliber machine gun
  DCS ammunition display: 7 rockets / 500 gun rounds

H17 Rockets, Gun
  1 × seven-shot M260 rocket launcher with M229 HE
  1 × M3P .50-caliber machine gun
  DCS ammunition display: 7 rockets / 500 gun rounds
```

The M229 is a heavier HE/fragmentation alternative. It is not a precision-guided weapon and is not a substitute for AGM-114 Hellfire against targets requiring guided point-target engagement.

## 3. Historical evidence boundary

The following points are sufficiently supported:

1. The OH-58D weapon family included 2.75-inch Hydra rockets, AGM-114 Hellfire and the M3P .50-caliber machine gun.
2. The M3P became the preferred OH-58D gun for deployed units in Iraq and Afghanistan from 2008/2009 onward.
3. A contemporary U.S. Army gunnery report dated May 2011 explicitly identifies the M151 HE rocket as the Kiowa's commonly used `10-pounder`.
4. Official Afghanistan imagery and video show OH-58D operations with rockets and the .50-caliber gun, and separate aircraft with Hellfire. Some of this corroborating media is dated 2012 and is therefore supporting context rather than direct evidence for every sortie inside the OMW period.
5. A March 2011 U.S. Army report confirms that Troop E, 7th Squadron, 17th Cavalry Regiment operated a Kandahar FARP that armed and refueled OH-58D aircraft. It does not establish a single fixed payload for all missions.

The reviewed evidence does not establish that M229 was the routine default in Kandahar. The M151 is better documented as the normal general-purpose Kiowa HE rocket during the relevant period.

## 4. Binding OMW payload policy

### 4.1 Default RECON/AFAC and general escort payload

```text
DCS preset: H10 Rockets, Gun
Stores:
  7 × Hydra 70 with M151 HE warhead
  M3P .50-caliber machine gun with 500 rounds in the DCS preset
Role:
  RECON
  AFAC
  route and convoy security
  general armed escort
  response against personnel, weapon teams and soft vehicles
```

This is the binding default for:

```text
TPL_AIR_US_KAF_OH58D_RECON_2SHIP
TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
```

The default remains subject to DCS runtime, hot-and-high performance and AI weapon-employment validation.

### 4.2 Authorized heavy-HE alternate

```text
DCS preset: H17 Rockets, Gun
Stores:
  7 × Hydra 70 with M229 HE warhead
  M3P .50-caliber machine gun
Use:
  stronger blast and fragmentation effect
  field fortifications
  compound walls or positions requiring more effect than M151
Status:
  authorized mission-specific alternate
  not the general default
```

H17 must not be described as an anti-armour or precision weapon.

### 4.3 Authorized guided alternate

```text
DCS preset: Hellfire, Gun
Use:
  identified point targets
  vehicles or protected targets
  targets for which guided engagement is tactically and legally appropriate
Status:
  mission-specific alternate
  not the routine RECON/AFAC default
```

Two-Hellfire and dual-rocket-pod configurations remain available only as explicitly selected task payloads. They are not the baseline because they remove the gun or increase weight while reducing the flexibility required for routine armed reconnaissance.

### 4.4 Smoke and illumination

Smoke or illumination rocket configurations are mission-specific support loads. They require a documented marking, illumination or coordination requirement and are not standard combat loads.

### 4.5 Stinger

Stinger presets are excluded from the routine Afghanistan payload set because the active OMW threat model does not contain an operational hostile air threat requiring OH-58D air-to-air self-defence stores.

A Stinger load may only be introduced by a separate scenario or threat decision. DCS availability alone is not sufficient.

### 4.6 APKWS exclusion

APKWS is excluded from the active OMW period and from the standard Kandahar OH-58D payload set.

Reason:

- the OMW scenario ends on 31.12.2011;
- NAVAIR records APKWS Initial Operating Capability in March 2012 on U.S. Marine Corps AH-1W and UH-1Y helicopters;
- first Afghanistan fielding occurred in 2012;
- successful OH-58D integration or demonstration testing does not prove operational U.S. Army OH-58D employment during the OMW period.

Therefore the DCS presets containing APKWS are technically available but historically out of scope for this campaign baseline.

## 5. DCS weight finding from the current screenshot

For the selected `H10 Rockets, Gun` preset, the Mission Editor screenshot shows:

```text
Equipped empty weight: 4,184 lb
Weapon weight:           558 lb
Internal fuel at 100%:   736 lb
Displayed total:       5,478 lb
Maximum weight:        5,200 lb
Displayed loading:       105%
```

The selected aircraft is therefore 278 lb above the DCS maximum at 100% internal fuel.

Maximum fuel without changing the observed weapon load:

```text
5,200 - 4,184 - 558 = 458 lb fuel
458 / 736 = approximately 62.2% internal fuel
```

Binding provisional Mission Editor value:

```text
H10 Rockets, Gun
Internal fuel: 60%
Approximate DCS total: 5,184 lb
```

The template must not be saved with this payload and 100% internal fuel. The 60% value is a weight-compliant starting point, not a completed performance acceptance. It must be validated under Kandahar temperature, density-altitude, formation, route-length and reserve-fuel conditions.

## 6. Flight-level employment

The current baseline applies the same default preset to both aircraft of the two-ship template. A complementary mixed flight, for example one `H10 Rockets, Gun` aircraft and one `Hellfire, Gun` aircraft, is tactically plausible but is not yet a binding template decision.

Before introducing mixed unit payloads, verify:

- whether the DCS group and MOOSE-spawn path preserve per-unit payload differences;
- AI employment of M151, M229, M3P and Hellfire;
- rearming behaviour at Kandahar and FARPs;
- fuel and maximum-weight compliance for each unit;
- whether RECON/AFAC tasking causes unwanted autonomous weapon employment.

## 7. Runtime and Mission Editor acceptance requirements

```text
TPL_AIR_US_KAF_OH58D_RECON_2SHIP uses H10 Rockets, Gun unless a task-specific payload is selected
TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP uses H10 Rockets, Gun unless a task-specific payload is selected
no APKWS in active 2010-2011 payload sets
no routine Stinger payload
H17 remains an explicitly selected heavy-HE alternate
Hellfire remains an explicitly selected guided alternate
all units remain at or below the DCS maximum weight
60% internal fuel is treated as provisional until hot-and-high testing passes
MOOSE payload assignment does not silently replace the documented preset
AI does not fire without the intended AUFTRAG, ROE and target authorization
```

## 8. Open questions

- exact operational frequency of M229 use by 7-17 Cavalry at Kandahar;
- whether the two-ship escort template should later receive complementary mixed payloads;
- validated fuel fraction for representative Kandahar missions;
- AI accuracy, minimum range and collateral-effect behaviour for M151 and M229;
- FARP ammunition availability and rearming rules;
- mapping between DCS payload identifiers and later MOOSE payload registration.

## 9. Sources

Primary and official sources reviewed:

- U.S. Army, `Kiowa Warrior gains firepower`, 06.05.2009: https://www.army.mil/article/20656/kiowa_warrior_gains_firepower
- U.S. Army, `6-6 Cavalry aircrews field new Kiowa Warrior weapons system`, 06.04.2009: https://www.army.mil/article/19271/6_6_cavalry_aircrews_field_new_kiowa_warrior_weapons_system
- U.S. Army, `4-6 ACS Conducts Annual Gunnery Qualifications`, 20.05.2011: https://www.army.mil/article/56830/4_6_acs_conducts_annual_gunnery_qualifications
- U.S. Army, `Safety, teamwork aid in FARP success`, 04.03.2011: https://www.army.mil/article/52876/safety_teamwork_aid_in_farp_success
- U.S. Army, `OH-58D Kiowa Warrior`, 04.11.2014: https://www.army.mil/article/137587/OH_58D_KIOWA_WARRIOR/
- DVIDS, `OH-58D Kiowas Fire Rockets and .50 Cal Machine Gun`, Afghanistan, 03.03.2012: https://www.dvidshub.net/video/138977/oh-58d-kiowas-fire-rockets-and-50-cal-machine-gun
- DVIDS, `Kiowa Warrior`, Jalalabad, Afghanistan, 02.03.2012: https://www.dvidshub.net/image/536069/kiowa-warrior
- NAVAIR, `Marine helicopters deploy with laser-guided rocket`, 17.04.2012: https://www.navair.navy.mil/node/18941
- NAVAIR, `APKWS` product page: https://www.navair.navy.mil/product/APKWS

Source-use boundary:

- official Army sources establish the OH-58D weapon family, the M3P deployment context and M151 `10-pounder` terminology;
- the Kandahar FARP report establishes local operational arming support but not one universal payload;
- 2012 Afghanistan media is corroborative and lies outside the strict scenario end date;
- NAVAIR chronology supports exclusion of APKWS from the 2010-2011 baseline.

## 10. Change boundary

This decision changes documentation only. It does not modify a `.miz`, Lua runtime file, MOOSE bundle, payload database or warehouse inventory.
