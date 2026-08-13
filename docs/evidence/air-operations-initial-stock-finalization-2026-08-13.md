---
document_id: OMW-LOG-AIROPS-INITIAL-STOCK-FINALIZATION-2026-08-13
status: BINDING_PROJECT_DECISION
document_class: RESOURCE_STOCK_POLICY
owning_policy: OMW-GOV-001
authoritative_for:
  - final AirOps strategic initial-store stock planning decisions
  - node-level strategic store aggregation rule
  - fixed-wing strategic ammunition resource identifiers
  - Bagram fighter external-tank classification
  - strategic mission-equipment resource classification and stock thresholds
  - warehouse/resource foundation closure status
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unresolved F-15E/F-16 external-tank strategic classification in docs/ammunition-item-mapping-contract.md
  - per-profile final stock summation where the same physical resource is shared at one node
  - generic AMMUNITION_GBU31 / AMMUNITION_GBU31_PEN planning labels
  - generic AMMUNITION_ILLUMINATION planning label for the OMW LUU-2B path
superseded_by:
source_branch: agent/fighter-store-runtime-correlation
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AirOps Initial-Stock Finalization – 13.08.2026

## 1. Abschlussstatus

Der Projektinhaber hat am 13.08.2026 die AirOps-Initial-Stock-Planung und die dazu gehörenden Warehouse-/Resource-Entscheidungen abgeschlossen.

Die zuvor noch offenen Fighter-Mapping-Gates wurden im Lauf `FIGHTER-STORE-RUNTIME-CORRELATION-1` technisch geschlossen:

```text
F-15E STRIKE GBU-31(V)1/B -> weapons.bombs.GBU_31
F-15E STRIKE GBU-31(V)3/B -> weapons.bombs.GBU_31_V_3B
F-16 deployment AIM-9     -> weapons.missiles.AIM_9
```

Der DCS-Nachweis steht in:

```text
docs/evidence/fighter-store-runtime-correlation-acceptance-2026-08-13.md
```

Damit gilt für den dokumentierten Foundation-Scope:

```text
INITIAL_STOCK_DECISION_BLOCK = CLOSED
FIGHTER_STORE_MAPPING_BLOCK = CLOSED
WAREHOUSE_RESOURCE_FOUNDATION = CLOSED
```

## 2. Strategische Node-Aggregation

Strategische Munition und strategisches Mission Equipment werden als gemeinsamer Pool je

```text
Node + Resource ID
```

geführt. Es existiert kein eigener Munitions- oder Equipmentbestand je SQUADRON oder Aircraft Type.

Verbindliche Berechnungsreihenfolge:

```text
Bedarf aller zulässigen Aircraft-/Payload-Profile desselben Stores am Node
-> Raw Target/Reorder/Critical je Profil
-> Raw-Werte je Node + Resource ID summieren
-> Pair-Multiple und Hub-Pack-Multiple bestimmen
-> Rundung genau einmal auf den aggregierten Node-Bestand anwenden
-> Initial/Target/Reorder/Critical festschreiben
```

MOOSE `WAREHOUSE`-/AIRWING-Instanzen verwalten weiterhin Aircraft-/Asset-Lifecycle. Sie begründen keine separaten strategischen Munitionslager. CampaignState bleibt die strategische Ressourcenhoheit.

## 3. Fixed-Wing-Munitions-IDs

Für die abgedeckten Fixed-Wing-Stores gelten verbindlich:

```text
AMMUNITION_GBU12
AMMUNITION_GBU38
AMMUNITION_GBU54
AMMUNITION_GBU31_V1
AMMUNITION_GBU31_V3
AMMUNITION_AGM65D
AMMUNITION_LUU2B
```

Die früheren Planungslabels

```text
AMMUNITION_GBU31
AMMUNITION_GBU31_PEN
AMMUNITION_ILLUMINATION
```

werden für neue AirOps-Buchungen nicht mehr verwendet.

`AMMUNITION_GBU31_V1` und `AMMUNITION_GBU31_V3` bleiben strategisch getrennte physische Ressourcen.

## 4. F-15E STRIKE Runtime-Mapping

Der Lauf `FIGHTER-STORE-RUNTIME-CORRELATION-1` beobachtete bei Materialisierung des vorhandenen F-15E-STRIKE-Two-Ships:

```text
weapons.bombs.GBU_31       100 -> 98  delta -2
weapons.bombs.GBU_31_V_3B  100 -> 98  delta -2
```

