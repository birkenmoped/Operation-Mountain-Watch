---
document_id: OMW-MOOSE-STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE
status: PLANNED
document_class: MOOSE_IMPLEMENTATION_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 AH-64 CAS route and execution acceptance
  - focused Stage 3 CH-47 Air-AMMO resupply acceptance
  - historical focused 2026-09-05 DCS evidence
  - correction of the falsified CARGOTRANSPORT auto-unpause diagnosis
  - current MOOSE OPSTRANSPORT STORAGE transport design for Wright
  - configurable FlightPath name/offset contract in the focused acceptance
  - 2026-09-07 rejected Focus-1-6 fixture run
  - removal of IncidentParticipants as tactical completion evidence in this acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – Focused CAS + Air-AMMO Resupply Acceptance

## 1. Zweck und Scope

Dieser Acceptance-Pfad isoliert zwei voneinander unabhängige Ausführungspfade:

```text
AH-64 CAS
CH-47 Air-AMMO resupply
```

Bewusst ausgeschlossen:

```text
Guard
QRF
ARTY
CampaignState strategic accounting
```

Ein Fehler eines Teilpfads darf den anderen Teilpfad nicht unterdrücken. Acceptance-Beobachtung darf keine künstliche Runtime-Voraussetzung erzeugen.

Für strategische Ressourcen gilt weiterhin die aktuelle Governance auf `main`: CampaignState ist die persistente strategische Autorität, MOOSE besitzt den physischen Runtime-Lifecycle. Die in dieser Acceptance verwendete MOOSE-STORAGE-Fixture ist ausschließlich Testmaterial und keine produktive Ressourcenbuchhaltung.

## 2. MOOSE-Basis

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die tatsächlich verwendete `Moose.lua` ist für Signaturen, Zustandsübergänge und Nebenwirkungen maßgeblich.

## 3. Historischer Rejected-Run 1-1

Der erste fokussierte Lauf ist `REJECTED`.

```text
Git commit: 31fb168b12dd893ed94ba71155a7edf86043e69d
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-1
Bundle SHA256: 9ABAED9388293DF31A201DE0F2C334BF384F3CCB8B3FB6B3FB9CC2DF938643D4
MizMutation: false
```

Der Acceptance-Fixture enthielt einen erfundenen Typ-Gate auf `cargo:GetID() == number`, obwohl der gepinnte MOOSE-Wrapper die ID als String liefert. Zusätzlich setzte ein gemeinsamer `state.failed` beide unabhängigen Teilpfade außer Betrieb.

Verbindlicher Fixture-Vertrag:

```text
CAS failure      != stop RESUPPLY
RESUPPLY failure != stop CAS
observation      != invented runtime prerequisite
```

## 4. CAS – bestehender Focus-Pfad

Der CAS-Pfad verwendet weiterhin:

```text
AUFTRAG:NewCAS
SetMissionIngressCoord
SetMissionEgressCoord
SetMissionWaypointRandomization(0)
SetEngageDetected
SetROE(ENUMS.ROE.OpenFire)
SetROT(ENUMS.ROT.PassiveDefense)
```

Aktuelle Acceptance-Geometrie:

```text
Jalalabad
-> configured OMW_FlightPath[_Rnnn/_Lnnn] @ 500 ft AGL
-> OMW_FlightPath_WEST @ 2500 ft AGL
-> explicit ingress
-> Honaker CAS
-> explicit egress
-> WEST reverse
-> configured FlightPath reverse
-> Jalalabad
```

Der Basename `OMW_FlightPath` ist die logische Routenidentität. `_Rnnn` beziehungsweise `_Lnnn` kodiert ausschließlich den seitlichen Offset und darf nicht als feste Routenidentität behandelt werden.

Die Acceptance-Freigabe erfolgt testbedingt 90 Sekunden nach dem ersten real bestätigten AH-64-Waffeneinsatz. Das ist kein Produktionskriterium.

Nicht zulässig als CAS-/Gefechtsabschluss:

```text
IncidentParticipants == 0
KNOWN_ATTACKERS_NEUTRALIZED
OPSZONE Defeated allein
Alarmzonen-Ausgang allein
```

### Historischer Focus-1-2-Befund

