---
document_id: OMW-SP-LLM-COMMANDERS-INTERFACTION
status: DRAFT_DESIGN_BASELINE
document_class: INTER_FACTION_RELATIONSHIP_AND_NEGOTIATION_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - directed relationships among the five campaign factions
  - ISAF and Afghan State partnership friction
  - Afghan State and RED competition
  - negotiation channels agreements and resource transfers
---

# Beziehungen, Konkurrenz, Partnerschaft und Verhandlungen zwischen Fraktionen

## 1. Zweck

Dieses Dokument definiert die gerichteten Beziehungen zwischen fünf getrennten Kampagnenfraktionen:

```text
ISAF
AFGHAN_STATE
TALIBAN
HAQQANI
HIG
```

Ziel ist kein statisches Bündnissystem. Die Kampagne bildet gleichzeitig ab:

- Bündnis und Friktion zwischen ISAF und Afghan State;
- militärische, politische und ressourcenbezogene Konkurrenz zwischen Afghan State und RED;
- formale Nähe, operative Eigenständigkeit und Rivalität der drei RED-Fraktionen;
- regional begrenzte Kooperation;
- Konkurrenz um Manpower, Finance, Materiel und Zugangsanteile;
- Informationsaustausch, Unterstützungsleistungen und Transfers;
- Misstrauen, Täuschung, gebrochene Zusagen und zeitweilige Absprachen.

```text
SHARED_ENEMY != UNIFIED_COMMAND
FORMAL_ALIGNMENT != SHARED_RESOURCES
LOCAL_COOPERATION != STRATEGIC_TRUST
SAME_DCS_COALITION != SAME_FACTION
PARTNERSHIP != OWNERSHIP
```

Ressourcenbegriffe folgen Dokument 17. Persistente Beziehungen und Agreements folgen Dokument 13.

## 2. Bilaterale und asymmetrische Beziehungen

Jede Beziehung wird zweimal geführt.

```text
ISAF_VIEW_OF_AFGHAN_STATE
AFGHAN_STATE_VIEW_OF_ISAF
```

```text
TALIBAN_VIEW_OF_HAQQANI
HAQQANI_VIEW_OF_TALIBAN
```

Werte müssen nicht identisch sein.

```yaml
relationship_state:
  actor_id: string
  counterpart_id: string
  geographic_scope: []

  formal_alignment: 0..100
  political_alignment: 0..100
  ideological_alignment: 0..100
  political_trust: 0..100
  operational_trust: 0..100
  personal_network_trust: 0..100

  intelligence_sharing_willingness: 0..100
  logistics_cooperation_willingness: 0..100
  transit_cooperation_willingness: 0..100
  joint_operation_willingness: 0..100

  finance_support_willingness: 0..100
  materiel_support_willingness: 0..100
  training_support_willingness: 0..100
  enabler_support_willingness: 0..100

  territorial_competition: 0..100
  recruitment_competition: 0..100
  revenue_competition: 0..100
  materiel_competition: 0..100
  patronage_competition: 0..100
  prestige_competition: 0..100
  political_representation_competition: 0..100

  enabler_dependency: 0..100
  command_friction: 0..100
  transition_pressure: 0..100
  perceived_respect_for_sovereignty: 0..100

  grievance_level: 0..100
  dependency: 0..100
  fear_of_betrayal: 0..100
  conflict_risk: 0..100
  negotiation_channel_quality: 0..100
```

## 3. Beziehungsebenen

### 3.1 Strategische Ebene

- politische Anerkennung;
- langfristige Zielkompatibilität;
- staatliche Souveränität;
- Stellung gegenüber externer Unterstützung;
- Anspruch auf Gesamtführung oder Eigenständigkeit;
- Transition und Abhängigkeit;
- Verhandlungsstrategie;
- Prestige und politische Repräsentation.

### 3.2 Operative Ebene

- Nutzung von Routen und Basen;
- Zuweisung von Enablern;
- Austausch von Intelligence;
- Deconfliction paralleler Operationen;
- Ressourcentransfers;
- Schutz oder Störung von ResourceSources und AccessNodes;
- gemeinsame Schwerpunktbildung.

### 3.3 Lokale Ebene

