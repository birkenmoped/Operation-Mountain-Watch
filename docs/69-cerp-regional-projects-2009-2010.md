---
document_id: OMW-STAB-CERP-REGIONAL-PROJECTS-2009-2010
status: BINDING
document_class: SOURCE_CRITICAL_HISTORICAL_DATA_REFERENCE
authoritative_for:
  - CERP project-volume baseline by Regional Command and province
  - 2009-07-31 to 2010-08-01 development activity context
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/stability-layeha-route-clearance-cerp-sigacts
validated_in_dcs: false
---

# CERP Regional Projects - 31 July 2009 to 1 August 2010

## 1. Source set

Six CIDNE-derived presentations: `RC-C-CERP.pdf`, `RC-E-CERP.pdf`, `RC-N-CERP.pdf`, `RC-S-CERP.pdf`, `RC-SW-CERP.pdf`, and `RC-W-CERP.pdf`. Each deck reports projects in the preceding 12 months and includes province views by month, district and AIMS category.

The extracted text reliably exposes the following province totals. Detailed chart values that are not text-extractable remain source-chart data and are not silently reconstructed.

## 2. Confirmed totals

### RC Capital

| Province | Projects |
|---|---:|
| Kabul | 302 |

### RC East

| Province | Projects |
|---|---:|
| Bamyan | 43 |
| Ghazni | 102 |
| Khost | 215 |
| Kunar | 462 |
| Laghman | 235 |
| Logar | 179 |
| Nangarhar | 370 |
| Nuristan | 96 |
| Paktya | 179 |
| Paktika | 268 |
| Panjshir | 52 |
| Parwan | 180 |
| Wardak | deck present; total pending visual chart transcription |

### RC South

| Province | Projects |
|---|---:|
| Kandahar | 98 |
| Zabul | 149 |
| Uruzgan | 105 |
| Daykundi | 41 |

### RC Southwest

| Province | Projects |
|---|---:|
| Helmand | 547 |
| Nimroz | 20 |

### RC West

| Province | Projects |
|---|---:|
| Herat | 181 |
| Badghis | 39 |
| Farah | 110 |

### RC North

The deck contains province-level charts for the northern region. Text extraction is ambiguous for several labels. Confirmed visible totals include Badakhshan 56 and Faryab 21; remaining labels and values require chart-by-chart visual normalization before they become structured data.

## 3. Interpretation

```text
PROJECT_COUNT != MONEY_SPENT
PROJECT_COUNT != PROJECT_QUALITY
PROJECT_COUNT != PROJECT_COMPLETION
PROJECT_COUNT != STABILITY_EFFECT
HIGH_PROJECT_DENSITY != HIGH_GOVERNMENT_LEGITIMACY
```

Counts indicate activity reported in CIDNE, not independently verified impact.

## 4. Mission-design use

CERP density can influence visible construction/service sites, contractor and convoy traffic, route-security demand, temporary employment, corruption exposure, RED intimidation opportunities, PRT workload, information narratives and maintenance/handover missions.

The confirmed values show especially high activity in Helmand, Kunar and Nangarhar, with substantial activity in Paktika, Laghman, Khost, Kabul, Parwan, Paktya, Logar and Herat. These values shape relative mission density, not one-to-one placement.

```yaml
cerp_project:
  source_region
  province
  district
  aims_category
  report_month
  status_unknown_or_reported
  local_priority_match
  contractor
  security_dependency
  corruption_exposure
  red_disruption_risk
  sustainment_capacity
  giroa_visibility
```

## 5. Source limits

- Period ends on 1 August 2010 and is a pre-/opening-scenario baseline.
- CIDNE reporting completeness is unknown.
- Totals may include projects at different stages.
- District and AIMS chart values are not inferred from unreadable extraction.
- No financial value is assigned unless explicitly transcribed.
