---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B Fortress automatic-response acceptance planning
  - Fortress threat-to-real-CAS execution and completion
  - Fortress infantry guard and QRF execution
  - native MOOSE Ground return-to-origin proof for the tested Fortress infantry
  - post-combat personnel settlement and resupply reevaluation proof
not_authoritative_for:
  - production CAS source-selection policy
  - production CAS altitude/speed policy
  - final guard rotation duration
  - production-wide ground return-zone policy before cross-site acceptance
  - installations other than Fortress
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Stage 2B plan using explicit Fortress ACCESS RTZ as the default return implementation
  - OMW-GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1 as the next required test path
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 2B – Fortress full automatic-response Acceptance 2

## Ziel

Der nächste DCS-Lauf ist wieder **ein vollständiger gemeinsamer Fortress-Test**. Es gibt keinen vorgeschalteten Joyce-/Convoy-Test mehr.

```text
real BLUE Fortress infantry sentry
-> MOOSE runtime OPSZONE around Fortress
-> real RED perimeter threat
-> OPSZONE Attacked(RED)
-> CAS_IMMEDIATE MissionDemand
-> Jalalabad AH-64D CAS
-> OMW_FlightPath corridor
-> Fortress infantry QRF
-> AUFTRAG:NewGROUNDATTACK(real RED group)
-> RED threat eliminated
-> OPSZONE Defeated(RED)
-> CAS AUFTRAG closure
-> CAS RTB / Landed / Arrived
-> Guard + QRF normal MOOSE mission closure
-> native MOOSE ReturnToLegion
-> origin Fortress Legion spawnzone
-> Returned
-> original Fortress Warehouse AddAsset
-> CampaignState casualty settlement
-> PERSONNEL reorder reevaluation
```

Ein PASS nur bis `CAS_EXECUTING` oder `QRF_GROUNDATTACK_EXECUTING` ist unzulässig.

## MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der tatsächlich gepinnte Source bestätigt für den Ground-Lifecycle:

```text
OPSGROUP constructor
-> SetReturnToLegion()
-> default legionReturn = true

MissionDone
-> if AUFTRAG.legionReturn was explicitly set, copy that value to OPSGROUP
-> if not explicitly set, keep OPSGROUP default true

_CheckGroupDone()
-> when final waypoint/task/mission is complete
-> if self.legion and self.legionReturn
-> ARMYGROUP:RTZ(self.legion.spawnzone)

ARMYGROUP:RTZ(zone)
-> if already in zone: Returned()
-> otherwise: GetRandomCoordinate() in zone + physical waypoint

ARMYGROUP:Returned
-> self.legion:__AddAsset(10, self.group, 1)
```

Für den normalen Stage-2B-Rückweg wird deshalb keine parallele OMW-Rückkehrsteuerung verwendet.

## Fortress-Prüfobjekte

```text
Installation: BLUE_GROUND_COP_FORTRESS
CampaignState node: GROUND_NODE_FORTRESS
Warehouse: WH_BLUE_GND_FORTRESS
Infantry template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Guard: 9 PERSONNEL
QRF: 9 PERSONNEL
Defence reserve floor: 80 PERSONNEL
Runtime security zone: OMW_SECURITY_BLUE_GROUND_COP_FORTRESS_A2
Runtime security radius: 1000 m
OPSZONE update: 5 s, acceptance-only
```

Für diesen Test wird **keine zusätzliche Mission-Editor-Testzone** benötigt.

Insbesondere nicht:

```text
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
irgendeine neue ZON_BLUE_GND_FORTRESS_*_TEST-Zone
```

Die Security-/Threat-Geometrie wird als MOOSE-Runtime-Zone erzeugt.

## Fortress ACCESS-Zone

Die vorhandene Zone

```text
ZON_BLUE_GND_FORTRESS_ACCESS
```

bleibt erhalten. Sie ist eine bereits vorhandene sichere Ground-Materialization-/Departure-/Arrival-/Handoff-Geometrie.

Sie wird im **ersten integrierten Test jedoch bewusst nicht als MOOSE spawnzone/homezone override gesetzt**, weil zuerst der native MOOSE-Default geprüft wird.

Der Test enthält daher nicht:

```text
BRIGADE:SetSpawnZone(ZON_BLUE_GND_FORTRESS_ACCESS, ...)
WAREHOUSE:SetSpawnZone(ZON_BLUE_GND_FORTRESS_ACCESS, ...)
AUFTRAG:SetReturnToLegion(false)
ARMYGROUP:RTZ(ZON_BLUE_GND_FORTRESS_ACCESS, ...)
```

Wenn die native Fortress-Warehouse-Geometrie in DCS sichtbar ungeeignet ist, ist der nächste MOOSE-first-Schritt:

```text
SetSpawnZone(existing ZON_BLUE_GND_FORTRESS_ACCESS)
-> normal ReturnToLegion bleibt aktiv
-> kein eigener OMW Return-Controller
```

## Ground-Spawn und Ground-Return im aktuellen Test

Die `BRIGADE` wird direkt auf

```text
WH_BLUE_GND_FORTRESS
```

aufgebaut und behält ihre native MOOSE-`spawnzone`.

Der erwartete Name dieser vom Warehouse erzeugten Zone ist:

```text
Warehouse WH_BLUE_GND_FORTRESS spawn zone
```

Der Acceptance-Harness beobachtet `ARMYGROUP:OnAfterRTZ(...)`. Ein Ground-PASS verlangt, dass Guard und QRF jeweils genau über diese Herkunftszone zurückkehren.

Damit wird gleichzeitig nachgewiesen:

```text
Fortress mission target != return authority
origin Legion remains Fortress
origin Warehouse remains Fortress
```

## Guard

Der Guard wird aus demselben realen Fortress-Infanterietemplate materialisiert:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Mission:

```text
AUFTRAG:NewONGUARD(Fortress coordinate)
```

Der real materialisierte BLUE Guard ist die lokale BLUE-Präsenz für OPSZONE. Erst nach `MissionExecute` des Guards wird die Threat-/CAS-Pipeline gestartet.

Bei `OPSZONE Defeated(RED)` wird die Guard-Mission nur über `AUFTRAG:Cancel()` beendet. Es wird **kein explizites RTZ** ausgelöst. Danach muss MOOSE den normalen ReturnToLegion-Pfad selbst ausführen.

## QRF / Gegenangriff

Bei qualifiziertem `OPSZONE Attacked(RED)` wird die tatsächlich von OPSZONE erkannte lebende RED-Gruppe als Ziel verwendet.

```text
CampaignState PERSONNEL reservation
-> Fortress QRF PLATOON
-> ARMYGROUP
-> AUFTRAG:NewGROUNDATTACK(real RED group, 8, OffRoad)
```

Es wird kein eigener DCS-Ground-Attack-Task gebaut.

`SetReturnToLegion(false)` wird nicht gesetzt.

Nach Threat-Clear wird die Mission nur dann explizit über `AUFTRAG:Cancel()` geschlossen, wenn sie noch nicht beendet ist. Die anschließende Rückkehr bleibt MOOSE-eigen.

## CAS

Bestehende OMW-Ressource:

```text
AIRWING: AW_US_JBAD_TF_SHOOTER_6_6_CAV
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
```

Acceptance-only Parameter:

```text
CAS altitude: 10000 ft
CAS speed: 120 kt
corridor PATHLINE: OMW_FlightPath
corridor offset: 500 m directional right
corridor altitude: 500 ft AGL
```

Pfad:

```text
OPSZONE Attacked
-> MissionDemand CAS_IMMEDIATE
-> FobAttackCasDispatchAdapter
-> AUFTRAG:NewCAS(...)
-> AssignSquadrons({Jalalabad AH-64D squadron})
-> AIRWING:AddMission(...)
```

Threat-Clear:

```text
OPSZONE Defeated(RED)
-> RequestMissionClosure(...)
-> AUFTRAG:Cancel()
-> MOOSE waits for group MissionDone
-> AUFTRAG Evaluate()
-> Success when mission success criteria are met
-> MissionDemand SUCCESS through the existing adapter callback
```

Der reale CAS-Rückweg muss zusätzlich zeigen:

```text
FLIGHTGROUP RTB
-> Landed
-> Arrived
```

## CampaignState PERSONNEL

Deployment ist keine Consumption.

```text
before deployment:
quantity = strategic personnel quantity
available = currently dispatchable personnel

Guard deployment:
quantity unchanged
available -= 9

QRF deployment:
quantity unchanged
available -= 9

physical return:
reservation released
survivors become available again

confirmed casualties:
separate exact-once CONSUMPTION
quantity -= casualties
```

