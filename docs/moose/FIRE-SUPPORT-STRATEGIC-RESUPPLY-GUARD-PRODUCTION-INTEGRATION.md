---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-PRODUCTION-INTEGRATION
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed production integration of persistent Guard demand with local MOOSE BRIGADE recruitment
  - separation of the accepted Guard materialization exception from public MOOSE mission and route handling
  - six-site Guard runtime assembly contract without operational asset preselection
not_authoritative_for:
  - a new DCS acceptance beyond the exact Gate-5 Builder-5 evidence
  - repeated multi-cycle Guard patrol validation
  - QRF, ARTY, CAS or resupply materialization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – Guard Production Integration

## Ziel

Die generische `FireSupStratResupply_Base:StartSite(siteId)`-Demand soll den bereits abgenommenen Six-Site-Guard-Pfad produktiv erreichen, ohne die Acceptance-3-Vorselektion `AssignCohort(...)` in die Produktion zu uebernehmen.

Produktiver Sollpfad:

```text
Base:StartSite(siteId)
-> persistent GUARD demand
-> OMW_FireSupStratResupply_GuardRuntime
-> OMW_FireSupStratResupply_LegionBridge
-> site-local BRIGADE organisational boundary
-> OMW_FireSupStratResupply_GuardMissionFactory
-> AUFTRAG:NewONGUARD(...)
-> BRIGADE/LEGION:AddMission(...)
-> MOOSE selects/recruits capable local cohort/asset
-> accepted Guard materializer controls exact physical spawn geometry only
-> ArmyOnMission
-> Guard PATHLINE route adapter applies accepted owner-authored route
```

## Autoritaetsgrenze

Die lokale BRIGADE ist fuer den persistenten Guard die fachlich gewollte organisatorische Grenze der Installation. Das ist keine operative Asset-Vorselektion. Innerhalb der BRIGADE bleiben COHORT-/Asset-Auswahl, Warehouse-Request und ARMYGROUP-Lifecycle bei MOOSE.

Produktiv verboten bleibt:

```text
AssignCohort(...) from OMW demand orchestration
manual asset candidate list
manual warehouse request/retry queue
ACCESS-zone use for Guard spawn or route
```

## Six-Site Guard Runtime

`scripts/campaign/OMW_FireSupStratResupply_GuardRuntime.lua` assembliert die produktiven Guard-Bausteine fuer alle registrierten Sites. Die tatsaechlichen MOOSE-BRIGADE-Objekte werden injiziert; der Runtime erzeugt keine zweite Ground-Organisation und startet keine konkurrierende Warehouse-Struktur.

Pro Site wird ausschliesslich aus dem Guard-Vertrag gelesen:

```text
guardTemplateName
guardRoute.pathlineName
injected local BRIGADE object
```

`accessZoneName` ist kein Input des GuardRuntime.

`Prepare()`:

```text
resolve owner-authored PATHLINE
resolve Guard template GROUP
-> GuardPathlineMaterializationAdapter:Prepare/Install(local BRIGADE)
-> GuardPathlineRouteAdapter:Install(local BRIGADE)
-> build GuardMissionFactory
-> build local LegionBridge
```

Danach kann der Runtime selbst als `Base.adapters.GUARD` verwendet werden, weil er `Dispatch(demand, context)` anbietet.

## Materialisierungsausnahme

Die bereits durch den Projektinhaber freigegebene private MOOSE-Ausnahme bleibt exakt auf

```text
scripts/ground/OMW_GuardPathlineMaterializationAdapter.lua
```

begrenzt. Sie setzt nur die exakten Positionen/Headings der Guard-Einheiten unmittelbar vor dem Warehouse-Spawn. BRIGADE/WAREHOUSE-Rekrutierung und Auftragshoheit bleiben MOOSE.

Diese Ausnahme wird nicht auf QRF, ARTY, CAS oder Resupply erweitert.

## Public-MOOSE-Missionspfad

`scripts/campaign/OMW_FireSupStratResupply_GuardMissionFactory.lua` erzeugt:

```text
AUFTRAG:NewONGUARD(materializer:GetLeadCoordinate())
SetTeleport(false)
SetRequiredAssets(1, 1)
optional SetPriority(demand.priority, false)
```

Es gibt **kein** `AssignCohort(...)` und keine Asset-ID im Factory-Vertrag.

## PATHLINE-Routing

`scripts/ground/OMW_GuardPathlineRouteAdapter.lua` nutzt den oeffentlichen `BRIGADE.OnAfterArmyOnMission`-Callback. Erst nachdem MOOSE ein ARMYGROUP rekrutiert/materialisiert hat, wird die in Gate 5 abgenommene Route aufgebaut:

```text
materialized lead coordinate
-> PATHLINE point 2
-> ...
-> final PATHLINE point
```

mit:

```text
WaypointGround(5 km/h, "Off Road")
OptionFormationInterval(2 m)
CONTROLLABLE.Route restart task at the final waypoint
Route(..., 2)
```

Der Adapter verkettet einen bereits vorhandenen `OnAfterArmyOnMission`-Callback statt ihn stillschweigend zu verwerfen.

## Patrol-Limit – Owner-Entscheidung

Der reale Gate-5-Lauf bestaetigte Materialisierung und Bewegung aller sechs Guards. Wright zeigte wiederholtes Patrouillieren; bei anderen Installationen wurde nach der ersten Runde teilweise eine Pause beobachtet. Der Projektinhaber hat diesen Stand fuer den Foundation-Scope als PASS akzeptiert.

Die spaetere Umstellung/Pruefung auf den MOOSE-eigenen `CONTROLLABLE:PatrolRoute()`-/Template-Waypoint-Pfad bleibt eine nachgelagerte To-do und blockiert die allgemeine Base nicht.

Der Produktionsadapter reproduziert deshalb bewusst den **abgenommenen** aktuellen Route()-Stand und fuehrt jetzt keinen neuen Patrol-Lifecycle ein.

## Contract-Tests

```text
tests/mission-demand/test_guard_pathline_route_adapter.lua
tests/mission-demand/test_fire_support_strategic_resupply_guard_mission_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_legion_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_guard_runtime.lua
```

Sie pruefen source-seitig insbesondere:

- kein Cohort-/Asset-Assignment im Demand-Adapter;
- ein lokaler `LEGION:AddMission`-Handoff;
- `SetTeleport(false)`;
- genau ein erforderliches Guard-Asset;
- Route erst fuer den getrackten Guard-AUFTRAG;
- Route beginnt am compact/aligned materialized lead und folgt der Guard-PATHLINE;
- bestehender `OnAfterArmyOnMission`-Callback bleibt erhalten;
- alle sechs SiteRegistry-Eintraege werden ueber Guard-Template und Guard-PATHLINE assembliert;
- kein ACCESS-Feld wird fuer Guard-Materialisierung oder Routing verwendet.

Diese neue produktive Verkabelung ist noch kein neuer DCS-Runtime-PASS. Der Gate-5-DCS-PASS bleibt exakt auf den dokumentierten Builder-5-Stand begrenzt.
