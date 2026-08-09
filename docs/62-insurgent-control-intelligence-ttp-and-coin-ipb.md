---
document_id: OMW-RED-CONTROL-INTELLIGENCE-TTP-COIN-IPB
status: BINDING
document_class: SOURCE_CRITICAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified RED local-control and shadow-governance progression
  - RED intelligence collection, pattern-learning and knowledge-decay model
  - source-qualified insurgent TTP selection and mission-pattern design
  - COIN IPB, ASCOPE3xD and insurgent-strategy assessment requirements
  - historical use of Lor Koh and Islam Dara as candidate terrain and network nodes
  - source-qualified suicide-attack and complex-attack capability gates
not_authoritative_for:
  - active OMW ORBAT or exact RED force strength
  - automatic DCS spawning from historical incident counts
  - target authorization, ROE or No-Strike-List decisions
  - deterministic ethnic, tribal, religious or cultural allegiance
  - release or republication of source documents carrying distribution restrictions
  - runtime acceptance of any MOOSE implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghan-air-wars-source-integration
source_commit: a36132276bc0986ed4e4085a6ebe5e3e980b5db9
validated_in_dcs: false
---

# Insurgenten-Kontrolle, Aufklärung, TTP und COIN-IPB

## 1. Zweck

Dieses Dokument überführt die für Operation Mountain Watch verwertbaren Inhalte einer Quellencharge aus zeitgenössischen US-Army-, USMC-, MCIA-, NGIC- und CTC-A-Unterlagen in eine gemeinsame, quellenkritische Designreferenz.

Der Schwerpunkt liegt auf:

1. der schrittweisen Entstehung lokaler insurgenter Kontrolle;
2. RED-Aufklärung, HUMINT und Pattern Learning;
3. TTP-Auswahl für IED, Hinterhalt, indirektes Feuer, Raid und komplexen Angriff;
4. COIN-IPB und ASCOPE3xD als BLUE-Planungs- und Informationsmodell;
5. konkreten historischen Gelände- und Basenreferenzen;
6. einer sauberen Trennung zwischen Quellenbefund, Designableitung und Runtime-Implementierung.

Verbindlich bleibt:

```text
1 konsolidierter RED Commander
1 gemeinsamer REDState
1 gemeinsamer RED-Ressourcenpool
```

Die Quellen beschreiben unterschiedliche historische Organisationen, Netzwerke und Operationsräume. Für die OMW-Grundversion werden daraus keine zusätzlichen Runtime-Fraktionen erzeugt.

## 2. Quellen und Verwendungsgrenzen

### 2.1 Hauptquellen

| Datei/Quelle | Datum | Quellenklasse | OMW-Verwendung |
|---|---:|---|---|
| `AfghanInsurgentControl.pdf`, U.S. Army NGIC, *Afghanistan: Mechanisms of Insurgent Local Control and Local Governance* | zeitgenössisch, vor/um 2010 | institutionelle analytische Studie | lokale Kontrolle, Compliance, Sanktion, Governance, beobachtbare Indikatoren |
| `USArmy-TalibanIntel.pdf`, TRISA, *Taliban Insurgent Syndicate Intelligence Operations* | November 2009 | militärisches Trainings-/Threat-Produkt | RED-HUMINT, IPB, Infiltration, Musterbeobachtung, Intelligence-Struktur |
| `USArmy-TalibanTTPs.pdf`, TRISA, *Taliban Top 5 Most Deadly Tactics, Techniques and Procedures* | Juni 2010 | militärisches Trainings-/Threat-Produkt | Bedrohungspriorisierung, Verlustursachen, TTP-Auswahl, regionale AO-Leads |
| `MCIA-InsurgentTTP.pdf`, *Afghan Insurgent Tactics, Techniques, and Procedures Field Guide* | Januar 2009 | MCIA-Feldführer mit historischen und neueren Vignetten | Hinterhalt, Raid, indirektes Feuer, Cordon/Search-Abwehr, lokale Unterstützung |
| `USArmy-AfghanSuicideAttacks.pdf`, TRISA, *Suicide Attacks: Afghanistan* | November 2010 | Ereignischronologie/Trainingsprodukt | BBIED/SVBIED, komplexe Angriffe, Ziele, Fehlschläge, regionale Muster |
| `USArmy-PakistanSuicideAttacks.pdf`, TRISA, *Suicide Attacks: Pakistan* | Januar 2011 | Ereignischronologie/Trainingsprodukt | externe Support-, Training- und Spezialisten-Dynamik; keine Pakistan-Missionen |
| `CTC-A-COIN-Guidebook.pdf`, *A Counterinsurgent's Guidebook* | November 2011 | zeitgenössischer COIN-Anwendungsleitfaden | COIN-IPB, ASCOPE3xD, PMESII-PT, Root Causes, ISAT, Clear-Hold-Build, SFA |
| `CACcoin.pdf`, US Army/USMC COIN Center, *Counterinsurgency Overview* | 17. Februar 2010 | zeitgenössisches Trainingsbriefing | COIN-Mindset, Governance Capacity Building, nichtlineare Operationsräume |
| `CACcoin2.pdf`, US Army/USMC COIN Center, *COIN Lessons Learned* | 17. Februar 2010 | zeitgenössisches Lessons-Learned-Briefing | Population Protection, ANSF-Partnering, dezentrale Führung, Ink-Spot-Ansatz |
| `MCIA-MujahedinBases.pdf`, *Afghanistan: Key Bases & Figures of the Mujahedin* | Februar 2009 | MCIA-Analystenreferenz | Lor Koh, Islam Dara, historische Basen, Gelände, Infiltration und Kontinuität |

