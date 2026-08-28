---
document_id: OMW-MOOSE-GROUND-RESUPPLY-EXECUTION-SOURCE-REVIEW
status: BINDING
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE source and runtime interpretation for accepted Ground RESUPPLY execution paths
  - relationship between Stage 1A AMMOSUPPLY, Stage 1C neutral NOTHING and Stage 1B2 FUELSUPPLY evidence
not_authoritative_for:
  - production generic Ground RESUPPLY executor outside accepted per-stage scopes
  - CAS or CSAR execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground RESUPPLY Execution – MOOSE Source Review

## 1. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Maßgeblich für API-Verfügbarkeit ist die tatsächlich verwendete `Moose.lua`.

## 2. Strategische Grenze

```text
CampaignState = einzige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Zustand
MOOSE = physische operative Ausführung
DCS groups = temporäre physische Repräsentation
```

Physische Trucks oder Tanker definieren keine autoritative CampaignState-Package-Kapazität.

## 3. Stage 1A – AMMO RESUPPLY

Technisch akzeptierter Pfad:

```text
MissionDemand RESUPPLY
-> CampaignState transfer
-> BRIGADE / PLATOON / ARMYGROUP
-> AUFTRAG:NewAMMOSUPPLY
-> destination proof
-> CampaignState DELIVERED
-> MissionDemand SUCCESS
-> RTZ / Returned
-> Warehouse AddAsset
```

Maßgeblich:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-1.md
```

## 4. Stage 1B – historischer FUELSUPPLY-Versuch

Der frühere Test verwendete einen harten Travel-Timeout und bleibt deshalb:

```text
HISTORICAL_TEST_FIXTURE / INCONCLUSIVE
```

Er ist kein Gegenbeweis gegen MOOSE FUELSUPPLY.

## 5. Stage 1C – neutraler Meta-RESUPPLY-Pfad

Technisch akzeptierter Pfad:

```text
AUFTRAG:NewNOTHING(destinationZone)
-> physical movement
-> destination proof
-> exact-once CampaignState delivery
-> MissionDemand SUCCESS
-> same ARMYGROUP return
-> Returned
-> Warehouse AddAsset
```

Maßgeblich:

```text
mission/tests/ground-resupply-execution/ACCEPTANCE-3.md
```

Dieser Pfad beweist einen neutralen physischen Executor für den exakt getesteten Scope. Er ist keine pauschale Produktionsfreigabe für jede Ressourcenklasse.

## 6. Stage 1B2 – Fuel-spezifischer Executor

Nach Source-Review und DCS-Acceptance gilt für `GROUND_FUEL_PACKAGE`:

```text
preferred physical executor = AUFTRAG:NewFUELSUPPLY
-> BRIGADE:AddMission
```

Nicht für One-Shot-Transfers:

```text
BRIGADE:AddRefuellingZone
```

Diese API registriert einen persistenten Refuelling-Service.

Maßgeblich:

```text
docs/moose/GROUND-FUEL-REFUELLING-ZONE-SOURCE-REVIEW.md
mission/tests/ground-resupply-execution/ACCEPTANCE-4.md
```

## 7. MOOSE-first Ergebnis

```text
AMMO  -> specialized MOOSE AMMOSUPPLY validated
FUEL  -> specialized one-shot MOOSE FUELSUPPLY validated
OTHER -> no production-generic executor selected by this branch
```

Die verbleibende Stage-1D-Reconciliation für andere Ressourcenklassen wurde in `agent/automatic-response-orchestration-continuation` verschoben.
