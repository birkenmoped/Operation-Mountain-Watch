---
document_id: OMW-AIR-KAIA-LOCAL-OPERATING-PROCEDURES-2009
status: BINDING
document_class: SOURCE_CRITICAL_LOCAL_AERODROME_OPERATIONS_REFERENCE
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
source_date: 2009-10-20
validated_in_dcs: false
---

# KAIA Local Operating Procedures 2009

## 1. Purpose and authority

This document records the mission-design-relevant contents of *Local Operating Procedures – Kabul Afghanistan International Airport, LOP V 9.7*, effective 20 October 2009 and current until superseded.

The source is marked NATO/ISAF UNCLASSIFIED. It applies to military and civilian users of KAIA operating to or from the aerodrome or inside Kabul CTR/TMA. It is subordinate to the Afghanistan AIP and subject to NOTAM and operations-order amendment.

Historical precedence:

```text
Afghanistan AIP
    > KAIA LOP
    > effective NOTAM / OPS order for temporary conditions
```

OMW runtime precedence:

```text
native DCS ATC used
    => DCS map/ME frequency and procedure constraints prevail

MOOSE/SRS service used
    => mission-defined frequency and menu/state logic may be adopted
```

## 2. Command and responsibilities

- KAIA belonged to and was operated by the Afghan Ministry of Transport and Civil Aviation.
- Troop Contributing Nations supported airport operation.
- COM KAIA, under COM ISAF, operated the military component, assisted Afghan authorities and exercised ATC authority in Kabul CTR.
- Afghan authorities retained responsibility inside their respective areas.
- ISAF controlled access inside the ISAF AOR.
- ISAF Rules of Engagement applied to ISAF operations and parked ISAF or ISAF-chartered aircraft where specified.
- Within Kabul CTR, ISAF was the Airspace Control Authority while Kabul Tower provided ATC service.
- Radar approach service in the Kabul TMA was provided under CFACC-designated authority.

## 3. Operating hours and airport closure

### 3.1 Operating hours

- Military traffic: H24.
- Civil traffic: sunrise to 2100 local / 1630Z, unless waived by ACA.
- Emergency aircraft requesting landing outside civil operating hours were to be assisted regardless of category.
- ISAF and coalition-supporting military flights were permitted H24.
- Other military or contractor night operations required written agreement.
- VMC night operations remained the crew's responsibility.
- Operations without runway lights were restricted to qualified NVG crews.

### 3.2 Closure authority

COM KAIA was the sole authority to close the airport to all or selected traffic. Closure or suspension could result from:

- direct threat;
- tower incapacitation;
- weather below airport minima;
- flight-safety concern;
- traffic saturation.

The airport visibility minimum was `800 m`. Below this value KAIA was closed for affected traffic.

## 4. Flight planning, PPR and slots

### 4.1 Flight plans

- Flight planning followed ICAO standards, the Afghanistan AIP and temporary NOTAM requirements.
- KAIA AIS provided planning support for ISAF and Afghan National Army Air Corps flights.
- Flights involving OAKB as destination, departure or alternate were required to include the applicable KAIA AIS and briefing AFTN addresses.
- Aircrews remained responsible for current NOTAM and weather review.

### 4.2 Prior Permission Required

- All flights to or from KAIA required PPR.
- PPR slot validity: `±30 minutes`.
- AMCC Eindhoven coordinated ISAF transport aircraft.
- ALCC HQ ISAF tasked intra-theatre airlift.
- Non-ISAF aircraft supporting ISAF also required AMCC coordination.
- Aircraft without valid PPR or Air Ops approval were not to be accepted for landing.
- A slot could include parking, passenger/cargo handling and refuelling when correctly requested.
- Unreported cancellations could unnecessarily activate SAR resources and result in denial of future slots.

Project abstraction:

```text
PPR_APPROVED != UNLIMITED_ARRIVAL_WINDOW
SLOT_APPROVED != AUTOMATIC_FUEL_ENTITLEMENT
CANCELLED_NOT_REPORTED -> SAR_AND_CAPACITY_COST
```

## 5. Historical communications and frequencies

