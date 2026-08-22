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

## 1. Zweck

Dieser Branch entwickelt die durchgängige automatische BLUE-Reaktionskette ausgehend vom aktuellen `main`-Stand. Ziel ist nicht die Neuerfindung bereits vorhandener Einzelbausteine, sondern ihre belastbare Orchestrierung über CampaignState, MissionDemand und MOOSE.

Arbeitsbranch:

```text
agent/automatic-response-orchestration
```

Aktuelle Branch-Basis nach Reconciliation von PR #114 und PR #115:

```text
main
28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c
```

Dieser Entwicklungsauftrag ist zugleich die laufende Übergabedokumentation. Nach jeder fachlich oder technisch relevanten Änderung müssen mindestens aktueller Branch-/Commit-Stand, erledigte Entwicklungsstufe, offene Punkte, betroffene Dateien, Teststatus, offene Owner-Entscheidungen und nächster zulässiger Schritt aktualisiert werden. Eine Übergabe darf sich nicht auf Chatverlauf oder Erinnerung verlassen.

## 2. Pflichtprüfung vor jeder Entwicklungsstufe

Vor Beginn jeder neuen Entwicklungsstufe oder nach einer längeren Unterbrechung müssen die aktuellen Regeln auf `main` erneut gelesen und gegen diesen Branch geprüft werden. Branchlokale Kopien, ältere Handoffs oder historische Teststände ersetzen diese Prüfung nicht.

Mindestens zu lesen:

```text
AGENTS.md
docs/00-project-governance.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
mission/tests/GOVERNANCE.md
```

Je nach Entwicklungsstufe zusätzlich die aktuellen zuständigen Fach-, Manifest-, Acceptance- und `docs/moose/`-Dokumente.

MOOSE-First ist zwingend. Vor eigener Runtime-Lua müssen passende MOOSE-Dokumentation, die tatsächlich verwendete `Moose.lua`, Signaturen, Rückgaben, FSMs, Events, Voraussetzungen und offizielle MOOSE-Demos/Tests geprüft werden. Keine MOOSE-Klasse, Methode, Event-Semantik oder DCS-Laufzeitwirkung darf geraten werden.

## 3. Verbindliche Aufgabentrennung und lokale Umgebung

### ChatGPT

- prüft vor jeder Entwicklungsstufe die maßgeblichen aktuellen `main`-Regeln;
- untersucht Repository, MOOSE-Dokumentation, tatsächlich verwendete `Moose.lua` und relevante historische Branches nur als Evidenz;
- erstellt Source-, Test-, Builder- und Dokumentationsänderungen;
- prüft Diff, Syntax, statische Guards und verfügbare Tests;
- aktualisiert diesen Entwicklungsauftrag nach jedem relevanten Schritt;
- committed und veröffentlicht Änderungen selbst auf dem Remote-Branch;
- gibt erst danach die lokal erforderlichen Schritte an den Projektinhaber aus;
- erfindet keine lokalen Builds, Hashes, MIZ-Änderungen oder DCS-Ergebnisse.

### Projektinhaber / lokale Entwicklungs- und DCS-Maschine

- führt die übergebenen PowerShell-Schritte aus;
- bearbeitet `.miz`-Dateien und Mission-Editor-Inhalte selbst, soweit die aktuelle `main`-Governance und zuständige ME-Arbeitsliste dies vorsehen;
- führt DCS-Runtime-Tests aus;
- liefert reale Konsolenausgabe, reale Hashes, DCS-Logs, Debriefs und Beobachtungen zurück.

### Lokale Toolgrenze

Auf der lokalen Entwicklungsmaschine stehen für diesen Workflow ausdrücklich kein Lua-Interpreter und kein Python zur Verfügung. Lokale Prüf- oder Buildanweisungen dürfen daher nicht `lua`, `luac`, `python` oder `python3` voraussetzen.

Lokale Build- und Prüfaufträge müssen PowerShell-basiert sein und immer in Code-Feldern übergeben werden.

Nach einem Remote-Commit erhält der Projektinhaber ausschließlich die nummerierten lokal erforderlichen PowerShell-Schritte für `git pull`, Build, Hash-Prüfung und gegebenenfalls ausdrücklich freigegebene MIZ-/DCS-Verifikation. Nur reale lokale Ausgabe und reale Hashes dürfen Grundlage des nächsten Schritts sein.

