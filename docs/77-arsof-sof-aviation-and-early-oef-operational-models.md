---
document_id: OMW-HIST-ARSOF-SOF-AVIATION-EARLY-OEF
status: BINDING
document_class: SOURCE_CRITICAL_OPERATIONAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical early-OEF ARSOF, SOF aviation, CSAR, PSYOP, civil-affairs and support patterns
  - historical base and communications models for K2, Bagram and Kandahar
  - mission-design lessons from October 2001 through May 2002
not_authoritative_for:
  - active 2010-2011 OMW SOF ORBAT
  - complete team roster or complete classified operation record
  - automatic use of early-OEF frequencies, callsigns or force levels
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: 60942323d6b4a58fd926999566a48df8da45fb99
supersedes: []
superseded_by: []
validated_in_dcs: false
---

# ARSOF, SOF Aviation and Early-OEF Operational Models

## 1. Quellenrahmen

Grundlage ist *Weapon of Choice: U.S. Army Special Operations Forces in Afghanistan*. Die Quelle behandelt den Zeitraum 11 September 2001 bis 15 Mai 2002 und ist eine offizielle, bewusst sanitizierte Operationsgeschichte.

```text
SANITIZED_PUBLIC_HISTORY != COMPLETE_OPERATIONAL_RECORD
PSEUDONYM_OR_GENERIC_ELEMENT != EXACT_UNIT_IDENTITY
VIGNETTE_SELECTION != COMPLETE_ORBAT
```

## 2. Führungsstruktur

Wesentliche Organisationen:

- USSOCOM;
- SOCCENT;
- JSOC;
- JSOTF-North / Task Force Dagger;
- spätere CJSOTF-Afghanistan;
- 5th Special Forces Group als Kern von CJSOTF-North;
- 7th und 3rd Special Forces Group in Vorbereitung und Folgeaufträgen;
- 160th Special Operations Aviation Regiment;
- Rangers;
- Civil Affairs;
- Psychological Operations;
- Signal- und Supportkräfte.

## 3. K2 / Karshi-Khanabad als austere SOF base

K2 wurde in kurzer Zeit zu Camp Freedom und JSOTF-North-Hub ausgebaut. Erforderlich waren:

- Host-Nation- und Site Coordination;
- Base Security;
- Runway und Air Movement Control;
- Fuel;
- Water;
- Power;
- billeting;
- food service;
- aviation maintenance;
- communications;
- JOC;
- medical support;
- logistics staging.

Reihenfolge:

```text
ACCESS_AGREEMENT
  -> ADVANCE_PARTY
  -> SECURITY_AND_AIRFIELD_CONTROL
  -> FUEL_AND_POWER
  -> COMMUNICATIONS
  -> AVIATION_MAINTENANCE
  -> JOC
  -> SUSTAINMENT_EXPANSION
```

```text
AIRFIELD_AVAILABLE != OPERATING_BASE_READY
AIRCRAFT_PRESENT != MAINTENANCE_SUPPORTED
SUPPLIES_DELIVERED != SUPPLIES_DISTRIBUTED
```

## 4. Aviation-System

Dokumentierte Plattformen und Rollen:

| Plattform | Rolle |
|---|---|
| MH-47E | Long-range infiltration, resupply, CSAR, high-altitude operations |
| MH-60L DAP | Armed escort and direct fire |
| AH-6 | Night attack and raid support |
| Mi-17 | austere utility movement with contract crews |
| MC-130P | infiltration support and aerial refueling |
| AC-130 | precision fires and overwatch |
| C-17/C-130 | strategic/theater airlift and humanitarian drops |
| P-3C | surveillance/support |
| A-10 | CAS |

Aerial refueling war für Reichweite und Loiter entscheidend. Maintenance war ein einsatzbestimmender Faktor.

```text
AIRFRAME_RANGE != MISSION_RADIUS_WITHOUT_TANKER
AIRCRAFT_TOTAL != AIRCRAFT_MISSION_READY
NIGHT_CAPABLE != WEATHER_INDEPENDENT
HIGH_ALTITUDE_CAPABLE != UNLIMITED_PAYLOAD
```

## 5. CSAR und Personnel Recovery

Northern Air Campaign und CSAR waren eng gekoppelt. MH-47E wurden für Personnel Recovery vorbereitet. Missionen mussten kombinieren:

- alert posture;
- survivor location;
- threat assessment;
- escort;
- tanker support;
- medical capability;
- recovery crew;
- alternate landing or hoist method.

```text
DOWNED_AIRCREW
  -> REPORT_AND_LOCATE
  -> ISOLATION_PLAN
  -> THREAT_SUPPRESSION
  -> RECOVERY_PACKAGE
  -> INFILTRATION
  -> AUTHENTICATION
  -> EXTRACTION
  -> MEDICAL_HANDOVER
```

## 6. Special Forces und indigene Partner

ODAs arbeiteten mit unterschiedlichen afghanischen Führern und Kräften. Wirkung entstand aus:

- rapport;
- communications;
- target designation;
- air-ground integration;
- small-unit advice;
- medical support;
- resupply;
- political mediation.

```text
PARTNER_FORCE_SIZE != PARTNER_FORCE_CONTROL
LOCAL_LEADER_ALLIED != LOCAL_FORCE_DISCIPLINED
TARGET_DESIGNATION != TARGET_AUTHORIZATION
RAPPORT != PERMANENT_LOYALTY
```