These are source-recorded historical values. When native DCS systems are used, DCS runtime values take precedence.

| Function | Frequency/channel | Source use |
|---|---:|---|
| KAIA ATIS | `130.150 MHz` | Obtain latest information before start-up |
| Emergency civil VHF | `121.500 MHz` | Radio-failure/emergency contact |
| Emergency military UHF | `243.000 MHz` | Radio-failure/emergency contact |
| Eagle Ops / MEDEVAC reporting | `135.850 MHz` | Inbound MEDEVAC ground-assistance information |
| Ground-vehicle/Tower VHF | `147.825 MHz` | Authorized vehicle/pedestrian movement contact |
| Internal communications | `ICN Ch 2` | Primary Tower contact for authorized operators |
| Internal communications | `ICN Ch 11` | Air Ops / alternate on Ch 2 failure |

### 5.1 Runtime rule

```text
native_dcs_atc_frequency = DCS_MAP_OR_ME_VALUE
historical_lop_frequency = DOCUMENTED_REFERENCE
moose_srs_frequency = MISSION_DEFINED_WHEN_IMPLEMENTED
```

Briefing and kneeboard must never instruct players to use a historical frequency that does not produce the intended runtime service.

## 6. Weather and operating minima

### 6.1 Standard VFR minima in Kabul CTR

- Visibility: `5,000 m`.
- Ceiling: `1,500 ft`.

### 6.2 Special VFR by day

| Traffic | Visibility | Cloud requirement |
|---|---:|---|
| Fixed wing | 1,500 m | 1,500 ft cloud base |
| Rotary wing, home based | 1,200 m | clear of cloud |
| Rotary wing, not home based | 1,500 m | clear of cloud |

### 6.3 Special VFR by night

| Traffic | Visibility | Cloud requirement |
|---|---:|---|
| Fixed wing | 3,000 m | 1,500 ft cloud base |
| Rotary wing, NVG | 1,500 m | clear of cloud |
| Rotary wing, no NVG | 3,000 m | clear of cloud |

- SVFR was pilot-requested.
- Fixed-wing SVFR could create delays up to approximately 30 minutes.
- If visibility fell below 1,500 m, ATC could reduce traffic to two movements per 15 minutes.
- If visibility fell below 1,000 m, ATC could suspend operations.
- Bagram Approach could restrict KAIA departures to one movement per five minutes or hold releases due to congestion.

### 6.4 Below-minima operations

- Below IFR approach minima, landing clearance was only issued after the pilot reported runway in sight; responsibility remained with the pilot.
- Below the 800 m airport minimum, the airport was closed and approaches were not permitted.
- Selected NATO priority missions such as MEDEVAC, EVAC or RECCE could request operation below the airport minimum through Air Ops and COM KAIA.
- In that condition Tower provided traffic, weather and runway-condition information rather than normal clearances.

## 7. VFR departure and arrival routes

### 7.1 Fixed wing departure

- Maintain runway heading/straight ahead until `1,500 ft AGL`.
- Then proceed on course unless otherwise approved.

### 7.2 Rotary wing departure

- Proceed along Taxiway B or H.
- Pass abeam the applicable A/J/G intersection.
- Climb to `500 ft AGL` or above before proceeding on course unless otherwise approved.

### 7.3 Fixed wing arrival

- Turn final no closer than `3 NM` from the approach end.
- Do not descend below `1,500 ft AGL` before the final arrangement unless approved.

### 7.4 Rotary wing arrival

- South final aligned with Taxiway B at `500 ft AGL`; or
- North final aligned with Taxiway H at `500 ft AGL`;
- unless otherwise approved.

## 8. Traffic priorities in Kabul CTR

Historical order of priority:

1. aircraft in emergency;
2. QRF flights;
3. MEDEVAC, CASEVAC, EVAC and ambulance flights;
4. Hajj pilgrimage flights;
5. VIP aircraft;
6. passenger-carrying civil and military flights before cargo flights;
7. IFR before VFR and SVFR;
8. arrival traffic before departure traffic;
9. fixed wing before rotary wing.

Potential MOOSE state:

