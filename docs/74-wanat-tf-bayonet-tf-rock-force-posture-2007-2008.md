---
document_id: OMW-HIST-WANAT-TF-BAYONET-TF-ROCK-FORCE-POSTURE
status: BINDING
document_class: SOURCE_CRITICAL_HISTORICAL_FORCE_POSTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical 2007-2008 RC-East force-posture reconstruction
  - TF Bayonet and TF Rock organizational strengths and disposition
  - historical FOB Fenty, FOB Blessing and Waygal Valley garrison models
  - historical Army aviation inventory, readiness allocation and support roles
  - Wanat/COP Kahler tactical-force, fires, ISR and reinforcement design lessons
not_authoritative_for:
  - active OMW ORBAT or exact 2010-2011 strengths
  - automatic persistence of 2007-2008 units, aircraft or procedures into the scenario period
  - current DCS terrain, radio or airfield implementation
  - current real-world operations or force protection procedures
scenario_period: 2010-08-01/2011-12-31
source_date: 2007-2008
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Wanat, TF Bayonet, TF Rock and RC-East Force Posture, 2007-2008

## 1. Purpose and source qualification

This document records operationally relevant force-strength, basing, aviation, sustainment, fire-support, ISR and outpost-design information from the official U.S. Army Combat Studies Institute Wanat source package:

- *Wanat: Combat Action in Afghanistan, 2008*, Combat Studies Institute Press, 2010, 268 pages;
- *Wanat Virtual Staff Ride Walkbook 2021.0*, Army University Press / Combat Studies Institute, 78 pages;
- *Battle of Wanat Staff Ride – 2nd Platoon, C Company, 173rd ABCT*, Visuals 2021.0.

The sources describe events and force posture principally from 2006 through July 2008. They predate the OMW scenario period. They are therefore authoritative only for the historical facts and explicit figures they report and for clearly labeled mission-design abstractions.

```text
SOURCE_REPORTED_2007_2008 != ACTIVE_OMW_2010_2011_ORBAT
NOMINAL_STRENGTH != LOCALLY_AVAILABLE_COMBAT_POWER
AIRCRAFT_INVENTORY != MISSION_READY_AIRCRAFT
BASE_OCCUPIED != RAPIDLY_REINFORCEABLE
```

## 2. Strategic and operational context

### 2.1 Economy-of-force campaign

The Wanat study characterizes Afghanistan during much of 2006-2008 as an economy-of-force campaign relative to Iraq. Sparse coalition force density required:

- very large battalion and brigade areas of operation;
- decentralized command and control;
- platoon-sized garrisons at many COPs;
- heavy reliance on rotary-wing movement and sustainment;
- continuous prioritization between population centers, routes, remote valleys and reserve forces.

By 2007, CJTF-82 and later CJTF-101 controlled RC-East from Bagram. The U.S. maneuver structure in RC-East centered on two brigades. The northern brigade area was assigned to the 173rd Airborne Brigade Combat Team, known as Task Force Bayonet.

### 2.2 RC-East outpost density

The CSI study reports approximately:

- 24 FOBs plus additional COPs under CJTF-82 in RC-East;
- around 120 combat outposts in RC-East under CJTF-101;
- roughly 50 rifle or maneuver companies, approximately 150 platoons;
- routine platoon garrisons of about 30-40 U.S. soldiers per outpost.

The operational constraint was explicit: the regional command normally could not allocate more than one U.S. platoon to an outpost regardless of local threat.

## 3. 173rd Airborne Brigade Combat Team / Task Force Bayonet

### 3.1 Organic brigade strength

The staff-ride organizational graphic gives an approximate organic brigade total of `3,395 PAX`:

| Formation | Internal breakdown | Source-reported strength |
|---|---|---:|
| 1-91 Cavalry | HHT 96; two motorized reconnaissance troops 140; dismounted reconnaissance troop 69 | 305 |
| 1-503 Infantry | HHC 171; three rifle companies 423; weapons company 71 | 665 |
| 2-503 Infantry | HHC 171; three rifle companies 423; weapons company 71 | 665 |
| 4-319 Field Artillery | HHB 76; target acquisition platoon 21; TUAV platoon 22; two firing batteries 188 | 307 |
| 173rd Special Troops Battalion | HHC 239; signal company 68; military intelligence company 133; engineer company 74 | 514 |
| 173rd Brigade Support Battalion | HHC 79; distribution company 214; maintenance company 109; medical company 72; four forward support companies 465 | 939 |
| **Organic total** | | **3,395** |

### 3.2 Deployed TF Bayonet strength

The CSI narrative reports approximately `3,000 U.S. soldiers` across TF Bayonet's five battalions, excluding TF Out Front. This lower deployed figure is consistent with the detachment of 1-503 Infantry from TF Bayonet for service under TF Fury and later TF Currahee.

```text
ORGANIC_BRIGADE_TOTAL = 3,395
DEPLOYED_TF_BAYONET_APPROX = 3,000
DIFFERENCE_REQUIRES_TASK_ORGANIZATION_CONTEXT
```

### 3.3 Task organization and basing

TF Bayonet retained:

- 2-503 Infantry as its only organic light-infantry battalion in the brigade AO;
- 1-91 Cavalry as reconnaissance, surveillance and target-acquisition formation;
- 4-319 Field Artillery, partly employed in an infantry role;
- 173rd Special Troops Battalion;
- 173rd Brigade Support Battalion.

Additional attached or supporting formations included:

- 3-103 Armor in Laghman from March 2008;
- Provincial Reconstruction Teams in the four provinces;
- TF Out Front / 2-17 Air Cavalry from January 2008;
- ANA, ANP, Afghan Border Police, Afghan Security Guards and embedded training teams at local level.

TF Bayonet's AO covered Nuristan, Nangarhar, Kunar and Laghman, approximately `15,058 square miles`, with around `2 million` inhabitants and approximately `125 miles` of border with Pakistan.

## 4. FOB Fenty / Jalalabad Airfield

### 4.1 Historical resident organizations

FOB Fenty at Jalalabad Airfield housed:

- TF Bayonet brigade headquarters;
- 173rd Special Troops Battalion;
- 173rd Brigade Support Battalion;
- brigade-level command, logistics, intelligence, signal, engineering, maintenance and medical support;
- TF Out Front / 2-17 Air Cavalry from January 2008.

FOB Fenty was therefore not merely an airfield parking location. It functioned as a brigade command-and-support hub and as the principal aviation base for the attached air-cavalry task force.

### 4.2 OMW abstraction

```text
FOB_FENTY_ROLE:
  brigade_command_hub
  brigade_support_hub
  aviation_operating_base
  QRF_launch_base
  MEDEVAC_launch_base
  logistics_distribution_node

HEADQUARTERS_AND_SUPPORT_PERSONNEL != MANEUVER_RESERVE
```

The source does not provide one exact total population for FOB Fenty. Any OMW estimate must therefore remain a derived planning figure, not a source fact.

## 5. TF Out Front / 2-17 Air Cavalry aviation inventory

### 5.1 Source-reported aircraft

| Aircraft | Quantity | Source-reported role |
|---|---:|---|
| OH-58D Kiowa Warrior | 14 | armed reconnaissance; limited suitability at higher altitudes north of the Pech River |
| UH-60 Black Hawk | 6 | air assault; movement of small numbers of personnel and supplies |
| CH-47 Chinook | 4 | heavy lift; larger personnel and supply movements; preferred high-altitude lift platform |
| AH-64 Apache | 6 | attack aviation, escort, QRF and close-combat attack |
| HH-60 air ambulance | 3 | air MEDEVAC |
| **Total** | **33** | historical source-reported inventory |

This is an Army aviation task-force inventory, not a USAF Air Expeditionary Wing.

### 5.2 AH-64 readiness allocation

The source gives a particularly valuable operational allocation for the six AH-64s:

