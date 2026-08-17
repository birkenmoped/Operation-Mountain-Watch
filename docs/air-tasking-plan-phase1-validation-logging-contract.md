---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-VALIDATION-LOGGING
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 validation contract for Air Tasking domain records
  - branch-local fail-closed rules for IDs, references, lifecycle transitions, serialization boundaries and domain invariants
  - branch-local logging requirements using stable domain identifiers
not_authoritative_for:
  - final Lua implementation
  - final logging backend or persistence file format
  - MOOSE API signatures, events or FSM behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Validation / Logging Contract

## 1. Zweck

Dieses Dokument schließt den letzten fachlichen Phase-1-Punkt der Air-Tasking-Foundation ab: Datenvalidierungsregeln und Fehlerlogging mit stabilen IDs.

Die Validierung bleibt DCS-/MOOSE-unabhängig. Sie schützt die fachliche Air-Tasking-Domain gegen ungültige Records, inkonsistente Referenzen, unerlaubte Statusübergänge, doppelte Identitäten und Runtime-Objekte in persistenter Datenstruktur.

Grundsatz:

```text
invalid domain state
-> reject / fail closed
-> log stable domain identity
-> do not invent missing state
-> do not mutate CampaignState resources implicitly
```

## 2. Validierungsstufen

Die spätere Implementierung trennt mindestens vier Prüfkontexte:

```text
RECORD
= einzelner Domain-Record ist strukturell und semantisch gültig

REFERENCE
= referenzierte Domain-Objekte existieren und passen semantisch zusammen

TRANSITION
= angeforderte Status-/Assignment-/Relationship-Änderung ist zulässig

SNAPSHOT
= persistente Gesamtmenge ist versioniert, serialisierbar und cross-reference-konsistent
```

Eine erfolgreiche RECORD-Prüfung beweist nicht automatisch, dass alle Cross-References vorhanden sind.

## 3. Stable-ID-Validierung

Kanonische Air-Tasking-Präfixe:

```text
ASR-  AIR_SUPPORT_REQUEST
ATM-  AIR_TASKING_MISSION
ATP-  AIR_TASKING_PLAN
REL-  SUPPORT_RELATIONSHIP
EXE-  EXECUTION_ATTEMPT
```

`MissionDemand` verwendet weiterhin die bestehende `MD-`-Identität. CampaignState-IDs wie `transactionId`, `reservationId`, `entityId` und `nodeId` behalten ihre eigene Semantik.

Für jede Air-Tasking-ID gilt:

```text
- non-empty string
- expected class prefix
- serial part present
- no reuse
- no duplicate within restored/active store
- immutable after record creation
```

Nicht zulässig als Primär-ID:

```text
callsign
DCS group/unit name
MOOSE object name
squadron display name
parking ID
array index
Lua table identity
runtime timestamp without persistent sequence authority
```

## 4. AIR_SUPPORT_REQUEST Validierung

Ein Request muss mindestens prüfen:

```text
request_id valid ASR-
mission_demand_id present and valid MD-
support_type from approved Phase-1 catalogue
request_timing = PREPLANNED | IMMEDIATE | EMERGENCY
at least one of requesting_entity_id / requesting_command_node_id present
priority present
created_at valid scalar timestamp/mission-time representation
required_effect_or_task present
status valid for Request FSM
assigned_mission_ids is a list of unique ATM- IDs
change_serial is positive integer
```

Zusätzliche Regeln:

```text
- EMERGENCY does not bypass Authority or resource checks
- FULFILLED requires domain fulfillment evidence/result
- terminal Request status cannot be silently reopened
- assigned_mission_ids may reference more than one mission
- duplicate ATM reference inside the same Request is invalid
```

## 5. AIR_TASKING_MISSION Validierung

Eine Mission muss mindestens prüfen:

```text
mission_id valid ATM-
mission_type is profiled for progression beyond DRAFT
status valid for Mission FSM
request_ids is a list of unique ASR- IDs
mission_demand_ids is a list of unique MD- IDs
support_relationship_ids is a list of unique REL- IDs
resource_reservation_refs is a list/table of stable CampaignState references
execution_attempt_ids is a list of unique EXE- IDs
change_serial is positive integer
```

Pfadregeln:

```text
direct tasking path:
request_ids may be empty
mission_demand_ids must contain at least one MD-

support request path:
request_ids must contain at least one ASR-
```

