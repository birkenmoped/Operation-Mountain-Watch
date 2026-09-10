---
document_id: OMW-HANDOFF-STAGE3-OPSTRANSPORT-CURRENT-STATE-2026-09-07
status: PLANNED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local current-state handoff for Stage 3 focused CAS and Air-AMMO resupply
  - current OPSTRANSPORT architecture and source-review findings
  - exact local build provenance before the pending DCS acceptance
  - continuation instructions for a new chat
not_authoritative_for:
  - repository-wide architecture before merge to main
  - DCS runtime validation of the current OPSTRANSPORT path
  - production CampaignState settlement for Air-AMMO resupply
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
base_commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
pull_request: 144
supersedes:
  - OMW-HANDOFF-STAGE3-BUILD-1-17-NEW-CHAT-2026-09-05
superseded_by:
---

# Übergabe – Stage 3 CAS / Air-AMMO OPSTRANSPORT – 07.09.2026

## 1. Zweck

Diese Übergabe dokumentiert den aktuellen Arbeitsstand nach der erneuten MOOSE-first-Reconciliation des CH-47-Air-AMMO-Pfads. Sie ersetzt für die unmittelbare Fortsetzung die Übergabe vom 05.09.2026, ohne deren historische DCS-Nachweise zu löschen.

Der nächste Chat soll **nicht** aus der früheren CARGOTRANSPORT-/Slingload-Handoff-Architektur weiterentwickeln. Zuerst sind Governance, aktueller Branch, `main`-Divergenz, gepinnter MOOSE-Stand und diese Übergabe zu prüfen.

Aktueller Status:

```text
focused OPSTRANSPORT source design: SOURCE_REVIEWED
focused local bundle build/hash: VERIFIED_LOCAL_BUILD
current OPSTRANSPORT DCS runtime: NOT VALIDATED
full Stage 3: NOT VALIDATED
```

## 2. Pflichtlektüre vor Fortsetzung

Mindestens:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/moose/STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE.md
mission/tests/stage3-cas-resupply-focused/README.md
```

Für MOOSE-Nachweise zusätzlich:

```text
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
```

Bei Widersprüchen gilt die Autoritätshierarchie aus `docs/00-project-governance.md`.

## 3. Git-/PR-Stand

Repository:

```text
birkenmoped/Operation-Mountain-Watch
```

Arbeitsbranch:

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

Lokaler Worktree des Projektinhabers:

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
```

Pull Request:

```text
#144
state: OPEN
mode: DRAFT
base: agent/fire-support-strategic-resupply-closure
base commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
```

Der PR bleibt DRAFT. Kein Ready-for-Review und kein Merge ohne erfolgreichen exakten DCS-Acceptance-Lauf und ausdrückliche Eigentümerfreigabe.

Unmittelbar vor Erstellung dieser Übergabe war der Remote-Branch nach der Statusdokumentation auf:

```text
07a644eb5b85a8e843ae6d3d7fa86d6150243061
```

Der Handoff-Commit selbst liegt danach. Vor weiterer Arbeit ist der reale aktuelle Remote-HEAD erneut zu lesen.

## 4. Aktueller `main`-Abgleich

Am 07.09.2026 wurde `main` erneut geprüft:

```text
main HEAD: a4a99a384e6c4ee9297226af6f0a0dd697ecc4e6
merge base: 10789637d009a664a6e65b633d3df8a35f8d5117
branch vs main: diverged
branch ahead: 225 commits at pre-status-doc HEAD 071587a5...
branch behind: 11 commits
```

Die seit dem Merge-Base auf `main` relevanten Änderungen umfassen insbesondere:

```text
docs/00-project-governance.md
docs/45-air-c2-cas-afghanistan.md
docs/77-arsof-sof-aviation-and-early-oef-operational-models.md
docs/ground/ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md
```

Nicht blind rebasen oder mergen. Vor neuer Architekturarbeit zuerst prüfen, ob `main` inzwischen eine neuere verbindliche Entscheidung enthält.

## 5. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Online-Dokumentation allein ist kein Verfügbarkeitsbeweis. Für Signaturen, Rückgaben, FSM-Reihenfolge und Nebenwirkungen ist die tatsächlich gepinnte `Moose.lua` maßgeblich.

