---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-3
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned scope and pass/fail criteria for the six-domain Kunar/Jalalabad ground integration test
  - concurrent BRIGADE/Warehouse/PLATOON lifecycle test for Fenty, Fortress, Joyce, Wright, Honaker-Miracle and Bostick
not_authoritative_for:
  - final production vehicle quantities for Fortress or Honaker-Miracle
  - final Mission Editor geometry
  - production behavior beyond the exactly documented Acceptance-3 runtime scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: true
supersedes:
superseded_by:
---

# ARMY Ground Foundation – Acceptance 3

## 1. Ziel

Acceptance 3 skaliert den in Acceptance 2 technisch bestätigten mounted-ground lifecycle auf sechs operative MOOSE-Domänen gleichzeitig.

```text
FENTY
FORTRESS
JOYCE
WRIGHT
HONAKER
BOSTICK

per domain:
ACCESS
-> one 4 x M-ATV ARMYGROUP
-> ARMOREDGUARD road approach / On Road / 27 kt
-> halt at road-side approach point
-> MissionDone with SetReturnToLegion(false)
-> same physical ARMYGROUP
-> ARMOREDGUARD tactical leg / Vee / 8 kt
-> FullStop at observation position
-> stable hold
```

Der Test ist ausdrücklich ein Integrations- und Parallelitätscheck. Er leitet aus den Testgruppen keine neuen CampaignState-Produktionsmengen ab.

## 2. Architekturgrenze

```text
CampaignState strategic authority
!= MOOSE BRIGADE / WAREHOUSE operational domain
!= physical DCS GROUP / ARMYGROUP
```

Für Fortress und Honaker-Miracle gilt im Test:

```text
integration-test patrol allocation only
production vehicle quantity = NOT YET DECIDED
strategic auto-credit = FORBIDDEN
```

Die Existenz einer test-only MOOSE-BRIGADE oder eines Warehouse-Hosts ist keine Aussage über historische Brigadegliederung oder einen unabhängigen strategischen Ressourcenpool.

## 3. Gepinnte MOOSE-Basis

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Acceptance 3 verwendet keine neue MOOSE-Mechanik gegenüber Acceptance 2. Wiederverwendet werden die bereits source-geprüften Pfade:

```lua
BRIGADE:New(...)
WAREHOUSE:SetSpawnZone(...)
PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:CountAssets(...)
LEGION:AddMission(...)
AUFTRAG:NewARMOREDGUARD(Coordinate, Formation)
AUFTRAG:SetMissionSpeed(Speed)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:__Cancel(delay)
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:GetClosestPointToRoad(...)
OPSGROUP MissionExecute / MissionDone callbacks
ARMYGROUP:FullStop()
SCHEDULER:New(...)
```

## 4. Operative Domains

| Site | BRIGADE | Warehouse host | PLATOON |
|---|---|---|---|
| Fenty | `BDE_BLUE_GND_JALALABAD` | `WH_BLUE_GND_FENTY` | `PLT_BLUE_GND_JALALABAD_PATROL_MATV` |
| Fortress | `BDE_BLUE_GND_FORTRESS` | `WH_BLUE_GND_FORTRESS` | `PLT_BLUE_GND_FORTRESS_PATROL_TEST` |
| Joyce | `BDE_BLUE_GND_JOYCE` | `WH_BLUE_GND_JOYCE` | `PLT_BLUE_GND_JOYCE_PATROL` |
| Wright | `BDE_BLUE_GND_WRIGHT` | `WH_BLUE_GND_WRIGHT` | `PLT_BLUE_GND_WRIGHT_PATROL` |
| Honaker | `BDE_BLUE_GND_HONAKER` | `WH_BLUE_GND_HONAKER` | `PLT_BLUE_GND_HONAKER_PATROL_TEST` |
| Bostick | `BDE_BLUE_GND_BOSTICK` | `WH_BLUE_GND_BOSTICK` | `PLT_BLUE_GND_BOSTICK_PATROL` |

