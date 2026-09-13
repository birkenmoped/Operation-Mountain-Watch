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

Der vorherige A4-Entwurf `ONGUARD -> PATROLZONE + HuntingPatrol` wurde am 13.09.2026 im realen DCS-Lauf verworfen. Dieser Lauf ist negative Design-Evidenz, kein Acceptance-PASS.

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

## RED-Fixture-Vertrag

`BadGuys_A3_JOYCE` besitzt in `OMW_Template_v24_GroundWorks_base.miz` bereits eine mehrstufige Mission-Editor-Angriffsroute. Der Harness darf die Gruppe nach dem Guard-Gate nur aktivieren und muss diese vorhandene Route unangetastet lassen. Der korrigierte A4-5-Builder sperrt eigene Fixture-Routen- oder Task-Zuweisungen. Ein PASS verlangt ausserdem mindestens 25 m reale Bewegung der Fixture nach ihrer Aktivierung.

## PASS-Kriterien

1. `BadGuys_A3_JOYCE` wird aktiviert und bewegt sich mindestens 25 m auf der vorhandenen Mission-Editor-Route; der Harness ersetzt die Route nicht.
2. Joyce erzeugt genau einen QRF-Demand aus physischer `PROXIMITY_INTRUSION`-Evidenz.
3. Die QRF materialisiert innerhalb `ZON_BLUE_GND_JOYCE_ACCESS`.
4. Die erste QRF-Mission ist `AUFTRAG.Type.ONGUARD`; sie dient nur der MOOSE-Rekrutierung/Materialisierung.
5. Dieselbe physische `ARMYGROUP` wird an konkrete lebende RED-`UNIT`-Objekte des aktiven Incidents gebunden.
6. Mindestens zwei unterschiedliche konkrete RED-Units werden nacheinander durch `ARMYGROUP:EngageTarget()` akquiriert.
7. Die physische `BadGuys_A3_JOYCE`-Fixture wird vollstaendig beseitigt.
8. Acceptance 4 ruft keine taktische Release-Funktion auf. Die Rueckkehr muss aus der produktiven Bedingung "keine lebenden autorisierten Incident-Ziele mehr" entstehen.
9. Perimeter-Clear oder Incident-Close allein duerfen keine vorzeitige Rueckkehr ausloesen.
10. Danach wird MOOSE `ReturnToLegion` / `RTZ` / `Returned` beobachtet.
11. Kein `GROUNDATTACK`, kein `PATROLZONE`, kein `HuntingPatrol`, kein Teleport und keine neue Mission-Editor-Zone.

## A4-4 Realtest vom 13.09.2026

Der DCS-Lauf des lokal verifizierten A4-4-Builds auf Source-Commit `ed43e14f9f0fde6d6dd9e46671600519a1de415a` zeigte den direkten QRF-Target-Cycle, mehrere konkrete Zielakquisitionen, Fixture-Clearance und MOOSE-Rueckkehr. Er gilt trotzdem nur als `PARTIAL_RUNTIME_EVIDENCE`, weil der A4-4-Harness die vorhandene RED-Mission-Editor-Route nach Aktivierung durch eine kuenstliche Intrusion-Route ersetzte. Damit wurde die vorgesehene Angriffsbewegung veraendert. Der Lauf ist daher kein vollstaendiger Acceptance-PASS und nicht `VALIDATED`.

Historischer A4-4-Build:

```text
Source commit: ed43e14f9f0fde6d6dd9e46671600519a1de415a
Production Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-15
QRF Runtime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-12
QRF Mission Factory: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-7
Installation Incident Bridge: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-INSTALLATION-INCIDENT-BRIDGE-4
Acceptance Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-4
Acceptance bundle SHA-256: 96B147C4C3E47AFB7EA3AE50E602DB87DF1CB186DF425844A6EB47D348718C0D
```

Der korrigierte naechste Builder ist `OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-5`.

Status: `DRAFT`, noch **nicht DCS-validiert**.

`VALIDATED` darf erst nach realem DCS-Test des exakt gebauten A4-5-Commits/Bundles mit unveraenderter Mission-Editor-Angriffsroute gesetzt werden.
