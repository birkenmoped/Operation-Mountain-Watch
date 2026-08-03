---
document_id: OMW-SP-LLM-COMMANDERS-MEMORY-BELIEF-INFORMATION
status: DRAFT_RUNTIME_DESIGN
document_class: MEMORY_BELIEF_AND_INFORMATION_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - information provenance and commander beliefs
  - five-faction information profiles
  - resource-source and resource-account beliefs
  - memory retention and information sharing
---

# Commander Memory, Belief and Information Model

## 1. Zweck

Dieses Dokument definiert, wie fünf Commander Informationen erhalten, bewerten, vergessen, weitergeben und in ein subjektives Lagebild überführen:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

```text
WORLD_TRUTH
-> OBSERVATION_EVENT
-> SOURCE_REPORT
-> INFORMATION_ITEM
-> COMMANDER_BELIEF
-> DECISION
-> RESULT
-> MEMORY_UPDATE
```

Kein Commander erhält direkten Zugriff auf `WORLD_TRUTH`.

## 2. Autoritative Ebenen

```text
WORLD_TRUTH = objektiver CampaignState
OBSERVATION = technisch oder narrativ erzeugtes Ereignis
INFORMATION_ITEM = gemeldete unvollständige Information
BELIEF = subjektive Bewertung eines Commanders
MEMORY = persistierte Erfahrung und Beziehungsgeschichte
```

Ein Widerspruch zwischen `WORLD_TRUTH` und `BELIEF` ist zulässig und spielmechanisch erwünscht.

Verbindlich:

```text
SAME_DCS_COALITION != SHARED_INFORMATION_DATABASE
ISAF_INFORMATION != AUTOMATIC_AFGHAN_INFORMATION
AFGHAN_INFORMATION != AUTOMATIC_ISAF_INFORMATION
```

## 3. Information Item

```yaml
information_item:
  information_id: string
  subject_ref: string
  subject_category: string
  statement: string
  source_type: enum
  source_owner: string
  source_chain: []
  first_reported: datetime
  last_updated: datetime
  geographic_scope: []
  temporal_scope: {}
  reliability: 0..100
  credibility: 0..100
  confidence: 0..100
  freshness: 0..100
  deception_risk: 0..100
  compromise_risk: 0..100
  sensitivity: enum
  sharing_restrictions: []
  corroborating_items: []
  contradicting_items: []
  current_status: enum
```

## 4. Source Types

```text
DIRECT_VISUAL_OBSERVATION
LOCAL_OBSERVER
FAMILY_OR_TRIBAL_CONTACT
MARKET_CONTACT
RELIGIOUS_CONTACT
GOVERNMENT_CONTACT
ANA_REPORT
ANP_REPORT
AFGHAN_INTELLIGENCE_REPORT
ANSF_OR_SECURITY_INSIDER
BASE_OR_GATE_WATCHER
ROUTE_SPOTTER
DRIVER_OR_CONTRACTOR
TECHNICAL_SENSOR
SIGINT_REPORT
ISR_REPORT
PATROL_REPORT
CHECKPOINT_REPORT
RESOURCE_ACCOUNTING_REPORT
WAREHOUSE_REPORT
TRANSFER_DELIVERY_REPORT
CAPTURED_DOCUMENT
DETAINEE_REPORT
OPEN_SOURCE_REPORT
RIVAL_FACTION_REPORT
FORMAL_LIAISON_REPORT
POST_OPERATION_OBSERVATION
RUMOR
INFERENCE
```

Fraktionen besitzen unterschiedliche Zugänge und Bewertungen derselben Quellentypen.

## 5. Informationszustände

```text
UNKNOWN
RUMOR
REPORTED
OBSERVED_ONCE
PARTIALLY_CORROBORATED
PATTERN_SUSPECTED
PATTERN_CONFIRMED
RECENTLY_VERIFIED
CONTESTED
STALE
COMPROMISED
DISPROVEN
ARCHIVED
```

