---
document_id: OMW-AIR-AIRFIELD-IMPLEMENTATION-WORKFLOW
status: BINDING
document_class: IMPLEMENTATION_WORKFLOW
owning_policy: OMW-GOV-001
authoritative_for:
  - mandatory preparation sequence for a new OMW airfield AIRWING node
  - mandatory AIRWING, SQUADRON and local COMMANDER acceptance gates
  - required Mission Editor, MOOSE, repository and provenance artifacts
  - separation of parking calibration from operational parking acceptance
  - mandatory handoff structure for the next airfield chat
not_authoritative_for:
  - active ORBAT or inventory selection for a specific airfield
  - base-specific object names, parking IDs, payloads or squadron identities
  - theater-wide production COMMANDER architecture
  - merge or Ready-for-Review authorization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - ad-hoc airfield implementation sequences without explicit phase gates
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Arbeitsanweisung – Flugplatz für AIRWING, SQUADRONs und COMMANDER vorbereiten

## 1. Zweck

Diese Arbeitsanweisung standardisiert die vollständige Vorbereitung eines weiteren Flugplatzes oder dauerhaft betriebenen Luftfahrtknotens für:

- Mission-Editor-Grundaufbau;
- MOOSE `AIRBASE`-/Warehouse-Auflösung;
- ein lokales `AIRWING`;
- typreine `SQUADRON`s;
- Capabilities und Payloads;
- direkten isolierten Dispatch;
- isolierte Auswahl und Zuweisung durch einen lokalen Acceptance-`COMMANDER`;
- reproduzierbare DCS-Acceptance;
- vollständige Dokumentation und Übergabe.

Ziel ist ein wiederholbarer Ablauf, bei dem ein neuer Chat nicht erneut den gesamten bisherigen Entwicklungsweg rekonstruieren muss.

## 2. Verbindliche Quellenhierarchie

Vor Vorschlägen, Code oder Missionseditor-Anweisungen sind mindestens folgende Dokumentgruppen zu prüfen.

### 2.1 Projektweite Autorität

```text
docs/00-project-governance.md
docs/DOCUMENT-METADATA-POLICY.md
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
```

### 2.2 Luftoperationen und Missionseditor

```text
docs/18-air-operations-implementation.md
docs/19-active-air-orbat-decisions.md
docs/20-air-orbat-mission-editor-worklist.md
docs/38-mission-editor-master-worklist.md
```

### 2.3 MOOSE und Testworkflow

```text
docs/26-moose-first-development-policy.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/moose/VERSION-AND-SOURCES.md
docs/moose/AIR-OPERATIONS.md
docs/moose/EVENTS-AND-FSM.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
```

### 2.4 Flugplatzspezifische Quellen

Für den neuen Flugplatz sind vollständig zu prüfen:

- eigenes oder vorbereitendes Air-Operations-Manifest;
- aktive ORBAT-Entscheidungen;
- historische Evidenz und Quellenkritik;
- Mission-Editor-Audits;
- Payload- und Loadout-Entscheidungen;
- relevante offene Branches und Draft-PRs;
- vorherige Acceptance-Berichte desselben Knotens;
- Handoffs des unmittelbar vorherigen Flugplatzes.

### 2.5 Referenzimplementierungen

Jalalabad, Bagram, Kandahar und Salerno sind Referenzen für Verfahren und nachgewiesene MOOSE-Nutzung. Ihre Bestände, Namen, Parking-IDs, Templategrößen und lokalen Sonderregeln dürfen nicht ungeprüft kopiert werden.

## 3. Unverhandelbare Grundregeln

