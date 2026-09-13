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

Der fruehere A4-Entwurf `ONGUARD -> PATROLZONE + HuntingPatrol` ist nach realem DCS-Lauf verworfen. Der spaetere A4-4-Lauf lieferte nur Teilnachweis, weil der Harness die RED-Mission-Editor-Route ueberschrieb. A4-6 pruefte erstmals die unveraenderte RED-Route zusammen mit dem vorgesehenen On-Road-QRF-Vertrag, scheiterte jedoch am Runtime-Override `Vee`.

Aktueller Vertrag:

```text
physical installation alarm
-> exactly one local QRF demand
-> existing ACCESS-only road-aligned materialization
-> ONGUARD only as recruitment/materialization anchor
-> same physical ARMYGROUP
-> nearest living known incident UNIT inside site-local 5-NM tactical zone
-> MOOSE ARMYGROUP:EngageTarget(concrete UNIT, speed, "On Road")
-> road-preferred motorized march/transit under MOOSE routing
-> MOOSE leaves the road for the final off-road target approach when required
-> target dead -> MOOSE Disengage -> next living incident UNIT
-> no living authorized incident UNIT remains
-> MOOSE ReturnToLegion / RTZ / Returned / Warehouse lifecycle
```

Zielautoritaet ist der vorhandene `OMW_GroundInstallationAttackIncident`-Teilnehmerbestand. Acceptance 4 implementiert keine eigene Zielsuche oder Zielwahl und keinen eigenen OMW-Strassenrouter.

## Bewegungsvertrag der motorisierten QRF

Die QRF wird strassenausgerichtet innerhalb ACCESS materialisiert. Fuer Marsch und Transit zum konkreten Ziel ist `On Road` verbindlich. `Vee` ist eine Gefechtsformation und darf den Marschvertrag weder im MissionFactory-Default noch durch einen Runtime-Override ersetzen.

Der gepinnte MOOSE-Stand verarbeitet `On Road` selbst. OMW gibt nur die Formation an; MOOSE besitzt die Routen-/Strassenlogik und kann fuer den finalen Anflug zu einem abseits der Strasse liegenden Ziel Off Road verlassen.

## RED-Fixture-Vertrag

`BadGuys_A3_JOYCE` besitzt in `OMW_Template_v24_GroundWorks_base.miz` bereits eine mehrstufige Mission-Editor-Angriffsroute. Der Harness darf die Gruppe nach dem Guard-Gate nur aktivieren und muss diese Route unangetastet lassen. Ein PASS verlangt mindestens 25 m reale Fixture-Bewegung nach Aktivierung.

## PASS-Kriterien

1. `BadGuys_A3_JOYCE` wird aktiviert und bewegt sich mindestens 25 m auf der vorhandenen Mission-Editor-Route; der Harness ersetzt die Route nicht.
2. Joyce erzeugt genau einen QRF-Demand aus physischer `PROXIMITY_INTRUSION`-Evidenz.
3. Die QRF materialisiert innerhalb `ZON_BLUE_GND_JOYCE_ACCESS` und ist dort strassenausgerichtet.
4. Die erste QRF-Mission ist `AUFTRAG.Type.ONGUARD`; sie dient nur der MOOSE-Rekrutierung/Materialisierung.
5. Dieselbe physische `ARMYGROUP` wird an konkrete lebende RED-`UNIT`-Objekte des aktiven Incidents gebunden.
6. Der motorisierte Anmarsch verwendet nachweislich MOOSE `EngageTarget(..., "On Road")`; sichtbar soll die QRF vorhandene Strassen bevorzugen und erst fuer den notwendigen Endanflug zum konkreten Ziel die Strasse verlassen.
7. Mindestens zwei unterschiedliche konkrete RED-Units werden nacheinander durch `ARMYGROUP:EngageTarget()` akquiriert.
8. `BadGuys_A3_JOYCE` wird vollstaendig beseitigt.
9. Acceptance 4 erzeugt keine taktische Release-Aktion. Die Rueckkehr muss aus der produktiven Bedingung "keine lebenden autorisierten Incident-Ziele mehr" entstehen.
10. Perimeter-Clear oder Incident-Close allein duerfen keine vorzeitige Rueckkehr ausloesen.
11. Danach wird MOOSE `ReturnToLegion` / `RTZ` / `Returned` beobachtet.
12. Kein `GROUNDATTACK`, kein `PATROLZONE`, kein `HuntingPatrol`, kein eigener QRF-Routen-Scheduler, kein Teleport und keine neue Mission-Editor-Zone.

## A4-4 Realtest vom 13.09.2026

A4-4 auf Source-Commit `ed43e14f9f0fde6d6dd9e46671600519a1de415a` zeigte den direkten QRF-Target-Cycle, mehrere konkrete Zielakquisitionen, Fixture-Clearance und MOOSE-Rueckkehr. Er gilt nur als `PARTIAL_RUNTIME_EVIDENCE`, weil der Harness die vorhandene RED-Mission-Editor-Route nach Aktivierung durch eine kuenstliche Intrusion-Route ersetzte. Kein vollstaendiger Acceptance-PASS und nicht `VALIDATED`.

## A4-6 Realtest vom 13.09.2026 - FAIL QRF road movement

Der lokal verifizierte A4-6-Build auf Source-Commit

```text
7c32cbccbad9d8a3681c86c80925c4797a42b330
```

wurde real in DCS ausgefuehrt. Positiv war, dass die RED-Fixture auf ihrer vorhandenen Mission-Editor-Route lief und die QRF strassenausgerichtet in ACCESS materialisiert wurde. Der sichtbare QRF-Anmarsch folgte danach jedoch nicht der Strasse.

Die Log-Evidenz identifiziert die Ursache eindeutig: Beim ersten direkten Target-Acquire protokollierte der produktive QRF-Code `formation=Vee`; auch die spaetere Reacquisition lief mit `formation=Vee`. Damit wurde der beabsichtigte `On Road`-Default der QRF MissionFactory von `OMW_FireSupStratResupply_QrfRuntime.lua` ueberschrieben.

Der defekte Runtime-Vertrag war:

```lua
local QRF_ENGAGE_FORMATION = "Vee"
...
engageFormation = QRF_ENGAGE_FORMATION
```

A4-6 ist deshalb **FAIL fuer den QRF-Bewegungsvertrag** und nicht `VALIDATED`. Der Lauf beweist nicht, dass MOOSE `EngageTarget(..., "On Road")` auf Joyce versagt; diese Variante wurde im realen Lauf wegen des Runtime-Overrides gar nicht ausgefuehrt.

## Korrektur A4-7

`OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13` setzt explizit:

```lua
local QRF_ENGAGE_FORMATION = "On Road"
```

und gibt diesen Wert weiterhin ueber `engageFormation=QRF_ENGAGE_FORMATION` an die MissionFactory. Runtime-Test, Acceptance-Contract-Test, Production Builder und Acceptance Builder sperren nun einen erneuten `Vee`-Override.

Naechster Builder:

```text
Production Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-17
QRF Runtime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13
QRF Mission Factory: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8
Acceptance Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-7
```

Status: `DRAFT`, noch **nicht DCS-validiert**.

`VALIDATED` darf erst nach realem DCS-Test des exakt gebauten A4-7-Commits/Bundles mit unveraenderter RED-Mission-Editor-Route und sichtbar funktionierendem MOOSE-`On Road`-Marschvertrag gesetzt werden.
