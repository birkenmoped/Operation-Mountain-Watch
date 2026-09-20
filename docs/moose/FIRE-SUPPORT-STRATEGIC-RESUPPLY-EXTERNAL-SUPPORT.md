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

Der externe Support-Pfad der allgemeinen Base folgt ADR 0008: C2/OMW erzeugt den fachlich qualifizierten Bedarf und die missionsspezifischen Faehigkeits-/Geometrieanforderungen; `COMMANDER`/`LEGION` waehlen innerhalb der konfigurierten Organisationen den operativ geeigneten Provider und das Asset. OMW baut davor keine zweite Asset- oder Provider-Selektion.

```text
explicit C2 escalation
-> Base:RequestIncidentSupport(..., ARTY/CAS)
-> external support adapter
-> public AUFTRAG
-> C2/OMW support requirement + mission capability/profile constraints
-> COMMANDER:AddMission(...)
-> MOOSE provider/asset recruitment inside configured organisations
-> provider-specific owner-route/lifecycle profile bound after MOOSE selection
-> MOOSE physical mission lifecycle
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
AUFTRAG:NewPATROLZONE(Zone, Speed, Altitude, Formation)
AUFTRAG:SetEngageDetected(Range, TargetTypes, EngageZone, NoEngageZoneSet)
AUFTRAG:SetTeleport(false)
AUFTRAG:SetRequiredAssets(min, max)
AUFTRAG:SetPriority(...)
AUFTRAG:Cancel()
COMMANDER:AddMission(...)
```

`NewARTY` ist ein Ground/Naval-ARTY-Auftrag. Der MOOSE-Kommentar weist zudem darauf hin, dass Waffenreichweiten bei Bedarf ueber den OPSGROUP-Vertrag konfiguriert werden sollen, da die DCS-API diese nicht verlaesslich liefert. Dieser Punkt wird nicht durch eine OMW-eigene Reichweitenberechnung ersetzt.

`NewCAS` erwartet eine CAS-Zone und erzeugt einen Aircraft-Auftrag. Die Alarmzone wird **nicht** automatisch als CAS-Zone interpretiert.

`NewPATROLZONE` ist im gepinnten Source fuer AIR/GROUND/NAVAL vorhanden. Fuer die Stage-3-CAS-Semantik ist zusaetzlich source-verifiziert, dass `SetEngageDetected(...)` auf demselben AUFTRAG die eigene MOOSE/DCS-Detection des spaeteren OPSGROUP/FLIGHTGROUP aktiviert. Die Base injiziert dadurch weiterhin keine allwissende Zielliste.

## CommanderBridge

`scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua` erlaubt einem Factory sauber

```text
nil, false, <reason>
```

zurueckzugeben, wenn die fachlich erforderliche Zielgeometrie noch nicht vorliegt. In diesem Fall wird kein MOOSE-Auftrag in die COMMANDER-Queue gestellt.

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

Die Verbindung eines durch COMMANDER gewaehlten ARTY-Auftrags mit dem bereits DCS-akzeptierten lokalen M1083-/ARTY-Rearm-Lifecycle ist fuer Stage-3-Acceptance-2 noch **offen**. Bis diese Bruecke nachgewiesen ist, darf der neue generische `NewARTY`-Pfad nicht als Ersatz fuer die bestehende Wright-Rearm-Evidenz ausgegeben werden.

## CAS Factory

`scripts/campaign/OMW_FireSupStratResupply_CasMissionFactory.lua` Schema 3 erwartet `resolveGeometry(demand, context)`.

Standardmodus:

```text
missionMode = CAS        # optional; default
zone
optional altitudeFt
optional speedKts
optional orbitCoordinate
optional headingDeg
optional legNm
optional targetTypes
optional configureMission(mission, geometry, demand, context)
```

Stage-3-kompatibler MOOSE-Modus:

```text
missionMode = PATROLZONE_ENGAGE
zone
altitudeFt
speedKts
engageDetectedRangeNm
optional engageDetectedTargetTypes
optional configureMission(mission, geometry, demand, context)
```


Schema 3 kann zusaetzlich MOOSE-eigene Rekrutierungsanforderungen aus der injizierten Geometrie weiterreichen:

```text
requiredAttributes -> AUFTRAG:SetRequiredAttribute(...)
requiredProperties -> AUFTRAG:SetRequiredProperty(...)
```

Diese Felder sind **keine OMW-Providerwahl**. Sie beschreiben die fachlich erforderliche MOOSE-Faehigkeit des Auftrags; `COMMANDER`/`LEGION` waehlen weiterhin selbst aus den konfigurierten Cohorts/Assets.

Im Modus `PATROLZONE_ENGAGE` baut der Factory ausschliesslich:

