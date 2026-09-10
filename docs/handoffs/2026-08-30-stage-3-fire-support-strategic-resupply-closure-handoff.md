---
document_id: OMW-HANDOFF-2026-08-30-STAGE-3-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CLOSURE
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - transfer point from completed Automatic Response Stages 1 and 2 into Stage 3
  - current Stage 3 source inventory and development start order
  - exact known acceptance boundaries inherited from Stages 1 and 2
not_authoritative_for:
  - a completed Stage 3 architecture
  - Stage 3 DCS acceptance before a real documented runtime test
  - changes to the binding CampaignState or MOOSE-first authority model
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: partial
---

# Stage 3 – Fire Support → Strategic Resupply Closure – Übergabe

## 1. Zweck dieser Übergabe

Diese Datei ist der Startpunkt für die nächste Entwicklungsstage der Automatic-Response-Orchestration.

Der unmittelbar vorausgehende Stand ist abgeschlossen:

```text
Stage 1: Ground RESUPPLY orchestration
-> COMPLETE / merged to main

Stage 2: FOB/COP attacked -> support demand / automatic response
-> Stage 2A PASS
-> Stage 2B PASS
-> COMPLETE / merged to main
```

Die nächste reguläre Stage der festgelegten Entwicklungsreihenfolge ist:

```text
Stage 3
fire support -> strategic resupply closure
```

Stage 3 beginnt **nicht** mit der Neuentwicklung von Artillerie, Rearm oder Ground-Logistik. Auf `main` existiert bereits eine DCS-validierte Fixed-Fire-Support-Rearm-Baseline. Die Aufgabe ist deshalb zunächst eine Reconciliation zwischen diesem vorhandenen Fire-Support-Lifecycle und der inzwischen ebenfalls vorhandenen MissionDemand-/CampaignState-Resupply-Orchestrierung.

Diese Übergabe dokumentiert, welche Baselines bereits gelten, welche Dateien zuerst zu lesen sind, welche Ergebnisse nicht erneut erfunden werden dürfen und welche Fragen Stage 3 tatsächlich noch beantworten muss.

## 2. Verbindlicher Startcheck

Vor jeder Stage-3-Änderung in dieser Reihenfolge prüfen:

```text
1. AGENTS.md
2. docs/00-project-governance.md
3. docs/26-moose-first-development-policy.md
4. docs/handoffs/2026-08-22-automatic-response-orchestration-development-order.md
5. diese Übergabe
6. aktuelle Stage-1-/Stage-2-/Ground-Fire-Support-Fachdokumentation
7. tatsächliche produktive Lua-Dateien auf aktuellem main
8. gepinnte Moose.lua für jede neu verwendete oder geänderte MOOSE-API
9. offizielle MOOSE-Dokumentation/Demos, soweit für den konkreten Stage-3-Schnitt relevant
```

Bei Widersprüchen gilt ausschließlich die Autoritätshierarchie aus `docs/00-project-governance.md`.

## 3. Repository- und MOOSE-Ausgangsstand

Ausgangspunkt für den Stage-3-Branch:

```text
Repository: birkenmoped/Operation-Mountain-Watch
Base branch: main
Base main HEAD: 10789637d009a664a6e65b633d3df8a35f8d5117
Stage-3 branch: agent/fire-support-strategic-resupply-closure
Project phase: COMPLETE_FOUNDATION_BUILD_PHASE
```

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Architekturgrenze bleibt unverändert:

```text
CampaignState = einzige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Domain
MOOSE = primärer operativer Executor und physischer Lifecycle
DCS groups = temporäre physische Repräsentationen
```

Keine Stage-3-Lösung darf dieselbe Ressource zusätzlich durch DCS Warehouses, MOOSE Warehouse oder einen eigenen Ledger strategisch autoritativ machen.

## 4. Gesamtziel der Automatic-Response-Orchestration

Die ursprüngliche Entwicklungsreihenfolge lautet:

```text
Stage 1D   generic remaining non-AMMO/non-FUEL RESUPPLY executor reconciliation
Stage 2    FOB attacked -> support demand
Stage 3    fire support -> strategic resupply closure
Stage 4    convoy attacked -> support demand
Stage 5    BLUE/CAS automatic-response adapter
Stage 6    aircraft loss -> CSAR incident / MOOSE CSAR-first execution
Stage 7    complete end-to-end automatic response chain
Stage 8    restart / restore / idempotence for automatic-response state
Stage 9    multiplayer / performance / failure acceptance
```

Aktueller Fortschritt:

```text
Stage 1   COMPLETE / merged
Stage 2   COMPLETE / merged
Stage 3   NEXT / this branch
Stage 4   OPEN
Stage 5   PARTIALLY PRE-IMPLEMENTED by Stage 2B; later reconciliation required
Stage 6   OPEN
Stage 7   OPEN
Stage 8   OPEN
Stage 9   OPEN
```

