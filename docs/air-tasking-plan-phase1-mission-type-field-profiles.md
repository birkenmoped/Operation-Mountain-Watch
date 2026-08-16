---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-MISSION-TYPE-FIELDS
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 required and optional field profiles for Air Tasking mission types
  - separation of support capability type from request timing/urgency class
  - validation requirements before an Air Tasking Mission may advance beyond draft planning
not_authoritative_for:
  - final MOOSE AUFTRAG mission-type mapping
  - final MOOSE method signatures or runtime behavior
  - exact historical ATO/JTAR/ASR message formats
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Mission Type Field Profiles

## 1. Zweck

Dieses Dokument erfüllt den Phase-1-Arbeitspunkt:

```text
Pflicht-/Optionalfelder je Missionstyp festlegen
```

Es ergänzt `OMW-AIR-TASKING-PLAN-PHASE1-DOMAIN-DATA-CONTRACT`, ohne bereits MOOSE-`AUFTRAG`-Konstruktoren oder Runtime-Verhalten festzulegen.

Die Profile beschreiben ausschließlich, welche fachlichen Informationen ein OMW-Missionsdatensatz besitzen muss, bevor er von einem Entwurf in einen planbaren beziehungsweise zuweisbaren Zustand übergehen darf.

## 2. Korrektur der Request-Typ-Semantik

Die Air-Support-Fachbaseline unterscheidet bei einem Request zwischen dem **benötigten Support-/Capability-Typ** und der **zeitlichen Bearbeitungsklasse**.

Daher werden diese Konzepte im Phase-1-Datenmodell getrennt:

```text
support_type
= welche Luftunterstützung wird benötigt?

request_timing
= wie entsteht beziehungsweise wie dringend ist der Request?
```

Baseline:

```text
support_type examples:
CAS
AAR
ISR
CSAR
AIRLIFT
ESCORT
OTHER

request_timing:
PREPLANNED
IMMEDIATE
EMERGENCY
```

Damit ist beispielsweise zulässig:

```text
support_type = CAS
request_timing = IMMEDIATE
```

oder:

```text
support_type = AAR
request_timing = PREPLANNED
```

`request_timing = EMERGENCY` erzeugt keine automatische Waffenfreigabe, keine automatische Ressourcenzuweisung und keine Umgehung der CampaignState-/Authority-Grenzen.

Der bisher im konzeptionellen Beispiel verwendete Ausdruck

```text
request_type = CAS
```

ist daher semantisch zu präzisieren und darf in der späteren Lua-Implementierung nicht gleichzeitig Capability und Timing repräsentieren.

## 3. Gemeinsamer Missionskern

Jede `AIR_TASKING_MISSION` besitzt unabhängig vom Missionstyp mindestens den bereits definierten stabilen Kern:

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

Zusätzlich gelten vor einer operativen Zuweisung grundsätzlich folgende Validierungen:

```text
at least one MissionDemand reference
mission_type has a registered field profile
no unresolved authoritative resource ownership inside mission record
all required references use stable IDs
all mission-type-required fields are present
```

Ein leerer Wert ist bei einem Pflichtfeld nur dann zulässig, wenn das jeweilige Profil dies ausdrücklich als `required_before_execution` statt `required_before_planning` kennzeichnet.

## 4. Validierungsstufen

Um frühe Planung zu ermöglichen, werden drei Feldstufen unterschieden:

```text
CORE_REQUIRED
= bereits beim Anlegen des Missionsdatensatzes erforderlich

PLANNING_REQUIRED
= erforderlich, bevor die Mission als vollständig geplant beziehungsweise zuweisbar gilt

EXECUTION_REQUIRED
= spätestens erforderlich, bevor ein physischer Execution Attempt erzeugt wird

OPTIONAL
= fachlich zulässig, aber nicht für jeden Fall erforderlich
```

Diese Stufen sind keine Mission-Lifecycle-Zustände. Sie definieren nur Validierungszeitpunkte für Datenfelder.

## 5. CAS-Profil

`CAS` beschreibt Close Air Support für eigene beziehungsweise unterstützte Kräfte.

### 5.1 `CORE_REQUIRED`

```text
mission_id
mission_type = CAS
mission_demand_ids
status
change_serial
```

### 5.2 `PLANNING_REQUIRED`

```text
mission_area_id or target_reference
planned_start or time constraint reference
required effect through MissionDemand / Request reference
supported command/entity reference where applicable
```

Bei CAS über eine Authority-Grenze zusätzlich:

```text
request_ids = at least one AIR_SUPPORT_REQUEST
```

Bei direktem lokalen Tasking innerhalb eigener Tasking Authority darf dagegen gelten:

```text
request_ids = {}
```

### 5.3 `EXECUTION_REQUIRED`

