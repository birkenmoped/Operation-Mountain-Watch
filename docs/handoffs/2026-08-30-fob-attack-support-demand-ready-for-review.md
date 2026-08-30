---
document_id: OMW-HANDOFF-2026-08-30-FOB-ATTACK-SUPPORT-DEMAND-RFR
status: BINDING
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - final review handoff for PR 138 before merge
  - exact Stage 2A and Stage 2B acceptance provenance
  - development chronology, failure analysis, fixes, and local verification commands
not_authoritative_for:
  - new architecture beyond the merged Stage 2 scope
  - installations other than the documented Fortress acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: f7348224d2740cf519315bcdfc727d9eed3b241e
validated_in_dcs: true
---

# Stage 2 FOB/COP Automatic Response – Ready-for-Review Handoff

## 1. Ziel

PR #138 integriert Stage 2 der automatischen Reaktion auf einen bedrohten BLUE-FOB/COP. Der Branch wurde nach realem DCS-Test durch den Projektinhaber für den dokumentierten Fortress-Scope als PASS geschlossen und für Ready for Review sowie Merge freigegeben.

```text
Branch: agent/fob-attack-support-demand
PR: #138
Base: main
Pinned MOOSE: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 2. Architekturgrenze

Unverändert verbindlich:

```text
CampaignState = strategische Ressourcenautorität
MOOSE = physische Runtime-Ausführung und Lifecycle
DCS groups = temporäre Repräsentationen
```

Stage 2 führt keine zweite Ressourcenhoheit ein. Kein MIST, kein eigener `world.addEventHandler`, kein eigener DCS-Ground-Attack-Task, kein eigener Ground-RTZ-Controller, keine Mutation von `MissionScripting.lua`.

## 3. Stage 2A – Bedrohungserkennung

Der ursprüngliche Ansatz verlangte einen realen Treffer auf ein bestimmtes BLUE-Ziel. Das erwies sich als zu spät und unnötig fragil.

Die MOOSE-first-Korrektur wurde:

```text
WH_BLUE_GND_FORTRESS coordinate
-> runtime ZONE_RADIUS(1000 m)
-> BLUE OPSZONE
-> real BLUE local-security presence remains
-> RED Ground presence enters
-> OPSZONE Attacked(RED)
-> qualified installation incident
-> CAS_IMMEDIATE MissionDemand
```

Damit ist kein `EVENTS.Hit`/`EVENTS.Shot` als Primärtrigger erforderlich.

Stage 2A wurde am 29.08.2026 in DCS bestanden. Vollständige Provenienz liegt in:

```text
mission/tests/fob-attack-support-demand/RESULT-1.md
```

## 4. Stage 2B – erster CAS-Ausführungspfad

Der MOOSE-first-CAS-Pfad nutzt:

```text
CAS_IMMEDIATE
-> OMW_FobAttackCasDispatchAdapter
-> existing Jalalabad AIRWING
-> existing AH-64D SQUADRON
-> AUFTRAG:NewCAS(...)
-> AIRWING:AddMission(...)
-> AIRWING OnAfterFlightOnMission
-> FLIGHTGROUP
```

Kein eigener Spawn-/Dispatcher wurde gebaut.

## 5. CAS-Talroute – Fehlerhistorie und Fix

### 5.1 Beobachteter Fehler

In einem realen DCS-Lauf materialisierte der AH-64D korrekt, flog aber direkt über das Gebirge. Der Log zeigte:

```text
CAS_CORRIDOR_INSTALL_FAILED reason=MISSION_ROUTE_UIDS_NOT_READY
```

### 5.2 Ursache 1 – Callback zu früh

Der gepinnte MOOSE-Source zeigte:

```text
LEGION OpsOnMission
-> AIRWING FlightOnMission

