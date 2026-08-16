---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-DOMAIN-DATA-CONTRACT
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 domain data contract for Air Support Requests, Air Tasking Missions and Air Tasking Plans
  - branch-local data boundaries for command references, capability allocation references, support relationships and execution correlation
  - DCS- and MOOSE-independent object shape required before runtime implementation
not_authoritative_for:
  - final Lua module implementation
  - final MOOSE adapter signatures or behavior
  - concrete OMW command-node inventory
  - exact historical OPCON, TACOM or TACON reconstruction
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Domain Data Contract

## 1. Zweck

Dieses Dokument überführt die abgeschlossenen Phase-0-Autoritätsgrenzen in ein konkretes, DCS-/MOOSE-unabhängiges Domänenmodell.

Es implementiert noch keinen Runtime-Code. Es legt fest, welche fachlichen Daten die spätere Lua-Implementierung tragen muss und welche Informationen ausdrücklich nur Referenzen auf andere autoritative Domänen bleiben.

Grundlage sind insbesondere:

- `OMW-GOV-001`;
- `OMW-GOV-MOOSE-FIRST`;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`;
- `OMW-AIR-TASKING-PLAN-FOUNDATION`;
- `OMW-AIR-TASKING-PLAN-PHASE0-CAMPAIGNSTATE-CONTRACT`;
- `OMW-AIR-TASKING-PLAN-PHASE0-PERSISTENCE-BOUNDARY`;
- `OMW-AIR-TASKING-PLAN-PHASE0-STABLE-ID-CONVENTION`;
- `OMW-AIR-TASKING-PLAN-PHASE0-COMMAND-AUTHORITY`;
- `OMW-AIR-TASKING-PLAN-PHASE0-MOOSE-COMMAND-MODEL-DECISION`;
- `OMW-AIR-TASKING-PLAN-PHASE0-VIEW-AUTHORITY`.

## 2. Verbindliche Domänengrenze

```text
CampaignState
= strategische Wahrheit, Ressourcen, MissionDemand und Settlement

Air Tasking Domain
= Requests, operative Air-Mission-Planung, Support-Beziehungen und Plan-Kontext

MOOSE
= Asset-Auswahl und physische Missionsausführung nach Phase-2-Verifikation

