---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-9
status: VALIDATED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - observer-only validation of shared production CAS lifecycle
  - lifecycle-inheritance gate for FSSR Base CAS
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: true
supersedes:
  - OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-8
superseded_by:
---

# Production Base Acceptance 9 – shared production CAS lifecycle

## 1. Lifecycle-Inheritance-Gate

| Feld | A9-Vertrag |
|---|---|
| inherited_contract | Stage-2B accepted OMW_FlightPath outbound/reverse lifecycle + binding Stage-3 CAS detection/release/recovery law |
| accepted_source_paths | `scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua`; `scripts/air-operations/OMW_HelicopterCasTacticalCorridor.lua`; MOOSE AUFTRAG/FLIGHTGROUP/LEGION lifecycle |
| evidence | Stage-2B RESULT-2: commit `7c40e43395788b1a7dd5e0c179264abb34834ec4`, bundle `AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B`, DCS `2.9.29.27278`, pinned MOOSE `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`; A7 adds real evidence that the newer owner-route chain reaches Joyce correctly but not that release/recovery is valid |
| invariants | owner-authored route; MOOSE provider/asset selection; own FLIGHTGROUP detection; supported-element + stable no-contact release; FuelLow is not normal completion; reverse route; physical home landing; exact Legion asset return |
| reuse_mode | `SHARED_EXTRACTION` + direct reuse of corridor modules |
| harness_role | activate Joyce RED fixture; request CAS support; observe production evidence; assert PASS/FAIL |
| changed_boundary | release/recovery state formerly embedded in specialized Stage-3/A7 harness is moved into shared production `CasLifecycleRuntime` |
| owner_approval | no accepted invariant is intentionally changed |
| revalidation_scope | new shared production composition from MOOSE selection through release and physical recovery |

Diese Tabelle erfuellt `ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`. A9 darf keinen zweiten CAS-Lifecycle besitzen.

## 2. Produktionskomponente

Neu gemeinsam produktiv:

```text
scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua
schema OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1
```

Die Komponente wird von `OMW_FireSupStratResupply_ExternalSupportRuntime.lua` hinter dem generischen COMMANDER-Bridge-CAS-Adapter eingebunden.

Sie uebernimmt ausschliesslich den bereits festgelegten CAS-Ausfuehrungslifecycle:

```text
MOOSE COMMANDER/LEGION selects provider + asset
-> selected provider owner profile
-> owner route and tactical ingress/egress
-> FLIGHTGROUP bound
-> AUFTRAG executing
-> own FLIGHTGROUP detection
-> supported element clear
-> configured release policy
-> controlled Cancel via shared CasPatrolClosure / existing CommanderBridge handle
-> reverse owner route
-> physical home landing
-> exact LegionAssetReturned
-> lifecycle complete
```

Sie waehlt weder AIRWING noch SQUADRON noch konkretes Asset. ADR 0008 bleibt unveraendert.

## 3. Wiederverwendete akzeptierte Route

Die Produktionskomponente verwendet direkt:

```text
OMW_FlightPathNameContract
OMW_HelicopterFlightPathCorridor
OMW_HelicopterCasTacticalCorridor
```

Der Stage-2B-Nachweis fuer `OMW_FlightPath` Hin-/Rueckroute, RTB, Landed und Arrived bleibt nur fuer seine exakte Provenienz akzeptiert. A9 revalidiert die neue gemeinsame Base-Komposition; es behauptet keine automatische Uebertragung der alten Acceptance auf neuen Source.

## 4. Release

Release-Autoritaet:

```text
AUFTRAG:IsExecuting()
AND
source installation incident coordinator has zero living RED participants
AND
FLIGHTGROUP:GetDetectedGroups() returns a valid set
AND
zero engagement-eligible RED Ground Units in CAS zone / engage range
AND
A9 release profile `SUPPORTED_ELEMENT_STABLE_NO_CONTACT` is satisfied
-> production lifecycle calls shared CasPatrolClosure request
-> existing CommanderBridge handle Cancel()
```

`nil` Detection ist nicht `no contact`.

### A9-spezifische Release-Policy

Die 30-Sekunden-Regel ist **keine allgemeine Base-Regel**. `STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md` §20 legt fest, dass die konkrete Freigabebedingung profilabhaengig bleibt. A9 injiziert fuer diesen Joyce-Test explizit:

```text
mode = SUPPORTED_ELEMENT_STABLE_NO_CONTACT
stableNoContactSec = 30
```

