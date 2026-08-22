---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned combined DCS acceptance of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - required Mission Editor target- and local support-spawn-zone contract for that combined run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: 6e0f26c270722450bb974a1f9c6a785fed853cd5
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

Der revidierte operative Pfad bleibt MOOSE-first:

```text
MOOSE BRIGADE/PLATOON/WAREHOUSE
-> lokaler M1083-Spawn in dedizierter ME-Zone
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

dcs log:
dcs(20260822-090622).log
SHA-256 C57B90AAF86BE2F07E93E1CE974C82ED1721BB13A63AA03CA2EC89CA0261D8C2

debrief:
debrief(20260822-090623).log
SHA-256 88AA0875B430BE4F75F8A61258E0F8352A092059968A9E8B3D3299AF84AD0614
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

Der Lauf ist damit **kein Acceptance-2-PASS**. Er beweist für diese exakte Revision den erfolgreichen Rearm-Pfad für Bostick, Wright und Fortress. Er validiert nicht die nachfolgende Revision 2.

Zusätzliche Owner-Beobachtung aus demselben Entwicklungszyklus:

```text
- der M1083 wird durch die road-aligned Ausnahme auf die nächste geeignete Straße gezwungen;
- nicht jedes FOB/COP besitzt innerhalb der Anlage eine geeignete Straße;
- dadurch kann der temporäre Support-LKW außerhalb der eigentlichen Anlage materialisieren;
- nach Rearm blieb der M1083 an seiner Rückkehr-/Spawnposition physisch bestehen, weil kein Return-to-Warehouse-Cleanup implementiert war.
```

Diese Punkte werden in Revision 2 korrigiert und gemeinsam mit dem noch offenen Honaker-Leg geprüft. Kein separater Mini-Regressionstest ist vorgesehen.

## 4. Revision 2 – revidierter Source-Stand

```text
Builder:
tools/build-ground-fire-support-acceptance-2.ps1

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-2

Output:
mission/tests/ground-ammo-rearm-integration/dist/OMW_Ground_Fire_Support_Acceptance_2.lua
```

Eingebundene Source-Module:

```text
scripts/ground/OMW_GroundSupportMaterializer.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
```

Bewusst **nicht** mehr Teil des Fixed-Fire-Support-Bundles:

```text
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
```

Der RoadSpawnAdapter bleibt für echte Road-/Convoy-Materialisierung im Projekt erhalten; Revision 2 verwendet ihn für den lokalen Fire-Support-M1083 nicht.

## 5. Lokaler Warehouse-Spawnvertrag

Für Fixed Fire Support wird ausschließlich die öffentliche MOOSE-Warehouse-Konfiguration verwendet:

```text
WAREHOUSE:SetSpawnZone(localSupportSpawnZone, 500)
WAREHOUSE:SetValidateAndRepositionGroundUnits(true)
```

Die dedizierte Mission-Editor-Zone muss auf freiem, für einen M1083 geeignetem Boden **innerhalb der jeweiligen FOB/COP-Anlage und nahe dem lokalen Warehouse** liegen. Sie ist keine Straßen-/Convoy-Zone.

Erforderliche Zonen:

```text
ZON_BLUE_GND_BOSTICK_AMMO_SUPPORT_SPAWN
ZON_BLUE_GND_WRIGHT_AMMO_SUPPORT_SPAWN
ZON_BLUE_GND_FORTRESS_AMMO_SUPPORT_SPAWN
ZON_BLUE_GND_HONAKER_AMMO_SUPPORT_SPAWN
```

Die vorhandenen Ground-ACCESS-Zonen bleiben unverändert für ihre anderen Ground-/Convoy-Verträge und werden durch Acceptance 2 nicht gelöscht oder umgedeutet.

## 6. Zielzonen

Erforderlich:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Sie müssen innerhalb der realen DCS-Reichweite des jeweiligen Systems liegen und dürfen keine BLUE-/zivilen Objekte oder andere Acceptance-Verträge gefährden.

## 7. Support-Return-/Cleanup-Vertrag

Nach erfolgreichem ARTY-Rearm:

```text
1. MOOSE ARTY OnAfterRearmed wird erreicht.
2. Der ARTY-Class-Lifecycle übernimmt den Return zur beim Rearm gemerkten M1083-Ausgangskoordinate.
3. OMW erzeugt keinen eigenen Return-Wegpunkt und keine Parallelroute.
4. Ein MOOSE SCHEDULER prüft alle 5 s, ob der M1083 wieder innerhalb 100 m seiner Ausgangskoordinate liegt.
5. Timeout des Return-Watch: 300 s.
6. Erst nach dieser Rückkehrgrenze ruft OMW public WAREHOUSE:AddAsset(group) auf.
7. Der M1083 wird damit in den Warehouse-Assetbestand zurückgeführt und seine physische Repräsentation entfernt.
8. Fehler/Tod/Timeout erzeugen SUPPORT_RETURN_FAILED und blockieren SITE_PASS.
```

Die 100-m-Grenze entspricht der explizit gesetzten `ARTY`-`RearmingDistance` und damit derselben Grenze, anhand derer der gepinnte ARTY-Source entscheidet, ob eine physische Rückfahrt erforderlich ist.

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

Alle vier Legs starten im selben Lauf:

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
- M1083 materializes through public MOOSE Warehouse lifecycle in the dedicated local support-spawn zone
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

Ein Standortfehler erzeugt einen eindeutigen `site=<SITE>`-Marker und blockiert den Aggregate-PASS.

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

Revision 2 kombiniert deshalb:

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
Revision-2 source: SOURCE_REVIEWED / DCS_PENDING
Revision-2 contract tests: UPDATED, NOT EXECUTED IN LOCAL OWNER ENVIRONMENT
Revision-2 builder: UPDATED, NOT YET BUILT BY OWNER
Revision-2 bundle hash: PENDING
Revision-2 local support-spawn zones in MIZ: PENDING OWNER ME CHANGE
Revision-2 MIZ embedding: NOT STARTED
Revision-2 DCS runtime: NOT_RUN
VALIDATED: false
```