| Allocation | Aircraft |
|---|---:|
| 24-hour QRF alert at Jalalabad | 2 |
| normally assigned to escort vulnerable CH-47s | 2 |
| normally in routine maintenance or battle-damage repair | 2 |

```text
AH64_TOTAL = 6
AH64_QRF_READY = 2
AH64_ESCORT_COMMITTED = 2
AH64_MAINTENANCE_OR_REPAIR = 2
AH64_SIMULTANEOUS_FREE_CAPACITY = LOW
```

This allocation is a historical snapshot/model, not a universal fixed ratio. Its value for OMW lies in distinguishing total inventory from ready, tasked and unavailable aircraft.

### 5.3 Altitude and role limitations

- OH-58D aircraft were described as unable to operate effectively in the higher terrain north of the Pech River.
- CH-47 was described as the best helicopter in the task force for high-altitude operations.
- UH-60 provided lighter air-assault and resupply capacity.
- HH-60 air ambulances provided dedicated airborne medical evacuation.

OMW planning variables:

```text
aircraft_total
aircraft_mission_ready
aircraft_tasked_qrf
aircraft_tasked_escort
aircraft_in_maintenance
aircraft_battle_damage_repair
high_altitude_performance_limit
lift_class
medical_configuration
```

## 6. TF Rock / 2-503 Infantry

### 6.1 Area and population

TF Rock's AO was approximately:

- `2,300 square miles`;
- `525,000` inhabitants;
- ten source-reported ethno-linguistic groups;
- fourteen dispersed bases by 13 July 2008, including COP Fiaz principally manned by Afghan police.

### 6.2 Force totals

The CSI study reports:

| Category | Approximate strength |
|---|---:|
| TF Rock organic U.S. personnel | 1,000 |
| Additional U.S. advisors and combat-support personnel | 400 |
| Total U.S. personnel in AO | 1,400 |
| Afghan security personnel | 2,500 |
| Combined security personnel | 3,900 |

The additional U.S. personnel included Marine embedded training teams and other combat-support elements. Afghan forces included ANA, ANP, Afghan Security Guards and Afghan Border Police.

Source-derived density:

```text
US_FORCE_DENSITY_APPROX = 2.7 per 1,000 inhabitants
ALL_SECURITY_FORCE_DENSITY_APPROX = 7.4 per 1,000 inhabitants
```

The source narrative rounds these to approximately two U.S. soldiers and six combined security personnel per 1,000 inhabitants. The precise arithmetic and the narrative rounding are both retained.

### 6.3 Operational activity

For its 14-month deployment, TF Rock reported:

- approximately `1,100` engagements;
- `5,400` fire missions;
- approximately `36,500` howitzer and mortar rounds;
- approximately `3,800` fixed-wing or rotary-wing bomb/gun runs;
- `131` Javelin and TOW missiles fired;
- `26` soldiers killed;
- `143` wounded.

These figures describe a highly active 2007-2008 deployment and must not be directly projected as 2010-2011 mission frequency without corroboration.

## 7. TF Rock company and platoon disposition

### 7.1 Destined Company / D Company

D Company was the mounted heavy-weapons company. A standard source-described platoon used four HMMWVs carrying combinations of:

- TOW;
- M2 .50-caliber machine gun;
- Mk 19 automatic grenade launcher.

Typical crews were three or four soldiers per vehicle.

Disposition included:

- company CP and one weapons platoon at FB Fortress, augmented by a Chosen Company rifle platoon;
- another weapons platoon at COP Chowkay with a partnered ANA platoon;
- other weapons elements attached to rifle companies and dispersed positions.

### 7.2 Able Company / A Company – Pech Valley

Able Company was TF Rock's main effort and retained all three rifle platoons, augmented by one weapons platoon.

| Position | Source-reported disposition |
|---|---|
| COP Honaker-Miracle | one U.S. rifle platoon and one partnered ANA platoon |
| COP Able Main | company CP, one U.S. rifle platoon, attached weapons platoon, ANA company CP and one ANA platoon |
| FB Michigan | one U.S. rifle platoon and one partnered ANA platoon |

