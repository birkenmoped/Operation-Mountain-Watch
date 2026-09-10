---
document_id: OMW-MOOSE-STAGE3-GUARD-PATHLINE-RECONCILIATION
status: PLANNED
document_class: MOOSE_TECHNICAL_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 Honaker Guard physical source and owner-authored PATHLINE interpretation
  - pinned-MOOSE public routing composition selected for the next Stage 3 acceptance build
  - current Mission Editor evidence for TPL_BLUE_GND_QRF_MIXED_6
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# Stage 3 – Honaker Guard PATHLINE Reconciliation

## 1. Anlass

Build `1-12` brach im Stage-3-Preflight mit einer irreführenden Meldung für `OMW_RTE_BLUE_GUARD_HONAKER_01` ab. Der Name wurde im Acceptance-Source als DCS/MOOSE `GROUP` behandelt. Der reale MOOSE-Log und die anschließend direkt geprüfte aktuelle Missionsdatei zeigen dagegen eindeutig, dass dieses Objekt eine Mission-Editor-Line-Drawing/PATHLINE ist.

Diese Reconciliation ersetzt keine DCS-Acceptance. Sie dokumentiert die Source-/Mission-Editor-Grundlage für den nächsten Build.

## 2. Geprüfte Missionsdatei

Aktuelle vom Projektinhaber bereitgestellte Mission:

```text
OMW_Template_v21_GroundWorks.miz
```

Die Datei wurde ausschließlich gelesen und als ZIP/Mission-Datenquelle ausgewertet. Es erfolgte keine `.miz`-Mutation.

Festgestellte Mission-Editor-Fakten:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
  object kind: drawing primitive / Line
  closed: true
  points: 13
  MOOSE interpretation: PATHLINE
```

Damit gilt zwingend:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
= route geometry
!= physical Guard GROUP
```

Die Mission enthält keinen dediziert nach `HONAKER` benannten physischen Guard-GROUP, der mit dieser PATHLINE identisch wäre.

## 3. Physischer Guard-Vertrag

Die branch-eigene Stage-3-Historie vor der fehlerhaften Build-1-11-Umstellung enthält bereits den vorgesehenen physischen Guard-Materialisierungspfad:

```lua
PLATOON:New("TPL_BLUE_GND_INF_RIFLE_SQUAD_9", 1, "PLT_BLUE_GND_HONAKER_STAGE3_GUARD")
```

mit Honaker `BRIGADE`, `AUFTRAG.Type.ONGUARD` und anschließendem `ArmyOnMission`-Lifecycle.

Die aktuelle Ground-Baseline führt `TPL_BLUE_GND_INF_RIFLE_SQUAD_9` als wiederverwendbares Infanterie-Template. Deshalb wird für den Stage-3-Acceptance-Guard **kein neuer physischer Gruppentyp erfunden**. Verwendet wird wieder der bereits vorgesehene Honaker-Guard-PLATOON aus diesem Template.

Trennung:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
-> physical Guard asset source

PLT_BLUE_GND_HONAKER_STAGE3_GUARD
-> MOOSE PLATOON / operational materialization source

