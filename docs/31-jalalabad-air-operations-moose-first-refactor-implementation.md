# Jalalabad Air Operations – MOOSE-first Refactoring Implementation

Stand: 2026-07-25  
Branch: `feature/jalalabad-airwing-phase1-functional-tests`  
BuilderVersion: `JBAD-AIR-OPS-PHASE1-11-MOOSE-FIRST`  
MOOSE-Pin: `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`  
Status: **IMPLEMENTED / LOCAL BUILD AND DCS VALIDATION PENDING**

## 1. Anlass

Das Code-Review in `docs/29-jalalabad-air-operations-moose-code-review.md` hat ergeben, dass wesentliche Teile der Phase-1-Laufzeitsteuerung MOOSE-Funktionalität duplizierten oder MOOSE-interne Tabellen direkt auswerteten.

Die daraus entstandenen Fehler waren nicht auf einen einzelnen Auftrag begrenzt. Betroffen waren:

- Mission Queue und Bestandszählung;
- Zuordnung dynamischer AIRWING-Spawns;
- Missionserfolg und Terminalzustände;
- Cargo-Aufnahme und Cargo-Abgabe;
- Asset-Freigabe;
- Routing-Korrekturen;
- nachgelagerte Lua-Override-Ketten.

Dieses Refactoring setzt die im Review geforderte Arbeitsteilung um:

```text
MOOSE verwaltet:
  AUFTRAG-/OPSTRANSPORT-Zustände
  AIRWING-/SQUADRON-Assets
  Mission Queue
  FLIGHTGROUP-Zuordnung
  Cargo Loading/Unloading/Delivery
  Transport-Carrier-Rekrutierung

Operation Mountain Watch verwaltet:
  ORBAT und Paketvertrag
  Parking- und Namensverträge
  taktisch sinnvolle Routen
  unabhängige physische Abnahme
  Watchdog und Ergebnisdokumentation
```

## 2. Ersetzte Eigenentwicklungen

### 2.1 Mission Queue

Entfernt:

```lua
cfg.Airwing.missionqueue
```

Verwendet:

```lua
AIRWING:CountMissionsInQueue()
```

Die Queue wird nicht mehr durch Iteration einer internen MOOSE-Tabelle gezählt.

### 2.2 SQUADRON-Bestand und Reservierungen

Entfernt:

```lua
squadron.assets
asset.requested
asset.spawned
asset.isReserved
```

Verwendet:

```lua
SQUADRON:CountAssets(nil)
SQUADRON:CountAssets(true)
SQUADRON:CountAssets(false)
AIRWING:CountAssetsOnMission(nil, squadron)
```

Der OMW-Code führt keine eigene operative Asset-Datenbank mehr. Snapshots dienen nur noch Abnahme und Diagnose.

### 2.3 Runtime-Gruppensuche und Namensrekonstruktion

Entfernt:

```text
mission.groupdata
opsgroup.groupname
opsgroup.group
wiederholte Suche nach AID-Präfixen
provisorische typbasierte Zuordnung
```

Verwendet:

```lua
AIRWING:OnAfterFlightOnMission(..., flightgroup, mission)
OPSTRANSPORT:GetCarriers()
```

Das konkrete `FLIGHTGROUP`-Objekt wird direkt von MOOSE übernommen. Gruppen- und Einheitennamen bleiben Assertions gegen den Paketvertrag; sie sind nicht mehr die primäre Objektquelle.

### 2.4 Parallele Missions-FSM

Entfernt wurden die operativen Eigenzustände und nachträglichen Terminalkorrekturen aus den bisherigen Dateien `14a`, `14b`, `16`, `17`, `18`, `19` und `20`.

Verwendet:

```text
AUFTRAG:
  Queued
  Requested
  Scheduled
  Started
  Executing
  Done
  Success
  Failed
  Cancel

OPSTRANSPORT:
  Queued
  Requested
  Scheduled
  Executing
  Loaded
  Unloaded
  Delivered
  Cancel
```

