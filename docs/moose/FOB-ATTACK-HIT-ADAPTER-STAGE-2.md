---
document_id: OMW-STAGE-2-FOB-ATTACK-HIT-ADAPTER
status: PLANNED
document_class: MOOSE_ADAPTER_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 MOOSE EVENTS.Hit qualification adapter design
  - explicit target-registration boundary for BLUE Ground installations
  - red-on-blue event qualification before CAS_IMMEDIATE MissionDemand creation
not_authoritative_for:
  - DCS runtime acceptance of the Hit callback
  - production-wide registration of all FOB/COP assets
  - CAS aircraft dispatch
  - final attack severity or priority model
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – MOOSE Hit Qualification Adapter

## 1. Ziel

Der nächste Stage-2-Slice verbindet den bereits vorhandenen Domain-Vertrag

```text
qualified FOB/COP attack
-> OMW_FobAttackDemandPolicy
-> MissionDemand CAS_IMMEDIATE
```

mit dem MOOSE-Eventpfad, ohne einen parallelen Native-DCS-Eventhandler einzuführen.

Implementierung:

```text
scripts/ground/OMW_FobAttackHitAdapter.lua
```

## 2. MOOSE-First-Nachweis

Verwendeter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich verwendeten `Moose.lua` ist öffentlich vorhanden:

```lua
BASE:HandleEvent(EventID, EventFunction)
BASE:UnHandleEvent(EventID)
```

`BASE:HandleEvent(...)` delegiert an den MOOSE-Eventdispatcher über `OnEventGeneric(...)`.
Für `EVENTS.Hit` werden im EventData-Pfad unter anderem aufgebaut:

```text
IniCoalition
IniUnitName
IniGroupName
TgtCoalition
TgtUnitName
TgtGroupName
TgtUnit
TgtGroup
WeaponName
```

Die Callback-Signatur ist im gepinnten Source durch mehrere MOOSE-Klassen praktisch als

```lua
function Class:_OnHit(EventData)
```

beziehungsweise über `HandleEvent(EVENTS.Hit, self._OnHit)` verwendet.

Folge für OMW:

```text
MOOSE BASE:HandleEvent(EVENTS.Hit, ...)
-> OMW qualification adapter
```

ist der kleinste MOOSE-first Weg. Ein `world.addEventHandler` wird nicht benötigt und ist für diesen Scope nicht verwendet.

## 3. Adapter-Grenze

Der Adapter besitzt keine strategische Ressourcenhoheit. Er akzeptiert nur explizit registrierte Zielnamen:

```text
targetGroups[groupName]
targetUnits[unitOrStaticName]
```

Jede Registrierung liefert mindestens:

```text
installationId
priority
```

Damit wird nicht versucht, aus beliebigen DCS-Gruppennamen eine CampaignState-Identität zu erraten.

Qualifikation:

```text
initiator coalition == configured RED
AND target coalition == configured BLUE
AND target is explicitly registered
-> qualified incident
```

Andere Treffer werden mit einem Diagnosegrund verworfen:

```text
INITIATOR_NOT_RED
TARGET_NOT_BLUE
TARGET_NOT_REGISTERED
INVALID_EVENT_DATA
```

## 4. Incident-ID und Position

Der Adapter erfindet bewusst keinen projektweiten Incident-ID-Algorithmus und keine Angriffsschwere.

Die Runtime-Komposition muss bereitstellen:

```lua
incidentIdFactory(eventData, registration)
```

Optional:

```lua
positionResolver(eventData, registration)
```

Dadurch bleibt die spätere persistente Incident-/Restart-Semantik eine eigene Campaign-Domain-Entscheidung und wird nicht versteckt in den MOOSE-Adapter eingebaut.

## 5. Demand-Erzeugung

Nach erfolgreicher Qualifikation delegiert der Adapter ausschließlich an:

```lua
OMW_FobAttackDemandPolicy.CreateDemand(...)
```

und damit an den bestehenden MissionDemand-Registry-Lifecycle.

Wiederholte Treffer derselben Installation werden nicht durch einen neuen Timer gedrosselt, sondern treffen auf den bestehenden aktiven Dedupe-Key:

```text
CAS_IMMEDIATE|FOB_ATTACK|<installationId>
```

und ergeben `active_duplicate`, solange der vorherige Demand nicht terminal ist.

## 6. Contract-Test

```text
tests/mission-demand/test_fob_attack_hit_adapter.lua
```

prüft:

```text
registered RED -> BLUE group hit -> CAS_IMMEDIATE
second hit same installation -> active_duplicate
BLUE initiator -> ignored
RED target -> ignored
unregistered BLUE target -> ignored
registered unit/static target -> separate site demand
Start -> HandleEvent(EVENTS.Hit, callback)
Stop -> UnHandleEvent(EVENTS.Hit)
Start/Stop idempotence
```

Die Test-Eventbasis ist ein Stub. Das beweist den Adaptervertrag, nicht die DCS-/MOOSE-Laufzeit.

## 7. Offene DCS-Acceptance

Vor Status `VALIDATED_FOR_DOCUMENTED_SCOPE` ist ein echter DCS-Lauf erforderlich:

```text
real registered BLUE FOB/COP target
-> real hostile RED weapon hit
-> MOOSE EVENTS.Hit callback
-> exact installation mapping
-> one CAS_IMMEDIATE MissionDemand
-> repeated hit does not create second active demand
```

Dabei sind Branch/Commit, MIZ/hash, generiertes Bundle/hash, DCS-Version und der exakt geladene MOOSE-Stand zu dokumentieren.

CAS-Dispatch über `AUFTRAG:NewCAS(...)`, BLUE COMMANDER, AIRWING oder SQUADRON ist ausdrücklich nicht Bestandteil dieses Adapter-Slices.
