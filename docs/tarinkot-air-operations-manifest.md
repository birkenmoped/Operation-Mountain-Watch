---
document_id: OMW-AIR-TKOT-MANIFEST
status: DRAFT
owning_policy: OMW-GOV-001
document_class: AIR_OPERATIONS_MANIFEST
authoritative_for:
  - accepted Tarinkot AIRWING and SQUADRON object contract on the active branch
  - Tarinkot unit and technical object naming derived from the safest available sources
  - accepted Tarinkot local aircraft inventory and representation limits
  - exact Tarinkot Mission Editor names for the audited source mission
  - Tarinkot warehouse-anchor, client-reservation, seed-template, static, parking, and zone contract
  - implementation gates before any Tarinkot runtime work
not_authoritative_for:
  - DCS runtime acceptance
  - final runtime parking suitability or parking allowlists
  - historical subordinate identities not explicitly supported by cited evidence
  - exact 2011 aircraft quantities beyond documented minimum presence
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_MOOSE_SOURCE_REVIEW_COMPLETE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
validated_in_dcs: false
object_contract_state: OWNER_ACCEPTED_BRANCH
moose_source_review_state: PASS_SOURCE_REVIEW
supersedes_on_merge:
  - Tarinkot object assumptions from docs/tarinkot-air-operations-baseline PR 40
  - Tarinkot Mission Editor assumptions based on OMW_Template(3).miz
  - generic Tarinkot AIRWING and SQUADRON names not derived from historical evidence
  - provisional UH-60 and CH-47 TF_ATTACK_ATTACHED names
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations Manifest and Object Contract

## 1. Zweck und Freigabegrenze

Dieses Dokument ist die aktive Tarinkot-Arbeitsbaseline auf PR #53. Es konsolidiert:

- den Eigentümerentscheid für den Zeitraum März bis Dezember 2011;
- die Juli-2011-ORBAT und zeitgenössische U.S.-Army-/DVIDS-Evidenz;
- die Tarinkot-Satellitenbeobachtungen und Mission-Editor-Audits;
- den vollständigen G2-Objektvertrag;
- die G4-Prüfung der exakt eingebetteten MOOSE-Version 2.9.18.

Der Vertrag wurde auf dem Branch ausdrücklich angenommen. Er ist nicht nach `main` gemergt und besitzt keine DCS-Runtime-Acceptance.

Weiterhin nicht autorisiert sind:

```text
Merge
Ready for Review
ungeprüfte AIRWING-/SQUADRON-Aktivierung
operative AUFTRAG- oder OPSTRANSPORT-Ausführung
MIZ-Änderungen ohne den vorgesehenen Gate-Schritt
```

## 2. Provenienz

```yaml
OMW_branch: agent/tarinkot-object-contract-reconciliation
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
mission_date: 2011-01-14
mission_date_controls_ORBAT: false
embedded_moose_path: l10n/DEFAULT/Moose.lua
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE_release: 2.9.18
```

Das Missionsdatum `14.01.2011` bleibt technische Kulisse. Die aktive Tarinkot-ORBAT wird durch den Eigentümerentscheid März bis Dezember 2011 bestimmt.

## 3. Historische Baseline

```text
Lokaler Aviation-Knoten:
Task Force Attack / 3-101 Attack Aviation

Übergeordnet:
Task Force Thunder / 159th Combat Aviation Brigade

AH-64:
Task Force Attack / 3-101 Attack Aviation

UH-60:
Task-Force-Attack-Komponente
administrative Company weiterhin offen

CH-47:
B Company, 1-52 Aviation Regiment
historisches Muster CH-47D
```

Frühere niederländische AH-64, C/5-101 „Phantoms“ und spätere 2012/2013-Rotationen bleiben Kontext, sind aber keine aktiven SQUADRON-Namen dieses Vertrags.

## 4. Technische Namen

