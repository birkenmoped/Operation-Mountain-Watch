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
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – Accepted Implementation Matrix

## 1. Zweck

Dieses Dokument verhindert, dass bereits gelöste, dokumentierte und DCS-erprobte Projektverträge bei der Generalisierung des Fire-Support-/Strategic-Resupply-Basismoduls erneut entworfen werden.

Es ersetzt keine vorhandene Acceptance. Es macht deren Wiederverwendung vor weiteren Implementierungsänderungen verbindlich.

## 2. Reuse-/Acceptance-Gate

Vor jeder Änderung an einem bereits im Projekt vorhandenen Verhalten sind **vor dem Code** diese Punkte zu beantworten und im Arbeitskontext nachzuweisen:

```text
1. Existiert dieses Verhalten bereits im Projekt?
2. Gibt es dafür DCS-Runtime-Evidenz oder eine Acceptance?
3. Welche konkrete Datei implementiert das Verhalten?
4. Welche Acceptance / welcher dokumentierte Stand belegt es?
5. Welche Semantik ist dort verbindlich?
6. Was ist an der neuen Aufgabe tatsächlich neu?
7. Welche bestehende Implementierung wird wiederverwendet?
8. Welche neue Logik ist nach dem Abgleich noch unvermeidbar?
```

Wenn 1 oder 2 mit `JA` beantwortet wird, gilt ohne vorherige ausdrückliche Owner-Entscheidung:

```text
NO REIMPLEMENTATION
NO SEMANTIC VARIATION
NO ALTERNATE MOOSE MISSION/LIFECYCLE
NO ACCEPTANCE SHORTCUT
```

## 3. Accepted-Implementation-Matrix

| Bereich | Wiederzuverwendende Referenz | Verbindliche Semantik |
|---|---|---|
| Installation Alarm | `docs/ground/ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md` | Alarmzone ist Detection-/Response-Trigger, nicht WEZ/Battlespace/Mission-Ende. Perimeter-Clear beendet keinen laufenden QRF-Auftrag. |
| QRF Mission | `mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md` und `src/01-honaker-wright-full-response-acceptance.lua` | `AUFTRAG:NewONGUARD(...)` + `SetEngageDetected(...)`; keine stille Substitution durch `GROUNDATTACK`. |
| QRF Tactical Area | Honaker Full-Response Source | 5 NM QRF tactical zone um die lokale BRIGADE-/Installationskoordinate; `SetEngageDetected(5, {"Ground Units"}, zone)`. |
| QRF Return Enable | Honaker Full-Response Source | `SetReturnToLegion(true)`. |
| QRF Release Authority | Honaker Full-Response Acceptance | Mission-Cancel erst nach expliziter Supported-Element/C2-Freigabe. Weder Bewegungsdistanz noch Perimeter-Clear noch lokale Incident-Completion sind Release-Authority. |
| Ground ACCESS | `docs/ground/ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md` | ACCESS ist Materialisierungs-/Departure-/Return-/Handoff-Grenze, nicht Installation-/Alarmgeometrie. |
| Road-aligned materialization | `scripts/ground/OMW_GroundRoadSpawnAdapter.lua`; Owner-Freigabe dokumentiert mit Commit `623dfd51fbf47043a2ff822f2ac489de123c1783` | Nur Spawn-Geometrie wird angepasst; BRIGADE/WAREHOUSE/PLATOON/ARMYGROUP/AUFTRAG bleiben MOOSE-owned. Road spawns liegen auf Straßenachse und sind in Fahrtrichtung ausgerichtet. |
| Ground return mechanics | ARMY Ground Foundation Acceptance 6/7 | `MissionDone/Release -> ARMYGROUP:RTZ(home ACCESS, OnRoad) -> Returned -> Warehouse AddAsset -> physical removal`; strategisches Settlement separat/exactly-once. |
| Strategic resources | `CampaignState` / Ground Foundation | CampaignState bleibt strategische Ressourcenautorität; keine zweite Bestandsautorität im QRF-/Acceptance-Code. |

## 4. Acceptance-Code-Gesetz

Acceptance-Code darf vorhandene Produktsemantik auslösen oder beobachten, aber **keine neue Produktsemantik erfinden**.

Verboten sind insbesondere:

```text
movement >= N meters -> release/cancel
perimeter clear -> QRF release/cancel
incident close -> QRF release/cancel
alternative AUFTRAG type only to simplify an acceptance
acceptance-only resource or lifecycle authority
```

Eine Bewegungsstrecke darf ausschließlich als physische Runtime-Evidenz gewertet werden. Sie besitzt keine Mission-End-Autorität.

## 5. QRF Anti-Regression-Gates

Die automatisierte MissionDemand-Test-Suite muss für den Fire-Support-QRF mindestens verhindern:

```text
QRF mission != ONGUARD
missing SetEngageDetected
missing SetReturnToLegion(true)
GROUNDATTACK substitution
missing ACCESS GroundRoadSpawnAdapter integration
movement-distance-driven ExpireDemand/Cancel in Acceptance 3
Acceptance-owned supported-element release token
return on perimeter clear
return on incident close
```

Der zugehörige statische Contract-Test ist:

```text
tests/mission-demand/test_fire_support_qrf_accepted_contract.lua
```

## 6. Regression-Verfahren

Wenn ein bereits gelöstes Verhalten erneut fehlschlägt:

```text
Regression feststellen
-> frühere Acceptance / accepted implementation identifizieren
-> aktuelle Implementierung dagegen diffen
-> Abweichung isolieren
-> Abweichung zurücknehmen oder mit expliziter Owner-Entscheidung ändern
```

Nicht zulässig:

```text
Regression
-> neue alternative Lösung
-> neuer Acceptance-Shortcut
-> nächster Folgefehler
```

## 7. Aktuelle Korrektur 13.09.2026

Die zwischenzeitliche Fire-Support-QRF-Umstellung auf `AUFTRAG:NewGROUNDATTACK(...)` und die Acceptance-3-Regel

```text
>=25 m closing progress
-> Base:ExpireDemand(...)
-> mission Cancel
-> RTZ
```

waren Regressionen gegenüber dem bereits dokumentierten Honaker-Vertrag und sind verworfen.

Acceptance 3 darf die 25 m weiterhin als physische Response-Evidenz messen, aber daraus **keinen** QRF-Release ableiten.

## 8. Statusgrenze

Dieses Dokument ist ein bindendes Entwicklungs-/Review-Gate. Es ist selbst kein DCS-Runtime-PASS und validiert keine neue Mission.