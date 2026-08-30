---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH
status: PLANNED
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B MissionDemand-to-MOOSE-CAS adapter design
  - Stage 2B Acceptance-2 MOOSE execution path
not_authoritative_for:
  - production CAS source-selection policy
  - production CAS altitude/speed policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2B – CAS dispatch MOOSE source review

## Ergebnis

Stage 2B benötigt keine eigene Spawn-/Dispatcher-Engine. Der gepinnte MOOSE-Stand stellt den vollständigen operativen Ausführungspfad bereit:

```text
CAS_IMMEDIATE MissionDemand
-> kleiner OMW-Adapter
-> AUFTRAG:NewCAS(...)
-> bestehender AIRWING:AddMission(...)
-> SQUADRON capability/payload selection
-> Warehouse asset request/materialization
-> FLIGHTGROUP
-> AIRWING OnAfterFlightOnMission
-> AUFTRAG OnAfterExecuting
```

OMW ergänzt nur die Domänenzuordnung MissionDemand -> AUFTRAG und synchronisiert die MissionDemand-Zustände mit öffentlichen MOOSE-FSM-Callbacks.

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Verifizierte APIs

Im tatsächlich verwendeten `Moose.lua` geprüft:

```lua
AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)
LEGION:AddMission(Mission)
COHORT:AddMissionCapability(MissionTypes, Performance)
AIRWING OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
AUFTRAG OnAfterExecuting(From, Event, To)
AUFTRAG OnAfterSuccess(From, Event, To)
AUFTRAG OnAfterFailed(From, Event, To)
```

`AIRWING` erbt `LEGION:AddMission`. `LEGION:AddMission` setzt den AUFTRAG auf `QUEUED`, ordnet die Legion zu und legt ihn in die Mission Queue. Der MOOSE-Lifecycle führt anschließend über `REQUESTED`, `SCHEDULED`, `STARTED` zu `EXECUTING`. `OPSGROUP:onafterMissionExecute` setzt den Gruppenstatus auf `EXECUTING` und löst `Mission:Executing()` aus.

Die gepinnte `AUFTRAG:NewCAS`-Signatur nimmt eine `ZONE_RADIUS` als CAS-Zone an. Ohne explizite Höhe gilt 10000 ft; die Dokumentation nennt 350 KIAS als Defaultgeschwindigkeit. Acceptance 2 setzt für den vorhandenen Jalalabad-AH-64D-Pfad bewusst 10000 ft / 120 kt. Diese Werte sind ausschließlich Acceptance-Konfiguration und keine Produktionsbaseline.

## OMW-AirOps-Iststand

`scripts/air-operations/OMW_AirOps_Jalalabad_Bootstrap.lua` stellt bereits bereit:

```text
AW_US_JBAD_TF_SHOOTER_6_6_CAV
SQ_US_JBAD_AH64D_B_1_10_AVN
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
AUFTRAG.Type.CAS capability
CAS payload
AIRWING Start()
OMW.AirOps.Jalalabad.Airwing
```

Stage 2B erzeugt daher weder einen zweiten AIRWING noch einen zweiten SQUADRON-Bestand.

## Offizielle MOOSE-Demo-Prüfung

Die offizielle Demo `MOOSE_MISSIONS/develop/Ops/Airwing/Airwing - 010 - Fighter Wing` bestätigt denselben öffentlichen Aufbau: `SQUADRON:AddMissionCapability(...)`, `AIRWING:AddSquadron(...)`, `AIRWING:Start()`, öffentliche `OnAfterFlightOnMission(...)`-Beobachtung und `AIRWING:AddMission(...)` für AUFTRAG-Missionen. Die Demo ist kein OMW-CAS-Nachweis; sie bestätigt den vorgesehenen AIRWING-Missions- und Callback-Mechanismus.

## Adaptergrenze

`scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua` darf:

```text
CAS_IMMEDIATE validieren
AUFTRAG:NewCAS(...) erzeugen
AIRWING:AddMission(...) verwenden
MissionDemand OPEN -> AI_ASSIGNED setzen
AUFTRAG Executing -> MissionDemand ACTIVE spiegeln
AUFTRAG Success/Failed -> MissionDemand terminal spiegeln
Demand-ID -> erzeugten AUFTRAG innerhalb der laufenden Instanz korrelieren
```

Er darf nicht:

```text
CampaignState-Ressourcen verändern
AIRWING/SQUADRON-Warehouse umgehen
SPAWN direkt verwenden
DCS world event handler ergänzen
eigene Asset-Selektion implementieren
produktiv entscheiden, welcher von mehreren AIRWINGs einen Demand erhält
```

Die letzte Grenze ist wichtig: Acceptance 2 injiziert ausdrücklich den bereits bestehenden Jalalabad-AIRWING. Eine spätere produktive Auswahl mehrerer CAS-Quellen bleibt eine eigene Designentscheidung.

## Acceptance-Nachweis

Ein Stage-2B-PASS erfordert über das reine Queueing hinaus beide MOOSE-Lifecycle-Belege:

```text
AIRWING OnAfterFlightOnMission
-> reale FLIGHTGROUP-Materialisierung / Missionzuordnung

AUFTRAG OnAfterExecuting
-> reale Missionausführung hat begonnen
```

Erst dann darf der zugehörige MissionDemand im Acceptance-Pfad als `ACTIVE` gelten.
