---
document_id: OMW-ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned restart and reconstitution boundaries for current ARMY Ground Foundation assets
  - planned ACCESS-zone, road-anchor and return/handoff rules for mobile ground assets
  - separation between fixed mission-start representation, live-session field persistence and cross-session reconstitution
not_authoritative_for:
  - final Mission Editor coordinates
  - accepted DCS ground pathfinding behavior
  - accepted restart persistence implementation
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Reconstitution and ACCESS Boundary Contract

## 1. Zweck

Dieser Vertrag schließt die Architekturgrenze vor dem ersten Ground-Runtime-Test.

Operation Mountain Watch trennt drei Fälle strikt:

```text
A. fixed mission-start representation
B. live-session mobile field persistence
C. cross-session / restart reconstitution
```

Diese Fälle dürfen nicht über denselben Spawn-/Teleport-/Warehouse-Pfad vermischt werden.

`CampaignState` bleibt strategische Autorität. MOOSE und DCS materialisieren den jeweils freigegebenen Zustand lediglich physisch.

## 2. Source-qualified MOOSE basis

Gepinnter Stand:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-verifiziert:

```lua
BRIGADE:New(WarehouseName, BrigadeName)
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
LEGION:AddMission(Mission)
AUFTRAG:NewPATROLZONE(Zone, Speed, Altitude, Formation)
AUFTRAG:SetReturnToLegion(false)
BRIGADE:LoadBackAssetInPosition(Templatename, Position)
```

Wichtige Source-Grenzen:

- `BRIGADE:New(...)` benötigt ein benanntes STATIC- oder UNIT-Objekt als physische Warehouse-Repräsentation.
- `LEGION:AddMission(...)` stellt die öffentliche Mission-Queue-Schnittstelle auch für BRIGADE bereit.
- `AUFTRAG:NewPATROLZONE(...)` ist ausdrücklich für AIR, GROUND und NAVAL dokumentiert.
- `BRIGADE:LoadBackAssetInPosition(...)` materialisiert gespeicherte Ground-Assets per SpawnFromCoordinate und ist daher kein unkritischer sichtbarer Wiederherstellungspfad.
- `AUFTRAG:SetReturnToLegion(false)` ist der primäre MOOSE-first-Kandidat dafür, dass ein Ground-Asset nach Missionsende physisch im Feld verbleibt.

Keiner dieser Punkte ist für die konkrete OMW-Ground-Foundation bereits DCS-validiert.

## 3. Fixed mission-start representation

Fixed Assets sind physisch von Missionsbeginn an vorhanden.

Beispiele:

```text
perimeter / tower / gate defenders
fixed installation security groups
Honaker fixed fire-support pair
```

Regeln:

```text
- Mission Editor / deterministic mission-start placement
- no demand-time spawn into occupied installation geometry
- no same-session replacement into exact fixed combat position
- destroyed fixed asset remains absent for the current session
- strategic loss is settled in CampaignState exactly once
```

Ein Server-/Missionsneustart darf einen fixed asset nur dann wieder zeigen, wenn CampaignState ihn zum Neustartzeitpunkt weiterhin als verfügbar beziehungsweise repariert/ersetzt führt.

## 4. Live-session mobile field persistence

Mobile operative Assets werden aus dem Root-Node-Pool materialisiert und physisch bewegt.

Für Missionen, bei denen die Gruppe nach Auftragsende im Feld verbleiben soll, ist der erste MOOSE-first-Testpfad:

```text
AUFTRAG
-> SetReturnToLegion(false)
-> MissionDone
-> group remains physical at current position
```

Dieser Fall darf **nicht** gleichzeitig eine CampaignState-Rückgabe auslösen.

Zulässiger strategischer Zustand nach Missionsende:

```text
vehicle/personnel reservation remains COMMITTED / FIELD_DEPLOYED
physical group remains correlated to the same stable entity/reservation
```

Unzulässig:

```text
MissionDone
-> group remains physically in field
AND
-> resource is credited back to available stock
```

Das wäre eine Dublette der strategischen Ressource.

## 5. Cross-session / restart reconstitution

Ein Neustart beendet die physische DCS-Welt, aber nicht automatisch den strategischen CampaignState.

Der Restart-Vertrag lautet:

```text
persisted CampaignState
-> determine strategic asset state
-> determine whether a physical representation is required at mission start
-> materialize before normal player observation OR at a controlled non-observable boundary
-> correlate to the same stable strategic entity/reservation
```

### 5.1 Zustandsklassen

Mindestens folgende Persistenzzustände werden vorgesehen:

```text
AVAILABLE_AT_NODE
FIELD_DEPLOYED
FIXED_ACTIVE
DAMAGED_OR_DISABLED
LOST
RETURN_PENDING
```

### 5.2 Reconstitution rules

