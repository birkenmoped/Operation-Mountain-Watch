---
document_id: OMW-AIR-TASKING-PLAN-FOUNDATION-MANIFEST
status: PLANNED
document_class: IMPLEMENTATION_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - phased work plan for agent/air-tasking-plan-foundation
  - implementation gates and dependencies for Air Tasking Plan runtime development
not_authoritative_for:
  - repository-wide architecture beyond OMW-AIR-TASKING-PLAN-FOUNDATION
  - MOOSE method signatures not yet verified against the pinned Moose.lua
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Foundation – Manifest / To-do

## 1. Zielzustand

Der Branch `agent/air-tasking-plan-foundation` entwickelt die in [`OMW-AIR-TASKING-PLAN-FOUNDATION`](88-air-tasking-plan-foundation.md) festgelegte Architektur schrittweise bis zu einem belastbaren ersten vertikalen Integrationsnachweis.

Zielarchitektur:

```text
CampaignState
    ↓
MissionDemand
    ├── direct tasking within verified command/tasking authority
    │       ↓
    │   MOOSE execution
    │
    └── AIR_SUPPORT_REQUEST across an authority boundary
            ↓
        AIR_TASKING_PLAN
            ↓
        OMW Tasking Adapter
            ↓
        MOOSE COMMANDER / AIRWING / BRIGADE / SQUADRON / PLATOON / AUFTRAG
            ↓
        FLIGHTGROUP / ARMYGROUP / DCS
            ↓
        mission result / request result / CampaignState effect
```

Die Foundation darf keine zweite Ressourcenhoheit neben CampaignState, MOOSE STORAGE/Warehouse oder den bestehenden Air-Ops-Verträgen erzeugen. Die reale NATO-/ISAF-C2-Struktur dient als historische Plausibilitätsvorlage; OMW bildet sie nicht 1:1 nach. MOOSE bleibt bevorzugter Mechanismus für Asset-Auswahl, Mission Assignment und physische Ausführung.

## 2. Branch-Basis und Abhängigkeiten

```text
branch: agent/air-tasking-plan-foundation
initial_main_sync: 180ecf748110e1777146c0ad357ea79d1976800f
current_main_reconciliation: d9150f96fac5b546fe515c89fd139851c6e9829b
```

Wesentliche Abhängigkeiten:

- `OMW-GOV-001` – Projekt-Governance;
- `OMW-GOV-MOOSE-FIRST` – MOOSE-First;
- `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS` – ATO/ASR/CAS/AAR-Fachdatenmodell;
- `OMW-AIR-TASKING-PLAN-FOUNDATION` – verbindliche Architekturentscheidung;
- `OMW-ARCH-CAMPAIGN-STATE` – strategische Zustands-/Ressourcenautorität;
- `OMW-AIR-IMPLEMENTATION` – technische Air-Ops-Grundstruktur;
- aktuelle AIRWING-/SQUADRON-/Warehouse-Foundations;
- aktuelle AAR-Baseline nach Abschluss ihrer Finalisierung;
- `OMW-AIR-TASKING-PLAN-PHASE0-COMMAND-AUTHORITY` – branch-lokale Authority-Grenzen;
- `OMW-AIR-TASKING-PLAN-PHASE0-MOOSE-COMMAND-MODEL-DECISION` – MOOSE-zentrierte C2-Designentscheidung;
- `OMW-AIR-TASKING-PLAN-PHASE0-VIEW-AUTHORITY` – branch-lokale View-/Briefing-Autoritätsgrenze;
- `OMW-AIR-TASKING-PLAN-PHASE1-DOMAIN-DATA-CONTRACT` – branch-lokaler Phase-1-Kerndatenvertrag;
- `OMW-AIR-TASKING-PLAN-PHASE1-MISSION-TYPE-FIELDS` – branch-lokale missionstypabhängige Feldprofile;
- `OMW-AIR-TASKING-PLAN-PHASE1-STATUS-LIFECYCLE` – branch-lokale Request-/Mission-Statusautomaten und Transitionen;
- `OMW-AIR-TASKING-PLAN-PHASE1-CANCELLATION-FAILURE-SETTLEMENT` – branch-lokale Cancellation-/Failure-/Settlement-Grenze;
- `OMW-AIR-TASKING-PLAN-PHASE1-SUPPORT-RELATIONSHIP` – branch-lokale Support-Beziehungs-, Richtungs- und Zyklusregeln;
- `OMW-AIR-TASKING-PLAN-PHASE1-PLAYER-AI-ASSIGNMENT` – branch-lokale Player-/AI-Assignment-Grenze ohne Ressourcenhoheit;
- `OMW-AIR-TASKING-PLAN-PHASE1-SNAPSHOT-SERIALIZATION` – branch-lokaler Snapshot-/Serialisierungsvertrag;
- `OMW-AIR-TASKING-PLAN-PHASE1-VALIDATION-LOGGING` – branch-lokale Validierungs- und Logging-Regeln;
- `OMW-AIR-TASKING-PLAN-PHASE1-GATE-ASSESSMENT` – branch-lokale Gate-1-Gesamtbewertung;
- `OMW-AIR-TASKING-PLAN-PHASE2-MOOSE-VERSION-BASELINE` – branch-lokale gepinnte MOOSE-Verifikationsbaseline;
- `OMW-AIR-TASKING-PLAN-PHASE2-CHIEF-VERIFICATION` – branch-lokale CHIEF-Quellprüfung und Authority-Grenze.