### 2.2 Schutz- und Veröffentlichungsgrenzen

Mehrere Dokumente tragen FOUO-, REL- oder Distribution-Restriction-Hinweise. Deshalb gilt:

```text
SOURCE_MAY_BE_ANALYZED
!=
SOURCE_MAY_BE_REPUBLISHED
```

Im öffentlichen Repository werden nur:

- bibliografische Metadaten;
- paraphrasierte, projektbezogene Erkenntnisse;
- quellenkritische Bewertungen;
- eigenständig formulierte Designableitungen;
- notwendige, kurze Datenpunkte

aufgenommen. Vollständige Folien, Kartenserien, Tabellen oder lange wörtliche Passagen werden nicht reproduziert.

### 2.3 Quellenkritische Grundregeln

```text
TRAINING_PRODUCT != FINISHED_INTELLIGENCE
HISTORICAL_TTP != AUTOMATIC_2010_2011_BEHAVIOR
ESTIMATED_STRENGTH != RUNTIME_FORCE_COUNT
INCIDENT_COUNT != MISSION_SPAWN_RATE
CULTURAL_GENERALIZATION != CAMPAIGN_MODIFIER
HISTORICAL_BASE != CONFIRMED_OMW_OCCUPATION
```

## 3. Lokale Kontrolle: vom Zugang zur institutionalisierten Herrschaft

Die NGIC-Studie beschreibt lokale Kontrolle nicht als binären Zustand, sondern als Prozess.

### 3.1 Phase 1: Compliance erzeugen und Kontrolle etablieren

```text
IDENTIFY_SYMPATHIZERS
-> TRANSFORM_TO_COLLABORATORS
-> MONITOR_POPULATION
-> SELECT_OPPOSITION
-> SANCTION_OPPOSITION
-> SIGNAL_CONSEQUENCES
```

#### Sympathisanten identifizieren

Mögliche Zugänge entstehen über:

- Familie und Heirat;
- Nachbarschaft;
- Stamm und Unterstamm;
- religiöse Autoritäten;
- frühere Kampf- oder Patronagebeziehungen;
- lokale Rivalitäten;
- Benachteiligung schwächerer Gruppen;
- materielle oder politische Gegenleistungen.

Für OMW folgt:

```text
local_access != ideological_support
collaboration != loyalty
```

Ein lokaler Akteur kann aus Angst, Rivalität, persönlichem Vorteil, Schutzbedürfnis oder Opportunismus kooperieren.

#### Kollaborateure gewinnen

Verwertbare Anreize sind:

- gemeinsame Identität oder Erzählung;
- Aussicht auf Schutz;
- Zugang zu Ressourcen;
- zukünftiger lokaler Einfluss;
- Vergeltung gegen Rivalen;
- wirtschaftlicher Nutzen;
- Vermeidung eigener Sanktionierung.

