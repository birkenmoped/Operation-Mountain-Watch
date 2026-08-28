---
document_id: OMW-AIR-AFGHANISTAN-AIP-2008
status: BINDING
document_class: SOURCE_CRITICAL_AERONAUTICAL_REFERENCE
owning_policy: OMW-GOV-001
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
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: 194bf317d8ad212aff9a1f3f578271b07d253e6c
source_date: 2008-11-20
validated_in_dcs: false
---

# Afghanistan AIP 2008 – Airspace, Aerodromes and Flight Procedures

## 1. Purpose and source authority

This document records the mission-design-relevant content of the *Republic of Afghanistan Aeronautical Information Publication*, Twenty-Ninth Edition, effective 20 November 2008. The AIP was issued by the Combined Forces Air Component Commander in coordination with the Afghan Ministry of Transport and Civil Aviation and contains 357 pages.

The AIP is an official primary source. It predates the OMW scenario period by approximately twenty months. Static geography, aerodrome identifiers, runway orientation and institutional structure are high-value historical baselines. Frequencies, serviceability, declared distances, operating hours and temporary procedures require later-source or DCS-terrain cross-checking.

Historical source precedence:

```text
NOTAM / AIP SUP effective at event time
    > applicable AIP edition
    > local operating procedure subordinate to the AIP
    > project abstraction
```

OMW runtime precedence:

```text
native DCS ATC or terrain navaid used
    => DCS terrain / Mission Editor value is mandatory at runtime

scripted MOOSE/SRS service used
    => mission-defined value may be used if implemented and briefed
```

```text
HISTORICAL_FREQUENCY != AUTOMATIC_RUNTIME_FREQUENCY
HISTORICAL_NAVAID != GUARANTEED_DCS_NAVAID
```

## 2. Kabul FIR governance and permissions

- CFACC, on behalf of MoTCA, served as Afghanistan Airspace Control Authority from 11 February 2002 until further notice.
- MoTCA remained responsible for civil aviation entry, overflight, arrival and departure approval.
- Kabul ACC/FIC provided national en-route service.
- The AIP applied to civil, military, humanitarian, NGO, international-organization and State aircraft operating in the Kabul FIR.
- All aircraft required MoTCA approval to land, depart or overfly Afghanistan.
- Requests were expected at least 24 hours in advance.
- PPR airfields were identified in ENR 1.9 and by NOTAM.
- Operators also required relevant airfield permission and an international flight plan.

Historical personal contact details are not reproduced as active project contacts.

## 3. Flight-risk environment

The AIP warned of:

- hostile non-military action against aircraft;
- ongoing military operations;
- interception by armed coalition aircraft for non-compliance;
- temporary route deviations directed by the ACA;
- poor pavement and limited or absent ATC, meteorological, fire/rescue and ground support at most airfields other than Kabul, Kandahar, Mazar-e-Sharif and U.S. military airfields.

```text
AIRFIELD_EXISTS != AIRFIELD_FULLY_SUPPORTED
PUBLISHED_ROUTE != GUARANTEED_UNCONTESTED_ROUTE
PROCEDURAL_NONCOMPLIANCE -> INTERCEPT_OR_AIRSPACE_DENIAL_RISK
```

## 4. Communications, surveillance and navigation requirements

### 4.1 Mandatory monitoring and transponder use

- Emergency frequency: `121.500 MHz`.
- Afghan Advisory air-to-air: `125.200 MHz` when not in positive contact with a controlling agency.
- Serviceable pressure-altitude-reporting transponder required.
- Mode C required continuously.
- VFR code `1200` unless assigned a discrete code.
- Military operators used ATO or AMCC assigned codes where applicable.

### 4.2 Navigation performance

- Civil and State overflight aircraft required RNP-10 approval.
- Dual navigation systems of adequate integrity were required.
- Aircraft unable to meet RNP-10 could not operate IFR in the Kabul FIR.
- Navigation-equipment degradation had to be reported to ATC.
- TCAS was required for civilian aircraft at or above FL240.