Die AAR-Finalisierung ist inzwischen auf `main` integriert. Die konkrete AAR-Runtime-Anbindung bleibt dennoch bis Phase 3 gesperrt; bis dahin werden ausschließlich die Foundation-Verträge und die MOOSE-First-Verifikation abgeschlossen.

## 3. Phasenübersicht

```text
PHASE 0  Governance / Reconciliation / Contracts
PHASE 1  Domain Data Model
PHASE 2  MOOSE-First Capability Verification
PHASE 3  First Vertical Integration – AAR
PHASE 4  Player-Facing Mission Products
PHASE 5  Ground Alert / CAS Request Lifecycle
PHASE 6  Dynamic Planning / Retasking / Persistence
```

Jede Phase besitzt ein eigenes Gate. Eine spätere Phase darf Designarbeiten vorziehen, aber produktive Runtime-Abhängigkeiten dürfen ein vorheriges Gate nicht umgehen.

---

# PHASE 0 – Governance / Reconciliation / Contracts

## Ziel

Alle Autoritätsgrenzen und Schnittstellen festlegen, bevor Runtime-Code entsteht.

## To-do

- [x] eigenständigen Branch `agent/air-tasking-plan-foundation` von `main` anlegen;
- [x] verbindliche Architekturentscheidung auf `main` dokumentieren;
- [x] Dokument 88 im zentralen Dokumentregister reservieren;
- [x] ATO Examples 1–3 als `EXAMPLE_ONLY`-Quellen erfassen;
- [x] aktuellen Stand von Dokument 54 gegen Dokument 88 prüfen und Überschneidungen/Abgrenzungen dokumentieren;
- [x] `CampaignState`-Vertrag für Air-Support-Requests, Missionsreservierungen und Ergebnisrückmeldung festlegen;
- [x] festlegen, welche Air-Tasking-Daten persistent und welche nur Runtime-Daten sind;
- [x] stabile ID-Konventionen für Request-, Mission- und Support-Beziehungen definieren;
- [x] MissionDemand-Origin/Consumer-Grenze über Command-/Tasking-/Request-Authority und CampaignState-Kanonisierung festlegen;
- [x] MOOSE-zentriertes Command-Modell als Projektentscheidung für diesen Foundation-Branch festlegen: historisch plausibel, Authority-Grenzen sichtbar, keine 1:1-NATO-C2-Simulation;
- [x] festlegen, welche Daten ausschließlich Views/Briefingdaten sind und keine Ressourcenautorität besitzen;
- [x] Branch gegen den nach AAR-Finalisierung aktuellen `main`-Stand reconciliieren; konkrete AAR-Runtime-Anbindung bleibt Phase 3.

## Gate 0

```text
PASS wenn:
- Ressourcenautorität eindeutig bleibt;
- Request/Mission/Support-IDs eindeutig definiert sind;
- Persistenzgrenze dokumentiert ist;
- MissionDemand-Origin und Authority-Grenzen eindeutig definiert sind;
- Views/Briefingprodukte keine eigene Ressourcen-, MissionDemand- oder Tasking-Autorität besitzen;
- keine direkte Runtime-Implementierung eine ungeklärte Architekturentscheidung vorwegnimmt.
```

Branch-lokale Gate-Bewertung:

```text
GATE 0: PASS
scope: architecture/contracts only
runtime_validation: not applicable yet
validated_in_dcs: false
```