DCS
= beobachtbare physische Laufzeit
```

Air-Tasking-Datensätze dürfen keine zweite Aircraft-, Fuel-, Weapon- oder sonstige Ressourcenmenge besitzen.

## 3. Namens- und ID-Regeln

Interne stabile IDs folgen dem Phase-0-Vertrag:

```text
MD-   MissionDemand
ASR-  AIR_SUPPORT_REQUEST
ATM-  AIR_TASKING_MISSION
ATP-  AIR_TASKING_PLAN
REL-  Support-/Dependency-Beziehung
EXE-  physischer Execution Attempt
```

CampaignState-`transactionId`, `reservationId`, `entityId`, `nodeId` und andere bestehende IDs behalten ihre eigene Semantik.

Alle persistenten Beziehungen verwenden stabile IDs und niemals Lua-Tabellenreferenzen, MOOSE-Objekte, DCS-Userdata oder DCS-Gruppennamen als Primäridentität.

## 4. `AIR_SUPPORT_REQUEST`

Ein Air Support Request repräsentiert Luftunterstützungsbedarf über eine Authority-Grenze hinweg.

Konzeptioneller Lua-Datensatz:

```lua
local request = {
  request_id = "ASR-000001",
  mission_demand_id = "MD-000001",
  request_type = "CAS",
  requesting_entity_id = "...",
  requesting_command_node_id = "...",
  supporting_authority_ref = "...",
  priority = "...",
  created_at = 0,
  required_effect_or_task = "...",
  area_or_target_reference = "...",
  time_constraints = {
    earliest = nil,
    latest = nil,
    on_station_from = nil,
    on_station_to = nil,
  },
  status = "REQUESTED",
  assigned_mission_ids = {},
  result = nil,
  closure_reason = nil,
  created_by = "...",
  change_serial = 1,
}
```

### 4.1 Pflichtfelder

```text
request_id
mission_demand_id
request_type
requesting_entity_id or requesting_command_node_id
priority
created_at
required_effect_or_task
status
assigned_mission_ids
change_serial
```

Mindestens eine stabile Herkunftsreferenz muss vorhanden sein:

```text
requesting_entity_id
or
requesting_command_node_id
```

### 4.2 Optionale Felder

```text
supporting_authority_ref
area_or_target_reference
time_constraints
result
closure_reason
created_by
```

`supporting_authority_ref` darf in Phase 1 noch abstrakt bleiben, weil die konkrete MOOSE-/Command-Topologie erst in Phase 2 geprüft wird.

### 4.3 Nicht zulässig

Ein `AIR_SUPPORT_REQUEST` darf nicht enthalten oder besitzen:

```text
aircraft inventory
fuel inventory
weapon inventory
MOOSE AUFTRAG object
AIRWING object
SQUADRON object
FLIGHTGROUP object
DCS Group / Unit
resource quantity as authoritative stock
```

## 5. `AIR_TASKING_MISSION`

Eine Air Tasking Mission ist die operative Planungs- und Zuordnungseinheit für eine konkrete Luftmission.

Konzeptioneller Lua-Datensatz:

```lua
local mission = {
  mission_id = "ATM-000001",
  mission_type = "CAS",
  request_ids = { "ASR-000001" },
  mission_demand_ids = { "MD-000001" },
  status = "PLANNED",

  planned_start = nil,
  planned_stop = nil,
  alert_window = nil,
  readiness_time = nil,

  departure_node_id = nil,
  recovery_node_id = nil,
  mission_area_id = nil,
  target_reference = nil,
  control_agency_id = nil,
  report_in_point_id = nil,

  assigned_command_ref = nil,
  assigned_airwing_id = nil,
  assigned_squadron_id = nil,
  aircraft_type = nil,
  aircraft_count = nil,
  callsign = nil,
  player_or_ai_assignment = nil,

  support_relationship_ids = {},
  resource_reservation_refs = {},

  execution_attempt_ids = {},
  active_execution_attempt_id = nil,

  result = nil,
  closure_reason = nil,
  change_serial = 1,
}
```

### 5.1 Pflichtfelder

```text
mission_id
mission_type
status
request_ids
mission_demand_ids
support_relationship_ids
resource_reservation_refs
execution_attempt_ids
change_serial
```

Eine Mission darf auch ohne `AIR_SUPPORT_REQUEST` existieren, wenn sie aus einem direkten Tasking-Pfad innerhalb vorhandener Tasking Authority entsteht. Dann gilt:

```text
request_ids = {}
mission_demand_ids = { at least one MD reference }
```

Für eine Mission, die einen Air Support Request erfüllt, gilt:

```text
request_ids = { at least one ASR reference }
```

### 5.2 Planungswerte sind keine Bestände

```text
aircraft_type
aircraft_count
assigned_airwing_id
assigned_squadron_id
```

sind Planungs-/Zuordnungswerte. Sie begründen keine strategische Verfügbarkeit.

Reale Ressourcenbindung erfolgt ausschließlich über `resource_reservation_refs` auf CampaignState-Reservierungen/Transaktionen.

### 5.3 MOOSE-Bindung

Persistiert wird nur:

```text
execution_attempt_ids
active_execution_attempt_id
```

Nicht persistiert werden:

```text
AUFTRAG object
FLIGHTGROUP object
AIRWING object
SQUADRON object
COMMANDER object
DCS Group / Unit userdata
```

## 6. `AIR_TASKING_PLAN`

Ein Air Tasking Plan gruppiert Missionen innerhalb eines Planungs-/Operationskontexts.

```lua
local plan = {
  plan_id = "ATP-000001",
  operation_id = nil,
  effective_from = nil,
  effective_to = nil,
  status = "DRAFT",
  mission_ids = {},
  change_serial = 1,
}
```

Pflichtfelder:

```text
plan_id
status
mission_ids
change_serial
```

Optional:

```text
operation_id
effective_from
effective_to
```

Der Plan besitzt keine Ressourcen und keine MOOSE-Objekte.

## 7. `SUPPORT_RELATIONSHIP`

Support-Beziehungen werden als eigenes Objekt geführt, sobald sie mehr Semantik als eine bloße Mission-ID-Referenz benötigen.

```lua
local relationship = {
  relationship_id = "REL-000001",
  relationship_type = "AAR_SUPPORT",
  provider_mission_id = "ATM-000002",
  consumer_mission_id = "ATM-000001",
  status = "PLANNED",
  priority = nil,
  sequence = nil,
  time_constraints = nil,
  result = nil,
  change_serial = 1,
}
```

Pflichtfelder:

```text
relationship_id
relationship_type
provider_mission_id
consumer_mission_id
status
change_serial
```

Das Relationship-Objekt besitzt keine Ressourcen. Ein Tanker-Support-Verhältnis reserviert beispielsweise nicht durch seine bloße Existenz einen Tanker.

## 8. `EXECUTION_ATTEMPT`

Ein Execution Attempt korreliert eine persistente Mission mit genau einem physischen Materialisierungsversuch.

```lua
local attempt = {
  execution_id = "EXE-000001",
  mission_id = "ATM-000001",
  generation = 1,
  status = "PENDING",
  created_at = 0,
  started_at = nil,
  ended_at = nil,
  runtime_binding = nil,
  result_observation = nil,
}
```

Persistierbar:

```text
execution_id
mission_id
generation
status
created_at
started_at
ended_at
result_observation if required for reconciliation
```

Runtime-only:

```text
runtime_binding.actual_auftrag
runtime_binding.flightgroup
runtime_binding.dcs_group
runtime_binding.callbacks
runtime_binding.scheduler_handles
```

Die konkrete Struktur von `runtime_binding` wird erst nach Phase-2-MOOSE-Verifikation festgelegt.

## 9. Command-/Authority-Referenzen

Phase 1 baut keine zweite NATO-C2-Engine.

Air-Tasking-Objekte dürfen jedoch stabile fachliche Referenzen tragen:

```text
requesting_command_node_id
supporting_authority_ref
assigned_command_ref
```

Diese Referenzen bedeuten nicht automatisch:

```text
MOOSE COMMANDER object identity
historical OPCON/TACOM/TACON identity
strategic asset ownership
```

Sie beschreiben ausschließlich die OMW-fachliche Authority-Beziehung aus Phase 0.

## 10. Capability Allocation

Eine Capability Allocation ist in Phase 1 zunächst eine Referenzbeziehung, keine eigene Ressourcenmenge.

Benötigte Mindestsemantik:

```text
allocation_id or stable external reference
provider_authority_ref
supported_command_ref
capability_type
valid_from
valid_to
mission_scope / geographic_scope if applicable
status
```

Die spätere Implementierung muss bevorzugt vorhandene MOOSE-Zuweisungs- und Asset-Management-Mechanismen nutzen. Phase 1 definiert deshalb bewusst keine eigene Asset-Pool- oder Dispatcher-Tabelle.

## 11. CampaignState-Reservierungsreferenz

Air Tasking speichert nur Referenzen auf bestehende CampaignState-Ressourcentransaktionen.

Konzeptionell:

```lua
local reservation_ref = {
  transaction_id = "...",
  reservation_id = nil,
  mission_demand_id = "MD-000001",
  request_id = "ASR-000001",
  mission_id = "ATM-000001",
}
```

Autoritativ für Ressource, Menge, Origin Node und Settlement bleibt CampaignState.

Eine spätere CampaignState-API-Erweiterung um `request_id`/`mission_id` darf erst separat entworfen und geprüft werden. Dieses Dokument behauptet keine bereits vorhandene Methode dafür.

## 12. Trennung von Mission-, Request- und Campaign-Ergebnis

```text
AIR_TASKING_MISSION.result
= operative Ausführung