#### Bevölkerung beobachten

Der RED Commander benötigt lokale Beobachter und Informanten, um zu unterscheiden:

```text
SUPPORTS_RED
SUPPORTS_GOVERNMENT
OPPORTUNISTIC
NEUTRAL_OR_UNCOMMITTED
FEARFUL_COMPLIANT
ACTIVE_OPPOSITION
UNKNOWN
```

Diese Zustände sind nicht dauerhaft und dürfen nicht allein aus ethnischen, religiösen oder Stammesmerkmalen abgeleitet werden.

#### Opposition auswählen und sanktionieren

Die Quelle beschreibt eine häufig eskalierende Abfolge:

```text
GENERAL_WARNING
-> SPECIFIC_WARNING
-> NIGHT_LETTER
-> PRIVATE_INTIMIDATION
-> PUBLIC_HUMILIATION_OR_BEATING
-> PROPERTY_DAMAGE_OR_CONFISCATION
-> KIDNAPPING
-> ASSASSINATION
```

OMW verwendet diese Leiter nur als Handlungsportfolio. Vor einer Eskalation bewertet RED:

```text
target_value
information_confidence
expected_deterrence
population_backlash_risk
blue_response_risk
network_exposure_risk
resource_cost
propaganda_effect
```

#### Glaubwürdigkeit und Vorhersehbarkeit

Die Kontrolle wächst, wenn die Bevölkerung glaubt, dass RED:

1. Aktivitäten relativ zuverlässig beobachten kann;
2. Opposition gezielt bestrafen kann;
3. nachvollziehbare Regeln und Folgen durchsetzt.

Verbindliche CampaignState-Felder:

```text
red_monitoring_capability
red_sanction_capability
red_threat_credibility
red_outcome_predictability
population_fear_of_red
population_compliance_red
population_support_red
local_opposition_visibility
```

Wichtig:

```text
POPULATION_COMPLIANCE_RED != POPULATION_SUPPORT_RED
```

### 3.2 Phase 2: Kontrolle institutionalisieren

Nach ausreichender Compliance kann RED Ressourcen von unmittelbarer Gewalt zu dauerhafter Kontrolle verlagern:

```text
PROPAGATE_KEY_MESSAGES
REGULATE_SOCIAL_INTERACTION
EXTRACT_RESOURCES
PROVIDE_SELECTIVE_BENEFITS
PROVIDE_COLLECTIVE_BENEFITS
```

Mögliche Auswirkungen:

- Schattenjustiz;
- Regeln für Bewegungen, Handel oder Zusammenarbeit;
- Besteuerung und Abgaben;
- Vermittlung lokaler Streitigkeiten;
- Schutz einzelner Gruppen;
- begrenzte Versorgung oder Infrastrukturhilfe;
- Informations- und Propagandaverbreitung.

Diese Funktionen werden in der Grundversion überwiegend als CampaignState-Ereignisse modelliert. Sie erzeugen nicht automatisch physische DCS-Gruppen.

## 4. Sektorales Kontrollmodell

### 4.1 Zustände

```text
NO_MEANINGFUL_RED_ACCESS
RED_CONTACTS_PRESENT
RED_MONITORING_NETWORK
RED_COMPLIANCE_BUILDING
RED_COERCIVE_CONTROL
RED_INSTITUTIONALIZING
RED_ESTABLISHED_LOCAL_CONTROL
RED_DISRUPTED
RED_RECONSTITUTING
```

### 4.2 Übergänge

Beispiel:

```text
NO_MEANINGFUL_RED_ACCESS
  + local_contact
  -> RED_CONTACTS_PRESENT

RED_CONTACTS_PRESENT
  + repeated_observation
  + collaborator_recruitment
  -> RED_MONITORING_NETWORK

RED_MONITORING_NETWORK
  + credible_sanction
  + low_blue_protection
  -> RED_COMPLIANCE_BUILDING

RED_COMPLIANCE_BUILDING
  + sustained_fear
  + weak_government_legitimacy
  -> RED_COERCIVE_CONTROL

RED_COERCIVE_CONTROL
  + resource_extraction
  + shadow_dispute_resolution
  -> RED_INSTITUTIONALIZING
```

BLUE kann den Prozess stören durch:

- Schutz gefährdeter lokaler Akteure;
- zuverlässige Präsenz;
- vertrauliche Meldemöglichkeiten;
- Gegenaufklärung;
- Cache- und Finanznetzwerkstörung;
- wirksame lokale Justiz;
- professionelle Polizei;
- glaubwürdige Reaktion auf Einschüchterung;
- Vermeidung ziviler Schäden und Missbrauchs.

## 5. RED Intelligence Operations

### 5.1 Grundsatz

Die TRISA-Unterlagen beschreiben HUMINT als besonders starke gegnerische Fähigkeit. Gleichzeitig bestanden keine einheitliche Führung und kein allwissendes gemeinsames Lagebild.

Für OMW gilt:

```text
RED_HAS_LOCAL_KNOWLEDGE
RED_DOES_NOT_HAVE_OMNISCIENCE
```

### 5.2 Informationsquellen

```text
LOCAL_OBSERVER
FAMILY_OR_TRIBAL_CONTACT
MARKET_CONTACT
RELIGIOUS_CONTACT
GOVERNMENT_OR_ANSF_INSIDER
BASE_OR_GATE_WATCHER
ROUTE_SPOTTER
DRIVER_OR_CONTRACTOR
CAPTURED_DOCUMENT_OR_EQUIPMENT
PROPAGANDA_OR_OPEN_REPORTING
POST_ATTACK_OBSERVATION
```

### 5.3 Wissenszustände

```text
UNKNOWN
RUMOR
OBSERVED_ONCE
PATTERN_SUSPECTED
PATTERN_CONFIRMED
RECENTLY_VERIFIED
STALE
COMPROMISED
DISPROVEN
```

Jeder Eintrag benötigt:

```text
source_type
source_reliability
information_confidence
first_observed
last_observed
sector_scope
decay_rate
compromise_risk
```

### 5.4 Lernbare BLUE-Muster

```text
patrol_route_pattern
convoy_schedule_estimate
route_clearance_cycle
checkpoint_manning_pattern
base_gate_routine
qrf_response_estimate
cas_response_estimate
medevac_response_estimate
helicopter_lz_pattern
isr_coverage_window
night_activity_pattern
common_search_method
```

Wissen muss altern. Ein bestätigtes Muster wird mit der Zeit unsicher, wenn BLUE Verfahren ändert oder gezielt Täuschung einsetzt.

### 5.5 Intelligence Preparation of the Battlefield

Vor höherwertigen Angriffen führt RED eine begrenzte eigene Vorbereitung durch:

```text
DEFINE_TARGET_EFFECT
-> OBSERVE_TARGET
-> MAP_SECURITY_ROUTINES
-> IDENTIFY_APPROACHES_AND_ESCAPE_ROUTES
-> TEST_REACTION
-> VERIFY_LOCAL_SUPPORT
-> ASSESS_AIR_AND_QRF_RESPONSE
-> AUTHORIZE_OR_ABORT
```

## 6. Bedrohungsprioritäten und TTP-Auswahl

Die TRISA-Verlustauswertung bis Mai/Juni 2010 zeigt IED/Explosive Devices als dominierende Ursache der betrachteten US-KIA und WIA. Die Werte sind zeit- und populationsgebunden, belegen aber eine klare Priorität.

```text
RED_PRIORITY_1 = IED_NETWORK
RED_PRIORITY_2 = SMALL_ARMS_AMBUSH
RED_PRIORITY_3 = RPG_OR_ANTI_VEHICLE_FIRE
RED_PRIORITY_4 = INDIRECT_FIRE
RED_PRIORITY_5 = HIGH_PROFILE_COMPLEX_ATTACK
```

Diese Prioritäten sind keine festen Häufigkeiten. TTP-Auswahl hängt ab von:

```text
target_type
terrain
civilian_presence
available_specialists
cache_access
network_security
blue_pattern_knowledge
airpower_expectation
escape_route_quality
propaganda_value
resource_cost
```

## 7. Hinterhaltsmodell

### 7.1 Auswahl des Hinterhaltsraums

```text
AMBUSH_SITE_SCORE =
  route_predictability
+ choke_point_value
+ terrain_dominance
+ concealment
+ interlocking_fire_potential
+ escape_route_quality
+ blue_reaction_delay
+ salvage_opportunity
- civilian_harm_risk
- persistent_isr_risk
- local_exposure_risk
```

