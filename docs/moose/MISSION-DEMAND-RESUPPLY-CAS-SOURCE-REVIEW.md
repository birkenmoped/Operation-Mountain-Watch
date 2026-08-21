---
document_id: OMW-MOOSE-MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW
status: PLANNED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE candidates for MissionDemand-driven Resupply and Immediate CAS
  - exact source limitations relevant to ROAD_CONVOY, OPSTRANSPORT, AUFTRAG supply missions and MOOSE Hit events
  - dependency boundary to the separate BLUE COMMANDER foundation
not_authoritative_for:
  - completed runtime implementation
  - DCS runtime acceptance
  - final Ground resupply thresholds
  - approval of a new production routing/spawn exception
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/mission-demand-resupply-cas-concept
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MissionDemand Resupply / Immediate CAS – MOOSE Source Review

## 1. Zweck

Dieses Dokument hält die Phase-0-Quellenprüfung für die in `OMW-PLAN-MISSION-DEMAND-RESUPPLY-CAS` geplanten Reaktionsketten fest.

Geprüfte Zielketten:

```text
FOB/COP stock shortage
-> RESUPPLY MissionDemand
-> strategic reservation
-> physical MOOSE execution
-> strategic settlement

BLUE convoy/group attacked
-> tactical support incident
-> AIR_SUPPORT_REQUEST
-> CAS_IMMEDIATE MissionDemand
-> AIR_TASKING_PLAN
-> MOOSE AUFTRAG / COMMANDER execution
```

Dieses Review ist `SOURCE_REVIEWED`, nicht `VALIDATED`. Es verändert keine `.miz` und führt keinen DCS-Lauf aus.

## 2. Verwendeter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Maßgebliche Projektregeln:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/moose/VERSION-AND-SOURCES.md
```

Zusätzlich fachlich maßgeblich:

```text
docs/04-campaign-state.md
docs/05-logistics.md
docs/37-campaign-architecture-and-dynamic-mission-design.md
docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md
docs/88-air-tasking-plan-foundation.md
docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md
```

## 3. CampaignState – vorhandener Transfervertrag

Für RESUPPLY muss kein zweiter Ressourcenledger entwickelt werden.

Der aktuelle `scripts/campaign/OMW_CampaignState.lua` besitzt bereits den strategischen Transfer-Lifecycle:

```lua
Store:ReserveResource(spec)
Store:MarkLoading(transactionId)
Store:MarkInTransit(transactionId)
Store:MarkDelivered(transactionId)
Store:MarkLost(transactionId)
Store:Cancel(transactionId)
```

Eine Transfertransaktion führt bereits mindestens:

```text
transactionId
reservationId
cargoId
missionDemandId
carrierEntityId
resourceId
quantity
canonicalUnit
originNodeId
destinationNodeId
status
originDebited
destinationCredited
```

Semantik aus dem aktuellen Source:

```text
RESERVED
-> MarkLoading
-> LOADING
-> MarkInTransit
-> origin debit exactly once
-> IN_TRANSIT
-> MarkDelivered
-> destination credit exactly once
-> DELIVERED
```

Alternativ:

```text
IN_TRANSIT -> MarkLost -> LOST
RESERVED/LOADING -> Cancel -> reservation released
```

Damit ist CampaignState bereits geeignet, einen physischen Resupply-Lauf strategisch zu besitzen. Der MOOSE-Executor darf diesen Ledger nicht duplizieren.

## 4. Ground-Stock-Daten – vorhandene Schwellenfelder

`scripts/logistics/OMW_GroundInitialStock.lua` besitzt je Ground-Ressourcenzeile bereits:

```text
initial
target
reorder
critical
supplyParent
```

Der aktuelle Foundation-Stand setzt jedoch:

```text
target   = initial
reorder  = 0
critical = 0
```

Daraus folgt für die weitere Konzeption:

```text
target
= gewünschter Auffüllbestand

reorder
= Schwelle zur Erzeugung eines normalen RESUPPLY-Bedarfs

