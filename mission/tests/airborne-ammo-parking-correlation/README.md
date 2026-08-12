---
document_id: OMW-TEST-AIRBORNE-AMMO-PARKING-CORRELATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - combined onboard gun lifecycle discovery for A-10C, F-16C, F-15E, UH-60 and CH-47
  - OH-58D and AH-64D regression observation
  - Kandahar Mission Editor parking to MOOSE TerminalID correlation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/airborne-ammo-parking-correlation
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/airborne-ammo-partial-consumption
base_commit: 5efe2bd558aa989528f0454d887b9a8f807c3b4f
merged_to_main: false
---

# Airborne Ammo und Kandahar Parking Correlation

## Ziel

Dieser Test erweitert den bisherigen `AIRBORNE-AMMO-PARTIAL-CONSUMPTION-2`-Scope, ohne einen produktiven Ressourcenadapter vorwegzunehmen.

Der kombinierte Lauf untersucht:

```text
A-10C / GAU-8        = verbleibendes Lifecycle-Gate
F-16C / M61          = neue Discovery
F-15E / M61          = neue Discovery
UH-60 / Bordwaffen   = neue Discovery
CH-47 / Bordwaffen   = neue Discovery
OH-58D / M3P         = Regression
AH-64D / M230        = Regression
```

Alle Ammo-Fälle verwenden reale DCS-Waffenabgabe, `FLIGHTGROUP:GetAmmoTot()`, read-only `STORAGE:GetInventory()` und den nativen `Landed -> Arrived -> AIRWING return`-Pfad. Es werden keine Munitionsdekremente simuliert und keine STORAGE-/CampaignState-Bestände verändert.

## STORAGE-Lanes

Fälle, die denselben physischen STORAGE-Node verwenden, laufen strikt nacheinander. Dadurch bleiben die Inventory-Deltas pro Fall eindeutig zuordenbar.

```text
Kandahar:
  A-10C / GAU-8

Bagram:
  F-16C / M61
  -> F-15E / M61

Jalalabad:
  UH-60 / Bordwaffen
  -> CH-47 / Bordwaffen
  -> OH-58D / M3P

Shindand Heliport:
  AH-64D / M230
```

Nur voneinander unabhängige STORAGE-Lanes dürfen parallel laufen. Der globale Safety-Timeout beträgt deshalb 14.400 Sekunden; der einzelne Lifecycle-Timeout bleibt 3.600 Sekunden.

## Kandahar Parking Correlation

Die aktuelle Arbeits-MIZ enthält vorbereitete Late-Activation-Gruppen mit folgenden Namenspräfixen:

```text
KANDAHAR_<ME-Parkplatz-Kennung>
KANDAHAR_HP_<ME-Parkplatz-Kennung>
```

Der Test liest die ME-Templateposition und die im Template gespeicherten Felder `parking_id` und `parking` ausschließlich über die öffentliche MOOSE-Methode `GROUP:GetTemplate()` aus. Die MOOSE-Parkingtabelle wird über `AIRBASE:GetParkingSpotsTable()` bezogen.

Für jede vorbereitete Gruppe wird der räumlich nächste MOOSE-Parkplatz bestimmt und protokolliert:

```text
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

Ein `MATCH` verlangt gleichzeitig:

```text
miz parking == MOOSE TerminalID
2D-Abstand Templateposition <-> MOOSE Parkingposition <= 5 m
```

Damit wird nicht nur eine statische `.miz`-Nummer ausgegeben, sondern die bislang offene Gleichheit zwischen Mission-Editor-Zuordnung und MOOSE-Runtime-TerminalID geprüft.

## MOOSE-First-Prüfung

Verwendet werden vorhandene öffentliche MOOSE-Funktionen:

```text
SET_GROUP:FilterPrefixes()
SET_BASE:FilterOnce()
SET_GROUP:ForEachGroup()
GROUP:GetTemplate()
AIRBASE:GetParkingSpotsTable()
AIRBASE:GetParkingData()
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP:SetOptionLandingRestrictPair()
AIRWING:NewPayload()
AIRWING:AddMission()
AUFTRAG:NewORBIT()
AUFTRAG:NewSTRAFING()
SPAWN:NewWithAlias()
SPAWN:SpawnFromCoordinate()
COORDINATE:GetClosestPointToRoad()
COORDINATE:IsInFlatArea()
STORAGE:GetInventory()
```

Die Signaturen und relevanten Datenfelder wurden gegen die im Projekt gepinnte `Moose.lua` geprüft:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für `AIRBASE:GetParkingSpotsTable()` liefert der gepinnte Quellstand unter anderem `TerminalID`, `TerminalID0`, `TerminalType`, `Vec3` und `Coordinate`. `TerminalID` wird intern aus DCS `Term_Index` aufgebaut. Der neue Test soll erstmals systematisch gegen die in den vorbereiteten ME-Gruppen gespeicherte `parking`-Nummer korrelieren.

## Acceptance-Grenzen

Der A-10-Fall ist nur dann geschlossen, wenn im selben Lauf reale GAU-8-Abgabe, reduzierter Onboard-Bestand, `Landed`, `Arrived` und finaler STORAGE-Snapshot beobachtet werden.

Für F-16C, F-15E, UH-60 und CH-47 ist der erste Lauf Discovery. Ein `AUFTRAG success` ohne reale Ammo-Änderung ist kein Waffenverbrauchsnachweis.

Die Bordwaffen der UH-60-/CH-47-DCS-Abbildung werden nicht vorab als lineare CampaignState-Ressource interpretiert. Maßgeblich sind die reale `GetAmmoTot()`-Telemetrie, der DCS-Debrief und das tatsächlich beobachtete STORAGE-Verhalten.

Die Parking-Korrelation ist nur für die exakt getestete MIZ-/DCS-/MOOSE-Kette belastbar. Ein statischer `.miz parking`-Wert wird vor diesem Runtime-Nachweis nicht pauschal als MOOSE-TerminalID für andere Kartenstände oder DCS-Versionen verallgemeinert.

## Build

Source:

```text
mission/tests/airborne-ammo-parking-correlation/src/01-airborne-ammo-parking-correlation.lua
```

Builder:

```text
tools/build-airborne-ammo-parking-correlation.ps1
```

Bundle:

```text
mission/tests/airborne-ammo-parking-correlation/dist/OMW_Airborne_Ammo_Parking_Correlation.lua
```

BuilderVersion:

```text
AIRBORNE-AMMO-PARKING-CORRELATION-3
```

Der Builder prüft die sieben Case-IDs, die Parking-Correlation-Marker, die serialisierten STORAGE-Lane-Verträge sowie verbotene mutierende STORAGE-, CampaignState-, native Spawn-, Return- und Despawn-Pfade.

`VALIDATED` oder `ACCEPTED_TECHNICAL_BASELINE` ist erst nach realem DCS-Lauf mit vollständiger Provenienz zulässig.
