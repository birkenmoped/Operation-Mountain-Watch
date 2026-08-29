---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B Fortress automatic response acceptance planning
  - Fortress threat-to-real-CAS execution and completion
  - local infantry counterattack and return/recovery proof
  - post-combat personnel settlement and resupply reevaluation proof
not_authoritative_for:
  - production CAS source-selection policy
  - production CAS altitude/speed policy
  - final guard rotation duration
  - installations other than Fortress
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2B – FOB/COP automatic response Acceptance 2

## Ziel

Acceptance 2 prüft den vollständigen Fortress-Response-Lifecycle:

```text
RED perimeter threat
-> OPSZONE Attacked(RED)
-> CAS_IMMEDIATE
-> Jalalabad AH-64D CAS via OMW_FlightPath
-> local infantry QRF via GROUNDATTACK
-> RED threat eliminated
-> OPSZONE Defeated(RED)
-> CAS mission closure / RTB / landing / recovery
-> Guard + QRF RTZ / Returned / Warehouse
-> exact personnel casualty settlement
-> existing PERSONNEL reorder evaluation
```

Ein PASS nur aufgrund von `CAS_EXECUTING` ist ausdrücklich unzulässig.

## Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die erforderlichen APIs wurden gegen den tatsächlichen gepinnten Source geprüft. Detailregister:

```text
docs/moose/PROJECT-CLASS-INDEX-STAGE-2-ACCEPTANCE-2.md
```

## Vorbedingungen

Vor dem Acceptance-Bundle müssen laufen:

```text
MOOSE 2.9.18 pinned artifact
OMW AirOps Warehouse Base
OMW Ground Base + GroundBase.Attach(...)
OMW_AirOps_Jalalabad_Bootstrap.lua
owner-authored PATHLINE: OMW_FlightPath
```

Erwartete vorhandene AirOps-Ressource:

```text
AIRWING:  AW_US_JBAD_TF_SHOOTER_6_6_CAV
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
CAS capability available
```

## Acceptance-spezifischer Fortress-Vertrag

```text
Installation: BLUE_GROUND_COP_FORTRESS
Warehouse: WH_BLUE_GND_FORTRESS
Security perimeter: runtime ZONE_RADIUS, 1000 m
OPSZONE scan: 5 s, acceptance-only
Guard template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
QRF template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Guard commitment: 9 PERSONNEL
QRF commitment: 9 PERSONNEL
PERSONNEL target: 160
Defence reserve floor: 80
Return handoff: ZON_BLUE_GND_FORTRESS_ACCESS
CAS altitude: 10000 ft, acceptance-only
CAS speed: 120 kt, acceptance-only
CAS corridor: OMW_FlightPath
Corridor offset: 500 m directional right
Corridor altitude: 500 ft AGL
```

`ZON_BLUE_GND_FORTRESS_ACCESS` bleibt ausschließlich Materialisierungs-/Departure-/Return-Handoff. Es wird nicht zur Security-Zone umdefiniert.

## PERSONNEL-Accounting

Stage 2B verwendet die bindende strategische Semantik:

```text
deployment
-> CampaignState ReserveResource
-> quantity unchanged
-> reserved increases
-> available decreases

physical return
-> deployment reservation released
-> survivors available again

confirmed casualties
-> separate exact-once CampaignState consumption
```

Damit werden Gefallene nicht nach einer bereits erfolgten Deployment-Buchung doppelt abgezogen.

## CAS-PASS-Kriterien

Der DCS-Log muss mindestens belegen:

```text
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING
READY ... detection=OPSZONE_ATTACKED
QUALIFIED_THREAT
DEMAND_RESULT ... created=true
CAS_DISPATCHED
CAS_FLIGHT_ON_MISSION
CAS_CORRIDOR_INSTALLED ... pathline=OMW_FlightPath
CAS_EXECUTING
THREAT_CLEARED ... OPSZONE_DEFEATED_RED
CAS_MISSION_CLOSURE ... requested=true
CAS_RTB
CAS_LANDED
CAS_ARRIVED
```

Zusätzlich gilt:

```text
exactly one CAS dispatch
MissionDemand reaches ACTIVE on AUFTRAG Executing
MissionDemand reaches SUCCESS only after MOOSE mission success
no direct SPAWN
no native world.addEventHandler
no MIST
no .miz mutation by ChatGPT
```

