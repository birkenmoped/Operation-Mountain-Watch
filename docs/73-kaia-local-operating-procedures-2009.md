---
document_id: OMW-AIR-KAIA-LOCAL-OPERATING-PROCEDURES-2009
status: BINDING
document_class: SOURCE_CRITICAL_LOCAL_AERODROME_OPERATIONS_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical KAIA local operating procedures effective 2009-10-20
  - Kabul CTR and KAIA multinational operating model
  - fixed-wing, rotary-wing and UAV local procedure design
  - historical priorities, PPR, slot, ground, emergency and MEDEVAC procedures
not_authoritative_for:
  - current DCS terrain frequencies
  - current real-world KAIA procedures
  - automatic persistence of every procedure into 2010-2011
  - active OMW runtime configuration unless explicitly adopted
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: ccf5fdaa988ba83c2c6684e477978ec2b259a211
source_date: 2009-10-20
validated_in_dcs: false
---

# KAIA Local Operating Procedures 2009

## 1. Purpose and authority

This document records the mission-design-relevant contents of *Local Operating Procedures – Kabul Afghanistan International Airport, LOP V 9.7*, effective 20 October 2009 and current until superseded. The source is marked `NATO/ISAF UNCLASSIFIED`, applies to military and civilian KAIA users in the aerodrome, Kabul CTR and Kabul TMA, and is subordinate to the Afghanistan AIP and effective NOTAM/operations orders.

```text
Afghanistan AIP
    > KAIA LOP
    > effective NOTAM / OPS order
```

For OMW runtime:

```text
native DCS ATC used
    => DCS map/ME frequency and procedure constraints prevail

MOOSE/SRS service used
    => mission-defined frequency and menu/state logic may be adopted
```

## 2. Command and responsibilities

- KAIA belonged to and was operated by MoTCA.
- Troop Contributing Nations supported operation.
- COM KAIA, under COM ISAF, operated the military component, supported Afghan authorities and exercised ATC authority in Kabul CTR.
- Afghan authorities retained responsibility in their areas.
- ISAF controlled access inside the ISAF AOR.
- Within Kabul CTR, ISAF was the Airspace Control Authority while Kabul Tower provided ATC service.
- Radar approach service in Kabul TMA was provided under CFACC authority.
- KAIA AIS supported ISAF-related aeronautical information.

## 3. Operating hours and closure

### Operating hours

- Military traffic: H24.
- Civil traffic: sunrise to 2100 local / 1630Z unless waived by ACA.
- Emergency traffic was to be assisted outside civil hours regardless of category.
- ISAF and coalition-supporting military traffic: H24.
- Other night operations required written agreement.
- VMC night operation remained crew responsibility.
- Operations without runway lights were restricted to qualified NVG crews.

### Closure

COM KAIA was sole closure authority. Closure or suspension could result from direct threat, tower incapacity, weather below minima, flight-safety concerns or traffic saturation.

Airport visibility minimum: `800 m`. Below this value KAIA was closed for affected traffic.

## 4. Flight planning, PPR and slots

- Flight planning followed ICAO, Afghanistan AIP and NOTAM requirements.
- KAIA AIS supported ISAF and Afghan National Army Air Corps flights.
- All flights to/from KAIA required PPR.
- PPR slot validity: `±30 minutes`.
- AMCC Eindhoven coordinated ISAF transport aircraft.
- ALCC HQ ISAF tasked intra-theatre airlift.
- Non-ISAF aircraft supporting ISAF also required AMCC coordination.
- Aircraft without valid PPR or Air Ops approval were not accepted for landing.
- A slot could include parking, handling and refueling when properly requested.
- Unreported cancellations could activate SAR resources and jeopardize future slots.

```text
PPR_APPROVED != UNLIMITED_ARRIVAL_WINDOW
SLOT_APPROVED != AUTOMATIC_FUEL_ENTITLEMENT
CANCELLED_NOT_REPORTED -> SAR_AND_CAPACITY_COST
```

Historical AFTN addresses recorded by the source included `OAKBYWYX`, `OAKBYNYX` and `OAKBZPZX` for KAIA AIS/briefing distribution.

## 5. Historical communications and frequencies

| Function | Frequency/channel | Historical use |
|---|---:|---|
| KAIA ATIS | `130.150 MHz` | latest information before start-up |
| civil emergency | `121.500 MHz` | emergency/radio failure |
| military emergency | `243.000 MHz` | emergency/radio failure |
| Eagle Ops / MEDEVAC | `135.850 MHz` | inbound MEDEVAC ground-assistance report |
| vehicle/Tower VHF | `147.825 MHz` | maneuvering-area vehicle/pedestrian contact |
| internal network | `ICN Ch 2` | primary Tower contact |
| internal network | `ICN Ch 11` | Air Ops / Channel-2 alternate |

