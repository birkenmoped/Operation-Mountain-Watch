---
document_id: OMW-SP-LLM-COMMANDERS-COMMON-MODEL
status: DRAFT_DESIGN_BASELINE
document_class: COMMANDER_DOMAIN_AND_DECISION_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Gemeinsames Commander-Daten- und Entscheidungsmodell

## 1. Zweck

Dieses Dokument definiert das gemeinsame, fraktionsneutrale Modell für:

```text
BLUE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Es beschreibt nicht die historische Persönlichkeit einer bestimmten Fraktion. Es legt fest, welche Zustände jeder Commander besitzt, welche Informationen er erhalten darf, wie Entscheidungen entstehen und welche strukturierte Ausgabe die technische Orchestrierung akzeptiert.

Die drei RED Commander erhalten später eigene Dossiers, Parameter, Zielhierarchien und Sonderregeln. Gemeinsam ist ihnen nur die technische Form.

## 2. Grundprinzipien

```text
LLM_PROPOSES_INTENT
ORCHESTRATOR_VALIDATES
CAMPAIGN_STATE_DECIDES_TRUTH
DCS_AND_MOOSE_EXECUTE
```

Das LLM ist weder Datenbank noch Simulationskern. Es darf:

- Lageinformationen interpretieren;
- Absichten priorisieren;
- Handlungsoptionen bewerten;
- Aufträge an unterstellte Rollen formulieren;
- mit anderen Commandern kommunizieren;
- begründete Annahmen und Unsicherheiten ausgeben.

Es darf nicht:

- unbekannte Weltzustände erfinden;
- Ressourcen ohne CampaignState-Nachweis erzeugen;
- Lua-, MOOSE- oder DCS-Befehle direkt ausführen;
- Positionen allwissend kennen;
- harte Regeln, Geographie oder historische Rahmenbedingungen überschreiben;
- eine Aktion allein durch erzählerische Plausibilität autorisieren.

## 3. Ebenen des Commander-Modells

Jeder Commander wird in sechs getrennte Ebenen zerlegt:

```text
IDENTITY
STRATEGIC_INTENT
ORGANIZATIONAL_AUTHORITY
CAPABILITIES_AND_RESOURCES
KNOWLEDGE_AND_BELIEFS
DECISION_AND_ACTION
```

Diese Trennung verhindert, dass Persönlichkeit, materielle Fähigkeit und tatsächliches Wissen vermischt werden.

## 4. CommanderIdentity

```yaml
commander_identity:
  commander_id: string
  faction_id: string
  display_name: string
  historical_archetype: string
  role_scope: strategic|operational|regional
  geographic_mandate: []
  political_mandate: []
  military_mandate: []
  source_classification: SOURCE_DOCUMENTED|ANALYTICAL_INFERENCE|SIMULATION_ABSTRACTION|DESIGN_DECISION
```

Der `display_name` muss keine reale historische Person sein. Für die erste Implementierung wird ein historisch informierter Archetyp empfohlen. Dadurch werden unbelegte Gedanken, private Motive oder konkrete Aussagen realer Personen vermieden.

```text
HISTORICAL_ARCHETYPE != BIOGRAPHICAL_REENACTMENT
```

## 5. Persönlichkeits- und Führungsprofil

Persönlichkeitswerte liegen auf einer Skala von `0..100`. Sie verändern Bewertungsgewichte, erzeugen aber keine automatischen Aktionen.

```yaml
personality:
  aggression: 0..100
  patience: 0..100
  risk_tolerance: 0..100
  loss_tolerance: 0..100
  prestige_sensitivity: 0..100
  ideological_rigidity: 0..100
  pragmatism: 0..100
  political_sensitivity: 0..100
  population_sensitivity: 0..100
  operational_security_bias: 0..100
  deception_preference: 0..100
  retaliation_bias: 0..100
  negotiation_preference: 0..100
  delegation_preference: 0..100
  distrust_of_subordinates: 0..100
  adaptability: 0..100
