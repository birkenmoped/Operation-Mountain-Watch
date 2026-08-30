---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-2
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B MOOSE class/API evidence pending DCS Acceptance 2
  - branch-local source evidence for Ground Warehouse spawnzone/homezone/ReturnToLegion behavior
  - branch-local source evidence for FLIGHTGROUP route-ready corridor installation
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main
  - DCS validation before Acceptance 2 passes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 2 Acceptance 2 – MOOSE class evidence

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Source-verifizierter Stage-2B-Scope

| Klasse/Pfad | Status vor DCS-Test | Stage-2B-/Ground-Verwendung |
|---|---|---|
| `OPSZONE OnAfterAttacked(From, Event, To, AttackerCoalition)` | `SOURCE_VERIFIED`, Stage 2A DCS-validiert | qualifizierter RED-Angriff auf den verteidigten Perimeter |
| `OPSZONE OnAfterDefeated(From, Event, To, DefeatedCoalition)` | `SOURCE_VERIFIED_PENDING_DCS` | RED ist aus dem verteidigten BLUE-Perimeter beseitigt; Stage-2B-Threat-Clear-Signal |
| `AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)` | `SOURCE_VERIFIED_PENDING_DCS` | vorhandener Jalalabad-AH-64D-CAS-Auftrag |
| `AIRWING` / `LEGION:AddMission` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener Jalalabad-AIRWING nimmt den CAS-AUFTRAG in seine Mission Queue auf |
| `SQUADRON` / `COHORT:AddMissionCapability` | `SOURCE_VERIFIED`, vorhandene OMW Foundation | vorhandener AH-64D-SQUADRON besitzt `AUFTRAG.Type.CAS` |
| `AIRWING OnAfterFlightOnMission` | `SOURCE_VERIFIED_PENDING_DCS` | reale FLIGHTGROUP-Materialisierung/Missionszuordnung; kann vor dem verzögerten Aufbau der gruppenspezifischen AUFTRAG-Route eintreten |
| `OPSGROUP:onafterMissionStart` / `RouteToMission(Mission, 3)` | `SOURCE_VERIFIED` | MOOSE setzt Mission STARTED und baut die Missionsroute anschließend verzögert auf; erklärt `nil`-Route-UIDs im früheren AIRWING-Callback |
| `FLIGHTGROUP OnAfterUpdateRoute(From, Event, To, n, N)` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | MOOSE-FSM-Callback zum eventgebundenen Einfügen des `OMW_FlightPath`-Korridors, sobald die Missionsroute aufgebaut wurde |
| `AUFTRAG OnAfterExecuting` | `SOURCE_VERIFIED_PENDING_DCS` | reale CAS-Missionausführung; MissionDemand wird `ACTIVE` |
| `AUFTRAG:Cancel()` | `SOURCE_VERIFIED_PENDING_DCS` | beendet den laufenden CAS-Auftrag nach `OPSZONE Defeated(RED)` über den MOOSE-FSM-Pfad |
| `FLIGHTGROUP:_CheckGroupDone()` / `RTB()` | `SOURCE_VERIFIED_PENDING_DCS` | nach Missionsende ohne verbleibende Mission/Task geht AI zum Home-/Destination-Airbase zurück |
| `FLIGHTGROUP OnAfterRTB` | `SOURCE_VERIFIED_PENDING_DCS` | Acceptance-Nachweis des begonnenen Rückflugs |
| `FLIGHTGROUP OnAfterLanded` | `SOURCE_VERIFIED_PENDING_DCS` | Acceptance-Nachweis der Landung |
| `FLIGHTGROUP OnAfterArrived` | `SOURCE_VERIFIED_PENDING_DCS` | Acceptance-Nachweis des MOOSE-Airwing-Recovery-Lifecycles |
| `AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)` | `SOURCE_VERIFIED_PENDING_DCS` | lokale Infanterie-QRF gegen die reale RED-Gruppe aus dem OPSZONE-Scan; MOOSE-eigener Ground-Attack-Weg statt eigener Attack-Task-Logik |
| `WAREHOUSE` constructor default `zone` / `spawnzone` | `SOURCE_VERIFIED_PENDING_DCS_GEOMETRY` | normales Ground-Warehouse erzeugt `zone` mit 500 m und `spawnzone` mit 250 m Radius um das Warehouse-Objekt |
| `WAREHOUSE:SetSpawnZone(zone, maxdist)` | `SOURCE_VERIFIED`; ältere OMW Ground-Acceptances nutzen die API | öffentliche Konfiguration der Materialisierungszone; `maxdist` default 5000 m; beeinflusst auch spätere ARMYGROUP-`homezone` |
| `LEGION:_CreateFlightGroup(asset)` Ground branch | `SOURCE_VERIFIED` | erzeugt `ARMYGROUP`, setzt Herkunfts-Legion und `opsgroup.homezone=self.spawnzone` |
| `OPSGROUP:SetReturnToLegion(Switch)` | `SOURCE_VERIFIED` | `true` oder `nil` setzt Ground/Naval-Group auf Return; `false` hält sie nach der letzten Mission im Feld |
| `AUFTRAG:SetReturnToLegion(Switch)` | `SOURCE_VERIFIED` | `true` fordert Return, `false` verhindert Return, `nil` lässt das Asset entscheiden; MissionDone übernimmt nur expliziten Mission-Wert |
| `ARMYGROUP:RTZ(Zone, Formation)` / `self.homezone` fallback | `SOURCE_VERIFIED`, expliziter RTZ in vorhandenen OMW DCS-Return-Baselines validiert | ohne explizite Zone verwendet RTZ die origin `homezone`; außerhalb wird `zone:GetRandomCoordinate()` als Wegpunkt gewählt |
| `ARMYGROUP/OPSGROUP Returned` | `SOURCE_VERIFIED`, vorhandene OMW DCS-Return-Baselines | bei `Returned` ruft ARMYGROUP die eigene Herkunfts-Legion per `__AddAsset(10, self.group, 1)` auf |
| `OPSGROUP:SetReturnOnOutOfAmmo(...)` / `OutOfAmmo`-Lifecycle | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | MOOSE besitzt einen nativen Leerschuss-Rückkehrpfad; Stage 2B führt keinen eigenen Ammo-Poller ein |
| `OPSGROUP:GetNelements()` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | Zahl der überlebenden physischen Elemente beim Recovery-/Loss-Settlement |
| `PATHLINE:FindByName("OMW_FlightPath")` / `PATHLINE:GetCoordinates()` | `SOURCE_VERIFIED`; OMW-FlightPath bereits in PERSONNEL-Air-Resupply DCS-validiert | owner-authored Tal-/Transitkorridor als gemeinsame Geometriequelle |
| `AUFTRAG:GetGroupWaypointIndex(...)` / `GetGroupEgressWaypointUID(...)` | `SOURCE_VERIFIED`; vorhandener OMW FlightPath-Präzedenzfall | gruppenspezifische MOOSE-Missionsanker; dürfen vor `RouteToMission` noch `nil` sein |
| `FLIGHTGROUP:AddWaypoint(...)` | `SOURCE_VERIFIED`; vorhandener OMW FlightPath-Präzedenzfall | 500-m-Rechtsversatz outbound/return, 500 ft AGL; bei Helos verwendet MOOSE Radar-/AGL-Waypoints |
| `AUFTRAG OnAfterSuccess` / `OnAfterFailed` | `SOURCE_VERIFIED_PENDING_DCS` | terminaler MissionDemand-Status nach MOOSE-Abschluss/Fehlschlag |

