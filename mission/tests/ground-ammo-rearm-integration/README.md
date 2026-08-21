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

Read-only geprüfte Startup-Reihenfolge in `OMW_Template_v15(3).miz`:

```text
LOAD_MOOSE                         mission start
LOAD_AIROPS_WAREHOUSE_BASE         TIME > 1 s
LOAD_GROUND_BASE                   TIME > 2 s + OMW_WAREHOUSE_READY == 1
  -> load OMW_Ground_Base.lua
  -> OMW.Ground.Base.Attach(...)
LOAD_AAR_BASE                      TIME > 5 s + OMW_WAREHOUSE_READY == 1
```

Der Acceptance-Bundle darf daher erst nach erfolgreichem Ground-Base-Attach geladen werden. Für den DCS-Test ist ein eigener Trigger vorgesehen:

```text
LOAD_GROUND_AMMO_REARM_ACCEPTANCE_1
TYPE: ONCE
CONDITIONS:
  TIME MORE 3
  FLAG EQUALS OMW_GROUND_READY, 1
ACTION:
  DO SCRIPT FILE OMW_Ground_Ammo_Rearm_Acceptance_1.lua
```

Diese Triggerintegration wird erst nach bestätigter lokaler Bundle-Provenienz in einer Testkopie der Mission vorgenommen. Sie ändert keine Produktionslogik und ersetzt keinen vorhandenen Startup-Trigger.

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

## Lokal bestätigte Build-Provenienz 2026-08-21

Vom Projektinhaber real ausgeführt und zurückgemeldet:

```text
Source/Build commit:
213119ca03a6aeae529d4291b4bbe174ac0995c2

BuilderVersion:
GROUND-AMMO-REARM-ACCEPTANCE-1

TestId:
GROUND-AMMO-REARM-ACCEPTANCE-1

GeneratedUtc:
2026-08-21T19:59:08Z

Bundle SHA-256:
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
```

Der vom Builder ausgegebene Bundle-Hash und der unmittelbar danach separat mit `Get-FileHash` ermittelte Hash stimmen exakt überein.

Zusätzlich lokal gemeldete SHA-256-Werte:

```text
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
733169BA2AE73D5234AD14A875038BAFD441244B9DE45CB0B22903325B218ACD

scripts/ground/OMW_BostickAmmoRearmService.lua
4A863B257C63E9E138B469BDDFA9E3BE6C7A59AF2A2E6B3AFF3B6B3B9AC698CC

tests/ground/test_ground_ammo_rearm_prestarted.lua
3CD4CF1B759BB891362B556D67974A34E768892FEA49FB29F2C799CE75BA3FB7

mission/tests/ground-ammo-rearm-integration/src/01-bostick-m1083-rearm-acceptance.lua
4B100C30EB5F95CD456CA6B6D3C2E6B9E5D80ADFB1AE2CF7650064C35529915E

tools/build-ground-ammo-rearm-acceptance.ps1
508D0901911CFF57242B205D625AC1EDFACDAF2951854BE8211642D23428A40E

mission/tests/ground-ammo-rearm-integration/README.md (pre-provenance-update)
C9D618A8042452E3C290978C4C5EEAFA0E0A3152186A3A4655101344CB715940
```

Bewertung dieser Stufe:

```text
REMOTE SOURCE COMMIT VERIFIED
LOCAL FAST-FORWARD VERIFIED
LOCAL HEAD VERIFIED
DIFF CHECK PASS
LOCAL ACCEPTANCE BUILD PASS
BUILDER/BUNDLE HASH MATCH PASS
DCS RESULT NOT_RUN
M1083 AMMO-SUPPLY EFFECT NOT_VALIDATED
```

Der Dokumentationsvalidator wurde in dieser Stufe nicht ausgeführt; ein `VALIDATED`-Status wird daraus nicht abgeleitet.

## Status vor DCS-Lauf

```text
SOURCE IMPLEMENTED
BUILDER IMPLEMENTED
LOCAL BUILD/HASH VERIFIED
MIZ INTEGRATION PENDING
DCS RESULT NOT_RUN
M1083 AMMO-SUPPLY EFFECT NOT_VALIDATED
```

Erst ein realer DCS-Lauf mit Bundle-/MIZ-/Log-/Debrief-Provenienz darf diesen Status anheben.
