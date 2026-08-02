---
document_id: OMW-HIST-BALUCH-KALAY-AIR-ASSAULT-2005
status: BINDING
document_class: SOURCE_CRITICAL_OPERATIONAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical reconstruction of the 3 May 2005 Baluch Kalay action
  - source-qualified air-assault, terrain, aviation, fires, casualty and command lessons
  - mission-design evidence for disrupted insertion, split-force and crossing-control states
not_authoritative_for:
  - active 2010-2011 OMW ORBAT
  - automatic reuse of the 2005 task organization
  - independently verified casualty or enemy-loss totals
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/army-history-baloch-kalay-cultural-turn
source_commit: PENDING_MERGE
supersedes: []
superseded_by: []
scenario_period: 2010-08-01/2011-12-31
historical_source_period: 2005-05-03
validated_in_dcs: false
---

# Baluch Kalay: Air Assault, Company Combat and Adaptive Command, 3 May 2005

## Purpose

This document converts the first-person U.S. Army account **“The Battle of Baluch Kalay”** by Maj. Dirk D. Ringgenberg into a controlled historical and mission-design reference for Operation Mountain Watch (OMW).

The source describes a twelve-hour engagement on 3 May 2005 in the Arghandab Valley, Zabul Province, involving Company C, 2d Battalion (Airborne), 503d Infantry, 173d Airborne Brigade, supported by Army aviation, close air support, a battalion scout platoon, Afghan National Police and a small Special Forces element.

The source predates the OMW scenario period. It is authoritative for the documented 2005 action and for historical task-organization, timing, terrain, air-assault and tactical-friction lessons. It is not authority for the active OMW ORBAT or for automatic persistence of 2005 dispositions into 2010–2011.

## Source

- *Army History*, Spring 2009, No. 71.
- Article: Dirk D. Ringgenberg, “The Battle of Baluch Kalay.”
- Publisher: U.S. Army Center of Military History.
- Source type: official Army professional-history bulletin; participant-authored tactical narrative.

Source limits:

```text
PARTICIPANT_ACCOUNT != COMPLETE_THEATER_RECORD
SOURCE_REPORTED_KILLS != INDEPENDENTLY_VERIFIED_COUNT
2005_TASK_ORGANIZATION != 2010_2011_ORBAT
```

## Operational setting

- Date: 3 May 2005.
- Area: Arghandab Valley, Zabul Province.
- Friendly base: FOB Lagman, outside Qalat.
- Approximate distance FOB Lagman to Baluch Kalay: 50 miles.
- Approximate one-way helicopter flight time: 45 minutes.
- Initial friendly problem: battalion scout platoon and a small Afghan National Police contingent engaged by a large Taliban force.
- Initial loss: one scout Humvee destroyed by RPG fire.
- Scout response: hasty defense on a small hill east of the Arghandab River and request for immediate reinforcement.

The battalion had deployed between February and early April 2005 and operated in an area with no meaningful ANA presence and only limited ANP coverage. This reinforces the distinction:

```text
NOMINAL_GOVERNMENT_CONTROL != AVAILABLE_PARTNER_FORCE
DISTRICT_ASSIGNMENT != ROUTINE_SECURITY_PRESENCE
```

## Friendly task organization

### Company C leadership and enablers

The documented company command group included:

- company commander;
- executive officer;
- first sergeant;
- fire support officer;
- fire support NCO;
- USAF Joint Terminal Attack Controller;
- senior medic;
- 60-mm mortar section leader;
- three rifle platoon leaders and platoon sergeants.

### Air-assault allocation

First lift:

- 2 x CH-47;
- company headquarters;
- 3d Platoon;
- 60-mm mortar section;
- approximately 60 personnel total.

Second lift:

- 1st Platoon elements;
- battalion commander;
- battalion S-3;
- command sergeant major;
- battalion S-2;
- security squad;
- approximately 28 personnel.

Base security:

- 2d Platoon remained at FOB Lagman.

Escort and air support:

- 2 x AH-64 initially assigned for security;
- later 2 x A-10 employed;
- additional AH-64 aircraft later available but constrained by target identification and proximity of friendly forces.

Additional friendly elements:

- battalion scout platoon;
- small Afghan National Police contingent;
- nine-man Special Forces team inserted on a later lift.

### Planning assumptions