Fortress- und Honaker-PLATOON-Namen tragen bewusst `TEST`, damit aus dieser Acceptance keine produktive Mengenentscheidung abgeleitet wird.

Gemeinsames Template:

```text
TPL_BLUE_GND_PATROL_MATV_4
4 x CHAP_MATV
```

## 5. Mission-Editor-Vertrag

Vor dem Build muss die Owner-Mission read-only gegen folgende Objekte geprüft werden:

```text
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK

TPL_BLUE_GND_PATROL_MATV_4

ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS

ZON_BLUE_GND_FENTY_PATROL_TEST_01
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
ZON_BLUE_GND_WRIGHT_PATROL_TEST_01
ZON_BLUE_GND_HONAKER_PATROL_TEST_01
ZON_BLUE_GND_BOSTICK_PATROL_TEST_01
```

ChatGPT verändert keine `.miz`.

## 6. Bewegungsprofil

### Road transit

```text
AUFTRAG:NewARMOREDGUARD(approachCoord, On Road)
SetMissionSpeed(27 kt)
SetReturnToLegion(false)
```

`27 kt` ist die technische Annäherung an die bereits für OMW-TM01M verwendete `50 km/h` Convoy-Baseline.

### Tactical final leg

```text
AUFTRAG:NewARMOREDGUARD(observationCoord, Vee)
SetMissionSpeed(8 kt)
SetReturnToLegion(false)
```

Der road-side approach point wird ungefähr 1500 m vor dem Ziel erzeugt und auf den nächsten Straßenpunkt gelegt. Die taktische Endstrecke muss nach dem Road-Snap weiterhin über 1050 m liegen.

## 7. Parallelitätsziel

Alle sechs BRIGADEs werden im selben Harness gestartet. Die erste Mission wird je Domain nach demselben kurzen Post-Start-Delay eingereiht. Der Test prüft damit bewusst gleichzeitige MOOSE-/DCS-Ground-Lifecycles und keine sequentielle Einzelabnahme.

Zu validieren:

```text
six BRIGADE instances start
six Warehouse hosts resolve
six PLATOONs each report exactly one ARMOREDGUARD-capable in-stock asset
exactly one physical group materializes per domain
no alias/callback/state collision
no group is reused across domains
same group is reused inside its own domain for Mission 2
no duplicate materialization
```

## 8. Runtime-PASS je Domain

Eine Domain erreicht Runtime-PASS nur wenn:

```text
spawnCount == 1
first ARMYGROUP remains alive after Mission 1
Mission 2 receives the exact same ARMYGROUP
Mission 2 reaches ARMOREDGUARD execution
hold movement after 20 s <= 75 m
distance to observation target <= 250 m
no harness FAIL was raised
```

Wenn alle sechs Domains diese Kriterien erfüllen, loggt der Harness:

```text
OMW_GND_A3 RUNTIME_PASS_VISUAL_PENDING sites=6 passed=6
```

Das ist noch kein endgültiges Acceptance-PASS.

## 9. Visuelle Acceptance

Der Owner bewertet alle sechs Standorte gemeinsam:

```text
[ ] alle sechs Gruppen materialisieren ohne sichtbare Dubletten
[ ] kein sichtbarer Teleport / Despawn
[ ] kein langes oder wiederholtes Kreisen am ACCESS vor dem Abmarsch
[ ] Straßenfahrt bei 27 kt wirkt gegenüber Acceptance 2 plausibler
[ ] kein offensichtlich unbrauchbares Pathfinding an einem Standort
[ ] je Domain klarer Übergang von On Road in Vee
[ ] Vee-/aufgefächerte Formation am Ziel sichtbar
[ ] keine zufälligen Patrol-Runden im Zielgebiet
[ ] jede Gruppe erreicht einen stabilen Halt
```

