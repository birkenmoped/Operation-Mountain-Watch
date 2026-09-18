---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-7
status: FAILED_DCS
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - compact production Base QRF plus full rotary-wing CAS lifecycle validation
  - fail-closed owner-route binding after MOOSE provider selection
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - rejected Production Base Acceptance 6
superseded_by:
---

# Production Base Acceptance 7 – routed CAS full lifecycle

## 1. Ziel

Acceptance 7 korrigiert zwei konkrete Fehler aus A6, ohne zur alten deterministischen Stage-3-Providerbindung zurueckzukehren:

```text
A6 Fehler 1:
PASS at OpsOnMission
-> zu frueh
-> Route / Release / Recovery blieben ungeprueft

A6 Fehler 2:
MOOSE provider selection
-> kein provider-/plattformgerechtes owner-authored execution profile gebunden
-> direkter Hubschrauberflug, FuelLow-RTB und unvollstaendige Recovery
```

Der gueltige A7-Pfad lautet:

```text
physical RED attack at FOB Joyce
-> production perimeter
-> authoritative installation incident
-> production QRF direct concrete-target engagement

same support situation
-> explicit Base CAS demand
-> CasMissionFactory PATROLZONE_ENGAGE
-> AUFTRAG requires GROUP.Attribute.AIR_ATTACKHELO
-> MOOSE COMMANDER / LEGION selects eligible provider + asset
-> OnBeforeMissionAssign binds the owner-authored route profile of the provider selected by MOOSE
-> Helicopter FlightPath / WEST route
-> dynamic 3.5-NM ingress/egress gates
-> PATROLZONE + SetEngageDetected
-> FLIGHTGROUP own detection
-> supported element clear + stable own no-contact >= 30 s
-> Base/CommanderBridge Cancel path
-> reverse owner route
-> physical landing
-> LEGION/AIRWING asset returned
-> PASS
```

## 2. Autoritaet: ADR 0008 bleibt verbindlich

A7 baut **keine** OMW-eigene Provider- oder Asset-Selektion.

```text
OMW
= support requirement + mission capability / geometry / lifecycle contract

MOOSE COMMANDER / LEGION
= provider and operational asset selection

OMW route adapter
= binds the matching already-owner-authored route/lifecycle profile
  after MOOSE selected the provider
```

Das ist von der verworfenen Stage-3-Fixture zu unterscheiden:

```text
VERBOTEN:
OMW -> choose Jalalabad -> choose AH-64D -> dispatch

A7:
OMW -> require PATROLZONE + attack-helicopter capability
MOOSE -> select eligible provider/asset
A7 -> validate that the selected provider has a known owner-route profile
```

## 3. Warum PATROLZONE + attack-helicopter capability

Der gepinnte MOOSE-Stand besitzt:

```text
AUFTRAG:SetRequiredAttribute(...)
COMMANDER:RecruitAssetsForMission(...)
LEGION._CohortCan(...)
COHORT mission capability / generalized attribute
```

A7 nutzt deshalb die MOOSE-eigene Capability-Selektion. Die generische CAS Factory wurde nur um die Weitergabe von `requiredAttributes` / `requiredProperties` an die vorhandenen MOOSE-AUFTRAG-Filter erweitert.

Fuer diesen Test gilt:

```text
mission type:
PATROLZONE

required generalized attribute:
GROUP.Attribute.AIR_ATTACKHELO
```

Damit wird kein bestimmtes AIRWING, keine SQUADRON und kein konkretes Luftfahrzeug durch A7 ausgewaehlt.

## 4. Fail-closed Route-Profil

Die im Projekt aktuell belegte Kunar-Rotary-CAS-Owner-Route ist:

```text
configured OMW_FlightPath variant
-> OMW_FlightPath_WEST
-> dynamic CAS ingress gate
-> dynamic CAS mission area
-> dynamic CAS egress gate
-> OMW_FlightPath_WEST reverse
-> configured OMW_FlightPath variant reverse
-> provider home
```

A7 hat Route-Profil-Metadaten fuer den bereits dokumentierten Jalalabad AIRWING. Das ist **keine Provider-Auswahl**. Wird dieser Provider von MOOSE ausgewaehlt, kann sein bekanntes Owner-Profil gebunden werden.

Waehlt MOOSE einen anderen operativ faehigen Provider, fuer den im aktuellen Projektstand noch kein owner-authored Route-Profil vorhanden ist, gilt:

```text
OnBeforeMissionAssign
-> SELECTED_PROVIDER_HAS_NO_OWNER_ROUTE_PROFILE
-> transition rejected
-> FAIL
-> no physical CAS dispatch
```

Es gibt **keinen** Direct-Line-Fallback.

## 5. FuelLow und Missionsende

Ein A7-PASS darf nicht durch FuelLow/Bingo entstehen.

Normaler Abschluss:

```text
FLIGHTGROUP physically on station
AND
supported element has no living known incident attackers
AND
FLIGHTGROUP:GetDetectedGroups() contains no engagement-eligible contact
AND
own no-contact picture stable >= 30 s
-> controlled CAS release
-> reverse owner route recovery
```

`FuelLow` vor physischer Rueckgabe ist Regression-Fail.

## 6. PASS

PASS erfordert gleichzeitig:

```text
1. Joyce physical RED attack
2. production installation incident
3. production QRF materialization
4. QRF ARMYGROUP direct concrete-target engagement
5. Base CAS demand
6. MOOSE provider/asset selection
7. selected provider owner-route profile bound before MissionAssign completes
8. owner corridor physically installed
9. CAS physically on station
10. own stable no-contact report
11. supported-element clear
12. controlled release before FuelLow
13. reverse owner-route recovery
14. physical landing
15. LEGION/AIRWING asset returned
16. no CAS unit loss
```

`OpsOnMission` allein ist ausdruecklich **kein PASS**.

## 7. Nicht Bestandteil

```text
ARTY
ARTY rearm
strategic resupply
fixed-wing CAS lifecycle
CampaignState persistence acceptance
```

Diese Trennung ist absichtlich. A7 prueft genau die in A6 gebrochene QRF/CAS-Befehls- und Ausfuehrungskette.

## 8. Artefakte

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-7.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/07-c2-routed-cas-lifecycle-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-7.ps1
```

DCS bleibt bis zum realen Lauf `NOT_VALIDATED`.

## 9. Owner-lokaler Build-Nachweis 2026-09-18

Der Projektinhaber hat den Branchstand und den Acceptance-7-Build lokal real ausgefuehrt und folgende Provenienz zurueckgemeldet:

```text
source commit:
500974a22915be7b468ef6855f0aefbc4805b897

production builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-20
SHA-256 93DC3312E752DA7BAB75C476965BE0AFE693A6EEC62F781A63C600682039AE83

production bundle:
SHA-256 7DF23DD90ECA2C1450A6B657447D3392EA545A279E244CA0C6B343BC4224E0EF

CasMissionFactory:
SHA-256 FB49D3338A073A2EC0E68C14621FEF9DE7B2D105D94BEC9F448893C7005E1377

OMW_FlightPathNameContract.lua:
SHA-256 333E895D8BF65138C96359CE564BE8F9967F7ADDA3A33E2AE8A8726103D95855

OMW_HelicopterFlightPathCorridor.lua:
SHA-256 04D99722F0246AD261C47A90104E488FE9EF65721A647BE5CF6BAA602A1E279B

OMW_HelicopterCasTacticalCorridor.lua:
SHA-256 E8FF4C196433CFCF287EEED25EAA31640EB8013A1286359CA63984811DDE08DA

Acceptance-7 source:
SHA-256 B37E29638A07917D0993803BB7D35331FB1B23D1CB2B82A58D349BC2BF51EA0C

Acceptance-7 builder:
SHA-256 787BD80417BB53660F6978CF571A1B0CDF06E3C197174D648A2F54E84AA07BB1

Acceptance-7 bundle:
SHA-256 B3012549B3F72BBDA04A06F4C922A85E3C09EB253642C6CEB6B7356F9E59F138
```

Der unabhaengige `Get-FileHash`-Lauf des Projektinhabers bestaetigte dieselben Werte. `git status --short` zeigte ausschliesslich untracked Build-`dist`-Verzeichnisse und keine tracked lokalen Aenderungen.

Status dieses Nachweises:

```text
source/build/hash provenance: VERIFIED_LOCAL_BUILD
DCS runtime: NOT_VALIDATED
```

Die naechste Evidenz darf nur aus einem realen DCS-Lauf mit exakt diesem Acceptance-7-Bundle stammen.

## 10. DCS-Lauf 2026-09-18 – FAIL

Reale Evidenz mit Acceptance-7-Bundle SHA-256 `B3012549B3F72BBDA04A06F4C922A85E3C09EB253642C6CEB6B7356F9E59F138`:

```text
outbound owner route: observed working
QRF direct-target chain: observed working
CAS mission assignment: AW_US_JBAD_TF_SHOOTER_6_6_CAV / SQ_US_JBAD_AH64D_B_1_10_AVN
owner corridor: installed
regular CAS release: NOT observed
FuelLow/Bingo RTB: observed by owner
DCS process crash during return: observed
```

Log root cause for the missing release:

```text
A7 terminal timeout fired while the CAS mission was still STARTED/outbound:
[PRODUCTION BASE A7][FAIL] TIMEOUT ... onStation=false ... recovery=false

after this FAIL, evaluate()/updateCasLifecycle() stopped because state.failed short-circuited the monitor.
Later MOOSE changed the mission to EXECUTING, but A7 no longer evaluated own detection, supported-element clear or controlled release.
```

A7 also used a geometric `flight coordinate inside CAS zone` check as on-station authority. The pinned MOOSE source provides the correct mission-state contract: `AUFTRAG:IsExecuting()` means the first OPSGROUP reached the mission execution waypoint and is executing the mission task.

The DCS crash itself is recorded as `C0000005 ACCESS_VIOLATION` in `edCore.dll` with frames including `LinkHost::ResetLinks`, `viMovingObject::~viMovingObject` and `woLABase::~woLABase`. The available log proves an engine-level crash but does not prove that the CAS script caused it.

Acceptance 7 is therefore `FAILED_DCS` and must not be rerun.
