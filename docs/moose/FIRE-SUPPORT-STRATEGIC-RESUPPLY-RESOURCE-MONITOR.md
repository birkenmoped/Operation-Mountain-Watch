---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-MONITOR
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed CampaignState shortage to generic Base resupply-demand bridge
  - shortage-episode dedupe boundary without a second retry or resource authority
not_authoritative_for:
  - final six-site resource threshold rows
  - final choice of ground versus air transport per resource shortage
  - DCS runtime validation or MOOSE transport lifecycle acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – Strategic Resource Monitor

## Zweck

`scripts/campaign/OMW_FireSupStratResupply_ResupplyMonitor.lua` verbindet den bestehenden strategischen Ressourcenvertrag mit der generischen Fire-Support-/Resupply-Base, ohne eine zweite Ressourcenautoritaet zu erzeugen.

Die Zuständigkeiten bleiben:

```text
CampaignState
-> authoritative strategic resource snapshot/reservations/transactions

OMW_ResourceDemandPolicy
-> threshold evaluation only

OMW_FireSupStratResupply_ResupplyMonitor
-> one shortage episode -> one Base resupply demand

OMW_FireSupStratResupply_Base
-> generic site/resource demand contract

MOOSE adapter
-> operational transport recruitment/queue/execution

confirmed physical lifecycle
-> CampaignState transaction settlement
```

## Kein Scheduler / keine Retry-Queue

Der Monitor besitzt bewusst keinen Scheduler. `EvaluateAll()` oder `EvaluateRow(row)` muss von der uebergeordneten Runtime in einem fachlich geeigneten Takt beziehungsweise nach einem relevanten Zustandsereignis aufgerufen werden.

Ein laufendes Shortage-Episode wird intern nur dedupliziert. Das ist keine operative Retry-Queue. Solange die Ressource unterhalb des Schwellwerts bleibt, wird nicht bei jedem Evaluate-Aufruf eine neue Demand erzeugt.

Wenn CampaignState wieder keinen Shortage-Kandidaten liefert, wird die Episode geschlossen. Ein nachfolgender erneuter Mangel kann eine neue Demand erhalten.

Bei einem bestaetigten terminalen Transportereignis, das keine Bestandswiederherstellung erzeugt, kann `ReleaseDemand(demandId, reason)` die Episode explizit fuer eine erneute fachliche Bewertung freigeben. Der Monitor startet dabei keinen automatischen Retry.

## Threshold-Autoritaet

Der Monitor erfindet keine Ziel-, Reorder- oder Critical-Werte. Er ruft die vorhandene `OMW_ResourceDemandPolicy:Evaluate`-Logik mit einem `CampaignState:GetResource()`-Snapshot auf. Die ResourceDemandPolicy ist bereits als Campaign-Domain-only implementiert und mutiert weder CampaignState noch MOOSE.

Die konkreten `rows` bleiben injizierte Baseline-/Manifestdaten.

## Site-Zuordnung

Ein Shortage-Kandidat adressiert einen strategischen `destinationNodeId`. Der Monitor mappt diesen ueber `SiteRegistry.Sites[*].campaignNodeId` auf die allgemeine Site-ID. Er interpretiert weder DCS-Gruppennamen noch Warehouses als strategische Resource Nodes.

Fehlt eine solche Zuordnung, erfolgt kein Dispatch:

```text
SITE_NOT_REGISTERED_FOR_RESOURCE_NODE
```

## Ground versus Air

Die Wahl zwischen

```text
GROUND_RESUPPLY
AIR_RESUPPLY
```

wird ueber `selectSupportType(candidate, site, snapshot)` injiziert. Der Monitor trifft keine versteckte Transportentscheidung und leitet sie auch nicht aus Entfernung, ACCESS-Zone oder Warehouse-Namen ab.

## Request-Key / Shortage Episode

Pro `nodeId + resourceId` wird eine lokale Episodengeneration gefuehrt:

```text
RESOURCE_THRESHOLD|<resourceId>|<generation>
```

Sie dient ausschliesslich der Demand-Deduplizierung innerhalb der laufenden Runtime. Die strategische Ressourcenwahrheit bleibt CampaignState.

## Contract-Test

```text
tests/mission-demand/test_fire_support_strategic_resupply_resupply_monitor.lua
```

Abgedeckt sind:

- CampaignState-Snapshot bleibt Input, nicht Kopie einer Ressourcenautoritaet;
- Restore-to-target-Menge kommt aus ResourceDemandPolicy;
- eine Demand je laufender Shortage-Episode;
- neue Episode erst nach Bestandsnormalisierung oder expliziter terminaler Freigabe;
- keine Demand fuer unbekannten Resource Node;
- Transportart wird injiziert;
- keine automatische Retry-Schleife.

Das ist Contract-/CI-Evidenz und kein DCS-PASS.
