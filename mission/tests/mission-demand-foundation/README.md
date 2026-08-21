---
document_id: OMW-TEST-MISSION-DEMAND-FOUNDATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current implementation and verification status of the MissionDemand domain foundation
  - current open blockers for automatic Ground resupply and Immediate CAS integration
not_authoritative_for:
  - DCS runtime acceptance
  - final Ground resupply threshold values
  - final ROAD_CONVOY routing implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-resupply-cas-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MissionDemand Foundation – Arbeits- und Prüfstand

## 1. Ziel

Der Branch `agent/mission-demand-resupply-cas-concept` baut die kleinste gemeinsame Domänenschicht für zwei erste dynamische Reaktionsketten:

```text
RESOURCE SHORTAGE -> RESUPPLY
TROOPS IN CONTACT -> CAS_IMMEDIATE
```

Die Domänenschicht entscheidet nicht über MOOSE-Ausführungsdetails und besitzt keine strategischen Ressourcen. CampaignState bleibt Ressourcenautorität; MOOSE bleibt Ausführungsframework.

## 2. Phase 0 – MOOSE/API Reconciliation

Dokumentiert in:

```text
docs/90-mission-demand-resupply-and-cas-orchestration-concept.md
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
```

Ergebnis:

```text
CampaignState transfer/transaction foundation          EXISTING
Ground target/reorder/critical metadata                EXISTING
Ground supplyParent metadata                           EXISTING
MOOSE BRIGADE/PLATOON/ARMYGROUP lifecycle             EXISTING / documented scope validated
MOOSE OPSTRANSPORT                                     SOURCE_REVIEWED
MOOSE AMMOSUPPLY/FUELSUPPLY                            SOURCE_REVIEWED
MOOSE AMMOTRUCK                                        SOURCE_REVIEWED / official demo located
MOOSE ARTY rearm lifecycle                             SOURCE_REVIEWED
MOOSE EVENTS.Hit                                       SOURCE_REVIEWED
MOOSE CAS AUFTRAG / COMMANDER dispatch                 SOURCE_REVIEWED
central BLUE COMMANDER                                 separate existing branch dependency
exact Production PATHLINE convoy routing               OPEN
```

Kein neuer Nicht-MOOSE-Routing-, Ammo-Monitor- oder Rearm-Controller-Pfad wurde freigegeben.

## 3. Phase 1 – MissionDemand Registry

Produktionsnaher Domain-Source:

```text
scripts/campaign/OMW_MissionDemand.lua
```

Aktueller Vertrag:

```text
Types:
  RESUPPLY
  CAS_IMMEDIATE

States:
  OPEN
  PLAYER_ASSIGNED
  AI_ASSIGNED
  ACTIVE
  SUCCESS
  FAILED
  EXPIRED
```

Funktionen:

```text
New
Restore
Create
Get
GetActiveByDedupeKey
AssignPlayer
AssignAI
Activate
Succeed
Fail
Expire
SetReservationState
SetPriority
ListActive
ExportSnapshot
```

Guards:

```text
- exactly one active demand per dedupeKey;
- duplicate id is idempotent only for an identical creation specification;
- every creation field, including nil-valued optional fields, participates in idempotency comparison;
- different specifications under the same id are rejected;
- player and AI assignment are mutually exclusive by state transition;
- reassignment to a different assignee without an explicit later retasking contract is rejected;
- terminal demands release their active dedupe key;
- MOOSE/DCS references are not stored;
- arbitrary nested demand metadata is copied defensively;
- snapshot restore rebuilds active dedupe state and rejects duplicate active keys.
```

Contract-Test-Source:

```text
tests/mission-demand/test_mission_demand.lua
```

Der Test deckt Create/Idempotenz, Deduplizierung, nil-Feld-Regressionsschutz, AI-vs-Player-Zuweisung, Aktivierung, Erfolg, Dedupe-Freigabe und Snapshot-Restore ab.

Der Test ist im Repository vorhanden, wurde auf der ChatGPT-Ausführungsumgebung aber noch nicht mit einem Lua-5.1-kompatiblen Interpreter ausgeführt. Das ist kein DCS-PASS.

## 4. Phase 2 – Resource Demand Policy

Source:

```text
scripts/campaign/OMW_ResourceDemandPolicy.lua
```

Die Policy verwendet ausschließlich die bereits vorhandenen Ground-Felder:

```text
target
reorder
critical
supplyParent
```

Semantik des aktuellen Codes:

```text
reorder == 0
-> automatic resupply disabled for that row

available <= critical, critical > 0
-> CRITICAL candidate

available <= reorder
-> REORDER candidate

requestedQuantity
= target - available
```