## 5. ATS structure

Aerodrome control service was published for:

- Bagram;
- Kandahar;
- Kabul;
- Herat;
- Mazar-e-Sharif.

Approach-control baseline:

- radar approach: Bagram, Kabul, Kandahar;
- procedural approach: Mazar-e-Sharif;
- Kabul ACC: procedural en-route service on high- and low-level route structures.

Published service types included Aerodrome Control, Surface Movement Control, Approach/Departure Control, Area Control, ATC Surveillance, Radar Information Service, Final Approach Service, Emergency Service and Flight Information Service. The workforce combined coalition military, military-contractor and civilian controllers.

## 6. Airspace and altitude baseline

The AIP defined a minimum-flight-altitude method based on terrain/obstacle height plus 2,000 ft and upward rounding to the applicable published value. This is historical context and does not replace DCS terrain-clearance analysis.

Class E implementation was non-standard: VFR aircraft required clearance and two-way communications.

## 7. Measurement and datum standards

- Navigation distance: nautical miles.
- Short aerodrome distances: metres.
- Altitude/elevation/height: feet.
- Horizontal and wind speed: knots.
- Vertical speed: feet per minute.
- Landing/take-off wind direction: magnetic degrees.
- Other wind direction: true degrees.
- Visibility/RVR: kilometres or metres.
- Pressure: hectopascals.
- Temperature: Celsius.
- Time: UTC.
- Coordinates: WGS-84.

## 8. Location indicators relevant to OMW

| Location | AIP code | Note |
|---|---|---|
| Bagram | `OAIX` | major military aerodrome |
| Jalalabad | `OAJL` | RC-East airfield |
| Kabul Airport | `OAKB` | KAIA |
| Kabul ACC/FIC | `OAKX` | ATS unit, not aerodrome |
| Kandahar | `OAKN` | major military/civil aerodrome |
| Khost | `OAKS` | Khost/Salerno area |
| Gardez | `OAGZ` | Gardez airfield |
| Ghazni | `OAGN` | Ghazni airfield |
| Shindand | `OASD` | RC-West aviation base |
| Herat | `OAHR` | Herat airfield |
| Mazar-e-Sharif | `OAMS` | northern hub |
| Kunduz | `OAUZ` | northern airfield |
| Tarin Kowt | `OATT` | listed as Tarin Kowt |
| Tereen/Tarin Kowt | `OATN` | separate historical entry; do not silently merge |
| Sharona Airstrip | `OASA` | Sharana-area historical identifier |
| Camp Bastion | `OAZI` | RC-Southwest hub |
| Farah | `OAFR` | RC-West airfield |
| Lashkar Gah/Bost | `OABT` | Helmand airfield |
| Qalat | `OAQA` | Zabul airfield |
| Zaranj | `OAZJ` | Nimroz airfield |

The AIP contains many additional minor landing locations. The table is the OMW-priority subset.

## 9. Published radio-navigation aids

| Site | Aid | Ident | Frequency/channel | Published coordinate | Note |
|---|---|---|---|---|---|
| Bagram | TACAN | `BGM` | CH105 / 115.8 | N34°56'34.8" E069°15'41.4" | military use only |
| Bagram | ILS | `I-BAG` | 110.7 | N34°57'45.48" E069°16'39.55" | historical value |
| Herat | TACAN | `HRT` | CH54 / 111.7 | N34°12'38" E062°13'42" | military use only |
| Herat | NDB | `HRT` | 412 kHz | N34°12'38" E062°13'42" | historical value |
| Kabul | VOR/DME | `KBL` | 112.0 / CH57 | N34°32'44.2" E069°17'25.4" | historical value |
| Kabul | TACAN | `OKB` | CH65 | N34°33'48.0" E069°12'58.7" | military use only |
| Kabul | ILS | `I-AKW` | 110.5 / CH42 | N34°34'16.3" E069°11'29.5" | historical value |
| Kandahar | NDB | `KN` | source prints `1720 MHz` | N31°29'57.92" E065°51'09.30" | unit appears anomalous; source wording retained |
| Kandahar | TACAN | `KAF` | CH75 / 112.8 | N31°30'24.6" E065°51'06.6" | historical value |
| Mazar-e-Sharif | TACAN | `MES` | CH72X / 112.5 | N36°42'15.84" E067°12'49.96" | military use only |