Planungswerte wie `aircraft_count`, `assigned_airwing_id` oder `assigned_squadron_id` dürfen nie als strategischer Bestandsnachweis interpretiert werden.

## 6. Missionsstufen und Feldprofile

Die missionstypabhängigen Feldprofile aus `OMW-AIR-TASKING-PLAN-PHASE1-MISSION-TYPE-FIELDS` bleiben maßgeblich.

Validierungsprinzip:

```text
DRAFT
-> CORE_REQUIRED fields

PLANNED
-> CORE_REQUIRED + PLANNING_REQUIRED

ALLOCATED / TASKED / EXECUTING
-> zusätzlich die jeweils benötigten EXECUTION_REQUIRED fields
```

Ein Record darf nicht in einen fortgeschrittenen Status wechseln, wenn die dafür erforderliche Feldstufe nicht erfüllt ist.

## 7. Status-Transition-Validierung

Statusänderungen müssen gegen den Phase-1-Lifecycle-Contract geprüft werden.

Nicht zulässig ist insbesondere:

```text
terminal -> active
without explicit later Reopen/Replacement policy

PLANNED -> EXECUTING
without ALLOCATED/TASKED path

REQUEST SUBMITTED -> FULFILLED
without required intermediate domain processing
```

Jede erfolgreiche fachliche Transition erhöht den zugehörigen `change_serial` genau einmal.

Eine abgelehnte Transition darf den Record nicht teilweise verändern.

## 8. Support-Relationship-Validierung

Ein `REL-`-Record muss mindestens prüfen:

```text
relationship_id valid REL-
provider_mission_id valid ATM-
consumer_mission_id valid ATM-
provider_mission_id != consumer_mission_id
relationship_type present
status valid
change_serial positive integer
```

Cross-Reference-Regeln:

```text
provider mission exists
consumer mission exists
both missions reference the same REL- ID where bidirectional lookup is required
no duplicate relationship ID
no active dependency cycle
```

Der aktive Relationship-Graph muss azyklisch bleiben.

Zulässig:

```text
A -> B
A -> C
B -> D
```

Unzulässig:

```text
A -> B
B -> A
```

und:

```text
A -> B
B -> C
C -> A
```

## 9. EXECUTION_ATTEMPT Validierung

Ein Execution Attempt muss mindestens prüfen:

```text
execution_id valid EXE-
mission_id references existing ATM-
generation positive integer
status valid for Execution Attempt lifecycle
created_at present
started_at / ended_at temporally consistent when present
```

Zusätzlich:

```text
- no more than one active execution attempt for one mission unless a later explicit policy permits it
- execution attempt identity never replaces ATM mission identity
- runtime_binding is never part of persistent validation state
```

## 10. Player-/AI-Assignment Validierung

Zulässige Assignment-Modi:

```text
UNASSIGNED
PLAYER
AI
```

Mindestens zu prüfen:

```text
PLAYER -> referenced MissionDemand is playerCapable
AI -> referenced MissionDemand is aiCapable
UNASSIGNED -> no active assignee requirement
```

Nicht zulässig:

```text
PLAYER and AI simultaneously
PLAYER/AI assignment used as resource reservation
AI assignment interpreted as existing MOOSE AUFTRAG
PLAYER assignment interpreted as currently connected player
```

Ein Assignment-Wechsel darf keinen aktiven Execution Attempt oder eine bestehende autoritative Reservierung stillschweigend umgehen.

## 11. CampaignState-Referenzen

Air Tasking validiert nur die Referenzform und die spätere Existenz/Korrelation gegen CampaignState.

Air Tasking darf nicht validieren durch eigene Kopie von:

```text
resource quantity
fuel stock
weapon stock
aircraft strategic availability
transaction lifecycle truth
```

Bei Restore oder Integrationsprüfung gilt:

```text
referenced transaction/reservation exists in CampaignState
or
validation/reconciliation fails closed
```

Fehlende CampaignState-Referenzen dürfen nicht automatisch neu erzeugt werden.

## 12. Snapshot-Validierung

Vor Restore muss mindestens geprüft werden:

```text
snapshot_version supported
domain_schema_version supported
all top-level collections present
all records contain only serializable scalar/table data
no function/userdata/thread/metatable runtime identity
duplicate IDs rejected
ID prefixes match record class
statuses valid
assignment modes valid
cross references valid
relationship graph acyclic
execution attempt ownership valid
```

MOOSE-/DCS-Objekte oder Runtime-Handles im Snapshot sind ein harter Fehler.

