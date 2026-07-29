---
document_id: OMW-STAB-PRT-INTERAGENCY-DISTRICT-FRAMEWORK
status: BINDING
document_class: SOURCE_CRITICAL_OPERATIONAL_DESIGN_REFERENCE
authoritative_for:
  - PRT and interagency mission-design abstractions
  - district stability continuum and effect modeling
  - governance-development-security interaction
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/stability-layeha-route-clearance-cerp-sigacts
validated_in_dcs: false
---

# Stability Operations, PRT, Interagency Integration and District Stability Framework

## 1. Source basis

- USMC Center for Lessons Learned, *Irregular Warfare (IW) and Interagency Integration - Lessons and observations from OIF/OEF*, 9 April 2008.
- U.S. Army/RC-East presentation, *Stability Operations*; internal milestones cover 2009-2012 and identify a 2011 current-state marker, but the supplied copy contains no explicit publication date.

The material is historical operational context. It does not supersede OMW governance, ROE, NSL, active ORBAT or MOOSE implementation policy.

## 2. Interagency and PRT findings

The MCCLL source describes recurring gaps in unity of effort, role clarity, staffing and access to civilian expertise. Personal relationships and liaison officers frequently compensated for formal coordination gaps. PRT effectiveness depended on specialists in governance, economics, agriculture, transportation, civil engineering, micro-finance, trade, customs, immigration, rule of law, law enforcement, contracting, budgeting and project management.

```text
ORGANIZATION_PRESENT != ORGANIZATION_EFFECTIVE
LIAISON_ASSIGNED != INFORMATION_FLOW_ESTABLISHED
PROJECT_FUNDED != PROJECT_DELIVERED
PROJECT_DELIVERED != LEGITIMACY_GAIN
EFFORT != EFFECT
MONEY_SPENT != STABILITY_GAIN
```

PRTs combined provincial security, reconstruction, development, governance support, engagement with local authorities and operation of a forward base. Personnel often arrived as individual augmentees and required broad civil-military preparation.

```text
prt_staffing_quality
prt_civilian_access
prt_liaison_density
prt_local_relationships
prt_contracting_capacity
prt_project_oversight
prt_cultural_competence
prt_governance_mentoring
prt_information_quality
```

Measures of effectiveness shall assess outcomes rather than activity or expenditure: access to services, perceived government responsiveness, dispute-resolution capacity, freedom of movement, persistent employment, corruption perception, local ownership, maintenance and GIRoA ability to continue without coalition substitution.

## 3. Stability continuum

| State | Security | Governance | Population | Economy |
|---|---|---|---|---|
| `DANGEROUS` | severe threat; low ANSF capability; limited freedom of movement | dysfunctional or absent; shadow governance evident | hostile, intimidated or unwilling to cooperate | stalled; very high unemployment; little licit activity |
| `IN_FLUX` | immediate post-clear/hold; frequent threats | GIRoA present but weak, corrupt, vacant or externally dependent | neutral or reluctant; uncertain of durable authority | minimal growth; mixed licit/illicit activity; short-term employment |
| `PERMISSIVE` | occasional threats; most routes and centers accessible | emerging institutions limited by competence and corruption | majority accepts GIRoA but confidence remains conditional | dependent growth; basic needs available; external support material |
| `SECURE` | few attacks; ANSF controls force | GIRoA authority prevails and services function | legitimacy broadly recognized; insurgency resisted and reported | sustainable activity; private investment and lower unemployment |

Transitions are reversible:

```text
DANGEROUS <-> IN_FLUX <-> PERMISSIVE <-> SECURE
```

```yaml
district_state:
  security_pressure: 0..100
  ansf_control: 0..100
  coalition_freedom_of_movement: 0..100
  civilian_implementer_access: 0..100
  giroa_presence: 0..100
  giroa_delivery_capacity: 0..100
  corruption_perception: 0..100
  shadow_governance: 0..100
  population_acceptance_giroa: 0..100
  population_confidence_giroa_survival: 0..100
  population_fear_red: 0..100
  licit_economic_activity: 0..100
  illicit_economic_activity: 0..100
  unemployment_pressure: 0..100
  donor_dependency: 0..100
```

## 4. RC-East Key Terrain District snapshot

The source places the following districts on the continuum. This is a time-bound source snapshot.

- **TF Bastogne** - `IN_FLUX`: Khas Kunar, Nurgal, Alingar, Khugyani, Mohmand Darah. `PERMISSIVE`: Mehtar Lam, Surkh Rod, Jalalabad, Rodat, Behsud, Qarghah'i, Kamah, Shinwar, Bati Kot, Kuz Kunar.
- **TF Lafayette** - `DANGEROUS`: Tagab. `PERMISSIVE`: Sarobi.
- **TF Bayonet** - `DANGEROUS`: Nerkh. `IN_FLUX`: Jalrayz, Sayad Abad. `PERMISSIVE`: Maidan Shahr, Pul-e Alam, Baraki Barak, Mohammad Agha.
- **TF Currahee** - `IN_FLUX`: Sar Rowzah. `PERMISSIVE`: Sharan, Orgun.
- **TF Rakkasan** - `DANGEROUS`: Dzadran, Sabari, Zurmat, Shamul. `IN_FLUX`: Jaji Maidan, Shwak, Bak. `PERMISSIVE`: Khost, Gardez, Nadir Shah Kot.
- **TF White Eagle** - `DANGEROUS`: Muqur, Ab Band, Waghaz, Qarah Bagh, Andar, Giro. `IN_FLUX`: Dehyak. `PERMISSIVE`: Ghazni.

## 5. Programming by state

- `DANGEROUS`: military-led clearing, civil-affairs contact, initial assessment, quick-impact employment and shaping.
- `IN_FLUX`: district support, mentoring, quick-response stabilization, rule-of-law support, short-term labor and rapid local-priority assessment.
- `PERMISSIVE`: local governance, community grants, municipal support, commercial agriculture, education, health, workforce development and strategic roads.
- `SECURE`: civilian-led long-term development, private investment, sustainable agriculture, national-ministry connection and transition.

The source presents District Support Teams and Village Stability Operations as complementary:

```text
DST = governance and stability in district center
VSO = population security and fear reduction in peripheral villages
DST + VSO = reintegration opportunity + transition conditions
```

## 6. Binding mission-design rules

1. Security gains without governance follow-through decay.
2. Development in an insecure area can create targets, corruption and dependency.
3. Large funding surges can increase instability when oversight and local legitimacy are weak.
4. Civilian casualties and disrespectful force posture can erase gains outside the incident location.
5. Local personnel selection and local ownership influence acceptance.
6. PRT effects depend on information quality and sustained relationships, not only project count.
7. No tribe, ethnicity or locality receives an automatic loyalty state.

## 7. Source limits

- The MCCLL paper combines OIF and OEF observations; Iraq-specific findings are used only where generalized to interagency practice.
- The Stability Operations deck is undated in the supplied copy. Its categories are not a universal 2011 truth.
- Historical program names and funding mechanisms are not recreated as current administrative systems.
