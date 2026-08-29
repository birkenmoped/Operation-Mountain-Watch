---
document_id: OMW-ARMY-GROUND-VEHICLE-REPLENISHMENT-DECISION
status: BINDING_PROJECT_DECISION
document_class: GROUND_RESOURCE_POLICY
owning_policy: OMW-GOV-001
authoritative_for:
  - strategic Ground VEHICLE replenishment policy
  - Stage 1D-V scope closure
  - behavior when a Ground node exhausts its VEHICLE stock
not_authoritative_for:
  - exact vehicle type composition of individual Ground formations
  - tactical vehicle relocation between operational formations
  - future owner-approved campaign reinforcement mechanics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - planned Stage 1D-V vehicle-resupply reconciliation
  - any inference that every strategic Ground resource requires its own replenishment executor
superseded_by:
source_branch: agent/vehicle-resupply-policy-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# ARMY Ground – Entscheidung zum VEHICLE-Nachschub

## 1. Owner-Entscheidung

Projektinhaberentscheidung vom 29.08.2026:

```text
Kein eigener Fahrzeug-Nachschub.

Wenn der strategische VEHICLE-Bestand eines Ground-Knotens aufgebraucht ist,
kommt kein Ersatz aus einem anderen Warehouse, Store, Ground-Knoten oder OFF_MAP nach.
```

Damit ist `VEHICLE` keine nachfüllbare CampaignState-Transferressource und erzeugt keinen eigenen `RESUPPLY`-Demand.

## 2. Strategischer Vertrag

`VEHICLE` bleibt node-spezifischer strategischer Bestand:

```text
GROUND:<groundNodeId>:VEHICLE
```

Beispiele:

```text
GROUND:GROUND_NODE_FORTRESS:VEHICLE
GROUND:GROUND_NODE_JOYCE:VEHICLE
GROUND:GROUND_NODE_BOSTICK:VEHICLE
```

Es wird ausdrücklich keine gemeinsame transferierbare Ressource wie

```text
GROUND_VEHICLE
```

oder ein äquivalenter Vehicle-Resupply-Pool eingeführt.

Die gemeinsam transferierbaren Ground-Ressourcen bleiben davon unberührt:

```text
GROUND_PERSONNEL
GROUND_SUPPLY_PACKAGE
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
```

## 3. Verlust, Rückkehr und Verfügbarkeit

Die bestehende Ground-Settlement-Semantik bleibt erhalten:

```text
confirmed correlated VEHICLE loss
-> VEHICLE decreases exactly once
-> VEHICLE_LOST audit increases exactly once

confirmed physical return of surviving vehicle
-> existing committed vehicle becomes available again exactly once

returned damaged survivor
-> follows the currently accepted immediate-availability contract
-> no new replacement vehicle is created
```

Eine Rückgabe eines zuvor eingesetzten Fahrzeugs ist keine Nachlieferung und keine Bestandsvermehrung.

MOOSE `WAREHOUSE`, `BRIGADE`, `PLATOON`, `ARMYGROUP` oder ein physischer Warehouse-Handoff dürfen deshalb nur den Lifecycle der bereits vorhandenen strategischen Ressource repräsentieren. Sie dürfen keinen zusätzlichen strategischen VEHICLE-Bestand erzeugen.

## 4. Erschöpfung des Bestands

Wenn für einen Knoten gilt:

```text
available VEHICLE = 0
```

oder eine Mission die noch verfügbare Menge beziehungsweise einen geschützten Restbestand überschreiten würde, gilt:

```text
vehicle-dependent mission not eligible
```

Es wird weder automatisch noch über MissionDemand ausgelöst:

```text
VEHICLE RESUPPLY
VEHICLE TRANSFER FROM ANOTHER NODE
VEHICLE OFF_MAP REPLENISHMENT
VEHICLE WAREHOUSE REFILL
VEHICLE COHORT RELOCATION AS REPLACEMENT
```

Ist der Bestand aufgebraucht, bleibt die entsprechende Fahrzeugkapazität für den laufenden Kampagnenzustand erschöpft, bis eine spätere ausdrückliche Owner-Entscheidung einen anderen Mechanismus einführt.

## 5. MOOSE-First-Grenze

Der frühere Stage-1D-Source-Review hatte `LEGION:RelocateCohort(...)` und `COMMANDER:RelocateCohort(...)` als mögliche MOOSE-Funktionen für die organisatorische Verlegung ganzer Cohorts identifiziert.

Diese Funktionen werden durch die vorliegende Entscheidung **nicht** zu einem Vehicle-Resupply-Mechanismus.

```text
whole-cohort relocation
!=
strategic VEHICLE replenishment
```

Für diese Entscheidung ist keine neue MOOSE-Implementierung erforderlich. Es besteht daher auch kein Anlass, einen eigenen Vehicle-Resupply-Adapter, einen Native-DCS-Fallback oder eine parallele Ressourcenlogik zu entwickeln.

## 6. Stage-1D-V-Closure

Der bisher geplante Entwicklungspunkt

```text
Stage 1D-V VEHICLE source/design reconciliation
```

wird geschlossen und nicht implementiert.

Begründung:

```text
VEHICLE remains finite node-specific stock
-> no replenishment requirement
-> no executor requirement
-> no DCS acceptance required for vehicle replenishment
```

Die vorhandenen Vehicle-Loss-/Return-Nachweise bleiben für ihren dokumentierten Scope gültig; sie beweisen Rückkehr und Verlust vorhandener Fahrzeuge, nicht Nachschub.

## 7. Nächster Automatic-Response-Scope

Nach Abschluss von Stage 1D-S und Stage 1D-P sowie dieser Owner-Entscheidung ist der nächste geplante Automatic-Response-Entwicklungspunkt:

```text
Stage 2
FOB attacked -> support demand
```

Stage 1D-V ist kein offener Vorgänger oder Blocker mehr.
