---
document_id: OMW-AIR-AFGHANISTAN-AIP-2008
status: BINDING
document_class: SOURCE_CRITICAL_AERONAUTICAL_REFERENCE
authoritative_for:
  - historical Afghanistan AIP baseline effective 2008-11-20
  - Kabul FIR governance and ATS architecture
  - historical aerodrome identifiers and published navigation aids
  - historical flight rules, SAR framework and aeronautical procedures
not_authoritative_for:
  - current DCS terrain frequencies or navaid implementation
  - unchanged validity during 2010-08-01/2011-12-31 without corroboration
  - current real-world procedures
  - active OMW runtime configuration unless explicitly adopted
scenario_period: 2010-08-01/2011-12-31
source_date: 2008-11-20
validated_in_dcs: false
---

# Afghanistan AIP 2008 – Airspace, Aerodromes and Flight Procedures

## 1. Purpose

This document records the operationally relevant content of the *Republic of Afghanistan Aeronautical Information Publication*, Twenty-Ninth Edition, effective 20 November 2008. The AIP was issued by the Combined Forces Air Component Commander in coordination with the Afghan Ministry of Transport and Civil Aviation.

The AIP is an official primary source. It predates the OMW scenario period by approximately twenty months. Static geography, aerodrome identifiers, runway orientation and institutional structure are high-value historical baselines. Frequencies, serviceability, declared distances, operating hours and temporary procedures require later-source or DCS-terrain cross-checking.

## 2. Source authority and precedence

The AIP states that:

- CFACC was the Airspace Control Authority for Afghanistan and the Kabul FIR;
- MoTCA retained responsibility for civil aviation approvals and safety matters;
- operators were required to consult NOTAMs for current changes;
- the AIP followed ICAO Annex 15 structure and consisted of GEN, ENR and AD parts;
- complete editions were issued on a 56-day AIRAC cycle.

Source precedence for historical reconstruction:

```text
NOTAM / AIP SUP effective at event time
    > applicable AIP edition
    > local operating procedure subordinate to the AIP
    > project abstraction
```

Runtime precedence in OMW:

```text
native DCS ATC or map navaid used
    => DCS terrain / Mission Editor value is mandatory at runtime

scripted MOOSE/SRS service used
    => mission-defined value may be used if technically implemented and briefed
```

Therefore:

```text
HISTORICAL_FREQUENCY != AUTOMATIC_RUNTIME_FREQUENCY
HISTORICAL_NAVAID != GUARANTEED_DCS_NAVAID
```

## 3. Kabul FIR governance

### 3.1 Authorities

- CFACC, on behalf of MoTCA, served as Afghanistan Airspace Control Authority from 11 February 2002 until further notice.
- MoTCA remained responsible for civil aviation entry, overflight, arrival and departure approval.
- Kabul ACC/FIC provided national en-route service.
- The AIP applied to civil, military, humanitarian, NGO, international-organization and State aircraft operating in the Kabul FIR.

### 3.2 Permissions

- All aircraft required MoTCA approval to land, depart or overfly Afghanistan.
- Requests were expected at least 24 hours in advance.
- PPR airfields were identified in ENR 1.9 and by NOTAM.
- Operators also required the relevant airfield permission and an international flight plan.

Historical contact details from the source are intentionally not reproduced as active project contacts.

## 4. Flight-risk environment

The AIP explicitly warned of:

- hostile non-military action against aircraft;
- ongoing military operations;
- interception by armed coalition aircraft for non-compliance;
- temporary route deviations directed by the ACA;
- poor pavement and limited or absent ATC, meteorological, fire/rescue and ground support at most airfields other than Kabul, Kandahar, Mazar-e-Sharif and U.S. military airfields.

Mission-design implications:

```text
AIRFIELD_EXISTS != AIRFIELD_FULLY_SUPPORTED
PUBLISHED_ROUTE != GUARANTEED_UNCONTESTED_ROUTE
PROCEDURAL_NONCOMPLIANCE -> INTERCEPT_OR_AIRSPACE_DENIAL_RISK
```

## 5. Communications and surveillance rules

### 5.1 Mandatory monitoring

- Emergency frequency: `121.500 MHz`.
- Afghan Advisory air-to-air: `125.200 MHz` when not in positive contact with a controlling agency.
- All aircraft were required to operate serviceable pressure-altitude-reporting transponders.
- Mode C was required continuously.
- VFR code was `1200` unless a discrete code was assigned.
- Military operators used assigned ATO or AMCC codes where applicable.

### 5.2 Navigation performance

