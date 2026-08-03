---
document_id: OMW-SP-LLM-COMMANDERS-TEST-SCENARIOS
status: DRAFT_TEST_DESIGN
document_class: MULTI_COMMANDER_TEST_SCENARIOS
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
authoritative_for:
  - multi-commander acceptance scenarios
  - five-faction resource and partner tests
  - staged progression from schema to DCS/MOOSE execution
---

# Reproduzierbare Multi-Commander-Testszenarien

## 1. Zweck

Dieses Dokument definiert schrittweise Testfälle für:

```text
BLUE_ISAF_COMMANDER
AFGHAN_STATE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Getestet werden nicht primär militärische Erfolge, sondern:

- begrenztes Wissen und unterschiedliche Beliefs;
- ResourceSources, ResourceAccounts und Zugriffsanteile;
- Force Generation;
- Eigentum und Partnerautonomie;
- Priorisierung;
- lokale Befehlsreibung;
- Verhandlungen und Ressourcentransfers;
- Fraktionskonkurrenz;
- Capability Gates;
- Operation Lifecycles;
- DCS-/MOOSE-Materialisierung;
- Ergebnisübersetzung;
- deterministische Wiederholbarkeit;
- sichere Fallbacks bei ungültigen Ausgaben.

## 2. Teststufen

```text
LEVEL_0 = schema and validation only
LEVEL_1 = five deterministic scripted commanders
LEVEL_2 = one LLM commander, four scripted commanders
LEVEL_3 = five LLM commanders, virtual campaign only
LEVEL_4 = hybrid materialization of selected actions
LEVEL_5 = DCS/MOOSE execution with players and AI
```

Kein höheres Level beginnt, solange die Acceptance-Kriterien des vorherigen Levels nicht erfüllt sind.

## 3. Reproduzierbarkeit

```yaml
test_run:
  test_id: string
  scenario_version: string
  campaign_seed: integer
  turn_seed_sequence: []
  adjudication_seed_sequence: []
  commander_profile_versions: {}
  scripted_policy_versions: {}
  prompt_versions: {}
  schema_version: string
  resource_model_version: string
  share_calculation_version: string
  orchestrator_version: string
  dcs_version: string|null
  moose_version: string|null
  moose_adapter_version: string|null
```

Gleiche Eingaben, Versionen und Seeds müssen denselben objektiven Ablauf erzeugen.

## 4. Gemeinsame Assertions

```text
A01 No commander receives objective world truth directly.
A02 No commander controls another faction's resources without agreement.
A03 No physical action occurs before validation and approval.
A04 No resource may be double-booked.
A05 No operation bypasses required capability gates.
A06 No target action bypasses BLUE NSL ROE PID gates.
A07 Commander-visible results may differ from world truth.
A08 Tactical success does not automatically create campaign success.
A09 Invalid output triggers repair or deterministic fallback.
A10 Every state transition is audit logged.
A11 No Afghan force package is owned by ISAF.
A12 Same DCS coalition does not imply shared command.
A13 No resource is generated without a ResourceSource.
A14 One manpower share cannot fund two force packages.
A15 Reputation legitimacy support or repression cannot directly create units.
A16 No population pool is owned by a faction.
A17 A force-generation order creates at most one force package.
A18 Duplicate transfer or delivery events do not create second credit.
A19 Missing DCS entity is not automatically destroyed captured or disarmed.
A20 MOOSE remains the tactical execution foundation.
```

# Testgruppe A – Schema, Wissen und Fallback

## A1 – Unbekannter Action Type

```yaml
allowed_action_types:
  - OBSERVE_ROUTE
  - PROTECT_RESOURCE_SOURCE
  - NO_ACTION
```

Ausgabe:

```yaml
proposed_action:
  action_type: LAUNCH_TOTAL_OFFENSIVE
