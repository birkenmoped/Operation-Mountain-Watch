---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned combined DCS acceptance of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - required Mission Editor target-zone contract for that combined run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: 593589ddeafc3f7671243e2c8c0d0f9866ec5605
validated_in_dcs: false
---

# Ground Fire Support Acceptance 2 – kombinierter Vier-Consumer-Lauf

## 1. Ziel

Der nächste DCS-Lauf soll die knappe Testzeit bündeln und vier getrennt bewertbare Rearm-Legs in **einem** Lauf ausführen:

```text
Bostick   L118  -> Regression des bereits validierten Pfades
Wright    L118  -> neue Runtime-Acceptance
Fortress  L118  -> neue Runtime-Acceptance
Honaker   2B11  -> neue Runtime-Acceptance über explicit MOOSE RearmingGroup
```

Der Lauf verwendet keine neue Native-DCS-Rearm-Logik. Der operative Pfad bleibt:

```text
MOOSE BRIGADE/PLATOON/WAREHOUSE
-> M1083 materialization
-> CampaignState GROUND_AMMO_PACKAGE consumption
-> MOOSE ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> ARTY OnAfterRearmed
```

## 2. Source und Builder

```text
Harness:
mission/tests/ground-ammo-rearm-integration/src/02-fixed-fire-support-combined-acceptance.lua

Builder:
tools/build-ground-fire-support-acceptance-2.ps1

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-1

Output:
mission/tests/ground-ammo-rearm-integration/dist/OMW_Ground_Fire_Support_Acceptance_2.lua
```

Eingebundene Source-Module:

```text
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
scripts/ground/OMW_GroundSupportMaterializer.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
```

## 3. MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source-geprüfte Methoden/FSM-Pfade:

```text
ARTY:New(...)
ARTY:AssignTargetCoord(...)
ARTY:GetAmmo(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:Rearm()
ARTY OnBeforeRearm
ARTY OnAfterRearmed
BRIGADE/PLATOON/WAREHOUSE self-request materialization
```

Für Wright, Fortress und Honaker bleibt der Runtime-Status bis zum ausgeführten Test `DCS_PENDING`.

## 4. Strategische Ressourcen

Pro Standort wird genau eine lokale Ressourceneinheit verwendet:

```text
Bostick   -> GROUND_NODE_BOSTICK
Wright    -> GROUND_NODE_WRIGHT
Fortress  -> GROUND_NODE_FORTRESS
Honaker   -> GROUND_NODE_HONAKER

Resource:
GROUND_AMMO_PACKAGE

Quantity per successful rearm:
1
```

CampaignState bleibt einzige strategische Ressourcenautorität.

## 5. Mission-Editor-Objektvertrag

Bereits vorhandene und read-only bestätigte Objekte:

```text
WH_BLUE_GND_BOSTICK
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_HONAKER

ZON_BLUE_GND_BOSTICK_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS

TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2

TPL_BLUE_GND_SUP_M1083
```

Bostick besitzt bereits:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
```

Für den kombinierten Lauf fehlen in der zuletzt read-only geprüften Mission noch drei eindeutige sichere Zielzonen:

```text
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Diese Zonen dürfen erst nach ausdrücklicher Owner-Freigabe in einer Arbeits-MIZ angelegt werden. Ihre Positionen müssen innerhalb der jeweiligen realen DCS-Reichweite liegen und dürfen keine BLUE-/zivilen Objekte oder andere Acceptance-Verträge gefährden.

## 6. Ausführung

Alle vier Legs werden im selben Lauf gestartet. Das ist beabsichtigt:

```text
ConcurrentSiteLegs: true
FireShellsPerSite: 4
GlobalTimeout: 900 s
```

Jeder Standort führt getrennte Marker:

```text
SITE_START site=<SITE>
SITE_FIRE_COMPLETE site=<SITE>
SITE_REARM_REQUEST site=<SITE>
SITE_SUPPORT_MATERIALIZED site=<SITE>
SITE_CONSUMPTION_COMMITTED site=<SITE>
SITE_REARMED site=<SITE>
SITE_PASS site=<SITE>
```

Aggregate PASS erst nach vier Standort-PASS:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4
```

## 7. PASS-Kriterien pro Standort

```text
- Battery/Mortar object resolved
- controlled fire assignment accepted
- ammunition decreases after firing
- M1083 materializes through existing MOOSE Ground lifecycle
- support group remains alive through completion
- local CampaignState transaction == CONSUMED
- exactly one local GROUND_AMMO_PACKAGE is debited
- ARTY rearm context reaches REARMED
- final ammunition is restored to at least the recorded initial baseline
```

Ein Standortfehler erzeugt einen eindeutigen `site=<SITE>`-Marker und blockiert den Aggregate-PASS.

## 8. Nicht Teil dieser Acceptance

```text
- Restart/replay semantics
- M1083 destruction/interruption recovery
- full-battery no-op/rejection policy beyond existing adapter behavior
- automatic fire-mission generation
- artillery/mortar tactical target allocation
- historical weapon-type replacement
- OP reinforcement lifecycle
```

## 9. Testökonomie

Owner-Entscheidung:

```text
Kein separater Bostick-only Regression Run,
sofern kein konkreter Fehler isoliert werden muss.
```

Der Bostick-Regressionsteil wird mit Wright/Fortress/Honaker in diesem Lauf kombiniert. Separate Folgeprüfungen werden nur zur konkreten Fehlerbehebung oder Fehlerisolierung durchgeführt.

## 10. Aktueller Status

```text
Source generalization: STAGED
Contract tests: ADDED, NOT EXECUTED IN LOCAL OWNER ENVIRONMENT
Builder: STAGED
Combined bundle: NOT YET BUILT BY OWNER
MIZ target-zone preparation: BLOCKED_PENDING_OWNER_APPROVAL
MIZ embedding: NOT STARTED
DCS runtime: NOT_RUN
VALIDATED: false
```
