---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE-4
status: DRAFT
document_class: ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Joyce-focused DCS acceptance of the owner-approved QRF response-to-clearance lifecycle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Production Base Acceptance 4 - QRF Response -> Clearance

Ziel ist die owner-genehmigte Erweiterung des QRF-Lifecycles zu pruefen, ohne die historische Acceptance 3 umzudeuten.

Vertrag:

```text
physical installation alarm
-> exactly one local QRF demand
-> existing ACCESS-only materialization
-> ONGUARD + SetEngageDetected response
-> same physical ARMYGROUP
-> PATROLZONE + EnableHuntingPatrol clearance
-> hostile Joyce fixture physically cleared during HuntingPatrol
-> no intermediate RTZ
-> no automatic release from perimeter/incident clear
-> explicit Supported-Element/C2 release only
-> normal MOOSE RTZ / Returned / Warehouse lifecycle
```

Primaerer DCS-Regressionsfall ist `FOB_JOYCE`, weil Acceptance 3 dort die reale Luecke sichtbar gemacht hat: Restkraefte hinter einem Gelaendekamm wurden durch reines `SetEngageDetected()` nicht systematisch gesucht.

## PASS-Kriterien

1. Joyce erzeugt genau einen QRF-Demand aus physischer Alarm-/PROXIMITY_INTRUSION-Evidenz.
2. Die QRF materialisiert innerhalb `ZON_BLUE_GND_JOYCE_ACCESS`.
3. Die erste QRF-Mission ist `AUFTRAG.Type.ONGUARD`.
4. Dieselbe physische `ARMYGROUP` wechselt danach auf `AUFTRAG.Type.PATROLZONE`.
5. HuntingPatrol ist fuer die site-local 5-NM-Tactical-Zone aktiv und akquiriert ein feindliches Ziel.
6. Die physische Joyce-RED-Fixture wird waehrend dieser Clearance-Phase vollstaendig beseitigt; erst danach darf der Acceptance-Harness die explizite Test-Freigabe ausloesen.
7. Vor expliziter Release-Anforderung gibt es keinen RTZ-/Returned-Zustand.
8. Acceptance 4 erzeugt keine eigene Search-Schleife, kein `GROUNDATTACK`, keinen Teleport und keine neue Mission-Editor-Zone.
9. Nach explizitem Test-Release wird HuntingPatrol beendet und der bestehende MOOSE ReturnToLegion/RTZ/Returned/Warehouse-Lifecycle verwendet.

Damit prueft Acceptance 4 nicht nur, ob MOOSE ein HuntingPatrol-Ziel intern setzt, sondern den eigentlichen Joyce-Regressionsfall: Die QRF muss die verbleibende feindliche Gruppe physisch bereinigen, bevor sie freigegeben wird.

`VALIDATED` darf erst nach realem DCS-Test gesetzt werden.
