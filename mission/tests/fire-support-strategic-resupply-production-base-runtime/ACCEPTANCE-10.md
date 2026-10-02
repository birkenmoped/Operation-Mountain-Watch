---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-10
status: DRAFT
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - ARTY selection-only DCS acceptance preflight
  - Functional ARTY ownership preservation gate
  - MOOSE recruitment representation blocker
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
superseded_by:
---

# Production Base Acceptance 10 – Functional ARTY Selection / Rearm

## 1. Zweck

A10 soll die neue FSSR-ARTY-Grenze gezielt in DCS pruefen, ohne den bereits akzeptierten Functional-ARTY-/M1083-Lifecycle neu zu implementieren.

Beabsichtigte Kette:

```text
qualified C2 ARTY demand
-> AUFTRAG:NewARTY as selection descriptor only
-> COMMANDER:CanMission
-> COMMANDER:RecruitAssetsForMission
-> MOOSE-selected provider/asset
-> identity-only handoff
-> existing long-lived Functional ARTY owner
-> AssignTargetCoord
-> OpenFire / CeaseFire
-> selection reservation release
-> accepted M1083 rearm service on the same ARTY owner
-> CampaignState consumption/completion
-> MOOSE ARTY support return
-> Warehouse return-to-stock
```

Der Selection-`AUFTRAG` darf nicht ueber `COMMANDER:AddMission` gequeued werden und darf keinen zweiten `FireAtPoint`-Owner erzeugen.

## 2. Lifecycle-Inheritance-Gate

| Feld | A10-Vertrag |
|---|---|
| inherited_contract | Functional ARTY + Fixed Fire Support Rearm Acceptance 2-11 |
| accepted_source_paths | `scripts/ground/OMW_FobAttackFunctionalArtyDispatchAdapter.lua`; `scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua`; `scripts/ground/OMW_FixedFireSupportAmmoSupport.lua`; `scripts/ground/OMW_GroundAmmoRearmAdapter.lua` |
| evidence | source/build `d52a47a418fe3a1a996a5b68198b8dc033ff86c4`; bundle `CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B`; mission `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620`; DCS `2.9.28.26385 MT`; pinned MOOSE |
| invariants | one long-lived Functional ARTY fire/rearm owner; no parallel AUFTRAG FireAtPoint owner; `startArty=false` for rearm after firing; CampaignState remains strategic resource authority; MOOSE ARTY owns physical M1083 rearm/return movement |
| reuse_mode | DIRECT_REUSE + MINIMAL_ADAPTER |
| harness_role | trigger demand/rearm stimulus, observe events/state, correlate IDs, assert; no fire/rearm state machine |
| changed_boundary | MOOSE COMMANDER/LEGION selection-only recruitment -> exact existing Functional ARTY identity |
| owner_approval | owner approved the selection -> existing Functional ARTY architecture on 22.09.2026; no further representation choice is inferred here |
| revalidation_scope | selection reservation, exact identity handoff, physical fire, reservation release, and unchanged accepted M1083 compatibility |
 
## 3. Testmission-Provenienz fuer den Preflight

Owner-provided artifact:

```text
OMW_Template_v25_GroundWorks_base(1).miz
SHA-256:
8C989DC531D1CCE30EF183F59874A6809B5C11D11932D893CD55ADAC3191D247
```

Embedded MOOSE:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Relevante vorhandene Mission-Editor-Gruppen:

```text
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2

TPL_BLUE_GND_SUP_M1083

WH_BLUE_GND_BOSTICK
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_HONAKER

ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY

BadGuys_A3_BOSTICK
BadGuys_A3_WRIGHT
BadGuys_A3_FORTRESS
BadGuys_A3_HONAKER
```

Diese Namen belegen vorhandene physische Fixtures in genau diesem Artefakt; sie begruenden noch keine neue Production-Konfiguration.

## 4. Gepinnter MOOSE-Source-Check

Fuer die neue Selection-Grenze sind source-verifiziert:

```text
AUFTRAG:NewARTY(...)
COMMANDER:CanMission(...)
COMMANDER:RecruitAssetsForMission(...)
LEGION.RecruitCohortAssets(...)
LEGION.UnRecruitAssets(...)
ARTY:AssignTargetCoord(...)
ARTY:RemoveTarget(...)
ARTY OnAfterOpenFire
ARTY OnAfterCeaseFire
ARTY OnAfterDead
```

