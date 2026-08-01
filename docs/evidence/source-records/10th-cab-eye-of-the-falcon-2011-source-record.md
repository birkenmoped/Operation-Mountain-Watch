# 10th CAB / Task Force Falcon source record — 2011

## Status and authority

This source record supplements the project-wide July 2011 ORBAT authority defined for:

```text
122362406-Afghanistan-order-of-battle-july-2011.pdf
```

The July 2011 ORBAT remains the primary unit-and-location snapshot. The contemporary `Eye of the Falcon` publications below are first-party 10th Combat Aviation Brigade publications and are authoritative supplements for company identity, aircraft type, mission role, operational attachment, forward location, transfer of authority and selected explicit aircraft counts.

They do not automatically provide a complete aircraft inventory for a base or task force.

## Sources evaluated

### `pdf_8055.pdf`

`Eye of the Falcon`, January 2011.

Relevant findings:

- Task Force Phoenix — Bagram Airfield;
- Task Force Tigershark — FOB Salerno;
- Task Force Knighthawk — FOB Shank;
- Task Force Shooter — FOB Fenty;
- Task Force Eagle, Task Force ODIN-A and Task Force Taeguek — Bagram Airfield;
- Task Force Gambler and Task Force Hippo — FOB Sharana;
- Bagram was described as home to ODIN, Phoenix, Mountain Eagle and Renegades;
- Task Force Tigershark imagery and captions confirm CH-47, OH-58 and UH-60 activity in Khost Province;
- contractor-operated Puma S330J flights moved personnel and supplies between Bagram and outlying RC-East locations. This is transient/support activity and not a U.S. Army aircraft inventory.

### `pdf_8632.pdf`

`Eye of the Falcon`, April 2011.

Relevant findings:

- Task Force Mountain Eagle avionics supported more than 170 aircraft across the brigade support mission;
- supported aircraft families were OH-58, AH-64, UH-60 and CH-47;
- the figure `over 170 aircraft` is a brigade-wide maintenance workload, not a Bagram inventory;
- Company C, 5th Battalion, 159th Aviation Regiment, `Cowboy Dustoff`, assumed Khost Province MEDEVAC responsibility on 25 March 2011;
- Cowboy Dustoff replaced Company C, 2nd Battalion, 104th Aviation Regiment;
- the active July 2011 Salerno/Khost Army MEDEVAC unit is therefore C/5-159 AVN unless a stronger date-specific source proves otherwise;
- Company C, Task Force Phoenix, flew UH-60 Black Hawk MEDEVAC missions into the Pech and Konar valleys and used FOB Fenty/Jalalabad as a forward operating and patient-transfer location.

### `pdf_8984.pdf`

`Eye of the Falcon`, June 2011.

Relevant findings:

- Company A, 1st Battalion, 169th General Support Aviation Regiment, was attached to Task Force Phoenix;
- A/1-169 GSAR operated UH-60 Black Hawks in the Bagram/Parwan support area;
- a documented 11 June mission inserted a TF Phoenix team at the Salang Girls' School;
- A/1-169 is therefore a directly evidenced TF Phoenix utility/transport UH-60 company for the June/July 2011 baseline;
- Task Force Gambler transferred authority at FOB Sharana to Task Force Attack on 24 June 2011;
- both formations operated mixed AH-64, OH-58, CH-47 and UH-60 fleets;
- the 10th CAB announced the forthcoming replacement of its MEDEVAC company by the 82nd CAB, confirming rotation rather than permanent identity.

### `Eye of the Falcon`, July 2011

Project-supplied contemporary brigade publication.

Relevant findings already adopted by the project:

- Task Force Phoenix — Bagram;
- Task Force Tigershark — Salerno;
- Task Force Knighthawk — Shank;
- Task Force Six-Shooters — Fenty;
- Company B `Killer Spades`, 1-10 Aviation, operated eight AH-64D at FOB Fenty;
- Company C `Mountain Dustoff`, 3-10 Aviation, operated UH-60 MEDEVAC aircraft;
- Mountain Dustoff had flown more than 2,300 missions and transported more than 3,500 patients by July 2011;
- flight nurses were attached to MEDEVAC elements at different locations in RC-East, proving distributed operation rather than one-ramp concentration.

### `Eye of the Falcon`, August 2011

Project-supplied contemporary brigade publication.

Relevant findings already adopted by the project:

- C/3-10 GSAB `Mountain Dustoff` operated with Task Force Knighthawk at FOB Shank;
- C/3-82 GSAB replaced C/3-10 GSAB on 20 August 2011;
- B/7-158 Aviation and B/2-135 Aviation both contributed CH-47 crews to Task Force Knighthawk operations;
- a task-force or base CH-47 total must not be equated with the separately reconstructed B/7-158 deployment pool.