A light/airborne rifle platoon is described as about `48 soldiers` in organizational terms. Actual outpost strength could be lower due to attachments, leave, casualties and tasking.

### 7.3 Battle Company / B Company – Korengal Valley

Battle Company retained three rifle platoons and received a weapons platoon.

| Position | Source-reported disposition |
|---|---|
| FB Vegas | one U.S. platoon and one ANA weapons platoon |
| Korengal Outpost | company CP, one U.S. platoon, attached weapons platoon, ANA weapons-company headquarters and two ANA platoons |
| FB Vimoto | one U.S. platoon and one ANA weapons platoon |

The Korengal accounted for almost 40 percent of TF Rock's troops-in-contact incidents.

### 7.4 Chosen Company / C Company – Waygal Valley

Chosen Company nominally contained three rifle platoons, but local availability was severely reduced:

- one platoon was detached to Destined Company;
- one platoon normally served as TF Rock QRF at FOB Blessing;
- only one platoon normally covered the Waygal Valley;
- this platoon was at times divided between COP Bella and COP Ranch House;
- the two available platoons rotated between Waygal duty and QRF duty.

```text
COMPANY_NOMINAL_PLATOONS = 3
PLATOON_DETACHED = 1
PLATOON_QRF = 1
PLATOON_LOCAL_WAYGAL = 1
LOCAL_PLATOON_MAY_SPLIT_BETWEEN_TWO_COPS = true
```

Chosen Company's AO accounted for roughly one tenth of TF Rock's combat activity, while its single local platoon covered an extensive and difficult area.

## 8. FOB Blessing / Camp Blessing

### 8.1 Resident forces and functions

FOB Blessing contained:

- TF Rock battalion headquarters and tactical-operations functions;
- partnered ANA battalion headquarters;
- one ANA company;
- one U.S. infantry platoon serving as battalion QRF;
- two 155-mm howitzers;
- fire-support, sustainment, medical and command functions.

The QRF platoon rotated with the platoon serving in the Waygal Valley to allow rest and maintenance.

### 8.2 Infrastructure and sustainment

Compared with austere COPs, Blessing included:

- showers;
- 24-hour dining facility;
- weight room;
- dedicated MWR facility;
- road and rotary-wing access.

This distinction is important:

```text
FOB_BLESSING = BATTALION_HUB
COP_BELLA_OR_RANCH_HOUSE = AUSTERE_FORWARD_GARRISON
```

## 9. Waygal Valley outpost models

### 9.1 COP Bella

Source-reported features:

- approximately `24 U.S. soldiers`;
- 120-mm mortar support for COP Ranch House;
- three observation posts on surrounding high ground;
- HLZ large enough for one helicopter;
- NGO medical clinic nearby;
- two foot trails onward to Aranas;
- strong dependence on air or narrow-route sustainment.

The source graphics show two 120-mm mortar positions. The narrative should be read as a mortar capability at the outpost, not as proof that every date had an identical weapon and crew configuration.

### 9.2 COP Ranch House

Source-reported garrison:

| Element | Strength |
|---|---:|
| U.S. soldiers | about 24 |
| ANA soldiers | 22 |
| Afghan Security Guards | 15 |

The force occupied a command post and five observation posts. The ASG primarily guarded the eastern position/gate and were assessed as low-quality local static guards. Aranas and Ranch House were reachable only on foot or by air from Bella.

### 9.3 COP Kahler / Wanat

The official CSI narrative reports a defending contingent of:

- `49 U.S. soldiers`;
- `24 ANA soldiers`;
- total `73` U.S./ANA defenders on 13 July 2008.

The staff-ride position graphic further breaks down the pre-attack layout:

| Position | Source-reported occupants |
|---|---|
| ANA traffic-control point | 10 ANA |
| U.S. traffic-control point / Chosen 2-1 | 6 U.S. |
| U.S. entry-control point / Chosen 2-2 | 7 U.S. plus 6 U.S. engineers |
| ANA positions | 3 U.S. Marine ETT, 14 ANA, 2 interpreters |
| Chosen 2-3 position | 3 U.S. |
| 120-mm mortar position | 6 U.S. |
| Command post | 6 U.S. plus 1 interpreter |
| TOW position | 3 U.S. |
| OP Topside | 9 U.S. |

These position-level numbers describe the staff-ride layout and can overlap with personnel later moving between positions. They must not be added blindly to derive a second total.

## 10. Force protection and outpost design

### 10.1 Recurrent constraints

The sources identify:

- dead space caused by steep valley terrain;
- limited high-angle artillery coverage;
- observation from surrounding high ground;
- narrow or absent roads;
- helicopter-only sustainment;
- small garrisons split among CP, ECP/TCP, mortar, TOW and OP positions;
- incomplete construction and delayed protective works;
- inability to hold a large mobile reserve while manning many fixed positions.

### 10.2 OMW outpost state model

```text
outpost_garrison_total
outpost_garrison_available
outpost_partner_force_strength
outpost_guard_force_quality
observation_post_coverage
high_ground_enemy_access
dead_space_exposure
overhead_cover_state
hesco_and_wall_completion
heavy_weapon_crew_strength
mortar_crew_strength
qrf_distance
qrf_readiness
road_access_class
hlz_capacity
weather_access_state
resupply_days_remaining
```

## 11. ROCK MOVE fires, aviation and ISR package

### 11.1 Source-reported available effects

The staff-ride visual for the 8-9 July 2008 operation lists:

| Capability | Source-reported allocation/callsign |
|---|---|
| AH-64 | 2 aircraft, `Hedgerow` |
| CAS | available, callsign TBD in the plan |
| 60-mm mortar | one company-internal system |
| 120-mm mortar at Bella | one system, `Thunder 5` |
| 120-mm mortar at Blessing | one system, `Chosen 95` |
| 155-mm at Blessing | two systems, `Thunderbolts` |
| 155-mm at Asadabad | two systems, `Cobra` |
| Predator | full-motion-video ISR |
| Warrior-A | full-motion-video ISR |
| Red Ridge | division SIGINT support |
| ICOM scanners | battalion SIGINT / warning |
| HCT 06 and HCT 01 | HUMINT tasking and warning |

### 11.2 Air and sensor stack

Source-reported altitude blocks:

| Layer | Altitude |
|---|---|
| Rotary wing | 0-10,000 ft MSL |
| UAS | 14,000-16,000 ft MSL |
| CAS / SIGINT | 17,000-24,000 ft MSL |

The source also states that Shadow could not support the operation while Predator/Warrior-A coverage was planned.

### 11.3 Air and fires tasks

CAS tasks included:

- non-standard ISR;
- preventing enemy reinforcement or escape;
- securing HLZs for infiltration/exfiltration;
- close air support as required.

AH-64 tasks included:

- securing COP Bella during infiltration/exfiltration;
- escorting equipment and personnel movement;
- non-standard ISR;
- close-combat attack.

OH-58D tasks included:

- armed reconnaissance;
- positive identification and screening of enemy movement;
- close-combat attack;
- observation of indirect fire and CAS;
- escort of non-standard MEDEVAC.

Mortars and artillery were assigned suppression and fixing effects to enable the ground force to establish the position and engage enemy forces.

## 12. Historical communications and callsigns

The staff-ride operational graphic records:

| Net/use | Historical source value |
|---|---|
| Rock TACSAT | CH 28 primary / CH 66 alternate |
| CAG | 57.850 FM |
| CAS | 69.350 FM |
| Chosen Fires | 80.175 FM |
| Plum 32 | 362.950 UHF |
| Brass 32 | 287.025 UHF |

Ground callsigns shown include:

- `Chosen 9` – Wanat;
- `Chosen 92` – Wanat;
- `Rock 6/9` – Camp Blessing;
- `Vino 20` – Camp Blessing.