- persönliche Beziehungen einzelner Kommandeure;
- Streit um Checkpoints, Steuern, Schmuggel oder Verträge;
- Konkurrenz um Rekruten und Informanten;
- Familien-, Patronage- und Stammeskontakte;
- lokale Waffenruhe;
- spontane Zusammenarbeit oder bewaffneter Konflikt;
- Verhalten einzelner ANA-, ANP- oder RED-Kommandeure.

Ein positives strategisches Verhältnis verhindert keinen lokalen Konflikt. Lokale Kooperation beweist keine strategische Allianz.

## 4. ISAF und Afghan State

### 4.1 Grundbeziehung

```text
RELATIONSHIP_TYPE = ALLIED_BUT_AUTONOMOUS_PARTNERS
```

ISAF und Afghan State sind gegen RED ausgerichtet, besitzen aber getrennte:

```text
FORCE_PACKAGE_OWNERSHIP
RESOURCE_ACCOUNTS
COMMANDER_VIEWS
OPERATION_AUTHORITY
LOSS_ASSESSMENT
POLITICAL_PRIORITIES
SUCCESS_CONDITIONS
```

### 4.2 Ausgangsdimensionen

Die Werte sind Simulationsstartbereiche, keine historischen Messwerte.

```yaml
isaf_to_afghan_state:
  formal_alignment: 85..100
  political_alignment: 65..90
  political_trust: 45..80
  operational_trust: 45..80
  intelligence_sharing_willingness: 45..85
  finance_support_willingness: 70..100
  materiel_support_willingness: 70..100
  training_support_willingness: 80..100
  enabler_support_willingness: 65..95
  enabler_dependency: 10..35
  command_friction: 20..60
  transition_pressure: 50..90
  perceived_respect_for_sovereignty: 45..85

afghan_state_to_isaf:
  formal_alignment: 85..100
  political_alignment: 60..90
  political_trust: 40..80
  operational_trust: 50..85
  intelligence_sharing_willingness: 35..80
  finance_support_dependency: 75..100
  materiel_support_dependency: 65..95
  training_support_dependency: 70..100
  enabler_dependency: 60..95
  command_friction: 20..65
  transition_pressure: 35..80
  perceived_respect_for_sovereignty: 35..80
```

Das YAML-Feld `finance_support_dependency` ist eine gerichtete Beziehungsdimension und keine ResourceAccount-Größe.

### 4.3 Typische Friktionen

```text
ISAF seeks measurable progress
AFGHAN_STATE may prioritize force preservation and local balance
```

```text
ISAF seeks rapid transition
AFGHAN_STATE may request continued enablers
```

```text
ISAF seeks corruption control
AFGHAN_STATE actors may depend on patronage arrangements
```

```text
ISAF offers support
AFGHAN_STATE retains approval and command authority over its forces
```

### 4.4 Partneroperationen

Zulässige Beziehungen:

```text
COALITION_LED
PARTNERED
AFGHAN_LED_WITH_COALITION_ENABLERS
AFGHAN_LED_ADVISED
AFGHAN_INDEPENDENT
```

Jede Partneroperation benötigt:

- Lead-Faction;
- Eigentümer der Force Packages;
- Partnerzustimmung;
- vereinbarte Enabler;
- getrennte Resource Reservations;
- Command Relationship;
- Abbruchrechte;
- Ergebnis- und Verlustzuordnung.

## 5. Afghan State und RED

Diese Beziehungen sind nicht nur militärische Feindschaft. Afghan State und RED konkurrieren um:

```text
RECRUITABLE_MANPOWER
FINANCE_FROM_LOCAL_OR_STATE_SOURCES
MATERIEL
ROUTE_AND_CHECKPOINT_ACCESS
LOCAL_COMMANDERS
POPULATION_ACCESS
INFORMATION
POLITICAL_LEGITIMACY
```

### 5.1 Afghan State gegenüber Taliban

```yaml
afghan_state_to_taliban:
  formal_alignment: 0..10
  political_trust: 0..20
  operational_trust: 0..15
  territorial_competition: 70..100
  recruitment_competition: 65..100
  revenue_competition: 70..100
  materiel_competition: 55..95
  political_representation_competition: 80..100
  conflict_risk: 70..100
  negotiation_channel_quality: 10..60
```

Verhandlungskanäle können trotz Feindschaft bestehen. Sie erzeugen keine automatische Anerkennung oder Waffenruhe.

