---
document_id: OMW-SP-LLM-COMMANDERS-MEMORY-BELIEF-INFORMATION
status: DRAFT_RUNTIME_DESIGN
document_class: MEMORY_BELIEF_AND_INFORMATION_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Commander Memory, Belief and Information Model

## 1. Zweck

Dieses Dokument definiert, wie BLUE, Taliban, Haqqani und HIG Informationen erhalten, bewerten, vergessen, weitergeben und in ein subjektives Lagebild überführen.

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
INFORMATION_ITEM = gemeldete, unvollständige Information
BELIEF = subjektive Bewertung des Commanders
MEMORY = persistierte Erfahrung und Beziehungsgeschichte
```

Ein Widerspruch zwischen `WORLD_TRUTH` und `BELIEF` ist zulässig und spielmechanisch erwünscht.

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
ANSF_OR_SECURITY_INSIDER
BASE_OR_GATE_WATCHER
ROUTE_SPOTTER
DRIVER_OR_CONTRACTOR
TECHNICAL_SENSOR
SIGINT_REPORT
ISR_REPORT
PATROL_REPORT
CAPTURED_DOCUMENT
DETAINEE_REPORT
OPEN_SOURCE_REPORT
RIVAL_FACTION_REPORT
FORMAL_LIAISON_REPORT
POST_ATTACK_OBSERVATION
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

Zustände werden nicht ausschließlich durch Zeit, sondern auch durch neue Berichte, Widersprüche, Quellenverlust und Täuschung verändert.

## 6. Reliability und Credibility

`reliability` bewertet die historische Zuverlässigkeit der Quelle.

`credibility` bewertet die Plausibilität der konkreten Meldung.

Beispiel:

```text
zuverlässige Quelle + überraschende Meldung
= hohe reliability, mittlere credibility

unzuverlässige Quelle + mehrfach bestätigte Meldung
= niedrige reliability, steigende credibility
```

## 7. Confidence Update

Vorläufiges Modell:

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

Alle Werte werden auf `0..100` begrenzt.

Die genaue Gewichtung ist konfigurierbar und wird nicht vom LLM frei erfunden.

## 8. Knowledge Decay

Jeder Informationstyp besitzt eine eigene Verfallsrate.

```yaml
knowledge_decay:
  static_location: slow
  permanent_infrastructure: very_slow
  route_usage_pattern: medium
  convoy_schedule: fast
  patrol_route: fast
  qrf_response_time: medium
  commander_loyalty: slow
  faction_relationship: slow
  active_operation: very_fast
  temporary_checkpoint: very_fast
```

Ein veralteter Bericht wird nicht gelöscht, sondern als `STALE` markiert.

## 9. Commander Belief

```yaml
commander_belief:
  belief_id: string
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

## 10. Falsche und widersprüchliche Lagebilder

Zulässige Situationen:

```text
COMMANDER_A believes route open
COMMANDER_B believes route compromised
WORLD_TRUTH route partially monitored
```

Der Orchestrator löst diesen Widerspruch nicht automatisch auf. Erst Beobachtung, Aufklärung, Ereignisse oder Ergebnisberichte verändern die Beliefs.