These are historical source values only.

```text
HISTORICAL_NET != OMW_RUNTIME_NET
DCS_OR_MISSION_DEFINED_RUNTIME_VALUE = PLAYER_BRIEFING_AUTHORITY
```

## 13. Reinforcement, MEDEVAC and air-support timing lessons

The battle sequence demonstrates that nominal availability of CAS, attack aviation, QRF and MEDEVAC does not equal immediate effect at an isolated outpost. Response depended on:

- alert posture;
- aircraft location;
- flight time from Jalalabad or another base;
- weather and terrain;
- airspace coordination;
- threat and landing-zone condition;
- casualty collection and extraction capacity;
- requirement to maintain support for other missions.

OMW must therefore model response as a chain rather than an instantaneous spawn:

```text
REQUEST
  -> VALIDATION
  -> ASSET_SELECTION
  -> CREW_AND_AIRCRAFT_READY
  -> LAUNCH
  -> TRANSIT
  -> CHECK_IN
  -> TACTICAL_EMPLOYMENT
  -> RECOVERY_OR_RETASK
```

## 14. Sustainment and route-access lessons

The road north from Wanat was described as only wide enough for HMMWVs, preventing opposing traffic from passing. Aranas was accessible only by foot or air. Rotary-wing assets were scarce and weather-sensitive.

The sources therefore support:

```text
ROAD_PRESENT != TWO_WAY_CONVOY_CAPABLE
FOB_DISTANCE != TRAVEL_TIME
AIR_RESUPPLY_AVAILABLE != WEATHER_INDEPENDENT
SINGLE_HELICOPTER_HLZ -> SERIAL_LIFT_AND_MEDEVAC_CONSTRAINT
```

For mission design, an isolated COP should consume:

- water;
- food;
- ammunition;
- mortar/artillery stocks;
- medical supplies;
- engineer materials;
- generator fuel;
- aviation lift capacity;
- escort capacity.

## 15. Intelligence and warning model

The ROCK MOVE ISR plan used layered collection:

- battalion ICOM scanners for communications intercept and early warning;
- HCT 06 for local source reporting;
- division Red Ridge SIGINT for emitter location and cross-cueing;
- HCT 01 for additional HUMINT;
- Predator and Warrior-A for FMV confirmation and observation;
- cross-cueing between SIGINT and FMV.

The sources also demonstrate that continuous sensor coverage did not guarantee correct prediction of enemy intent or complete tactical warning.

```text
SENSOR_ON_STATION != ENEMY_INTENT_UNDERSTOOD
SIGINT_DETECTION != POSITIVE_IDENTIFICATION
FMV_COVERAGE != ALL_TERRAIN_VISIBLE
HUMINT_REPORT != TIMELY_CONFIRMED_WARNING
```

## 16. Enemy attack and observation design implications

The pre-operation assessment anticipated:

- enemy visual observation of coalition air and ground movement;
- ICOM warning networks;
- near ambushes along the ground route;
- command-wire IEDs;
- heavy weapons in support-by-fire positions;
- pre-positioned small groups using forward caches;
- engagement from the bazaar and nearby compounds;
- reinforcement moving back toward Wanat.

This supports a RED planning sequence:

```text
OBSERVE_MOVEMENT
  -> REPORT_BY_LOCAL_NETWORK
  -> ACTIVATE_CACHES
  -> OCCUPY_SUPPORT_BY_FIRE_POSITIONS
  -> EMPLACE_OR_ARM_IED
  -> ISOLATE_OUTPOST_OR_CONVOY
  -> INITIATE_COMPLEX_ATTACK
  -> BLOCK_OR_DELAY_REINFORCEMENT
  -> DISENGAGE_BEFORE_DECISIVE_COUNTERACTION
```

It does not justify scripted omniscience. Each step requires detection, communication, preparation and survivable command links.

## 17. Population, governance and infrastructure effects

The sources connect roads and bridges with:

- faster coalition mobility;
- easier civilian commerce;
- improved access to government and markets;
- reduced weather vulnerability;
- local employment;
- improved contact with community leaders;
- possible reduction in IED activity along improved routes.

They also show that completed projects and previous goodwill did not guarantee durable political alignment or tactical warning.

```text
PROJECT_COMPLETED != PERMANENT_POPULATION_SUPPORT
LOCAL_EMPLOYMENT != INSURGENT_NETWORK_REMOVED
PAST_COOPERATION != CURRENT_WARNING
ROAD_IMPROVEMENT -> BOTH_SECURITY_AND_ENEMY_MOBILITY_EFFECTS
```

## 18. Direct implications for OMW AIRWING/SQUADRON implementation

The historical aviation data should inform availability modeling, not be copied as an active 2010-2011 inventory decision.

Recommended abstract squadron states:

```text
TOTAL_ASSIGNED
MISSION_READY
QRF_ALERT
ESCORT_COMMITTED
AIR_ASSAULT_COMMITTED
MEDEVAC_ALERT
MAINTENANCE_SCHEDULED
BATTLE_DAMAGE_REPAIR
CREW_REST
WEATHER_RESTRICTED
ALTITUDE_RESTRICTED
```

For the 2008 Jalalabad example:

```text
OH58D_TOTAL_SOURCE = 14
UH60_TOTAL_SOURCE = 6
CH47_TOTAL_SOURCE = 4
AH64_TOTAL_SOURCE = 6
HH60_MEDEVAC_TOTAL_SOURCE = 3
```

These values are historical evidence for plausible order-of-magnitude and task allocation. Document 19 remains authoritative for active OMW ORBAT decisions.

## 19. Direct implications for FOB and COP implementation

A historically plausible FOB/COP model should distinguish:

| Facility class | Typical function |
|---|---|
| brigade hub | headquarters, support battalions, aviation and regional logistics |
| battalion FOB | battalion command, artillery/mortars, QRF, sustainment and partner HQ |
| company position | company CP, one or more platoons, local partner force and limited sustainment |
| platoon COP | 20-40 U.S. personnel, partner forces, OPs, limited heavy weapons and austere sustainment |
| split-platoon position | approximately 20-25 U.S. personnel, high dependency on fires and reinforcement |
| observation post | squad/section-sized, limited endurance and evacuation options |

These are role classes, not fixed spawn templates.

## 20. Source contradictions and precision limits

1. The staff-ride graphic gives `3,395 PAX` for the organic brigade while the CSI narrative gives about `3,000` TF Bayonet personnel excluding aviation. Both are retained because they describe different task-organization scopes.
2. The virtual-staff-ride cover displays `13 AUG 2008`, while the documented battle occurred on `13 July 2008`. The internal content consistently addresses the July battle; the cover date is treated as a source artifact or labeling error.
3. Position-level Wanat strengths must not be summed without checking overlap and personnel movement.
4. Aircraft totals describe a 2008 supporting task force and do not establish 2010-2011 Jalalabad inventory.
5. Approximate values remain approximate; they are not silently converted into exact headcounts.
6. Ethnic, tribal or local identity in the source does not imply automatic insurgent or government alignment.

## 21. Source hierarchy

For Wanat and 2007-2008 force posture:

```text
CSI 2010 historical study
  > 2021 official staff-ride walkbook
  > 2021 staff-ride visual package
  > OMW derived abstraction
```

The later staff-ride products are valuable for organization graphics, terrain views and position-level diagrams. When they conflict with the researched 2010 historical narrative, the conflict must be recorded rather than silently reconciled.

## 22. Sources

- Combat Studies Institute Press, *Wanat: Combat Action in Afghanistan, 2008*, 2010.
- Army University Press / Combat Studies Institute, *Wanat Virtual Staff Ride Walkbook 2021.0*.
- Army University Press / Combat Studies Institute, *Battle of Wanat Staff Ride – 2nd Platoon, C Company, 173rd ABCT*, Visuals 2021.0.
