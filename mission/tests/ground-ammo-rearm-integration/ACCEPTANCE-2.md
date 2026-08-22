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
source_commit: 1e086c0e6c7c06239a6e0a1be77f9aed2af0b07a
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

## 10. Reale lokale Build-Provenienz

Vom Projektinhaber am 22.08.2026 lokal ausgeführt:

```text
Git HEAD:
1e086c0e6c7c06239a6e0a1be77f9aed2af0b07a

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-1

TestId:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2

GeneratedUtc:
2026-08-22T08:42:47Z

Bundle:
mission/tests/ground-ammo-rearm-integration/dist/OMW_Ground_Fire_Support_Acceptance_2.lua

Builder SHA-256:
730F07B1AE79EAA5C4632A4A4CF44A64C41507F2D0E1C317B3F14405F2AA260E

Independent Get-FileHash SHA-256:
730F07B1AE79EAA5C4632A4A4CF44A64C41507F2D0E1C317B3F14405F2AA260E

Hash match:
PASS
```

Zusätzliche lokal ermittelte Source-/Builder-/Test-Hashes:

```text
OMW_FixedFireSupportAmmoSupport.lua
9277057D7E3DB511C66A2ED430E6DFA5FC211F9E6F00530CDEA00BC566CEF40B

OMW_FixedFireSupportAmmoRearmService.lua
FF02B1184DF6F576E73090711B8CF1A29EF5C7DFD168EA5826631ABEB6C7C951

02-fixed-fire-support-combined-acceptance.lua
E866E375FE8CB884B1CF984291839E14F4E3E1CA8DFC23F3DAF2AF68C8AD87D1

build-ground-fire-support-acceptance-2.ps1
8E7B49F7651A5A10B1F47B4FF83162871DA208C29B14F9A474BEA875630F18CF

test_fixed_fire_support_ammo_support.lua
EBE28CA1789E2A29867317D38D0795837094349D6004F75B42042472CC19D78E

test_fixed_fire_support_ammo_rearm_service.lua
AF7DEA1BBBDFAB8B8FCD685E761FE0580DBB693919A1C4221B80FECD398FD1A1

ACCEPTANCE-2.md before this provenance update
B1AF54DBE5C02604F4E6A2D9EF87D29990C236A7341C9D028CA6B8C17DF2C73B
```

## 11. Aktueller Status

```text
Source generalization: STAGED
Contract tests: ADDED, NOT EXECUTED IN LOCAL OWNER ENVIRONMENT
Builder: BUILT BY OWNER
Combined bundle: BUILT AND HASH-MATCHED
MIZ target-zone preparation: BLOCKED_PENDING_OWNER_APPROVAL
MIZ embedding: NOT STARTED
DCS runtime: NOT_RUN
VALIDATED: false
```
