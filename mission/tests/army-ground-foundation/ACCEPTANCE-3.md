---
document_id: OMW-TEST-ARMY-GROUND-ACCEPTANCE-3
status: PLANNED
document_class: ACCEPTANCE_TEST_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - planned scope and pass/fail criteria for the six-domain Kunar/Jalalabad ground integration test
  - concurrent BRIGADE/Warehouse/PLATOON lifecycle test for Fenty, Fortress, Joyce, Wright, Honaker-Miracle and Bostick
not_authoritative_for:
  - final production vehicle quantities for Fortress or Honaker-Miracle
  - final Mission Editor geometry
  - accepted runtime behavior before real DCS execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
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
OMW_GND_A3 START testId=ARMY-GROUND-ACCEPTANCE-3-1 sites=6
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
