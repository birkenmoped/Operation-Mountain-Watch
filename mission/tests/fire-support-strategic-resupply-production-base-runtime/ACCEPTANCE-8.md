---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-8
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - corrected CAS release authority after A7
  - non-terminal watchdog behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-7
superseded_by:
---

# Production Base Acceptance 8 – CAS release correction

## Ziel

A8 behaelt den erfolgreichen A7-Hinflug-/Provider-/Owner-Route-Pfad und korrigiert ausschliesslich die reale Release-Regression.

Der A7-Fehler war doppelt:

```text
1. terminaler 900-s-Watchdog setzte state.failed=true
2. state.failed stoppte evaluate()/updateCasLifecycle()
3. MOOSE wechselte erst danach auf EXECUTING
4. daher liefen CAS own-detection, supported-element-clear und controlled release nie mehr
```

Zusaetzlich war der bisherige On-Station-Test zu streng geometrisch. Der gepinnte MOOSE-Stand definiert `AUFTRAG:IsExecuting()` als Zustand, in dem der erste OPSGROUP den Mission-Execution-Waypoint erreicht hat und die Mission ausfuehrt. A8 verwendet deshalb diesen MOOSE-Zustand als On-Station-/Execution-Autoritaet.

## Erwarteter Ablauf

```text
Joyce attack
-> production incident
-> QRF direct concrete-target engagement
-> Base CAS demand
-> MOOSE provider/asset selection
-> owner route / WEST / ingress
-> AUFTRAG:IsExecuting() == true
-> FLIGHTGROUP own detection valid
-> living incident attackers == 0
-> eligible own detected contacts == 0 for >= 30 s
-> Base/CommanderBridge controlled Cancel
-> owner egress / reverse route
-> home landing
-> LegionAssetReturned
-> PASS
```

## Watchdog

Der neue 3600-s-Watchdog ist rein diagnostisch. Er darf den CAS-Lifecycle weder beenden noch den Release-Monitor abschalten.

## Sensor-Gate

`GetDetectedGroups()` muss ein gueltiges MOOSE-Set liefern. `nil` wird nicht mehr als 'zero contacts' interpretiert. Dadurch kann A8 keinen False-No-Contact-Release erzeugen, bevor die FLIGHTGROUP-eigene Detection tatsaechlich verfuegbar ist.

## PASS

PASS erst nach kontrolliertem Release, Rueckroute, physischer Heimatlandung und exact asset return. `OpsOnMission`, `Mission Started` und `Mission Executing` allein sind kein PASS.

## Artefakte

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-8.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/08-c2-routed-cas-release-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-8.ps1
```