```

### 5.1 Verwendungsregeln

- `aggression` erhöht die Bereitschaft, günstige Gelegenheiten kurzfristig zu nutzen.
- `patience` erhöht die Bereitschaft zu längerer Aufklärung und Vorbereitung.
- `risk_tolerance` betrifft Gefährdung von Kräften und Netzwerken.
- `loss_tolerance` betrifft akzeptierte materielle und personelle Verluste.
- `prestige_sensitivity` erhöht die Bedeutung öffentlich wahrnehmbarer Erfolge und Kränkungen.
- `political_sensitivity` bewertet längerfristige Legitimitäts- und Bündniswirkungen.
- `population_sensitivity` bewertet Unterstützung, Duldung, Angst und Rückschlagsrisiken.
- `operational_security_bias` bevorzugt Abbruch, Verzögerung, Compartmentation und Routenwechsel.
- `negotiation_preference` erhöht die Nutzung von Absprachen, Vermittlern und zeitweisen Vereinbarungen.
- `adaptability` bestimmt, wie schnell der Commander nach Fehlschlägen seine Annahmen und Verfahren ändert.

Ein Wert ist kein moralisches Urteil und keine klinische Diagnose.

## 6. Strategische Zielhierarchie

Jeder Commander besitzt dauerhaft gültige Ziele sowie zeitabhängige Kampagnenziele.

```yaml
strategic_goal:
  goal_id: string
  category: survival|political_control|territorial_access|military_pressure|resource_growth|legitimacy|prestige|negotiation|rival_containment
  base_priority: 0..100
  current_priority: 0..100
  desired_end_state: string
  geographic_scope: []
  time_horizon: immediate|short|medium|long
  success_metrics: []
  failure_thresholds: []
  source_classification: string
```

### 6.1 Prioritätsregel

```text
CURRENT_PRIORITY =
  BASE_PRIORITY
  + THREAT_MODIFIER
  + OPPORTUNITY_MODIFIER
  + PERSONALITY_MODIFIER
  + POLITICAL_MODIFIER
  + RELATIONSHIP_MODIFIER
  - RESOURCE_CONSTRAINT
```

Die technische Schicht berechnet oder begrenzt diese Werte. Das LLM darf Prioritätsänderungen begründen, aber nicht beliebig außerhalb definierter Grenzen setzen.

## 7. Autorität, Organisation und Befehlsreichweite

Ein Commander kontrolliert nicht automatisch jede zugehörige Zelle.

```yaml
organizational_authority:
  strategic_cohesion: 0..100
  command_reach: 0..100
  communication_reliability: 0..100
  provincial_control: 0..100
  district_control: 0..100
  local_commander_compliance: 0..100
  discipline_capacity: 0..100
  appointment_power: 0..100
  removal_power: 0..100
  sanction_capacity: 0..100
  internal_rivalry: 0..100
  criminality_pressure: 0..100
  defection_risk: 0..100
  representation_clarity: 0..100
```

### 7.1 Auftrag statt Fernsteuerung

Der strategische Commander erteilt bevorzugt:

```text
PURPOSE
PRIORITY
GEOGRAPHIC_SCOPE
RESOURCE_LIMIT
RISK_LIMIT
TIME_WINDOW
ABORT_CONDITIONS
REPORTING_REQUIREMENT
```

Lokale Kommandeure entscheiden innerhalb ihrer Autonomie über konkrete Ausführung. Die Ausführung kann:

```text
COMPLY
PARTIALLY_COMPLY
DELAY
MODIFY
REFUSE
MISREPORT
EXPLOIT_FOR_PRIVATE_GAIN
```

Die Wahrscheinlichkeit hängt von Disziplin, Loyalität, Kommunikation, lokaler Lage, persönlichem Interesse und Ressourcenlage ab.

## 8. Ressourcen- und Fähigkeitsmodell

Ressourcen werden nicht als frei formulierter Text geführt.

```yaml
resource_state:
  manpower: 0..100
  leadership: 0..100
  finance: 0..100
  weapons: 0..100
  explosives: 0..100
  transport: 0..100
  communications: 0..100
  intelligence_access: 0..100
  local_access: 0..100
  cache_capacity: 0..100
  safehouse_capacity: 0..100
  specialist_access: 0..100
  training_capacity: 0..100
  media_access: 0..100
  political_access: 0..100
  external_support: 0..100
  operational_security: 0..100
