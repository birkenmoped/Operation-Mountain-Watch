---
document_id: OMW-ARMY-GROUND-RESOURCE-READINESS-CONTRACT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned resource-class contract for the current ARMY Ground Foundation root Ground Nodes
  - planned CampaignState readiness semantics derived from ground resource availability
  - planned supply-loss effects on patrol, QRF, defense, child occupancy and fire-support capability
not_authoritative_for:
  - final resource quantities or numeric thresholds
  - final historical company or platoon strengths
  - final MOOSE BRIGADE or PLATOON topology
  - final DCS templates or artillery proxies
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Ressourcen- und Readiness-Vertrag

## 1. Zweck

Dieses Dokument setzt die nächsten beiden Phase-D-Schritte der ARMY Ground Foundation um:

```text
1. Personnel / Vehicle / Supply / Ammo / Fuel contracts per root Ground Node
2. resource loss / resupply failure -> readiness / patrol / QRF / defense effects
```

Die strategische Ressourcenautorität bleibt ausschließlich `CampaignState`.

```text
CampaignState resource contract
-> reservation / transfer / settlement
-> optional MOOSE / DCS representation
-> observed result
-> CampaignState settlement
```

MOOSE `BRIGADE`, `PLATOON`, `WAREHOUSE`, `ARMYGROUP`, `OPSTRANSPORT`, CTLD und DCS Warehouses dürfen diese Bestände nicht unabhängig erzeugen, erhöhen oder zurückbuchen.

Dieses Dokument definiert zunächst **Ressourcenklassen, Capability-Abhängigkeiten und Zustandssemantik**. Exakte Mengen und numerische Schwellen bleiben Owner-Entscheidungen und werden nicht aus historischen Battalion-/Company-Bezeichnungen geraten.

## 2. Strategische Ressourcenklassen

Für jeden Root Ground Node gelten folgende CampaignState-Ressourcenklassen:

```text
PERSONNEL
VEHICLE
SUPPLY
AMMO
FUEL
```

### 2.1 `PERSONNEL`

Repräsentiert strategisch verfügbares und bindbares Personal für:

- lokale Base-/FOB-/COP-Verteidigung;
- Patrols;
- QRF;
- OP-/COP-Besatzungen;
- Escort-/Security-Aufgaben;
- gegebenenfalls Fire-Support-Crews, sofern der entsprechende Capability-Vertrag aktiv ist.

`PERSONNEL` ist keine direkte Zählung sichtbarer DCS-Infanteristen. Eine physische Gruppe kann eine strategische Personnel-Reservation repräsentieren, ohne dass jedes DCS-Modell eine einzelne persistente Person abbildet.

### 2.2 `VEHICLE`

Repräsentiert einsatzfähige Ground-Mobility-/Support-Fahrzeuge eines Nodes.

Abhängig davon können insbesondere sein:

- motorisierte Patrols;
- Ground-QRF;
- lokale Convoy-/Escort-Aufgaben;
- OP-/COP-Reinforcement;
- Ground-Resupply.

Konkrete Fahrzeugfamilien und DCS-Typen werden separat festgelegt. `VEHICLE` ist deshalb zunächst eine strategische Klasse, kein DCS-Type-Name.

### 2.3 `SUPPLY`

Repräsentiert allgemeine Verbrauchs- und Sustainment-Güter, die nicht bereits als `AMMO` oder `FUEL` getrennt geführt werden.

Dazu gehören im Ground-Foundation-Vertrag insbesondere:

- Verpflegung/Wasser und allgemeine Versorgung;
- Ersatz-/Verbrauchsmaterial;
- lokale Sustainment-Bindung für abhängige Stellungen;
- nicht weiter spezifizierte Ground-Logistikgüter.

`SUPPLY` wirkt primär auf **Sustainment und dauerhafte Readiness**, nicht als unmittelbarer Ersatz für Munition oder Treibstoff.

### 2.4 `AMMO`

Repräsentiert strategisch verfügbare Ground-Munition für:

- Base Defense;
- Patrol/QRF;
- Crew-served weapons;
- Mortar-/Artillery-/Fire-Support, soweit der Node dafür eine genehmigte Capability besitzt.

Historische M777-Evidenz erzeugt nicht automatisch einen aktiven DCS-Artillerievertrag. Fire-Support-Ammo wird nur dort operativ genutzt, wo Capability und technischer Proxy beziehungsweise historisches System separat freigegeben sind.

