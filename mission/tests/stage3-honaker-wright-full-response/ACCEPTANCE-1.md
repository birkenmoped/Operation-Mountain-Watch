---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 combined Honaker attack, local response, Wright fire support, local rearm and strategic Air-AMMO closure acceptance contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## 1. Status

Dieser Acceptance-Test bleibt **PLANNED / nicht DCS-validiert**.

Historische Fehltests bis einschließlich der externen Slingload-/CARGOTRANSPORT-Versuche bleiben als Evidenz in den vorhandenen `FAIL-*`- und MOOSE-Analyse-Dokumenten erhalten. Sie validieren den aktuellen Pfad nicht.

Aktueller Builderstand:

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-19
```

Aktuelle Owner-Entscheidung vom 08.09.2026:

```text
external slingload development: SUSPENDED
current Air-AMMO transport: MOOSE OPSTRANSPORT + internal STORAGE
outbound: configured logical OMW_FlightPath
return: same configured route in reverse
```

Maßgebliches Entscheidungsdokument:

```text
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
```

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Für den aktuellen Stand verwendet beziehungsweise source-geprüft:

```text
OPSZONE Attacked / Defeated / Evaluated
OPSZONE:GetScannedGroupSet()
AUFTRAG:NewONGUARD(...)
AUFTRAG:SetEngageDetected(...)
AUFTRAG:AssignCohort(...)
AUFTRAG:NewPATROLZONE(...)
AUFTRAG:AssignSquadrons(...)
OPSTRANSPORT:New(...)
OPSTRANSPORT:AddCargoStorage(...)
OPSTRANSPORT OnAfterExecuting / OnAfterDelivered
LEGION.RecruitCohortAssets(...)
AIRWING:TransportAssign(...)
FLIGHTGROUP:GetWaypointCurrentUID()
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:UpdateRoute()
ARTY:New / AssignTargetCoord / GetAmmo / Rearm lifecycle
EVENTHANDLER / EVENTS.Shot
PATHLINE / COORDINATE routing
```

Nicht Bestandteil des aktuellen Air-AMMO-Pfads:

```text
AUFTRAG:NewCARGOTRANSPORT
PauseMission / TaskDone slingload handoff
CargoTransportation waypoint task
OMW_SlingloadCorridorHandoff
```

## 3. Alarm und Attack Incident

Die 1000-m-OPSZONE ist Alarm-/Evidence-Grenze:

```text
RED enters 1000-m alarm perimeter
-> OPSZONE Attacked
-> PROXIMITY_INTRUSION
-> one Honaker attack incident
```

Weitere `OPSZONE Evaluated`-Zyklen ergänzen neu erkannte RED-Gruppen als Incident-Teilnehmer. `OPSZONE Defeated` setzt `perimeterClear=true`; die taktische Completion basiert weiterhin auf den bekannten Incident-Teilnehmern:

```text
no living known attack participant remains
-> Close("KNOWN_ATTACKERS_NEUTRALIZED")
```

## 4. Guard und QRF

Aktueller Guard-Vertrag:

```text
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Spawn: ZON_BLUE_GND_HONAKER_ACCESS via BRIGADE:SetSpawnZone default distance
Route: OMW_RTE_BLUE_GUARD_HONAKER_01
Routing: PATHLINE:GetCoordinates -> COORDINATE:WaypointGround
         -> GROUP:TaskFunction / SetTaskWaypoint / Route
Behavior: repeated circuit
```

Aktueller QRF-Vertrag:

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
Composition: 5 infantry + 1 CHAP_MATV
Representation: one GROUP
Mission: AUFTRAG:NewONGUARD + SetEngageDetected
Return: SetReturnToLegion(true), mission Cancel after tactical completion
Settlement: PersonnelLedger only after ARMYGROUP:Returned
```

## 5. CAS

Der aktuelle CAS-Pfad verwendet:

```text
AUFTRAG:NewPATROLZONE
SetEngageDetected
Jalalabad AH-64D Squadron
configured logical OMW_FlightPath
-> WEST
-> tactical area
-> WEST reverse
-> configured logical OMW_FlightPath reverse
-> Jalalabad
```

Die konkrete primäre FlightPath-Variante wird nicht hart codiert. Gültig ist genau eine Mission-Editor-Konfiguration aus:

```text
OMW_FlightPath
OMW_FlightPath_Rnnn
OMW_FlightPath_Lnnn
```

`OMW_FlightPath_WEST` ist ein separater CAS-Segmentpfad und kein Kandidat für die primäre Variante.

Reale `EVENTS.Shot`-Telemetrie bleibt Acceptance-Evidence. Sie blockiert aber nicht mehr die operative CAS-Closure nach taktischer Completion.

## 6. Wright ARTY und lokaler M1083-Rearm

Der Acceptance-Vertrag bleibt:

```text
Wright L118 real fire
-> physical ammo decrease
-> local M1083 request
-> M1083 materialization
-> MOOSE ARTY rearm
-> CampaignState Wright 16 -> 15
-> M1083 return to Warehouse stock
-> reorder threshold 15 / 30 reached
```

Mindestens eine reale Fire-At-Point-Mission muss physische Munitionsabnahme zeigen.

## 7. Strategischer Air-AMMO-Resupply

Nach Erreichen des Reorder-Schwellwerts wird genau ein strategischer RESUPPLY-Demand erzeugt. Dedupe wird semantisch geprüft:

```text
duplicate.id == demand.id
duplicate.dedupeKey == demand.dedupeKey
created == false
reason == active_duplicate
```

CampaignState reserviert den strategischen Transfer:

```text
15 x GROUND_AMMO_PACKAGE
Jalalabad -> Wright
```