```text
AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Veraltete oder verworfene Namen:

```text
AW_US_TARINKOT
SQ_US_TKOT_AH64D_ATTACK_DET
SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
SQ_US_TKOT_UH60_TF_ATTACK_ATTACHED
SQ_US_TKOT_CH47_HEAVYLIFT_DET
SQ_US_TKOT_CH47_TF_ATTACK_ATTACHED
```

## 5. Lokaler OMW-Nominalbestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Evidenzgrenze:

- AH-64-, UH-60- und CH-47-Präsenz 2011 ist bestätigt;
- B/1-52 als lokales CH-47D-Detachment ist bestätigt;
- die exakten Werte `14/6/2/0` bleiben eine quellennahe OMW-Rekonstruktion;
- die Werte werden aus dem RC-South-/Kandahar-Parent-Pool abgezogen und nicht doppelt gezählt.

## 6. Darstellungsledger

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

## 7. Mission-Editor-Vertrag

### 7.1 Airbase und Warehouse

```yaml
dcsAirdromeId: 9
runtimeAirbaseName: G5_READ_ONLY_DIAGNOSTIC_REQUIRED
warehouseAnchor: WH_AIR_US_TARINKOT
warehouseObjectType: container_20ft
warehouseUnitId: 1608
```

### 7.2 Clients

```text
CLIENT_US_TKOT_AH64D_01
C01-H / interner Parking-Wert "20"

CLIENT_US_TKOT_AH64D_02
C05-H / interner Parking-Wert 8

CLIENT_US_TKOT_CH47F_01
C07-H / interner Parking-Wert 3
```

Der Stringwert `"20"` wird vor G5 nicht stillschweigend normalisiert.

### 7.3 AI-Seeds

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
2 × AH-64D_BLK_II

TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
1 × UH-60A

TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
1 × CH-47Fbl1
```

Historische Abweichung:

```text
B/1-52 setzte 2011 CH-47D ein.
CH-47Fbl1 ist der dokumentierte DCS-Ersatz.
```

### 7.4 Registrierter KI-Bestand

```yaml
AH64:
  templateAircraftPerGroup: 2
  registeredGroups: 2
  grouping: 2
  maximumRegisteredAIAircraft: 4

UH60:
  templateAircraftPerGroup: 1
  registeredGroups: 2
  grouping: 1
  maximumRegisteredAIAircraft: 2
  seedReuse: SAME_ONE_SHIP_TEMPLATE_SOURCE_CONFIRMED

CH47:
  templateAircraftPerGroup: 1
  registeredGroups: 1
  grouping: 1
  maximumRegisteredAIAircraft: 1
```

## 8. Parking-Vertrag

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

G4 bestätigt:

- MOOSE-Parking-Listen verwenden interne `TerminalID`, nicht sichtbare ME-Labels;
- `allowSpawnOnClientSpots` ist im Warehouse standardmäßig `false`;
- Client-Template-Koordinaten werden bei der Parkplatzsuche als Hindernisse behandelt;
- `SetSafeParkingOn()` ist verfügbar;
- `SQUADRON:SetParkingIDs()` aktiviert einen asset-spezifischen Zweig, der die normale Terminaltyp- und Airbase-Black-/Whitelist-Prüfung umgeht.

Daraus folgt:

```text
keine positive SQUADRON-Parking-Liste vor G6
SetAllowSpawnOnClientParking() bleibt verboten
Client-, Static- und Rotorkonflikte müssen vor jeder positiven Liste ausgeschlossen sein
```

## 9. Funktionszonen

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

Regeln:

- keine Zone wird durch Lua-Fallback-Koordinaten erfunden;
- G5 protokolliert nur vorhanden/fehlend;
- zonenabhängige Tests bleiben bis zur jeweiligen ME-Anlage gesperrt;
- `ZONE_AIR_US_TKOT_FARP` ist durch die September-2011-Evidenz zu Hot Refueling und Rapid Turnaround fachlich begründet.

## 10. G4 – bestätigte MOOSE-Semantik

### 10.1 SQUADRON