```text
EMERGENCY > QRF > MEDICAL > HAJJ > VIP > PAX > CARGO
IFR > VFR_OR_SVFR
ARRIVAL > DEPARTURE
FIXED_WING > ROTARY_WING
```

This ordering is a historical KAIA rule, not a universal OMW rule outside Kabul CTR.

## 9. Fixed-wing and runway procedures

### 9.1 Reduced runway separation

Reduced separation was allowed only when:

- VMC prevailed;
- braking action was not degraded;
- traffic information was passed and acknowledged;
- full runway length was available.

For a succeeding jet:

- RWY 29: preceding aircraft airborne/past intersection C or landing aircraft past C and moving;
- RWY 11: preceding aircraft airborne/past intersection F or landing aircraft past F and moving.

For a succeeding propeller aircraft:

- RWY 29: preceding aircraft airborne/past D or landing aircraft past D and moving;
- RWY 11: preceding aircraft airborne/past E or landing aircraft past E and moving.

### 9.2 VOR approach RWY 11

Only one aircraft could conduct the VOR approach at a time. When the first aircraft turned final RWY 11, a second aircraft was required to remain at least 20 NM on the RWY 29 final.

### 9.3 Low pass and formation

- Low pass: runway, at or above `500 ft AGL`, maximum `250 kt`, unless prior authorization.
- Non-tactical formation flights normally required 24-hour prior permission through Chief Air Operations.

## 10. Rotary-wing operations

- Helicopter start/landing was permitted from designated helistrips, Taxiway F and specified Taxiway B segments.
- Taxiway B between D and G was restricted for helicopter take-off, landing and hovering except B1/B2 helistrips.
- No air taxi was permitted on Taxiway B between D and F except for based helicopters or aircraft unable to ground taxi.
- Aprons 1, 2, 7 and 8 were closed to helicopter landing, take-off, hover and air taxi unless coordinated.
- Armed helicopters with external stores were to park on Apron 7 facing north.
- Helicopters were not to overfly taxiing aircraft below `500 ft AGL`.
- Normal helicopter training used the south pattern unless otherwise directed.
- Autorotation training normally used the runway and required 24-hour advance request.
- Skid landing was not approved.
- Apron 5C helicopter operations required Tower clearance, but separation on the ramp remained at crew discretion because it was outside the manoeuvring area.
- Aprons 6 and 10 were not to be overflown during Apron 5C procedures.

## 11. UAV operations

- All UAV operations required ATC coordination.
- Rotary-wing aircraft and UAVs could operate simultaneously with fixed-wing aircraft at or below `500 ft AGL` when clear of instrument tracks and altitudes.
- Outside a `5 NM` radius from KAIA ARP, UAVs could operate up to `8,000 ft AMSL`.
- Above 8,000 ft AMSL required KRAPCON clearance.
- Within 5 NM required prior Kabul Tower permission.
- Exact UAV position reports were not guaranteed.
- ATC could limit or deny UAV operations for flight safety.
- UAV activity was to be restricted when QRF, CASEVAC, MEDEVAC or EVAC rotary-wing traffic operated nearby.

Project state model:

```text
uav_zone_radius_nm
uav_altitude_block
uav_position_confidence
uav_atc_clearance_state
priority_rotary_wing_active
uav_operation_suspended
```

## 12. Ground operations

### 12.1 Aircraft taxi

- ATC and Follow-Me/marshaller instructions were mandatory.
- Military aircraft expected Follow-Me or marshaller guidance to Aprons 1, 2, 7, 8 and Helipads 1, 2, 3.
- Entry into those aprons without guidance was prohibited.
- Maximum aircraft taxi speed: `15 kt`.
- High-power engine tests were prohibited on aprons.
- Pedestrian and vehicle traffic was considered a major hazard.
- Jet-blast caution was required near Taxiway F and for heavy cargo aircraft.

### 12.2 Passenger handling

Aircraft on Aprons 2 and 8 were not to remain with engines running longer than 15 minutes for passenger drop-off or pick-up. Longer operations required shutdown or alternate parking coordination.

### 12.3 Vehicle and pedestrian movement