Stage 5 darf später nicht blind neu implementiert werden. Stage 2B enthält bereits einen realen `CAS_IMMEDIATE -> AIRWING -> AH-64D CAS -> closure -> RTB/Landed/Arrived`-Pfad, der in Stage 5 wiederzuverwenden bzw. zu generalisieren ist.

# Teil A – Rückblick auf Stage 1

## 5. Stage 1 – Ground RESUPPLY Orchestration

Stage 1 etablierte die strategisch/physisch getrennte Resupply-Kette.

### 5.1 Stage 1A – AMMO

Akzeptierte Grundrichtung:

```text
CampaignState shortage
-> MissionDemand RESUPPLY
-> CampaignState transaction/reservation
-> MOOSE Ground logistics asset
-> AUFTRAG:NewAMMOSUPPLY(...)
-> physical execution
-> delivery evidence
-> exactly-once settlement
-> MOOSE return lifecycle
```

Status:

```text
ACCEPTED_TECHNICAL_BASELINE
merged to main
```

### 5.2 Stage 1B / 1B2 – FUEL

Der frühe FUELSUPPLY-Versuch mit einem harten Fahrzeit-Timeout blieb historisch/inconclusive. Danach wurde der normale MOOSE-Weg als One-Shot-Executor real validiert:

```text
GROUND_FUEL_PACKAGE
-> CampaignState remains strategic authority
-> AUFTRAG:NewFUELSUPPLY(destinationZone)
-> BRIGADE:AddMission(...)
-> normal MOOSE ReturnToLegion
-> Returned
-> Warehouse AddAsset
```

Status Stage 1B2:

```text
ACCEPTED_TECHNICAL_BASELINE
validated_in_dcs: true
```

### 5.3 Stage 1C / Stage 1D-S – allgemeines SUPPLY

Für normalisierte allgemeine `SUPPLY`-Einheiten wurde im gepinnten MOOSE keine passende dedizierte Ground-SUPPLY-AUFTRAG-Fabrik gefunden. Deshalb wurde der bereits akzeptierte neutrale MOOSE-Lifecycle genutzt:

```text
CampaignState SUPPLY reservation
-> existing Ground logistics asset
-> AUFTRAG:NewNOTHING(destinationZone)
-> BRIGADE:AddMission(...)
-> physical arrival evidence
-> exactly-once CampaignState settlement
-> return lifecycle
```

Stage 1D-S Runtime-Acceptance:

```text
status: ACCEPTED_TECHNICAL_BASELINE
build_commit: 4771420480a994ce7356abc618ae0a3189dc105e
builder: GROUND-SUPPLY-RESUPPLY-NOTHING-ACCEPTANCE-1-2
bundle SHA-256: C805C996A2028629251F833F0E0D0ED06F462C15271A1166E0DB8DF0BA105CE3
mission SHA-256: BA556641A9ECAD629FDBE62AEA5CC30E22E081B81B4188C136855026F70D0907
DCS: 2.9.29.27278 MT
```

### 5.4 Stage 1D-P – PERSONNEL

Strategische `GROUND_PERSONNEL` bleiben Headcount und werden nicht künstlich zu einer physischen Infantry-Cargo-Gruppe umdefiniert.

Der gemergte Stage-1D-P-Scope umfasst insbesondere:

```text
GROUND_PERSONNEL strategic contract
Ground carrier path
Air PERSONNEL Jalalabad -> Fortress
OMW_FlightPath rotary-wing corridor
LANDAT TaskDone settlement
physical Jalalabad return proof
```

Der Air-PERSONNEL-Acceptance-4-Stand ist als exakte technische Baseline auf `main` dokumentiert.

### 5.5 Stage 1D-V – VEHICLE

Die Fahrzeugfrage wurde separat behandelt. Wichtig für spätere Stages bleibt die Unterscheidung:

```text
CampaignState VEHICLE quantity
!=
MOOSE whole-cohort relocation
```

Keine spätere Automatic-Response-Stage darf aus `LEGION/COMMANDER:RelocateCohort(...)` ohne eigene Semantik einen beliebigen `VEHICLE +N`-Resupply-Executor machen.

### 5.6 Wichtige Stage-1-Dokumente

Zuerst lesen:

```text
docs/handoffs/2026-08-22-automatic-response-orchestration-development-order.md
docs/handoffs/2026-08-29-automatic-response-orchestration-continuation.md
docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-RUNTIME-RESULT.md
docs/ground/ARMY-GROUND-RESOURCE-READINESS-CONTRACT.md
docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
docs/ground/ARMY-GROUND-VEHICLE-REPLENISHMENT-DECISION.md
mission/tests/ground-resupply-execution/README.md
mission/tests/ground-resupply-execution/ACCEPTANCE-5.md
mission/tests/ground-resupply-execution/results/2026-08-29-ground-supply-resupply-nothing-acceptance-1-pass-1.md
```