- two CH-47s, each with space for approximately 28 personnel;
- troops packed water and ammunition for up to 72 hours;
- second lift expected about 95 minutes after the first;
- assault plan developed under severe time pressure, mainly verbally and with limited maps and black-and-white aerial imagery.

## Original scheme of maneuver

```text
HLZ 1, north of Baluch Kalay:
  3d Platoon
  attack south as main effort

HLZ 2, south of Baluch Kalay:
  company headquarters
  machine guns
  support-by-fire position

Second lift:
  1st Platoon follows and supports the attack
```

The two planned landing zones were on the west side of the Arghandab River.

## Air-assault disruption

The CH-47 carrying the company headquarters and machine-gun element received small-arms fire on approach to HLZ 2. An RPG struck near the tail and detonated under the rear ramp, causing the aircraft to spin at very low altitude.

The crew initially aborted and headed toward FOB Lagman. The company commander insisted that the aircraft land because 3d Platoon was already on the ground. The aircraft returned and landed at an unplanned site, designated HLZ 3, on the east side of the river.

Operational model:

```text
PLANNED_HLZ
  -> ENEMY_FIRE
  -> AIRCRAFT_DAMAGE
  -> ABORT_OR_CONTINUE_DECISION
  -> EMERGENCY_HLZ
  -> SPLIT_FORCE
  -> REVISED_SCHEME_OF_MANEUVER
```

Mission-design implication:

```text
AIR_ASSAULT_LAUNCHED != FORCE_INSERTED_AS_PLANNED
ESCORT_PRESENT != SAFE_HLZ
AIRCRAFT_AIRBORNE != AIRCRAFT_MISSION_EFFECTIVE
```

## Terrain and mobility

Documented terrain characteristics:

- Arghandab River approximately 50–75 m wide;
- cold, swift current fed by snowmelt;
- thick orchards along both banks for roughly 2 km;
- vegetation already about 1 m high in early May;
- terraced agricultural ground;
- steep mountains and dominant high ground;
- Baluch Kalay composed of roughly 20 mud compounds;
- compound walls approximately 3–5 m high;
- settlements on both sides of the river;
- one critical improvised footbridge of logs, sticks, boards, mud and twine.

Operational effects:

```text
RIVER = MANEUVER_BARRIER
BRIDGE = SINGLE_POINT_OF_FAILURE
ORCHARD = CONCEALMENT_AND_TARGET_IDENTIFICATION_PROBLEM
HIGH_GROUND = OBSERVATION_AND_FIRE_ADVANTAGE
COMPOUND_WALLS = CLOSE_COMBAT_AND_CHANNELIZATION
```

## Enemy behavior and tactical system

The source documents the following Taliban behaviors:

- rapid maneuver against a lightly protected scout element;
- RPG use against a Humvee and CH-47;
- occupation of dominant terrain;
- contesting landing zones;
- concentration of fire on a support-by-fire position;
- use of dense orchards for movement and concealment;
- attempt to destroy the only bridge to isolate friendly elements;
- use of unsecured handheld radios;
- withdrawal attempts through vegetation;
- deception by discarding a weapon and posing as a civilian agricultural worker;
- use of terrain and distributed positions rather than concentration in the village itself.

Derived adversary process:

```text
OBSERVE_ISOLATED_FORCE
  -> ATTACK_LIGHT_VEHICLE
  -> OCCUPY_HIGH_GROUND
  -> CONTEST_HLZ
  -> ISOLATE_BY_DESTROYING_CROSSING
  -> SUPPRESS_SUPPORT_BY_FIRE
  -> WITHDRAW_THROUGH_ORCHARD
```

The source supports adaptive and locally coordinated enemy behavior. It does not establish a universal Taliban template.

## Intelligence and communications

A captured Taliban handheld radio monitored by the Afghan interpreter provided real-time insight into:

- enemy attempts to escape;
- the effect of the support-by-fire position;
- the intended destruction of the bridge;
- enemy distress and local coordination.

This information enabled rapid friendly decisions.

```text
LOCAL_LANGUAGE_CAPABILITY + SIGNAL_INTERCEPT
  -> ENEMY_INTENT_INDICATION
  -> MANEUVER_DECISION
  -> BRIDGE_SECURITY_PRIORITY
```

The interpreter also contributed tactical judgment and identification of deception. The source therefore supports:

```text
INTERPRETER != PASSIVE_TRANSLATION_ASSET
LOCAL_KNOWLEDGE = TACTICAL_ENABLER
```