OPSGROUP MissionStart
-> RouteToMission(Mission, 3)
```

Damit kann `OnAfterFlightOnMission` eintreten, bevor die gruppenspezifische Missionsroute aufgebaut ist.

Fix:

```text
route UID not ready
-> bind FLIGHTGROUP OnAfterUpdateRoute
-> wait for MOOSE RouteToMission
-> install corridor after route creation
```

### 5.3 Ursache 2 – falsche Egress-Annahme

Der Adapter verlangte zusätzlich zum Mission-Waypoint-UID einen Egress-UID. Der gepinnte Source zeigte jedoch:

```text
mission waypoint UID = always created for RouteToMission mission route
egress UID = only created if MissionEgressCoord exists
```

`AUFTRAG:NewCAS(...)` garantiert keinen Egress-Punkt.

Fix:

```text
mission waypoint UID: required
egress UID: optional
```

### 5.4 String-Vertrag

Zwischen Adapter und Acceptance-Harness bestand zwischenzeitlich zusätzlich:

```text
MISSION_ROUTE_UID_NOT_READY
vs.
MISSION_ROUTE_UIDS_NOT_READY
```

Dieser Pending-Status wurde vereinheitlicht, damit ein legitimer MOOSE-Route-Build nicht als Testfehler behandelt wird.

### 5.5 Rückflug

Die Reverse-`OMW_FlightPath`-Waypoints werden nach dem CAS-Missions-Waypoint eingefügt und sind nicht als mission-owned Waypoints markiert. Der MOOSE-Source-Review zeigte, dass beim Missionsabschluss nur die mission-owned Waypoints entfernt werden. Dadurch bleiben die Reverse-Corridor-Waypoints erhalten; der eigentliche `RTB()`-Landing-Pfad folgt erst anschließend.

Finaler DCS-Lauf:

```text
CAS_CORRIDOR_INSTALLED
corridorPoints=14
outboundWaypoints=14
returnWaypoints=13
altitudeFtAGL=500
```

Der Projektinhaber bestätigte visuell:

```text
outbound valley route: PASS
return valley route: PASS
```

Danach:

```text
CAS_RTB
CAS_LANDED
CAS_ARRIVED
```

## 6. Guard – aktives Reagieren statt passiver Stand

Der reine `ONGUARD`-Gedanke wurde als zu passiv verworfen. Ein Perimeterschutz muss bei erkannten Feinden aktiv reagieren.

MOOSE-first-Korrektur:

```text
AUFTRAG:NewONGUARD(...)
+ AUFTRAG:SetEngageDetected(..., {"Ground Units"})
-> native ARMYGROUP EngageTarget lifecycle
```

Der gepinnte MOOSE-Source verwendet selbst `ONGUARD + SetEngageDetected` in seinem strategischen Pfad. Es wurde daher keine eigene Attack-Task-Logik ergänzt.

Im finalen Lauf:

```text
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING activeResponse=MOOSE_SET_ENGAGE_DETECTED
```

Der Guard-Missionsabschluss wurde nach Threat Clear angefordert. Ein abschließendes `GUARD_RETURNED_ORIGIN` wurde vor Missionsende nicht geloggt. Der Owner akzeptierte den beobachteten Guard/HESCO-Restbefund ausdrücklich als nicht blockierende Einschränkung dieses Stage-2B-PASS.

## 7. QRF – von einer festen Gruppe zu bedarfsgerechter Multi-QRF

### 7.1 Fehler des früheren Harness

Der Harness verhinderte weitere QRFs effektiv nach der ersten Gruppe. Zusätzlich wurde ein RED-Ziel aus einer unsortierten Gruppenmenge gewählt. Das war keine belastbare taktische Zuordnung.

### 7.2 Neue MOOSE-first-Logik

`AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)` bleibt der MOOSE-eigene Ground-Attack-Weg. Keine Native-DCS-`Attack Group`-/`Attack Unit`-Tasks.

Dispatch-Limit:

```text
min(
  alive RED groups in OPSZONE,
  available GROUNDATTACK-capable QRF assets,
  CampaignState 9-person slots above reserve floor 80,
  acceptance cap 7
)
```

Zielsortierung:

```text
nearest to Fortress first
-> stable group-name tie-break
```

Jede QRF erhält eine eigene konkrete RED-Gruppe.

### 7.3 Finaler Lauf

```text
QRF_RESPONSE_PLAN
redGroups=3
availableAssets=7
strategicSlots=7
maxGroups=7
dispatchGroups=3
reserveFloor=80

