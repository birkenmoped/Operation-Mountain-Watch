---
document_id: OMW-STAGE3-CAS-RESUPPLY-FOCUSED-README
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - focused Stage 3 CAS and OPSTRANSPORT resupply test scope
  - source-reviewed OPSTRANSPORT STORAGE acceptance observations
  - configurable FlightPath naming contract for the focused acceptance
  - 2026-09-07 rejected Focus-1-6 fixture run
not_authoritative_for:
  - DCS runtime validation before the documented acceptance run passes
  - production CampaignState resource accounting
  - final Stage 3 combined acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 CAS + Air-AMMO Resupply – Focused Acceptance

Status: **SOURCE_REVIEWED / DCS pending**

Diese fokussierte Acceptance trennt den bereits bestehenden AH-64-CAS-Pfad vom neu reconcilierten CH-47-Air-AMMO-Resupply-Pfad. Ein Fehler eines Teilpfads darf die reale MOOSE-Ausführung des anderen Teilpfads nicht unterdrücken.

## Verwendeter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Maßgeblich ist die tatsächlich verwendete `Moose.lua`, nicht allein die Online-Dokumentation.

## FlightPath-Namensvertrag

Die primäre FlightPath-Linie besitzt eine stabile logische Identität und eine veränderbare Konfiguration im Mission-Editor-Namen:

```text
OMW_FlightPath          = logische Route
_R200                   = 200 m rechts
_R500                   = 500 m rechts
_L350                   = 350 m links
```

Beispiele:

```text
OMW_FlightPath_R200
OMW_FlightPath_R500
OMW_FlightPath_L350
```

Der Offset-Suffix ist **nicht** Teil der fachlichen Routenidentität. Eine Änderung von `R500` auf `R200` darf daher weder CAS noch RESUPPLY deaktivieren.

Der gemeinsame Corridor-Code interpretiert `_Rnnn`/`_Lnnn` bereits über `PATHLINE_SUFFIX`. Der Focus-1-6-Fixture verletzte diesen Vertrag jedoch, weil er `OMW_FlightPath_R500` als exakten Namen hart codiert hatte.

Der korrigierte Acceptance-Pfad verwendet deshalb:

```text
logical base: OMW_FlightPath
configured runtime name: genau ein OMW_FlightPath oder OMW_FlightPath_[RL]<meter>
secondary segment: OMW_FlightPath_WEST
```

MOOSE 2.9.18 stellt `PATHLINE:FindByName()` nur für exakte Namen bereit; eine öffentliche Wildcard-/Enumerationsmethode für PATHLINEs wurde im gepinnten Source nicht gefunden. Die Acceptance liest daher **einmalig und ausschließlich zur Validierung** `_DATABASE.PATHLINES`, um den owner-konfigurierten Namen zu bestimmen. Geometrie und Routing bleiben MOOSE-PATHLINE-basiert. Das ist keine produktive Ressourcen- oder Transportautorität.

Mehrere gleichzeitig passende primäre FlightPaths gelten als Konfigurationsfehler und führen zu einem eindeutigen Ambiguity-Fail statt zu stiller Auswahl.

## Rejected Focus-1-6 – 07.09.2026

Der reale Lauf mit `OMW_Template_v22_GroundWorks.miz` ist **REJECTED_TEST_FIXTURE**. Er beweist keinen Fehler des OPSTRANSPORT-Pfads.

Provenienz:

```text
DCS: 2.9.29.27468 MT
Mission: OMW_Template_v22_GroundWorks.miz
Mission SHA256: A06B69A459ADF69AC7047EA7F446DCB1EE5B88F80EE04A45DAB01EA26107088C
DCS log SHA256: 8F933330C9515069C84B846D7DFFD4EA2412D8D38C7F952982765EA64259C25E
Debrief SHA256: 2CBC07B92CB466E7A73171F2A344ABEF92FEF60B98A4A121B5B12E390069C3E5
BuilderVersion under test: STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-6
Bundle SHA256 from the documented local build: 193801A95EEFD58C0C978C5FEF83097F582D51EF53D93AD8925BAD003E202F40
```

MOOSE registrierte real:

```text
OMW_FlightPath_R200
OMW_FlightPath_WEST
```