```text
AUFTRAG:NewPATROLZONE(zone, speedKts, altitudeFt)
-> SetEngageDetected(engageDetectedRangeNm, targetTypes, zone, nil)
```

Damit kann der bisherige Stage-3-CAS-Vertrag in die generische Base uebernommen werden, **ohne** den Provider im OMW-Factory vorab festzulegen. Der spaetere COMMANDER-Handoff bleibt unveraendert.

`configureMission(...)` ist nur ein expliziter Konfigurations-Hook fuer bereits owner-authored MOOSE-Missionsgeometrie, beispielsweise die vorhandenen Stage-3-CAS-Ingress-/Egress-/Corridor-Knoten. Der Hook darf keine Assetauswahl, eigene Zielsuche oder zweite Lifecycle-Autoritaet einfuehren.

Die Zone muss in beiden Modi eine explizite taktische CAS-Geometrie sein. Insbesondere gelten weiterhin:

```text
alarm perimeter != CAS engagement zone
alarm perimeter != fire-support target area
```

## ExternalSupportRuntime

`scripts/campaign/OMW_FireSupStratResupply_ExternalSupportRuntime.lua` setzt beide Factories mit demselben injizierten MOOSE-`COMMANDER` zusammen und stellt Base-kompatible Adapter bereit:

```text
ARTY -> CommanderBridge(MISSION)
CAS  -> CommanderBridge(MISSION)
```

Der generische Composition Root `OMW_FireSupStratResupply_Runtime.lua` kann diesen Block ueber `externalSupport` integrieren. `externalAdapters` duerfen dann ARTY/CAS nicht parallel ueberschreiben.

## Stage-3-Reconciliation 15.09.2026

Production Base Acceptance 4/A4-8 und Acceptance 5 ersetzen die alten lokalen Stage-3-Guard-/QRF-Annahmen. Fuer die externe Unterstuetzung gilt getrennt:

```text
GUARD/QRF
-> Production Base A4/A5

CAS
-> generic Base / COMMANDER
-> CasMissionFactory PATROLZONE_ENGAGE
-> existing Stage-3 tactical corridor through configureMission

ARTY
-> generic Base / COMMANDER target handoff is source-reviewed
-> integration with the accepted Wright functional ARTY + local M1083 rearm remains unresolved
```

Daraus folgt: Acceptance 2 darf den CAS-Pfad jetzt ohne AIRWING-/SQUADRON-Hardcoding an die Base anbinden. Fuer ARTY wird dagegen **keine** Gleichwertigkeit erfunden; die Rearm-Bruecke muss vor dem naechsten Gesamt-DCS-Lauf separat implementiert und getestet werden.

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
- `NewPATROLZONE + SetEngageDetected` fuer explizit konfigurierten CAS-Modus;
- optionaler Missionskonfigurations-Hook ohne Provider-Selektion;
- kein Provider-/Asset-Assignment im OMW-Factory-Pfad;
- `SetTeleport(false)` und explizite Required-Asset-Anzahl.

Das ist Source-/CI-Evidenz und kein DCS-PASS.

## Production Base Acceptance 6 – variable C2 provider selection

Nach Verwerfung der deterministischen Stage-3-Acceptance wird die offene Runtime-Frage der allgemeinen Base jetzt direkt getestet:

```text
physical installation attack
-> production incident
-> explicit CAS escalation through Base
-> ExternalSupportRuntime
-> CommanderBridge
-> COMMANDER:AddMission(...)
-> MOOSE recruitment across multiple registered AIRWING candidates
-> COMMANDER MissionAssign
-> OPSGROUP on mission
```

Acceptance 6 bindet keinen AIRWING, keine SQUADRON und keinen Luftfahrzeugtyp. Der Acceptance-COMMANDER registriert alle bereits laufenden `OMW.AirOps`-AIRWINGs und verlangt vor Testbeginn mindestens zwei CAS-faehige AIRWING-Kandidaten.

Der gepinnte MOOSE-Source wurde fuer diesen Scope erneut geprueft. Relevante oeffentliche Pfade sind:

```text
COMMANDER:New(...)
COMMANDER:AddAirwing(...)
COMMANDER:Start()
COMMANDER:AddMission(...)
COMMANDER:CanMission(...)
COMMANDER:OnAfterMissionAssign(...)
COMMANDER:OnAfterOpsOnMission(...)
AUFTRAG.CheckMissionCapability(...)
LEGION recruitment / cohort eligibility / asset optimization
```

Die MOOSE-Rekrutierung bewertet geeignete Cohorts und Assets innerhalb der registrierten Legions. OMW Acceptance 6 beobachtet die resultierende Auswahl nur; es setzt weder `specialLegions`/`specialCohorts` noch einen direkten `AIRWING:AddMission()`-Pfad.

