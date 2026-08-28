---
document_id: OMW-EVIDENCE-AFGHANISTAN-AIP-KAIA-LOP-SOURCE-RECORD
status: BINDING
document_class: SOURCE_RECORD
source_charge_date: 2026-07-29
validated_in_dcs: false
---

# Source Record – Afghanistan AIP 2008 and KAIA LOP 2009

## 1. Sources

### 1.1 Afghanistan AIP

- File: `9195568-AIP-Afghanistan-Ed29-20-Nov-08.pdf`
- Title: *Republic of Afghanistan Aeronautical Information Publication (AIP), Twenty-Ninth Edition*
- Effective date: 20 November 2008
- Issuing authorities: Combined Forces Air Component Commander and Ministry of Transport and Civil Aviation
- Length: 357 pages
- Classification marking: none identified in the supplied copy
- Repository treatment: source PDF not committed; paraphrased and structured content only

### 1.2 KAIA LOP

- File: `KAIA-LOP-9.7.pdf`
- Title: *Local Operating Procedures – Kabul Afghanistan International Airport, LOP V 9.7*
- Effective date: 20 October 2009
- Issuing authority: HQ ISAF / COM KAIA
- Length: 30 pages
- Marking: NATO/ISAF UNCLASSIFIED
- Repository treatment: source PDF not committed; paraphrased and structured content only

## 2. Resulting documents

- `docs/72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md`
- `docs/73-kaia-local-operating-procedures-2009.md`

## 3. Extracted subject areas

### Afghanistan AIP

- CFACC/MoTCA authority split;
- Kabul FIR and ATS architecture;
- PPR and overflight approval;
- flight-risk warnings and intercept consequences;
- RNP-10, Mode C, TCAS and monitoring requirements;
- ATS service types and controlled-airfield list;
- measurement and WGS-84 standards;
- aerodrome/location indicators;
- published navigation aids, channels, frequencies and coordinates;
- meteorological station codes;
- national/ISAF SAR framework;
- DCS/MOOSE implementation boundary.

### KAIA LOP

- KAIA command and responsibility model;
- H24 military and restricted civil operating hours;
- airport closure and weather minima;
- PPR, slots, AMCC and ALCC coordination;
- historical ATIS, emergency, MEDEVAC and ground-control frequencies;
- VFR/SVFR minima;
- fixed-wing and rotary-wing routes;
- aircraft priority order;
- runway separation;
- UAV operating limits;
- taxi, parking, vehicle, pedestrian and Follow-Me rules;
- fuel, cargo and jet-blast handling;
- emergency, MEDEVAC, SAFIRE and radio-failure procedures;
- controlled jettison and bailout areas;
- ANA Air Corps local procedures;
- ISAF AOR and military-camp overflight maps.

## 4. Source-critical limitations

- The AIP is effective in 2008 and the KAIA LOP in 2009; neither proves every value remained unchanged throughout 2010–2011.
- Historical frequencies are retained as source facts but do not override native DCS terrain or Mission Editor values.
- DCS terrain-embedded ILS/VOR/TACAN/NDB behavior remains runtime authority when native systems are used.
- The Kandahar NDB frequency unit in the AIP appears anomalous (`1720 MHz`) and is preserved as a source issue rather than silently corrected.
- `OATT` and `OATN` are both retained as historical Tarin Kowt-related location entries.
- Low-resolution maps are not treated as ready-to-use DCS polygons without georeferencing.
- Historical personal telephone numbers, email addresses and named current contacts were not retained as active project contacts.

## 5. Confidence model

```text
OFFICIAL_PRIMARY_SOURCE_FOR_EFFECTIVE_DATE = HIGH
STATIC_GEOGRAPHY_AND_IDENTIFIERS = HIGH
PROCEDURE_VALIDITY_IN_2010_2011 = MEDIUM_PENDING_CROSSCHECK
FREQUENCY_VALIDITY_IN_2010_2011 = MEDIUM_PENDING_CROSSCHECK
NATIVE_DCS_RUNTIME_VALUE = DCS_MAP_OR_ME_AUTHORITY
```

## 6. No runtime acceptance

This source charge changes documentation only. It does not establish:

- successful DCS Mission Editor implementation;
- MOOSE ATC capability acceptance;
- SRS/TTS integration;
- validated taxi, runway or UAV deconfliction;
- active OMW frequency or navaid assignments.