Die offizielle MOOSE-Missionssammlung wurde für `GROUNDATTACK` und für einen belastbaren `OnAfterUpdateRoute`-Korridor-Präzedenzfall durchsucht; es wurde dabei kein belastbarer Demo-Nachweis gefunden. Deshalb wird für diese Pfade der tatsächlich gepinnte `Moose.lua` als API-/Semantiknachweis verwendet. Es wird kein nicht gefundener Demo-Test behauptet.

## Verifizierte Threat-Clear-Semantik

Der gepinnte `OPSZONE`-FSM definiert:

```text
Attacked -> Defeated -> Guarded
```

Für eine BLUE-owned Zone gilt im relevanten Pfad: bleibt BLUE im Perimeter und ist RED nicht mehr vorhanden, erzeugt MOOSE `Defeated(RED)`. Stage 2B verwendet genau diesen Framework-Zustandswechsel als Threat-Clear-Signal. Ein separater OMW-Präsenzscanner wird nicht eingeführt.

## Verifizierte CAS-Routenbereitschaft

Der gepinnte Source belegt die Reihenfolge:

```text
LEGION OpsOnMission
-> AIRWING FlightOnMission

OPSGROUP MissionStart
-> RouteToMission(Mission, 3)
-> gruppenspezifische Mission-/Egress-Waypoint-UIDs
-> FLIGHTGROUP UpdateRoute
```