## Ground-PASS-Kriterien

Der DCS-Lauf muss belegen:

```text
PERSONNEL_RESERVED ... GUARD
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING
PERSONNEL_RESERVED ... QRF
QRF_ON_MISSION
QRF_GROUNDATTACK_EXECUTING
50 % defence reserve floor never violated
THREAT_CLEARED
QRF_RETURN_RTZ_ISSUED
GUARD_RETURN_RTZ_ISSUED
QRF_RETURNED_HANDOFF or QRF_GROUP_DEAD
GUARD_RETURNED_HANDOFF or GUARD_GROUP_DEAD
QRF_PERSONNEL_SETTLED
GUARD_PERSONNEL_SETTLED
```

Die Rückkehr erfolgt über den MOOSE-`ARMYGROUP:RTZ`-/`Returned`-/Warehouse-Lifecycle; ein nacktes `Destroy()` zählt nicht.

## OutOfAmmo und Guard-Rotation

MOOSE besitzt einen nativen OutOfAmmo-/Return-Pfad. Acceptance 2 führt deshalb keinen eigenen Munitions-Polling-Scheduler ein.

Der primäre Acceptance-Lauf prüft den Guard-Return über **explicit relief after threat clear**. Eine produktive zeitbasierte Guard-Rotationsdauer bleibt eine separate, noch nicht entschiedene Designkonstante.

## Post-combat Reorder / RESUPPLY

Nach Guard-/QRF-Settlement wird der bestehende Fortress-PERSONNEL-Row erneut bewertet:

```text
target = 160
reorder = 128
comparison = BELOW
```

Der normale End-to-End-Lauf beginnt mit vollem Bestand und bindet nur 18 Personen. Selbst Totalverlust ergibt 142 und kann deshalb die 128er-Reorder-Schwelle nicht sinnvoll unterschreiten. Daher gelten zwei getrennte Nachweise:

```text
DCS Acceptance 2:
real post-combat CampaignState reevaluation is observed

Lua contract test:
available=127 -> exactly one RESUPPLY MissionDemand
available=128 -> no demand under strict BELOW
```

Die physische PERSONNEL-Transportausführung bleibt der bereits vorhandenen PERSONNEL-Resupply-Orchestration vorbehalten. Acceptance 2 implementiert keinen zweiten Transportmechanismus.

## Build

Der aktuelle Builder ist:

```text
tools/build-fob-attack-cas-dispatch-acceptance-2.ps1
BuilderVersion: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-2
```

Erzeugtes Bundle:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua
```

Der ältere lokal verifizierte Build `FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-1` mit SHA-256 `9ADB5C601A1F30C748C747835FA62B191F485AEC002106020B34EC9D0844CCD8` ist nur historischer Dispatch-Checkpoint und **nicht** das aktuelle Stage-2B-Acceptance-Bundle.

## Statische Verifikation

Die MissionDemand-Vertragstests decken jetzt zusätzlich ab:

```text
OPSZONE threat-start / threat-clear callbacks
CAS threat-clear closure request
PERSONNEL deployment reservation and casualty-only consumption
ResourceDemandPolicy -> MissionDemand RESUPPLY bridge
shared OMW_FlightPath corridor adapter
```

Ein erfolgreicher CI-Lauf ersetzt keinen DCS-Acceptance-Test.

## Terminaler PASS

Der Acceptance-Harness darf erst `PASS` loggen, wenn gleichzeitig belegt sind:

```text
threat cleared
CAS closure requested
CAS executed
CAS RTB
CAS landed
CAS arrived/recovered
OMW_FlightPath installed
QRF GROUNDATTACK executed
Guard settlement complete
QRF settlement complete
post-combat PERSONNEL reorder evaluated
CAS MissionDemand SUCCESS
no defence-reserve violation
strategic PERSONNEL quantity = initial quantity - confirmed casualties
```

## Nicht entschieden

```text
production CAS source selection
final CAS altitude/speed
final guard rotation duration
counterattack force sizing below 50 % maximum
maximum simultaneous local response groups
optional BDA/clear hold before CAS closure
production OPSZONE cadence
restart/restore idempotency beyond separately accepted contracts
```