critical
= Schwelle für Prioritätserhöhung / Emergency-Resupply
```

Die ursprünglich in Dokument 90 vorgeschlagenen zusätzlichen Begriffe `preferredLevel`, `minimumLevel` und `criticalLevel` sollen nicht parallel eingeführt werden, solange `target/reorder/critical` die Anforderung vollständig tragen.

Die konkrete Kalibrierung der Werte bleibt eine fachliche Eigentümerentscheidung. Die bereits vorhandenen Readiness-Prozentstufen aus der Ground-Baseline sind nicht automatisch identisch mit den Resupply-Triggerwerten.

## 5. `AUFTRAG:NewAMMOSUPPLY` und `NewFUELSUPPLY`

Im tatsächlich verwendeten `Moose.lua` vorhanden:

```lua
AUFTRAG:NewAMMOSUPPLY(Zone)
AUFTRAG:NewFUELSUPPLY(Zone)
```

Beide Missionen:

```text
- besitzen eine Zone als Ziel;
- sind Ground-Missionen;
- setzen WeaponHold / Auto alarm state;
- werden über den normalen AUFTRAG-/OPSGROUP-Lifecycle ausgeführt.
```

Für `AMMOSUPPLY` wird `missionWaypointRadius = 0` gesetzt. Beide Typen werden in der OPSGROUP-Missionsroutenlogik als Zonenmissionen behandelt. Eine Ground-Group erhält einen Zielpunkt innerhalb der Zielzone auf gültiger LAND/ROAD-Oberfläche.

Wichtig:

```text
AUFTRAG AMMOSUPPLY / FUELSUPPLY
!=
CampaignState resource transfer
```

Die MOOSE-Mission transportiert nicht automatisch eine OMW-normalisierte Ressource wie `GROUND:...:AMMO` oder `GROUND:...:FUEL` zwischen zwei CampaignState-Knoten und schreibt auch keinen strategischen Zielbestand gut.

Diese AUFTRAG-Typen sind daher mögliche physische Missionsformen, aber kein Ersatz für den OMW-Transfervertrag.

## 6. `OPSTRANSPORT`

Im gepinnten Source vorhanden und source-reviewed:

```lua
OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
OPSTRANSPORT:AddPathTransport(PathGroup, Reversed, Radius, TransportZoneCombo)
COMMANDER:AddOpsTransport(Transport)
```

`AddPathTransport` liest die Waypoints eines angegebenen Gruppenpfades über `PathGroup:GetTaskRoute()` ein. Die Kategorie des PathGroup bestimmt, für welche Carrier-Kategorie der Pfad gilt.

Source-Grenze:

```text
Der Parameter Reversed ist in der geprüften Funktionssignatur vorhanden,
wird im geprüften Funktionskörper jedoch nicht ausgewertet.
```

Für produktiven Code darf deshalb nicht angenommen werden, dass `Reversed=true` die gespeicherte Route tatsächlich umkehrt.

Der OPSTRANSPORT-FSM besitzt unter anderem:

```text
PLANNED
SCHEDULED
EXECUTING
DELIVERED
```

und einen öffentlichen `onafterDelivered(...)`-Pfad. Zusätzlich werden Carrier- und Cargo-Verlustzustände geführt.

`OPSTRANSPORT` passt fachlich besonders gut, wenn reale MOOSE-Cargo-Gruppen beziehungsweise physische Carrier/Cargo-Objekte transportiert werden.

OMW Ground `SUPPLY`, `AMMO` und `FUEL` sind derzeit jedoch normalisierte CampaignState-Einheiten und keine automatisch vorhandenen MOOSE-Cargo-Gruppen oder STORAGE-Waren. Eine zusätzliche operative Darstellung darf nicht zu einer zweiten strategischen Ressourcenhoheit werden.

## 7. Wichtige negative Source-Feststellung: kein öffentliches `AUFTRAG:NewOPSTRANSPORT`

Im gepinnten `Moose.lua` ist ein Entwurf für:

```lua
AUFTRAG:NewOPSTRANSPORT(...)
```

nur innerhalb eines auskommentierten Blockes vorhanden.

Folge:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= NICHT als verfügbare öffentliche API verwenden
```

Wenn OPSTRANSPORT verwendet wird, erfolgt die produktive Prüfung über die tatsächlich aktive öffentliche `OPSTRANSPORT`-Klasse und `COMMANDER:AddOpsTransport(...)`, nicht über den auskommentierten AUFTRAG-Konstruktor.

## 8. ROAD_CONVOY – Bewertung der MOOSE-Kandidaten

### 8.1 Variante A – AUFTRAG / ARMYGROUP als physischer Konvoi

Zielbild:

```text
CampaignState transfer transaction
-> MissionDemand RESUPPLY
-> select Ground operational asset via BRIGADE/PLATOON/COMMANDER
-> AUFTRAG / ARMYGROUP drives to destination
-> physical delivery boundary
-> CampaignState MarkDelivered
```

Vorteile:

```text
- nutzt den bereits DCS-erprobten BRIGADE/PLATOON/ARMYGROUP-Lifecycle;
- benötigt keine erfundene MOOSE-Cargo-Menge für abstrakte Ground-Ressourcen;
- CampaignState bleibt alleiniger Cargo-/Mengenbesitzer;
- Fahrzeugverluste können über den bereits etablierten Ground-Settlement-Vertrag behandelt werden.
```

