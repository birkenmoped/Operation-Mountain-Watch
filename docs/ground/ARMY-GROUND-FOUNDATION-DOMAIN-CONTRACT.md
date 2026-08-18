---
document_id: OMW-ARMY-GROUND-DOMAIN-CONTRACT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned stable CampaignState identities for the current ARMY Ground Foundation installation scope
  - planned parent-child relationships between current FOB, COP and OP campaign objects
  - separation of installation identity from historical formation, MOOSE pool and physical DCS group identity
not_authoritative_for:
  - final ground-force ORBAT strengths
  - final MOOSE BRIGADE topology
  - final personnel, vehicle, ammunition, fuel or supply quantities
  - final Mission Editor object state
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – CampaignState-Domainvertrag

## 1. Zweck und Grenze

Dieses Dokument definiert die erste stabile Identitäts- und Parent-Baseline für die aktuelle BLUE ARMY Ground Foundation im Jalalabad-/Kunar-Raum.

Es setzt die verbindlichen Architekturgrenzen aus `OMW-ARCH-CAMPAIGN-STATE` und `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` um:

```text
CampaignState strategic identity
!= historical formation identity
!= MOOSE BRIGADE / PLATOON identity
!= physical DCS GROUP / UNIT identity
```

Die hier festgelegten IDs sind strategische Primärschlüssel. DCS-Gruppennamen, MOOSE-Aliase, Warehouse-Namen und Mission-Editor-Objektnamen dürfen später auf diese IDs verweisen, dürfen sie aber nicht ersetzen.

Dieses Dokument legt bewusst **keine** Personal-, Fahrzeug-, Munitions-, Fuel- oder Supply-Mengen fest.

## 2. ID-Schema

Für persistente Ground-Installationen gilt im aktuellen Foundation-Scope:

```text
BLUE_GROUND_<CLASS>_<NAME>
```

Klassen:

```text
HUB
FOB
COP
OP
```

Die ID beschreibt die strategische Installation, nicht deren zeitweise Besatzung.

Beispiel:

```text
BLUE_GROUND_FOB_BOSTICK
!= TF_WOLFHOUND_2_27
!= BRIGADE_BOSTICK
!= TPL_BLUE_INFANTRY_...
!= a runtime ARMYGROUP name
```

## 3. Stabile Installations-IDs

### 3.1 Root-Installationen / operative Ground Nodes

| Stable ID | Installation | Campaign class | Parent installation | Current OMW scope |
|---|---|---|---|---|
| `BLUE_GROUND_HUB_JALALABAD_FENTY` | Jalalabad / FOB Fenty | `HUB` | none | active root |
| `BLUE_GROUND_FOB_JOYCE` | FOB Joyce | `FOB` | none | active root |
| `BLUE_GROUND_FOB_WRIGHT` | FOB Wright | `FOB` | none | active root |
| `BLUE_GROUND_FOB_BOSTICK` | FOB Bostick / Naray | `FOB` | none | active root |

`root` bedeutet in diesem Dokument nur, dass die Installation im aktuellen Ground-Foundation-Ausschnitt keinen lokalen FOB-/COP-Parent besitzt. Es bedeutet **nicht**, dass sie strategisch unabhängig von übergeordneten Theaterressourcen oder Command-Strukturen ist.

### 3.2 Joyce-Komplex

| Stable ID | Installation | Campaign class | Parent installation | Current OMW scope |
|---|---|---|---|---|
| `BLUE_GROUND_COP_HONAKER_MIRACLE` | COP Honaker-Miracle | `COP` | `BLUE_GROUND_FOB_JOYCE` | active dependent installation |
| `BLUE_GROUND_OP_JOJO` | OP JoJo | `OP` | `BLUE_GROUND_COP_HONAKER_MIRACLE` | reserved identity; activation remains provisional |

Für `BLUE_GROUND_OP_JOJO` wird die stabile Identität bereits reserviert, obwohl die konkrete 2010/11-Besetzung weiterhin nicht ausreichend belegt ist. Eine stabile ID ist **keine Aktivierungsentscheidung**.

### 3.3 Bostick-Komplex

| Stable ID | Installation | Campaign class | Parent installation | Current OMW scope |
|---|---|---|---|---|
| `BLUE_GROUND_OP_MUSTANG` | OP Mustang | `OP` | `BLUE_GROUND_FOB_BOSTICK` | planned active dependent installation |
| `BLUE_GROUND_OP_CLYDESDALE` | OP Clydesdale | `OP` | `BLUE_GROUND_FOB_BOSTICK` | planned active dependent installation |
| `BLUE_GROUND_OP_STALLION` | OP Stallion | `OP` | `BLUE_GROUND_FOB_BOSTICK` | planned active dependent installation |

Die Parent-Zuordnung von Mustang/Clydesdale/Stallion zu Bostick ist eine OMW-Designentscheidung. Sie wird nicht als Behauptung identischer historischer Juli-2011-Kommandobeziehungen formuliert.

## 4. Parent-Vertrag

Ein abhängiger COP/OP erhält keinen unabhängigen strategischen Ressourcenpool allein aufgrund seiner physischen Existenz.

```text
child installation
-> parentInstallationId
-> parent Ground Node resource reservation
-> physical occupancy / reinforcement / resupply
-> settlement against parent-bound CampaignState resources
```

