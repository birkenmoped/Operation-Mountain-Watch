---
document_id: OMW-TEST-STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 Honaker CAS support-lifecycle and engagement acceptance after the Build 1-19 CAS regression
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# Stage 3 Honaker CAS Support Acceptance 1

## 1. Zweck

Dieser fokussierte Test prüft ausschließlich den CAS-Teil, der im realen Full-Response-Build `1-19` vom 08.09.2026 offen geblieben ist.

Der vorherige Lauf hat Guard, QRF, Wright ARTY und den internen CH-47-OPSTRANSPORT-Pfad belastbar beobachtbar gemacht. Diese Systeme werden deshalb in dieser LUA **nicht erneut dispatcht**.

Ziel ist, ohne einen weiteren unnötigen vollständigen 30-Minuten-Lauf zu prüfen:

```text
Honaker attack detection
-> CAS support requirement
-> C2/AIRWING allocation
-> AH-64D route to Honaker
-> PATROLZONE + SetEngageDetected
-> AH-64D own MOOSE/DCS detection picture
-> actual EngageTarget/weapon telemetry if a target is detected
-> independent Honaker status + CAS status reconciliation
-> explicit supported-element release
```

## 2. Maßgebliche CAS-Entscheidung

Es gilt:

```text
OPSZONE / 1000-m alarm
!= CAS lifecycle authority

GroundInstallationAttackIncident
!= CAS lifecycle authority

TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC
!= CAS lifecycle authority

F10-visible RED units
!= AH-64D detected targets
```

Vollständiger Entscheidungsnachweis:

```text
docs/moose/STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md
```

Die temporäre Build-1-17-Regel

```text
zero living incident participants -> immediate CAS release
```

ist für diesen Test ausdrücklich außer Kraft.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source-geprüfte öffentliche Funktionen/Mechanismen:

```text
AUFTRAG:NewPATROLZONE()
AUFTRAG:SetEngageDetected()
OPSGROUP:SetEngageDetectedOn()
OPSGROUP:SetDetection(true)   [MOOSE-intern durch SetEngageDetectedOn]
OPSGROUP:GetDetectedGroups()
ZONE_BASE:IsCoordinateInZone()
COORDINATE:Get3DDistance()
FLIGHTGROUP OnAfterEngageTarget FSM event
EVENTS.Shot
AUFTRAG:Cancel() through OMW_FobAttackCasPatrolClosure
```

`SetEngageDetectedOn()` aktiviert im gepinnten Source die MOOSE-Erkennung. Der automatische Engage-Pfad arbeitet anschließend mit dem eigenen `detectedgroups`-Bild des OPSGROUP/FLIGHTGROUP.

## 4. Informationsgrenzen

Der Test erzeugt **keine** künstliche globale RED-Zielliste für den Apache.

Insbesondere verboten:

```text
blanket KnowTarget()
F10-map RED injection
raw tactical RED count as CAS target list
attackIncident participants injected into AH-64 sensors
```

Der CAS-Sensorreport basiert ausschließlich auf:

```lua
state.casFlight:GetDetectedGroups()
```

und wird für die aktuelle Mission gegen dieselben Kriterien eingegrenzt, die der MOOSE-Engage-Pfad verwendet:

```text
alive
RED
Ground Units
inside current CAS tactical zone
within configured 5-NM engage range from the AH-64 flight
```

## 5. On-station-Gate

Ein leeres Detection-Set darf während Anflug/Ingress niemals als `CAS_NO_CONTACT_REPORTED` interpretiert werden.

Der Test setzt `CAS_ON_STATION` erst, wenn die reale FLIGHTGROUP-Koordinate innerhalb der Honaker-CAS-Tactical-Zone liegt:

```text
AH-64 flight coordinate inside CAS tactical zone
-> CAS_ON_STATION
-> begin CAS own detection-status reconciliation
```

## 6. Unterstützungsstatus und Release

Honaker kann lokal melden:

```text
HONAKER_NO_KNOWN_ATTACKERS
```

Das schließt CAS **nicht**.

CAS kann melden:

```text
CAS_CONTACT_REPORTED
oder
CAS_NO_CONTACT_REPORTED
```

