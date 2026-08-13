---
document_id: OMW-EVIDENCE-MQ9-FUEL-RATE-SOURCE-ANALYSIS-2026-08-13
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - source-derived MQ-9 fuel-planning rate calculation
  - distinction between derived planning rate and measured fuel flow
not_authoritative_for:
  - strategic JP-8 stock quantities
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# MQ-9 Reaper - quellenabgeleitete Fuel-Planungsraten

## Quellenbasis

Die bestehende OMW-Referenz nennt fuer MQ-9 eine Fuel Capacity von 4,000 lb / 602 US gal. Dave Sloggett, *Drone Warfare: The Development of Unmanned Aerial Conflict*, Pen & Sword Aviation, 2014, S. 107, nennt fuer die dort beschriebenen britischen MQ-9 in Afghanistan bis zu 18 h Endurance bei voller Waffenbeladung und nahe 30 h in unbewaffneter Konfiguration.

Reg Austin, *Unmanned Aircraft Systems: UAVS Design, Development and Deployment*, Wiley, 2010, S. 53-54, stuetzt die technische Interpretation, dass externe Payloads den Widerstand erhoehen und Reichweite sowie Endurance reduzieren.

Die von Sloggett ebenfalls genannte Reichweite von ungefaehr 3,700 miles / 5,900 km ist nicht eindeutig jeweils einer bewaffneten oder unbewaffneten Konfiguration zugeordnet und wird deshalb nicht fuer eine getrennte Verbrauchsrechnung verwendet.

## Berechnungsannahme

Die Rechnung setzt voraus, dass die OMW-Referenzkapazitaet von 602 US gal / 4,000 lb als Kapazitaetsbasis fuer die veroeffentlichten Endurance-Werte verwendet werden kann. Nicht belegt sind exakt nutzbare Restmenge, Fuel Reserve am Missionsende, Hoehen-/Leistungsprofil, Wetter oder die konkrete Last jeder Referenzmission.

Daher gilt:

```text
SOURCE_DERIVED_CONFIGURATION_SPECIFIC_PLANNING_RATE
!= MEASURED_FUEL_FLOW
```

## Abgeleitete Werte

Bewaffnete Konfiguration:

```text
602 US gal / 18 h = 33.444444... US gal/h
4,000 lb / 18 h = 222.222222... lb/h
                    = approximately 100.798 kg/h
```

OMW-Planungswert: `33.44 US gal/h`, approximately `100.80 kg/h`.

Unbewaffnete Konfiguration:

```text
602 US gal / 30 h = 20.066666... US gal/h
4,000 lb / 30 h = 133.333333... lb/h
                    = approximately 60.479 kg/h
```

OMW-Planungswert: `20.07 US gal/h`, approximately `60.48 kg/h`.

## Abgrenzung zum bisherigen Proxy

Der aeltere OMW-Arbeitswert `602 US gal / 14 h = 43.0 US gal/h` war ein konservativer Capacity/Endurance-Proxy. Fuer neue konfigurationsbezogene MQ-9-Planungsmodelle werden stattdessen `20.07 US gal/h` unbewaffnet und `33.44 US gal/h` bewaffnet verwendet.

Diese Praezisierung betrifft nur die MQ-9-Verbrauchs-Planungsrate. Sie berechnet den bereits abgeschlossenen Kandahar-JP-8-Lagerbestand nicht neu und ist kein DCS-Runtime-Nachweis.
