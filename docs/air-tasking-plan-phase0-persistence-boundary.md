---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-PERSISTENCE-BOUNDARY
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 persistence boundary for Air Support Requests, Air Tasking Missions and Air Tasking Plans
  - separation of persistent OMW domain state from transient MOOSE and DCS runtime objects
not_authoritative_for:
  - concrete serialization format or persistence implementation
  - MOOSE API signatures or runtime behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 Persistence Boundary

## 1. Zweck

Dieses Dokument schließt den Phase-0-Punkt ab, welche Air-Tasking-Daten dauerhaft kampagnenrelevant sind und welche ausschließlich Laufzeitdaten bleiben.

Die Grenze folgt `OMW-GOV-001`, `OMW-AIR-TASKING-PLAN-FOUNDATION` und dem Phase-0-CampaignState-Vertrag:

```text
persistent OMW domain state
!=
transient MOOSE / DCS execution state
```

Die Persistenz darf keine DCS-Gruppen, MOOSE-Objekte oder Framework-internen FSM-Zustände als dauerhafte strategische Wahrheit speichern.

## 2. Grundregel

Persistiert wird nur, was nach einem Server- oder Missionsneustart weiterhin für Kampagnenlogik, Ressourcenhoheit, Nachvollziehbarkeit oder die Wiederherstellung eines fachlichen Auftrags benötigt wird.

Nicht persistiert werden technische Objekte und Zustände, die aus dem persistenten Domänenzustand neu materialisiert oder durch die laufende DCS-/MOOSE-Ausführung erneut ermittelt werden können.

Verbindliche Trennung:

```text
CampaignState / domain records
= persistent candidates

MOOSE AUFTRAG / FLIGHTGROUP / GROUP / UNIT / schedulers / handles
= runtime only
```

## 3. Persistente Air-Tasking-Daten

### 3.1 `AIR_SUPPORT_REQUEST`

Persistenzfähig beziehungsweise langfristig kampagnenrelevant sind mindestens:

```text
request_id
source missionDemandId
request_type
requesting_entity_id
priority
created_at
required_effect_or_task
area_or_target_reference
time_constraints
status
assigned_mission_ids
terminal result / closure reason
```

Begründung:

- ein Request bleibt auch nach Neustart fachlich derselbe Bedarf;
- Request-to-Mission-Korrelation muss erhalten bleiben;
- abgeschlossene, abgelehnte oder abgebrochene Requests müssen für Historie und Idempotenz nachvollziehbar bleiben.

### 3.2 `AIR_TASKING_MISSION`

Persistenzfähig sind die stabilen Planungs- und Ergebnisdaten:

```text
mission_id
mission_type
request_ids
planning status
planned_start
planned_stop
alert_window / readiness_time where applicable
departure_node_id
recovery_node_id
assigned_squadron_id
aircraft_type
aircraft_count as planning requirement
callsign assignment if still operationally relevant
mission_area_id / target reference
control_agency_id
report_in_point_id
support_mission_ids
player_or_ai_assignment intent
resource reservation references
terminal mission result
```

Diese Felder beschreiben die fachliche Mission, nicht die aktuelle DCS-Instanz.

### 3.3 `AIR_TASKING_PLAN`

Persistenzfähig sind mindestens:

```text
plan_id
operation_id / campaign context
effective_from
effective_to
version / change serial
plan status
mission_ids
```

Der Plan darf keine eigene Ressourcenmenge persistieren. Er referenziert ausschließlich Missionen und deren autorisierte CampaignState-Reservierungen.

### 3.4 Korrelation und Settlement

Persistiert werden müssen stabile Referenzen, soweit sie für Idempotenz und Settlement erforderlich sind:

```text
missionDemandId
request_id
mission_id
reservationId / transactionId
resource settlement status
campaign-effect settlement reference
support relationship IDs
```

Damit kann nach Neustart unterschieden werden, ob ein Vorgang bereits reserviert, verbraucht, verloren, freigegeben oder abgeschlossen wurde.

## 4. Ausschließlich transiente Runtime-Daten

Folgende Daten dürfen nicht als dauerhafte strategische Wahrheit gespeichert werden:

```text
MOOSE AUFTRAG object reference
COMMANDER object reference
AIRWING object reference
SQUADRON object reference
FLIGHTGROUP object reference
DCS Group / Unit / Airbase userdata
SPAWN objects
SCHEDULER objects
FSM object references
callback closures
event handler registrations
raw object memory identities
DCS runtime group names as primary IDs
current route-task objects
current waypoint task handles
current tanker orbit AUFTRAG handle
current MOOSE mission queue position as strategic state
```

Auch technische Laufzeitwerte wie folgende bleiben grundsätzlich transient:

```text
current DCS object existence
current unit health as unverified raw observation
current coordinate sampled from DCS
current route leg
current taxi state
current MOOSE FSM state without domain settlement
runtime object pointer / table reference
scheduler next-run timestamp
```

Solche Werte dürfen während einer laufenden Mission beobachtet und für Entscheidungen verwendet werden, werden aber nicht als dauerhafte Kampagnenwahrheit gespeichert.

## 5. `moose_mission_binding`

Das in Dokument 88 vorgesehene Feld `moose_mission_binding` wird in zwei Teile getrennt:

```text
persistent:
- optional stable execution correlation token
- last known execution generation / attempt identifier

runtime only:
- actual AUFTRAG object
- FLIGHTGROUP object
- MOOSE object references
```

Damit kann eine Air-Tasking-Mission nachvollziehen, dass sie bereits einen Ausführungsversuch hatte, ohne ein nicht wiederherstellbares Lua-/MOOSE-Objekt zu persistieren.

Phase 1 legt die konkrete Feldstruktur fest.

## 6. Neustart- und Restore-Semantik

Nach einem Missions- oder Serverneustart gilt:

```text
restore persistent domain state
    ↓
reconcile open requests and missions
    ↓
reconcile CampaignState reservations / settlements
    ↓
materialize fresh MOOSE objects only where still required
```

Nicht zulässig ist:

```text
restore serialized MOOSE/DCS object
```

Für eine beim Neustart offene Mission muss später anhand ihrer fachlichen Daten und des CampaignState-Zustands entschieden werden, ob sie:

```text
- wieder geplant wird;
- neu materialisiert wird;
- als stale/abgebrochen bewertet wird;
- auf eine neue Mission überführt wird;
- ohne erneuten Ressourcenverbrauch geschlossen wird.
```

Die konkrete stale-mission recovery gehört zu Phase 6. Phase 0 legt nur die Persistenzgrenze fest.

## 7. Laufende Mission versus strategischer Zustand

Ein DCS-Neustart beendet die physische Repräsentation, nicht automatisch den zugrunde liegenden kampagnenweiten Bedarf.

Deshalb gilt:

```text
DCS group disappeared because mission/server restarted
!= aircraft strategically lost

MOOSE AUFTRAG no longer exists after restart
!= AIR_TASKING_MISSION automatically failed
```

Strategische Verlust-, Verbrauchs- oder Erfolgsentscheidungen dürfen nur durch den zuständigen Settlement-Vertrag getroffen werden.

## 8. Player- und UI-Daten

Persistiert werden dürfen nur die zugrunde liegenden fachlichen Daten, soweit sie selbst kampagnenrelevant sind.

Nicht als eigene Autorität persistiert werden:

```text
rendered mission-card text
rendered F10 menu text
rendered kneeboard page
localized display strings
formatted ATO-like export text
```

Diese Ausgaben werden aus den persistenten Request-/Mission-/Plan-Daten erneut erzeugt.

Damit gilt:

```text
persistent domain data
    ↓
view generation
    ↓
player-facing output
```

und nicht:

```text
player-facing output
    ↓
becomes new mission truth
```

## 9. Historie und Retention

Terminale Requests und Missionen dürfen als kompakte Historie persistiert werden, soweit dies für:

- Debriefing;
- Kampagnenwirkung;
- Idempotenz;
- Auditierbarkeit;
- spätere Statistik oder ATO-artige Tagesübersicht

erforderlich ist.

Die konkrete Retention-Dauer, Archivierung und mögliche Verdichtung werden erst in Phase 6 festgelegt.

## 10. Phase-0-Entscheidung

Für die weitere Entwicklung gilt:

```text
PERSISTENT
- stable domain IDs
- request records
- mission planning records
- plan metadata
- resource reservation / settlement references
- support relationships
- terminal results and required history

RUNTIME ONLY
- MOOSE objects
- DCS objects
- schedulers / callbacks / FSM instances
- physical group identity
- current technical execution handles
- rendered player views
```

Die spätere Lua-Implementierung muss diese Trennung bereits im Datenmodell ermöglichen.

## 11. Noch offene Folgepunkte

Mit diesem Dokument ist der Phase-0-Punkt `festlegen, welche Air-Tasking-Daten persistent und welche nur Runtime-Daten sind` abgeschlossen.

Weiter offen bleiben:

```text
- stable ID convention
- MissionDemand producer/consumer boundary
- view/briefing-data authority boundary
- Gate 0 assessment
```

Die konkrete Serialisierung, Snapshot-Versionierung und Restore-Implementierung gehören nicht zu Phase 0.

Kein DCS-Test ist für diese reine Architekturentscheidung erforderlich. `validated_in_dcs` bleibt `false`.
