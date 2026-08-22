---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned combined DCS acceptance of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - required Mission Editor target- and local resupply-zone contract for that combined run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: 5c4bbe44bee994c5dd9b1c9cfec011e7a67c8158
validated_in_dcs: false
---

# Ground Fire Support Acceptance 2 – kombinierter Vier-Consumer-Lauf

## 1. Ziel

Ein DCS-Lauf bündelt vier getrennt bewertbare Rearm-Legs:

```text
Bostick   L118  -> Regression des bereits früher validierten Bostick-Pfades
Wright    L118  -> Runtime-Acceptance
Fortress  L118  -> Runtime-Acceptance
Honaker   2B11  -> Runtime-Acceptance über explicit MOOSE RearmingGroup
```

Der aktuelle operative Pfad bleibt MOOSE-first:

```text
MOOSE BRIGADE/PLATOON/WAREHOUSE
-> lokaler M1083-Spawn in dedizierter ME-RESUPPLY-Zone
-> CampaignState GROUND_AMMO_PACKAGE consumption
-> MOOSE ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> ARTY OnAfterRearmed
-> MOOSE ARTY return movement to remembered support start coordinate
-> low-frequency MOOSE SCHEDULER return confirmation
-> public WAREHOUSE:AddAsset(group)
-> physical M1083 removed / asset back in Warehouse stock
```

CampaignState bleibt einzige strategische Ressourcenautorität.

## 2. MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich verwendeten Source geprüft:

```text
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
WAREHOUSE:AddAsset(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY:onafterRearm
ARTY:onafterRearmed
SCHEDULER:New(...)
```

`ARTY:onafterRearm` merkt sich die initiale Koordinate der RearmingGroup. `ARTY:onafterRearmed` routet eine lebende RearmingGroup bei einer Distanz oberhalb `RearmingDistance` zu dieser Ausgangskoordinate zurück; andernfalls werden ihre Tasks gelöscht. Für Acceptance 2 wird `RearmingDistance=100 m` und `onRoad=false` verwendet.

## 3. Revision 1 – realer DCS-Lauf vom 22.08.2026

Die erste kombinierte Revision verwendete noch die bestehende private road-aligned Warehouse-Spawn-Ausnahme.

```text
Source commit:
1e086c0e6c7c06239a6e0a1be77f9aed2af0b07a

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-1

Bundle SHA-256:
730F07B1AE79EAA5C4632A4A4CF44A64C41507F2D0E1C317B3F14405F2AA260E

MIZ:
OMW_Template_v15(9).miz

MIZ SHA-256:
BC912E94109731CA043ED75CDB3369CAB033998F451B95FDF516F1A509059002

internal mission SHA-256:
01667C1247E8A06B760356FEBB208A9FB80FF68B9F9E3CABFD3314F27B469EC0

DCS:
2.9.28.26385 MT

dcs log SHA-256:
C57B90AAF86BE2F07E93E1CE974C82ED1721BB13A63AA03CA2EC89CA0261D8C2

debrief SHA-256:
88AA0875B430BE4F75F8A61258E0F8352A092059968A9E8B3D3299AF84AD0614
```

Beobachtetes Ergebnis:

```text
BOSTICK   SITE_PASS
WRIGHT    SITE_PASS
FORTRESS  SITE_PASS
HONAKER   kein SITE_PASS bis GlobalTimeout

Aggregate:
FAIL reason=TIMEOUT seconds=900
```

Der Lauf ist damit **kein Acceptance-2-PASS**. Er beweist für diese exakte Revision den erfolgreichen Rearm-Pfad für Bostick, Wright und Fortress. Er validiert keine nachfolgende Revision.

Zusätzliche Owner-Beobachtung:

```text
- der M1083 wurde durch die road-aligned Ausnahme auf die nächste geeignete Straße gezwungen;
- nicht jedes FOB/COP besitzt innerhalb der Anlage eine geeignete Straße;
- dadurch konnte der temporäre Support-LKW außerhalb der eigentlichen Anlage materialisieren;
- nach Rearm blieb der M1083 an seiner Rückkehr-/Spawnposition physisch bestehen, weil kein Return-to-Warehouse-Cleanup implementiert war.
```

## 4. Revision 2 – Source-Korrektur, nicht DCS-ausgeführt

Revision 2 entfernte den `OMW_GroundRoadSpawnAdapter` aus dem Fixed-Fire-Support-Bundle und führte ein:

```text
public WAREHOUSE:SetSpawnZone(...)
public WAREHOUSE:SetValidateAndRepositionGroundUnits(true)
ARTY-owned support return
public WAREHOUSE:AddAsset(group) return-to-stock
```

Owner-lokal gebaut:

```text
Source commit:
08c51e981061e3647f83231be1361e6e61e51260

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-2

Bundle SHA-256:
9446332A5BEB0088CD27AC0D3B1F0A06B9B8E1B624D004016C85DB77AFEE241A
```

