---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-EXTERNAL-SUPPORT
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed generic COMMANDER handoff for external ARTY and CAS support
  - tactical-geometry injection boundary for external fire support
  - no-provider-preselection contract for external support
not_authoritative_for:
  - concrete six-site ARTY target geometry or CAS engagement zones
  - concrete provider legions, batteries, squadrons or aircraft
  - DCS runtime validation of the generic external-support assembly
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – External ARTY/CAS Support

## Zweck

Der externe Support-Pfad der allgemeinen Base nutzt den bereits in Gate 1 festgelegten MOOSE-`COMMANDER` als Provider-Aggregator. OMW erzeugt den fachlich qualifizierten Auftrag und dessen taktische Zielgeometrie; `COMMANDER`/MOOSE waehlen die operativ geeigneten Provider und Assets.

```text
explicit C2 escalation
-> Base:RequestIncidentSupport(..., ARTY/CAS)
-> external support adapter
-> public AUFTRAG
-> COMMANDER:AddMission(...)
-> MOOSE provider/asset recruitment and mission lifecycle
```

Perimeter-Eintritt erzeugt weiterhin **keinen** automatischen ARTY-/CAS-Auftrag.

## Source-Review des gepinnten MOOSE-Stands

Verwendeter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsaechlichen `Moose.lua` sind die benoetigten oeffentlichen Konstruktoren vorhanden:

```text
AUFTRAG:NewARTY(TargetCoordinate, Nshots, Radius, Altitude)
AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, OrbitCoordinate, Heading, Leg, TargetTypes)
AUFTRAG:SetTeleport(false)
AUFTRAG:SetRequiredAssets(min, max)
AUFTRAG:SetPriority(...)
AUFTRAG:Cancel()
COMMANDER:AddMission(...)
```

`NewARTY` ist ein Ground/Naval-ARTY-Auftrag. Der MOOSE-Kommentar weist zudem darauf hin, dass Waffenreichweiten bei Bedarf ueber den OPSGROUP-Vertrag konfiguriert werden sollen, da die DCS-API diese nicht verlaesslich liefert. Dieser Punkt wird nicht durch eine OMW-eigene Reichweitenberechnung ersetzt.

`NewCAS` erwartet eine CAS-Zone und erzeugt einen Aircraft-Auftrag. Die Alarmzone wird **nicht** automatisch als CAS-Zone interpretiert.

## CommanderBridge

`scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua` ist auf Schema 2 erweitert. Ein Factory darf jetzt sauber

```text
nil, false, <reason>
```

liefern, wenn die fachlich erforderliche Zielgeometrie noch nicht vorliegt. In diesem Fall wird kein MOOSE-Auftrag in die COMMANDER-Queue gestellt.

Damit ist ein fehlendes C2-Ziel kein Anlass fuer einen geratenen Fallback.

## ARTY Factory

`scripts/campaign/OMW_FireSupStratResupply_ArtyMissionFactory.lua` erwartet einen injizierten `resolveTarget(demand, context)`-Resolver. Dieser liefert die fachlich qualifizierte Zielgeometrie:

```text
coordinate
optional shots
optional radiusM
optional altitudeM
```

Der Factory setzt keine Batterie und keinen Provider fest. Standardmaessig wird genau ein MOOSE-Asset angefordert; die konkrete Auswahl bleibt bei COMMANDER/MOOSE.

## CAS Factory

`scripts/campaign/OMW_FireSupStratResupply_CasMissionFactory.lua` erwartet `resolveGeometry(demand, context)` mit:

```text
zone
optional altitudeFt
optional speedKts
optional orbitCoordinate
optional headingDeg
optional legNm
optional targetTypes
```

Die Zone muss eine explizite taktische CAS-Geometrie sein. Insbesondere gelten weiterhin:

```text
alarm perimeter != CAS engagement zone
alarm perimeter != fire-support target area
```

Der Factory waehlt kein AIRWING, keine SQUADRON und kein Luftfahrzeug.

## ExternalSupportRuntime

`scripts/campaign/OMW_FireSupStratResupply_ExternalSupportRuntime.lua` setzt beide Factories mit demselben injizierten MOOSE-`COMMANDER` zusammen und stellt Base-kompatible Adapter bereit:

```text
ARTY -> CommanderBridge(MISSION)
CAS  -> CommanderBridge(MISSION)
```

Der generische Composition Root `OMW_FireSupStratResupply_Runtime.lua` kann diesen Block ueber `externalSupport` integrieren. `externalAdapters` duerfen dann ARTY/CAS nicht parallel ueberschreiben.

## Contract-Tests

```text
tests/mission-demand/test_fire_support_strategic_resupply_commander_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_arty_mission_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_cas_mission_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_external_support_runtime.lua
```

Geprueft werden unter anderem:

- genau ein COMMANDER-Queue-Handoff pro Demand;
- idempotentes Duplicate-Verhalten;
- Cancel-Forwarding an den MOOSE-Lifecycle;
- Factory-Refusal ohne geratenen Auftrag;
- `NewARTY` mit injizierter Zielkoordinate;
- `NewCAS` mit injizierter taktischer Zone;
- kein Provider-/Asset-Assignment im OMW-Pfad;
- `SetTeleport(false)` und explizite Required-Asset-Anzahl.

Das ist Source-/CI-Evidenz und kein DCS-PASS.
