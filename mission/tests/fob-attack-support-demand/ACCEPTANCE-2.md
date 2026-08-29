---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B Fortress threat-to-real-CAS execution acceptance
not_authoritative_for:
  - production CAS source-selection policy
  - production CAS altitude/speed policy
  - installations other than Fortress
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2B – FOB/COP threat -> real CAS execution Acceptance 2

## Ziel

Acceptance 2 schließt den in Acceptance 1 real bestätigten Stage-2A-Pfad direkt an die vorhandene MOOSE-AirOps-Foundation an:

```text
Fortress RED perimeter threat
-> MOOSE OPSZONE Attacked(RED)
-> CAS_IMMEDIATE MissionDemand
-> OMW_FobAttackCasDispatchAdapter
-> existing OMW.AirOps.Jalalabad.Airwing
-> AUFTRAG:NewCAS(...)
-> AIRWING:AddMission(...)
-> real FLIGHTGROUP
-> AIRWING OnAfterFlightOnMission
-> AUFTRAG OnAfterExecuting
-> MissionDemand ACTIVE
```

Ein PASS allein aufgrund von `AUFTRAG:NewCAS()` oder `AIRWING:AddMission()` ist ausdrücklich unzulässig.

## MOOSE-first-Basis

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich verwendeten `Moose.lua` verifiziert:

```lua
AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)
LEGION:AddMission(Mission) -- inherited by AIRWING
AIRWING OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
AUFTRAG OnAfterExecuting(From, Event, To)
COHORT:AddMissionCapability(MissionTypes, Performance)
```

`AIRWING` erbt `LEGION:AddMission()`. MOOSE übernimmt damit Auswahl, Warehouse-Anforderung, Materialisierung und den FLIGHTGROUP-/AUFTRAG-Lifecycle. Es gibt keinen OMW-`SPAWN:`-Shortcut.

## Vorbedingungen

Die Mission muss vor dem Acceptance-Bundle bereits den bestehenden OMW-Stack geladen haben, insbesondere:

```text
OMW AirOps Warehouse Base
OMW Ground Base + GroundBase.Attach(...)
OMW_AirOps_Jalalabad_Bootstrap.lua
```

`OMW.AirOps.Jalalabad.Status` muss `RUNNING` sein. Die bestehende Jalalabad-Foundation stellt `SQ_US_JBAD_AH64D_B_1_10_AVN` mit `AUFTRAG.Type.CAS` und CAS-Payload bereit.

## Acceptance-spezifisches CAS-Profil

Nur für diesen technischen DCS-Nachweis:

```text
Airwing:  AW_US_JBAD_TF_SHOOTER_6_6_CAV
Squadron: SQ_US_JBAD_AH64D_B_1_10_AVN
Altitude: 10000 ft
Speed:    120 kt
Target:   dieselbe runtime ZONE_RADIUS des Fortress-Sicherheitsperimeters
```

Diese Werte beweisen die Integrationskette und sind **keine** produktive Source-Selection-, Höhen- oder Geschwindigkeitsbaseline.

## PASS-Kriterien

Der reale DCS-Lauf muss mindestens folgende Reihenfolge im Log belegen:

```text
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING
READY ... detection=OPSZONE_ATTACKED
QUALIFIED_THREAT
DEMAND_RESULT ... created=true
CAS_DISPATCHED
CAS_FLIGHT_ON_MISSION
CAS_EXECUTING
PASS
```

Zusätzlich gelten:

```text
exactly one dispatch for the created demand
MissionDemand assignedTo = AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV
MissionDemand reaches ACTIVE on AUFTRAG Executing
real FLIGHTGROUP is observed through AIRWING OnAfterFlightOnMission
Fortress personnel commitment remains exactly 9
no second CampaignState
no direct SPAWN
no native world.addEventHandler
no MIST
no .miz mutation by ChatGPT
```

## Nicht durch Acceptance 2 entschieden

Offen bleiben bewusst Produktionsfragen wie automatische Wahl zwischen mehreren CAS-Quellen, missionsweite Prioritätsübersetzung, finale CAS-Höhen-/Geschwindigkeitsprofile, Incident-Closure nach Bedrohungsende sowie Restart/Restore-Idempotenz. Diese dürfen aus einem PASS dieses Tests nicht abgeleitet werden.
