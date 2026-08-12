---
document_id: OMW-MOOSE-AIRBORNE-AMMO-PARKING-CORRELATION
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE path for Kandahar ME parking to runtime TerminalID correlation
  - source-reviewed extension of the airborne onboard-gun lifecycle harness
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/airborne-ammo-parking-correlation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Airborne Ammo und Kandahar Parking Correlation

## Zweck

Der Test `AIRBORNE-AMMO-PARKING-CORRELATION-3` bündelt zwei technisch zusammengehörige Diagnoseblöcke in einem DCS-Lauf:

```text
A-10C / GAU-8        = Lifecycle-Gate
F-16C / M61          = Discovery
F-15E / M61          = Discovery
UH-60 / Bordwaffen   = Discovery
CH-47 / Bordwaffen   = Discovery
OH-58D / M3P         = Regression
AH-64D / M230        = Regression

Kandahar Main        = ME-Parkplatzkennung -> MOOSE TerminalID
Kandahar Heliport    = ME-Parkplatzkennung -> MOOSE TerminalID
```

Der Ammo-Pfad baut auf dem bereits source-reviewten V2-Harness auf. Die Parking-Korrelation ist read-only und verändert weder Parking-Pools noch WAREHOUSE-/AIRWING-Konfiguration.

## Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Source-reviewed Parking-APIs

Der gepinnte Source bestätigt die für den neuen Pfad verwendeten öffentlichen Methoden:

```text
SET_GROUP:New()
SET_GROUP:FilterPrefixes(prefix)
SET_BASE:FilterOnce()
SET_GROUP:ForEachGroup(iterator)
GROUP:GetTemplate()
AIRBASE:GetParkingSpotsTable(termtype)
```

`GROUP:GetTemplate()` liefert eine Kopie des Mission-Editor-Gruppentemplates. Der Harness liest daraus ausschließlich die erste Unit der vorbereiteten Kandahar-Markergruppe:

```text
unit.x
unit.y
unit.parking_id
unit.parking
```

Der Harness greift nicht direkt auf `_DATABASE` zu.

`AIRBASE:GetParkingSpotsTable()` liefert im gepinnten Stand Parking-Einträge mit unter anderem:

```text
TerminalID
TerminalID0
TerminalType
Vec3
Coordinate
```

Im MOOSE-Initialisierungspfad gilt:

```text
TerminalID  <- DCS Term_Index
TerminalID0 <- DCS Term_Index_0
```

Damit beweist die Existenz eines numerischen `.miz parking`-Werts allein noch nicht seine Gleichheit mit `TerminalID`. Genau diese Gleichheit wird im DCS-Lauf korreliert.

## Marker-Selektion

Die aktuelle Arbeits-MIZ verwendet:

```text
KANDAHAR_<ME-Parkplatz-Kennung>
KANDAHAR_HP_<ME-Parkplatz-Kennung>
```

Da `FilterPrefixes()` im gepinnten MOOSE-Source intern eine Pattern-Suche verwendet, prüft der Harness den echten String-Anfang zusätzlich selbst. Für den Main-Airfield-Lauf wird `KANDAHAR_HP_` ausdrücklich ausgeschlossen.

## Korrelationslogik

Für jede vorbereitete Markergruppe:

```text
1. Mission-Editor-Template über GROUP:GetTemplate() lesen.
2. ME-Kennung aus unit.parking_id lesen.
3. numerisches .miz-parking aus unit.parking lesen.
4. MOOSE-Parkingtabelle des korrekten AIRBASE-Nodes lesen.
5. räumlich nächsten Parking-Spot anhand Template-x/y und spot.Vec3.x/z bestimmen.
6. .miz parking gegen MOOSE TerminalID vergleichen.
7. Positionsabstand zusätzlich prüfen.
```

Ein `MATCH` erfordert:

```text
mizParking == mooseTerminalID
und
distanceM <= 5
```

Pro Marker wird ausgegeben:

```text
PARKING_MAP
node
markerGroup
meParkingId
mizParking
mooseTerminalID
terminalID0
terminalType
distanceM
exactIdMatch
positionMatch
status
```

Zusätzlich werden `PARKING_NODE_RESULT` und `PARKING_CORRELATION_RESULT` geschrieben.

## STORAGE-Lane-Serialisierung

STORAGE-Deltas dürfen nicht durch zwei gleichzeitig laufende Fälle desselben Warehouses vermischt werden. Deshalb laufen nur unabhängige STORAGE-Nodes parallel; Fälle innerhalb desselben Nodes werden strikt nacheinander gestartet.

```text
Kandahar:
  A-10C / GAU-8

Bagram:
  F-16C / M61
  -> danach F-15E / M61

Jalalabad:
  UH-60 / Bordwaffen
  -> danach CH-47 / Bordwaffen
  -> danach OH-58D / M3P

Shindand Heliport:
  AH-64D / M230
```

Der nächste Fall einer Lane wird erst nach `CASE_RESULT` des vorherigen Falls gestartet. Independent Lanes dürfen gleichzeitig laufen. Damit bleiben `pre -> postSpawn -> final`-Deltas pro STORAGE-Node einem Fall zuordenbar.

Der globale Safety-Timeout beträgt wegen der serialisierten Bagram-/Jalalabad-Lanes 14.400 Sekunden; die individuellen Assignment-/Lifecycle-Timeouts bleiben 600 beziehungsweise 3.600 Sekunden.

## Architekturgrenzen

Die Korrelation ist Diagnose, kein Parking-Controller.

Nicht verwendet werden:

```text
WAREHOUSE:_FindParkingForAssets() override
AIRBASE parking whitelist/blacklist mutation
SQUADRON:SetParkingIDs() mutation
native DCS parking manipulation
_DATABASE direct access
world.searchObjects
```

Das Ergebnis darf nur für die exakt getestete MIZ-/DCS-/MOOSE-Kette als Runtime-Nachweis behandelt werden. Erst ein vollständiger positiver Kandahar-Lauf rechtfertigt die projektspezifische Schlussfolgerung, dass die vorbereiteten `.miz parking`-Werte in diesem Stand 1:1 den MOOSE-`TerminalID`s entsprechen.

## Ammo-Erweiterung

Die neuen F-16C-, F-15E-, UH-60- und CH-47-Fälle übernehmen den bereits source-reviewten Pfad:

```text
AIRWING:NewPayload()
AUFTRAG:NewORBIT()
AIRWING:AddMission()
FLIGHTGROUP:SetOptionLandingRestrictPair()
FLIGHTGROUP:GetAmmoTot()
AUFTRAG:NewSTRAFING()
OPSGROUP:AddMission()
STORAGE:GetInventory()
```

Es werden keine vorab angenommenen Rundenzahlen als CampaignState-Ressourcen gebucht. Maßgeblich sind reale `GetAmmoTot()`-Deltas, DCS-Debrief-`ammo_consumption` und beobachtete STORAGE-Deltas.

Der A-10 bleibt das strenge Gate. F-16C, F-15E, UH-60 und CH-47 sind im ersten Lauf Discovery-Fälle. OH-58D und AH-64D bleiben Regression.

## DCS-Acceptance

Vor einem positiven Runtime-Nachweis bleibt dieses Dokument `PLANNED` und `validated_in_dcs: false`.

Erforderliche Provenienz entspricht `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION`:

```text
Branch
Source-Commit
Builder-Version
Bundle-SHA-256
MIZ-Dateiname
MIZ-SHA-256
interner mission-SHA-256
DCS-Version
MOOSE-Commit
Moose.lua-SHA-256
DCS-Log-SHA-256
Debrief-SHA-256
```
