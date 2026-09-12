---
document_id: OMW-MOOSE-GATE5-GUARD-COMPACT-ALIGNED-MATERIALIZATION
status: SOURCE_REVIEWED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 Acceptance-2 Guard compact/aligned materialization source review
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5 Guard – compact/aligned Materialisierung

## Zweck

Diese Notiz dokumentiert den MOOSE-first-Pfad fuer Gate 5 Acceptance 2. Anlass ist die reale Acceptance-1-Evidenz, bei der alle sechs Guards materialisiert und geroutet wurden, einzelne Gruppen aber je nach Lauf trotz `routeStarted=true` praktisch keine Bewegung zeigten.

Der Projektinhaber entschied deshalb am 12.09.2026, dass Guards eng und entlang ihrer bestehenden owner-authored Guard-PATHLINE ausgerichtet materialisiert werden sollen, analog zum bereits DCS-erprobten Strassenkonvoi-Spawnprinzip.

## Gepinnter MOOSE-Stand

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Public-MOOSE-Pfad

Source-geprueft fuer Acceptance 2:

```text
PATHLINE:GetCoordinates()
COORDINATE:WaypointGround(speed, formation)
CONTROLLABLE:OptionFormationInterval(meters)
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:Route(...)
BRIGADE / PLATOON / AUFTRAG:NewONGUARD lifecycle
```

`OptionFormationInterval(meters)` ist im gepinnten Source eine Ground-Option. Zulaessig sind 0 bis 100 Meter; ausserhalb dieses Bereichs faellt MOOSE auf 50 Meter zurueck. Acceptance 2 verwendet 2 Meter.

Die Route bleibt `Off Road`, damit die vorhandene Guard-PATHLINE und nicht das DCS-Strassennetz die Bewegung vorgibt.

## Verifizierte MOOSE-Luecke im Materialisierungspfad

Der gepinnte `WAREHOUSE:_SpawnAssetGroundNaval(...)`:

1. bereitet das Asset-Template vor;
2. waehlt einen Zufallspunkt aus der Warehouse-Spawn-Zone;
3. verschiebt alle Template-Units relativ zu diesem Zufallspunkt;
4. behaelt damit die relative Template-Geometrie bei;
5. materialisiert anschliessend die Gruppe.

Dieser Pfad besitzt keinen oeffentlichen Parameter, um fuer ein mehrgliedriges Ground-Asset die einzelnen Unit-Positionen und Headings exakt entlang des ersten Segments einer owner-authored PATHLINE festzulegen.

## Wiederverwendete genehmigte Ausnahme

ARMY Ground Acceptance 3-2 hat nach ausdruecklicher Owner-Freigabe vom 19.08.2026 einen kleinen Adapter um den privaten MOOSE-WAREHOUSE-Spawn-Schritt verwendet. Dabei blieben erhalten:

```text
BRIGADE
WAREHOUSE lifecycle
Asset reservation / request handling
PLATOON / ARMYGROUP lifecycle
MOOSE mission execution
```

Nur die unmittelbar vor Materialisierung verwendeten Unit-Positionen/Headings wurden kontrolliert gesetzt. Gate 5 Acceptance 2 verwendet dieses bereits genehmigte Muster erneut, jetzt fuer Guard-Infanterie und ausschliesslich im dokumentierten Acceptance-Scope.

Keine generelle Produktionsfreigabe privater MOOSE-Methoden wird daraus abgeleitet.

## Acceptance-2-Konfiguration

```text
Spawn basis: first segment of existing OMW_RTE_BLUE_GUARD_<SITE>_01
Target spacing: 2 m
Minimum adaptive spacing: 0.75 m
Heading: PATHLINE point 1 -> point 2
Movement formation: Off Road
MOOSE formation interval: 2 m
Observation: 300 s
Minimum movement: 25 m per Guard
```

Alle vorbereiteten Spawnpunkte muessen innerhalb der bereits bestehenden ACCESS-Zone liegen. Es werden keine neuen Mission-Editor-Objekte erzeugt und keine `ZON_BLUE_GND_<SITE>_ALARM`-Objekte eingefuehrt.

## Statusgrenze

```text
SOURCE_REVIEWED / STAGED
DCS VALIDATION: pending
```

Erst ein realer Acceptance-2-Lauf kann bestaetigen, ob die kompakte PATHLINE-ausgerichtete Materialisierung die beobachteten Festsitz-Symptome behebt.
