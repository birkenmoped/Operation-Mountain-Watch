---
document_id: OMW-TEST-SHINDAND-G2-HELIPAD-SPAWN-ROOT-CAUSE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TECHNICAL_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-level root cause of Shindand G2 AH-64 parking non-compliance
  - limitation of pinned MOOSE WAREHOUSE aircraft spawning on HELIPAD and SHIP airbase categories
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: f08032e945578e9d22cfa6bbbd49c57e9e06142a
validated_in_dcs: true
---

# Shindand G2 – Root Cause des HELIPAD-Parking-Fehlers

## 1. Ausgangslage

Der isolierte Shindand-G2-Lauf hat den nativen MOOSE-Pfad

```text
AIRWING -> AUFTRAG -> WAREHOUSE asset request -> aircraft spawn
```

ohne COMMANDER erfolgreich bis zum tatsächlichen AH-64-Spawn ausgeführt.

Die Foundation-Konfiguration war vor dem Dispatch konsistent:

```text
SQUADRON: SQ_US_SHND_AH64D_ATTACK
Configured TerminalIDs: 21,3,34,15
post-start asset.parkingIDs: synchronized
```

Der tatsächliche AH-64-Spawn wurde jedoch bei TerminalID `41` beobachtet und damit außerhalb des Owner-Pools `21,3,34,15`.

## 2. DCS-Beobachtung

Der G2-Lauf dokumentierte:

```text
FLIGHT_ON_MISSION
group=SQ_US_SHND_AH64D_ATTACK_AID-197
missionType=CAS
unitType=AH-64D_BLK_II
terminalID=41
parkingAllowed=false
distanceM=1.667
state=Parking
```

Danach meldete das Gate korrekt:

```text
FAIL Assigned AH-64 spawned outside owner-defined AH-64 parking pool: terminalID=41
```

Damit ist die physische Parking-Compliance für Shindand Heliport im getesteten G2-Stand `FAIL`.

## 3. Gepinnter MOOSE-Stand

```yaml
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die folgende Root-Cause-Aussage bezieht sich ausschließlich auf diesen tatsächlich verwendeten Quellstand.

## 4. Quellpfad

### 4.1 `WAREHOUSE:_FindParkingForAssets()` berücksichtigt `asset.parkingIDs`

Im gepinnten Quellstand prüft `_FindParkingForAssets()` für jedes Asset:

```lua
if asset.parkingIDs then
  valid=self:_CheckParkingAsset(parkingspot, asset)
else
  -- terminal/BW-list path
end
```

Damit werden die am SQUADRON konfigurierten und nach `AIRWING:Start()` an die Assets gebundenen Parking-IDs in der WAREHOUSE-Parkplatzsuche tatsächlich berücksichtigt.

### 4.2 `_SpawnAssetRequest()` reicht das Parking-Ergebnis weiter

Für Aircraft-Assets berechnet `_SpawnAssetRequest()` zunächst:

```lua
Parking=self:_FindParkingForAssets(self.airbase, cargoassets) or {}
```

und ruft anschließend für das jeweilige Asset auf:

```lua
self:_SpawnAssetAircraft(_alias, asset, Request, Parking[asset.uid], ...)
```

Die Parking-Auswahl geht auf diesem Pfad somit nicht bereits zwischen Auswahl und `_SpawnAssetAircraft()` verloren.

### 4.3 `_SpawnAssetAircraft()` verwirft Parking für `HELIPAD` und `SHIP`

Der entscheidende Quellpfad liegt in `WAREHOUSE:_SpawnAssetAircraft()`.

Für

```lua
AirbaseCategory == Airbase.Category.HELIPAD
```

oder

```lua
AirbaseCategory == Airbase.Category.SHIP
```

wird **nicht** der übergebene Parking-Datensatz verwendet. Stattdessen setzt MOOSE jede Unit auf die Airbase-Koordinate und löscht die Parking-Felder:

```lua
local coord=self.airbase:GetCoordinate()

unit.x=coord.x
unit.y=coord.z
unit.alt=coord.y

