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

Historische Fehltests bis einschließlich der externen Slingload-/CARGOTRANSPORT-Versuche bleiben als Evidenz erhalten. Der reale Build-1-19-Lauf bestätigte getrennt Guard, QRF, ARTY und den internen CH-47-OPSTRANSPORT-Pfad, war aber wegen der veralteten CAS-Closure nicht als Gesamt-PASS gültig.

Aktueller Builderstand:

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-22
```

Owner-Entscheidungen vom 08.09.2026:

```text
external slingload development: SUSPENDED
current Air-AMMO transport: MOOSE OPSTRANSPORT + internal STORAGE
outbound: configured logical OMW_FlightPath
return: same configured route in reverse
CH-47 full-response transit profile: 125 kt
CH-47 lead-turn acceptance profile: 250 m bounded fly-by approximation
CAS termination: supported-element/control release, not OPSZONE/attackIncident/raw RED count
```

Maßgebliche Entscheidungsdokumente:

```text
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
docs/moose/STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md
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
FLIGHTGROUP:GetDetectedGroups()
FLIGHTGROUP:GetWaypointCurrentUID()
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:UpdateRoute()
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:HeadingTo(...)
OPSTRANSPORT:New(...)
OPSTRANSPORT:AddCargoStorage(...)
OPSTRANSPORT OnAfterExecuting / OnAfterDelivered
LEGION.RecruitCohortAssets(...)
AIRWING:TransportAssign(...)
ARTY:New / AssignTargetCoord / GetAmmo / Rearm lifecycle
EVENTHANDLER / EVENTS.Shot
PATHLINE / COORDINATE routing
```

Nicht Bestandteil des aktuellen Pfads:

```text
AUFTRAG:NewCARGOTRANSPORT
PauseMission / TaskDone slingload handoff
CargoTransportation waypoint task
OMW_SlingloadCorridorHandoff
KnowTarget() injection for CAS
raw tactical RED count as CAS release gate
```

## 3. Alarm und lokales Attack Incident

Die 1000-m-OPSZONE ist Alarm-/Evidence-Grenze:

```text
RED enters 1000-m alarm perimeter
-> OPSZONE Attacked
-> PROXIMITY_INTRUSION
-> one Honaker attack incident
```

Weitere `OPSZONE Evaluated`-Zyklen ergänzen neu erkannte RED-Gruppen als Incident-Teilnehmer. Sind keine bekannten Incident-Teilnehmer mehr am Leben, darf Honaker den lokalen Status setzen:

```text
HONAKER_NO_KNOWN_ATTACKERS
```

Das beendet die lokale Incident, **aber weder automatisch CAS noch QRF**. QRF bleibt im bestehenden MOOSE-ONGUARD-Auftrag, bis die unterstützte Einheit CAS ausdrücklich freigibt. `OPSZONE Defeated`, `attackIncidentClosed` und ein raw RED-group count besitzen keine CAS-Termination-Authority.

## 4. Guard und QRF

Guard-Vertrag:

```text
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Spawn: ZON_BLUE_GND_HONAKER_ACCESS via BRIGADE:SetSpawnZone default distance
Route: OMW_RTE_BLUE_GUARD_HONAKER_01
Routing: PATHLINE:GetCoordinates -> COORDINATE:WaypointGround
         -> GROUP:TaskFunction / SetTaskWaypoint / Route
Behavior: repeated circuit
```

QRF-Vertrag:

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
Composition: 5 infantry + 1 CHAP_MATV
Representation: one GROUP
Mission: AUFTRAG:NewONGUARD + SetEngageDetected
Return: SetReturnToLegion(true), mission Cancel erst nach expliziter supported-element/C2-Freigabe; nie allein nach lokaler Incident-Completion
Settlement: PersonnelLedger only after ARMYGROUP:Returned
```

## 5. CAS – korrigierter Gesamtintegrationsvertrag

Der CAS-Pfad verwendet:

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

`OMW_FlightPath_WEST` ist ein separater CAS-Segmentpfad.

### 5.1 Informations- und Release-Grenze

Die AH-64-FLIGHTGROUP verwendet ihr eigenes MOOSE/DCS-Detektionsbild:

```text
FLIGHTGROUP:GetDetectedGroups()
-> alive RED Ground Units
-> inside Honaker CAS tactical zone
-> within configured CAS engagement range
```

Die Acceptance injiziert **keine** F10-map-RED-Liste mit `KnowTarget()`.

CAS bleibt aktiv, wenn das eigene AH-64-Bild noch einen relevanten Kontakt enthält, auch wenn Honaker bereits `HONAKER_NO_KNOWN_ATTACKERS` gemeldet hat.