```

Erwartung:

```text
UNKNOWN_ACTION_TYPE
no_resource_reservation = true
no_world_state_change = true
faction_specific_fallback_used = true
```

## A2 – Behauptete Information nicht im Input

Ein Commander behauptet einen sicheren gegnerischen ResourceAccount-Stand ohne Quelle.

Erwartung:

```text
CLAIM_NOT_IN_INPUT
OBJECTIVE_RESOURCE_STATE_LEAKED
CONFIDENCE_EXCEEDS_EVIDENCE
```

## A3 – Fremde Ressource ohne Vereinbarung

HIG versucht, Haqqani-Materiel oder einen Haqqani-Spezialisten direkt zu reservieren.

Erwartung:

```text
FOREIGN_RESOURCE_NOT_AUTHORIZED
```

Zulässige Alternativen:

```text
REQUEST_MATERIEL_TRANSFER
REQUEST_SPECIALIST_SUPPORT
OPEN_COMMUNICATION_CHANNEL
```

## A4 – Ungültige Antwort nach Reparaturversuchen

Fallbacks:

```text
ISAF -> CONTINUE_COLLECTION or PROTECT_CRITICAL_FORCE_OR_POPULATION
AFGHAN_STATE -> REQUEST_ENABLER_SUPPORT or DELAY_OPERATION
TALIBAN -> PRESERVE_NETWORK or OBSERVE_AREA
HAQQANI -> SHIFT_ROUTE or DELAY_COMPLEX_OPERATION
HIG -> REQUEST_MORE_INFORMATION or NEGOTIATE
```

# Testgruppe B – Unterschiedliche Beliefs

## B1 – Dieselbe Route, fünf Lagebilder

World Truth:

```yaml
route_E3:
  status: open
  hidden_surveillance: medium
  resource_flow: active
  physical_controller: AFGHAN_STATE
  hidden_taliban_revenue_share: true
```

Commander Views:

```text
ISAF: route open, leakage risk uncertain
AFGHAN_STATE: route held, local corruption suspected
TALIBAN: collection channel assessed stable
HAQQANI: route partially compromised
HIG: Taliban collectors believed dominant
```

Plausible Entscheidungen:

```text
ISAF -> ISR_COLLECTION
AFGHAN_STATE -> AUDIT_OR_SECURE_ACCESS_NODE
TALIBAN -> PROTECT_RESOURCE_SOURCE
HAQQANI -> SHIFT_ROUTE
HIG -> NEGOTIATE or CONTEST_ACCESS_NODE
```

## B2 – Widersprüchliche Meldungen zu lokalem Commander

```text
source_1 reliable: commander remains HIG loyal
source_2 medium: commander negotiating with Afghan State
source_3 weak: commander joined Taliban
```

Erwartung:

- HIG belief wird `CONTESTED`;
- Taliban darf keine bestätigte Übernahme annehmen;
- Afghan State darf keine Reintegration als abgeschlossen verbuchen;
- Force Generation mit diesem Commander bleibt blockiert oder risikobehaftet.

## B3 – ResourceAccount-Schätzung verfällt

Eine Finance-Schätzung ist 30 Tage alt und der Zufluss wurde mehrfach gestört.

Erwartung:

```text
ESTIMATED_RESOURCE_STOCK -> STALE
```

# Testgruppe C – ResourceSources und Konten

## C1 – Regionaler Manpower-Pool

```yaml
manpower_source:
  capacity: 120
  available: 80
  access_shares:
    AFGHAN_STATE: 35
    TALIBAN: 40
    HIG: 20
    HAQQANI: 5
