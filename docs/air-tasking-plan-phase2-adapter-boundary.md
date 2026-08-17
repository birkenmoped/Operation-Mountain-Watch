---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-ADAPTER-BOUNDARY
status: DRAFT
document_class: MOOSE_INTEGRATION_BOUNDARY
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local final Phase-2 boundary between persistent OMW Air Tasking data and MOOSE runtime objects
  - branch-local field and lifecycle handoff contract before Gate 2
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - Phase-3 implementation details not yet tested
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – Final OMW / MOOSE Adapter Boundary

## 1. Zweck

Dieses Dokument schließt die Phase-2-Frage ab, welche Daten im OMW-Air-Tasking-Domänenmodell autoritativ bleiben und welche Informationen an MOOSE zur operativen Ausführung übergeben werden.

Ziel ist ausdrücklich **keine** neue Dispatcher- oder Missionsengine, sondern die kleinste notwendige Korrelationsschicht zwischen bereits definiertem OMW-Domainzustand und den source-geprüften MOOSE-Mechanismen.

## 2. Zielpfad

```text
CampaignState / MissionDemand
        ↓
AIR_SUPPORT_REQUEST / AIR_TASKING_MISSION
        ↓
small OMW Air Tasking adapter
        ↓
COMMANDER
        ↓
AIRWING / BRIGADE
        ↓
SQUADRON / PLATOON
        ↓
AUFTRAG
        ↓
FLIGHTGROUP / ARMYGROUP
        ↓
DCS
        ↓
MOOSE events / mission result observations
        ↓
small OMW correlation / settlement adapter
        ↓
AIR_TASKING_MISSION / request result / CampaignState settlement
```

`CHIEF` bleibt für diesen Pfad `REJECTED_FOR_PROJECT_USE`.

## 3. OMW Domain-Wahrheit

Folgende Daten bleiben außerhalb von MOOSE autoritativ und persistent, soweit Phase 1 sie als persistent definiert:

```text
request_id
mission_id
mission_demand_ids
request_ids
support_relationship_ids
execution_attempt_ids
request status
Air Tasking mission status
planned_start / planned_stop
alert_window / readiness_time
command / tasking / request authority
strategic resource reservation refs
departure_node_id / recovery_node_id
assigned_squadron_id as organizational/strategic constraint
aircraft_type / aircraft_count as planning requirement
player_or_ai_assignment
control_agency_id
report_in_point_id
persistent mission result/history
```

Diese Felder dürfen nicht durch MOOSE-Objekt-IDs oder DCS-Gruppennamen ersetzt werden.

## 4. Daten, die in MOOSE übersetzt werden

Nur für die physische Ausführung erforderliche Werte werden aus der Domain beziehungsweise aus zuständigen Fachbaselines in MOOSE-Konfiguration übersetzt.

Je nach Missionstyp gehören dazu:

```text
AUFTRAG mission constructor / type
runtime target / zone / coordinate
required runtime asset count
mission altitude / speed / range where applicable
mission start / stop / duration where applicable
ingress / holding / egress runtime geometry where applicable
runtime mission priority / urgency only if explicitly mapped from OMW policy
allowed LEGION / COHORT scope derived from strategic assignment constraints
mission-specific MOOSE settings already owned by existing adapters
```

Der Adapter überträgt nicht automatisch jedes Domainfeld an AUFTRAG.

## 5. Missionstyp-Mapping

### AAR

```text
OMW AAR
→ existing strategic AAR adapter / profile data
→ AUFTRAG:NewTANKER(...)
```

Die bestehende AAR-Baseline bleibt maßgeblich. Air Tasking ersetzt weder MissionDemand-/Area-/Profile-Auswahl noch Fuel-/Relief-/Egress-/Settlement-Verträge.

### CAS

```text
OMW CAS
→ AUFTRAG:NewCAS(...)
   or AUFTRAG:NewCASENHANCED(...)
```

Die endgültige Variante ist eine missionsspezifische Implementierungsentscheidung für den späteren CAS-Scope. Phase 2 bestätigt lediglich, dass MOOSE die physische CAS-Missionsart nativ trägt.

### ISR

```text
OMW ISR execution requirement
→ AUFTRAG:NewRECON(...)
```

`NewRECON` trägt Route/Presence der Recon-Mission. Sensor-/INTEL-Wirkung und kampagnenweite Aufklärung bleiben separate zuständige MOOSE-/OMW-Verträge und werden nicht aus `AUFTRAG` erfunden.

### CSAR

```text
OMW CSAR
→ dedicated MOOSE CSAR / AICSAR path
```

`AUFTRAG:NewRESCUEHELO(Carrier)` ist carrier-spezifisch und keine generische Downed-Aircrew-CSAR-Mission. Eine eigene OMW-CSAR-Engine ist nicht vorgesehen.

### AIRLIFT

Der Adapter wählt nach tatsächlicher Cargo-Semantik:

```text
troops / groups
→ AUFTRAG:NewTROOPTRANSPORT(...)

external sling cargo
→ AUFTRAG:NewCARGOTRANSPORT(...)

internal static freight to destination / airbase
→ AUFTRAG:NewFREIGHTTRANSPORT(...)
```

Am gepinnten eingebetteten Quellstand gilt ausdrücklich:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= source text commented out
= not callable
= MUST NOT USE
```

### ESCORT

```text
OMW ESCORT
→ AUFTRAG:NewESCORT(...)
```

MOOSE trägt damit die physische Follow-/Escort-Ausführung.

## 6. Runtime-Korrelation

Für jede AI-Ausführung ist nur eine kleine temporäre Zuordnung erforderlich:

```text
OMW execution_attempt_id
    ↔ OMW mission_id
    ↔ AUFTRAG runtime reference / auftragsnummer
    ↔ FLIGHTGROUP or ARMYGROUP runtime reference