Wichtige Stage-1-/Shared-Domain-Quellen:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
scripts/campaign/OMW_ResourceDemandCoordinator.lua
scripts/logistics/OMW_GroundInitialStock.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
```

# Teil B – Rückblick auf Stage 2

## 6. Stage 2A – FOB/COP Threat -> MissionDemand

Stage 2A änderte die operative Alarmbedingung von einem notwendigen physischen Treffer auf eine qualifizierte Installationsbedrohung.

Akzeptierte Kette:

```text
BLUE FOB/COP installation
-> stable Warehouse/BRIGADE coordinate
-> runtime MOOSE ZONE_RADIUS
-> MOOSE OPSZONE(owner = BLUE)
-> BLUE local-security presence
-> hostile RED Ground presence inside perimeter
-> OPSZONE Attacked(RED)
-> stable installation threat incident
-> OMW_FobAttackDemandPolicy
-> MissionDemand CAS_IMMEDIATE
-> active-demand dedupe
```

Fortress-Acceptance verwendete einen Runtime-Radius von 1000 m. Kein `EVENTS.Hit`/`EVENTS.Shot`, kein eigener `world.addEventHandler`, kein MIST und keine zusätzliche ME-Security-Zone waren für die primäre Alarmbedingung nötig.

Exakte Stage-2A-Provenienz:

```text
source commit: e3bc977e35ab3a06a5417124684250ae50a15a8b
DCS: 2.9.29.27278
Acceptance bundle SHA-256: 9A3382BF0EE476ED105A5EEF56575C73EBE591AAA00C1C4B1DA7A55F27835650
Mission SHA-256: 54E6562A095E771721E417CC8F5AEE0606066EA619E9E72D462E402A6D3EC118
dcs.log SHA-256: 8C8821ABDD412258A1B2ABF18FC9AA8018767E80894B174DAFE982513B3D2B2D
debrief.log SHA-256: 081FE758DAE40933F011CE8156364BAC5EF40C13247150999F7CACE2159FD227
result: PASS
```

## 7. Stage 2B – automatische BLUE-Reaktion

Stage 2B integrierte reale CAS- und lokale Ground-Reaktion.

### 7.1 CAS

Akzeptierter Pfad:

```text
CAS_IMMEDIATE
-> OMW_FobAttackCasDispatchAdapter
-> Jalalabad AIRWING
-> AUFTRAG:NewCAS(...)
-> AIRWING:AddMission(...)
-> FLIGHTGROUP
-> OMW_FlightPath valley corridor
-> threat clear
-> AUFTRAG mission closure
-> RTB
-> Landed
-> Arrived
```

Der entscheidende korrigierte Fehler war:

```text
CAS_CORRIDOR_INSTALL_FAILED reason=MISSION_ROUTE_UIDS_NOT_READY
```

Source-Prüfung des gepinnten MOOSE ergab:

```text
AIRWING OnAfterFlightOnMission
can occur before delayed OPSGROUP:RouteToMission(...)

AUFTRAG:NewCAS(...)
does not guarantee a separate egress coordinate/UID
```

Der MOOSE-first Fix wurde daher:

```text
mission waypoint UID = required
egress waypoint UID = optional
route not ready
-> defer to FLIGHTGROUP OnAfterUpdateRoute
-> retry after MOOSE route creation
```

Der finale DCS-Lauf protokollierte:

```text
CAS_CORRIDOR_INSTALLED
corridorPoints=14
outboundWaypoints=14
returnWaypoints=13
altitudeFtAGL=500
```

Der Projektinhaber bestätigte visuell Hin- und Rückflug durch die vorgesehene Talroute.

### 7.2 Guard

MOOSE-first Kombination:

```text
AUFTRAG:NewONGUARD(...)
+
AUFTRAG:SetEngageDetected(..., {"Ground Units"})
```

Es wurde kein eigener nativer DCS `Attack Group`/`Attack Unit` Task eingeführt.

### 7.3 QRF

Die QRF-Anzahl wird nicht fest auf eine Gruppe begrenzt, sondern aus realer Lage und strategischer Verfügbarkeit bestimmt:

```text
min(
  alive RED groups,
  available GROUNDATTACK-capable QRF assets,
  CampaignState 9-person slots above Fortress reserve floor 80,
  acceptance cap 7
)
```

Ziele werden deterministisch `nearest-to-Fortress` plus stabilem Gruppenname-Tie-Break sortiert. Jede QRF bekommt einen eigenen:

```text
AUFTRAG:NewGROUNDATTACK(...)
```

Finaler Acceptance-Lauf:

```text
RED groups: 3
available physical QRF assets: 7
strategic slots: 7
dispatched QRFs: 3

