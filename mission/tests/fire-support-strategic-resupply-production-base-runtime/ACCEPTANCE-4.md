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

Der fruehere A4-Entwurf `ONGUARD -> PATROLZONE + HuntingPatrol` ist nach realem DCS-Lauf verworfen. Der spaetere A4-4-Lauf lieferte nur Teilnachweis, weil der Harness die RED-Mission-Editor-Route ueberschrieb. A4-6 pruefte erstmals die unveraenderte RED-Route zusammen mit dem vorgesehenen On-Road-QRF-Vertrag, scheiterte jedoch am Runtime-Override `Vee`. A4-7 korrigierte diesen Override und lieferte reale DCS-Evidenz fuer den beabsichtigten On-Road-/Direct-Target-Lifecycle; lediglich der Acceptance-Observer fuer die physische Rueckkehr war fehlerhaft.

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
-> MOOSE may recompute the route as the moving target changes position
-> target dead -> MOOSE Disengage -> next living incident UNIT
-> no living authorized incident UNIT remains
-> MOOSE ReturnToLegion / RTZ / Returned / Warehouse lifecycle
```

Zielautoritaet ist der vorhandene `OMW_GroundInstallationAttackIncident`-Teilnehmerbestand. Acceptance 4 implementiert keine eigene Zielsuche oder Zielwahl und keinen eigenen OMW-Strassenrouter.

## Bewegungsvertrag der motorisierten QRF

Die QRF wird strassenausgerichtet innerhalb ACCESS materialisiert. Fuer Marsch und Transit zum konkreten Ziel ist `On Road` verbindlich. `Vee` ist eine Gefechtsformation und darf den Marschvertrag weder im MissionFactory-Default noch durch einen Runtime-Override ersetzen.

Der gepinnte MOOSE-Stand verarbeitet `On Road` selbst. OMW gibt nur die Formation an; MOOSE besitzt die Routen-/Strassenlogik. Der reale A4-7-Lauf bestaetigt, dass `On Road` eine Strassenpraeferenz und keine starre Road-Lock-Garantie ist: bei beweglichen Zielen wird die Route mit aktualisierter Zielposition neu bewertet; je nach aktueller Geometrie kann der resultierende Pfad einen Strassenabschnitt verwenden oder einen direkteren Off-Road-Anteil enthalten. Fuer ummauerte FOBs wie Joyce ist dies eine bekannte DCS/MOOSE-Pathfinding-Grenze. OMW fuehrt deshalb ohne separate Owner-Freigabe keinen eigenen Gate-/Strassenrouter ein.

## RED-Fixture-Vertrag

`BadGuys_A3_JOYCE` besitzt in `OMW_Template_v24_GroundWorks_base.miz` bereits eine mehrstufige Mission-Editor-Angriffsroute. Der Harness darf die Gruppe nach dem Guard-Gate nur aktivieren und muss diese Route unangetastet lassen. Ein PASS verlangt mindestens 25 m reale Fixture-Bewegung nach Aktivierung.

## PASS-Kriterien

1. `BadGuys_A3_JOYCE` wird aktiviert und bewegt sich mindestens 25 m auf der vorhandenen Mission-Editor-Route; der Harness ersetzt die Route nicht.
2. Joyce erzeugt genau einen QRF-Demand aus physischer `PROXIMITY_INTRUSION`-Evidenz.
3. Die QRF materialisiert innerhalb `ZON_BLUE_GND_JOYCE_ACCESS` und ist dort strassenausgerichtet.
4. Die erste QRF-Mission ist `AUFTRAG.Type.ONGUARD`; sie dient nur der MOOSE-Rekrutierung/Materialisierung.
5. Dieselbe physische `ARMYGROUP` wird an konkrete lebende RED-`UNIT`-Objekte des aktiven Incidents gebunden.
6. Der motorisierte Anmarsch verwendet nachweislich MOOSE `EngageTarget(..., "On Road")`; `On Road` ist road-preferred und nicht road-locked.
7. Mindestens zwei unterschiedliche konkrete RED-Units werden nacheinander durch `ARMYGROUP:EngageTarget()` akquiriert.
8. `BadGuys_A3_JOYCE` wird vollstaendig beseitigt.
9. Acceptance 4 erzeugt keine taktische Release-Aktion. Die Rueckkehr muss aus der produktiven Bedingung "keine lebenden autorisierten Incident-Ziele mehr" entstehen.
10. Perimeter-Clear oder Incident-Close allein duerfen keine vorzeitige Rueckkehr ausloesen.
11. Danach werden die oeffentlichen MOOSE-ARMYGROUP-FSM-Callbacks `OnAfterRTZ` und `OnAfterReturned` beobachtet; `Returned` ist fuer PASS zwingend.
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

A4-6 ist deshalb **FAIL fuer den QRF-Bewegungsvertrag** und nicht `VALIDATED`. Der Lauf beweist nicht, dass MOOSE `EngageTarget(..., "On Road")` auf Joyce versagt; diese Variante wurde im realen Lauf wegen des Runtime-Overrides gar nicht ausgefuehrt.

## A4-7 lokaler Build vom 14.09.2026 - VERIFIED_LOCAL_BUILD

Der Projektinhaber hat auf folgendem Source-Commit real lokal gebaut:

```text
ab3b53a07b8cdee024e23427cd8f47db8e7d9ced
```

Builder-/Schema-Stand:

```text
Production Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-17
QRF Runtime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13
QRF Mission Factory: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8
Acceptance Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-7
```

Verifizierte lokale Hashes:

```text
Production builder SHA-256:
9D65F27B869AB2AA24FACB557213D47204ADD612F1956331605D9408EF667982