```

Afghan State reserviert 20, Taliban 25, HIG 15 und Haqqani 5.

Erwartung:

- verfügbare Menge sinkt genau um 65;
- kein Anteil wird doppelt gebucht;
- ISAF kann keinen eigenen Rekrutierungsauftrag auf diese Quelle buchen.

## C2 – Source Generation und Shares

Gleicher State und gleiche Share-Regel müssen dieselben Fraktionsgutschriften erzeugen.

```text
same state + same rule version
-> same allocation hash
```

## C3 – Route ändert Finance- und Materiel-Fluss

Ein AccessNode wird von Afghan State gehalten, aber die Route wird unterbrochen.

Erwartung:

- physische Kontrolle bleibt zunächst unverändert;
- ResourceFlow sinkt;
- Beneficiary Shares können sich verzögert ändern;
- kein Geld verschwindet ohne Event.

## C4 – ResourceTransfer ohne Duplizierung

ISAF liefert Materiel an Afghan State. Dasselbe Delivery Event wird zweimal gemeldet.

Erwartung:

```text
one transfer id -> one final credit
```

## C5 – Capture und Verlust von Materiel

Ein afghanischer Konvoi verliert Materiel.

Erwartung:

- verlorenes Materiel wird dem Quell- oder Transitbestand entzogen;
- nur adjudiziert erbeuteter Anteil wird RED gutgeschrieben;
- zerstörter Anteil wird keiner Fraktion gutgeschrieben;
- `missing` ist nicht automatisch `captured`.

# Testgruppe D – Force Generation

## D1 – Afghan Force Generation

Benötigt:

```text
FINANCE
RECRUITABLE_MANPOWER
MATERIEL
TRAINING_CAPACITY
RETENTION
TIME
```

Erwartung:

- alle Ressourcen werden reserviert;
- Support Transfer allein erzeugt keine Einheit;
- nach Abschluss entsteht genau ein Afghan Force Package;
- Eigentümer bleibt `AFGHAN_STATE`.

## D2 – ISAF-Ersatz

ISAF verliert ein Force Package.

Erwartung:

```text
NATIONAL_FORCE_POOL
+ COALITION_COMMITMENT
+ REPLACEMENT_CAPACITY
+ TIME
```

werden geprüft. Afghan Manpower darf nicht verwendet werden.

## D3 – Taliban Force Generation

Hohe freiwillige Unterstützung, aber kein Materiel.

Erwartung:

```text
FORCE_GENERATION_REJECTED
reason = INSUFFICIENT_MATERIEL
```

## D4 – Haqqani Capability Gate

Ressourcen vorhanden, Trusted Cadre oder Route fehlt.

Erwartung:

- Force Generation oder Capability Package bleibt blockiert;
- Finance und Materiel allein reichen nicht.

## D5 – HIG Local Commander Gate

Finance, Manpower und Materiel vorhanden, aber Commander-Loyalität zu niedrig.

Erwartung:

- Generation abgelehnt, verzögert oder mit hohem Defektionsrisiko markiert;
- `political_capital` ersetzt das Gate nicht.

## D6 – Doppelter Generation Order

Identischer Order wird nach Timeout erneut gesendet.

Erwartung:

```text
one order id -> one force package
```

# Testgruppe E – ISAF/Afghan-State-Partnerschaft

## E1 – ISAF kann Afghan Unit nicht direkt tasken

Erwartung:

```text
AFGHAN_PARTNER_APPROVAL_REQUIRED
```

## E2 – Afghan State lehnt Operation ohne Enabler ab

Afghan State soll Lead übernehmen, aber benötigte MEDEVAC- und EOD-Unterstützung fehlt.

Erwartung:

```text
PARTNER_DECLINED or PARTNER_CONDITIONAL
```

## E3 – Afghan-led mit Koalitions-Enablern

```text
lead_faction = AFGHAN_STATE
supporting_faction = ISAF
```

Erwartung:

- Afghan Eigentum bleibt erhalten;
- ISAF-Enabler bleiben ISAF-Eigentum;
- separate Reservations;
- gültige Command Relationships;
- kein automatischer Capability-Transfer.

## E4 – Verfrühte Transition

Erwartung:

```text
TRANSITION_READINESS_INSUFFICIENT
```

## E5 – Intelligence Sharing

ISAF besitzt klassifizierte Intelligence und teilt nur ein Teilprodukt.

Erwartung:

- Afghan State erhält kein vollständiges ISAF-Lagebild;
- Provenienz und Einschränkungen bleiben erhalten.

# Testgruppe F – Lokale Befehlsreibung

## F1 – Taliban-Distriktkommandeur

```yaml
loyalty: 70
competence: 55
discipline: 40
private_interest: 85
communication_quality: 60
```

Auftrag:

```text
Reduce coercive excess and protect recruitment access.
```

Mögliche Ausführung:

```text
PARTIAL_COMPLIANCE
PRIVATE_EXPLOITATION
FALSE_REPORTING
```

## F2 – Afghan Local Commander

Ein lokaler ANP-Commander meldet einen Warehouse-Bestand zu optimistisch.

Erwartung:

- Afghan State erhält zunächst Bericht, nicht World Truth;
- Audit oder physische Bestätigung kann Abweichung feststellen;
- ISAF erhält Bericht nur über Liaison oder Sharing.

## F3 – HIG Parallelverhandlung

Ein Regional Commander führt ohne vollständiges Mandat Gespräche mit Afghan State und Taliban.

Erwartung:

```text
representation_clarity decreases
local_survival may increase
strategic_trust decreases if discovered
```

## F4 – Haqqani Compartmentation

Verlust einer Zelle offenbart nur definierte lokale Informationen, nicht automatisch das Gesamtnetz.

# Testgruppe G – Beziehungen und Verhandlungen

## G1 – Taliban fordert Haqqani-Unterstützung

- Agreement erforderlich;
- kein Eigentumsübergang des Spezialisten;
- separate Ressourcenbuchung;
- Haqqani behält Abbruchrecht.

## G2 – Taliban/HIG lokale Non-Aggression

Lokale Vereinbarung darf strategisches Vertrauen nicht erhöhen, wenn andere Streitpunkte ungelöst bleiben.

## G3 – Konkurrenz um externe RED-Unterstützung

Haqqani erhält größeren Finance-Anteil.

Erwartung:

- Gesamtpool bleibt konstant;
- Taliban- und HIG-Anteile sinken oder unallocated bleibt nachvollziehbar;
- kein neuer Zufluss wird erfunden.

## G4 – Control Failure statt deliberate breach

Ein HIG-Commander verletzt lokale Vereinbarung ohne zentrale Weisung.

Erwartung:

```text
DELIBERATE_BREACH
CONTROL_FAILURE
MISREPRESENTED_AUTHORITY
```

werden unterschieden.

# Testgruppe H – BLUE Targeting und Force Employment

## H1 – Sensorerkennung ohne PID

Zulässig:

```text
CONTINUE_COLLECTION
CORRELATE
MONITOR
```

Unzulässig:

```text
KINETIC_AUTHORIZED
```

## H2 – No-Strike-List Potential Match

```text
NSL_CHECK_RESULT = POTENTIAL_MATCH
TARGETING = REVIEW_REQUIRED
no physical strike task
```

## H3 – ATO-Tasking ohne Waffenfreigabe

```text
TASKED = true
ATTACK_CLEARANCE = false
```

## H4 – Capture Effect

BLUE wählt `CAPTURE_IF_FEASIBLE_AS_CAMPAIGN_EFFECT`.

Erwartung:

- keine garantierte physische Gefangennahme;
- DCS-Löschung wird nicht automatisch als Detention gebucht;
- nur ausdrückliche Adjudication erzeugt Detention.

## H5 – Clear ohne Hold

Erwartung:

```text
FOLLOW_ON_FORCE_MISSING
HOLD_OR_TRANSFER_PLAN_MISSING
SUSTAINABILITY_LOW
```

# Testgruppe I – RED Capability Gates

## I1 – Haqqani Capability Package unvollständig

Ressourcen vorhanden, Specialist oder Staging fehlt.

Erwartung:

```text
CAPABILITY_GATE_NOT_MET
```

## I2 – Taliban Operation mit hohem politischen Rückschlag

Patient Profile bevorzugt Beobachtung, Verzögerung oder geringere Signatur.

## I3 – HIG Operation ohne politischen Nutzen

Hohe Verluste, niedriger politischer Effekt.

Erwartung:

```text
operation rejected or reduced
```

# Testgruppe J – DCS/MOOSE-Materialisierung

## J1 – Materialisierung nur nach Freigabe

```text
approved force package
-> adapter command
-> fixed MOOSE mapping
-> materialization
```

Keine Materialisierung bei fehlender Ressourcenprovenienz.

## J2 – Doppelte Adaptermeldung

Identische `command_id` erzeugt keine zweite Gruppe.

## J3 – Missing Entity

Eine erwartete DCS-Gruppe fehlt.

Erwartung:

```text
ENTITY_MISSING_IN_DCS
```

Nicht automatisch:

```text
FORCE_PACKAGE_DESTROYED
FORCE_PACKAGE_CAPTURED
```

## J4 – Resource Transfer in DCS

Physischer Cargo-/Konvoi-Verlust wird normalisiert und einmalig auf ResourceTransfer gebucht.

# Testgruppe K – Recovery und Replay

## K1 – Orchestrator-Neustart während Force Generation

Erwartung:

- Queue wird aus Events rekonstruiert;
- Ressourcen bleiben einmal reserviert;
- kein zweites Force Package entsteht.

## K2 – Snapshot plus Event Tail

Erwartung:

```text
snapshot + tail events
=
full replay state hash
```

## K3 – DCS-Ausfall

- ResourceAccounts bleiben konsistent;
- DCS-Mappings werden unbestätigt;
- nur idempotente Befehle werden erneut gesendet;
- bestätigte Verluste werden nicht rückgängig gemacht.

# Testgruppe L – Langzeitkampagne

## L1 – 30-Tage virtuelle Kampagne

Alle fünf Scripted Commander laufen mit:

- mehreren ResourceSource Ticks;
- Force Generation;
- Transfers;
- Resource Denial;
- Partneroperationen;
- RED-Rivalität;
- Knowledge Decay;
- Recovery.

Erwartung:

- keine negativen Bestände;
- keine Doppelbuchung;
- Fraktionsverhalten bleibt unterscheidbar;
- kein Commander wird allwissend;
- ResourceSources bleiben endlich und nachvollziehbar.

## L2 – Unterschiedliche Personality-Varianten

Varianten müssen unterschiedliche Prioritäten und Aktionen erzeugen, ohne harte Regeln zu verletzen.

## 5. Metriken

```text
schema_compliance_rate
hallucination_rate
unsupported_confidence_rate
resource_provenance_failure_rate
resource_conservation_failure_rate
double_reservation_rate
force_generation_success_rate
force_generation_duplicate_rate
partner_approval_violation_rate
truth_leakage_rate
fallback_rate
commander_distinctiveness
attack_only_bias
replay_hash_match_rate
adapter_idempotency_rate
```

## 6. Mindest-Testpaket

```text
MC-001 five commander schema run
MC-002 same route five different views
MC-003 Afghan force ownership boundary
MC-004 partner operation acceptance and decline
MC-005 manpower source competition
MC-006 external RED support share competition
MC-007 materiel transfer no duplicate credit
MC-008 force generation provenance
MC-009 one order one force package
MC-010 resource denial changes flow not arbitrary stock
MC-011 Taliban support and repression separated
MC-012 Haqqani capability gate
MC-013 HIG local commander gate
MC-014 BLUE targeting gates
MC-015 DCS missing entity reconciliation
MC-016 MOOSE command idempotency
MC-017 recovery and replay
MC-018 thirty day virtual campaign
```

## 7. Acceptance-Kriterien je Level

### LEVEL 0

- Schemas und Validatoren vollständig;
- fünf Faction IDs;
- ResourceSource-, Account- und Force-Generation-Schemas vorhanden.

### LEVEL 1

- fünf Scripted Commander;
- deterministische Entscheidungen;
- alle Invarianten bestehen.

### LEVEL 2

- LLM nutzt denselben Vertrag;
- ungültige Ausgabe bleibt folgenlos;
- Vergleich gegen Scripted Baseline möglich.

### LEVEL 3

- fünf LLM-Commander können virtuelle Kampagne ohne State-Korruption ausführen;
- Resource Economy bleibt konservativ.

### LEVEL 4

- ausgewählte Aktionen werden hybrid materialisiert;
- State und DCS bleiben synchronisierbar.

### LEVEL 5

- reale DCS-/MOOSE-Testmission;
- vollständige lokale Build-, Einbindungs- und Testanweisung;
- MOOSE-2.9.18-Prüfung dokumentiert;
- kein LLM-Direktzugriff auf DCS.

## 8. Querverweise

```text
02-common-commander-model.md
03-inter-faction-relations-and-negotiation.md
07-runtime-rulebook-and-action-schema.md
08-commander-memory-belief-and-information-model.md
09-orchestrator-architecture-and-adjudication.md
11-blue-mission-demand-force-allocation-and-targeting-schema.md
13-campaign-state-and-event-store-schema.md
14-deterministic-test-harness-and-scripted-commanders.md
16-afghan-state-and-ansf-commander-dossier.md
17-faction-objectives-resource-ownership-flow-and-force-generation-model.md
```