### 2.5 `FUEL`

Repräsentiert Ground-Fuel für:

- Fahrzeuge;
- Ground-QRF;
- Patrols;
- Convoys/Resupply;
- lokale Generator-/Sustainment-Anteile, soweit später erforderlich.

Aviation-Fuel und Ground-Fuel dürfen technisch getrennte Resource IDs erhalten. Dieses Dokument definiert ausschließlich den Ground-Foundation-Vertrag.

## 3. Resource IDs pro Root Ground Node

Stabile Resource IDs werden aus der stabilen Ground-Node-Domain-ID abgeleitet, nicht aus DCS- oder MOOSE-Namen.

Schema:

```text
GROUND:<groundNodeId>:<resourceClass>
```

Aktueller Scope:

```text
GROUND:GROUND_NODE_JALALABAD:PERSONNEL
GROUND:GROUND_NODE_JALALABAD:VEHICLE
GROUND:GROUND_NODE_JALALABAD:SUPPLY
GROUND:GROUND_NODE_JALALABAD:AMMO
GROUND:GROUND_NODE_JALALABAD:FUEL

GROUND:GROUND_NODE_JOYCE:PERSONNEL
GROUND:GROUND_NODE_JOYCE:VEHICLE
GROUND:GROUND_NODE_JOYCE:SUPPLY
GROUND:GROUND_NODE_JOYCE:AMMO
GROUND:GROUND_NODE_JOYCE:FUEL

GROUND:GROUND_NODE_WRIGHT:PERSONNEL
GROUND:GROUND_NODE_WRIGHT:VEHICLE
GROUND:GROUND_NODE_WRIGHT:SUPPLY
GROUND:GROUND_NODE_WRIGHT:AMMO
GROUND:GROUND_NODE_WRIGHT:FUEL

GROUND:GROUND_NODE_BOSTICK:PERSONNEL
GROUND:GROUND_NODE_BOSTICK:VEHICLE
GROUND:GROUND_NODE_BOSTICK:SUPPLY
GROUND:GROUND_NODE_BOSTICK:AMMO
GROUND:GROUND_NODE_BOSTICK:FUEL
```

Die IDs definieren die strategische Buchungsadresse. Sie definieren noch keine Menge.

## 4. Root-Node-Verträge

### 4.1 Jalalabad / Fenty

```yaml
groundNodeId: GROUND_NODE_JALALABAD
rootInstallationId: BLUE_GROUND_HUB_JALALABAD_FENTY
resources:
  PERSONNEL: { quantity: OWNER_DECISION_REQUIRED }
  VEHICLE:   { quantity: OWNER_DECISION_REQUIRED }
  SUPPLY:    { quantity: OWNER_DECISION_REQUIRED }
  AMMO:      { quantity: OWNER_DECISION_REQUIRED }
  FUEL:      { quantity: OWNER_DECISION_REQUIRED }
capabilities:
  BASE_DEFENSE: ACTIVE_CONTRACT
  PATROL: ACTIVE_CONTRACT
  QRF: ACTIVE_CONTRACT
  LOGISTICS: ACTIVE_CONTRACT
  FIRE_SUPPORT: ACTIVE_CONTRACT
```

`FIRE_SUPPORT` ist aufgrund des Juli-2011-Kontexts `TF Steel / 3-7 FA` als Node-Capability zulässig. Die konkrete Artillerie-/Mörser-Template- oder Waffenabbildung ist dadurch nicht festgelegt.

### 4.2 Joyce

```yaml
groundNodeId: GROUND_NODE_JOYCE
rootInstallationId: BLUE_GROUND_FOB_JOYCE
resources:
  PERSONNEL: { quantity: OWNER_DECISION_REQUIRED }
  VEHICLE:   { quantity: OWNER_DECISION_REQUIRED }
  SUPPLY:    { quantity: OWNER_DECISION_REQUIRED }
  AMMO:      { quantity: OWNER_DECISION_REQUIRED }
  FUEL:      { quantity: OWNER_DECISION_REQUIRED }
capabilities:
  BASE_DEFENSE: ACTIVE_CONTRACT
  PATROL: ACTIVE_CONTRACT
  QRF: ACTIVE_CONTRACT
  LOGISTICS: ACTIVE_CONTRACT
  FIRE_SUPPORT: ACTIVE_CONTRACT
children:
  - BLUE_GROUND_COP_HONAKER_MIRACLE
  - BLUE_GROUND_OP_JOJO
```

