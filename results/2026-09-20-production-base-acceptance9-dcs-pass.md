---
document_id: OMW-RESULT-FSSR-PRODUCTION-BASE-A9-DCS-PASS-20260920
status: PLANNED
document_class: RUNTIME_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact observed DCS runtime result of Production Base Acceptance 9
  - CAS route/release/recovery evidence for the documented source and bundle
not_authoritative_for:
  - repository-wide governance
  - fixed-wing CAS
  - ARTY or ARTY rearm
  - Strategic Resupply
  - other provider/site execution profiles
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: true
validation_status: DCS_VALIDATED_FOR_DOCUMENTED_SCOPE
---

# Production Base Acceptance 9 – finaler DCS-PASS am 20.09.2026

## Provenienz

```text
tested source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2

Production Base:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-25

Acceptance Builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-9-3

Acceptance Bundle SHA-256:
D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0

DCS:
2.9.29.27468

MOOSE:
2.9.18
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Der lokale Build/Hash-Nachweis steht in `mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-9.md`.

## Reale DCS-Evidenz

Der finale Lauf erreichte die beabsichtigte Production-CAS-Kette:

```text
CAS_PROVIDER_PROFILE_BOUND
-> CAS_MISSION_ASSIGNED
-> CAS_OWNER_CORRIDOR_INSTALLED
-> CAS_EXECUTING
-> CAS_SENSOR_REPORT detectedTotal=0 eligible=0
-> CAS_SUPPORTED_ELEMENT_CLEAR
-> CAS_NO_CONTACT_REPORTED stableSec=30
-> CAS_CONTROLLED_RELEASE reason=SUPPORTED_ELEMENT_RELEASE_NO_CONTACT
-> physical recovery
-> CAS_HOME_LANDED airport=Jalalabad
-> CAS_LEGION_ASSET_RETURNED
-> CAS_LIFECYCLE_COMPLETE fuelLowBeforeRelease=false
-> [PRODUCTION BASE A9][PASS]
```

Der DCS-Log beendet den Acceptance-Pfad explizit mit:

```text
[PRODUCTION BASE A9][PASS]
Production Base CAS lifecycle complete:
MOOSE selection
-> owner route
-> supported-element/no-contact release
-> reverse recovery
-> home landing
-> Legion asset return
```

## Provider / Asset / Home

Im Lauf wurde der operative Provider durch MOOSE ausgewählt und anschließend dessen Owner-Profil gebunden:

```text
provider:
AW_US_JBAD_TF_SHOOTER_6_6_CAV

asset:
SQ_US_JBAD_AH64D_B_1_10_AVN_AID-158

home:
Jalalabad

primary pathline:
OMW_FlightPath_R200

resolved owner-route points:
24
```

OMW traf keine vorgelagerte konkrete Assetauswahl.

## Release-Evidenz

Die Release-Kette war:

```text
valid own FLIGHTGROUP detection
detectedTotal=0
eligible=0

CAS_SUPPORTED_ELEMENT_CLEAR
source=INSTALLATION_INCIDENT_PARTICIPANTS

CAS_NO_CONTACT_REPORTED
source=FLIGHTGROUP_GetDetectedGroups
stableSec=30

CAS_CONTROLLED_RELEASE
reason=SUPPORTED_ELEMENT_RELEASE_NO_CONTACT
reverseOwnerRoute=true
```

Damit ist fuer diesen A9-Scope belegt:

- Alarm-/Perimeter-Clear ist nicht die Release-Autoritaet.
- Eigene CAS-Detection wurde verwendet.
- `nil` wurde nicht als no contact interpretiert.
- die A9-spezifische 30-s-Policy wurde produktiv ausgefuehrt;
- Release erfolgte vor FuelLow;
- FuelLow war kein Completion-Ersatz.

## Recovery-Evidenz

Der DCS-Log bestaetigt:

```text
CAS_HOME_LANDED airport=Jalalabad
CAS_LEGION_ASSET_RETURNED
CAS_LIFECYCLE_COMPLETE fuelLowBeforeRelease=false
```

Der Debrief bestaetigt zwei physische `AH-64D_BLK_II`-Landungen in Jalalabad fuer die Mission IDs `1000011` und `1000012`.

## Geschlossene Regression

Der erste A9-Lauf hatte nach erfolgreichem exact asset return den anschliessenden MOOSE/DCS-Cleanup der physischen Gruppe irrtuemlich als:

```text
CAS_ASSET_LOSS initialAlive=2 alive=0
```

klassifiziert.

Im korrigierten finalen Lauf tritt dieser terminale False-Fail nicht mehr auf.

Daraus folgt die festgeschriebene Lifecycle-Regel:

```text
exact LegionAssetReturned
-> authoritative return confirmation
-> later physical representation removal/despawn
   != asset loss
```

## Watchdog

Der Acceptance-Watchdog blieb rein diagnostisch. Auch wenn vor der spaeten physischen Recovery ein WARN ausgegeben wurde, lief der Production-Lifecycle unveraendert weiter bis:

```text
home landing
-> LegionAssetReturned
-> lifecycle complete
-> PASS
```

Damit bestaetigt der reale Lauf auch das Watchdog-Gesetz aus `ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`.

## Shutdown

Nach dem A9-PASS wurde DCS regulaer beendet. Ein spaeterer `bhHook.lua`-Fehler mit `tcp == nil` trat im Shutdown-Hook auf und ist keine Evidenz fuer einen FSSR-/CAS-Lifecycle-Fehler.

## Ergebnis

```text
A9 runtime result: PASS
DCS runtime: VALIDATED_FOR_DOCUMENTED_SCOPE
post-return false loss regression: CLOSED
FuelLow before release: NO
physical home landing: YES
exact Legion asset return: YES
Acceptance-owned lifecycle logic: NO
```

## Scope-Grenze

Dieser Lauf validiert exakt:

```text
Joyce Production Base incident/QRF
+ MOOSE-selected Jalalabad rotary-wing CAS
+ owner route/tactical corridor
+ own-detection release
+ reverse recovery
+ home landing
+ exact asset return
```

Nicht automatisch validiert:

```text
fixed-wing CAS
other provider profiles
other site execution profiles
ARTY
ARTY rearm
Strategic Resupply
combined full-response _base
```