## 6. Entscheidende fachliche Klarstellung des Projektinhabers

Für den aktuellen Air-AMMO-Resupply ist **sichtbarer Slingload sekundär**. Das primäre Ziel lautet:

```text
Munition Jalalabad
-> per CH-47 schneller als Convoy
-> über den vorgesehenen Flugkorridor
-> nach Wright
-> dort in Warehouse/Store geliefert
-> CH-47 zurück nach Jalalabad
```

Damit ist nicht „Slingload ermöglichen“ das Kernproblem. MOOSE besitzt seit langem Cargo-/Slingload-Funktionalität. Das eigentliche Problem war die Wahl des falschen Transportcontrollers und die Routenintegration.

## 7. Offizielle MOOSE-Demo als Architekturbeleg

Der Projektinhaber identifizierte die offizielle Demo:

```text
Ops/Transport/Transport - 051 - COMBINED By All Means/
Transport - 051 - COMBINED By All Means.lua
```

Der zentrale Demo-Vertrag ist:

```lua
local transport=OPSTRANSPORT:New(CargoSet, zonePickup, zoneDeploy)

local Mi26=FLIGHTGROUP:New("Mi-26 Alpha-1")
Mi26:Activate()

Mi26:AddOpsTransport(transport)
```

Die Demo weist denselben `OPSTRANSPORT` mehreren Carrier-Arten zu und verwendet `AddPathTransport(...)` für Transportpfade. Damit ist source-/demo-seitig klar:

```text
OPSTRANSPORT = Transportauftrag/FSM
FLIGHTGROUP = Helicopter-Carrier
AddOpsTransport = Carrier-Zuweisung
AddPathTransport = Transportpfad-Mechanismus
```

Die frühere Annahme, ein eigener CARGOTRANSPORT-Handoff sei notwendig, wird für den aktuellen fokussierten Air-AMMO-Test nicht weiterverfolgt.

## 8. Aktuelle CH-47-Architektur

Der neue fokussierte Pfad verwendet MOOSE `OPSTRANSPORT` mit `STORAGE`-Cargo:

```text
OPSTRANSPORT:New(nil, PickupZone, DeployZone)
-> AddCargoStorage(StorageFrom, StorageTo, CargoType, Amount, ItemWeight)
-> SetRequiredCarriers(1,1)
-> LEGION.RecruitCohortAssets(... AUFTRAG.Type.OPSTRANSPORT ...)
-> AddAsset(asset)
-> AIRWING:TransportAssign(transport, legions)
-> MOOSE loading
-> MOOSE transport
-> MOOSE unloading
-> MOOSE Delivered
```

Acceptance-Fixture:

```text
Cargo type: ENUMS.Storage.weapons.bombs.Mk_82
Amount: 4
Item weight: 230 kg
Total weight: 920 kg
Source STORAGE static: OMW_STAGE3_OPSTRANSPORT_SOURCE_STORAGE_001
Destination STORAGE static: OMW_STAGE3_OPSTRANSPORT_WRIGHT_STORAGE_001
Pickup zone: ZON_BLUE_LOG_SLG_JALALABAD_01
Deploy zone: OMW_BLUE_LZ_WRIGHT_01
```

Die Mk-82-Fixture ist ausschließlich ein reproduzierbarer MOOSE-STORAGE-Transfer-Test. Sie ist **keine** produktive OMW-Munitionsbestandsentscheidung und ersetzt CampaignState nicht.

## 9. Verifizierte MOOSE-Lücke für Wright-Feld-LZ

`OPSTRANSPORT:AddPathTransport(...)` existiert. Im gepinnten Source wird dieser Transportpfad für `FLIGHTGROUP`-Carrier im implementierten Airbase-Zielpfad verwendet. Wright ist dagegen eine normale Feld-LZ-Zone.

Deshalb existiert die kleine MOOSE-nahe Ergänzung:

```text
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
```

Sie benutzt ausschließlich öffentliche MOOSE-APIs:

```text
OnAfterTransport
-> GetWaypointCurrentUID
-> AddWaypoint R500 outbound
-> UpdateRoute

OnAfterDelivered
-> GetWaypointCurrentUID
-> AddWaypoint R500 reverse
-> UpdateRoute
```