Für Honaker-Miracle ist am 30.07.2011 C Battery / 3-321 FA mit zwei M777A2 belegt. Deshalb darf der Joyce-Node Fire-Support-Ressourcen an Honaker binden. Das ist keine Festlegung eines DCS-M777-Proxys.

`BLUE_GROUND_OP_JOJO` bleibt nur als reservierte Identität geführt. Solange seine Aktivierung nicht genehmigt ist, darf er keine aktive Occupancy-Reservation erzeugen.

### 4.3 Wright

```yaml
groundNodeId: GROUND_NODE_WRIGHT
rootInstallationId: BLUE_GROUND_FOB_WRIGHT
resources:
  PERSONNEL: { quantity: OWNER_DECISION_REQUIRED }
  VEHICLE:   { quantity: OWNER_DECISION_REQUIRED }
  SUPPLY:    { quantity: OWNER_DECISION_REQUIRED }
  AMMO:      { quantity: OWNER_DECISION_REQUIRED }
  FUEL:      { quantity: OWNER_DECISION_REQUIRED }
capabilities:
  BASE_DEFENSE: ACTIVE_CONTRACT
  PATROL: ACTIVE_CONTRACT
  QRF: ACTIVE_CONTRACT
  LOGISTICS: ACTIVE_CONTRACT
  FIRE_SUPPORT: PENDING_JULY_2011_ASSIGNMENT
```

Wright erhält `AMMO` als allgemeine Ground-Munitionsklasse für Security/Base Defense. Eine eigenständige Juli-2011-Artillerie-Capability wird **nicht** aktiviert, solange die exakte Artilleriezuordnung offen ist.

### 4.4 Bostick

```yaml
groundNodeId: GROUND_NODE_BOSTICK
rootInstallationId: BLUE_GROUND_FOB_BOSTICK
resources:
  PERSONNEL: { quantity: OWNER_DECISION_REQUIRED }
  VEHICLE:   { quantity: OWNER_DECISION_REQUIRED }
  SUPPLY:    { quantity: OWNER_DECISION_REQUIRED }
  AMMO:      { quantity: OWNER_DECISION_REQUIRED }
  FUEL:      { quantity: OWNER_DECISION_REQUIRED }
capabilities:
  BASE_DEFENSE: ACTIVE_CONTRACT
  PATROL: ACTIVE_CONTRACT
  QRF: ACTIVE_CONTRACT
  LOGISTICS: ACTIVE_CONTRACT
  FIRE_SUPPORT: PENDING_JULY_2011_ASSIGNMENT
children:
  - BLUE_GROUND_OP_MUSTANG
  - BLUE_GROUND_OP_CLYDESDALE
  - BLUE_GROUND_OP_STALLION
```

Der 2010er M777-/3-321-Nachweis wird nicht automatisch in eine aktive Juli-2011-Fire-Support-Capability übertragen. `AMMO` bleibt dennoch als allgemeine Ground-Munitionsklasse erforderlich.

## 5. Child-Installationen besitzen keinen Root-Vertrag

Abhängige COPs/OPs erhalten grundsätzlich keinen eigenen unabhängigen Gesamtbestand der fünf Root-Ressourcenklassen.

```text
child requirement
-> reservation / transfer from parent node
-> physical representation
-> confirmed consumption, loss or return
-> CampaignState settlement
```

Mögliche gebundene Child-Resource-Records sind beispielsweise:

```text
GROUND-OCCUPANCY:<childInstallationId>:PERSONNEL
GROUND-OCCUPANCY:<childInstallationId>:VEHICLE
GROUND-TRANSFER:<transferId>:SUPPLY
GROUND-TRANSFER:<transferId>:AMMO
GROUND-TRANSFER:<transferId>:FUEL
```

Damit bleibt insbesondere die bereits beschlossene OP-Parent-Regel erhalten.

## 6. Readiness-Modell

### 6.1 Readiness ist abgeleitet, nicht eigener Bestand

`Readiness` ist kein separat auffüllbarer strategischer Rohstoff. Sie wird aus Ressourcenverfügbarkeit, aktiven Bindungen, Schäden und Capability-Zuständen abgeleitet.

Pro Node werden mindestens folgende Capability-Readiness-Werte vorgesehen:

```text
DEFENSE_READINESS
PATROL_READINESS
QRF_READINESS
LOGISTICS_READINESS
FIRE_SUPPORT_READINESS
CHILD_SUPPORT_READINESS
```

Die numerische Berechnungsfunktion und Schwellen bleiben offen, bis die Resource Quantities beschlossen sind.

### 6.2 Zustände

Für jede Capability gilt die gemeinsame Zustandsmenge:

```text
AVAILABLE
CONSTRAINED
CRITICAL
UNAVAILABLE
```

Semantik:

```text
AVAILABLE
-> normal MissionDemand eligibility subject to reservations and local conditions

CONSTRAINED
-> capability remains usable
-> new commitments require explicit availability check
-> lower-priority demand may be deferred

CRITICAL
-> only essential defensive / recovery / sustainment commitments are eligible
-> routine offensive or discretionary patrol demand is blocked

UNAVAILABLE
-> no new mission requiring this capability may be materialized
-> existing physical groups remain physical and are settled normally
```

Der Zustand selbst erzeugt keinen Despawn und keine automatische Rückgabe bereits materialisierter Gruppen.

## 7. Ressourcenabhängigkeit der Capabilities

Qualitative Baseline:

| Capability | PERSONNEL | VEHICLE | SUPPLY | AMMO | FUEL |
|---|---|---|---|---|---|
| Base Defense | required | supporting | sustainment | required | supporting |
| Foot Patrol | required | optional | sustainment | required | optional |
| Motorized Patrol | required | required | sustainment | required | required |
| Ground QRF | required | required | supporting | required | required |
| Ground Logistics / Resupply | required | required | payload | supporting | required |
| Child Occupancy Support | required | supporting | required | required | supporting |
| Fire Support | crew-required | system-dependent | sustainment | required | system-dependent |

`required`, `supporting`, `optional`, `payload`, `sustainment` sind Domain-Beziehungen und keine Gewichtungsfaktoren.

## 8. Nachschubverlust und Capability-Auswirkung

### 8.1 Grundregel

Ein verlorener oder nicht zugestellter Nachschub reduziert ausschließlich die strategischen Ressourcen, die durch den bestätigten Transfer-/Loss-Settlement tatsächlich betroffen sind.

```text
convoy / transport loss
-> settle reserved transfer as LOST
-> no delivery credit
-> parent/child resource position remains reduced by the committed quantity
-> recalculate affected capability readiness
```

Ein DCS-Fahrzeugverlust allein darf nicht pauschal fünf Ressourcenklassen reduzieren. Maßgeblich ist das zugehörige Cargo-/Reservation-/Manifest-Objekt.

### 8.2 Auswirkung auf Patrols

```text
PERSONNEL or AMMO degraded
-> patrol readiness degrades

VEHICLE or FUEL degraded
-> motorized patrol readiness degrades before foot-patrol capability

SUPPLY degraded
-> sustained patrol generation degrades over the contract horizon
```

Bei `CRITICAL` Patrol Readiness werden neue routinemäßige Patrol-Demands nicht materialisiert. Bereits im Feld befindliche Gruppen werden nicht deswegen automatisch entfernt.

### 8.3 Auswirkung auf QRF

Ground-QRF benötigt gleichzeitig:

```text
PERSONNEL
VEHICLE
AMMO
FUEL
```

Fehlt eine davon bis zum Zustand `UNAVAILABLE`, darf kein neuer Ground-QRF-MissionDemand materialisiert werden.

Bei `CRITICAL` QRF Readiness bleibt QRF ausschließlich für priorisierte defensive/recovery-nahe Demands reserviert. Routine-Patrol oder nichtkritische Escort-Aufträge dürfen QRF-Ressourcen dann nicht verbrauchen.

### 8.4 Auswirkung auf Base Defense

Base Defense hängt primär von `PERSONNEL` und `AMMO` ab. `SUPPLY` wirkt auf die Dauerhaltefähigkeit; `VEHICLE` und `FUEL` beeinflussen lokale Reaktion und mobile Verstärkung.

```text
DEFENSE_READINESS = CRITICAL
-> no discretionary personnel release to new patrols
-> no nonessential child reinforcement if it would violate local defense reservation

DEFENSE_READINESS = UNAVAILABLE
-> node remains a physical installation
-> CampaignState marks defense capability unavailable
-> no synthetic defenders are spawned to restore strength
```

Ein niedriger Defense-State darf die Installation nicht automatisch zerstören oder kampflos umschalten. Capture-/Damage-/Loss-Settlement ist ein separater Vertrag.