QRF-1 -> Ground-3 -> ~751 m
QRF-2 -> Ground-1 -> ~778 m
QRF-3 -> Ground-2 -> ~878 m
```

Alle drei QRF-Gruppen erreichten den origin-bound MOOSE Return-to-Legion-Lifecycle nach Fortress zurück.

### 7.4 CampaignState Ground-Deployment-Settlement

Stage 2B etablierte für das Personal:

```text
reserve while physically deployed
-> confirm actual casualties
-> consume confirmed losses only
-> release/settle survivors on return
```

Damit wird nicht bereits beim Spawn eines temporären DCS-Ground-Assets dessen gesamter strategischer Wert endgültig verbraucht.

### 7.5 Akzeptierte Stage-2B-Grenze

Nach Kampfende waren einzelne BLUE-Soldaten im Fortress-/HESCO-Bereich sichtbar. Alle drei QRFs hatten bereits `QRF_RETURNED_ORIGIN` geloggt. Der Guard erhielt seine Mission-Close-Anforderung, aber vor Missionsende keinen abschließenden `GUARD_RETURNED_ORIGIN`-Nachweis.

Der Projektinhaber akzeptierte diesen Restbefund ausdrücklich als **nicht blockierend für Stage 2B**.

Nicht behaupten:

```text
perfect Guard pathfinding through arbitrary HESCO geometry
all Guard survivors always reach Returned
```

## 8. Stage-2B-Provenienz

```text
tested source commit: 7c40e43395788b1a7dd5e0c179264abb34834ec4
builder: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-6
Acceptance bundle SHA-256: AB696D8E9CEBACD3A402E34DA016773046181E998318214C2198A9915E396C7B
Mission: OMW_Template_v20_GroundWorks(20260830-132050).miz
Mission SHA-256: 28FE4AB40F54CEB48FA5428C0E5E2DAF2874F6F61213C964A317434087F413CC
DCS: 2.9.29.27278
dcs.log SHA-256: 062B83B61C02E7F7A93CF260540588F6849819E74CF1DC20F406EDF17C170EE2
debrief.log SHA-256: 4863E4B945E3B8F4719E081A18A56737E74989A414CBEB05B62793C53CE605F8
result: PASS
```

Stage-2-Integration nach `main`:

```text
Stage 2 merge commit: 46729cf2b16032b54252490dfa3b46926dca88b5
post-merge documentation provenance fix: 10789637d009a664a6e65b633d3df8a35f8d5117
```

## 9. Wichtige Stage-2-Dokumente

```text
docs/handoffs/2026-08-30-fob-attack-support-demand-ready-for-review.md

docs/moose/FOB-ATTACK-AUTOMATIC-RESPONSE-STAGE-2B.md
docs/moose/FOB-ATTACK-CAS-DISPATCH-STAGE-2B-SOURCE-REVIEW.md
docs/moose/FOB-ATTACK-CAS-OUTBOUND-RETURN-ROUTE-STAGE-2B.md
docs/moose/FOB-ATTACK-CAS-ROUTE-READY-STAGE-2B.md
docs/moose/FOB-ATTACK-SUPPORT-DEMAND-STAGE-2-SOURCE-REVIEW.md
docs/moose/FOB-ATTACK-THREAT-OPSZONE-STAGE-2.md
docs/moose/GROUND-WAREHOUSE-RETURN-HOMEZONE-LIFECYCLE.md
docs/moose/PROJECT-CLASS-INDEX-STAGE-2-ACCEPTANCE-1.md
docs/moose/PROJECT-CLASS-INDEX-STAGE-2-ACCEPTANCE-2.md
docs/moose/PROJECT-CLASS-INDEX-STAGE-2-ACCEPTANCE-2-ACTIVE-GROUND-ADDENDUM.md

