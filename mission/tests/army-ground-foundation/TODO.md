---
document_id: OMW-TEST-ARMY-GROUND-FOUNDATION-TODO
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current working scope and open tasks for the Jalalabad/Kunar ARMY ground foundation
not_authoritative_for:
  - final historical ground-force ORBAT strengths
  - final Mission Editor object state
  - DCS runtime acceptance beyond cited result documents
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Arbeitsstand und To-do

## 1. Aktueller Scope

Verbindlicher Recherche-/Kampagnenzeitraum:

```text
01.08.2010–31.12.2011
```

Aktive Ground-ORBAT-Arbeitsreferenz:

```text
July 2011
```

Aktueller Kunar-/Jalalabad-Foundation-Scope:

```text
Jalalabad / FOB Fenty
FOB Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick

Dependent OPs:
Honaker-Miracle -> OP JoJo
Bostick -> OP Mustang / OP Clydesdale / OP Stallion
```

Maßgebliche Fachdateien:

```text
docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md
docs/ground/ARMY-GROUND-RESOURCE-READINESS-CONTRACT.md
docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
docs/ground/ARMY-GROUND-RETURN-SETTLEMENT-DECISION-PREPARATION.md
```

## 2. Architekturgrenze

```text
CampaignState strategic authority
!= MOOSE BRIGADE / WAREHOUSE / PLATOON
!= physical DCS GROUP / ARMYGROUP
```

Zusätzlich:

```text
strategic parent / resource obligation
!= physical dispatch origin
```

MOOSE bleibt für Materialisierung, AUFTRAG-/ARMYGROUP-Lifecycle, Routing, RTZ, Returned und Warehouse-Handoff verantwortlich. CampaignState bleibt alleinige strategische Ressourcenautorität.

## 3. Operative MOOSE-Domänen

```text
BDE_BLUE_GND_JALALABAD -> WH_BLUE_GND_FENTY
BDE_BLUE_GND_FORTRESS  -> WH_BLUE_GND_FORTRESS
BDE_BLUE_GND_JOYCE     -> WH_BLUE_GND_JOYCE
BDE_BLUE_GND_WRIGHT    -> WH_BLUE_GND_WRIGHT
BDE_BLUE_GND_HONAKER   -> WH_BLUE_GND_HONAKER
BDE_BLUE_GND_BOSTICK   -> WH_BLUE_GND_BOSTICK
```

Fortress und Honaker besitzen weiterhin keinen erfundenen unabhängigen Produktionspool. Ihre endgültigen permanenten Personnel-/Vehicle-Mengen bleiben offen.

## 4. Produktionsnahe Ground-Root-Baseline

```text
GROUND_NODE_JALALABAD / Fenty:
  PERSONNEL 480 / VEHICLE 48 / SUPPLY 120 / AMMO 100 / FUEL 120

GROUND_NODE_JOYCE:
  PERSONNEL 180 / VEHICLE 20 / SUPPLY 48 / AMMO 44 / FUEL 40

GROUND_NODE_WRIGHT:
  PERSONNEL 120 / VEHICLE 22 / SUPPLY 36 / AMMO 30 / FUEL 36

GROUND_NODE_BOSTICK:
  PERSONNEL 220 / VEHICLE 26 / SUPPLY 56 / AMMO 52 / FUEL 48
```

Verbindliche M-ATV-Korrelation:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
4 M-ATV = 4 VEHICLE + 12 PERSONNEL
```

Settlement-Regeln:

```text
confirmed return -> immediate one-time availability credit
confirmed loss -> permanent loss
returned damaged vehicle -> immediate one-time availability credit
active nonterminal commitment at server stop/crash -> one-time strategic recredit at next startup
no physical DCS/MOOSE continuation or respawn
```

## 5. Validierte technische Meilensteine

### Acceptance 3-2

```text
six road-aligned Warehouse materializations
same ARMYGROUP across mission phases
stable target hold
PASS / owner visual acceptance
```

### Acceptance 4-2

```text
MissionDone
-> ARMYGROUP:RTZ(existing ACCESS zone, OnRoad)
-> Returned
-> Warehouse AddAsset
-> controlled physical group removal
PASS / owner visual acceptance
```

Ergebnis:

```text
mission/tests/army-ground-foundation/results/2026-08-19-acceptance-4-runtime.md
```

### Acceptance 6

```text
Fenty:  4 -> 4 return
Joyce:  4 -> 1 loss + 3 return
Wright: 4 -> 1 loss + damaged survivor + 3 return
PASS / owner visual acceptance
```

### Acceptance 7 – VALIDATED

Acceptance 7 bestätigte den Ground-CampaignState-Settlement-Adapter gegen den realen MOOSE-Ground-Lifecycle.

```text
Source commit:
e049e34fe8e6de878fd390486888f3912bb179d8