Zustände werden durch Zeit, neue Berichte, Widersprüche, Quellenverlust, Täuschung und Ergebnisse verändert.

## 6. Reliability und Credibility

`reliability` bewertet die historische Zuverlässigkeit der Quelle.

`credibility` bewertet die Plausibilität der konkreten Meldung.

```text
reliable source + surprising report
= high reliability, medium credibility

unreliable source + repeated corroboration
= low reliability, increasing credibility
```

## 7. Confidence Update

```text
new_confidence =
  previous_confidence
+ corroboration_gain
+ source_reliability_gain
+ recent_verification_gain
- contradiction_penalty
- age_decay
- deception_penalty
- source_compromise_penalty
```

Alle Werte werden auf `0..100` begrenzt. Die Gewichtung ist versioniert und nicht frei vom LLM bestimmbar.

## 8. Knowledge Decay

```yaml
knowledge_decay:
  static_location: slow
  permanent_infrastructure: very_slow
  resource_source_location: slow
  resource_account_estimate: fast
  beneficiary_share_estimate: medium
  route_usage_pattern: medium
  convoy_schedule: fast
  patrol_route: fast
  qrf_response_time: medium
  commander_loyalty: slow
  faction_relationship: slow
  active_operation: very_fast
  temporary_checkpoint: very_fast
  force_generation_status: fast
```

Ein veralteter Bericht wird nicht gelöscht, sondern als `STALE` markiert.

## 9. Commander Belief

```yaml
commander_belief:
  belief_id: string
  commander_id: string
  subject_ref: string
  proposition: string
  belief_strength: 0..100
  confidence: 0..100
  supporting_information_ids: []
  contradicting_information_ids: []
  origin: direct|inferred|inherited|shared
  geographic_scope: []
  last_reassessed: datetime
  action_relevance: 0..100
  known_uncertainties: []
  suspected_deception: []
```

Das LLM erhält Beliefs und unterstützende Informationsauszüge, aber keine versteckte objektive Wahrheit.

## 10. Resource-bezogene Beliefs

ResourceSources, ResourceAccounts und Fraktionsanteile müssen als eigene subjektive Wissensobjekte behandelt werden.

```text
KNOWN_RESOURCE_SOURCE
ESTIMATED_RESOURCE_SOURCE_CAPACITY
BELIEVED_PHYSICAL_CONTROLLER
BELIEVED_LEGAL_OWNER
BELIEVED_ACCESS_SHARE
BELIEVED_BENEFICIARY_SHARE
ESTIMATED_RESOURCE_ACCOUNT_STOCK
BELIEVED_TRANSFER_STATUS
BELIEVED_FORCE_GENERATION_STATUS
```

Beispiel:

```text
WORLD_TRUTH:
  checkpoint physically held by Afghan State
  Taliban receives hidden revenue share

AFGHAN_STATE_BELIEF:
  revenue leakage suspected but unquantified

TALIBAN_BELIEF:
  local collector reports stable share

ISAF_BELIEF:
  checkpoint assessed operational, corruption risk medium
```

Kein Commander darf objektive Shares allein aus technischer Existenz im CampaignState erfahren.

## 11. Falsche und widersprüchliche Lagebilder

```text
COMMANDER_A believes route open
COMMANDER_B believes route compromised
WORLD_TRUTH route partially monitored
```

```text
ISAF believes Afghan unit ready
AFGHAN_STATE believes unit requires enablers
WORLD_TRUTH readiness is mixed and leadership dependent
```

```text
TALIBAN believes HIG controls recruitment network
HIG believes local commander remains loyal
WORLD_TRUTH local commander is negotiating with both
```

Der Orchestrator löst Widersprüche nicht automatisch für die Commander auf.

## 12. Deception Model

Täuschung kann entstehen durch:

```text
FALSE_REPORT
PLANTED_INFORMATION
DELIBERATE_PATTERN_CHANGE
DECOY_ACTIVITY
FALSE_ATTRIBUTION
CONTROLLED_LEAK
FEIGNED_WITHDRAWAL
SIMULATED_PREPARATION
RIVAL_DISINFORMATION
SOURCE_DOUBLE_GAME
FALSE_RESOURCE_STOCK_REPORT
FALSE_TRANSFER_CONFIRMATION
FALSE_FORCE_READINESS_REPORT
```

```yaml
deception_operation:
  deception_id: string
  originator: string
  intended_recipient: string
  false_narrative: string
  supporting_signatures: []
  duration: {}
  exposure_risk: 0..100
  discovery_effects: []
```

Eine entdeckte Täuschung reduziert Vertrauen in Quelle, Kanal und Gegenpartei.

## 13. Information Sharing

```yaml
information_share:
  sender: string
  recipient: string
  information_ids: []
  fidelity: 0..100
  delay: duration
  omissions: []
  distortions: []
  classification_limit: string
  expected_reciprocity: string|null
```

Mögliche Resultate:

```text
FULL_TRANSFER
PARTIAL_TRANSFER
DELAYED_TRANSFER
DISTORTED_TRANSFER
WITHHELD
INTERCEPTED
COMPROMISED
```

### 13.1 ISAF und Afghan State

Informationsteilung hängt ab von:

```text
CLASSIFICATION
SOURCE_PROTECTION
LIAISON_CAPACITY
TRUST
POLITICAL_SENSITIVITY
TECHNICAL_INTEROPERABILITY
OPERATIONAL_SECURITY
```

Eine gemeinsame Operation erzeugt keine automatische Vollteilung aller Intelligence- oder ResourceAccount-Daten.

### 13.2 RED-Fraktionen

Geteilte Information kann absichtlich selektiv, verspätet oder verzerrt sein. Gemeinsame Gegnerlage bedeutet keine gemeinsame Datenbank.

## 14. Fraktionsspezifische Informationsprofile

### 14.1 BLUE ISAF

Stärken:

- technische Sensoren;
- ISR, SIGINT und strukturierte Berichte;
- formale Auswertung;
- Air- und Ground-Mission-Reporting;
- verbesserte Erfassung eigener Assets und Transfers.

Schwächen:

- Sensorbeobachtung ist nicht automatisch Absichtserkenntnis;
- zeitliche Verzögerung;
- Terrain- und Prioritätslücken;
- Fehlinterpretation lokaler Beziehungen;
- begrenzte Sicht auf informelle Afghan-State- und RED-Ressourcenflüsse;
- unvollständige Partnerinformationen.

### 14.2 Afghan State

Stärken:

- ANA- und ANP-Berichte;
- lokale Verwaltungs- und Checkpointinformationen;
- Community-, Elder- und lokale Machtkontakte;
- afghanische Intelligence- und Sicherheitsberichte;
- Einblick in formale staatliche ResourceSources und eigene Force Packages;
- lokales Sprach-, Sozial- und Kontextwissen.

Schwächen:

- uneinheitliche Berichtsqualität;
- politische Filterung;
- Patronage- und Korruptionsverzerrung;
- lokale Eigeninteressen;
- mögliche Infiltration;
- unvollständige Erfassung von Abwesenheit, Verlusten oder Materielumleitung;
- ISAF-Klassifikationsgrenzen.

### 14.3 Taliban

Stärken:

- lokale Beobachter;
- soziale und politische Netzwerke;
- Route Spotters;
- Einschätzung von Bevölkerung, Verwaltung und Machtverhältnissen;
- langfristiges Pattern Learning;
- Beobachtung lokaler Revenue-, Manpower- und Materielzugänge.

Schwächen:

- uneinheitliche Berichtsqualität;
- lokale Eigeninteressen;
- Falschmeldungen zur Selbstdarstellung;
- verzögerte Weitergabe;
- verdeckte Rivalität um Ressourcen.

### 14.4 Haqqani

Stärken:

- compartmentierte Netzwerkberichte;
- Facilitation- und Routenwissen;
- hochwertige Zielaufklärung für ausgewählte Operationen;
- externe Kontakte und Spezialisten;
- Brokerinformationen über externe Supportflüsse.

Schwächen:

- bewusst begrenzte Teilung;
- einzelne Zellen kennen nur Ausschnitte;
- Verlust eines Brokers kann mehrere Informationspfade stören;
- externe Kanäle können als stabil angenommen werden, obwohl sie kompromittiert sind.

### 14.5 HIG

Stärken:

- politische Kontakte;
- lokale Patronagenetze;
- mehrere Gesprächskanäle;
- Zugang zu Gerüchten, Verhandlungen und Seitenwechseln;
- lokale Commander- und Revenue-Informationen.

Schwächen:

- widersprüchliche Vertreter;
- Parallelverhandlungen;
- hohe Verzerrungsgefahr durch Eigeninteressen;
- unklare Autorität des Meldenden;
- lokale Zustände werden fälschlich als Gesamtfraktionszustand berichtet.

## 15. Memory Classes

```text
EPISODIC_MEMORY
SEMANTIC_MEMORY
RELATIONSHIP_MEMORY
OPERATIONAL_MEMORY
ORGANIZATIONAL_MEMORY
RESOURCE_MEMORY
TRAUMA_OR_SHOCK_MEMORY
```

### 15.1 Episodic Memory

Konkrete Ereignisse, Operationen und Ergebnisse.

### 15.2 Semantic Memory

Verallgemeinerte Muster wie wiederkehrende Gegnerreaktionen.

### 15.3 Relationship Memory

Versprechen, Verrat, Kooperation, Schulden, Partnerfriktion und Konflikte.

### 15.4 Operational Memory

Routen, Knoten, Caches, Methoden und bekannte Gegenmaßnahmen.

### 15.5 Organizational Memory

Leistung, Loyalität und Zuverlässigkeit eigener Unterführer.

### 15.6 Resource Memory

- bekannte oder vermutete ResourceSources;
- frühere Transfers;
- wiederkehrende Verluste und Umleitungen;
- bekannte Share-Konflikte;
- Force-Generation-Erfolge und Fehlschläge;
- wiederholte Materiel- oder Finance-Engpässe.

## 16. Memory Record

```yaml
memory_record:
  memory_id: string
  owner_commander_id: string
  memory_class: enum
  event_ref: string|null
  summary: string
  emotional_weight: 0..100
  strategic_weight: 0..100
  confidence: 0..100
  created_at: datetime
  last_recalled: datetime
  decay_rate: enum
  linked_entities: []
  linked_resource_sources: []
  linked_resource_accounts: []
  linked_relationships: []
  lessons_inferred: []
  reconsideration_trigger: []
```

## 17. Memory Retention

Langfristig zu speichern sind insbesondere:

- Führungsverluste;
- große Niederlagen oder Erfolge;
- kompromittierte Netzwerkknoten;
- verlorene ResourceSources;
- große ResourceTransfers;
- wiederholte Umleitung oder Korruption;
- Force-Generation-Fehlschläge;
- gebrochene Vereinbarungen;
- zuverlässige und unzuverlässige Partner;
- wiederholte Muster;
- erfolgreiche Täuschungen;
- Defektionen;
- regionale Konflikte zwischen Fraktionen.

Routineereignisse werden verdichtet oder verworfen.

## 18. Memory Summarization

```text
RAW_EVENTS
-> NORMALIZED_EVENTS
-> RELEVANCE_FILTER
-> MEMORY_RECORDS
-> PERIODIC_SUMMARY
-> COMMANDER_CONTEXT
```

Die Zusammenfassung muss Fakten, Annahmen, Schätzungen und Bewertungen getrennt halten.

## 19. Bias und Persönlichkeit

