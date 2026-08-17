---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-SNAPSHOT-SERIALIZATION
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 snapshot and serialization contract for Air Tasking domain records
  - separation of persistent Air Tasking domain data from runtime-only MOOSE and DCS bindings
  - deterministic restore boundary and snapshot validation requirements before runtime implementation
not_authoritative_for:
  - final persistence file format or filesystem path
  - final CampaignState snapshot schema extension
  - final MOOSE runtime binding structure
  - stale mission recovery policy
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Snapshot / Serialization Contract

## 1. Zweck

Dieses Dokument konkretisiert die in Phase 0 festgelegte Persistenzgrenze fuer die Air-Tasking-Domain.

Es definiert:

- welche Air-Tasking-Datensaetze in einen persistenten Snapshot gehoeren;
- welche Felder bewusst ausgeschlossen bleiben;
- wie stabile IDs und Referenzen erhalten bleiben;
- welche Invarianten beim Export und Restore gelten;
- wie sich der Air-Tasking-Snapshot zum bestehenden `CampaignState`-Snapshot verhaelt.

Es implementiert noch keine Persistenzdatei und erweitert nicht automatisch `OMW_CampaignState.lua`.

## 2. Verbindliche Trennung

```text
CampaignState snapshot
= strategische Ressourcen-/Transaktionswahrheit

Air Tasking snapshot
= persistenter fachlicher Request-/Mission-/Plan-/Relationship-/Assignment-Zustand

MOOSE / DCS runtime
= nicht serialisierbare physische Ausfuehrung
```

Der Air-Tasking-Snapshot darf keine zweite strategische Ressourcenwahrheit erzeugen.

## 3. Bestehender CampaignState-Snapshot bleibt autoritativ

Der aktuelle `OMW_CampaignState.lua` besitzt bereits einen eigenen Snapshot-Vertrag mit:

```text
snapshotVersion = CAMPAIGNSTATE-SNAPSHOT-1
stateSchemaVersion
nodes
transactions
resourceCredits
aircraftRecovery
```

Die aktuelle `CampaignState.Restore(snapshot)`-Logik validiert die `snapshotVersion`, rekonstruiert den Store und stellt reservierte Mengen aus den Transaktionsdaten wieder her.

Air Tasking darf diesen Vertrag weder duplizieren noch stillschweigend ersetzen.

Deshalb gilt:

```text
Air Tasking resource_reservation_refs
-> reference CampaignState transactionId / reservationId
-> never serialize resource quantity as Air Tasking authority
```

## 4. Snapshot-Container

Konzeptioneller Air-Tasking-Snapshot:

```lua
local snapshot = {
  snapshot_version = "AIR-TASKING-SNAPSHOT-1",
  domain_schema_version = "AIR-TASKING-DOMAIN-1",
  exported_at = 0,

  requests = {},
  missions = {},
  plans = {},
  support_relationships = {},
  execution_attempts = {},
}
```

Pflichtfelder des Containers:

```text
snapshot_version
domain_schema_version
requests
missions
plans
support_relationships
execution_attempts
```

`exported_at` ist optional, darf aber nur als Metadatum verwendet werden. Es darf keinen Domainstatus bestimmen.

## 5. Serialisierbare Datentypen

Zulaessig sind ausschliesslich Werte, die ohne MOOSE-/DCS-Laufzeitobjekte rekonstruiert werden koennen:

```text
string
number
boolean
nil
tables composed recursively from those types
stable ID references
ordered lists
plain key/value maps where keys are stable scalar identifiers
```

Nicht zulaessig:

```text
function
userdata
thread
Lua metatable identity
MOOSE class instance
DCS object / userdata
closure
scheduler handle
event handler registration
raw object pointer/reference
```

## 6. AIR_SUPPORT_REQUEST Snapshot

Persistiert werden die fachlichen Felder des Request-Records, mindestens:

```text
request_id
mission_demand_id
support_type
request_timing
requesting_entity_id
requesting_command_node_id
supporting_authority_ref
priority
created_at
required_effect_or_task
area_or_target_reference
time_constraints
status
assigned_mission_ids
result
closure_reason
created_by
change_serial
```

