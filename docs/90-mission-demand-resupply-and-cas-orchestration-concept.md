---
document_id: OMW-PLAN-MISSION-DEMAND-RESUPPLY-CAS
status: PLANNED
document_class: IMPLEMENTATION_CONCEPT
owning_policy: OMW-GOV-001
authoritative_for:
  - MissionDemand domain foundation for RESUPPLY and CAS_IMMEDIATE
  - orchestration boundary between CampaignState demand and MOOSE execution
  - implementation sequence for resupply and immediate CAS
  - approved Ground resupply trigger ratios for transferable resources
not_authoritative_for:
  - DCS runtime acceptance
  - BLUE COMMANDER production integration
  - final player tasking UI
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-resupply-thresholds
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 90 – MissionDemand-Orchestrierung für Resupply und Immediate CAS

## 1. Reconciliation-Zweck

Dieses Dokument ersetzt nicht die verbindliche Kampagnenarchitektur aus `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`. Es konkretisiert den ersten gemeinsamen Domain-Layer für zwei Reaktionsketten:

```text
RESOURCE SHORTAGE
-> RESUPPLY MissionDemand
-> CampaignState reservation/transaction
-> MOOSE physical execution
-> CampaignState settlement

TROOPS IN CONTACT
-> tactical support incident
-> CAS_IMMEDIATE MissionDemand
-> Air Support Request / Air Tasking
-> MOOSE AUFTRAG through BLUE COMMANDER
-> result settlement
```

Verbindliche Grundregel:

```text
CampaignState = strategic truth and resource authority
MissionDemand = authoritative demand identity and assignment state
MOOSE         = operational selection and execution
DCS groups    = temporary physical representation
```

## 2. Reconciliation gegen aktuellen `main`

Ausgangsbasis des Reconciliation-Branches:

```text
main commit:
96b11739708c298ff00d8d9964c97f8e444b15bf

legacy source branch:
agent/mission-demand-resupply-cas-concept

final reconciliation source head:
c8d1cad4ce7469f350b6a3d6e10fee955348620c

merged via PR:
114

merge commit:
341a65105c24807de3ac289bb18d80339111cbd1
```

Der Legacy-Branch wurde nicht als Ganzes übernommen. Seit seiner Abzweigung wurden insbesondere Ground-Ressourcen, Ground-Rearm, CampaignState-Integration und MOOSE-Dokumentation auf `main` weiterentwickelt.

Nicht zurückportiert wurden deshalb ältere Branch-Fassungen von:

```text
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/logistics/OMW_GroundInitialStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
tools/build-ground-production-base.ps1
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
```

Die aktuelle `main`-Fassung dieser Bereiche bleibt maßgeblich.

## 3. Bereits vorhandene verbindliche Grundlagen

### CampaignState

Der aktuelle Store besitzt bereits den strategischen Ressourcenvertrag:

```text
GetResource(nodeId, resourceId)
ReserveResource(spec)
MarkLoading(transactionId)
MarkInTransit(transactionId)
MarkDelivered(transactionId)
MarkLost(transactionId)
Cancel(transactionId)
```

MissionDemand führt deshalb keinen zweiten Ressourcenledger.

### Ground transferable resources

Die aktuelle Ground-Baseline verwendet bereits die fungiblen IDs:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

Die Node-Zuordnung bleibt separat in `nodeId`.

### Ground demand metadata

Vorhandene Stock-Felder:

```text
target
reorder
critical
supplyParent
```

Es werden keine parallelen `minimumLevel`-/`preferredLevel`-Felder eingeführt.

### Freigegebene Ground-Resupply-Schwellen

Projektinhaberentscheidung vom 22. August 2026:

```text
reorder  = 50% of target
critical = 25% of target
```

Die Schwellen gelten ausschließlich für die übertragbaren Ground-Ressourcen:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

`PERSONNEL`, `VEHICLE` und reine Loss-Audit-Ressourcen erhalten dadurch keine automatische RESUPPLY-Schwelle.

Die Berechnung erfolgt direkt aus `target`. Es wird keine zusätzliche Rundungsregel eingeführt. Bei den aktuellen Beständen kann daher beispielsweise ein Schwellenwert von `7.5` entstehen; die Policy vergleicht numerisch gegen `available`.

## 4. MissionDemand Domain Registry

Auf `main` integrierter Domain-Layer:

```text
scripts/campaign/OMW_MissionDemand.lua
```

Der Registry-Layer besitzt keine MOOSE- oder DCS-Abhängigkeit.

Typen im ersten Scope:

```text
RESUPPLY
CAS_IMMEDIATE
```

Zustände gemäß verbindlicher Architektur:

```text
OPEN
PLAYER_ASSIGNED
AI_ASSIGNED
ACTIVE
SUCCESS
FAILED
EXPIRED
```

Vertrag:

```text
- stable demand IDs
- active dedupe key
- idempotent Create for identical IDs/specifications
- no simultaneous player and AI assignment
- terminal release of dedupe key
- snapshot/restore without MOOSE/DCS object references
```

Mindestens geführte Felder:

```text
id
missionType
origin
objective
target
priority
playerCapable
aiCapable
reservationState
expiresAt
successCriteria
failureConsequences
resourceReservation
createdReason
dedupeKey
status
assignedTo
```

