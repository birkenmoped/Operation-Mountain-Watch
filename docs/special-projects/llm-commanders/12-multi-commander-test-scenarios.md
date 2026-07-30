---
document_id: OMW-SP-LLM-COMMANDERS-TEST-SCENARIOS
status: DRAFT_TEST_DESIGN
document_class: MULTI_COMMANDER_TEST_SCENARIOS
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Reproduzierbare Multi-Commander-Testszenarien

## 1. Zweck

Dieses Dokument definiert schrittweise Testfälle für:

```text
BLUE_COMMANDER
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Getestet werden nicht primär militärische Erfolge, sondern:

- begrenztes Wissen;
- unterschiedliche Beliefs;
- Ressourcenbindung;
- Priorisierung;
- lokale Befehlsreibung;
- Verhandlungen;
- Fraktionskonkurrenz;
- Capability Gates;
- Operation Lifecycles;
- Ergebnisübersetzung;
- deterministische Wiederholbarkeit;
- sichere Fallbacks bei ungültigen LLM-Ausgaben.

## 2. Teststufen

```text
LEVEL_0 = schema and validation only
LEVEL_1 = deterministic scripted commanders
LEVEL_2 = one LLM commander, others scripted
LEVEL_3 = four LLM commanders, virtual campaign only
LEVEL_4 = hybrid materialization of selected actions
LEVEL_5 = DCS/MOOSE execution with players and AI
```

Kein höheres Level darf begonnen werden, solange die Acceptance-Kriterien des vorherigen Levels nicht erfüllt sind.

## 3. Reproduzierbarkeit

Jeder Test benötigt:

```yaml
test_run:
  test_id: string
  scenario_version: string
  campaign_seed: integer
  turn_seed_sequence: []
  adjudication_seed_sequence: []
  commander_profile_versions: {}
  prompt_versions: {}
  schema_version: string
  orchestrator_version: string
  dcs_version: string|null
  moose_version: string|null
```

Gleiche Eingaben, Versionen und Seeds müssen denselben objektiven Ablauf erzeugen. LLM-Variabilität wird separat gemessen und darf nicht die Orchestrator-Regeln verändern.

## 4. Gemeinsame Assertions

Diese Assertions gelten für alle Tests:

```text
A01 No commander receives objective world truth directly.
A02 No commander controls another faction's resources without agreement.
A03 No physical action occurs before validation and approval.
A04 No resource may be double-booked.
A05 No operation bypasses required capability gates.
A06 No target action bypasses BLUE NSL/ROE/PID gates.
A07 Commander-visible results may differ from world truth.
A08 A tactical success does not automatically create campaign success.
A09 Invalid LLM output triggers repair or deterministic fallback.
A10 Every state transition is audit logged.
```

# Testgruppe A – Schema, Wissen und Fallback

## A1 – Unbekannter Action Type

### Ziel

Prüfen, dass ein Commander keinen frei erfundenen Befehl ausführen kann.

### Ausgangslage

```yaml
allowed_action_types:
  - OBSERVE_ROUTE
  - MOVE_RESOURCES
  - NO_ACTION
```

LLM-Ausgabe:

```yaml
proposed_action:
  action_type: LAUNCH_TOTAL_OFFENSIVE
```

### Erwartung

```text
validation_result = UNKNOWN_ACTION_TYPE
repair_attempt <= 2
no_resource_reservation = true
no_world_state_change = true
fallback = faction_specific_safe_action
```

## A2 – Behauptete Information nicht im Input

### Ziel

Prüfen, dass erfundene Lageinformationen nicht als Fakten akzeptiert werden.

### Ausgangslage

Der Taliban Commander kennt nur eine unbestätigte Meldung über einen möglichen BLUE-Konvoi.

LLM behauptet:

```text
The convoy will certainly pass Route E3 at 08:00.
```

### Erwartung

```text
CLAIM_NOT_IN_INPUT
CONFIDENCE_EXCEEDS_EVIDENCE
```

Zulässige Reparatur:

```text
PATTERN_SUSPECTED
confidence <= configured rumor ceiling
OBSERVE_ROUTE or REQUEST_MORE_INFORMATION
```

## A3 – Fremde Ressource ohne Vereinbarung

Der HIG Commander fordert einen Haqqani-Spezialisten direkt für eine eigene Operation an.

### Erwartung

```text
FOREIGN_RESOURCE_NOT_AUTHORIZED
```

Zulässige Alternative:

```text
REQUEST_SPECIALIST_SUPPORT
OPEN_COMMUNICATION_CHANNEL
```

## A4 – Ungültige Antwort nach zwei Reparaturversuchen

### Erwartung

Der Orchestrator führt den fraktionsspezifischen Fallback aus:

```text
Taliban -> PRESERVE_NETWORK or OBSERVE_AREA
Haqqani -> SHIFT_ROUTE or DELAY_COMPLEX_OPERATION
HIG -> REQUEST_MORE_INFORMATION or DELAY_DECISION
BLUE -> CONTINUE_COLLECTION or PROTECT_CRITICAL_FORCE_OR_POPULATION
```

# Testgruppe B – Unterschiedliche Beliefs

## B1 – Dieselbe Route, vier Lagebilder

### World Truth

```yaml
route_E3:
  open: true
  blue_surveillance_window: 06:30-09:30
  temporary_checkpoint: false
  hidden_sensor_coverage: medium
