---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B Fortress automatic-response acceptance planning
  - Fortress active infantry guard and scalable local QRF response
  - Fortress threat-to-real-CAS execution and completion
  - native MOOSE Ground return-to-origin proof for tested Fortress infantry
  - post-combat personnel settlement and resupply reevaluation proof
not_authoritative_for:
  - production-wide response-force sizing policy
  - production CAS source-selection policy
  - production CAS altitude/speed policy
  - installations other than Fortress
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Stage 2B plan with passive ONGUARD-only sentry behavior and exactly one QRF
  - branch-local Stage 2B plan using explicit Fortress ACCESS RTZ as the default return implementation
  - OMW-GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1 as the next required test path
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 2B – Fortress full automatic-response Acceptance 2

## Ziel

Der nächste DCS-Lauf ist ein vollständiger gemeinsamer Fortress-Test. Der letzte reale Lauf hat bereits CAS-Dispatch/Recovery, QRF-Materialisierung, native Fortress-ReturnToLegion-Rückkehr und CampaignState-Settlement nachgewiesen, aber **nicht** die gewünschte aktive Ground-Reaktion und **nicht** den `OMW_FlightPath`-Korridor.

Der neue Test muss deshalb insbesondere diese beiden offenen Verhaltensblöcke beweisen:

```text
Fortress Guard ONGUARD
-> RED threat detected
-> MOOSE SetEngageDetected
-> ARMYGROUP EngageTarget
-> visible active movement/engagement

RED groups detected by OPSZONE
-> deterministic target ordering
-> as many local QRF groups as needed and available
-> one MOOSE GROUNDATTACK per assigned RED group
-> visible active movement/engagement
```

und:

```text
Jalalabad AH-64D
-> OMW_FlightPath outbound valley corridor
-> CAS
-> reverse OMW_FlightPath return valley corridor
-> Jalalabad RTB / Landed / Arrived
```

Ein PASS nur bis `MissionExecute` ist unzulässig.

## Verbindlicher MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## MOOSE-First Ground-Response

Der gepinnte Source bestätigt `AUFTRAG:SetEngageDetected(...)`. MOOSE selbst kombiniert in seinem CHIEF-Pfad `AUFTRAG:NewONGUARD(...)` mit `SetEngageDetected(...)`. Für `ARMYGROUP` führt erkannte Zielerfassung zu `EngageTarget(...)`; `onafterEngageTarget` setzt ROE/Alarmzustand, ermittelt eine Zwischenkoordinate nahe dem Ziel und fügt einen aktiven Ground-Waypoint ein.

Daher gilt für den Guard im Acceptance-Harness:

```text
AUFTRAG:NewONGUARD(Fortress coordinate)
-> SetEngageDetected(~1000 m, {"Ground Units"})
-> MOOSE detection
-> ARMYGROUP:EngageTarget(...)
```

`ONGUARD` ist damit die Bereitschafts-/Sicherungsmission, aber **kein passiver Endzustand bei erkanntem Feind**.

Der Test verlangt den Log-/FSM-Nachweis:

```text
SENTRY_ENGAGE_TARGET
```

und zusätzlich sichtbare Bewegung bzw. ein plausibles aktives Engagement in DCS.

## MOOSE-First QRF

`AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)` ist laut gepinntem Source der MOOSE-eigene Ground-Attack-Workaround: Ground-Gruppen werden in die Nähe des konkreten Zielobjekts geführt und bekämpfen das erkannte Ziel anschließend selbständig.

Der Harness verwendet deshalb weiterhin **keinen eigenen DCS Attack Group/Attack Unit Task**.

Die bisherige künstliche Ein-QRF-Begrenzung ist entfernt. Für diesen Acceptance-Test gilt:

```text
Fortress initial PERSONNEL: 160
Guard reservation: 9
Defence reserve floor: 80
QRF squad size: 9
QRF physical test assets: max 7 groups
```

Die tatsächliche QRF-Anzahl wird zur Laufzeit begrenzt durch das Minimum aus:

```text
number of alive RED groups detected in the OPSZONE
physical available GROUNDATTACK-capable QRF assets
CampaignState personnel slots above the 80-person reserve floor
acceptance cap of 7 QRF groups
```

Es werden **nicht** blind sieben Gruppen erzeugt.

Die RED-Gruppen werden deterministisch sortiert:

```text
nearest to Fortress first
-> stable name tie-break
```

Jede disponierte QRF erhält genau eine konkrete lebende RED-Gruppe als `GROUNDATTACK`-Ziel. Der Harness protokolliert:

```text
QRF_RESPONSE_PLAN
QRF_QUEUED index=<n> targetGroup=<name> distanceM=<distance>
QRF_ON_MISSION
QRF_GROUNDATTACK_EXECUTING
QRF_ENGAGE_TARGET
QRF_DISPATCH_COMPLETE
```

Ein `QRF_GROUNDATTACK_EXECUTING` ohne anschließenden `QRF_ENGAGE_TARGET` reicht nicht als aktiver Gegenangriffs-PASS.

## PLATOON-Assetsemantik

Der gepinnte Source bestätigt die Signatur:

```lua
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
```

`Ngroups` ist die Anzahl der Asset-Gruppen des Platoons. Der Acceptance-Harness darf daher sieben physische QRF-Assetgruppen aus demselben 9-Mann-Template bereitstellen, ohne zusätzliche Mission-Editor-Templates anzulegen.

## Fortress-Prüfobjekte