Nicht persistiert werden Runtime-Callbacks, UI-Handles oder MOOSE-Objekte.

## 7. AIR_TASKING_MISSION Snapshot

Persistiert werden mindestens:

```text
mission_id
mission_type
request_ids
mission_demand_ids
status
planned_start
planned_stop
alert_window
readiness_time
departure_node_id
recovery_node_id
mission_area_id
target_reference
control_agency_id
report_in_point_id
assigned_command_ref
assigned_airwing_id
assigned_squadron_id
aircraft_type
aircraft_count
callsign
player_or_ai_assignment
support_relationship_ids
resource_reservation_refs
execution_attempt_ids
active_execution_attempt_id
result
closure_reason
change_serial
```

Diese Felder sind nur fachliche Planung beziehungsweise stabile Korrelation.

Insbesondere gilt:

```text
assigned_airwing_id
assigned_squadron_id
aircraft_type
aircraft_count
```

sind keine Bestandsautoritaet.

## 8. AIR_TASKING_PLAN Snapshot

Persistiert werden:

```text
plan_id
operation_id
effective_from
effective_to
status
mission_ids
change_serial
```

Der Plan besitzt keine Ressourcen und keine MOOSE-Objekte.

## 9. SUPPORT_RELATIONSHIP Snapshot

Persistiert wird das kanonische `REL-`-Objekt:

```text
relationship_id
relationship_type
provider_mission_id
consumer_mission_id
status
required
priority
sequence
time_constraints
result
closure_reason
change_serial
```

Missionen persistieren nur die referenzierten `support_relationship_ids`.

Die Beziehung wird beim Restore nicht aus zwei Missionsrecords neu erfunden, sondern ueber genau ein kanonisches `REL-`-Objekt wiederhergestellt.

## 10. EXECUTION_ATTEMPT Snapshot

Persistiert werden nur stabile Korrelation und fachlich benoetigte Beobachtung:

```text
execution_id
mission_id
generation
status
created_at
started_at
ended_at
result_observation
```

Nicht persistiert werden:

```text
runtime_binding.actual_auftrag
runtime_binding.flightgroup
runtime_binding.dcs_group
runtime_binding.callbacks
runtime_binding.scheduler_handles
```

Nach Restore existiert deshalb kein wiederhergestelltes MOOSE- oder DCS-Objekt.

## 11. Player-/AI-Assignment Snapshot

Die Assignment-Struktur ist persistierbarer Planungszustand:

```text
mode
assignee_ref
assigned_at
assignment_reason
change_serial
```

Dabei gilt weiterhin:

```text
PLAYER / AI assignment
!= resource reservation
!= active physical execution
```

Ein `PLAYER`-Assignment nach Restart beweist insbesondere nicht, dass ein Spieler aktuell verbunden ist.

Ein `AI`-Assignment nach Restart beweist nicht, dass ein MOOSE `AUFTRAG` oder ein `FLIGHTGROUP` noch existiert.

## 12. CampaignState-Reservierungsreferenzen

Persistiert werden ausschliesslich stabile Referenzen:

```text
transaction_id
reservation_id
mission_demand_id
request_id
mission_id
```

Nicht im Air-Tasking-Snapshot dupliziert werden:

```text
resourceId quantity
canonicalUnit
origin stock
destination stock
transaction status as independent Air Tasking truth
```

Beim Restore muss die spaetere Integrationslogik die Referenz gegen den autoritativen CampaignState-Store pruefen.

Fehlende oder widerspruechliche CampaignState-Referenzen duerfen nicht stillschweigend repariert werden.

## 13. Deterministischer Export

Der spaetere Export muss fuer gleiche fachliche Daten eine deterministische Struktur erzeugen.

Dazu muessen mindestens die folgenden Collections in stabiler ID-Reihenfolge exportiert werden:

```text
requests by request_id
missions by mission_id
plans by plan_id
support_relationships by relationship_id
execution_attempts by execution_id
```

Dies folgt dem bereits im CampaignState verwendeten Prinzip, Maps vor Snapshot-Ausgabe nach stabilen Schluesseln zu sortieren.

