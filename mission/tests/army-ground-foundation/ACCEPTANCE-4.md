---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-4
status: PLANNED
document_class: DCS_RUNTIME_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Acceptance 4 Fenty return-handoff runtime criteria
  - branch-scoped MOOSE lifecycle and Mission Editor object contract
not_authoritative_for:
  - CampaignState settlement
  - production resource credit
  - cross-session reconstitution
  - permanent Fortress or Honaker quantities
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_DCS_BUILD
validated_in_dcs: false
base_branch: agent/army-ground-foundation-reconciliation
base_commit: beef12f97a9c53970729270bb7b8b74cdd73f036
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# ARMY Ground Foundation – Acceptance 4

## 1. Zweck und Scope

Acceptance 4 prüft **ausschließlich** den Fenty-Rückgabe-Handoff einer durch MOOSE materialisierten 4 x M-ATV-Patrouille.

```text
WAREHOUSE/BRIGADE materialization
-> ARMOREDGUARD road approach
-> MissionDone with physical group retained
-> public ARMYGROUP:RTZ(return handoff zone, OnRoad)
-> ARMYGROUP Returned
-> existing MOOSE LEGION:__AddAsset(10, group, 1)
-> WAREHOUSE AddAsset
-> physical group removal after the handoff
```

Dabei bleiben unverändert:

```text
CampaignState = sole strategic resource authority
BRIGADE / PLATOON / WAREHOUSE / ARMYGROUP = operational lifecycle
DCS GROUP = temporary physical representation
```

Es gibt keine CampaignState-Buchung, keine Produktionserhöhung, keine Reconstitution und keine Änderung an einer `.miz` durch ChatGPT.

## 2. Ausgangsbasis

Acceptance 3-2 ist nur für den dokumentierten Branch-/Artefaktstand technisch akzeptiert:

```text
Acceptance 3 source commit: 9b4997bf024efe0fab18b4d18552117cd8eeee21
Acceptance 3 bundle SHA-256: 1f3879c1245483ba69cb8a5cc76ea1af4f46cdd01d7c9778440f2a2c6d08ef00
MIZ: OMW_Template_v13_ground_test(10).miz
MIZ SHA-256: a6ce41bc9d7ab0f352f567322401e238dcd2057c548b4ddba44fe9f32f4577cd
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Acceptance 4 ist ein neues Gate. Der Acceptance-3-PASS beweist keinen Rückgabe-Handoff.

## 3. Geprüfte MOOSE-Pfade

Im gepinnten MOOSE-Source sind folgende Pfade geprüft:

```text
ARMYGROUP:RTZ(Zone, Formation)
-> ARMYGROUP:onafterRTZ(...)
-> for mobile groups: AddWaypoint(zone:GetRandomCoordinate(), ..., Formation)
-> temporary detour waypoint

OPSGROUP passing the detour while Returning
-> ARMYGROUP:Returned()

ARMYGROUP:onafterReturned(...)
-> self.legion:__AddAsset(10, self.group, 1)

