---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - reconciled Stage 3 combined Honaker attack, local response, Wright fire support and Jalalabad Air-AMMO full-response acceptance contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1 for future full-response runs
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
base_status:
  qrf: ACCEPTED_TECHNICAL_BASELINE
  guard: ACCEPTED_TECHNICAL_BASELINE
---

# Stage 3 Acceptance 2 – reconciled full response

## 1. Zweck

Acceptance 2 ersetzt fuer kuenftige Full-Response-Laeufe die veraltete Guard-/QRF-Semantik aus Acceptance 1. Sie fuehrt keinen neuen lokalen Ground-Response-Vertrag ein, sondern verwendet die bereits in DCS akzeptierten Production-Base-Baselines.

Die zu pruefende Gesamtfolge lautet:

```text
physical RED intrusion at COP Honaker
-> production installation alarm / incident
-> incident-local GUARD materializes locally
-> production QRF direct-target response
-> Wright ARTY support
-> local M1083 rearm
-> strategic AMMO reorder
-> Jalalabad CH-47 MOOSE OPSTRANSPORT Air-AMMO resupply
-> existing CAS support/recovery contract
-> all participating physical assets complete their own MOOSE lifecycle
```

## 2. Verbindliche geerbte Ground-Baselines

### 2.1 GUARD

Production Base Acceptance 5 ist die technische Referenz fuer GUARD.

```text
NORMAL
-> no physical Guard
-> no Guard demand

qualified RED perimeter presence
-> installation incident
-> GUARD demand INSTALLATION_ATTACK_LOCAL_GUARD
-> local MOOSE AUFTRAG:NewONGUARD(...)
-> no persistent PATHLINE patrol
-> no proactive SetEngageDetected()
-> no OMW EngageTarget cycle

incident close
-> Guard demand Cancel
-> MOOSE ReturnToLegion / RTZ / Returned
```

Acceptance 2 darf weder eine persistente Guard-Mission beim Missionsstart erzeugen noch den historischen PATHLINE-Rundlauf wieder einfuehren.

### 2.2 QRF

Production Base Acceptance 4 / A4-8 ist die technische Referenz fuer QRF.

```text
incident
-> INSTALLATION_ATTACK_INITIAL_QRF
-> AUFTRAG:NewONGUARD(initial threat coordinate) as recruitment/materialization anchor only
-> same physical ARMYGROUP
-> nearest living authorized incident UNIT in the 5-NM tactical zone
-> ARMYGROUP:EngageTarget(concrete UNIT, speed, "On Road")
-> target dead -> MOOSE Disengage -> reacquire
-> no living authorized incident target remains
-> mission Cancel / SetReturnToLegion(true)
-> RTZ / Returned / Warehouse lifecycle
```

Acceptance 2 darf insbesondere nicht verwenden:

```text
SetEngageDetected as QRF target authority
PATROLZONE / HuntingPatrol
GROUNDATTACK
custom QRF target scheduler
custom QRF road router
incident-close-only QRF release
perimeter-clear-only QRF release
supported-element/C2 release as replacement for target exhaustion
```

## 3. Honaker Alarm- und Tactical-Semantik

Fuer `COP_HONAKER` gilt die aktuelle SiteRegistry-Baseline:

```text
alarm anchor: WH_BLUE_GND_HONAKER
alarm radius: 2743.2 m / 9000 ft
QRF tactical area: 5 NM
```

Der Alarmperimeter ist ausschliesslich Detection-/Response-Trigger und keine WEZ, kein Battlespace und keine Mission-Endbedingung.

Die historische Acceptance-1-Konstante `SECURITY_RADIUS_M = 1000` darf fuer den produktiven Honaker-Alarm nicht weiterverwendet werden.

## 4. Keine doppelte Ground-Response-Implementierung

Der neue Full-Response-Harness muss die Production-Base-Implementierung konsumieren beziehungsweise beobachten. Er darf GUARD oder QRF nicht parallel erneut implementieren.

Verbindlich zu wiederverwenden sind die aktuell akzeptierten Produktionspfade unter anderem:

```text
OMW_FireSupStratResupply_Base
OMW_FireSupStratResupply_InstallationIncidentRuntime
OMW_FireSupStratResupply_InstallationIncidentBridge
OMW_FireSupStratResupply_PerimeterRuntime
OMW_FireSupStratResupply_PerimeterBridge
OMW_FobThreatOpsZoneAdapter
OMW_FireSupStratResupply_GuardRuntime
OMW_FireSupStratResupply_GuardMissionFactory
OMW_FireSupStratResupply_QrfRuntime
OMW_FireSupStratResupply_QrfMissionFactory
OMW_GroundRoadSpawnAdapter
```

Acceptance-Code darf beobachten, Teststimuli erzeugen und Ergebnisbedingungen pruefen. Er darf die Production-Base-Autoritaet nicht durch eigene Missionen oder eigene Target-Selektion ersetzen.

## 5. ARTY-Vertrag

Der bisherige Stage-3-Wright-Pfad bleibt fuer Acceptance 2 fachlich erhalten, soweit er nicht mit den akzeptierten Ground-Baselines kollidiert:

```text
C2-observed eligible RED ground target
-> Wright L118 real Fire At Point
-> physical EVENTS.Shot evidence
-> physical ammunition decreases
-> local M1083 rearm
-> CampaignState AMMO consumption exactly once
-> Wright reaches strategic reorder threshold
```

