---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Production Base installation-incident to local-QRF integration acceptance
  - MOOSE-native QRF recruitment filtering
  - active-incident refresh deduplication
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Production Base Acceptance 2 – Honaker Incident + QRF

## Ziel

Acceptance 2 bündelt mehrere bisher offene Punkte in **einem** DCS-Lauf:

```text
owner-authored BadGuys1 fixture
-> injected installation evidence at the live group coordinate
-> authoritative OMW_GroundInstallationAttackIncident
-> InstallationIncidentBridge
-> generic FireSupStratResupply Base
-> initial local QRF demand
-> site-local MOOSE BRIGADE
-> MOOSE AUFTRAG recruitment filter
-> physical QRF movement toward the incident position
```

Zusätzlich wird ein zweites Evidence-Update für denselben aktiven Installation-Incident eingespeist. Dieses Update darf **keinen zweiten QRF-Demand** erzeugen.

## Abgrenzung

Die Evidence wird absichtlich durch den Acceptance-Harness als `DIRECT_FIRE_ATTACK` eingespeist. Damit prüft dieser Lauf die **Incident-/QRF-Integration**, nicht die physische Detection- oder Alarm-Qualifikation. Ein PASS dieses Tests darf daher nicht als DCS-Validierung von OPSZONE-, Shot-, Hit- oder Weapon-Evidence ausgelegt werden.

ARTY, CAS und Resupply sind ebenfalls nicht Bestandteil dieses Laufs. Für diese Fähigkeiten fehlen in der allgemeinen Six-Site-Baseline weiterhin die jeweils erforderlichen produktiven Resolver-/Providerdaten; historische Stage-3-Geometrien werden nicht verallgemeinert.

## MOOSE-First / Recruitment

Guard und QRF nutzen derzeit beide den MOOSE-Missionstyp `AUFTRAG.Type.ONGUARD`. Sobald mehrere dafür geeignete Cohorts in derselben BRIGADE liegen, darf OMW deshalb nicht selbst ein konkretes Asset auswählen.

Die Production Base unterstützt nun optionale QRF-Fähigkeitsanforderungen und gibt diese direkt an öffentliche MOOSE-APIs weiter:

```text
AUFTRAG:SetRequiredAttribute(...)
AUFTRAG:SetRequiredProperty(...)
-> LEGION recruitment
```

Acceptance 2 setzt für Honaker ausschließlich:

```text
qrfRequiredAttributes = GROUP.Attribute.GROUND_APC
```

Das ist keine OMW-Assetvorwahl. MOOSE bleibt für Cohort-/Asset-Rekrutierung verantwortlich. Die Anforderung beschreibt nur die benötigte QRF-Fähigkeit.

Für den konkreten Acceptance-Stand ist `TPL_BLUE_GND_QRF_MIXED_6` bereits durch frühere reale DCS-Ausgabe als `Ground_APC` klassifiziert. Der Test verlangt deshalb, dass die tatsächlich von MOOSE auf Mission gebrachte QRF-Gruppe `GROUP.Attribute.GROUND_APC` besitzt.

## Mission-Editor-Voraussetzungen

Verwendet wird weiterhin die Foundation-Mission `OMW_Template_v24_GroundWorks_base.miz` mit mindestens:

```text
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK

TPL_BLUE_GND_INF_RIFLE_SQUAD_9
TPL_BLUE_GND_QRF_MIXED_6
BadGuys1

OMW_RTE_BLUE_GUARD_FENTY_01
OMW_RTE_BLUE_GUARD_FORTRESS_01
OMW_RTE_BLUE_GUARD_JOYCE_01
OMW_RTE_BLUE_GUARD_WRIGHT_01
OMW_RTE_BLUE_GUARD_HONAKER_01
OMW_RTE_BLUE_GUARD_BOSTICK_01
```

`BadGuys1` ist eine bereits vorhandene late-activated RED-Gruppe. Der Acceptance-Harness aktiviert sie über die öffentliche MOOSE-Methode `GROUP:Activate()` und verwendet anschließend ausschließlich ihre reale `GROUP:GetCoordinate()`-Position als Incident-/QRF-Ziel. Es wird keine künstliche QRF-Zielkoordinate erfunden.

`ZON_BLUE_GND_*_ACCESS` ist ausdrücklich **nicht** Teil dieses QRF-/Alarm-Vertrags.

## Testablauf

1. Production Base Package nach MOOSE laden.
2. Sechs lokale BRIGADE-Objekte auf den vorhandenen Warehouses erzeugen.
3. Nur Honaker erhält für diesen Test einen QRF-PLATOON auf Basis von `TPL_BLUE_GND_QRF_MIXED_6`.
4. Runtime mit `qrfRequiredAttributes = GROUP.Attribute.GROUND_APC` vorbereiten.
5. BRIGADEs starten.
6. `BadGuys1` über MOOSE aktivieren.
7. Reale Position von `BadGuys1` lesen.
8. Erste Integration-Evidence an `BLUE_GROUND_COP_HONAKER_MIRACLE` melden.
9. Zweite Evidence für denselben aktiven Incident melden.
10. Prüfen, dass der Base-Incident weiterhin genau einen Response-Demand enthält.
11. Beobachten, dass MOOSE eine `Ground_APC`-QRF auf Mission bringt.
12. Prüfen, dass die QRF lebt und ihre Distanz zur realen Incident-Position um mindestens 25 m reduziert.

## PASS-Kriterium

Der DCS-Log muss enthalten:

```text
[PRODUCTION BASE A2][PASS] Honaker incident opened once; MOOSE recruited Ground_APC QRF; target-distance progress ... m; refresh kept one response demand
```

Zusatzbedingungen:

- kein `[PRODUCTION BASE A2][FAIL]`;
- `qrfObserved=true`;
- QRF lebt;
- QRF-Attribut ist `Ground_APC`;
- Distanzfortschritt zum echten `BadGuys1`-Ziel >= 25 m;
- nach dem zweiten Evidence-Update bleibt `demandCountAfterRefresh=1`.

Der Test verlangt weder die Vernichtung von `BadGuys1` noch einen vollständigen QRF-Auftragsabschluss. DCS-Ground-Pathfinding bleibt separat zu beobachten.

## Builder

```text
tools/build-fire-support-strategic-resupply-production-base-acceptance-2.ps1
```

Ausgabe:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_2.lua
```

Der Builder erzeugt zuerst das aktuelle Production-Base-Paket und hängt anschließend ausschließlich den Acceptance-2-Harness an. Die `.miz` wird nicht verändert.

## Noch nicht bewiesen

Auch nach einem PASS von Acceptance 2 bleiben insbesondere offen:

```text
physical multi-evidence detection / qualification
ARTY escalation
CAS escalation
Ground resupply
Air resupply
CampaignState physical transport settlement
```

Diese offenen Funktionen sollen soweit möglich in wenigen größeren Folge-Acceptances gebündelt werden.