Sie besitzt **keine** Cargo-/Delivery-Autorität und erzeugt keinen eigenen Transport-FSM.

Nicht mehr Bestandteil des aktuellen fokussierten Pfads:

```text
AUFTRAG:NewCARGOTRANSPORT
PauseMission
TaskCancel-based handoff
native CargoTransportation waypoint task
OnBeforeUnpauseMission guard
manual delivery monitor
manual AUFTRAG Success
```

## 10. Wichtige Source-Details

### 10.1 `LEGION.RecruitCohortAssets` Rückgabe

`Legions` ist nach `asset.legion.alias` indiziert und keine numerische Lua-Liste:

```lua
Legions[asset.legion.alias] = asset.legion
```

Deshalb ist `#legions` falsch. Der aktuelle Acceptance-Code iteriert mit `pairs()` und verlangt genau einen Eintrag, der dem Jalalabad-AIRWING entspricht.

### 10.2 Delivered-/Return-Reihenfolge

Source-geprüft:

```text
OPSTRANSPORT:onafterDelivered
-> carrier:Delivered(self)

OPSGROUP:onafterDelivered
-> schedules _CheckGroupDone after 0.2 s
```

Der uppercase `OnAfterDelivered`-Userhook läuft nach dem Framework-Handler. Der R500-Return-Adapter kann deshalb die Rückroute vor dem verzögerten `_CheckGroupDone` einsetzen. Das bleibt bis zum DCS-Lauf `SOURCE_REVIEWED`, nicht `VALIDATED`.

### 10.3 Frühere Auto-Unpause-Diagnose korrigiert

Die frühere Root-Cause-Zuordnung

```text
_CheckGroupDone auto-unpause -> MissionDone before physical delivery
```

wurde im Focus-1-4-Lauf nicht bestätigt. Der instrumentierte `OnBeforeUnpauseMission`-Marker trat nicht auf, obwohl der CARGOTRANSPORT-Pfad erneut vor physischer Lieferung endete.

Daher:

```text
Auto-unpause als konkrete Focus-1-4 Root Cause: FALSIFIED_FOR_FOCUS_1_4_RUNTIME
allgemeine Existenz des MOOSE auto-unpause source path: SOURCE_CONFIRMED
```

Nicht wieder die alte Guard-/Pause-Architektur weiterpatchen.

## 11. Aktuelle Dateien

```text
mission/tests/stage3-cas-resupply-focused/src/02-stage3-cas-resupply-opstransport-acceptance.lua
mission/tests/stage3-cas-resupply-focused/README.md
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
scripts/air-operations/OMW_AirOps_Jalalabad_Bootstrap.lua
tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
tests/mission-demand/test_focused_cas_resupply_fixture_contract.lua
docs/moose/STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE.md
```

Historische CARGOTRANSPORT-/Slingload-Dateien bleiben Evidenz, sind aber nicht der aktuelle fokussierte Ausführungspfad.

## 12. Aktueller lokaler Build – exakt dokumentiert

Der Projektinhaber hat am 07.09.2026 real lokal gebaut:

```text
Worktree: P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
Branch: agent/fire-support-strategic-resupply-alarm-evidence
GitCommit: 071587a507bfd34e394dad0ee4b1c41c455d3770
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-6
TestId: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1
GeneratedUtc: 2026-09-07T18:38:10Z
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Builder SHA256: 193801A95EEFD58C0C978C5FEF83097F582D51EF53D93AD8925BAD003E202F40
Independent Get-FileHash SHA256: 193801A95EEFD58C0C978C5FEF83097F582D51EF53D93AD8925BAD003E202F40
MizMutation: false
```

Der erste direkte PowerShell-Aufruf scheiterte wegen lokaler Execution Policy. Der danach angezeigte alte Dist-Hash

```text
3410B4149FD5C4786887F019AB95080EF4AE05407DDA3DB1BBC47653AB4D45DB
```

ist **nicht** die Provenienz des aktuellen Builds. Erst der erfolgreiche Aufruf mit `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` erzeugte das oben dokumentierte Bundle.