```text
AVAILABLE_AT_NODE
-> remains virtual/warehouse-eligible until demanded

FIXED_ACTIVE
-> mission-start physical representation if still strategically available

FIELD_DEPLOYED
-> may be reconstituted only through a controlled restart path
-> never as an observable same-session teleport

DAMAGED_OR_DISABLED
-> no automatic full-strength regeneration

LOST
-> must not reappear

RETURN_PENDING
-> settlement must be resolved before any new availability credit
```

### 5.3 MOOSE LoadBack boundary

`BRIGADE:LoadBackAssetInPosition(...)` remains source-reviewed but **not approved as the general OMW restart solution**.

It may only be considered later if all of the following are true:

```text
- persisted identity correlation is deterministic
- materialization happens before players can observe it or at a non-observable boundary
- no duplicate asset exists in Warehouse/BRIGADE stock
- CampaignState remains authoritative
- DCS test confirms lifecycle and follow-up mission reuse
```

Until then, restart reconstitution is `PLANNED / NOT_ACCEPTED`.

## 6. Root-node ACCESS zones

Each Root Ground Node uses one operational handoff zone:

```text
ZON_BLUE_GND_JALALABAD_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

The ACCESS zone is not the installation itself.

Placement rules:

```text
- outside the active FOB/HUB perimeter
- preferably on or directly beside a usable road
- no tight internal FOB pathfinding requirement
- screened from normal player observation where practical
- enough space for the largest approved template to materialize without collision
- suitable for both outbound and inbound handoff
```

The ACCESS zone may serve as:

```text
materialization boundary
convoy departure boundary
convoy arrival boundary
return/handoff boundary
reinforcement handoff
supply transfer handoff
```

A second assembly zone is not required by default.

## 7. Road-anchor contract

Every mobile route used for production must have a validated road-side start/transition point.

Working object naming:

```text
RTE_BLUE_GND_<NODE>_<ROLE>_<NN>
```

Examples:

```text
RTE_BLUE_GND_JOYCE_PATROL_01
RTE_BLUE_GND_BOSTICK_QRF_01
RTE_BLUE_GND_JALALABAD_LOGISTICS_01
```

A route object may later be represented by a Mission Editor PathGroup where MOOSE functionality benefits from an explicit predefined path.

No route is production-approved merely because a straight-line waypoint can be generated.

## 8. Return / handoff boundary

Normal mobile return must remain physical until the group reaches a non-observable handoff boundary.

Preferred contract:

```text
mission decides to return
-> physical route to ACCESS / return boundary
-> confirm arrival
-> settle mission state
-> only then allow MOOSE Returned / Warehouse AddAsset behavior
-> CampaignState release exactly once
```

Because source review shows that Warehouse AddAsset removes the physical group, the actual removal point must be outside reasonable player observation.

Unzulässig:

```text
field mission ends
-> immediate Returned
-> visible Despawn/Destroy near player area
```

## 9. Dependent OP boundary

Dependent OPs do not receive independent Warehouse/ACCESS infrastructure.

```text
JoJo <- Honaker-Miracle <- Joyce
Mustang/Clydesdale/Stallion <- Bostick
```

OP reinforcement therefore starts at the direct parent transport domain and ends through a validated ROAD / FOOT / ROAD_FOOT path.

No standard AIR sustainment or direct theater-hub spawn at an OP is permitted.

## 10. Acceptance sequencing

The first DCS runtime test intentionally excludes restart reconstitution and OPSTRANSPORT.

Acceptance sequence:

```text
ACCEPTANCE 1
one BRIGADE / one PLATOON / one mobile ARMYGROUP
PATROLZONE mission
SetReturnToLegion(false)
physical stay after MissionDone
follow-up mission reuse
no duplicate strategic credit

ACCEPTANCE 2+
return/handoff
CampaignState settlement adapter
restart/reconstitution
OPSTRANSPORT
artillery
full multi-node integration
```

This keeps the first runtime test focused on the smallest source-reviewed lifecycle that can invalidate or confirm the planned architecture.

## 11. Mission Editor prerequisites for Acceptance 1

The first test will use Joyce.

Required physical objects to be created by the project owner in the Mission Editor:

```text
WH_BLUE_GND_JOYCE
  STATIC or UNIT object
  physical MOOSE BRIGADE warehouse host

TPL_BLUE_GND_PATROL_MATV_4
  late-activated reusable template
  4 x CHAP_MATV

ZON_BLUE_GND_JOYCE_ACCESS
  road-side / player-non-observable handoff zone

ZON_BLUE_GND_JOYCE_PATROL_TEST_01
  nearby reachable ground patrol test zone
```

The exact coordinates are Mission Editor decisions and require visual/terrain inspection. They are not invented in documentation.

## 12. Exit criteria for architecture preparation

This contract is ready for the first runtime implementation only when:

```text
- Joyce warehouse host exists
- Joyce PATROL template exists
- Joyce ACCESS zone exists
- Joyce patrol test zone exists
- placement is visually/pathfinding-plausible
- exact mission artifact hash is recorded after owner build
```

Only then should the Ground Runtime Acceptance 1 Lua be built against that exact mission artifact.