## Fires and aviation employment

### Support-by-fire

The machine-gun position established from the unplanned eastern landing area became decisive by blocking enemy withdrawal and fixing fighters in the valley.

### Mortars

The 60-mm mortar section was mistakenly retained near HLZ 1 instead of accompanying the assault. The company commander discovered this during the attack and had to compensate with speed and external fires.

```text
MORTAR_ASSIGNED != MORTAR_AT_POINT_OF_NEED
```

### A-10

The JTAC coordinated A-10 strikes on enemy positions on the mountainside. The source reports successful suppression and engagement, though one weapon description in the article appears inconsistent with standard A-10 armament terminology and must not be silently normalized.

### AH-64

AH-64 crews requested targets, but dense vegetation, uncertain enemy locations and close friendly proximity prevented immediate employment in parts of the fight.

```text
ATTACK_HELICOPTER_PRESENT != CLEAR_TARGET_SOLUTION
ASSET_AVAILABLE != ASSET_EMPLOYABLE
```

## Medical and casualty handling

The action included:

- immediate treatment of wounded personnel;
- use of a senior company medic;
- assistance from a Special Forces medic;
- casualty evacuation by helicopter;
- medical stabilization under fire;
- movement of wounded personnel to landing zones despite dispersed company elements.

Mission-design states:

```text
CASUALTY_OCCURRED
  -> POINT_OF_INJURY_CARE
  -> STABILIZATION
  -> MOVEMENT_TO_HLZ
  -> AIR_MEDEVAC
```

## Command and control lessons

The action demonstrates:

- rapid planning with incomplete information;
- verbal orders under time pressure;
- loss of the original scheme through enemy action;
- company-level replanning while split by a river;
- coordination of battalion leadership, scouts, aviation, JTAC, platoons, interpreters and later-arriving SOF;
- importance of protecting the sole crossing site;
- need to preserve command relationships when forces land at unexpected locations.

```text
PLAN_QUALITY != EXECUTION_CERTAINTY
COMMANDER_INTENT + SUBORDINATE_INITIATIVE = ADAPTIVE_COHESION
```

## OMW implementation guidance

### Air-assault mission states

```text
PLANNED
ALERTED
MANIFESTING
AIRBORNE
ENROUTE
CONTACT_ON_APPROACH
DIVERTED
PARTIALLY_INSERTED
SPLIT_FORCE
REPLANNING
ASSAULTING
CONSOLIDATING
CASEVAC_OR_MEDEVAC
EXTRACTING
```

### Landing-zone risk fields

```text
enemy_observation_probability
enemy_small_arms_coverage
enemy_rpg_coverage
approach_exposure
terrain_masking
landing_surface_capacity
alternate_hlz_distance
friendly_force_separation
cas_deconfliction_risk
```

### Bridge and crossing model

```text
crossing_status:
  OPEN
  CONTESTED
  DAMAGED
  DESTROYED
  TEMPORARY

crossing_effect:
  isolate_force
  delay_reinforcement
  block_casevac
  channel_movement
  create_ambush_opportunity
```

### Required distinction

```text
HISTORICAL_CASE_STUDY = DESIGN_EVIDENCE
HISTORICAL_CASE_STUDY != SCRIPTED_REENACTMENT_REQUIREMENT
```

## Cross-references

Relevant OMW documents include:

- Document 49: MSR and route design;
- Document 52: Army aviation;
- Document 62: insurgent intelligence and TTP;
- Document 67: route clearance and counter-IED;
- Document 74: Wanat, TF Bayonet and RC-East force posture;
- Document 75: Vanguard of Valor small-unit operations;
- Document 77: ARSOF and early OEF operational models.

## Binding conclusions

1. A planned air assault may result in partial, dispersed or unplanned insertion.
2. Enemy fire on the approach and at the HLZ must be capable of altering the mission rather than serving only as visual decoration.
3. A single bridge, ford or crossing can become the decisive terrain feature.
4. Aviation availability does not imply immediate tactical employability.
5. Local-language capability and interpreters may provide tactical intelligence and judgment.
6. Assigned enablers must be tracked by actual location and availability.
7. Dense vegetation and close friendly proximity must constrain CAS and attack-helicopter employment.
8. The 2005 task organization is a historical model, not a 2010–2011 active ORBAT.