Der verbleibende Controller besitzt keine zweite operative SUCCESS-/FAILED-/CANCELLED-FSM. Er dispatcht das native MOOSE-Objekt, überwacht einen Timeout und klassifiziert den Test anhand nativer Zustände plus unabhängiger DCS-Beobachtung.

### 2.5 Missionserfolg

Verwendet werden native AUFTRAG-Bedingungen:

```lua
AUFTRAG:AddConditionSuccess(...)
```

Beispiele:

- AH-64D CAS: Zielgruppe zerstört;
- CH-47 Sling Cargo: Static befindet sich in der Drop-Zone.

Entfernt wurden:

```text
runtime.ObjectiveCheck
MarkObjectiveDrivenSuccess
post-hoc Umdeutung von FAILED/CANCELLED/DONE
```

### 2.6 FLIGHTGROUP-Lifecycle

MOOSE liefert das konkrete FLIGHTGROUP. Objektgebunden beobachtet werden:

- Engine Startup;
- Takeoff;
- Land;
- Engine Shutdown;
- Crash/Dead;
- RTB;
- native Cargo-Completion-Events.

Globale Event-Suche und anschließende Namensheuristik wurden entfernt. DCS-Ereignisse bleiben nur als unabhängige physische Abnahme innerhalb der bereits von MOOSE gebundenen Gruppe.

## 3. Generische MOOSE-native Logistikarchitektur

Die neue Datei

```text
mission/tests/jalalabad-air-operations/src/12a-phase1-moose-logistics.lua
```

ist nicht UH-60-spezifisch. Sie ist der gemeinsame Adapter für alle aktuellen und geplanten Transport-/Logistikprofile.

### 3.1 GROUP_CARGO

Anwendungsfälle:

- Infanterie;
- Fahrzeuggruppen;
- andere OPSGROUP-Cargos.

Native Autorität:

```lua
OPSTRANSPORT:New(cargoGroup, pickupZone, deployZone)
OPSTRANSPORT:SetRequiredCarriers(...)
OPSTRANSPORT:SetRequiredCargos(...)
```

Native Transportereignisse:

```text
OPSTRANSPORT Loaded
OPSTRANSPORT Unloaded
OPSTRANSPORT Delivered
```

Native Carrier-Ereignisse:

```text
FLIGHTGROUP/OPSGROUP LoadingDone
FLIGHTGROUP/OPSGROUP UnloadingDone
```

Zusätzliche OMW-Abnahme:

- Carrier landet in der konfigurierten Pickup-Zone;
- exakt erwartetes Cargoobjekt wird geladen;
- Carrier landet in der konfigurierten Deploy-Zone;
- exakt erwartetes Cargoobjekt wird entladen;
- Cargo lebt in der Deploy-Zone;
- `GetNcargoDelivered() == GetNcargoTotal()`.

Der UH-60-TROOPTRANSPORT verwendet dieses Profil.

### 3.2 STORAGE_CARGO

Anwendungsfälle:

- Treibstoff;
- Waffen;
- Ausrüstung;
- DCS-Warehouse-/STORAGE-Transfer.

Native Autorität:

```lua
OPSTRANSPORT:New(nil, pickupZone, deployZone)
OPSTRANSPORT:AddCargoStorage(storageFrom, storageTo, cargoType, amount, itemWeight)
```

Carrier werden nicht über eigene Tabellen ausgewählt, sondern mit der nativen MOOSE-Rekrutierung:

```lua
LEGION.RecruitCohortAssets(...)
AIRWING:TransportAssign(...)
```

Der Auftrag kann einen Carrier-SQUADRON vorgeben, zum Beispiel CH-47 für schwere Logistik. Ein optionaler projektspezifischer `VerifyDelivered`-Callback darf den tatsächlichen STORAGE-Zuwachs prüfen. Die operative Transportausführung verbleibt vollständig bei OPSTRANSPORT.

### 3.3 STATIC_SLING_CARGO