```lua
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

`Ngroups` zählt Asset-Gruppen. `SetGrouping(n)` bestimmt getrennt die Einheiten pro Asset-Gruppe. Damit sind die angenommenen Tarinkot-Gruppierungen quellenkompatibel.

### 10.2 UH-60

Im exakten Artefakt existiert kein eigener landgestützter `MEDEVAC`-AUFTRAG.

```text
AUFTRAG:NewRESCUEHELO(Carrier)
```

ist trägerbezogen und darf nicht als Tarinkot-MEDEVAC verwendet werden.

Geeignete getrennt zu testende Primitive sind:

```text
LANDATCOORDINATE
TROOPTRANSPORT
CARGOTRANSPORT
FREIGHTTRANSPORT
GROUNDESCORT
```

Die Bezeichnung MEDEVAC Lead/Support ist OMW-Paketlogik, keine native MOOSE-MEDEVAC-Automatik.

### 10.3 CH-47 und OPSTRANSPORT

In MOOSE 2.9.18 ist:

```lua
AUFTRAG:NewOPSTRANSPORT(...)
```

vollständig auskommentiert und nicht aufrufbar.

Der gültige Pfad lautet:

```lua
local transport = OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
commander:AddOpsTransport(transport)
```

Die Carrier-SQUADRON benötigt `AUFTRAG.Type.OPSTRANSPORT`. Pickup- und Deploy-Zone müssen reale ZONE-Objekte sein; Cargo wird nur berücksichtigt, wenn es sich beim Laden in der Pickup-Zone befindet.

### 10.4 COMMANDER

Quellenbestätigt:

```text
COMMANDER:New
AddAirwing
AddMission
AddOpsTransport
CanMission
Start
```

Trennung:

```text
AUFTRAG → AddMission
OPSTRANSPORT → AddOpsTransport
```

Der vorhandene Jalalabad-PASS bestätigt Grundkonstruktion, AIRWING-Anbindung und Start für dasselbe MOOSE-Artefakt, nicht aber taktische Tarinkot-Missionen oder OPSTRANSPORT.

## 11. Gate-Matrix

| Gate/Test | Erforderliche Zone | Regel |
|---|---|---|
| G5 read-only Diagnose | keine | nur protokollieren; keine Runtime-Objekte erzeugen |
| G6 Parking-Kalibrierung | keine Funktionszone | Parking-Dump und isolierte Spawn-/Starttests |
| G7 AIRWING-/SQUADRON-Grundlage | keine Funktionszone | keine operative Mission auslösen |
| G8 AH-64-CAS | separat festgelegter Ziel-/Testbereich | kein Transport/FARP erforderlich |
| G8 UH-60 Utility | `UH60_RAMP` oder `ROTARY_STAGING` | Testvertrag vorher festlegen |
| G8 UH-60 MEDEVAC-Paket | `MEDEVAC_READY`, `HELO_RECOVERY` | OMW-Paketlogik, kein nativer MEDEVAC-AUFTRAG |
| G8 CH-47 Direct Transport | `CH47_READY`, `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | direkten AUFTRAG-Pfad isoliert prüfen |
| G8 CH-47 OPSTRANSPORT | `LOGISTICS_LOAD`, `LOGISTICS_UNLOAD` | `OPSTRANSPORT:New` plus `AddOpsTransport` |
| FARP-/Hot-Refuel-Test | `FARP` | eigene spätere Acceptance |
| Fixed-Wing-Transient-Test | `TRANSIENT_FIXED_WING` | zurückgestellt |

## 12. G0-bis-G10-Status

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | MIZ, Hash und eingebetteter MOOSE-Commit festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | aktive Baseline und Quellenkritik konsolidiert |
| G2 Objektvertrag | `OWNER_ACCEPTED_BRANCH` | vollständiger G2-Vertrag angenommen |
| G3 Mission Editor | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `PASS_SOURCE_REVIEW` | exaktes Artefakt und relevante API-Pfade geprüft |
| G5 Read-only Diagnose | `AUTHORIZED_NOT_STARTED` | nächster zulässiger Implementierungsschritt |
| G6 Parking-Kalibrierung | `NOT_STARTED` | keine positive AI-Allowlist |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt bis G5/G6 |
| G8 direkter Dispatch/Transport | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/Operational Parking | `NOT_STARTED` | gesperrt |
| G10 Lifecycle/Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 13. G5-Vertrag

Das nächste zulässige Bundle ist ausschließlich read-only. Es protokolliert:

```text
MIZ-/Bundle-/MOOSE-Provenienz
MOOSE-Commitzeile und Hash
AIRBASE:FindByID(9)
Runtime-Airbase-Name
GetID() und GetID(true)
Kategorie und Koalition
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
AIRWING oder SQUADRON erzeugen
SetParkingIDs anwenden
Payloads registrieren
Assets anfordern oder spawnen
AUFTRAG erzeugen
COMMANDER erzeugen oder starten
OPSTRANSPORT erzeugen
CampaignState verändern
MIZ verändern
```
