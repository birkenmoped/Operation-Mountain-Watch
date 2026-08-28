---
document_id: OMW-COIN-ASSESSMENT-TRANSITIONS-NONSTATE-SECURITY
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical campaign assessment and control-metric model
  - clear-hold-build and operational-transition design requirements
  - source-qualified private-security and powerbroker actor model for southern Afghanistan
  - separation of tactical activity, control, influence, legitimacy and sustainable security
not_authoritative_for:
  - active BLUE, ANSF, PSC or RED ORBAT
  - exact local private-security strength or loyalty
  - direct transfer of Iraq-specific organizations or tactics into Afghanistan
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: 4aff0014843e87626e1c619350121c81458fe17e
validated_in_dcs: false
---

# 59 – Kampagnenbewertung, operative Übergänge und nichtstaatliche Sicherheitsakteure

## 1. Zweck

Dieses Dokument verarbeitet die übrigen zuletzt bereitgestellten Quellen zu:

- Konflikt- und Kontrollmetriken;
- Clear-, Hold- und Build-Übergängen;
- ANSF-Fähigkeit und Enabler-Abhängigkeit;
- civil-military alignment;
- privaten Sicherheitsunternehmen, Milizen und Powerbroker-Netzwerken;
- Quellenunsicherheit und belastbarer CampaignState-Bewertung.

Es ergänzt:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md);
- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md);
- [`OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS`](58-eastern-afghanistan-network-operations-and-complex-attack-model.md);
- [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md).

## 2. Quellenregister und Bewertung

| ID | Quelle | Datum | Einstufung | Hauptnutzen | Grenze |
|---|---|---:|---|---|---|
| CAT-01 | Anthony H. Cordesman, *Afghanistan: Conflict Metrics 2000–2018* | 22.06.2018 | `POST_PERIOD_RETROSPECTIVE_METRICS` | Vergleich konkurrierender Metriken, Kritik an Definitionen, Methodik, Control-/Influence-Darstellung und taktischer Erfolgsbewertung | kompiliert viele Sekundär- und Regierungsquellen; einzelne Grafiken besitzen unterschiedliche Provenienz |
| CAT-02 | James M. Dubik, *Operational Art in Counterinsurgency: A View from the Inside* | 05.2012 | `POST_PERIOD_DOCTRINAL_ANALYSIS` | Clear-Hold-Build, taktische/operative/strategische Übergänge, civil-military alignment, Campaign Assessment | überwiegend Irak 2007/2008; Generalisierung muss an Afghanistan angepasst werden |
| CAT-03 | Lauren McNally und Paul Bucala, *The Taliban Resurgent* | 03.2015 | `POST_PERIOD_VALIDATION` | Regeneration nach Clear, fehlende Hold-Präsenz, ANSF-Enabler- und Aviation-Lücken, offene Quellenmethodik | Lage 2014/2015; keine 2010/2011-ORBAT oder direkte Rückprojektion |
| CAT-04 | Kimberly Kagan, *The Real Surge: Preparing for Operation Phantom Thunder* | 2007 | `IRAQ_BACKGROUND_ONLY` | allgemeines Operationsdesign zu äußeren Support-Räumen, Lines of Communication und simultanem Druck | Irak-spezifisch; keine Afghanistan-Einheit, Basis, Route oder Stärke übernehmen |
| CAT-05 | Carl Forsberg und Kimberly Kagan, *Consolidating Private Security Companies in Southern Afghanistan* | 28.05.2010 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Kandahar-PSCs, Powerbroker-Einfluss, Highway-One-Sicherung, geplante Konsolidierung und ANSF-Konkurrenz | politische Analyse; Eigentums-, Einfluss- und Stärkezahlen teilweise berichtsbasiert oder geplant |
| CAT-06 | Jeffrey Dressler und Carl Forsberg, *The Quetta Shura Taliban in Southern Afghanistan* | 21.12.2009 | `PRE_PERIOD_ANALYTICAL_BASELINE` | strategische Führung, lokale Ausführung, Shadow Governance, gezielte Ausschaltung lokaler Führung | südlicher Fokus; kompiliert ältere Helmand-/Kandahar-Arbeiten |

## 3. Grundsatz: Aktivität ist kein Erfolg

Die Quellen bestätigen folgende verbindliche Trennungen:

```text
ENEMY_KILLED != CAMPAIGN_SUCCESS
SORTIES_FLOWN != SECURITY_EFFECT
ATTACKS_REDUCED != NETWORK_REMOVED
DISTRICT_CAPITAL_PRESENT != DISTRICT_CONTROLLED
AREA_CLEARED != AREA_HELD
AREA_HELD != LEGITIMATE_GOVERNANCE
```