Die Qualifikation wird vom produktiven `OMW_FireSupStratResupply_CasReleasePolicy.lua` ausgefuehrt. Der Acceptance-Harness fuehrt keinen eigenen No-Contact-Timer.

## 5. Recovery

Der Lifecycle beobachtet:

```text
OnAfterFuelLow
OnAfterLanded
LegionAssetReturned
```

`FuelLow` wird nicht blockiert. Es bleibt MOOSE-Sicherheitsverhalten, ist aber kein regulaerer Missionsabschluss. Ein PASS verlangt kontrollierten Release vor vollstaendiger Recovery sowie physische Heimatlandung und exact asset return.

## 6. Acceptance-Harness-Grenze

`09-production-cas-lifecycle-acceptance.lua` darf nicht enthalten:

```text
GetDetectedGroups()
corridor Bind/Resolve
FuelLow callback ownership
Landed callback ownership
LegionAssetReturned callback ownership
mission Cancel
UpdateRoute/AddWaypoint
eigene CAS no-contact state machine
```

Der Builder bricht bei diesen Markern ab.

Die Acceptance darf nur:

```text
fixture activation
Base CAS demand
production onEvidence observation
production lifecycle GetState observation
PASS/FAIL assertions
diagnostic watchdog WARN
```

## 7. Acceptance-Szenario

```text
FOB Joyce RED attack
-> production perimeter / installation incident
-> production QRF direct target engagement
-> Base CAS demand
-> MOOSE COMMANDER/LEGION selection
-> shared production CasLifecycleRuntime
-> route / execution / release / recovery
-> PASS only after lifecycle complete
```

ARTY, rearm und strategic resupply sind nicht Bestandteil dieses Laufs.

## 8. Route-Profil-Konfiguration

Die Acceptance injiziert nur Konfigurationsdaten fuer das aktuell bekannte Jalalabad-Rotary-Profil. Das ist keine Asset-Selektion. Waehlt MOOSE einen anderen Provider ohne registriertes Owner-Profil, lehnt die Produktionskomponente dessen MissionAssign fail-closed ab.

`_DATABASE.PATHLINES` wird in A9 nur als Acceptance-Kompositionsquelle fuer `FlightPathNameContract.SelectFromRegistry()` injiziert. Die produktive Lifecycle-Komponente greift nicht selbst global auf `_DATABASE` zu. Eine spaetere produktive Missionseinbindung muss den PATHLINE-Registry-/Konfigurationsvertrag am Composition Root bereitstellen.

## 9. PASS

PASS erfordert mindestens:

```text
QRF_DIRECT_TARGET_ENGAGE
CAS_PROVIDER_PROFILE_BOUND
CAS_MISSION_ASSIGNED
CAS_OWNER_CORRIDOR_INSTALLED
CAS_EXECUTING
CAS_NO_CONTACT_REPORTED
CAS_SUPPORTED_ELEMENT_CLEAR
CAS_CONTROLLED_RELEASE
CAS_HOME_LANDED
CAS_LEGION_ASSET_RETURNED
CAS_LIFECYCLE_COMPLETE
```

Kein `OpsOnMission`- oder Watchdog-Ereignis kann PASS erzeugen.

## 10. Artefakte

```text
scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua
scripts/campaign/OMW_FireSupStratResupply_CasReleasePolicy.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/09-production-cas-lifecycle-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-9.ps1
```

Status vor realem DCS-Lauf: `SOURCE_REVIEWED / CI_GATED / DCS_PENDING`.

Shared closure request is reused from `scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua` schema `OMW-FOB-ATTACK-CAS-PATROL-CLOSURE-3`; the Base lifecycle does not reimplement mission-cancel semantics.

## 11. Vier-Gates-Abschluss

### Gate 1 – Lifecycle inheritance

`PASS`. Die Lifecycle-Inheritance-Tabelle in Abschnitt 1 bindet die akzeptierte Stage-2B-Route und die verbindlichen CAS-Release-/Recovery-Invarianten. Keine alte Acceptance-Evidenz wird auf neu geschriebenen Source hochgestuft.

### Gate 2 – produktive Extraktion

`PASS / DCS_PENDING`. Routing, eigene Detection, profilierte Release-Qualifikation, Closure und Recovery liegen nicht mehr im Acceptance-Harness, sondern in gemeinsamem Production-Code:

```text
OMW_FireSupStratResupply_CasLifecycleRuntime.lua
OMW_FireSupStratResupply_CasReleasePolicy.lua
OMW_FobAttackCasPatrolClosure.lua
OMW_HelicopterFlightPathCorridor.lua
OMW_HelicopterCasTacticalCorridor.lua
```