Der erste korrigierte Lauf beschraenkt sich bewusst auf CAS-Provider-/Asset-Selektion. ARTY bleibt aus diesem Lauf heraus, weil die Verbindung zwischen generischem `AUFTRAG:NewARTY()`/COMMANDER-Recruitment und dem bereits akzeptierten Functional-ARTY-/Rearm-Lifecycle noch nicht als einheitlicher Produktionspfad belegt ist. Diese Grenze darf nicht durch einen deterministischen ARTY-Testprovider umgangen werden.

Artefakte:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-6.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/06-c2-provider-selection-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-6.ps1
```

Status vor DCS-Lauf: `SOURCE_REVIEWED / DCS_PENDING`.

## Reconciliation 18.09.2026 – Acceptance 6 rejected

Der reale Acceptance-6-Lauf hat nicht die MOOSE-Auswahlautoritaet widerlegt; ADR 0008 bleibt verbindlich. Falsch war, dass A6 nach der MOOSE-Auswahl keinen provider-/plattformgerechten Owner-Route-, Release- und Recovery-Vertrag an die ausgewaehlte physische FLIGHTGROUP band und trotzdem bereits bei `OpsOnMission` PASS meldete.

Verbindlicher Ablauf:

```text
support requirement
-> OMW defines mission capability/profile constraints
-> MOOSE COMMANDER/LEGION evaluates eligible configured cohorts/assets
-> MOOSE selects provider + operational asset
-> OMW binds the matching owner-authored execution profile to that selected provider
-> MOOSE executes and recovers the physical asset
```

Fuer Rotary-Wing-CAS gehoeren damit bereits vor dem physischen Dispatch zusammen:

```text
selected rotary-wing pool
+ approved OMW helicopter owner route
+ tactical ingress/egress gate contract
+ supported-element release plus own detection/no-contact policy
+ owner reverse route
+ physical home landing
+ LEGION/AIRWING asset return
```

`OpsOnMission` allein ist keine Acceptance-Grenze. `FuelLow`/Bingo, direkter RTB oder bloße Missionsbeendigung sind keine regulaere CAS-Completion.

## Acceptance 7 – selected-provider execution profile

Der nach A6 korrigierte Runtime-Pfad nutzt die MOOSE-Auswahl weiter, bindet aber vor physischer Ausfuehrung den passenden Owner-Route-/Lifecycle-Vertrag:

```text
Base CAS demand
-> PATROLZONE_ENGAGE + required AIR_ATTACKHELO attribute
-> COMMANDER/LEGION recruits eligible provider/asset
-> COMMANDER OnBeforeMissionAssign
-> validate selected provider has owner-authored route profile
-> configure owner ingress/egress before LEGION MissionRequest
-> OpsOnMission
-> bind full owner corridor
-> own detection / stable no-contact release
-> reverse owner route
-> physical landing
-> LegionAssetReturned
```

Kann fuer den von MOOSE ausgewaehlten Provider kein owner-authored Profil aufgeloest werden, wird die MissionAssign-Transition fail-closed abgewiesen. Ein Direct-Line-Fallback ist nicht zulaessig.


## Acceptance 9 – validated shared rotary-wing CAS lifecycle

The generic external-support CAS path is now DCS-validated for the exact A9 Joyce/Jalalabad scope.

```text
source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2

Acceptance bundle SHA-256:
D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0

DCS:
2.9.29.27468

MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

result:
PASS
```

Validated chain:

```text
Base CAS demand
-> CasMissionFactory
-> CommanderBridge
-> MOOSE COMMANDER/LEGION provider + asset selection
-> selected-provider owner execution profile
-> owner route / tactical corridor
-> AUFTRAG executing
-> own FLIGHTGROUP detection
-> configured release policy
-> shared CasPatrolClosure
-> reverse owner route
-> physical home landing
-> exact LegionAssetReturned
-> lifecycle complete
```

The previous false post-return loss classification was corrected and revalidated. After exact `LegionAssetReturned`, removal of the temporary physical DCS group representation is cleanup and must not be reinterpreted as asset loss.

This CAS lifecycle is now a reuse boundary for subsequent Base work. It must not be reconstructed inside a later Acceptance harness.

### Remaining external-support boundary

ARTY remains deliberately separate:

```text
generic NewARTY / COMMANDER recruitment
!= automatically validated Functional ARTY rearm ownership
```

The next ARTY step must reconcile the generic external-support handoff with the already accepted Functional ARTY/M1083 rearm lifecycle without placing the same battery under two independent mission/FSM owners.