```text
native_dcs_atc_frequency = DCS_MAP_OR_ME_VALUE
historical_lop_frequency = DOCUMENTED_REFERENCE
moose_srs_frequency = MISSION_DEFINED_WHEN_IMPLEMENTED
```

Briefing and kneeboard must use the actual runtime service value, not merely the historical value.

## 6. Weather and operating minima

### Standard VFR

- visibility: `5,000 m`;
- ceiling: `1,500 ft`.

### Day SVFR

| Traffic | Visibility | Cloud requirement |
|---|---:|---|
| fixed wing | 1,500 m | 1,500 ft cloud base |
| rotary wing, home based | 1,200 m | clear of cloud |
| rotary wing, not home based | 1,500 m | clear of cloud |

### Night SVFR

| Traffic | Visibility | Cloud requirement |
|---|---:|---|
| fixed wing | 3,000 m | 1,500 ft cloud base |
| rotary wing, NVG | 1,500 m | clear of cloud |
| rotary wing, no NVG | 3,000 m | clear of cloud |

- SVFR required pilot request.
- Fixed-wing SVFR could create delays up to about 30 minutes.
- Below 1,500 m visibility ATC could reduce traffic to two movements per 15 minutes.
- Below 1,000 m ATC could suspend operations.
- Bagram Approach could restrict KAIA departures to one movement per five minutes or hold releases.
- Below 800 m airport minimum, approaches were not permitted.
- Selected NATO priority missions such as MEDEVAC, EVAC or RECCE could request exceptional operation through Air Ops and COM KAIA; Tower then provided information rather than normal clearance/control.

## 7. VFR arrival and departure

### Fixed-wing departure

- runway heading/straight ahead to `1,500 ft AGL`;
- then proceed on course unless otherwise approved.

### Rotary-wing departure

- along Taxiway B or H;
- pass abeam applicable A/J/G intersection;
- climb to `500 ft AGL` or above before proceeding.

### Fixed-wing arrival

- turn final no closer than `3 NM` from approach end;
- remain at or above `1,500 ft AGL` unless otherwise approved.

### Rotary-wing arrival

- south final aligned with Taxiway B at `500 ft AGL`; or
- north final aligned with Taxiway H at `500 ft AGL`.

## 8. Traffic priorities in Kabul CTR

1. emergency;
2. QRF;
3. MEDEVAC, CASEVAC, EVAC and ambulance;
4. Hajj pilgrimage flights;
5. VIP;
6. passenger flights before cargo;
7. IFR before VFR/SVFR;
8. arrivals before departures;
9. fixed wing before rotary wing.

```text
EMERGENCY > QRF > MEDICAL > HAJJ > VIP > PAX > CARGO
IFR > VFR_OR_SVFR
ARRIVAL > DEPARTURE
FIXED_WING > ROTARY_WING
```

This ordering is a historical KAIA rule, not a universal OMW rule outside Kabul CTR.

## 9. Fixed-wing and runway procedures

Reduced runway separation required VMC, acceptable braking, acknowledged traffic information and full runway availability.

For a succeeding jet:

- RWY 29: preceding traffic airborne/past intersection C or landing traffic past C and moving;
- RWY 11: preceding traffic airborne/past F or landing traffic past F and moving.

For a succeeding propeller aircraft:

- RWY 29: preceding traffic airborne/past D or landing traffic past D and moving;
- RWY 11: preceding traffic airborne/past E or landing traffic past E and moving.

VOR RWY 11: only one aircraft on the approach at a time; when one turned final RWY 11, a second aircraft was to remain at least 20 NM on RWY 29 final.

Low pass: at or above `500 ft AGL`, maximum `250 kt`, unless specially approved. Non-tactical formation flights normally required 24-hour prior permission.

## 10. Rotary-wing operations

- Designated helistrips, Taxiway F and specified Taxiway-B segments were used.
- Taxiway B between D and G was restricted for helicopter takeoff, landing and hover except B1/B2.
- No air taxi on Taxiway B between D and F except based helicopters or aircraft unable to ground taxi.
- Aprons 1, 2, 7 and 8 were closed to helicopter takeoff, landing, hover and air taxi unless coordinated.
- Armed helicopters with external stores parked on Apron 7 facing north.
- Helicopters did not overfly taxiing aircraft below `500 ft AGL`.
- Normal training used the south pattern unless directed otherwise.
- Autorotation training normally required 24-hour advance request and used the runway; skid landing was not approved.
- Apron 5C operations required Tower clearance, but ramp deconfliction remained crew responsibility.
- Overflight of Aprons 6 and 10 was prohibited during the Apron-5C procedure.