```

Persistiert werden **nicht**:

```text
AUFTRAG object
COMMANDER object
AIRWING / BRIGADE object
SQUADRON / PLATOON object
FLIGHTGROUP / ARMYGROUP object
DCS Group object
MOOSE auftragsnummer as OMW identity
DCS group name as OMW identity
```

Nach Missions-/Server-Neustart werden physische Runtimeobjekte aus strategischem Zustand und Planungsdaten neu materialisiert beziehungsweise reconciliert.

## 7. Assignment-Reihenfolge

Für AI-Missionen lautet die Foundation-Reihenfolge:

```text
1. MissionDemand / Request prüfen
2. Authority prüfen
3. CampaignState strategic availability prüfen
4. strategische Reservation durchführen
5. zulässigen MOOSE execution scope bestimmen
6. AUFTRAG erzeugen und konfigurieren
7. COMMANDER / LEGION native capability and asset allocation verwenden
8. OpsOnMission / FlightOnMission / ArmyOnMission mit execution_attempt_id korrelieren
9. AUFTRAG / OPSGROUP lifecycle beobachten
10. missionsspezifisches Ergebnis bewerten
11. CampaignState exact-once settlement durchführen
12. Request-/Missionstatus persistent fortschreiben
```

MOOSE-Auswahl darf Schritt 3/4 nicht ersetzen. OMW darf Schritt 7 nicht durch eine parallele Asset-Scoring-/Dispatcher-Engine ersetzen.

## 8. Lifecycle-Mapping

MOOSE-Ereignisse werden als **Beobachtungen** verwendet, nicht als persistentes OMW-Statusmodell.

Vorläufig verbindliche Grenze:

```text
MissionAssign / LEGION queue
→ operative Zuweisung erfolgt

FlightOnMission / ArmyOnMission
→ konkrete physische Execution-Instanz existiert

AUFTRAG STARTED
→ MOOSE execution started

AUFTRAG EXECUTING
→ MOOSE task execution active

AUFTRAG DONE
→ technische Ausführung beendet
→ NOT automatically OMW success

AUFTRAG SUCCESS
→ positiver MOOSE-Endzustand
→ missionsspezifischen Kampagneneffekt trotzdem prüfen

AUFTRAG FAILED
→ negativer MOOSE-Endzustand
→ OMW failure/settlement path

AUFTRAG CANCELLED
→ operative Cancellation
→ strategische Reservation erst durch OMW exact-once settlement freigeben

AssetDead / no living OPSGROUP
→ native Loss-Beobachtung
→ strategischen Verlust über OMW settlement verbuchen
```

## 9. Events statt globalem Polling

Bevorzugte Korrelationspunkte:

```text
COMMANDER:OnAfterOpsOnMission(...)
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
AUFTRAG lifecycle callbacks
OPSGROUP MissionStart / MissionExecute / MissionDone / MissionCancel callbacks
mission-specific FLIGHTGROUP / ARMYGROUP callbacks only where needed
```

Damit sind nicht erforderlich:

```text
frame scans
high-frequency global schedulers
global DCS group discovery for mission correlation
parallel OMW mission FSM for physical execution
```

Bounded status checks bleiben nur für dokumentierte Sonderfälle zulässig.

## 10. Capability-/Allocation-Grenze

```text
OMW
= defines allowed strategic envelope

MOOSE
= selects and executes operational assets inside that envelope
```

MOOSE `COHORT:AddMissionCapability(...)`, Performance, payload suitability und COMMANDER-/LEGION-Rekrutierung werden nativ genutzt. OMW entwickelt keine zweite Capability-/Performance-Matrix.

## 11. Bestehende Adapter nicht ersetzen

Wo ein spezialisierter OMW-Adapter bereits eine akzeptierte missionsspezifische Grenze besitzt, wird Air Tasking davor beziehungsweise darum herum integriert.

Insbesondere für AAR:

```text
Air Tasking
→ request / mission planning / correlation
→ existing AAR strategic adapter
→ existing MOOSE execution path
```

Nicht zulässig:

```text
Air Tasking recomputes AAR area/profile selection
Air Tasking replaces AAR FuelLow/relief logic
Air Tasking creates a second external tanker inventory
Air Tasking settles CampaignState independently from the existing exact-once contract
```

## 12. Fehlergrenze

Eine fehlende MOOSE-Runtime-Allokation trotz strategischer Reservation wird als operative Failure-/Replanning-Bedingung zurückgemeldet. Sie berechtigt nicht zu:

```text
unreserved spawn
bypass of COMMANDER/LEGION
invented strategic inventory
native-DCS parallel dispatcher
```

Die vorhandene OMW Cancellation-/Failure-/Settlement-Semantik entscheidet über Reservation Release, Retry oder Replanning.

## 13. Ergebnis

Der Manifestpunkt

```text
OMW planning data vs. data handed to MOOSE
```

ist für den Foundation-Scope abgeschlossen.

Ergebnis:

```text
PASS_FOR_ARCHITECTURE_AND_SOURCE_REVIEW
validated_in_dcs: false
```

Die benötigte projektspezifische Ergänzung ist auf eine kleine Domain-to-MOOSE-Übersetzungs- und Lifecycle-Korrelationsschicht begrenzt. Es wurde keine technische Notwendigkeit für eine parallele OMW-Command-, Capability-, Asset- oder Physical-Mission-Engine festgestellt.
