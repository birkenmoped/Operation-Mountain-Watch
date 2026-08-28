---
document_id: OMW-DECISION-TARINKOT-G2-OBJECT-CONTRACT-2026-08-03
status: BINDING_PROJECT_DECISION
document_class: OBJECT_CONTRACT_ACCEPTANCE_CHECKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - complete owner-accepted Tarinkot G2 object contract
  - distinction between accepted technical decisions and later runtime questions
  - Tarinkot functional-zone gate dependencies including the historically supported FARP
  - implementation lock and gate sequence before runtime activation
not_authoritative_for:
  - DCS runtime acceptance
  - final AI parking allowlists
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
decision_date: 2026-08-03
source_branch: agent/tarinkot-object-contract-reconciliation
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
decision_state: OWNER_ACCEPTED_BRANCH
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
supersedes:
  - proposed owner-acceptance state of this checklist
superseded_by: []
---

# Tarinkot – G2-Objektvertrag und Abnahmeliste

## 1. Zweck und Entscheidung

Dieses Dokument enthält den vollständigen Tarinkot-G2-Objektvertrag. Der Projekteigentümer hat ihn am 03.08.2026 ausdrücklich angenommen.

```yaml
G2_object_contract: OWNER_ACCEPTED_BRANCH
runtime_acceptance: false
merge_approval: false
ready_for_review_approval: false
```

Der separate Entscheidungsnachweis steht in:

```text
docs/evidence/tarinkot-g2-owner-acceptance-2026-08-03.md
```

## 2. Historischer Arbeitszeitraum

```text
März bis Dezember 2011
```

Das in der aktuellen MIZ eingetragene Datum `14.01.2011` ist für die aktive Tarinkot-ORBAT und Benennung nicht steuernd.

## 3. Historische Organisationsstruktur

```text
Lokaler Aviation-Knoten:
Task Force Attack / 3-101 Attack Aviation

Übergeordnet:
Task Force Thunder / 159th Combat Aviation Brigade

UH-60:
Task-Force-Attack-Komponente
administrative Company weiterhin offen

CH-47:
B Company, 1-52 Aviation Regiment
historisches Muster CH-47D
```

## 4. Technische Namen

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

## 5. Standort und Warehouse

```yaml
locationCode: TKOT
dcsAirdromeId: 9
runtimeAirbaseName: READ_ONLY_DIAGNOSTIC_REQUIRED
warehouseAnchor: WH_AIR_US_TARINKOT
warehouseObjectType: container_20ft
warehouseUnitId: 1608
```

Vertrag:

- der Runtime-Airbase-Name wird nicht geraten;
- Airbase-ID und MOOSE-Name werden in G5 read-only protokolliert;
- exakt ein Warehouse-Anker muss vorhanden sein;
- bei fehlendem oder mehrfach vorhandenem Anker erfolgt später Fail-fast;
- das native unbegrenzte DCS-Warehouse erzeugt keinen unbegrenzten CampaignState-Bestand.

## 6. Nominaler lokaler OMW-Bestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Evidenzgrenze:

- AH-64-, UH-60- und CH-47-Präsenz 2011 ist bestätigt;
- B/1-52 als lokales CH-47D-Detachment ist bestätigt;
- die exakten Werte `14/6/2/0` sind eine quellennahe OMW-Rekonstruktion;
- die Werte dürfen nicht zusätzlich in Kandahar oder einem anderen RC-South-Pool gezählt werden.

## 7. Darstellungsledger

| Musterfamilie | Statics | aktive Clients maximal | aktive KI maximal | maximale gleichzeitige Darstellung |
|---|---:|---:|---:|---:|
| AH-64 | 8 | 2 | 4 | 14 |
| UH-60 | 4 | 0 | 2 | 6 |
| CH-47 | 0 | 1 | 1 | 2 |
| OH-58D | 0 | 0 | 0 | 0 |

Invariante:

```text
Statics
+ aktive Clients
+ aktive KI
+ bestätigte Wartungs-/Stranded-Zustände
<= verbleibender lokaler Bestand je Musterfamilie
```

Late-Activation-Seeds und unbelegte Client-Slots erhöhen den Bestand nicht.

## 8. Mission-Editor-Seeds und registrierter KI-Bestand

```yaml
AH64:
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  templateAircraftPerGroup: 2
  registeredGroups: 2
  grouping: 2
  maximumRegisteredAIAircraft: 4

UH60:
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  templateAircraftPerGroup: 1
  registeredGroups: 2
  grouping: 1
  maximumRegisteredAIAircraft: 2
  seedReuse: SAME_ONE_SHIP_TEMPLATE_SOURCE_CONFIRMED

CH47:
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  templateAircraftPerGroup: 1
  registeredGroups: 1
  grouping: 1
  maximumRegisteredAIAircraft: 1
```

Historische Abweichung:

```text
B/1-52 setzte 2011 CH-47D ein.
CH-47Fbl1 ist ein dokumentierter DCS-Ersatz.
```

Die Wiederverwendung des UH-60-One-Ship-Seeds für zwei Asset-Gruppen wurde in G4 anhand der exakten MOOSE-2.9.18-Quelle bestätigt.

## 9. Client-Reservierungen

```text
CLIENT_US_TKOT_AH64D_01
C01-H / interne Parking-ID "20"

CLIENT_US_TKOT_AH64D_02
C05-H / interne Parking-ID 8

CLIENT_US_TKOT_CH47F_01
C07-H / interne Parking-ID 3
```

Diese Positionen werden für KI-Initialspawns gesperrt. Der Stringwert `"20"` wird vor der Laufzeitdiagnose nicht stillschweigend normalisiert.

## 10. AI-Parking-Status

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

Eine leere Liste bedeutet:

- keine positive KI-Parking-Abnahme;
- keine Ableitung aus sichtbaren Parkplatzlabels;
- keine AIRWING-/SQUADRON-Spawnfreigabe vor G6.

G4 bestätigt zusätzlich, dass `SQUADRON:SetParkingIDs()` die normale Terminaltyp- und Airbase-Black-/Whitelist-Prüfung umgehen kann. Positive SQUADRON-Parking-Listen bleiben deshalb bis nach der G6-Kalibrierung verboten.

## 11. Funktionszonen

Bereits vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Erforderlich, aber noch nicht angelegt:

```text
ZONE_AIR_US_TKOT_AH64_RAMP
ZONE_AIR_US_TKOT_UH60_RAMP
ZONE_AIR_US_TKOT_MEDEVAC_READY
ZONE_AIR_US_TKOT_CH47_READY
ZONE_AIR_US_TKOT_ROTARY_STAGING
ZONE_AIR_US_TKOT_LOGISTICS_LOAD
ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD
ZONE_AIR_US_TKOT_HELO_RECOVERY
ZONE_AIR_US_TKOT_TRANSIENT_FIXED_WING
ZONE_AIR_US_TKOT_FARP
```

`ZONE_AIR_US_TKOT_FARP` ist durch die offizielle September-2011-Evidenz zu Hot Refueling und Rapid Turnaround fachlich begründet.

Keine Zone darf durch Lua-Fallback-Koordinaten erfunden werden.

## 12. Zone-/Gate-Matrix

| Gate/Test | Erforderliche Zone | Regel |
|---|---|---|
| G5 read-only Diagnose | keine | vorhandene und fehlende Zonen nur protokollieren |
| G6 Parking-Kalibrierung | keine Funktionszone | Parking-Dump und isolierte Spawn-/Starttests verwenden |
| G7 AIRWING-/SQUADRON-Grundlage | keine Funktionszone | keine operative Mission auslösen |
| G8 AH-64-CAS | später separat festgelegter Ziel-/Testbereich | keine FARP- oder Transportzone erforderlich |
| G8 UH-60 Utility | `UH60_RAMP` oder `ROTARY_STAGING` | exakte Funktion vor Test festlegen |
| G8 UH-60 MEDEVAC-Paket | `MEDEVAC_READY`, `HELO_RECOVERY` | OMW-Paketlogik; keine native MOOSE-MEDEVAC-Automatik |
| G8 CH-47 Direct Transport | `CH47_READY`, `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | direkten AUFTRAG-Pfad isoliert prüfen |
| G8 CH-47 OPSTRANSPORT | `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | `OPSTRANSPORT:New` plus `COMMANDER:AddOpsTransport` |
| FARP-/Hot-Refuel-Test | `FARP` | eigene DCS-/MOOSE-Acceptance |
| Fixed-Wing-Transient-Test | `TRANSIENT_FIXED_WING` | vollständig zurückgestellt |

## 13. G4-Korrekturen für spätere Implementierung

### 13.1 UH-60

MOOSE 2.9.18 besitzt keinen eigenen landgestützten `MEDEVAC`-AUFTRAG. `AUFTRAG:NewRESCUEHELO(Carrier)` ist trägerbezogen.

Geeignete getrennt zu testende Primitive sind:

```text
LANDATCOORDINATE
TROOPTRANSPORT
CARGOTRANSPORT
FREIGHTTRANSPORT
GROUNDESCORT
```

### 13.2 CH-47 OPSTRANSPORT

`AUFTRAG:NewOPSTRANSPORT()` ist im exakten Artefakt auskommentiert und darf nicht aufgerufen werden.

Der gültige Pfad lautet:

```lua
local transport = OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
commander:AddOpsTransport(transport)
```

Die Carrier-SQUADRON benötigt `AUFTRAG.Type.OPSTRANSPORT`.

## 14. Gate-Status

| Gate | Status | Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | Branch, MIZ, MIZ-Hash und MOOSE-Hash dokumentiert |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | aktive Baseline und Quellenkritik konsolidiert |
| G2 Objektvertrag | `OWNER_ACCEPTED_BRANCH` | vollständiger Vertrag angenommen |
| G3 Mission Editor | `PARTIAL` | Kernobjekte vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `PASS_SOURCE_REVIEW` | exaktes Artefakt und relevante API-Pfade geprüft |
| G5 Read-only Diagnose | `AUTHORIZED_NOT_STARTED` | nächster zulässiger Implementierungsschritt |
| G6 Parking-Kalibrierung | `NOT_STARTED` | Allowlisten leer |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt bis G5/G6 |
| G8 direkter Dispatch/Transport | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/Operational Parking | `NOT_STARTED` | gesperrt |
| G10 Lifecycle/Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 15. G5-Freigabegrenze

G5 darf ausschließlich read-only protokollieren:

```text
MIZ-/Bundle-/MOOSE-Provenienz
AIRBASE:FindByID(9)
Runtime-Airbase-Name
GetID() und GetID(true)
Airbase-Kategorie und Koalition
vollständige Parking-Datensätze
TerminalID, TerminalType, ID0, TOAC und Free
Client-Gruppen und interne Parking-Werte einschließlich Datentyp
Warehouse-Anker und Eindeutigkeit
AI-Seeds, DCS-Typen und Templategrößen
Tarinkot-Statics
vorhandene und fehlende Funktionszonen
Namensduplikate und fehlende Pflichtobjekte
```

G5 darf nicht:

```text
AIRWING erzeugen
SQUADRON erzeugen
SetParkingIDs anwenden
Payloads registrieren
Assets anfordern oder spawnen
AUFTRAG erzeugen
COMMANDER erzeugen oder starten
OPSTRANSPORT erzeugen
CampaignState verändern
MIZ verändern
```