Zeitbeschleunigung darf verwendet werden, muss für die Provenienz angegeben werden. Sie darf nicht zur Bewertung kurzfristiger Formationseffekte verwendet werden, wenn diese bei hoher Beschleunigung optisch nicht zuverlässig beurteilbar sind.

## 10. Erforderliche Logmarker

Global:

```text
OMW_GND_A3 START testId=ARMY-GROUND-ACCEPTANCE-3-2 sites=6
OMW_GND_A3 RUNTIME_PASS_VISUAL_PENDING sites=6 passed=6
```

Je Domain mindestens:

```text
OMW_GND_A3 SITE_READY site=<SITE> ...
OMW_GND_A3 BRIGADE_STARTED site=<SITE> ...
OMW_GND_A3 PLATOON_READY site=<SITE> assets=1
OMW_GND_A3 MISSION1_QUEUED site=<SITE> formation=On Road speedKt=27
OMW_GND_A3 GROUP_MATERIALIZED site=<SITE> ...
OMW_GND_A3 APPROACH_GUARD_EXECUTING site=<SITE> ...
OMW_GND_A3 MISSION1_DONE site=<SITE> reservation=FIELD_DEPLOYED
OMW_GND_A3 MISSION2_QUEUED site=<SITE> formation=Vee speedKt=8
OMW_GND_A3 MISSION2_SAME_GROUP site=<SITE> ...
OMW_GND_A3 OBS_GUARD_EXECUTING site=<SITE> ...
OMW_GND_A3 SITE_RUNTIME_PASS site=<SITE> ...
```

## 11. FAIL-Kriterien

```text
missing ME object
invalid geometry at any site
BRIGADE or PLATOON construction failure
PLATOON asset count != 1
more than one materialization for a site
same ARMYGROUP correlated to two different sites
Mission 2 receives a different ARMYGROUP
group removed after Mission 1
hold movement > 75 m
target distance > 250 m
runtime Lua error
visible teleport/despawn
unusable repeated ACCESS loop at any site
```

Ein einzelner Site-FAIL verhindert den globalen PASS.

## 12. Nicht validiert

Acceptance 3 validiert nicht:

```text
final Fortress vehicle quantity
final Honaker vehicle quantity
per-vehicle observation sectors
combat response / enemy contact
QRF behavior
logistics payloads
OP reinforcement
return-to-warehouse handoff
cross-session reconstitution
full CampaignState settlement adapter
multiplayer synchronization
```

## 13. Provenienzregel

Ein endgültiger Acceptance-Status ist nur mit realer Evidenz zulässig für:

```text
branch
source commit
BuilderVersion/Test-ID
mission filename
mission SHA-256
internal mission SHA-256
runtime bundle SHA-256
embedded bundle SHA-256
DCS version
Moose.lua SHA-256 / commit
relevant dcs.log markers
owner visual observations
```

## Addendum 2026-08-19 – Acceptance 3-2: road-aligned Warehouse-Spawn-Ausnahme

Die öffentliche, gepinnte MOOSE-`WAREHOUSE`-API nimmt keine individuellen absoluten Unitpositionen oder Headings entgegen. Im tatsächlichen Source wählt `WAREHOUSE:_SpawnAssetGroundNaval(...)` sonst eine zufällige Koordinate in der Spawnzone und verschiebt das Template relativ dazu.

Der Projektinhaber hat am **19.08.2026** die kleinstmögliche Ausnahme ausdrücklich genehmigt:

~~~text
pro BRIGADE-Instanz lokaler Adapter an WAREHOUSE:_SpawnAssetGroundNaval(...)
TM01M-Positions-/Heading-Berechnung wiederverwenden
keine direkte SPAWN-Materialisierung
keine Änderung von Assetreservation, Warehouse-Request, AssetSpawned-/ArmyOnMission-Callbacks,
ARMYGROUP-/AUFTRAG-Lifecycle oder CampaignState-Autorität
~~~

