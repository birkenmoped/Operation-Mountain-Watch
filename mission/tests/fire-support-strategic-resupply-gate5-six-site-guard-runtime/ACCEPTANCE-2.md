---
document_id: OMW-FIRE-SUPPORT-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 compact PATHLINE-aligned six-site Guard acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5 - Six-Site Guard Runtime Acceptance 2

## Anlass und Lernpunkt

Acceptance 1 hat die Six-Site-Pipeline grundsätzlich bestätigt: alle sechs Guard-Aufträge wurden erzeugt, alle sechs vorhandenen `OMW_RTE_BLUE_GUARD_*_01`-PATHLINEs wurden aufgelöst und Guards wurden materialisiert. Die reale DCS-Evidenz zeigte jedoch standortabhängig praktisch keine Bewegung einzelner Gruppen. In verschiedenen Läufen betraf dies unter anderem Fenty beziehungsweise Fortress, obwohl `routeStarted=true` und die Gruppe lebte.

Damit ist die nächste Frage nicht mehr, ob die sechs Sites und PATHLINEs existieren, sondern ob die Guard-Materialisierung innerhalb dichter FOB/COP-Geometrie robust genug erfolgt.

Der Projektinhaber legte am 12.09.2026 fest:

```text
Guard-Gruppen sollen eng formiert und entlang der vorhandenen Guard-Route ausgerichtet materialisiert werden,
aehnlich dem bereits fuer Strassenkonvois praktisch bestaetigten Spawn-Prinzip,
damit Infanterie nicht bereits beim Spawn in Gebaeuden, HESCOs oder anderen Statics festhaengt.
```

Diese Entscheidung ist Bestandteil dieses Acceptance-Scope.

## MOOSE-first-Pruefung

Im gepinnten MOOSE-Stand wurden fuer diesen Schritt bestaetigt:

```text
PATHLINE:GetCoordinates()
COORDINATE:WaypointGround(speed, formation)
CONTROLLABLE:OptionFormationInterval(meters)
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:Route(...)
```

`OptionFormationInterval` ist eine Ground-Option und akzeptiert im gepinnten Source 0 bis 100 Meter.

Der gepinnte `WAREHOUSE:_SpawnAssetGroundNaval(...)` waehlt fuer Ground-Assets einen Zufallspunkt in der Spawn-Zone und uebertraegt die relative Geometrie des Templates auf diesen Punkt. Er bietet damit keinen oeffentlichen Parameter, um die neun Infanteristen exakt kompakt entlang des ersten Guard-PATHLINE-Segments auszurichten.

Fuer Acceptance 2 wird deshalb **nur in diesem Test-Scope** das bereits am 19.08.2026 vom Projektinhaber genehmigte und in ARMY Ground Acceptance 3-2 DCS-erprobte Adaptermuster wiederverwendet: der BRIGADE/WAREHOUSE-Lifecycle bleibt erhalten, waehrend die MOOSE-Warehouse-Materialisierung die vorbereiteten absoluten Positionen/Headings erhaelt.

Dies ist keine neue generelle Freigabe fuer private MOOSE-Methoden und keine Produktionsentscheidung ueber diesen dokumentierten Scope hinaus.

## Materialisierungsvertrag

Pro Site:

```text
bestehende ACCESS-Zone
+ bestehende OMW_RTE_BLUE_GUARD_<SITE>_01
+ TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> 1 BRIGADE / 1 PLATOON / 1 ONGUARD-Auftrag
```

Spawn-Geometrie:

```text
- Basis: erstes Segment der vorhandenen owner-authored Guard-PATHLINE;
- alle neun Infanteristen in einer schmalen Linie entlang dieses Segments;
- Zielabstand: 2 m, bei kurzem erstem Segment automatisch kleiner;
- Mindestabstand fuer diesen Test: 0,75 m;
- alle Einheiten identisch in Fahr-/Laufrichtung PATHLINE Punkt 1 -> Punkt 2 ausgerichtet;
- jeder vorbereitete Spawnpunkt muss innerhalb der bestehenden ACCESS-Zone liegen;
- keine neue Mission-Editor-Zone und keine MIZ-Mutation.
```

Nach Materialisierung:

```text
Formation: Off Road
MOOSE OptionFormationInterval: 2 m
Speed: 5 km/h
Route: vorhandene Guard-PATHLINE
```

`On Road` wird absichtlich nicht verwendet, weil die owner-authored Guard-PATHLINE und nicht das DCS-Strassennetz fuehrend sein soll.

## Testumfang

Sites:

```text
JALALABAD_FENTY
COP_FORTRESS
FOB_JOYCE
FOB_WRIGHT
COP_HONAKER
FOB_BOSTICK
```

Beobachtung:

```text
300 Sekunden
Telemetry: 30 Sekunden
Mindestbewegung: 25 m pro Guard-Gruppe
```

Zusaetzliche Log-Evidenz:

```text
COMPACT_SPAWN_PREPARED
COMPACT_ALIGNED_WAREHOUSE_SPAWN
GUARD_MISSION_ADDED
TELEMETRY
```

## PASS

PASS nur wenn fuer alle sechs Sites gilt:

```text
- kompakte PATHLINE-ausgerichtete Materialisierung wurde ausgefuehrt;
- Guard lebt;
- Route wurde gestartet;
- mindestens 25 m physische Bewegung innerhalb von 300 Sekunden.
```

Zusätzlich wird visuell beurteilt, ob die Infanteristen beim Spawn und Anlaufen nicht in HESCOs/Gebaeuden/Statics festhaengen und die Formation hinreichend kompakt bleibt.

## Exclusions

Nicht Bestandteil dieses Tests:

```text
- Alarm-/OPSZONE-Stimulus;
- QRF;
- lokale/externe ARTY;
- CAS;
- Resupply;
- CampaignState-Settlement;
- Mission-Editor-Aenderung;
- Produktionsfreigabe des test-spezifischen Warehouse-Adapters.
```

## Builder

```text
tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
```

Output bleibt bewusst identisch:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua
```

Pinned MOOSE:

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Lokale Build-Evidenz 2026-09-12

Der Projektinhaber hat den Acceptance-2-Builder lokal auf folgendem exakten Branch-Stand ausgefuehrt:

```text
Git HEAD:
e5b1a79e5bdb6e9ba4479ebc9e35d76ba5dddab2

BuilderVersion:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-2

TestId:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

Formation:
Off Road

FormationIntervalM:
2

SpawnAlignment:
PATHLINE_FIRST_SEGMENT

Encoding:
UTF-8 without BOM

MIZ mutation:
false
```

Reale lokale Hashes:

```text
Bundle:
D30E63BFFCC506EB579FAE3AF662D6EED8C2C0D06DD5F57C0F22C12BA026390C

Acceptance-2 source:
1BF6A18992355B150CF2C5507636497141A3C2A9BBDF771D8E447D61C77AE9F5

Builder:
50001FC4DCC1976F024F29CC88B5BDA6BF3B0C18528763C26345ADCB178E7846
```

Der Build war erfolgreich. Der lokale Worktree enthielt danach ausschliesslich die erwarteten untracked `dist/`-Verzeichnisse fuer vorhandene Acceptance-Bundles.

GitHub-CI fuer denselben funktionalen Stand war erfolgreich:

```text
Documentation validation: PASS
MissionDemand validation: PASS
```

Diese Evidenz belegt Build und Artefakt-Provenienz. Sie ist **kein DCS-Runtime-PASS**; `validated_in_dcs` bleibt bis zum dokumentierten Acceptance-2-Lauf `false`.