Ein Campaign Assessment muss Wirkung und Nachhaltigkeit prüfen, nicht nur Tätigkeit zählen.

## 4. Quellenkritik an Konfliktmetriken

CAT-01 zeigt wiederkehrende Probleme:

- Schlüsselbegriffe werden nicht immer definiert;
- Erhebungsmethode und Unsicherheit fehlen teilweise;
- verschiedene Quellen messen unterschiedliche Dinge unter ähnlichen Bezeichnungen;
- taktische Gefechtsausgänge können über politische und territoriale Wirkung hinwegtäuschen;
- eine Regierungspräsenz im Distriktzentrum kann fälschlich als Kontrolle eines gesamten Distrikts erscheinen;
- lokale Powerbroker, Milizen und informelle Herrschaft werden in binären Control-Karten unzureichend sichtbar;
- Berichtsreihen können abbrechen oder ihre Methodik wechseln.

Daraus folgt:

```text
NO_METRIC_WITHOUT_DEFINITION
NO_TREND_WITHOUT_METHOD_CONTINUITY
NO_CONTROL_VALUE_WITHOUT_SCOPE
NO_SOURCE_WITHOUT_PROVENANCE
```

## 5. April-2010-Metriken als historische Momentaufnahme

CAT-01 reproduziert DoD-Grafiken aus April 2010. Darin wurden für 121 Key Terrain- und Area-of-Interest-Distrikte unter anderem berichtet:

- 29 von 121 Distrikten beziehungsweise 24 Prozent mit Bevölkerung, die die afghanische Regierung unterstützte oder mit ihr sympathisierte;
- 42 von 121 Distrikten beziehungsweise 35 Prozent mit einer Sicherheitsbewertung von mindestens „occasionally“ oder besser.

Verwendungsgrenzen:

- es handelt sich um eine retrospektiv reproduzierte Regierungsmetrik;
- Begriffe, Auswahl der 121 Distrikte und Bewertungsmethode müssen mitgeführt werden;
- die Werte sind keine flächendeckende Afghanistan-Baseline;
- sie erzeugen keine automatische OMW-Sektorbewertung;
- sie belegen vor allem, dass Unterstützung, Sicherheit und nominelle Kontrolle getrennt betrachtet wurden.

## 6. AssessmentRecord

Jede externe oder interne Kampagnenbewertung benötigt mindestens:

```yaml
assessment_record:
  id: string
  date_or_period: date_range
  geography: string
  metric_name: string
  metric_definition: string
  unit_of_measure: string
  population_or_area_scope: string
  collection_method: known|partial|unknown
  source: string
  source_class: string
  confidence: low|medium|high
  uncertainty_note: string
  methodology_version: string
  comparable_to_previous: true|false|unknown
  campaign_use: baseline|trend|context|lead_only
```

Fehlt eine Definition oder Methodik, darf der Wert angezeigt, aber nicht unbemerkt mit anderen Reihen verrechnet werden.

## 7. Mehrdimensionale Sektorbewertung

Ein Sektor erhält keine einzelne binäre Control-Kennzahl. Mindestdimensionen:

```yaml
sector_assessment:
  blue_physical_presence: 0..100
  ansf_physical_presence: 0..100
  red_armed_presence: 0..100
  red_night_freedom: 0..100
  route_access_blue: 0..100
  route_access_red: 0..100
  population_support_government: 0..100
  population_support_red: 0..100
  population_passivity: 0..100
  intimidation: 0..100
  government_legitimacy: 0..100
  dispute_resolution_access: 0..100
  local_security_reliability: 0..100
  humint_access_blue: 0..100
  humint_access_red: 0..100
  cache_network: 0..100
  governance_delivery: 0..100
```

Sichtbare Kurzlabels dürfen diese Werte zusammenfassen, dürfen die Einzelwerte aber nicht ersetzen.

## 8. Tactical, Operational und Strategic Transitions

CAT-02 beschreibt COIN als Folge miteinander verbundener Übergänge statt einer linearen Front.

### 8.1 Tactical Transition

```text
CLEAR
→ HOLD
→ BUILD
```

Jede Phase besitzt eigene Voraussetzungen. Ein Erfolg in einer Phase garantiert den Erfolg der nächsten nicht.

### 8.2 Operational Transition

Für einen nachhaltigen Übergang an lokale Verantwortung sind mindestens zu bewerten:

```text
SECURITY
GOVERNANCE
ADJUDICATION
RECONSTRUCTION_AND_SERVICES
```