OMW_RTE_BLUE_GUARD_HONAKER_01
-> owner-authored patrol geometry as MOOSE PATHLINE
```

## 4. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich gepinnten Source wurden für den Guard-Pfad verifiziert:

```lua
PATHLINE:FindByName(name)
PATHLINE:GetCoordinates()
COORDINATE:WaypointGround(speedKmh, formation, dcsTasks)
CONTROLLABLE:TaskFunction(functionString, ...)
CONTROLLABLE:SetTaskWaypoint(waypoint, task)
CONTROLLABLE:Route(route, delaySeconds)
OPSGROUP:GetGroup()
```

`CONTROLLABLE:PatrolRoute()` wurde ebenfalls geprüft. Diese Methode liest mit `GetTemplateRoutePoints()` die Route der physischen GROUP selbst. Sie ist deshalb **nicht** der passende direkte Consumer für eine separat im Mission Editor gezeichnete `PATHLINE`.

## 5. MOOSE-first Routingentscheidung für Build 1-13

Für den nächsten Source-Review-/DCS-Pending-Stand wird die externe PATHLINE ausschließlich über öffentliche MOOSE-APIs in eine Ground-Route übersetzt:

```text
PATHLINE:FindByName
-> PATHLINE:GetCoordinates
-> COORDINATE:WaypointGround
-> physical Guard GROUP from ArmyOnMission
-> CONTROLLABLE:TaskFunction("CONTROLLABLE.Route", route, delay)
-> CONTROLLABLE:SetTaskWaypoint(lastWaypoint, repeatTask)
-> CONTROLLABLE:Route(route, delay)
```

Der `TaskFunction`-Aufruf am letzten Wegpunkt startet dieselbe MOOSE-Route erneut und bildet damit den geforderten wiederholten Circuit. Die gepinnte `Moose.lua` dokumentiert den allgemeinen `TaskFunction`/`SetTaskWaypoint`/`Route`-Mechanismus selbst; es wird kein eigener DCS-Controller, kein `coalition.addGroup`, kein `Controller:setTask`-Parallelpfad und kein Patrol-Polling-Scheduler eingeführt.

Status dieses konkreten Zusammenspiels:

```text
MOOSE API existence/signatures       SOURCE VERIFIED
MOOSE-only composition               SOURCE REVIEWED
Honaker PATHLINE object/type          MISSION FILE VERIFIED
physical Guard route behavior         DCS PENDING
Afghanistan pathfinding               DCS PENDING
repeated circuit behavior             DCS PENDING
```

## 6. QRF-Reconciliation derselben Missionsdatei

Die aktuelle Mission enthält:

```text
TPL_BLUE_GND_QRF_MIXED_6
```

als late-activated DCS GROUP mit sechs Units. Die direkt gelesene Mission-Editor-Zusammensetzung ist:

```text
1 x CHAP_MATV
3 x Soldier M4
2 x Soldier M249
```

also insgesamt:

```text
5 infantry + 1 M-ATV/MRAP-class vehicle
```

Der owner-approved Stage-3-Vertrag bleibt:

```text
one DCS/MOOSE GROUP
no embark/disembark
5 GROUND_PERSONNEL debit
```

Die Source wurde deshalb direkt auf `TPL_BLUE_GND_QRF_MIXED_6` normalisiert. Die vorherige Split-Lösung aus `TPL_BLUE_GND_INF_RIFLE_SQUAD_9` plus `TPL_BLUE_GND_QRF_MIXED_4` ist nicht mehr Teil des Stage-3-Acceptance-Source.

## 7. Builder-Normalisierung

Der reguläre Builder

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

baut Build `1-13` wieder deterministisch direkt aus dem aktuellen Source.

Der Build-1-12-Post-Transform-Wrapper ist kein dauerhafter Architekturpfad. Der neue Builder prüft unter anderem explizit:

```text
Guard template
Guard PATHLINE lookup
MOOSE PATHLINE-to-ground-route API markers
TPL_BLUE_GND_QRF_MIXED_6
QRF personnel debit = 5
absence of obsolete split-QRF markers
absence of GROUP lookup for the PATHLINE
absence of direct Guard PatrolRoute() on the PATHLINE name
```

## 8. Acceptance-Grenze

Build `1-13` ist nach Remote-Sourceänderung **nicht** DCS-validiert.

Erst die reale lokale Builderausgabe einschließlich Git-Commit und SHA-256 kann die Build-Provenienz schließen. Anschließend muss DCS mindestens nachweisen:

```text
Guard materializes through Honaker BRIGADE/PLATOON
Guard receives the 13-point owner-authored route
Guard moves along that route
Guard repeats the circuit
mixed-6 QRF materializes as one GROUP
QRF ArmyOnMission / engagement path executes
remaining Stage-3 response chain reaches its existing gates
```

Bis dahin bleibt:

```text
validated_in_dcs: false
Stage 3 overall: FAIL / DCS PENDING
```