```

### 8.1 Reservierung und Verbrauch

Eine geplante Aktion durchläuft:

```text
AVAILABLE
-> RESERVED
-> COMMITTED
-> CONSUMED_OR_RETURNED
```

Ein Commander kann dieselbe Ressource nicht gleichzeitig mehreren Operationen verbindlich zusagen.

### 8.2 Capability Packages

Höherwertige Aktionen benötigen ein zusammengesetztes Paket:

```yaml
capability_package:
  package_id: string
  action_class: string
  manpower_required: 0..100
  intelligence_required: 0..100
  specialist_required: 0..100
  logistics_required: 0..100
  safehouse_required: 0..100
  route_required: true|false
  staging_required: true|false
  leadership_required: 0..100
  expected_preparation_time_hours: number
  expected_recovery_time_hours: number
  compromise_risk: 0..100
```

## 9. Gebiets- und Einflussmodell

Kontrolle wird nicht auf einen einzigen Wert reduziert.

```yaml
area_influence:
  armed_presence: 0..100
  freedom_of_movement: 0..100
  local_access: 0..100
  population_support: 0..100
  population_compliance: 0..100
  population_fear: 0..100
  intelligence_penetration: 0..100
  recruitment_access: 0..100
  revenue_access: 0..100
  cache_network: 0..100
  shadow_governance: 0..100
  shadow_justice: 0..100
  route_influence: 0..100
  rival_influence: 0..100
  blue_pressure: 0..100
  government_legitimacy: 0..100
  persistence_potential: 0..100
```

```text
SUPPORT != COMPLIANCE
COMPLIANCE != FEAR
ARMED_PRESENCE != GOVERNANCE
ROUTE_INFLUENCE != TERRITORIAL_CONTROL
```

## 10. Wissen, Wahrnehmung und Überzeugungen

### 10.1 Drei Wahrheitsstufen

```text
WORLD_TRUTH
OBSERVED_INFORMATION
COMMANDER_BELIEF
```

`WORLD_TRUTH` ist ausschließlich dem CampaignState bekannt. Der Commander erhält nur `OBSERVED_INFORMATION` und bildet daraus `COMMANDER_BELIEF`.

### 10.2 KnowledgeItem

```yaml
knowledge_item:
  knowledge_id: string
  subject_type: unit|route|base|person|network|pattern|event|resource|relationship
  subject_id: string
  claim: string
  source_type: string
  source_owner: string
  reliability: 0..100
  confidence: 0..100
  first_observed: timestamp
  last_verified: timestamp
  geographic_scope: []
  freshness: 0..100
  decay_rate: 0..100
  deception_risk: 0..100
  compromise_risk: 0..100
  sharing_restrictions: []
  status: rumor|unconfirmed|probable|confirmed|stale|disproven|compromised
```

### 10.3 Lernbare Muster

- Patrouillenrouten;
- Konvoizeiten;
- Route-Clearance-Zyklen;
- QRF-Reaktionszeiten;
- CAS- und ISR-Fenster;
- Gate- und Checkpoint-Routinen;
- Landeplatzmuster;
- Suchverfahren;
- wiederkehrende Verlegungen;
- Reaktionen auf Scheinangriffe oder Ablenkungen.

Muster altern. Täuschung oder geänderte BLUE-Verfahren müssen bestätigtes Wissen wieder unsicher machen können.

## 11. Gedächtnismodell

Das LLM erhält nicht die gesamte Kampagnenhistorie ungefiltert.

```yaml
commander_memory:
  doctrine_memory: []
  strategic_memory: []
  relationship_memory: []
  recent_event_memory: []
  lessons_learned: []
  unresolved_assumptions: []
  grievances: []
  commitments: []
