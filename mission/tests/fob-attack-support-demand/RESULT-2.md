---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-RESULT-2
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance Stage 2B Fortress automatic-response DCS acceptance
  - Fortress CAS valley-route execution and recovery
  - deterministic multi-QRF dispatch and native return-to-origin evidence
  - owner acceptance of the documented residual Guard return observation
not_authoritative_for:
  - installations other than Fortress
  - production-wide QRF sizing doctrine
  - arbitrary DCS Ground-AI pathfinding through dense static obstacles
  - proof that every Guard survivor completed Returned before mission shutdown
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
acceptance_branch: agent/fob-attack-support-demand
acceptance_commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
acceptance_mission: OMW_Template_v20_GroundWorks(20260830-132050).miz
acceptance_mission_sha256: 28FE4AB40F54CEB48FA5428C0E5E2DAF2874F6F61213C964A317434087F413CC
dcs_version: 2.9.29.27278
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
---

# Stage 2B – Fortress Automatic Response Acceptance 2 Result

## Ergebnis

```text
PASS
```

Der Projektinhaber hat den realen DCS-Lauf vom 30.08.2026 nach visueller Prüfung ausdrücklich als PASS geschlossen. Der akzeptierte technische Scope ist auf die unten dokumentierte Mission, den Branch-Commit, das Bundle, DCS und den gepinnten MOOSE-Stand begrenzt.

## Exakte Provenienz

```text
Branch: agent/fob-attack-support-demand
Tested source commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
BuilderVersion: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-6
Acceptance Lua: OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua
Acceptance bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
Owner-supplied MIZ artifact: OMW_Template_v20_GroundWorks(20260830-132050).miz
Owner-supplied MIZ SHA-256: 28FE4AB40F54CEB48FA5428C0E5E2DAF2874F6F61213C964A317434087F413CC
Embedded Acceptance bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
DCS version: 2.9.29.27278
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
dcs.log SHA-256: 062B83B61C02E7F7A93CF260540588F6849819E74CF1DC20F406EDF17C170EE2
debrief.log SHA-256: 4863E4B945E3B8F4719E081A18A56737E74989A414CBEB05B62793C53CE605F8
Runtime mission path from debrief: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v20_GroundWorks.miz
```

Die hochgeladene MIZ enthält das exakt lokal gebaute Acceptance-Bundle. Der interne Bundle-Hash stimmt mit dem realen lokalen Builder-/`Get-FileHash`-Wert überein.

## Validierte automatische Reaktionskette

```text
Fortress BLUE security presence
-> runtime MOOSE ZONE_RADIUS / OPSZONE
-> RED Ground presence
-> OPSZONE Attacked(RED)
-> one CAS_IMMEDIATE MissionDemand
-> Jalalabad AH-64D CAS
-> local Fortress infantry response
-> OPSZONE Defeated(RED)
-> CAS mission closure
-> valley-route return
-> Jalalabad RTB / Landed / Arrived
```

## CAS – Fehlerweg und endgültige Korrektur

Frühere Stage-2B-Läufe materialisierten den AH-64D, ließen ihn aber direkt über das Gebirge fliegen. Der entscheidende Fehler war nicht `PATHLINE` selbst, sondern die Einbauvoraussetzung des OMW-Corridor-Adapters.

Der erste fehlerhafte Vertrag verlangte gleichzeitig:

```text
AUFTRAG group mission waypoint UID
AND
AUFTRAG group egress waypoint UID
```

Der gepinnte MOOSE-Source zeigt jedoch: `OPSGROUP:RouteToMission(...)` erzeugt den Mission-Waypoint immer für die Missionsroute; einen Egress-Waypoint nur dann, wenn die AUFTRAG-Mission tatsächlich eine Mission-Egress-Coordinate besitzt. `AUFTRAG:NewCAS(...)` garantiert keinen separaten Egress-Punkt.

Dadurch blieb der frühere Adapter dauerhaft bei:

```text
CAS_CORRIDOR_INSTALL_FAILED reason=MISSION_ROUTE_UIDS_NOT_READY
```

Zusätzlich kann `AIRWING OnAfterFlightOnMission` vor dem verzögerten `OPSGROUP:RouteToMission(Mission, 3)` eintreten. Deshalb wurde die Korrektur MOOSE-first umgesetzt:

```text
mission waypoint UID = required
egress waypoint UID = optional
route not ready
-> FLIGHTGROUP OnAfterUpdateRoute
-> retry corridor installation after MOOSE route build
```

Der endgültige Lauf bestätigte:

```text
CAS_CORRIDOR_INSTALLED
group=SQ_US_JBAD_AH64D_B_1_10_AVN_AID-158
pathline=OMW_FlightPath
corridorPoints=14
outboundWaypoints=14
returnWaypoints=13
altitudeFtAGL=500
```

Der Projektinhaber bestätigte visuell sowohl den Hinflug als auch den Rückflug durch die vorgesehene Talroute. Nach Threat Clear folgten außerdem:

```text
CAS_MISSION_CLOSURE requested=true
CAS_RTB airbase=Jalalabad
CAS_LANDED airbase=Jalalabad
CAS_ARRIVED airwingAssetReturn=MOOSE_FLIGHTGROUP
```

Damit ist der `OMW_FlightPath`-Hin-/Rückflug für diesen Acceptance-Scope DCS-validiert.

## Ground – Guard und QRF

Der vorherige Testzustand war zu passiv beziehungsweise künstlich auf eine einzige QRF begrenzt. Die Korrektur blieb MOOSE-first.

### Guard

Die Bereitschaft bleibt:

```text
AUFTRAG:NewONGUARD(...)
```

Für erkannte Ground-Bedrohungen wird der MOOSE-eigene Mechanismus ergänzt:

```text
AUFTRAG:SetEngageDetected(..., {"Ground Units"})
```

MOOSE besitzt dafür den ARMYGROUP-`EngageTarget`-Lifecycle. Es wurde kein eigener DCS `Attack Group`/`Attack Unit` Task eingeführt.

Im akzeptierten Lauf wurden bestätigt:

```text
SENTRY_ON_MISSION group=PLT_BLUE_GND_FORTRESS_SENTRY_STAGE2_A2_AID-219
SENTRY_ONGUARD_EXECUTING ... activeResponse=MOOSE_SET_ENGAGE_DETECTED
GUARD_MISSION_CLOSE_REQUESTED ... returnController=MOOSE_RETURN_TO_LEGION explicitRTZ=false
MOOSE On Guard mission result: success
```

Ein abschließendes `GUARD_RETURNED_ORIGIN` wurde vor Missionsende nicht protokolliert. Nach visueller Prüfung ordnete der Projektinhaber die noch sichtbaren Soldaten dem dynamischen Guard als wahrscheinlichsten Kandidaten zu und akzeptierte diesen Restbefund ausdrücklich als nicht blockierend für Stage 2B. Daraus wird **kein** allgemeiner Nachweis abgeleitet, dass jeder Guard-Survivor den `Returned`-Callback erreicht hat.

### Deterministische Multi-QRF

Die frühere künstliche Ein-QRF-Sperre wurde entfernt. Die reale Zahl wird jetzt begrenzt durch:

```text
alive RED groups detected in OPSZONE
available GROUNDATTACK-capable QRF assets
CampaignState 9-person slots above Fortress reserve floor 80
acceptance cap 7
```

Die Zielgruppen werden deterministisch sortiert:

```text
nearest to Fortress first
-> stable group-name tie-break
```

Jede disponierte QRF erhält genau eine eigene MOOSE-`AUFTRAG:NewGROUNDATTACK(...)`-Mission gegen die konkret zugewiesene RED-Gruppe.

Der reale Lauf ergab:

```text
QRF_RESPONSE_PLAN redGroups=3 availableAssets=7 strategicSlots=7 maxGroups=7 dispatchGroups=3 reserveFloor=80
QRF_DISPATCH_COMPLETE dispatched=3 redGroups=3 undispatched=0 reasonForLimit=ALL_DETECTED_RED_GROUPS_ASSIGNED
```

Zuweisungen:

```text
QRF-1 -> Ground-3 -> 751 m
QRF-2 -> Ground-1 -> 778 m
QRF-3 -> Ground-2 -> 878 m
```

Alle drei QRFs materialisierten. Mindestens der explizit protokollierte QRF-1-Pfad erreichte `QRF_ENGAGE_TARGET`; zwei MOOSE Ground-Attack-Aufträge endeten `success`, einer `failed`. Der Owner bewertete den sichtbaren Ground-Gegenangriff insgesamt als plausibel und den Lauf als PASS.

## Native QRF-Rückkehr und CampaignState-Settlement

Alle drei QRF-Gruppen erreichten den origin-bound MOOSE-Rückkehrpfad zum Fortress-Warehouse:

```text
QRF-2: survivors=4 casualties=5 -> QRF_RETURNED_ORIGIN
QRF-3: survivors=1 casualties=8 -> QRF_RETURNED_ORIGIN
QRF-1: survivors=2 casualties=7 -> QRF_RETURNED_ORIGIN
```

Ziel blieb jeweils:

```text
warehouse=WH_BLUE_GND_FORTRESS
homezone=Warehouse WH_BLUE_GND_FORTRESS spawn zone
```

Der Harness verwendet weiterhin keinen eigenen Ground-Return-Controller:

```text
SetReturnToLegion(false): false
explicit ARMYGROUP:RTZ(...): false
WAREHOUSE:SetSpawnZone(...) override: false
Teleport: false
```

CampaignState reserviert Personal während der physischen Deployment-Phase und verbraucht erst bestätigte Verluste. Die QRF-Settlements wurden einzeln ausgeführt.

## Bekannte und akzeptierte Grenze

Der Lauf zeigte nach Kampfende noch einzelne BLUE-Soldaten im Fortress-/HESCO-Bereich. Die drei QRFs waren zu diesem Zeitpunkt bereits als `RETURNED_ORIGIN` protokolliert. Für den Guard wurde dagegen zwar die Mission geschlossen, aber kein abschließendes `GUARD_RETURNED_ORIGIN` vor Missionsende geloggt.

Der Projektinhaber entschied am 30.08.2026 ausdrücklich:

```text
Stage 2B Acceptance 2 = PASS
residual Guard/HESCO return observation = accepted non-blocking limitation
```

Diese Entscheidung ersetzt keinen späteren Ground-AI-/Pathfinding-Test. Sie begrenzt nur den Acceptance-Claim: Stage 2B beweist die automatische Response-Orchestrierung, den QRF-Rückkehrpfad und die CAS-Talroute; nicht die perfekte Navigation jedes Guard-Survivors durch jede HESCO-Geometrie.

## Acceptance-Grenze

Validiert für den dokumentierten Fortress-Scope:

```text
OPSZONE threat detection
CAS_IMMEDIATE demand creation and dedupe
Jalalabad AH-64D CAS dispatch/materialization/execution
OMW_FlightPath outbound corridor
OMW_FlightPath reverse return corridor
Threat Clear -> CAS closure -> RTB -> Landed -> Arrived
Guard ONGUARD + SetEngageDetected configuration
resource-aware deterministic multi-QRF dispatch
one GROUNDATTACK per assigned RED group
three concurrent QRF deployments in the tested threat set
native QRF ReturnToLegion to Fortress origin Warehouse
per-QRF survivor/casualty CampaignState settlement
Fortress defence reserve floor respected
```

Nicht als allgemeine Wahrheit validiert:

```text
all installations
all terrain/static layouts
perfect Guard return through dense HESCO geometry
every dispatched QRF mission ending SUCCESS
production-wide QRF cap or force-sizing doctrine
production CAS altitude/speed policy
```