1. **MOOSE-first:** Vor eigener Lua-Logik Dokumentation, exakter MOOSE-Quellcode und offizielle Beispiele prüfen.
2. **Bestandsaufnahme vor Änderung:** Keine Namen, Objekte oder Runtime-Strukturen erfinden, bevor Dokumentation und Mission geprüft wurden.
3. **Ein Flugplatz – ein Manifest:** Jede Basis benötigt einen eigenen autoritativen Objekt-, Bestands- und Testvertrag.
4. **Logischer Bestand ist keine Objektsumme:** Clients, Templates, Statics und aktive KI dürfen nicht mehrfach gezählt werden.
5. **SQUADRON zählt Gruppen:** `SQUADRON:New(..., Ngroups, ...)` verwendet Gruppenanzahl, nicht Luftfahrzeuganzahl.
6. **Read-only vor Mutation:** AIRBASE, Warehouse, Clients, Templates, Statics, Zonen und Parking zuerst nur diagnostizieren.
7. **Ein Dispatchpfad pro Acceptance-Lauf:** Direkter AIRWING-Dispatch und COMMANDER-Dispatch dürfen nicht parallel geprüft werden.
8. **Ein erwarteter Assettyp pro Auswahltest:** Sichtbarer Spawn muss eindeutig einem Auftrag zuordenbar sein.
9. **Positive PASS-Kriterien:** Ein Auftrag besteht nur bei ausdrücklich beobachteter Eignung, Auswahl, Anforderung und Zustandsprogression.
10. **Parking separat behandeln:** Kalibrierung, Tabellenkonsistenz und tatsächliche DCS-Platzierung sind drei verschiedene Ergebnisse.
11. **Fehlschläge bleiben erhalten:** FAIL, PARTIAL und INVALID erhalten eigene Ergebnisberichte.
12. **Keine Merge-Automatik:** Ein technischer PASS erteilt keine Merge- oder Ready-for-Review-Freigabe.

## 4. Pflichtdaten vor Beginn

Vor dem ersten Lua-Code muss folgende Datenmatrix vorliegen oder ausdrücklich als offen markiert sein.

| Bereich | Pflichtangabe |
|---|---|
| Flugplatz | historische Bezeichnung, DCS-Name, erwarteter MOOSE-Enum |
| Airbase | erwartete beziehungsweise zu ermittelnde `airdromeId` |
| ORBAT | aktiver Verband, Typ, logischer Bestand, Evidenzklasse |
| DCS-Abbildung | exakter DCS-Typ, historischer Ersatz, Mod-/Risikostatus |
| Clients | Anzahl, vollständige Gruppen- und Unitnamen, Startpositionen |
| KI-Templates | Gruppenname, Unitnamen, Typ, Gruppengröße, Rolle, Startart |
| SQUADRON | Name, Template, logische Stärke, `Ngroups`, Restbestand |
| Statics | Anzahl, Typ, Namen, Flächen, Bestandszuordnung |
| Warehouse | Ankername, Objekttyp, Koalition, Standort |
| Zonen | vollständiger Name, Zweck, tatsächlicher Verbraucher |
| Capabilities | AUFTRAG-Typen je SQUADRON |
| Payloads | Template, Rolle, Menge, Performance, Loadout-Quelle |
| Parking | ME-Labels, Client-/Static-Reservierungen, Runtime-TerminalIDs |
| Testmission | Dateiname und Ausgangshash |
| MOOSE | tatsächlich eingebetteter Commit und `Moose.lua`-SHA-256 |
| Branch | Basisbranch, Entwicklungsbranch, offene abhängige PRs |

Unbekannte Angaben dürfen nicht durch plausible Annahmen ersetzt werden. Sie werden als `OPEN`, `TO_BE_MEASURED` oder `NOT_APPLICABLE` dokumentiert.

## 5. Standardisierte Repository-Artefakte

Für `<airfield>` wird mindestens folgende Struktur angelegt:

```text
docs/<AIRFIELD>-air-operations-manifest.md
docs/evidence/<airfield>-air-operations-*.md
docs/handoffs/<date>-<airfield>-current-state-and-next-step-handoff.md

mission/tests/<airfield>-air-operations/
├── README.md
├── calibration/        # nur bei erforderlicher Parking-Kalibrierung
├── expected/
├── results/
└── src/

tools/build-<airfield>-air-operations-bundle.ps1
```

`dist/` wird ausschließlich vom Builder erzeugt und nicht manuell gepflegt.

### 5.1 Verbindliches Namensschema

Das konkrete Manifest legt die Namen fest. Standardmuster:

```text
AW_US_<BASE>
SQ_US_<BASE>_<TYPE>_<UNIT_OR_ROLE>
WH_AIR_US_<BASE>
CLIENT_US_<BASE>_<TYPE>_<NN>
TPL_AIR_US_<BASE>_<TYPE>_<ROLE>_<GROUPSIZE>
STATIC_AIR_US_<BASE>_<TYPE>_<NN>
ZONE_AIR_US_<BASE>_<FUNCTION>
```

Vorhandene akzeptierte Namen werden nicht ohne Migrationsentscheidung umbenannt.