mission/tests/fob-attack-support-demand/ACCEPTANCE-1.md
mission/tests/fob-attack-support-demand/RESULT-1.md
mission/tests/fob-attack-support-demand/ACCEPTANCE-2.md
mission/tests/fob-attack-support-demand/RESULT-2.md
```

Wichtige Stage-2-Quellen:

```text
scripts/campaign/OMW_FobAttackDemandPolicy.lua
scripts/campaign/OMW_ResourceDemandCoordinator.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
```

# Teil C – Bestehende Fire-Support-Baseline vor Stage 3

## 10. Stage 3 startet nicht bei Null

Auf `main` ist PR #112 bereits gemerged:

```text
PR #112
Ground ammo rearm lifecycle / fixed fire support
merge commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
```

Der entsprechende Ground-Rearm-Arbeitsblock ist laut aktuellem Statusdokument geschlossen:

```text
Source implementation: COMPLETE / MERGED TO MAIN
Bundled DCS physical rearm: PASS
Option-B same-session Restore settlement: PASS
Ground rearm integration block: CLOSED
OPEN ITEMS FOR THIS BLOCK: NONE
```

Stage 3 darf deshalb weder `ARTY:Rearm()` noch den M1083-Support-Spawn-/Rearm-Lifecycle parallel neu bauen.

## 11. DCS-validierte Fixed-Fire-Support-Rearm-Baseline

Exakte Accepted Baseline:

```text
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11-RUNTIME
status: ACCEPTED_TECHNICAL_BASELINE
acceptance source/build commit: d52a47a418fe3a1a996a5b68198b8dc033ff86c4
builder: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11
bundle SHA-256: CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B
mission: OMW_Template_v16.miz
mission SHA-256: 388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620
DCS: 2.9.28.26385 MT
dcs.log SHA-256: B65B3010612F9FEDCB90210C0799DE889F64A7D643818CD8326730716662D128
debrief.log SHA-256: ED298DC7A21F153021C50726A7B9D245BD9BAF098163D6D59B9D4CB593E40C39
```

Physische Runtime-Ergebnisse:

```text
BOSTICK   L118 300 -> 296 -> 301 / M1083 / GROUND_AMMO_PACKAGE 52 -> 51 / COMPLETED / returned / PASS
WRIGHT    L118 300 -> 296 -> 300/301 / M1083 / GROUND_AMMO_PACKAGE 30 -> 29 / COMPLETED / returned / PASS
FORTRESS  L118 150 -> 146 -> 151 / M1083 / GROUND_AMMO_PACKAGE 48 -> 47 / COMPLETED / returned / PASS
HONAKER   2B11 40 -> 0 -> 40 / M1083 / GROUND_AMMO_PACKAGE 40 -> 39 / COMPLETED / returned / PASS
```

Damit ist bereits DCS-validiert:

```text
fixed fire-support ammunition expenditure
-> support request
-> physical M1083 support
-> CampaignState GROUND_AMMO_PACKAGE consumption
-> MOOSE ARTY Rearm
-> ARTY OnAfterRearmed
-> support return-to-stock
```

Für Honaker wurde insbesondere validiert:

```text
40 rounds -> 0
-> request only after ammo depleted
-> M1083 rearm
-> 40 rounds restored
```

## 12. Bestehender Rearm-/Settlement-Vertrag

Owner-approved Option-B-Vertrag:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED

Restore with CONSUMED but not COMPLETED
-> exactly-once CreditResourceOnce
-> transaction = COMPENSATED
-> no physical replay
-> later rearm requires new transaction ID
```

Same-session Restore-Acceptance bestand:

```text
CONSUMED -> COMPENSATED exactly once
second restore -> no duplicate credit
new transaction after compensation -> new ID -> COMPLETED
COMPLETED restore -> no compensation
RESERVED restore -> CANCELLED
LOADING restore -> CANCELLED
```

Grenze:

```text
external filesystem/server persistence host: NOT PRESENT / NOT TESTED / NOT CLAIMED
real DCS process restart with snapshot file: NOT TESTED / NOT CLAIMED
```

Diese Persistenzgrenze wird erst in der dafür vorgesehenen Stage 8 global adressiert, sofern kein früherer fachlicher Grund eine engere Teilprüfung erforderlich macht.

## 13. Aktuelle Fire-Support-Quellen auf main

Vor Stage-3-Design mindestens prüfen:

```text
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_BostickAmmoRearmService.lua
scripts/ground/OMW_BostickAmmoSupport.lua
scripts/ground/OMW_GroundSupportMaterializer.lua
scripts/ground/OMW_GroundRoadSpawnAdapter.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
```

Die aktuelle `OMW_FixedFireSupportAmmoRearmService.lua` erklärt ihre Grenze selbst:

```text
configured MOOSE WAREHOUSE/BRIGADE/PLATOON support materialization
+
CampaignState-backed ARTY rearm adapter
+
MOOSE ARTY owns physical rearm/return behavior
+
known group handed back to WAREHOUSE stock
```

Sie führt keinen zweiten Resource Ledger ein, implementiert keine eigene Routing-FSM und ersetzt nicht den MOOSE ARTY FSM.

## 14. Wichtige Fire-Support-Dokumente

```text
mission/tests/ground-ammo-rearm-integration/CURRENT-STATUS-TODO.md
mission/tests/ground-ammo-rearm-integration/ACCEPTANCE-2.md
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md
mission/tests/ground-ammo-rearm-integration/V15-7-FIRE-SUPPORT-REVIEW.md
mission/tests/ground-ammo-rearm-integration/README.md
```

Autoritativ für den exakten Runtime-PASS ist:

```text
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md
```

`README.md` ist ausdrücklich `HISTORICAL_TEST_FIXTURE`; ältere Entwicklungsbefunde daraus dürfen die spätere Acceptance-2-11-Baseline nicht überschreiben.

# Teil D – Stage 3

## 15. Verbindliches Stage-3-Ziel

Die vorhandene Entwicklungsreihenfolge definiert Stage 3 nur als:

```text
fire support -> strategic resupply closure
```

Das bedeutet **nicht automatisch**, dass bereits entschieden ist, welches konkrete Event oder welcher Schwellwert den strategischen Resupply-Demand erzeugt. Diese Detailentscheidung muss aus den aktuellen Fire-Support-, CampaignState-, MissionDemand- und Resource-Demand-Verträgen abgeleitet und gegebenenfalls vom Projektinhaber entschieden werden.

Gesicherte Ausgangspunkte sind:

```text
A. Fire Support kann real Munition verschießen.
B. Fixed Fire Support kann über MOOSE/CampaignState physisch nachmunitioniert werden.
C. GROUND_AMMO_PACKAGE wird strategisch durch CampaignState geführt.
D. MissionDemand / ResourceDemand Orchestration existiert bereits.
E. Ground AMMO RESUPPLY besitzt bereits einen akzeptierten MOOSE-Ausführungspfad.
```

Daraus ergibt sich als Stage-3-Arbeitsziel:

```text
existing Fire-Support state/evidence
-> qualified strategic ammunition shortage / resupply requirement
-> existing MissionDemand / ResourceDemand contract
-> existing CampaignState resource authority
-> existing MOOSE AMMO resupply/rearm executor
-> exactly-once completion/failure settlement
-> demand closure
```

Die genaue Trigger- und Ownership-Grenze ist zu Beginn der Stage anhand der aktuellen produktiven Quellen festzuziehen, nicht zu erraten.

## 16. Was Stage 3 ausdrücklich wiederverwenden soll

```text
CampaignState transactions and resource ownership
MissionDemand domain
ResourceDemand policy/coordinator
GROUND_AMMO_PACKAGE identity
existing fixed-fire-support ARTY lifecycle
existing M1083 materialization/support path
existing MOOSE ARTY:Rearm() path
existing WAREHOUSE/BRIGADE/PLATOON lifecycle
existing return-to-stock behavior
existing Stage-1 AMMO RESUPPLY mechanisms where semantically applicable
```

Nicht neu bauen:

```text
custom artillery FSM
custom native-DCS rearm
parallel ammo ledger
second strategic Warehouse authority
new Ground router if existing validated route/materialization suffices
poll-every-frame ammo scanner
```

## 17. Offene Stage-3-Fragen, die zuerst technisch geklärt werden müssen

Vor Implementierung systematisch beantworten:

```text
1. Welche produktive Fire-Support-Komponente besitzt heute die autoritative Information,
   dass strategischer AMMO-Nachschub benötigt wird?

2. Ist der bestehende FixedFireSupportAmmoRearmService bereits ein lokaler
   self-requesting End-to-End-Pfad, der Stage 3 nur an MissionDemand anbinden muss,
   oder muss Request-Erzeugung sauber in Demand/Policy und Executor getrennt werden?

3. Welche bestehende MissionDemand.Type / ResourceDemand-Repräsentation ist für
   GROUND_AMMO_PACKAGE bereits verbindlich und kann direkt wiederverwendet werden?

4. Welches Ereignis ist für Demand-Erzeugung geeignet:
   tatsächlicher ARTY ammo state, MOOSE ARTY FSM event, definierter readiness threshold,
   oder bereits vorhandener GroundResourceReadiness-Vertrag?
   Keine Entscheidung ohne Source-/Policy-Abgleich.

5. Wie wird dedupliziert, solange ein Rearm/RESUPPLY bereits RESERVED, LOADING,
   in physical execution oder CONSUMED-but-not-COMPLETED ist?

6. Welche bestehende completion evidence schließt MissionDemand/ResourceDemand exakt einmal?
   `ARTY OnAfterRearmed` ist als physischer Rearm-Nachweis akzeptiert;
   seine Rolle als Demand-Closure-Signal muss gegen die aktuelle Domain geprüft werden.

7. Wie werden Supportverlust, failed materialization, rearm failure und return failure
   auf Demand- und CampaignState-Ebene abgebildet, ohne doppelte Buchung?

8. Muss Stage 3 nur die bereits akzeptierten vier Fixed-Fire-Support-Standorte abdecken
   oder zuerst bewusst einen einzelnen Vertical Slice verwenden?
   Das ist eine Scope-/Acceptance-Entscheidung, keine stillschweigende Annahme.
```

## 18. Stage-3-MOOSE-first-Prüfreihenfolge