Erwarteter Endbestand:

```text
Wright:     30
Jalalabad:  85
```

CampaignState bleibt die strategische Ressourcenautorität.

## 8. CH-47 Air-AMMO – aktueller interner OPSTRANSPORT-Pfad

Der physische Ausführungspfad verwendet jetzt denselben MOOSE-Mechanismus wie der fokussierte erfolgreiche interne Transporttest:

```text
OPSTRANSPORT:New(nil, pickup, drop)
-> AddCargoStorage(sourceStorage, destinationStorage, ...)
-> SetRequiredCarriers(1,1)
-> bounded Jalalabad CH-47 recruitment
-> LEGION.RecruitCohortAssets(... AUFTRAG.Type.OPSTRANSPORT ...)
-> transport:AddAsset(asset)
-> AIRWING:TransportAssign(transport, legions)
-> MOOSE Loading
-> MOOSE Transporting
-> MOOSE Unloading
-> OPSTRANSPORT Delivered
```

Die MOOSE-STORAGE-Fixture dient ausschließlich als reproduzierbarer physischer Runtime-Nachweis. Sie ist keine zweite strategische Munitionsbuchhaltung und ersetzt `GROUND_AMMO_PACKAGE` in CampaignState nicht.

Acceptance-Fixture:

```text
Cargo type: ENUMS.Storage.weapons.bombs.Mk_82
Amount: 4
Item weight: 230 kg
Total: 920 kg
Source storage static: OMW_STAGE3_E2E_OPSTRANSPORT_SOURCE_STORAGE_001
Destination storage static: OMW_STAGE3_E2E_OPSTRANSPORT_WRIGHT_STORAGE_001
Pickup zone: ZON_BLUE_LOG_SLG_JALALABAD_01
Deploy zone: OMW_BLUE_LZ_WRIGHT_01
```

Die Zone behält ihren historischen Namen; daraus folgt keine Slingload-Semantik für den aktuellen Pfad.

## 9. Air-AMMO FlightPath-Routing

Die primäre Route wird mit `OMW_FlightPathNameContract.lua` als logische Route `OMW_FlightPath` aus der tatsächlich konfigurierten Mission-Editor-Variante bestimmt.

Für Wright als Feld-LZ verwendet der aktuelle Test:

```text
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
```

Der Adapter besitzt keine Cargo-/Delivery-Autorität und erzeugt keinen eigenen Transport-FSM. Er verwendet ausschließlich öffentliche MOOSE-FLIGTHGROUP-Waypointmethoden.

Outbound:

```text
OPSTRANSPORT carrier enters Transport lifecycle
-> OnAfterTransport
-> GetWaypointCurrentUID
-> configured FlightPath outbound via AddWaypoint
-> UpdateRoute
```

Return:

```text
OPSTRANSPORT Delivered
-> FLIGHTGROUP OnAfterDelivered
-> GetWaypointCurrentUID
-> configured FlightPath reverse via AddWaypoint
-> UpdateRoute
-> Jalalabad
```

Acceptance verlangt ausdrücklich:

```text
configured outbound route installed
Wright STORAGE delivery confirmed
configured reverse route installed after Delivered
Jalalabad landing observed
AIRWING/LEGION asset returned observed
```

## 10. Externe Slingload-Entwicklung

Bis zu einer neuen ausdrücklichen Owner-Entscheidung:

```text
NO external slingload development
NO NewCARGOTRANSPORT target path
NO PauseMission/TaskDone slingload handoff
NO CargoTransportation lifecycle bridge
```

Historische Slingload-Dateien und FAIL-Berichte bleiben Evidenz, aber nicht aktuelle Architektur.

## 11. Offline-/Build-Gate vor DCS

Vor einem neuen DCS-Lauf müssen mindestens erfüllt sein:

```text
MissionDemand CI: PASS
Documentation validation: PASS
full-response source contains OPSTRANSPORT/STORAGE path
full-response source contains no NewCARGOTRANSPORT/PauseMission/CargoTransportation handoff
configured FlightPath is logical-name based
builder embeds OMW_FlightPathNameContract and OMW_OpsTransportCorridorAdapter
builder static checks reject reintroduction of legacy slingload path
local builder succeeds
local GitCommit equals remote target commit
builder SHA256 equals independent Get-FileHash SHA256
MizMutation: false
```

Erst danach ist ein DCS-Lauf sinnvoll.

## 12. DCS-Acceptance-Gate

Der nächste reale Lauf muss mindestens bestätigen:

### Guard / QRF

```text
Guard materializes and follows OMW_RTE_BLUE_GUARD_HONAKER_01
mixed QRF materializes, engages as applicable, returns, PersonnelLedger settles
```

### CAS

```text
Jalalabad -> configured FlightPath -> WEST -> AO
real weapon employment
known incident participants neutralized -> immediate CAS closure
WEST reverse -> configured FlightPath reverse -> Jalalabad
safe landing / AIRWING recovery
```

### Fire support / local rearm

```text
real Wright L118 fire
physical ammo consumption
M1083 local rearm
M1083 return
strategic reorder trigger at 15/30
```

### Air-AMMO

```text
one strategic RESUPPLY demand
CH-47 executes MOOSE OPSTRANSPORT with internal STORAGE
configured FlightPath outbound physically flown
Wright OPSTRANSPORT/STORAGE delivery succeeds
configured FlightPath reverse physically flown
Jalalabad landing
AIRWING/LEGION recovery
Wright final strategic AMMO = 30
Jalalabad final strategic AMMO = 85
```

Nur ein realer Lauf mit vollständiger Branch-/Commit-/Bundle-/Mission-/DCS-/MOOSE-Provenienz darf den Status ändern.