## 11. UAV operations

- All UAV operations required ATC coordination.
- RW aircraft and UAVs could operate simultaneously with fixed wing at or below `500 ft AGL` when clear of instrument tracks/altitudes.
- Outside `5 NM` from KAIA ARP: UAV operation at or below `8,000 ft AMSL`.
- Above 8,000 ft: KRAPCON clearance required.
- Inside 5 NM: prior Kabul Tower permission required.
- Exact UAV position reports were not guaranteed.
- ATC could limit or deny UAV operation for safety.
- UAV activity was restricted near active RW QRF, CASEVAC, MEDEVAC or EVAC traffic.

```text
uav_zone_radius_nm
uav_altitude_block
uav_position_confidence
uav_atc_clearance_state
priority_rotary_wing_active
uav_operation_suspended
```

## 12. Ground operations

### Aircraft taxi

- ATC and Follow-Me/marshaller instructions were mandatory.
- Military aircraft expected guidance to Aprons 1, 2, 7, 8 and Helipads 1, 2, 3.
- Entry without guidance was prohibited.
- Maximum aircraft taxi speed: `15 kt`.
- High-power engine tests were prohibited on aprons.
- Pedestrian/vehicle traffic was a major hazard.
- Heavy-cargo jet blast required special caution.

### Passenger handling

Aircraft on Aprons 2 and 8 were not to remain with engines running longer than 15 minutes for passenger drop-off/pick-up. Longer operations required shutdown or alternate parking.

### Vehicle and pedestrian movement

- Tower coordination and radio contact expected.
- Stop at least `50 m` before taxiing aircraft.
- Maintain at least `75 m` behind taxiing aircraft.

| Area | Vehicle maximum |
|---|---:|
| Apron | 20 km/h |
| Taxiway | 40 km/h |
| Runway | 60 km/h |

Tower light-gun meanings for vehicles:

| Signal | Meaning |
|---|---|
| flashing green | permission to cross landing area or enter taxiway |
| steady red | stop |
| flashing red | move off landing area/taxiway and watch for aircraft |
| flashing white | vacate maneuvering area according to local instructions |

## 13. Parking, fuel and cargo

- KAIA did not provide unrestricted fuel to all transient aircraft.
- Priority entitlement: KAIA military aircraft, MEDEVAC assets, ISAF/ISF callsigns with official PPR/tasking.
- Other users required approval based on mission priority and service status.
- Air Ops could assist with civilian providers but did not guarantee fuel quality.

```text
FUEL_PRESENT_AT_AIRFIELD != FUEL_AVAILABLE_TO_ALL
```

Civil cargo aircraft were limited to Taxiways D1, D2 and E. Additional cargo traffic could be denied if these positions were blocked. Hot cargo was assigned to Apron 7 or the designated Taxiway-C position.

## 14. Hazards and airport services

- Intensive bird activity: March through October.
- Tactical departures below `30 ft AGL` were discouraged during this period.
- Animals on the maneuvering area could cause suspension.
- KAIA was ICAO crash category 9.
- Category downgrade required traffic notification.
- Heavy aircraft specifically included An-124, Il-76, C-5 and C-17 for jet-blast awareness.

## 15. Radio failure

Initial attempts used `121.5 MHz` and `243.0 MHz`. Radar-capable ATC could request IDENT or squawk change to confirm reception.

Without contact:

- light aircraft: low approach at/above 500 ft AGL, wing rock, observe light gun;
- medium/heavy: low approach at/above 500 ft AGL, flash landing lights;
- helicopters: low approach over Taxiway B/H at/above 500 ft AGL, wing rock and observe light gun;
- terrain-related gaps could use relay through another aircraft.

On the ground:

- taxiing aircraft stopped and awaited Follow-Me/light-gun guidance;
- aircraft lined up taxied down the runway, vacated at earliest safe point and awaited guidance.

Radio-failure traffic was not to cross north-south over the airport or interfere with final sectors.

## 16. Emergency procedures

Pilots were expected to report:

- emergency type;
- intentions;
- requested assistance;
- persons on board;
- weapons/ammunition;
- hazardous cargo.

Tower coordinated emergency services, requested SPECI weather, suspended conflicting operations and required a surface inspection after emergency movement. Only the on-scene commander could terminate the emergency.

Annex-C report fields:

```yaml
emergency_report:
  aircraft_type:
  emergency_type:
  persons_on_board:
  eta:
  runway_or_crash_map_position:
  fuel_remaining:
  hazardous_materials:
  wind:
  remarks:
```

## 17. MEDEVAC, diversion and SAFIRE