Zusatzbefund des A10-Preflights:

```text
BRIGADE:AddPlatoon(...)
-> BRIGADE:AddAssetToPlatoon(...)
-> WAREHOUSE:AddAsset(...)

WAREHOUSE:onafterAddAsset:
"If the group is alive, it is destroyed."
```

Damit ist die bereits aktive Functional-ARTY-Batterie nicht ohne Lifecycle-Aenderung als neuer Warehouse-Stock fuer COMMANDER/LEGION-Recruitment registrierbar.

`COHORT:GetMissionRange(WeaponTypes)` addiert `engageRange` und registrierte WeaponRange-Daten. `COHORT:SetMissionRange(...)` ist ein Missionsradius, kein automatisch aus DCS ausgelesener Waffenreichweitenbeweis. A10 darf deshalb keine angeblichen L118-/2B11-Waffenreichweiten erfinden.

### 4.1 Source-Review 27.09.2026 – bereits aktive ME-Batterie als COMMANDER-Asset

Der gepinnte MOOSE-Source wurde nach der Wright-/Ground-Reconciliation erneut gezielt auf einen oeffentlichen Adopt-/Register-Pfad fuer bereits aktive Mission-Editor-Gruppen geprueft.

Befund:

```text
BRIGADE:AddPlatoon(...)
-> BRIGADE:AddAssetToPlatoon(...)
-> WAREHOUSE:AddAsset(...)
-> live group is removed/despawned

COHORT:AddAsset(Asset)
-> accepts an existing WAREHOUSE.Assetitem only
-> does not register an arbitrary live DCS/MOOSE GROUP
-> does not create the required ARMYGROUP lifecycle wrapper

LEGION:onafterAssetSpawned(...)
-> creates ARMYGROUP for a registered/spawned warehouse asset
-> is reached through the Warehouse/Legion spawn lifecycle

COHORT:RecruitAssets(...)
-> CAN recruit asset.spawned == true
-> but only if that asset already belongs to the cohort and has a live asset.flightgroup
```

`BRIGADE:LoadBackAssetInPosition(...)` ist **kein AdoptExistingGroup-Pfad**. Im gepinnten Source setzt die Methode ein bereits registriertes Asset auf `spawned=true`, erzeugt die physische Gruppe mit `SPAWN:NewWithAlias(...):SpawnFromCoordinate(...)` neu und ruft anschliessend `__AssetSpawned(...)` auf. Sie ist fuer das Wiederherstellen zuvor gefieldeter BRIGADE-Assets gedacht und wuerde die bestehende site-bound ME-Batterie nicht einfach uebernehmen.

Im geprueften oeffentlichen API-Scope wurde **keine** Methode gefunden, die eine bereits aktive beliebige ME-Gruppe ohne Despawn/Respawn als neues `WAREHOUSE.Assetitem` + `PLATOON`/`BRIGADE`-Asset adoptiert.

Damit gilt fuer A10 weiterhin:

```text
existing active ME battery
!= directly COMMANDER-recruitable asset
unless its physical lifecycle is changed to MOOSE materialization
or a separate selection representation is used
```

Dieser Befund ist `SOURCE_REVIEWED`, nicht DCS-validiert.

## 5. Preflight-Blocker

Die aktuelle Mission hat eine physische Fixed-Fire-Support-Ebene. Fuer den Selection-only-Vertrag fehlt dagegen eine owner-approved MOOSE-Recruitment-Repräsentation, die

```text
MOOSE can reserve/select
AND
maps one-to-one to the existing physical Functional ARTY battery
AND
does not destroy, respawn or duplicate that battery
AND
does not become a second strategic/physical resource owner
```

erfuellt.

Eine A10-Harness-Implementierung jetzt waere daher entweder ein Lifecycle-Verstoss oder wuerde eine neue Architekturentscheidung stillschweigend treffen.

## 6. Nicht zulaessige Abkuerzungen

```text
active battery -> BRIGADE:AddPlatoon -> WAREHOUSE:AddAsset
  # destroys the live group

destroy -> respawn same battery
  # observable physical lifecycle mutation

unrelated dummy group -> claim exact ARTY asset identity
  # false identity / shadow resource

custom nearest-battery selector
  # bypasses approved COMMANDER/LEGION selection without owner exception

OPSGROUP:SetRearmOnOutOfAmmo
  # different rearm lifecycle; accepted M1083/CampaignState evidence does not transfer
```

