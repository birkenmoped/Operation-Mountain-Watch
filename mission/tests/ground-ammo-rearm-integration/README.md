# Bostick M1083 / L118 Rearm Acceptance

## Ziel

`GROUND-AMMO-REARM-ACCEPTANCE-1` ist der gebündelte Runtime-Nachweis für den ersten lokalen OMW-Ground-Rearm-Vertical-Slice.

```text
Bostick fixed L118 battery
-> controlled ARTY firing
-> observable ammunition reduction
-> Bostick M1083 WAREHOUSE self-request
-> road-aligned ACCESS materialization
-> CampaignState GROUND_AMMO_PACKAGE CONSUMPTION
-> ARTY:Rearm()
-> native DCS rearm effect
-> ARTY Rearmed
-> full-ammo confirmation
```

Der Test führt keine eigene strategische Ressourcenhoheit ein. Er verwendet ausschließlich den bereits an `OMW.Ground.Base` gebundenen autoritativen `CampaignState`-Store.

## Missionsbasis

Owner-provided Mission-Editor-Artefakt, read-only geprüft:

```text
OMW_Template_v15(3).miz
SHA-256: DE19EC3727591E5BEC1FB00E6EEF2D63FF688C97D57390A2BF68607A15E5D84D
```

Erforderliche Objekte:

```text
WH_BLUE_GND_BOSTICK
ZON_BLUE_GND_BOSTICK_ACCESS
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_SUP_M1083
```

Die Zielzone wurde ausdrücklich für diesen Acceptance-Scope angelegt. Entfernte ältere Patrol-/Testmarker werden nicht vorausgesetzt und nicht rekonstruiert.

## MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für diesen Lauf werden aus dem gepinnten Source insbesondere folgende öffentliche ARTY-Pfade verwendet:

```lua
ARTY:New(group, alias)
ARTY:AssignTargetCoord(...)
ARTY:GetAmmo(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:Rearm()
ARTY OnAfterCeaseFire
ARTY OnBeforeRearm
ARTY OnAfterRearmed
```

Wichtige Source-Grenze: `ARTY:onafterStart(...)` schreibt den initialen Munitionsbestand in `Nammo0`/`Nshells0`/weitere Baselines. `_CheckRearmed()` vergleicht den späteren Munitionsstand gegen diese Start-Baseline. Deshalb darf dieselbe ARTY-Instanz nach dem Acceptance-Feuer nicht erneut mit `Start()` initialisiert werden. Der Rearm-Adapter unterstützt dafür `startArty = false`; dies übergibt die bereits laufende ARTY-Instanz an `Rearm()` und erhält die ursprüngliche Vollbestand-Baseline.

## Testablauf

Der Harness:

1. verlangt `OMW_GROUND_READY == 1` und liest `store`/`campaignState` aus `OMW.Ground.Base.GetContext()`;
2. erstellt die Bostick-Test-`BRIGADE` am vorhandenen Warehouse und bindet die vorhandene ACCESS-Zone;
3. erstellt genau eine `ARTY`-Instanz für `TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2`;
4. weist `ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET` mit vier Schuss als Testziel zu;
5. erfasst den realen ARTY-Munitionsbestand vor und nach dem Engagement;
6. fordert `TPL_BLUE_GND_SUP_M1083` über den bestehenden MOOSE-Self-Request-/RoadSpawn-Pfad an;
7. reserviert und verbraucht genau ein `GROUND_AMMO_PACKAGE` erst am bestätigten ARTY-`OnBeforeRearm`-Kopplungspunkt;
8. wartet auf `ARTY OnAfterRearmed` und prüft den wiederhergestellten Munitionsbestand;
9. bricht nach 600 Sekunden mit `FAIL` ab, wenn der Lifecycle nicht abgeschlossen wurde.

## PASS-Kriterien

```text
initialAmmo > postFireAmmo
finalAmmo >= initialAmmo
CampaignState transaction status == CONSUMED
Bostick GROUND_AMMO_PACKAGE available == before - 1
materialized support GROUP is alive
rearm context status == REARMED
log marker: PASS M1083_REARM_CONFIRMED=true
```

`finalAmmo >= initialAmmo` ist absichtlich nicht auf exakte Gleichheit eingeschränkt, weil der gepinnte ARTY-Source selbst einen beobachteten DCS-Fall dokumentiert, in dem ein Rearm einen zusätzlichen Schuss gegenüber der ursprünglichen Maximalzahl ergab.

## Builder

```text
tools/build-ground-ammo-rearm-acceptance.ps1
```

Ausgabe:

```text
mission/tests/ground-ammo-rearm-integration/dist/OMW_Ground_Ammo_Rearm_Acceptance_1.lua
```

Der Builder bettet nur die bereits getrennten Ground-Module plus Acceptance-Harness ein. Die einzige private MOOSE-Abhängigkeit bleibt der bereits owner-genehmigte `OMW_GroundRoadSpawnAdapter` mit genau einem `_DATABASE:Spawn(template)` im Warehouse-Geometriepfad.

## Status vor DCS-Lauf

```text
SOURCE IMPLEMENTED
BUILDER IMPLEMENTED
LOCAL BUILD/HASH PENDING
DCS RESULT NOT_RUN
M1083 AMMO-SUPPLY EFFECT NOT_VALIDATED
```

Erst ein realer DCS-Lauf mit Bundle-/MIZ-/Log-/Debrief-Provenienz darf diesen Status anheben.