Die Policy erzeugt nur einen Resupply-Kandidaten. Sie:

```text
- reserviert keine Ressource;
- verändert CampaignState nicht;
- erzeugt keine MOOSE-Mission;
- legt keine neuen Threshold-Werte fest.
```

Damit bleibt der derzeitige Foundation-Stand mit `reorder=0` und `critical=0` inert, bis konkrete Werte ausdrücklich festgelegt werden.

Contract-Test-Source:

```text
tests/mission-demand/test_resource_demand_policy.lua
```

Der Test deckt disabled thresholds, REORDER, CRITICAL, Auffüllmenge bis `target`, Unit-Mismatch, doppelte Policy-Zeilen und ungültige Threshold-Reihenfolge ab.

Gemeinsamer Test-Runner:

```text
tests/mission-demand/run.lua
```

Auch dieser Teststand ist noch nicht lokal mit einem Lua-Interpreter ausgeführt.

## 5. Owner-Entscheidung 2026-08-21 – Ground Ammo als strategisches Rearm-Paket

Der Projektinhaber hat für Ground-Munition die Paketvariante bestätigt.

Verbindliche Arbeitssemantik für diesen Branch:

```text
CampaignState Ground ammo
= standardisiertes strategisches Nachschub-/Rearm-Paket
!= einzelne DCS-Granate
!= Truck-Inventar einzelner DCS-Waffen
```

Begründung:

```text
- ein realer Nachschubkonvoi wird nicht für einzelne Restgranaten ausgelöst;
- DCS Ground Rearm führt keinen nachgewiesenen stückweisen Truck-Ledger;
- MOOSE besitzt operative Rearm-Lifecycles, aber keinen strategischen OMW-Bestand;
- CampaignState bleibt alleinige strategische Mengenautorität.
```

DCS-/MOOSE-Munitionswerte dürfen für Bedarfserkennung und Rearm-Bestätigung verwendet werden, aber nicht als zweite strategische Ressourcendatenbank.

Die bestehende Ground-Baseline definiert bereits:

```text
1 AMMO_UNIT = one normalized Ground ammunition package
```

Diese Grundidee bleibt erhalten. Die konkrete spätere Unterteilung nach Empfängerklasse, z. B. Artillerie-/Mörser-/AT-/Small-Arms-Pakete, wird erst festgelegt, wenn sie für die reale OMW-ORBAT erforderlich ist. Es werden keine Kategorien ohne konkreten Bedarf erfunden.

## 6. Transferlücke neu bewertet – Ursache ist die Resource-ID-Namensgebung

Der generische CampaignState-`TRANSFER` verwendet absichtlich dieselbe `resourceId` am Ursprung und Ziel:

```text
originNodeId + resourceId
-> transfer
-> destinationNodeId + resourceId
```

Der aktuelle Ground-Stock erzeugt dagegen node-spezifische IDs, z. B.:

```text
GROUND:GROUND_NODE_JOYCE:AMMO
GROUND:GROUND_NODE_HONAKER:AMMO
```

Damit liegt der Ort zweimal in den Daten:

```text
nodeId     = WO liegt die Ressource?
resourceId = enthält zusätzlich nochmals den Node
```

Für transferierbare Ressourcen ist die sauberere Semantik:

```text
nodeId     = Ort
resourceId = Ressourcentyp / Pakettyp
quantity   = Bestand
```

Beispielrichtung, noch ohne Produktionsmigration:

```text
GROUND_NODE_JOYCE   + GROUND:AMMO
GROUND_NODE_HONAKER + GROUND:AMMO
```

oder bei später ausdrücklich benötigter Unterteilung derselbe gemeinsame Pakettyp auf beiden Nodes.

Damit kann der bestehende CampaignState-Transfervertrag unverändert bleiben.

## 7. Verworfenes Gate – keine originResourceId/destinationResourceId-Erweiterung

Die vorherige Empfehlung, den persistierten CampaignState-Transfervertrag um getrennte

```text
originResourceId
destinationResourceId
```

zu erweitern, wird für diesen Ground-Resupply-Scope nicht weiterverfolgt.

Grund:

```text
Die Resource-ID sollte den Ressourcentyp beschreiben, nicht den Lagerort.
Der Lagerort ist bereits durch originNodeId/destinationNodeId eindeutig bestimmt.
```

Damit ist aktuell keine Änderung am generischen CampaignState-Transaktionsschema erforderlich.

Wichtig: Die bestehende produktive Ground-Foundation auf `main` verwendet weiterhin die bisherigen node-spezifischen IDs. Diese werden nicht stillschweigend geändert. Eine Resource-ID-Normalisierung ist ein eigener, regressionspflichtiger Migrationsschritt und muss Ground-Settlement, Initializer, Snapshots und vorhandene Acceptance-Verträge berücksichtigen.