Der Fixture brach anschließend ab mit:

```text
[STAGE3 FOCUSED][FATAL] missing OMW_FlightPath_R500
```

Root Cause:

```text
Acceptance treated configurable _Rnnn/_Lnnn suffix as fixed PATHLINE identity.
```

Nicht getestet wurden dadurch:

```text
CH-47 recruitment
OPSTRANSPORT executing
STORAGE loading/unloading
Wright delivery
Delivered -> return
Jalalabad recovery
current CAS terrain behavior
```

## Resupply-Architektur

Der frühere fokussierte Pfad mit `AUFTRAG:NewCARGOTRANSPORT`, `PauseMission()`, einem nativen DCS-`CargoTransportation`-Waypoint-Task und einem eigenen Delivery-Monitor wird für diese Acceptance nicht weiterverwendet. Der Focus-1-4-Lauf hat die zuvor angenommene Auto-Unpause-Ursache nicht bestätigt; der `OnBeforeUnpauseMission`-Guard wurde nicht ausgelöst, obwohl die Mission vor physischer Lieferung endete. Die frühere Auto-Unpause-Diagnose ist daher für diesen Lauf falsifiziert und darf nicht als Root Cause weitergeführt werden.

Der neue Pfad verwendet MOOSE `OPSTRANSPORT` für den kompletten Storage-Transport-Lifecycle:

```text
OPSTRANSPORT:New(nil, PickupZone, DeployZone)
-> AddCargoStorage(StorageFrom, StorageTo, CargoType, Amount, ItemWeight)
-> LEGION.RecruitCohortAssets(... AUFTRAG.Type.OPSTRANSPORT ...)
-> OPSTRANSPORT:AddAsset(asset)
-> AIRWING:TransportAssign(transport, legions)
-> MOOSE pickup/loading/transport/unloading/delivery
```

Für den Acceptance-Nachweis wird eine **temporäre MOOSE-STORAGE-Fixture** verwendet:

```text
Resource: ENUMS.Storage.weapons.bombs.Mk_82
Amount: 4
Item weight: 230 kg
Total: 920 kg
Source: ZON_BLUE_LOG_SLG_JALALABAD_01
Destination: OMW_BLUE_LZ_WRIGHT_01
```

Diese Mk-82-Fixture ist ausschließlich ein reproduzierbarer Storage-Transfer-Test und **keine** produktive OMW-Munitionsbestandsentscheidung. CampaignState ist in dieser fokussierten Acceptance ausdrücklich nicht angebunden. Damit wird die auf `main` verbindliche Regel nicht geändert, dass CampaignState die strategische Ressourcenautorität bleibt und MOOSE den physischen Runtime-Lifecycle ausführt.

## Source-verifizierte MOOSE-Verträge

Im gepinnten Source wurden für diesen Pfad geprüft:

- `PATHLINE:FindByName(Name)` löst exakt einen Namen über die MOOSE-Datenbank auf;
- `DATABASE.PATHLINES` enthält die von MOOSE registrierten Mission-Editor-Pathlines; der direkte Zugriff bleibt auf diesen Acceptance-Discovery-Fall beschränkt;
- `OPSTRANSPORT:New(nil, PickupZone, DeployZone)` für Storage-Transporte;
- `OPSTRANSPORT:AddCargoStorage(...)` einschließlich explizitem Stückgewicht für Waffen/Equipment;
- `OPSTRANSPORT:SetRequiredCarriers(...)`;
- `LEGION.RecruitCohortAssets(...)` mit `CargoWeight` und `TotalWeight`;
- Rückgabe `Legions` als nach `asset.legion.alias` indizierte Tabelle; daher wird **nicht** `#legions` verwendet;
- `AIRWING:TransportAssign(...)` für die bereits rekrutierten Carrier-Assets;
- `LEGION:onafterAssetSpawned(...)` erstellt zuerst `asset.flightgroup`; anschließend kann der öffentliche `OnAfterAssetSpawned`-Callback darauf zugreifen;
- `OPSTRANSPORT:onafterDelivered(...)` informiert Carrier über `carrier:Delivered(self)`;
- `OPSGROUP:onafterDelivered(...)` plant danach `_CheckGroupDone(0.2)`;
- MOOSE-FSM ruft den lowercase Framework-Handler vor dem uppercase User-Callback auf. Der `OnAfterDelivered`-Adapter läuft damit nach dem Framework-Handler, aber vor dem verzögerten `_CheckGroupDone`;
- `FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)` fügt über `GetWaypointIndexAfterID()` und `_AddWaypoint()` tatsächlich direkt hinter der angegebenen Waypoint-UID ein.