Für OPs gilt verbindlich:

```text
OP active only if:
- parent installation is active
  OR
- explicit replacement parent is documented
```

Ein OP besitzt daher nicht automatisch:

```text
independent personnel pool
independent vehicle pool
independent warehouse authority
independent QRF origin
independent patrol origin
```

Eine lokale physische Munitions-, Fuel- oder Supply-Darstellung kann später existieren. Sie bleibt jedoch eine operative Abbildung beziehungsweise eine gebundene Teilmenge des autoritativen CampaignState-Vertrags und erzeugt keine zweite Ressourcenhoheit.

## 5. Formation Assignments

Historische Formationen werden als **Assignments** an Installationen beziehungsweise Ground Nodes geführt, nicht in die Installations-ID eingebaut.

Aktueller belastbarer Juli-2011-/juli-naher Arbeitsstand:

| Installation ID | Formation assignment | Evidence boundary |
|---|---|---|
| `BLUE_GROUND_HUB_JALALABAD_FENTY` | TF Bronco / 3rd BCT, 25th ID; TF Steel / 3-7 FA | July 2011 ORBAT; exact local ground QRF/base-defense formation remains open |
| `BLUE_GROUND_HUB_JALALABAD_FENTY` | HHC / 3rd BSTB Military Police Platoon | June 2011 security element in immediate July context; not proof of full base-defense ownership |
| `BLUE_GROUND_FOB_JOYCE` | TF Cacti / 2-35 Infantry | July 2011 ORBAT |
| `BLUE_GROUND_COP_HONAKER_MIRACLE` | C Battery / 3-321 FA, two M777A2 | directly supported for 30 July 2011 |
| `BLUE_GROUND_FOB_WRIGHT` | 1-14th Illinois ADT / Security Force Platoon | July 2011 ground/security approach |
| `BLUE_GROUND_FOB_BOSTICK` | TF Wolfhound / TF No Fear / 2-27 Infantry | July 2011 battalion-node baseline; exact Bostick maneuver company remains open |

Nicht ausreichend geklärte Company-/Platoon-Verteilungen bleiben offene Research-Attribute und werden nicht durch ID-Namen vorweggenommen.

## 6. Vorgesehene CampaignState-Felder

Für eine spätere Implementierung soll ein Ground-Installation-State mindestens folgende Identitäts- und Beziehungsfelder besitzen:

```yaml
id: BLUE_GROUND_FOB_BOSTICK
displayName: FOB Bostick
installationClass: FOB
parentInstallationId: null
groundNodeId: GROUND_NODE_BOSTICK
activationState: ACTIVE
historicalFormationAssignments: []
resourceContractId: null
missionEditorAnchorId: null
runtimeRepresentationIds: []
```

Für einen abhängigen OP entsprechend:

```yaml
id: BLUE_GROUND_OP_MUSTANG
displayName: OP Mustang
installationClass: OP
parentInstallationId: BLUE_GROUND_FOB_BOSTICK
groundNodeId: GROUND_NODE_BOSTICK
activationState: PLANNED_ACTIVE
historicalFormationAssignments: []
resourceContractId: null
missionEditorAnchorId: null
runtimeRepresentationIds: []
```

`groundNodeId` bleibt eine operative Domain-Zuordnung und ist **keine** Festlegung, dass exakt eine gleichnamige MOOSE-`BRIGADE` existieren muss.

## 7. Runtime-Repräsentationsgrenze

Eine Installation kann gleichzeitig oder nacheinander durch mehrere physische Objekte dargestellt werden:

```text
CampaignState installation ID
-> static infrastructure
-> one or more DCS ground groups
-> MOOSE ARMYGROUP wrappers
-> optional BRIGADE / PLATOON pool membership
```

Diese Repräsentationen dürfen verändert, zerstört, ersetzt oder neu materialisiert werden, ohne dass sich die strategische Installations-ID ändert.

Umgekehrt darf ein DCS-Gruppenname niemals die persistente Installationsidentität bestimmen.

## 8. Noch offene Domain-Entscheidungen

Dieses Dokument entscheidet ausdrücklich noch nicht:

```text
- exact MOOSE BRIGADE count and boundaries
- exact PLATOON roles and asset counts
- exact personnel / vehicle / ammo / fuel / supply quantities
- exact July-2011 Jalalabad ground QRF/base-defense formation
- exact July-2011 Joyce company distribution
- exact July-2011 Bostick maneuver company distribution
- exact July-2011 Wright artillery assignment
- final DCS artillery proxies
- final Mission Editor anchor and route IDs
- runtime persistence/reconstitution acceptance
```

## 9. Nächster Domain-Schritt

Nach dieser Identitätsbaseline kann Phase D ohne Namensabhängigkeiten fortgesetzt werden:

```text
stable installation IDs
-> parent relationships
-> resource contracts per root Ground Node
-> child occupancy/resource reservations
-> MissionDemand / MOOSE materialization adapters
-> DCS acceptance
```

Die nächsten Ressourcenverträge dürfen nur Mengen oder Kategorien festlegen, die als bewusste OMW-Designentscheidung beziehungsweise ausreichend belastbare Baseline beschlossen sind. Historische Battalion-/Company-Namen werden nicht automatisch in exakte DCS-Gruppenstärken umgerechnet.