Production bundle SHA-256:
BE593C53324938B6BA02CCD2830230E313B21F84D528BC77CBC6BA85C24F8A0B

Acceptance source SHA-256:
475EA70AC3CB1B6B42634EE7BB22D4033DA2DA952F70E88DF4FEE0EBABDBFB7D

Acceptance builder SHA-256:
57BA916366FF9632AD2C618B7679982B2ED1BDF92C13B787D64CA0E8A54356B4

Acceptance bundle SHA-256:
8DD1F21EF978CF46F4396F23C87E22835F0361A3DC9254D86C8E1E767C7BAE20
```

## A4-7 Realtest vom 14.09.2026 - PRODUCT LIFECYCLE PASS / HARNESS RETURN OBSERVER FAIL

Realer DCS-Lauf mit:

```text
DCS: 2.9.29.27468
Mission: OMW_Template_v24_GroundWorks_base.miz
Source commit: ab3b53a07b8cdee024e23427cd8f47db8e7d9ced
Acceptance bundle SHA-256: 8DD1F21EF978CF46F4396F23C87E22835F0361A3DC9254D86C8E1E767C7BAE20
Runtime log: dcs(20260914-161903).log
Debrief: debrief(20260914-161903).log
```

Beobachtete und geloggte Produkt-Evidenz:

```text
- RED fixture follows the existing Mission Editor route.
- QRF materializes road-aligned inside ZON_BLUE_GND_JOYCE_ACCESS.
- direct target acquisitions use formation=On Road.
- at least three concrete RED UNIT targets are acquired in sequence.
- the hostile fixture is cleared.
- production logs QRF_NO_LIVING_INCIDENT_TARGETS_IN_TACTICAL_ZONE -> MOOSE ReturnToLegion.
- project owner visually observes the QRF physically driving back to the FOB and despawning there.
```

Die Screenshots zeigen zugleich die reale Road-Preferred-Semantik: MOOSE verwendet je nach aktueller Zielposition teilweise Strassenabschnitte und teilweise direktere Abschnitte. Bei neuer Zielposition kann sich diese Routenentscheidung aendern. Das ist fuer Joyce mit vielen HESCO-Waenden nicht ideal, wird aber nicht durch einen projektspezifischen Router uebersteuert.

Der A4-7-Harness meldete trotzdem am Ende `TIMEOUT_INCOMPLETE_QRF_DIRECT_TARGET_CHAIN`, weil sein Return-Observer die ARMYGROUP-Zustaende alle 5 Sekunden pollte (`IsReturning()` beziehungsweise `GetState()=="Returned"`). Diese Polling-Logik ist fuer den kurzen bzw. anschliessend durch Warehouse-Reintegration bereinigten `Returned`-Lifecycle nicht belastbar. Das ist ein **Acceptance-Harness-Defekt**, kein beobachteter Produktfehler.

A4-7 wird deshalb noch nicht als vollstaendig `VALIDATED` markiert. Seine reale DCS-Evidenz bestaetigt jedoch den produktiven Direct-Target-, On-Road- und physischen Return-/Despawn-Lifecycle.

## Korrektur A4-8

A4-8 aendert ausschliesslich den Acceptance-Observer. Produktionscode bleibt unveraendert.

Der gepinnte MOOSE-Stand stellt fuer `ARMYGROUP` die oeffentlichen FSM-Callbacks

```text
OnAfterRTZ
OnAfterReturned
```

bereit. `ARMYGROUP:onafterRTZ` fuehrt die Gruppe zur Homezone; sobald sie dort ist, loest MOOSE `Returned()` aus. `ARMYGROUP:onafterReturned` fuegt die Gruppe anschliessend ueber die Legion wieder dem Warehouse-Bestand hinzu. A4-8 haengt sich daher ereignisgetrieben an genau diese oeffentlichen Callbacks und bewahrt eventuell vorhandene vorherige Callback-Funktionen.

A4-8 verwendet **keine** eigene Rueckkehrsteuerung und **keine** Polling-Ersatzlogik. Fuer PASS ist `OnAfterReturned` zwingend; `OnAfterRTZ` wird zusaetzlich als Beginn der MOOSE-Rueckkehr protokolliert.

Naechster Builder:

```text
Production Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-17
QRF Runtime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-13
QRF Mission Factory: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-8
Acceptance Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-4-8
```

Status: `DRAFT`, noch **nicht DCS-validiert**.

`VALIDATED` darf erst nach realem DCS-Test des exakt lokal gebauten A4-8-Bundles gesetzt werden.