```text
departure_node_id
recovery_node_id
assigned execution source reference
aircraft_type or equivalent capability selection result
aircraft_count or equivalent execution requirement
```

Wenn die Mission terminal durch eine modellierte Control Agency geführt wird, muss vor dem entsprechenden Ausführungsabschnitt eine gültige Control-/Terminal-Control-Referenz vorhanden sein. Phase 1 schreibt jedoch noch keine konkrete JTAC-/MOOSE-Runtime vor.

### 5.4 `OPTIONAL`

```text
control_agency_id
report_in_point_id
callsign
target_reference when area-based CAS is used
alert_window
readiness_time
support_relationship_ids
player_or_ai_assignment
```

Ground Alert ist kein eigener strategischer CAS-Bestand, sondern ein möglicher Bereitschafts-/Ausführungszustand einer dafür vorgesehenen Mission.

## 6. AAR-Profil

`AAR` beschreibt Air-to-Air Refueling Support.

### 6.1 `CORE_REQUIRED`

```text
mission_id
mission_type = AAR
mission_demand_ids
status
change_serial
```

### 6.2 `PLANNING_REQUIRED`

```text
planned_start
planned_stop
mission_area_id or AAR area/profile reference
departure_node_id
recovery_node_id
```

Wenn die AAR-Mission einen externen Support Request erfüllt:

```text
request_ids = at least one AIR_SUPPORT_REQUEST
```

Receiver-Zuordnungen dürfen über `SUPPORT_RELATIONSHIP` abgebildet werden und sind nicht für jede AAR-Mission zwingend erforderlich.

### 6.3 `EXECUTION_REQUIRED`

```text
assigned execution source reference
aircraft_type
aircraft_count
```

Die konkreten MOOSE-Tanker-Missionstypen, Frequenz-/TACAN-Methoden, Orbit-Geometrie und Lifecycle-Methoden werden erst in Phase 2 gegen die gepinnte `Moose.lua` verifiziert.

### 6.4 `OPTIONAL`

```text
control_agency_id
report_in_point_id
callsign
support_relationship_ids
receiver relationship timing
planned offload planning value
```

Ein geplanter Offload-Wert ist Planungs-/Briefinginformation und keine Fuel-Ressourcenautorität.

## 7. ISR-Profil

`ISR` beschreibt Intelligence-, Surveillance- oder Reconnaissance-Unterstützung.

### 7.1 `CORE_REQUIRED`

```text
mission_id
mission_type = ISR
mission_demand_ids
status
change_serial
```

### 7.2 `PLANNING_REQUIRED`

```text
mission_area_id or target_reference
planned_start
planned_stop or observation window
required observation/effect through MissionDemand / Request
```

### 7.3 `EXECUTION_REQUIRED`

```text
departure_node_id
recovery_node_id
assigned execution source reference
aircraft_type or capability type
aircraft_count or equivalent execution requirement
```

### 7.4 `OPTIONAL`

```text
request_ids
control_agency_id
report_in_point_id
callsign
support_relationship_ids
player_or_ai_assignment
```

Ein ISR-Ergebnis wird nicht allein durch das Ende des Fluges zum CampaignState-Erkenntnisgewinn. Die fachliche Auswertung beziehungsweise CampaignState-Wirkung bleibt Settlement-/MissionDemand-Semantik.

## 8. CSAR-/Rescue-Profil

`CSAR` beschreibt luftgestützte Unterstützung eines bestehenden autoritativen CSAR-/Personnel-Recovery-Bedarfs.

### 8.1 `CORE_REQUIRED`

```text
mission_id
mission_type = CSAR
mission_demand_ids
status
change_serial
```

### 8.2 `PLANNING_REQUIRED`

```text
incident/reference target
mission_area_id or recovery reference
planned_start or response window
```

Wenn ein separates autoritatives `CSARIncident`-Objekt existiert, muss die Air-Tasking-Mission dieses nur referenzieren und darf keinen zweiten Incident anlegen.

### 8.3 `EXECUTION_REQUIRED`

```text
departure_node_id
recovery_node_id
assigned execution source reference
aircraft_type or rescue capability
aircraft_count or equivalent execution requirement
```

### 8.4 `OPTIONAL`

```text
request_ids
control_agency_id
report_in_point_id
callsign
support_relationship_ids
escort relationship
player_or_ai_assignment
```

Die konkrete MOOSE-CSAR-Anbindung bleibt MOOSE-first und wird nicht durch diesen Datenvertrag vorweggenommen.

## 9. AIRLIFT-/Transport-Profil

`AIRLIFT` beschreibt Lufttransport einer fachlich autorisierten MissionDemand-/Logistikaufgabe.

### 9.1 `CORE_REQUIRED`

```text
mission_id
mission_type = AIRLIFT
mission_demand_ids
status
change_serial
```

