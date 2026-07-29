---
document_id: OMW-BLUE-NTMA-SFA-ATN-STRATCOM-LOCAL-INFLUENCE
status: BINDING
document_class: SOURCE_CRITICAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified NTM-A/CSTC-A organizational context
  - source-qualified Security Force Assistance design principles
  - source-qualified Attack the Network and C-IED campaign logic
  - NATO/ISAF Strategic Communication objectives and effects for 2011
  - local influence-network and tribal-engagement constraints
  - post-period HTS and SFA material as qualified continuity evidence
not_authoritative_for:
  - active OMW ORBAT or player slots
  - exact 2010/2011 HTS site inventory
  - deterministic tribal, ethnic, religious or cultural allegiance
  - automatic target authorization or lethal action
  - republication of FOUO or distribution-restricted source material
  - runtime acceptance of MOOSE implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghan-air-wars-source-integration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# NTM-A/CSTC-A, Security Force Assistance, Attack the Network, StratCom und lokale Einflussnetzwerke

## 1. Zweck

Dieses Dokument führt sieben Quellen zu einer gemeinsamen, quellenkritischen Referenz für BLUE-Commander-, CampaignState- und Missionsdesign zusammen:

- NTM-A/CSTC-A Task Organization, 17. Januar 2012;
- *Afghan Tribal Structure Versus Iraqi Tribal Structure*, Human Terrain System, 26. September 2008;
- Human Terrain System Afghanistan Map, 3. April 2012;
- NATO/ISAF Strategic Communications Framework 2011;
- JIEDDO *Attack the Network Field Guide – Afghanistan*, April 2011;
- ISAF *Security Force Assistance Guide*, April 2013;
- DIA *History of Afghanistan*, unklassifizierte Ausbildungspräsentation.

Die Quellen ergänzen Dokumente 37, 59, 61 und 62. Sie erzeugen keine neue BLUE- oder RED-Fraktion.

## 2. Quellenhierarchie und Zeitbezug

| Quelle | Zeitbezug | Projektwert | Grenze |
|---|---:|---|---|
| NATO/ISAF Strategic Communications Framework | Februar 2011 | direkt zeitgenössisch, sehr hoch | politische/kommunikative Guidance, keine taktische ORBAT |
| JIEDDO Attack the Network Field Guide | April 2011, Erfahrungen 2007–2010 | direkt zeitgenössisch, sehr hoch | Best-Practice-Guide, keine garantierte Wirkung |
| NTM-A/CSTC-A Task Organization | Januar 2012 | unmittelbare Nachperiode, hoch | kein exakter Organisationsstand für August 2010 |
| Afghan Tribal Structure vs Iraqi Tribal Structure | September 2008 | Vorperioden-Analyse, hoch | FOUO; keine lokale Istlage ohne Feldprüfung |
| HTS Afghanistan Map | April 2012 | Nachperioden-Standortreferenz, mittel | kein Beleg für 2010/2011-Bestand |
| ISAF SFA Guide | April 2013 | post-periodische Synthese, hoch | keine direkte Lagebeschreibung 2010/2011 |
| DIA History of Afghanistan | Ausbildungsprodukt ohne Szenario-Spezifik | Hintergrund, mittel | keine Autorität für konkrete Einheiten, Stärken oder TTP |

Verbindliche Regeln:

```text
POST_PERIOD_STRUCTURE != IN_PERIOD_ORBAT
TRAINING_GUIDE != GUARANTEED_OUTCOME
TRIBAL_LABEL != COMMAND_HIERARCHY
MAP_LOCATION_2012 != CONFIRMED_LOCATION_2010_2011
STRATCOM_MESSAGE != OBJECTIVE_REALITY
```

## 3. NTM-A/CSTC-A Organisationskontext

Das Organigramm vom 17. Januar 2012 zeigt eine kombinierte Ausbildungs-, Aufbau-, Beratungs- und Unterstützungsorganisation unter COM NTM-A/CG CSTC-A.

### 3.1 Hauptelemente

