---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-2
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B MOOSE class/API evidence pending DCS Acceptance 2
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main
  - DCS validation before Acceptance 2 passes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 Acceptance 2 – MOOSE class evidence

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Source-verifizierter Stage-2B-Scope

| Klasse/Pfad | Status vor DCS-Test | Stage-2B-Verwendung |
|---|---|---|
| `OPSZONE OnAfterAttacked(From, Event, To, AttackerCoalition)` | `SOURCE_VERIFIED`, Stage 2A DCS-validiert | qualifizierter RED-Angriff auf den verteidigten Perimeter |
| `OPSZONE OnAfterDefeated(From, Event, To, DefeatedCoalition)` | `SOURCE_VERIFIED_PENDING_DCS` | RED ist aus dem verteidigten BLUE-Perimeter beseitigt; Stage-2B-Threat-Clear-Signal |
| `AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)` | `SOURCE_VERIFIED_PENDING_DCS` | vorhandener Jalalabad-AH-64D-CAS-Auftrag |
| `AIRWING` / `LEGION:AddMission` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener Jalalabad-AIRWING nimmt den CAS-AUFTRAG in seine Mission Queue auf |
| `SQUADRON` / `COHORT:AddMissionCapability` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener AH-64D-SQUADRON besitzt `AUFTRAG.Type.CAS` |
| `AIRWING OnAfterFlightOnMission` | `SOURCE_VERIFIED_PENDING_DCS` | reale FLIGHTGROUP-Materialisierung/Missionszuordnung |
| `AUFTRAG OnAfterExecuting` | `SOURCE_VERIFIED_PENDING_DCS` | reale CAS-Missionausführung; MissionDemand wird `ACTIVE` |
| `AUFTRAG:Cancel()` | `SOURCE_VERIFIED_PENDING_DCS` | beendet den laufenden CAS-Auftrag nach `OPSZONE Defeated(RED)` über den MOOSE-FSM-Pfad |
| `FLIGHTGROUP:_CheckGroupDone()` / `RTB()` | `SOURCE_VERIFIED_PENDING_DCS` | nach Missionsende ohne verbleibende Mission/Task geht AI zum Home-/Destination-Airbase zurück |
| `FLIGHTGROUP OnAfterRTB` | `SOURCE_VERIFIED_PENDING_DCS` | Acceptance-Nachweis des begonnenen Rückflugs |
| `FLIGHTGROUP OnAfterLanded` | `SOURCE_VERIFIED_PENDING_DCS` | Acceptance-Nachweis der Landung |
| `FLIGHTGROUP OnAfterArrived` | `SOURCE_VERIFIED_PENDING_DCS` | Acceptance-Nachweis des MOOSE-Airwing-Recovery-Lifecycles |
| `AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)` | `SOURCE_VERIFIED_PENDING_DCS` | lokale Infanterie-QRF gegen die reale RED-Gruppe aus dem OPSZONE-Scan; MOOSE-eigener Ground-Attack-Workaround statt eigener Attack-Task-Logik |
| `AUFTRAG:SetReturnToLegion(false)` | `SOURCE_VERIFIED`, bereits in OMW Ground-Return-Baselines genutzt | verhindert vorzeitige automatische Rückgabe, damit OMW den sichtbaren RTZ-Handoff explizit abnehmen kann |
| `ARMYGROUP:RTZ(Zone, Formation)` | `SOURCE_VERIFIED`, vorhandene OMW DCS-Return-Baselines | Guard/QRF nach Missionsende zum installationsbezogenen Recovery-Handoff zurückführen |
| `ARMYGROUP/OPSGROUP Returned` | `SOURCE_VERIFIED`, vorhandene OMW DCS-Return-Baselines | physische Rückkehr; MOOSE gibt das Asset anschließend an Legion/Warehouse zurück |
| `OPSGROUP:SetReturnOnOutOfAmmo(...)` / `OutOfAmmo`-Lifecycle | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | MOOSE besitzt einen nativen Leerschuss-Rückkehrpfad; Stage 2B führt keinen eigenen Ammo-Poller ein |
| `OPSGROUP:GetNelements()` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | Zahl der überlebenden physischen Elemente beim Recovery-/Loss-Settlement |
| `PATHLINE:FindByName("OMW_FlightPath")` / `PATHLINE:GetCoordinates()` | `SOURCE_VERIFIED`; OMW-FlightPath bereits in PERSONNEL-Air-Resupply DCS-validiert | owner-authored Tal-/Transitkorridor als gemeinsame Geometriequelle |
| `AUFTRAG:GetGroupWaypointIndex(...)` / `GetGroupEgressWaypointUID(...)` | `SOURCE_VERIFIED`; vorhandener OMW FlightPath-Präzedenzfall | MOOSE-Missionsroute als Einfügeanker für den Korridor |
| `FLIGHTGROUP:AddWaypoint(...)` | `SOURCE_VERIFIED`; vorhandener OMW FlightPath-Präzedenzfall | 500-m-Rechtsversatz outbound/return, 500 ft AGL, ohne Koordinatenkopie |
| `AUFTRAG OnAfterSuccess` / `OnAfterFailed` | `SOURCE_VERIFIED_PENDING_DCS` | terminaler MissionDemand-Status nach MOOSE-Abschluss/Fehlschlag |

Die offizielle MOOSE-Missionssammlung wurde für `GROUNDATTACK` durchsucht; es wurde dabei kein belastbarer Demo-Nachweis gefunden. Deshalb wird für diesen Pfad ausschließlich der tatsächlich gepinnte `Moose.lua` als API-/Semantiknachweis verwendet. Es wird kein nicht gefundener Demo-Test behauptet.

## Verifizierte Threat-Clear-Semantik

Der gepinnte `OPSZONE`-FSM definiert:

```text
Attacked -> Defeated -> Guarded
```

Für eine BLUE-owned Zone gilt im relevanten Pfad: bleibt BLUE im Perimeter und ist RED nicht mehr vorhanden, erzeugt MOOSE `Defeated(RED)`. Stage 2B verwendet genau diesen Framework-Zustandswechsel als Threat-Clear-Signal. Ein separater OMW-Präsenzscanner wird nicht eingeführt.

## Verifizierte CAS-Abschluss-Semantik

`AUFTRAG:NewCAS(...)` ist im gepinnten Source aus einer ORBIT-Mission abgeleitet und besitzt zusätzlich `EngageTargetsInZone`. Deshalb endet eine CAS-Mission nicht automatisch nur deshalb, weil aktuell keine Ziele mehr vorhanden sind.

Stage 2B koppelt deshalb die vorhandenen MOOSE-Lifecycles:

```text
OPSZONE Defeated(RED)
-> AUFTRAG:Cancel()
-> FLIGHTGROUP has no remaining mission/task
-> MOOSE RTB
-> Landed
-> Arrived / AIRWING recovery
```

Diese Kette ist source-verifiziert, aber für die neue Stage-2B-Komposition noch `PENDING_DCS`.

## Verifizierter Ground-Return-Scope

Die vorhandenen OMW Ground-Resupply-Acceptances haben bereits den expliziten MOOSE-Pfad nachgewiesen:

```text
mission end/cancel
-> delayed ARMYGROUP:RTZ(recovery zone, formation)
-> physical return
-> Returned
-> Warehouse AddAsset
```

Stage 2B verwendet denselben technischen Rückkehrvertrag für mobile Guard-/QRF-Infanterie und setzt den vorhandenen Fortress-`ACCESS`-Bereich ausschließlich als Materialisierungs-/Return-Handoff ein. Er bleibt ausdrücklich **keine** Security-Zone.

## CampaignState-/MOOSE-Grenze

Stage 2B korrigiert die strategische Deployment-Semantik gegenüber dem Acceptance-1-Harness:

```text
CampaignState PERSONNEL deployment
-> ReserveResource while physically deployed
-> quantity remains unchanged
-> available decreases

physical Returned
-> cancel deployment reservation
-> survivors become available again
-> consume only confirmed casualties exactly once
```

Damit wird kein bereits gebundener Soldat beim Tod ein zweites Mal vom verfügbaren Bestand abgezogen. MOOSE bleibt nur Autorität für die physische Gruppe und deren beobachtbaren Lifecycle.

## Validierungsgrenze

Alle als `PENDING_DCS` gekennzeichneten Kombinationen dürfen erst nach dem dokumentierten Acceptance-2-Lauf auf `VALIDATED`/`ACCEPTED_TECHNICAL_BASELINE` angehoben werden. Insbesondere reicht ein `CAS_EXECUTING` nicht mehr aus: Threat clear, CAS RTB/recovery, QRF/Guard-Return, Settlement und Reorder-Evaluation gehören zum Stage-2B-Abnahmescope.