### 8.3 Strategic Transition

Langfristige Selbsttragfähigkeit umfasst:

```text
INSTITUTIONAL_CAPACITY
GOVERNMENT_CAPACITY
SECURITY_SECTOR_CAPACITY
ECONOMIC_CAPACITY
ORGANIZATIONAL_COHERENCE
```

OMW simuliert diese Ebenen nur so weit, wie sie nachvollziehbare MissionDemand- und CampaignState-Folgen erzeugen. Es entsteht keine vollständige Staatsaufbausimulation.

## 9. Clear-Phase

Ein Clear ist beendet, wenn:

- definierte taktische Ziele erreicht oder neutralisiert sind;
- Hauptwiderstand ausgewichen, zerstreut oder unterbrochen wurde;
- Schlüsselrouten und Schlüsselobjekte für die folgende Phase zugänglich sind;
- verbleibende Bedrohungen dokumentiert sind;
- ein Hold-Plan mit Ressourcen und Verantwortlichem existiert.

Nicht ausreichend:

```text
last_enemy_group_destroyed
area_temporarily_empty
single_successful_patrol
```

## 10. Hold-Phase

Hold benötigt:

```yaml
hold_requirements:
  assigned_force: true
  persistent_presence: sufficient
  route_security: sufficient
  reaction_force: available
  local_partner: present
  local_partner_reliability: sufficient
  humint_access: developing_or_better
  official_protection: available
  cache_disruption: recurring
  incident_response: functional
```

Fehlt Hold, entsteht der in Dokumenten 56 und 57 definierte Zustand:

```text
BLUE_CLEARED_NOT_HELD
```

CAT-03 liefert eine post-periodische Bestätigung dieses Musters: ANSF konnten Räume zurückgewinnen, hielten aber nicht immer genügend Vorwärtspräsenz, um die Rückkehr des Gegners zu verhindern. Diese Beobachtung bestätigt das Modell, ist jedoch keine 2010/2011-Istlage.

## 11. Build-Phase

Build umfasst nicht nur Bauprojekte. Mögliche CampaignState-Effekte:

```text
local_government_presence
reliable_policing
accessible_dispute_resolution
market_and_route_access
essential_services
reconstruction_project_status
public_reporting_willingness
protection_of_officials_and_contacts
```

Ein statisches DCS-Objekt allein schließt Build nicht ab.

## 12. Enabler- und Partnerabhängigkeit

CAT-03 betont für die spätere ANSF-Lage Fähigkeitslücken insbesondere bei Luftunterstützung und Mobilität. Für OMW wird dies als allgemeine, bereits durch weitere Quellen gestützte Trennung übernommen:

```yaml
partner_force_state:
  nominal_strength: documented_or_unknown
  present_strength: 0..100
  leadership_quality: 0..100
  training: 0..100
  discipline: 0..100
  logistics: 0..100
  intelligence: 0..100
  mobility: 0..100
  fires_access: 0..100
  aviation_access: 0..100
  medevac_access: 0..100
  partner_support: 0..100
```

Eine nominell vorhandene Einheit ist nicht automatisch selbstständig kampffähig.

## 13. Civil-Military Alignment

CAT-02 leitet aus der Irak-Erfahrung allgemeine Anforderungen ab:

- gemeinsames Campaign Goal;
- zentraler Campaign Plan;
- eindeutige Verantwortungen;
- regelmäßige Assessment- und Entscheidungszyklen;
- Feedback aus taktischer, ziviler und lokaler Ebene;
- Anpassung an Gegner- und Umgebungsänderungen;
- gemeinsame Bewertung von Sicherheit, Governance und Aufbau.

Für OMW bedeutet dies kein simuliertes Konferenzsystem. Technisch relevant sind:

```text
one_authoritative_campaign_state
one_mission_demand_registry
one_assessment_cycle
traceable_decisions
recorded_assumptions
recorded_source_confidence
```

## 14. Keine unkritische Irak-Übertragung

CAT-02 und CAT-04 verwenden überwiegend Irak-Fälle. Folgende Elemente werden nicht übernommen:

- konkrete Baghdad-Belts-Geografie;
- Iraq-spezifische Joint Security Stations;
- Sons-of-Iraq-/Concerned-Local-Citizens-Strukturen;
- konkrete Truppenansätze;
- konkrete Befehlsorganisationen;
- irakische politische oder konfessionelle Modelle.

Zulässig sind nur abstrakte Muster:

```text
protect_population
interdict_support_routes
maintain_presence
coordinate_simultaneous_effects
fill_security_and_governance_vacuum
assess_transitions_by_conditions
```

## 15. Private Security Companies in Kandahar

CAT-05 beschreibt für Mai 2010 zahlreiche private Sicherheitsunternehmen und bewaffnete Gruppen in Kandahar, die zugleich:

- Sicherheitsaufträge für ISAF oder Unternehmen ausführten;
- als Milizen lokaler Powerbroker fungierten;
- Hauptverkehrsachsen und Verträge kontrollierten;
- mit ANSF konkurrierten;
- formale und informelle Befehlsketten vermischten.

Genannt werden unter anderem:

- Watan Risk Management;
- Asia Security Group;
- Kandahar Strike Force;
- Provincial Council Security Force;
- Ayno-Mena-Sicherheitskräfte;
- Sicherheitskräfte von Commander Ruhullah auf Highway One.

Die Quelle ist eine politische Analyse. Eine Nennung belegt weder dauerhaftes Eigentum noch vollständige Kontrolle oder unveränderte Loyalität während des gesamten OMW-Zeitraums.

## 16. Geplante Kandahar Security Company

CAT-05 berichtet über Pläne, bis zu achtzehn unlizenzierte Sicherheitsunternehmen in einer Kandahar Security Company zusammenzuführen.

Quellenwerte:

```text
initial_planned_personnel: 500
suggested_possible_growth: 2500
```

Diese Zahlen werden klassifiziert als:

```text
SOURCE_REPORTED_PLAN
```

und nicht als bestätigte Iststärke. Sie erzeugen keine aktive OMW-Einheit.

## 17. SecurityActor-Modell

Private, staatliche und informelle Sicherheitsakteure werden getrennt beschrieben:

```yaml
security_actor:
  id: string
  actor_type: ANSF|PSC|LOCAL_MILITIA|PERSONAL_SECURITY|CONTRACT_ROUTE_SECURITY
  legal_status: formal|licensed|unlicensed|disputed|unknown
  nominal_authority: string
  effective_patron: string_or_unknown
  assigned_area: string_or_unknown
  assigned_route: string_or_unknown
  nominal_strength: integer_or_unknown
  present_strength: 0..100
  reliability: 0..100
  professionalism: 0..100
  local_legitimacy: 0..100
  political_alignment: 0..100
  ansf_interoperability: 0..100
  abuse_risk: 0..100
  defection_or_noncompliance_risk: 0..100
  source_confidence: low|medium|high
```

Verbindlich:

```text
PRO_GOVERNMENT != STATE_CONTROLLED
CONTRACTED_BY_ISAF != RELIABLE
ROUTE_SECURITY_PROVIDER != ROUTE_OWNER
```

## 18. Stellung im Koalitionsmodell

PSCs und lokale Milizen werden nicht automatisch zu BLUE, RED oder einer eigenständigen spielbaren Fraktion.

Mögliche technische Darstellung:

```text
ABSTRACT_SECURITY_MODIFIER
NEUTRAL_OR_BLUE_ADJACENT_ACTOR
MISSION_SPECIFIC_PHYSICAL_GROUP
```

Eine physische Gruppe entsteht nur bei konkretem MissionDemand, eindeutigem Auftrag und geklärter Coalition-/ROE-Zuordnung.

## 19. Highway One und Routensicherheit

CAT-05 beschreibt den Raum Kandahar–Kabul auf Highway One als durch Vertrags-, Patronage- und bewaffnete Netzwerke beeinflusst. Für Routensegmente werden ergänzt:

```yaml
route_security:
  formal_responsible_authority: string_or_unknown
  effective_security_provider: string_or_unknown
  provider_type: ANSF|PSC|MILITIA|MIXED|NONE|UNKNOWN
  provider_reliability: 0..100
  patronage_dependency: 0..100
  payment_dependency: 0..100
  convoy_access: 0..100
  civilian_access: 0..100
  extortion_risk: 0..100
  interruption_risk: 0..100
```

Ein Vertragsausfall, politischer Streit oder Providerwechsel kann die Routensicherheit verändern, ohne dass RED eine neue militärische Offensive beginnt.

## 20. Powerbroker-Netzwerke

Die Grafik in CAT-05 zeigt eine dichte Verbindung aus Familienbeziehungen, politischer Patronage, offiziellen Funktionen, PSCs, Milizen und Route-Security-Verträgen. Die Grafik wird als analytisches Beziehungsmodell verwendet, nicht als gerichtsfester Eigentumsnachweis.

Für OMW werden nur abstrahierte Wirkungen genutzt:

```text
contract_access
security_provider_reliability
political_protection
ansf_competition
information_access
route_access
corruption_pressure
```

Eine vollständige Personen- oder Patronagesimulation ist nicht Bestandteil der Grundversion.

## 21. QST-Organisationsmuster

CAT-06 unterstützt folgende bereits in Dokumenten 56 und 57 verankerte Muster:

- strategische Führung gibt allgemeine Ziele und Kampagnenrichtung;
- lokale Kommandeure führen innerhalb des Rahmens dezentral aus;
- militärische und logistische Rollen können getrennt oder kombiniert sein;
- Beschwerden und lokale Konflikte werden zur Kohäsion und Legitimität bearbeitet;
- Shadow Governance ergänzt militärische Aktivität;
- gezielte Angriffe auf Polizei, Funktionsträger, Stammesführer und lokale Sicherheitskommandeure sollen Widerstandsnetzwerke schwächen.

Für den einen RED Commander bedeutet dies:

```text
CENTRAL_STRATEGIC_INTENT
+ DELEGATED_LOCAL_EXECUTION
+ CAMPAIGN_EFFECTS_BEYOND_KINETIC_ACTION
```

Es bedeutet nicht mehrere Runtime-Gegner.

## 22. Assessment-Zyklus

```text
COLLECT
→ VALIDATE_SOURCE
→ UPDATE_METRICS
→ IDENTIFY_CHANGE
→ TEST_ASSUMPTIONS
→ PRIORITIZE_DEMANDS
→ EXECUTE
→ ASSESS_EFFECTS
→ ADAPT
```

Jede Entscheidung speichert:

```yaml
decision_record:
  trigger: string
  evidence_ids: []
  assumptions: []
  confidence: low|medium|high
  selected_action: string
  rejected_alternatives: []
  expected_effect: string
  review_after: duration_or_event
```

## 23. Erfolgsmessung

### 23.1 Measure of Effort

- Patrouillen;
- Convoys;
- Route-Clearance-Einsätze;
- Partnertrainings;
- Projekte;
- eingesetzte Flugstunden.

### 23.2 Measure of Performance

- definierte Route geprüft;
- Reaktionszeit eingehalten;
- Hold-Kraft präsent;
- lokaler Partner tatsächlich verfügbar;
- Auftrag und Übergabe abgeschlossen.

### 23.3 Measure of Effectiveness

- Route über längeren Zeitraum nutzbar;
- Reinfiltration erkannt oder verhindert;
- freiwillige Meldungen steigen;
- Einschüchterung sinkt;
- lokale Verwaltung bleibt funktionsfähig;
- ANSF hält ohne unmittelbare BLUE-Ersatzleistung;
- zivile Schäden und Fehlidentifikationen bleiben begrenzt;
- RED-Netzwerk verliert nachhaltige Fähigkeit statt nur einzelne Gruppen.

## 24. Konsequenz für den RED Commander

Aus dieser Quellencharge folgt keine Erweiterung auf mehrere Gegner. Der RED Commander erhält stattdessen bessere Lage- und Zielbewertung:

```yaml
red_strategy_inputs:
  blue_presence: 0..100
  blue_hold_strength: 0..100
  route_security_reliability: 0..100
  security_actor_fragmentation: 0..100
  government_legitimacy: 0..100
  population_passivity: 0..100
  red_network_pressure: 0..100
  alternate_route_access: 0..100
  expected_information_effect: 0..100
```

Beispiele:

```text
weak_hold → REINFILTRATE_SECTOR
fragmented_route_security → OBSERVE_ROUTE / BUILD_CACHE
high_blue_pressure → DISPERSE_UNDER_PRESSURE
high_value_target + mature capability package → later CONDUCT_HIGH_PROFILE_COMPLEX_ATTACK
```

## 25. Abnahmekriterien

Das Modell gilt erst als technisch integriert, wenn:

- jede Metrik Definition, Scope und Quelle besitzt;
- Methodenwechsel Trends nicht unbemerkt fortschreiben;
- Control, Influence, Presence und Legitimacy getrennt bleiben;
- Clear, Hold und Build eigene Zustände und Anforderungen besitzen;
- PSCs nicht automatisch als staatlich, loyal oder feindlich gelten;
- geplante PSC-Stärken nicht als Istbestände übernommen werden;
- Iraq-spezifische Strukturen nicht auf Afghanistan kopiert werden;
- MissionDemand, CampaignState und Assessment nachvollziehbar verbunden sind;
- MOOSE-First und DCS-Acceptance separat dokumentiert sind.