- Chief of Staff;
- DCG NTM-A / DCG Operations;
- DCG CSTC-A / DCG Support;
- CJ1 bis CJ8;
- Staff Judge Advocate, Inspector General, Equal Opportunity, Surgeon, Public Affairs, Chaplain und Historian;
- Base Support Group, Kabul Regional Contracting Center und Task Force Security Force;
- DCOM Army;
- DCOM Police;
- DCOM Air;
- DCOM Special Operations;
- DCOM Special Operations Mobility;
- DCOM Institutional Support Command;
- Senior Afghan Office / Assistance Group;
- regionale Support Commands.

### 3.2 Regionale Support Commands

```text
RSC_WEST
RSC_SOUTHWEST
RSC_SOUTH
RSC_CAPITAL
RSC_NORTH
RSC_EAST
```

Für OMW sind diese Elemente keine zusätzlichen Kampfkommandos. Sie bilden abstrakte regionale Kapazitäten für:

- Ausbildung;
- Mentoring und Beratung;
- Infrastruktur;
- Logistik;
- Polizei- und Armeentwicklung;
- Luftstreitkräfteentwicklung;
- institutionelle Unterstützung;
- regionale Koordination.

### 3.3 Organisationsmodell

```yaml
TrainingMissionState:
  army_development_capacity: 0.0
  police_development_capacity: 0.0
  air_development_capacity: 0.0
  sof_development_capacity: 0.0
  institutional_support_capacity: 0.0
  regional_support:
    west: 0.0
    southwest: 0.0
    south: 0.0
    capital: 0.0
    north: 0.0
    east: 0.0
```

Das Organigramm differenziert Command Authority, Support und Administrative Control. OMW darf deshalb organisatorische Nähe nicht mit taktischer Befehlsgewalt gleichsetzen.

## 4. Security Force Assistance

### 4.1 Grunddefinition

SFA umfasst das Organisieren, Ausbilden, Ausrüsten, Aufbauen, Wiederaufbauen, Beraten und Unterstützen von Sicherheitskräften und ihren Institutionen.

```text
OTERA =
ORGANIZE
TRAIN
EQUIP
REBUILD_OR_BUILD
ADVISE_AND_ASSIST
```

### 4.2 Sechs SFA-Imperative

```text
UNDERSTAND_OPERATIONAL_ENVIRONMENT
PROVIDE_EFFECTIVE_LEADERSHIP
BUILD_LEGITIMACY
MANAGE_INFORMATION
ENSURE_UNITY_OF_EFFORT
SUSTAIN_THE_EFFORT
```

Die wichtigste Designfolge lautet:

```text
ANSF_CAPABILITY != ANSF_SUSTAINABILITY
```

Eine kurzfristig erfolgreiche, vollständig durch BLUE-Enabler getragene Operation beweist keine selbsttragende afghanische Fähigkeit.

### 4.3 By, with and through

```text
AFGHAN_LEAD
+
BLUE_ADVICE
+
BLUE_SAFETY_NET
+
SELECTIVE_ENABLERS
```

Der Advisor:

- kommandiert die afghanische Einheit nicht;
- berät und beeinflusst;
- vermittelt zwischen afghanischen und Koalitionsstrukturen;
- ermöglicht Zugang zu Support;
- bewertet Leistung und Grenzen;
- soll mit wachsender ANSF-Fähigkeit weniger sichtbar werden.

### 4.4 Erfolgskriterium

```text
ADVISOR_SUCCESS
!=
NUMBER_OF_BLUE_TASKS_COMPLETED

ADVISOR_SUCCESS
=
IMPROVEMENT_OF_ANSF_CAPABILITY_AND_INDEPENDENCE
```

Eine ausreichende afghanische Lösung ist für Entwicklung und Legitimität häufig wertvoller als eine perfekte BLUE-Lösung.

### 4.5 Advisor- und Partnerbeziehung

Rapport beruht auf:

```text
UNDERSTANDING
RESPECT
TRUST
```

Erforderliche Advisor-Eigenschaften:

- fachliche Kompetenz;
- Geduld;
- Empathie;
- kulturelle Anpassungsfähigkeit;
- Einfluss ohne formale Autorität;
- Kommunikations- und Verhandlungskompetenz;
- Fähigkeit, in Mehrdeutigkeit zu arbeiten.

