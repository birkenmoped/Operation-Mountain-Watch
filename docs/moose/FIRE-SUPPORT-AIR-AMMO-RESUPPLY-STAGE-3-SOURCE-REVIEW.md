---
document_id: OMW-MOOSE-FIRE-SUPPORT-AIR-AMMO-RESUPPLY-STAGE-3-SOURCE-REVIEW
status: PLANNED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage-3 MOOSE-first source review for Air Ground-AMMO resupply
  - owner decision to extend Stage 3 with an Air-AMMO contract before final combined acceptance
  - source-reviewed selection of CARGOTRANSPORT for the first isolated Air-AMMO acceptance
not_authoritative_for:
  - DCS runtime validation of Air-AMMO resupply
  - normative physical mass or kg conversion for GROUND_AMMO_PACKAGE
  - final combined Honaker attack/fire-support/resupply acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Air-AMMO Resupply – MOOSE-First Source Review

## 1. Owner-Entscheidungen

Am 30.08.2026 hat der Projektinhaber Stage 3 ausdrücklich erweitert:

```text
B) Stage 3 erweitern und zuerst einen neuen MOOSE-first Air-AMMO-Resupply-Vertrag entwickeln und validieren.
```

Nach der MOOSE-/OMW-Reconciliation wurde zusätzlich folgende Semantik freigegeben:

```text
CARGOTRANSPORT + Jalalabad CH-47

1 physisches Slingload-Cargo
= physische Repräsentation eines vollständigen CampaignState-AMMO-Transfermanifests

keine 1:1-Beziehung
zwischen Cargo-Objekten/Kilogramm und GROUND_AMMO_PACKAGE
```

Der bereits DCS-validierte Ground-AMMOSUPPLY-Pfad bleibt erhalten, ist aber nicht der alleinige Stage-3-Abschluss.

## 2. Unveränderte Autoritätsgrenze

```text
CampaignState
= einzige strategische Ressourcenautorität

MissionDemand
= Demand-/Assignment-/Statusautorität

MOOSE
= operativer Air-Transport- und physischer Lifecycle

DCS STATIC cargo
= nichtautoritative physische Repräsentation

DCS / MOOSE Warehouse / STORAGE / CTLD stock
= keine zweite strategische AMMO-Autorität
```

`GROUND_AMMO_PACKAGE` bleibt die strategische OMW-Einheit. Die verbindliche Ground-Ressourcenbaseline definiert sie als normalisiertes Ground-AMMO-Paket und ausdrücklich nicht als historische Tonnage.

## 3. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden die tatsächlich verwendete `Moose.lua`, vorhandene OMW-MOOSE-Dokumentation, die Stage-1D-P-Air-PERSONNEL-Baseline und die offiziellen MOOSE-Missions-/Demoquellen soweit für den konkreten Transportpfad auffindbar.

## 4. MOOSE-Kandidaten

### 4.1 `OPSTRANSPORT`

Der gepinnte Source unterstützt Carrier als `OPSGROUP`, einschließlich `FLIGHTGROUP`.

Für Storage-Transport existiert unter anderem:

```lua
local transport = OPSTRANSPORT:New(nil, PickupZone, DeployZone)
transport:AddCargoStorage(StorageFrom, StorageTo, CargoType, CargoAmount, CargoWeight)
carrier:AddOpsTransport(transport)
```

`AddCargoStorage(...)` liest und verändert jedoch die angegebenen DCS-`STORAGE`-Bestände beim Laden und Entladen. Für `GROUND_AMMO_PACKAGE` würde eine direkte Übernahme dieses Modus eine zweite Ressourcenbuchhaltung neben `CampaignState` riskieren.

Ergebnis:

```text
OPSTRANSPORT Storage mode
= MOOSE-funktional vorhanden
= nicht als erster OMW strategic Ground-AMMO executor gewählt
```

### 4.2 `AUFTRAG:NewFREIGHTTRANSPORT(...)`

Der gepinnte Source enthält:

```lua
AUFTRAG:NewFREIGHTTRANSPORT(StaticCargo, DestinationAirbase)
```

Source-bestätigte Eigenschaften:

```text
- planes und helicopters
- internes Cargo
- STATIC oder SET_STATIC
- Ziel muss AIRBASE sein
- Cargo muss zum Missionsstart innerhalb 40 m des Carriers liegen
- Weight limits werden in diesem AUFTRAG-Pfad nicht geprüft
- bei mehreren Cargo-Items reicht irgendein geliefertes Cargo für Mission Success
```

Für Wright ist dieser Vertrag unnötig eng an AIRBASE-/FARP-Semantik gekoppelt. Stage 1D-P hat außerdem gezeigt, dass fremde AIRBASE-/FARP-Zwischenziele im AIRWING-Lifecycle besonders sorgfältig behandelt werden müssen.

Ergebnis:

```text
FREIGHTTRANSPORT
= echter MOOSE-Kandidat
= nicht für Acceptance 1 gewählt
```

### 4.3 `AUFTRAG:NewCARGOTRANSPORT(...)`

Der gepinnte Source enthält:

```lua
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)
```

Source-bestätigte Eigenschaften:

```text
- Helicopter only
- externe Slingload-Fracht
- genaues STATIC cargo als Zielobjekt
- DropZone muss eine Mission-Editor-Zone mit ZoneID sein
- MissionTask = TRANSPORT
```

Der gepinnte `AUFTRAG:Evaluate()`-Pfad prüft bei `CARGOTRANSPORT` genau:

```text
cargo exists
AND
cargo:IsInZone(dropZone)
```

Damit besitzt MOOSE bereits die zentrale physische Delivery-Prüfung. OMW muss nur die strategische `cargoId`/`transactionId`-Korrelation und CampaignState-Gutschrift exakt einmal darum legen.

Ergebnis:

```text
CARGOTRANSPORT
= ausgewählter MOOSE-first Acceptance-1-Pfad
= DCS-Runtime noch offen
```

### 4.4 `SPAWNSTATIC`

Der gepinnte Source bestätigt die für eine nichtautoritative Manifest-Repräsentation benötigten öffentlichen Methoden:

```lua
SPAWNSTATIC:NewFromType(StaticType, StaticCategory, CountryID)
SPAWNSTATIC:InitCargo(true)
SPAWNSTATIC:InitCargoMass(Mass)
SPAWNSTATIC:InitCoordinate(Coordinate)
SPAWNSTATIC:InitValidateAndRepositionStatic(OnOff, MaxRadius)
SPAWNSTATIC:Spawn(Heading, NewName)
```

MOOSE selbst verwendet `ammo_cargo` als Cargo-Static-Typ in seinem AMMOTRUCK-Pfad. Das rechtfertigt den Typ als technischen Acceptance-Kandidaten, nicht eine strategische AMMO-Mengenbedeutung.

### 4.5 CTLD

MOOSE CTLD unterstützt reale Crates, Cargo-Massen und Slingload. Der geprüfte Klassenvertrag besitzt aber zusätzlich eigene Cargo-/Stockmechanismen und ist primär für CTLD-gesteuerte Cargo-Workflows ausgelegt.

Für den hier benötigten automatischen AI-MissionDemand-Executor wird CTLD deshalb nicht als strategischer Stockowner eingesetzt.

## 5. Beste MOOSE-first Entwicklungsrichtung

Die freigegebene erste Acceptance-Komposition lautet:

```text
CampaignState GROUND_AMMO_PACKAGE shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER reservation with stable cargoId

-> one non-authoritative physical ammo_cargo STATIC
-> Jalalabad AIRWING / SQ_US_JBAD_CH47_HEAVYLIFT
-> MOOSE AUFTRAG:NewCARGOTRANSPORT(...)
-> real slingload pickup
-> real flight Jalalabad -> Wright
-> real drop into Wright ME LZ

-> exact cargo physically in drop zone
-> AUFTRAG Success
-> CampaignState MarkDelivered exactly once
-> MissionDemand SUCCESS exactly once

-> physical CH-47 return to Jalalabad
-> home OnAfterLanded
-> afterwards LegionAssetReturned
```

Keine native DCS-Cargo-Task wird parallel implementiert.

## 6. Physische Manifest-Semantik

Der strategische und physische Wert werden bewusst getrennt:

```text
CampaignState manifest:
resourceType = GROUND_AMMO_PACKAGE
quantity = N
cargoId = stable transfer cargo ID

physical DCS/MOOSE representation:
1 slingload STATIC
```