```text
high prestige_sensitivity
-> remembers public humiliation and rival credit strongly

high distrust_of_subordinates
-> discounts optimistic local reports

high political_sensitivity
-> retains partner and legitimacy failures strongly

high operational_security_bias
-> overweights compromise indicators

high pragmatism
-> retains useful cross-faction resource agreements
```

Bias verändert Bewertung, nicht objektive Daten.

## 20. Commander Input Construction

```yaml
memory_and_information_context:
  current_beliefs: []
  high_relevance_information: []
  resource_beliefs: []
  force_generation_beliefs: []
  unresolved_contradictions: []
  stale_but_relevant_items: []
  suspected_deception: []
  recent_events: []
  relationship_memories: []
  organizational_memories: []
  resource_memories: []
  omitted_item_count: integer
```

`omitted_item_count` verhindert den Eindruck vollständiger Informationsabdeckung.

## 21. Update Pipeline

```text
INGEST_REPORT
-> VALIDATE_SOURCE_AND_FORMAT
-> CORRELATE_WITH_EXISTING_ITEMS
-> UPDATE_INFORMATION_STATUS
-> UPDATE_OR_CREATE_BELIEF
-> APPLY_DECAY
-> DETECT_CONTRADICTION
-> DETECT_POSSIBLE_DECEPTION
-> CREATE_MEMORY_IF_THRESHOLD_MET
-> BUILD_COMMANDER_CONTEXT
```

## 22. Sicherheitsregeln

1. Keine Fraktion erhält Informationen allein aufgrund technischer Existenz im CampaignState.
2. Geteilte Information behält Provenienz und Einschränkungen.
3. Das LLM darf keine fehlende Quelle erfinden.
4. Widersprüche werden sichtbar gehalten.
5. Veraltete Informationen bleiben als veraltet erkennbar.
6. Täuschung verändert Beliefs, nicht rückwirkend World Truth.
7. Memory ergänzt keine objektiven Fakten, die nie beobachtet wurden.
8. Objektive ResourceAccount-Stände werden nicht als Commander-Wissen serialisiert.
9. ISAF und Afghan State erhalten keine automatische Vollteilung.
10. ResourceSource-Control und Beneficiary Share werden getrennt geglaubt.

## 23. Testfälle

```text
TEST-INFO-01 conflicting route reports
TEST-INFO-02 stale convoy pattern
TEST-INFO-03 compromised local source
TEST-INFO-04 successful deception operation
TEST-INFO-05 partial inter-faction intelligence sharing
TEST-INFO-06 local commander false reporting
TEST-INFO-07 discovered double agent
TEST-INFO-08 memory-driven overreaction
TEST-INFO-09 belief correction after failed operation
TEST-INFO-10 persistent disagreement between commanders
TEST-INFO-11 ISAF and Afghan State receive different partner reports
TEST-INFO-12 hidden Taliban revenue share remains unknown to Afghan State
TEST-INFO-13 false transfer confirmation is rejected
TEST-INFO-14 resource account estimate decays
TEST-INFO-15 five commander views differ from same world state
```

## 24. Abnahmekriterien

Das Modell ist technisch akzeptiert, wenn:

- objektive Wahrheit und Commander-Belief getrennt persistieren;
- Quellenprovenienz erhalten bleibt;
- Wissen nachvollziehbar altert;
- widersprüchliche Berichte parallel bestehen können;
- Informationsweitergabe unvollständig und verzögert sein kann;
- ISAF und Afghan State getrennte Informationsprofile besitzen;
- ResourceSource-, ResourceAccount- und Share-Beliefs subjektiv bleiben;
- Memory-Zusammenfassungen reproduzierbar erzeugt werden;
- keine Commander-Instanz Informationen einer anderen automatisch erhält;
- alle fünf Commander deterministisch unterschiedliche Views erhalten können.

## 25. Querverweise

```text
02-common-commander-model.md
03-inter-faction-relations-and-negotiation.md
07-runtime-rulebook-and-action-schema.md
09-orchestrator-architecture-and-adjudication.md
13-campaign-state-and-event-store-schema.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```
