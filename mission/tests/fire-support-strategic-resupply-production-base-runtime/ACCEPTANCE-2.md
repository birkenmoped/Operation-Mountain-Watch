---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Production Base six-site Guard regression
  - Production Base installation-incident to local-QRF integration acceptance
  - MOOSE-native Guard and QRF recruitment filtering
  - active-incident refresh deduplication
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Production Base Acceptance 2 – Six Guards + Honaker Incident + QRF

## Ziel

Auf Wunsch des Projektinhabers werden mehrere sinnvolle Prüfungen in **einem** DCS-Lauf gebündelt. Acceptance 2 regressiert die bereits akzeptierte Six-Site-Guard-Kette und prüft gleichzeitig erstmals die produktive Installation-Incident-/QRF-Kette:

```text
six site-local persistent Guard demands
-> MOOSE recruits Ground_Infantry Guards
-> accepted compact materialization + owner PATHLINE routing

owner-authored BadGuys1 fixture
-> injected integration evidence at the live group coordinate
-> OMW_GroundInstallationAttackIncident
-> InstallationIncidentBridge
-> FireSupStratResupply Base
-> one initial local QRF demand
-> Honaker BRIGADE
-> MOOSE recruits Ground_APC QRF
-> physical movement toward the incident coordinate
```

Ein zweites Evidence-Update für denselben aktiven Installation-Incident darf keinen zweiten QRF-Demand erzeugen.

## Abgrenzung

Die Evidence wird durch den Acceptance-Harness als `DIRECT_FIRE_ATTACK` eingespeist. Dieser Lauf prüft deshalb die **Incident-/QRF-Integration**, nicht die physische Detection-/Alarmqualifikation. Ein PASS validiert keine OPSZONE-, Shot-, Hit- oder Weapon-Evidence.

ARTY, CAS und Resupply sind nicht Bestandteil dieses Laufs. Die allgemeine Six-Site-Baseline besitzt dafür noch nicht sämtliche produktiven Resolver-/Providerdaten; historische Stage-3-Geometrien werden nicht verallgemeinert.

## MOOSE-First / gemeinsame BRIGADE

Guard und QRF verwenden `AUFTRAG.Type.ONGUARD`. Beide Cohorts dürfen in derselben Site-BRIGADE existieren, ohne dass OMW ein konkretes Asset auswählt. Der fachliche Bedarf wird über öffentliche MOOSE-Rekrutierungsfilter ausgedrückt:

```text
Guard demand
-> AUFTRAG:SetRequiredAttribute(GROUP.Attribute.GROUND_INFANTRY)
-> LEGION/BRIGADE recruitment by MOOSE

QRF demand
-> AUFTRAG:SetRequiredAttribute(GROUP.Attribute.GROUND_APC)
-> LEGION/BRIGADE recruitment by MOOSE
```

Die Production Base stellt dafür optionale `guardRequiredAttributes` / `guardRequiredProperties` sowie `qrfRequiredAttributes` / `qrfRequiredProperties` bereit. Ohne Konfiguration setzt sie keine impliziten Assetfilter.

Die verwendeten Acceptance-Attribute sind durch gepinnten MOOSE-Source und reale OMW-DCS-Ausgabe belegt: `TPL_BLUE_GND_INF_RIFLE_SQUAD_9` wurde als `Ground_Infantry` klassifiziert; `TPL_BLUE_GND_QRF_MIXED_6` als `Ground_APC`. Die konkreten Attribute sind Acceptance-Konfiguration, keine projektweite Festlegung zukünftiger QRF-Typen.

## Mission-Editor-Voraussetzungen

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

`BadGuys1` ist eine vorhandene late-activated RED-Gruppe. Der Harness aktiviert sie mit der öffentlichen MOOSE-Methode `GROUP:Activate()` und nutzt danach ihre reale `GROUP:GetCoordinate()`-Position als Incident-/QRF-Ziel. Es wird keine QRF-Zielkoordinate erfunden.

### Testfixture versus produktive RED-Kräfte

Die aktuell in der Foundation-`.miz` vorhandenen `BadGuys*`-Gruppen sind **ausschließlich Testfixtures** für Acceptance-, Integrations- und Regressionsläufe. Sie sind kein vorgesehenes produktives Feindkräfte-, ORBAT-, Spawn- oder Tasking-Modell und dürfen nicht als dauerhafte RED-Operationsquelle in die Production-Architektur übernommen werden.

Für die spätere produktive Mission gilt stattdessen:

```text
RED C2 / RED operational command layer
-> determines hostile operational demand / intent
-> selects and tasks eligible RED formations through the approved MOOSE/OMW architecture
-> dynamically deploys / moves hostile RED groups
-> BLUE installation alarm receives only resulting physical/evidence state
```

Damit bleibt die Richtung ausdrücklich getrennt:

```text
Acceptance fixture:
BadGuys* exists in .miz
-> harness activates/moves/uses it for a defined test

Production:
RED C2 owns enemy employment
-> RED groups are dynamically committed and moved by RED command logic
-> BLUE alarm/QRF reacts to the resulting threat
```

BLUE Installation Incident, Guard, QRF, Fire Support oder Resupply dürfen deshalb keine produktive Abhängigkeit von den Namen, Positionen oder der Existenz der `BadGuys*`-Testgruppen erhalten. Die konkrete RED-C2-Architektur ist außerhalb dieses Acceptance-2-Scope und muss separat nach den dann gültigen Governance-/MOOSE-First-Regeln implementiert und validiert werden.

`ZON_BLUE_GND_*_ACCESS` ist ausdrücklich kein Guard-, QRF- oder Alarmvertrag.

## Testablauf

1. Production Base nach MOOSE laden.
2. Für alle sechs Sites lokale BRIGADEs erzeugen.
3. Jede Site erhält einen Guard-PLATOON; Honaker zusätzlich den vorhandenen QRF-PLATOON.
4. Runtime mit `Guard=GROUND_INFANTRY`, `QRF=GROUND_APC` als MOOSE-Rekrutierungsanforderungen vorbereiten.
5. BRIGADEs starten und alle sechs persistenten Guard-Demands über `Runtime:StartSite()` erzeugen.
6. `BadGuys1` über MOOSE aktivieren und reale Position lesen.
7. Erste Integration-Evidence an Honaker melden.
8. Zweite Evidence für denselben aktiven Incident melden und genau einen Base-Response-Demand verifizieren.
9. Parallel Guard- und QRF-Telemetrie beobachten.
10. Nach 300 Sekunden gemeinsames PASS/FAIL bewerten.

## PASS-Kriterium

```text
[PRODUCTION BASE A2][PASS] 6/6 Guards >=25 m; Honaker incident opened once; MOOSE recruited Ground_APC QRF; target-distance progress ... m; refresh kept one response demand
```

Zusatzbedingungen:

- kein `[PRODUCTION BASE A2][FAIL]`;
- sechs Guards `missionObserved`, lebendig und jeweils mindestens 25 m Positionsänderung;
- QRF `missionObserved`, lebendig und Attribut `Ground_APC`;
- QRF reduziert ihre Distanz zur realen `BadGuys1`-Position um mindestens 25 m;
- nach dem zweiten Evidence-Update bleibt `demandCountAfterRefresh=1`.

Das Guard-Kriterium bleibt wie Acceptance 1 ein initialer Bewegungsnachweis, kein dauerhafter Patrol-Loop-Test. Die vom Eigentümer abgelehnte zweite Patrol-Ausnahme wird nicht eingeführt.

## Builder

```text
tools/build-fire-support-strategic-resupply-production-base-acceptance-2.ps1
```

Ausgabe:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_2.lua
```

Die `.miz` wird nicht verändert.

## Nach PASS weiterhin offen

```text
physical multi-evidence detection / qualification
ARTY escalation
CAS escalation
Ground resupply
Air resupply
CampaignState physical transport settlement
productive RED C2 employment / hostile force generation and movement
```

Diese offenen Punkte werden weiterhin soweit fachlich möglich in wenigen größeren Folge-Acceptances gebündelt.
