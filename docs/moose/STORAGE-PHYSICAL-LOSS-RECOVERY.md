---
document_id: OMW-MOOSE-STORAGE-PHYSICAL-LOSS-RECOVERY
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE physical aircraft destruction test path
  - UNIT Explode usage for STORAGE recovery correlation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-physical-loss-recovery
source_commit: PENDING_DCS_TEST
validated_in_dcs: false
---

# MOOSE – STORAGE Physical Loss Recovery

## Zweck

Diese Notiz dokumentiert den kleinsten MOOSE-first-Pfad, mit dem OMW die noch offene Frage nach DCS/STORAGE-Recredits bei einem physisch zerstoerten AIRWING-Flugzeug prueft.

Der fruehere Verlusttest verwendete `OPSGROUP:Destroy()`. Der gepinnte MOOSE-Quellcode erzeugt dabei fuer Aircraft ein `UnitLost`-Event und entfernt die Unit anschliessend programmgesteuert. Dieser Pfad ist daher kein hinreichender Ersatz fuer reale physische Zerstoerung.

## Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Source-reviewed Methoden

### `UNIT:Explode(power, delay)`

Der tatsaechlich verwendete `Moose.lua` definiert:

```text
UNIT:Explode(power, delay)
```

Semantik des geprueften Quellpfads:

```text
UNIT:GetDCSObject()
-> UNIT:GetCoordinate()
-> COORDINATE:Explosion(power)
```

Default-Power ist 100 kg TNT. OMW setzt im isolierten Test explizit 1500 kg TNT pro AH-64-Unit, um einen eindeutigen Totalverlust zu erzwingen.

Projektstatus vor dem DCS-Lauf:

```text
SOURCE_REVIEWED
```

Nicht als `VALIDATED` zu bezeichnen, bevor der dokumentierte DCS-Test gelaufen ist.

### `FLIGHTGROUP:GetGroup()` / `GROUP:GetUnits()`

Der AIRWING-Callback liefert die reale `FLIGHTGROUP`-Instanz. Der Harness verwendet den oeffentlichen Wrapper-Pfad:

```text
FLIGHTGROUP:GetGroup()
-> GROUP:GetUnits()
-> UNIT wrappers
```

`GROUP:GetUnits()` liefert laut gepinntem Quellcode eine numerisch indexierte Liste von `UNIT`-Wrappern fuer die aktuellen DCS-Units der Gruppe.

## Abgrenzung zu `OPSGROUP:Destroy()`

Der gepruefte `OPSGROUP:Destroy()`-Pfad delegiert je Unit an `DestroyUnit()`. Fuer Flightgroups erzeugt dieser Pfad ein `UnitLost`-Event und entfernt die DCS-Unit anschliessend programmgesteuert.

Daher gilt fuer OMW:

```text
OPSGROUP:Destroy()
!= belastbarer Proxy fuer physischen Crash/Totalverlust
```

Der frueher damit beobachtete STORAGE-Recredit bleibt reale Evidenz fuer den programmgesteuerten Loss-/Removal-Pfad, darf aber nicht auf physisch zerstoerte Assets verallgemeinert werden.

## Testpfad

```text
AIRWING:AddMission(AUFTRAG)
-> OnAfterFlightOnMission
-> bestaetigter STORAGE Materialization Debit
-> FLIGHTGROUP:GetGroup()
-> GROUP:GetUnits()
-> UNIT:Explode(1500)
-> DCS damage/death lifecycle
-> STORAGE:GetInventory()
-> Recredit-Klassifikation
```

Der Harness schreibt weder in STORAGE noch in CampaignState und ruft `ReturnToLegion()` nicht selbst auf.

## Offene Runtime-Frage

Zu bestimmen ist ausschliesslich:

```text
Werden bei real physisch zerstoertem Aircraft
- Aircraft item,
- Fuel/Liquid,
- externe Stores
von DCS/STORAGE ganz, teilweise oder gar nicht zurueckgebucht?
```

Erst danach kann die strategische CampaignState-Loss-Semantik abschliessend beschlossen werden.
