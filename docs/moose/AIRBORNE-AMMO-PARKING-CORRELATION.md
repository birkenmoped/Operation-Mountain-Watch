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
validated_in_dcs: partial
---

# MOOSE Airborne Ammo und Kandahar Parking Correlation

## Zweck

Der Test `AIRBORNE-AMMO-PARKING-CORRELATION-3` bündelt Bordwaffen-/Lifecycle-Telemetrie mit einer vollständigen Kandahar-Parking-Korrelation. Die Parking-Korrelation ist read-only und verändert weder Parking-Pools noch WAREHOUSE-/AIRWING-Konfiguration.

## Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Verwendeter Parking-Pfad

```text
SET_GROUP:New()
SET_GROUP:FilterPrefixes(prefix)
SET_BASE:FilterOnce()
SET_GROUP:ForEachGroup(iterator)
GROUP:GetTemplate()
AIRBASE:GetParkingSpotsTable(termtype)
```

`GROUP:GetTemplate()` liefert das Mission-Editor-Gruppentemplate; der Harness liest `unit.x`, `unit.y`, `unit.parking_id` und `unit.parking`. `AIRBASE:GetParkingSpotsTable()` liefert unter anderem `TerminalID`, `TerminalID0`, `TerminalType` und `Vec3`. Im gepinnten Source wird `TerminalID` aus DCS `Term_Index` aufgebaut.

Marker:

```text
KANDAHAR_<ME-Parkplatz-Kennung>
KANDAHAR_HP_<ME-Parkplatz-Kennung>
```

Ein Match verlangt:

```text
mizParking == mooseTerminalID
und
distanceM <= 5
```

## STORAGE-Lane-Serialisierung

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

Fälle desselben STORAGE-Nodes laufen nacheinander; unabhängige Nodes dürfen parallel laufen.

## Runtime-Nachweis 12.08.2026

```text
Branch: agent/airborne-ammo-parking-correlation
Source commit: 5ad6d2c535c2e6796a677fd18975be794533ab8b
BuilderVersion: AIRBORNE-AMMO-PARKING-CORRELATION-3
Bundle SHA-256: cb650dd8bab448de39eb1a26f4bc856964f375600df51a5587fcf02c521a65fd
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 8f345af681276bc8634128b023873be4473df459deb2f6f9b230f3cbd901c84d
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: a0473859853a2786c188b3cf3c3095e570806c20b6cb49216e9befe0ac6df7b8
debrief.log SHA-256: 5b083460b339b78aa6d8d1754e60c81d10c3f7e84f56f9f74eedece6fc31eca3
```

Harness:

```text
status=COMPLETE_WITH_GAPS
casesTotal=7
casesObserved=6
casesFailed=1
parkingGroups=376
parkingMapped=376
parkingExactIdMatches=376
parkingFailed=0
```

Parking-Ergebnis:

```text
Kandahar Main:     296/296 exact matches
Kandahar Heliport:  80/80 exact matches
Total:             376/376 exact matches
```

Damit ist für die exakt getestete Kette praktisch bestätigt:

```text
ME parking_id -> .miz unit.parking -> MOOSE TerminalID
.miz unit.parking == MOOSE TerminalID
```

Die vollständige Mapping-Baseline liegt auf `main` unter `docs/data/kandahar-me-parking-to-moose-terminalid.csv`.

Bekannte ME-Namensanomalie: `AAF05` wurde als `KANDAHAR_AAF05KANDAHAR_AAF01` gefunden; `.miz parking=29` und `TerminalID=29` stimmen dennoch eindeutig überein.

## Bordwaffen-/Lifecycle-Ergebnis

```text
A-10C / GAU-8:
  2300 -> 1764; real consumption 536; debrief 536
  beide Flugzeuge visuell normal gestartet, angegriffen, gelandet, geparkt und engines off
  MOOSE Arrived/despawn blieb aus

F-16C / M61:
  real consumption 762; debrief 762; normal return

F-15E / M61:
  real consumption 804; debrief 804; normal return

UH-60A:
  GetAmmoTot = 0; keine beobachtete Zielbekämpfung

CH-47F:
  guns=800; PORT/STBD M60D container debit/recredit beobachtet
  keine reale M60D-Abgabe beobachtet

AH-64D / M230:
  regression consumption 87; normal return

OH-58D / M3P:
  Lauf durch Baumkollision eines Elements kontaminiert
  debrief real expenditure 64
  Gruppendelta nicht als Round-Verbrauch verwendbar
```

## Projektentscheidungen

Der Projektinhaber schließt den **A-10/GAU-8-Gate für die aktuelle Warehouse-Ressourcenfrage**. Die reale Schussabgabe ist durch Onboard-Telemetrie und Debrief bestätigt; der physische Return beider A-10 wurde visuell bis Parking und Engine shutdown beobachtet. Das fehlende MOOSE-`Arrived` beziehungsweise der ausgebliebene Despawn bleibt als DCS/MOOSE-Lifecycle-Anomalie offen und gilt ausdrücklich nicht als technisch repariert.

UH-60-/CH-47-Zielartenverhalten wird vorerst nicht weiter untersucht. Aus den CH-47-M60D-Containern wird keine Rundenzahl-Conversion abgeleitet.

Der aktuelle OH-58-Lauf wird wegen der beobachteten Baumkollision und Notlandung eines Elements nicht zur Neubewertung der früheren sauberen M3P-Evidenz verwendet.

## Architekturgrenzen

Nicht verwendet werden:

```text
WAREHOUSE:_FindParkingForAssets() override
AIRBASE parking whitelist/blacklist mutation
SQUADRON:SetParkingIDs() mutation
native DCS parking manipulation
_DATABASE direct access
world.searchObjects
```

Die Kandahar-Korrelation ist an die getestete MIZ-/DCS-/MOOSE-Kette gebunden. Andere Airbases oder geänderte Karten-/DCS-Stände benötigen eigene Korrelation.