Wenn CAS physisch ON STATION ist, darf keine neue ARTY-Fire-Mission in denselben taktischen Raum eingereiht werden. Bereits laufende MOOSE-Fire-Lifecycles werden nicht kuenstlich durch den Harness abgebrochen.

Die historische ungebremste `FIRE_SUPPORT_REARMED_CONTINUATION`-Wiederholung ist keine akzeptierte allgemeine Policy. Acceptance 2 darf nur frische, noch nicht bereits fuer denselben Zyklus abgearbeitete C2-Kontakte fuer einen Follow-on-Fire-Demand verwenden.

## 6. CAS-Vertrag

Acceptance 2 veraendert die bereits dokumentierte Stage-3-CAS-Geometrie und Recovery-Semantik nicht stillschweigend.

Weiterhin gilt fuer den Full-Response-Test:

```text
Jalalabad
-> configured logical OMW_FlightPath
-> WEST
-> dynamic CAS ingress / mission area / egress
-> WEST reverse
-> configured logical OMW_FlightPath reverse
-> Jalalabad
```

CAS verwendet sein eigenes MOOSE/DCS-Detektionsbild. Kein `KnowTarget()`-Inject und kein raw RED count als CAS-Release-Autoritaet.

Der bestehende supported-element/no-contact CAS-Closure-Vertrag bleibt fuer CAS separat erhalten. Er darf jedoch nicht mehr als QRF-Release-Autoritaet missbraucht werden.

## 7. Strategic Air-AMMO / OPSTRANSPORT

Der bestehende interne MOOSE-OPSTRANSPORT-Pfad bleibt unveraendert Gegenstand der Full-Response-Acceptance:

```text
Wright AMMO reaches reorder threshold
-> exactly one strategic RESUPPLY demand
-> CampaignState transfer reservation
-> MOOSE OPSTRANSPORT
-> Jalalabad CH-47 recruitment
-> STORAGE load / transport / unload / Delivered
-> configured OMW_FlightPath outbound
-> configured OMW_FlightPath reverse return
-> physical Jalalabad landing / LEGION return
-> CampaignState delivered exactly once
```

CampaignState bleibt strategische Ressourcenautoritaet. MOOSE bleibt operative Transport- und physische Lifecycle-Autoritaet.

## 8. Acceptance-2 PASS-Kriterien

Ein Gesamt-PASS benoetigt mindestens:

```text
1. no physical Honaker Guard before qualified alarm
2. physical RED intrusion qualifies through the production perimeter path
3. exactly one installation incident for the attack lifecycle
4. exactly one incident-local Guard demand
5. Guard materializes locally on MOOSE ONGUARD without persistent PATHLINE patrol
6. exactly one initial QRF demand
7. QRF materializes through the accepted ACCESS / GroundRoadSpawnAdapter path
8. QRF uses direct concrete incident UNIT targets and On Road transit
9. QRF retargets surviving authorized incident targets as required
10. Guard returns after authoritative incident close
11. QRF is not cancelled merely by perimeter clear or incident close
12. QRF returns after its own target-exhaustion lifecycle
13. Wright ARTY produces real physical shot evidence and ammunition decrease
14. local M1083 rearm completes and returns
15. strategic AMMO reorder creates exactly one active RESUPPLY demand
16. CH-47 OPSTRANSPORT completes physical STORAGE delivery
17. Wright / Jalalabad strategic AMMO settlement is correct and exactly once
18. CAS follows its own accepted task / release / recovery contract
19. no acceptance-owned replacement routing, target authority or resource authority
```

## 9. Explizit verbotene Regressionen

```text
persistent Guard on mission start
Guard PATHLINE repeated circuit
Guard SetEngageDetected
1000-m Honaker production alarm radius
QRF SetEngageDetected target authority
QRF supported-element release
QRF incident-close release
QRF perimeter-clear release
QRF Vee march default
PATROLZONE/HuntingPatrol for QRF
GROUNDATTACK for QRF
custom QRF target scheduler
custom QRF road router
Acceptance-owned ExpireDemand/Cancel as tactical completion
Mission Editor alarm-zone proliferation
```

## 10. Implementierungsgrenze

Der vorhandene Acceptance-1-Harness `src/01-honaker-wright-full-response-acceptance.lua` und Builder `tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1` enthalten historische Guard-/QRF-Annahmen und duerfen nicht fuer einen neuen DCS-PASS wiederverwendet werden, bevor sie reconciliert oder durch Acceptance-2-Artefakte ersetzt wurden.

Insbesondere sind dort derzeit noch nachweisbar:

```text
SECURITY_RADIUS_M = 1000
persistent Guard creation from brigade OnAfterStart
Guard SetEngageDetected
PATHLINE repeated Guard circuit
QRF SetEngageDetected
QRF recovery coupled to CAS supported-element release
```

Diese Marker sind fuer Acceptance 2 Anti-Regression-Fails.

## 11. Naechster Implementierungsschritt

```text
Production Base A4/A5 runtime as local Ground authority
+ existing Stage-3 ARTY/CAS/OPSTRANSPORT pieces
-> new reconciled Acceptance-2 harness
-> builder anti-regression markers
-> local build/hash provenance
-> MIZ embedding verification
-> one real DCS full-response run
```

Bis dieser neue Harness gebaut ist, bleibt Acceptance 2 `PLANNED` und `validated_in_dcs: false`.