Der damalige reale Lauf bestätigte im dokumentierten Stand:

```text
AH-64 dispatch Jalalabad
R500 outbound
WEST outbound
CAS attack
real weapon employment
acceptance release
WEST reverse
R500 reverse
Jalalabad landing
AIRWING recovery
```

Spätere Läufe zeigten jedoch erneut ein AH-64-Terrain-/Route-Following-Problem. Insbesondere erreichte ein Apache die AO nicht, konnte einen folgenden Geländerücken nicht überwinden, flog anschließend rückwärts und kollidierte mit dem Gelände. Dieser Verlust wird nicht als RPG-bedingte Root Cause klassifiziert. Die aktuelle Acceptance darf das bekannte CAS-Terrainproblem daher nicht als behoben darstellen.

## 5. Historischer CH-47-CARGOTRANSPORT-Pfad

Der frühere Pfad lautete:

```text
AUFTRAG:NewCARGOTRANSPORT
-> physical external slingload pickup Jalalabad
-> PauseMission / source task release
-> R500 outbound handoff
-> native CargoTransportation waypoint task
-> intended physical Wright delivery
-> intended AUFTRAG Success
-> R500 reverse
-> Jalalabad
```

Dieser Pfad bestätigte wiederholt Pickup und Teile des R500-Routings, erreichte aber keine belastbare physische Wright-Ablieferung.

### Focus 1-2

```text
Git commit: b0b862cc0a51e478ef8210dff426727b1cb3071e
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-2
Bundle SHA256: BDB15116D7761B621831BC2D7075FA0820DEA186371DED787556723BED9B019B
Mission: OMW_Template_v21_GroundWorks_RadioPresets_v1.7(2).miz
Mission SHA256: 569A22453588FBE9950BBEC78A29F7002F017AF64BB96C47B75FEC8ED096B900
DCS: 2.9.29.27468 MT
MizMutation: false
```

Bestätigt:

```text
physical pickup
cargo/drop identity preserved
PauseMission requested
source CargoTransportation task released
external slingload survived TaskCancel/TaskDone
R500 route installed and flown
```

Nicht bestätigt:

```text
physical Wright delivery
```

### Focus 1-3

```text
Git commit: 7063cee05307c3f3aeb959fd9c0ab896fcfb66c6
BuilderVersion: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-3
Bundle SHA256: FED684961B5DC0988A5893168849615F37515FC53611D4671E18D2E2DFE3E6C6
Mission: OMW_Template_v21_GroundWorks_RadioPresets_v1.8.miz
DCS: 2.9.29.27468 MT
MizMutation: false
```

Beobachtet wurde:

```text
PauseMission -> mission executing / group paused
original TaskDone -> current mission/task cleared while paused mission remained
UpdateRoute -> paused mission remained
T+1/T+2/T+3/T+5 -> paused mission remained
later -> MissionDone before physical Wright delivery
```

Die gepinnte MOOSE-Quelle zeigt zwar einen `_CheckGroupDone()`-Pfad, der eine allein verbleibende pausierte Mission automatisch unpausieren kann. Aus Focus 1-3 allein war jedoch **nicht** bewiesen, dass genau dieser interne Pfad den beobachteten `MissionDone` ausgelöst hatte.

## 6. Korrektur der früheren Auto-Unpause-Diagnose

Die frühere Dokumentation wertete die Kombination aus Source-Möglichkeit und Focus-1-3-Lauf zu stark und bezeichnete Auto-Unpause faktisch als Ursache. Das war nicht ausreichend belegt.

Focus 1-4 instrumentierte deshalb den regulären MOOSE-FSM-Hook `OnBeforeUnpauseMission` mit dem eindeutigen Marker:

```text
BLOCKED_AUTO_UNPAUSE_BEFORE_PHYSICAL_DELIVERY
```

Im realen Focus-1-4-Lauf trat dieser Marker **nicht** auf. Es gab keinen beobachteten `UnpauseMission`-Versuch vor dem Fehler. Trotzdem wechselte der CARGOTRANSPORT-Auftrag später auf `MissionDone` und endete vor physischer Ablieferung.

Damit gilt:

```text
Hypothese: _CheckGroupDone auto-unpauses CARGOTRANSPORT und verursacht MissionDone
Status: FALSIFIED_FOR_FOCUS_1_4_RUNTIME
```

