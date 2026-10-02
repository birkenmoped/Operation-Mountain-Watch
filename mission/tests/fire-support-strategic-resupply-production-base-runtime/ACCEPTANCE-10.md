---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-10
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - accepted real-asset ARTY/Mortar materialization and MOOSE selection boundary
  - Functional ARTY ownership preservation and selection-reservation release
  - accepted M1083/CampaignState rearm regression evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: 4c8793a9b155f85e7a229117725fca55f58987c3
acceptance_mission: OMW_Template_v25_GroundWorks_base.miz
acceptance_mission_sha256: 95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232
acceptance_bundle_sha256: FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9
dcs_version: 2.9.30.28536 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
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

## 9. Historischer Status vor A10-Schliessung

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

## 9.4 A10 Mission-Editor fixture prepared 02.10.2026

Aus dem owner-provided Preflight-Artefakt

```text
OMW_Template_v25_GroundWorks_base(1).miz
SHA-256 8C989DC531D1CCE30EF183F59874A6809B5C11D11932D893CD55ADAC3191D247
```

wurde eine A10-Geometrie-Fixture erzeugt:

```text
OMW_Template_v25_GroundWorks_base_A10_ARTY_LateActivation.miz
SHA-256 5C94578EE282E4DB740299D7A2EDCACD1B388090FDBB3BBBC9D7DB184DDAAFCB
```

Die Mission-Datei wurde byte-seitig nur im entpackten `mission`-Inhalt geändert. Der vollständige Text-Diff enthält genau vier Ergänzungen:

```text
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2        -> ["lateActivation"] = true
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2         -> ["lateActivation"] = true
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1       -> ["lateActivation"] = true
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2      -> ["lateActivation"] = true
```

Keine Koordinate, Unit-Position, Unit-Anzahl, Unit-Type, Heading, Route oder sonstige Mission-Editor-Eigenschaft dieser Gruppen wurde geändert.

Diese Datei ist **noch keine ausführbare A10-Acceptance-Mission**. Sie enthält weiterhin die bisherige eingebettete `OMW_FireSupStratResupply_Production_Base_Acceptance_9.lua`-Ressource und dient zunächst nur als reproduzierbare ME-Fixture für den neuen RealAssetRegistry-Lifecycle. Der A10-Harness-/Bundle-Handoff muss vor dem realen DCS-Lauf separat geschlossen werden.

Status:

```text
A10 ME late-activation fixture = PREPARED
exact source->fixture mutation = VERIFIED_OFFLINE
A10 runtime bundle embedded = NO
DCS runtime validation = PENDING
```

## 9.5 A10 Harness 02.10.2026 – real asset selection + accepted rearm reuse

Der A10-Harness ist nun als observer-/stimulus-only Integrationsharness implementiert:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/10-production-real-arty-selection-rearm-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-10.ps1
```

Komposition:

```text
4 site BRIGADEs
-> RealAssetRegistry materializes Bostick/Wright/Fortress/Honaker at exact template route point
-> all 4 real spawned Assetitems registered with one COMMANDER
-> runtime target = midpoint between Wright and Honaker original template positions
-> both Wright L118 and Honaker 2B11 must be within their pinned MOOSE range
-> both cohorts use equal performance=50
-> ArtySelectionRuntime lets MOOSE COMMANDER select/reserve exactly one real spawned asset
-> selected asset.flightgroup:GetGroup() becomes the physical group for the Functional ARTY owner
-> no COMMANDER:AddMission(selection mission)
-> Functional ARTY fires
-> ArtySelectionRuntime releases reservation after CeaseFire
-> harness then triggers the accepted FixedFireSupportAmmoRearmService with startArty=false
-> M1083/CampaignState/ARTY rearm/return-to-stock remains the accepted production lifecycle
```

Der M1083-Pfad verwendet bewusst weiterhin eine **eigene support-only BRIGADE-Instanz** am selben physischen Warehouse-Anker. Das ist keine zweite Eigentümerschaft desselben Assets: Die Site-BRIGADE besitzt ausschließlich die realen Fixed-ARTY/Mortar-Assets; die Support-BRIGADE besitzt ausschließlich ihr M1083-Support-Asset. `CampaignState` bleibt alleinige strategische Autorität für `GROUND_AMMO_PACKAGE`.

Warum nicht dieselbe BRIGADE für beides: `WAREHOUSE:SetSpawnZone(...)` ist im gepinnten MOOSE eine Eigenschaft des gesamten Warehouse/BRIGADE-Objekts. QRF nutzt die Site-BRIGADE-Spawnzone als ACCESS-Materialisierung, während der akzeptierte M1083-Pfad die RESUPPLY-Zone benötigt. Eine gemeinsame Instanz würde diese Spawnzonen gegeneinander überschreiben und damit zwei bereits getrennte physische Lifecycles koppeln.

Der Harness prüft zusätzlich:

```text
- alle vier realen Batterien: Unit-Zahl und jede Unit-Position <= 1.0 m zur ursprünglichen Asset-Template-Position
- selected provider must be WRIGHT or HONAKER for the overlap target
- ammo decreases after Functional ARTY fire
- if HONAKER is selected: observed ammo must reach 0 before rearm
- selected fixed battery stays <= 1.0 m from materialization position after fire
- same check after rearm/support return
- selection Assetitem is released
- CampaignState GROUND_AMMO_PACKAGE available decreases exactly by 1
- final artillery ammo is restored to at least initial ammo
- M1083 returns to its accepted Warehouse stock lifecycle
```

Status: `SOURCE_IMPLEMENTED / CI_PENDING / LOCAL_BUILD_PENDING / DCS_PENDING`.

## 9.6 Owner-local A10 build evidence 02.10.2026

Der Projektinhaber hat den A10-Builder lokal auf dem exakten Branch-Stand ausgeführt und die erzeugten Hashes unabhängig mit `Get-FileHash -Algorithm SHA256` bestätigt.

```text
GitCommit:
4c8793a9b155f85e7a229117725fca55f58987c3