- Continuous radio contact with Tower was expected.
- Pedestrians and vehicles stopped at least `50 m` before taxiing aircraft.
- Vehicles behind a taxiing aircraft maintained at least `75 m` distance.

Vehicle speed limits:

| Area | Maximum |
|---|---:|
| Apron | 20 km/h |
| Taxiway | 40 km/h |
| Runway | 60 km/h |

Vehicle access to the runway required unambiguous Tower clearance by radio or light-gun signal.

### 12.4 Vehicle light-gun signals

| Signal | Meaning |
|---|---|
| Green flashes | Permission to cross landing area or move onto taxiway |
| Steady red | Stop |
| Red flashes | Move off landing area/taxiway and watch for aircraft |
| White flashes | Vacate manoeuvring area as instructed |

## 13. Parking, cargo and fuel

### 13.1 Civil cargo parking

- Civil cargo aircraft used Taxiways D1, D2 and E.
- Taxiway C was not authorized for normal civil cargo parking.
- Additional IL-76, An-124, An-12 or comparable aircraft could be denied landing when the approved positions were occupied.

### 13.2 Hot cargo

Hot cargo was assigned to Apron 7 or Taxiway C under the local procedure.

### 13.3 Fuel

- KAIA did not hold universally available fuel for all transient traffic.
- KAIA military aircraft and MEDEVAC assets received priority according to mission.
- NATO-contracted fuel was for eligible ISAF/ISF callsigns through PPR or tasking.
- Other operators required approval based on mission priority and logistics status.
- Air Ops could assist coordination with civil suppliers but did not guarantee quality.

```text
FUEL_PRESENT_ON_AIRFIELD != FUEL_AVAILABLE_TO_ALL
MEDEVAC_OR_ASSIGNED_MILITARY -> PRIORITY_FUEL_ACCESS
```

## 14. Bird, animal and jet-blast hazards

- Intensive bird activity occurred from March through October.
- Low-level tactical departures below `30 ft AGL` were discouraged during that period.
- Animals on the manoeuvring area could cause suspension of operations.
- Heavy aircraft explicitly identified for jet-blast concern included An-124, IL-76, C-5 and C-17.

## 15. Fire and emergency response

- KAIA was published as ICAO crash category 9.
- Pilots declared emergency type, intentions, requested assistance, POB, weapons, ammunition and hazardous cargo.
- Tower suspended conflicting operations.
- Rotary-wing emergency traffic landed on the active runway.
- Flight Safety Officer inspection was required after emergency landing or take-off.
- Only the on-scene commander could terminate the emergency.

### 15.1 Annex C emergency broadcast fields

- aircraft type;
- emergency type;
- POB;
- ETA;
- runway/position;
- fuel remaining and unit;
- hazardous materials;
- wind;
- remarks;
- confirmation of Fire Brigade, Air Ops, FSO and GDCC receipt.

## 16. MEDEVAC procedures

Inbound MEDEVAC pilots were required to transmit:

- total POB requiring ground assistance;
- the same information to Air Ops on Eagle Ops `135.850 MHz`.

MEDEVAC belonged to the highest routine traffic priorities and could justify exceptional below-minima requests.

## 17. SAFIRE reporting

All small-arms-fire events during arrival or departure were to be reported to the Local Controller. Tower attempted to collect checklist information and forwarded it to Intelligence.

OMW implication:

```text
SAFIRE_EVENT
    -> IMMEDIATE_ATC_REPORT
    -> LOCATION_DIRECTION_ALTITUDE_DETAILS
    -> INTELLIGENCE_HANDOFF
    -> POSSIBLE_ROUTE_OR_PROCEDURE_CHANGE
```

## 18. Radio-failure procedures

### 18.1 General

- ICAO radio-communication-failure procedure applied.
- Attempts were made on `121.500 MHz` or `243.000 MHz`.
- Radar acknowledgement could use IDENT or squawk change.
- Traffic was not to cross north/south over the airport or final sectors during radio failure.

### 18.2 Light fixed wing

- Low approach at or above 500 ft AGL;
- rock wings abeam Tower;
- observe light-gun signal;
- join south pattern;
- vacate at A/J or G as applicable;
- do not enter B/H without radio, light-gun or Follow-Me clearance.

