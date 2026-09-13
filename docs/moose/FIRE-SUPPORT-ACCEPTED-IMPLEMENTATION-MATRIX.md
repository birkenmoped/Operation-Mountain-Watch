---
document_id: OMW-FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX
status: BINDING
document_class: IMPLEMENTATION_GUARDRAIL
owning_policy: OMW-GOV-001
authoritative_for:
  - reuse gate before Fire Support / Strategic Resupply implementation changes
  - accepted implementation references for local Ground QRF integration
  - anti-regression rules for Acceptance code
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# Fire Support / Strategic Resupply – Accepted Implementation Matrix

## Reuse-Gate

Vor Änderungen an bereits vorhandenem Verhalten ist verpflichtend zu klären:

```text
1. Existiert das Verhalten bereits?
2. Gibt es DCS-Evidenz / Acceptance?
3. Welche Datei implementiert es?
4. Welche Acceptance belegt es?
5. Welche Semantik ist bindend?
6. Was ist wirklich neu?
7. Welche Implementierung wird wiederverwendet?
8. Welche neue Logik bleibt unvermeidbar?
```

Wenn vorhandene Lösung/Evidenz existiert:

```text
NO REIMPLEMENTATION
NO UNAPPROVED SEMANTIC VARIATION
NO UNAPPROVED ALTERNATE MOOSE MISSION/LIFECYCLE
NO ACCEPTANCE SHORTCUT
```

## Accepted Implementation Matrix

| Bereich | Referenz | Verbindliche Semantik |
|---|---|---|
| Alarm | `ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md` | Alarmzone = Detection/Response-Trigger, nicht WEZ/Battlespace/Mission-Ende. |
| QRF Response Mission | Honaker Full-Response | `AUFTRAG:NewONGUARD(...)` + `SetEngageDetected(...)`; kein `GROUNDATTACK`. |
| QRF Tactical Area | Honaker Full-Response | 5 NM site-local tactical zone; Ground Units. |
| QRF Clearance Mission | Owner decision 2026-09-13 + pinned MOOSE source review | Nach Beginn der ONGUARD-Ausführung wechselt dieselbe physische `ARMYGROUP` in `AUFTRAG:NewPATROLZONE(site-local tactical zone)` + `SetPatrolAdInfinitum(true)` + `EnableHuntingPatrol(...)`. Diese Erweiterung benötigt DCS-Acceptance. |
| QRF Return Enable | Honaker Full-Response + clearance extension | Response und Clearance verwenden `SetReturnToLegion(true)`. |
| QRF Release | Honaker Full-Response | Nur explizite Supported-Element/C2-Freigabe. Bewegung, Perimeter-Clear, Incident-Close und "keine Gegner gefunden" sind keine Release Authority. |
| ACCESS | `ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md` | `ZON_BLUE_GND_XXX_ACCESS` ist Materialisierungs-/Departure-/Return-/Handoff-Grenze. |
| Road-aligned materialization | `OMW_GroundRoadSpawnAdapter.lua` | Nur Spawngeometrie wird angepasst; MOOSE besitzt BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG. |
| Ground Return | Ground Acceptance 6/7 | Release -> aktive QRF-Mission Cancel -> HuntingPatrol aus -> RTZ(home ACCESS) -> Returned -> Warehouse AddAsset -> physical removal. |
| Resources | CampaignState / Ground Foundation | CampaignState bleibt strategische Autorität. |

## Owner-genehmigte QRF-Erweiterung 13.09.2026

Der reale Production-Base-Acceptance-3-Lauf zeigte bei Joyce, dass die QRF korrekt anrückte, aber zwei überlebende Gegner hinter einer Geländekante nicht systematisch suchte. `SetEngageDetected(...)` ist im gepinnten MOOSE-Stand kein Search-and-Clear-Vertrag. `GROUNDATTACK` bleibt ausdrücklich ausgeschlossen.

Der Projektinhaber hat deshalb folgende Erweiterung ausdrücklich genehmigt:

```text
Incident / QRF demand
        -> ONGUARD + SetEngageDetected              [RESPONSE]
        -> ONGUARD executing at response waypoint
        -> same physical ARMYGROUP
        -> PATROLZONE(site-local tactical zone)     [CLEARANCE]
        -> SetPatrolAdInfinitum(true)
        -> EnableHuntingPatrol(...)
        -> remain employed until explicit C2 release
        -> DisableHuntingPatrol / patrol infinitum off
        -> cancel active clearance mission
        -> MOOSE ReturnToLegion / RTZ lifecycle
```

Verbindliche Grenzen:

```text
- kein GROUNDATTACK als Ersatz für ONGUARD;
- kein eigener Search-and-Destroy-Scanner;
- kein OMW-Scheduler/Frame-Scan für Feindsuche;
- keine automatische Freigabe bei Perimeter-Clear, Incident-Close oder fehlenden Targets;
- keine Änderung des ACCESS-/RoadSpawnAdapter-Vertrags;
- dieselbe bereits materialisierte ARMYGROUP wird weiterverwendet;
- MOOSE PATROLZONE/HuntingPatrol besitzt Suche, Zielwahl und Engagement;
- DCS-Validierung dieser neuen Clearance-Phase ist noch offen.
```

Pinned source review:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

AUFTRAG:NewPATROLZONE(...)
AUFTRAG:GetOpsGroups()
OPSGROUP:AddMission(...)
OPSGROUP:__MissionDone(...)
ARMYGROUP:SetPatrolAdInfinitum(...)
ARMYGROUP:EnableHuntingPatrol(...)
ARMYGROUP:DisableHuntingPatrol(...)
```

## Harte ACCESS-Regel

```text
JALALABAD_FENTY -> ZON_BLUE_GND_FENTY_ACCESS
COP_FORTRESS    -> ZON_BLUE_GND_FORTRESS_ACCESS
FOB_JOYCE       -> ZON_BLUE_GND_JOYCE_ACCESS
FOB_WRIGHT      -> ZON_BLUE_GND_WRIGHT_ACCESS
COP_HONAKER     -> ZON_BLUE_GND_HONAKER_ACCESS
FOB_BOSTICK     -> ZON_BLUE_GND_BOSTICK_ACCESS
```

Nicht als QRF-Materialisierungsabhängigkeit zulässig:

```text
*_PATROL_TEST_01
Alarm-/Security-Zone
Warehouse-Center
FOB-/COP-Mittelpunkt
taktisches Ziel als Spawnzone
zusätzliche Mission-Editor-Spawnzone
```

Die physische Incident-Zielkoordinate darf im aktuellen Composition Root ausschließlich als Road-Forward-Richtungsinformation an den vorhandenen RoadSpawnAdapter weitergereicht werden. Die tatsächliche Materialisierung muss vollständig innerhalb ACCESS bleiben.

## Acceptance-Code-Gesetz

Acceptance darf beobachten und vorhandene Produktsemantik auslösen, aber keine neue Produktsemantik erfinden. Verboten:

```text
movement >= N m -> release/cancel
perimeter clear -> release/cancel
incident close -> release/cancel
no targets detected -> release/cancel
alternative AUFTRAG type nur für bequemeren Test
Acceptance-eigene Resource-/Lifecycle-Authority
```

Die historische Production Base Acceptance 3 bleibt als Evidenz des damals exakt gebauten ONGUARD-Response-Pfads unverändert. Die owner-genehmigte Clearance-Erweiterung benötigt eine nachfolgende gezielte Acceptance und darf nicht rückwirkend in das eingefrorene A3-Artefakt hineininterpretiert werden.

## Nicht wiederholen – dokumentierte Regressionen

1. QRF-Materialisierung außerhalb des ACCESS-Vertrags.
2. `GROUNDATTACK` statt Honaker-`ONGUARD`.
3. `>=25 m -> ExpireDemand -> Cancel -> RTZ`; führte zu zu frühem Umdrehen u.a. bei Fortress/Joyce.
4. Eigene 500/1000/1500/2000-m Road-Sampling-Heuristik.
5. Historische `PATROL_TEST`-Fixtures als aktuelle Acceptance-Voraussetzung; realer Preflight-Fail wegen fehlender Zone.
6. Eigene Search-/Sweep-Logik parallel zu MOOSE `PATROLZONE`/`HuntingPatrol`.

## Anti-Regression-Gate

`tests/mission-demand/test_fire_support_qrf_accepted_contract.lua` muss mindestens verhindern:

```text
Response mission != ONGUARD
missing SetEngageDetected
missing SetReturnToLegion(true)
GROUNDATTACK substitution
missing PATROLZONE clearance phase
missing SetPatrolAdInfinitum(true)
missing EnableHuntingPatrol
missing explicit-release cleanup of HuntingPatrol
missing ACCESS GroundRoadSpawnAdapter integration
PATROL_TEST dependency
movement-distance-driven release
return on perimeter clear
return on incident close
return when no target is found
custom QRF search scheduler
```

## Regression-Verfahren

```text
Regression feststellen
-> frühere Acceptance identifizieren
-> akzeptierte Implementierung prüfen
-> aktuellen Code dagegen diffen
-> Abweichung zurücknehmen
```

Keine weitere Alternativlösung ohne vorherige Owner-Entscheidung.

Dieses Dokument ist ein Entwicklungs-/Review-Gate, kein DCS-Runtime-PASS.