## 5. ResourceDemandPolicy

Auf `main` integrierter Domain-Layer:

```text
scripts/campaign/OMW_ResourceDemandPolicy.lua
```

Aufgabe:

```text
CampaignState resource snapshot
+
current Ground target/reorder/critical/supplyParent metadata
-> zero or one RESUPPLY candidate per row evaluation
```

Semantik:

```text
reorder <= 0
-> automatic demand disabled

available > reorder
-> no demand

available <= reorder
-> REORDER candidate

critical > 0 and available <= critical
-> CRITICAL candidate

requestedQuantity
= target - available
```

Die Policy:

```text
- reserviert keine Ressource;
- mutiert CampaignState nicht;
- erzeugt keine MOOSE-Mission;
- materialisiert keine Gruppe;
- erfindet keine Schwellenwerte.
```

Deduplizierungsschlüssel:

```text
RESUPPLY|<destinationNodeId>|<resourceId>
```

## 6. RESUPPLY – nächster vertikaler Pfad

Die Domain-Tests des Foundation-Blocks sind ausgeführt und bestanden. Die für den nächsten Schritt erforderliche Schwellenentscheidung ist abgeschlossen:

```text
reorder  = 50% of target
critical = 25% of target
```

Zielkette:

```text
ResourceDemandPolicy candidate
-> MissionDemand.Create
-> choose approved origin from CampaignState/supplyParent
-> CampaignState ReserveResource(TRANSFER)
-> bind transactionId to MissionDemand
-> MOOSE Ground execution
-> MarkLoading
-> MarkInTransit
-> physical delivery or loss
-> MarkDelivered / MarkLost / Cancel
-> MissionDemand SUCCESS / FAILED / EXPIRED
```

Für physische Ground-Ausführung bleibt die aktuelle MOOSE-Source-Review-Fassung auf `main` maßgeblich. Ein eigener paralleler Convoy-Dispatcher oder eigener strategischer Cargo-Store wird nicht eingeführt.

## 7. CAS_IMMEDIATE – Abhängigkeit und Grenze

CAS-Runtime wird in diesem Schritt noch nicht implementiert.

Zielkette:

```text
MOOSE EVENTS.Hit
-> known BLUE strategic/runtime entity
-> TacticalSupportIncident aggregation
-> AIR_SUPPORT_REQUEST
-> CAS_IMMEDIATE MissionDemand
-> AIR_TASKING_PLAN
-> AUFTRAG CAS
-> BLUE COMMANDER
```

Wiederholte Treffer dürfen keinen Request-Sturm erzeugen. Ein Incident bleibt die Deduplizierungsgrenze für denselben laufenden Kontakt.

Die produktive CAS-Ausführung hängt weiterhin von der Reconciliation des bestehenden BLUE-COMMANDER-Branches ab. Dieser Scope wird hier nicht parallel neu implementiert.

## 8. MOOSE-First-Bewertung dieses Schritts

Die Schwellenänderung bleibt Campaign-Domain-/Konfigurationslogik. Sie führt keine eigene operative DCS-Ausführung ein und ersetzt keine MOOSE-Funktion.

Für die späteren Runtime-Schritte bleibt `docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md` auf `main` die maßgebliche Source-Review-Grundlage. Neue MOOSE-Nutzung ist erneut gegen die tatsächlich geladene `Moose.lua` und die offizielle Dokumentation zu prüfen.

## 9. Tests

```text
tests/mission-demand/test_mission_demand.lua
tests/mission-demand/test_resource_demand_policy.lua
tests/mission-demand/run.lua
```

Der ResourceDemandPolicy-Test prüft zusätzlich die produktive `OMW_GroundInitialStock.lua`-Konfiguration:

```text
- reorderRatio = 0.50
- criticalRatio = 0.25
- SUPPLY/AMMO/FUEL erhalten 50%/25% von target
- PERSONNEL/VEHICLE/Loss-Audit bleiben bei 0/0
```

DCS ist für diese reine Domain-/Konfigurationsstufe nicht erforderlich. Daraus folgt ausdrücklich keine DCS-Runtime-Acceptance.

## 10. Nicht Teil dieses Schritts

```text
- keine Änderung von Ground target
- keine automatische Resupply-Materialisierung
- kein ROAD_CONVOY Runtime-Adapter
- kein eigener Ground routing/spawn fallback
- kein TacticalSupportIncident Runtime-Adapter
- kein EVENTS.Hit Runtime-Hook
- kein CAS AUFTRAG
- kein BLUE COMMANDER
- kein Spieler-Tasking
- keine Änderung an .miz
```

## 11. Abnahmekriterien des Schwellen-Schritts

```text
[x] owner decision: reorder = 50% of target
[x] owner decision: critical = 25% of target
[x] thresholds limited to transferable SUPPLY/AMMO/FUEL resources
[x] no parallel resource authority introduced
[ ] Lua contract tests PASS on threshold branch
[ ] documentation validator reviewed
[ ] complete diff reviewed
[ ] final local pull/hash readback complete
```

Nach Abschluss dieser Checks ist der Schwellen-Gate geschlossen und der erste physische RESUPPLY-Vertical-Slice fachlich nicht mehr durch fehlende Schwellenwerte blockiert.
