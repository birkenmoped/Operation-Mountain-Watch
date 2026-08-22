---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local development order for automatic BLUE operational reactions
  - current implementation status and development-stage tracking for this branch
  - mandatory handoff state for automatic support, resupply and CSAR orchestration
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local planning assumptions from agent/mission-demand-resupply-cas-concept
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: main
base_commit: 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
---

# Entwicklungsauftrag – Automatic Response Orchestration

## 1. Zweck und Arbeitsbranch

Dieser Branch entwickelt die geschlossene automatische BLUE-Reaktionskette aus dem aktuellen `main`-Stand. Bereits vorhandene CampaignState-, MissionDemand-, Ground-, Fire-Support-, AirOps- und CSAR-Bausteine werden orchestriert; akzeptierte Funktionen werden nicht parallel neu implementiert.

```text
branch: agent/automatic-response-orchestration
base: main @ 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
```

Dieses Dokument ist zugleich Entwicklungsauftrag und laufendes Handoff. Es ist nach jedem relevanten Schritt mit Ist-Stand, Dateien, Tests, offenen Grenzen und nächstem zulässigen Gate zu aktualisieren.

## 2. Pflichtprüfung vor jeder Entwicklungsstufe

Vor jeder neuen Stufe und nach längerer Unterbrechung müssen die aktuellen Regeln auf `main` erneut gelesen werden. Branchkopien oder alte Handoffs ersetzen dies nicht.

Mindestens:

```text
AGENTS.md
docs/00-project-governance.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
mission/tests/GOVERNANCE.md
```

Je nach Stufe zusätzlich die aktuellen Fach-, Acceptance- und `docs/moose/`-Dokumente.

MOOSE-First bleibt zwingend:

```text
MOOSE documentation
-> actual pinned Moose.lua
-> signatures / returns / FSM / events / prerequisites
-> official demos/tests where relevant
-> MOOSE configuration/composition/events
-> smallest adapter only if still required
```

Keine MOOSE- oder DCS-Funktion wird geraten.

## 3. Aufgabentrennung / lokale Toolgrenze

### ChatGPT

```text
Repository/Governance prüfen
-> Entwicklung erstellen
-> Diff/Guards/Dokumentation/MOOSE-First prüfen
-> selbst committen und remote veröffentlichen
-> erst danach lokale Schritte übergeben
```

### Projektinhaber

```text
PowerShell-Schritte lokal ausführen
MIZ/Mission Editor gemäß main-Governance bearbeiten
DCS-Läufe ausführen
reale Konsole / Hashes / Logs / Debrief / Beobachtungen zurückgeben
```

Lokale Entwicklungsmaschine:

```text
Lua interpreter: NOT AVAILABLE
Python: NOT AVAILABLE
```

Deshalb:

- lokale Build-/Prüfschritte nur PowerShell;
- Buildanweisungen immer in Codeblöcken;
- keine lokalen `lua`, `luac`, `python`, `python3`-Befehle voraussetzen;
- keine lokalen Builds oder Hashes erfinden;
- kein CODEX.

## 4. Aktuelle Source of Truth

Der Legacy-Branch:

```text
agent/mission-demand-resupply-cas-concept
```

ist historische Referenz בלבד. Aktuelle Autorität ist `main`.

### PR #114 – MissionDemand Foundation

```text
branch: agent/mission-demand-reconciliation
merge commit: 341a65105c24807de3ac289bb18d80339111cbd1
status: MERGED
```

Integriert:

```text
MissionDemand registry/state model
RESUPPLY
CAS_IMMEDIATE
AI/player assignment exclusivity
active dedupe
snapshot/restore
ResourceDemandPolicy
```

### PR #115 – Ground RESUPPLY thresholds

```text
branch: agent/mission-demand-resupply-thresholds
merge commit: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
status: MERGED
```

Verbindlich für transferierbare Ground-Ressourcen:

```text
reorder  = 50% of target
critical = 25% of target
```

### PR #112 – Fixed Fire Support / local ammo rearm

```text
status: MERGED
physical MOOSE/DCS rearm: DCS PASS for documented provenance
same-session restore settlement: PASS
external process/server persistence: NOT TESTED / NOT CLAIMED
```

Der M1083-/ARTY-Rearm-Pfad wird wiederverwendet, nicht neu gebaut.

## 5. Endziele

```text
A. FOB attacked
   -> ARTY / CAS / QRF support demand

B. Fire-support unit depleted
   -> own-site M1083 local rearm

C. Ground stock <= reorder/critical
   -> RESUPPLY demand
   -> physical transport
   -> delivery/loss settlement

D. BLUE resupply convoy attacked
   -> deduplicated support demand

E. CAS helicopter lost with surviving isolated personnel
   -> one CSARIncident
   -> Player CSAR or AICSAR
```