Offen:

```text
- welcher konkrete AUFTRAG-Typ ist für generische SUPPLY-Payloads fachlich am saubersten;
- exakte Route statt nur Zielzone;
- road-aligned Materialisierung in Production;
- Rückkehr des Carrier-Convoys nach bestätigter Lieferung.
```

### 8.2 Variante B – OPSTRANSPORT

Zielbild:

```text
CampaignState transfer transaction
-> physical CargoGroups
-> OPSTRANSPORT
-> carrier selection
-> pickup/path/deploy
-> Delivered callback
-> CampaignState settlement
```

Vorteile:

```text
- dedizierter MOOSE-Transport-FSM;
- definierte Pickup-/Deploy-Zonen;
- definierter Delivered-Pfad;
- PathGroup-Waypoints können als Transportpfad vorgegeben werden.
```

Nachteile/Risiken:

```text
- benötigt ein echtes CargoGroup-/Carrier-Modell;
- OMW-normalisierte Ressourcen sind nicht automatisch physisches Cargo;
- sichtbare Load/Unload/Respawn-Pfade benötigen eigene DCS-Acceptance;
- darf keinen zweiten Bestand neben CampaignState erzeugen.
```

### 8.3 Phase-0-Empfehlung

Für den ersten ROAD_CONVOY-Vertical-Slice ist Variante A der derzeit kleinere und risikoärmere Kandidat:

```text
CampaignState transfer owns abstract cargo
+
MOOSE BRIGADE/PLATOON/ARMYGROUP owns physical convoy execution
```

`OPSTRANSPORT` bleibt für spätere reale Cargo-/Troop-Transportfälle ausdrücklich erhalten und wird nicht verworfen.

Diese Empfehlung ist noch keine Produktionsfreigabe für eine eigene Route-/Spawn-Erweiterung.

## 9. Exakte Straße / PATHLINE / TM01M

TM01M bleibt `HISTORICAL_TEST_FIXTURE`.

Erhaltene Evidenz:

```text
road-aligned individual unit placement
heading from route direction
PATHLINE-based route geometry
COORDINATE road projection/connectors
physical GROUP route assignment
```

Der aktuelle öffentliche MOOSE-AUFTRAG-Zonenpfad kann eine Ground-Gruppe auf LAND/ROAD zu einer Zielzone führen, garantiert aber nicht automatisch die projektspezifisch gewünschte exakte Mission-Editor-PATHLINE.

Die bereits genehmigte interne WAREHOUSE-Spawn-Ausnahme aus Ground Acceptance 3-2 ist versions- und acceptancegebunden. Sie darf nicht stillschweigend zur Production-Routing-Ausnahme hochgestuft werden.

Vor einem Production-Adapter für exakte PATHLINE-Fahrt gilt daher weiterhin:

```text
1. öffentliche MOOSE-Routingoptionen vollständig prüfen;
2. technische Lücke dokumentieren;
3. kleinsten Adapter bestimmen;
4. ausdrückliche Eigentümerfreigabe einholen;
5. reproduzierbaren DCS-Regressionstest durchführen.
```

## 10. Immediate CAS – Event-Erfassung

Der gepinnte MOOSE-Source unterstützt:

```lua
BASE:HandleEvent(EVENTS.Hit, ...)
```

MOOSE selbst verwendet `EVENTS.Hit` in mehreren Modulen. EventData stellt Initiator-/Target-bezogene Wrapper-/Namensfelder bereit.

Für OMW gilt daher:

```text
kein paralleler world.addEventHandler für den Standardfall
```

Zielpfad:

```text
MOOSE Hit event
-> target belongs to known BLUE strategic/runtime entity?
-> TacticalSupportIncident create/update
-> deduplicate repeated hits
-> AIR_SUPPORT_REQUEST
-> MissionDemand CAS_IMMEDIATE
```

Ein einzelner Treffer darf nicht automatisch eine eigene CAS-Mission erzeugen.

## 11. Immediate CAS – AUFTRAG und COMMANDER

Im gepinnten Source vorhanden:

```lua
AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)
AUFTRAG:NewFromTarget(Target, AUFTRAG.Type.CAS)
COMMANDER:AddMission(Mission)
COMMANDER:CanMission(Mission)
```

Der MOOSE-Selektionspfad bewertet Missionsfähigkeit und verfügbare Assets der angebundenen Legions/AIRWINGs. OMW soll daher keine parallele feste Auswahlmatrix wie `Kunar -> AH-64`, `weit -> F-15E` entwickeln, solange MOOSE die Auswahl ausreichend leisten kann.

