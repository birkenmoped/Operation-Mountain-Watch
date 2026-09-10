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
source_commit: b092f8cc0f6505f43a868a35741d03d95f30cfd9
validated_in_dcs: false
---

Verbindliche CAS-Verträge: [`OMW-MOOSE-STAGE3-CAS-LIFECYCLE-RECOVERY-LAW`](../../../docs/moose/STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md) und [`OMW-MOOSE-STAGE3-CAS-TACTICAL-CORRIDOR`](../../../docs/moose/STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md). Ein Build oder DCS-Lauf darf weder Lifecycle- noch Geometrie-Regression-Gates umgehen.

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## 1. Status

Dieser Acceptance-Test bleibt **PLANNED / nicht DCS-validiert**.

## 1.1 DCS-Lauf 2026-09-10 – Build 1-26 (teilvalidierte Runtime-Evidenz)

**Keine Gesamtfreigabe:** Der Teststatus bleibt `PLANNED`, weil weder ein terminaler Acceptance-PASS noch ein AH-64-`EVENTS.Shot`/Engage-Nachweis in diesem Full-Response-Lauf vorliegt.

Exakte Artefaktkette des gestarteten Laufs:

```text
Source commit:       b092f8cc0f6505f43a868a35741d03d95f30cfd9
BuilderVersion:      STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-26
MOOSE commit:        73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:   E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
embedded bundle SHA: 33CEB7AA6BC7FA833CCF456C41B689245B0CB70BD587AF533D0071A92B346661
MIZ mutation:        false
```

Im DCS-Log positiv belegt:

```text
CAS_ROUTE_GATES_DERIVED: OMW_FlightPath_R200 -> OMW_FlightPath_WEST,
  routegebundene dynamische Gates, 3.50 NM, ingress index 27, egress index 10
CAS queued -> Mission executing -> MOOSE route callback -> corridor installed
AH-64 physically ON STATION
FLIGHTGROUP:GetDetectedGroups(): 0 eligible contacts
30 s stable own no-contact -> explizite supported-element release
controlled reverse recovery -> Jalalabad landing -> AIRWING/LEGION asset return
```

Kein Waffenpfad ist daraus abzuleiten: C2 hatte beim Alarm noch 13 RED-Gruppen; ARTY hatte das beobachtete Zielbild vor CAS-On-Station auf null reduziert. Deshalb fand die AH-64 eigene Detektion keine zulässigen Ziele. Es gab **keine** Zielinjektion und kein `KnowTarget()`; dies ist ein korrekter No-Contact-Zweig, aber kein CAS-Engagement-Nachweis.

Offene, separat zu behandelnde Beobachtung: Die ARTY-Rearm-Follow-up-Logik erzeugte mehrere `FIRE_SUPPORT_REARMED_CONTINUATION`-Zyklen auf dasselbe C2-Zielbild. Dieses Verhalten ist weder als allgemeine ARTY-Policy abgenommen noch Bestandteil eines Gesamt-PASS. Der nächste gezielte Lauf muss (a) bei Ankunft des CAS noch ein eigenes detektierbares Zielbild vorhalten und (b) die ARTY-Continuation über Kontaktfrische/Cooldown oder eine explizite Policy begrenzen.

Historische Fehltests bis einschließlich der externen Slingload-/CARGOTRANSPORT-Versuche bleiben als Evidenz erhalten. Der reale Build-1-19-Lauf bestätigte getrennt Guard, QRF, ARTY und den internen CH-47-OPSTRANSPORT-Pfad, war aber wegen der veralteten CAS-Closure nicht als Gesamt-PASS gültig.

Aktueller Builderstand:

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-26
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

## 14. Final-DCS-Gate – Build 1-23

**Status: PLANNED / NOT_RUN.** Dieser Abschnitt ersetzt die aufgehobenen Build-1-22-Anweisungen vollständig. Er ist der einzige zulässige Abschlusstest für den aktuellen Branch-Stand, bis ein Ergebnisbericht mit vollständiger Artefaktkette vorliegt.

### 14.1 Exakter Testgegenstand

```text
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-26
TestId:         STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
MOOSE commit:   73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA:  E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
MIZ mutation by builder: false
```

Der Test ist eine **Honaker/Wright/Jalalabad-Testfixture**. Seine konkrete AH-64-Bindung, 125 kt, 2.500 ft AGL, 5-NM-Zone, 30-Sekunden-No-Contact und 3,5-NM-Routengates sind keine allgemeine CAS-Policy. Die allgemeingültigen Grenzen stehen im CAS-Lifecycle-/Recovery-Gesetz.

### 14.2 Unbedingte statische Freigabe

Vor dem DCS-Start muss der lokale Builder ohne Ausnahme belegen:

```text
Git HEAD = im Bundle-Header genannter GitCommit
BuilderVersion = 1-23
MOOSE commit und Moose.lua SHA entsprechen Abschnitt 2
Builder SHA256 = unabhängiger Get-FileHash SHA256
MizMutation: false
```

Zusätzlich müssen die bestehenden Builder-Guards PASS ergeben. Der Lauf wird nicht gestartet, wenn der Builder einen alten Slingload-Pfad, KnowTarget-Injection, CASENHANCED, direkte Incident-/RED-Count-CAS-Closure oder einen der im Builder gesperrten Native-DCS-Pfade meldet.

### 14.3 MIZ-Transfer- und Objektvertragsgate

Der Builder verändert keine MIZ. Vor der Testausführung muss deshalb die tatsächlich gestartete MIZ erneut und unabhängig nachgewiesen werden:

```text
MIZ SHA-256
interner mission-SHA-256
eingebetteter Acceptance-Bundle-SHA-256 = lokaler Bundle-SHA-256
eingebetteter Moose.lua-SHA-256 = gepinnter Moose.lua-SHA-256
Moose.lua lädt vor dem Acceptance-Bundle
keine ältere parallele Stage-3-Test-Lua aktiv
Objektvertragssmoke nach dem letzten MIZ-Speichern
```

Der Objektvertragssmoke umfasst mindestens Jalalabad AIRBASE/Warehouse, Jalalabad AH-64- und CH-47-Templates, Honaker-Alarm-/CAS-/Access-Zonen, Wright L118/M1083 und die verwendeten FlightPath-/WEST-PATHLINEs. Fehlt einer dieser Nachweise, ist das Ergebnis INVALID, nicht FAIL und nicht PASS.

### 14.4 Ein gebündelter DCS-Lauf

Der Lauf verwendet genau das in Abschnitt 14.3 nachgewiesene Bundle und prüft die folgenden unabhängigen Evidenzketten:

| Kette | erforderliche positive Evidenz |
|---|---|
| Alarm/Guard/QRF | Honaker-Alarm; Guard-Route; QRF-ONGUARD; QRF bleibt bis zur expliziten CAS-Freigabe aktiv |
| CAS Dispatch/Ingress | MOOSE PATROLZONE + SetEngageDetected; konkrete FlightGroup; 125-kt-Default; dynamische, route-gebundene Ingress-/AO-/Egress-Knoten; kein freier Gebirgswegpunkt |
| CAS Engagement/Release | eigene GetDetectedGroups()-Evidenz; CAS_ON_STATION; bei vorhandenem Kontakt Fortsetzung; No-Contact erst nach 30 s stabil; erst dann explizite Supported-Element-Freigabe |
| CAS Recovery | Egress, WEST reverse, FlightPath reverse, Landung Jalalabad und AIRWING:OnAfterLegionAssetReturned |
| ARTY/C2 | mindestens ein zielkorrelierter physischer Wright-ARTY-Schuss; keine neue ARTY-Mission ab CAS On Station; laufende Feueraufträge nicht künstlich abgebrochen |
| Rearm/Resupply | M1083-Rearm und Rückkehr; genau ein Demand; genau ein CH-47-OPSTRANSPORT; STORAGE delivery; Rückflug; CH-47-Landung und AIRWING-/LEGION-Rückgabe |
| Bestand | nach bestätigter Delivery Wright = 30 und Jalalabad = 85 strategische AMMO-Packages |

Ein beobachteter CAS-FuelLow-/Bingo-Direktrückflug, ein Kreisflug nach gültiger Release, eine fehlende AIRWING-/LEGION-Rückgabe oder ein nicht-routegebundener künstlicher Wegpunkt ist ein **FAIL**. Ein fehlender Startnachweis, fehlende Artefaktkette oder eine unklare parallele Lua ist **INVALID**.

### 14.5 Erforderliche Testunterlagen

Nach dem Lauf wird ein Ergebnisbericht angelegt. Er enthält mindestens:

```text
Klassifikation: PASS | PASS_WITH_LIMITATION | PARTIAL | FAIL | INVALID
Branch und GitCommit
BuilderVersion, Bundlepfad und Bundle-SHA-256
MIZ-Dateiname und MIZ-SHA-256
interner mission-SHA-256
DCS-Version
MOOSE-Commit und Moose.lua-SHA-256
DCS-Log- und Debrief-SHA-256
Zeitfenster des Laufs
eindeutige Log-/Telemetriebelege für jede Kette aus 14.4
Abweichungen und offene Grenzen
```

Erst ein solcher Ergebnisbericht darf diesen Acceptance-Status von PLANNED verändern. Ein fehlerfreier Build beweist ausschließlich die statische Vorbedingung; er ist kein DCS-PASS.