Überall gilt:

```text
CampaignState = strategic truth/resource authority
MissionDemand = demand identity/assignment state
MOOSE = operational execution
DCS groups = temporary physical representation
```

## 6. Entwicklungsstufen und aktueller Stand

### Stage 0 – Governance / Ist-Stand / MOOSE Ground reconciliation

Status: `COMPLETE FOR STAGE-1A SCOPE`

Erledigt:

- [x] aktuelle Pflichtregeln auf `main` erneut geprüft;
- [x] PR #114 / #115 / #112 als heutige Grundlagen bestätigt;
- [x] CampaignState TRANSFER lifecycle geprüft;
- [x] aktuelle Ground Production-Trennung geprüft;
- [x] BRIGADE/PLATOON/ARMYGROUP/AUFTRAG- und Return-Lifecycle aus den Ground-Acceptances geprüft;
- [x] owner-approved `OMW_GroundRoadSpawnAdapter` als bestehende Materialisierungsausnahme bestätigt;
- [x] gepinnte `Moose.lua` für `NewAMMOSUPPLY`, `NewFUELSUPPLY`, Formation, Mission-Lifecycle, Zone-Prüfung und OPSTRANSPORT geprüft;
- [x] `AUFTRAG:NewOPSTRANSPORT(...)` als nicht verfügbare auskommentierte API ausgeschlossen;
- [x] erster kleinster physischer AMMO-Pfad festgelegt;
- [x] keine neue Nicht-MOOSE-Ausnahme erforderlich.

Technisches Review:

```text
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

### Stage 1 – Physical RESUPPLY execution

Status: `IN DEVELOPMENT`

#### Stage 1A – Ground AMMO / Joyce -> Honaker

Status: `SOURCE_AND_BUILDER_STAGED / LOCAL BUILD NOT RUN`

Gewählter Pfad:

```text
Honaker AMMO 40
-> test-only CampaignState CONSUMPTION 20
-> Honaker AMMO 20 == reorder
-> ResourceDemandPolicy candidate
-> one MissionDemand RESUPPLY
-> CampaignState TRANSFER 20 Joyce -> Honaker
-> MOOSE BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG AMMOSUPPLY
-> M1083 drives OnRoad toward Honaker ACCESS zone
-> exact MissionExecute + IsInZone(destination) proof
-> MarkDelivered
-> MissionDemand SUCCESS
-> explicit RTZ Joyce ACCESS zone OnRoad
-> Returned -> Warehouse AddAsset -> physical cleanup
```

Erwarteter strategischer Endzustand:

```text
JOYCE AMMO   44 -> 24
HONAKER AMMO 40 -> 20 -> 40
```

Staged files:

```text
mission/tests/ground-resupply-execution/src/01-ground-ammo-resupply-acceptance.lua
mission/tests/ground-resupply-execution/README.md
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
tools/build-ground-ammo-resupply-acceptance-1.ps1
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
```

Builder:

```text
GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-2
```

Wichtige Designentscheidung dieses Slices:

```text
CampaignState owns cargo quantity.
MOOSE AMMOSUPPLY owns physical movement only.
```

`OPSTRANSPORT` wird nicht verwendet, weil der erste AMMO-Slice keine zusätzliche physische CargoGroup benötigt und keine zweite Fracht-/Bestandsautorität entstehen darf.

Delivery ist fail-closed:

```text
MissionDone alone != delivery