Die produktiven AirOps-Foundations deklarieren bereits CAS-fähige SQUADRONs, unter anderem:

```text
Bagram:
  F-15E -> CAS
  F-16C -> CAS

Jalalabad:
  AH-64D -> CAS

Kandahar:
  A-10C  -> CAS / CASENHANCED
  AH-64D -> CAS / CASENHANCED / ESCORT
```

Damit ist die MOOSE-first Zielkette technisch plausibel:

```text
CAS MissionDemand
-> AIR_SUPPORT_REQUEST
-> AIR_TASKING_PLAN mission
-> AUFTRAG:NewCAS(...)
-> BLUE COMMANDER:AddMission(...)
-> AIRWING/SQUADRON recruitment
-> FLIGHTGROUP / DCS
```

## 12. Abhängigkeit: BLUE COMMANDER

Auf `main` existiert noch keine produktive zentrale BLUE-COMMANDER-Runtime.

Es existiert jedoch bereits der separate Branch:

```text
agent/blue-commander-foundation
```

Dort liegt:

```text
scripts/command/OMW_Blue_Commander.lua
```

Der Branch implementiert bereits genau den vorgesehenen Foundation-Scope:

```text
- one BLUE COMMANDER;
- registration of productive BLUE AIRWING exports;
- no AUFTRAG creation;
- no OPSTRANSPORT creation;
- no CampaignState mutation.
```

Die MissionDemand/CAS-Arbeit darf diesen Branch nicht parallel neu implementieren. Vor CAS-Runtime-Integration ist der BLUE-COMMANDER-Branch gegen den dann aktuellen `main`-Stand zu reconciliieren und gemäß seinem eigenen Acceptance-/Merge-Status zu behandeln.

## 13. Offizielle Demo-/Testmissionen

Die offiziellen MOOSE-Missionsrepositories wurden erneut für die unmittelbar relevanten Begriffe durchsucht.

Aktueller Suchstand:

```text
MOOSE_MISSIONS:
  NewAMMOSUPPLY / NewFUELSUPPLY -> kein direkter Treffer

MOOSE_MISSIONS_UNPACKED:
  OPSTRANSPORT / AddPathTransport -> kein direkter Treffer
```

Dieser fehlende Suchtreffer ist kein Beweis, dass nie ein Beispiel existierte. Er ist lediglich der aktuelle dokumentierte Review-Stand.

Bereits früher dokumentiert ist, dass `WHS-020 - Self Propelled Ground Troops` WAREHOUSE direkt verwendet, aber keinen vollständigen Beleg für die OMW-Kombination `BRIGADE -> PLATOON -> ARMYGROUP` liefert.

Daher bleibt für die OMW-Kombination ein eigener DCS-Test erforderlich.

## 14. Phase-0-Ergebnis

```text
CampaignState transfer ledger
= READY / existing

Ground threshold data fields
= READY structurally; values not calibrated

MOOSE AUFTRAG AMMOSUPPLY/FUELSUPPLY
= SOURCE_REVIEWED; not strategic cargo transfer

MOOSE OPSTRANSPORT
= SOURCE_REVIEWED; strong real-cargo candidate

MOOSE BRIGADE/PLATOON/ARMYGROUP
= already validated for documented Ground lifecycle scope

MOOSE Hit event
= SOURCE_REVIEWED candidate for tactical incident input

MOOSE CAS AUFTRAG
= SOURCE_REVIEWED / existing AirOps capability declarations

BLUE COMMANDER
= separate existing branch; integration dependency, do not duplicate

Production exact PATHLINE routing
= unresolved; no new exception approved
```

## 15. Nächste Umsetzungsschritte

```text
STEP 1
Define MissionDemand domain registry/state model without MOOSE/DCS dependency.

STEP 2
Bind RESUPPLY demand to existing CampaignState transfer transaction IDs.

STEP 3
Calibrate target/reorder/critical policy separately; do not invent values.

STEP 4
Implement AI-first ROAD_CONVOY vertical slice using the smallest public MOOSE execution path that preserves CampaignState authority.

STEP 5
Reconcile/integrate the existing BLUE COMMANDER foundation before CAS runtime.

STEP 6
Implement MOOSE Hit -> TacticalSupportIncident -> AIR_SUPPORT_REQUEST -> CAS MissionDemand.

STEP 7
Translate the CAS demand to AUFTRAG and hand it to BLUE COMMANDER.

STEP 8
Add failure/cancel/restart and exactly-once settlement acceptance cases.
```

No step may mark DCS behavior `VALIDATED` until a reproducible owner DCS run with full provenance exists.