Anwendungsfall:

- slingload-fähiges Static Cargo, aktuell der CH-47-Test.

Native Autorität:

```lua
AUFTRAG:NewCARGOTRANSPORT(cargoStatic, deployZone)
AUFTRAG:AddConditionSuccess(...)
```

Für Static-Sling-Cargo erzeugt MOOSE keinen OPSTRANSPORT-Gruppen-Cargo-Lifecycle. Deshalb werden hier nicht künstlich `Loaded`-/`Unloaded`-Events erfunden. Maßgeblich sind der native AUFTRAG-Zustand und die physische Position des Static in der Drop-Zone.

### 3.4 STATIC_FREIGHT_CARGO

Anwendungsfall:

- interne statische Fracht über `AUFTRAG:NewFREIGHTTRANSPORT`.

Native Autorität:

```text
AUFTRAG FREIGHTTRANSPORT
AUFTRAG native mission callbacks
```

Dieses Profil ist im gemeinsamen Vertrag vorgesehen. Eine konkrete Mission wird erst angelegt, wenn ein passendes Missionseditor-Frachtobjekt definiert ist.

### 3.5 DYNAMIC_CARGO

Anwendungsfall:

- DCS Dynamic Cargo.

Native MOOSE-Ereignisse:

```text
EVENTS.DynamicCargoLoaded
EVENTS.DynamicCargoUnloaded
EVENTS.DynamicCargoRemoved
```

Diese Ereignisse werden durch einen generischen MOOSE-`EVENTHANDLER` beobachtet. Auch hier wird kein eigener Cargo-Zustand aus Entfernung oder Objektverschwinden abgeleitet.

## 4. Carrier-Auswahl

Für projektspezifisch festgelegte Carrier-SQUADRONs wird die native MOOSE-Funktion verwendet:

```lua
LEGION.RecruitCohortAssets(...)
```

Berücksichtigt werden:

- erforderliche minimale und maximale Carrierzahl;
- MOOSE-Missionsfähigkeit `AUFTRAG.Type.OPSTRANSPORT`;
- passende Payload;
- Zielentfernung;
- Cargo-Einzelgewicht;
- Cargo-Gesamtgewicht;
- verfügbare Cargo-Kapazität.

Anschließend erfolgt die native Zuweisung:

```lua
transport:AddAsset(asset)
AIRWING:TransportAssign(transport, legions)
```

Als allgemeiner Fallback bleibt vorhanden:

```lua
AIRWING:RecruitAssetsForTransport(transport)
```

Der aktuelle UH-60-Test fordert explizit den UH-60-SQUADRON. STORAGE_CARGO verwendet standardmäßig CH-47, kann aber einen anderen Carrier-SQUADRON angeben.

## 5. Despawn-Regel

In der gepinnten MOOSE-Version ist

```lua
SQUADRON:SetDespawnAfterLanding(false)
```

fehlerhaft, weil auch `false` intern zu `despawnAfterLanding=true` führt.

Verbindliche Lösung:

```text
UH-60- und CH-47-SQUADRON:
  SetDespawnAfterLanding(...) bleibt vollständig ungesetzt.

Nach bestätigtem nativen Cargo-/Missionsziel:
  exaktes FLIGHTGROUP:SetDespawnAfterLanding()

Wirkung:
  Pickup- und Deploy-Landungen bleiben erhalten.
  Erst die folgende finale Landung darf despawnen.
```

Der Builder blockiert jeden erneuten tatsächlichen Aufruf `SetDespawnAfterLanding(false)`.

## 6. Entfernte Override-Kette

Aus dem Repository und dem Bundle entfernt:

```text
14a-phase1-lifecycle-corrections.lua
14b-phase1-sequence-finalization.lua
16-phase1-moose-compatibility.lua
17-phase1-operational-safety.lua
18-phase1-readiness-and-recon-telemetry.lua
19-phase1-oh58-formation-recovery-counting.lua
20-phase1-uh60-transport-lifecycle.lua
```