## Binding interpretation rules

```text
JULY 2011 ORBAT = primary unit/location baseline
EYE OF THE FALCON = first-party company/type/role/attachment supplement
MISSION PRESENCE != PERMANENT BASING
TASK-FORCE MEMBERSHIP != EVERY AIRCRAFT ON THE HQ RAMP
BRIGADE MAINTENANCE WORKLOAD != BASE INVENTORY
ATTACHED COMPANY != ORGANIC BATTALION COMPANY
VISIBLE AIRCRAFT != ASSIGNED INVENTORY
```

## Bagram conclusions

### Utility UH-60

Directly evidenced company:

```text
A Company, 1st Battalion, 169th General Support Aviation Regiment
Task Force Phoenix
UH-60 Black Hawk
Bagram/Parwan support context
```

Binding conclusion:

```yaml
Bagram_UH60_Utility:
  unit: A Company, 1-169 Aviation Regiment
  attached_to: Task Force Phoenix
  aircraft_family: UH-60 Black Hawk
  presence_confirmed: true
  exact_inventory: unresolved
```

This replaces the earlier assumption that only a generic `3-10 GSAB UH-60 Utility` label could be used. TF Phoenix remained the command umbrella; A/1-169 is the directly evidenced flying company.

### Army MEDEVAC

```text
C Company, 3-10 Aviation Regiment
Mountain Dustoff
UH-60 MEDEVAC
```

The company was administratively associated with Task Force Phoenix but operated distributed RC-East sites, including a strong FOB Shank relationship and missions through FOB Fenty/Jalalabad. It must not be counted as a wholly Bagram-based ramp inventory.

### USAF rescue separation

Army Mountain Dustoff is separate from:

```text
83rd Expeditionary Rescue Squadron
HH-60G
Bagram Airfield
```

The two pools must remain separate in ORBAT, AIRWING, SQUADRON, warehouse and mission accounting.

### Brigade support

Task Force Mountain Eagle / 277th Aviation Support Battalion supported more than 170 brigade aircraft across OH-58, AH-64, UH-60 and CH-47 families. This is not evidence for 170 aircraft at Bagram.

## Salerno conclusions

### MEDEVAC

Active July 2011 unit:

```text
C Company, 5th Battalion, 159th Aviation Regiment
Cowboy Dustoff
Wyoming Army National Guard
FOB Salerno / Khost Province
```

Predecessor:

```text
C Company, 2nd Battalion, 104th Aviation Regiment
West Virginia Army National Guard
relieved 25 March 2011
```

### Mixed aviation task force

Contemporary first-party material confirms CH-47, UH-60 and OH-58 operations in the Task Force Tigershark/Khost area. AH-64 presence is independently established by the July 2011 ORBAT and brigade material.

These type-presence records support the mixed Salerno manifest but do not independently establish the complete local aircraft count.

## Jalalabad / FOB Fenty conclusions

- B/1-10 Aviation `Killer Spades`: eight AH-64D is a direct contemporary count;
- TF Phoenix Mountain Dustoff used Fenty/Jalalabad for forward MEDEVAC and patient transfer;
- patient-transfer or mission presence does not create an additional locally assigned aircraft inventory;
- B/3-10 Aviation CH-47 elements were operationally reassigned to the Fenty task force during the rotation and must be tracked by time and attachment.

## Shank conclusions

- C/3-10 GSAB Mountain Dustoff operated with TF Knighthawk;
- it was replaced by C/3-82 GSAB on 20 August 2011;
- B/7-158 and B/2-135 CH-47 personnel both appear in TF Knighthawk operations;
- the local CH-47 picture can therefore include parallel unit contributions and must not be reduced to one company pool.

## 2013 comparison sources

`pdf_12305.pdf` and `pdf_12516.pdf` are 2013 `Falcon Summit` publications. They are retained only for later organizational comparison, continuity and role validation.

They must not replace the 2010-2011 active ORBAT.

## Open inventory questions

The sources resolve several unit identities but do not state complete local counts for:

- A/1-169 UH-60 assigned to TF Phoenix/Bagram;
- C/3-10 Mountain Dustoff aircraft distributed across RC-East;
- C/5-159 Cowboy Dustoff aircraft at Salerno;
- total CH-47 strength at Shank across all contributing companies.

Any OMW count for these subjects remains a documented project reconstruction until a date-specific strength source is found.