Die noch offenen Detailfragen zu konkreten Command Nodes, Capability-Zuordnungen, MOOSE-Topologie, Priorisierung und Retasking sind bewusst den folgenden Domain-/MOOSE-/Runtime-Phasen zugeordnet und blockieren Gate 0 nicht.

---

# PHASE 1 – Domain Data Model

## Ziel

Ein DCS-/MOOSE-unabhängiges OMW-Domänenmodell für Requests, Air-Tasking-Missionen und Pläne definieren.

## Mindestobjekte

### `AIR_SUPPORT_REQUEST`

Vorgesehene Kernfelder:

```text
request_id
mission_demand_id
support_type
request_timing
requesting_entity_id / requesting_command_node_id
priority
created_at
required_effect_or_task
area_or_target_reference
time_constraints
status
assigned_mission_ids
```

Dabei gilt:

```text
support_type = CAS | AAR | ISR | CSAR | AIRLIFT | ESCORT | OTHER
request_timing = PREPLANNED | IMMEDIATE | EMERGENCY
```

Capability und zeitliche Bearbeitungsklasse werden getrennt modelliert.

### `AIR_TASKING_MISSION`

Vorgesehene Kernfelder:

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
assigned_squadron_id
aircraft_type
aircraft_count
callsign
mission_area_id
target_reference
control_agency_id
report_in_point_id
support_relationship_ids
resource_reservation_refs
player_or_ai_assignment
execution_attempt_ids
result
```

### `AIR_TASKING_PLAN`

Vorgesehene Funktionen:

```text
contains mission records
indexes by mission_id
links requests to missions
links missions to support missions
tracks planning/runtime status
provides read-only data for player-facing views
```

## To-do

- [x] konkrete Lua-Datenverträge beziehungsweise Modulschnittstellen entwerfen;
- [x] Pflicht-/Optionalfelder je Missionstyp festlegen;
- [x] Statusautomaten für Request und Mission getrennt definieren;
- [x] erlaubte Statusübergänge dokumentieren;
- [x] Cancellation-/Failure-Semantik definieren;
- [x] Support-Beziehungen bidirektional nachvollziehbar machen, ohne zyklische Ressourcenhoheit zu erzeugen;
- [x] Player-/AI-Assignment als Planungsattribut definieren, nicht als zweite Aircraft-Resource-Tabelle;
- [x] Serialisierbarkeit der persistenten Teilmenge festlegen;
- [x] Datenvalidierungsregeln und Fehlerlogging mit stabilen IDs festlegen.

Aktuell profilierte Missionstypen:

```text
CAS
AAR
ISR
CSAR
AIRLIFT
ESCORT
```

Noch nicht profilierte Missionstypen dürfen als `DRAFT`-Forschungs-/Planungsdatensatz existieren, aber nicht bis zur Execution-Planung fortschreiten, bevor ein Feldprofil definiert ist.

## Gate 1

```text
PASS wenn:
- Datenmodell ohne DCS/MOOSE-Objekte instanziierbar ist;
- keine DCS-Gruppennamen als stabile IDs benötigt werden;
- CampaignState-Autorität nicht dupliziert wird;
- Request- und Mission-Lifecycle getrennt testbar sind.
```

Branch-lokale Gate-Bewertung:

```text
GATE 1: PASS
scope: domain architecture/contracts only
runtime_validation: not applicable yet
validated_in_dcs: false
```

Die Gesamtbewertung ist in `OMW-AIR-TASKING-PLAN-PHASE1-GATE-ASSESSMENT` dokumentiert. Damit ist Phase 1 branch-lokal abgeschlossen. Produktiver Adapter- oder Runtime-Code bleibt weiterhin bis zum Abschluss von Phase 2 gesperrt.

---

# PHASE 2 – MOOSE-First Capability Verification

## Ziel

Vor Adaptercode exakt bestimmen, welche Teile durch die tatsächlich verwendete MOOSE-Version getragen werden und wo nur eine kleine OMW-Adapterlogik erforderlich ist.

## Verbindlicher Rechercheweg

```text
MOOSE documentation for pinned version
→ actual pinned Moose.lua
→ signatures / returns / FSM events / prerequisites
→ official MOOSE demo/test missions
→ smallest OMW adapter design
```

## Zu prüfende MOOSE-Bereiche

Mindestens:

- `CHIEF`;
- `COMMANDER`;
- `AIRWING`;
- `BRIGADE`;
- `SQUADRON`;
- `PLATOON`;
- `AUFTRAG`;
- `FLIGHTGROUP`;
- `ARMYGROUP`;
- relevante OPS-/FSM-Events für Mission Assignment, Start, Execution und Completion;
- vorhandene Missionstypen für AAR und später CAS/Alert-nahe Abläufe;
- Mechanismen zur Missionsannahme, Verfügbarkeit und Statusbeobachtung;
- Möglichkeiten und Grenzen für zugewiesene, gebundene und externe Support-Assets ohne parallele OMW-Dispatcher-Engine.

**Keine Methodensignatur wird aus Erinnerung übernommen.** Jede produktiv genutzte Methode muss gegen die tatsächlich gepinnte `Moose.lua` bestätigt werden.

## To-do

- [x] pinned MOOSE branch/commit/hash aus `docs/moose/VERSION-AND-SOURCES.md` übernehmen;
- [x] `CHIEF`-relevante APIs und Verantwortungsgrenzen prüfen;
- [ ] `COMMANDER`-relevante APIs prüfen;
- [ ] `AIRWING`-/`BRIGADE`-relevante APIs prüfen;
- [ ] `SQUADRON`-/`PLATOON`-relevante APIs prüfen;
- [ ] `AUFTRAG`-Konstruktion und Missionstypen prüfen;
- [ ] Mission Assignment/Lifecycle/FSM-Callbacks prüfen;
- [ ] `FLIGHTGROUP`-/`ARMYGROUP`-Status-/Lifecycle-Anbindung prüfen;
- [ ] offizielle Beispiele für die tatsächlich benötigten Kombinationen prüfen;
- [ ] prüfen, welche Authority-/Allocation-Fälle MOOSE nativ oder durch Konfiguration/Kombination ausreichend trägt;
- [ ] dokumentieren, welche Daten im OMW-Plan bleiben und welche an MOOSE übergeben werden;
- [x] `docs/moose/PROJECT-CLASS-INDEX.md` aktualisieren;
- [x] passendes MOOSE-Themendokument aktualisieren oder neu anlegen;
- [x] noch **keine** Methode als `VALIDATED` markieren, solange kein dokumentierter DCS-Test existiert.

## Gate 2

```text
PASS wenn:
- jede geplante MOOSE-Verwendung quellengeprüft ist;
- Adaptergrenze explizit ist;
- keine MOOSE-Funktion unnötig nachgebaut wird;
- keine parallele OMW-Command-/Asset-Dispatcher-Engine entsteht;
- eventuelle echte Framework-Lücken dokumentiert sind.
```

Eine Nicht-MOOSE-Ausnahme benötigt vor Implementierung die ausdrückliche Freigabe des Projektinhabers.

---

# PHASE 3 – First Vertical Integration: AAR

## Voraussetzung

Die aktuelle AAR-Finalisierung ist abgeschlossen und der relevante Stand ist auf `main` verfügbar.

## Ziel

AAR als ersten vollständigen Nachweis verwenden:

```text
MissionDemand
→ AIR_SUPPORT_REQUEST
→ AIR_TASKING_MISSION
→ existing AAR strategic adapter
→ MOOSE execution
→ mission result
→ request result
```

## Warum AAR zuerst

AAR besitzt bereits:

- definierte MissionDemand-Beziehungen;
- CampaignState-Verfügbarkeitsregeln;
- operative Areas/Profile;
- strategischen Adapter;
- MOOSE-geführten Lifecycle;
- klare Acceptance-Grenzen.

Damit muss die Air-Tasking-Foundation nicht gleichzeitig auch erst eine neue physische Missionsart erfinden.

## To-do

- [x] Foundation-Branch mit aktuellem `main` nach AAR-Abschluss reconciliieren;
- [ ] AAR-Schnittstelle gegen die dann verbindliche Dokument-29-Baseline prüfen;
- [ ] einen AAR-Request-Typ definieren;
- [ ] eine AAR-Air-Tasking-Mission definieren;
- [ ] Support-/Receiver-Relationen optional abbilden;
- [ ] bestehenden AAR-Adapter anbinden, nicht ersetzen;
- [ ] MissionDemand-/Area-/Profile-Auswahl nicht duplizieren;
- [ ] STANDARD-Track-Lifecycle nicht durch starre ARCT-Planung überschreiben;
- [ ] FLEX-/Reserve-Bedarf als bevorzugten Receiver-Demand-Testfall prüfen;
- [ ] Mission- und Request-Status aus vorhandenen MOOSE-/AAR-Lifecycle-Ereignissen ableiten;
- [ ] Failure/Cancellation/Resource-return prüfen;
- [ ] Logging mit `request_id` und `mission_id` ergänzen;
- [ ] Testfixture erstellen;
- [ ] Syntax-/statische Tests durchführen;
- [ ] DCS-Integrationstest durchführen;
- [ ] Acceptance-Provenienz dokumentieren.

## Gate 3

```text
PASS wenn ein realer Testfall reproduzierbar zeigt:
MissionDemand
→ request
→ planned mission
→ MOOSE execution
→ completion/failure
→ korrektes Ergebnis ohne doppelte Ressourcenhoheit.
```

Erst danach darf der vertikale Air-Tasking-Pfad als technisch akzeptiert bezeichnet werden.

---

# PHASE 4 – Player-Facing Mission Products

## Ziel

Aus demselben strukturierten Missionsdatensatz unterschiedliche Spieleransichten erzeugen.

## Geplante Views

```text
AIR_TASKING_MISSION
    ├── Mission Briefing
    ├── Player Mission Card
    ├── Kneeboard data
    ├── F10 mission information
    ├── ATO-like overview
    └── Debrief / mission history view
