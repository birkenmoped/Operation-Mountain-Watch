---
document_id: OMW-MOOSE-GATE5-GUARD-COMPACT-ALIGNED-MATERIALIZATION
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 Acceptance-2 Guard compact/aligned materialization source review
  - exact Builder-4 DCS validation evidence for compact PATHLINE-aligned Guard materialization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: a7944a995954a962d2a3b33b7a6d4c459d845f1e
acceptance_mission: OMW_Template_v24_GroundWorks_base.miz
acceptance_mission_sha256: 865bcb91fd3ef8f81e71e3acef0e0e0a7bf74737117549f7e059815c94929f91
dcs_version: 2.9.29.27468
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Gate 5 Guard – compact/aligned Materialisierung

## Zweck

Diese Notiz dokumentiert den MOOSE-first-Pfad für Gate 5 Acceptance 2. Anlass ist die reale Acceptance-1-Evidenz, bei der alle sechs Guards materialisiert und geroutet wurden, einzelne Gruppen aber je nach Lauf trotz `routeStarted=true` praktisch keine Bewegung zeigten.

Der Projektinhaber entschied am 12.09.2026, dass Guards eng und entlang ihrer bestehenden owner-authored Guard-PATHLINE ausgerichtet materialisiert werden sollen.

## Verbindliche Owner-Korrektur: ACCESS gehört nicht zum Guard-Vertrag

Der Projektinhaber stellte am 12.09.2026 ausdrücklich klar:

```text
ZON_BLUE_GND_<SITE>_ACCESS wurde für Convoys/Zufahrt angelegt.
Diese Zonen haben mit Guards und Guard-Routen nichts zu tun.
Sie liegen regelmäßig nicht auf den Guard-PATHLINEs.
```

Daraus folgt für Gate 5:

```text
Guard spawn geometry = Guard PATHLINE
Guard movement geometry = Guard PATHLINE
ZON_BLUE_GND_<SITE>_ACCESS = für diesen Guard-Scope irrelevant
```

Die zwischenzeitliche Annahme, ACCESS als zulässige Guard-Materialisierungsfläche oder als Guard-Spawn-Anker zu behandeln, war falsch. Auch die daraus abgeleitete Zwischenkorrektur `ACCESS_CENTER_PATHLINE_HEADING` ist verworfen und darf nicht getestet oder produktiv übernommen werden.

## Gepinnter MOOSE-Stand

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Public-MOOSE-Pfad

Source-geprüft für Acceptance 2:

```text
PATHLINE:GetCoordinates()
COORDINATE:WaypointGround(speed, formation)
CONTROLLABLE:OptionFormationInterval(meters)
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:Route(...)
BRIGADE / PLATOON / AUFTRAG:NewONGUARD lifecycle
```

Die Route bleibt `Off Road`, damit die vorhandene Guard-PATHLINE und nicht das DCS-Straßennetz die Bewegung vorgibt.

## Verifizierte MOOSE-Lücke im Materialisierungspfad

Der gepinnte `WAREHOUSE:_SpawnAssetGroundNaval(...)` behält ohne Adapter die relative Template-Geometrie bei und bietet keinen öffentlichen Parameter, um die einzelnen Unit-Positionen und Headings eines mehrgliedrigen Ground-Assets exakt entlang des ersten Segments einer owner-authored PATHLINE festzulegen.

## Wiederverwendete genehmigte Ausnahme

ARMY Ground Acceptance 3-2 hat nach ausdrücklicher Owner-Freigabe vom 19.08.2026 einen kleinen Adapter um den privaten MOOSE-WAREHOUSE-Spawn-Schritt verwendet. Dabei blieben erhalten:

```text
BRIGADE
WAREHOUSE lifecycle
Asset reservation / request handling
PLATOON / ARMYGROUP lifecycle
MOOSE mission execution
```

Nur die unmittelbar vor Materialisierung verwendeten Unit-Positionen/Headings wurden kontrolliert gesetzt. Gate 5 Acceptance 2 verwendet dieses bereits genehmigte Muster erneut, jetzt für Guard-Infanterie und ausschließlich im dokumentierten Acceptance-Scope.

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
Guard ACCESS-zone dependency: none
```

Es werden keine neuen Mission-Editor-Objekte erzeugt und keine `.miz` verändert.

## Reale DCS-Evidenz und Fehlerklassifikation

Der erste Acceptance-2-Lauf brach vor der Materialisierung mit

```text
JALALABAD_FENTY SPAWN_OUTSIDE_ACCESS_1
```

ab. Das war kein Guard-/PATHLINE-/Warehouse-Runtime-Nachweis, sondern ein Testfehler: Der Code koppelte Guard-PATHLINE-Geometrie fälschlich an die Convoy-ACCESS-Zone.

Der korrigierte Builder 4 enthält deshalb zusätzlich eine Anti-Regression-Prüfung, die Guard-Code mit `ZONE:FindByName(site.accessZoneName)`, `SetSpawnZone(access)`, `ACCESS_CENTER` oder `IsVec2InZone(` ablehnt.

## Reale Builder-4-DCS-Validierung

Owner-local Build-HEAD:

```text
a7944a995954a962d2a3b33b7a6d4c459d845f1e
```

Bundle SHA-256:

```text
E1CBF5341D608714C912380FA4806D73BFBF42BBE5F2D0E8513298C96555E9DC
```

Der korrigierte DCS-Lauf meldete nach der 300-Sekunden-Beobachtung:

```text
[GATE 5][PASS] 6/6 Guards compact/aligned and >=25 m movement observed
```

Checkpoint:

```text
JALALABAD_FENTY   movementM=176.2
COP_FORTRESS      movementM=195.1
FOB_JOYCE         movementM=195.6
FOB_WRIGHT        movementM=235.0
COP_HONAKER       movementM=165.6
FOB_BOSTICK       movementM=137.1
```

Alle sechs Gruppen waren am Checkpoint alive, `routeStarted=true` und deutlich über dem geforderten Mindestweg. Der Projektinhaber bestätigte für denselben Lauf zusätzlich, dass visuell keine Probleme auszumachen waren. Damit ist der Acceptance-2-Scope einschließlich visueller Hindernis-/Formationskontrolle erfüllt.

## Statusgrenze

```text
SOURCE_REVIEWED: PASS
OWNER-LOCAL BUILD: PASS
DCS ACCEPTANCE-2 BUILDER 4: VALIDATED / PASS
```

Diese Validierung ist eng auf den Acceptance-2-Scope begrenzt. Sie ist keine produktive Generalfreigabe der privaten MOOSE-Warehouse-Materialisierungsstelle.