ADR 0008 bleibt unveraendert: COMMANDER/LEGION waehlt Provider und Asset.

### Gate 3 – statische Regression-Gates

`PASS`. Der MissionDemand-Testlauf enthaelt eigene Contract-Tests fuer Release-Policy, Production-Lifecycle und die observer-only Harness-Grenze. Der A9-Builder bricht bei Detection-, Route-, Cancel-, FuelLow-, Landing-, Legion-return- oder eigener No-Contact-State-Machine im Harness ab.

### Gate 4 – CI und Source Review

`PASS` fuer den Source-Stand vor diesem reinen Dokumentationsabschluss. MissionDemand validation Run 1032 und Documentation validation Run 2260 waren erfolgreich. Im MissionDemand-Log sind insbesondere belegt:

```text
PASS fire support CAS release policy
PASS fire support CAS lifecycle runtime
PASS fire support CAS harness boundary
PASS test_fire_support_strategic_resupply_external_support_runtime
PASS mission-demand test suite
```

Der gepinnte `Moose.lua`-Source wurde fuer `AUFTRAG:IsExecuting`, `COMMANDER:onafterMissionAssign`, `OPSGROUP:GetDetectedGroups`, `FLIGHTGROUP:onafterFuelLow`, `FLIGHTGROUP:onafterLanded` und `LEGION:onafterLegionAssetReturned` erneut direkt geprueft.

Die vier Gates erlauben den lokalen A9-Build. Sie sind **keine DCS-Acceptance**; der neue gemeinsame Production-CAS-Lifecycle bleibt bis zum realen Lauf `DCS_PENDING`.

## 12. Owner-local Buildversuch auf `c9636462`

Der erste owner-lokale Buildversuch auf

```text
c963646219a3092a746ca1a7b398260a37ba5c27
```

ist **vor der Bundle-Erzeugung abgebrochen**:

```text
Source lacks SchemaVersion: scripts\air-operations\OMW_HelicopterCasTacticalCorridor.lua
```

Ursache war ein zu enger Production-Builder-Preflight: `OMW_HelicopterCasTacticalCorridor.lua` verwendet seinen bestehenden Vertrag

```lua
local Adapter = {
  Schema = "OMW-HELICOPTER-CAS-TACTICAL-CORRIDOR-1",
}
```

und nicht `SchemaVersion`. Der akzeptierte/reused Tactical-Corridor-Source wurde deshalb **nicht** geaendert. Stattdessen akzeptiert Production Base Builder 24 fuer genau dieses Modul explizit dessen vorhandenes `Schema`-Feld; alle anderen Module bleiben auf dem bisherigen `SchemaVersion`-Preflight.

Aus diesem fehlgeschlagenen Lauf existiert **kein gueltiges A9-Bundle und kein A9-Bundle-Hash**. Die bereits vorhandene Production-Base-Datei im lokalen `dist` darf nicht als Ergebnis dieses Builds interpretiert werden.

Revalidation nach der Builderkorrektur: owner-lokaler Build + unabhaengige Hashkette erforderlich.

## 13. Owner-local Buildnachweis auf `eb9788fe`

Der Projektinhaber hat Production Base 24 und Acceptance 9 lokal erfolgreich gebaut.

```text
source commit:
eb9788fe6c70c77aeedf9bfe2dae585e6dca4fc6

production builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-25
SHA-256 4B9C7F5DBFB05B7E6809553F4A25847D085809C407E1B36255FB32BAE4546D6F

production bundle:
SHA-256 D6C0D2089D046C65477E197F645EA5C9CA540B1274037ED588059F1EE8C0F3E8

CasLifecycleRuntime:
SHA-256 2CC98A2DE51E574E0C62C1DCF81BC86D49E5A3561A6C10EC3249E06BF74DF147

CasReleasePolicy:
SHA-256 A61D71C6C4851B38E46DD9BC839825E0A34F25C81D79932E412C6016AF42D827

CasPatrolClosure:
SHA-256 C503500FB69FEFB4A429BF8AF403770FAA72C59A91B5CC0276D9EE27A41898F4

FlightPathNameContract:
SHA-256 333E895D8BF65138C96359CE564BE8F9967F7ADDA3A33E2AE8A8726103D95855

HelicopterFlightPathCorridor:
SHA-256 04D99722F0246AD261C47A90104E488FE9EF65721A647BE5CF6BAA602A1E279B

HelicopterCasTacticalCorridor:
SHA-256 E8FF4C196433CFCF287EEED25EAA31640EB8013A1286359CA63984811DDE08DA

Acceptance 9 source:
SHA-256 B5AD27452D7610B6C6B813780D0B3812F8E3EE6F000AC5FE17068E8BF3A2701E

Acceptance 9 builder:
SHA-256 305F59C020BDE7A729E45F0383F2FCF9F0DF1A0773B1BC83ABF017BBF798DB75

Acceptance 9 bundle:
SHA-256 E624F624746C0A419E81871345C4EB446B31E4521DBE347D9FB40B0854775BBF
```

