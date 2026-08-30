---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-STAGE-3-SOURCE-REVIEW
status: PLANNED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 source/domain reconciliation before implementation
  - relationship between fixed-fire-support local rearm consumption and strategic Ground AMMO RESUPPLY demand
  - identification of existing reusable MissionDemand, ResourceDemand, CampaignState and MOOSE execution contracts
not_authoritative_for:
  - final Stage 3 acceptance scope
  - new owner decisions for thresholds or site coverage
  - DCS runtime validation of the Stage 3 integration
  - new Native-DCS or non-MOOSE exceptions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Fire Support -> Strategic Resupply Closure – Source-/Domain-Reconciliation

## 1. Zweck

Diese Reconciliation ist Schritt 1 der Stage-3-Übergabe. Sie prüft den aktuellen `main`-Stand gegen die vorhandenen DCS-validierten Fire-Support- und Ground-AMMO-RESUPPLY-Baselines, bevor neue Integrationslogik entworfen wird.

Verbindliche Authority-Grenze:

```text
CampaignState = einzige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Domain
MOOSE = primärer operativer Executor / physischer Lifecycle
DCS groups = temporäre physische Repräsentationen
```

Stage 3 darf deshalb weder einen zweiten Ammo-Ledger noch einen parallelen Artillery-/Rearm-/Ground-Routing-Lifecycle einführen.

## 2. Geprüfter Repository-Stand

```text
main HEAD:
10789637d009a664a6e65b633d3df8a35f8d5117

Stage-3 branch HEAD vor dieser Reconciliation:
6397b6eaa796da908fccd29ef1d49065a52eb97e

Stage-3 branch relation to main:
ahead 1 / behind 0
```

Der Stage-3-Branch basiert damit weiterhin exakt auf dem in der Übergabe dokumentierten `main`-Stand; zwischen Übergabe und Startcheck ist kein neuer `main`-Commit hinzugekommen.

## 3. Geprüfte Baselines und produktive Quellen

Governance / Handoffs / Contracts:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/handoffs/2026-08-22-automatic-response-orchestration-development-order.md
docs/handoffs/2026-08-30-fob-attack-support-demand-ready-for-review.md
docs/handoffs/2026-08-30-stage-3-fire-support-strategic-resupply-closure-handoff.md
mission/tests/ground-ammo-rearm-integration/CURRENT-STATUS-TODO.md
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md
docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md
docs/moose/GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW.md
docs/ground/ARMY-GROUND-RESOURCE-READINESS-CONTRACT.md
docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
```

Produktive Domain-/Runtime-Quellen:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
scripts/campaign/OMW_ResourceDemandCoordinator.lua
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
```

Acceptance-Referenz für den bereits DCS-validierten strategischen AMMO-Transport:

```text
mission/tests/ground-resupply-execution/src/01-ground-ammo-resupply-acceptance.lua
```

## 4. Reconciliation-Matrix