Es gilt ausdrücklich **nicht**:

```text
1 STATIC = 1 GROUND_AMMO_PACKAGE
1 kg = X GROUND_AMMO_PACKAGE
```

Die physische Static-Masse ist ein DCS-/Slingload-Parameter. Acceptance 1 verwendet testweise 1000 kg ausschließlich als nichtnormativen technischen Parameter; daraus entsteht keine Projekt-Massenbaseline.

## 7. Acceptance-spezifische vorhandene Geometrie

Für Acceptance 1 werden vorhandene Mission-Editor-Objekte wiederverwendet:

```text
Pickup anchor:
OMW_LOG_NODE_JALALABAD

DropZone:
OMW_BLUE_LZ_WRIGHT_01
```

`OMW_BLUE_LZ_WRIGHT_01` besitzt die für `CARGOTRANSPORT` notwendige Mission-Editor-Zonen-ID. Es wird keine zusätzliche Testzone angelegt.

Für die Cargo-Materialisierung wird `SPAWNSTATIC:InitValidateAndRepositionStatic(...)` innerhalb eines begrenzten Acceptance-Radius verwendet, statt einen eigenen Terrain-/Obstacle-Scanner zu implementieren.

## 8. In-Transit- und Settlement-Grenze

Ein Helicopter-Takeoff ist bei `CARGOTRANSPORT` noch kein sicherer Cargo-Pickup-Beweis. Deshalb gilt für Acceptance 1:

```text
AIRWING FlightOnMission
-> TRANSFER LOADING

exact cargo alive
AND exact cargo has physically left pickup zone
-> TRANSFER IN_TRANSIT
-> origin debit exactly once

exact cargo in Wright drop zone
AND MOOSE AUFTRAG Success
-> MarkDelivered exactly once
-> destination credit exactly once
-> MissionDemand SUCCESS exactly once
```

Die In-Transit-Prüfung erfolgt mit einem kleinen MOOSE-`SCHEDULER` ausschließlich gegen das korrelierte `STATIC`-Objekt. Kein World-Scan und keine zweite Cargo-Engine werden eingeführt.

Failure vor In-Transit kann die Reservation `CANCELLED` setzen. Failure nach In-Transit setzt den Transfer `LOST`; das Ziel erhält keinen Credit.

## 9. Offizielle Demo-Prüfung

Die offiziellen MOOSE-Missions-/Demoquellen wurden nach einem unmittelbar übertragbaren `AUFTRAG:NewCARGOTRANSPORT`-Vertical-Slice durchsucht. Es wurde kein passender offizieller AIRWING + CARGOTRANSPORT + strategischer Settlement-Nachweis gefunden.

Das ist kein Beweis gegen die API: Konstruktor, DCS-Task-Aufbau und `Evaluate()`-Semantik sind im tatsächlich gepinnten Source vorhanden. Genau deshalb ist ein eigener reproduzierbarer DCS-Acceptance-Lauf erforderlich, bevor OMW diesen Pfad als validiert bezeichnet.

## 10. Verhältnis zum finalen Stage-3-Test

Nach einem separaten Air-AMMO-PASS soll der kombinierte Stage-3-Lauf werden:

```text
Honaker attacked
-> existing Stage-2 OPSZONE threat detection
-> existing Guard/QRF response
-> FIRE_SUPPORT_IMMEDIATE
-> Honaker local mortar unavailable for acceptance
-> Wright L118 external fire support
-> real MOOSE ARTY mission
-> real Wright local rearm
-> CampaignState GROUND_AMMO_PACKAGE reaches existing reorder threshold
-> automatic RESUPPLY MissionDemand
-> Air-AMMO CARGOTRANSPORT Jalalabad -> Wright
-> physical delivery
-> CampaignState settlement
-> MissionDemand SUCCESS
-> carrier return
```

## 11. Aktueller Status

```text
Owner decision B: ACCEPTED
Physical manifest semantics: ACCEPTED
MOOSE source review: COMPLETE for Acceptance-1 candidate selection
Air-AMMO Acceptance-1: STAGED / NOT YET RUN IN DCS
Air-AMMO production contract: OPEN until runtime acceptance
Final Stage-3 combined acceptance: NOT YET RUN
```