Falsch ausgewählte Advisor können größeren Schaden verursachen als eine unbesetzte Advisor-Stelle.

### 4.6 Nachhaltigkeitsregel

```text
DO_NOT_BUILD_CAPABILITY
THAT_ANSF_CANNOT_OPERATE_OR_SUSTAIN
```

Ausrüstung, Verfahren und Organisation müssen zu:

- physischer Umgebung;
- Ausbildungsstand;
- technischer Fähigkeit;
- Logistik;
- Finanzierung;
- Personal;
- institutioneller Kapazität

passen.

### 4.7 SFA-Readiness

```yaml
ANSFReadiness:
  organization: 0.0
  personnel: 0.0
  leadership: 0.0
  training: 0.0
  equipment: 0.0
  logistics: 0.0
  maintenance: 0.0
  intelligence: 0.0
  communications: 0.0
  planning: 0.0
  force_protection: 0.0
  medical_support: 0.0
  air_support_access: 0.0
  local_legitimacy: 0.0
  advisor_dependency: 1.0
```

## 5. Insider-Threat-Modell als spätere Erweiterung

Der SFA Guide systematisiert ein nach unserem Zeitraum entwickeltes Modell:

```text
PREPARE
DETER
DETECT
RESPOND
RECOVER_AND_EXPLOIT
```

### 5.1 Verwendungsgrenze

Der Guide stammt aus 2013 und nutzt Erfahrungen bis 2012. Das Modell wird daher nur als post-periodische Designreferenz aufgenommen.

### 5.2 mögliche CampaignState-Felder

```text
partner_trust
partner_reliability
insider_threat_risk
cultural_friction
communication_quality
guardian_angel_readiness
shared_base_vulnerability
post_incident_cohesion
```

### 5.3 Ursachenklassen

```text
PERSONALLY_MOTIVATED
INSURGENT_MANIPULATED
CRIMINAL
UNKNOWN
```

OMW darf einen Insider-Angriff nicht automatisch als direkte RED-Steuerung werten.

## 6. Attack the Network

### 6.1 Dreieck des AtN-Ansatzes

```text
BUILD_RELATIONSHIPS
<-> GAIN_VALUABLE_INTELLIGENCE
<-> NEUTRALIZE_THE_ADVERSARY
```

Die drei Bereiche wirken zyklisch. Rein kinetische Maßnahmen ohne Beziehungen und Intelligence können das Netzwerk nur vorübergehend beeinträchtigen.

### 6.2 Beziehungen aufbauen

- negative Wirkungen eigener Operationen minimieren;
- lokalen Kontext verstehen;
- tatsächliche lokale Influencer bestimmen;
- Vertrauen durch verlässliche Handlungen aufbauen;
- häufig mit Bevölkerung und Einflussakteuren interagieren;
- KLEs vorbereiten, dokumentieren und fortsetzen;
- keine korrupten oder unrepräsentativen Akteure unbeabsichtigt stärken.

Verbindliche Regel:

```text
FORMAL_POSITION != ACTUAL_INFLUENCE
```

Mögliche lokale Einflussquellen:

- religiöse Autorität;
- Alter und persönliche Reputation;
- Land- oder Wasserzugang;
- medizinische Versorgung;
- wirtschaftliche Stellung;
- frühere Mujahedin-Rolle;
- Polizei- oder Regierungsfunktion;
- bewaffnete Zwangsmacht;
- Familien- und Heiratsnetzwerke.

### 6.3 Intelligence gewinnen

```text
COLLECT_HUMAN_TERRAIN
COLLECT_PATTERN_OF_LIFE
ANALYZE_NETWORK_IN_REAL_TIME
COLLECT_AND_EXPLOIT_WTI
IDENTIFY_MEASURES_OF_INFLUENCE
RETAIN_SHARE_TRANSFER_INTELLIGENCE
IDENTIFY_DRIVERS_OF_INSTABILITY
```

IED-Aufklärung umfasst nicht nur den Sprengsatz, sondern:

- Hersteller;
- Finanziers;
- Materialquellen;
- Transporteure;
- Cache-Betreiber;
- Spotter;
- Auslöser;
- Schutz- und Einflussnetzwerke;
- Rekrutierung;
- lokale passive oder aktive Unterstützung.