Der neue kanonische Phase-1-Teil besteht aus:

```text
11-phase1-test-manifest.lua
12-phase1-runtime-observer.lua
12a-phase1-moose-logistics.lua
13-phase1-mission-factory.lua
14-phase1-test-controller.lua
15-phase1-f10-and-acceptance.lua
16-phase1-moose-first-readiness-routing.lua
```

## 7. Verbleibende Eigenentwicklung

Bewusst projektspezifisch bleiben:

- Paket- und ORBAT-Vertrag;
- OH-58D-/AH-64D-Two-Ship-Invarianten;
- UH-60 Lead-/Guard-Paketmodell;
- Parking-Pools und Client-Schutz;
- Static-Reservierungen;
- exakte Runtime-Namensassertions;
- Gebirgs- und Rückkorridorplanung;
- Fuel-Telemetrie;
- unabhängige physische DCS-Abnahme;
- Ergebnis- und Fehlerdokumentation.

Diese Funktionen ersetzen keine operative MOOSE-Funktion, sondern definieren Anforderungen des Projekts.

## 8. Builder-Gates

Der Builder blockiert:

```text
SetDespawnAfterLanding(false)
.Airwing.missionqueue / .missionqueue
squadron.assets
_DATABASE.Templates.Groups
mission.groupdata
opsgroup.groupname
opsgroup.group
RefreshMissionGroups
MarkObjectiveDrivenSuccess
runtime.ObjectiveCheck
MissionStateSeen
```

Er fordert ausdrücklich:

```text
CountMissionsInQueue
CountAssets
CountAssetsOnMission
OnAfterFlightOnMission
AddConditionSuccess
AddRequiredPayload
OPSTRANSPORT:New
LEGION.RecruitCohortAssets
RecruitAssetsForTransport
TransportAssign
OnAfterLoaded
OnAfterLoadingDone
OnAfterUnloaded
OnAfterUnloadingDone
OnAfterDelivered
DynamicCargoLoaded
DynamicCargoUnloaded
```

## 9. Aktueller Validierungsstand

Durchgeführt:

- MOOSE-Quellcode am gepinnten Commit geprüft;
- öffentliche Funktionen gegen die gepinnte Quelle abgeglichen;
- Override-Dateien aus Repository und Builder entfernt;
- Builder-Gates ergänzt;
- Paket- und Logistikprofile zentralisiert;
- keine `.miz` verändert.

Noch ausstehend:

- lokaler PowerShell-Build;
- Lua-Parse des lokal gebauten vollständigen Bundles;
- DCS-Startprüfung;
- isolierte DCS-Läufe für OH-58D, AH-64D, UH-60 und CH-47;
- Gesamtablauf.

Wegen fehlendem Netzwerkzugriff des Ausführungscontainers konnte der GitHub-Branch nicht lokal geklont und der PowerShell-Builder nicht in dieser Umgebung ausgeführt werden. Der lokale Build beim Projektinhaber ist daher ein zwingendes Gate.

## 10. DCS-Abnahmereihenfolge

```text
1. Baseline startet und meldet PHASE1-11-MOOSE-FIRST READY.
2. UH-60 GROUP_CARGO / OPSTRANSPORT isoliert.
3. CH-47 STATIC_SLING_CARGO / AUFTRAG isoliert.
4. OH-58D RECON physical two-ship und Rückkorridor.
5. AH-64D CAS physical two-ship.
6. UH-60 Abort/Release.
7. Gesamtablauf.
```

Der UH-60-Test steht zuerst, weil der wiederholte Pickup-LZ-Despawn der unmittelbar zu beseitigende Fehler ist.

## 11. Freigabegrenze

```text
IMPLEMENTED bedeutet nicht DCS PASS.
```

Weitere Flugplätze, dynamische Spieleranforderungen und das vollständige MEDEVAC-Lead-/Guard-Paket bleiben gesperrt, bis die konsolidierte Architektur in DCS bestanden hat.
