---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE-4
status: DRAFT
document_class: ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Joyce-focused DCS acceptance of the owner-approved direct-target QRF lifecycle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Production Base Acceptance 4 - QRF Direct Target Cycle

Ziel ist der Joyce-Regressionsfall gegen den mit dem historischen Honaker-Lifecycle reconcilierten QRF-Vertrag zu pruefen, ohne Acceptance 3 umzudeuten.

Der vorherige A4-Entwurf `ONGUARD -> PATROLZONE + HuntingPatrol` wurde am 13.09.2026 im realen DCS-Lauf verworfen: Die QRF fuhr nach veralteter Einsatzgeometrie beziehungsweise blieb im Gelaende gebunden, waehrend die RED-Fixture weiter zum FOB lief. Dieser Lauf ist negative Design-Evidenz, kein Acceptance-PASS.

Aktueller Vertrag:

```text
physical installation alarm
-> exactly one local QRF demand
-> existing ACCESS-only materialization
-> ONGUARD only as recruitment/materialization anchor
-> same physical ARMYGROUP
-> nearest living known incident UNIT inside site-local 5-NM tactical zone
-> MOOSE ARMYGROUP:EngageTarget(concrete UNIT)
-> MOOSE tracks the moving target
-> target dead -> MOOSE Disengage -> next living incident UNIT
-> no living authorized incident UNIT remains
-> mission completion/cancel
-> MOOSE ReturnToLegion / RTZ / Returned / Warehouse lifecycle
```

Zielautoritaet ist der vorhandene `OMW_GroundInstallationAttackIncident`-Teilnehmerbestand. Acceptance 4 implementiert keine eigene Zielsuche oder Zielwahl.

## PASS-Kriterien

1. Joyce erzeugt genau einen QRF-Demand aus physischer `PROXIMITY_INTRUSION`-Evidenz.
2. Die QRF materialisiert innerhalb `ZON_BLUE_GND_JOYCE_ACCESS`.
3. Die erste QRF-Mission ist `AUFTRAG.Type.ONGUARD`; sie dient nur der MOOSE-Rekrutierung/Materialisierung.
4. Dieselbe physische `ARMYGROUP` wird an konkrete lebende RED-`UNIT`-Objekte des aktiven Incidents gebunden.
5. Mindestens zwei unterschiedliche konkrete RED-Units werden nacheinander durch `ARMYGROUP:EngageTarget()` akquiriert. Damit wird der Target-Death/Reacquire-Pfad nachgewiesen.
6. Die physische `BadGuys_A3_JOYCE`-Fixture wird vollstaendig beseitigt.
7. Acceptance 4 ruft weder `ExpireDemand()` noch eine andere taktische Release-Funktion auf. Die Rueckkehr muss aus der produktiven Bedingung "keine lebenden autorisierten Incident-Ziele mehr" entstehen.
8. Perimeter-Clear oder Incident-Close allein duerfen keine vorzeitige Rueckkehr ausloesen.
9. Danach wird MOOSE `ReturnToLegion` / `RTZ` / `Returned` beobachtet.
10. Kein `GROUNDATTACK`, kein `PATROLZONE`, kein `HuntingPatrol`, kein produktiver OMW-Target-Scheduler, kein Teleport und keine neue Mission-Editor-Zone.

`VALIDATED` darf erst nach realem DCS-Test des exakt gebauten Commits/Bundles gesetzt werden.
