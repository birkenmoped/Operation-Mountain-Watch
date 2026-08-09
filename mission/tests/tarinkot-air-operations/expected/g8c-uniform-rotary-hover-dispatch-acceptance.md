---
document_id: OMW-TEST-TKOT-G8C-UNIFORM-ROTARY-HOVER-DISPATCH-ACCEPTANCE
status: PLANNED
document_class: TEST_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - G8C uniform native rotary dispatch acceptance boundary
  - runtime propagation evidence for the AIRWING vertical policy
not_authoritative_for:
  - production CAS, transport, landing, recovery or persistence behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot G8C – einheitlicher Rotary-Hover-Dispatch

## Ziel und Grenze

G8C ist ein Diagnose- und Acceptance-Test, keine Produktionskorrektur. Er isoliert den Auftragstyp, indem alle fünf registrierten Assetgruppen denselben öffentlichen MOOSE-Auftrag erhalten:

```text
AIRWING:SetOptionPreferVerticalLanding() vor AIRWING:Start()
-> AIRWING:onafterFlightOnMission()
-> FLIGHTGROUP:SetOptionPreferVertical()
-> fünf AUFTRAG:NewHOVER()-Missionen
```

Die Gruppen sind `AH64_1` (2), `AH64_2` (2), `UH60_1` (1), `UH60_2` (1) und `CH47_1` (1). Die beiden AH-64-Gruppen bleiben zwingend Zwei-Schiff-Gruppen. G8C erzeugt weder Raw-SPAWN noch einzelne `UNIT`-Optionen, standalone-`FLIGHTGROUP`, `COMMANDER`, `OPSTRANSPORT`, MOOSE-Quelländerungen oder Warehouse-Overrides.

## MOOSE-Quellenprüfung

Geprüfter Stand: MOOSE 2.9.18, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, `Moose.lua` SHA-256 `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`.

| API | Quellbefund | Verwendung in G8C |
|---|---|---|
| `AUFTRAG:NewHOVER(Coordinate, Altitude, Time, Speed, MissionAlt)` | Rotary-Mission; setzt `categories={AUFTRAG.Category.HELICOPTER}` | Nur `Coordinate`, `Altitude`, `Time`; keine Mutation von `DCStask` oder MOOSE-Interna |
| `SQUADRON:AddMissionCapability()` | öffentliche Capability-Registrierung | HOVER vor dem Dispatch je Squadron |
| `AIRWING:AddPayloadCapability()` | öffentliche Payload-Capability-Registrierung | HOVER vor dem Dispatch je Rollenpayload |
| `AIRWING:onafterFlightOnMission()` | ruft bei gesetzter AIRWING-Policy `FlightGroup:SetOptionPreferVertical()` | Telemetrie beobachtet die reale `FLIGHTGROUP` |
| `FLIGHTGROUP:SetOptionPreferVertical()` | setzt Gruppenflag und die DCS-Gruppenoption | ausschließlich durch den nativen AIRWING-Pfad |

Die lokale MOOSE-Dokumentation und der gepinnte Quellcode wurden geprüft. Offizielle Demos lagen im Projektarbeitsstand nicht vor; deshalb wird keine Demo-basierte Laufzeitbehauptung gemacht.

## Runtime-Vertrag

- G7 muss `PASS` melden und der AIRWING muss laufen.
- `OptionPreferVerticalLanding=true` muss vor dem Dispatch vorhanden sein.
- Jede Mission besitzt `AUFTRAG.Type.HOVER`, genau eine SQUADRON und genau einen erforderlichen Payload.
- Assignment-Timeout: 720 s; Takeoff-Timeout ab `FlightOnMission`: 360 s; Aggregate-Timeout: 1200 s.
- Runtime-PASS verlangt `assigned=5`, `takeoffGroups=5`, `runtimeUnits=7`, `failedGroups=0` und `optionPreferVertical=5/5`.
- Eine Positions- oder Distanzmessung ist kein Taxi-Nachweis und wird nicht als PASS-/FAIL-Kriterium verwendet.

Der technische PASS lautet:

```text
PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL
```

Er wird erst durch die Sichtabnahme ergänzt: alle fünf Gruppen heben jeweils vom Stand vertikal ab, benutzen weder Taxiway noch Runway, die AH-64 bleiben Zwei-Schiff-Gruppen und es gibt keine Kollision mit Clients, Statics oder anderer KI.

## DCS-Teststatus

```yaml
implementation: IMPLEMENTED_AWAITING_DCS
runtime: NOT_TESTED
owner_visual_acceptance: NOT_TESTED
```