Der Adapter ist auf Ground-Assets der sechs Acceptance-3-Instanzen beschränkt. Er setzt die TM01M-berechneten Straßenpositionen (18 m Abstand, 20 m hinterer Freiraum, 10-m-Heading-Sample, höchstens 30 m Road-Snap) in die vom ursprünglichen Warehouse bereits vorbereitete Spawn-Templatekopie und führt danach genau einen internen DCS-Spawn aus. Andere Kategorien fallen in die originale MOOSE-Methode zurück.

Status: `SOURCE_REVIEWED_EXCEPTION_APPROVED_DCS_PENDING`. Das ist weder eine allgemeine MOOSE-API noch eine Produktionsbaseline. Der DCS-Regressionstest muss zusätzlich zum bisherigen Lifecycle die road-aligned Aufstellung, Marschreihenfolge/Fahrtrichtung, fehlende Scenery-/Static-Kollisionen sowie unveränderte einmalige Warehouse-Materialisierung und denselben ARMYGROUP über Mission 1/2 belegen.

Zusätzliche erwartete Marker:

~~~text
OMW_GND_A3 ROAD_ALIGNED_WAREHOUSE_SPAWN site=<SITE> units=4 leadDistanceM=74 maximumSnapM=<30
~~~

Zusätzlicher FAIL: privater Spawnadapter fehlt/ist unvereinbar, Road-Projektion liegt außerhalb ACCESS, Road-Snap > 30 m, Abstand < 8 m oder die sichtbare Aufstellung kollidiert mit Geometrie.
## 14. DCS-Ergebnis – 19.08.2026

**Ergebnis: PASS für den exakt folgenden branchgebundenen technischen Stand.**

~~~text
Branch: agent/army-ground-foundation-reconciliation
Tested source commit: 9b4997bf024efe0fab18b4d18552117cd8eeee21
BuilderVersion/Test-ID: ARMY-GROUND-ACCEPTANCE-3-2
Bundle SHA-256: 1f3879c1245483ba69cb8a5cc76ea1af4f46cdd01d7c9778440f2a2c6d08ef00
Mission artifact: OMW_Template_v13_ground_test(10).miz
MIZ SHA-256: a6ce41bc9d7ab0f352f567322401e238dcd2057c548b4ddba44fe9f32f4577cd
internal mission SHA-256: 2888b04265516f6aa1698f54cf08d3df987d8e7c7f3335e0594da46deba8a3b4
embedded bundle SHA-256: 1f3879c1245483ba69cb8a5cc76ea1af4f46cdd01d7c9778440f2a2c6d08ef00
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT / Windows 10.0.26200
~~~

Die reale Laufzeit zeigte sechs `ROAD_ALIGNED_WAREHOUSE_SPAWN`-Marker mit jeweils vier M-ATV, `leadDistanceM=74` und maximal `4 m` Road-Snap. Alle sechs Domains materialisierten genau einmal, führten Mission 1 aus, behielten mit `SetReturnToLegion(false)` ihre physische Gruppe, verwendeten für Mission 2 denselben ARMYGROUP und endeten mit `SITE_RUNTIME_PASS`. Der globale Marker lautet `RUNTIME_PASS_VISUAL_PENDING sites=6 passed=6`.

Der Projektinhaber bestätigte die visuelle Abnahme des erfolgreichen Laufs als **„Perfekt“**. Damit ist für diesen Artefaktstand zusätzlich bestätigt: road-aligned Aufstellung, Marschreihenfolge/Fahrtrichtung und keine sichtbare Scenery-/Static-Kollision.

Die Akzeptanz gilt nur für den oben genannten Branch, Commit, Bundle, MIZ, MOOSE- und DCS-Stand. Sie ändert weder CampaignState-Autorität noch permanente Fahrzeugmengen von Fortress oder Honaker und autorisiert keinen Merge.