Lokal waren vor dem Pull mehrere `dist/`-Verzeichnisse untracked. Das ist erwartbarer Build-Output und kein dokumentierter Source-Diff.

## 13. CI-/Offline-Status

Für den vor dem lokalen Build gepullten Commit `071587a507bfd34e394dad0ee4b1c41c455d3770` waren die GitHub-Workflows erfolgreich:

```text
Documentation validation: SUCCESS
MissionDemand validation: SUCCESS
```

Die MissionDemand-CI bestätigte dabei unter anderem Lua-Syntax des fokussierten Stage-3-Acceptance-Skripts und die MissionDemand-Contract-Tests.

CI und lokaler Build ersetzen keinen DCS-Test.

## 14. CAS-Status

Der fokussierte CAS-Pfad bleibt unabhängig vom RESUPPLY-Pfad und verwendet weiterhin:

```text
AUFTRAG:NewCAS
SetMissionIngressCoord
SetMissionEgressCoord
SetMissionWaypointRandomization(0)
SetEngageDetected
SetROE(ENUMS.ROE.OpenFire)
SetROT(ENUMS.ROT.PassiveDefense)
```

Sollroute:

```text
Jalalabad
-> R500 @ 500 ft AGL
-> WEST @ 2500 ft AGL
-> ingress
-> CAS
-> egress
-> WEST reverse
-> R500 reverse
-> Jalalabad
```

Ein historischer Focus-Lauf bestätigte diese Kette. Spätere Läufe zeigten aber erneut Terrain-/Route-Following-Probleme; ein Apache erreichte die AO nicht, flog nach gescheitertem Geländeanflug rückwärts und kollidierte mit dem Gelände. Das darf nicht als RPG-Verlust umgedeutet werden.

Der aktuelle OPSTRANSPORT-Umbau erklärt dieses CAS-Terrainproblem nicht als gelöst.

## 15. Nächster Schritt – genau ein fokussierter DCS-Lauf

Kein weiterer Architekturumbau vor dem nächsten DCS-Lauf, sofern nicht bereits vor Missionsstart ein reproduzierbarer Source-/Buildfehler gefunden wird.

Für RESUPPLY beobachten:

```text
1. genau ein Jalalabad CH-47 wird rekrutiert/bereitgestellt
2. OPSTRANSPORT beginnt
3. MOOSE lädt den Storage-Cargo
4. R500 outbound wird eingesetzt
5. CH-47 fliegt R500 tatsächlich nach Wright
6. source STORAGE 4 -> 0
7. destination STORAGE 0 -> 4
8. OPSTRANSPORT erreicht Delivered
9. R500 reverse wird eingesetzt und tatsächlich geflogen
10. CH-47 landet physisch in Jalalabad
11. AIRWING bestätigt LegionAssetReturned danach
```

Für CAS parallel beobachten:

```text
spawn/dispatch
R500 outbound
WEST outbound
AO/weapon employment
release
egress
WEST reverse
R500 reverse
Jalalabad landing/AIRWING recovery
```

Ein Fehler in CAS darf RESUPPLY nicht stoppen und umgekehrt.

## 16. Was nach dem DCS-Lauf benötigt wird

Vom Projektinhaber:

```text
dcs.log
debrief.log, falls vorhanden
kurze Sichtbeobachtung des CH-47 und AH-64
```

Beim CH-47 insbesondere:

```text
startet er?
fliegt er R500 outbound?
erreicht er Wright?
was tut er dort: landen / schweben / weiterfliegen?
wird Delivered gemeldet?
fliegt er R500 reverse?
erreicht/landet er Jalalabad?
```

Danach Log/FSM chronologisch gegen den gepinnten MOOSE-Source auswerten. Keine Ursache behaupten, die der Log nicht trägt.

## 17. Entscheidungsgrenzen

Weiterhin nicht automatisch erlaubt:

```text
MOOSE-Version wechseln
native DCS-Transport-/Routinglogik neu einführen
CampaignState durch STORAGE ersetzen
PR #144 Ready setzen oder mergen
.miz automatisch mutieren
MissionScripting.lua ändern
```

Eine neue Nicht-MOOSE-/Native-DCS-Ausnahme benötigt weiterhin die ausdrückliche Eigentümerfreigabe.
