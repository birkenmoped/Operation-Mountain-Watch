---
document_id: OMW-RED-SIGACT-PATTERNS-2010-08-10
status: BINDING
document_class: SOURCE_CRITICAL_HISTORICAL_INCIDENT_REFERENCE
authoritative_for:
  - weekly SIGACT pattern context from 2010-08-29 to 2010-10-24
  - regional threat and incident mission-design baselines
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/stability-layeha-route-clearance-cerp-sigacts
validated_in_dcs: false
---

# NATO/ISAF SIGACT Patterns - 29 August to 24 October 2010

## 1. Source set

The archive contains seven IDC weekly security narratives and six map packets.

Narratives:

- 29 Aug-5 Sep 2010
- 6-12 Sep 2010
- 13-19 Sep 2010
- 27 Sep-3 Oct 2010
- 4-10 Oct 2010
- 11-17 Oct 2010
- 18-24 Oct 2010

Maps:

- 6-12 Sep 2010
- 13-19 Sep 2010
- 27 Sep-3 Oct 2010
- 4-10 Oct 2010
- 11-17 Oct 2010
- 18-24 Oct 2010

The interval 20-26 September and a 29 Aug-5 Sep map packet are absent. Several files retain NATO RESTRICTED or FOUO/REL UNDSS markings. OMW stores paraphrased historical abstractions and provenance, not the PDFs.

## 2. Source-use discipline

```text
REPORTED_INCIDENT != INDEPENDENTLY_VERIFIED_EVENT
INCIDENT_COUNT != INSURGENT_STRENGTH
LOW_REPORTED_ACTIVITY != LOW_THREAT
MAP_DENSITY != POPULATION_SUPPORT
```

The products combine reported incidents, selected highlights, narrative assessment and map symbology. Reporting bias and gaps remain relevant.

## 3. Incident classes

- IED found, cleared or detonated;
- suicide and vehicle-borne attack;
- small-arms fire;
- RPG/anti-vehicle fire;
- indirect fire;
- complex attack;
- raid or capture operation;
- assassination or targeted killing;
- intimidation, threat or abduction;
- demonstration and civil disturbance;
- cache discovery;
- narcotics or criminal activity;
- ANSF/coalition operation;
- civilian-casualty or collateral narrative;
- infrastructure, convoy or supply-route incident.

## 4. Weekly timeline

- **29 Aug-5 Sep:** opening late-summer baseline across all Regional Commands.
- **6-12 Sep:** low Kabul activity but a mobile-phone-linked RCIED in Paghman and demonstrations related to the proposed Quran-burning controversy, showing that external political events could alter the local information environment.
- **13-19 Sep:** election-week security; Kabul incident density remained comparatively low while security posture and threat reporting increased.
- **27 Sep-3 Oct:** post-election bridge into normal autumn threat patterns.
- **4-10 Oct:** the map packet reports an IED detonation between convoy vehicles south of Bagram during resupply, demonstrating route exposure near major bases.
- **11-17 Oct:** full-country mid-October incident and map baseline.
- **18-24 Oct:** the map packet reports a coalition raid in Deh Sabz capturing an alleged IED facilitator, linking network targeting with capital-region security.

## 5. Regional use

- **RC Capital:** generally lower density than several other regions, but demonstrations, assassination/grenade threats, facilitation and convoy risk remain relevant.
- **RC East:** route/IED activity, cross-border facilitation, network operations and terrain-driven district variation.
- **RC North:** localized spikes around contested districts and routes rather than uniform saturation.
- **RC South:** IED, assassination, complex attack and Kandahar intimidation interacting with governance and confidence.
- **RC Southwest:** sustained IED and insurgent activity with route-clearance, resupply and casualty narratives.
- **RC West:** lower aggregate density than southern/eastern centers but persistent district threats, route attacks and border considerations.

```yaml
weekly_threat_state:
  region
  province
  district
  week_start
  week_end
  incident_density
  ied_pressure
  direct_fire_pressure
  indirect_fire_pressure
  complex_attack_pressure
  assassination_pressure
  civil_unrest_pressure
  network_targeting_activity
  route_risk
  reporting_confidence
  source_marking
```

## 6. Mission-generation rules

1. Generate clusters and quiet periods, not uniform random attacks.
2. Recent incidents raise route risk and intelligence interest but do not guarantee repetition.
3. Political events can shift posture and protest risk.
4. Raids should be linked to prior intelligence and may reduce or displace capability.
5. A quiet week may reflect suppression, displacement, weather, reporting gaps or deliberate preparation.
6. Incident effects propagate through information, fear and confidence systems.
7. Historical incidents inspire archetypes; exact victims or sensitive details are not recreated without separate approval.

## 7. Data gaps

- 20-26 September 2010 missing.
- no 29 Aug-5 Sep map packet.
- map and narrative coverage may differ.
- source markings and release provenance must remain recorded.
- no ambiguous field is silently invented.