### 8.5 Auswirkung auf Child Occupancy und Reinforcement

Child-Occupancy-Reservations bleiben gebunden, solange die Stellung aktiv besetzt ist.

Sinkt `CHILD_SUPPORT_READINESS`, gilt:

```text
CONSTRAINED
-> existing child occupancy remains
-> new reinforcement requires explicit reservation check

CRITICAL
-> no discretionary increase of child occupancy
-> resupply/recovery/withdrawal demands may outrank expansion

UNAVAILABLE
-> no new child reinforcement may be materialized
-> existing child garrison is not silently despawned
```

Eine Räumung oder Aufgabe eines OP/COP benötigt einen expliziten MissionDemand-/CampaignState-Entscheidungspfad.

### 8.6 Auswirkung auf Fire Support

Fire Support benötigt mindestens:

```text
approved local FIRE_SUPPORT capability
PERSONNEL / crew availability
AMMO
required weapon-system availability
```

Bei motorisierten/self-propelled Systemen kann zusätzlich `FUEL` erforderlich sein.

```text
FIRE_SUPPORT_READINESS = CRITICAL
-> fire missions restricted to owner-approved priority policy later

FIRE_SUPPORT_READINESS = UNAVAILABLE
-> no new Fire-Support AUFTRAG / MissionDemand materialization
```

Für Wright und Bostick bleibt der Fire-Support-Capability-Status zunächst `PENDING_JULY_2011_ASSIGNMENT`. Das Readiness-Modell aktiviert dort keine Artillerie durch bloße Ammo-Verfügbarkeit.

## 9. MissionDemand-Gate

Vor jeder Ground-Materialisierung muss die Domain-Sequenz mindestens sein:

```text
MissionDemand candidate
-> resolve required Ground Node capability
-> check capability contract active
-> check readiness state
-> reserve exact CampaignState resources
-> only then call MOOSE selection/materialization
```

Unzulässig:

```text
MOOSE selects/spawns an asset
-> afterwards invent or backfill CampaignState resources
```

Damit bleibt `CampaignState` auch bei `BRIGADE`/`PLATOON`-Assetselektion autoritativ.

## 10. Anti-Doppelhoheitsregel

Für jede strategische Ressource existiert genau eine CampaignState-Buchung.

```text
CampaignState quantity
= strategic authority

MOOSE WAREHOUSE / BRIGADE asset count
= operational availability representation only

DCS Warehouse / physical cargo / group state
= physical representation / telemetry only
```

Insbesondere gilt:

```text
MOOSE AddAsset != strategic credit
MOOSE Returned != strategic release until CampaignState settlement confirms it
DCS Despawn != strategic return
DCS Destroy != automatically strategic loss class/quantity
CTLD delivery != strategic credit until delivery settlement is accepted
```

Die spätere Runtime benötigt Adapter, die genau diese einseitige Autoritätsgrenze einhalten.

## 11. Quantitative Owner-Gates

Für die nächste Quantifizierungsstufe sind weiterhin Entscheidungen beziehungsweise belastbare Baselines nötig:

```text
- initial PERSONNEL quantity per root Ground Node
- initial VEHICLE quantity / vehicle-class split per root Ground Node
- initial SUPPLY quantity and unit
- initial AMMO quantity/unit and any weapon-class split
- initial Ground FUEL quantity/unit
- reservation costs per Patrol / QRF / Child Occupancy / Fire Support action
- numeric AVAILABLE / CONSTRAINED / CRITICAL / UNAVAILABLE thresholds
- minimum protected Base-Defense reserve per node
```

Diese Werte werden nicht aus nomineller Battalion-/Company-Stärke oder DCS-Templategröße automatisch abgeleitet.

## 12. Aktueller Ergebnisstand

Mit diesem Vertrag sind folgende Phase-D-Fragen fachlich strukturiert:

```text
DONE AT CONTRACT LEVEL
- resource classes per current root Ground Node
- stable strategic Resource IDs
- child resources remain parent-bound
- capability-to-resource dependency model
- resupply/loss -> readiness semantics
- patrol/QRF/defense/child-support/fire-support gating semantics
- CampaignState -> MOOSE/DCS single-authority boundary

STILL OPEN
- exact quantities
- exact numeric thresholds
- exact action costs
- DCS/MOOSE runtime implementation and acceptance
```
