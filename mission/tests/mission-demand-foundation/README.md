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
MOOSE EVENTS.Hit                                       SOURCE_REVIEWED
MOOSE CAS AUFTRAG / COMMANDER dispatch                 SOURCE_REVIEWED
central BLUE COMMANDER                                 separate existing branch dependency
exact Production PATHLINE convoy routing               OPEN
```

Kein neuer Nicht-MOOSE-Routing- oder Spawnpfad wurde freigegeben.

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

## 5. Neu erkannte CampaignState-Transferlücke

Die Phase-0-Prüfung des generischen `CampaignState` und der tatsächlichen Ground-Initialisierung zeigt eine wichtige Integrationslücke.

Der generische Transfervertrag `ReserveResource()` erwartet derzeit für einen Transfer denselben `resourceId` am Ursprung und Ziel.

Ground-Ressourcen sind dagegen absichtlich node-spezifisch benannt, zum Beispiel:

```text
GROUND:GROUND_NODE_JOYCE:AMMO
GROUND:GROUND_NODE_HONAKER:AMMO
```

Der Initializer legt genau diese unterschiedlichen IDs in den jeweiligen CampaignState-Nodes an.

Folge:

```text
JOYCE AMMO -> HONAKER AMMO
```

kann nicht korrekt durch einen unveränderten generischen `TRANSFER` mit nur einem `resourceId` dargestellt werden.

Das ist kein MOOSE-Problem. Es ist eine CampaignState-Domänenlücke zwischen dem vorhandenen generischen Transfermodell und der aktuellen Ground-ID-Namensgebung.

## 6. Impact Review der Transferlücke

Geprüft wurden mindestens:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
```

Feststellungen:

```text
1. CampaignState TRANSFER nutzt resourceId derzeit gleichzeitig für:
   - origin resource lookup
   - reservation accounting
   - origin debit
   - destination resource lookup
   - destination credit
   - transaction equality
   - snapshot/restore

2. Der Initializer unterstützt bewusst unterschiedliche resourceId pro Node.

3. Ground action commitments verwenden CONSUMPTION und CreditResourceOnce.
   Dieser bestehende Ground-Settlement-Pfad darf durch eine Transfererweiterung nicht verändert werden.

4. Eine abwärtskompatible Transfererweiterung kann den bisherigen resourceId-Pfad als Legacy-Kurzform erhalten.
```

Technisch kleinster kompatibler Entwurf:

```text
legacy input:
  resourceId = X

normalisiert zu:
  originResourceId      = X
  destinationResourceId = X

new cross-node input:
  originResourceId      = A
  destinationResourceId = B
```

Für `CONSUMPTION` bleibt weiterhin ausschließlich die Ursprungsressource relevant.

Snapshot-/Restore-Regel für die vorwärtskompatible Implementierung:

```text
old snapshot without originResourceId/destinationResourceId
-> derive both from existing resourceId

new snapshot
-> persist explicit originResourceId/destinationResourceId
```

Ein Snapshot, der bereits eine laufende Cross-ID-Transfertransaktion enthält, ist nicht für ein Rollback auf alten Code garantiert. Diese Rollback-Grenze muss vor Produktivnutzung dokumentiert werden.

## 7. Zulässige Lösungsrichtungen für die Transferlücke

### A – CampaignState Transfer unterstützt getrennte Resource IDs

Abwärtskompatible Erweiterung:

```text
originResourceId
originNodeId

destinationResourceId
destinationNodeId
```

Vorteil:

```text
- echter TRANSFER-Lifecycle bleibt erhalten;
- origin debit / destination credit / lost / cancel bleiben zusammenhängend;
- node-spezifische Ground-IDs müssen nicht umbenannt werden;
- bestehende CONSUMPTION-/Ground-Settlement-Pfade bleiben unverändert.
```

### B – Verbrauch am Ursprung + idempotente Gutschrift am Ziel

```text
origin CONSUMPTION
+
destination CreditResourceOnce
```

Vorteil: keine Änderung des generischen Transfer-Schemas.

Nachteil: Transportzustand, Verlust und Transferidentität würden über einen zusätzlichen OMW-Vertrag gekoppelt und damit Teile des bereits vorhandenen TRANSFER-Modells parallel abbilden.

### Empfehlung nach Impact Review

```text
PREFERRED: A
```

Begründung:

Richtung A erweitert den vorhandenen CampaignState-Transfervertrag an genau der festgestellten Domänenlücke. Richtung B würde dagegen einen zweiten projektspezifischen Transfer-Lifecycle aus vorhandenen Einzeloperationen zusammensetzen.

Da Richtung A den persistierten CampaignState-Transaktionsvertrag erweitert, bleibt die Umsetzung ein dokumentierter Architektur-/Domain-Gate und wird nicht als bereits akzeptierte Produktionsbaseline bezeichnet.

## 8. BLUE COMMANDER Dependency

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

## 9. Nächste Gates

```text
GATE 1
MissionDemand Registry source + contract tests staged

GATE 2
ResourceDemandPolicy source + contract tests staged

GATE 3
Owner approval for preferred CampaignState cross-node transfer direction A
then implement compatibility-preserving transaction extension + tests

GATE 4
ROAD_CONVOY MOOSE execution decision

GATE 5
BLUE COMMANDER reconciliation

GATE 6
MOOSE Hit -> TacticalSupportIncident -> CAS request

GATE 7
CAS AUFTRAG dispatch and DCS acceptance
```

## 10. Aktuelle Validierungsgrenze

Zum Zeitpunkt dieses Dokuments wurde kein neuer DCS-Test ausgeführt.

Die neuen Domain-Module enthalten keine DCS- oder MOOSE-Aufrufe. Ein DCS-Test ist für die reine Domainlogik nicht erforderlich, bevor die physische Execution-Schicht angeschlossen wird. Syntax- und ausführbare Contract-Tests bleiben dennoch erforderlich, bevor dieser Branch als fertig bewertet wird.

Aktueller Teststatus:

```text
MissionDemand contract test source      STAGED / NOT EXECUTED
ResourceDemandPolicy contract test      STAGED / NOT EXECUTED
MOOSE/DCS runtime                       NOT STARTED
```