WAREHOUSE:onafterAddAsset(...)
-> returned known asset restored to Warehouse stock
-> alive physical group: OPSGROUP:Despawn(...) / Stop(...)
```

Für mobile Gruppen verwendet `ARMYGROUP:RTZ` keinen Teleport. Der immobile-Group-Teleportzweig wird weder verwendet noch akzeptiert.

## 4. Road-aligned Materialisierung

Die in Acceptance 3-2 real bestätigte, eng begrenzte interne Spawn-Ausnahme wird **unverändert** für den initialen Fenty-Spawn wiederverwendet:

```text
TM01M-derived absolute unit positions/headings
-> per-BRIGADE _SpawnAssetGroundNaval adapter
-> one _DATABASE:Spawn(template)
```

Sie betrifft nicht den Rückgabeweg. Der Rückgabeweg verwendet ausschließlich die öffentliche MOOSE-`ARMYGROUP:RTZ(...)`-API. Assetreservation, Request Queue, `OnAfterAssetSpawned`, `OnAfterArmyOnMission`, `AUFTRAG` und `ARMYGROUP` werden nicht umgangen.

## 5. Owner Mission-Editor object contract

Der Owner erstellt bzw. positioniert den folgenden Marker. ChatGPT verändert keine `.miz`.

```text
ZON_BLUE_GND_FENTY_RETURN_HANDOFF_01
```

Anforderungen:

- benannte Triggerzone, die nach MOOSE als `ZONE:FindByName(...)` verfügbar ist;
- auf bzw. unmittelbar an einem validen Straßenabschnitt für die Rückfahrt;
- klein genug, dass MOOSE' zufälliger RTZ-Zielpunkt innerhalb der Zone noch durch denselben sicheren Rückgabeabschnitt abgedeckt ist;
- außerhalb jeder für Spieler vernünftig beobachtbaren Rückgabe-/Despawn-Sichtlinie;
- frei von Static-, Scenery- und Gebäudeüberlappung für die vier M-ATV;
- keine neue permanente Fahrzeugmenge und keine zusätzliche Trigger-/Skriptlogik.

Vor DCS ist der gesamte geänderte MIZ-Stand erneut nach dem verbindlichen Artefaktworkflow zu hashen und gegen diesen Objektvertrag zu prüfen.

## 6. Runtime-Kriterien

Der Lauf ist nur positiv, wenn alle folgenden Marker und Beobachtungen vorliegen:

```text
OMW_GND_A4 SITE_READY site=FENTY ...
OMW_GND_A4 ROAD_ALIGNED_WAREHOUSE_SPAWN site=FENTY units=4 ...
OMW_GND_A4 GROUP_MATERIALIZED site=FENTY ...
OMW_GND_A4 MISSION1_DONE site=FENTY physicalGroupRetained=true
OMW_GND_A4 RETURN_TO_HANDOFF_QUEUED site=FENTY ... formation=OnRoad
OMW_GND_A4 RETURNED_HANDOFF site=FENTY ...
OMW_GND_A4 WAREHOUSE_ADD_ASSET site=FENTY ...
OMW_GND_A4 SITE_RUNTIME_PASS site=FENTY spawnCount=1 returnedCount=1 warehouseAddAssetCount=1 physicalGroupRemoved=true
OMW_GND_A4 RUNTIME_PASS_VISUAL_PENDING sites=1 passed=1
```

Zusätzlich visuell:

- vier M-ATV materialisieren road-aligned in Marschreihenfolge ohne Kollision;
- die Gruppe fährt normal zur Rückgabezone;
- es gibt keinen sichtbaren Teleporter;
- die Gruppe wird erst am nicht beobachtbaren Handoff-Ort entfernt;
- kein Doppelspawn und keine zweite Rückgabe.

## 7. Builder und Artefaktkette

```text
Source:
mission/tests/army-ground-foundation/src/04-army-ground-acceptance-4.lua

Builder:
tools/build-army-ground-acceptance-4.ps1

Output:
mission/tests/army-ground-foundation/dist/OMW_Army_Ground_Acceptance_4.lua

BuilderVersion / Test ID:
ARMY-GROUND-ACCEPTANCE-4-1
```

Der Builder blockiert direkte DCS-Spawn-/Teleport-/MIST-Pfade, verlangt genau einen bereits freigegebenen privaten Warehouse-Spawnaufruf und verlangt die RTZ-, Returned-, AddAsset- und Despawn-Prüfmarker.

## 8. Nicht Teil dieses Gates

```text
- CampaignState settlement or strategic resource credit
- production return policy
- cross-session reconstitution
- loss handling
- OPSTRANSPORT
- multi-site return
- Fortress/Honaker quantity decision
- .miz modification by ChatGPT
- merge or Ready-for-Review
```