## 13. Idempotenz-Prüfungen

Wiederholte Verarbeitung desselben fachlichen Vorgangs darf nicht erzeugen:

```text
second ASR for same already-canonical request event
second ATM for same authoritative operation unless explicitly Replacement
second REL for the same canonical relationship mutation
second active EXE for same mission
second CampaignState reservation because snapshot/restore was repeated
```

Existiert dieselbe stabile ID mit identischem fachlichem Inhalt, darf die spätere Implementierung idempotent `unchanged` melden.

Existiert dieselbe stabile ID mit abweichendem fachlichem Inhalt, muss sie fail closed ablehnen.

## 14. Logging-Grundsatz

Jeder fachliche Fehler und jede relevante Statusänderung muss soweit vorhanden die stabile Domain-ID enthalten.

Minimalformat:

```text
[OMW][AirTasking][<LEVEL>][<OBJECT_CLASS>][<STABLE_ID>] message key=value ...
```

Beispiele:

```text
[OMW][AirTasking][INFO][ATM][ATM-000042] status_transition from=PLANNED to=ALLOCATED
[OMW][AirTasking][WARN][ASR][ASR-000017] unresolved_campaign_reference transaction_id=TX-...
[OMW][AirTasking][ERROR][REL][REL-000009] dependency_cycle_detected provider=ATM-000010 consumer=ATM-000004
[OMW][AirTasking][ERROR][EXE][EXE-000031] invalid_transition from=ENDED to=STARTED mission_id=ATM-000021
```

Die konkreten Logging-Funktionen werden erst mit der Lua-Implementierung festgelegt. Dieser Contract legt nur die fachlichen Felder und Mindestinformationen fest.

## 15. Log-Level-Semantik

Mindestens:

```text
DEBUG
= detaillierte Diagnose; nicht für jede normale Scheduler-/Frame-Aktivität

INFO
= erfolgreiche fachlich relevante Zustandsänderung

WARN
= inkonsistenter oder unvollständiger Zustand, der ohne Mutation sicher abgefangen werden kann

ERROR
= abgelehnte fachliche Operation / ungültiger Zustand / fehlende Pflichtreferenz
```

`ERROR` bedeutet nicht automatisch DCS-/MOOSE-Laufzeitfehler. Es kann ein reiner Domain-Validierungsfehler sein.

## 16. Pflichtkontext im Fehlerlog

Wenn verfügbar, sollen Fehlerlogs enthalten:

```text
stable object ID
object class
operation / attempted transition
referenced IDs relevant to the failure
expected value/state
actual value/state
```

Nicht als primärer Fehlerkontext verwenden:

```text
Lua table address
DCS object pointer
MOOSE object memory identity
only callsign without stable domain ID
only DCS group name without stable domain ID
```

Runtime-Namen dürfen später ergänzend geloggt werden, aber nur zusätzlich zur stabilen Domain-Korrelation.

## 17. Keine stillen Reparaturen

Die Domain darf bei Validation Failure nicht automatisch:

```text
create missing MissionDemand
create missing ASR/ATM/REL/EXE
create missing CampaignState reservation
rewrite invalid ID prefix
remove a dependency edge to break a cycle
change terminal status back to active
replace missing stable ID with DCS/MOOSE runtime name
```

Eine solche Änderung wäre eine fachliche Entscheidung und muss durch einen expliziten Recovery-/Migration-/Replacement-Pfad erfolgen.

## 18. Keine hochfrequenten Validierungsscans

Die spätere Implementierung soll Validierung ereignis-/mutationsbezogen durchführen:

```text
on create
on update
on transition
on relationship mutation
on snapshot export
on snapshot restore
on explicit reconciliation
```

Ein unbegründeter globaler High-Frequency-Scan aller Air-Tasking-Records ist nicht Teil des Designs.

## 19. Phase-1-Ergebnis

Mit diesem Vertrag ist der letzte fachliche Phase-1-To-do-Punkt abgeschlossen:

```text
[x] Datenvalidierungsregeln und Fehlerlogging mit stabilen IDs festlegen
```

Damit sind alle im Foundation-Manifest vorgesehenen Phase-1-Domain-Contracts fachlich beschrieben.

Noch separat zu prüfen ist Gate 1 als Gesamtbewertung gegen die vollständige Phase-1-Dokumentmenge.

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diesen Domain-Vertrag erforderlich. `validated_in_dcs` bleibt `false`.
