---
document_id: OMW-HIST-US-ARMY-OEF-COMMAND-FORCE-POSTURE-2001-2005
status: BINDING
document_class: SOURCE_CRITICAL_HISTORICAL_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical US Army command evolution, force posture and ORBAT from October 2001 through September 2005
  - historical basing, PRT, ANA-training, logistics and campaign-transition patterns
  - pre-period institutional and operational context for OMW
not_authoritative_for:
  - active OMW ORBAT
  - exact 2010-2011 strengths or locations
  - current DCS implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/afghanistan-aip-kaia-lop
source_commit: 0a70f9f9dffc69961cb0e93c2c3fc0d62a0a78e0
supersedes: []
superseded_by: []
validated_in_dcs: false
---

# US Army OEF Command, Force Posture and ORBAT 2001–2005

## 1. Quelle

Grundlage ist *A Different Kind of War: The United States Army in Operation ENDURING FREEDOM, October 2001–September 2005*. Die offizielle CSI-Gesamtdarstellung enthält eine chronologische Kampagnengeschichte, Kommandoentwicklungen, Truppenstärken, Basen, PRT-/ANA-Entwicklung und Appendix A mit Army Order of Battle.

Die Quelle ist pre-period und wird nicht zur direkten Festlegung der OMW-ORBAT verwendet.

## 2. Kampagnenentwicklung

### Phase 1 – Regimewechsel 2001

- SOF und indigene Partner;
- Airpower als Hauptwirkungsmittel;
- regionale Basen und Lines of Communication;
- humanitäre Luftabwürfe;
- Objective Rhino/Gecko;
- Mazar-e Sharif, Kabul, Tarin Kowt, Kandahar und Tora Bora.

### Phase 2 – Operation ANACONDA und Übergang 2002

- CJTF Mountain;
- TF Rakkasan;
- Integration konventioneller Kräfte;
- Air Assault, CAS, Attack Aviation und Fires;
- anschließend Übergang zu Stabilisierung.

### Phase 3 – CJTF-180, 2002–2003

- corps-level headquarters;
- Security Operations;
- Reconstruction;
- Joint Regional Teams/PRTs;
- Afghan National Army;
- Intelligence und Detainee Operations.

### Phase 4 – CFC-A und formale COIN-Ausrichtung, 2003–2004

- theater-strategic headquarters;
- synchronisierte politische und militärische Linien;
- dezentralere Präsenz;
- Embedded Training Teams;
- Governance und Reconstruction.

### Phase 5 – CJTF-76, 2004–2005

- wachsende insurgent threat;
- Regional Commands;
- PRT expansion;
- ANA/ANP development;
- elections;
- increasing distributed basing.

## 3. Truppenstärken

Die Quelle beschreibt:

- bis Mitte 2002 weniger als 10.000 US-Soldaten im Land;
- Konzentration vor allem auf Bagram und Kandahar;
- Wachstum bis ungefähr 16.000 US-Army-Soldaten im Jahr 2005;
- zusätzliche Combat-, Aviation-, Logistics- und Trainingselemente;
- gleichzeitige Economy-of-Force-Rahmenbedingung wegen Irak.

```text
TROOP_LEVEL_TOTAL != LOCALLY_AVAILABLE_MANEUVER_FORCE
FORCE_GROWTH != PROPORTIONAL_AREA_CONTROL
LARGE_BASE_POPULATION != FIELD_PRESENCE
```

## 4. Kommandoentwicklung

```text
JOINT_SPECIAL_OPERATIONS_TASK_FORCES
  -> CJTF_MOUNTAIN
  -> CJTF_180
  -> CFC_A + CJTF_180/76
  -> REGIONAL_COMMAND_STRUCTURE
```

Bedeutung:

- wachsender Stab wegen größerer politischer, militärischer und interagency Aufgaben;
- Trennung von theater-strategischer Synchronisierung und taktischer Führung;
- zunehmende Koordination mit ISAF und afghanischen Institutionen.

## 5. Basen und Lines of Communication

Wichtige Knoten:

- Karshi-Khanabad/K2;
- Bagram Airfield;
- Kandahar Airfield;
- Kabul;
- Gardez;
- Khost;
- Jalalabad;
- regionale Firebases und PRT-Standorte.

Bagram und Kandahar bildeten frühe Großbasen. Später verlagerten sich Kräfte in kleinere Basen und in Bevölkerungsnähe.

```text
MAIN_OPERATING_BASE
  -> REGIONAL_HUB
  -> FOB
  -> FIREBASE_OR_COP
  -> PATROL_AND_LOCAL_ENGAGEMENT
```

Die Verlagerung erhöhte:

- lokale Reaktionsfähigkeit;
- Intelligence-Zugang;
- Partnerkontakt;

aber auch:

- Force-Protection-Bedarf;
- Convoy- und Airlift-Abhängigkeit;
- Medical- und Recovery-Risiko;
- Kommunikationslast.

## 6. Operation ANACONDA – Task Organization

Die Quelle dokumentiert CJTF Mountain, TF Rakkasan, TF Summit, TF Commando und SOF-Elemente sowie die schrittweise Verstärkung. Einheiten waren teilweise durch andere Aufträge gebunden; beispielsweise standen nicht alle organischen Companies für den Hauptangriff zur Verfügung.

```text
BATTALION_ASSIGNED != ALL_COMPANIES_AVAILABLE
TASK_FORCE_NAME != FIXED_ORGANIZATION
RESERVE_DESIGNATED != RESERVE_UNCOMMITTED
```

## 7. Army Aviation

Relevante Rollen:

- CH-47 Heavy Lift und Hochgebirge;
- UH-60 Air Assault/Utility;
- AH-64 Attack Aviation;
- MEDEVAC;
- resupply;
- PRT support;
- command movement.

Der CH-47 wird als Army Workhorse hervorgehoben. Für OMW:

```text
HEAVY_LIFT_AVAILABLE != WEATHER_CLEAR
LIFT_CAPACITY_NOMINAL != HIGH_ALTITUDE_PAYLOAD
AIR_ASSAULT_COMPLETE != GROUND_FORCE_SUSTAINED
```

## 8. Logistics

Frühe Operationen benötigten:

- regionalen strategic airlift;
- K2 und weitere Zwischenbasen;
- fuel;
- water;
- maintenance;
- communications;
- medical support;
- ground LOCs;
- aerial resupply.

Spätere Full-Spectrum Operations erforderten Support Battalions und dauerhaftes PRT-/FOB-Sustainment.

Empfohlene Zustände:

```yaml
base_support:
  fuel_days:
  water_days:
  ammunition_days:
  food_days:
  medical_capacity:
  maintenance_capacity:
  airlift_access:
  ground_route_access:
  communications_state:
```

## 9. PRT-Entwicklung

Joint Regional Teams entwickelten sich zu Provincial Reconstruction Teams. Allgemeine Struktur:

- military security and command;
- civil affairs;
- State/USAID beziehungsweise zivile Vertreter;
- engineering/project management;
- liaison with provincial government.

Die Quelle beschreibt PRTs als wichtige, aber ungleichmäßig wirksame Innovation.

```text
PRT_PRESENT != PROVINCE_STABLE
PROJECT_COUNT != GOVERNANCE_EFFECT
INTERAGENCY_STAFFED != INTERAGENCY_SYNCHRONIZED
```

## 10. ANA-Aufbau

Entwicklung:

- Kabul Military Training Center;
- Office of Military Cooperation-Afghanistan;
- CJTF Phoenix;
- Recruiting;
- Basic Training;
- Equipment;
- facilities;
- Embedded Training Teams;
- regional commands.

Bewertungsfelder:

- recruitment;
- retention;
- ethnic balance;
- leader quality;
- equipment serviceability;
- mentor coverage;
- operational readiness;
- sustainment independence.

```text
TRAINED != OPERATIONALLY_READY
EQUIPPED != MAINTAINABLE
KANDAK_PRESENT != KANDAK_SELF_SUSTAINING
```

## 11. Intelligence und Detainee Operations

Die Kampagne litt an:

- unvollständiger Enemy Order of Battle;
- Wechsel von konventionellem Gegner zu Netzwerken;
- begrenztem HUMINT;
- kulturellen und sprachlichen Lücken;
- Übergabeproblemen zwischen rotierenden Verbänden;
- kontroversen Detainee-Praktiken.

OMW-Modell:

```text
REPORT
  -> SOURCE_EVALUATION
  -> CORROBORATION
  -> NETWORK_UPDATE
  -> COLLECTION_TASK
  -> OPERATION
  -> EXPLOITATION
```

## 12. SOF und Conventional Integration

Frühe SOF-/Airpower-Wirkung wurde später durch konventionelle Präsenz, Security Operations und Partnering ergänzt. Reibungspunkte:

- command relationships;
- information sharing;
- airlift scarcity;
- differing time horizons;
- deconfliction;
- transition of border firebases.

## 13. Regional Commands 2005

Die Quelle zeigt die schrittweise Regionalisierung. RC-South und RC-East bestanden ab 2004; bis September 2005 war eine Regional-Command-Struktur dokumentiert. Dies ist Vorläufer der 2010/2011-ISAF-Struktur, aber kein identischer Snapshot.

## 14. Appendix-A-Nutzung

Appendix A wird als Army-ORBAT 2001–2005 behandelt. Datensätze sind stets mit Zeitraum zu speichern:

```yaml
orbat_record:
  unit:
  parent:
  role:
  location:
  date_from:
  date_to:
  source_page:
  confidence:
```

Keine Einheit aus Appendix A wird ohne weitere 2010/2011-Quelle in die aktive ORBAT übernommen.

## 15. Strategische Lessons

```text
REGIME_REMOVED != ENEMY_NETWORK_DESTROYED
INITIAL_SUCCESS != ENDURING_STABILITY
SMALL_FOOTPRINT != LOW_SUPPORT_REQUIREMENT
COMMAND_REORGANIZATION != IMMEDIATE_FIELD_EFFECT
TRAINING_FORCE != SELF_SUSTAINING_FORCE
RECONSTRUCTION_ACTIVITY != POLITICAL_LEGITIMACY
```

## 16. OMW-Anwendung

Diese Quelle dient als:

- Ursprungslinie für Kommando- und Regionalstruktur;
- historische Baseline für Bagram/Kandahar und verteilte Basen;
- Vergleichsrahmen für 2010/2011-Truppenwachstum;
- Architekturquelle für PRT, ANA mentoring, logistics und SOF/conventional integration.

## 17. Querverweise

- `docs/50-afghanistan-force-basing-aviation-2010-2011.md`
- `docs/55-monthly-coalition-orbat-and-basing-2010-2011.md`
- `docs/61-coin-governance-strategy-and-afghan-led-transition.md`
- `docs/63-ntma-sfa-attack-the-network-stratcom-and-local-influence.md`
- `docs/65-stability-operations-prt-interagency-and-district-framework.md`
- `docs/77-arsof-sof-aviation-and-early-oef-operational-models.md`