Der DCS-Lauf mit Commit `8d900cf5f87082e79a46e9ba53602aa1e6ff6810` zeigte praktisch, dass ein ausschließlich timerbasierter Zugriff aus `AIRWING FlightOnMission` zu früh sein kann:

```text
CAS_CORRIDOR_INSTALL_FAILED reason=MISSION_ROUTE_UIDS_NOT_READY
```

Dies ist kein Nachweis gegen `OMW_FlightPath`, sondern gegen die bisherige Timing-Annahme des Stage-2B-Adapters.

Der korrigierte Branch-Pfad verwendet deshalb den MOOSE-FSM-Callback:

```text
route UIDs ready
-> FLIGHTGROUP:AddWaypoint(...)

route UIDs not ready
-> arm FLIGHTGROUP OnAfterUpdateRoute
-> MOOSE RouteToMission creates route
-> OnAfterUpdateRoute
-> FLIGHTGROUP:AddWaypoint(...)
```

`OMW_HelicopterFlightPathCorridor` Schema 2 cached eine erfolgreiche Installation pro FLIGHTGROUP/AUFTRAG, damit ein späterer Acceptance-Aufruf dieselben Waypoints nicht erneut einfügt.

Diese Korrektur ist source- und unit-testbar, bleibt für den sichtbaren Talflug jedoch `PENDING_DCS`.

Themendokument:

```text
docs/moose/FOB-ATTACK-CAS-ROUTE-READY-STAGE-2B.md
```

## Verifizierte CAS-Abschluss-Semantik

`AUFTRAG:NewCAS(...)` ist im gepinnten Source aus einer ORBIT-Mission abgeleitet und besitzt zusätzlich `EngageTargetsInZone`. Deshalb endet eine CAS-Mission nicht automatisch nur deshalb, weil aktuell keine Ziele mehr vorhanden sind.

Stage 2B koppelt deshalb die vorhandenen MOOSE-Lifecycles:

```text
OPSZONE Defeated(RED)
-> AUFTRAG:Cancel()
-> FLIGHTGROUP has no remaining mission/task
-> MOOSE RTB
-> Landed
-> Arrived / AIRWING recovery
```

Diese Kette ist source-verifiziert, aber für die neue Stage-2B-Komposition noch `PENDING_DCS`.

## Verifizierte Ground-Warehouse-/Homezone-Semantik

Der gepinnte Source erzeugt für ein normales nicht schiffsbasiertes `WAREHOUSE`:

```text
self.zone:
ZONE_RADIUS centered on Warehouse object, radius 500 m

self.spawnzone:
ZONE_RADIUS centered on Warehouse object, radius 250 m
```

Die öffentliche API

```lua
WAREHOUSE:SetSpawnZone(zone, maxdist)
```

ersetzt `self.spawnzone`; `maxdist` ist optional und fällt auf 5000 m zurück.

Wenn `LEGION` für eine Brigade ein Ground-Asset materialisiert, wird:

```text
ARMYGROUP created
-> opsgroup._SetLegion(origin Legion)
-> opsgroup.homezone = origin Legion spawnzone
```

Damit enthält die MOOSE-Gruppe bereits ihre Herkunfts-Legion und ihren Herkunfts-Rückkehrbereich.

## Verifizierte `ReturnToLegion`-/RTZ-Semantik

Für Ground/Naval-Gruppen gilt source-seitig:

```text
OPSGROUP:SetReturnToLegion(true or nil)
-> legionReturn = true

OPSGROUP:SetReturnToLegion(false)
-> legionReturn = false
```

Für Missionskonfiguration gilt:

```text
AUFTRAG:SetReturnToLegion(true)
-> mission requests return

AUFTRAG:SetReturnToLegion(false)
-> mission prevents return

AUFTRAG:SetReturnToLegion(nil)
-> asset decides
```