Kein CODEX-Einsatz und keine CODEX-CLI-Übergabe.

## 4. Aktuelle Source-of-Truth nach Legacy-Reconciliation

Der alte Branch

```text
agent/mission-demand-resupply-cas-concept
```

ist heute nur noch historische Referenz. Er wurde nicht als Ganzes ersetzt oder gemergt, sondern fachlich zerlegt und selektiv in `main` überführt.

Aktuelle Autorität:

```text
CURRENT SOURCE OF TRUTH: main
```

### 4.1 MissionDemand Domain Foundation

PR #114 wurde nach `main` gemergt:

```text
PR: 114
branch: agent/mission-demand-reconciliation
merge commit: 341a65105c24807de3ac289bb18d80339111cbd1
```

Damit sind auf `main` integriert:

```text
MissionDemand registry/state model
RESUPPLY demand type
CAS_IMMEDIATE demand type
assignment exclusivity
active-demand deduplication
snapshot/restore
ResourceDemandPolicy
contract tests / validation workflow
```

MissionDemand bleibt Campaign-Domain-Logik und besitzt keine eigenständige MOOSE-/DCS-Ausführungshoheit.

### 4.2 Ground RESUPPLY thresholds

PR #115 wurde nach `main` gemergt:

```text
PR: 115
branch: agent/mission-demand-resupply-thresholds
merge commit: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
```

Verbindliche Ground-Threshold-Entscheidung:

```text
reorder  = 50% of target
critical = 25% of target
```

Geltungsbereich:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

Nicht automatisch über diese Policy disponiert:

```text
PERSONNEL
VEHICLE
Loss-Audit resources
```

Damit ist die automatische Bedarfserkennung fachlich vorbereitet. Noch nicht vorhanden ist die produktive physische Transportausführung.

### 4.3 Ground ammo rearm / Fixed Fire Support

Der frühere Legacy-Anteil wird nicht wiederverwendet. Maßgeblich ist der separate, inzwischen bessere Ground-Rearm-Stand auf `main` aus PR #112.

Verbindliche Grenze:

```text
physical MOOSE/DCS rearm: accepted for documented provenance
CampaignState settlement: accepted for documented same-session scope
external filesystem/server persistence restart: not tested / not claimed
```

Der vorhandene MOOSE-ARTY-/M1083-Rearm-Pfad wird in diesem Branch nur angebunden und nicht parallel neu implementiert.

### 4.4 CampaignState

CampaignState bleibt die einzige strategische Ressourcenautorität. MissionDemand, MOOSE Warehouse, DCS Warehouse, CTLD, Ground Runtime und Transportadapter dürfen keinen zweiten strategischen Ressourcenledger erzeugen.

### 4.5 CAS / BLUE COMMANDER

`CAS_IMMEDIATE` existiert als Demand-Typ auf `main`, aber die produktive CAS-Runtime existiert noch nicht. Die physische CAS-Zuweisung hängt weiterhin von der separaten BLUE-COMMANDER-Reconciliation und der aktuellen MOOSE-Prüfung für `COMMANDER`, `AIRWING`, `SQUADRON` und `AUFTRAG` ab.

Der ältere Branch `agent/blue-commander-foundation` ist keine aktuelle Produktionsautorität und darf nur selektiv gegen heutigen `main` reconciliiert werden.

### 4.6 CSAR

Die CSAR-Fach- und Quellenarbeit ist umfangreich vorhanden. Produktiv fehlen weiterhin insbesondere endgültiges `CSARIncident`-Datenmodell/FSM, MOOSE-CSAR/AICSAR-Testharness, Player-/AI-Acceptance sowie Dedicated-Server-, Multiplayer-, Persistenz- und Restart-Prüfungen.

## 5. Zielbild

Die Entwicklung soll folgende geschlossene Reaktionskette ermöglichen:

```text
FOB / Convoy / Aircraft event
        |
        v
CampaignState authoritative state change
        |
        v
MissionDemand or CSARIncident
        |
        v
capability / readiness / range / stock / reservation / ROE evaluation
        |
        v
player assignment OR MOOSE AI assignment
        |
        v
physical execution in DCS
        |
        v
result / loss / consumption / return settlement
        |
        v
follow-up demand when required
```

## 6. Endziele