## 11. Deception Model

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
```

Jede Täuschung besitzt:

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

## 12. Information Sharing

Informationsweitergabe ist niemals automatisch vollständig.

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

## 13. Fraktionsspezifische Informationsprofile

### 13.1 Taliban

Stärken:

- lokale Beobachter;
- soziale und politische Netzwerke;
- Route Spotters;
- Einschätzung von Bevölkerung, Verwaltung und lokalen Machtverhältnissen;
- langfristiges Pattern Learning.

Schwächen:

- uneinheitliche Berichtsqualität;
- lokale Eigeninteressen;
- Falschmeldungen zur Selbstdarstellung;
- verzögerte Weitergabe zwischen Ebenen.

### 13.2 Haqqani

Stärken:

- compartmentierte Netzwerkberichte;
- Facilitation- und Routenwissen;
- hochwertige Zielaufklärung für ausgewählte Operationen;
- externe Kontakte und technische Spezialisten.

Schwächen:

- bewusst begrenzte Teilung;
- einzelne Zellen kennen nur Ausschnitte;
- Verlust eines Brokers kann mehrere Informationspfade stören.

### 13.3 HIG

Stärken:

- politische Kontakte;
- lokale Patronagenetze;
- mehrere Gesprächskanäle;
- Zugang zu Gerüchten, Verhandlungen und Seitenwechseln.

Schwächen:

- widersprüchliche Vertreter;
- Parallelverhandlungen;
- hohe Verzerrungsgefahr durch Eigeninteressen;
- unklare Autorität des Meldenden.

### 13.4 BLUE

Stärken:

- technische Sensoren;
- ISR, SIGINT und strukturierte Berichte;
- gemeinsame Lagebilder und formale Auswertung.

Schwächen:

- Sensorbeobachtung ist nicht automatisch Absichtserkenntnis;
- zeitliche Verzögerung;
- Lücken durch Terrain und Einsatzprioritäten;
- mögliche Fehlinterpretation lokaler Beziehungen.

## 14. Memory Classes

```text
EPISODIC_MEMORY
SEMANTIC_MEMORY
RELATIONSHIP_MEMORY
OPERATIONAL_MEMORY
ORGANIZATIONAL_MEMORY
TRAUMA_OR_SHOCK_MEMORY
```

### Episodic Memory

Konkrete Ereignisse, Operationen und Ergebnisse.

### Semantic Memory

Verallgemeinerte Muster wie wiederkehrende BLUE-Reaktionen.

### Relationship Memory

Versprechen, Verrat, Kooperation, Schulden und Konflikte.

### Operational Memory

Routen, Knoten, Caches, Methoden und bekannte Gegenmaßnahmen.

### Organizational Memory

Leistung, Loyalität und Zuverlässigkeit eigener Unterführer.

## 15. Memory Record

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
  linked_relationships: []
  lessons_inferred: []
  reconsideration_trigger: []
```

## 16. Memory Retention

Langfristig zu speichern sind insbesondere:

- Führungsverluste;
- große Niederlagen oder Erfolge;
- kompromittierte Netzwerkknoten;
- gebrochene Vereinbarungen;
- zuverlässige und unzuverlässige Partner;
- wiederholte BLUE-Muster;
- erfolgreiche Täuschungen;
- entdeckte Doppelspiele;
- Defektionen;
- regionale Konflikte zwischen Fraktionen.

Routineereignisse werden verdichtet oder verworfen.

## 17. Memory Summarization

Das LLM erhält keine unbegrenzte Ereignishistorie.

```text
RAW_EVENTS
-> NORMALIZED_EVENTS
-> RELEVANCE_FILTER
-> MEMORY_RECORDS
-> PERIODIC_SUMMARY
-> COMMANDER_CONTEXT
```

Die Zusammenfassung muss Fakten, Annahmen und Bewertungen getrennt halten.

## 18. Bias und Persönlichkeit

Persönlichkeitswerte beeinflussen, welche Informationen bevorzugt erinnert oder geglaubt werden.

Beispiele:

```text
high prestige_sensitivity
-> remembers public humiliation strongly

high distrust_of_subordinates
-> discounts optimistic local reports

high retaliation_bias
-> raises relevance of attributed attacks

high operational_security_bias
-> overweights compromise indicators
```

Bias verändert Bewertung, nicht objektive Daten.

## 19. Commander Input Construction

Pro Turn erhält ein Commander:

```yaml
memory_and_information_context:
  current_beliefs: []
  high_relevance_information: []
  unresolved_contradictions: []
  stale_but_relevant_items: []
  suspected_deception: []
  recent_events: []
  relationship_memories: []
  organizational_memories: []
  omitted_item_count: integer
```

Die Angabe `omitted_item_count` verhindert den Eindruck vollständiger Informationsabdeckung.

## 20. Update Pipeline

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

## 21. Sicherheitsregeln

1. Keine Fraktion erhält Informationen allein aufgrund technischer Existenz im CampaignState.
2. Geteilte Information behält Provenienz und Einschränkungen.
3. Das LLM darf keine fehlende Quelle erfinden.
4. Widersprüche werden sichtbar gehalten.
5. Veraltete Informationen bleiben als veraltet erkennbar.
6. Täuschung verändert Beliefs, nicht rückwirkend World Truth.
7. Memory darf keine objektiven Fakten ergänzen, die nie beobachtet wurden.

## 22. Testfälle

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
```

## 23. Abnahmekriterien

Das Modell ist erst technisch akzeptiert, wenn:

- objektive Wahrheit und Commander-Belief getrennt persistieren;
- Quellenprovenienz erhalten bleibt;
- Wissen nachvollziehbar altert;
- widersprüchliche Berichte parallel bestehen können;
- Informationsweitergabe unvollständig und verzögert sein kann;
- Memory-Zusammenfassungen reproduzierbar erzeugt werden;
- keine Commander-Instanz Informationen einer anderen automatisch erhält;
- Testfälle deterministisch wiederholbar sind.
