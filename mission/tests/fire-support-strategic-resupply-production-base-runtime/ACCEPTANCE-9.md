---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-9
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - observer-only validation of shared production CAS lifecycle
  - lifecycle-inheritance gate for FSSR Base CAS
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
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
-> stable no-contact >= 30 sec
-> controlled Cancel via existing CommanderBridge handle
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
stable >= 30 sec
-> production lifecycle calls existing CommanderBridge handle Cancel()
```

`nil` Detection ist nicht `no contact`.

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
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/09-production-cas-lifecycle-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-9.ps1
```

Status vor realem DCS-Lauf: `SOURCE_REVIEW_PENDING / DCS_PENDING`.
