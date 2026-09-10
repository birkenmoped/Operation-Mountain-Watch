---
document_id: OMW-AIR-AMMO-CARGOTRANSPORT-ACCEPTANCE-1
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage-3 isolated Air Ground-AMMO slingload acceptance scope
  - approved physical-manifest representation for this acceptance
  - Jalalabad-to-Wright CARGOTRANSPORT success-path acceptance criteria
not_authoritative_for:
  - DCS runtime validation before the documented acceptance run passes
  - normative kg conversion for GROUND_AMMO_PACKAGE
  - final combined Honaker attack/fire-support/resupply acceptance
  - all future Air-AMMO transport modes or carriers
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Air-AMMO `CARGOTRANSPORT` Acceptance 1

## 1. Owner-Freigabe und Zweck

Der Projektinhaber hat am 30.08.2026 nach der MOOSE-first Source-Review folgende Semantik freigegeben:

```text
CARGOTRANSPORT + Jalalabad CH-47

1 physisches Slingload-Cargo
= physische Repräsentation eines vollständigen CampaignState-AMMO-Transfermanifests

keine 1:1-Beziehung
zwischen Cargo-Objekten/Kilogramm und GROUND_AMMO_PACKAGE
```

Acceptance 1 validiert zunächst ausschließlich diesen neuen physischen Air-AMMO-Vertrag. Die bereits validierten Stage-2-Angriffs-/QRF-Reaktionen und der finale Honaker -> Wright Fire-Support-Zusammenhang werden erst nach einem PASS dieses Transportvertrags zusammengeführt.

## 2. Authority-Grenze

```text
CampaignState
= strategische Menge, Eigentum, Reservierung und Settlement

MissionDemand
= Demand-/Assignment-/Statusautorität

MOOSE AIRWING / SQUADRON / AUFTRAG / FLIGHTGROUP / SPAWNSTATIC
= physischer Executor und Runtime-Evidenz

DCS STATIC slingload
= nichtautoritative physische Manifest-Repräsentation
```

Das physische Cargo besitzt keine eigene strategische AMMO-Menge und schreibt keinen DCS-`STORAGE`-Bestand als OMW-Wahrheit zurück.

## 3. Geprüfter MOOSE-Vertrag

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendete Source-bestätigte Methoden:

```lua
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)

SPAWNSTATIC:NewFromType(StaticType, StaticCategory, CountryID)
SPAWNSTATIC:InitCargo(true)
SPAWNSTATIC:InitCargoMass(Mass)
SPAWNSTATIC:InitCoordinate(Coordinate)
SPAWNSTATIC:InitValidateAndRepositionStatic(true, MaxRadius)
SPAWNSTATIC:Spawn(Heading, NewName)
```

`AUFTRAG:NewCARGOTRANSPORT(...)` ist Helicopter-only, verwendet ein reales STATIC als externes Slingload und verlangt eine echte Mission-Editor-Zone mit `ZoneID` als DropZone.

Der gepinnte AUFTRAG-`Evaluate()`-Pfad bewertet `CARGOTRANSPORT` anhand genau des referenzierten Cargos:

```text
cargo exists
AND
cargo:IsInZone(dropZone)
```

Damit ist der MOOSE-Missionsabschluss eine geeignete physische Delivery-Evidenz, wird aber weiterhin mit der exakten CampaignState-`cargoId`/`transactionId`-Korrelation abgesichert.

### Demo-Prüfung

Die offiziellen MOOSE-Missions-/Demoquellen wurden im Rahmen der Stage-3-Prüfung nach einem unmittelbar übertragbaren `AUFTRAG:NewCARGOTRANSPORT`-Beispiel durchsucht. Es wurde kein passender offizieller Vertical-Slice gefunden, der den hier benötigten AIRWING + strategisches Settlement-Vertrag zusätzlich belegt. Deshalb stützt sich Acceptance 1 auf die dokumentierte öffentliche Klasse und den tatsächlich gepinnten Source; das Runtime-Verhalten bleibt bis zum DCS-Lauf ausdrücklich unvalidiert.