Delivery requires:
exact AMMOSUPPLY MissionExecute
AND ARMYGROUP:IsInZone(Honaker ACCESS) == true
```

Readiness wird über die MOOSE-USERFLAGs geprüft:

```text
OMW_WAREHOUSE_READY == 1
OMW_GROUND_READY == 1
```

Noch offen:

- [ ] Owner local PowerShell build;
- [ ] unabhängiger Bundle-SHA-256;
- [ ] anschließend konkrete Arbeits-MIZ bestimmen;
- [ ] Objektvertragssmoke für Joyce/Honaker/M1083;
- [ ] Bundle einbetten und interne Hashkette prüfen;
- [ ] DCS-Lauf;
- [ ] Ergebnisdokumentation;
- [ ] `docs/moose/PROJECT-CLASS-INDEX.md` bei Runtime-Abschluss mit dem exakten AMMOSUPPLY-Scope synchronisieren; die Klassenstatus selbst wurden durch das reine Source-Staging noch nicht angehoben.

#### Stage 1B – Ground FUEL

Status: `PLANNED AFTER STAGE 1A`

MOOSE-Kandidat source-confirmed:

```text
AUFTRAG:NewFUELSUPPLY(Zone)
```

Kein Runtime-Code vor Abschluss/Review von Stage 1A.

#### Stage 1C – Generic Ground SUPPLY

Status: `BLOCKED FOR SEPARATE MOOSE GAP REVIEW`

Keine generische gleichwertige `AUFTRAG:NewSUPPLY(...)`-API wurde für den gepinnten Scope bestätigt. Es wird kein PATROL-/RELOCATE-Ersatz missbraucht. Falls MOOSE keine geeignete Funktion bietet, ist vor eigenem Fallback eine Owner-Entscheidung erforderlich.

### Stage 2 – FOB attack -> support demand

Status: `PLANNED`

- Event-/Incident-Grenze verifizieren;
- Treffer zu einem laufenden TacticalSupportIncident aggregieren;
- kein Request-Sturm;
- ARTY/QRF/CAS capability/readiness/range/resources/ROE bewerten.

### Stage 3 – Fire support -> local rearm -> RESUPPLY follow-up

Status: `PLANNED / FOUNDATIONS AVAILABLE`

- PR-#112-Rearm wiederverwenden;
- Verbrauch CampaignState-seitig abrechnen;
- nach Verbrauch ResourceDemandPolicy evaluieren;
- genau einen RESUPPLY-Demand erzeugen.

### Stage 4 – Convoy under attack -> support demand

Status: `PLANNED`

- physischer Convoy-Lifecycle als Eventquelle;
- deduplizierter Supportincident;
- Transport-Demand und Support-Demand bleiben getrennte Identitäten.

### Stage 5 – BLUE assignment / CAS execution

Status: `BLOCKED BY BLUE COMMANDER RECONCILIATION`

- aktuelles `COMMANDER/AIRWING/SQUADRON/AUFTRAG` erneut source-reviewen;
- alten BLUE-COMMANDER-Branch nur selektiv reconciliieren;
- `CAS_IMMEDIATE` erst danach produktiv dispatchen.

### Stage 6 – Aircraft loss -> CSARIncident -> Player/AICSAR

Status: `PLANNED`

- endgültiges CSARIncident-Modell/FSM;
- Loss/Ejection/Survival-Ereignisse verifizieren;
- genau ein Incident;
- Player/AICSAR exklusiv;
- Rescue/Capture/Death/Expired/Recovery persistent abrechnen.

### Stage 7 – End-to-End chain

Status: `PLANNED`

```text
FOB attacked
-> support demand
-> artillery
-> fire
-> local ammo rearm
-> stock threshold crossed
-> RESUPPLY demand
-> physical convoy
-> convoy attacked
-> support demand
-> response
-> delivery/loss settlement
```

plus:

```text
CAS helicopter lost
-> one CSARIncident
-> Player CSAR or AICSAR
-> final settlement
```

### Stage 8 – Restore / restart / idempotence

Status: `PLANNED`

Keine doppelten Demands, Reservierungen, Abbuchungen, Gutschriften oder grundlosen Verluste. Externer Prozess-/Serverrestart wird nur nach realem Test behauptet.

### Stage 9 – Multiplayer / performance / failures

Status: `PLANNED`

Parallele Demands, Assignment-Races, zerstörte Carrier/Responder, Routingfehler, Abbruch, Reconnect und Schedulerlast.

### Stage 10 – Production reconciliation / merge readiness

Status: `PLANNED`

Diff, Tests, MOOSE-Doku, Acceptance-Provenienz, Register, keine `PENDING_MERGE`-Werte auf `main`, keine Aussagen über getesteten Scope hinaus.

## 7. Aktueller technischer Gate-Stand

```text
branch:
agent/automatic-response-orchestration

implementation head before this handoff refresh:
f9f2a82a221c82c0f8a5d096d1247f4ba4dba886

stage:
STAGE_1A_GROUND_AMMO_RESUPPLY

MOOSE-first source review:
COMPLETE FOR STAGE-1A TEST SCOPE

acceptance source:
STAGED

builder:
STAGED / GROUND-AMMO-RESUPPLY-ACCEPTANCE-1-2

local owner build:
NOT RUN

bundle SHA-256:
UNKNOWN

MIZ mutation:
NOT STARTED

DCS runtime:
NOT RUN

production runtime implementation:
NOT YET CREATED
```

## 8. Nächster zulässiger Schritt

Der aktuelle Gate ist kein MIZ- oder DCS-Gate. Zuerst muss der Projektinhaber den versionierten Acceptance-Builder lokal mit PowerShell ausführen und den unabhängig berechneten SHA-256 zurückgeben.

Erst danach:

```text
build/hash PASS
-> select current work MIZ
-> object-contract smoke
-> owner MIZ embedding
-> embedded bundle/Moose/MIZ hashes
-> DCS acceptance
-> evaluate result
-> only then production adapter decision
```

Kein DCS-PASS und keine Produktionsreife werden vorweggenommen.
