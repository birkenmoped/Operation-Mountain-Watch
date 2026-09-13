---
document_id: OMW-HANDOFF-FSSR-20260913
status: PLANNED
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current Fire Support Strategic Resupply handoff context
not_authoritative_for:
  - DCS runtime acceptance not yet performed for the current build
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: d63aded64cc7eb63c9f5809f5bf5451067332d3a
validated_in_dcs: false
supersedes:
  - OMW-HANDOFF-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-20260911
superseded_by:
---

# Fire Support / Strategic Resupply – Übergabe 13.09.2026

## Ziel

Branch: `agent/fire-support-strategic-resupply-base-gate0`, PR #149, Draft. Ziel ist eine standortunabhängige MOOSE-first Basis für Alarm/Incident, lokalen QRF, externe ARTY/CAS und Strategic Resupply. Die Base darf weder MOOSE-Recruitment/Queue/Lifecycle noch CampaignState-Ressourcenhoheit duplizieren.

## Pflichtlektüre

Vor jeder Änderung: `AGENTS.md`, `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`, `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`, `docs/ground/ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md`, `docs/ground/ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md`, Honaker Full-Response Acceptance sowie Ground Acceptance 6/7.

MOOSE pin: 2.9.18, commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, Moose.lua SHA-256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`.

## Bindende Verträge

Alarmzone ist nur Detection-/Response-Trigger, niemals WEZ/Battlespace/Mission-Ende. Perimeter-Clear und Incident-Close beenden laufende QRF/CAS/ARTY nicht automatisch.

QRF-Vertrag aus Honaker: `AUFTRAG:NewONGUARD(...)` + `SetEngageDetected(5 NM, {"Ground Units"}, site-local tactical zone)` + `SetReturnToLegion(true)`. Rückkehr erst nach expliziter Supported-Element/C2-Freigabe. Keine 25-m-, Perimeter- oder Incident-basierte Release-Autorität.

Motorisierte QRFs materialisieren ausschließlich in vorhandenen ACCESS-Zonen:

```text
JALALABAD_FENTY -> ZON_BLUE_GND_FENTY_ACCESS
COP_FORTRESS    -> ZON_BLUE_GND_FORTRESS_ACCESS
FOB_JOYCE       -> ZON_BLUE_GND_JOYCE_ACCESS
FOB_WRIGHT      -> ZON_BLUE_GND_WRIGHT_ACCESS
COP_HONAKER     -> ZON_BLUE_GND_HONAKER_ACCESS
FOB_BOSTICK     -> ZON_BLUE_GND_BOSTICK_ACCESS
```

`OMW_GroundRoadSpawnAdapter.lua` wird wiederverwendet. Keine `PATROL_TEST`-, Alarm-, Warehouse-Center-, FOB/COP-Center- oder zusätzliche Spawnzone als Materialisierungsabhängigkeit. Die physische Incident-Zielkoordinate darf nur Richtungsinformation für den RoadSpawnAdapter sein; tatsächliche Spawnpositionen bleiben in ACCESS.

Ground Return bleibt: Release/MissionDone -> `ARMYGROUP:RTZ(home ACCESS, OnRoad)` -> Returned -> Warehouse AddAsset -> physical removal -> strategisches Settlement exactly once.

## Fehlerhistorie, nicht wiederholen

1. Falsche QRF-Materialisierung statt ACCESS-Vertrag.
2. `GROUNDATTACK` statt Honaker-`ONGUARD`.
3. Acceptance-eigener `>=25 m -> ExpireDemand -> Cancel -> RTZ`; dadurch drehten u.a. Fortress/Joyce zu früh um.
4. Eigene 500/1000/1500/2000-m Road-Sampling-Heuristik.
5. Historische `PATROL_TEST`-Fixtures als aktuelle Acceptance-Voraussetzung; letzter Lauf brach bereits mit fehlender `PATROL_TEST`-Zone ab.

Korrektes Regression-Verfahren: frühere Acceptance finden -> akzeptierte Implementierung prüfen -> aktuellen Code diffen -> Abweichung zurücknehmen. Keine neue Alternativlösung erfinden.

## Aktueller Build

Source commit `d63aded64cc7eb63c9f5809f5bf5451067332d3a`.

```text
Production Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-13
QRF Runtime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-10
QRF Mission Factory: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-5
Acceptance Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-9
Production bundle: 7432541B6EA8906BBC6B80ECCA4A3F9E150E6BF523BA403A73C05ACC5F70DE7E
Acceptance bundle: 1B3C23AB249A128A9863877CCFE3E3D996EA470CA9F450A18DF8498F324C0873
```

Unabhängige `Get-FileHash`-Prüfungen stimmen exakt. GitHub Actions auf `d63aded...`: Documentation validation run 34769336458 PASS; MissionDemand run 34769336404 PASS. Status: `VERIFIED_LOCAL_BUILD`, nicht DCS-validiert.

## Nächste Schritte

1. Exakt dieses Acceptance-Bundle real in DCS testen.
2. `dcs.log` und möglichst `debrief.log` auswerten.
3. 6/6 prüfen: Guard, Alarm, PROXIMITY_INTRUSION, genau ein QRF-Demand, QRF in korrekter ACCESS-Zone, ONGUARD, SetEngageDetected, >=25 m physische Reaktion.
4. Prüfen, dass kein Harness-Release/Cancel und kein frühes RTZ erfolgt.
5. Bei Road-/ACCESS-Fehlern keine neue Geometrie erfinden, sondern gegen den bestehenden RoadSpawnAdapter und akzeptierte Ground-Baselines diffen.
6. Erst realen DCS-PASS mit DCS-Version, MIZ-Hash, Bundle-Hash und Log-Evidenz dokumentieren.
7. Danach Final-Reconciliation Guard/QRF/ARTY/CAS/Resupply.
8. PR #149 bleibt Draft; Ready/Merge nur nach ausdrücklicher Owner-Freigabe.

Kein CODEX, keine automatische `.miz`-Mutation, keine erfundenen Hashes oder Runtime-Ergebnisse.
