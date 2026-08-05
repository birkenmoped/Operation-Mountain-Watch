---
document_id: OMW-HIST-VANGUARD-SMALL-UNIT-OPERATIONS-2006-2011
status: BINDING
document_class: SOURCE_CRITICAL_OPERATIONAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical small-unit operations lessons from Vanguard of Valor volumes I and II
  - historical tactical task organization, enablers, fires, aviation and sustainment patterns
  - mission-design patterns for Kunar, Nuristan, Kandahar, Paktika, Badghis and Kabul Province
not_authoritative_for:
  - active OMW ORBAT
  - exact unit strength outside explicitly quoted source values
  - current DCS or MOOSE runtime acceptance
  - automatic projection of 2006-2009 conditions into 2010-2011
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: 0ee2ae3b057d4fccc4c866770fbda7a2aca83e18
supersedes: []
superseded_by: []
validated_in_dcs: false
---

# Vanguard of Valor – Small-Unit Operations 2006–2011

## 1. Zweck und Quellenrahmen

Dieses Dokument normalisiert die für Operation Mountain Watch relevanten Inhalte aus:

- *Vanguard of Valor: Small Unit Actions in Afghanistan*;
- *Vanguard of Valor, Volume II: Small Unit Actions in Afghanistan*.

Die beiden offiziellen CSI-/US-Army-Veröffentlichungen beruhen auf Interviews, Operationsunterlagen und militärhistorischer Auswertung. Band I enthält acht Fallstudien, Band II sechs Fallstudien. Die behandelten Ereignisse reichen von 2006 bis 2011. Die Fälle von 2010 und 2011 liegen unmittelbar im OMW-Szenariozeitraum; frühere Fälle werden als strukturelle und taktische Baseline verwendet.

Verbindliche Quellenregel:

```text
CASE_STUDY != COMPLETE_THEATER_RECORD
TACTICAL_SUCCESS != STRATEGIC_SUCCESS
UNIT_ASSIGNED != UNIT_LOCALLY_AVAILABLE
PLANNED_SUPPORT != SUPPORT_ACTUALLY_AVAILABLE
SOURCE_ABSENCE != CAPABILITY_ABSENCE
```

## 2. Fallstudienübersicht

### 2.1 Band I

| Kapitel | Raum/Zeit | Schwerpunkt |
|---|---|---|
| Firefight above Gowardesh | Nuristan/Kunar, Juni 2006 | Gebirgsaufklärung, isolierte OP, Fires, Extraction |
| Ambushing the Taliban | Korengal Valley | Patrol Base, Ambush, Terrain, Feindbewegung |
| Flipping the Switch | Zhari District | Weapons Platoon, Movement to Contact |
| Forging Alliances at Yargul | Kunar | lokale Sicherheit, Vertrauen, Infrastruktur |
| Operation STRONG EAGLE | Ghakhi Valley/Marawara, 2010 | Air Assault, gebirgige Offensive, Partnerkräfte |
| Disrupt and Destroy | Zhari District | Platoon Patrol, Kontakt, Standoff |
| Trapping the Taliban at OP Dusty | Zhari, 26 Sep 2010 | OP-Verteidigung, CAS, LGB |
| Objective Lexington | Ganjgal Valley, 29 Mar 2011 | Company Action, Fires, Reinforcement |

### 2.2 Band II

| Kapitel | Raum/Zeit | Schwerpunkt |
|---|---|---|
| Toe to Toe with the Taliban | Makuan/Zhari, 14–18 Sep 2010 | Deliberate Breach, IED-Gürtel, MASCAL |
| Gaining the Initiative in Musahi | Kabul Province | CERP, lokale Regierung, Disruption |
| Partnership in Paktika | Paktika, 2010–2011 | US-/ANA-Partnerschaft, Route Clearance |
| Leading the Charge | Badghis, 3–4 Apr 2011 | Cavalry Platoon, SLE, CAS |
| Combat Multipliers | Paktika | Female Engagement Teams |
| Securing Dan Patan | Paktia | Squad-level COIN, ALP, District Security |

