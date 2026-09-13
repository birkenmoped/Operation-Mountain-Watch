---
document_id: OMW-MOOSE-QRF-RESPONSE-CLEARANCE-LIFECYCLE
status: BINDING
document_class: MOOSE_INTEGRATION_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-approved local Ground QRF response-to-clearance lifecycle
  - MOOSE API/source evidence for QRF clearance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# QRF Response -> Clearance Lifecycle

## Entscheidung

Der Projektinhaber hat am 13.09.2026 die Erweiterung der lokalen Ground-QRF ausdrücklich genehmigt.

Der bisher akzeptierte Honaker-Response-Vertrag bleibt erhalten:

```text
AUFTRAG:NewONGUARD(...)
+ SetEngageDetected(5 NM, {"Ground Units"}, site-local tactical zone)
+ SetReturnToLegion(true)
```

Neu ist eine zweite MOOSE-Phase für die lokale Bereinigung des taktischen Bereichs:

```text
ONGUARD executing
-> dieselbe physische ARMYGROUP
-> AUFTRAG:NewPATROLZONE(site-local tactical zone)
-> ARMYGROUP:SetPatrolAdInfinitum(true)
-> ARMYGROUP:EnableHuntingPatrol(...)
-> explizite Supported-Element/C2-Freigabe
-> DisableHuntingPatrol()
-> SetPatrolAdInfinitum(false)
-> aktive Clearance-Mission Cancel
-> MOOSE ReturnToLegion / Ground-RTZ-Lifecycle
```

Die Erweiterung reagiert auf die DCS-Beobachtung aus Production Base Acceptance 3: Die Joyce-QRF rückte physisch korrekt an, zwei überlebende Gegner lagen jedoch etwa 50 m hinter einer Geländekante und wurden vom bisherigen `SetEngageDetected(...)`-Pfad nicht systematisch gesucht.

## MOOSE-First-Nachweis

Geprüfter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im gepinnten Source sind für den implementierten Pfad vorhanden und geprüft:

```text
AUFTRAG:NewPATROLZONE(Zone, Speed, Altitude, Formation)
AUFTRAG:GetOpsGroups()
AUFTRAG:SetReturnToLegion(...)
AUFTRAG:SetTeleport(...)
AUFTRAG:Cancel()
AUFTRAG:IsOver()

OPSGROUP:AddMission(...)
OPSGROUP:__MissionDone(...)

ARMYGROUP:SetPatrolAdInfinitum(...)
ARMYGROUP:EnableHuntingPatrol(Zone, Speed, Formation, Interval)
ARMYGROUP:DisableHuntingPatrol()
```

`EnableHuntingPatrol(...)` arbeitet nur bei einer aktuellen `PATROLZONE`-Mission. Deshalb wird die Funktion nicht parallel auf die ONGUARD-Mission aufgesetzt; stattdessen folgt eine zweite MOOSE-Mission auf derselben bereits materialisierten `ARMYGROUP`.

Die HuntingPatrol-Implementierung durchsucht die konfigurierte Zone nach gegnerischen Bodeneinheiten und übergibt Ziele an den vorhandenen `ARMYGROUP:EngageTarget(...)`-Pfad. OMW implementiert keinen eigenen Feindscan, keinen Search-Scheduler und keine alternative Targeting-Authority.

## Phasengrenze

Die Phasengrenze ist das MOOSE-AUFTRAG-Ereignis `OnAfterExecuting` der ONGUARD-Response-Mission.

Beim Übergang wird für jede der Response-Mission zugeordnete OPSGROUP genau eine Clearance-Mission erzeugt. Reihenfolge:

```text
1. PATROLZONE für dieselbe taktische Zone erstellen.
2. PATROLZONE derselben OPSGROUP mit AddMission(...) hinzufügen.
3. Patrol ad infinitum und HuntingPatrol aktivieren.
4. Erst danach ONGUARD für diese OPSGROUP über __MissionDone(...) abschließen.
```

Damit bleibt eine Folge-Mission in der MOOSE-Missionsqueue, bevor der Response-Auftrag beendet wird. Es wird keine neue Warehouse-/BRIGADE-Rekrutierung für die Clearance-Phase ausgelöst.

## Release-Vertrag

Die Erweiterung erzeugt **keine neue Release Authority**.

Zulässig bleibt ausschließlich:

```text
Supported Element / C2 -> explicit release
```

Nicht zulässig:

```text
movement >= N m -> release
perimeter clear -> release
incident close -> release
no target found -> release
elapsed timer -> release
```

Der QRF-Dispatch-Handle verfolgt deshalb die vom Response-Auftrag erzeugten Clearance-Missionen. Bei expliziter Freigabe werden HuntingPatrol und Ad-Infinitum-Patrol beendet und die aktive Clearance-AUFTRAG-Mission abgebrochen. Hat die Clearance-Phase noch nicht begonnen, wird weiterhin die ONGUARD-Response-Mission abgebrochen.

## Unveränderte Verträge

Unverändert bleiben:

```text
CampaignState = strategische Ressourcenautorität
MOOSE = operative Mission-/Gruppen-/Lifecycle-Autorität
QRF materialization = bestehende site-local ACCESS-Zone
Road alignment = OMW_GroundRoadSpawnAdapter.lua
physical incident target = ausschließlich Road-Forward-Richtungsinformation
kein PATROL_TEST
kein GROUNDATTACK
kein zusätzlicher Mission-Editor-Spawn-/Alarmbereich
```

## Implementierung

```text
scripts/campaign/OMW_FireSupStratResupply_QrfMissionFactory.lua
scripts/campaign/OMW_FireSupStratResupply_QrfRuntime.lua
tests/mission-demand/test_fire_support_qrf_accepted_contract.lua
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/04-qrf-response-clearance-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-4.ps1
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-4.md
```

Die historische Production Base Acceptance 3 bleibt unverändert und belegt weiterhin nur den exakt damals gebauten Response-Stand. Die neue Clearance-Phase wird durch die Joyce-fokussierte Production Base Acceptance 4 geprüft; diese Acceptance ist staged und noch nicht in DCS validiert.

## Status

```text
Owner decision: APPROVED
MOOSE pinned-source review: SOURCE_REVIEWED
Static anti-regression test: REQUIRED
Acceptance 4: STAGED
DCS runtime validation: OPEN
```
