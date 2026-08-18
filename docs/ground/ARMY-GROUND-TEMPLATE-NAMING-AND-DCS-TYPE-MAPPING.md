---
document_id: OMW-ARMY-GROUND-TEMPLATE-NAMING-TYPE-MAPPING
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working naming scheme for reusable BLUE ground templates, MOOSE ground pools, warehouse mirrors and access zones
  - source-qualified mapping from approved OMW vehicle families to DCS type names for the current Ground Foundation
  - technical proxy decision for the Honaker-Miracle M777A2 representation
  - separation between strategic installation IDs, operational nodes, reusable templates and runtime groups
not_authoritative_for:
  - final Mission Editor object placement
  - DCS runtime acceptance
  - historical equivalence of technical proxies
  - final CampaignState resource quantities beyond the separate vehicle baseline
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Template Naming and DCS Type Mapping

## 1. Zweck

Dieses Dokument legt Naming, Access-Zonen und die aktuelle DCS-Type-/Proxy-Baseline der BLUE Ground Foundation fest.

Die Identitätsebenen bleiben strikt getrennt:

```text
CampaignState installation
!= Ground Node
!= MOOSE warehouse / brigade / platoon
!= reusable DCS template
!= runtime DCS group / ARMYGROUP
```

## 2. Naming

### 2.1 Strategische Installationen

```text
BLUE_GROUND_<CLASS>_<NAME>
```

Beispiele:

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
BLUE_GROUND_FOB_JOYCE
BLUE_GROUND_COP_HONAKER_MIRACLE
BLUE_GROUND_FOB_WRIGHT
BLUE_GROUND_FOB_BOSTICK
BLUE_GROUND_OP_MUSTANG
```

### 2.2 Ground Nodes

```text
GROUND_NODE_JALALABAD
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_BOSTICK
```

### 2.3 MOOSE-Objekte

```text
WH_BLUE_GND_<NODE>
BDE_BLUE_GND_<NODE>
PLT_BLUE_GND_<NODE>_<ROLE>[_<VARIANT>]
```

Die vier aktuellen operativen BRIGADE-Namen sind:

```text
BDE_BLUE_GND_JALALABAD
BDE_BLUE_GND_JOYCE
BDE_BLUE_GND_WRIGHT
BDE_BLUE_GND_BOSTICK
```

`BDE_` ist eine MOOSE-Operationsdomäne und keine historische Brigadebehauptung.

### 2.4 Reusable Mission Editor templates

Projektbaseline:

```text
TPL_<COALITION>_<ROLE>_<VARIANT>
```

Ground-Spezialisierung:

```text
TPL_BLUE_GND_<ROLE>_<VARIANT>
```

`#` wird in projektdefinierten Template-/Aliasnamen nicht verwendet.

## 3. ACCESS-Zonen

Pro Root Ground Node gilt grundsätzlich eine gemeinsame operative Access-/Handoff-Zone:

```text
ZON_BLUE_GND_JALALABAD_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

Sie darf als Materialisierungs-, Abfahrts-, Ankunfts-, Return-/Handoff- und Transfergrenze dienen.

Regeln:

```text
- outside active FOB/COP geometry
- preferably on or directly beside a verified usable road
- no default separate SPAWN / ASSEMBLY / RETURN zones
- no observable spawn/despawn transition
```

Abhängige OPs erhalten keine eigene Standard-ACCESS-Zone, kein Warehouse und keinen eigenen strategischen Stock.

```text
OP access modes:
ROAD
FOOT
ROAD_FOOT

AIR = FORBIDDEN for normal OP sustainment
```

## 4. Materialisierungsklassen

```text
FIXED INSTALLATION DEFENSE
-> physical at mission start
-> no demand-time respawn into exact defensive positions

FIXED FIRE SUPPORT
-> physical at mission start
-> fire mission dynamic, weapon not spawned on demand

MOBILE OPERATIONAL ASSETS
-> CampaignState reservation first
-> materialize at root-node ACCESS boundary
-> validated road/route required