## 4. Vorhandene OMW-Bausteine

Wiederverwendet werden:

```text
Jalalabad AIRWING
SQ_US_JBAD_CH47_HEAVYLIFT
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
GROUND_NODE_JALALABAD
GROUND_NODE_WRIGHT
GROUND_AMMO_PACKAGE
OMW_LOG_NODE_JALALABAD
OMW_BLUE_LZ_WRIGHT_01
```

Der Jalalabad-CH-47-AIRWING-/SQUADRON-Lifecycle inklusive physischer Rückkehr wurde bereits mit der Air-PERSONNEL Acceptance-4 auf dem dort exakt dokumentierten Stand nachgewiesen. Dieser Nachweis wird nicht auf `CARGOTRANSPORT` extrapoliert; er reduziert lediglich die Zahl der gleichzeitig neuen Komponenten.

`OMW_BLUE_LZ_WRIGHT_01` wird als vorhandene Mission-Editor-DropZone verwendet. Es wird keine zusätzliche Testzone erzeugt.

`OMW_LOG_NODE_JALALABAD` ist der vorhandene Pickup-Anker. Das physische Static wird über MOOSE `SPAWNSTATIC` dort materialisiert; `InitValidateAndRepositionStatic(...)` darf innerhalb eines begrenzten Acceptance-Radius eine freie Bodenposition suchen.

## 5. Acceptance-only Mengen

```text
Jalalabad initial GROUND_AMMO_PACKAGE: 100
Wright initial GROUND_AMMO_PACKAGE:     30
Acceptance shortage:                    15
Wright after shortage:                  15
reorder threshold:                      15 (AT_OR_BELOW)
requested transfer:                     15
expected final Jalalabad:               85
expected final Wright:                  30
```

Die isolierte Shortage-Erzeugung ist Teststeuerung. Sie beweist nicht den späteren Artillerie-Rearm-Trigger. Der finale Stage-3-Lauf muss die Wright-Absenkung durch den realen Fire-Support-Rearm erzeugen.

## 6. Physisches Manifest

```text
cargoId:
CARGO-ACCEPTANCE-JALALABAD-WRIGHT-AMMO-AIR-CARGOTRANSPORT-001

physical static type:
ammo_cargo

physical static count:
1

CampaignState manifest quantity:
15 GROUND_AMMO_PACKAGE
```

Acceptance 1 verwendet für das Slingload-Objekt:

```text
physical cargo mass = 1000 kg
```

Dieser Wert ist ausdrücklich nur ein **technischer DCS-Acceptance-Parameter**. Er definiert weder:

```text
1 GROUND_AMMO_PACKAGE = 1000 kg
```

noch irgendeine andere strategische kg-Umrechnung. Eine normative Cargo-Massen-/Kapazitätsmatrix ist nicht Bestandteil dieser Acceptance.

## 7. Erwarteter Lifecycle

```text
Wright shortage 30 -> 15
-> ResourceDemandPolicy REORDER
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER RESERVED

-> one physical ammo_cargo static at OMW_LOG_NODE_JALALABAD
-> MOOSE AUFTRAG:NewCARGOTRANSPORT(cargo, OMW_BLUE_LZ_WRIGHT_01)
-> Jalalabad CH-47 AIRWING/SQUADRON assigned
-> AIRWING FlightOnMission
-> CampaignState TRANSFER LOADING

-> exact cargo physically leaves pickup zone
-> CampaignState MarkInTransit
-> Jalalabad strategic quantity 100 -> 85
-> MissionDemand ACTIVE

-> real slingload transport
-> exact cargo physically delivered into OMW_BLUE_LZ_WRIGHT_01
-> MOOSE AUFTRAG Success / exact cargo in DropZone
-> CampaignState MarkDelivered exactly once
-> Wright 15 -> 30
-> MissionDemand SUCCESS exactly once

-> CH-47 physically returns to Jalalabad
-> FLIGHTGROUP OnAfterLanded at home
-> afterwards LegionAssetReturned
-> PASS
```