Für jede neu benötigte MOOSE-Funktion:

```text
1. passende MOOSE-Dokumentation
2. tatsächlich gepinnte Moose.lua
3. exakte Signatur/Rückgabe/Event/FSM/Voraussetzungen
4. vorhandene offizielle MOOSE-Demos/Tests, soweit relevant
5. vorhandene OMW-Verwendung prüfen
6. direkt verwenden oder konfigurieren/kombinieren
7. Event/Callback/FSM bevorzugen
8. nur kleinen Adapter ergänzen
9. Native-DCS/custom nur nach ausdrücklicher Ausnahmefreigabe
```

Besonders relevant sind voraussichtlich die bereits verwendeten MOOSE-Verträge:

```text
ARTY
WAREHOUSE
BRIGADE
PLATOON
ARMYGROUP / OPSGROUP lifecycle
AUFTRAG AMMOSUPPLY where applicable
SCHEDULER only where already justified/low-frequency
```

Neue Methoden oder Events dürfen erst nach Prüfung der tatsächlichen `Moose.lua` in Stage-3-Dokumentation oder Code genannt werden.

## 19. Empfohlene Stage-3-Entwicklungsreihenfolge

### Schritt 1 – Ist-Stand-Reconciliation

```text
current main
-> Fire Support runtime/source
-> CampaignState AMMO transaction model
-> GroundResourceReadiness contract
-> MissionDemand / ResourceDemand model
-> Stage-1 AMMO RESUPPLY executor
```

Ergebnis soll eine kurze Source-Review-Matrix sein:

```text
producer of shortage evidence
stable node/resource identity
demand creator/dedupe
assignment/executor
physical materialization
commit point
completion point
failure/compensation point
return-to-stock point
```

### Schritt 2 – MOOSE-Prüfung

Nur die APIs prüfen, die für die konkrete Verbindung fehlen. Bereits DCS-validierte MOOSE-Rearm-Funktionalität nicht erneut parallel implementieren.

### Schritt 3 – kleinster Vertical Slice

Erst nach der Reconciliation den kleinsten realistischen Integrationsschnitt festlegen.

Bevorzugte Struktur, sofern Source und aktuelle Domain sie bestätigen:

```text
qualified fixed-fire-support ammo shortage
-> one strategic RESUPPLY demand
-> reserve CampaignState GROUND_AMMO_PACKAGE
-> dispatch existing MOOSE support/rearm path
-> physical rearms
-> exactly-once demand success/closure
-> support returns
```

Diese Darstellung ist eine **Arbeitsrichtung**, noch keine DCS-validierte Stage-3-Baseline.

### Schritt 4 – Contract-/Syntax-Tests

Vor DCS:

```text
no duplicate demand
no duplicate CampaignState consumption
correct failure rollback/compensation
existing Fire Support APIs unchanged unless required
existing Stage-1/Stage-2 regressions covered
```

### Schritt 5 – DCS Acceptance

Ein DCS-PASS muss für den exakt gebauten Branch-/Commit-/Bundle-/Mission-/DCS-/MOOSE-Stand dokumentiert werden.

Mindestens beobachten:

```text
actual fire support ammo use
qualified resupply condition
demand creation exactly once
physical support materialization
MOOSE rearm lifecycle
CampaignState commit exactly once
demand closure exactly once
support return/recovery
post-combat resource/readiness state
```

## 20. Acceptance-Grenze für Stage 3

Stage 3 darf erst `VALIDATED` bzw. `ACCEPTED_TECHNICAL_BASELINE` werden, wenn ein realer DCS-Lauf für die exakt dokumentierte Integration vorliegt.

Nicht ausreichend:

```text
Lua unit tests alone
builder success alone
hash equality alone
historical Acceptance-2-11 alone
```

Die historische Fire-Support-Acceptance beweist den physischen Rearm-Mechanismus, aber **nicht automatisch** die noch zu entwickelnde Stage-3-Demand-Closure-Verbindung.

# Teil E – Nächste Stages

## 21. Stage 4 – convoy attacked -> support demand

Nach Stage 3:

```text
convoy attacked
-> qualified support incident
-> support demand
```

Die Details müssen MOOSE-first geprüft werden. Vorhandene TM01M-/Ground-Convoy-Baselines sind wiederzuverwenden; keine neue Ground-Routing-Architektur ohne Notwendigkeit.

## 22. Stage 5 – BLUE/CAS automatic-response adapter

Status:

```text
PARTIALLY PRE-IMPLEMENTED
```

Stage 2B hat bereits einen Fortress-`CAS_IMMEDIATE`-Pfad bis Jalalabad AIRWING, AH-64D, Talroute, Mission-Close und Recovery validiert.

Stage 5 muss deshalb beginnen mit:

```text
reconcile Stage-2B adapter
-> identify what is Fortress-specific acceptance logic
-> identify reusable production adapter contract
-> generalize only the missing part
```

Kein zweiter CAS-Dispatcher neben `OMW_FobAttackCasDispatchAdapter.lua` ohne belegten Grund.

## 23. Stage 6 – aircraft loss -> CSAR

```text
aircraft loss
-> CSAR incident
-> MOOSE CSAR-first execution
```

Vor Entwicklung zwingend aktuelle CSAR-Dokumentation, gepinnte Moose.lua und vorhandene OMW-CSAR-Arbeit prüfen. Keine eigene CSAR-Engine parallel zu MOOSE.

## 24. Stage 7 – complete end-to-end automatic response chain

Hier werden die bis dahin getrennt akzeptierten Ereignis-/Demand-/Executor-Ketten zusammengeführt und auf Authority-, Dedupe- und Settlement-Konsistenz geprüft.

## 25. Stage 8 – restart / restore / idempotence

Gesamtweite Restart-/Restore-/Idempotence-Acceptance.

Bekannt:

```text
Fire Support Option-B same-session Restore settlement = PASS
external persistence host / real process restart = not tested
```

Stage 8 darf den same-session Nachweis nicht als echten Server-Restart-Nachweis ausgeben.

## 26. Stage 9 – multiplayer / performance / failure acceptance

Abschlussprüfung für:

```text
multiplayer concurrency
multiple simultaneous incidents
demand dedupe and ownership
failure handling
resource contention
scheduler/event load
performance
long-running mission behavior
```

# Teil F – Startpaket für den nächsten Chat

## 27. Dateien, die im nächsten Chat zuerst gelesen werden sollen

Minimaler Pflichtsatz:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md

docs/handoffs/2026-08-22-automatic-response-orchestration-development-order.md
docs/handoffs/2026-08-30-fob-attack-support-demand-ready-for-review.md
docs/handoffs/2026-08-30-stage-3-fire-support-strategic-resupply-closure-handoff.md

mission/tests/ground-ammo-rearm-integration/CURRENT-STATUS-TODO.md
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md

docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md
docs/ground/ARMY-GROUND-RESOURCE-READINESS-CONTRACT.md
docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
```

Danach die aktuellen produktiven Quellen:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
scripts/campaign/OMW_ResourceDemandCoordinator.lua

scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_GroundCampaignStateAdapter.lua
scripts/ground/OMW_GroundRuntimeIntegration.lua
scripts/ground/OMW_GroundSupportMaterializer.lua
```

## 28. Konkreter Auftrag für den nächsten Chat

```text
Lese die Stage-3-Übergabe
`docs/handoffs/2026-08-30-stage-3-fire-support-strategic-resupply-closure-handoff.md`
auf
`agent/fire-support-strategic-resupply-closure`
und beginne exakt mit der dort beschriebenen Ist-Stand-Reconciliation.

Prüfe vor jeder Implementierung Governance, MOOSE-first Policy, aktuelle main-Daten,
den bestehenden Fixed-Fire-Support-Rearm-Pfad, MissionDemand/ResourceDemand und
CampaignState. Erfinde keine neue Fire-Support- oder Rearm-Logik, solange der
vorhandene MOOSE-/OMW-Pfad die Funktion bereits bietet.
```

## 29. Was zu Beginn ausdrücklich noch NICHT entschieden ist

Nicht stillschweigend festlegen:

```text
- exakter Stage-3 shortage trigger / threshold
- ob Stage 3 zuerst einen Standort oder alle vier Fixed-Fire-Support-Standorte akzeptiert
- ob eine vorhandene MissionDemand-Type unverändert genügt oder eine fachlich neue Domain-Variante erforderlich ist
- welcher vorhandene Event exakt als Demand-Close-Authority verwendet wird, bevor Domain und Source abgeglichen sind
- neue Native-DCS-/Nicht-MOOSE-Ausnahmen
```

Diese Punkte werden erst nach Source-/Governance-Reconciliation entschieden bzw. dem Projektinhaber zur Entscheidung vorgelegt.

## 30. Abschlussstand der Übergabe

```text
main through Stage 2: merged
main base for Stage 3: 10789637d009a664a6e65b633d3df8a35f8d5117
Stage 1: COMPLETE
Stage 2: COMPLETE
existing Fixed Fire Support physical rearm: ACCEPTED_TECHNICAL_BASELINE
Stage 3: READY TO START SOURCE/DOMAIN RECONCILIATION
Stage 4: OPEN
Stage 5: PARTIALLY PRE-IMPLEMENTED / RECONCILIATION REQUIRED
Stage 6: OPEN
Stage 7: OPEN
Stage 8: OPEN
Stage 9: OPEN
```
