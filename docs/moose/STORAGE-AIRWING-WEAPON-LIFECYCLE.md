---
document_id: OMW-MOOSE-STORAGE-AIRWING-WEAPON-LIFECYCLE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE lifecycle used by STORAGE-AIRWING-WEAPON-LIFECYCLE-2
  - distinction between Landed, Arrived, ReturnToLegion and STORAGE weapon telemetry
  - exact STORAGE:GetInventory return contract for the lifecycle gate
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

## 2. Exakter STORAGE:GetInventory-Vertrag

Im tatsaechlich verwendeten `Moose.lua` lautet der relevante Pfad:

```lua
function STORAGE:GetInventory(Item)
  local inventory=self.warehouse:getInventory(Item)
  return inventory.aircraft, inventory.liquids, inventory.weapon
end
```

Damit sind drei Rueckgabewerte zu behandeln:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

Eine Interpretation als einzelne Tabelle mit `inventory.weapon` oder `inventory.weapons` ist fuer diesen MOOSE-Stand falsch.

Der verworfene V1-Lifecycle-Harness machte genau diesen Fehler und verlor dadurch die Weapon-Tabelle. Der DCS-Lauf vom 2026-08-11 mit `weaponKeys=0` ist deshalb keine STORAGE-Recredit-Evidenz. V2 erzwingt die korrekte Signatur sowohl im Lua-Harness als auch durch statische Builder-Checks und validiert vor dem ersten Dispatch nichtleere Weapon-Inventories sowie die drei bekannten Shindand-AH-64-Keys.

## 3. Source-reviewed Lifecycle

### FLIGHTGROUP Landed

`FLIGHTGROUP:onafterLanded(From, Event, To, airbase)` protokolliert die Landung und aktualisiert bei vorhandenem FLIGHTCONTROL dessen Status. Dieser Callback fuehrt selbst keine OMW-STORAGE-Buchung aus.

Der erste V1-DCS-Lauf des Lifecycle-Gates lieferte fuer beide Sorties keinen User-`OnAfterLanded`-Callback. Deshalb bleibt `Landed` in V2 zusaetzliche Telemetrie und darf fuer diesen Gate nicht als zwingender Recovery-Anker vorausgesetzt werden.

### FLIGHTGROUP Arrived

`FLIGHTGROUP:onafterArrived(From, Event, To)` behandelt das vollstaendige Ankommen. Fuer AI-Fluege mit zugeordnetem AIRWING und ohne Pickup-/Transportzustand gilt im gepinnten Source-Pfad:

```text
GetAirwing()
-> ReturnToLegion(1)
```

Der V1-DCS-Lauf beobachtete `Arrived` fuer beide AH-64D-Sorties sowie einen erfolgreichen zweiten Dispatch nach dem ersten Return. Diese Teilergebnisse sind informativ fuer den AIRWING-/FLIGHTGROUP-Lifecycle, validieren wegen der defekten STORAGE-Auswertung aber keine Recredit-Semantik.

### Helicopter Element-Landing

`FLIGHTGROUP:onafterElementLanded(...)` setzt das Element auf `LANDED`. Fuer Helikopter kann der Elementstatus unmittelbar in Richtung `ARRIVED` fortschreiten. Ist `despawnAfterLanding` aktiv und gehoert die Gruppe zu einer LEGION, verwendet MOOSE ebenfalls den nativen Return-to-Legion-Pfad. Der Test setzt `SetDespawnAfterLanding()` nicht selbst und veraendert die Foundation-Konfiguration nicht.

### Read-only Weapon Telemetry

Der Test liest ausschliesslich ueber:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory() -> aircraft, liquids, weapons
```

und beobachtet Aenderungen der DCS-Warehouse-Weapon-Keys. Er ruft keine STORAGE-Mutationsmethode auf.

V2 verlangt als Kontrollsignal nach der ersten Shindand-2-Ship-AH-64D-Materialisierung exakt den bereits akzeptierten Parent-Befund:

```text
weapons.nurs.HYDRA_70_M151: -76
weapons.missiles.AGM_114K: -4
weapons.droptanks.{IAFS_ComboPak_100}: -2
```

Fehlt dieser Delta oder ist die Weapon-Tabelle leer, darf der Harness nicht PASS melden.

### AIRWING Wiederverwendung

Die zweite Sortie wird erneut ueber:

```text
AUFTRAG:NewCAS()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission
```

angefordert. `AIRWING:CountAssets()` und `AIRWING:CountAssetsOnMission()` dienen nur der Lifecycle-Telemetrie. OMW fuegt kein Asset manuell zurueck.

### No-fire Plausibilisierung

`FLIGHTGROUP:GetAmmoTot()` ist im gepinnten Source vorhanden. V2 protokolliert die Summen fuer `MissilesAG`, `Rockets`, `Bombs` und `Guns` bei Assignment und Arrived; `Landed` bleibt optional. Assignment und Arrived muessen fuer jede Sortie uebereinstimmen, sonst kann der Gate keinen PASS liefern.

## 4. V2 Fail-Fast-Grenzen

Vor einem gueltigen PASS muessen mindestens gelten:

```text
GetInventory() three-return contract valid
all seven weapon inventories non-empty
required Shindand keys numeric and sufficiently stocked
first known external-store debit exactly validated
first and second Arrived observed
both no-fire comparisons true
final STORAGE read succeeds
```

Damit kann insbesondere der V1-Fehlermodus `weaponKeys=0` nicht erneut als PASS durchlaufen.

## 5. Noch nicht validiert

Bis zum korrigierten V2-DCS-Lauf bleiben folgende Punkte offen:

```text
Zeitpunkt einer moeglichen STORAGE-Rueckgutschrift
volle / teilweise / keine Recredit-Semantik
zweite STORAGE-Abbuchung nach Recovery
finaler Warehouse-Zustand nach zwei no-fire Roundtrips
```

Erst ein dokumentierter V2-DCS-Lauf darf diese Punkte auf `VALIDATED_FOR_DOCUMENTED_SCOPE` anheben.