Auch `CAS_NO_CONTACT_REPORTED` schließt CAS alleine **nicht**.

Der fokussierte Acceptance-Release erfolgt erst nach der expliziten Kombination:

```text
HONAKER_NO_KNOWN_ATTACKERS
AND
CAS_ON_STATION
AND
CAS_NO_CONTACT_REPORTED
-> supported element/control releases CAS
-> OMW_FobAttackCasPatrolClosure
-> AUFTRAG:Cancel()
-> planned reverse recovery chain
```

Wenn der AH-64 dagegen einen engagement-eligible Kontakt meldet:

```text
CAS_CONTACT_REPORTED
-> CAS support requirement remains ACTIVE
```

## 7. Engagement-Telemetrie

Zusätzlich zur MOOSE-internen Logik protokolliert der Test:

```text
CAS_SENSOR_REPORT
CAS_ENGAGE_EVENT
EVENTS.Shot
```

Damit kann der nächste Log eindeutig unterscheiden:

```text
A. AH-64 reached station but detected nothing
B. AH-64 detected an eligible target but MOOSE did not enter EngageTarget
C. MOOSE entered EngageTarget but DCS produced no weapon employment
D. weapon employment occurred
```

Diese Trennung fehlte im Build-1-19-Lauf.

## 8. Route

Die Route bleibt unverändert MOOSE-first und owner-configured:

```text
Jalalabad
-> logical configured OMW_FlightPath variant
-> OMW_FlightPath_WEST
-> PATROLZONE task
-> OMW_FlightPath_WEST reverse
-> same configured OMW_FlightPath variant reverse
-> Jalalabad
```

Kein hart codiertes `_R200` oder `_R500`.

## 9. Isolation des Tests

Diese Acceptance-LUA dispatcht ausdrücklich nicht:

```text
Guard
QRF
ARTY
M1083 rearm
CH-47 resupply
```

Die vorhandenen RED-Angreifer bleiben damit für den CAS-Test möglichst unbeeinflusst, sodass ein fehlender Apache-Angriff nicht wieder durch Ground-/ARTY-Wirkung verdeckt wird.

## 10. Build

Builder:

```text
tools/build-stage3-honaker-cas-support-acceptance-1.ps1
```

Erzeugte LUA:

```text
mission/tests/stage3-honaker-cas-support/dist/OMW_Stage3_Honaker_CAS_Support_Acceptance_1.lua
```

Builder-Version:

```text
STAGE3-HONAKER-CAS-SUPPORT-ACCEPTANCE-1-1
```

## 11. Static Gate

Vor DCS müssen mindestens PASS sein:

```text
Lua syntax
Documentation validation
builder completes
GitCommit in bundle == actual branch HEAD
pinned Moose hash recorded
builder SHA256 == independent Get-FileHash SHA256
no closeCasIfReady legacy coupling
no tactical RED count CAS gate
no KnowTarget target injection
no CASENHANCED
no native DCS spawn/task fallback
MizMutation=false
```

## 12. DCS Acceptance

Ein erfolgreicher Lauf muss mindestens zeigen:

```text
CAS demand created from Honaker attack
AH-64D allocated
configured ingress route installed
PATROLZONE + SetEngageDetected executing
AH-64D reaches CAS_ON_STATION
CAS_SENSOR_REPORT produced
```

Wenn ein relevanter AH-64-eigener Kontakt vorhanden ist, zusätzlich erwartet:

```text
CAS_CONTACT_REPORTED
-> MOOSE EngageTarget / CAS_ENGAGE_EVENT
-> weapon employment if DCS can execute the engagement
-> CAS remains active while relevant contacts persist
```

Wenn nach Honakers lokalem `HONAKER_NO_KNOWN_ATTACKERS` kein relevanter AH-64-eigener Kontakt mehr vorhanden ist:

```text
CAS_NO_CONTACT_REPORTED
-> explicit supported-element release
-> demand SUCCESS
-> recovery chain released
```

Der Test ist bis zu diesem realen DCS-Nachweis `PLANNED` und `validated_in_dcs: false`.