## 8. MOOSE-First Ground-Rearm – aktuelle Source-Lage

Für die operative Versorgung wurden zusätzlich zum bestehenden AUFTRAG-/BRIGADE-/ARMYGROUP-Pfad geprüft:

```text
AMMOTRUCK
ARTY rearming lifecycle
GROUP/UNIT ammunition telemetry
```

Der offizielle MOOSE-Missionsbestand enthält:

```text
MOOSE_MISSIONS/develop/Functional/AmmoTruck/AmmoTruck 100 - NTTR - Basic
```

Die Demo verwendet `AMMOTRUCK:New(...)`, einen Truck-Set und einen Artillery-Set. Wenn die Artillerie nahe am Munitionsende ist, werden Trucks zur Batterie geschickt und kehren danach zurück.

Für den gepinnten MOOSE-Stand gilt source-seitig:

```text
AMMOTRUCK
- besitzt automatische Low-Ammo-Erkennung;
- besitzt Truck-Dispatch/Arrival/Returning/Home-FSM-Pfade;
- kann ARMYGROUP-Routing verwenden;
- `reloads` bedeutet Rearm-Einsätze, nicht einzelne Granaten.

ARTY
- besitzt eigene Ammo-/Shell-Type-Auswertung;
- unterstützt RearmingGroup/RearmingPlace;
- besitzt einen Rearm-Completion-Pfad anhand des realen Empfänger-Munitionsstands.
```

Folge für OMW:

```text
kein eigener Ground-Ammo-Scheduler
kein eigener Ammo-Truck-Dispatcher
kein eigener Rearm-Controller
```

Die genaue Wahl zwischen `ARTY`, `AMMOTRUCK` und `BRIGADE/AUFTRAG:NewAMMOSUPPLY()` hängt vom konkreten Empfänger- und Missionsmodell ab und benötigt für den OMW-Produktionspfad einen reproduzierbaren DCS-Test.

## 9. BLUE COMMANDER Dependency

Für CAS wird kein zweiter COMMANDER entwickelt.

Vorhandener separater Branch:

```text
agent/blue-commander-foundation
```

Vorhandener Source dort:

```text
scripts/command/OMW_Blue_Commander.lua
```

Der Branch registriert die produktiven BLUE AIRWINGs an genau einem MOOSE COMMANDER, erzeugt selbst keine AUFTRAG- oder OPSTRANSPORT-Objekte und verändert CampaignState nicht.

Vor CAS-Runtime muss dieser Branch gegen den dann aktuellen `main` reconciled und gemäß seiner eigenen Acceptance-/Merge-Grenze integriert werden.

## 10. Nächste Gates

```text
GATE 1
MissionDemand Registry source + contract tests staged

GATE 2
ResourceDemandPolicy source + contract tests staged

GATE 3
Ground transferable resource-ID normalization impact review
- no CampaignState cross-ID transfer extension
- preserve existing accepted Ground settlement semantics
- define migration/regression scope before production stock change

GATE 4
Ground ammo package taxonomy only where required by actual OMW consumers
- do not invent package classes
- DCS/MOOSE ammo telemetry remains operational evidence only

GATE 5
Select smallest public MOOSE execution path for first Ground ammo-resupply vertical slice
- ARTY / AMMOTRUCK / BRIGADE+AUFTRAG comparison
- no custom ammo monitor/dispatcher

GATE 6
BLUE COMMANDER reconciliation

GATE 7
MOOSE Hit -> TacticalSupportIncident -> CAS request

GATE 8
CAS AUFTRAG dispatch and DCS acceptance
```

## 11. Aktuelle Validierungsgrenze

Zum Zeitpunkt dieses Dokuments wurde kein neuer DCS-Test ausgeführt.

Die neuen Domain-Module enthalten weiterhin keine DCS- oder MOOSE-Aufrufe. Die ergänzte MOOSE-Rearm-Bewertung ist `SOURCE_REVIEWED`, nicht `VALIDATED` für OMW.

Syntax- und ausführbare Contract-Tests bleiben erforderlich, bevor der Branch als fertig bewertet wird. Für die physische Rearm-Ausführung ist ein späterer DCS-Test mit vollständiger Provenienz erforderlich.

Aktueller Teststatus:

```text
MissionDemand contract test source      STAGED / NOT EXECUTED
ResourceDemandPolicy contract test      STAGED / NOT EXECUTED
MOOSE Ground rearm source review        UPDATED / NOT DCS VALIDATED IN OMW
MOOSE/DCS runtime                       NOT STARTED
```