- Civil and State overflight aircraft required RNP-10 approval.
- Dual navigation systems of adequate integrity were required.
- Aircraft unable to meet RNP-10 could not operate IFR in the Kabul FIR.
- Navigation equipment deterioration had to be reported to ATC using the published inability phraseology.
- TCAS was required for civilian aircraft at or above FL240.

## 6. ATS structure

### 6.1 Aerodrome control

Aerodrome control service was published for:

- Bagram;
- Kandahar;
- Kabul;
- Herat;
- Mazar-e-Sharif.

### 6.2 Approach control

- Radar approach control: Bagram, Kabul, Kandahar.
- Procedural approach control: Mazar-e-Sharif.
- Kabul ACC provided procedural en-route service on high- and low-level route structures.

### 6.3 Service types

The AIP differentiated:

- Aerodrome Control;
- Surface Movement Control;
- Approach/Departure Control;
- Area Control;
- ATC Surveillance Service;
- Radar Information Service;
- Final Approach Service;
- Emergency Service;
- Flight Information Service.

The workforce was a combination of coalition military, military-contractor and civilian controllers.

## 7. Airspace and IFR minimum-altitude baseline

The AIP defined minimum flight altitude by adding 2,000 ft to terrain or obstacle height and rounding upward to the applicable published value. This provides a historical planning baseline but does not replace DCS terrain clearance or mission-specific altitude analysis.

The AIP also recorded non-standard Class E implementation: VFR aircraft required clearance and two-way communications.

## 8. Measurement and datum standards

- Navigation distance: nautical miles.
- Short aerodrome distances: metres.
- Altitude/elevation/height: feet.
- Horizontal speed and wind speed: knots.
- Vertical speed: feet per minute.
- Landing/take-off wind direction: magnetic degrees.
- Other wind direction: true degrees.
- Visibility/RVR: kilometres or metres.
- Pressure: hectopascals.
- Temperature: Celsius.
- Time: UTC.
- Coordinates: WGS-84.

## 9. Location indicators relevant to OMW

| Location | AIP code | OMW note |
|---|---|---|
| Bagram | `OAIX` | Major military aerodrome |
| Jalalabad | `OAJL` | RC-East airfield |
| Kabul Airport | `OAKB` | KAIA |
| Kabul ACC/FIC | `OAKX` | ATS unit, not aerodrome |
| Kandahar | `OAKN` | Major military/civil aerodrome |
| Khost | `OAKS` | Khost/Salerno area |
| Gardez | `OAGZ` | Gardez airfield |
| Ghazni | `OAGN` | Ghazni airfield |
| Shindand | `OASD` | RC-West aviation base |
| Herat | `OAHR` | Herat airfield |
| Mazar-e-Sharif | `OAMS` | Northern hub |
| Kunduz | `OAUZ` | Northern airfield |
| Tarin Kowt | `OATT` | Listed as Tarin Kowt |
| Tereen/Tarin Kowt | `OATN` | Separate historical entry; do not silently merge |
| Sharona Airstrip | `OASA` | Sharana-area historical identifier |
| Camp Bastion | `OAZI` | RC-Southwest hub |
| Farah | `OAFR` | RC-West airfield |
| Lashkar Gah/Bost | `OABT` | Helmand airfield |
| Qalat | `OAQA` | Zabul airfield |
| Zaranj | `OAZJ` | Nimroz airfield |

The source contains additional minor airfields and landing locations. This table is the OMW-priority subset.

## 10. Published radio-navigation aids

| Site | Aid | Ident | Frequency/channel | Published coordinate | Restriction/note |
|---|---|---|---|---|---|
| Bagram | TACAN | `BGM` | CH105 / 115.8 | N34°56'34.8" E069°15'41.4" | Military use only |
| Bagram | ILS | `I-BAG` | 110.7 | N34°57'45.48" E069°16'39.55" | Historical source value |
| Herat | TACAN | `HRT` | CH54 / 111.7 | N34°12'38" E062°13'42" | Military use only |
| Herat | NDB | `HRT` | 412 kHz | N34°12'38" E062°13'42" | Historical source value |
| Kabul | VOR/DME | `KBL` | 112.0 / CH57 | N34°32'44.2" E069°17'25.4" | Historical source value |
| Kabul | TACAN | `OKB` | CH65 | N34°33'48.0" E069°12'58.7" | Military use only |
| Kabul | ILS | `I-AKW` | 110.5 / CH42 | N34°34'16.3" E069°11'29.5" | Historical source value |
| Kandahar | NDB | `KN` | source prints `1720 MHz` | N31°29'57.92" E065°51'09.30" | Unit appears anomalous; retain source wording pending verification |
| Kandahar | TACAN | `KAF` | CH75 / 112.8 | N31°30'24.6" E065°51'06.6" | Historical source value |
| Mazar-e-Sharif | TACAN | `MES` | CH72X / 112.5 | N36°42'15.84" E067°12'49.96" | Military use only |