AIR_SUPPORT_REQUEST.result
= Erfüllung des angeforderten Air-Support-Bedarfs

MissionDemand result
= Erfüllung des kampagnenweiten Effekts/Auftrags

CampaignState settlement
= Ressourcenwirkung
```

Diese Ergebnisse dürfen korreliert, aber nicht automatisch gleichgesetzt werden.

## 13. Änderungsserialisierung und Idempotenz

Jeder persistente Air-Tasking-Datensatz führt mindestens:

```text
stable ID
change_serial
```

`change_serial` wird monoton erhöht, wenn sich der fachlich persistente Datensatz ändert. Es ist keine globale CampaignState-Version und ersetzt keine bestehende Persistenzversionsnummer.

Wiederholte Verarbeitung desselben fachlichen Vorgangs darf keine zweite ID, zweite Reservierung oder zweite physische Mission für denselben autoritativen Vorgang erzeugen.

## 14. Validierungsgrundsätze

Die spätere Lua-Implementierung muss mindestens fail-closed prüfen:

```text
- stable ID present and class prefix valid
- referenced MissionDemand exists before support/tasking creation
- referenced ASR/ATM/REL IDs exist when relation is committed
- no self-referencing support relationship
- provider_mission_id != consumer_mission_id
- no duplicate IDs
- no duplicate active execution attempt for the same mission unless explicitly allowed by later retry semantics
- no authoritative resource quantity in Air Tasking records
- no MOOSE/DCS object in persistent snapshot
```

Fehler müssen mit stabiler Domain-ID protokolliert werden.

## 15. Vorgesehene Lua-Modulgrenzen

Noch ohne Implementierung wird folgende kleinste sinnvolle Aufteilung festgelegt:

```text
AirTaskingDomain
  - record validation
  - stable relationship handling
  - status-transition validation