### 7.2 Historisch belegte Prinzipien

Aus den MCIA-Vignetten:

- Konvoi vorher beobachten;
- wahrscheinlichen Rückweg bestimmen;
- Brücke, Furt oder Engstelle nutzen;
- Kolonne teilen;
- RPG/Recoilless Rifle nahe der Route einsetzen;
- schwere Waffen auf dominierendem Gelände platzieren;
- mehrere Feuerbereiche überlappen lassen;
- BLUE-Reserve binden oder ausschalten;
- Zeitpunkt so wählen, dass Luftunterstützung eingeschränkt ist;
- Exfiltration und Sammelpunkt vorbereiten;
- Beute- oder Waffenbergung nur bei vertretbarem Risiko.

### 7.3 Abbruchregeln

```text
IF blue_airpower_arrival_imminent
OR qrf_strength_exceeds_threshold
OR escape_route_compromised
OR civilian_harm_exceeds_limit
OR cell_leadership_lost
THEN withdraw_or_disperse
```

## 8. Raid- und Infiltrationsmodell

Historische Vignetten zeigen:

- getrennte Assault-, Support-, Blocking- und Evacuation-Elemente;
- lokale Kollaborateure innerhalb regierungsnaher Milizen;
- Insiderinformation über Ziel und Reaktion;
- Schwächen durch schlechte interne Kommunikation;
- zu große Gruppen aufgrund familiärer oder persönlicher Bindungen;
- hohe Bedeutung eines vorbereiteten Sammelpunkts.

OMW-Felder:

```text
cell_communications_quality
insider_penetration
local_access
blocking_element_readiness
evacuation_plan_quality
rally_point_security
force_size_discipline
```

## 9. Indirect Fire

### 9.1 Operationsmuster

```text
SURVEY_POSITION_BY_DAY
-> MOVE_WEAPON_AT_NIGHT
-> ESTABLISH_FORWARD_OBSERVER
-> FIRE_SHORT_MISSION
-> DISPLACE
```

Varianten:

- reverse-slope firing position;
- mobile firing base;
- vorbereitete unbemannte Abschussstelle;
- zeitverzögerter Start;
- lokaler Lasttier- oder Fahrzeugtransport.

### 9.2 Wirkung

```text
physical_damage
sleep_disruption
morale_effect
force_protection_burden
sortie_generation_disruption
patrol_diversion
perceived_base_vulnerability
```

Indirektes Feuer kann strategisch nützlich sein, obwohl der materielle Schaden gering bleibt.

## 10. Suicide Attack und Complex Attack

### 10.1 Historische Lieferformen

Die Afghanistan-Chronologie dokumentiert:

```text
BBIED
SVBIED
MOTORCYCLE_SVBIED
BICYCLE_SVBIED
RICKSHAW_SVBIED
UNIFORM_DISGUISE
BURQA_DISGUISE
GATE_BREACH
FOLLOW_ON_ASSAULT
MULTI_TARGET_COMPLEX_ATTACK
```

### 10.2 Typische Ziele

- Konvois;
- Basiseingänge;
- Polizei- und Militäranlagen;
- Regierungsgebäude;
- Ausbildungszentren;
- Märkte und Versammlungen;
- lokale Führungsfiguren;
- private Sicherheitsunternehmen;
- Logistik- und Versorgungseinrichtungen;
- ausländisch genutzte Unterkünfte.

### 10.3 Capability Gates

Komplexe oder selbstmordgestützte Angriffe gehören nicht zum alltäglichen RED-MVP. Voraussetzungen:

```text
target_value >= HIGH
intelligence_quality >= HIGH
specialist_access = true
network_security >= MEDIUM
staging_access = true
delivery_platform_available = true
propaganda_value >= HIGH
acceptable_resource_loss = true
final_authorization = true
```

### 10.4 mögliche Ergebnisse

```text
ABORTED
INTERCEPTED_BEFORE_STAGING
INTERCEPTED_AT_CHECKPOINT
PREMATURE_DETONATION
FAILED_BREACH
PARTIAL_BREACH
SUCCESSFUL_BREACH
FOLLOW_ON_ASSAULT_FAILED
FOLLOW_ON_ASSAULT_SUCCESSFUL
```