## 6. Phase 0 – Repository- und Branchbaseline

### Aufgaben

- `main` und alle relevanten offenen Branches prüfen;
- Basisbranch und Abhängigkeiten dokumentieren;
- aktuellen lokalen Branch und Arbeitsbaum prüfen;
- keine unverbundenen Änderungen überschreiben;
- Testmission und Mission-Editor-Ausgangsstand hashen.

### Pflichtnachweis

```text
repository
base branch and commit
feature branch and commit
relevant PRs
mission file and SHA-256
working tree status
```

### Gate G0

```yaml
repository_context_known: true
branch_dependencies_known: true
mission_baseline_identified: true
unrelated_changes_protected: true
```

Ohne G0 keine Dokumentations- oder Codeänderung.

## 7. Phase 1 – Dokumentations- und Evidenzprüfung

### Aufgaben

- Governance vollständig lesen;
- aktive ORBAT und historische Quellen abgleichen;
- vorhandene Manifeste, Audits, Loadout-Entscheidungen und Handoffs prüfen;
- Widersprüche nicht stillschweigend auflösen;
- offene Entscheidungen als Liste an den Projektinhaber geben;
- bereits akzeptierte Namen und Strukturen identifizieren.

### Ergebnis

Eine Bestandsaufnahme mit:

```text
confirmed facts
binding project decisions
branch-bound technical evidence
open contradictions
missing Mission Editor data
missing MOOSE evidence
```

### Gate G1

Die aktive Flugplatz-ORBAT, der geplante DCS-Ersatz und der Scope des Grundknotens sind eindeutig. Ist dies nicht der Fall, wird noch kein Runtime-Code geschrieben.

## 8. Phase 2 – Flugplatzmanifest und Objektvertrag

Das Flugplatzmanifest muss vor mutierender Runtime-Logik mindestens festlegen:

- AIRBASE-/Warehouse-Vertrag;
- aktiven lokalen Bestand;
- Repräsentationsregeln;
- Clients;
- Templates;
- Statics;
- Zonen;
- SQUADRON-Matrix;
- Capabilities und Payloads;
- Startarten;
- Parking-Status;
- Acceptance-Scope;
- offene Grenzen.

### Bestandsrechnung

Für jedes Muster:

```text
logical aircraft inventory
units per AI template group
registered SQUADRON groups
aircraft represented by registered groups
logical residual reserve
client reservations
visible statics
```

Diese Werte werden getrennt dokumentiert.

### Gate G2

Alle verpflichtenden Mission-Editor-Namen, DCS-Typen und Mengen sind festgelegt. Der Missionsdesigner muss keine Namen oder Bestandsregeln improvisieren.

## 9. Phase 3 – Mission-Editor-Grundaufbau

### Aufgaben des Missionsdesigners

- Warehouse-Anker anlegen oder vorhandenen bestätigten Anker verwenden;
- Clientgruppen platzieren;
- Late-Activation-KI-Templates anlegen;
- Statics platzieren;
- erforderliche Zonen anlegen;
- Startarten, Gruppengrößen, Payloads und Liveries speichern;
- ausreichend Rotor-/Flügel-/Rollwegabstand prüfen;
- Mission speichern und Hash dokumentieren.

### Verboten

- Clientgruppen als KI-Templates wiederverwenden;
- Statics als zusätzlichen Bestand zählen;
- Zonen ohne konkreten Verbraucher prophylaktisch vervielfachen;
- Parking-IDs aus anderen Flugplätzen übernehmen;
- nicht bestätigte Community-Mod-Abhängigkeiten in die Kernmission einbauen.

### Gate G3

Das Manifest und der gespeicherte Missionsstand stimmen bezüglich Namen, Typen, Mengen und Rollen überein.

## 10. Phase 4 – MOOSE-first-Prüfung

Für jede benötigte Funktion gilt die Reihenfolge:

```text
1. passende MOOSE-Dokumentation
2. exakter Quellcode der eingebetteten Version
3. offizielle Demo-/Testmission
4. vorhandene OMW-Referenzimplementierung
5. erst danach kleinste notwendige OMW-Ergänzung
```

Mindestens zu prüfen:

- `AIRBASE`-Auflösung und Parking-APIs;
- `AIRWING`-Konstruktion, Airbase-Bindung und Start;
- `SQUADRON`-Konstruktion, Gruppierung und Registrierung;
- Mission Capabilities;
- `AIRWING:NewPayload()`;
- `AUFTRAG`-Konstruktor des gewählten Testtyps;
- `COMMANDER:New()`, `AddAirwing()`, `Start()`, `CanMission()`, `AddMission()` und `Status()`;
- relevante FSM-Callbacks;
- Warehouse-/Asset-Verhalten;
- Parkingpfad nur, wenn Parking Bestandteil des Tests ist.

### Pflichtdokumentation

```text
MOOSE commit
Moose.lua SHA-256
source files inspected
public methods used
callbacks used
known limitations
OMW adapters required
```

### Gate G4

Die geplante Lösung verwendet vorhandene MOOSE-Funktionalität. Jede Eigenlogik besitzt eine dokumentierte Lückenbegründung.

## 11. Phase 5 – Read-only-Diagnose

Der erste Bundle-Stand darf keine AIRWING-, SQUADRON-, Payload- oder Spawnmutation ausführen.

### Zu prüfen

- MOOSE-Verfügbarkeit und Provenienz;
- AIRBASE-Name und ID;
- Warehouse-Anker;
- Client-Templateexistenz;
- KI-Templateexistenz;
- DCS-Typen und Gruppengrößen;
- Statics;
- Zonen;
- Runtime-Parkingnodes;
- unerwartete Namenskollisionen.

Unbesetzte Clientgruppen werden über die Mission-Template-Datenbank validiert, nicht ausschließlich über aktive Runtime-GROUP-Wrapper.

### Gate G5

```yaml
airbase_resolved: true
warehouse_resolved: true
required_clients_found: true
required_templates_found: true
required_statics_found: true
required_zones_found: true
unexpected_mutation: false
lua_errors: false
```

Erst nach G5 wird der AIRWING-Grundknoten konstruiert.

## 12. Phase 6 – Parking-Kalibrierung

Diese Phase ist verpflichtend, wenn konkrete ME-Parkinglabels, Clientreservierungen oder Static-Ausschlüsse technisch verwendet werden sollen.

### 12.1 Kalibrierung

Mission-Editor-Labels werden gegen tatsächlich beobachtete MOOSE-`TerminalID`s gemappt.

```text
ME parking label != MOOSE TerminalID
```

Ergebnisstufen:

```yaml
parking_node_dump: PASS_or_FAIL
me_to_terminal_mapping: PASS_or_FAIL
mapping_ambiguity: count
```

### 12.2 Keine vorzeitige operative Mutation

Ein bestandener Mapping-Dump erlaubt noch keine Aussage über tatsächliche AIRWING-Spawnplatzierung.

```text
calibration PASS
!= configured pool consistency PASS
!= actual runtime placement PASS
```

### 12.3 Gate G6

Nur eindeutige Mappings dürfen in einen späteren Parking-Vertrag einfließen. Unsichere Positionen bleiben ausgeschlossen.

## 13. Phase 7 – AIRWING- und SQUADRON-Grundknoten

### Reihenfolge

1. AIRWING mit Warehouse-Anker konstruieren.
2. bestätigten AIRBASE explizit binden.
3. Startart setzen.
4. SQUADRONs aus bestätigten Templates konstruieren.
5. Gruppenzahl und logischen Restbestand prüfen.
6. SQUADRONs am AIRWING registrieren.
7. Capabilities und Payloads registrieren.
8. vollständige Preflight-Validierung ausführen.
9. erst danach `AIRWING:Start()`.

### Pflichttelemetrie

```text
AIRWING alias and state
bound AIRBASE name and ID
SQUADRON count
registered assets per SQUADRON
registered assets total
logical residual reserve
capabilities count
payload registrations and internal table count
mission queue count
```

### Grundknotentest

Nach Start muss der AIRWING ohne Auftrag stabil bleiben:

```yaml
airwing_state: Running
spontaneous_missions: 0
unexpected_spawns: 0
lua_errors: 0
```

### Gate G7

AIRWING, sämtliche SQUADRONs, Capabilities und Payloads bestehen die Grundvalidierung ohne automatische Mission.

## 14. Phase 8 – Isolierter direkter Dispatch

Der direkte Dispatch bestätigt zunächst, dass das lokale AIRWING unabhängig vom COMMANDER eine geeignete SQUADRON und ein Asset für genau einen Auftrag verwenden kann.

### Testregeln

