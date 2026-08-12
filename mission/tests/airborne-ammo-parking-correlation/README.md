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
validated_in_dcs: partial
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

Alle Ammo-Fälle verwenden reale DCS-Waffenabgabe, `FLIGHTGROUP:GetAmmoTot()`, read-only `STORAGE:GetInventory()` und den nativen AIRWING-Lifecycle. Es werden keine Munitionsdekremente simuliert und keine STORAGE-/CampaignState-Bestände verändert.

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

Die Arbeits-MIZ enthält vorbereitete Late-Activation-Gruppen mit folgenden Namenspräfixen:

```text
KANDAHAR_<ME-Parkplatz-Kennung>
KANDAHAR_HP_<ME-Parkplatz-Kennung>
```

Der Test liest die ME-Templateposition und die im Template gespeicherten Felder `parking_id` und `parking` über die öffentliche MOOSE-Methode `GROUP:GetTemplate()` aus. Die MOOSE-Parkingtabelle wird über `AIRBASE:GetParkingSpotsTable()` bezogen.

Ein `MATCH` verlangt gleichzeitig:

```text
miz parking == MOOSE TerminalID
2D-Abstand Templateposition <-> MOOSE Parkingposition <= 5 m
```

## Lauf vom 12.08.2026

Provenienz:

```text
Branch: agent/airborne-ammo-parking-correlation
Source commit: 5ad6d2c535c2e6796a677fd18975be794533ab8b
BuilderVersion: AIRBORNE-AMMO-PARKING-CORRELATION-3
Bundle SHA-256: cb650dd8bab448de39eb1a26f4bc856964f375600df51a5587fcf02c521a65fd
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 8f345af681276bc8634128b023873be4473df459deb2f6f9b230f3cbd901c84d
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: a0473859853a2786c188b3cf3c3095e570806c20b6cb49216e9befe0ac6df7b8
debrief.log SHA-256: 5b083460b339b78aa6d8d1754e60c81d10c3f7e84f56f9f74eedece6fc31eca3
```

Harness-Endstatus:

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

### Parking

```text
Kandahar Main:     296 / 296 exact matches
Kandahar Heliport:  80 /  80 exact matches
Total:             376 / 376 exact matches
```

Damit ist für die getestete Kette praktisch bestätigt:

```text
ME parking_id -> .miz unit.parking -> MOOSE TerminalID
.miz unit.parking == MOOSE TerminalID
```

Die vollständige Zuordnung ist auf `main` unter `docs/data/kandahar-me-parking-to-moose-terminalid.csv` dokumentiert.

Bekannte ME-Namensanomalie: `AAF05` wurde als `KANDAHAR_AAF05KANDAHAR_AAF01` gefunden; die Zuordnung blieb mit `.miz parking=29` und `TerminalID=29` eindeutig.

### Bordwaffen- und Lifecycle-Befunde

```text
A-10C / GAU-8:
  ASSIGNED 2300
  real consumption 536
  DCS debrief 536
  beide Flugzeuge vom Projektinhaber visuell mit normalem Start, Angriff, Landung,
  Parking und Engine shutdown beobachtet
  MOOSE Arrived/despawn blieb aus

F-16C / M61:
  real consumption 762
  DCS debrief 762
  normal return observed

F-15E / M61:
  real consumption 804
  DCS debrief 804
  normal return observed

UH-60A:
  GetAmmoTot = 0
  keine beobachtete Zielbekämpfung

CH-47F:
  GetAmmoTot guns = 800
  CH47_PORT_M60D und CH47_STBD_M60D STORAGE container debit/recredit beobachtet
  keine reale M60D-Abgabe beobachtet

AH-64D / M230:
  regression consumption 87
  normal return observed

OH-58D / M3P:
  aktueller Lauf durch Baumkollision eines Elements kontaminiert
  debrief real expenditure 64
  Gruppendelta ist wegen fehlendem Element kein gültiger Round-Verbrauchsnachweis
  früherer sauberer M3P-Nachweis bleibt maßgeblich
```

## Projektentscheidungen nach dem Lauf

Der Projektinhaber schließt den **A-10/GAU-8-Gate für die aktuelle Warehouse-Ressourcenfrage**. Begründung: reale GAU-8-Abgabe ist unabhängig durch `GetAmmoTot()` und DCS-Debrief korreliert; beide A-10 wurden visuell nach normalem Start, Angriff und Landung vollständig geparkt und mit abgestellten Triebwerken beobachtet. Das fehlende MOOSE-`Arrived` beziehungsweise Ausbleiben des üblichen Despawns bleibt als **DCS/MOOSE-Lifecycle-Anomalie** dokumentiert und wird nicht als fehlender physischer Return interpretiert. Diese Entscheidung behauptet ausdrücklich nicht, dass der `Arrived`-/Despawn-Pfad technisch repariert oder allgemein validiert sei.

Für UH-60 und CH-47 wird die Frage, welche Zielarten die DCS-AI mit Bord-/Door-Guns angreift, **vorerst nicht weiter untersucht**. Aus dem CH-47-Containerbefund wird keine Round-Conversion abgeleitet.

Der aktuelle OH-58-Lauf wird wegen der beobachteten Baumkollision und anschließenden Notlandung eines Elements nicht zur Neuberechnung des M3P-Roundverbrauchs verwendet.

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

Die Signaturen und relevanten Datenfelder wurden gegen die im Projekt gepinnte `Moose.lua` geprüft.

## Build

```text
Source: mission/tests/airborne-ammo-parking-correlation/src/01-airborne-ammo-parking-correlation.lua
Builder: tools/build-airborne-ammo-parking-correlation.ps1
Bundle: mission/tests/airborne-ammo-parking-correlation/dist/OMW_Airborne_Ammo_Parking_Correlation.lua
BuilderVersion: AIRBORNE-AMMO-PARKING-CORRELATION-3
```

Der Builder prüft die sieben Case-IDs, die Parking-Correlation-Marker, die serialisierten STORAGE-Lane-Verträge sowie verbotene mutierende STORAGE-, CampaignState-, native Spawn-, Return- und Despawn-Pfade.