### 18.3 Medium/heavy fixed wing

Same general procedure, using landing-light flashes rather than wing rock as the recognition signal.

### 18.4 Helicopters

- Low approach over Taxiway B/H at or above 500 ft AGL;
- rock wings abeam Tower;
- observe light-gun signals;
- join north or south pattern;
- land on B/H abeam parking ramp and clear promptly.

### 18.5 Ground radio failure

- Taxiing aircraft stopped and awaited Follow-Me/light-gun guidance.
- Aircraft lined up for departure taxied down the runway, vacated as soon as possible and awaited guidance.

Mountain terrain could require relay through other aircraft.

## 19. Controlled jettison and bailout

No dedicated Kabul-airspace jettison or abandonment areas existed. The LOP directed controlled actions into Bagram Radar airspace.

### 19.1 Jettison area

- Start: `BGM R130 / 4 NM`.
- Fly parallel to runway heading `030°`.
- Release between `BGM R130 / 4 NM` and `BGM R090 / 4 NM` over deserted terrain.

### 19.2 Controlled bailout area

- `BGM R145 / 4 NM`.
- Heading sector `120°–180°`.
- `7,000 ft MSL`, approximately `2,000 ft AGL`.
- Intended aircraft impact on Zin Ghar and pilot descent east of the mountain.

These are historical emergency procedures and require terrain verification before any OMW implementation.

## 20. ANA Air Corps operations

- ANAAC liaison passed weather data to Air Ops.
- Because some ANAAC helicopter pilots could not receive KAIA ATIS, pilots reported the ATIS code received through ANAAC Air Ops; otherwise Tower issued the full meteorological report.
- Local training took place in the regular Kabul circuit and required Tower Supervisor approval.

## 21. Maps and spatial constraints

### 21.1 Annex A – ISAF AOR

The source contains a map of the ISAF responsibility area around the central aerodrome and military aprons. It should be used as a visual historical reference for security-zone and ground-layout reconstruction, not as an exact DCS polygon until georeferenced.

### 21.2 Annex B – military camps

The source maps military camps in the Kabul area and states that overflight was strictly prohibited. Visible labels include KAIA and multiple Kabul-area camps such as Eggers, Phoenix, Warehouse and Julien.

Implementation requirement:

```text
source_map -> georeference -> named polygon/point registry -> DCS terrain verification
```

No precise ROZ polygon is to be invented from the low-resolution image alone.

## 22. DCS/MOOSE implementation guidance

### 22.1 Native DCS baseline

- Use DCS map and Mission Editor frequencies for native ATC.
- Use DCS runway, taxiway and navaid implementation as runtime truth where not script-replaceable.
- Record historical discrepancies rather than misleading players.

### 22.2 Potential MOOSE/SRS implementation

A scripted KAIA service could model:

- F10 request for start, taxi, take-off, arrival, SVFR, formation and training;
- priority queue using the historical order;
- runway state and traffic saturation;
- UAV altitude blocks and suspension for medical/QRF traffic;
- PPR and slot validation;
- Follow-Me handoff state;
- emergency broadcast state;
- SRS/TTS replies on mission-defined frequencies;
- text fallback where radio reception is unavailable.

Pilot voice transmission is not automatically understood by MOOSE. Without an external speech-recognition integration, requests remain menu or trigger actions even when responses are heard over a tuned cockpit/SRS frequency.

## 23. Source-critical rules

```text
KAIA_LOP_2009 = HIGH_VALUE_NEAR_PERIOD_PRIMARY_SOURCE
LOP_PROCEDURE != GUARANTEED_UNCHANGED_2011_PROCEDURE
HISTORICAL_FREQUENCY != NATIVE_DCS_RUNTIME_FREQUENCY
SOURCE_MAP != READY_DCS_ZONE
PUBLISHED_PRIORITY != UNIVERSAL_THEATER_PRIORITY
```

## 24. Source

- *Local Operating Procedures, Kabul Afghanistan International Airport, LOP V 9.7*, effective 20 October 2009, HQ ISAF / COM KAIA, NATO/ISAF UNCLASSIFIED, 30 pages.
