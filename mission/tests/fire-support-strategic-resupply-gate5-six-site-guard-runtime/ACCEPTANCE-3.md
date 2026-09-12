---
document_id: OMW-FIRE-SUPPORT-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 DCS regression of the productive Guard PATHLINE materialization adapter
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 33c900bea65b53159f8ebed5690a0a5139af164f
validated_in_dcs: true
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: 33c900bea65b53159f8ebed5690a0a5139af164f
acceptance_mission: OMW_Template_v24_GroundWorks_base.miz
acceptance_mission_sha256: 865BCB91FD3EF8F81E71E3ACEF0E0E0A7BF74737117549F7E059815C94929F91
dcs_version: 2.9.29.27468
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
bundle_sha256: 1DA151FB71A631C13A151E23A0C25DBD788E282E060C480BC07DAE1B98C61E02
materializer_sha256: 6FA28519564377ADF40175F9F1DFC1607B2ED693DF30AD6DD57AF92ED4B7D4E2
acceptance_source_sha256: A562A4B9379F91E962C538FBD7B3825701C1C78EE0AD881F7EC7C49EAE175410
---

# Gate 5 - Guard Production Materializer Acceptance 3

## Ergebnis

Gate 5 Acceptance 3 ist fuer den festgelegten Foundation-Scope PASS. Der Owner-local Builder-5-Lauf wurde auf Commit `33c900bea65b53159f8ebed5690a0a5139af164f` erzeugt; `MIZ mutation: false` wurde bestaetigt.

Der reale DCS-Lauf auf DCS `2.9.29.27468` bestaetigte fuer alle sechs Sites: produktiven Guard-Materializer, PATHLINE-ausgerichtete Materialisierung, alive Guard, gestartete Route, 2.00 m Spawnabstand und mindestens 25 m Bewegung. Die Testtelemetrie endete mit `6/6 Guards production materializer >=25 m movement observed`.

## Ausnahmegrenze

Die Owner-Freigabe bleibt ausschliesslich auf die exakte Guard-Materialisierung am privaten MOOSE-WAREHOUSE-Spawn-Schritt begrenzt. MOOSE BRIGADE/WAREHOUSE sowie PLATOON/ARMYGROUP/AUFTRAG bleiben autoritativ. Keine eigene Asset-Selektion, Queue/Retry-Queue oder Wiederverwendung fuer Convoy/QRF/ARTY/CAS/Resupply ohne neue Owner-Freigabe. `ZON_BLUE_GND_*_ACCESS` ist kein Guard-Vertrag.

## Patrol-Wiederholung

Im Lauf wurde beobachtet, dass Wright weiterpatrouillierte, waehrend andere Sites nach der ersten Runde teilweise pausierten. Der Projektinhaber hat dieses Verhalten am 12.09.2026 fuer den aktuellen Foundation-Scope als PASS akzeptiert. Die bestehende Routing-Implementierung bleibt unveraendert.

Spaeteres TODO nach Fertigstellung der allgemeinen Base: `CONTROLLABLE:PatrolRoute()` und Template-Waypoint-Vertrag sowie die Abbildung der owner-authored Guard-PATHLINE auf den MOOSE-Template-Route-Vertrag pruefen und ueber mehrere Patrol-Zyklen in DCS regressionspruefen.

## Statusgrenze

```text
OWNER-LOCAL BUILD: PASS
DCS ACCEPTANCE-3: PASS
PRODUCTIVE GUARD MATERIALIZER: VALIDATED fuer diesen Scope
CONTINUOUS MULTI-CYCLE PATROL REFINEMENT: DEFERRED TODO
GATE 5: ACCEPTED
```