## 7. Airpower Integration

ODAs konnten mit Laser Designators und Funk die Wirkung großer Luftstreitkräfte auf taktische Ziele lenken. Erforderlich:

- eindeutige Friendly Location;
- Target Description;
- Attack Geometry;
- Airspace Deconfliction;
- Mark;
- Abort Criteria;
- BDA.

Friktionen:

- unterschiedliche Intelligence-Anforderungen von Air und Ground;
- Zeitverzug;
- Kommunikationsausfälle;
- unklare Friendly Positions;
- Wetter und Gelände;
- Munitions- und Plattformverfügbarkeit.

## 8. Communications

Die Quelle beschreibt Signalaufbau als kritische Grundlage. K2 und später Bagram benötigten:

- SATCOM;
- line-of-sight radio;
- data networks;
- redundant paths;
- power and cabling;
- battle-captain/JOC integration;
- cryptographic control.

```text
PRIMARY_NET_LOSS
  -> ALTERNATE_NET
  -> RELAY_OR_RETRANSMISSION
  -> SATCOM
  -> RUNNER_OR_PREPLANNED_ACTION
```

Ein Kryptografiekompromiss ist als eigener Incident mit Schlüsselwechsel und Netzrekonstitution zu behandeln.

## 9. PSYOP

Dokumentierte Mittel:

- leaflets;
- Commando Solo;
- lokale Radiofrequenzen;
- loudspeaker teams;
- transistor radios;
- tactical messages;
- surrender and reassurance themes.

```text
MESSAGE_BROADCAST != MESSAGE_RECEIVED
MESSAGE_RECEIVED != MESSAGE_BELIEVED
LEAFLET_DROP != BEHAVIOR_CHANGE
```

PSYOP-Wirkung hängt ab von:

- credibility;
- language;
- timing;
- local messenger;
- consistency with observed coalition behavior;
- enemy counter-narrative.

## 10. Civil Affairs und Humanitarian Assistance

CA-Teams arbeiteten an:

- wells;
- schools;
- hospitals;
- humanitarian delivery;
- local negotiations;
- liaison;
- needs assessment.

Inventur, Accountability und Distribution waren ebenso wichtig wie Lieferung.

```text
AID_ARRIVES_AT_BASE != AID_REACHES_POPULATION
AID_DISTRIBUTED != GOVERNMENT_CREDIT
LOCAL_REQUEST != VERIFIED_PRIORITY
```

## 11. Aerial Resupply

Einsatzmuster:

- receiver-marked drop zones;
- bundles from altitude;
- emergency resupply;
- date drops;
- vehicle and equipment insertion;
- recovery of misdropped supplies.

Risiken:

- navigation error;
- wind drift;
- enemy observation;
- bundle damage;
- inability to recover heavy loads;
- compromise of team location.

## 12. Tarin Kowt, Kandahar and southern campaign

Die Quelle dokumentiert die Kombination aus:

- ODA support to Afghan forces;
- close air support;
- rapid political-military alignment;
- ground maneuver toward Kandahar;
- tactical engagements at bridges and approaches;
- Civil Affairs after combat.

Für OMW gilt:

```text
CITY_CAPTURED != REGION_STABILIZED
LOCAL_LEADER_EMPOWERED != GOVERNANCE_INSTITUTIONALIZED
TACTICAL_AIRPOWER_SUCCESS != POST_CONFLICT_CONTROL
```

## 13. Tora Bora und Anaconda

Die Fälle zeigen:

- Grenzen kleiner Ground Footprints;
- Bedeutung von Blocking Positions;
- komplexe SOF-/Conventional-/Air-Integration;
- Hochgebirgs- und LZ-Probleme;
- Rescue under Fire;
- Friktionen durch unvollständige gemeinsame Planung.

Takur Ghar und andere Rescue-Fälle bestätigen:

```text
ISR_CONTACT != COMPLETE_SITUATIONAL_AWARENESS
EXTRACTION_HELICOPTER != SECURED_LZ
CAS_AVAILABLE != IMMEDIATE_FIRE
```

## 14. Base- und JOC-Modell

```yaml
sof_base:
  runway_status:
  fuel_state:
  water_state:
  power_state:
  billeting_capacity:
  maintenance_capacity:
  communications_primary:
  communications_alternate:
  medical_capacity:
  security_state:
  air_movement_capacity:
  jstaff_capacity:
```

## 15. OMW-Nutzungsgrenzen

Die Quelle darf verwendet werden für:

- frühe SOF- und Aviation-Prinzipien;
- austere basing;
- CSAR;
- Air-Ground Integration;
- PSYOP/CA;
- Kommunikationsfriktion.

Sie darf nicht unverändert die 2010/2011-ORBAT bestimmen.

## 16. Querverweise

- `docs/45-air-c2-cas-afghanistan.md`
- `docs/50-afghanistan-force-basing-aviation-2010-2011.md`
- `docs/52-army-aviation-vignettes-and-coin-intelligence-metrics.md`
- `docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md`
- `docs/60-afghan-air-wars-2009-2011-airpower-operations-reference.md`
- `docs/63-ntma-sfa-attack-the-network-stratcom-and-local-influence.md`