Die konkrete Textserialisierung darf spaeter separat gewaehlt werden. Dieser Contract schreibt weder JSON noch Lua-Table-Text als Dateiformat vor.

## 14. Restore-Reihenfolge

Konzeptionelle Restore-Reihenfolge:

```text
1. validate snapshot container/version
2. restore requests
3. restore missions
4. restore plans
5. restore support relationships
6. restore execution-attempt correlation
7. validate cross references
8. reconcile CampaignState references
9. leave all MOOSE/DCS runtime bindings empty
10. later runtime reconciliation decides whether fresh physical execution is required
```

Die Reihenfolge ist fachlich; eine Implementierung darf intern anders strukturieren, sofern dieselben Invarianten gelten.

## 15. Restore-Invarianten

Ein Restore muss mindestens fail closed bei:

```text
unsupported snapshot_version
unsupported domain_schema_version
duplicate stable IDs
invalid ID prefixes
mission referencing unknown request
mission referencing unknown relationship
relationship referencing unknown provider or consumer mission
relationship cycle in active dependency graph
execution attempt referencing unknown mission
more than one active execution attempt where not explicitly allowed
invalid Request or Mission status
invalid assignment mode
MOOSE/DCS object or function found in persistent data
```

Cross-Domain-Referenzen zu CampaignState werden separat reconciliiert und duerfen nicht durch Air Tasking erfunden werden.

## 16. Kein automatisches Runtime-Recovery

Der Snapshot stellt Domainzustand wieder her, nicht physische Missionsausfuehrung.

Deshalb gilt:

```text
restored mission status = EXECUTING
!= recreate old DCS group automatically

restored execution_attempt status = STARTED
!= old MOOSE object exists
```

Nach einem Restart muss die spaetere Phase-6-Recovery-Logik entscheiden, ob ein offener Vorgang:

```text
- neu geplant wird
- einen neuen EXE- Versuch erhaelt
- als stale geschlossen wird
- durch Replacement ersetzt wird
- ohne erneuten Ressourcenverbrauch fortgesetzt wird
```

Phase 1 trifft diese Entscheidung nicht.

## 17. Versionierung

Air Tasking verwendet eine eigene Snapshot-Version getrennt von CampaignState:

```text
AIR-TASKING-SNAPSHOT-1
```

und eine getrennte Domain-Schema-Version:

```text
AIR-TASKING-DOMAIN-1
```

Semantik:

```text
snapshot_version
= Struktur des serialisierten Containers

domain_schema_version
= Struktur/Semantik der enthaltenen Air-Tasking-Domainrecords
```

Eine spaetere Migration benoetigt eine explizite Versionierungs-/Migrationsentscheidung. Unbekannte Versionen werden nicht stillschweigend akzeptiert.

## 18. Idempotenz

Wiederholtes Exportieren und Restore derselben Daten darf keine neuen fachlichen IDs oder Ressourcenwirkungen erzeugen.

Insbesondere darf Restore nicht:

```text
- neue ASR-/ATM-/REL-/EXE-IDs erzeugen
- CampaignState-Reservierungen erneut anlegen
- Ressourcen erneut abbuchen oder gutschreiben
- MOOSE-Missionen automatisch duplizieren
- terminale Records reopenen
```

## 19. Abgrenzung zum finalen Persistence-System

Noch nicht festgelegt werden:

```text
persistence file path
write cadence
atomic file replacement
backup rotation
retention duration
compression
multi-server synchronization
stale mission policy
migration tooling
```

Diese Themen gehoeren in spaetere Persistenz-/Runtime-Phasen.

## 20. Phase-1-Ergebnis

Mit diesem Vertrag ist der Manifest-Punkt abgeschlossen:

```text
[x] Serialisierbarkeit der persistenten Teilmenge festlegen
```

Noch offen bleiben in Phase 1 insbesondere:

```text
- Datenvalidierungsregeln und Fehlerlogging mit stabilen IDs
- Gate-1-Gesamtpruefung
```

Kein Runtime-Code wurde geaendert. Kein DCS-Test ist fuer diesen Domain-/Snapshot-Contract erforderlich. `validated_in_dcs` bleibt `false`.