### 9.2 `PLANNING_REQUIRED`

```text
departure_node_id
recovery_node_id or destination node reference
planned_start or delivery window
cargo/resource correlation reference when strategic cargo is involved
```

### 9.3 `EXECUTION_REQUIRED`

```text
assigned execution source reference
aircraft_type or transport capability
aircraft_count or equivalent execution requirement
```

### 9.4 `OPTIONAL`

```text
request_ids
mission_area_id
callsign
support_relationship_ids
player_or_ai_assignment
```

Strategischer Cargo-Bestand bleibt CampaignState-/Warehouse-Autorität. `AIR_TASKING_MISSION` speichert nur die erforderlichen Korrelationen und Planungsdaten.

## 10. ESCORT-Profil

`ESCORT` beschreibt eine Unterstützungsmission für eine andere Mission.

### 10.1 `CORE_REQUIRED`

```text
mission_id
mission_type = ESCORT
mission_demand_ids
status
change_serial
```

### 10.2 `PLANNING_REQUIRED`

```text
at least one support_relationship_id
provider/consumer relationship resolved through REL object
planned_start or relationship time constraints
```

### 10.3 `EXECUTION_REQUIRED`

```text
departure_node_id
recovery_node_id
assigned execution source reference
aircraft_type or escort capability
aircraft_count or equivalent execution requirement
```

### 10.4 `OPTIONAL`

```text
request_ids
mission_area_id
control_agency_id
report_in_point_id
callsign
player_or_ai_assignment
```

Eine Escort-Beziehung erzeugt keine Ressourcenreservierung durch ihre bloße Existenz.

## 11. Generische und noch nicht profilierte Missionstypen

Phase 1 legt bewusst keinen vollständigen Katalog aller später denkbaren Air-Missionen fest.

Für einen noch nicht profilierten Missionstyp gilt fail-closed:

```text
mission may exist as DRAFT research/planning record
but may not advance to execution planning
until a field profile is registered
```

Neue Profile müssen:

```text
- die CampaignState-Ressourcenautorität wahren;
- die Authority-Grenze aus Phase 0 respektieren;
- persistenten Domain State von MOOSE/DCS Runtime trennen;
- MOOSE-Execution erst nach Phase-2-Verifikation anbinden.
```

Damit werden Missionstypen nicht aus Erinnerung oder aus einem vermuteten MOOSE-`AUFTRAG`-Katalog erfunden.

## 12. Gemeinsame optionale Missionsdaten

Folgende Felder bleiben grundsätzlich optional und werden nur gesetzt, wenn Missionstyp und operative Planung sie benötigen:

```text
callsign
control_agency_id
report_in_point_id
alert_window
readiness_time
support_relationship_ids
player_or_ai_assignment
active_execution_attempt_id
result
closure_reason
```

`resource_reservation_refs` ist als Container Bestandteil des gemeinsamen Missionskerns, darf aber leer sein, solange noch keine strategische Ressource gebunden wurde.

## 13. Authority- und MOOSE-Grenze

Die Feldprofile entscheiden nicht, **welches konkrete Asset** ausgewählt wird.

Zielgrenze:

```text
OMW Domain Model
= describes requirement, authority references and planning constraints

MOOSE
= preferred asset selection / assignment / execution mechanism
```

Ein Feld wie

```text
assigned_airwing_id
assigned_squadron_id
```

ist deshalb nur dann zu setzen, wenn die Planung beziehungsweise die spätere MOOSE-Auswahl diese Zuordnung tatsächlich ergeben hat. Es darf nicht als Ersatz für einen eigenen OMW-Asset-Dispatcher missbraucht werden.

## 14. Konsequenz für die Phase-1-Implementierung

Der spätere Validator muss mindestens unterstützen:

```text
ValidateCore(mission)
ValidateForPlanning(mission)
ValidateForExecution(mission)
```

Die Funktionsnamen sind Designbezeichnungen und noch keine freigegebenen Lua-APIs.

Die Validierung muss missionstypabhängig sein und bei fehlenden Pflichtdaten fail-closed reagieren.

## 15. Phase-1-Status

Mit diesem Dokument ist der Arbeitspunkt

```text
[x] Pflicht-/Optionalfelder je Missionstyp festlegen
```

für die derzeit im Foundation-Scope benötigten Profile abgeschlossen.

Noch nicht festgelegt werden:

```text
- konkrete MOOSE-Missionstyp-Mappings
- konkrete MOOSE-Konstruktoren/Methoden
- produktive Alert-/CAS-/AAR-Runtime
- vollständiger Katalog aller möglichen Air Mission Types
```

Kein Runtime-Code wurde verändert. Kein DCS-Test ist für diesen Domain-Contract erforderlich. `validated_in_dcs` bleibt `false`.