Beim MissionDone-Pfad wird ein expliziter `Mission.legionReturn`-Wert auf das OPSGROUP übernommen. Deshalb ist `SetReturnToLegion(false)` kein neutraler Default, sondern eine bewusste Feldpersistenz-/Sonderpfadentscheidung.

`ARMYGROUP:RTZ(...)` verwendet:

```text
Zone argument OR self.homezone
```

und bei mobilen Gruppen:

```text
already in zone
-> Returned()

outside zone
-> zone:GetRandomCoordinate()
-> AddWaypoint(...)
-> physical return movement
```

Für immobile Gruppen außerhalb der Zone existiert ein Teleportpfad. Dieser bleibt für beobachtbare OMW-Bereiche ausgeschlossen.

`ARMYGROUP:onafterReturned(...)` ruft anschließend die bereits gespeicherte Herkunfts-Legion auf:

```lua
self.legion:__AddAsset(10, self.group, 1)
```

Damit ist der normale Framework-Lifecycle grundsätzlich origin-bound.

## Neue Ground-Designgrenze

Die bereits akzeptierten OMW Ground-Resupply-Acceptances haben einen **expliziten** MOOSE-Pfad nachgewiesen:

```text
SetReturnToLegion(false)
-> mission end/cancel
-> delayed ARMYGROUP:RTZ(origin ACCESS, formation)
-> physical return
-> Returned
-> Warehouse AddAsset
```

Dieser Nachweis bleibt gültig, wird aber nicht mehr als Beweis interpretiert, dass jedes Ground-Asset explizites RTZ oder eine ACCESS-Zone benötigt.

Die neue MOOSE-first-Prüfreihenfolge lautet:

```text
1. native Warehouse spawnzone/homezone + normal ReturnToLegion
2. if geometry fails: public WAREHOUSE:SetSpawnZone(origin ACCESS, ...)
3. explicit ARMYGROUP:RTZ(origin zone, ...) only when mission semantics require it
4. custom fallback only after proven MOOSE gap + owner approval
```

Die vorhandenen `ZON_BLUE_GND_*_ACCESS` bleiben erhalten, werden aber vor DCS-Nachweis nicht pauschal als verpflichtender Return-Bereich definiert.

Querschnittsdokument:

```text
docs/moose/GROUND-WAREHOUSE-RETURN-HOMEZONE-LIFECYCLE.md
```

## CampaignState-/MOOSE-Grenze

Stage 2B korrigiert die strategische Deployment-Semantik gegenüber dem Acceptance-1-Harness:

```text
CampaignState PERSONNEL deployment
-> ReserveResource while physically deployed
-> quantity remains unchanged
-> available decreases

confirmed physical Returned
-> release deployment reservation
-> survivors become available again
-> consume only confirmed casualties exactly once
```

CampaignState berechnet nicht den physischen Rückweg und wählt nicht anhand des Zielortes ein Rückkehr-Warehouse. MOOSE führt den origin-bound physischen Lifecycle; CampaignState übernimmt bestätigte Return-/Loss-Ereignisse idempotent für das ursprüngliche Deployment.

## Aktueller DCS-Befund und Validierungsgrenze

Der Fortress-Gesamtlauf mit Commit `8d900cf5f87082e79a46e9ba53602aa1e6ff6810` ist **kein vollständiger Acceptance-2-PASS**. Er belegte jedoch innerhalb seines dokumentierten Laufes:

```text
BLUE Guard materialization / ONGUARD
QRF materialization / GROUNDATTACK
QRF native ReturnToLegion
QRF origin Fortress Warehouse recovery
CampaignState QRF settlement
```

Nicht nachgewiesen wurden insbesondere der korrekte `OMW_FlightPath`-Talflug und die vollständige CAS-Closure-/RTB-/Landed-/Arrived-Kette. Zusätzlich blieb mindestens eine RED-Infanterieeinheit im Fortress-/HESCO-Bereich, so dass Threat Clear nicht sauber erreicht wurde.

Alle als `PENDING_DCS` gekennzeichneten Kombinationen dürfen erst nach dem dokumentierten Acceptance-Lauf auf einen validierten technischen Status angehoben werden.

Ein `CAS_EXECUTING` oder ein bloßer Ground-Mission-Start reicht nicht: sichtbarer Talflug, Threat Clear, CAS RTB/recovery, origin-bound Ground-Return, Returned/Warehouse-Settlement und Reorder-Evaluation gehören zum Abnahmescope.