```

### 11.1 Erinnerungsklassen

- `DOCTRINE`: dauerhaft;
- `STRATEGIC`: langfristig, selten gelöscht;
- `RELATIONSHIP`: langfristig, aber durch Ereignisse veränderbar;
- `OPERATIONAL`: mittlere Lebensdauer;
- `TACTICAL`: kurze Lebensdauer;
- `RUMOR`: schnell verfallend;
- `LESSON_LEARNED`: bleibt, bis neue Evidenz widerspricht.

### 11.2 Vermeidung künstlicher Perfektion

Ein Commander darf:

- Ereignisse falsch gewichten;
- Quellen überschätzen;
- Rivalen misstrauen;
- aus veralteten Mustern falsche Schlüsse ziehen;
- einen Erfolg falsch attribuieren.

Er darf aber nicht willkürlich bekannte harte Fakten vergessen, wenn die Simulation diese als sicher und aktuell übergibt.

## 12. Beziehungen zwischen Commandern

Beziehungen sind bilateral und asymmetrisch. Taliban kann Haqqani stärker vertrauen als Haqqani den Taliban.

```yaml
relationship_state:
  actor: string
  counterpart: string
  formal_alignment: 0..100
  ideological_alignment: 0..100
  personal_trust: 0..100
  operational_trust: 0..100
  intelligence_sharing: 0..100
  logistics_cooperation: 0..100
  territorial_competition: 0..100
  recruitment_competition: 0..100
  revenue_competition: 0..100
  prestige_competition: 0..100
  grievance_level: 0..100
  dependency: 0..100
  conflict_risk: 0..100
  negotiation_channel_quality: 0..100
  outstanding_commitments: []
  disputed_claims: []
```

### 12.1 Zulässige Interaktionen

```text
REQUEST_INFORMATION
SHARE_INFORMATION
REQUEST_TRANSIT
GRANT_TRANSIT
REQUEST_SUPPORT
OFFER_SUPPORT
REQUEST_RESOURCE_TRANSFER
PROPOSE_JOINT_OPERATION
PROPOSE_DECONFLICTION
PROPOSE_TEMPORARY_TRUCE
WARN_COUNTERPART
ACCUSE_COUNTERPART
CLAIM_CREDIT
DISPUTE_CREDIT
WITHHOLD_SUPPORT
BREAK_COMMITMENT
```

Der Empfänger bewertet eine Anfrage selbstständig. Kein Commander kann Kooperation erzwingen, sofern CampaignState keine entsprechende Abhängigkeit oder Autorität abbildet.

## 13. Bedrohungs- und Chancenbewertung

```yaml
assessment:
  subject_id: string
  military_value: 0..100
  political_value: 0..100
  intelligence_value: 0..100
  resource_value: 0..100
  prestige_value: 0..100
  urgency: 0..100
  opportunity_window: 0..100
  expected_cost: 0..100
  expected_network_risk: 0..100
  expected_population_backlash: 0..100
  expected_rival_benefit: 0..100
  confidence: 0..100
```

Eine einfache Bewertungsgrundlage:

```text
ACTION_UTILITY =
  strategic_gain
  + political_gain
  + resource_gain
  + information_gain
  + prestige_gain
  + rival_denial
  - personnel_cost
  - resource_cost
  - compromise_risk
  - retaliation_risk
  - population_backlash
  - opportunity_cost
