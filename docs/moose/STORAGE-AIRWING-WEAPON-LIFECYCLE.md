---
document_id: OMW-MOOSE-STORAGE-AIRWING-WEAPON-LIFECYCLE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE lifecycle used by STORAGE-AIRWING-WEAPON-LIFECYCLE-1
  - distinction between Landed, Arrived, ReturnToLegion and STORAGE weapon telemetry
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-airwing-weapon-lifecycle
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# STORAGE / AIRWING Weapon Lifecycle - MOOSE-Stand

## 1. Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Source-reviewed Lifecycle

Im tatsaechlich verwendeten `Moose.lua` sind fuer den geplanten Gate folgende Pfade vorhanden.

### FLIGHTGROUP Landed

`FLIGHTGROUP:onafterLanded(From, Event, To, airbase)` protokolliert die Landung und aktualisiert bei vorhandenem FLIGHTCONTROL dessen Status. Dieser Callback fuehrt selbst keine OMW-STORAGE-Buchung aus.

### FLIGHTGROUP Arrived

`FLIGHTGROUP:onafterArrived(From, Event, To)` behandelt das vollstaendige Ankommen. Fuer AI-Fluege mit zugeordnetem AIRWING und ohne Pickup-/Transportzustand gilt im gepinnten Source-Pfad:

```text
GetAirwing()
-> ReturnToLegion(1)
```

Damit existiert bereits ein nativer MOOSE-Asset-Recovery-Pfad. OMW darf diesen fuer den Test nicht parallel nachbauen.

### Helicopter Element-Landing

`FLIGHTGROUP:onafterElementLanded(...)` setzt das Element auf `LANDED`. Fuer Helikopter wird ein Parking Spot bestimmt und der Elementstatus kann unmittelbar auf `ARRIVED` uebergehen. Ist `despawnAfterLanding` aktiv und gehoert die Gruppe zu einer LEGION, verwendet MOOSE ebenfalls den nativen Return-to-Legion-Pfad. Der geplante Test setzt `SetDespawnAfterLanding()` nicht selbst und veraendert die Foundation-Konfiguration nicht.

### Read-only Weapon Telemetry

Der Test liest ausschliesslich ueber:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
```

und beobachtet Aenderungen der DCS-Warehouse-Weapon-Keys. Er ruft keine STORAGE-Mutationsmethode auf.

### AIRWING Wiederverwendung

Die zweite Sortie wird erneut ueber:

```text
AUFTRAG:NewCAS()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission
```

angefordert. `AIRWING:CountAssets()` und `AIRWING:CountAssetsOnMission()` dienen nur der Lifecycle-Telemetrie. Damit wird geprueft, ob der native Recovery-Pfad das Asset wieder fuer einen Folgedispatch bereitstellt; OMW fuegt kein Asset manuell zurueck.

### No-fire Plausibilisierung

`FLIGHTGROUP:GetAmmoTot()` ist im gepinnten Source vorhanden. Der Gate protokolliert die Summen fuer `MissilesAG`, `Rockets`, `Bombs` und `Guns` bei Assignment, Landed und Arrived. Diese Telemetrie soll einen unerwarteten Waffenverbrauch sichtbar machen; sie ersetzt nicht die STORAGE-Deltamessung.

## 3. Noch nicht validiert

Bis zum DCS-Lauf sind folgende Punkte nur source-reviewed bzw. geplant:

```text
Zeitpunkt einer moeglichen STORAGE-Rueckgutschrift
volle / teilweise / keine Recredit-Semantik
Asset-Wiederverfuegbarkeit nach ReturnToLegion im konkreten Shindand-Lauf
zweite identische STORAGE-Abbuchung nach Recovery
Ammo-Summenstabilitaet eines no-fire AI-Roundtrips
```

Erst ein dokumentierter DCS-Lauf darf diese Punkte auf `VALIDATED_FOR_DOCUMENTED_SCOPE` anheben.