Inbound MEDEVAC pilots reported the total number of persons needing ground assistance and passed the information to Eagle Ops on `135.850 MHz`.

Diverting jets were handled separately from declared emergencies; Fire Service and Air Ops coordinated parking and support.

All small-arms-fire events during approach/departure were reported to Local Control and passed to Intelligence. The source confirms a checklist process but does not reproduce every checklist field.

```yaml
safire_report_design:
  flight_phase:
  estimated_location:
  observed_origin:
  direction:
  altitude:
  damage_or_effect:
  time:
  confidence:
```

This is an OMW design schema, not a verbatim historical checklist.

## 18. Jettison and controlled bailout

No local Kabul jettison or abandonment area existed. Controlled procedures used Bagram airspace.

Controlled jettison:

- BGM radial 130 / 4 NM;
- fly parallel to heading 030°;
- release toward BGM radial 090 / 4 NM in the deserted area.

Controlled bailout:

- BGM radial 145 / 4 NM;
- 7,000 ft MSL, about 2,000 ft AGL;
- heading sector 120–180°;
- intended aircraft impact on Zin Ghar with pilot landing east of the mountain.

These are historical emergency references, not automatically authorized OMW zones.

## 19. Training and special procedures

- ANAAC training used the regular circuit and required Tower Supervisor approval.
- Tower provided complete weather when ANAAC pilots could not receive ATIS or reported no valid code.
- Autorotation training: 24-hour request, normally runway, patterns north/south at 750 ft AGL.
- Skid landing prohibited.
- Non-tactical formation flights: 24-hour prior permission.
- Low pass: runway, at/above 500 ft AGL, max 250 kt unless approved.
- Helicopter training normally used the south pattern.
- VVIP movements could impose special procedures and delays.

## 20. Maps and spatial extraction

Annex A shows the ISAF AOR around KAIA. Annex B shows Kabul-area military camps and states that overflight was strictly prohibited. Visible labels include KAIA, Souter, Phoenix, Eggers, Warehouse, Julien and additional camp markers.

```text
MAP_VISIBLE != GEOREFERENCED_ZONE
```

Before runtime use:

1. identify map projection/base map;
2. georeference control points;
3. digitize boundaries/points;
4. compare with scenario-date ACO/ROZ sources;
5. validate against DCS terrain.

## 21. Mission-design model

```yaml
kaia_operations:
  operating_state:
    - OPEN_NORMAL
    - OPEN_REDUCED_RATE
    - MILITARY_ONLY
    - SUSPENDED
    - CLOSED_WEATHER
    - CLOSED_THREAT
  priority_queue: true
  ppr_required: true
  slot_tolerance_minutes: 30
  follow_me_required_for_military_aprons: true
  vehicle_hazard_level: HIGH
  uav_deconfliction_required: true
  fuel_entitlement_restricted: true
  safire_reporting_enabled: true
  medevac_priority_enabled: true
```

## 22. DCS and MOOSE boundaries

### Native DCS ATC

- DCS map/Mission Editor frequencies are runtime authority.
- Native menu and phraseology limitations remain.
- Historical frequencies are reference and comparison values.
- Terrain navaids cannot be rewritten by documentation.

### MOOSE/SRS option

A later scripted implementation may use mission-defined frequencies, F10 requests, SRS/TTS responses, state-based priorities, slot/PPR simulation, UAV restrictions and weather/closure states. It does not automatically understand spoken pilot transmissions without an external recognition layer.

## 23. Required validation

1. compare KAIA layout with current DCS Afghanistan terrain;
2. record native DCS ATC and navaid values;
3. identify usable taxiways, helipads and parking positions;
4. test fixed-wing and rotary-wing AI pathing;
5. decide native DCS ATC versus scripted ATC scope;
6. validate SRS/TTS behavior if used;
7. georeference Annex A/B where required;
8. test priority, closure, radio-failure and emergency workflows.

## 24. Binding rules

```text
DCS_RUNTIME_FREQUENCY > HISTORICAL_FREQUENCY
WHEN_NATIVE_DCS_ATC_IS_USED

HISTORICAL_KAIA_PROCEDURE != AUTOMATIC_DCS_CAPABILITY
PPR_APPROVED != ALL_SERVICES_GUARANTEED
UAV_CLEARANCE != GUARANTEED_POSITION_ACCURACY
AIRFIELD_OPEN != UNRESTRICTED_CIVIL_OPERATIONS
MEDEVAC_PRIORITY != EXEMPT_FROM_DECONFLICTION
```

## 25. Source note

This document paraphrases the supplied 30-page LOP and retains operational values required for mission design. Personal telephone numbers, individual mobile numbers and obsolete direct contact details are intentionally not reproduced.