QRF_DISPATCH_COMPLETE
dispatched=3
redGroups=3
undispatched=0
reasonForLimit=ALL_DETECTED_RED_GROUPS_ASSIGNED
```

Zuordnung:

```text
QRF-1 -> Ground-3 -> 751 m
QRF-2 -> Ground-1 -> 778 m
QRF-3 -> Ground-2 -> 878 m
```

Alle drei QRFs materialisierten und gingen in den Ground-Attack-Lifecycle. Zwei MOOSE-Missionen wurden als `success`, eine als `failed` bewertet; alle drei Gruppen erreichten dennoch den nativen Herkunfts-Return.

## 8. Ground Return und CampaignState

Es wurde bewusst kein eigener Rückkehr-Controller eingeführt.

```text
SetReturnToLegion(false): false
explicit ARMYGROUP:RTZ: false
WAREHOUSE:SetSpawnZone override: false
```

Drei QRF-Rückkehrer:

```text
QRF-2 -> Returned origin -> 4 survivors / 5 casualties
QRF-3 -> Returned origin -> 1 survivor / 8 casualties
QRF-1 -> Returned origin -> 2 survivors / 7 casualties
```

Herkunft:

```text
WH_BLUE_GND_FORTRESS
Warehouse WH_BLUE_GND_FORTRESS spawn zone
```

CampaignState-Abrechnung:

```text
deployment -> reserve
return -> release reservation / survivors available
confirmed casualties -> consume exactly once
```

## 9. Finaler Acceptance-2-PASS

Exakte Provenienz:

```text
Tested source commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
BuilderVersion: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-6
Bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
Mission: OMW_Template_v20_GroundWorks(20260830-132050).miz
Mission SHA-256: 28FE4AB40F54CEB48FA5428C0E5E2DAF2874F6F61213C964A317434087F413CC
Embedded bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
DCS: 2.9.29.27278
dcs.log SHA-256: 062B83B61C02E7F7A93CF260540588F6849819E74CF1DC20F406EDF17C170EE2
debrief.log SHA-256: 4863E4B945E3B8F4719E081A18A56737E74989A414CBEB05B62793C53CE605F8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Result: PASS by explicit owner decision
```

Detailliertes Ergebnis:

```text
mission/tests/fob-attack-support-demand/RESULT-2.md
```

## 10. Reale lokale Build-/Hash-Befehle

Der Owner führte den finalen Build mit folgenden Befehlen aus:

```powershell
Set-Location 'P:\DCS-DEV\Operation-Mountain-Watch-fob-attack-support-demand'
git pull --ff-only
git rev-parse HEAD
git status --short --branch
```

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\tools\build-fob-attack-cas-dispatch-acceptance-2.ps1"
```

```powershell
Get-FileHash ".\mission\tests\fob-attack-support-demand\dist\OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua" -Algorithm SHA256
```

Der reale lokale Builder-Hash und der unabhängige `Get-FileHash`-Wert stimmten überein.

## 11. Bekannte untracked lokale Verzeichnisse

Beim letzten lokalen Status waren ausschließlich die bereits bekannten Build-/Arbeitsverzeichnisse untracked:

```text
?? mission/ground-operations/
?? mission/tests/fob-attack-support-demand/dist/
?? mission/tests/ground-native-homezone-return/dist/
```

Sie sind nicht Teil des Remote-Merges.

## 12. Review-Grenzen

Der Merge akzeptiert:

```text
Stage 2A Fortress threat detection
Stage 2B CAS dispatch and lifecycle
Stage 2B OMW_FlightPath outbound/return valley routing
active Guard configuration through MOOSE SetEngageDetected
resource-aware deterministic multi-QRF dispatch
native QRF ReturnToLegion / origin Warehouse recovery
CampaignState QRF survivor/casualty settlement
```

Nicht behauptet werden:

```text
perfect DCS infantry pathfinding through every HESCO layout
GUARD_RETURNED_ORIGIN in the final run
production-wide QRF force-size doctrine
production-wide helicopter routing configuration for every mission type
acceptance beyond Fortress and exact documented provenance
```