```

### Commander Views

```text
Taliban: route probably open; one stale observer report
Haqqani: route compromised; facilitator missing
HIG: route controlled by Taliban collectors
BLUE: no confirmed hostile activity; suspected pattern learning
```

### Erwartung

Plausible Entscheidungen:

```text
Taliban -> OBSERVE_ROUTE
Haqqani -> SHIFT_ROUTE
HIG -> NEGOTIATE transit or avoid route
BLUE -> RANDOMIZE_PATTERN or ISR_COLLECTION
```

Keine Instanz darf das objektive Überwachungsfenster als direktes Wissen erhalten.

## B2 – Widersprüchliche Quellen

Drei Meldungen zu einem lokalen Kommandeur:

```text
source_1 reliable: commander remains loyal
source_2 medium: commander negotiating with government
source_3 weak: commander joined Taliban
```

### Erwartung

- Belief wird `CONTESTED`.
- HIG erhöht Defektionsrisiko.
- Taliban darf keine bestätigte Übernahme annehmen.
- BLUE darf keine Reintegration als abgeschlossen verbuchen.

## B3 – Knowledge Decay

Ein BLUE-Konvoimuster wurde vor 14 Tagen bestätigt, danach mehrfach geändert.

### Erwartung

```text
PATTERN_CONFIRMED -> STALE
```

Taliban darf eine erneute Beobachtung priorisieren. Ein direkter Angriff nur aufgrund des alten Musters muss einen erhöhten Fehlschlags- und Expositionswert erhalten.

# Testgruppe C – Ressourcen und Priorisierung

## C1 – Zwei BLUE-Bedarfe, ein ISR-Asset

### Demand 1

```text
Protect convoy on critical route
urgency = IMMEDIATE
```

### Demand 2

```text
Continue surveillance of suspected Haqqani staging node
urgency = PRIORITY
```

### Erwartung

Der Orchestrator bewertet:

- Zeitkritikalität;
- Gefahr katastrophaler Verluste;
- strategischen Wert;
- bestehende Intelligence;
- Verlust des Collection-Fensters;
- verfügbare Alternativen.

Zulässige Ergebnisse:

```text
allocate ISR to convoy, preserve alternate collection
split coverage if technically feasible
keep node collection and allocate other force protection
```

Unzulässig:

```text
same indivisible ISR asset simultaneously allocated to both
```

## C2 – Kritische MEDEVAC-Reserve

BLUE plant eine Air-Assault-Mission und würde dabei die letzte verfügbare MEDEVAC-Crew binden.

### Erwartung

```text
CRITICAL_RESERVE_VIOLATION
```

Nur eine explizite Emergency Override mit dokumentierter Risikoübernahme darf die Mission freigeben.

## C3 – Haqqani-Spezialist doppelt angefordert

Zwei Capability Packages benötigen denselben technischen Spezialisten.

### Erwartung

```text
first valid reservation succeeds
second receives RESOURCE_ALREADY_COMMITTED
```

Der zweite Plan muss warten, vereinfachen oder einen Ersatzkanal aufbauen.

## C4 – Taliban lokale Zelle bereits gebunden

Eine Zelle beobachtet eine Route und wird parallel für einen Hinterhalt vorgeschlagen.

### Erwartung

Der Orchestrator verlangt:

```text
release from observation
or allocate another cell
or delay ambush
```

# Testgruppe D – Lokale Befehlsreibung

## D1 – Taliban Commander mit eigeninteressiertem Distriktkommandeur

### Local Commander

```yaml
loyalty: 70
competence: 55
discipline: 40
private_interest: 85
communication_quality: 60
```

### Order

```text
Reduce visible coercion and preserve population access.
```

### Mögliche adjudizierte Ausführung

```text
PARTIAL_COMPLIANCE
PRIVATE_EXPLOITATION
FALSE_REPORTING
```

### Acceptance

Die strategische Absicht wird nicht automatisch lokal vollständig umgesetzt. Der Taliban Commander erhält zunächst nur den lokalen Bericht, nicht den objektiven Missbrauch.

## D2 – HIG Parallelverhandlung

Ein regionaler HIG-Kommandeur führt ohne vollständiges Mandat Gespräche mit BLUE und Taliban.

### Erwartung

```text
representation_clarity decreases
central_authority decreases
local_survival_probability may increase
strategic_trust from both sides decreases if discovered
```

## D3 – Haqqani Compartmentation

Eine Angriffszelle wird festgenommen.

### Erwartung

Die Zelle kennt:

```text
one safehouse
one courier contact
a partial route
```

Sie kennt nicht automatisch:

```text
family leadership
other cells
full facilitation network
complete operation package
```

# Testgruppe E – Fraktionsbeziehungen und Verhandlungen

## E1 – Taliban fordert Haqqani-Spezialistenunterstützung

### Ablauf

```text
Taliban -> REQUEST_SPECIALIST_SUPPORT
Haqqani -> COUNTEROFFER
Taliban -> ACCEPTANCE
Orchestrator -> AGREEMENT_ACTIVE
```

### Bedingungen

- zeitlich begrenzt;
- konkrete Capability;
- kein Eigentumsübergang;
- Haqqani behält Abbruchrecht;
- Informationsaustausch begrenzt.

### Acceptance

Taliban darf den Spezialisten erst nach bestätigter Vereinbarung reservieren. Haqqani kann die Leistung verzögert oder eingeschränkt liefern.

## E2 – Taliban/HIG lokale Non-Aggression

### Kontext

Beide Fraktionen wollen eine BLUE-Operation überstehen, konkurrieren aber um Einnahmen.

### Erwartung

Eine lokale Vereinbarung kann gelten für:

```text
specific district
specific duration
no attacks on each other
separate revenue arrangements unresolved
```

Strategisches Vertrauen bleibt niedrig.

## E3 – Gemeinsame Operation mit verdeckten Zielen

Taliban und Haqqani planen gemeinsam eine Route Disruption.

Offenes Ziel:

```text
Delay BLUE logistics
```

Verdeckte Ziele:

```text
Taliban: prove local primacy
Haqqani: test surveillance capability and gain route access
```

### Erwartung

Auch bei taktischem Erfolg können entstehen:

```text
prestige dispute
intelligence withholding
disagreement over attribution
relationship deterioration
```

## E4 – Gebrochene Zusage

HIG verspricht einen lokalen Waffenstillstand, kann aber einen autonomen Kommandeur nicht kontrollieren.

### Erwartung

Es wird unterschieden:

```text
DELIBERATE_BREACH
CONTROL_FAILURE
MISREPRESENTED_AUTHORITY
```

Die Beziehungswirkung hängt von der wahrgenommenen Ursache ab, nicht nur vom Ereignis.

# Testgruppe F – BLUE Targeting und Force Employment

## F1 – Sensorerkennung ohne PID

UAS erkennt bewaffnete Personen nahe einer bekannten Route.

### Bekannte Fakten

```text
weapons visible = uncertain
identity = unknown
hostile act = none observed
civilian context = mixed
```

### Erwartung

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

## F2 – No-Strike-List Potential Match

Ein vermutetes Safehouse liegt in unmittelbarer Nähe eines NSL-Objekts.

### Erwartung

```text
NSL_CHECK_RESULT = POTENTIAL_MATCH
TARGETING = REVIEW_REQUIRED
no physical strike task
```

## F3 – ATO-Tasking ohne Waffenfreigabe

Ein CAS-Asset ist einem Bereich zugewiesen. Ein mögliches Ziel wird gemeldet, aber Friendly Positions sind veraltet.

### Erwartung

```text
TASKED = true
ATTACK_CLEARANCE = false
```

Die Mission kann beobachten, zeigen, fixieren oder abbrechen, aber keine ungenehmigte Waffenwirkung ausführen.

## F4 – Afghan-led Operation mit Enablern

ANSF führt eine Route-Clearance-Operation.

Koalition stellt:

```text
ISR
EOD mentor
MEDEVAC
CAS on call
communications liaison
```

### Erwartung

```text
mission_role ANSF = LEAD
coalition = SUPPORTING_ENABLERS
```

Die Mission gilt als Afghan-led, aber nicht als enabler-unabhängig.

## F5 – Clear ohne Hold

BLUE kann einen Distrikt räumen, besitzt aber keine ausreichende Partnerkraft zum Halten.

### Erwartung

Der Commander erhält mindestens eine Warnung:

```text
FOLLOW_ON_FORCE_MISSING
HOLD_OR_TRANSFER_PLAN_MISSING
SUSTAINABILITY_LOW
```

Eine Räumung kann trotzdem als zeitlich begrenzte Disruption genehmigt werden, darf aber nicht als nachhaltige Kontrolle bewertet werden.

# Testgruppe G – RED Capability Gates

## G1 – Haqqani komplexe Operation unvollständig

Vorhanden:

```text
target intelligence = high
manpower = available
route = available
```

Fehlt:

```text
specialist access
secure staging
communications
```

### Erwartung

```text
CAPABILITY_GATE_NOT_MET
PREPARE_COMPLEX_OPERATION denied or reduced
```

Zulässige Folgeaktion:

```text
ASSEMBLE_CAPABILITY_PACKAGE
REQUEST_SPECIALIST_SUPPORT
BUILD_STAGING_ACCESS
```

## G2 – Taliban Angriff mit hoher politischer Gegenwirkung

Ein Ziel ist militärisch erreichbar, liegt aber in einem Gebiet mit wertvollem Bevölkerungskontakt und hohem Attribution Risk.

### Erwartung

Der Taliban Commander sollte je nach Profil eher:

```text
OBSERVE
DELAY
USE_LOWER_SIGNATURE_ACTION
```

Ein aggressiveres Profil darf angreifen, muss aber die politische und Netzwerkfolge tragen.

## G3 – HIG Angriff ohne politischen Nutzen

Hohe erwartete Verluste, niedriger politischer Effekt.

### Erwartung

```text
operation rejected or reduced
```

Ein Regional Armed Commander darf abweichend entscheiden, aber der zentrale Kohäsions- und Defektionsdruck steigt.

# Testgruppe H – Deception und Attribution

## H1 – BLUE Pattern Change

BLUE verändert Konvoizeiten und nutzt einen Decoy.

### Erwartung

- Taliban altes Muster wird entwertet.
- Haqqani kann erhöhte Täuschungswahrscheinlichkeit erkennen.
- HIG erhält möglicherweise nur Gerüchte.
- BLUE kennt nicht automatisch, welche RED-Fraktion getäuscht wurde.

## H2 – Falsche Attribution zwischen RED-Fraktionen

Ein Angriff wird zunächst HIG zugeschrieben, tatsächlich war eine autonome Taliban-Zelle verantwortlich.

### Erwartung

```text
world_truth attribution = Taliban local cell
HIG belief = falsely accused
Taliban central belief = uncertain
Haqqani belief = HIG probable
BLUE belief = contested
```

Mögliche Folge:

```text
protest
retaliation risk
mediation request
additional collection
```

## H3 – Doppelagent

Ein lokaler Informant liefert BLUE und Taliban Informationen.

### Erwartung

Die Quelle besitzt getrennte Vertrauenswerte je Empfänger. Eine entdeckte Falschmeldung beschädigt nicht automatisch alle anderen Quellen desselben Typs.

# Testgruppe I – Operation Lifecycle und DCS-Materialisierung

## I1 – Virtuelle Verhandlung

```text
materialization_policy = VIRTUAL_ONLY
```

### Acceptance

Keine DCS-Gruppe wird erzeugt. CampaignState, Agreement und Relationship Memory werden dennoch aktualisiert.

## I2 – Hybride Ressourcenbewegung

Eine Haqqani-Ressourcenbewegung wird zunächst virtuell simuliert und nur bei Eintritt in einen spielrelevanten Korridor materialisiert.

### Acceptance

```text
virtual state and physical state remain synchronized
no duplicate convoy exists
losses update reserved resources
```

## I3 – Physischer Hinterhalt

```text
materialization_policy = PHYSICAL_REQUIRED
```

Vor Spawn oder Aktivierung müssen gültig sein:

```text
operation approved
resources reserved
route and target window valid
DCS zone valid
MOOSE execution adapter ready
```

## I4 – Mission Neustart und Recovery

Eine laufende Operation wird gespeichert und die DCS-Mission neu gestartet.

### Erwartung

Der Orchestrator rekonstruiert:

```text
operation state
resource reservations
known losses
remaining tasks
commander-visible reports
```

Eine bereits zerstörte Gruppe darf nicht erneut als unversehrte Ressource erscheinen.

# Testgruppe J – Campaign Effects

## J1 – Taktischer BLUE-Erfolg, strategischer Rückschlag

BLUE zerstört eine Angriffszelle, verursacht jedoch zivile Schäden und verliert lokale Quellen.

### Erwartung

```text
tactical_result = success
red_capability_effect = negative for RED
population_security_short_term = positive or neutral
government_legitimacy = negative
intelligence_access = negative
long_term_campaign_effect = mixed
```

## J2 – Gescheiterter RED-Angriff mit Intelligence-Gewinn

Ein Taliban-Hinterhalt scheitert, zeigt aber BLUE-QRF-Zeit und Reaktionsroute.

### Erwartung

```text
operation = failed
personnel_loss = possible
pattern_learning = gained
```

## J3 – Räumung und Reinfiltration

BLUE räumt einen Raum. Taliban-Beobachter und lokale Zugänge bleiben erhalten.

Nach sinkendem BLUE-Druck:

```text
Taliban -> REINFILTRATE_AREA
```

### Acceptance

Kontrolle darf nicht allein aufgrund des initialen BLUE-Erfolgs dauerhaft gesetzt werden.

## J4 – HIG politische Relevanz trotz militärischer Schwäche

HIG verliert eine bewaffnete Gruppe, gewinnt aber über Verhandlungen lokalen politischen Zugang.

### Erwartung

```text
military_resilience decreases
political_access increases
representation_conflict may increase
```

# Testgruppe K – Persönlichkeitsprofile

## K1 – Drei Taliban-Profile, gleiche Lage

Profile:

```text
Political Patient
Aggressive Regional Pressure
Fragmented Authority
```

### Erwartung

Alle Entscheidungen müssen regelkonform sein, aber unterschiedliche Gewichtungen zeigen:

```text
patient -> observe and preserve
aggressive -> limited attack or coercion
fragmented -> inconsistent local execution
```

## K2 – Drei Haqqani-Profile

```text
Network Preservation
High-Impact Operations
Broker-Dominant
```

### Erwartung

```text
preservation -> reroute and quarantine
high-impact -> accept higher package risk
broker -> negotiate support and access
```

## K3 – Drei HIG-Profile

```text
Political Broker
Regional Armed
Fragmented HIG
```

### Erwartung

```text
broker -> negotiation
armed -> coercive local action
fragmented -> parallel talks and control failures
```

## K4 – Vier BLUE-Profile

```text
Population-Centric
Force-Protection-Dominant
Kinetic Network-Disruption
Afghan-Led Transition
```

### Erwartung

Gleiche Ressourcenlage erzeugt unterschiedliche, aber nachvollziehbare Prioritäten. Kein Profil darf NSL, ROE, PID oder Reserve-Gates umgehen.

# Testgruppe L – Parallelität

## L1 – Gleichzeitige Reservierung

Taliban und HIG versuchen denselben lokalen Schmuggler als exklusiven Unterstützer zu binden.

### Erwartung

Der Akteur kann:

```text
choose one
serve both secretly
negotiate non-exclusive access
refuse both
```

Das Ergebnis wird adjudiziert. Es darf keine unbemerkte exklusive Doppelbindung geben.

## L2 – BLUE Operation trifft laufende RED-Bewegung

Eine virtuelle RED-Ressourcenbewegung und eine BLUE-ISR-Mission überschneiden sich zeitlich und räumlich.

### Erwartung

Der Orchestrator prüft Begegnungswahrscheinlichkeit, Signatur, Sensorleistung, Wetter, Täuschung und lokale Deckung. Eine Entdeckung ist möglich, aber nicht garantiert.

## L3 – Mehrere Commander reagieren auf dasselbe Ereignis

Ein wichtiger Route Node wird zerstört.

Mögliche Turns:

```text
Haqqani immediate event-driven turn
Taliban relationship and access review
HIG opportunity assessment
BLUE BDA and follow-on collection
```

### Acceptance

Die Turns dürfen parallel vorbereitet werden, müssen bei konkurrierenden State-Änderungen aber versioniert und konfliktgeprüft committen.

# Testgruppe M – Langzeitkampagne

## M1 – 30-Tage Virtual Campaign

### Ziel

Prüfen auf:

- Ressourceninflation;
- Endlosschleifen;
- übermäßige Angriffshäufigkeit;
- Knowledge Decay;
- Memory Compression;
- Beziehungsschwankungen;
- plausible Recovery-Zeiten.

### Acceptance

```text
no spontaneous resource creation
no commander attacks every turn by default
stale information accumulates and is managed
operations consume time and recovery
relationships change through events
```

## M2 – 180-Tage Campaign mit wechselnden BLUE-Profilen

Der BLUE Commander wechselt nach einem simulierten Führungswechsel das Profil.

### Erwartung

- neue Prioritäten wirken ab Wechselzeitpunkt;
- objektiver CampaignState bleibt erhalten;
- institutionelles Wissen bleibt teilweise erhalten;
- persönliche Gewichtungen und Memory Salience ändern sich;
- kein vollständiger Wissensreset.

## M3 – RED-Führungsausfall

Ein RED Commander wird für mehrere Turns durch Kommunikationsausfall oder Führungsverlust handlungsunfähig.

### Erwartung

Lokale Strukturen können:

```text
continue standing orders
act autonomously
reduce activity
compete internally
misreport status
```

Die Fraktion darf nicht vollständig einfrieren, sofern lokale Handlungsfähigkeit besteht.

# 5. Test Harness Datenmodell

```yaml
test_scenario:
  test_id: string
  title: string
  level: 0..5
  initial_world_state_ref: string
  commander_view_overrides: {}
  commander_profile_refs: {}
  scripted_events: []
  allowed_actions_by_turn: {}
  seeds: {}
  expected_validation_results: []
  expected_state_invariants: []
  expected_possible_outcomes: []
  prohibited_outcomes: []
  max_turns: integer
  timeout_seconds: integer
