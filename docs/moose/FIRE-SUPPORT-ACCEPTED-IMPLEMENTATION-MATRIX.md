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
NO SEMANTIC VARIATION
NO ALTERNATE MOOSE MISSION/LIFECYCLE
NO ACCEPTANCE SHORTCUT
```

## Accepted Implementation Matrix

| Bereich | Referenz | Verbindliche Semantik |
|---|---|---|
| Alarm | `ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md` | Alarmzone = Detection/Response-Trigger, nicht WEZ/Battlespace/Mission-Ende. |
| QRF Mission | Honaker Full-Response | `AUFTRAG:NewONGUARD(...)` + `SetEngageDetected(...)`; kein stilles `GROUNDATTACK`. |
| QRF Tactical Area | Honaker Full-Response | 5 NM site-local tactical zone; Ground Units. |
| QRF Return Enable | Honaker Full-Response | `SetReturnToLegion(true)`. |
| QRF Release | Honaker Full-Response | Nur explizite Supported-Element/C2-Freigabe. Bewegung, Perimeter-Clear und Incident-Close sind keine Release Authority. |
| ACCESS | `ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md` | `ZON_BLUE_GND_XXX_ACCESS` ist Materialisierungs-/Departure-/Return-/Handoff-Grenze. |
| Road-aligned materialization | `OMW_GroundRoadSpawnAdapter.lua` | Nur Spawngeometrie wird angepasst; MOOSE besitzt BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG. |
| Ground Return | Ground Acceptance 6/7 | Release -> RTZ(home ACCESS) -> Returned -> Warehouse AddAsset -> physical removal. |
| Resources | CampaignState / Ground Foundation | CampaignState bleibt strategische Autorität. |

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

Die physische Incident-Zielkoordinate darf im aktuellen Composition Root ausschließlich als Road-Forward-Richtungsinformation an den vorhandenen RoadSpawnAdapter weitergereicht werden. Die tatsächliche Materialisierung muss vollständig innerhalb ACCESS bleiben. Dieser konkrete korrigierte Integrationsstand benötigt noch DCS-Runtime-Evidenz.

## Acceptance-Code-Gesetz

Acceptance darf beobachten und vorhandene Produktsemantik auslösen, aber keine neue Produktsemantik erfinden. Verboten:

```text
movement >= N m -> release/cancel
perimeter clear -> release/cancel
incident close -> release/cancel
alternative AUFTRAG type für bequemeren Test
Acceptance-eigene Resource-/Lifecycle-Authority
```

## Nicht wiederholen – dokumentierte Regressionen

1. QRF-Materialisierung außerhalb des ACCESS-Vertrags.
2. `GROUNDATTACK` statt Honaker-`ONGUARD`.
3. `>=25 m -> ExpireDemand -> Cancel -> RTZ`; führte zu zu frühem Umdrehen u.a. bei Fortress/Joyce.
4. Eigene 500/1000/1500/2000-m Road-Sampling-Heuristik.
5. Historische `PATROL_TEST`-Fixtures als aktuelle Acceptance-Voraussetzung; realer Preflight-Fail wegen fehlender Zone.

## Anti-Regression-Gate

`tests/mission-demand/test_fire_support_qrf_accepted_contract.lua` muss mindestens verhindern:

```text
QRF mission != ONGUARD
missing SetEngageDetected
missing SetReturnToLegion(true)
GROUNDATTACK substitution
missing ACCESS GroundRoadSpawnAdapter integration
PATROL_TEST dependency
movement-distance-driven release
return on perimeter clear
return on incident close
```

## Regression-Verfahren

```text
Regression feststellen
-> frühere Acceptance identifizieren
-> akzeptierte Implementierung prüfen
-> aktuellen Code dagegen diffen
-> Abweichung zurücknehmen
```

Keine neue Alternativlösung ohne vorherige Owner-Entscheidung.

Dieses Dokument ist ein Entwicklungs-/Review-Gate, kein DCS-Runtime-PASS.