## 8. In-Transit Commitpunkt

Takeoff ist für `CARGOTRANSPORT` kein geeigneter strategischer Debitpunkt, weil der Helicopter zunächst zum physischen Cargo fliegen kann.

Acceptance 1 verwendet deshalb eine kleine, nur während des aktiven Transports laufende MOOSE-`SCHEDULER`-Prüfung im 5-Sekunden-Intervall:

```text
loading confirmed
AND exact cargo alive
AND exact cargo no longer inside OMW_LOG_NODE_JALALABAD
-> MarkInTransit exactly once
```

Das ist keine zweite Cargo-Engine und kein World-Scan. Geprüft wird ausschließlich das bereits korrelierte MOOSE-`STATIC`-Objekt. Nach In-Transit oder terminalem Ergebnis wird der Scheduler beendet.

## 9. Failure-Grenze

Für diesen Acceptance-Code gilt:

```text
failure while TRANSFER RESERVED/LOADING
-> CampaignState Cancel
-> no origin debit
-> no destination credit
-> MissionDemand FAILED

failure after TRANSFER IN_TRANSIT
-> CampaignState MarkLost
-> origin remains debited
-> no destination credit
-> MissionDemand FAILED
```

Acceptance 1 ist primär ein Success-Path-DCS-Test. Vollständige reproduzierbare Loss-Injection ist nicht automatisch Teil desselben DCS-Laufs.

## 10. Bewusst noch nicht enthalten

```text
kein zusätzlicher ME-Trigger
kein Stage-2 Threat-Nachbau
kein Honaker-Angriff
kein Wright-Artilleriefeuer
kein lokaler Fire-Support-Rearm
kein Ground-AMMOSUPPLY-Convoy
kein OPSTRANSPORT Storage mode
kein CTLD-Stockledger
kein FREIGHTTRANSPORT
kein Native-DCS Event Handler
keine MissionScripting.lua-Änderung
keine automatisierte MIZ-Mutation
kein eigener Flugkorridor-Dispatcher
```

Der erste Lauf soll die ungeprüfte MOOSE-`CARGOTRANSPORT`-Komponente möglichst isoliert beweisen. `OMW_FlightPath` wird nicht gleichzeitig neu in den CARGOTRANSPORT-Waypoint-Lifecycle injiziert. Der bereits validierte CH-47-FlightPath-Vertrag kann nach erfolgreicher Grundfunktion in einer Folgestufe gezielt ergänzt werden, falls die MOOSE-Missionsführung dies für den finalen Stage-3-Lauf benötigt.

## 11. PASS-Kriterien

Ein PASS erfordert mindestens:

```text
1. genau ein RESUPPLY Demand;
2. genau eine TRANSFER-Reservation mit cargoId;
3. genau ein physisches ammo_cargo Static;
4. Jalalabad CH-47 wird über AIRWING/SQUADRON der CARGOTRANSPORT-Mission zugeordnet;
5. TRANSFER erreicht LOADING;
6. physisches Cargo verlässt Pickup-Zone -> genau ein MarkInTransit;
7. Ursprung wird genau einmal um 15 reduziert;
8. reales Slingload wird nach Wright transportiert;
9. dasselbe Cargo liegt in OMW_BLUE_LZ_WRIGHT_01;
10. MOOSE CARGOTRANSPORT meldet Success;
11. genau ein MarkDelivered;
12. Wright wird genau einmal von 15 auf 30 gutgeschrieben;
13. MissionDemand wird genau einmal SUCCESS;
14. CH-47 landet physisch wieder in Jalalabad;
15. erst danach wird das AIRWING-Asset als zurückgekehrt beobachtet.
```

DCS-/MOOSE-Runtimeverhalten bleibt bis zu diesem Test `NOT YET VALIDATED`.
