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
- different specifications under the same id are rejected;
- player and AI assignment are mutually exclusive by state transition;
- reassignment to a different assignee without an explicit later retasking contract is rejected;
- terminal demands release their active dedupe key;
- MOOSE/DCS references are not stored;
- arbitrary nested demand metadata is copied defensively;
- snapshot restore rebuilds active dedupe state and rejects duplicate active keys.
```

Dieser Stand ist Source-Review, kein DCS-PASS.

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

## 6. Zulässige Lösungsrichtungen für die Transferlücke

Noch keine der folgenden Richtungen wird in diesem Dokument stillschweigend als verbindliche Eigentümerentscheidung festgelegt.

### A – CampaignState Transfer unterstützt getrennte Resource IDs

Abwärtskompatible Erweiterung, beispielsweise logisch:

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
- node-spezifische Ground-IDs müssen nicht umbenannt werden.
```

Zu prüfen:

```text
- Snapshot-Kompatibilität;
- bestehende Transfer-Nutzer;
- transaction identity/equality;
- Restore/Reconciliation;
- Dokument 04/05-Vertrag.
```

### B – Verbrauch am Ursprung + idempotente Gutschrift am Ziel

```text
origin CONSUMPTION
+
destination CreditResourceOnce
```

Vorteil: keine Änderung des generischen Transfer-Schemas.

Nachteil: Transportzustand, Verlust und Transferidentität würden über einen zusätzlichen OMW-Vertrag gekoppelt und damit Teile des bereits vorhandenen TRANSFER-Modells parallel abbilden.

Aus MOOSE-/Architektursicht ist Richtung A deshalb derzeit der sauberere Prüfpfad, aber eine Änderung des CampaignState-Kernvertrags wird erst nach vollständigem Impact-Review umgesetzt.

## 7. BLUE COMMANDER Dependency

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

## 8. Nächste Gates

```text
GATE 1
MissionDemand Registry source review + executable contract test

GATE 2
ResourceDemandPolicy contract test with thresholds disabled and synthetic calibrated rows

GATE 3
CampaignState cross-node resource-ID transfer decision and compatibility review

GATE 4
ROAD_CONVOY MOOSE execution decision

GATE 5
BLUE COMMANDER reconciliation

GATE 6
MOOSE Hit -> TacticalSupportIncident -> CAS request

GATE 7
CAS AUFTRAG dispatch and DCS acceptance
```

## 9. Aktuelle Validierungsgrenze

Zum Zeitpunkt dieses Dokuments wurde kein neuer DCS-Test ausgeführt.

Die neuen Domain-Module enthalten keine DCS- oder MOOSE-Aufrufe. Ein DCS-Test ist für die reine Domainlogik nicht erforderlich, bevor die physische Execution-Schicht angeschlossen wird. Syntax- und ausführbare Contract-Tests bleiben dennoch erforderlich, bevor dieser Branch als fertig bewertet wird.