### 5.2 Taliban gegenüber Afghan State

Taliban betrachtet den Afghan State regelmäßig zugleich als:

- militärischen Gegner;
- konkurrierenden Herrschafts- und Justizanspruch;
- konkurrierenden Rekrutierungsakteur;
- Inhaber staatlicher Finance- und Materielquellen;
- mögliches Ziel politischer Delegitimierung;
- möglichen Verhandlungs- oder Reintegrationskanal für lokale Akteure.

### 5.3 Afghan State und Haqqani

Schwerpunkte:

```text
route and facilitation denial
network disruption
intelligence competition
materiel and external-support interdiction
selected local access competition
```

Haqqani benötigt nicht zwingend flächendeckende politische Kontrolle. Afghan State kann deshalb territoriale Präsenz verbessern, ohne automatisch das Netzwerk zu beseitigen.

### 5.4 Afghan State und HIG

Zusätzliche Besonderheiten:

- politische Kontakte und frühere Parteiverbindungen;
- lokale Absprachen;
- Defektion und Kooptation;
- unklare Vertretungsbefugnis;
- Konkurrenz um lokale Commander und Patronage;
- mögliche Teilintegration einzelner Akteure ohne Auflösung der Gesamtfraktion.

## 6. RED-Ausgangsprofile 2010–2011

Die folgenden Werte sind Simulationsstartbereiche.

### 6.1 Taliban gegenüber Haqqani

```yaml
taliban_to_haqqani:
  formal_alignment: 75..95
  ideological_alignment: 65..90
  political_trust: 55..80
  operational_trust: 60..85
  intelligence_sharing_willingness: 45..75
  logistics_cooperation_willingness: 50..80
  joint_operation_willingness: 50..80
  territorial_competition: 15..50
  recruitment_competition: 10..45
  revenue_competition: 15..45
  external_support_competition: 20..60
  prestige_competition: 30..65
  dependency: 20..55
  conflict_risk: 5..30
```

Taliban kann Haqqani als leistungsfähigen, formal verbundenen, aber eigenständigen Partner betrachten.

### 6.2 Haqqani gegenüber Taliban

```yaml
haqqani_to_taliban:
  formal_alignment: 75..95
  ideological_alignment: 65..90
  political_trust: 50..80
  operational_trust: 60..85
  intelligence_sharing_willingness: 35..70
  logistics_cooperation_willingness: 45..80
  joint_operation_willingness: 50..85
  territorial_competition: 10..45
  recruitment_competition: 5..35
  revenue_competition: 10..40
  external_support_competition: 20..65
  prestige_competition: 35..70
  dependency: 15..50
  fear_of_betrayal: 15..45
  conflict_risk: 5..25
```

Hohe operative Kooperation führt nicht automatisch zu vollständiger Informationsteilung oder gemeinsamer Ressourcenkontrolle.

### 6.3 Taliban gegenüber HIG

```yaml
taliban_to_hig:
  formal_alignment: 10..35
  ideological_alignment: 35..65
  political_trust: 10..35
  operational_trust: 15..45
  intelligence_sharing_willingness: 5..35
  logistics_cooperation_willingness: 10..45
  joint_operation_willingness: 15..55
  territorial_competition: 40..85
  recruitment_competition: 35..75
  revenue_competition: 40..85
  materiel_competition: 20..65
  political_representation_competition: 45..90
  grievance_level: 20..70
  conflict_risk: 25..75
```

### 6.4 HIG gegenüber Taliban

```yaml
hig_to_taliban:
  formal_alignment: 5..30
  ideological_alignment: 30..60
  political_trust: 5..30
  operational_trust: 10..40
  intelligence_sharing_willingness: 5..30
  logistics_cooperation_willingness: 10..40
  joint_operation_willingness: 15..50
  territorial_competition: 45..90
  recruitment_competition: 40..80
  revenue_competition: 45..90
  patronage_competition: 50..95
  political_representation_competition: 55..95
  grievance_level: 25..75
  fear_of_betrayal: 35..80
  conflict_risk: 30..80
```

### 6.5 Haqqani und HIG

Die direkte Quellenlage ist schwächer.

```text
DEFAULT_RELATIONSHIP = PRAGMATIC_UNCERTAINTY
```