```

## To-do

- [ ] minimale Player Mission Card festlegen;
- [ ] Trennung zwischen internen IDs und spielerrelevanter Darstellung definieren;
- [ ] Callsign-, Area-, Control- und Support-Information aus bestehenden autoritativen Datenquellen referenzieren;
- [ ] F10-Informationsumfang definieren;
- [ ] Kneeboard-/Briefing-Ausgabeweg technisch prüfen;
- [ ] DE/EN-Spielertextstrategie festlegen;
- [ ] keine USMTF-Rohnachricht als Standard-Spielerinterface verwenden;
- [ ] ATO-artige Gesamtübersicht als optionale Lage-/Operationsansicht definieren;
- [ ] sicherstellen, dass Views keine eigene Mission-/Ressourcenwahrheit speichern.

## Gate 4

```text
PASS wenn mehrere Player Views aus demselben Missionsdatensatz erzeugt werden können,
ohne redundante manuelle Missionsdaten zu pflegen.
```

---

# PHASE 5 – Ground Alert / CAS Request Lifecycle

## Ziel

Den Request-to-Mission-Lifecycle auf unmittelbaren CAS-Bedarf und Ground Alert erweitern.

Zielbild:

```text
eligible aircraft / alert mission
    ↓
GROUND ALERT
    ↓
