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
ZONE_BASE:GetVec2()
ZONE_BASE:IsVec2InZone(...)
COORDINATE:WaypointGround(speed, formation)
CONTROLLABLE:OptionFormationInterval(meters)
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:Route(...)
```

`OptionFormationInterval` ist eine Ground-Option und akzeptiert im gepinnten Source 0 bis 100 Meter.

Der gepinnte `WAREHOUSE:_SpawnAssetGroundNaval(...)` waehlt fuer Ground-Assets einen Zufallspunkt in der Spawn-Zone und uebertraegt die relative Geometrie des Templates auf diesen Punkt. Er bietet damit keinen oeffentlichen Parameter, um die neun Infanteristen exakt kompakt auszurichten.

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

Korrigierte Spawn-Geometrie nach dem realen Precheck-FAIL vom 12.09.2026:

```text
- Materialisierungsanker: Zentrum der bestehenden ACCESS-Zone;
- alle neun Infanteristen in einer schmalen, um den ACCESS-Mittelpunkt zentrierten Linie;
- Heading weiterhin aus PATHLINE Punkt 1 -> Punkt 2;
- Zielabstand: 2 m;
- falls die Linie nicht vollstaendig in ACCESS passt: schrittweise Reduktion bis mindestens 0,75 m;
- jeder vorbereitete Spawnpunkt muss innerhalb der bestehenden ACCESS-Zone liegen;
- nach Materialisierung Route vom realen Spawnpunkt zu PATHLINE Punkt 1 und danach entlang der vollstaendigen owner-authored PATHLINE;
- keine neue Mission-Editor-Zone und keine MIZ-Mutation.
```

Damit sind die Rollen explizit getrennt:

```text
ACCESS = zulaessige Materialisierungsflaeche
PATHLINE = owner-authored Bewegungsroute und Ausrichtungsreferenz
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
- kompakte PATHLINE-heading-ausgerichtete Materialisierung innerhalb ACCESS wurde ausgefuehrt;
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

## Reale DCS-Evidenz 2026-09-12 - erster Acceptance-2-Lauf

Der erste reale Acceptance-2-Lauf erreichte die Materialisierung nicht. DCS meldete:

```text
2026-09-12 16:32:20.418 ... [GATE 5][FAIL] JALALABAD_FENTY SPAWN_OUTSIDE_ACCESS_1
```

Die vom Projektinhaber gelieferte Mission wurde read-only geprueft:

```text
Mission: OMW_Template_v24_GroundWorks_base.miz
Uploaded-copy SHA-256: DEB7ABEAB39DFE386D54CD606C838F50BBDBB2A147EE3BA011F269037113C85B
```

Ergebnis der Geometriepruefung: Das erste Segment von `OMW_RTE_BLUE_GUARD_FENTY_01` liegt nicht innerhalb von `ZON_BLUE_GND_FENTY_ACCESS`. Der vorherige Acceptance-Code koppelte daher zwei unvereinbare Annahmen und brach beim ersten Site-Setup ab. Deshalb wurden in diesem Lauf **keine** Guards materialisiert; ein Six-Site-Bewegungsergebnis liegt aus diesem Lauf nicht vor.

Ausfuehrliche Evidenz:

```text
results/2026-09-12-gate5-acceptance2-spawn-precheck-failure.md
```

## Vorherige lokale Build-Evidenz

Der vor dem realen Precheck-FAIL gebaute Stand war:

```text
Git HEAD:
e5b1a79e5bdb6e9ba4479ebc9e35d76ba5dddab2

BuilderVersion:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-2

TestId:
FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-2

SpawnAlignment:
PATHLINE_FIRST_SEGMENT

Bundle SHA-256:
D30E63BFFCC506EB579FAE3AF662D6EED8C2C0D06DD5F57C0F22C12BA026390C
```

Dieser Build ist jetzt als DCS-FAIL fuer den dokumentierten Precheck-Scope eingeordnet. Der korrigierte Builder ist Version 3 mit:

```text
SpawnAlignment: ACCESS_CENTER_PATHLINE_HEADING
```

Der korrigierte Stand benoetigt einen neuen realen Owner-Build mit neuen Hashes und danach einen neuen DCS-Lauf. Bis dahin bleibt `validated_in_dcs: false` fuer die korrigierte Acceptance-2-Fassung.