```yaml
haqqani_to_hig:
  political_trust: 10..45
  operational_trust: 15..50
  joint_operation_willingness: 10..55
  territorial_competition: 15..65
  recruitment_competition: 10..55
  revenue_competition: 15..65
  prestige_competition: 20..60
  conflict_risk: 15..60
  negotiation_channel_quality: 20..65

hig_to_haqqani:
  political_trust: 10..40
  operational_trust: 10..45
  joint_operation_willingness: 10..50
  territorial_competition: 15..65
  recruitment_competition: 10..60
  revenue_competition: 15..65
  fear_of_betrayal: 25..70
  conflict_risk: 15..65
  negotiation_channel_quality: 20..65
```

## 7. Regionale Beziehungsinstanzen

```yaml
regional_relationship:
  region_id: string
  actor_id: string
  counterpart_id: string
  local_commander_relationship: 0..100
  active_deconfliction: true|false
  shared_route_use: 0..100
  shared_safehaven_use: 0..100
  territorial_dispute: 0..100
  resource_source_dispute: 0..100
  tax_or_revenue_dispute: 0..100
  recruitment_dispute: 0..100
  materiel_dispute: 0..100
  recent_cooperation: 0..100
  recent_violence: 0..100
  mediator_present: true|false
  local_agreement_ids: []
```

## 8. Verhandlungskanäle

Verhandlungen benötigen einen tatsächlichen Kanal.

```text
DIRECT_COMMANDER_CHANNEL
FORMAL_LIAISON
TRUSTED_EMISSARY
RELIGIOUS_MEDIATOR
LOCAL_ELDER
FAMILY_OR_PATRONAGE_CONTACT
POLITICAL_INTERMEDIARY
EXTERNAL_SPONSOR_CHANNEL
FIELD_COMMANDER_CONTACT
```

```yaml
negotiation_channel:
  channel_id: string
  participants: []
  channel_type: string
  reliability: 0..100
  secrecy: 0..100
  latency_hours: number
  distortion_risk: 0..100
  compromise_risk: 0..100
  mediator_bias: 0..100
  active: true|false
```

Ohne Kanal kann kein Commander direkt mit einem anderen kommunizieren.

## 9. Verhandlungsgegenstände

```text
INFORMATION_EXCHANGE
TRANSIT_ACCESS
SAFEHOUSE_ACCESS
ROUTE_DECONFLICTION
TEMPORARY_AREA_DECONFLICTION
FINANCE_TRANSFER
MATERIEL_TRANSFER
RESOURCE_SOURCE_SHARE
SPECIALIST_SUPPORT
ENABLER_SUPPORT
TRAINING_SUPPORT
PARTNER_OPERATION
JOINT_OPERATION
REVENUE_SHARING
LOCAL_NON_AGGRESSION
TEMPORARY_TRUCE
MEDIATION_OF_COMMANDER_DISPUTE
WITHDRAWAL_FROM_DISPUTED_AREA
REINTEGRATION_OR_DEFECTION_MATTER
```

Keine Verhandlung kann Population Ownership übertragen.

## 10. Vereinbarungsmodell

```yaml
agreement:
  agreement_id: string
  parties: []
  agreement_type: string
  geographic_scope: []
  valid_from: timestamp
  valid_until: timestamp|null
  public_or_secret: public|secret|partially_disclosed
  obligations: []
  benefits: []
  resource_transfer_refs: []
  partner_force_refs: []
  enabler_refs: []
  verification_method: []
  breach_conditions: []
  termination_conditions: []
  mediator_id: string|null
  confidence_in_counterpart_compliance: 0..100
  campaign_state: proposed|negotiating|active|suspended|breached|expired|terminated
```

```yaml
obligation:
  obligation_id: string
  responsible_party: string
  action: string
  deadline: timestamp|null
  resource_ceiling: {}
  ownership_boundary: string|null
  verification: string
  fulfilled: true|false|unknown
```

## 11. Ressourcen- und Unterstützungssemantik

### 11.1 Resource Transfer

Nur folgende gemeinsamen Grundressourcen werden als ResourceAccount-Transfer gebucht:

```text
FINANCE
MATERIEL
RECRUITABLE_MANPOWER only where explicitly valid
```

Ein Transfer benötigt:

- Quelle und Ziel;
- Menge;
- Eigentumsübergang oder Leihstatus;
- Agreement;
- gegebenenfalls Transportoperation;
- Verlust- und Abbruchregel;
- eindeutige Transfer-ID.

### 11.2 Capability Support

Folgende Unterstützungen sind keine Grundressourcentransfers:

```text
ISR_SUPPORT
MEDEVAC_SUPPORT
CAS_SUPPORT
EOD_SUPPORT
ADVISOR_SUPPORT
SPECIALIST_SUPPORT
AIRLIFT_SUPPORT
```

Sie bleiben Eigentum der bereitstellenden Fraktion oder Organisation und werden zeitlich reserviert.

### 11.3 ResourceSource Share

Eine Vereinbarung kann einen Anteil an einer ResourceSource verändern, aber keine ResourceSource aus dem Nichts erzeugen.

```text
SHARE_CHANGE
!= NEW_RESOURCE
```

## 12. Verhandlungsentscheidung

```text
EXPECTED_BENEFIT
+ PRESSURE_RELIEF
+ RESOURCE_GAIN
+ ACCESS_GAIN
+ CAPABILITY_GAIN
+ RIVAL_CONTAINMENT
+ POLITICAL_GAIN
- BETRAYAL_RISK
- PRESTIGE_COST
- AUTONOMY_COST
- INFORMATION_EXPOSURE
- COUNTERPART_STRENGTHENING
- OPPORTUNITY_COST
```

Zusätzliche Persönlichkeitsmodifikatoren:

- Pragmatismus erhöht die Annahme zweckmäßiger Absprachen.
- ideologische Starrheit reduziert bestimmte Kompromisse.
- Misstrauen erhöht Verifikationsanforderungen.
- Prestigeempfindlichkeit erschwert einseitig wirkende Zugeständnisse.
- politische Sensibilität kann eine militärisch günstige, politisch schädliche Vereinbarung verhindern.
- Souveränitätssensibilität beeinflusst Afghan-State-Reaktionen auf ISAF-Vorgaben.

## 13. Informationsaustausch

```yaml
shared_information:
  sender: string
  receiver: string
  knowledge_ids: []
  fidelity: 0..100
  intentional_omissions: []
  intentional_distortion: 0..100
  attribution: confirmed|claimed|anonymous
  sharing_restrictions: []
  expiry: timestamp|null
```

```text
SAME_DCS_COALITION
!= SHARED_INFORMATION_DATABASE
```

## 14. Gemeinsame und Partneroperationen

```yaml
joint_or_partner_operation:
  operation_id: string
  participants: []
  lead_faction: string
  supporting_factions: []
  shared_objective: string
  individual_objectives: {}
  force_package_contributions: {}
  capability_contributions: {}
  resource_contributions: {}
  ownership_boundaries: {}
  command_relationships: {}
  information_sharing_scope: []
  deconfliction_rules: []
  credit_sharing_rule: string
  abort_rights: {}
  withdrawal_rules: []
  betrayal_or_control_failure_risk: 0..100
  status: proposed|assembling|ready|executing|complete|failed|aborted|disputed
```

Jeder Teilnehmer behält:

- eigene Kräfte;
- eigene Ressourcenbuchung;
- eigenes Lagebild;
- eigenes Abbruchrecht;
- eigene Bewertung des Ergebnisses.

## 15. Verdeckte Ziele

Zulässige abstrakte versteckte Ziele:

```text
TEST_COUNTERPART_RELIABILITY
GAIN_ROUTE_ACCESS
OBSERVE_COUNTERPART_CAPABILITY
SHIFT_COSTS_TO_COUNTERPART
CLAIM_DISPROPORTIONATE_CREDIT
WEAKEN_LOCAL_RIVAL
CREATE_FUTURE_DEPENDENCY
PROTECT_AUTONOMY
```

Verdeckte Ziele dürfen keine technischen Anleitungen oder direkte Umgehung von Validatoren enthalten.

## 16. Deconfliction ohne Kooperation

```yaml
deconfliction_measure:
  area: []
  time_window: {}
  restricted_actions: []
  communication_procedure: string
  identification_method: string
  violation_response: string
```

Beispiele:

- getrennte Operationsfenster;
- unterschiedliche Routen;
- keine gleichzeitige Nutzung eines AccessNodes;
- keine Rekrutierung in einem definierten Netzwerk;
- abgestimmte Rückzugs- oder Unterstützungsfenster.