campaign event / ground-unit demand
    ↓
AIR_SUPPORT_REQUEST
    ↓
mission assignment
    ↓
launch authorization
    ↓
transit
    ↓
CAS execution
```

## To-do

- [ ] historische/technische Grenze der Alert-Codes und Beispielwerte beibehalten;
- [ ] OMW-eigene Readiness-Stufen erst nach Projektentscheidung definieren;
- [ ] `alert_window` und `readiness_time` getrennt implementieren;
- [ ] Taxi, Takeoff, Transit und On-Station nicht in Readiness einrechnen;
- [ ] Aircraft-Reservierung gegen CampaignState/Warehouse-Vertrag prüfen;
- [ ] Spieler-Ground-Alert-Workflow definieren;
- [ ] KI-Ground-Alert-Workflow MOOSE-first prüfen;
- [ ] Request Assignment und Reassignment definieren;
- [ ] Launch-Abbruch, Spieler-No-show und Aircraft-Loss behandeln;
- [ ] CAS Control Agency/Report-In/Area als Missionsdaten anbinden;
- [ ] F10-/Mission-Card-Tasking für einen neu zugewiesenen Request erproben;
- [ ] DCS-Multiplayer-Test durchführen.

## Gate 5

```text
PASS wenn ein Spieler- oder KI-Flight auf Alert stehen kann,
ein echter Kampagnenbedarf einen Request erzeugt,
der Request einer Mission zugewiesen wird und diese Zuordnung bis zum Ergebnis nachvollziehbar bleibt.
```

---

# PHASE 6 – Dynamic Planning / Retasking / Persistence

## Ziel

Die Foundation zu einem dynamischen operativen Air-Tasking-System erweitern, ohne einen monolithischen ATO-Generator zu bauen.

## Geplante Fähigkeiten

- Priorisierung konkurrierender Air Support Requests;
- Verfügbarkeits- und Kapazitätsprüfung;
- Auswahl geeigneter Mission/Unit/Support-Beziehungen;
- Retasking bestehender Missionen, soweit MOOSE und die Missionsart dies sauber unterstützen;
- Mission Cancellation und Replacement;
- Support-Abhängigkeiten zwischen CAS/ISR/AAR/CSAR;
- persistente Request-/Mission-History;
- Wiederherstellung nach Mission/Server-Neustart, soweit für den Kampagnenvertrag erforderlich;
- Debrief-/Result-Korrelation;
- ATO-artige Tages-/Operationsübersicht.

## To-do

- [ ] Prioritätsmodell definieren;
- [ ] Konfliktauflösung bei knappen Assets definieren;
- [ ] Support Dependency Graph definieren;
- [ ] Retasking-Fähigkeiten der gepinnten MOOSE-Version prüfen;
- [ ] Persistenzschema definieren;
- [ ] Restore-Semantik definieren: strategischer Zustand versus temporäre DCS-Repräsentation;
- [ ] stale mission/request recovery definieren;
- [ ] Mission History und Result Records definieren;
- [ ] Multiplayer-Synchronisationsgrenzen prüfen;
- [ ] Performance-/Scheduler-Budget dokumentieren;
- [ ] keine hochfrequenten globalen Scans einführen;
- [ ] umfassende Integrations- und Regressionstests durchführen.

## Gate 6

```text
PASS wenn dynamische Planung und Retasking reproduzierbar funktionieren,
CampaignState strategisch autoritativ bleibt,
MOOSE die physische Missionsausführung führt
und Persistenz keine DCS-Objekte als dauerhafte strategische Wahrheit behandelt.
```

---

# 4. Cross-Cutting Acceptance Checklist

Für jede Runtime-Phase:

- [ ] Governance geprüft;
- [ ] zuständige Fachbaseline geprüft;
- [ ] tatsächlich gepinnte MOOSE-Version geprüft;
- [ ] MOOSE-Dokumentation geprüft;
- [ ] `Moose.lua`-Signaturen geprüft;
- [ ] offizielle MOOSE-Demo/Testmissionen geprüft, soweit relevant;
- [ ] keine parallele Framework-Funktion implementiert;
- [ ] CampaignState-Ressourcenautorität gewahrt;
- [ ] stabile IDs verwendet;
- [ ] DCS-/MOOSE-Objekte vor Zugriff validiert;
- [ ] vollständiger Diff geprüft;
- [ ] verfügbare Syntax-/Unit-/Integrationstests ausgeführt;
- [ ] DCS-Testbedarf ausdrücklich benannt;
- [ ] `VALIDATED` nur nach dokumentiertem DCS-Test vergeben;
- [ ] MOOSE-Projektdokumentation im selben Entwicklungsstand aktualisiert.

# 5. Nichtziele

Der Branch soll nicht:

- einen realen NATO-/USMTF-ATO-Workflow vollständig simulieren;
- historische Beispielcodes aus Sekundärquellen als OMW-Wahrheit übernehmen;
- `CampaignState` als Ressourcenautorität ersetzen;
- MOOSE `CHIEF`, `COMMANDER`, `AIRWING`, `BRIGADE`, `SQUADRON`, `PLATOON`, `AUFTRAG`, `FLIGHTGROUP` oder `ARMYGROUP` nachbauen;
- eine parallele OMW-Command-/Asset-Dispatcher-Engine neben MOOSE einführen;
- die inzwischen auf `main` integrierte AAR-Baseline vor Phase 3 erneut umbauen;
- alle Missionsarten gleichzeitig implementieren;
- Spieler mit Roh-ATO-Nachrichten als primärem Interface belasten.

# 6. Empfohlene Arbeitsreihenfolge ab jetzt

```text
1. Phase 2 MOOSE-First Capability Verification durchführen
2. Gate 2 prüfen
3. Phase 3 AAR Vertical Slice implementieren und testen
4. Phase 4 Player Views
5. Phase 5 Ground Alert / CAS
6. Phase 6 Dynamic Planning / Retasking / Persistence
```

Phase 0 und Phase 1 sind auf diesem Foundation-Branch als Architektur-/Contract-Gates abgeschlossen. Produktiver Adapter- oder Runtime-Code bleibt bis zum Abschluss von Phase 2 gesperrt.
