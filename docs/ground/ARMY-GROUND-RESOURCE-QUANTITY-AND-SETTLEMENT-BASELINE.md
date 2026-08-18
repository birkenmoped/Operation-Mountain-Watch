---
document_id: OMW-ARMY-GROUND-RESOURCE-QUANTITY-SETTLEMENT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working CampaignState quantities for the current Jalalabad/Kunar ARMY Ground Foundation nodes
  - working action costs and readiness thresholds for ground resources
  - planned installation-damage to CampaignState settlement semantics
  - explicit one-way authority boundary between CampaignState and MOOSE/DCS warehouse representations
not_authoritative_for:
  - exact historical July-2011 property-book inventories or personnel rosters
  - final Mission Editor object counts
  - final DCS proxy behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Resource Quantity and Settlement Baseline

## 1. Zweck

Die Ground Foundation benötigt konkrete CampaignState-Mengen, obwohl vollständige historische lokale Inventare nicht vorliegen. Dieses Dokument setzt deshalb bewusst **OMW-Designwerte** auf Basis der bereits festgelegten Fahrzeugbaseline, Standortrollen, Formationseinordnung, Parent-Hierarchie und der bisherigen Evidenz.

Die Werte sind keine Behauptung exakter historischer Property-Book- oder Personnel-Roster-Zahlen.

```text
historical evidence
-> supported role / scale
-> OMW working quantity
-> CampaignState authority
-> MOOSE/DCS operational representation
```

## 2. Einheitensystem

### 2.1 PERSONNEL

`PERSONNEL` wird als reale strategische Personenzahl geführt. Die Zahl beschreibt den für Ground-Operations, lokale Sicherung, QRF, Patrol, Logistics und Child-Support verfügbaren OMW-Pool des Nodes; sie ist **nicht** die vollständige historische Basisbevölkerung einschließlich aller Aviation-, Contractor-, Medical-, Staff- oder sonstigen nicht für Ground-Tasking verfügbaren Personen.

### 2.2 VEHICLE

`VEHICLE` wird als einzelne strategische Fahrzeugeinheit geführt. Die Menge entspricht der Working Vehicle Baseline:

```text
Jalalabad / Fenty = 48
Joyce             = 20
Wright            = 22
Bostick           = 26
```

Die Fahrzeugfamilien stehen in `OMW-ARMY-GROUND-VEHICLE-BASELINE` und `OMW-ARMY-GROUND-TEMPLATE-NAMING-TYPE-MAPPING`.

### 2.3 SUPPLY, AMMO, FUEL

Um unbelegte Tonnen- oder Literbestände zu vermeiden, werden diese Ressourcen als **normalized logistics units** geführt:

```text
1 SUPPLY_UNIT = one normalized general sustainment package
1 AMMO_UNIT   = one normalized ground-ammunition package
1 FUEL_UNIT   = one normalized ground-fuel package
```

Diese Units sind CampaignState-Buchungseinheiten. Eine spätere Mission kann ein Paket auf konkrete Cargo-/Truck-Kapazität abbilden, ohne rückwirkend eine historisch exakte Tonnage zu behaupten.

## 3. Working initial quantities

### 3.1 Jalalabad / FOB Fenty

```yaml
groundNodeId: GROUND_NODE_JALALABAD
resources:
  PERSONNEL: 480
  VEHICLE: 48
  SUPPLY: 120
  AMMO: 100
  FUEL: 120
```

Begründung:

- regionaler Ground-/Logistics-Hub;
- Brigade-HQ-/Security-Kontext;
- größter lokaler Fahrzeugpool;
- regionaler Parent für Joyce, Wright und Bostick;
- zusätzlicher Nachschub von Bagram sowie Pakistan/Torkham-GLOC.

`480 PERSONNEL` ist ein OMW-verfügbarer Ground-Pool, nicht die Gesamtstärke aller real auf Jalalabad/Fenty befindlichen Kräfte.

### 3.2 FOB Joyce

```yaml
groundNodeId: GROUND_NODE_JOYCE
resources:
  PERSONNEL: 180
  VEHICLE: 20
  SUPPLY: 48
  AMMO: 44
  FUEL: 40
```

Begründung:

- TF-Cacti-/2-35-Infantry-Knoten;
- Patrol/QRF/Logistics;
- Parent für Honaker-Miracle;
- Fire-Support-Sustainment für die auf Honaker bestätigten zwei M777A2.

### 3.3 FOB Wright