When native DCS systems are used:

```text
runtime_frequency = DCS_MAP_VALUE
runtime_channel = DCS_MAP_VALUE
runtime_location = DCS_TERRAIN_IMPLEMENTATION
```

Historical values remain reference, comparison and optional scripted-service data.

## 10. Meteorological services

| Location | Source code | Note |
|---|---|---|
| Kabul | `OAKB` | full station |
| Kandahar | `KQHN` | historical military code |
| Bagram | `KQSA` | historical military code |
| Herat | `OAHR` | full station |
| Mazar-e-Sharif | `EQBM` | historical military code |
| Kunduz | `EQBA` | observation post only |
| Feyzabad | `EQBF` | observation post only |

Kabul ACC could provide current conditions, altimeter settings and limited forecasts. Aircrews were encouraged to submit weather reports.

## 11. Search and Rescue baseline

The AIP records:

- no national Afghan SAR capability;
- limited ISAF SAR through retasking available aircraft or helicopters;
- coordination by the Combined Rescue Coordination Centre at HQ ISAF Kabul;
- H24 CRCC operation;
- monitoring of 121.5 MHz by operating units;
- ELT reporting through the nearest ATC facility to HQ ISAF;
- standard ICAO survivor ground-to-air visual signals.

```text
AFGHAN_NATIONAL_SAR = UNAVAILABLE
ISAF_SAR = LIMITED_ASSET_DEPENDENT
CRCC_KABUL = COORDINATING_AUTHORITY
SAR_RESPONSE_TIME = NOT_GUARANTEED
```

## 12. DCS and MOOSE implementation boundary

### Native DCS ATC

- DCS terrain frequencies and ATC bindings take precedence at runtime.
- A historically different frequency cannot replace native ATC unless DCS exposes it in the Mission Editor.
- Briefings and presets must use the actual runtime value.

### Scripted MOOSE/SRS service

A later scripted service may use historical or mission-defined frequencies for controller audio, ATIS-style broadcasts, advisory channels, tactical beacons and menu-driven clearances. Pilot requests normally originate through F10/menu logic unless a separate voice-recognition integration exists. Cockpit tuning can gate reception of radio or SRS transmissions.

### Navaids

- Terrain-embedded ILS, VOR, DME and NDB remain controlled by the DCS map.
- Additional mission beacons may be possible where DCS/MOOSE supports them.
- A scripted transmitter is not automatically equivalent to a terrain-integrated ILS or module navigation-database entry.

## 13. Required later AD-2 extraction

The full AIP contains detailed AD-2 records and charts. A later structured extraction should capture for each OMW-priority airfield:

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

## 14. Source-critical rules

```text
AIP_2008_STATIC_BASELINE = HIGH_CONFIDENCE_FOR_2008
AIP_2008_FREQUENCY = HISTORICAL_VALUE_ONLY_UNTIL_RUNTIME_ADOPTED
AIP_2008_SERVICEABILITY = NOT_ASSUMED_FOR_2010_2011
DCS_MAP_VALUE = RUNTIME_AUTHORITY_WHEN_NATIVE_SYSTEM_USED
NOTAM_DEPENDENT_STATUS = UNKNOWN_WITHOUT_PERIOD_NOTAM
```

## 15. Source

- *Republic of Afghanistan Aeronautical Information Publication (AIP), Twenty-Ninth Edition*, effective 20 November 2008, CFACC / Ministry of Transport and Civil Aviation, 357 pages.
