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

## Lokal bestätigte Acceptance-Build-Provenienz 2026-08-21

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
```

## Erster DCS-Anlauf: INVALID vor Acceptance-Start

Der erste DCS-Anlauf mit DCS `2.9.28.26385 MT` erreichte den Warehouse-Production-READY-Zustand, scheiterte aber vor `OMW_GROUND_READY` beim Ground-Base-Attach:

```text
[OMW][Logistics.AirOpsWarehouseProduction] READY mode=NEW ... readyFlag=1
[OMW][CampaignState] unknown nodeId=GROUND_NODE_JALALABAD
```

Der Fehler trat in zwei Missionsstarts desselben Logsatzes auf. Damit wurde der eigentliche Rearm-Harness nicht gestartet. Dieser Lauf wird deshalb als `INVALID` klassifiziert und ist ausdrücklich kein negativer DCS-Nachweis gegen `CHAP_M1083`, `ARTY:Rearm()` oder den Road-Spawn-Pfad.

Root Cause: Der Warehouse-Production-Bundle erzeugte zwar den gemeinsamen autoritativen CampaignState, hatte `OMW_GroundInitialStock` aber noch nicht in dessen Initialisierung aufgenommen. `OMW_Ground_Base.Attach(...)` erwartete die sechs `GROUND_NODE_*` bereits im gemeinsamen Store.

## Korrigierter Warehouse-Production-Build

Der gemeinsame CampaignState-Produktionspfad wurde auf demselben Integrationsbranch korrigiert. Es wird weiterhin genau ein autoritativer Store erzeugt; Ground-Initialbestand wird nur als zusätzlicher Stock in denselben Initializer eingespeist.

Vom Projektinhaber lokal bestätigt:

```text
Commit:
7da56fdfb45888e7f88d4ea5c3b0fa691f2b0423

BuilderVersion:
OMW-AIROPS-WAREHOUSE-BASE-3

CampaignStateAuthority:
OMW.AirOps.CampaignContext

CampaignStateAdditionalStocks:
OMW_AirOpsInitialJP8Stock,OMW_AirOpsInitialFuelSupplement,OMW_AARStrategicStock,OMW_GroundInitialStock

GroundInitialStockSchema:
OMW-GROUND-INITIAL-STOCK-2

GroundNodesSeeded:
GROUND_NODE_JALALABAD,GROUND_NODE_FORTRESS,GROUND_NODE_JOYCE,GROUND_NODE_WRIGHT,GROUND_NODE_HONAKER,GROUND_NODE_BOSTICK

GroundTransferableResources:
GROUND_SUPPLY_PACKAGE,GROUND_AMMO_PACKAGE,GROUND_FUEL_PACKAGE

Bundle SHA-256:
FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
```

Separat lokal bestätigte SHA-256-Werte:

```text
scripts/logistics/OMW_AirOpsWarehouseProduction.lua
25A8C90C9AA4901B84605EB7F83250545650139F82FE0BDB1999A946EC08040B

tools/build-air-ops-warehouse-production-base.ps1
866E8845DF87AADE798197615364C7A28444FFC064C9334D284F60886D36CF03

scripts/logistics/OMW_GroundInitialStock.lua
E4E099A1C949C69C5E3682403162DC5B435D0C1885845ED5625D281DA77FACCF

scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
275ACBBFC6D102AD1FA5C5398EB4331B6E072B77D9EA063D54CB97AC925B7F13

mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
```

Bewertung dieser Stufe:

```text
REMOTE FIX COMMIT VERIFIED
LOCAL FAST-FORWARD VERIFIED
DIFF CHECK PASS
WAREHOUSE PRODUCTION BUILD PASS
BUILDER/BUNDLE HASH MATCH PASS
PREVIOUS DCS RUN INVALID
NEXT DCS RUN PENDING NEW MIZ HASH CHAIN
M1083 AMMO-SUPPLY EFFECT NOT_VALIDATED
```

Der Dokumentationsvalidator wurde in dieser Stufe nicht ausgeführt; ein `VALIDATED`-Status wird daraus nicht abgeleitet.

## OMW_Template_v15(6): INVALID wegen Ground-Readiness-Gate

Read-only geprüftes Owner-Artefakt:

```text
OMW_Template_v15(6).miz
MIZ SHA-256: 389604B9D16688A0FED4BE9877E1D97E2970057012FE2510FFE41E9D5A2CF3E1
internal mission SHA-256: 3B39D0655C1847D92BEFAB924414CC688056CD4FAD7B162674B371BE1E86CA8A
```

Die relevanten eingebetteten Bytes waren diesmal konsistent:

```text
OMW_AirOps_Warehouse_Base.lua
  BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
  SHA-256: FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B

OMW_Ground_Base.lua
  BuilderVersion: OMW-GROUND-PRODUCTION-BASE-2
  SHA-256: F92A05B6ABE8A12F1470BB2E1A2D6FE66746DDE09DE75D9077675E459411FF3A

OMW_Ground_Ammo_Rearm_Acceptance_1.lua
  SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7

Moose.lua
  SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der DCS-Lauf mit `OMW_Template_v15(6)` erreicht den korrigierten Warehouse-READY-Zustand einschließlich `groundStockSeeded=true`; die früheren `unknown nodeId`-/`unknown resourceId`-Fehler treten in diesem Lauf nicht mehr auf. Der eigentliche Rearm-Acceptance-Harness startet jedoch nicht.

Root Cause ist der Readiness-Vertrag zwischen Lua und Mission Editor:

```text
Mission Editor trigger:
FLAG EQUALS OMW_GROUND_READY, 1

Ground BASE-2:
OMW_GROUND_READY = 1
```

`BASE-2` setzte damit nur eine Lua-Globale. Der Mission-Editor-Trigger prüft dagegen einen DCS User Flag. Der Warehouse-Pfad verwendet bereits MOOSE `USERFLAG` und besitzt deshalb diese Brücke; der Ground-Pfad hatte sie nicht.

Bewertung:

```text
Warehouse BASE-3 startup                  PASS
Ground stock schema / resource mismatch   no longer observed
Ground DCS readiness user flag             NOT REACHED
Acceptance harness                         NOT STARTED
L118 controlled firing                     NOT TESTED
M1083 materialization                      NOT TESTED
CampaignState local ammo consumption       NOT TESTED
ARTY rearm                                 NOT TESTED
M1083 native ammo-supply effect             NOT TESTED

RESULT: INVALID
```

Dies ist kein Feature-FAIL gegen M1083 oder ARTY-Rearm, weil die Acceptance-Voraussetzung nicht erfüllt wurde.

Der gepinnte MOOSE-Stand stellt den öffentlichen `USERFLAG`-Pfad bereit: `USERFLAG:New(name)`, `Set(number)` -> DCS user flag und `Get()` -> DCS user flag readback. Der Ground-Production-Builder verwendet deshalb ab `OMW-GROUND-PRODUCTION-BASE-3` denselben MOOSE-first Readiness-Mechanismus und setzt `OMW_GROUND_READY` fail-closed erst nach erfolgreichem `GroundBase.Attach(...)` plus User-Flag-Readback.

Source-Fix-Commits auf `agent/ground-ammo-rearm-integration`:

```text
0e02d44ff08299eedd3c53657bfe5099a420c2d6
  Make Ground ready gate use MOOSE USERFLAG

318890bc2b05e3102450cbfac79922bf8aa4cca2
  Verify Ground USERFLAG bundle contract
```

Der neue Ground-Bundle ist zu diesem Zeitpunkt noch nicht lokal gebaut oder DCS-validiert. Die Dokumentationsprüfung wird erst nach der realen lokalen Build-/Hash-Rückmeldung und dem nächsten MIZ-Preflight fortgesetzt.

## Finaler DCS-PASS und geschlossene Acceptance-Provenienz 2026-08-22

Der spätere Lauf mit Ground BASE-3 erreichte das reale Mission-Editor-Readiness-Gate und führte den vollständigen Rearm-Harness aus.

Runtime:

```text
DCS: 2.9.28.26385 MT
initialAmmo = 300
postFireAmmo = 296
support type = CHAP_M1083
GROUND_AMMO_PACKAGE before = 52
after = 51
finalAmmo = 302
PASS M1083_REARM_CONFIRMED=true
OMW_GROUND_READY = 1
```

Der Debrief bestätigte zusätzlich zwei BLUE-Verluste (`Soldier M249`, `Soldier M4`) am absichtlich als Artillerieziel verwendeten BLUE OP. Diese Verluste sind Testdesign und kein Rearm-Fehler. Ein daraus später abzuleitender OP->COP/FOB-Verstärkungsbedarf wurde in diesem Lauf nicht getestet.

Die tatsächliche ausgeführte Missionsdatei wurde anschließend read-only gehasht und intern erneut geprüft:

```text
Executed mission path:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v15.miz

MIZ SHA-256:
A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4

internal mission SHA-256:
2378F38E9B07365D25ACE38E45A23D87E2CC76F185A062FB2A46CA8EE31C1A53
```

Embedded-resource recheck der tatsächlich ausgeführten MIZ:

```text
Moose.lua
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
MATCH

OMW_AirOps_Warehouse_Base.lua
FC0F8F20909DD57E5DEE3AF6414FB56B35D8671D726471DEDB6D6984E590801B
MATCH

OMW_Ground_Base.lua
6DBDE7AA75E34FA6C7A42A7C97B3E407C069806666C60E8D27F8616D647383EE
MATCH

OMW_Ground_Ammo_Rearm_Acceptance_1.lua
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
MATCH
```

Runtime-Logs:

```text
dcs(20260821-215616).log
SHA-256: 8ECFD3CACC58FF0421E55280D7CE63EFA2A6C1CDA0A09095F7A69E588290DE71

debrief(20260821-215616).log
SHA-256: B773DDB09401B7E58F4393EEEEDCE858EB98F769E1BE2DE9AB12392B10583A9E
```

Bewertung für genau diese Provenienz:

```text
FUNCTIONAL DCS RESULT: PASS
ACCEPTED_TECHNICAL_BASELINE: YES — EXACT DOCUMENTED SCOPE ONLY
MERGED_TO_MAIN: false
```

Damit sind für diesen exakten Stand praktisch bestätigt:

```text
Ground readiness USERFLAG bridge
OMW_GROUND_READY Mission-Editor gate
L118 controlled firing and ammo reduction
M1083 WAREHOUSE self-request/materialization
CHAP_M1083 operational rearm support for this Bostick L118 path
CampaignState one-package local consumption
ARTY:Rearm()
ARTY Rearmed callback
full-ammo restoration
```

Nicht aus diesem PASS abzuleiten sind Full-Battery-Rejection, M1083-Verlust/Unterbrechung, Restart/Replay, generisches CHAP_M1083-Verhalten, AMMOTRUCK-Runtime oder OP-Verstärkungslogik.