```text
Installation: BLUE_GROUND_COP_FORTRESS
CampaignState node: GROUND_NODE_FORTRESS
Warehouse: WH_BLUE_GND_FORTRESS
Infantry template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Guard: 9 PERSONNEL
QRF: 9 PERSONNEL per dispatched group
Defence reserve floor: 80 PERSONNEL
Runtime security zone: OMW_SECURITY_BLUE_GROUND_COP_FORTRESS_A2
Runtime security radius: 1000 m
OPSZONE update: 5 s, acceptance-only
```

Keine zusätzliche Mission-Editor-Testzone wird angelegt.

## Ground Return

Der bereits real beobachtete MOOSE-native Herkunftspfad bleibt unverändert:

```text
origin Fortress BRIGADE/PLATOON
-> normal mission lifecycle
-> ReturnToLegion default true
-> origin Legion spawnzone
-> Warehouse WH_BLUE_GND_FORTRESS spawn zone
-> Returned
-> origin Warehouse AddAsset
```

Der Harness enthält weiterhin **nicht**:

```text
SetSpawnZone(...)
SetReturnToLegion(false)
explicit ARMYGROUP:RTZ(...)
Teleport(...)
```

Für jede disponierte QRF wird Return/Dead/Settlement separat verfolgt.

## CampaignState PERSONNEL

Deployment bleibt Reservation, nicht Consumption:

```text
deployment:
quantity unchanged
available -= 9 per deployed infantry group

return:
reservation released
survivors become available

confirmed casualty:
quantity decreases exactly once
```

Jede QRF besitzt eine eigene Deployment-ID. Nach Abschluss aller Guard-/QRF-Deployments wird die bestehende PERSONNEL-Reorder-Policy erneut ausgewertet.

## CAS und OMW_FlightPath

Bestehende Ressourcen:

```text
AIRWING: AW_US_JBAD_TF_SHOOTER_6_6_CAV
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
PATHLINE: OMW_FlightPath
```

Der letzte DCS-Lauf zeigte, dass der CAS zwar dispatched, eingesetzt und nach Jalalabad zurückgeführt wurde, der Tal-Korridor aber nicht installiert wurde. Die Ursache war eine zu strenge Route-Ready-Annahme: der Adapter verlangte zusätzlich zum Mission-Waypoint-UID einen Egress-UID, obwohl `NewCAS` keinen separaten Egress-Waypoint garantieren muss.

Der korrigierte Adaptervertrag lautet:

```text
mission waypoint UID: required
egress waypoint UID: optional
OnAfterUpdateRoute: MOOSE-native deferred installation fallback
```

Der neue DCS-Lauf muss **beide Richtungen sichtbar** beweisen:

```text
OUTBOUND:
Jalalabad -> OMW_FlightPath valley corridor -> Fortress

RETURN:
Fortress -> reverse OMW_FlightPath valley corridor -> Jalalabad
```

Ein direkter Luftlinienflug über die Berge oder ein direkter Terrain-Following-RTB über die Berghänge ist kein Corridor-PASS.

## PASS-Kriterien

Der Acceptance-Test darf erst PASS melden, wenn mindestens nachgewiesen sind:

```text
real Fortress Guard materialized
Guard ONGUARD executing
Guard SENTRY_ENGAGE_TARGET observed
visible plausible Guard active engagement
OPSZONE Attacked(RED)
exactly one CAS_IMMEDIATE demand
exactly one Jalalabad AH-64D CAS dispatch
CAS executing
OMW_FlightPath corridor installed
visible outbound valley transit
QRF_RESPONSE_PLAN produced
>= 1 QRF dispatched
all dispatched QRFs have concrete target groups
all dispatched QRFs reach QRF_ENGAGE_TARGET or are physically destroyed before doing so
visible plausible QRF movement/engagement
OPSZONE Defeated(RED)
CAS closure requested
visible reverse-valley return
CAS RTB / Landed / Arrived
Guard native origin return or confirmed destruction
all QRFs native origin return or confirmed destruction
CampaignState settlement for every deployed infantry group
post-combat PERSONNEL reorder evaluated
CAS MissionDemand == SUCCESS
no defence reserve floor violation
final strategic PERSONNEL quantity == initial quantity - confirmed casualties
```

## DCS-only Geometriegrenzen

Folgende Punkte bleiben bis zum realen Lauf ausdrücklich unvalidiert:

```text
Guard SetEngageDetected causes useful infantry maneuver in Fortress geometry
multiple concurrent QRFs receive and execute useful routes
GROUNDATTACK pathfinding around HESCOs/terrain
RED assault pathfinding avoids pathological HESCO penetration
OMW_FlightPath is actually flown outbound
reverse OMW_FlightPath survives mission closure/RTB and is actually flown
native Warehouse homezone remains geometrically acceptable for all survivors
```

Ein Log-PASS bei sichtbar unplausiblem Pathfinding ist kein Produktions-PASS.

## Build

```text
tools/build-fob-attack-cas-dispatch-acceptance-2.ps1

-> mission/tests/fob-attack-support-demand/dist/
   OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua
```

Aktueller Builder-Vertrag:

```text
FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-6
Fortress only
Infantry Guard + scalable Infantry QRF
Guard active response: MOOSE SetEngageDetected
QRF target assignment: deterministic nearest-first
QRF maximum: 7 groups, additionally bounded by assets/reserve floor/RED target count
additional ME test zone: false
Ground spawnzone override: false
Ground SetReturnToLegion(false): false
Ground explicit RTZ: false
MIZ mutation: false
```

Status:

```text
READY_FOR_BUILD_AND_DCS_TEST_AFTER_LOCAL_HASH_VERIFICATION
```
