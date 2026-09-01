---
document_id: OMW-MOOSE-STAGE3-BUILD-1-11-RECONCILIATION
status: PLANNED
document_class: MOOSE_TECHNICAL_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 build 1-11 MOOSE-first reconciliation after build 1-10 failure
  - approved owner decision for PATHLINE suffix offset metadata
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

## 12. Verifikationsstatus

```text
Source/MOOSE review             COMPLETE for build 1-11 path
Owner offset decision           APPROVED 2026-09-01
Implementation                  COMPLETE for planned build 1-11 source
Local PowerShell build          PENDING
Real local SHA-256 provenance   PENDING
Mission Editor rename           PENDING OWNER LOCAL STEP
Combined DCS acceptance         PENDING
validated_in_dcs                false
```

Erst reale lokale Build-/Hash-Ausgabe und danach ein dokumentierter DCS-Lauf dürfen den Status verändern.
