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
source_commit: ea07916ddc8e18b5f5d72e48750229dc8085ff63
validated_in_dcs: false
---

# Ground Fire Support Acceptance 2 – kombinierter Vier-Consumer-Lauf

## 1. Ziel

Ein DCS-Lauf bündelt vier getrennt bewertbare Rearm-Legs:

```text
Bostick   L118  -> Regression
Wright    L118  -> Runtime-Acceptance
Fortress  L118  -> Runtime-Acceptance
Honaker   2B11  -> Runtime-Acceptance über explicit MOOSE RearmingGroup
```

Aktueller MOOSE-first-Pfad:

```text
MOOSE BRIGADE/PLATOON/WAREHOUSE
-> WAREHOUSE:SetSpawnZone(RESUPPLY zone)
-> local M1083 materialization
-> CampaignState GROUND_AMMO_PACKAGE consumption
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> ARTY OnAfterRearmed
-> MOOSE ARTY support return
-> low-frequency MOOSE SCHEDULER return confirmation
-> WAREHOUSE:AddAsset(group)
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

Verwendete öffentliche MOOSE-Verträge:

```text
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddAsset(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY:onafterRearm
ARTY:onafterRearmed
SCHEDULER:New(...)
```

Bewusst ausgeschlossen ist ab Revision 4:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
```

Grund: Der gepinnte Source ruft in `UTILS.ValidateAndRepositionGroundUnits(...)` `UTILS.GetCenterPoint(units)` auf; für den gepinnten OMW-Stand wurde keine Definition dieser Funktion gefunden. Der reale Revision-3-Lauf reproduzierte exakt `attempt to call field 'GetCenterPoint' (a nil value)`. OMW patcht MOOSE nicht und implementiert keinen Ersatz, weil `SetSpawnZone(...)` mit kontrolliert freier ME-Zone ausreicht.

## 3. Revision 1 – realer DCS-Lauf

```text
Source commit: 1e086c0e6c7c06239a6e0a1be77f9aed2af0b07a
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-1
Bundle SHA-256: 730F07B1AE79EAA5C4632A4A4CF44A64C41507F2D0E1C317B3F14405F2AA260E
MIZ: OMW_Template_v15(9).miz
MIZ SHA-256: BC912E94109731CA043ED75CDB3369CAB033998F451B95FDF516F1A509059002
internal mission SHA-256: 01667C1247E8A06B760356FEBB208A9FB80FF68B9F9E3CABFD3314F27B469EC0
DCS: 2.9.28.26385 MT
dcs log SHA-256: C57B90AAF86BE2F07E93E1CE974C82ED1721BB13A63AA03CA2EC89CA0261D8C2
debrief SHA-256: 88AA0875B430BE4F75F8A61258E0F8352A092059968A9E8B3D3299AF84AD0614
```

```text
BOSTICK   SITE_PASS
WRIGHT    SITE_PASS
FORTRESS  SITE_PASS
HONAKER   kein SITE_PASS bis GlobalTimeout
Aggregate: FAIL reason=TIMEOUT seconds=900
```

Revision 1 verwendete noch den road-aligned Warehouse-Spawnadapter. Zusätzlich blieb der Support-LKW nach Rückkehr physisch bestehen.

## 4. Revision 2 – nicht DCS-ausgeführt

```text
Source commit: 08c51e981061e3647f83231be1361e6e61e51260
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-2
Bundle SHA-256: 9446332A5BEB0088CD27AC0D3B1F0A06B9B8E1B624D004016C85DB77AFEE241A
```

Revision 2 entfernte den RoadSpawnAdapter aus Fixed Fire Support und führte Local Spawn plus Return-to-stock ein. Sie wurde wegen nicht reconciliierter Zonennamen nicht in DCS ausgeführt.

## 5. Revision 3 – realer DCS-FAIL mit isolierter Root Cause

```text
Source commit: 5c4bbe44bee994c5dd9b1c9cfec011e7a67c8158
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-3
Bundle SHA-256: C3526CE2863C94D4F351D438219B744D23B2A11C09A59094944332DBEDD59B31
MIZ: OMW_Template_v15(20260822-093745).miz
MIZ SHA-256: FBA4D8C5966DA375396014E2C2E8BC81B17F7595EBE5DBEF9544AD9FDD2747C5
internal mission SHA-256: 77C876E029C91F098E30648205FDED144EE67F6234385BB5D04E59B9F90A742E
DCS: 2.9.28.26385 MT
embedded Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs log: dcs(20260822-094345).log
SHA-256: 844D5D5D1E38C96E925F3186F216356A44AB7F91923CB20B33C3D1AC79434B55
debrief: debrief(20260822-094344).log
SHA-256: 5E07BB46F6709FA847C27A239934305CB9974E5569EDB86BC61DD6A3D571499A
```

Ergebnis:

```text
BOSTICK   fire -> ammo decrease -> rearm request reached
WRIGHT    fire -> ammo decrease -> rearm request reached
FORTRESS  fire -> ammo decrease -> rearm request reached
HONAKER   fire -> ammo decrease -> rearm request reached

M1083 materialization: 0/4
SITE_SUPPORT_MATERIALIZED: 0/4
SITE_PASS: 0/4
Aggregate: FAIL reason=TIMEOUT seconds=1200
```

Runtime-Root-Cause:

```text
Moose.lua:7377
attempt to call field 'GetCenterPoint' (a nil value)
ValidateAndRepositionGroundUnits
-> _SpawnAssetGroundNaval
-> _SpawnAssetRequest
-> onafterRequest
```

Die statische Nachprüfung bestätigte im gepinnten Source den Aufruf `UTILS.GetCenterPoint(units)` innerhalb `UTILS.ValidateAndRepositionGroundUnits(...)`, aber keine Definition von `UTILS.GetCenterPoint(...)`. Die Methode `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` ist real und offiziell dokumentiert; der Fehler liegt in ihrer internen Helper-Kette des gepinnten MOOSE-Stands. Der OMW-Prozessfehler bestand darin, diese neue API-Nutzung vor dem Test nicht bis zu dieser internen Abhängigkeit zu prüfen.

## 6. Revision 4 – aktueller Korrekturkandidat

Revision 4 ist die kleinste MOOSE-first-Korrektur:

```text
WAREHOUSE:SetSpawnZone(...): retained
WAREHOUSE:SetValidateAndRepositionGroundUnits(...): NOT CALLED
RoadSpawnAdapter: NOT USED
MOOSE patch/override: NONE
native DCS spawn/reposition: NONE
```

Die vorhandenen kleinen, vom Owner auf freie Flächen gelegten RESUPPLY-Zonen übernehmen den Geometrievertrag. Der Builder blockiert künftig eine erneute Nutzung von `SetValidateAndRepositionGroundUnits` im Fixed-Fire-Support-Modul.

Aktueller Source-Stand vor Owner-Build:

```text
FixedFireSupportAmmoSupport schema:
OMW-FIXED-FIRE-SUPPORT-AMMO-SUPPORT-3

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-4

Bundle hash:
PENDING OWNER BUILD
```

## 7. Mission-Editor-Vertrag

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
```

Zielzonen:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Bestehende ACCESS-Zonen und übrige Missionsobjekte bleiben unverändert.

## 8. Support-Return-/Cleanup-Vertrag

```text
1. ARTY OnAfterRearmed wird erreicht.
2. ARTY übernimmt den Return zur gemerkten M1083-Ausgangskoordinate.
3. OMW erzeugt keinen eigenen Return-Wegpunkt.
4. MOOSE SCHEDULER prüft alle 5 s die 100-m-Rückkehrgrenze.
5. Return-Watch-Timeout: 300 s.
6. Nach bestätigter Rückkehr: WAREHOUSE:AddAsset(group).
7. Physische M1083-Repräsentation wird entfernt; Asset ist wieder im Warehouse-Stock.
8. Keine CampaignState-Munition wird zurückerstattet.
```

## 9. Strategische Ressourcen

```text
Bostick   -> GROUND_NODE_BOSTICK
Wright    -> GROUND_NODE_WRIGHT
Fortress  -> GROUND_NODE_FORTRESS
Honaker   -> GROUND_NODE_HONAKER
Resource  -> GROUND_AMMO_PACKAGE
Quantity  -> 1 je erfolgreichem Rearm
```

## 10. Ausführung und PASS-Kriterien

```text
ConcurrentSiteLegs: true
FireShellsPerSite: 4
GlobalTimeout: 1200 s
```

Pflichtmarker pro Standort:

```text
SITE_START
SITE_FIRE_COMPLETE
SITE_REARM_REQUEST
SITE_SUPPORT_MATERIALIZED
SITE_CONSUMPTION_COMMITTED
SITE_REARMED
SITE_SUPPORT_RETURNED
SITE_PASS
```

Aggregate PASS nur bei:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4
```

Pro Standort muss nachgewiesen werden:

```text
- Battery/Mortar resolved
- fire assignment accepted
- ammunition decreases
- M1083 materializes through public WAREHOUSE lifecycle in RESUPPLY zone
- no road-spawn override
- no SetValidateAndRepositionGroundUnits path
- exactly one local GROUND_AMMO_PACKAGE consumed
- ARTY reaches OnAfterRearmed
- ammunition restored to at least initial baseline
- M1083 survives return handling
- ARTY-owned return reaches boundary or no movement is required
- WAREHOUSE:AddAsset returns known M1083 asset to stock
- no physical support group remains after handoff
```

## 11. Nicht Teil dieser Acceptance

```text
- Restart/replay semantics
- M1083 destruction/interruption recovery beyond explicit failure detection
- automatic fire-mission generation
- tactical target allocation
- historical weapon replacement
- OP reinforcement lifecycle
- GroundRoadSpawnAdapter regression
- MOOSE patch or UTILS.GetCenterPoint fallback
```

## 12. Testökonomie

Owner-Entscheidung:

```text
Jeder DCS-Test kostet praktisch mindestens 30 Minuten.
Kleine Folgeänderungen erhalten keinen eigenen Lauf, sofern sie nicht der konkreten Fehlerbehebung/-isolierung dienen.
```

Revision 4 ist eine direkte Korrektur der in Revision 3 isolierten Runtime-Ursache und bleibt derselbe kombinierte Vier-Standort-Lauf.

## 13. Aktueller Status

```text
Revision-1: AGGREGATE FAIL / HONAKER TIMEOUT; Bostick/Wright/Fortress SITE_PASS for exact old provenance
Revision-2: BUILT / NOT RUN / superseded
Revision-3: FAIL / pinned MOOSE GetCenterPoint defect isolated
Revision-3 fire legs: 4/4 reached rearm request
Revision-3 support materialization: 0/4
Revision-4 source: STAGED
Revision-4 builder: UPDATED / OWNER BUILD PENDING
Revision-4 bundle hash: PENDING
Revision-4 MIZ embedding: NOT STARTED
Revision-4 DCS runtime: NOT_RUN
VALIDATED: false
```