### Ziel A – FOB unter Angriff fordert Unterstützung

Ein real angegriffener BLUE-FOB erzeugt bei erfüllten taktischen Kriterien genau einen laufenden Support-Bedarf. Abhängig von Lage, Fähigkeit und Verfügbarkeit können geeignete Unterstützungsarten sein:

```text
ARTILLERY / MORTAR FIRE SUPPORT
CAS
QRF
```

Keine Doppelbeauftragung desselben Bedarfs durch Spieler und KI. Keine Unterstützung ohne nachvollziehbaren Bedarf, Ressourcenverfügbarkeit und zulässige Ziel-/ROE-Prüfung.

### Ziel B – Artillerie fordert lokalen Ammo-Rearm

Eine Fire-Support-Einheit fordert bei definiertem Munitionszustand einen geeigneten Munitions-LKW des eigenen Standorts an. Der bereits akzeptierte MOOSE-/DCS-Rearm-Pfad wird wiederverwendet.

### Ziel C – Warehouse unterschreitet Mindestbestand und erzeugt Nachschubbedarf

Durch autorisierten Verbrauch sinkt ein lokaler CampaignState-Bestand. Auf Basis der bereits integrierten `reorder`-/`critical`-Schwellen entsteht genau ein deduplizierter `RESUPPLY`-MissionDemand. Danach folgen Ursprungsauswahl, Reservierung, physischer Transport und Delivery/Loss-Settlement.

### Ziel D – angegriffener BLUE-Nachschubkonvoi fordert Unterstützung

Ein real angegriffener oder nach definierten Kriterien ernsthaft bedrohter BLUE-Konvoi erzeugt einen deduplizierten Support-Bedarf. Unterstützungsoptionen werden erst nach aktueller MOOSE-First- und CampaignState-Prüfung festgelegt.

### Ziel E – verlorener CAS-Helikopter erzeugt CSAR

Wenn ein unterstützendes Luftfahrzeug verloren geht und isoliertes Personal gemäß DCS/MOOSE-Ereignislage entsteht, wird genau ein autoritatives `CSARIncident` erzeugt. Spieler-CSAR und `AICSAR` dürfen denselben Incident nicht doppelt übernehmen oder abschließen.

## 7. Entwicklungsstufen bis zum Ziel

### Stufe 0 – Governance- und Ist-Stand-Gate

Status: `PARTIALLY COMPLETE`

Erledigt:

- [x] aktueller `main` nach PR #114 und PR #115 als Branch-Basis übernommen;
- [x] Legacy-Branch `agent/mission-demand-resupply-cas-concept` als historische Referenz klassifiziert;
- [x] MissionDemand-Domainfoundation auf `main` bestätigt;
- [x] `RESUPPLY` / `CAS_IMMEDIATE` Demand-Typen auf `main` bestätigt;
- [x] ResourceDemandPolicy auf `main` bestätigt;
- [x] Ground-Threshold-Entscheidung 50%/25% auf `main` bestätigt;
- [x] separaten Ground-Rearm-Stand PR #112 als maßgebliche Fire-Support-Rearm-Basis bestätigt.

Noch offen vor neuer Runtime-Implementierung:

- [ ] aktuelle `main`-MOOSE-Dokumentation für den ersten physischen RESUPPLY-Vertical-Slice lesen;
- [ ] tatsächlich verwendete `Moose.lua` für die benötigten Warehouse-/Ground-/Transport-/OPS-Verträge prüfen;
- [ ] aktuelle Ground-Convoy-/BRIGADE-/PLATOON-/ARMYGROUP-/OPSTRANSPORT-Produktionspfade erfassen;
- [ ] kleinsten zulässigen Adapter zwischen `RESUPPLY` MissionDemand und bestehender physischer Ground-Ausführung definieren;
- [ ] erforderliche Owner-Entscheidungen oder MOOSE-Ausnahmen ausdrücklich dokumentieren.

Exit-Kriterium:

```text
physical RESUPPLY implementation contract documented
no stale Legacy runtime copied
no unverified MOOSE API assumed
```

### Stufe 1 – Physical RESUPPLY execution

Status: `NEXT DEVELOPMENT STEP`

Zielkette:

```text
ResourceDemandPolicy candidate
-> MissionDemand.Create(RESUPPLY)
-> select approved origin / supplyParent
-> CampaignState ReserveResource(TRANSFER)
-> bind transactionId to MissionDemand
-> physical MOOSE transport execution
-> MarkLoading
-> MarkInTransit
-> delivery or loss
-> MarkDelivered / MarkLost / Cancel
-> MissionDemand SUCCESS / FAILED / EXPIRED
```

Zu erledigen:

- [ ] vorhandenen MOOSE-first Ground-/Convoy-Pfad identifizieren und wiederverwenden;
- [ ] keine parallele strategische Cargo-/Ressourcenhoheit einführen;
- [ ] MissionDemand und CampaignState transaction genau einmal verknüpfen;
- [ ] Dedupe für `RESUPPLY|destination|resource` erhalten;
- [ ] Herkunft, Ziel, Menge und Transportidentität stabil protokollieren;
- [ ] Verlust-, Abbruch- und Rückkehrpfade gegen vorhandenes Ground-Settlement führen;
- [ ] Build-/Testbundle nach Dokument 22 erzeugen;
- [ ] MIZ-Arbeit nur durch Projektinhaber nach expliziter Übergabe;
- [ ] DCS-Acceptance mit realer Hashkette.

Exit-Kriterium:

```text
stock shortage
-> one RESUPPLY demand
-> one physical transport
-> one authoritative settlement
```

### Stufe 2 – FOB attack -> Support Demand

Status: `PLANNED`

Zu erledigen:

- [ ] belastbare Eventquelle für Angriff/Kontakt gegen aktuelle MOOSE-/DCS-Verträge bestimmen;
- [ ] TacticalSupportIncident oder gleichwertige deduplizierte Incident-Grenze definieren;
- [ ] wiederholte Treffer dürfen keinen Request-Sturm erzeugen;
- [ ] Supporttypen anhand Fähigkeit, Reichweite, Readiness, Ressourcen und ROE bewerten;
- [ ] Artillery/QRF/CAS Demand-Generierung von physischer Ausführung trennen;
- [ ] keine globale Frame-/World-Object-Scan-Schleife.

### Stufe 3 – Fire Support -> lokaler Ammo-Rearm -> Resupply-Folgebedarf

Status: `PLANNED / FOUNDATION AVAILABLE`

Zu erledigen:

- [ ] bestehenden PR-#112-Rearm-Pfad an Fire-Support-Verbrauch anbinden;
- [ ] keine neue ARTY-Rearm-Implementierung;
- [ ] Verbrauch in CampaignState korrekt abrechnen;
- [ ] nach Verbrauch Ground-Threshold-Policy erneut bewerten;
- [ ] bei Schwellenunterschreitung genau einen `RESUPPLY`-Demand erzeugen.

### Stufe 4 – Convoy under attack -> Support Demand

Status: `PLANNED`

Zu erledigen:

- [ ] aktuellen physischen Convoy-Lifecycle als Eventquelle verwenden;
- [ ] Attack-/Threat-Kriterien definieren;
- [ ] Support-Demand deduplizieren;
- [ ] CAS / Fire Support / QRF nur nach bestätigter Capability-/Assignment-Architektur;
- [ ] Transportmission und Supportmission bleiben getrennte MissionDemand-Identitäten.

### Stufe 5 – BLUE assignment / response orchestration

Status: `BLOCKED BY BLUE COMMANDER RECONCILIATION FOR CAS`

Zu erledigen:

- [ ] aktuelle MOOSE-Verträge `COMMANDER`, `AIRWING`, `SQUADRON`, `AUFTRAG` gegen die tatsächlich verwendete `Moose.lua` prüfen;
- [ ] historischen `agent/blue-commander-foundation` selektiv reconciliieren, nicht übernehmen;
- [ ] MissionDemand-Zuweisung für Spieler und AI exklusiv halten;
- [ ] Capability, Readiness, Reichweite, Payload, Bestand und laufende Missionen berücksichtigen;
- [ ] CAS_IMMEDIATE erst nach dieser Reconciliation produktiv dispatchen.

### Stufe 6 – Aircraft loss -> CSARIncident -> Player/AICSAR

Status: `PLANNED`

Zu erledigen:

- [ ] endgültiges `CSARIncident`-Datenmodell/FSM;
- [ ] Ereignisquelle für Loss/Ejection/Survival gegen MOOSE/DCS verifizieren;
- [ ] genau einen Incident je Recovery-Fall;
- [ ] Player-Reservierung und AICSAR-Übernahme synchronisieren;
- [ ] Rescue / Capture / Death / Expired / Recovery persistent abrechnen;
- [ ] Dedicated-Server-/MP-/Reconnect-Grenzen separat testen.

### Stufe 7 – Geschlossene End-to-End-Kette

Status: `PLANNED`

Pflichtszenario:

```text
FOB attacked
-> support MissionDemand
-> artillery assigned
-> fire mission
-> ammo consumed
-> local M1083 rearm
-> local stock below threshold
-> RESUPPLY MissionDemand
-> physical convoy/transport
-> convoy attacked
-> support MissionDemand
-> response
-> arrival/loss
-> CampaignState settlement
```

Zusätzlich:

```text
CAS helicopter lost
-> surviving crew/ejection
-> one CSARIncident
-> Player CSAR or AICSAR
-> final settlement
```

### Stufe 8 – Restore / Restart / Idempotenz

Status: `PLANNED`

Zu prüfen:

- [ ] MissionDemand snapshot/restore ohne Doppelauftrag;
- [ ] Resource reservations ohne Doppelabbuchung oder Doppelgutschrift;
- [ ] in-flight Convoy-Zustände nach Restart gemäß verbindlicher Ground-Reconciliation;
- [ ] SupportIncident-/CSARIncident-Dedupe nach Restore;
- [ ] keine grundlosen Einheitenverluste;
- [ ] realer externer Prozess-/Serverrestart nur behaupten, wenn tatsächlich getestet.

### Stufe 9 – Multiplayer / Performance / Failure Acceptance

Status: `PLANNED`

Zu prüfen:

- [ ] gleichzeitige Ereignisse an mehreren FOBs;
- [ ] mehrere parallele RESUPPLY-Demands;
- [ ] Player-vs-AI Assignment-Races;
- [ ] zerstörter Responder;
- [ ] Pathfinding-/Routing-Ausfall;
- [ ] Transportabbruch;
- [ ] CAS/CSAR-Reconnect;
- [ ] Scheduler-/Performance-Verhalten;
- [ ] keine unnötigen High-Frequency-Scans.

### Stufe 10 – Production reconciliation / merge readiness

Status: `PLANNED`

Abschluss:

- [ ] vollständiger Diff-Review;
- [ ] relevante Tests und statische Guards;
- [ ] Dokumentation aktuell;
- [ ] `docs/moose/PROJECT-CLASS-INDEX.md` aktuell;
- [ ] `docs/moose/VERIFIED-METHODS.md` nur mit real bestätigten Methoden;
- [ ] Acceptance-Provenienz vollständig;
- [ ] `SUBPROJECT-REGISTRY` und gegebenenfalls `DOCUMENT-REGISTRY` synchron;
- [ ] keine `PENDING_MERGE`-Metadaten auf `main`;
- [ ] keine DCS-Aussage über den tatsächlich getesteten Scope hinaus.

## 8. Aktueller Entwicklungsstatus

```text
branch:
agent/automatic-response-orchestration

base:
main @ 28d0069d5d9ec66e62f1e81ad59fc3dd4e2e249c

legacy mission-demand branch:
HISTORICAL REFERENCE ONLY

PR #114 MissionDemand foundation:
MERGED TO MAIN

PR #115 Ground resupply thresholds:
MERGED TO MAIN

PR #112 Ground ammo rearm:
MERGED TO MAIN / documented DCS acceptance

current stage:
STAGE_0_GOVERNANCE_AND_CURRENT_MOOSE_GROUND_EXECUTION_REVIEW

next implementation stage:
STAGE_1_PHYSICAL_RESUPPLY_EXECUTION

runtime code changed on this branch:
false

miz change required now:
false

local build required now:
false

dcs test required now:
false
```

## 9. Nächster zulässiger Schritt

Vor der ersten Runtime-Änderung ist ausschließlich die Stage-0-MOOSE-/Ground-Ausführungsreconciliation zulässig:

```text
current main rules
-> current MissionDemand / ResourceDemandPolicy
-> current Ground production runtime
-> current Moose.lua
-> suitable MOOSE physical transport contract
-> smallest adapter design
-> documented acceptance plan
```

Erst danach beginnt die Implementierung von Physical RESUPPLY execution.