### 10.1 Runtime rule

When native DCS ATC or terrain navaids are used:

```text
runtime_frequency = DCS_MAP_VALUE
runtime_channel = DCS_MAP_VALUE
runtime_location = DCS_TERRAIN_IMPLEMENTATION
```

Historical AIP values are retained for comparison, briefing context and later MOOSE/SRS implementation. They do not override DCS terrain data.

## 11. Meteorological services

Published weather-station codes included:

| Location | Source code | Note |
|---|---|---|
| Kabul | `OAKB` | Full station |
| Kandahar | `KQHN` | Historical military code |
| Bagram | `KQSA` | Historical military code |
| Herat | `OAHR` | Full station |
| Mazar-e-Sharif | `EQBM` | Historical military code |
| Kunduz | `EQBA` | Observation post only |
| Feyzabad | `EQBF` | Observation post only |

Kabul ACC could provide current conditions, altimeter settings and limited forecasts. Aircrews were encouraged to submit weather reports.

## 12. Search and Rescue baseline

The AIP states:

- no national Afghan SAR capability existed;
- ISAF could provide limited SAR by retasking available aircraft or helicopters;
- the Combined Rescue Coordination Centre at HQ ISAF Kabul coordinated SAR;
- CRCC operated H24;
- 121.5 MHz was monitored by operating units;
- ELT reports were to be passed to the nearest ATC facility and onward to HQ ISAF;
- standard ICAO survivor ground-to-air visual signals applied.

Project abstraction:

```text
AFGHAN_NATIONAL_SAR = UNAVAILABLE
ISAF_SAR = LIMITED_ASSET_DEPENDENT
CRCC_KABUL = COORDINATING_AUTHORITY
SAR_RESPONSE_TIME = NOT_GUARANTEED
```

## 13. DCS and MOOSE implementation boundary

### 13.1 Native DCS ATC

- DCS terrain frequencies and ATC bindings take precedence at runtime.
- A historically different frequency cannot be substituted while retaining native ATC unless DCS exposes it in the Mission Editor.
- Briefings and presets must use the actual runtime value.

### 13.2 Scripted MOOSE/SRS services

A later scripted service may use historical or mission-defined frequencies for:

- controller audio;
- ATIS-style broadcasts;
- advisory channels;
- tactical beacons;
- menu-driven clearances.

Pilot requests would normally be initiated through F10/menu logic unless a separate voice-recognition integration exists. Cockpit tuning can still gate reception of radio or SRS transmissions.

### 13.3 Navaids

- Terrain-embedded ILS, VOR, DME and NDB facilities remain controlled by the DCS map.
- Additional mission beacons may be possible where DCS/MOOSE supports them.
- A scripted transmitter is not automatically equivalent to a terrain-integrated ILS or module navigation-database entry.

## 14. Required later extraction

The full AIP contains detailed AD 2 records and charts for numerous aerodromes. A later structured extraction should capture for each OMW-priority airfield:

- ARP and elevation;
- runway dimensions and orientation;
- surface and PCN;
- declared distances;
- taxiways and aprons;
- lighting;
- operating hours;
- fuel and handling;
- fire category;
- ATS and radio services;
- local procedures;
- approach plates and airport diagrams;
- source page and confidence;
- DCS-map comparison.

## 15. Source-critical rules

```text
AIP_2008_STATIC_BASELINE = HIGH_CONFIDENCE_FOR_2008
AIP_2008_FREQUENCY = HISTORICAL_VALUE_ONLY_UNTIL_RUNTIME_ADOPTED
AIP_2008_SERVICEABILITY = NOT_ASSUMED_FOR_2010_2011
DCS_MAP_VALUE = RUNTIME_AUTHORITY_WHEN_NATIVE_SYSTEM_USED
NOTAM_DEPENDENT_STATUS = UNKNOWN_WITHOUT_PERIOD_NOTAM
```

## 16. Source

- *Republic of Afghanistan Aeronautical Information Publication (AIP), Twenty-Ninth Edition*, effective 20 November 2008, CFACC / Ministry of Transport and Civil Aviation, 357 pages.