unit.parking_id = nil
unit.parking    = nil
```

Der Quellkommentar lautet sinngemäß, dass bei Helipads die Airbase-Position verwendet wird, da die exakte Spawnposition dort nicht sinnvoll sei.

Für normale Airdromes benutzt derselbe Funktionspfad dagegen ausdrücklich:

```lua
coord=parking[i].Coordinate
terminal=parking[i].TerminalID
...
unit.parking = terminal
```

## 5. Root-Cause-Bewertung

Die technische Ursache ist damit für den gepinnten MOOSE-Stand nachgewiesen:

```text
SQUADRON:SetParkingIDs()
-> asset.parkingIDs
-> WAREHOUSE:_FindParkingForAssets() wählt passenden Owner-Pool
-> WAREHOUSE:_SpawnAssetRequest() reicht Parking weiter
-> WAREHOUSE:_SpawnAssetAircraft()
   erkennt Airbase.Category.HELIPAD
   und verwirft die expliziten Parkingdaten
-> DCS erhält keine TerminalID-Bindung
-> tatsächlicher HELIPAD-Spawn kann außerhalb des Owner-Pools erfolgen
```

Der beobachtete Spawn auf TerminalID `41` ist damit konsistent mit dem Quellpfad.

Status:

```yaml
root_cause: CONFIRMED_FOR_PINNED_MOOSE_SOURCE_AND_DOCUMENTED_DCS_G2_RUN
squadron_parking_configuration: PASS
asset_parking_inheritance: PASS
warehouse_parking_selection_path: SOURCE_CONFIRMED
helipad_physical_parking_enforcement: FAIL
```

## 6. MOOSE-First-Grenze

`SPAWN:SpawnAtAirbase(..., Parkingdata)` besitzt im selben gepinnten MOOSE-Stand einen öffentlichen expliziten Parking-Pfad und dokumentiert, dass `Parkingdata` den Spawn auf genau diese Spots zwingt. Dieser `SPAWN`-Pfad ist jedoch **nicht** der von AIRWING/WAREHOUSE verwendete Asset-Lifecycle-Pfad.

Eine direkte Umstellung auf `SPAWN` würde daher den AIRWING-/WAREHOUSE-Asset-Lifecycle umgehen und ist keine gleichwertige MOOSE-Konfiguration des bestehenden Produktionspfads.

Ebenso ist ein Override von `WAREHOUSE:_SpawnAssetAircraft()` ein Eingriff in eine interne MOOSE-Methode und gemäß OMW-Governance ohne ausdrückliche Owner-Freigabe nicht zulässig.

## 7. Kleinste verbleibende Lösungsrichtungen

Ohne Architekturentscheidung darf noch keine davon produktiv umgesetzt werden:

```text
A. MOOSE-internen WAREHOUSE-HELIPAD-Spawnpfad überschreiben/patchen
   -> technisch kleinster Eingriff in den bestehenden AIRWING-Lifecycle
   -> aber interne Methode / MOOSE-Override
   -> Owner-Freigabe erforderlich

B. Separaten öffentlichen SPAWN:SpawnAtAirbase(..., Parkingdata)-Pfad verwenden
   -> explizites Parking öffentlich unterstützt
   -> würde aber den AIRWING-/WAREHOUSE-Lifecycle parallelisieren oder umgehen
   -> Owner-Freigabe erforderlich und deutlich größerer Integrationsaufwand

C. Physische typgebundene Parking-Compliance am Shindand Heliport nicht erzwingen
   -> keine technische Abweichung
   -> fachliche Parking-Baseline würde auf Konfigurationsabsicht statt physische Garantie reduziert
   -> Owner-Entscheidung erforderlich
```

Keine dieser Richtungen ist durch diesen Bericht freigegeben.

## 8. Acceptance-Grenze

Dieser Bericht validiert die Root Cause des beobachteten G2-Parking-Fehlers für die dokumentierte Artefaktkette. Nicht validiert sind:

- ein korrigierter HELIPAD-Spawnpfad;
- tatsächlicher Start/Abflug nach einem korrigierten Parking-Spawn;
- Landing/Recovery;
- Persistenz;
- COMMANDER-Integration;
- Verhalten anderer MOOSE-Versionen.