```yaml
groundNodeId: GROUND_NODE_WRIGHT
resources:
  PERSONNEL: 120
  VEHICLE: 22
  SUPPLY: 36
  AMMO: 30
  FUEL: 36
```

Begründung:

- SECFOR-/PRT-/Support-Knoten;
- signifikante geschützte Mobilität;
- kein bestätigtes Juli-2011-Artillerie-Detachment im aktuellen Vertrag.

### 3.4 FOB Bostick

```yaml
groundNodeId: GROUND_NODE_BOSTICK
resources:
  PERSONNEL: 220
  VEHICLE: 26
  SUPPLY: 56
  AMMO: 52
  FUEL: 48
```

Begründung:

- Battalion-/Task-Force-Knoten;
- hoher Patrol-/QRF-Bedarf;
- direkte Parent-Verantwortung für Mustang, Clydesdale und Stallion;
- Recovery-/Logistics-Capability.

## 4. Dependent installation personnel commitments

### 4.1 COP Honaker-Miracle

Honaker besitzt keinen unabhängigen Root-Pool. Für die Working Baseline wird eine lokale Personnel-Bindung aus Joyce vorgesehen:

```yaml
childInstallationId: BLUE_GROUND_COP_HONAKER_MIRACLE
parentInstallationId: BLUE_GROUND_FOB_JOYCE
PERSONNEL_nominal: 40
PERSONNEL_source: GROUND_NODE_JOYCE
```

Die zwei M777A2 sind physischer Fire-Support-Bestand; Crew-/Security-Personal ist in dieser 40-Personen-Bindung enthalten. Supply/Ammo/Fuel dürfen für den COP separat aus Joyce transferiert werden, weil Honaker als sustained COP behandelt wird.

### 4.2 Bostick OPs

Für die drei geplanten Bostick-OPs wird je eine kleine Personnel-Occupancy vorgesehen:

```text
OP Mustang     nominal PERSONNEL = 12
OP Clydesdale  nominal PERSONNEL = 12
OP Stallion    nominal PERSONNEL = 12
```

Gesamtbindung bei vollständiger Besetzung:

```text
Bostick child OP occupancy = 36 PERSONNEL
```

Routine-AMMO/SUPPLY/FOOD/WATER werden für OPs weiterhin abstrahiert. Es gibt keinen unabhängigen OP-VEHICLE-, FUEL- oder Warehouse-Vertrag.

### 4.3 OP JoJo

```text
nominal PERSONNEL candidate = 12
activation = PROVISIONAL
active reservation = 0 until owner activates the OP
```

Damit erzeugt die reservierte Identität noch keinen Ressourcenverbrauch.

## 5. Protected local defense reserve

Nicht der gesamte Personnel-/Vehicle-Pool darf für MissionDemand freigegeben werden. Pro Root Node bleibt folgende Mindestreserve geschützt:

| Node | Personnel reserve | Vehicle reserve | Ammo reserve | Fuel reserve |
|---|---:|---:|---:|---:|
| Jalalabad | 120 | 10 | 25 | 20 |
| Joyce | 48 | 4 | 12 | 8 |
| Wright | 36 | 4 | 10 | 8 |
| Bostick | 60 | 5 | 14 | 10 |

MissionDemand darf eine neue offensive/routinemäßige Mission nicht reservieren, wenn dadurch die jeweilige lokale Defense Reserve unterschritten würde.

Child-Occupancy-Reservations zählen als gebunden und reduzieren den frei disponiblen Personnel-Pool.

## 6. Working action costs

Die Kosten sind CampaignState-Reservierungen pro gleichzeitigem Auftrag. Verbrauch und Rückgabe werden erst durch den jeweiligen Mission-/Loss-/Return-Settlement entschieden.

### 6.1 Motorized Patrol

```yaml
PERSONNEL: 12
VEHICLE: 4
SUPPLY: 1
AMMO: 2
FUEL: 2
```

### 6.2 Ground QRF

```yaml
PERSONNEL: 16
VEHICLE: 4
SUPPLY: 1
AMMO: 3
FUEL: 3
```

### 6.3 Local Logistics / Resupply Convoy

```yaml
PERSONNEL: 6
VEHICLE: 2
SUPPLY: payload-defined
AMMO: payload-defined
FUEL: 2 plus payload-defined fuel transfer
```

### 6.4 OP personnel reinforcement