## 7. Owner-Entscheidung und implementierte Option A

Owner decision 25.09.2026: **A**.

```text
one fixed physical battery
<-> one unspawned MOOSE selection descriptor asset
<-> one descriptor PLATOON
<-> one exact Functional ARTY owner
```

Implemented production source:

```text
scripts/campaign/OMW_FireSupStratResupply_ArtySelectionDescriptorRegistry.lua
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-DESCRIPTOR-REGISTRY-1
```

The registry uses the existing external-support COMMANDER as the MOOSE selection authority. It never queues the descriptor AUFTRAG and rejects any descriptor that is already physically spawned.

Der bereits implementierte Option-A-Descriptor bleibt technisch ein moeglicher Weg, weil er die MOOSE-Selektion von der unveraenderten physischen ME-Batterie trennt. Nach der erneuten Owner-Rueckfrage vom 27.09.2026 wird jedoch **keine Mission-Editor-Descriptor-Fixture angelegt**, bis diese Repräsentationsentscheidung erneut bestaetigt oder durch eine andere owner-approved Lifecycle-Entscheidung ersetzt wurde.

Aktueller Entscheidungsraum:

```text
A) keep active site-bound ME batteries unchanged
   + separate one-to-one MOOSE selection descriptor

B) change physical initial lifecycle
   -> battery becomes a MOOSE-registered asset and is materialized by MOOSE
   -> requires explicit owner approval + scoped DCS revalidation

C) custom provider selector over existing Functional ARTY instances
   -> bypasses COMMANDER/LEGION asset selection
   -> non-MOOSE/parallel selection exception; requires explicit owner approval
```

Es wurde kein vierter oeffentlicher MOOSE-Pfad nachgewiesen, der eine bereits aktive ME-Batterie direkt in `COMMANDER/LEGION` adoptiert.

The exact ARTY min/max selection ranges are also still configuration data and must be explicitly established; no L118/2B11 range is guessed by the Base.

## 8. Geplanter PASS nach Aufloesung des Blockers

PASS darf erst nach realer DCS-Evidenz fuer mindestens folgende Punkte entstehen:

```text
1. multiple eligible ARTY provider representations exist
2. MOOSE performs the operational selection/reservation
3. selected identity maps unambiguously to one existing Functional ARTY owner
4. no COMMANDER:AddMission / AUFTRAG FireAtPoint owner exists for that battery
5. Functional ARTY OpenFire occurs
6. real ammunition decreases
7. Functional ARTY CeaseFire occurs
8. selection reservation is released exactly at the terminal fire-selection state
9. accepted M1083 rearm is requested on the same ARTY instance
10. CampaignState GROUND_AMMO_PACKAGE consumption is committed exactly once
11. ARTY OnAfterRearmed completes the transaction
12. physical M1083 returns under the accepted MOOSE ARTY lifecycle
13. support is returned to Warehouse stock
14. restored artillery ammunition is observed
15. harness only triggers/observes/asserts
```

## 9. Status

```text
Production Base 27 local build: VERIFIED_LOCAL_BUILD
source commit: ee431db16c2fb3f3bf4fa2c33a0da4ff0363ded6
production builder SHA-256: 8CA05C37D9D51B5AF44A052B91B620D91CB77B997632E0073FC140052BF462A3
production bundle SHA-256: 5FEDBA2486CC048D2805615945D0A016EA7939B4920796BCEAF870DAC7FBE4F4
independent direct Get-FileHash readback: MATCH for builder and bundle
ARTY selection-only source: SOURCE_IMPLEMENTED
ARTY Option-A descriptor source: SUPERSEDED_BEFORE_DCS
unit/CI: PASS at ee431db16c2fb3f3bf4fa2c33a0da4ff0363ded6
A10 mission preflight: COMPLETE
A10 RealAssetRegistry source: SOURCE_IMPLEMENTED / DCS_PENDING
A10 runtime harness: NOT RELEASED until ME late-activation fixture + real DCS bootstrap observation are ready
A10 DCS status: BLOCKED_ON_ME_FIXTURE_AND_DCS_BOOTSTRAP
Strategic Resupply: NOT STARTED; waits for ARTY closure
```

## 10. Owner-local Build-/Hash-Verifikation 26.09.2026

Der Projektinhaber hat den Branch lokal auf den exakten Source-Stand aktualisiert und den Production-Builder ausgefuehrt.

