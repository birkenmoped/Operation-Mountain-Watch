---
document_id: OMW-MOOSE-STAGE3-BUILD-1-11-RECONCILIATION
status: PLANNED
document_class: MOOSE_TECHNICAL_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 build 1-11 MOOSE-first reconciliation after build 1-10 failure
  - approved owner decision for PATHLINE suffix offset metadata
  - real local Build 1-11 provenance before DCS acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 Build 1-11 – MOOSE-first Reconciliation

## 1. Ausgangspunkt

Der reale Stage-3-Build-`1-10`-Lauf blieb `FAIL`. Der zugehörige Source-Audit ist:

```text
docs/moose/STAGE3-CAS-GUARD-QRF-ROUTING-AUDIT.md
```

Der Projektinhaber hat am 01.09.2026 die vollständige Korrekturreihenfolge freigegeben, ausdrücklich einschließlich einer kleinen OMW-Erweiterung für segmentbezogene PATHLINE-Offset-Metadaten.

Freigegebene Reihenfolge:

```text
1. CAS-Lifecycle auf native MOOSE MissionIngress/MissionEgress zurückführen.
2. PATROLZONE + SetEngageDetected gegen NewCASENHANCED bewerten.
3. Höhenführung auf einen Mechanismus reduzieren.
4. owner-authored FlightPath lifecycle-sicher anbinden.
5. segmentbezogene Offset-Metadaten entscheiden.
6. Guard auf owner-authored PatrolRoute bringen.
7. QRF auf bindende Infantry+Vehicle-Baseline bringen.
8. RESUPPLY-Dedupe-Gate korrigieren.
9. Erst danach neuer Gesamt-DCS-Test.
```

Alle folgenden Änderungen bleiben bis zum realen DCS-Lauf `SOURCE_REVIEWED / DCS_PENDING`.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 3. CAS-Missionsform

Build `1-11` verwendet für die gewünschte CAS-Bereitschaft im Einsatzraum:

```lua
local mission = AUFTRAG:NewPATROLZONE(zone, speedKts, altitudeFtAsl)
mission:SetEngageDetected(rangeNm, { "Ground Units" }, zone, nil)
```

Das ist gegenüber `NewCASENHANCED(...)` für den Acceptance-Zweck die bewusst gewählte MOOSE-first-Kombination:

```text
PATROLZONE
-> persistent readiness / loiter in tactical area
SetEngageDetected
-> MOOSE-owned detection and target selection
EngageTarget
-> existing MOOSE/DCS attack task path
```

Die Änderung behauptet ausdrücklich **keine** Apache-spezifische Hellfire-/Standoff-Steuerung. Das tatsächliche AH-64D-Angriffsverhalten bleibt DCS-pending.

Der Jalalabad-AH-64D-SQUADRON-/Payload-Pfad enthält für Build `1-11` zusätzlich `AUFTRAG.Type.PATROLZONE`.

## 4. Native MissionIngress/MissionEgress

Der CAS-Auftrag erhält vor dem AIRWING-Queueing die nativen MOOSE-Lifecycle-Anker:

```lua
mission:SetMissionIngressCoord(...)
mission:SetMissionEgressCoord(...)
```

Damit bleibt MOOSE Eigentümer von Missionsbeginn, Missionsende und Egress-Semantik.

Die owner-authored Valley-Geometrie wird nicht mehr als unabhängige, lifecycle-fremde Return-Route behandelt.

## 5. Lifecycle-sicherer owner-authored FlightPath

Neuer kleiner Adapter:

```text
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
SchemaVersion: OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-2
```

Vertrag:

```text
native AUFTRAG ingress/egress remain lifecycle anchors
owner-authored PATHLINE geometry is supplemental only
all injected FLIGHTGROUP waypoints receive:
  waypoint.missionUID = mission.auftragsnummer
MOOSE PauseMission may therefore remove them with the mission
OnAfterUpdateRoute re-installs them after MOOSE rebuilds the mission route
```