Die Chronologie enthält viele vereitelte oder wirkungsarme Angriffe. Deshalb darf kein Angriff automatisch sein Ziel erreichen.

### 10.5 Datenverwendung

Historische Einzelereignisse werden erfasst als:

```text
HISTORICAL_INCIDENT_REFERENCE
```

Sie sind keine automatische Spawnliste und keine Vorgabe, reale Orte erneut als Ziele zu verwenden.

## 11. Externe Support- und Sanctuary-Dynamik

Die Pakistan-Chronologie und Intelligence-Unterlagen stützen virtuelle externe Faktoren:

```text
external_training_pressure
external_specialist_availability
external_finance_access
external_explosives_access
cross_border_facilitation
external_network_disruption
```

Diese Faktoren beeinflussen RED-Fähigkeiten innerhalb Afghanistans. Sie erzeugen keine physische Pakistan-Karte und keine grenzüberschreitenden Spielermissionen außerhalb des DCS-Theaters.

## 12. Historische Basen und Gelände

### 12.1 Lor Koh / Sharafat Koh

Die MCIA-Quelle nennt:

```text
32°31'29"N
062°41'22"E
```

Quellenangaben:

- ungefähr 30 km südöstlich von Farah;
- ungefähr 12 km von Highway 1;
- ungefähr 20 km von Highway 517;
- Plateau etwa 1.500 m über dem Wüstenboden;
- mehrere tiefe Canyons;
- historische Konvoiangriffe in der Umgebung;
- Wasser, Vegetation und geschützte Innenräume in einzelnen Tälern.

Kale-e Kaneske Canyon wird als besonders enger, tief eingeschnittener und teilweise gegen Beobachtung von oben geschützter Raum beschrieben.

OMW-Klassifikation:

```text
historical_base_confirmed = true
omw_2010_2011_red_occupation = unconfirmed
coordinate_status = source_reported_requires_validation
```

Mögliche spätere Nutzung:

```text
RED_HISTORICAL_BASE_AREA
RED_CACHE_COMPLEX
RED_TRAINING_AREA
RED_REGENERATION_NODE
RED_MOUNTAIN_HIDE_SITE
```

### 12.2 Islam Dara

Die Quelle beschreibt Islam Dara im Raum Khakrez/nördliches Kandahar als historische Unterstützungs- und Trainingsbasis mit schwer zugänglichem Gelände und potenzieller Wiederverwendung durch spätere Netzwerke.

OMW-Klassifikation:

```text
historical_base_confirmed = true
exact_omw_location = requires_georeferencing
omw_2010_2011_red_occupation = unconfirmed
```

### 12.3 Verifikationsworkflow

```text
SOURCE_LOCATION
-> validate_coordinate_or_map
-> compare_with_historical_imagery
-> compare_with_OMW_location_registry
-> inspect_DCS_terrain
-> classify_physical_or_virtual_node
-> authorize_for_mission_use
```

## 13. COIN-IPB

Das CTC-A-Guidebook beschreibt einen wiederholten Planungsprozess:

```text
DEFINE_OPERATIONAL_ENVIRONMENT
-> DESCRIBE_ENVIRONMENT_EFFECTS
-> EVALUATE_PREREQUISITES_AND_ROOT_CAUSES
-> EVALUATE_INSURGENT_STRATEGY
-> DETERMINE_COURSES_OF_ACTION
-> EXECUTE
-> REASSESS
```

### 13.1 ASCOPE3xD

Kategorien:

```text
AREAS
STRUCTURES
CAPABILITIES
ORGANIZATIONS
PEOPLE
EVENTS
```

Perspektiven:

```text
POPULATION
INSURGENT
COUNTERINSURGENT
```

Vorgeschlagenes Sektormodell:

```yaml
SectorAssessment:
  ascope:
    areas: []
    structures: []
    capabilities: []
    organizations: []
    people: []
    events: []
  perspectives:
    population: {}
    red: {}
    blue: {}
```

### 13.2 Erhebungsmethoden

- Fußpatrouillen mit spezifischem Informationsauftrag;
- Key Leader Engagements;
- Census Operations;
- Tactical Questioning;
- Patrol Debriefs;
- ISR;
- gegnerische Propaganda;
- Übergabeinformationen vorheriger Einheiten;
- offene Quellen und Lagekarten.