```

Das Ergebnis ist ein Vergleichswert, keine mathematisch exakte Vorhersage.

## 14. Entscheidungszyklus

```text
1. RECEIVE_STATE_UPDATE
2. VALIDATE_INFORMATION_SCOPE
3. UPDATE_BELIEFS
4. UPDATE_GOAL_PRIORITIES
5. IDENTIFY_THREATS_AND_OPPORTUNITIES
6. GENERATE_CANDIDATE_ACTIONS
7. CHECK_RESOURCES_AND_AUTHORITY
8. SCORE_CANDIDATES
9. SELECT_INTENT
10. DEFINE_ABORT_CONDITIONS
11. ISSUE_ORDER_OR_REQUEST
12. WAIT_FOR_ADJUDICATION
13. RECEIVE_RESULT
14. UPDATE_MEMORY_AND_RELATIONSHIPS
```

### 14.1 Entscheidungstakt

Nicht jeder Commander muss gleich häufig entscheiden.

- strategische Neubewertung: selten;
- operative Planung: periodisch oder ereignisgetrieben;
- taktische Reaktion: durch lokale regelbasierte Instanzen;
- Krisenentscheidung: unmittelbar nach definierten Ereignissen.

Dadurch wird vermieden, dass ein strategisches LLM jede Minute neue Befehle erzeugt.

## 15. Aktionsklassen

Das gemeinsame Vokabular soll fraktionsneutral bleiben.

```text
PRESERVE_NETWORK
IMPROVE_INTELLIGENCE
BUILD_LOCAL_ACCESS
BUILD_POLITICAL_INFLUENCE
BUILD_GOVERNANCE_CAPACITY
BUILD_LOGISTICS
BUILD_CACHE_OR_SAFEHOUSE
MOVE_RESOURCES
RECRUIT_OR_REPLACE_LEADERSHIP
INFLUENCE_POPULATION
COERCE_LOCAL_ACTOR
DISRUPT_ROUTE
HARASS_BASE_OR_CHECKPOINT
CONDUCT_LIMITED_ATTACK
PREPARE_COMPLEX_OPERATION
CONDUCT_COMPLEX_OPERATION
DISPERSE_UNDER_PRESSURE
RELOCATE_NETWORK
REINFILTRATE_AREA
NEGOTIATE
COOPERATE_WITH_FACTION
CONTAIN_RIVAL
DISCIPLINE_SUBORDINATE
EXPLOIT_INFORMATION_EFFECT
```

Die konkreten Unterformen werden in den Fraktionsdossiers und im Action Schema definiert. Reale technische Anleitungen für Waffen, Sprengmittel oder Anschläge sind nicht Bestandteil des Modells.

## 16. Auftragsformat an lokale Instanzen

```yaml
commander_order:
  order_id: string
  issuer: string
  recipient_role: string
  intent: string
  purpose: string
  area: []
  priority: 0..100
  earliest_start: timestamp
  latest_end: timestamp
  resource_ceiling: {}
  risk_limit: low|medium|high|critical
  civilian_harm_limit: string
  network_exposure_limit: 0..100
  coordination_required: []
  abort_conditions: []
  success_conditions: []
  reporting_requirements: []
```

Der Auftrag enthält keine direkte DCS-Gruppensteuerung.

## 17. Strukturierte LLM-Ausgabe

Jeder Entscheidungsdurchlauf muss genau eine maschinenlesbare Antwort erzeugen.

```json
{
  "commander_id": "TALIBAN_COMMANDER",
  "decision_type": "ISSUE_ORDER",
  "situation_summary": "Kurze, aus dem übergebenen Lagebild abgeleitete Zusammenfassung.",
  "key_assumptions": [
    {
      "claim": "BLUE wird die Route voraussichtlich weiter nutzen.",
      "confidence": 64,
      "knowledge_ids": ["K-102", "K-118"]
    }
  ],
  "selected_goal_id": "G-ROUTE-INFLUENCE-03",
  "selected_action": "IMPROVE_INTELLIGENCE",
  "target_scope": ["SECTOR-TAGAB"],
  "resource_request": {
    "intelligence_access": 8,
    "local_access": 4
  },
  "risk_limit": "medium",
  "abort_conditions": [
    "observer_network_compromised",
    "persistent_blue_presence"
  ],
  "expected_effects": [
    "improve_route_pattern_confidence"
  ],
  "alternative_considered": "DISRUPT_ROUTE",
  "reason_alternative_rejected": "Intelligence confidence below authorization threshold.",
  "communications": [],
  "uncertainties": [
    "BLUE route variation remains insufficiently observed."
  ]
}
```

### 17.1 Erlaubte `decision_type`

```text
NO_ACTION
ISSUE_ORDER
MODIFY_ORDER
CANCEL_ORDER
REQUEST_INFORMATION
COMMUNICATE_WITH_COMMANDER
RESERVE_RESOURCES
RELEASE_RESOURCES
UPDATE_STRATEGIC_PRIORITY
```

### 17.2 Validierungsanforderungen

Die Orchestrierung verwirft oder korrigiert eine Antwort, wenn:

- unbekannte IDs verwendet werden;
- Ressourcen fehlen;
- Aktionsklasse unzulässig ist;
- geographischer Scope außerhalb des Mandats liegt;
- Knowledge-Referenzen nicht existieren;
- harte Schwellen nicht erfüllt sind;
- Ausgabe nicht dem Schema entspricht;
- der Commander auf World Truth statt auf sein Lagebild zugreift.

## 18. Harte und weiche Regeln

### 18.1 Harte Regeln

- keine Omniszienz;
- keine Ressourcenerzeugung;
- keine Teleportation;
- keine Aktion außerhalb des geografischen oder organisatorischen Mandats;
- keine direkte Kontrolle fremder Fraktionen;
- keine doppelte Ressourcenbindung;
- keine höherwertige Operation ohne Capability Gates;
- keine automatische Gleichsetzung von Ethnie, Stamm oder Religion mit Loyalität;
- keine automatische Zielklassifikation ziviler, religiöser, medizinischer oder Bildungsobjekte;
- keine technische Anleitung zur realen Durchführung von Gewaltakten.

### 18.2 Weiche Regeln

- Führung schützen;
- Netzwerke nicht unnötig exponieren;
- langfristige politische Wirkungen beachten;
- Zusagen gegenüber Partnern möglichst einhalten;
- lokale Kommandeure nicht ohne Grund übersteuern;
- nach Fehlschlägen Annahmen überprüfen;
- bei sinkender Informationsqualität von höherem Risiko absehen.

Weiche Regeln dürfen verletzt werden, müssen dann aber als bewusste Abweichung begründet und mit Folgen bewertet werden.

## 19. Ergebnis- und Lernmodell

Nach jeder Aktion erhält der Commander keine vollständige Wahrheit, sondern einen Ergebnisbericht entsprechend seinen Quellen.

```yaml
operation_result_report:
  operation_id: string
  reported_outcome: success|partial|failure|aborted|unknown
  source_reports: []
  confirmed_losses: {}
  suspected_losses: {}
  confirmed_effects: []
  suspected_effects: []
  intelligence_gained: []
  compromise_indicators: []
  population_reaction_estimate: {}
  rival_reaction_estimate: {}
  confidence: 0..100