```yaml
PERSONNEL: requested replacement count
VEHICLE: transport-method dependent
SUPPLY: 0
AMMO: 0
FUEL: transport-method dependent
```

Die OP-Ressource selbst ist ausschließlich `PERSONNEL`; Fahrzeug/Fuel gehören gegebenenfalls zum Parent-Transportauftrag und werden nicht dem OP gutgeschrieben.

### 6.5 Honaker Fire Support

Für einen Fire-Support-Auftrag wird kein Geschütz neu materialisiert. Die zwei Geschütze sind fixed physical assets.

Working reservation per fire mission:

```yaml
PERSONNEL: 0 additional if crew already committed to Honaker occupancy
VEHICLE: 0
SUPPLY: 0
AMMO: 2
FUEL: 0
```

Die spätere DCS-Acceptance kann den Ammo-Kostensatz kalibrieren, wenn tatsächliche Schusszahlen/Proxyverhalten bekannt sind.

## 7. Numeric readiness thresholds

Readiness wird pro Ressource aus dem Verhältnis `available / initial` abgeleitet. Bereits gebundene Ressourcen gelten nicht als `available`.

```text
AVAILABLE     >= 60%
CONSTRAINED   >= 35% and < 60%
CRITICAL      > 0% and < 35%
UNAVAILABLE   = 0% or required minimum cannot be met
```

Für eine Capability gilt der **schlechteste Zustand ihrer required resources** als Baseline-State. Supporting-/Sustainment-Ressourcen dürfen den State um höchstens eine Stufe verschlechtern, wenn sie unter `CRITICAL` fallen.

Zusätzlich gilt immer der harte Action-Cost-/Defense-Reserve-Test:

```text
percentage says AVAILABLE
but mission cost would violate protected reserve
-> mission is NOT ELIGIBLE
```

Damit vermeiden Prozentwerte unrealistische Freigaben kleiner Restmengen.

## 8. Capability-specific gates

### 8.1 PATROL

Required:

```text
PERSONNEL
AMMO
```

Motorized additionally:

```text
VEHICLE
FUEL
```

`CRITICAL` blockiert routinemäßige neue Patrols.

### 8.2 QRF

Required:

```text
PERSONNEL
VEHICLE
AMMO
FUEL
```

Bei `CRITICAL` bleibt QRF nur für defensive/recovery-nahe Prioritätsfälle zulässig, sofern Action Cost und Defense Reserve trotzdem eingehalten werden.

### 8.3 LOGISTICS

Required:

```text
PERSONNEL
VEHICLE
FUEL
```

Payload-Ressource muss zusätzlich in der zu transferierenden Menge verfügbar sein.

### 8.4 CHILD SUPPORT

Für OP-Reinforcement required:

```text
PERSONNEL
```

Für Honaker-Sustainment zusätzlich die konkret transferierte Resource Class.

### 8.5 FIRE SUPPORT

Required:

```text
approved physical fire-support system
committed crew/occupancy
AMMO
```

Wright und Bostick bleiben ohne aktive Juli-2011-Fire-Support-Capability, bis eine separate Entscheidung das ändert.

## 9. Installation damage -> CampaignState settlement

### 9.1 Grundregel

Physischer DCS-Schaden ist zunächst **Telemetry/Evidence**, nicht automatisch eine strategische Buchung.

```text
DCS hit / destroy event
-> correlate physical object to stable installation/resource representation
-> classify damage/loss
-> create idempotent settlement record
-> apply CampaignState mutation exactly once
-> recalculate readiness
```

### 9.2 Settlement classes

```text
DAMAGE_INFRASTRUCTURE
LOSS_PERSONNEL
LOSS_VEHICLE
LOSS_FIRE_SUPPORT_SYSTEM
LOSS_SUPPLY
LOSS_AMMO
LOSS_FUEL
NO_STRATEGIC_SETTLEMENT
```

Ein einzelnes Explosionsereignis darf mehrere Settlement Records erzeugen, wenn tatsächlich mehrere getrennte Ressourcen betroffen sind, aber jede konkrete Resource-/Entity-Korrelation darf nur einmal gebucht werden.

### 9.3 Vehicle loss

```text
confirmed destruction of strategic vehicle representation
-> VEHICLE -1 exactly once
```

Ein dekoratives Static ohne CampaignState-Fahrzeugbindung erzeugt keinen `VEHICLE`-Verlust.

### 9.4 Personnel loss

Visible DCS soldiers are tactical representation, not one-to-one persistent personnel unless explicitly correlated.

