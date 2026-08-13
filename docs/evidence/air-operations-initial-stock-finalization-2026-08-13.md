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
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unresolved F-15E/F-16 external-tank strategic classification in docs/ammunition-item-mapping-contract.md
  - per-profile final stock summation where the same physical resource is shared at one node
  - generic AMMUNITION_GBU31 / AMMUNITION_GBU31_PEN planning labels
  - generic AMMUNITION_ILLUMINATION planning label for the OMW LUU-2B path
superseded_by:
source_branch: agent/warehouse-resource-final-acceptance
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AirOps Initial-Stock Finalization – 13.08.2026

## 1. Abschlussstatus

Der Projektinhaber hat am 13.08.2026 die noch offenen Entscheidungen der AirOps-Initial-Stock-Planung abgeschlossen. Die strategische Initial-Stock-Matrix ist damit für den dokumentierten Foundation-Scope fachlich abgeschlossen.

Nicht blockierende technische Restgates bleiben:

```text
F-15E STRIKE GBU-31(V)1/B exact STORAGE runtime correlation
F-15E STRIKE GBU-31(V)3/B exact STORAGE runtime correlation
F-16 deployment AIM-9 exact DCS/MOOSE item correlation
```

Diese drei Mapping-Gates dürfen die beschlossenen strategischen Initialmengen nicht erneut öffnen. `VALIDATED` bleibt für die konkrete DCS-Warehouse-Initialisierung bis zu einem dokumentierten DCS-Lauf unzulässig.

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

Damit ist eine per Profil vorgenommene Pack-Rundung mit anschließender Addition für gemeinsam genutzte physische Stores nicht zulässig.

MOOSE `WAREHOUSE`-/AIRWING-Instanzen verwalten weiterhin Aircraft-/Asset-Lifecycle. Sie begründen keine separaten strategischen Munitionslager. CampaignState bleibt die strategische Ressourcenhoheit.

## 3. Fixed-Wing-Munitions-IDs

Für die abgedeckten Fixed-Wing-Stores gelten verbindlich:

```text
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

`AMMUNITION_GBU31_V1` und `AMMUNITION_GBU31_V3` bleiben auch strategisch getrennte physische Ressourcen.

## 4. F-15E STRIKE Mapping-Grenze

Die strategischen GBU-31-Bestände sind final. Die technisch plausiblen Kandidaten bleiben bis zum gezielten Runtime-Gate ausdrücklich unvalidiert:

```text
AMMUNITION_GBU31_V1
candidate STORAGE key = weapons.bombs.GBU_31
mapping status = UNVALIDATED_RUNTIME_MAPPING

AMMUNITION_GBU31_V3
candidate STORAGE key = weapons.bombs.GBU_31_V_3B
mapping status = UNVALIDATED_RUNTIME_MAPPING
```

Die Existenz der Keys im gepinnten `Moose.lua` und ihre Übereinstimmung mit dem Mission-Editor-Payload ersetzen keinen DCS-Runtime-Nachweis.

## 5. Bagram Fighter A/A

Der Vertrag `OMW-LOG-BAGRAM-FIGHTER-AA-DEPLOYMENT-STOCK` bleibt unverändert maßgeblich:

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

Für den F-16-Deployment-AIM-9-Pfad gilt weiterhin:

```text
strategic initial warehouse stock = FINAL
DCS/MOOSE item = UNRESOLVED_F16_DEPLOYMENT_ITEM
runtime mapping = UNVALIDATED
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

Der bekannte Runtime-Befund `spawn debit / no AI normal-return recredit` wird nicht durch eine parallele OMW-Rückbuchungslogik kompensiert.

## 7. Strategisches Mission Equipment

Folgende Pods werden als strategische, rückgabefähige Equipment-Ressourcen geführt:

```text
EQUIPMENT_AAQ13
EQUIPMENT_AAQ14
EQUIPMENT_AAQ33
EQUIPMENT_AAQ28
```

Physische Mappings im aktuellen dokumentierten Scope:

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

Daraus folgen für den aktuellen ORBAT-Scope:

| Node | Resource | Initial | Target | Reorder | Critical |
|---|---|---:|---:|---:|---:|
| Bagram | `EQUIPMENT_AAQ13` | 16 | 16 | 13 | 10 |
| Bagram | `EQUIPMENT_AAQ14` | 16 | 16 | 13 | 10 |
| Bagram | `EQUIPMENT_AAQ33` | 16 | 16 | 13 | 10 |
| Kandahar Main | `EQUIPMENT_AAQ28` | 20 | 20 | 16 | 12 |

Equipment ist nodeweit gepoolt. Aircraft-/Payload-Zulässigkeit wird separat gemappt und erzeugt keinen Aircraft-Type- oder Squadron-eigenen Bestand.

## 8. Mission-Equipment-Lifecycle

Für die strategische Domain gilt:

```text
normal return
-> equipment remains available

aircraft total loss with fitted equipment
-> fitted equipment is strategically lost

maintenance damage states
-> not modeled; CampaignState uses AVAILABLE / LOST only

authorized aircraft redeployment
-> fitted equipment moves to the destination node with the aircraft

replacement
-> normal configured logistics parent chain
-> no direct magical refill at forward nodes
```

Die 20-Prozent-Reserve ist Teil des dauerhaften Sollbestands und kein einmaliger Startbonus.

Strategisches Mission Equipment ist eine harte Mission-/Payload-Verfügbarkeitsgrenze. Beim verbindlichen Mission-Commit wird die erforderliche Equipment-Menge strategisch reserviert. Cancel vor Issue/Materialisierung gibt die Reservation frei; normaler Return stellt das Equipment wieder zur Verfügung; Totalverlust wandelt die gebundene Menge in strategischen Verlust um.

Diese Entscheidung genehmigt noch keinen neuen parallelen Aircraft-/Payload-Lifecycle. Eine produktive Implementierung muss die vorhandenen MOOSE-AIRWING-/WAREHOUSE-/FLIGHTGROUP-Pfade verwenden und nur die CampaignState-Reservation/Ergebnisgrenze ergänzen.

## 9. Verbindliche Datenartefakte

Die finalisierte Planungsmatrix wird durch folgende Artefakte repräsentiert:

```text
OMW_AirOps_Logistics_Planning_v20.xlsx (planning workbook artifact; SHA-256 441e7b15a43fdf6a0c956a60fdcda8b4c42b525a1383607447c53725e8f7ae9b)
data/logistics/air-operations-initial-store-stock-v20.csv
```

Das CSV ist die im Repository geführte maschinenlesbare Node-/Resource-Sicht für Initial/Target/Reorder/Critical. Das separat erzeugte Workbook bewahrt die Herleitung nach Aircraft-/Payload-Profil, Deployment-Stores, Countermeasures, Pack-/Pair-Regeln und Evidenz.

## 10. Acceptance-Grenze

Mit dieser Entscheidung ist der fachliche Initial-Stock-Entscheidungsblock `CLOSED`.

Noch nicht DCS-validiert sind:

```text
physical initialization of all final DCS warehouse items
F-15E STRIKE GBU-31(V)1 runtime key correlation
F-15E STRIKE GBU-31(V)3 runtime key correlation
F-16 deployment AIM-9 runtime key correlation
strategic mission-equipment reservation/result integration with AIRWING lifecycle
```

Diese technischen Gates sind Folgeschritte. Sie ändern die hier freigegebenen strategischen Initialmengen nur dann, wenn der Projektinhaber aufgrund neuer Evidenz ausdrücklich eine neue Stock-Entscheidung trifft.
