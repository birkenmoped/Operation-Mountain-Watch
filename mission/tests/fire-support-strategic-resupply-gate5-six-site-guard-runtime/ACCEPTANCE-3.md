---
document_id: OMW-FIRE-SUPPORT-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 DCS regression of the productive Guard PATHLINE materialization adapter
  - Gate-5 regression of continuous Guard patrol on owner-authored closed PATHLINE drawings
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5 - Guard Production Materializer Acceptance 3

## Ziel

Acceptance 2 hat den eng begrenzten Warehouse-Spawn-Adapter im Testscope erfolgreich in DCS validiert. Der Projektinhaber hat am 12.09.2026 die produktive Nutzung genau dieses Musters fuer Guard-Materialisierung freigegeben, sofern kein effektiver oeffentlicher MOOSE-Weg existiert.

Die Source-Pruefung des gepinnten MOOSE-Stands bestaetigt diese Voraussetzung fuer die Materialisierung: der oeffentliche WAREHOUSE-Vertrag bietet keinen Parameter fuer die exakte kompakte Ausrichtung aller Units eines Ground-Assets auf einem owner-authored PATHLINE-Segment. Die private Materialisierungsstelle bleibt deshalb ausschliesslich fuer diesen Guard-Scope freigegeben.

## Nachbefund aus dem Builder-5-DCS-Lauf

Der Builder-5-Lauf bestaetigte die produktive Materialisierung und die initiale Bewegung aller sechs Guards. Der Projektinhaber beobachtete danach jedoch, dass nur die Wright-Guard-Gruppe offenbar dauerhaft weiterpatrouillierte, waehrend die anderen Gruppen nach ihrem ersten Umlauf bzw. am Routenende pausierten.

Damit war das bisherige Acceptance-Kriterium `alive + routeStarted + >=25 m movement` fuer eine permanente Guard-Patrouille zu schwach. Dieser Lauf darf deshalb nicht als Nachweis einer dauerhaften Six-Site-Patrouille gewertet werden.

## MOOSE-First-Analyse des Patrol-Pfads

Der gepinnte `Moose.lua`-Stand wurde erneut gegen den konkreten Patrol-Bedarf geprueft.

Public MOOSE bietet:

```text
CONTROLLABLE:PatrolRoute()
CONTROLLABLE:TaskFunction(...)
CONTROLLABLE:SetTaskWaypoint(...)
CONTROLLABLE:WayPointInitialize(...)
CONTROLLABLE:WayPointExecute(...)
CONTROLLABLE:Route(...)
```

`CONTROLLABLE:PatrolRoute()` ist fuer diesen Scope nicht direkt verwendbar, weil die Methode intern `GetTemplateRoutePoints()` verwendet. Die Guard-Routen sind jedoch Mission-Editor-Line-Drawings, die von MOOSE als `PATHLINE` importiert werden.

Der relevante Source-Befund ist entscheidend: MOOSE registriert Line-Drawings als `PATHLINE:NewFromVec2Array(...)`, uebernimmt dabei aber nur die Punktliste. Das DCS-Drawing-Merkmal `closed=true` wird im PATHLINE-Objekt nicht erhalten. Alle sechs Guard-Zeichnungen sind im getesteten Missionsstand als geschlossene Line-Drawings angelegt. Eine Route aus `PATHLINE:GetCoordinates()` enthaelt deshalb nicht automatisch das implizite Segment vom letzten Punkt zurueck zum ersten Punkt.

Der bisherige Acceptance-Code routete nur

```text
spawn lead -> PATHLINE point 2 -> ... -> PATHLINE last point
```

und startete danach die Route erneut. Dadurch musste DCS vom letzten Punkt ohne expliziten owner-authored Closing-Waypoint zurueck zum Anfang finden. Das ist fuer Ground-AI nicht belastbar.

## Korrigierter MOOSE-First-Pfad

Der neue Patrol-Adapter verwendet ausschliesslich oeffentliche MOOSE-Methoden und fuegt keine eigene Scheduler-/Retry-/Assetlogik hinzu:

```text
owner-authored Guard PATHLINE
-> lead point
-> PATHLINE points 2..N
-> PATHLINE point 1 als explizites Closing-Segment
-> CONTROLLABLE:TaskFunction("CONTROLLABLE.WayPointExecute", ...)
-> CONTROLLABLE:WayPointInitialize(route)
-> CONTROLLABLE:WayPointExecute(...)
-> gleiche geschlossene Route erneut
```

Produktive Module:

```text
scripts/ground/OMW_GuardPathlineMaterializationAdapter.lua
scripts/ground/OMW_GuardPathlinePatrolAdapter.lua
```

Die zweite Datei benutzt nur public MOOSE APIs. Dafuer ist keine neue private-MOOSE-Ausnahme erforderlich.

## Produktive Ausnahmegrenze

Zugelassen ist ausschliesslich die bereits freigegebene Guard-Materialisierung:

```text
Guard asset
-> normaler MOOSE BRIGADE / WAREHOUSE Lifecycle
-> direkt vor Ground-Asset-Materialisierung exakte Unit-Positionen/Headings
   auf erstem Guard-PATHLINE-Segment setzen
-> normaler MOOSE PLATOON / ARMYGROUP / AUFTRAG Lifecycle
```

Nicht freigegeben sind:

```text
- allgemeine private-MOOSE-Nutzung;
- eigene Asset-Selektion;
- eigene Queue oder Retry-Queue;
- Ersatz des COMMANDER-/BRIGADE-Recruitments;
- Convoy-/QRF-/ARTY-/CAS-/Resupply-Nutzung dieser Ausnahme ohne neue Owner-Freigabe;
- Guard-Abhaengigkeit von ZON_BLUE_GND_*_ACCESS;
- MIZ-Mutation.
```

## DCS-Pruefung

Die gleiche Six-Site-Geometrie wie in Acceptance 2 wird verwendet:

```text
JALALABAD_FENTY
COP_FORTRESS
FOB_JOYCE
FOB_WRIGHT
COP_HONAKER
FOB_BOSTICK
```

Automatischer Mindestnachweis fuer alle sechs Sites:

```text
- produktives Materializer-Modul wird verwendet;
- produktiver public-MOOSE Patrol-Adapter wird verwendet;
- Guard materialisiert PATHLINE-ausgerichtet;
- Guard lebt;
- geschlossene Route wurde gestartet;
- mindestens 25 m Bewegung innerhalb 300 Sekunden;
- keine Convoy-ACCESS-Zone ist Teil der Guard-Materialisierung oder Route.
```

Zusaetzlich ist fuer den Abschluss dieser Acceptance eine reale visuelle Bestaetigung erforderlich, dass die Guards nach Erreichen des PATHLINE-Endes nicht dauerhaft stehenbleiben, sondern die geschlossene Patrouille fortsetzen. Der automatische 300-Sekunden-PASS allein beweist diese Langzeitbedingung ausdruecklich nicht.

Acceptance 2 bleibt als exakte Builder-4-Evidenz fuer kompakte Materialisierung gueltig. Acceptance 3 bleibt bis zur realen DCS-Regressionspruefung des korrigierten geschlossenen Patrol-Pfads `validated_in_dcs: false`.