Eine Patrouille ist damit nicht nur erfolgreich, weil sie einen Wegpunkt erreicht. Sie kann als Informationsmission bewertet werden:

```text
new_contacts_identified
assumptions_confirmed_or_denied
route_pattern_updated
population_perception_updated
insurgent_indicator_detected
source_reliability_improved
```

### 13.3 PMESII-PT

Auf operativer Ebene werden ASCOPE-Daten in breitere Variablen eingeordnet:

```text
POLITICAL
MILITARY
ECONOMIC
SOCIAL
INFORMATION
INFRASTRUCTURE
PHYSICAL_ENVIRONMENT
TIME
```

## 14. BLUE-Commander-Anforderungen

### 14.1 Population Protection und Partnerschaft

Die CAC-Unterlagen betonen:

- Kräfte zum Schutz der Bevölkerung ausrichten;
- Operationen mit afghanischen Kräften durchführen;
- dauerhafte Präsenz und Kontakt aufbauen;
- untergeordnete Führer mit Intelligence, Logistik, Guidance und Authority ausstatten;
- gesicherte Räume schrittweise erweitern;
- Insurgenten von Bevölkerung und Ressourcen isolieren.

### 14.2 Dezentrale Ausführung

```text
CENTRALIZED_CAMPAIGN_INTENT
+
DECENTRALIZED_TACTICAL_EXECUTION
+
SHARED_INFORMATION
+
CLEAR_AUTHORITY_LIMITS
```

### 14.3 Schutz vor Fehlinterpretationen

Einige Trainingsfolien enthalten pauschalisierende kulturelle Aussagen. OMW übernimmt daraus keine ethnischen, religiösen oder Stammes-Automatismen.

```text
NO_ETHNIC_DETERMINISM
NO_TRIBAL_AUTOMATIC_LOYALTY
NO_RELIGIOUS_AUTOMATIC_HOSTILITY
LOCAL_EVIDENCE_REQUIRED
```

## 15. Verknüpfung mit CampaignState

Mindestfelder:

```text
population_support_red
population_compliance_red
population_fear_of_red
population_fear_of_government
red_monitoring_capability
red_sanction_capability
red_threat_credibility
red_outcome_predictability
local_opposition_visibility
insider_penetration
partner_reliability
local_access
cache_access
route_predictability
blue_pattern_knowledge
cell_communications_quality
external_specialist_availability
```

## 16. Missionsmuster

### 16.1 RED

```text
BUILD_LOCAL_ACCESS
RECRUIT_OBSERVER
MONITOR_GOVERNMENT_CONTACT
ISSUE_WARNING
SANCTION_COLLABORATOR
PREPARE_AMBUSH_SITE
CONDUCT_COMPLEX_AMBUSH
CONDUCT_INDIRECT_FIRE_HARASSMENT
PROBE_BASE_SECURITY
PREPARE_COMPLEX_ATTACK
DISPERSE_AFTER_CONTACT
RECONSTITUTE_LOCAL_NETWORK
```

### 16.2 BLUE

```text
ASCOPE_COLLECTION_PATROL
KLE_AND_SOURCE_VALIDATION
PROTECT_THREATENED_LOCAL_ACTOR
COUNTER_SURVEILLANCE
ROUTE_PATTERN_CHANGE
INSIDER_NETWORK_INVESTIGATION
CACHE_AND_FINANCE_DISRUPTION
HOLD_AND_REASSURE
PARTNER_RELIABILITY_ASSESSMENT
HISTORICAL_BASE_RECONNAISSANCE
```

## 17. Implementierungsstufen

### Stufe 1: RED-MVP

Unverändert:

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

### Stufe 2: Intelligence und lokale Kontrolle

```text
RECRUIT_OBSERVER
BUILD_MONITORING_NETWORK
LEARN_BLUE_PATTERN
ISSUE_WARNING
APPLY_LIMITED_SANCTION
DECAY_STALE_KNOWLEDGE
```

### Stufe 3: institutionalisierte Kontrolle und komplexe Angriffe