Zulässig bleibt ausschließlich die allgemein source-verifizierte Aussage:

```text
FLIGHTGROUP:_CheckGroupDone besitzt einen Auto-Unpause-Pfad für verbleibende pausierte Missionen.
```

Nicht mehr zulässig ist die Behauptung, dieser Pfad habe den realen Focus-1-4-Fehler verursacht.

Der `OnBeforeUnpauseMission`-Guard löste das reale Delivery-Problem nicht und wird im neuen Acceptance-Pfad nicht weiterverwendet.

## 7. MOOSE-first Reconciliation: OPSTRANSPORT STORAGE

Die erneute MOOSE-Prüfung ergab einen passenderen vorhandenen Framework-Pfad für strategischen Air-AMMO-Transport: `OPSTRANSPORT` kann `STORAGE`-Bestände direkt transportieren.

Der gepinnte Source bestätigt:

```text
OPSTRANSPORT:New(nil, PickupZone, DeployZone)
OPSTRANSPORT:AddCargoStorage(StorageFrom, StorageTo, CargoType, CargoAmount, CargoWeight)
OPSTRANSPORT:SetRequiredCarriers(Nmin, Nmax)
LEGION.RecruitCohortAssets(... AUFTRAG.Type.OPSTRANSPORT ...)
OPSTRANSPORT:AddAsset(asset)
AIRWING:TransportAssign(transport, legions)
```

Für Waffen und Equipment muss das Stückgewicht explizit angegeben werden, weil es nicht aus der DCS-API ermittelt werden kann.

Der MOOSE-Lifecycle besitzt selbst Storage-Cargo-Zustände und führt Source-Abbuchung, Carrier-Cargo-Bay, Transport, Unloading und Destination-Zubuchung aus. OMW implementiert diese Logik nicht parallel.

### Acceptance-STORAGE-Fixture

```text
Cargo type: ENUMS.Storage.weapons.bombs.Mk_82
Amount: 4
Item weight: 230 kg
Total weight: 920 kg
Source static: OMW_STAGE3_OPSTRANSPORT_SOURCE_STORAGE_001
Destination static: OMW_STAGE3_OPSTRANSPORT_WRIGHT_STORAGE_001
Pickup: ZON_BLUE_LOG_SLG_JALALABAD_01
Deploy: OMW_BLUE_LZ_WRIGHT_01
```

Die Mk-82-Auswahl dient nur einem eindeutig messbaren MOOSE-STORAGE-Transfer. Sie legt keinen produktiven Munitionsbestand fest.

## 8. Carrier-Recruitment – verifizierter Tabellenvertrag

`LEGION.RecruitCohortAssets(...)` hat im gepinnten Source die Signatur:

```text
Cohorts,
MissionTypeRecruit,
MissionTypeOpt,
NreqMin,
NreqMax,
TargetVec2,
Payloads,
RangeMax,
RefuelSystem,
CargoWeight,
TotalWeight,
MaxWeight,
Categories,
Attributes,
Properties,
WeaponTypes,
RangeMin
```

Die Rückgabe `Legions` ist keine numerische Liste. MOOSE schreibt:

```lua
Legions[asset.legion.alias] = asset.legion
```

Daher ist `#legions` für diesen Rückgabewert falsch. Der fokussierte Test iteriert die Tabelle mit `pairs()` und prüft genau einen rekrutierten Carrier-Legion-Eintrag, der dem Jalalabad-AIRWING entsprechen muss.

## 9. Wright-Feld-LZ und kleinster Routing-Adapter

`OPSTRANSPORT:AddPathTransport(...)` ist vorhanden. Im gepinnten MOOSE-Stand wird dieser Transportpfad für FLIGHTGROUP-Carrier jedoch nur im implementierten Airbase-Zielpfad übernommen. Wright ist eine normale Feld-LZ-Zone.

Deshalb ergänzt `OMW_OpsTransportCorridorAdapter.lua` ausschließlich die fehlende Feld-LZ-Routengeometrie über öffentliche MOOSE-APIs:

```text
OnAfterTransport
-> FLIGHTGROUP:GetWaypointCurrentUID()
-> FLIGHTGROUP:AddWaypoint(... configured FlightPath outbound ...)
-> FLIGHTGROUP:UpdateRoute()

OnAfterDelivered
-> FLIGHTGROUP:GetWaypointCurrentUID()
-> FLIGHTGROUP:AddWaypoint(... configured FlightPath reverse ...)
-> FLIGHTGROUP:UpdateRoute()
```

Source-verifiziert ist außerdem die Insert-Semantik: `AddWaypoint(..., AfterWaypointWithID, ...)` ermittelt `GetWaypointIndexAfterID()` und `_AddWaypoint()` führt `table.insert(self.waypoints, index, waypoint)` aus. Die konfigurierten FlightPath-Punkte werden damit tatsächlich hinter der angegebenen UID und vor dem bisher folgenden Waypoint in die MOOSE-Route eingefügt.

Der Adapter übernimmt **nicht**:

```text
Cargo ownership
loading/unloading
delivery completion
OPSTRANSPORT state
native DCS Controller tasking
Pause/Unpause lifecycle
```

## 10. FlightPath-Namensvertrag und MOOSE-Grenze

Der gemeinsame Corridor-Code kann den Offset bereits aus `_Rnnn`/`_Lnnn` parsen. Focus-1-6 behandelte jedoch fälschlich den vollständigen Namen `OMW_FlightPath_R500` als unveränderliche Routenidentität.

Verbindlicher Acceptance-Vertrag:

```text
logical route identity: OMW_FlightPath
accepted configured names:
  OMW_FlightPath
  OMW_FlightPath_R<meters>
  OMW_FlightPath_L<meters>
```

`OMW_FlightPath_WEST` ist ein separates Segment und darf nicht als konfigurierte Primärroute erkannt werden.

Der gepinnte MOOSE-Source bestätigt `PATHLINE:FindByName(Name)` nur als exakte Namensauflösung. Eine öffentliche PATHLINE-Wildcard- oder Enumerationsfunktion wurde nicht gefunden. Für den **Acceptance-/Validierungsfall** liest der Fixture deshalb genau einmal `_DATABASE.PATHLINES`, um den realen owner-konfigurierten Primärnamen auszuwählen. Diese Nutzung bleibt `INTERNAL_RESTRICTED`, ist keine Produktionsarchitektur und übernimmt keine DCS- oder MOOSE-Lifecycle-Funktion.

Bei null oder mehreren passenden Primärpathlines bricht die Acceptance eindeutig ab. Es gibt keine stille Priorisierung.

Regressionen prüfen mindestens:

```text
OMW_FlightPath_R200 -> RIGHT 200 m
OMW_FlightPath_R500 -> RIGHT 500 m
OMW_FlightPath_L350 -> LEFT 350 m
OMW_FlightPath      -> CENTER 0 m
OMW_FlightPath_WEST -> kein Primärmatch
multiple matches    -> explicit ambiguity failure
```

## 11. Delivered -> Return-Reihenfolge

Der gepinnte MOOSE-Source zeigt:

```text
OPSTRANSPORT:onafterDelivered
-> carrier:Delivered(self)

OPSGROUP:onafterDelivered
-> carrier status Delivered
-> _CheckGroupDone scheduled after 0.2 s
```

MOOSE-FSM ruft den lowercase Framework-Handler vor dem uppercase User-Callback auf. Der OMW-`OnAfterDelivered`-Callback kann daher unmittelbar nach dem Framework-Handler den konfigurierten FlightPath reverse einfügen, bevor der verzögert geplante `_CheckGroupDone` ausgeführt wird.

Das ist **SOURCE_REVIEWED**, noch kein DCS-Laufzeitbeweis.

## 12. Historischer lokaler Buildstand 1-6 – 07.09.2026

Der Projektinhaber hatte den fokussierten OPSTRANSPORT-Build lokal aus dem vorgesehenen Worktree erzeugt und den Bundle-Hash unmittelbar danach unabhängig erneut ermittelt.

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