## 3. Gowardesh / TF Titan

### 3.1 Operationsrahmen

3-71 Cavalry der 3rd BCT, 10th Mountain Division operierte 2006 als Task Force Titan aus FOB Naray. Die Task Force verfügte über vier company-sized maneuver elements und zusätzliche Anhänge. Ziel war die Sicherung von Bevölkerungszentren, die Bekämpfung von Infiltrationsrouten und die Vorbereitung von Operation GOWARDESH THRUST.

### 3.2 16-Mann-Kill-Team

Für Aufklärung, Beobachtung und Feuerleitung wurde eine besondere Formation gebildet:

```yaml
strength: 16
components:
  - COLT section
  - sniper section
capabilities:
  - observation
  - target acquisition
  - laser designation
  - fire direction
  - local security
```

Auftrag:

- Observation Post nahe Mountain 2610 beziehen;
- Named Areas of Interest überwachen;
- ausweichende Gegner erkennen;
- Artillerie und CAS lenken;
- Ziele bei Gelegenheit bekämpfen.

Geplante Unterstützung:

- 105-mm-Haubitzen;
- 120-mm-Mörser;
- Close Air Support;
- spätere Luftversorgung beziehungsweise Extraction.

### 3.3 Friktionen

Die Formation trug mehr als 50 lb Ausrüstung pro Soldat zusätzlich zur persönlichen Waffe und Proviant für drei Tage. Der Anstieg dauerte drei Tage. Nach Verzögerung der Hauptoperation entstand ein Versorgungskonflikt: Die geplante UH-60-Versorgung sollte ursprünglich durch größere Luftaktivität maskiert werden; der separate Tagesflug erhöhte das Entdeckungsrisiko.

Verbindliche Ableitungen:

```text
TACTICAL_SKILL != LONG_DURATION_SUSTAINMENT
OBSERVATION_POSITION != PREPARED_DEFENSIVE_POSITION
THREE_DAY_LOAD != SIX_DAY_ENDURANCE
AIR_RESUPPLY != LOW_SIGNATURE_RESUPPLY
EXTRACTION_PLAN_DEPENDENT_ON_MAIN_EFFORT = HIGH_RISK
```

## 4. Makuan / Operation DRAGON STRIKE

### 4.1 Auftrag und Gelände

Bravo Company, 1-502 Infantry, 2nd BCT, 101st Airborne Division, sollte Makuan im Zhari District von IEDs, Bombenbauplätzen und Aufständischen säubern. Das Gelände bestand aus Lehmkomplexen, hohen Weinstockreihen, Marihuana- und Granatapfelfeldern, Mauern, Kanälen und Wadis. Makuan diente als:

- IED-Produktionsraum;
- Bed-down Area;
- Sammelraum für Angriffe auf Highway 1;
- durch IED-Gürtel geschützter Rückzugsraum.

### 4.2 Task Organization

Organisch:

- drei Rifle Platoons.

Zusätzliche Enabler:

- Engineer Squad;
- EOD Team;
- Human Intelligence Collection Team;
- Advanced Trauma Life Support element;
- drei USMC Assault Breacher Vehicles;
- zwei M88 Recovery Vehicles;
- MRAPs;
- Navy Seabees mit D7;
- USAF- und Navy-Bombenspürhunde;
- ANA Company;
- ursprünglich Army Rangers, später anderweitig gebunden.

Die Quelle beschreibt die Gesamtgliederung als ungefähr neun Platoon-Äquivalente. Dies ist eine missionsbezogene Task Organization, keine permanente Kompaniestärke.

### 4.3 Breach

ABVs setzten MICLIC ein. Ein MICLIC schuf ungefähr einen acht Meter breiten Weg. Ein nicht detonierter Line Charge musste manuell nachgezündet werden. Die starke Sprengwirkung beeinträchtigte anschließend die Suchhunde.

An einer Kanalbrücke kombinierten die Gegner:

- Sprengladungen unter der Brücke;
- ein vergrabenes Rohr;
- einen baumhängenden IED als Overwatch-/Sekundärfalle;
- mögliches Direct- und Indirect-Fire-Risiko.

Zwei A-10 warfen je eine 500-lb-GBU auf die Brücke. Der Angriff zerstörte die Brücke und detonierte mehrere IEDs. Weitere MICLIC-Schüsse öffneten parallele Wege entlang des Kanals.

### 4.4 Missionsmodell

```text
INTELLIGENCE_PREPARATION
  -> BREACH_ASSET_POSITIONING
  -> MICLIC_OR_MECHANICAL_BREACH
  -> DISMOUNTED_FLANK_SECURITY
  -> EOD_CONFIRMATION
  -> ROUTE_MARKING
  -> INFANTRY_CLEARANCE
  -> RECOVERY_AND_MEDICAL_SUPPORT
```

Fehlerzustände:

```text
BREACH_CHARGE_FAILS
DOG_CAPABILITY_DEGRADED_BY_BLAST
BRIDGE_CANNOT_BE_RENDERED_SAFE
BREACH_FORCE_ISOLATED
MASCAL_EXCEEDS_ORGANIC_MEDICAL_CAPACITY
ATTACHED_ENABLER_RETASKED
```

## 5. Zhari-, OP- und CAS-Muster

Die Zhari-Fälle zeigen wiederkehrend:

- dichte Vegetation und eingeschränkte Sicht;
- IED-belastete Zugänge;
- dismounted infantry als entscheidenden Sensor;
- kleine OPs als Auslöser für größere Feuerunterstützung;
- Gegner, die Deckung, Bewässerungssysteme und Compound-Strukturen nutzen;
- CAS, Artillerie und Mörser nur bei tragfähiger Zielidentifikation und Deconfliction.

OP Dusty bestätigt die Bedeutung von:

```text
OP_DETECTION
  -> CONTACT_REPORT
  -> POSITIVE_IDENTIFICATION
  -> FIRE_SUPPORT_REQUEST
  -> MARK_OR_LASER
  -> CAS_ATTACK
  -> BDA
  -> DISPLACEMENT_OR_REINFORCEMENT
```

## 6. Operation STRONG EAGLE und Ghakhi Valley

Für gebirgige Offensiveinsätze sind relevant:

- Air Assault als Mittel zum Überwinden begrenzter Straßen;
- Trennung von Insertion, Assembly und Assault;
- hohe Abhängigkeit von Weather, LZ Capacity und Aircraft Availability;
- Partnerkräfte, die eigene Führungs-, Bewegungs- und Sustainmentgrenzen besitzen;
- Notwendigkeit, Fires und Luftbewegungen schon vor dem ersten Lift zu deconflicten.

```text
AIR_ASSAULT_INSERTED != COMBAT_EFFECTIVE
LANDING_COMPLETE != FORCE_CONSOLIDATED
PARTNER_FORCE_PRESENT != PARTNER_FORCE_SYNCHRONIZED
```

## 7. Paktika: Partnerschaft, Route Clearance und FET

### 7.1 US-/ANA-Partnerschaft

Die Quelle beschreibt Partnerschaft nicht als bloße gemeinsame Anwesenheit, sondern als wiederholten Zyklus:

```text
PLAN_TOGETHER
  -> REHEARSE_TOGETHER
  -> EXECUTE_TOGETHER
  -> DEBRIEF_TOGETHER
  -> CORRECT_SHORTFALLS
  -> REPEAT
```

Bewertungsfelder:

- leadership reliability;
- route discipline;
- reporting quality;
- medical response;
- maintenance;
- resupply;
- willingness to operate;
- local legitimacy.

### 7.2 Female Engagement Teams

FETs ermöglichten Zugang zu Bevölkerungsgruppen, die männliche Soldaten kulturell oder praktisch nicht erreichen konnten. Missionsnutzen:

- weibliche Personen an Kontrollpunkten ansprechen;
- medizinische und humanitäre Gespräche;
- Atmospherics;
- Hinweise zu Familien- und Dorfbedürfnissen;
- vertrauensbildende Maßnahmen.

Restriktion:

```text
FET_CONTACT != VERIFIED_INTELLIGENCE
FET_PRESENCE != AUTOMATIC_TRUST
CULTURAL_ACCESS != TARGETING_AUTHORITY
```

## 8. Musahi: CERP und Stabilisierung

CERP wurde genutzt, um Initiative zu gewinnen und lokale Regierungsfähigkeit sichtbar zu machen. Das Missionsmodell muss Projektaktivität von Wirkung trennen:

```text
PROJECT_FUNDED != PROJECT_COMPLETED
PROJECT_COMPLETED != PROJECT_MAINTAINED
AID_DELIVERED != GOVERNMENT_CREDIT
SHORT_TERM_ACCESS != DURABLE_SECURITY
```

Empfohlene Zustände:

- project_selection_quality;
- local_government_ownership;
- corruption_risk;
- contractor_reliability;
- insurgent_interference;
- population_perception;
- maintenance_capacity.

## 9. Dan Patan und Afghan Local Police

Squad-level COIN konnte durch dauerhaftes lokales Engagement, ALP-Strukturen und district-level Beziehungen Wirkung erzeugen. Für OMW gilt:

```text
ALP_SITE_ACTIVE != ALP_SITE_RELIABLE
LOCAL_RECRUITMENT != LOCAL_LEGITIMACY
LOCAL_KNOWLEDGE != COMMAND_DISCIPLINE
```

Missionsfelder:

- vetting quality;
- district leadership support;
- ammunition control;
- pay reliability;
- checkpoint discipline;
- insider-risk;
- population complaints;
- response time.

## 10. Badghis Cavalry Platoon

Der Fall bestätigt die Bedeutung kleiner, beweglicher Elemente, die:

- reconnaissance;
- security;
- village engagement;
- supporting fires;
- CAS;
- rapid concentration

kombinieren. Ein Platoon kann taktische Initiative erzeugen, bleibt aber von höherer Feuerunterstützung, medizinischer Evakuierung und Wiederauffüllung abhängig.

## 11. Übergreifende Missionsdesignregeln

```text
ORGANIC_UNIT != MISSION_TASK_ORGANIZATION
SMALL_UNIT != LOW_COMPLEXITY
FIRE_SUPPORT_AVAILABLE != FIRE_SUPPORT_CLEARED
CAS_ON_STATION != CAS_EFFECTIVE
IED_FOUND != ROUTE_SAFE
CLEARANCE_COMPLETE != AREA_SECURE
PARTNER_PRESENT != PARTNER_CAPABLE
LOCAL_PROJECT != STABILITY_EFFECT
```

## 12. OMW-Implementierungsfelder

```yaml
small_unit_operation:
  organic_strength:
  attached_enablers:
  partner_force:
  terrain_restriction:
  route_ied_risk:
  observation_quality:
  fires_available:
  fires_clearance_state:
  cas_state:
  medical_capacity:
  resupply_state:
  extraction_state:
  local_support:
  local_fear:
  mission_duration_planned:
  mission_duration_actual:
```

## 13. Querverweise

- `docs/49-msr-routendesign-und-infrastrukturmarker.md`
- `docs/56-insurgent-factions-shadow-governance-and-red-commander-behavior.md`
- `docs/58-eastern-afghanistan-network-operations-and-complex-attack-model.md`
- `docs/62-insurgent-control-intelligence-ttp-and-coin-ipb.md`
- `docs/65-stability-operations-prt-interagency-and-district-framework.md`
- `docs/67-afghanistan-route-clearance-counter-ied-and-convoy-design.md`
- `docs/68-kandahar-city-and-dand-operational-environment-2010.md`
- `docs/74-wanat-tf-bayonet-tf-rock-force-posture-2007-2008.md`
