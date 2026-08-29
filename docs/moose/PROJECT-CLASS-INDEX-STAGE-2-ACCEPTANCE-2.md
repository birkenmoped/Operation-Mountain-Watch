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

## Bereits source-verifizierter Stage-2B-Dispatch-Scope

| Klasse/Pfad | Status vor DCS-Test | Stage-2B-Verwendung |
|---|---|---|
| `AUFTRAG:NewCAS` | `SOURCE_VERIFIED` | CAS-Zone aus dem bereits erzeugten Fortress-`ZONE_RADIUS` |
| `AIRWING` / `LEGION:AddMission` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener Jalalabad-AIRWING nimmt den CAS-AUFTRAG in seine Mission Queue auf |
| `SQUADRON` / `COHORT:AddMissionCapability` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener AH-64D-SQUADRON besitzt `AUFTRAG.Type.CAS` |
| `AIRWING OnAfterFlightOnMission` | `SOURCE_VERIFIED` | Acceptance-Beleg für reale FLIGHTGROUP-Materialisierung/Missionszuordnung |
| `AUFTRAG OnAfterExecuting` | `SOURCE_VERIFIED` | Acceptance-Beleg, dass reale Missionausführung begonnen hat; setzt MissionDemand `ACTIVE` |
| `AUFTRAG OnAfterSuccess` | `SOURCE_VERIFIED` | spiegelt erfolgreichen MOOSE-Abschluss auf MissionDemand `SUCCESS`, soweit der konkrete CAS-Abschlusspfad ihn tatsächlich erreicht |
| `AUFTRAG OnAfterFailed` | `SOURCE_VERIFIED` | spiegelt MOOSE-Fehlschlag auf MissionDemand `FAILED` |

## Vor Implementierung zusätzlich zu verifizierender Scope

Die aktuelle Stage-2B-Planung umfasst jetzt auch CAS-Abschluss, lokale Infanteriegegenwehr sowie Guard-/QRF-Rückkehr. Folgende Punkte sind deshalb **noch nicht als verwendete API freigegeben**, sondern müssen vor Codeänderung nach der verbindlichen MOOSE-first-Reihenfolge Dokumentation -> gepinnter Source -> offizielle Beispiele geprüft werden:

| Klasse/Pfad | Aktueller Status | Geplanter Zweck |
|---|---|---|
| `AUFTRAG` mission completion/cancel/Done/Success FSM | `REVIEW_REQUIRED` | CAS nach beseitigter Bedrohung sauber beenden, nicht bis Fuel-Low im Orbit halten |
| `FLIGHTGROUP` RTB / landing / recovery lifecycle | `REVIEW_REQUIRED` | reale CAS-Rückkehr und physische Asset-Recovery nachweisen |
| `ARMYGROUP:RTZ(...)` | `REVIEW_REQUIRED_FOR_STAGE_2B` | Guard-/Counterattack-Gruppe zu einem installationsbezogenen Recovery-Handoff zurückführen |
| `OPSGROUP` / `ARMYGROUP` `Returned` lifecycle | `REVIEW_REQUIRED_FOR_STAGE_2B` | bestätigte physische Rückkehr vor Warehouse-/CampaignState-Settlement |
| `ReturnToLegion` / Legion-Warehouse AddAsset lifecycle | `REVIEW_REQUIRED_FOR_STAGE_2B` | MOOSE-eigene Rückgabe und Cleanup statt nacktem `Destroy()` |
| `OutOfAmmo` FSM / configuration | `REVIEW_REQUIRED` | leergeschossene Guard-/Counterattack-Gruppe ohne eigenen Ammo-Polling-Scheduler zurückführen |
| geeigneter `AUFTRAG`-Typ für lokalen Infanteriegegenangriff | `REVIEW_REQUIRED` | vorhandene MOOSE-Mission statt eigener Targeting-/Routinglogik |
| MOOSE-/OMW-Waypoint-/routing path used by existing helicopter transport corridor | `REVIEW_REQUIRED` | AH-64-CAS über bereits validierten Tal-/Transitkorridor führen, ohne Koordinatenkopie |

## CampaignState-/MOOSE-Grenze

Die Stage-2B-Prüfung ändert keine Ressourcenautorität:

```text
CampaignState
= strategic personnel availability / commitment / survivor-loss settlement / reorder evaluation

MOOSE
= physical BRIGADE/PLATOON/ARMYGROUP and AIRWING/SQUADRON/FLIGHTGROUP lifecycle
```

Rückkehr, Verlust und erneute Verfügbarkeit müssen über stabile Settlement-IDs idempotent abgeglichen werden. Ein `AUFTRAG:Done`, Cancel oder Return-Befehl allein ist noch keine strategische Rückkehr.

## Validierungsgrenze

`VALIDATED_FOR_DOCUMENTED_SCOPE` darf für diese Stage-2B-Komposition erst nach den dokumentierten DCS-Nachweisen vergeben werden. Ein CAS-Start oder `CAS_EXECUTING` allein genügt nicht mehr; zusätzlich sind der vorgesehene Abschluss-/RTB-Pfad und die Ground-Response-/Recovery-Teilketten separat nachzuweisen.