Diese Revision wurde **nicht** in DCS ausgeführt, weil die zunächst im Source vorgesehenen Zonennamen nicht den vom Projektinhaber tatsächlich in der Arbeits-MIZ angelegten `*_RESUPPLY`-Zonen entsprachen.

## 5. Revision 3 – aktueller Testkandidat

Der Source wurde ausschließlich auf die tatsächlich angelegten Mission-Editor-Zonennamen reconciliert:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Aktueller Source-/Builderstand:

```text
Source commit:
5c4bbe44bee994c5dd9b1c9cfec011e7a67c8158

Builder:
tools/build-ground-fire-support-acceptance-2.ps1

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-3

TestId:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2

GeneratedUtc:
2026-08-22T09:34:45Z

Output:
mission/tests/ground-ammo-rearm-integration/dist/OMW_Ground_Fire_Support_Acceptance_2.lua
```

Owner-lokaler Build und unabhängige Hash-Prüfung:

```text
Builder SHA-256:
C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31

Independent Get-FileHash SHA-256:
C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31

Hash match:
PASS
```

Zusätzliche lokal ermittelte Hashes:

```text
02-fixed-fire-support-combined-acceptance.lua
108FD27EFE971BCB375221E0967FC0F508B1F8EB8732EF81081E50D49E60947E

build-ground-fire-support-acceptance-2.ps1
DF464E761806C065747C0B4BE4C6CBF4F6AE0854F1D14EA09D97C91343264438

OMW_GroundSupportMaterializer.lua
4A5506C7719216EFC8098661117B9917A215DAF39C161BD81D2560C7F52964ED

OMW_FixedFireSupportAmmoSupport.lua
30EF36F7F46B46B09398E3D6514D83E29ABDA0069FC9376BAC55E01B5436289A

OMW_FixedFireSupportAmmoRearmService.lua
2829BDD72840FEB14D744072AD7BAD2B81901E43807D5E75BB1DB654AEFFE067
```

## 6. Mission-Editor-Vertrag und Revision-3-MIZ-Preflight

Erforderliche Resupply-Zonen:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Anforderung:

```text
- innerhalb der jeweiligen FOB/COP-Anlage
- nahe dem lokalen Warehouse
- freier, für einen M1083 geeigneter Boden
- nicht als Straßen-/Convoy-Zone auslegen
- Abstand zu HESCOs, Gebäuden, Statics und anderen Ground Units berücksichtigen
```

Die bestehenden Ground-ACCESS-Zonen bleiben unverändert für ihre anderen Ground-/Convoy-Verträge.

Erforderliche Zielzonen:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Nach der Owner-Ersetzung des Acceptance-Bundles wurde die bereitgestellte Arbeits-MIZ read-only geprüft:

```text
MIZ:
OMW_Template_v15(20260822-093745).miz

MIZ SHA-256:
FBA4D8C5966DA375396014E2C2E8BC81B17F7595EBE5DBEF9544AD9FDD2747C5

internal mission SHA-256:
77C876E029C91F098E30648205FDED144EE67F6234385BB5D04E59B9F90A742E

embedded Acceptance-2 bundle SHA-256:
C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31

embedded Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

embedded OMW_AirOps_Warehouse_Base.lua SHA-256:
FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B

embedded OMW_Ground_Base.lua SHA-256:
6DBDE7AA75E34FA6C7A42A7C97B3E407C069806666C60E8D27F8616D647383EE
```

Bundle-Header und Einbindung wurden ebenfalls geprüft:

```text
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-3
GitCommit: 5c4bbe44bee994c5dd9b1c9cfec011e7a67c8158
ResKey_Action_240 -> OMW_Ground_Fire_Support_Acceptance_2.lua
Trigger action 18 -> ResKey_Action_240
Moose.lua loads before Warehouse Base, Ground Base and Acceptance-2
OMW_Ground_Ammo_Rearm_Acceptance_1.lua: NOT PRESENT
```

Objektvertragssmoke nach dem letzten MIZ-Speichern:

```text
four required *_RESUPPLY zones: PRESENT exactly once
RESUPPLY zone radius: 15.24 m each
four required acceptance target zones: PRESENT exactly once
WH_BLUE_GND_BOSTICK / WRIGHT / FORTRESS / HONAKER: PRESENT
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2: 2 x L118_Unit
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2: 2 x L118_Unit
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1: 1 x L118_Unit
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2: 2 x 2B11 mortar
TPL_BLUE_GND_SUP_M1083: 1 x CHAP_M1083, Late Activation
```

Statische Freigabe für den nächsten DCS-Lauf:

```yaml
branch_and_commit_known: true
builder_version_known: true
source_guard_pass: true
lifecycle_guard_pass: true
bundle_built_from_current_source: true
bundle_hash_recorded: true
miz_hash_recorded: true
embedded_bundle_hash_matches: true
embedded_moose_hash_matches: true
object_contract_smoke_present: true
acceptance_criteria_current: true
previous_failures_documented: true
```