Der Adapter ersetzt keine MOOSE-Mission, keinen EngageDetected-Lifecycle, keinen RTB-FSM und keinen eigenen Flugcontroller.

## 6. Höhenführung

Build `1-10` kombinierte:

```text
FLIGHTGROUP:AddWaypoint(... RADIO altitude ...)
+
FLIGHTGROUP:SetAltitude(... Keep=true, RadarAlt=true)
```

Build `1-11` entfernt den Stage-3-`SetAltitude()`-Override vollständig.

Verbleibender Höhenpfad:

```text
AUFTRAG PATROLZONE mission altitude
+
FLIGHTGROUP:AddWaypoint altitude for owner-authored route points
```

Für Hubschrauber setzt der gepinnte MOOSE-Source die erzeugten FLIGHTGROUP-Waypoints auf `RADIO`. Ob die reale DCS-Flugführung das gewünschte Profil stabil hält, muss im nächsten Lauf durch Telemetrie geprüft werden.

## 7. Owner-approved segmentbezogene PATHLINE-Offsets

Die MOOSE-Prüfung hat keine native Funktion ergeben, welche PATHLINE-Namenssuffixe automatisch in laterale Segment-Offsets umsetzt. Der Projektinhaber hat die kleine OMW-Metadatenadaption deshalb ausdrücklich freigegeben.

Verbindlicher Adaptervertrag:

```text
_R<number> am Namensende = number Meter rechts relativ zur Flugrichtung
_L<number> am Namensende = number Meter links relativ zur Flugrichtung
kein Suffix              = 0 m / Centerline
```

Beispiele:

```text
OMW_FlightPath_R500      -> +500 m rechts
OMW_FlightPath_WEST      -> 0 m
OMW_FlightPath_EAST_L250 -> -250 m / links
```

Stage-3-Mission-Editor-Prerequisite:

```text
OMW_FlightPath -> OMW_FlightPath_R500
OMW_FlightPath_WEST bleibt unverändert
```

Der Builder verändert die `.miz` nicht.

## 8. Guard

Build `1-11` verwendet die owner-authored Gruppe:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
```

mit:

```lua
group:PatrolRoute()
```

Damit wird die bindende Guard-Baseline erstmals tatsächlich getestet. Afghanistan-Ground-Pathfinding bleibt DCS-pending.

## 9. QRF – Infantry + Vehicle und deterministische Cohort-Bindung

Build `1-11` verwendet:

```text
INFANTRY:
TPL_BLUE_GND_INF_RIFLE_SQUAD_9

VEHICLE:
TPL_BLUE_GND_QRF_MIXED_4
```

Beide erhalten getrennte `PLATOON`-Pools und getrennte `ONGUARD + SetEngageDetected`-Aufträge gegen dasselbe Attack Incident/Tactical Area.

Die gepinnte `AUFTRAG:AssignCohort(Cohort)`-Dokumentation sagt ausdrücklich, dass nur die zugewiesenen Cohorts für den Auftrag berücksichtigt werden. Build `1-11` bindet deshalb jeden Auftrag explizit:

```lua
mission:AssignCohort(platoon)
```

Dadurch ist der Acceptance-Vertrag deterministisch:

```text
INFANTRY AUFTRAG -> infantry PLATOON only
VEHICLE AUFTRAG  -> vehicle PLATOON only
```

Es wird kein eigener Recruitment-/Target-Selection-Mechanismus implementiert.

## 10. RESUPPLY-Dedupe

Build `1-10` verglich bei `active_duplicate` fälschlich Lua-Tabellenidentität.

Build `1-11` prüft:

```text
duplicate.id == demand.id
duplicate.dedupeKey == demand.dedupeKey
duplicateCreated == false
duplicateReason == "active_duplicate"
```

Damit entspricht das Acceptance-Gate dem tatsächlichen `MissionDemand.Registry:Create()`-Vertrag.

## 11. Builder-Gates

Builder:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-11
```

Der Builder verlangt unter anderem:

```text
AUFTRAG:NewPATROLZONE
SetEngageDetected
AssignCohort
SetMissionIngressCoord
SetMissionEgressCoord
missionUID
OMW-HELICOPTER-MISSION-OWNED-CORRIDOR-2
PATHLINE_SUFFIX
OMW_FlightPath_R500
OMW_FlightPath_WEST
PatrolRoute
TPL_BLUE_GND_QRF_MIXED_4
semantic RESUPPLY dedupe markers
```

Zusätzlich verbietet der Stage-3-Acceptance-Source-Gate:

```text
CasAdapter.MissionMode.CASENHANCED
Stage-3 SetAltitude(...)
duplicate ~= demand
```

## 12. Reale lokale Build-Provenienz 2026-09-01

Der Projektinhaber führte nach dem dokumentierten Preflight-Fix den realen lokalen Build im Worktree

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
```

aus.

Verifizierter Git-Stand:

```text
Branch: agent/fire-support-strategic-resupply-alarm-evidence
HEAD:   8c543826f63d7cb436c8cddfac3feb029bcdce96
```

Vor und nach dem Build meldete `git status --short` ausschließlich bereits vorhandene untracked `dist/`-Verzeichnisse; keine tracked Source-Datei wurde lokal verändert.

Jalalabad AirOps Foundation:

```text
BuilderVersion: JBAD-AIR-OPS-FOUNDATION-ONLY-4
AH64DCapabilities: CAS,CASENHANCED,PATROLZONE
Bundle SHA-256: E70443B6363D576BCDA55CF7EE87266BA413546AB5840CF002ACEC2E0023C468
GitCommit: 8c543826f63d7cb436c8cddfac3feb029bcdce96
```

Stage 3:

```text
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-11
GeneratedUtc: 2026-09-01T16:07:04Z
GitCommit: 8c543826f63d7cb436c8cddfac3feb029bcdce96
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Bundle SHA-256: 77C5214982272B251CB11CD95E6BB996091873028C6D242FBDA2D765AA11CBB8
```

Relevante neue Source-Hashes des Build-1-11-Pfads:

```text
OMW_FobAttackCasDispatchAdapter.lua      55722F557CBDF982E293B10D6201385F4F21ED80D8D401DB6C17165F7F68B3EA
OMW_FobAttackCasPatrolClosure.lua        FCBD97E2DAD589642AA89FC55E2FD35ED2E92A09946B4CD15BAA03BD8B2CD6D7
OMW_HelicopterFlightPathCorridor.lua     04D99722F0246AD261C47A90104E488FE9EF65721A647BE5CF6BAA602A1E279B
OMW_HelicopterMissionOwnedCorridor.lua   B940CE6A17D9AB59B1E254A19AB95BB82D94A345571B0A9D032D8C85AA20AF2C
01-honaker-wright-full-response-acceptance.lua
                                        A042EBC5B52FEC60AC220B851CACA9403A9ADEF1DAA241A269858DB66ADF49E4
OMW_AirOps_Jalalabad_Bootstrap.lua       108993CBA4552E0A9893C54F58D207AE1A42635C5895D26BE0DA4C4FEC0C4EEE
```

Damit ist der lokale Build-/Hash-Gate für Build `1-11` erfüllt. Dies ist **kein DCS-Runtime-PASS**.

## 13. Verifikationsstatus

```text
Source/MOOSE review             COMPLETE for build 1-11 path
Owner offset decision           APPROVED 2026-09-01
Implementation                  COMPLETE for planned build 1-11 source
Local PowerShell build          PASS at commit 8c543826f63d7cb436c8cddfac3feb029bcdce96
Real local SHA-256 provenance   RECORDED
Mission Editor rename           PENDING OWNER LOCAL STEP
Combined DCS acceptance         PENDING
validated_in_dcs                false
```

Nächster zulässiger Schritt ist die lokale Mission-Editor-Reconciliation (`OMW_FlightPath` -> `OMW_FlightPath_R500`), Einbettung der beiden neu gebauten Lua-Bundles und danach ein neuer dokumentierter DCS-Lauf.