| Stage-3-Verantwortung | Aktueller Owner / bestehender Vertrag | Befund |
|---|---|---|
| producer of shortage evidence | `CampaignState`-Resource `GROUND_AMMO_PACKAGE` nach bestätigter lokaler Rearm-Consumption | Bereits vorhanden. Kein eigener Fire-Support-Ammo-Scanner erforderlich. |
| stable node/resource identity | `nodeId` + shared `GROUND_AMMO_PACKAGE` | Bereits vorhanden und in `OMW_GroundInitialStock.lua` für alle sechs Ground-Nodes normalisiert. |
| threshold / shortage qualification | `OMW_ResourceDemandPolicy` + `OMW_GroundInitialStock.Rows` | Bereits vorhanden: Commodity-Reorder bei 50 %, Critical bei 25 %, Vergleich `AT_OR_BELOW`. |
| demand creator | `OMW_ResourceDemandCoordinator.EvaluateAndCreate(...)` | Bereits vorhanden; erzeugt `MissionDemand.Type.RESUPPLY`. |
| active-demand dedupe | `MissionDemand.activeByDedupeKey` | Bereits vorhanden; Key für ResourceDemand: `RESUPPLY|nodeId|resourceId`. |
| strategic transfer authority | `CampaignState` TRANSFER transaction | Bereits im Stage-1-AMMO-Acceptance verwendet. |
| physical strategic AMMO executor | MOOSE `BRIGADE` / `PLATOON` / `ARMYGROUP` + `AUFTRAG:NewAMMOSUPPLY(...)` | DCS-validiert in Stage 1A, aber derzeit als Acceptance-Vertical-Slice dokumentiert; kein eigenständiger produktiver AMMO-Dispatcher im `scripts/campaign/`-Baum gefunden. |
| local artillery rearm | `OMW_FixedFireSupportAmmoRearmService` -> `OMW_GroundAmmoRearmAdapter` -> MOOSE `ARTY:Rearm()` | DCS-validiert. Nicht neu bauen. |
| local rearm commit point | MOOSE `ARTY.OnBeforeRearm` -> `CampaignState:Consume(...)` | DCS-validierter Option-B-Vertrag: Consumption erst nach akzeptiertem MOOSE-Rearm-Start. |
| local rearm completion | MOOSE `ARTY.OnAfterRearmed` -> `CampaignState:CompleteConsumption(...)` | DCS-validiert; bestätigt lokalen Rearm, nicht strategische Parent-to-Node-RESUPPLY-Lieferung. |
| strategic resupply completion | Stage-1-AMMO: exakte `ARMYGROUP` MissionExecute-/Destination-Zone-Evidenz -> `CampaignState:MarkDelivered(...)` -> `MissionDemand:Succeed(...)` | DCS-validiert für Joyce -> Honaker Vertical Slice. Dies ist der passende Demand-Closure-Vertrag für Stage 3. |
| support return-to-stock | local Fire Support: `FixedFireSupportAmmoRearmService` + MOOSE return + Warehouse `AddAsset`; strategic AMMO Stage 1: `ARMYGROUP:RTZ(...)` -> `Returned` -> Warehouse `AddAsset` | Beide Lebenszyklen sind getrennt und bereits technisch nachgewiesen. |
| local rearm restore compensation | `OMW_GroundAmmoRearmAdapter.ReconcileRestore(...)` | Same-session DCS PASS; echter Prozessrestart bleibt Stage 8. |

## 5. Wichtigster Source-Befund: Stage 3 braucht keinen neuen Fire-Support-Trigger

Die produktive Fire-Support-Rearm-Kette besitzt bereits den strategisch relevanten Commit:

```text
ARTY rearm accepted
-> GroundAmmoRearmAdapter OnBeforeRearm
-> CampaignState Consume(GROUND_AMMO_PACKAGE at local node)
-> local node quantity decreases exactly once
```

Damit liegt die autoritative Shortage-Evidenz bereits im CampaignState. Stage 3 muss nicht die DCS-Artilleriemunition pollen und auch kein neues MOOSE-Event in einen separaten Ammo-Ledger übersetzen.

Der bestehende ResourceDemand-Vertrag kann anschließend genau diesen CampaignState-Zustand bewerten:

```text
CampaignState local GROUND_AMMO_PACKAGE available
-> ResourceDemandPolicy.Evaluate(...)
-> existing row target/reorder/critical
-> RESUPPLY candidate
-> ResourceDemandCoordinator
-> MissionDemand RESUPPLY
```

### Bestehender AMMO-Schwellwert

`OMW_GroundInitialStock.lua` definiert für `SUPPLY`, `AMMO` und `FUEL` bereits:

```text
reorder = 50 % des Targets
critical = 25 % des Targets
reorder comparison = AT_OR_BELOW
```

Daraus folgt für die aktuellen Fixed-Fire-Support-Nodes:

```text
BOSTICK  target 52 -> reorder <= 26 -> critical <= 13
WRIGHT   target 30 -> reorder <= 15 -> critical <= 7.5
FORTRESS target 48 -> reorder <= 24 -> critical <= 12
HONAKER  target 40 -> reorder <= 20 -> critical <= 10
```

Diese Werte sind bereits bestehende Runtime-Daten. Stage 3 muss keinen neuen Artillerie-spezifischen Threshold erfinden, sofern der Projektinhaber den allgemeinen Ground-AMMO-ResourceDemand-Vertrag auch für Fixed Fire Support beibehalten will.

## 6. Trennung zweier AMMO-Lebenszyklen

Stage 3 darf zwei bereits vorhandene, semantisch verschiedene Vorgänge nicht vermischen.

### 6.1 Lokaler Fire-Support-Rearm

```text
local fixed-fire-support battery depleted / requires rearm
-> local M1083 support materialization
-> ARTY:Rearm()
-> consume 1 local GROUND_AMMO_PACKAGE
-> ARTY OnAfterRearmed
-> local consumption COMPLETED
-> M1083 returns to local Warehouse stock
```