## Verifizierte MOOSE-Lücke für Wright

`OPSTRANSPORT:AddPathTransport(...)` ist vorhanden. Im gepinnten MOOSE-Stand wird ein Transportpfad für `FLIGHTGROUP`-Carrier jedoch nur in dem dort implementierten Airbase-Zielpfad übernommen. Wright ist eine normale Feld-LZ-Zone. Deshalb bleibt für diesen Zieltyp die kleine OMW-Ergänzung erforderlich.

`scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua` darf ausschließlich öffentliche FLIGHTGROUP-Routing-APIs verwenden:

```text
OnAfterTransport
-> GetWaypointCurrentUID()
-> AddWaypoint(... configured FlightPath outbound ...)
-> UpdateRoute()

OnAfterDelivered
-> GetWaypointCurrentUID()
-> AddWaypoint(... configured FlightPath reverse ...)
-> UpdateRoute()
```

Der Adapter besitzt weder Cargo- noch Delivery-State. Er verwendet keinen nativen DCS-Controller, keinen `PauseMission()`-Eingriff und keinen eigenen Transport-FSM.

## Acceptance-Beobachtung

Im nächsten DCS-Lauf sind für RESUPPLY zu beobachten und zu dokumentieren:

```text
1. Der konfigurierte primäre FlightPath wird mit realem Namen und Offset geloggt.
2. Genau ein Jalalabad-CH-47 wird als OPSTRANSPORT-Carrier bereitgestellt.
3. MOOSE beginnt den OPSTRANSPORT-Lifecycle.
4. Der konfigurierte FlightPath outbound wird nach Beginn des Transportabschnitts eingefügt und tatsächlich geflogen.
5. Der Source-STORAGE-Bestand wechselt von 4 auf 0.
6. Der Wright-STORAGE-Bestand wechselt von 0 auf 4.
7. OPSTRANSPORT erreicht Delivered.
8. Der konfigurierte FlightPath reverse wird nach Delivered eingefügt und tatsächlich geflogen.
9. CH-47 landet physisch in Jalalabad.
10. AIRWING bestätigt anschließend LegionAssetReturned.
```

Für CAS bleibt unabhängig zu beobachten:

```text
Jalalabad -> configured FlightPath -> WEST -> MOOSE ingress -> CAS -> egress -> WEST reverse -> configured FlightPath reverse -> Jalalabad
```

Die bekannte AH-64-Terrain-/Route-Following-Frage wird durch den Resupply-Umbau nicht als gelöst erklärt und darf den CH-47-Teilpfad nicht blockieren.

## Nächster Build

Die Korrektur ist im Builder als

```text
STAGE3-CAS-RESUPPLY-FOCUSED-ACCEPTANCE-1-7
```

gestaged. Der reale lokale Build und dessen SHA-256 müssen nach dem Pull im vorgesehenen Worktree neu erzeugt und vom Projektinhaber zurückgemeldet werden. Bis dahin existiert **kein** lokaler 1-7-Buildnachweis.

## Noch nicht validiert

Bis zum realen DCS-Test gilt insbesondere **nicht** als bestätigt:

- tatsächliche CH-47-Bewegung über den konfigurierten FlightPath im neuen OPSTRANSPORT-Pfad;
- tatsächliches Be-/Entladen der Storage-Fixture in DCS;
- Reihenfolge `Delivered -> configured FlightPath reverse -> regulärer AIRWING-RTB` im Runtime-Verhalten;
- physische Jalalabad-Landung und anschließendes `LegionAssetReturned` für diesen neuen Transportpfad;
- CAS-Terrainverhalten des aktuellen Focus-Bundles.

Ein `VALIDATED`- oder `PASS`-Status darf erst nach dokumentiertem DCS-Lauf mit Mission-, Bundle-, Git-, DCS- und MOOSE-Provenienz vergeben werden.