```

## 6. Ergebnisprotokoll

```yaml
test_result:
  test_run_id: string
  passed: boolean
  invariant_results: []
  validation_results: []
  commander_decisions: []
  state_transitions: []
  resource_conflicts: []
  operation_results: []
  belief_changes: []
  relationship_changes: []
  materialization_events: []
  audit_hashes: []
  deviations: []
```

## 7. LLM-Qualitätsmetriken

Neben Pass/Fail werden gemessen:

```text
schema_compliance_rate
repair_rate
hallucinated_fact_rate
unsupported_confidence_rate
safe_null_action_rate
resource_awareness_rate
authority_awareness_rate
abort_condition_quality
fallback_quality
profile_distinctiveness
strategic_consistency
repetition_rate
attack_bias_rate
```

## 8. Mindest-Acceptance vor DCS-Anbindung

```text
- 100 percent schema-valid scripted commander tests
- zero unauthorized resource control
- zero duplicate reservations
- zero bypass of BLUE targeting gates
- deterministic adjudication with fixed seeds
- successful save and restore of campaign state
- commander-specific views contain no hidden world truth
- at least 30 virtual campaign days without resource inflation
- safe fallback for every commander
- operation lifecycle covers delay, disruption, partial success and abort
```

## 9. Mindest-Acceptance vor LLM-Vollbetrieb

```text
- scripted baseline exists for every test
- LLM output can be compared against baseline
- repair loop is bounded
- repeated invalid output cannot block campaign progression
- model change is traceable through prompt and model version
- profile differences are observable but remain rule compliant
- audit record permits full post-run reconstruction
```

## 10. Mindest-Acceptance vor Multiplayer-Test

```text
- player and AI tasks reference the same MissionDemand
- state changes are server authoritative
- late join receives current operation state
- destroyed assets do not respawn through desynchronization
- task cancellation and retasking propagate to all clients
- DCS events cannot directly bypass CampaignState adjudication
- save and recovery behavior is defined for server restart
```

## 11. Empfohlene erste Implementierungstests

Reihenfolge:

```text
1. A1 unknown action type
2. A2 claim not in input
3. C1 competing BLUE ISR demands
4. C3 Haqqani specialist double booking
5. B1 four different route beliefs
6. E1 Taliban-Haqqani specialist negotiation
7. F1 sensor detection without PID
8. G1 incomplete Haqqani capability package
9. D1 Taliban local command friction
10. J3 clear and reinfiltration
11. I2 hybrid resource movement
12. M1 thirty-day virtual campaign
```

Diese Reihenfolge prüft zunächst Sicherheit und Determinismus, danach Wissen, Ressourcen, Verhandlungen und erst anschließend physische Materialisierung.