## 17. Konkurrenz um gemeinsame Ressourcen

### 17.1 Recruitable Manpower

Afghan State, Taliban, Haqqani und HIG können um regionale Anteile konkurrieren. ISAF rekrutiert daraus keine Eigenkräfte.

### 17.2 Finance

Konkurrenz kann bestehen um:

- formale staatliche Einnahmen;
- lokale Wirtschaftszuflüsse;
- illegale Einnahmen;
- externe RED-Unterstützung;
- internationale Unterstützung für Afghan State.

Nicht jede Fraktion ist für jede Quelle zulässig.

### 17.3 Materiel

Materiel kann:

- übertragen;
- erbeutet;
- umgeleitet;
- zerstört;
- verloren;
- zwischen RED-Fraktionen umkämpft werden.

## 18. Eskalationsleiter

```text
POLITICAL_DISPUTE
RESOURCE_OR_ACCESS_DISPUTE
WITHHOLD_SUPPORT
LOCAL_OBSTRUCTION
PUBLIC_ACCUSATION
TARGETED_PRESSURE
LOCALIZED_CLASH
SUSTAINED_LOCAL_CONFLICT
BROADER_RELATIONSHIP_BREAKDOWN
```

ISAF/Afghan-State-Friktion verwendet zusätzlich:

```text
PARTNER_DISAGREEMENT
SUPPORT_DELAY
PARTNER_REFUSAL
COMMAND_RELATIONSHIP_DISPUTE
TRANSITION_DISPUTE
POLITICAL_ESCALATION
```

Sie führt nicht automatisch zu bewaffnetem Konflikt.

## 19. Beziehungsereignisse

```text
INFORMATION_SHARED
INFORMATION_WITHHELD
FINANCE_SUPPORT_OFFERED
MATERIEL_SUPPORT_OFFERED
TRAINING_SUPPORT_OFFERED
PARTNER_OPERATION_REQUESTED
PARTNER_OPERATION_ACCEPTED
PARTNER_OPERATION_DECLINED
AGREEMENT_FULFILLED
AGREEMENT_BREACHED
CONTROL_FAILURE_REPORTED
RESOURCE_SOURCE_SHARE_CHANGED
RESOURCE_TRANSFER_LOST
LOCAL_CLASH
PUBLIC_CREDIT_DISPUTE
TRANSITION_PRESSURE_CHANGED
SOVEREIGNTY_GRIEVANCE_CHANGED
```

## 20. Testfälle

```text
REL-001 ISAF requests Afghan-led operation
REL-002 Afghan State rejects operation without enablers
REL-003 ISAF materiel transfer preserves Afghan ownership
REL-004 classified information is only partially shared
REL-005 Taliban and HIG compete for regional manpower
REL-006 Haqqani gains larger external support share
REL-007 local RED non-aggression does not create strategic alliance
REL-008 HIG agreement fails through local control failure
REL-009 Taliban-Haqqani joint operation retains separate resources
REL-010 physical checkpoint control does not guarantee full revenue share
REL-011 same DCS coalition does not permit direct force tasking
REL-012 duplicate transfer result does not create second credit
```

## 21. Acceptance-Kriterien

Das Modell ist akzeptiert, wenn:

- alle gerichteten Beziehungen der fünf Fraktionen persistieren können;
- ISAF und Afghan State als verbündete, aber autonome Partner behandelt werden;
- Afghan-State-/RED-Konkurrenz nicht auf reine Feindschaft reduziert wird;
- RED-Konkurrenz um ResourceSources und Zugangsanteile abbildbar ist;
- Finance-/Materiel-Transfers von Capability Support getrennt sind;
- Partneroperationen Eigentum und Befehlsgewalt nicht vermischen;
- Agreements zeitlich, regional und überprüfbar sind;
- lokale Kooperation keine strategische Allianz erzeugt;
- Beziehungsänderungen event-sourced und reproduzierbar sind.

## 22. Querverweise

```text
02-common-commander-model.md
07-runtime-rulebook-and-action-schema.md
08-commander-memory-belief-and-information-model.md
09-orchestrator-architecture-and-adjudication.md
13-campaign-state-and-event-store-schema.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```