Normale Acceptance-Release:

```text
Honaker: HONAKER_NO_KNOWN_ATTACKERS
AND
CAS: physically ON STATION
AND
CAS own detectedgroups: NO eligible contact, stabil über 30 Sekunden
-> SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
-> CasPatrolClosure.Complete(... releaseSource=BLUE_GROUND_COP_HONAKER ...)
```

Der erste leere Sensor-Snapshot nach On Station ist ausdrücklich keine Freigabe. Ein Engage-Event setzt eine laufende No-Contact-Qualifikation zurück. Damit prüft der Gesamtintegrationstest, ob die Apaches nach Wirkung von Guard/QRF/ARTY noch selbst erkannte verbleibende Gruppen weiter angreifen und anschließend kontrolliert zurückkehren.

### 5.2 Reale fokussierte CAS-Evidenz vom 08.09.2026

Der unmittelbar vorhergehende fokussierte CAS-Test bestätigte praktisch:

```text
AH-64 two-ship dispatched: YES
PATROLZONE + SetEngageDetected: YES
both AH-64 attacked: YES (owner observation / DCS log evidence)
both AH-64 lost during engagement: YES
full-response interaction with Guard/QRF/ARTY: NOT TESTED by focused acceptance
```

Der fokussierte Lauf ist daher ein positiver Engagement-Nachweis, aber kein Gesamtintegrations-PASS und keine Aussage über CAS-Survivability.

## 6. C2-Beobachtung für QRF / ARTY

Der Full-Response-Test erzeugt zusätzlich zur 1000-m-Alarm-OPSZONE eine eigene MOOSE-OPSZONE mit 5 NM Radius um Honaker:

```text
C2_FIRE_OBSERVATION
-> MOOSE OPSZONE:GetScannedGroupSet()
-> bekannte lebende RED Ground Groups
-> QRF-/ARTY-Zielbild
```

Sie besitzt keine CAS-Release- oder CAS-Termination-Authority. Sie bleibt nach Abschluss der ersten lokalen Honaker-Incident aktiv, damit QRF und ARTY nicht allein deshalb heimkehren beziehungsweise das Feuer einstellen. Sobald CAS physisch ON STATION ist, erzeugt C2 keine neue ARTY-Fire-Mission; laufende Fire-Missionen werden nicht künstlich abgebrochen.

## 7. Wright ARTY und lokaler M1083-Rearm

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

## 8. Strategischer Air-AMMO-Resupply

Nach Erreichen des Reorder-Schwellwerts wird genau ein strategischer RESUPPLY-Demand erzeugt. Dedupe wird semantisch geprüft:

```text
duplicate.id == demand.id
duplicate.dedupeKey == demand.dedupeKey
created == false
reason == active_duplicate
```

CampaignState reserviert:

```text
15 x GROUND_AMMO_PACKAGE
Jalalabad -> Wright
```

Erwarteter Endbestand:

```text
Wright:     30
Jalalabad:  85
```

CampaignState bleibt strategische Ressourcenautorität.

## 9. CH-47 Air-AMMO – interner OPSTRANSPORT-Pfad

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

Die MOOSE-STORAGE-Fixture ist nur reproduzierbare physische Runtime-Evidence; sie ist keine zweite strategische Ressourcenautorität.

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

## 10. Air-AMMO FlightPath, Geschwindigkeit und Lead-Turn-Profil

Die primäre Route wird mit `OMW_FlightPathNameContract.lua` aus der tatsächlich konfigurierten logischen `OMW_FlightPath`-Variante bestimmt.

Für Wright als Feld-LZ verwendet der Test:

```text
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
Schema: OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2
```

Der Adapter besitzt keine Cargo-/Delivery-Autorität und keinen eigenen Transport-FSM.

### 9.1 Geschwindigkeit

MOOSE `FLIGHTGROUP:AddWaypoint(Coordinate, Speed, ...)` verwendet bei `Speed=nil` den generischen `GetSpeedCruise()`-Wert. Für den nächsten Full-Response-Test wird deshalb explizit gesetzt:

```text
CH47_TRANSIT_SPEED_KTS = 125
```

Die 125 kt sind eine Owner-gewählte Acceptance-/Verbandstransit-Baseline für den Jalalabad-Wright-Pfad. Sie ist keine globale Änderung des MOOSE-Hubschrauberdefaults.

### 9.2 Fly-by-/Lead-Turn-Approximation

