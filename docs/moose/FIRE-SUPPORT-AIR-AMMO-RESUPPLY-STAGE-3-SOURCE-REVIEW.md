---
document_id: OMW-MOOSE-FIRE-SUPPORT-AIR-AMMO-RESUPPLY-STAGE-3-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage-3 MOOSE-first source review for Air Ground-AMMO resupply
  - owner decision to extend Stage 3 with an Air-AMMO contract before final combined acceptance
not_authoritative_for:
  - DCS runtime validation of Air-AMMO resupply
  - final carrier type or package mass before explicit contract approval
  - changing CampaignState strategic resource authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Air-AMMO Resupply – MOOSE-First Source Review

## 1. Owner-Entscheidung

Am 30.08.2026 hat der Projektinhaber für Stage 3 ausdrücklich entschieden:

```text
B) Stage 3 erweitern und zuerst einen neuen MOOSE-first Air-AMMO-Resupply-Vertrag entwickeln und validieren.
```

Damit wird der bereits DCS-validierte Ground-AMMOSUPPLY-Pfad nicht als alleiniger Stage-3-Abschluss verwendet. Vor dem finalen kombinierten Fire-Support-Test wird ein eigenständiger Air-AMMO-Vertrag entwickelt und in DCS validiert.

## 2. Unveränderte Autoritätsgrenze

```text
CampaignState
= einzige strategische Ressourcenautorität

MissionDemand
= Demand-/Assignment-/Statusautorität

MOOSE
= operativer Air-Transport- und physischer Lifecycle

DCS / MOOSE Warehouse / STORAGE
= keine zweite strategische AMMO-Autorität
```

`GROUND_AMMO_PACKAGE` bleibt die strategische OMW-Einheit. Eine MOOSE-/DCS-Cargo-Repräsentation darf nur physischer Carrier-/Delivery-Nachweis sein.

## 3. Geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden die tatsächlich verwendete `Moose.lua`, die vorhandene OMW-MOOSE-Dokumentation sowie vorhandene Air-/Ground-Transport-Baselines.

## 4. MOOSE-Kandidaten

### 4.1 `OPSTRANSPORT`

Der gepinnte Source unterstützt Carrier als `OPSGROUP`, einschließlich `FLIGHTGROUP`; Carrier können Ground, Helicopter, Plane oder Ship sein.

Für Storage-Transport existiert:

```lua
local transport = OPSTRANSPORT:New(nil, PickupZone, DeployZone)
transport:AddCargoStorage(StorageFrom, StorageTo, CargoType, CargoAmount, CargoWeight)
carrier:AddOpsTransport(transport)
```

`AddCargoStorage(...)` liest und verändert jedoch die angegebenen DCS-`STORAGE`-Bestände beim Laden und Entladen. Damit würde dieser direkte Storage-Modus im OMW-Strategiemodell eine zweite Ressourcenbuchhaltung neben `CampaignState` erzeugen.

Ergebnis:

```text
OPSTRANSPORT Storage mode
= MOOSE-funktional vorhanden
= für OMW strategic GROUND_AMMO_PACKAGE nicht direkt zulässig
```

Er darf nur dann später verwendet werden, wenn DCS STORAGE ausdrücklich als nichtautoritativer Mirror gekapselt wird und exakt bewiesen ist, dass keine doppelte Ressourcenhoheit entsteht. Das ist nicht der kleinste Stage-3-Weg.

### 4.2 `AUFTRAG:NewFREIGHTTRANSPORT(...)`

Der gepinnte Source enthält:

```lua
AUFTRAG:NewFREIGHTTRANSPORT(StaticCargo, DestinationAirbase)
```

Eigenschaften:

```text
- planes und helicopters
- internes Cargo
- STATIC oder SET_STATIC als Cargo
- DCS internal cargo transportation / unload tasks
- Ziel muss AIRBASE sein
- Mission gilt als erfolgreich, wenn mindestens ein Cargo-Item geliefert wurde
```

Grenzen für Stage 3:

```text
- Wright muss für diesen Pfad als geeigneter AIRBASE/FARP-Endpunkt vertraglich nachgewiesen werden;
- statisches Cargo benötigt eine explizite OMW-Abbildung auf GROUND_AMMO_PACKAGE;
- "any cargo delivered" ist allein kein CampaignState-Settlement-Signal für eine Mehrfachpaket-Transaktion.
```

Damit ist FREIGHTTRANSPORT ein echter MOOSE-Kandidat, aber noch kein freigegebener OMW-Air-AMMO-Vertrag.

### 4.3 `AUFTRAG:NewCARGOTRANSPORT(...)`

Der gepinnte Source enthält:

```lua
AUFTRAG:NewCARGOTRANSPORT(StaticCargo, DropZone)
```

Eigenschaften:

```text
- Helicopter only
- externe Slingload-Fracht
- STATIC cargo
- DropZone muss eine Mission-Editor-Zone mit ZoneID sein
```

Dieser Pfad passt grundsätzlich zu einem FOB/COP-LZ-Ziel, weil kein AIRBASE als Destination erforderlich ist. Für OMW fehlen jedoch noch Runtime-Beweise für:

```text
- gewählten Jalalabad Carrier
- physische Cargo-Materialisierung
- Aufnahme des Cargo
- Talrouting
- Absetzen in der Wright-LZ
- Cargo-/Carrier-Verlust
- Rückkehr des Carrier-Assets
- exakt einmalige CampaignState-Settlement-Korrelation
```

### 4.4 CTLD

MOOSE CTLD unterstützt Cargo/Crates und reale Cargo-Masse. Der aktuell geprüfte Klassenvertrag ist primär für Spieler-CTLD ausgelegt und besitzt zusätzlich eigene Cargo-Stock-Mechanismen.

Für den hier benötigten automatischen AI-MissionDemand-Executor würde eine direkte Übernahme des CTLD-Stockmodells erneut eine parallele Ressourcenhoheit erzeugen.

Ergebnis:

```text
CTLD
= nicht verworfen als MOOSE-System
= aber nicht automatisch der strategische AI-Air-AMMO-Executor
= CampaignState muss auch bei späterer CTLD-Nutzung autoritativ bleiben
```

## 5. Beste derzeitige MOOSE-first Entwicklungsrichtung

Für den ersten Air-AMMO-Acceptance wird kein DCS-Warehouse-Storage als strategische Fracht verwendet.

Der kleinste belastbare Kandidat ist:

```text
CampaignState GROUND_AMMO_PACKAGE shortage
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER reservation
-> physisches, nichtautoritative Static-Cargo-Repräsentation
-> MOOSE helicopter transport
-> reale Aufnahme
-> realer Flug Jalalabad -> Wright
-> reale Ablage / Delivery-Evidenz
-> CampaignState MarkDelivered exactly once
-> MissionDemand SUCCESS exactly once
-> Carrier RTB / AIRWING asset return
```

Für den eigentlichen MOOSE-Executor werden als nächste Vergleichsstufe getestet:

```text
1. AUFTRAG:NewCARGOTRANSPORT(...)
2. AUFTRAG:NewFREIGHTTRANSPORT(...), nur falls Wright als geeigneter AIRBASE/FARP-Endpunkt nachgewiesen wird
3. OPSTRANSPORT nur ohne direkte strategische DCS-STORAGE-Autorität
```

Keine native DCS-Cargo-Task wird parallel implementiert, solange einer dieser MOOSE-Wege den benötigten Scope tragen kann.

## 6. Noch festzulegende OMW-Verträge vor Runtime-Code

Folgende Punkte sind technische Vertragsarbeit und dürfen nicht erfunden werden:

```text
A. Carrier
   Jalalabad CH-47 oder anderer bereits vorhandener, passender AIRWING/SQUADRON-Carrier.

B. physische Package-Repräsentation
   Zuordnung 1 GROUND_AMMO_PACKAGE <-> physisches Static Cargo.
   Masse und Anzahl müssen explizit festgelegt oder aus bereits bindender OMW-Evidenz übernommen werden.

C. Pickup
   existierende Jalalabad Pickup-/Warehouse-/LZ-Geometrie wiederverwenden; keine neue Zone ohne Not.

D. Wright Delivery
   vorhandene Wright-LZ/FARP-/RESUPPLY-Geometrie prüfen und den MOOSE-geeigneten Endpunkt auswählen.

E. Settlement
   CampaignState debit erst am akzeptierten In-Transit-Commitpunkt;
   destination credit ausschließlich nach realer physischer Delivery-Evidenz;
   kein Settlement nur wegen AUFTRAG-Queue oder Asset-Materialisierung.

F. Loss
   Carrier/Cargo-Verlust vor Delivery -> TRANSFER LOST / Demand FAILED;
   kein Ziel-Credit.

G. Return
   Lieferung und strategische Settlement-Entscheidung bleiben vom späteren Carrier-RTB getrennt.
```

## 7. Verhältnis zum finalen Stage-3-Test

Nach separater Air-AMMO-Acceptance soll der kombinierte Stage-3-Lauf werden:

```text
Honaker attacked
-> existing OPSZONE threat detection
-> existing Guard/QRF response
-> FIRE_SUPPORT_IMMEDIATE
-> Wright L118 external fire support
-> real fire mission
-> local Wright rearm
-> CampaignState GROUND_AMMO_PACKAGE reaches existing reorder threshold
-> automatic RESUPPLY MissionDemand
-> Air-AMMO executor Jalalabad -> Wright
-> physical delivery
-> CampaignState settlement
-> MissionDemand SUCCESS
-> carrier return
```

Die bereits DCS-validierten Fire-Support-Rearm-, Stage-2-Threat- und Ground-RESUPPLY-Bausteine werden nicht isoliert erneut entwickelt.

## 8. Aktueller Status

```text
Owner decision B: ACCEPTED
MOOSE source review: COMPLETE for candidate selection
Air-AMMO production contract: OPEN
Air-AMMO DCS acceptance: NOT YET RUN
Final Stage-3 combined acceptance: NOT YET RUN
```