```text
branch:
agent/fire-support-strategic-resupply-base-gate0

git HEAD:
ee431db16c2fb3f3bf4fa2c33a0da4ff0363ded6

BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-27

RuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-10

ArtySelectionRuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-RUNTIME-1

ArtySelectionDescriptorRegistrySchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-DESCRIPTOR-REGISTRY-1

MOOSE release:
2.9.18

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

MizMutation:
false
```

Builder-reported hashes:

```text
BuilderSHA256:
8CA05C37D9D51B5AF44A052B91B620D91CB77B997632E0073FC140052BF462A3

BundleSHA256:
5FEDBA2486CC048D2805615945D0A016EA7939B4920796BCEAF870DAC7FBE4F4
```

Separate direkte Owner-Readbacks mit `Get-FileHash -Algorithm SHA256` ergaben exakt dieselben Werte:

```text
tools/build-fire-support-strategic-resupply-production-base.ps1
8CA05C37D9D51B5AF44A052B91B620D91CB77B997632E0073FC140052BF462A3

mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
5FEDBA2486CC048D2805615945D0A016EA7939B4920796BCEAF870DAC7FBE4F4
```

Damit ist die Production-Base-27-Provenienz fuer diesen Source-Stand als `VERIFIED_LOCAL_BUILD` geschlossen.

Dies ist **keine DCS-Acceptance**. A10 bleibt bis zur erneuten Schliessung der Selection-Repräsentationsentscheidung und der expliziten ARTY-Range-Konfiguration `DCS_PENDING`.

## 9.1 Owner-Entscheidung 01.10.2026 – reale ARTY/Mortar-Assets duerfen durch MOOSE materialisiert werden

Der Projektinhaber hat die bisherige Randbedingung aufgehoben, dass die vier site-bound Fire-Support-Gruppen bereits aktiv im Mission Editor stehen muessen. Zulaessig ist nun:

```text
same existing ME groups/templates
-> Late Activation / not physically active at mission start
-> PLATOON + BRIGADE registration
-> real WAREHOUSE.Assetitem
-> MOOSE materialization
-> asset.spawned=true
-> real ARMYGROUP
-> COMMANDER/LEGION recruitment of the real asset
```

Unveraendert bindend:

```text
- exact current emplacement must be preserved
- exact relative gun/mortar formation must be preserved
- no post-spawn relocation of the fixed battery
- no RTZ/RELOCATE/PATROL/ONGUARD movement contract for these batteries
- selection-only AUFTRAG is never queued through COMMANDER:AddMission
- existing Functional ARTY instance remains sole fire-control owner
- accepted M1083/CampaignState rearm lifecycle remains authoritative
```

### Exact-position MOOSE source path

Im gepinnten `Moose.lua` nutzt `WAREHOUSE:_SpawnAssetGroundNaval(...)` die konfigurierte Warehouse-Spawnzone und verschiebt jede Unit relativ zum ersten Template-Wegpunkt:

```text
TX = spawnX + (unitTemplateX - originalRoutePointX)
TY = spawnY + (unitTemplateY - originalRoutePointY)
```

Liegt der Spawnpunkt exakt auf dem urspruenglichen ersten Template-Wegpunkt, bleiben daher alle Unit-X/Y-Positionen exakt auf der heutigen ME-Geometrie.

`ZONE_RADIUS:GetRandomVec2(...)` liefert bei `Radius=0` den Zonenmittelpunkt, weil inner=0 und outer=0 verwendet werden. Damit ist source-seitig ein exakter, nicht zufaelliger Spawnpunkt darstellbar. Dieser konkrete Radius-0-Einsatz ist `SOURCE_REVIEWED`, aber noch `DCS_PENDING`.

Der bevorzugte Lifecycle fuer A10 ist deshalb der regulaere Warehouse-/Legion-Pfad:

```text
register one real PLATOON asset from the existing late-activation group
-> temporarily bind the site BRIGADE spawn zone to a zero-radius runtime ZONE_RADIUS
   centered on the original template route point
-> self-request exactly that registered Assetitem
-> WAREHOUSE _SpawnAssetGroundNaval
-> LEGION AssetSpawned
-> ARMYGROUP wrapper
-> restore the site's normal BRIGADE spawn zone
```