Der Accepted-Fire-Support-Lauf hat für jeden der vier Standorte genau einen lokalen Package-Verbrauch bestätigt.

### 6.2 Strategischer Parent-to-Node-RESUPPLY

```text
local CampaignState AMMO stock reaches qualified shortage threshold
-> MissionDemand RESUPPLY
-> reserve TRANSFER at supplyParent
-> MOOSE AUFTRAG:NewAMMOSUPPLY(destinationZone)
-> physical convoy reaches destination
-> CampaignState MarkDelivered
-> destination stock credited
-> MissionDemand SUCCESS
-> strategic convoy returns to origin stock
```

Der passende Demand-Closure-Punkt ist deshalb die **strategische Lieferung am Zielknoten**, nicht `ARTY OnAfterRearmed`.

`ARTY OnAfterRearmed` schließt ausschließlich den lokalen Verbrauchsvorgang ab, der den strategischen Bestand zuvor reduziert hat.

## 7. Dedupe- und Exactly-once-Grenze

Bereits vorhanden:

```text
ResourceDemandPolicy dedupeKey
= RESUPPLY|<destinationNodeId>|<resourceId>

MissionDemand
= höchstens ein nichtterminaler Demand pro dedupeKey
```

Der strategische Transfer selbst besitzt zusätzlich eine CampaignState-Transaction-ID.

Für Stage 3 darf deshalb kein zweiter Fire-Support-spezifischer Dedupe-Ledger eingeführt werden.

Arbeitsrichtung:

```text
while MissionDemand RESUPPLY active
-> repeated policy evaluation returns same candidate
-> MissionDemand Create returns active_duplicate
-> no second transfer / no second convoy
```

Diese Kombination muss im Stage-3-Contract-Test explizit verifiziert werden.

## 8. Failure-/Compensation-Grenze

### Lokaler Rearm

Bereits DCS-validiert:

```text
RESERVED / LOADING at restore -> CANCELLED
CONSUMED but not COMPLETED -> exactly-once compensation -> COMPENSATED
COMPLETED -> preserved
```

### Strategischer RESUPPLY

Stage-1-AMMO-Acceptance beweist den SUCCESS-Pfad, aber ausdrücklich nicht:

```text
convoy loss
abort settlement
multiple concurrent demands
external process/server persistence
```

Stage 3 darf diese nicht getesteten Fehlerpfade nicht stillschweigend als geschlossen ausgeben. Für den kleinsten Vertical Slice ist zunächst der bereits akzeptierte Success-Lifecycle wiederzuverwenden; zusätzliche Failure-Akzeptanz ist nur soweit nötig in Stage 3 zu ergänzen, ohne Stage 4/8/9 vorwegzunehmen.

## 9. MOOSE-first Bewertung

Für die bisherige Reconciliation wird **keine neue MOOSE-API benötigt**.

Bereits akzeptierte MOOSE-Verträge:

```text
local rearm:
ARTY:Rearm()
ARTY OnBeforeRearm
ARTY OnAfterRearmed
WAREHOUSE / BRIGADE / PLATOON support materialization

strategic AMMO resupply:
BRIGADE
PLATOON:AddMissionCapability(AUFTRAG.Type.AMMOSUPPLY, ...)
AUFTRAG:NewAMMOSUPPLY(...)
BRIGADE:AddMission(...)
ARMYGROUP lifecycle
ARMYGROUP:RTZ(...)
Returned / Warehouse AddAsset
```

Da Schritt 1 nur bestehende, bereits source-geprüfte und DCS-validierte APIs miteinander abgleicht, ist vor dieser Dokumentation kein neuer MOOSE-Source-Claim erforderlich.

Sobald Stage 3 eine zusätzliche oder veränderte MOOSE-API benötigt, gilt erneut zwingend:

```text
MOOSE docs
-> gepinnte Moose.lua 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
-> Signatur / FSM / Events / Voraussetzungen
-> offizielle Demos soweit relevant
-> erst danach Code
```

## 10. Tatsächliche Integrationslücke auf `main`

Die Reconciliation findet keine fehlende Artillerie- oder Rearm-Funktion.

Die konkrete Lücke ist die **produktive Orchestrierungsverbindung** zwischen:

```text
CampaignState AMMO shortage candidate
-> MissionDemand RESUPPLY
-> strategischer AMMO-Transfer
-> bereits validierter MOOSE AMMOSUPPLY executor
-> delivery settlement
-> MissionDemand closure
```

Der Stage-1A-Pfad ist technisch akzeptiert, liegt aber als Acceptance-Vertical-Slice vor. Im aktuellen `scripts/campaign/`-Baum existieren nur:

```text
OMW_CampaignState.lua
OMW_FobAttackDemandPolicy.lua
OMW_MissionDemand.lua
OMW_ResourceDemandCoordinator.lua
OMW_ResourceDemandPolicy.lua
```

Ein eigenständiger produktiver Ground-AMMO-RESUPPLY-Dispatcher ist dort nicht vorhanden.

Damit ist Stage 3 **keine Rearm-Neuentwicklung**, sondern voraussichtlich die kleinste produktive Extraktion/Komposition des bereits akzeptierten Stage-1A-AMMOSUPPLY-Lifecycles hinter den bestehenden ResourceDemand-/MissionDemand-Vertrag.

## 11. Offene Entscheidungen nach Reconciliation

### A. Acceptance-Scope

Die Übergabe lässt ausdrücklich offen:

```text
one-site vertical slice
oder
alle vier Fixed-Fire-Support-Standorte
```

Technisch ist ein einzelner Vertical Slice die kleinste Änderung. Die vier Standorte teilen jedoch bereits denselben generischen Fire-Support-Rearm-Service und denselben Ground-AMMO-Ressourcenvertrag.

Keine Scope-Entscheidung wird in dieser Source-Review stillschweigend getroffen.

### B. Commodity-Threshold übernehmen oder Fire-Support-spezifisch abweichen

Der bestehende produktive Vertrag liefert bereits `AMMO <= 50 % -> REORDER`.

Eine andere Fire-Support-spezifische Schwelle wäre eine neue Fachentscheidung und müsste ausdrücklich genehmigt werden. Ohne solche Entscheidung ist die technisch konsistenteste Arbeitsrichtung die Wiederverwendung des vorhandenen Ground-AMMO-Thresholds.

### C. Produktionsadapter

Vor Implementierung ist zu entscheiden, ob der Stage-1A-Acceptance-Lifecycle:

```text
1. in einen kleinen generischen Ground-AMMO-RESUPPLY-Executor extrahiert
oder
2. in einer engeren Stage-3-Kompositionsschicht gekapselt
```

wird.

MOOSE-first und Duplicate-Code-Vermeidung sprechen für einen kleinen generischen Executor, sofern Diff-/Regression-Review bestätigt, dass dadurch Stage-1A-Semantik unverändert bleibt.

## 12. Empfohlener kleinster nächste Schritt

Nach Owner-Scope-Entscheidung:

```text
1. Stage-1A-Acceptance-Code gegen produktive Ground-Materializer/Adapter prüfen.
2. Nur fehlende produktive AMMO-RESUPPLY-Orchestrierung extrahieren.
3. Keine neue MOOSE-API einführen, solange BRIGADE/PLATOON/AUFTRAG AMMOSUPPLY genügt.
4. Contract-Test:
   - threshold evaluation
   - one demand only
   - one CampaignState transfer only
   - idempotent duplicate evaluation
   - delivery closes demand exactly once
5. DCS Vertical Slice:
   local fire-support rearm consumption
   -> stock reaches threshold
   -> strategic AMMO RESUPPLY
   -> delivery
   -> demand SUCCESS
   -> convoy return.
```

## 13. Reconciliation-Verdict

```text
existing local fire-support rearm: REUSE / DCS VALIDATED
existing strategic AMMO resource identity: REUSE
existing commodity threshold model: REUSE CANDIDATE / owner may override explicitly
existing MissionDemand RESUPPLY type: REUSE
existing ResourceDemandPolicy/Coordinator: REUSE
existing demand dedupe: REUSE
existing MOOSE AMMOSUPPLY physical path: REUSE / DCS VALIDATED IN STAGE 1A
existing strategic delivery closure: REUSE / DCS VALIDATED IN STAGE 1A
new Fire-Support ammo scanner: NOT REQUIRED
new ARTY/rearm FSM: NOT REQUIRED
new Native-DCS path: NOT REQUIRED
production Stage-3 orchestration bridge: MISSING / NEXT IMPLEMENTATION TARGET
DCS Stage-3 integrated acceptance: NOT YET PERFORMED
```