```text
EXTRACT_RESOURCES
RUN_SHADOW_DISPUTE_RESOLUTION
REGULATE_LOCAL_ACTIVITY
BUILD_CAPABILITY_PACKAGE
CONDUCT_HIGH_PROFILE_COMPLEX_ATTACK
```

Die Stufen 2 und 3 dürfen den stabilen MVP nicht blockieren.

## 18. Daten- und Kartenpflege

Historische Karten und Koordinaten werden nicht direkt in Missionen übernommen. Für jeden Kandidaten sind zu dokumentieren:

```text
source_name
source_page
source_date
reported_name
reported_coordinate
coordinate_precision
historical_role
2010_2011_status
DCS_terrain_match
verification_status
approved_use
```

## 19. Verbindliche Designentscheidungen

1. Es bleibt bei einem konsolidierten RED Commander.
2. Unterstützung, Compliance und Angst bleiben getrennte Zustände.
3. RED-Wissen ist sektoral, quellenabhängig und zeitlich vergänglich.
4. IED und Hinterhalt sind Standardfähigkeiten; komplexe Angriffe sind seltene, voraussetzungsreiche Capability Packages.
5. Historische Ereigniszahlen werden nicht in Spawnraten übersetzt.
6. Historische Basen werden erst nach Georeferenzierung und Terrainprüfung verwendet.
7. FOUO-/Distributionshinweise werden respektiert; Quellen werden nicht reproduziert.
8. Keine ethnische, religiöse oder tribale Zugehörigkeit erzeugt automatisch Loyalität oder Feindschaft.
9. BLUE-Aufklärung und Patrouillen müssen messbaren Informationsgewinn erzeugen können.
10. Dieses Dokument ist Designreferenz, keine Runtime-Acceptance.

## 20. Offene Aufgaben

- [ ] Lor Koh gegen DCS Afghanistan und historische Bildquellen prüfen.
- [ ] Islam Dara georeferenzieren und gegen Khakrez-Gelände abgleichen.
- [ ] Ereignischronologie 2010 in einen getrennten, nicht-spawnenden Referenzdatensatz normalisieren.
- [ ] RED-Knowledge-Decay und Source-Reliability als Datenmodell spezifizieren.
- [ ] ASCOPE3xD-Felder mit bestehendem CampaignState abgleichen.
- [ ] MOOSE-First-Prüfung für RECCE-, DETECTION-, ZONE- und eventbasierte Bausteine durchführen.
- [ ] Verifizieren, welche Quellen wegen Distribution Restriction nur intern zitiert werden dürfen.

## 21. Quellenverweise nach Themen

| Thema | Primär verwendete Quelle |
|---|---|
| lokale Compliance und Governance | `AfghanInsurgentControl.pdf`, besonders S. 1-6 |
| RED-HUMINT und IPB | `USArmy-TalibanIntel.pdf`, besonders S. 2, 8-12 |
| Verlust- und TTP-Prioritäten | `USArmy-TalibanTTPs.pdf`, besonders S. 2-11 |
| Hinterhalt, Raid und Indirect Fire | `MCIA-InsurgentTTP.pdf`, besonders Vignetten 1-3 sowie 15-17 |
| Suicide/Complex Attack 2010 | `USArmy-AfghanSuicideAttacks.pdf`, Ereignischronologie und Statistikabschnitte |
| externe Support-Dynamik | `USArmy-PakistanSuicideAttacks.pdf` |
| COIN-IPB und ASCOPE3xD | `CTC-A-COIN-Guidebook.pdf`, besonders S. 2-12 und Folgeabschnitte |
| COIN Mindset und Lessons Learned | `CACcoin.pdf`, `CACcoin2.pdf` |
| Lor Koh und Islam Dara | `MCIA-MujahedinBases.pdf`, besonders S. 3-9 und Kartenanhänge |

## 22. Querverweise

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md)
- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md)
- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md)
- [`OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS`](58-eastern-afghanistan-network-operations-and-complex-attack-model.md)
- [`OMW-COIN-ASSESSMENT-TRANSITIONS-NONSTATE-SECURITY`](59-campaign-assessment-operational-transitions-and-nonstate-security.md)
- [`OMW-COIN-GOVERNANCE-STRATEGY-TRANSITION`](61-coin-governance-strategy-and-afghan-led-transition.md)