Für mobile Gruppen wird die zugehörige Mission-/Reservation-Stärke als Verlustbasis verwendet. Teilverluste werden später anhand des bestätigten Gruppen-/Unit-Vertrags gebucht; keine pauschale 1:1-Zählung aller sichtbaren Soldaten ohne Korrelation.

### 9.5 Fixed fire-support loss

Für Honaker gilt:

```text
2 physical M777A2-equivalent proxy slots
-> each slot has stable fire-support asset identity
-> confirmed destruction of one slot
-> fire-support available systems 2 -> 1
-> confirmed destruction of second slot
-> 1 -> 0
-> FIRE_SUPPORT_READINESS = UNAVAILABLE regardless of AMMO
```

Kein Same-Session-Respawn erzeugt das verlorene Geschütz neu.

### 9.6 Supply/Ammo/Fuel damage

Nur physische Storage-/Cargo-Repräsentationen mit explizitem Transfer-/Stock-Manifest erzeugen strategischen Verlust.

```text
burning fuel object without manifest
!= automatic arbitrary FUEL debit
```

## 10. CampaignState <-> MOOSE Warehouse one-way authority contract

### 10.1 Authority

```text
CampaignState
= sole strategic authority

MOOSE WAREHOUSE / BRIGADE / PLATOON
= operational asset selection and lifecycle representation

DCS Warehouse / DCS group / static / cargo
= physical representation and telemetry
```

### 10.2 Allowed direction

```text
CampaignState reservation approved
-> adapter enables/selects corresponding MOOSE operational asset
-> physical mission executes
-> observed result
-> adapter submits settlement candidate
-> CampaignState accepts/rejects settlement exactly once
```

### 10.3 Forbidden reverse authority

Unzulässig:

```text
MOOSE AddAsset -> CampaignState credit
MOOSE Returned -> automatic CampaignState credit
MOOSE Warehouse count change -> overwrite CampaignState quantity
DCS warehouse quantity -> overwrite CampaignState quantity
DCS Despawn -> resource return
DCS Destroy -> unclassified strategic debit
CTLD delivery -> automatic strategic credit
```

### 10.4 Reconciliation invariant

Für jede strategische Ressource gilt:

```text
strategicAvailable
+ strategicReserved
+ strategicCommitted
+ strategicLost/consumed
= authoritative CampaignState accounting domain
```

MOOSE-/DCS-Zähler dürfen zur Diagnose mitgeführt werden, sind aber Mirrors. Eine Abweichung erzeugt einen Fehler-/Reconciliation-Event und **keine** automatische Gegenbuchung.

## 11. Initial node snapshot

```yaml
GROUND_NODE_JALALABAD:
  PERSONNEL: 480
  VEHICLE: 48
  SUPPLY: 120
  AMMO: 100
  FUEL: 120

GROUND_NODE_JOYCE:
  PERSONNEL: 180
  VEHICLE: 20
  SUPPLY: 48
  AMMO: 44
  FUEL: 40
  childCommitments:
    BLUE_GROUND_COP_HONAKER_MIRACLE:
      PERSONNEL: 40

GROUND_NODE_WRIGHT:
  PERSONNEL: 120
  VEHICLE: 22
  SUPPLY: 36
  AMMO: 30
  FUEL: 36

GROUND_NODE_BOSTICK:
  PERSONNEL: 220
  VEHICLE: 26
  SUPPLY: 56
  AMMO: 52
  FUEL: 48
  childCommitments:
    BLUE_GROUND_OP_MUSTANG:
      PERSONNEL: 12
    BLUE_GROUND_OP_CLYDESDALE:
      PERSONNEL: 12
    BLUE_GROUND_OP_STALLION:
      PERSONNEL: 12
```

`BLUE_GROUND_OP_JOJO` remains reservation-free while activation is provisional.

## 12. Acceptance boundary

Dieser Stand ist `PLANNED`.

Noch in DCS zu prüfen sind insbesondere:

```text
- actual mission-group sizes against the selected action costs
- practical vehicle availability and simultaneous tasking
- MOOSE BRIGADE/PLATOON asset selection with CampaignState gating
- loss correlation and exactly-once settlement
- physical destruction versus warehouse/asset mirror behavior
- readiness transitions under real mission losses
- fire-support ammo calibration
- multiplayer event ordering and duplicate-event resistance
```

Keiner dieser Punkte ist durch dieses Dokument `VALIDATED`.
