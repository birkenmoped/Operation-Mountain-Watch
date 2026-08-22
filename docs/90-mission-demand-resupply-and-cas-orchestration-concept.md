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
source_branch: main
source_commit: 34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
validated_in_dcs: false
---

# 90 – MissionDemand-Orchestrierung für Resupply und Immediate CAS

## 1. Reconciliation-Zweck

Dieses Dokument ersetzt nicht die verbindliche Kampagnenarchitektur aus `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`. Es konkretisiert den gemeinsamen Domain-Layer für zwei Reaktionsketten:

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

## 2. Foundation-Integration

```text
legacy source branch:
agent/mission-demand-resupply-cas-concept

final reconciliation source head:
c8d1cad4ce7469f350b6a3d6e10fee955348620c

merged via PR:
114

merge commit:
341a65105c24807de3ac289bb18d80339111cbd1
```

Der Legacy-Branch wurde nicht als Ganzes übernommen. Aktuelle Ground-Ressourcen, Ground-Rearm, CampaignState-Integration und MOOSE-Dokumentation auf `main` bleiben maßgeblich.

## 3. CampaignState- und Ressourcenvertrag

CampaignState bleibt alleinige strategische Ressourcenautorität. MissionDemand führt keinen zweiten Ressourcenledger.

Übertragbare Ground-Ressourcen:

```text
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

Vorhandene Demand-Metadaten:

```text
target
reorder
critical
supplyParent
```

## 4. Freigegebene Ground-Resupply-Schwellen

Projektinhaberentscheidung vom 22. August 2026:

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

Nicht automatisch über diese Policy disponiert werden:

```text
PERSONNEL
VEHICLE
Loss-Audit resources
```

Die Berechnung erfolgt direkt aus `target`. Es wird keine zusätzliche Rundungsregel eingeführt.

PR #115 integrierte diese Schwellen nach `main`:

```text
branch:
agent/mission-demand-resupply-thresholds

final source head:
48e627eb3d61ab8e41d933d709d9f93cdc0a0273

merge commit:
34b1f46120f951ca2a6308cf1d9fbbb4b0a17863
```

## 5. MissionDemand Domain Registry

Integrierter Domain-Layer:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
```

Typen im ersten Scope:

```text
RESUPPLY
CAS_IMMEDIATE
```

MissionDemand besitzt keine MOOSE- oder DCS-Abhängigkeit. ResourceDemandPolicy reserviert keine Ressource, mutiert CampaignState nicht und materialisiert keine DCS-/MOOSE-Gruppe.

Demand-Semantik:

```text
available > reorder
-> no demand

available <= reorder
-> REORDER candidate

critical > 0 and available <= critical
-> CRITICAL candidate

requestedQuantity
= target - available
```

Deduplizierungsschlüssel:

```text
RESUPPLY|<destinationNodeId>|<resourceId>
```

## 6. Verifikation des Schwellen-Schritts

Finaler Source-Head des Merge-Kandidaten:

```text
48e627eb3d61ab8e41d933d709d9f93cdc0a0273
```

GitHub Actions:

```text
MissionDemand validation
run: 32583400735
result: PASS
```

Documentation Validation:

```text
run: 32583400737
result: 18 error(s), 0 warning(s)
```

Alle 18 Fehler sind bereits vorhandene Army-Ground-/Ground-Metadatenfehler auf `main`; der Threshold-Branch fügte keinen MissionDemand-spezifischen Validatorfehler hinzu.

Der Projektinhaber meldete für denselben finalen Source-Head real zurück:

```text
HEAD MATCH
PASS git diff --check
PASS no unresolved merge placeholder
6 files changed, 247 insertions(+), 319 deletions(-)
```

Nach dem Merge wurde `main` real auf folgenden Stand aktualisiert:

```text
main head:
34b1f46120f951ca2a6308cf1d9fbbb4b0a17863

merge ancestry:
PASS PR #115 source head is in main
```

Die sechs SHA-256-Werte des integrierten Stands entsprechen dem finalen Branch-Readback.

DCS ist für diese reine Domain-/Konfigurationsstufe nicht erforderlich. Daraus folgt ausdrücklich keine DCS-Runtime-Acceptance.

## 7. RESUPPLY – nächster vertikaler Pfad

Der Schwellen-Gate ist fachlich, technisch und auf `main` integriert geschlossen. Der nächste Entwicklungsschritt ist der erste physische RESUPPLY-Vertical-Slice:

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

Vor der Runtime-Implementierung ist die aktuelle MOOSE-Source-Review-Fassung auf `main` erneut gegen die tatsächlich verwendete `Moose.lua` zu prüfen. Ein eigener paralleler Convoy-Dispatcher oder strategischer Cargo-Store wird nicht eingeführt.

## 8. CAS_IMMEDIATE – Abhängigkeit und Grenze

CAS-Runtime ist weiterhin nicht Teil dieses Schritts. Zielkette:

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

Die produktive CAS-Ausführung hängt von der separaten BLUE-COMMANDER-Reconciliation ab.

## 9. Nicht Teil dieses Schritts

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

## 10. Abnahmekriterien des Schwellen-Schritts

```text
[x] owner decision: reorder = 50% of target
[x] owner decision: critical = 25% of target
[x] thresholds limited to transferable SUPPLY/AMMO/FUEL resources
[x] no parallel resource authority introduced
[x] Lua contract tests PASS on threshold branch
[x] documentation validator reviewed
[x] complete diff reviewed
[x] final local branch pull/hash readback complete
[x] merged via PR #115
[x] post-merge main readback complete
```

Der Schwellen-Gate ist damit geschlossen. Der erste physische RESUPPLY-Vertical-Slice ist fachlich nicht mehr durch fehlende Schwellenwerte blockiert.
