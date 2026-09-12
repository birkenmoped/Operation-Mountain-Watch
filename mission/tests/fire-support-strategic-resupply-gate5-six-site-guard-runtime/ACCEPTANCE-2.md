---
document_id: OMW-FIRE-SUPPORT-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2
status: ACCEPTED_TECHNICAL_BASELINE
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
validated_in_dcs: true
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: a7944a995954a962d2a3b33b7a6d4c459d845f1e
acceptance_mission: OMW_Template_v24_GroundWorks_base.miz
acceptance_mission_sha256: 865bcb91fd3ef8f81e71e3acef0e0e0a7bf74737117549f7e059815c94929f91
dcs_version: 2.9.29.27468
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Gate 5 - Six-Site Guard Runtime Acceptance 2

## Anlass und Lernpunkt

Acceptance 1 hat die Six-Site-Pipeline grundsätzlich bestätigt: alle sechs Guard-Aufträge wurden erzeugt, alle sechs vorhandenen `OMW_RTE_BLUE_GUARD_*_01`-PATHLINEs wurden aufgelöst und Guards wurden materialisiert. Die reale DCS-Evidenz zeigte jedoch standortabhängig praktisch keine Bewegung einzelner Gruppen. In verschiedenen Läufen betraf dies unter anderem Fenty beziehungsweise Fortress, obwohl `routeStarted=true` und die Gruppe lebte.

Der Projektinhaber legte am 12.09.2026 fest, dass Guard-Gruppen eng formiert und entlang der vorhandenen Guard-Route ausgerichtet materialisiert werden sollen, damit Infanterie nicht bereits beim Spawn in Gebäuden, HESCOs oder anderen Statics festhängt.

Wichtige Owner-Korrektur vom selben Tag:

```text
ZON_BLUE_GND_<SITE>_ACCESS ist ein Convoy-/Zufahrtsvertrag.
Diese ACCESS-Zonen gehören nicht zum Guard-Vertrag.
Guard-Materialisierung darf weder an ACCESS gebunden noch gegen ACCESS validiert werden.
```

Damit gilt für Acceptance 2 ausschließlich die vorhandene owner-authored Guard-PATHLINE als räumliche Guard-Referenz.

## MOOSE-first-Prüfung

Im gepinnten MOOSE-Stand wurden für diesen Schritt bestätigt:

```text
PATHLINE:GetCoordinates()
COORDINATE:WaypointGround(speed, formation)
CONTROLLABLE:OptionFormationInterval(meters)
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:Route(...)
```

Der gepinnte `WAREHOUSE:_SpawnAssetGroundNaval(...)` bietet keinen öffentlichen Parameter, um die einzelnen Unit-Positionen und Headings eines mehrgliedrigen Ground-Assets exakt entlang eines owner-authored PATHLINE-Segments festzulegen.

Für Acceptance 2 wird deshalb nur im dokumentierten Testscope das bereits am 19.08.2026 vom Projektinhaber genehmigte und in ARMY Ground Acceptance 3-2 DCS-erprobte Adaptermuster wiederverwendet. BRIGADE-/WAREHOUSE-/PLATOON-/ARMYGROUP-/AUFTRAG-Lifecycle bleiben erhalten; unmittelbar vor der Materialisierung werden nur die Unit-Positionen und Headings kontrolliert gesetzt.

Dies ist keine generelle Produktionsfreigabe privater MOOSE-Methoden.

## Materialisierungsvertrag

Pro Site:

```text
bestehende OMW_RTE_BLUE_GUARD_<SITE>_01
+ TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> 1 BRIGADE / 1 PLATOON / 1 ONGUARD-Auftrag
```

Spawn-Geometrie:

```text
- Basis: erstes Segment der bestehenden owner-authored Guard-PATHLINE;
- alle neun Infanteristen in einer schmalen Linie auf diesem Segment;
- Zielabstand: 2 m;
- bei kurzem ersten Segment adaptive Reduktion bis mindestens 0,75 m;
- identisches Heading PATHLINE Punkt 1 -> Punkt 2;
- keine Prüfung gegen ZON_BLUE_GND_<SITE>_ACCESS;
- kein SetSpawnZone(...) auf die Convoy-ACCESS-Zone;
- keine neue Mission-Editor-Zone und keine MIZ-Mutation.
```

Nach Materialisierung:

```text
Formation: Off Road
MOOSE OptionFormationInterval: 2 m
Speed: 5 km/h
Route: vorhandene Guard-PATHLINE
```

`On Road` wird absichtlich nicht verwendet, weil die owner-authored Guard-PATHLINE und nicht das DCS-Straßennetz führend sein soll.

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

Zusätzliche Log-Evidenz:

```text
COMPACT_SPAWN_PREPARED
COMPACT_ALIGNED_WAREHOUSE_SPAWN
GUARD_MISSION_ADDED
TELEMETRY
```

## PASS-Kriterien

PASS nur wenn für alle sechs Sites gilt:

```text
- kompakte PATHLINE-ausgerichtete Materialisierung wurde ausgeführt;
- Guard lebt;
- Route wurde gestartet;
- mindestens 25 m physische Bewegung innerhalb von 300 Sekunden.
```

Zusätzlich wird visuell beurteilt, ob die Infanteristen beim Spawn und Anlaufen nicht in HESCOs/Gebäuden/Statics festhängen und die Formation hinreichend kompakt bleibt.

## Exclusions

Nicht Bestandteil dieses Tests:

```text
- Convoy-ACCESS-Zonen;
- Alarm-/OPSZONE-Stimulus;
- QRF;
- lokale/externe ARTY;
- CAS;
- Resupply;
- CampaignState-Settlement;
- Mission-Editor-Änderung;
- Produktionsfreigabe des test-spezifischen Warehouse-Adapters.
```

## Reale DCS-Evidenz 2026-09-12 - erster Acceptance-2-Lauf

Der erste reale Acceptance-2-Lauf erreichte die Materialisierung nicht. DCS meldete:

```text
[GATE 5][FAIL] JALALABAD_FENTY SPAWN_OUTSIDE_ACCESS_1
```

Dieser FAIL wurde durch eine falsche Testannahme verursacht: Der Acceptance-Code verlangte, dass PATHLINE-basierte Guard-Spawnpunkte zugleich innerhalb `ZON_BLUE_GND_FENTY_ACCESS` liegen. Der Projektinhaber stellte anschließend klar, dass die `ZON_BLUE_GND_<SITE>_ACCESS`-Zonen ausschließlich Convoy-/Zufahrtszwecken dienen und mit Guard-Routen nichts zu tun haben.

Folge:

```text
Acceptance-2 Build 2: DCS FAIL vor Materialisierung
Ursache: fehlerhafte ACCESS-Abhängigkeit im Testcode
Guard-Lifecycle: nicht bewertet
Movement: nicht bewertet
```

Die unmittelbar danach erstellte Zwischenkorrektur `ACCESS_CENTER_PATHLINE_HEADING` war ebenfalls fachlich falsch und darf nicht getestet oder als Baseline verwendet werden.

## Builder-4-Provenance

```text
Owner-local build HEAD:
a7944a995954a962d2a3b33b7a6d4c459d845f1e

BuilderVersion:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-4

SpawnAlignment:
PATHLINE_FIRST_SEGMENT

GuardAccessZoneDependency:
none

Bundle SHA-256:
E1CBF5341D608714C912380FA4806D73BFBF42BBE5F2D0E8513298C96555E9DC

Acceptance-2 source SHA-256:
DDADEA6531EA05A31E836EC0AC35319F83673B9AC4B16D2465A9E218E2C1AE36

Builder SHA-256:
BC6A28F1D167BB4DF768D8FB3F6FAAE60468B7111C77313BCE9715E1186D4D59
```

Pinned MOOSE:

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Reale DCS-Evidenz 2026-09-12 - korrigierter Builder-4-Lauf

Der korrigierte ACCESS-freie Lauf erreichte den vollständigen Acceptance-Checkpoint und meldete:

```text
[GATE 5][PASS] 6/6 Guards compact/aligned and >=25 m movement observed
```

Checkpoint-Telemetrie:

```text
JALALABAD_FENTY   alive=true  routeStarted=true  movementM=176.2
COP_FORTRESS      alive=true  routeStarted=true  movementM=195.1
FOB_JOYCE         alive=true  routeStarted=true  movementM=195.6
FOB_WRIGHT        alive=true  routeStarted=true  movementM=235.0
COP_HONAKER       alive=true  routeStarted=true  movementM=165.6
FOB_BOSTICK       alive=true  routeStarted=true  movementM=137.1
```

Damit haben alle sechs Guard-Gruppen die geforderten 25 m innerhalb der 300-Sekunden-Beobachtung deutlich überschritten, lebten am Checkpoint und hatten ihre Route gestartet.

Der Projektinhaber bestätigte anschließend für denselben Lauf die visuelle Prüfung mit der Aussage, dass keine Probleme auszumachen waren. Damit ist auch das visuelle Kriterium hinsichtlich offensichtlichem Festhängen in HESCOs/Gebäuden/Statics beziehungsweise auffälliger Formation erfüllt.

Vollständiges Ergebnis:

```text
6/6 compact PATHLINE-aligned materialization: PASS
6/6 alive: PASS
6/6 routeStarted: PASS
6/6 >=25 m within 300 s: PASS
Visual obstacle/formation check: PASS
Guard ACCESS-zone dependency: none
Acceptance 2 exact scope: VALIDATED / PASS
```

Ergebnisdokument:

```text
results/2026-09-12-gate5-acceptance2-builder4-dcs-pass.md
```

Die Validierung gilt ausschließlich für den dokumentierten Acceptance-2-Scope und ist keine produktive Generalfreigabe des test-spezifischen privaten Warehouse-Materialisierungsadapters.