REINFORCEMENT / LOGISTICS TRANSPORT
-> same ACCESS/handoff model
-> strategic ownership changes only by explicit CampaignState settlement
```

## 5. Tatsächlich im aktuellen Missionsartefakt beobachtete Typnamen

Read-only inspection der aktuellen Mission hat folgende relevante Typnamen bestätigt:

```text
CHAP_MATV
MaxxPro_MRAP
CHAP_M1083
Hummer
L118_Unit
2B11 mortar
Soldier M4
Soldier M249
M 818
MLRS FDDM
```

`CHAP_*` bleibt eine Mod-/Content-Abhängigkeit.

Diese Liste ist kein vollständiger Installed-DCS-Katalog.

## 6. Gepinnter MOOSE-Source als zusätzlicher Type-Name-Nachweis

Im tatsächlich verwendeten `Moose.lua`-Stand

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

ist in der CTLD-Hercules-Typentabelle der DCS-Typname

```text
M978 HEMTT Tanker
```

enthalten. Das stützt den exakten Type-String für die Foundation-Planung. Die tatsächliche Verfügbarkeit und das Verhalten in der OMW-Mission bleiben DCS-testpflichtig.

## 7. Beschlossene Foundation-Mappings

| OMW family / role | DCS type | Foundation status | Grenze |
|---|---|---|---|
| M-ATV class | `CHAP_MATV` | `PLANNED_MAPPING` | im aktuellen Missionsartefakt beobachtet; Mod-Abhängigkeit |
| MaxxPro/MRAP class | `MaxxPro_MRAP` | `PLANNED_MAPPING` | im aktuellen Missionsartefakt beobachtet |
| FMTV/M1083 class | `CHAP_M1083` | `PLANNED_MAPPING` | im aktuellen Missionsartefakt beobachtet; Mod-Abhängigkeit |
| utility/HMMWV class | `Hummer` | `PLANNED_MAPPING` | im aktuellen Missionsartefakt beobachtet |
| Fenty fuel-support | `M978 HEMTT Tanker` | `PLANNED_MAPPING` | Type-String im gepinnten MOOSE-Source; OMW-Mission-Test offen |
| Wright engineer/route-support security | `MaxxPro_MRAP` | `PLANNED_ABSTRACTION` | kein Buffalo/Husky-Proxy erfunden; bildet geschützte Engineer-/Route-Support-Begleitung ab, keine Mine-Clearance-Funktion |
| Bostick recovery/support | `CHAP_M1083` | `PLANNED_ABSTRACTION` | Support-/Recovery-Repräsentation; kein DCS-Towing behauptet |
| Honaker-Miracle M777A2 technical proxy | `L118_Unit` | `PLANNED_PROXY` | 2 x L118 repräsentieren 2 x historisch belegte M777A2; keine historische Gleichsetzung |

Damit sind die zuvor offenen Foundation-Type-Slots geschlossen, ohne nicht nachgewiesene Spezialfahrzeuge zu erfinden.

## 8. Reusable Template Baseline

```text
TPL_BLUE_GND_PATROL_MATV_4
  4 x CHAP_MATV

TPL_BLUE_GND_PATROL_MRAP_4
  4 x MaxxPro_MRAP

TPL_BLUE_GND_QRF_MIXED_4
  2 x CHAP_MATV
  2 x MaxxPro_MRAP

TPL_BLUE_GND_SECURITY_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_LOG_M1083_2
  2 x CHAP_M1083

TPL_BLUE_GND_FUEL_M978_2
  2 x M978 HEMTT Tanker

TPL_BLUE_GND_UTILITY_HMMWV_2
  2 x Hummer

TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3
  3 x MaxxPro_MRAP

TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2
  2 x L118_Unit
```

Die konkrete Node-Multiplikation und PLATOON-Zuordnung steht in `OMW-ARMY-GROUND-ROLE-PLATOON-BASELINE`.

## 9. Artilleriegrenze

Historische Evidenz:

```text
COP Honaker-Miracle
30.07.2011
2 x M777A2
C Battery / 3-321 FA
```

Technische Foundation-Abbildung:

```text
2 x L118_Unit
```

Dabei gilt zwingend:

```text
L118_Unit != M777A2 historically
```

Der Proxy ist eine OMW-Designentscheidung, um die belegte feste 155-mm-Fire-Support-Funktion technisch abbilden zu können, solange kein besser bestätigter/geeigneter M777A2-Typ im tatsächlich verwendeten DCS-/Mod-Stand verfügbar ist.

Vor `VALIDATED` müssen mindestens Reichweite, Fire-at-Point-Verhalten, Munition, Sichtwirkung und MOOSE-`AUFTRAG:NewARTY(...)` in DCS geprüft werden.

## 10. Wright- und Bostick-Spezialrollen

### Wright

Es wird **kein** Buffalo-/Husky-/Cougar-DCS-Typ erfunden oder stillschweigend vorausgesetzt.

Die Foundation bildet die Rolle zunächst als geschützte Engineer-/Route-Support-Security ab:

```text
2 x TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2
= 4 x MaxxPro_MRAP
```

Das simuliert keine Minensuch- oder Räummechanik.

### Bostick

Die Recovery-Funktion bleibt fachlich erhalten, aber DCS-Towing wird nicht behauptet.

```text
LOGISTICS / RECOVERY SUPPORT
-> CHAP_M1083 family
```

Eine spätere nachgewiesene Wrecker-Mod-/DCS-Lösung kann diese Abstraktion ersetzen, ohne den CampaignState-Ressourcenvertrag zu ändern.

## 11. Fenty heavy logistics / fuel support

Die frühere vier Fahrzeuge umfassende offene Heavy-Logistics/Fuel-Allokation wird für die Foundation wie folgt geschlossen:

```text
2 x M978 HEMTT Tanker
2 x additional CHAP_M1083 logistics vehicles
```

Zusammen mit der übrigen Fenty-Baseline ergibt sich damit:

```text
16 CHAP_MATV
14 MaxxPro_MRAP
12 CHAP_M1083
2  M978 HEMTT Tanker
4  Hummer
= 48 wheeled vehicles
```

## 12. Acceptance-Grenze

Alle Mappings in diesem Dokument sind Foundation-Planung, nicht DCS-Abnahme.

Offen bleiben insbesondere:

```text
- Mission Editor template creation by the project owner
- M978 availability/behavior in the actual mission
- L118 proxy ballistic/range/ARTY behavior
- road-side ACCESS-zone positions
- pathfinding, tasking, return and visibility behavior
- mod dependency verification for CHAP_* types
```

`VALIDATED` ist erst nach dokumentiertem DCS-Test zulässig.