Damit gilt:

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
mapping status = RUNTIME_MAPPING_VALIDATED
```

## 5. Bagram Fighter A/A

Der Vertrag `OMW-LOG-BAGRAM-FIGHTER-AA-DEPLOYMENT-STOCK` bleibt maßgeblich:

```text
BAGRAM / AMMUNITION_AIM120 initial warehouse stock = 52
BAGRAM / AMMUNITION_AIM9   initial warehouse stock = 26
```

Gesamtes mitgebrachtes Theaterinventar:

```text
AMMUNITION_AIM120 = 104 total theater inventory
AMMUNITION_AIM9   = 52 total theater inventory
```

`WAREHOUSE + FITTED` bilden jeweils ein endliches strategisches Theaterinventar. Verschossene oder mit einem Totalverlust des Aircraft verlorene Raketen reduzieren den Bestand dauerhaft. Normale Rückgabe oder Umlagerung verändert nur den Ort. Normaler automatischer Off-Map-Nachschub ist `NONE`.

Für den F-16-Deployment-AIM-9-Pfad ist jetzt technisch bestätigt:

```text
AMMUNITION_AIM9 -> weapons.missiles.AIM_9
mapping status = RUNTIME_MAPPING_VALIDATED
```

## 6. Externe F-15E-/F-16-Tanks

Verbindliche Klassifikation:

```text
F-15E external tank = TECHNICAL_NON_STRATEGIC
F-16C 370-gal external tank = TECHNICAL_NON_STRATEGIC
```

Daraus folgt:

```text
no CampaignState strategic resource
no strategic loss/depletion accounting
DCS/MOOSE STORAGE = operational technical availability only
no artificial AI normal-return recredit
```

## 7. Strategisches Mission Equipment

Folgende Pods werden als strategische, rückgabefähige Equipment-Ressourcen geführt:

```text
EQUIPMENT_AAQ13
EQUIPMENT_AAQ14
EQUIPMENT_AAQ33
EQUIPMENT_AAQ28
```

Mappings:

```text
EQUIPMENT_AAQ13 -> weapons.containers.F-15E_AAQ-13_LANTIRN
EQUIPMENT_AAQ14 -> weapons.containers.F-15E_AAQ-14_LANTIRN
EQUIPMENT_AAQ33 -> weapons.containers.AN_AAQ_33
EQUIPMENT_AAQ28 -> weapons.containers.AAQ-28_LITENING
```

Bestandsregel:

```text
operational requirement = 1 complete pod set per logical aircraft
reserve = +20%, rounded up to whole units
Initial = Target
Reorder = ceil(Target * 0.80)
Critical = ceil(Target * 0.60)
```

| Node | Resource | Initial | Target | Reorder | Critical |
|---|---|---:|---:|---:|---:|
| Bagram | `EQUIPMENT_AAQ13` | 16 | 16 | 13 | 10 |
| Bagram | `EQUIPMENT_AAQ14` | 16 | 16 | 13 | 10 |
| Bagram | `EQUIPMENT_AAQ33` | 16 | 16 | 13 | 10 |
| Kandahar Main | `EQUIPMENT_AAQ28` | 20 | 20 | 16 | 12 |

Equipment ist nodeweit gepoolt. Aircraft-/Payload-Zulässigkeit wird separat gemappt.

## 8. Mission-Equipment-Lifecycle

```text
normal return
-> equipment remains available

aircraft total loss with fitted equipment
-> fitted equipment is strategically lost

maintenance damage states
-> not modeled; CampaignState uses AVAILABLE / LOST only

authorized aircraft redeployment
-> fitted equipment moves to destination node with aircraft

replacement
-> normal configured logistics parent chain
-> no direct magical refill at forward nodes
```

Die 20-Prozent-Reserve ist Teil des dauerhaften Sollbestands.

Strategisches Mission Equipment ist eine harte Mission-/Payload-Verfügbarkeitsgrenze. Beim verbindlichen Mission-Commit wird die erforderliche Equipment-Menge strategisch reserviert. Cancel vor Issue/Materialisierung gibt die Reservation frei; normaler Return stellt das Equipment wieder zur Verfügung; Totalverlust wandelt die gebundene Menge in strategischen Verlust um.

Diese Entscheidung genehmigt keinen parallelen Aircraft-/Payload-Lifecycle. Eine produktive Implementierung muss die vorhandenen MOOSE-AIRWING-/WAREHOUSE-/FLIGHTGROUP-Pfade verwenden und nur die CampaignState-Reservation/Ergebnisgrenze ergänzen.

## 9. Verbindliche Datenartefakte

```text
OMW_AirOps_Logistics_Planning_v20.xlsx
data/logistics/air-operations-initial-store-stock-v20.csv
scripts/logistics/OMW_AirOpsResourceManifest.lua
```

Das CSV ist die maschinenlesbare Node-/Resource-Sicht für Initial/Target/Reorder/Critical. Das Workbook bewahrt die Herleitung nach Aircraft-/Payload-Profil, Deployment-Stores, Countermeasures, Pack-/Pair-Regeln und Evidenz.

## 10. Warehouse-/Resource-Foundation-Abschluss

Für den aktuellen Foundation-Scope sind damit abgeschlossen:

```text
CampaignState resource authority
STORAGE operational mirror boundary
fuel resource semantics
AI materialization observations
normal return semantics
client fuel/rearm behavior
selected weapon/store lifecycle mappings
physical loss semantics
forced-landing/recovery settlement semantics
restart/idempotency boundary
read-only reconciliation
initial/target/reorder/critical stock matrix
supply-parent topology
fixed-wing store mappings
fighter finite A/A inventory
external-tank exception policy
strategic mission-equipment stock policy
```

Status:

```text
WAREHOUSE_RESOURCE_FOUNDATION = CLOSED
```

Nicht als bereits DCS-validiert auszugeben sind zukünftige produktive Implementierungen eines schreibenden CampaignState-to-STORAGE-Initialisierungsadapters oder eines strategischen Equipment-Reservation-/Result-Adapters. Diese sind separate Implementierungsarbeit und **kein offener Warehouse-Planungs- oder Mapping-Testblock**. Sie dürfen die verabschiedeten Initialbestände nicht stillschweigend neu öffnen.
