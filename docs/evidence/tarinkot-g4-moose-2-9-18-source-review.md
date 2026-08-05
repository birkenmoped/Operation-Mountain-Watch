---
document_id: OMW-EVIDENCE-TARINKOT-G4-MOOSE-2-9-18-SOURCE-REVIEW
status: BINDING
document_class: MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G4 source-level review against the exact embedded MOOSE artifact
  - source-confirmed SQUADRON group-count and grouping semantics
  - source-confirmed AIRWING, warehouse and parking behavior relevant to Tarinkot
  - source-qualified UH-60 mission-type limits and CH-47 OPSTRANSPORT integration path
  - authorization boundary for the subsequent read-only G5 diagnostic bundle
not_authoritative_for:
  - DCS runtime acceptance
  - final parking allowlists
  - successful AUFTRAG or OPSTRANSPORT execution in Tarinkot
  - final lifecycle, loss, return or stranded-state behavior
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_path: l10n/DEFAULT/Moose.lua
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_lines: 261036
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_commit_timestamp: 2026-06-14T16:11:05+02:00
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot – G4-Prüfung der eingebundenen MOOSE-Version 2.9.18

## 1. Ergebnis

```yaml
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
runtime_acceptance: false
Tarinkot_runtime_Lua_created: false
MIZ_modified: false
next_gate: G5_READ_ONLY_DIAGNOSTICS
```

Die G4-Prüfung bestätigt die technische Umsetzbarkeit des angenommenen Tarinkot-G2-Vertrags auf Quellenebene. Sie enthält noch keinen DCS-Laufzeitnachweis.

Vier Ergebnisse sind für die weitere Implementierung besonders relevant:

1. `SQUADRON:New(..., Ngroups, ...)` zählt Asset-Gruppen und nicht einzelne Luftfahrzeuge.
2. Ein einzelnes One-Ship-Template kann durch `Ngroups = 2` zwei getrennte One-Ship-Asset-Gruppen erzeugen.
3. MOOSE 2.9.18 besitzt keinen eigenständigen landgestützten `MEDEVAC`-AUFTRAG; `RESCUEHELO` ist trägerbezogen.
4. `AUFTRAG:NewOPSTRANSPORT()` ist im eingebetteten Artefakt auskommentiert. Für CH-47-OPS-Transport ist `OPSTRANSPORT:New()` zusammen mit `COMMANDER:AddOpsTransport()` zu verwenden.

## 2. Geprüfte Provenienz

### 2.1 Tatsächlich eingebettetes Artefakt

```text
Mission:
OMW_Template_v5_Salerno.miz

Mission SHA-256:
203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5

MOOSE-Pfad in der MIZ:
l10n/DEFAULT/Moose.lua

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Zeilen:
261036
```

Die erste Artefaktzeile nennt:

```text
MOOSE GITHUB Commit Hash ID:
2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

### 2.2 Zugeordneter offizieller Quellstand

```text
Repository:
FlightControl-Master/MOOSE

Commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Commit-Zeit:
2026-06-14T14:11:05Z

Commit-Nachricht:
Merge remote-tracking branch 'origin/master-ng' into develop
```

Die Zuordnung stimmt mit dem bereits dokumentierten, identischen Jalalabad-Artefaktnachweis überein.

## 3. SQUADRON- und Asset-Gruppen-Semantik

### 3.1 Konstruktor

Im exakten Quellstand lautet die Signatur:

```lua
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

`Ngroups` ist ausdrücklich die Anzahl der Asset-Gruppen des SQUADRON. Der Konstruktor delegiert an:

```lua
COHORT:New(TemplateGroupName, Ngroups, SquadronName)
```

`COHORT:New()` setzt:

```lua
self.Ngroups = Ngroups or 3
```

### 3.2 Hinzufügen zum AIRWING

`AIRWING:AddSquadron()` ruft auf:

```lua
self:AddAssetToSquadron(Squadron, Squadron.Ngroups)
```

Damit wird das Mission-Editor-Template `Ngroups`-mal als eigenständige Asset-Gruppe registriert.

Die Anzahl der Einheiten innerhalb jeder Asset-Gruppe wird getrennt behandelt:

- ohne `SetGrouping()` bleibt die Gruppengröße des Templates erhalten;
- mit `SetGrouping(n)` setzt MOOSE jede registrierte Asset-Gruppe auf `n` Einheiten;
- zulässig sind ein bis vier Einheiten je Gruppe.

### 3.3 Tarinkot-Folgerung

Der angenommene G2-Bestand ist damit quellenkompatibel:

```yaml
AH64:
  template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
  template_units: 2
  Ngroups: 2
  grouping: 2
  registered_AI_aircraft: 4

UH60:
  template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
  template_units: 1
  Ngroups: 2
  grouping: 1
  registered_AI_aircraft: 2

CH47:
  template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
  template_units: 1
  Ngroups: 1
  grouping: 1
  registered_AI_aircraft: 1
```

Für die Implementierung wird die Gruppengröße jeweils ausdrücklich gesetzt. Dadurch hängt sie nicht implizit vom unveränderten Template ab.

## 4. AIRWING- und Warehouse-Verhalten

### 4.1 AIRWING-Konstruktion

```lua
AIRWING:New(warehousename, airwingname)
```

Der erste Parameter muss den Namen eines vorhandenen Static- oder Unit-Warehouse-Ankers enthalten. Ein nicht gefundener Anker führt zu `nil`.

Für Tarinkot bleibt daher verbindlich:

```text
WH_AIR_US_TARINKOT
```

### 4.2 Airbase-Zuordnung

Der Warehouse-Konstruktor versucht zunächst, die nächstgelegene gleichkoalitionäre Airbase innerhalb von fünf Kilometern automatisch zuzuordnen.

Für Tarinkot wird diese Heuristik nicht als Vertragsgrundlage verwendet. G5 muss Airbase-ID 9 über MOOSE auflösen und protokollieren. Erst ein späterer AIRWING-Test darf die ermittelte `AIRBASE`-Instanz explizit übergeben:

```lua
Airwing:SetAirbase(Airbase)
```

### 4.3 Startverhalten

Der Jalalabad-Nachweis zeigt für dasselbe MOOSE-Artefakt folgende akzeptierte Grundreihenfolge:

```text
alle Objekte validieren
AIRWING starten
COMMANDER erstellen
AIRWING an COMMANDER anbinden
COMMANDER starten
keine Mission einreihen
```

Dieser Nachweis gilt nur für Konstruktion, Verknüpfung und Grundstart. Er beweist keine Tarinkot-Mission und keine Transportausführung.

## 5. Parking-Verhalten

### 5.1 Unterschied zwischen Parkplatzlabel und MOOSE-Terminal-ID

MOOSE verwendet für Parking-Listen die interne `TerminalID`. Diese ist nicht mit dem sichtbaren Mission-Editor-Parkplatzlabel gleichzusetzen.

Daher bleiben die Tarinkot-Listen bis G6 leer:

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

### 5.2 Client-Positionen

Der Warehouse-Konstruktor setzt standardmäßig:

```lua
allowSpawnOnClientSpots = false
```

Bei der Parkplatzsuche übernimmt MOOSE die Koordinaten aller Client-Templates als Hindernisse. Dadurch werden Client-Positionen auch ohne besetzten Spielerslot bei der Sicherheitsprüfung berücksichtigt.

Die G7-/G8-Konfiguration ruft zusätzlich auf:

```lua
SetSafeParkingOn()
```

Korrektur aus der vollständigen G8-Parking-Recherche vom 5. August 2026:

```text
SetSafeParkingOn() setzt self.safeparking=true.
Warehouse.lua liest dieses Feld im gepinnten Stand jedoch nirgends.
Der Aufruf aktiviert deshalb im geprüften Quellpfad keine nachweisbare
zusätzliche Client-, Reservierungs- oder Static-Prüfung.
```

Die Client-Hindernisse entstehen unabhängig davon allein über `allowSpawnOnClientSpots=false`. Vollständiger Nachweis:

- [`OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH`](../moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

Für Tarinkot gilt:

```text
SetAllowSpawnOnClientParking() darf nicht verwendet werden.
```

### 5.3 Blacklist und positive SQUADRON-Parking-IDs

`AIRBASE:_CheckParkingLists()` wertet zuerst die Blacklist und danach die Whitelist aus. Eine Blacklist-Sperre hat damit Vorrang.

Allerdings besitzt `SQUADRON:SetParkingIDs()` eine wichtigere Sonderwirkung:

```text
Wenn asset.parkingIDs gesetzt ist,
verwendet WAREHOUSE:_FindParkingForAssets() ausschließlich die asset-spezifische Prüfung.
Die normale Terminaltyp-, Warehouse- und AIRBASE-Black-/Whitelist-Prüfung wird in diesem Zweig umgangen.
```

Daraus folgt:

- vor G6 keine positive SQUADRON-Parking-Liste setzen;
- jede spätere positive Liste muss Client-, Static- und Größenkonflikte bereits ausschließen;
- die drei Client-Reservierungen müssen in G5 mit tatsächlicher Runtime-`TerminalID` und Datentyp protokolliert werden;
- der Missionswert `"20"` wird vor diesem Dump nicht stillschweigend in eine Zahl umgewandelt.

## 6. UH-60 – Utility und MEDEVAC

### 6.1 Kein nativer landgestützter MEDEVAC-AUFTRAG

Im exakten Artefakt existiert kein `AUFTRAG.Type.MEDEVAC` und kein `AUFTRAG:NewMEDEVAC()`.

`AUFTRAG:NewRESCUEHELO(Carrier)` ist nicht die gesuchte Funktion. Der Konstruktor verlangt eine Carrier-Unit und bildet den trägergebundenen Rescue-Helo-Dienst ab.

### 6.2 Geeignete vorhandene Missionstypen

Für einen kontrollierten ersten UH-60-Test sind vorhanden:

```text
AUFTRAG.Type.LANDATCOORDINATE
AUFTRAG.Type.TROOPTRANSPORT
AUFTRAG.Type.CARGOTRANSPORT
AUFTRAG.Type.FREIGHTTRANSPORT
AUFTRAG.Type.GROUNDESCORT
```

Grenzen:

- `TROOPTRANSPORT` benötigt eine reale `GROUP` oder `SET_GROUP` als zu transportierende Kräfte sowie Pickup-/Dropoff-Koordinaten;
- `CARGOTRANSPORT` ist externer Slingload und benötigt eine im Mission Editor angelegte Drop-Zone mit DCS-Zonen-ID;
- `FREIGHTTRANSPORT` ist interner Static-Cargo-Transport zu einer AIRBASE; der Quellcode prüft keine Gewichtsgrenzen;
- `LANDATCOORDINATE` ist für einen isolierten Bewegungs-/Lande-Nachweis geeignet, beweist aber keine medizinische Evakuierung.

### 6.3 Tarinkot-Testmodell

Die zwei UH-60-One-Ships können als zwei unabhängige Asset-Gruppen registriert werden. Die semantische Zuordnung als:

```text
MEDEVAC Lead
Support Aircraft
```

ist jedoch OMW-Paketlogik und keine native MOOSE-MEDEVAC-Funktion.

Daher gilt für G8:

1. zuerst einzelner `LANDATCOORDINATE`- oder klar definierter `TROOPTRANSPORT`-Test;
2. danach ein separat dokumentierter Zwei-One-Ship-Pakettest;
3. keine Behauptung einer nativen MOOSE-MEDEVAC-Automatik.

## 7. CH-47 – Transport und OPSTRANSPORT

### 7.1 Direkte AUFTRAG-Transporttypen

Für den CH-47 sind dieselben direkten Missionstypen verfügbar:

```text
TROOPTRANSPORT
CARGOTRANSPORT
FREIGHTTRANSPORT
LANDATCOORDINATE
```

Sie werden getrennt von `OPSTRANSPORT` getestet.

### 7.2 Kritische API-Grenze

Im eingebetteten Artefakt steht zwar Quelltext für:

```lua
AUFTRAG:NewOPSTRANSPORT(...)
```

Der gesamte Konstruktor befindet sich aber innerhalb eines Lua-Blockkommentars:

```lua
--[[
function AUFTRAG:NewOPSTRANSPORT(...)
  ...
end
]]
```

Diese Methode ist in MOOSE 2.9.18 daher nicht aufrufbar und darf im Tarinkot-Code nicht verwendet werden.

### 7.3 Gültiger OPS-Transportpfad

Der eigenständige Konstruktor ist aktiv:

```lua
OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
```

Der Transport wird beim COMMANDER separat eingereiht:

```lua
Commander:AddOpsTransport(Transport)
```

Die Carrier-SQUADRON benötigt dafür die Capability:

```lua
AUFTRAG.Type.OPSTRANSPORT
```

`OPSTRANSPORT` verlangt echte ZONE-Objekte. Cargo wird beim Laden nur berücksichtigt, wenn es sich zu diesem Zeitpunkt in der Pickup-Zone befindet.

Für Tarinkot bleiben deshalb zwingend:

```text
ZONE_AIR_US_TKOT_LOGISTICS_LOAD
ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD
```

### 7.4 Abgrenzung zum Jalalabad-Nachweis

Der vorhandene Jalalabad-CH-47-Aufbau registriert:

```text
TROOPTRANSPORT
CARGOTRANSPORT
LANDATCOORDINATE
```

Er registriert dort nicht `OPSTRANSPORT` und ist deshalb kein Laufzeitnachweis für den Tarinkot-OPS-Transportpfad.

## 8. COMMANDER

Quellenbestätigt sind:

```lua
COMMANDER:New(Coalition, Alias)
COMMANDER:AddAirwing(Airwing)
COMMANDER:AddMission(Mission)
COMMANDER:AddOpsTransport(Transport)
COMMANDER:CanMission(Mission)
COMMANDER:Start()
```

Wichtige Trennung:

```text
AUFTRAG-Missionen → AddMission()
OPSTRANSPORT       → AddOpsTransport()
```

`CanMission()` prüft verfügbare Legions/Cohorts, Capabilities, Zielbezug und bei Transportbedarf verfügbare Cargo-Bay-Grenzen. Das ist Quellenverhalten und noch kein Tarinkot-Runtime-PASS.

## 9. Lifecycle

Der exakte Quellstand enthält Event- und FSM-Pfade für:

- Spawn und Entfernung des Assets aus dem Warehouse-Bestand;
- Engine Start und Takeoff;
- Landung und Shutdown;
- Rückgabe eines Assets an Warehouse und Cohort;
- Crash, Unit Lost und Asset Dead;
- Parking-Reservierung und -Freigabe;
- RTB und Landung an einer AIRBASE.

Diese Pfade begründen das spätere G10-Testprogramm, gelten aber nicht als akzeptiertes Verhalten für Tarinkot. Insbesondere müssen getrennt getestet werden:

```text
normale Rückkehr
Despawn nach Landung oder Holding
Verlust einer Teilmaschine aus einem 2-Ship
vollständiger Gruppenverlust
abgebrochene oder gestrandete Mission
Parking-Freigabe
Ledger-Rückführung
```

## 10. Entscheidungen für die nachfolgenden Gates

### 10.1 Quellenbestätigt

```yaml
UH60_one_ship_seed_reuse_for_two_groups: CONFIRMED_BY_SOURCE
AH64_two_ship_template_times_two_groups: CONFIRMED_BY_SOURCE
CH47_one_ship_one_group: CONFIRMED_BY_SOURCE
AIRWING_warehouse_anchor_model: CONFIRMED_BY_SOURCE
explicit_airbase_assignment: SUPPORTED
safe_parking: SUPPORTED
client_template_obstacle_protection: SUPPORTED
COMMANDER_basic_linkage: SUPPORTED_AND_PREVIOUSLY_VALIDATED_FOR_JALALABAD_SCOPE
```

### 10.2 Korrigiert oder eingeschränkt

```yaml
native_land_based_MEDEVAC_AUFTRAG: NOT_AVAILABLE
AUFTRAG_NewOPSTRANSPORT: NOT_CALLABLE_COMMENTED_OUT
standalone_OPSTRANSPORT_plus_COMMANDER_queue: REQUIRED_PATH
positive_squadron_parking_IDs_before_G6: FORBIDDEN
Jalalabad_CH47_as_OPSTRANSPORT_proof: NOT_VALID
```

### 10.3 Weiterhin laufzeitoffen

```yaml
Tarinkot_airbase_runtime_name: G5
Tarinkot_parking_terminal_IDs_and_types: G5_G6
rotor_clearance_and_taxi_start: G6
AIRWING_SQUADRON_payload_start: G7
AH64_CAS_dispatch: G8
UH60_utility_and_package_behavior: G8
CH47_direct_transport: G8
CH47_OPSTRANSPORT: G8
COMMANDER_selection: G9
return_loss_stranding_ledger: G10
```

## 11. G5-Vertrag

G5 darf nun als isoliertes read-only Diagnosebundle erstellt werden.

Es muss protokollieren:

```text
OMW-Branch-/Bundle-/MIZ-/MOOSE-Provenienz
MOOSE-Commitzeile und MOOSE-Hash
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

G5 darf weiterhin nicht:

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

## 12. Gate-Status nach G4

| Gate | Status | Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | MIZ und eingebettetes MOOSE-Artefakt identifiziert |
| G1 ORBAT/Evidenz | `PASS_BRANCH` | aktive historische Baseline konsolidiert |
| G2 Objektvertrag | `OWNER_ACCEPTED_BRANCH` | vollständiger Vertrag angenommen |
| G3 Mission Editor | `PARTIAL` | Kernobjekte vorhanden; Funktionszonen fehlen |
| G4 MOOSE-Quellenprüfung | `PASS_SOURCE_REVIEW` | exakter Commit, Quellen und relevante API-Pfade geprüft |
| G5 Read-only Diagnose | `AUTHORIZED_NOT_STARTED` | nächster zulässiger Implementierungsschritt |
| G6 Parking-Kalibrierung | `NOT_STARTED` | positive Listen bleiben leer |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt bis G5/G6 |
| G8 direkter Dispatch/Transport | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/Operational Parking | `NOT_STARTED` | gesperrt |
| G10 Lifecycle/Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |
