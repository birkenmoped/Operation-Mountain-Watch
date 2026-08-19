---
document_id: OMW-TEST-ARMY-GROUND-FOUNDATION-TODO
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - current working scope and open tasks for the Jalalabad/Kunar ARMY ground foundation
not_authoritative_for:
  - final historical ground-force ORBAT strengths
  - final Mission Editor object state
  - DCS runtime acceptance beyond cited result documents
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Arbeitsstand und To-do

## 1. Aktueller Scope

Verbindlicher Recherche-/Kampagnenzeitraum:

```text
01.08.2010–31.12.2011
```

Aktive Ground-ORBAT-Arbeitsreferenz:

```text
July 2011
```

Aktueller Kunar-/Jalalabad-Foundation-Scope:

```text
Jalalabad / FOB Fenty
FOB Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick

Dependent OPs:
Honaker-Miracle -> OP JoJo
Bostick -> OP Mustang / OP Clydesdale / OP Stallion
```

Die aktuelle Reconciliation steht in:

- [`OMW-ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION`](../../../docs/ground/ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION.md)

## 2. Architekturgrenze

```text
CampaignState strategic authority
!= historical formation
!= MOOSE BRIGADE / WAREHOUSE / PLATOON
!= physical DCS GROUP / ARMYGROUP
```

Zusätzlich gilt nach der Kunar-Reconciliation:

```text
strategic parent / resource obligation
!= physical dispatch origin
```

Ein MOOSE-Warehouse ist nur physischer Host/operativer Mirror. Es erzeugt keine eigene strategische Ressourcenhoheit.

## 3. Aktuelle operative MOOSE-Domänen

Für den nächsten Integrationslauf sind sechs Domains geplant:

```text
BDE_BLUE_GND_JALALABAD -> WH_BLUE_GND_FENTY
BDE_BLUE_GND_FORTRESS  -> WH_BLUE_GND_FORTRESS
BDE_BLUE_GND_JOYCE     -> WH_BLUE_GND_JOYCE
BDE_BLUE_GND_WRIGHT    -> WH_BLUE_GND_WRIGHT
BDE_BLUE_GND_HONAKER   -> WH_BLUE_GND_HONAKER
BDE_BLUE_GND_BOSTICK   -> WH_BLUE_GND_BOSTICK
```

Fortress und Honaker erhalten damit einen eigenen operativen MOOSE-Materialisierungspunkt, aber **keinen automatisch neuen CampaignState-Fahrzeugbestand**.

Für Fortress und Honaker gilt bis zu einer separaten Mengenentscheidung:

```text
production vehicle quantity = NOT YET DECIDED
production personnel quantity = NOT YET DECIDED
integration-test patrol allocation = ALLOWED TEST-ONLY
strategic auto-credit = FORBIDDEN
```

## 4. Bestehende Produktionsnahe Vehicle Baselines

Unverändert:

```text
Jalalabad / Fenty   48 wheeled vehicles
FOB Joyce           20 wheeled vehicles
FOB Wright          22 wheeled vehicles
FOB Bostick         26 wheeled vehicles
```

Honaker:

```text
2 x M777A2 historically confirmed for 2011-07-30
Foundation technical proxy: 2 x L118_Unit
```

Die bisherige Aussage `Honaker = 0 permanent wheeled vehicles` bleibt nur für die bereits beschlossene frühere Vehicle Baseline gültig und darf **nicht** als Beweis verwendet werden, dass Honaker 2011 keine lokale operative Fahrzeugnutzung oder Staging-Funktion hatte. Die neue Mengenentscheidung bleibt offen.

Fortress erhält ebenfalls noch keine erfundene permanente Vehicle-Baseline.

## 5. Ground Acceptance 1

Acceptance 1 bestätigte für den exakt dokumentierten Joyce-Teststand:

```text
BRIGADE / PLATOON lifecycle
one materialization
SetReturnToLegion(false)
MissionDone physical stay
same physical ARMYGROUP follow-up reuse
spawnCount = 1
```

Ergebnisdokument:

- [`2026-08-18-acceptance-1-runtime.md`](results/2026-08-18-acceptance-1-runtime.md)

Der PATROLZONE-Fahrzeuglauf war technisch nützlich, ist aber kein gewünschtes Production-Fahrverhalten für mounted security groups.

## 6. Ground Acceptance 2

Acceptance 2 ersetzte `PATROLZONE` durch:

```text
ARMOREDGUARD / On Road
-> same-group MissionDone persistence
-> ARMOREDGUARD / Vee
-> FullStop / stable hold
```

Der technische Runtime-Pfad lief bis:

```text
RUNTIME_PASS_VISUAL_PENDING
spawnCount=1
same group reused
Vee visible
hold movedM=0
```

Owner-Beobachtung:

```text
behavior deutlich besser
Vee im Zielgebiet sichtbar
10 kt road speed deutlich zu langsam
DCS time acceleration used
```

Ergebnisdokument:

- [`2026-08-18-acceptance-2-runtime.md`](results/2026-08-18-acceptance-2-runtime.md)

Die vollständige visuelle Acceptance bleibt formal offen, bis sichtbarer Teleport/Despawn und sichtbare Dublette ausdrücklich bestätigt oder verneint wurden. Der getestete ARMOREDGUARD-Verhaltenspfad ist dennoch ausreichend, um nun auf Multi-Domain-Ebene zu skalieren.

## 7. Ground Acceptance 3 – aktueller Gate

Testplan:

- [`OMW-TEST-ARMY-GROUND-ACCEPTANCE-3`](ACCEPTANCE-3.md)

Runtime source:

```text
mission/tests/army-ground-foundation/src/03-army-ground-acceptance-3.lua
```

Builder:

```text
tools/build-army-ground-acceptance-3.ps1
```

BuilderVersion/Test-ID:

```text
ARMY-GROUND-ACCEPTANCE-3-1
```

### Bewegungsprofil

```text
normal road transit:
ARMOREDGUARD / On Road / 27 kt (~50 km/h)

final tactical leg:
ARMOREDGUARD / Vee / 8 kt

objective:
FullStop / stable hold
SetReturnToLegion(false)
```

### Testziel

Alle sechs Domains gleichzeitig:

```text
FENTY
FORTRESS
JOYCE
WRIGHT
HONAKER
BOSTICK
```

Zu prüfen:

```text
six BRIGADE starts
six Warehouse hosts
six independent materializations
one patrol test group per site
no cross-site group/callback/state collision
no duplicate spawn
same-group Mission 1 -> Mission 2 reuse per site
27 kt road movement quality
Vee transition
stable ARMOREDGUARD hold
no visible teleport/despawn
pathfinding quality at all six sites
```

## 8. Mission-Editor-Gate für Acceptance 3

Vor lokalem Build/Einbau muss die aktuelle Owner-`.miz` read-only gegen folgende Objektliste geprüft werden:

```text
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK

TPL_BLUE_GND_PATROL_MATV_4

ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS

ZON_BLUE_GND_FENTY_PATROL_TEST_01
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
ZON_BLUE_GND_WRIGHT_PATROL_TEST_01
ZON_BLUE_GND_HONAKER_PATROL_TEST_01
ZON_BLUE_GND_BOSTICK_PATROL_TEST_01
```

ChatGPT verändert keine `.miz`.

## 9. Offene Architektur-/Research-Punkte

Nicht im Acceptance-3-Test stillschweigend entscheiden:

```text
- final Fortress personnel/vehicle property book
- final Honaker personnel/vehicle property book
- exact July-2011 Joyce company distribution
- exact July-2011 Bostick maneuver company/platoon distribution
- exact July-2011 Wright artillery assignment
- Jalalabad exact ground QRF/base-defense formation
- final Honaker strategic parent/support-parent contract after complete evidence reconciliation
- production return/handoff and Warehouse re-entry
- cross-session reconstitution
- OPSTRANSPORT
- CampaignState exactly-once runtime settlement adapter
```

## 10. Nächster lokaler Schritt

Da derzeit kein Zugriff auf die lokale Entwicklungsstation besteht, bleibt der lokale Gate bewusst offen.

Sobald Zugriff wieder vorhanden ist:

```text
remote branch pull
-> read-only Mission Editor object check
-> build Acceptance 3 bundle
-> record real bundle SHA-256
-> owner embeds bundle in test .miz
-> record final MIZ/internal mission/embedded resource hashes
-> run one six-domain DCS integration test
-> return real logs + visual observations
```

Kein lokaler Build, Hash oder DCS-Verhalten wird bis dahin angenommen oder simuliert.