### 6.4 Neutralisierung

```text
PROVIDE_PHYSICAL_SECURITY
MINIMIZE_DRIVERS_OF_INSTABILITY
DISRUPT_NETWORK_WITH_INFORMATION_OPERATIONS
DISRUPT_ACTIVITIES_AND_SUPPLIES
CONDUCT_TARGETED_LETHAL_ACTIONS
```

Targeted Lethal Actions sind nur ein Element des Ansatzes und bleiben an ROE, Identifizierung und Target Authorization gebunden.

### 6.5 IED-Netzwerkmodell

```yaml
IEDNetwork:
  finance: 0.0
  recruitment: 0.0
  technical_expertise: 0.0
  precursor_access: 0.0
  component_supply: 0.0
  cache_capacity: 0.0
  emplacement_capacity: 0.0
  observation_capacity: 0.0
  command_and_control: 0.0
  local_support_active: 0.0
  local_support_passive: 0.0
  freedom_of_movement: 0.0
```

### 6.6 Missionsbewertung

Eine Route-Clearance-Mission ist nicht nur anhand gefundener IEDs zu bewerten.

```text
route_temporarily_opened
network_member_identified
cache_discovered
supply_route_disrupted
local_tip_received
pattern_updated
civilian_harm_avoided
ANSF_leadership_improved
```

## 7. Key Leader Engagement

Der AtN Guide beschreibt KLE als zyklischen Prozess:

```text
JIPOE
-> IDENTIFY_KEY_LEADER
-> DEFINE_DESIRED_EFFECT
-> PREPARE
-> EXECUTE
-> DEBRIEF_AND_REPORT
-> REENGAGE
```

Jeder KLE-Eintrag sollte enthalten:

```text
actor_id
formal_role
actual_influence
influence_basis
relationships
reliability
agenda
commitments
commitment_status
last_engagement
next_engagement
protection_risk
```

Versprechen, die BLUE nicht erfüllen kann, reduzieren Vertrauen stärker als ein frühzeitiges, klares Nein.

## 8. Lokale Einflussnetzwerke statt vereinfachter Stammeshierarchie

Die HTS-Studie warnt ausdrücklich vor einer direkten Übertragung irakischer Tribal-Engagement-TTPs auf Afghanistan.

### 8.1 Verbindliche Regeln

```text
TRIBE != COMMAND_STRUCTURE
ELDER != AUTOMATIC_GROUP_CONTROLLER
TRIBAL_IDENTITY != POLITICAL_LOYALTY
TRIBAL_MAP != CURRENT_POWER_MAP
```

Paschtunische kollektive Handlung wird in der Studie stärker über wechselnde lokale Solidaritäts-, Patronage- und Einflussnetzwerke erklärt als über eine starre, von oben nach unten befehlende Stammeshierarchie.

### 8.2 Local Influence Graph

```yaml
LocalActor:
  identity_tags: []
  formal_roles: []
  influence_bases: []
  allies: []
  rivals: []
  patronage_links: []
  coercive_capacity: 0.0
  economic_capacity: 0.0
  religious_authority: 0.0
  dispute_resolution_role: 0.0
  population_trust: 0.0
  government_access: 0.0
  red_access: 0.0
```

Identitätsmerkmale sind Kontext, keine automatische Verhaltenslogik.

## 9. Human Terrain System Map 2012

Die Karte zeigt eine post-periodische Verteilung von HTS-/Research-Elementen und weist unter anderem Bezüge zu Bagram, Kabul, Jalalabad, FOB Shank, Salerno/Khost, Kandahar, Tarin Kowt, Camp Bastion, Lashkar Gah, Herat und Shindand auf.

Verwendung:

- Lead für mögliche Cultural-Analysis- und HTS-Supportknoten;
- Vergleich mit Basen- und Regional-Command-Struktur;
- Hinweis auf räumliche Prioritäten späterer Human-Terrain-Unterstützung.

Nicht zulässig:

```text
2012_HTS_MAP
-> automatic_2010_2011_location
```