Die statische Artefaktkette ist damit für Revision 3 geschlossen. Das ist **kein DCS-Runtime-PASS**.

## 7. Support-Return-/Cleanup-Vertrag

Nach erfolgreichem ARTY-Rearm:

```text
1. MOOSE ARTY OnAfterRearmed wird erreicht.
2. ARTY übernimmt den Return zur beim Rearm gemerkten M1083-Ausgangskoordinate.
3. OMW erzeugt keinen eigenen Return-Wegpunkt und keine Parallelroute.
4. Ein MOOSE SCHEDULER prüft alle 5 s, ob der M1083 wieder innerhalb 100 m seiner Ausgangskoordinate liegt.
5. Timeout des Return-Watch: 300 s.
6. Erst nach dieser Rückkehrgrenze ruft OMW public WAREHOUSE:AddAsset(group) auf.
7. Der M1083 wird damit in den Warehouse-Assetbestand zurückgeführt und seine physische Repräsentation entfernt.
8. Fehler/Tod/Timeout erzeugen SUPPORT_RETURN_FAILED und blockieren SITE_PASS.
```

## 8. Strategische Ressourcen

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

Die Warehouse-Rückgabe des temporären M1083 erzeugt keine zweite strategische Ressourcenhoheit und schreibt keine CampaignState-Munition zurück.

## 9. Ausführung und Marker

```text
ConcurrentSiteLegs: true
FireShellsPerSite: 4
GlobalTimeout: 1200 s
```

Pro Standort:

```text
SITE_START site=<SITE>
SITE_FIRE_COMPLETE site=<SITE>
SITE_REARM_REQUEST site=<SITE>
SITE_SUPPORT_MATERIALIZED site=<SITE>
SITE_CONSUMPTION_COMMITTED site=<SITE>
SITE_REARMED site=<SITE>
SITE_SUPPORT_RETURNED site=<SITE>
SITE_PASS site=<SITE>
```

Aggregate PASS erst nach vier Standort-PASS:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4
```

## 10. PASS-Kriterien pro Standort

```text
- Battery/Mortar object resolved
- controlled fire assignment accepted
- ammunition decreases after firing
- M1083 materializes through public MOOSE Warehouse lifecycle in the dedicated local RESUPPLY zone
- no forced road-aligned Warehouse spawn override is used
- local CampaignState transaction == CONSUMED
- exactly one local GROUND_AMMO_PACKAGE is debited
- ARTY rearm reaches OnAfterRearmed
- final ammunition is restored to at least the recorded initial baseline
- M1083 survives until return handling
- MOOSE ARTY return lifecycle reaches the configured return boundary or no movement is required by that same boundary
- WAREHOUSE:AddAsset returns the known M1083 asset to stock
- no materialized support group remains active after the return handoff
```

## 11. Nicht Teil dieser Acceptance

```text
- Restart/replay semantics
- M1083 destruction/interruption recovery beyond explicit failure detection
- automatic fire-mission generation
- artillery/mortar tactical target allocation
- historical weapon-type replacement
- OP reinforcement lifecycle
- GroundRoadSpawnAdapter regression for convoy missions
```

## 12. Testökonomie

Owner-Entscheidung:

```text
Jeder DCS-Test kostet praktisch mindestens 30 Minuten.
Kleine Folgeänderungen erhalten keinen eigenen Lauf, sofern sie nicht der konkreten Fehlerbehebung/-isolierung dienen.
Anstehende Prüfungen werden soweit möglich in einem gemeinsamen Folgetest gebündelt.
```

Revision 3 kombiniert deshalb:

```text
- Bostick/Wright/Fortress Regression
- offenes Honaker-Rearm-Leg
- lokaler non-road M1083-Spawn
- ARTY-Rückkehr
- Warehouse-Return-to-stock / physischer Cleanup
```

## 13. Aktueller Status

```text
Revision-1 DCS result: AGGREGATE FAIL / HONAKER TIMEOUT
Revision-1 Bostick/Wright/Fortress: SITE_PASS for exact old provenance
Revision-2: BUILT / NOT RUN / superseded as test candidate by zone-name reconciliation
Revision-3 source: SOURCE_REVIEWED / DCS_PENDING
Revision-3 builder: OWNER-BUILT
Revision-3 bundle hash: C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31
Revision-3 build/hash match: PASS
Revision-3 MIZ: OMW_Template_v15(20260822-093745).miz
Revision-3 MIZ hash: FBA4D8C5966DA375396014E2C2E8BC81B17F7595EBE5DBEF9544AD9FDD2747C5
Revision-3 embedded bundle hash match: PASS
Revision-3 embedded Moose hash match: PASS
Revision-3 object contract smoke: PASS
Revision-3 static preflight: PASS
Revision-3 DCS runtime: NOT_RUN
VALIDATED: false
```
