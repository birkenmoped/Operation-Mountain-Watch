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
- `FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)` fügt über `GetWaypointIndexAfterID()` und `_AddWaypoint()` tatsächlich direkt hinter der angegebenen Waypoint-UID ein. Mehrere aufeinanderfolgende Einfügungen mit der jeweils neu erzeugten UID erhalten ihre Reihenfolge und liegen vor dem vorherigen Folge-Waypoint.

## Verifizierte MOOSE-Lücke für Wright

`OPSTRANSPORT:AddPathTransport(...)` ist vorhanden. Im gepinnten MOOSE-Stand wird ein Transportpfad für `FLIGHTGROUP`-Carrier jedoch nur in dem dort implementierten Airbase-Zielpfad übernommen. Wright ist eine normale Feld-LZ-Zone. Deshalb bleibt für diesen Zieltyp die kleine OMW-Ergänzung erforderlich.

`scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua` darf ausschließlich öffentliche FLIGHTGROUP-Routing-APIs verwenden:

```text
OnAfterTransport
-> GetWaypointCurrentUID()
-> AddWaypoint(... R500 outbound ...)
-> UpdateRoute()

OnAfterDelivered
-> GetWaypointCurrentUID()
-> AddWaypoint(... R500 reverse ...)
-> UpdateRoute()
```

Der Adapter besitzt weder Cargo- noch Delivery-State. Er verwendet keinen nativen DCS-Controller, keinen `PauseMission()`-Eingriff und keinen eigenen Transport-FSM.

## Acceptance-Beobachtung

Im DCS-Lauf sind für RESUPPLY zu beobachten und zu dokumentieren:

```text
1. Genau ein Jalalabad-CH-47 wird als OPSTRANSPORT-Carrier bereitgestellt.
2. MOOSE beginnt den OPSTRANSPORT-Lifecycle.
3. R500 outbound wird nach Beginn des Transportabschnitts eingefügt und tatsächlich geflogen.
4. Der Source-STORAGE-Bestand wechselt von 4 auf 0.
5. Der Wright-STORAGE-Bestand wechselt von 0 auf 4.
6. OPSTRANSPORT erreicht Delivered.
7. R500 reverse wird nach Delivered eingefügt und tatsächlich geflogen.
8. CH-47 landet physisch in Jalalabad.
9. AIRWING bestätigt anschließend LegionAssetReturned.
```

Für CAS bleibt unabhängig zu beobachten:

```text
Jalalabad -> R500 -> WEST -> MOOSE ingress -> CAS -> egress -> WEST reverse -> R500 reverse -> Jalalabad
```

Die bekannte AH-64-Terrain-/Route-Following-Frage wird durch den Resupply-Umbau nicht als gelöst erklärt und darf den CH-47-Teilpfad nicht blockieren.

## Noch nicht validiert

Bis zum realen DCS-Test gilt insbesondere **nicht** als bestätigt:

- tatsächliche CH-47-Bewegung über R500 im neuen OPSTRANSPORT-Pfad;
- tatsächliches Be-/Entladen der Storage-Fixture in DCS;
- Reihenfolge `Delivered -> R500 reverse -> regulärer AIRWING-RTB` im Runtime-Verhalten;
- physische Jalalabad-Landung und anschließendes `LegionAssetReturned` für diesen neuen Transportpfad;
- CAS-Terrainverhalten des aktuellen Focus-Bundles.

Ein `VALIDATED`- oder `PASS`-Status darf erst nach dokumentiertem DCS-Lauf mit Mission-, Bundle-, Git-, DCS- und MOOSE-Provenienz vergeben werden.