Jeder Standort benötigt eine unabhängige zeitgenössische Bestätigung.

## 10. NATO/ISAF Strategic Communications Framework 2011

### 10.1 Ziele

- Stabilität Afghanistans als Bestandteil gemeinsamer Sicherheit erklären;
- Transition gemeinsam mit GIRoA erklären und unterstützen;
- Unterstützung der afghanischen Bevölkerung, GIRoA, TCN-Bevölkerungen und internationalen Gemeinschaft gewinnen;
- langfristige NATO-Verpflichtung kommunizieren;
- Fortschritt anhand von theaterdefinierten Measures of Effect kommunizieren;
- Unterstützung für Insurgenten und schädliche kriminelle Patronagenetzwerke reduzieren.

### 10.2 Kernthemen

```text
RESOLVE
MAINTAIN_MOMENTUM
PARTNERSHIP
AFGHAN_LEAD
ENDURING_COMMITMENT
```

### 10.3 Kampagnenwirkung

```text
TACTICAL_EVENT
-> VERIFIED_FACTS
-> NARRATIVE_CONSTRUCTION
-> AUDIENCE_RECEPTION
-> POPULATION_EFFECT
-> TCN_POLITICAL_EFFECT
-> CAMPAIGN_EFFECT
```

Eine Aussage über Fortschritt ist kein Beweis für tatsächlichen Fortschritt. CampaignState und StratComState bleiben getrennt.

```text
REPORTED_PROGRESS != VERIFIED_PROGRESS
MESSAGE_REACH != MESSAGE_ACCEPTANCE
MESSAGE_ACCEPTANCE != BEHAVIOR_CHANGE
```

### 10.4 StratComState

```yaml
StratComState:
  blue_message_consistency: 0.0
  blue_credibility: 0.0
  girOA_message_alignment: 0.0
  population_reach: 0.0
  population_acceptance: 0.0
  tcn_public_support: 0.0
  red_narrative_strength: 0.0
  criminal_network_legitimacy: 0.0
  transition_confidence: 0.0
```

## 11. DIA-Hintergrund: historische Tiefe und Geografie

Die DIA-Präsentation ordnet Afghanistan als Schnittstelle, Pufferraum und Einflusszone verschiedener regionaler Mächte ein. Für OMW verwertbar sind vor allem:

- starke Bedeutung von Geografie und Verkehrsachsen;
- wiederkehrende Spannung zwischen Kabul und Peripherie;
- regionale statt ausschließlich nationale Identitäten;
- lange Erfahrung mit externer Einflussnahme;
- historische Gewalt- und Staatsbildungszyklen;
- Notwendigkeit, lokale Geschichte in KLE, SFA und Intelligence einzubeziehen.

Nicht übernommen werden vereinfachende Narrative, nach denen Geografie allein unvermeidlich ein bestimmtes politisches Ergebnis produziert.

## 12. BLUE-Commander-Entscheidungslogik

```text
ASSESS_LOCAL_NETWORK
-> IDENTIFY_REAL_INFLUENCERS
-> BUILD_RELATIONSHIPS
-> COLLECT_AND_VALIDATE_INTELLIGENCE
-> SELECT_LETHAL_AND_NONLETHAL_ACTIONS
-> EXECUTE_WITH_ANSF
-> ASSESS_TACTICAL_AND_NARRATIVE_EFFECT
-> TRANSFER_LESSONS
-> REASSESS
```

Der BLUE Commander soll vermeiden:

- IED-Bekämpfung nur auf Detektion zu reduzieren;
- den sichtbarsten Amtsträger automatisch als wichtigsten Akteur anzunehmen;
- kurzfristige BLUE-Leistung mit ANSF-Entwicklung zu verwechseln;
- Informationen bei RIP/TOA zu verlieren;
- unerfüllbare Versprechen zu geben;
- ein taktisches Ereignis kommunikativ zu überzeichnen;
- irakische oder andere externe Tribal-TTPs schematisch zu übertragen.

## 13. Missionsmuster

### 13.1 Attack the Network