Der erste direkte Buildversuch wurde durch die lokale PowerShell Execution Policy abgewiesen. Der dabei anschließend angezeigte ältere Dist-Hash `3410B4149FD5C4786887F019AB95080EF4AE05407DDA3DB1BBC47653AB4D45DB` ist **kein Hash dieses Builds** und darf nicht als Provenienz verwendet werden. Der erfolgreiche Build wurde danach explizit mit `powershell.exe -NoProfile -ExecutionPolicy Bypass -File ...` ausgeführt.

## 13. Rejected Focus-1-6 Runtime – 07.09.2026

Der reale DCS-Lauf des 1-6-Fixtures ist `REJECTED_TEST_FIXTURE` und **kein** OPSTRANSPORT-Runtime-Fail.

```text
DCS: 2.9.29.27468 MT
Mission: OMW_Template_v22_GroundWorks.miz
Mission SHA256: A06B69A459ADF69AC7047EA7F446DCB1EE5B88F80EE04A45DAB01EA26107088C
DCS log SHA256: 8F933330C9515069C84B846D7DFFD4EA2412D8D38C7F952982765EA64259C25E
Debrief SHA256: 2CBC07B92CB466E7A73171F2A344ABEF92FEF60B98A4A121B5B12E390069C3E5
BuilderVersion under test: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-6
Bundle SHA256: 193801A95EEFD58C0C978C5FEF83097F582D51EF53D93AD8925BAD003E202F40
```

MOOSE registrierte real:

```text
OMW_FlightPath_R200
OMW_FlightPath_WEST
```

Der Fixture verlangte dagegen den hart codierten Namen `OMW_FlightPath_R500` und meldete:

```text
[STAGE3 FOCUSED][FATAL] missing OMW_FlightPath_R500
```

Root Cause:

```text
Acceptance treated configurable PATHLINE suffix as fixed route identity.
```

Damit wurden weder der aktuelle CH-47-OPSTRANSPORT-Pfad noch das aktuelle CAS-Terrainverhalten erreicht. Aus diesem Lauf darf keine Aussage über Wright-Delivery, `Delivered`, Return oder AIRWING-Recovery abgeleitet werden.

## 14. Aktuelle Dateien

```text
mission/tests/stage3-cas-resupply-focused/src/02-stage3-cas-resupply-opstransport-acceptance.lua
mission/tests/stage3-cas-resupply-focused/README.md
scripts/air-operations/OMW_FlightPathNameContract.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
scripts/air-operations/OMW_AirOps_Jalalabad_Bootstrap.lua
tools/build-stage3-cas-resupply-focused-acceptance-1.ps1
tests/mission-demand/test_flightpath_name_contract.lua
tests/mission-demand/test_focused_cas_resupply_fixture_contract.lua
```

Generiertes Bundle:

```text
mission/tests/stage3-cas-resupply-focused/dist/OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua
```

## 15. Nächster Build und DCS-Nachweis

Der korrigierte Builder ist:

```text
STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-7
```

Ein realer lokaler 1-7-Build und dessen SHA-256 existieren noch nicht. Nach Pull muss der Projektinhaber den Builder im vorgesehenen Worktree ausführen und die echte Konsolenausgabe einschließlich Hash zurückmelden.

Der nächste reale Lauf muss für RESUPPLY beobachten:

```text
configured FlightPath name/offset logged
exactly one Jalalabad CH-47 recruited
OPSTRANSPORT executing
configured FlightPath outbound inserted and physically flown
source STORAGE 4 -> 0
destination STORAGE 0 -> 4
OPSTRANSPORT Delivered
configured FlightPath reverse inserted and physically flown
physical Jalalabad landing
AIRWING LegionAssetReturned after landing
```

CAS bleibt parallel und unabhängig zu beobachten:

```text
Jalalabad -> configured FlightPath -> WEST -> ingress -> CAS -> egress -> WEST reverse -> configured FlightPath reverse -> Jalalabad
```

Bis zu einem dokumentierten DCS-Lauf gilt:

```text
OPSTRANSPORT STORAGE design: SOURCE_REVIEWED
Focus-1-6 runtime: REJECTED_TEST_FIXTURE
Focus-1-7 source fix: STAGED / DCS PENDING
Wright storage delivery: NOT VALIDATED
configured FlightPath reverse after Delivered: NOT VALIDATED
current CAS terrain behavior: NOT VALIDATED
full Stage 3: NOT VALIDATED
```