- genau ein `AIRWING:AddMission()`-Pfad;
- genau ein Missionstyp;
- genau ein erwarteter Luftfahrzeugtyp;
- keine parallele RECON-, LIFT-, CAS- oder COMMANDER-Mission;
- eindeutiger Missionsname;
- FSM-Telemetrie;
- kontrollierter Cleanup.

### PASS-Kriterien

```yaml
mission_added: true
mission_left_planned: true
expected_squadron_selected: true
expected_asset_type_observed: true
ops_on_mission: true
lua_errors: false
```

Ein sichtbares Luftfahrzeug ohne eindeutige Zuordnung ist kein PASS-Nachweis.

### Gate G8

Der lokale AIRWING-Dispatch ist für mindestens einen repräsentativen Auftrag reproduzierbar bestanden.

## 15. Phase 9 – Isolierter COMMANDER-Auswahltest

Der lokale COMMANDER ist ausschließlich ein Acceptance-Harness. Er ist noch nicht die theaterweite Produktionsinstanz.

### Verbindliche Sequenz

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status()
```

### Pflichtzustände

```text
before Start: NotReadyYet
 after Start: OnDuty
```

### Pflichttelemetrie

- COMMANDER-Legionanzahl;
- AIRWING-Rückreferenz;
- `CanMission()`;
- Commander- und AIRWING-Missionqueue;
- `MissionAssign`;
- `MissionRequest`;
- `OpsOnMission`;
- AUFTRAG-Zustand;
- ausgewählter SQUADRON-/Assettyp.

### Testisolation

```yaml
direct_airwing_missions: 0
commander_missions: 1
expected_aircraft_type: exactly_one
parking_acceptance_in_same_run: false
```

### Zustandsauswertung

Zustandsstrings werden vor Vergleichen normalisiert. `planned` und `unknown` sind kein Fortschritt.

PASS ist nur zulässig, wenn:

```yaml
commander_state_onduty: true
commander_can_mission: true
mission_assigned: true
airwing_requested_mission: true
expected_asset_ops_on_mission: true
auftrag_progressed: true
```

### Gate G9

Der COMMANDER hat das lokale AIRWING nachweislich ausgewählt und ein erwartetes Asset bis mindestens `started` überführt.

## 16. Phase 10 – Operative Parking-Acceptance, optional und separat

Parking darf nur dann als bestanden gelten, wenn für jede gespawnte Unit erfasst wird:

```text
runtime group name
runtime unit name
asset UID or equivalent identity
configured SQUADRON parking IDs
configured asset parking IDs
actual unit coordinate
nearest runtime TerminalID
mapped Mission Editor label
inside allowed pool
inside client exclusion
inside static exclusion
```

### Besondere Regel für Multi-Unit-Gruppen

Jede Unit wird einzeln bewertet. Die Gruppenposition oder Position der ersten Unit genügt nicht.

### PASS-Kriterien

- jede Unit liegt auf einem erlaubten Terminal;
- keine Unit verwendet Client-, Static- oder sonstige Sperrposition;
- erwartete Startart ist visuell und telemetrisch bestätigt;
- kein DCS-Relocation-/Fallback-Verhalten verletzt den Vertrag.

Scheitert Parking, wird es `DEFERRED`. Dies blockiert den bereits bestandenen AIRWING-/SQUADRON-/COMMANDER-Grundknoten nicht, sofern Parking ausdrücklich aus dessen Acceptance-Scope entfernt wurde.

## 17. Phase 11 – Provenienz und Abschluss

Jeder relevante PASS-, FAIL-, PARTIAL- oder INVALID-Lauf erhält einen eigenen Ergebnisbericht.

### Pflichtprovenienz

```text
branch
source commit
builder version
bundle path
bundle SHA-256
mission name
mission SHA-256
DCS version
MOOSE commit
Moose.lua SHA-256
test date and runtime window
logs evaluated
visual observations
```

### Pflichtbewertung

```text
test objective
expected result
actual result
classification
root cause
correction
still-valid findings
invalidated assumptions
remaining risks
next action
```

### Abschlussdokumente

- Flugplatzmanifest aktualisieren;
- technisches Test-README aktualisieren;
- MOOSE-Klassenindex und `VERIFIED-METHODS.md` aktualisieren;
- Evidence-/Lessons-Learned-Dokument aktualisieren;
- Handoff für den nächsten Chat erstellen;
- PR-Beschreibung auf tatsächlichen Scope bringen;
- nicht akzeptierte Bereiche ausdrücklich nennen.

### Gate G10

```yaml
manifest_current: true
results_complete: true
provenance_complete: true
moose_docs_current: true
handoff_complete: true
contradictory_current_docs: false
```

Erst nach G10 gilt der Flugplatzgrundknoten als abgeschlossen.

## 18. Stop-Regeln

Die Arbeit wird angehalten und nicht durch Annahmen fortgesetzt, wenn:

- aktive ORBAT oder Einheitenauswahl widersprüchlich ist;
- DCS-Typ oder Templategröße unbekannt ist;
- Warehouse- oder AIRBASE-Bindung nicht eindeutig aufgelöst wird;
- Mission und eingebettetes Bundle nicht eindeutig dem Commit zugeordnet werden können;
- MOOSE-Dokumentation und tatsächlicher Quellstand nicht zusammenpassen;
- Testläufe mehrere Dispatchpfade oder Assettypen vermischen;
- ein PASS nur aus dem Fehlen eines einzelnen Fehlerzustands abgeleitet würde;
- tatsächliche DCS-Realisierung nicht von interner Tabellenkonsistenz getrennt werden kann;
- relevante Lua-/Timerfehler auftreten;
- ein Branchwechsel ungesicherte lokale Änderungen gefährdet.

## 19. Kompakte Master-To-do-Liste

```text
[ ] G0 Repository, Branches, Mission und Abhängigkeiten bekannt
[ ] G1 Dokumentation, ORBAT, Evidenz und Widersprüche geprüft
[ ] G2 Manifest und vollständiger Objektvertrag festgelegt
[ ] G3 Mission-Editor-Grundobjekte gespeichert und geprüft
[ ] G4 MOOSE-Dokumentation, Quellcode, Demos und OMW-Referenzen geprüft
[ ] G5 Read-only-Diagnose PASS
[ ] G6 Parking-Kalibrierung PASS oder ausdrücklich NOT_APPLICABLE
[ ] G7 AIRWING/SQUADRON/Capability/Payload-Grundknoten PASS
[ ] G8 isolierter direkter Dispatch PASS
[ ] G9 isolierter COMMANDER-Dispatch PASS
[ ] operative Parking-Acceptance separat PASS oder DEFERRED
[ ] G10 Provenienz, Ergebnisberichte, MOOSE-Doku und Handoff vollständig
```

## 20. Verbindliche Lehren aus Salerno

1. Mission-Editor-Parkinglabels sind keine MOOSE-TerminalIDs.
2. `syncedAssets` und null Vertragsverletzungen beweisen nur Tabellenkonsistenz.
3. Tatsächliche Spawnpositionen müssen anhand der einzelnen Runtime-Units gemessen werden.
4. Direkte LIFT-/RECON-/CAS-Missionen dürfen einen COMMANDER-Test nicht überlagern.
5. Ein sichtbarer Aircrafttyp ist ein wichtiges Attributionssignal.
6. Zustände werden normalisiert; `planned` ist kein Fortschritt.
7. `COMMANDER:AddAirwing()` startet den COMMANDER nicht.
8. Die korrekte COMMANDER-Sequenz war bereits im Jalalabad-Code vorhanden und muss vor Neuentwicklung geprüft werden.
9. Parking kann fachlich zurückgestellt werden, ohne einen sauber abgegrenzten AIRWING-/SQUADRON-/COMMANDER-PASS zu entwerten.
10. Ein technischer Grundknoten-PASS beweist noch keine taktische Missionsdurchführung, Rückkehr, Recovery oder Persistenz.

## 21. Ergebnis für den nächsten Chat

Ein neuer Flugplatzchat beginnt nicht mit Code. Die erste Antwort liefert ausschließlich:

1. geprüfte Branches und Dokumente;
2. aktuelle ORBAT- und Mission-Editor-Bestandsaufnahme;
3. bekannte Objekte und Namen;
4. offene Widersprüche und fehlende Daten;
5. MOOSE-Prüfplan;
6. vorgeschlagene Phasen und Gates;
7. den ersten zulässigen Arbeitsschritt.

Die direkt kopierbare Startvorlage steht unter:

```text
docs/handoffs/TEMPLATE-airfield-airwing-squadron-commander-chat-handoff.md
```