Bundle SHA-256:
b591ccd746896c90064fa93d9b3d42626384f55e605efc748bf304ffccb86ec7

MIZ:
OMW_Template_v14_ground_test.miz

MIZ SHA-256:
88184ec180837044ff4dcef7cca264fe7ee5fcf5d55a8af19b11125c41eab94d

DCS:
2.9.28.26385 MT

Result:
PASS / owner visual acceptance
```

Bestätigt:

```text
Fenty:  4 VEHICLE + 12 PERSONNEL consumed -> 4/12 returned exactly once
Joyce:  4/12 consumed -> 1/3 permanent loss + 3/9 returned exactly once
Wright: 4/12 consumed -> 1/3 permanent loss + damaged survivor + 3/9 returned exactly once
restart: unresolved 4/12 commitment -> strategic recredit exactly once
no physical restart continuation or respawn
```

Runtime-Evidenz:

```text
mission/tests/army-ground-foundation/results/2026-08-20-acceptance-7-runtime.md
```

## 6. Aktueller Gate – Acceptance 8

Acceptance 8 integriert den validierten Ground-Settlement-Adapter gegen den produktionsnahen initialen CampaignState-Bestand, ohne einen zweiten strategischen Store zu erzeugen.

Neue Produktionsmodule:

```text
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
```

Bestehender gemeinsamer Initializer wird erweitert:

```text
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
```

Zielkomposition:

```text
single CampaignState store
= AirOpsInitialStock
+ AARStrategicStock
+ GroundInitialStock
```

Ground-Root-Nodes:

```text
GROUND_NODE_JALALABAD
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_BOSTICK
```

Loss-Audit-Ressourcen pro Root-Node:

```text
GROUND:<nodeId>:VEHICLE_LOST
GROUND:<nodeId>:PERSONNEL_LOST
```

Sie sind reine Audit-Zähler und keine Verfügbarkeitsquelle.

Testplan:

```text
mission/tests/army-ground-foundation/ACCEPTANCE-8.md
```

Runtime source:

```text
mission/tests/army-ground-foundation/src/08-army-ground-production-integration.lua
```

Builder:

```text
tools/build-army-ground-acceptance-8.ps1
```

Bundle:

```text
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_8.lua
```

BuilderVersion / Test-ID:

```text
ARMY-GROUND-ACCEPTANCE-8-1
```

## 7. MOOSE-first-Status Acceptance 8

Acceptance 8 führt keine neue MOOSE-Klasse, keinen neuen MOOSE-Callback und keinen weiteren privaten MOOSE-Override ein.

Der physische Ground-Lifecycle ist durch Acceptance 7 validiert. Acceptance 8 testet nur die strategische CampaignState-Komposition und die bereits validierte Adapter-Semantik gegen die Produktionsmengen.

```text
new MOOSE behavior: none
new Native-DCS behavior: none
new private MOOSE override: none
```

Die bereits genehmigte road-aligned Warehouse-Ausnahme aus Acceptance 3-2 bleibt unverändert und ist nicht Bestandteil des neuen Produktionsintegrationscodes.

## 8. Nächster lokaler Schritt

```text
pull current remote branch
-> build Acceptance 8 bundle
-> record real bundle SHA-256
-> owner embeds only the generated bundle in the test .miz
-> run Acceptance 8
-> return real DCS log and tested MIZ
```

Acceptance 8 benötigt keine neue Ground-Bewegungs- oder Pathfinding-Abnahme. Die DCS-Ausführung dient dem realen Laufzeitnachweis der produktionsnahen Single-CampaignState-Komposition.

## 9. Weiterhin offene Punkte

Nicht durch Acceptance 8 stillschweigend entscheiden:

```text
- permanent Fortress personnel/vehicle property book
- permanent Honaker personnel/vehicle property book
- exact July-2011 Joyce company distribution
- exact July-2011 Bostick maneuver company/platoon distribution
- exact July-2011 Wright artillery assignment
- Jalalabad exact ground QRF/base-defense formation
- final Honaker strategic parent/support-parent contract after complete evidence reconciliation
- production Ground-order generation
- OPSTRANSPORT
- general cross-domain persistence architecture
```

Kein lokaler Build, Hash oder DCS-Verhalten wird angenommen oder simuliert. Nur reale Konsolenausgabe, reale Artefakt-Hashes und dokumentierte DCS-Evidenz bilden die Grundlage für den nächsten Gate.