Production BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-28

ProductionBuilderSHA256:
E6934463EFE4751EE6AC276D9C247187B39DE79305FB82986C7D44CC79EB04A2

ProductionBundleSHA256:
B3ACED1E5F39B67AF6E89D9F4914B4D59585B0802AC9FE357F6DECFEAB96AE5F

RealAssetRegistrySourceSHA256:
9BCA9741C447FE43D6B8E14977A9F21396913435CDFFFB6D80D27B32783FA615

ArtySelectionRuntimeSourceSHA256:
EE3DC1A5EE799D9608E9779018399A4D6FFC06087B0C3EA1954F1013B80DB86E

FixedFireSupportAmmoRearmServiceSHA256:
2829BDD72840FEB14D744072AD7BAD2B81901E43807D5E75BB1DB654AEFFE067

Acceptance BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-10-1

AcceptanceSourceSHA256:
BEB2995336FEE020752F8F61BBD681A4A2EA6A0227130B7F48D56501557F150E

AcceptanceBuilderSHA256:
B2458817B6522CD93CCE8917DCB5E470AC850F7464294BEA4775E457426EC443

AcceptanceBundleSHA256:
FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9

MizMutation:
false
```

Die separaten Owner-`Get-FileHash`-Readbacks für Acceptance-Builder und Acceptance-Bundle stimmen exakt mit der Builder-Ausgabe überein.

Lokaler `git status --short` zeigte ausschließlich die bekannten untracked Build-/dist-Verzeichnisse und keine getrackten lokalen Änderungen.

Damit gilt:

```text
A10 source/build/hash provenance = VERIFIED_LOCAL_BUILD
A10 Lua bundle = READY_FOR_OWNER_ME_INSERTION
MIZ modification = OWNER-MANUAL
DCS acceptance = PENDING
```

Workflow-Grenze: ChatGPT liefert ausschließlich den reproduzierbaren LUA-Build und die zugehörige Provenienz. Der Projektinhaber bringt das erzeugte A10-LUA selbst in die gewünschte MIZ ein; ChatGPT mutiert die MIZ in diesem Workflow nicht.

## 9.7 DCS runtime acceptance 02.10.2026 – PASS

Realer DCS-Lauf:

```text
DCS:
2.9.30.28536 MT

Mission:
OMW_Template_v25_GroundWorks_base.miz
tested mission artifact SHA-256:
95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232

Acceptance bundle:
OMW_FireSupStratResupply_Production_Base_Acceptance_10.lua
SHA-256:
FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9

Source commit:
4c8793a9b155f85e7a229117725fca55f58987c3

MOOSE:
2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der hochgeladene `dcs.log` enthält zwei aufeinanderfolgende Versuche. Der erste Versuch scheiterte um 19:10:01 mit:

```text
[PRODUCTION BASE A10][FAIL] ARTY_TEMPLATE_MUST_BE_LATE_ACTIVATION site=FORTRESS
```

DCS wurde anschließend beendet und die Mission erneut gestartet. Der zweite Lauf ist der maßgebliche Acceptance-Lauf und endete mit PASS.

### Zweiter Lauf – beobachtete Evidenz

Alle vier realen Fixed-Fire-Support-Assets wurden durch MOOSE materialisiert:

```text
FORTRESS -> FortressArtillery_AID-219#001
BOSTICK  -> BostickArtillery_AID-220#001
WRIGHT   -> WrightArtillery_AID-221#001
HONAKER  -> HonakerMortar_AID-222#001
```

Die Positionsprüfung bestand für alle sieben physischen Geschütze/Mörser. Beobachtete maximale Abweichung zur ursprünglichen Asset-Template-Position:

```text
0.014 m
```

Damit ist die Exact-Position-Anforderung innerhalb der A10-Toleranz von 1.0 m erfüllt.

Der geometrisch abgeleitete Zielpunkt war gleichzeitig für Wright und Honaker reichweitenfähig:

```text
WRIGHT distance 4610.4 m / max 17500.0 m
HONAKER distance 4737.7 m / max 7000.0 m
```

MOOSE/COMMANDER wählte anschließend das reale Wright-Asset:

```text
provider=BDE_FSSR_A10_WRIGHT
asset=WrightArtillery_AID-221#001
initialAmmo=300
```

Functional ARTY startete das Feuer. Nach CeaseFire wurde die MOOSE-Selection-Reservation freigegeben; der Ammo-Stand betrug danach 296. Die Batterie blieb nach dem Feuer auf ihrer materialisierten Position.

Der akzeptierte M1083-Rearm-Pfad wurde anschließend auf derselben Wright-Batterie ausgeführt:

```text
transactionId=FSSR-A10-REARM-WRIGHT
resourceBefore=30
status=WAITING_FOR_SUPPORT
consumption committed
rearm completed
finalAmmo=301
M1083 returned to Warehouse stock
```

Nach dem Rearm bestand die No-Movement-Prüfung erneut.

Terminale A10-Meldung:

```text
[PRODUCTION BASE A10][PASS]
real MOOSE ARTY assets materialized at exact ME positions;
Wright and Honaker were both eligible;
COMMANDER selected the real spawned asset;
Functional ARTY fired without battery movement;
selection reservation released;
accepted M1083/CampaignState rearm completed and returned to stock.
```

Bewertung:

```text
real MOOSE fixed-ARTY/Mortar materialization = PASS
exact emplacement preservation             = PASS
multiple eligible provider setup           = PASS
COMMANDER real-asset selection              = PASS
Functional ARTY single-owner fire path      = PASS
selection reservation release               = PASS
fixed-battery no-movement invariant         = PASS
accepted M1083/CampaignState rearm reuse     = PASS
M1083 return-to-stock                        = PASS
A10 overall                                 = PASS
```

Der nach Missionsende geloggte `bhHook.lua`-Fehler (`tcp` nil) liegt außerhalb des A10-Lifecycles und trat erst nach `Dispatcher Stop` auf; er beeinflusst den dokumentierten A10-PASS nicht.

Status: `DCS_PASS / ACCEPTED_TECHNICAL_BASELINE candidate on this exact provenance`.

## 9.8 Lessons learned / current boundary after A10

A10 schliesst die fruehere ARTY-Repräsentationsfrage fuer den getesteten Stand. Die wesentlichen Erfahrungen sind:

~~~text
1. already-active ME battery -> BRIGADE:AddPlatoon
   is not a safe adoption path because WAREHOUSE registration owns materialization/despawn semantics.

2. separate selection-descriptor assets
   were technically possible as a reservation representation
   but became unnecessary once the owner allowed MOOSE to materialize the real batteries.

3. late-activation real battery template
   -> PLATOON/BRIGADE/Warehouse asset
   -> LoadBackAssetInPosition(original emplacement)
   works in DCS for this fixed-fire-support bootstrap.

4. the MOOSE runtime group name changes to <platoon>_AID-<uid>#001.
   Strategic/project identity must therefore remain independent of DCS runtime group names.

5. COMMANDER/LEGION can choose a real spawned fixed-fire-support asset from more than one eligible provider
   without an OMW-side provider selector.
   A10 proved Wright and Honaker simultaneously eligible and MOOSE selected Wright.

6. selection-only AUFTRAG + CanMission/RecruitAssetsForMission
   must remain separate from fire execution.
   Functional ARTY remains the single fire/rearm FSM owner.

7. the fixed battery must never be moved to satisfy range.
   Range/capability are selection constraints; absence of an eligible provider is a valid no-support outcome.

8. the accepted M1083 lifecycle can remain a separate support-only BRIGADE on the same physical Warehouse anchor,
   because it owns a different physical asset set and CampaignState remains the sole strategic resource authority.

9. Acceptance harnesses must observe production lifecycles.
   They must not select providers, route CAS, own ARTY fire control, own M1083 return or create a second resupply ledger.
~~~

A10 does not prove:

~~~text
- concurrent handling of multiple external-support demands
- actual 2B11 mortar fire in the selected-provider path
- simultaneous ARTY + mortar + CAS demands
- autonomous queueing/contention across multiple busy providers
- physical Strategic Resupply via OPSTRANSPORT/STORAGE
- combined multi-FOB/COP full-response behavior
- fixed-wing CAS or additional unvalidated CAS owner profiles
~~~

These are the next Base/generalization boundaries and are deliberately moved to Acceptance 11 rather than being inferred from A10.