`BRIGADE:LoadBackAssetInPosition(...)` bleibt als source-verifizierter exakter Spawnmechanismus bekannt, wird fuer den regulaeren OMW-Initialstart aber nicht bevorzugt, weil die Methode dokumentiert fuer das Wiederherstellen zuvor gefieldeter/persistierter BRIGADE-Assets vorgesehen ist.

### Range-Blocker geschlossen durch gepinnte MOOSE-ARTY-Datenbank

Der erneute Review des exakt verwendeten `Moose.lua` hat fuer die beiden aktuellen DCS-Typen bereits MOOSE-eigene Range-Daten gefunden:

```text
ARTY.db["L118_Unit"]
  minrange = 500 m
  maxrange = 17500 m

ARTY.db["2B11 mortar"]
  minrange = 500 m
  maxrange = 7000 m
```

Diese Werte stammen aus der gepinnten MOOSE-Quelle und werden daher fuer die MOOSE-Selection-Range verwendet; es werden keine externen Realweltwerte erfunden. Fuer `COHORT:AddWeaponRange(...)` sind die Werte ueber `UTILS.MetersToNM(...)` umzusetzen.

Die A10-Blocker reduzieren sich damit auf:

```text
1. source implementation of real-asset bootstrap/materialization
2. ME change of the four existing site-bound groups to Late Activation without moving/renaming them
3. DCS proof of exact spawn positions/formation
4. DCS proof that COMMANDER selects the real spawned asset and Functional ARTY fires without movement
5. rearm/regression proof against accepted M1083 lifecycle
```

## 9.2 Source implementation 02.10.2026 – RealAssetRegistry

Implementiert: `scripts/campaign/OMW_FireSupStratResupply_ArtyRealAssetRegistry.lua` (`OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-REAL-ASSET-REGISTRY-1`).

Der Registry registriert die späteren site-bound Fire-Support-Fixtures als jeweils genau ein reales PLATOON-/WAREHOUSE-Asset. Nach dem MOOSE-`NewAsset`-Lifecycle wird `BRIGADE:LoadBackAssetInPosition(asset.spawngroupname, originalTemplateRoutePoint)` verwendet. Dieser Pfad vermeidet ein temporäres globales Umschalten der Site-BRIGADE-Spawnzone, die gleichzeitig vom QRF-Vertrag als ACCESS-Spawnzone verwendet wird.

Der Registry akzeptiert den MOOSE-generierten Runtime-Namen `<platoon>_AID-<uid>` und bindet bei späterer COMMANDER-Selektion den exakten `asset.flightgroup:GetGroup()` an den bestehenden Functional-ARTY-Owner.

Noch DCS-offen:

```text
- four existing ME groups -> Late Activation without changing positions/headings
- exact materialization position/formation
- real COMMANDER recruitment across multiple fixed batteries
- no battery movement before/during/after fire
- same Functional ARTY owner and accepted M1083 rearm lifecycle
```

## 9.3 Local build evidence 02.10.2026 – Production Base 28

Vom Projektinhaber lokal auf dem Branch `agent/fire-support-strategic-resupply-base-gate0` ausgeführt:

```text
GitCommit:
4acd25cfacc10c530e50b336cbb2472f5eb8c360

BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-28

ArtyRealAssetRegistrySchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-REAL-ASSET-REGISTRY-1

MOOSERelease:
2.9.18

MOOSECommit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

MooseLuaSHA256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

MizMutation:
false

BuilderSHA256:
E6934463EFE4751EE6AC276D9C247187B39DE79305FB82986C7D44CC79EB04A2

BundleSHA256:
0525D0CA70BA356B3A27FFBCB222EC21346891D5B71252F57551E89FC0612A47
```

`Get-FileHash` wurde fuer Builder und Bundle separat ausgefuehrt; beide Hashes stimmen mit der Builder-Ausgabe ueberein.

Lokaler `git status --short` zeigte ausschliesslich die bereits vorhandenen untracked Build-/`dist`-Verzeichnisse; keine getrackten lokalen Aenderungen.

Remote CI fuer denselben Source-Commit:

```text
Documentation validation #2321 = PASS
MissionDemand validation #1092 = PASS
```

Bewertung:

```text
source/build provenance = VERIFIED
unit/contract tests = PASS
documentation validation = PASS
DCS real-asset materialization = NOT YET TESTED
exact emplacement preservation = NOT YET TESTED IN DCS
COMMANDER real-asset recruitment = NOT YET TESTED IN DCS
Functional ARTY + M1083 regression = NOT YET TESTED IN DCS
```