Der unabhaengige `Get-FileHash`-Lauf bestaetigte dieselben Werte. `git status --short` zeigt ausschliesslich untracked Build-`dist`-Verzeichnisse und keine getrackten lokalen Aenderungen.

Status:

```text
source/build/hash provenance: VERIFIED_LOCAL_BUILD
DCS runtime: DCS_PENDING
```

Die fuer den naechsten DCS-Lauf maßgebliche Acceptance-LUA ist damit exakt das Bundle mit SHA-256 `E624F624746C0A419E81871345C4EB446B31E4521DBE347D9FB40B0854775BBF`.

## 14. DCS-Lauf 2026-09-20 – Runtime-Kette erfolgreich, Acceptance-False-Fail am post-return despawn

Testprovenienz:

```text
source commit: eb9788fe6c70c77aeedf9bfe2dae585e6dca4fc6
Acceptance bundle SHA-256: E624F624746C0A419E81871345C4EB446B31E4521DBE347D9FB40B0854775BBF
DCS: 2.9.29.27468
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Reale Runtime-Evidenz bestaetigt die beabsichtigte produktive Kette:

```text
QRF_DIRECT_TARGET_ENGAGE
-> CAS mission executing
-> CAS_SENSOR_REPORT detectedTotal=0 eligible=0
-> CAS_SUPPORTED_ELEMENT_CLEAR
-> CAS_NO_CONTACT_REPORTED stableSec=30
-> CAS_CONTROLLED_RELEASE reason=SUPPORTED_ELEMENT_RELEASE_NO_CONTACT
-> MOOSE mission status done
-> CAS_HOME_LANDED airport=Jalalabad
-> CAS_LEGION_ASSET_RETURNED
-> CAS_LIFECYCLE_COMPLETE fuelLowBeforeRelease=false
```

Das DCS-Debrief bestaetigt beide AH-64D desselben Einsatzes als in Jalalabad gestartet und spaeter wieder in Jalalabad gelandet.

Unmittelbar **nach** `CAS_LEGION_ASSET_RETURNED` setzte MOOSE den physischen Gruppenbestand auf 0/despawnte die zurueckgegebene Representation. Der bisherige Diagnosecheck interpretierte dieses post-return `CountAliveUnits()==0` faelschlich als:

```text
CAS_ASSET_LOSS initialAlive=2 alive=0
```

und A9 meldete deshalb trotz bereits vollstaendig erfolgreichem Lifecycle:

```text
[PRODUCTION BASE A9][FAIL] PRODUCTION_CAS_LIFECYCLE_FAILED CAS_ASSET_LOSS initialAlive=2 alive=0
```

Das ist **kein physischer Assetverlust**: `CAS_HOME_LANDED`, `CAS_LEGION_ASSET_RETURNED`, `CAS_LIFECYCLE_COMPLETE` sowie zwei reale `land`-Events in Jalalabad liegen vor.

Fehlerklasse:

```text
ACCEPTANCE_OBSERVER_FALSE_FAIL
```

Produktive Korrektur:

```text
asset-loss CountAliveUnits monitoring
-> only while assetReturned ~= true
-> post-LegionAssetReturned physical despawn is not loss evidence
```

Ein dedizierter Regressionstest setzt nach `LegionAssetReturned` den physischen Gruppenbestand auf 0 und verlangt weiterhin `completed=true`, `failed=false`, `assetLossReported=false`.

Der bestehende DCS-Lauf ist daher starke reale Evidenz fuer die produktive Route/Release/Recovery-Kette, kann aber wegen des fehlerhaften terminalen Acceptance-Ergebnisses nicht als finaler A9-PASS auf dem korrigierten Source hochgestuft werden. Korrigierter Source bleibt bis zum erneuten realen Lauf `DCS_PENDING`.

## 15. Owner-local Buildnachweis auf `c956b7b0`

Der Projektinhaber hat den korrigierten Production Base 25 / Acceptance 9-3 Stand lokal erfolgreich gebaut und die Builder-Ausgaben unabhaengig mit `Get-FileHash` bestaetigt.

```text
source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2

production builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-25
SHA-256 28B88BDFFC8499C9FC94C18732E8A0F45847E1D9DAEB7B93314A20853CF31D88

production bundle:
SHA-256 55D5B20DA29E8D646BAD5E23EBA72EF2422362868F5C22CF58956527631AFB47

CasLifecycleRuntime:
SHA-256 0C14D183F6692ADC6B5C4C18347364FED492695D48D919F9AE92995916286E05

CasReleasePolicy:
SHA-256 A61D71C6C4851B38E46DD9BC839825E0A34F25C81D79932E412C6016AF42D827

CasPatrolClosure:
SHA-256 C503500FB69FEFB4A429BF8AF403770FAA72C59A91B5CC0276D9EE27A41898F4

FlightPathNameContract:
SHA-256 333E895D8BF65138C96359CE564BE8F9967F7ADDA3A33E2AE8A8726103D95855

HelicopterFlightPathCorridor:
SHA-256 04D99722F0246AD261C47A90104E488FE9EF65721A647BE5CF6BAA602A1E279B

HelicopterCasTacticalCorridor:
SHA-256 E8FF4C196433CFCF287EEED25EAA31640EB8013A1286359CA63984811DDE08DA

Acceptance 9 source:
SHA-256 B5AD27452D7610B6C6B813780D0B3812F8E3EE6F000AC5FE17068E8BF3A2701E

Acceptance 9 builder:
SHA-256 A708F134DBC95B55D9C528E0A1DFE0E0E07B18EC5F5323FF611F0652CE3A1801

Acceptance 9 bundle:
SHA-256 D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0
```

`git status --short` zeigte ausschliesslich untracked Build-`dist`-Verzeichnisse und keine getrackten lokalen Aenderungen.

Status:

```text
source/build/hash provenance: VERIFIED_LOCAL_BUILD
DCS runtime: DCS_PENDING
```

Die fuer den naechsten DCS-Lauf massgebliche Acceptance-LUA ist damit exakt das Bundle mit SHA-256 `D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0`.

## 16. Finaler DCS-PASS auf korrigiertem Source

Finale Testprovenienz:

```text
source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2

Acceptance 9 bundle SHA-256:
D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0

DCS:
2.9.29.27468

MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Der reale DCS-Lauf vom 20.09.2026 auf dem korrigierten Source bestaetigt den vollstaendigen A9-Vertrag:

```text
FOB Joyce incident / QRF response
-> CAS_PROVIDER_PROFILE_BOUND
   provider=AW_US_JBAD_TF_SHOOTER_6_6_CAV
   home=Jalalabad
   primaryPathline=OMW_FlightPath_R200
   routePoints=24
-> CAS_MISSION_ASSIGNED
   asset=SQ_US_JBAD_AH64D_B_1_10_AVN_AID-158
-> owner tactical corridor configured
-> CAS mission executing
-> CAS_SUPPORTED_ELEMENT_CLEAR
-> CAS_NO_CONTACT_REPORTED stableSec=30
-> CAS_CONTROLLED_RELEASE reason=SUPPORTED_ELEMENT_RELEASE_NO_CONTACT reverseOwnerRoute=true
-> CAS_HOME_LANDED airport=Jalalabad
-> CAS_LEGION_ASSET_RETURNED
-> CAS_LIFECYCLE_COMPLETE fuelLowBeforeRelease=false
-> [PRODUCTION BASE A9][PASS]
```

Der zuvor beobachtete falsche post-return `CAS_ASSET_LOSS initialAlive=2 alive=0` tritt im finalen Lauf nicht mehr auf.

Der Acceptance-Watchdog lief vor der spaeten physischen Recovery ab, meldete aber wie vorgesehen nur `WARN`; er aenderte keinen Lifecycle-State. Der physische Production-Lifecycle lief weiter bis Landing, Legion asset return und PASS.

Nach dem PASS wurde DCS regulaer beendet (`Dispatcher Stop`). Der anschliessende `bhHook.lua`-Fehler (`tcp` nil) trat erst beim Shutdown auf und ist kein FSSR-/A9-Lifecycle-Fehler.

Finaler Status:

```text
source/build/hash provenance: VERIFIED_LOCAL_BUILD
DCS runtime: VALIDATED
Acceptance 9: PASS
```

Scope der Validation bleibt exakt A9: Joyce Production Base QRF + Rotary-Wing-CAS selection/owner-route/release/recovery. ARTY, ARTY rearm, strategic resupply, fixed-wing CAS und andere Site-/Provider-Profile sind dadurch nicht automatisch validiert.