```text
NETWORK_MAPPING_PATROL
KLE_INFLUENCE_ASSESSMENT
IED_SUPPLY_CHAIN_INTERDICTION
CACHE_EXPLOITATION
WTI_COLLECTION
LOCAL_SOURCE_PROTECTION
NIGHT_PATTERN_PATROL
NETWORK_FINANCE_DISRUPTION
```

### 13.2 SFA

```text
ANSF_LED_PATROL_WITH_ADVISORS
ADVISOR_TEAM_RESUPPLY
ANSF_STAFF_PLANNING_SUPPORT
POLICE_PROFESSIONALIZATION
AIR_SUPPORT_REQUEST_TRAINING
MEDEVAC_ACCESS_EXERCISE
LOGISTICS_AND_MAINTENANCE_ASSESSMENT
```

### 13.3 StratCom

```text
POST_OPERATION_FACT_CONFIRMATION
CIVCAS_RESPONSE
TRANSITION_MESSAGING
LOCAL_RADIO_ENGAGEMENT
RUMOR_CONTROL
PUBLIC_SHURA_SUPPORT
RED_PROPAGANDA_COUNTERACTION
```

## 14. Verbindliche Designentscheidungen

1. NTM-A/CSTC-A wird als Ausbildungs-, Aufbau- und Supportsystem modelliert, nicht als zusätzliche Kampf-ORBAT.
2. SFA-Erfolg bemisst sich an ANSF-Entwicklung und Nachhaltigkeit.
3. Attack the Network verbindet Beziehungen, Intelligence und Neutralisierung.
4. IED-Bekämpfung beginnt vor der Verlegung des Sprengsatzes.
5. Lokale Macht wird als Netzwerk und nicht als starre Stammeshierarchie modelliert.
6. StratCom-Wirkung bleibt von tatsächlicher Operationswirkung getrennt.
7. 2012-/2013-Quellen werden als post-periodische Synthese oder Kontinuitätsreferenz gekennzeichnet.
8. FOUO-/REL-Quellen werden nicht vollständig publiziert.
9. Keine Quelle ändert Dokument 19 oder autorisiert neue Ziele.
10. Vor technischer Eigenentwicklung gilt MOOSE-First.

## 15. Offene Aufgaben

- [ ] NTM-A/CSTC-A-Struktur gegen zeitgenössische 2010- und 2011-Organigramme prüfen.
- [ ] RSC-Zuständigkeiten mit regionalen Basen und ANSF-Strukturen verknüpfen.
- [ ] HTS-Standorte 2010/2011 einzeln verifizieren.
- [ ] CampaignState-Felder für Einflussgraph, SFA und StratCom harmonisieren.
- [ ] AtN-Intelligence- und WTI-Prozess mit Dokument 62 zusammenführen.
- [ ] Insider-Threat-Mechanik als optionale spätere Erweiterung spezifizieren.
- [ ] MOOSE-First-Prüfung für Tasking, Events, Detection und Scoring durchführen.

## 16. Quellenverweise

- `NTM-A-OrgChart.pdf`, Task Organization, Stand 17. Januar 2012.
- `USArmy-AfghanTribalStructure.pdf`, Human Terrain System Research Reachback Center, 26. September 2008.
- `USArmy-HTS-Map-2012.pdf`, Human Terrain System, Stand 3. April 2012.
- `NATO-STRATCOM-Afghanistan.pdf`, SG(2011)0071 / IMSM-0093-2011, Februar 2011.
- `JIEDDO-ATN-FieldGuide.pdf`, Version 1, April 2011.
- `ISAF-SecurityForceAssistance.pdf`, HQ ISAF, April 2013.
- `DIA-AfghanHistory.pdf`, DIA Directorate for Human Capital, unklassifizierte Ausbildungspräsentation.

## 17. Querverweise

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-COIN-ASSESSMENT-TRANSITIONS-NONSTATE-SECURITY`](59-campaign-assessment-operational-transitions-and-nonstate-security.md)
- [`OMW-COIN-GOVERNANCE-STRATEGY-TRANSITION`](61-coin-governance-strategy-and-afghan-led-transition.md)
- [`OMW-RED-CONTROL-INTELLIGENCE-TTP-COIN-IPB`](62-insurgent-control-intelligence-ttp-and-coin-ipb.md)