`FLIGHTGROUP:AddWaypoint()` erzeugt im gepinnten MOOSE-Stand Air-`TurningPoint`-Waypoints. Eine öffentliche `SetLeadTurnDistance`-/`FlyByDistance`-API wurde im gepinnten MOOSE-Stand nicht gefunden.

Die bounded MOOSE-first Approximation verwendet daher ausschließlich öffentliche MOOSE-Geometrie:

```text
configured PATHLINE coordinates
-> for each relevant interior corner:
   point 250 m before corner, bounded to <=25% inbound leg
   point 250 m after corner, bounded to <=25% outbound leg
-> omit exact corner vertex for that turn
-> FLIGHTGROUP:AddWaypoint(..., 125 kt, ..., TurningPoint)
-> UpdateRoute()
```

Implementiert mit:

```text
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)
COORDINATE:GetIntermediateCoordinate(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:UpdateRoute()
```

Grenzen:

```text
requested lead turn: 250 m
minimum applied trim: 50 m
maximum per leg: 25%
minimum heading change: 5 deg
first and last route coordinate remain exact
```

Das ist **STAGED / noch nicht DCS-validiert**. Der nächste Lauf muss zeigen, ob die Flugbahn tatsächlich weniger eckig wirkt und ob die Route weiterhin zuverlässig abgeflogen wird.

Outbound:

```text
OPSTRANSPORT OnAfterTransport
-> configured FlightPath outbound
-> 125-kt smoothed TurningPoint sequence
-> UpdateRoute
```

Return:

```text
OPSTRANSPORT Delivered
-> configured FlightPath reverse
-> 125-kt smoothed TurningPoint sequence
-> UpdateRoute
-> Jalalabad
```

## 11. Externe Slingload-Entwicklung

Bis zu einer neuen ausdrücklichen Owner-Entscheidung:

```text
NO external slingload development
NO NewCARGOTRANSPORT target path
NO PauseMission/TaskDone slingload handoff
NO CargoTransportation lifecycle bridge
```

## 12. Offline-/Build-Gate vor DCS

Vor einem neuen DCS-Lauf müssen mindestens erfüllt sein:

```text
MissionDemand CI: PASS
Documentation validation: PASS
full-response Lua syntax: PASS
full-response source contains corrected CAS support-state contract
full-response source contains OPSTRANSPORT/STORAGE path
full-response source contains no old direct incident->CAS closure
full-response source contains no tactical RED-count CAS gate
full-response source contains no NewCARGOTRANSPORT/PauseMission/CargoTransportation handoff
configured FlightPath is logical-name based
CH-47 explicit speed = 125 kt
lead-turn profile = 250 m via public MOOSE COORDINATE/FLIGHTGROUP APIs
builder static checks reject obsolete paths
local builder succeeds
local GitCommit equals remote target commit
builder SHA256 equals independent Get-FileHash SHA256
MizMutation: false
```

## 13. DCS-Acceptance-Gate

### Guard / QRF

```text
Guard materializes and follows OMW_RTE_BLUE_GUARD_HONAKER_01
mixed QRF materializes, engages as applicable, returns, PersonnelLedger settles
```

### CAS

```text
Jalalabad -> configured FlightPath -> WEST -> AO at explicit 125 kt
CAS_ON_STATION observed
CAS_SENSOR_REPORT observed
CAS_NO_CONTACT_REPORTED only after 30-second stable own sensor picture
real CAS_ENGAGE_EVENT and/or EVENTS.Shot as applicable
Honaker local incident may close without directly closing CAS
if AH-64 still detects eligible contacts after Honaker local closure: CAS stays active and may continue engagement
only Honaker no-known-attackers + CAS on-station stable own no-contact permits normal supported-element release
configured reverse corridor observed
Jalalabad landing observed
AIRWING/LEGION asset return observed
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
CH-47 configured outbound route physically flown near 125-kt command profile
lead-turn geometry appears smoother without route-cutting failure
Wright OPSTRANSPORT/STORAGE delivery succeeds
configured reverse route physically flown with same profile
Jalalabad landing
AIRWING/LEGION recovery
Wright final strategic AMMO = 30
Jalalabad final strategic AMMO = 85
```

Nur ein realer Lauf mit vollständiger Branch-/Commit-/Bundle-/Mission-/DCS-/MOOSE-Provenienz darf den Status ändern.


## 14. Build 1-22 – regressionskorrektur nach realem 1-21-Lauf

Der reale Lauf mit Build 1-21 ist **kein PASS**. Seine beobachtete Fehlerevidenz ist verbindlich für die Korrektur:

```text
CAS: nach vollständiger Bekämpfung kreiste die AH-64 weiter bis Bingo/FuelLow;
anschließend erfolgte ein direkter statt kontrollierter Rückflug.
Route: Waypoint UID=3 erschien erneut als eigener, ungeeigneter Gebirgspunkt.
ARTY: drei 4-Schuss-Missionen wurden physisch ausgelöst (300 -> 296 -> 292 -> 288);
eine wiederholte Zielzuordnung und der schwankende Momentwert 288 -> 291 lösten
fälschlich PHYSICAL_AMMO_UNCHANGED aus. Der daraus entstandene globale FAIL
unterband die weitere CAS-Lifecycle-Auswertung und damit den Restock-Pfad.
```

Build 1-22 stellt den bereits DCS-abgenommenen Stage-2B-Vertrag wieder her:

```text
kein SetMissionIngressCoord()/SetMissionEgressCoord() für diesen CAS-Auftrag
bestehender Pre-Mission-Waypoint
-> owner-authored OMW_FlightPath/WEST outbound Waypoints
-> PATROLZONE mission waypoint
-> owner-authored reverse waypoints
-> normaler MOOSE RTB/Landing
route readiness ausschließlich über FLIGHTGROUP:OnAfterUpdateRoute
```

Die ARTY-Abnahme zählt nicht mehr eine Momentaufnahme aus `ARTY:GetAmmo()` als
einzigen Schussbeweis. Der gepinnte MOOSE-ARTY-Handler verarbeitet `EVENTS.Shot`
für die Batterie; mindestens ein zielkorrelierter `WRIGHT_ARTY_EVENTS_SHOT`
ist die physische Fire-Evidence. Ammo-Snapshots bleiben Telemetrie. Bereits
eingeplante C2-Zielgruppen werden nicht erneut eingeplant; neue Feueraufträge
bleiben ab physischem CAS On Station gesperrt.

Ein Acceptance-FAIL stoppt zudem keine unabhängige physische CAS-Recovery-
Beobachtung mehr. Er bleibt sichtbar und verhindert PASS, aber die
supported-element-gesteuerte CAS-Freigabe kann ihre Reverse-Route und
Jalalabad-Rückkehr weiterhin ausführen.

Vor dem nächsten DCS-Lauf zusätzlich prüfen:

```text
BuilderVersion = STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-22
kein MISSION_OWNED_CORRIDOR-6 Marker im Bundle
CAS_CORRIDOR_PENDING_MOOSE_ROUTE_CALLBACK oder Stage-2B-Korridorinstallation sichtbar
WRIGHT_ARTY_EVENTS_SHOT sichtbar, sofern Wright feuert
kein wiederholter C2-Quellgruppenname innerhalb einer ARTY-Fire-Cycle
```


## 15. Build 1-22 gesperrt – dynamische OMW-CAS-Geometrie wiederherstellen

**Status: NICHT ZU BAUEN ODER IN DCS ZU TESTEN.**

Die im Build-1-22-Source vorgenommene Rückkehr zum allgemeinen Stage-2B-
Korridor erfüllt nicht die für Honaker vereinbarte OMW-owned taktische
Geometrie. Sie wird deshalb nicht als Korrektur akzeptiert.

Der verbindliche Zielvertrag lautet:

```text
Jalalabad -> R500 -> WEST
-> pro CAS-Mission dynamisch abgeleiteter CAS_INGRESS
   (Abzweig von WEST, ca. 3–4 NM vor Honaker)
-> pro CAS-Mission dynamisch abgeleiteter CAS_MISSION_POINT / BP
-> pro CAS-Mission dynamisch abgeleiteter CAS_EGRESS
-> WEST reverse -> R500 reverse -> Jalalabad
```

CAS_INGRESS, CAS_MISSION_POINT/BP und CAS_EGRESS sind **keine statischen
Mission-Editor-Marker**. OMW leitet sie je Allocation deterministisch aus der
festgelegten Transitroute, Honaker/AO und der taktischen Achse ab und übergibt
sie als Owner-Entscheidung über die öffentlichen MOOSE-Missionsparameter.
MOOSE darf diese Geometrie weder aus `resolved.outbound[1]`, einer
PATHLINE-Nähe noch selbständig erzeugen. Der gegebene Wert muss später mit
Route, Höhe und Achse als Evidenz geloggt werden.

Die nächste Implementierung hat MOOSE ausschließlich für AUFTRAG, FLIGHTGROUP,
Tasking, EngageDetected und AIRWING-Lifecycle zu verwenden. Die Geometrie
bleibt OMW-owned.