Der Harness speichert deshalb getrennt:

```text
personnelInitialQuantity
personnelInitialAvailable
```

Die Endmengenprüfung verwendet die initiale **quantity**, nicht fälschlich `available`.

## Reorder

Fortress bleibt:

```text
target: 160
reorder: 128
comparison: BELOW
```

Ein normaler 18-Personen-Guard/QRF-Test kann aus vollem Bestand selbst bei Totalverlust nur auf 142 sinken und damit die 128er-Schwelle nicht überschreiten.

Der DCS-Test beweist daher die reale **post-combat reevaluation**. Der separate Lua-Contract beweist weiterhin:

```text
127 -> RESUPPLY demand
128 -> no RESUPPLY demand
```

Es wird keine künstliche Zusatzattrition nur zur Erzwingung eines Resupply-Auftrags eingeführt.

## PASS-Kriterien

Der Test darf erst PASS melden, wenn gleichzeitig nachgewiesen sind:

```text
real Fortress BLUE infantry guard materialized
Guard ONGUARD executing
OPSZONE Attacked(RED)
exactly one CAS_IMMEDIATE demand
exactly one Jalalabad AH-64D CAS dispatch
CAS executing
OMW_FlightPath corridor installed
real Fortress infantry QRF materialized
QRF GROUNDATTACK executing against real RED OPSZONE group
OPSZONE Defeated(RED)
CAS closure requested
CAS RTB
CAS Landed
CAS Arrived
Guard native RTZ observed
QRF native RTZ observed
both RTZ zones == Warehouse WH_BLUE_GND_FORTRESS spawn zone
Guard Returned
QRF Returned
CampaignState Guard settlement
CampaignState QRF settlement
post-combat PERSONNEL reorder evaluated
CAS MissionDemand == SUCCESS
no duplicate CAS dispatch
no defence reserve floor violation
final strategic PERSONNEL quantity == initial quantity - confirmed casualties
```

## Visuelle Owner-Prüfung

Zusätzlich zu Logs ist in DCS zu beobachten:

```text
wo Guard und QRF tatsächlich materialisieren
ob die Fortress-Infanterie plausibel läuft
ob QRF die RED-Gruppe tatsächlich angreift
ob CAS real erscheint, anfliegt und wirkt
ob CAS physisch zurückkehrt
ob Guard/QRF nach Missionsende selbständig zurücklaufen
ob die native 250-m-Warehouse-spawnzone die Infantry durch HESCOs/Statics zwingt
ob irgendein beobachtbarer Teleport auftritt
wo Returned/Despawn tatsächlich erfolgt
```

Ein technischer Log-PASS bei sichtbar unplausiblem Ground-Pathfinding ist **kein geometrischer Produktions-PASS**.

## Build

Builder:

```text
tools/build-fob-attack-cas-dispatch-acceptance-2.ps1
```

Output:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua
```

Aktueller Builder-Vertrag:

```text
FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-3
Fortress only
Infantry only for Guard/QRF
additional ME test zone: false
Ground spawnzone override: false
Ground SetReturnToLegion(false): false
Ground explicit RTZ: false
MIZ mutation: false
```

## Joyce-Fehlpfad

Der kurzfristig erzeugte isolierte Joyce-/M-ATV-Homezone-Test ist für Stage 2B verworfen und in

```text
mission/tests/ground-native-homezone-return/ACCEPTANCE-1.md
```

als `SUPERSEDED` dokumentiert.

Der reale Lauf vom 30.08.2026 brach bereits an einer fehlenden historischen `ZON_BLUE_GND_JOYCE_PATROL_TEST_01`-Vorbedingung ab. Er enthält **keine** Aussage über MOOSE ReturnToLegion und **keine** Aussage über Fortress-Infanterie.

## DCS-only Grenze

Bis zum nächsten realen Lauf bleiben insbesondere offen:

```text
native Fortress Infantry materialization position
native Fortress Warehouse spawnzone Ground pathfinding
actual Guard/QRF RTZ path
physical Returned timing
full CAS + Ground composition
casualties and exact settlement under real combat
```

Status:

```text
READY_FOR_BUILD_AND_DCS_TEST_AFTER_LOCAL_HASH_VERIFICATION
```