```

Der Commander kann daraus ein `lesson_learned` erzeugen:

```yaml
lesson_learned:
  lesson_id: string
  statement: string
  evidence_ids: []
  confidence: 0..100
  affected_actions: []
  expires_if: []
```

## 20. Fehlerzustände und sichere Degradation

Wenn das LLM keine gültige Entscheidung liefert:

```text
INVALID_OUTPUT
-> RETRY_WITH_SCHEMA_ERROR
-> IF_STILL_INVALID: NO_ACTION
-> PRESERVE_EXISTING_ORDERS
-> LOG_FAILURE
```

Bei Nichterreichbarkeit des LLM übernimmt eine deterministische Fallback-Logik:

- laufende Aufträge fortsetzen, sofern keine Abbruchbedingung eingetreten ist;
- gefährdete Operationen pausieren oder abbrechen;
- keine neuen komplexen Operationen starten;
- Ressourcenreservierungen nach Timeout freigeben;
- keine Fraktionsbeziehungen verändern.

## 21. Noch nicht festgelegte Punkte

- konkrete LLM-Taktfrequenz;
- Modellgröße und Kontextfenster;
- Persistenzformat;
- exakte Token- und Laufzeitbudgets;
- Anzahl lokaler Unterkommandeur-Instanzen;
- Verhältnis LLM zu deterministischen Utility Scores;
- technische Message-Bus- oder API-Struktur;
- DCS-/MOOSE-Schnittstelle;
- BLUE-Commander-Sonderrechte und Human-in-the-Loop;
- maximale Zahl paralleler Operationen je Commander.

## 22. Abnahmekriterien für dieses Modell

Das gemeinsame Modell ist fachlich ausreichend, wenn:

1. alle vier Commander dieselbe technische Schnittstelle verwenden können;
2. Wissen strikt von World Truth getrennt ist;
3. Ressourcen und Autorität unabhängig von Persönlichkeit modelliert sind;
4. Beziehungen asymmetrisch und veränderbar sind;
5. lokale Befehlsabweichung darstellbar ist;
6. Aktionen nur aus einem kontrollierten Vokabular stammen;
7. jede Entscheidung Wissen, Ziel, Kosten, Risiko und Abbruchbedingungen referenziert;
8. ungültige oder fehlende LLM-Ausgaben deterministisch abgefangen werden;
9. die späteren Fraktionsdossiers Unterschiede abbilden können, ohne das Grundschema zu verändern.

## 23. Nächste Dokumente

```text
03-inter-faction-relations-and-negotiation.md
04-taliban-commander-dossier.md
05-haqqani-commander-dossier.md
06-hig-commander-dossier.md
07-commander-action-and-output-schema.md
08-blue-commander-dossier.md
```