AirTaskingStore
  - persistent domain records
  - indexes by stable ID
  - snapshot export / restore interface

AirTaskingPlanner
  - request-to-mission planning decisions
  - no physical mission execution

AirTaskingAdapter
  - later Phase-2/3 MOOSE translation and runtime correlation
```

Diese Namen sind Designbezeichnungen und noch keine freigegebenen produktiven Lua-Dateinamen.

`AirTaskingPlanner` darf keine parallele MOOSE-Asset-Dispatcher-Engine werden. Asset-Auswahl und Ausführung bleiben MOOSE-first.

## 16. Explizite Nichtziele dieses Contracts

Nicht festgelegt werden hier:

```text
- konkrete MOOSE-Konstruktoren oder Methoden
- konkrete CHIEF-/COMMANDER-/AIRWING-/BRIGADE-Topologie
- konkrete OMW Command-Node-Liste
- vollständige CAS-Priorisierung
- AAR-Receiver-Scheduling
- Ground-Alert-Runtime
- Retasking-Regeln
- stale-mission recovery
- endgültige Snapshot-Dateistruktur
- Player-UI-Format
```

## 17. Phase-1-Status nach diesem Dokument

Mit diesem Contract ist der erste Phase-1-Arbeitspunkt erfüllt:

```text
[x] konkrete Lua-Datenverträge beziehungsweise Modulschnittstellen entwerfen
```

Noch offen bleiben insbesondere:

```text
- Pflicht-/Optionalfelder je Missionstyp
- getrennte Request-/Mission-Statusautomaten
- erlaubte Statusübergänge
- Cancellation-/Failure-Semantik
- Support-Beziehungen und Zyklusregeln im Detail
- Player-/AI-Assignment-Semantik
- Serialisierbarkeit der persistenten Teilmenge im konkreten Snapshot-Vertrag
- vollständige Datenvalidierungs- und Logging-Regeln
```

Kein Runtime-Code wurde verändert. Kein DCS-Test ist für diesen Domain-Contract erforderlich. `validated_in_dcs` bleibt `false`.
