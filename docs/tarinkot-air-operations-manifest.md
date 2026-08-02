---
document_id: OMW-AIR-TKOT-MANIFEST
status: PROPOSED_BINDING_OBJECT_CONTRACT
owning_policy: OMW-GOV-001
document_class: AIR_OPERATIONS_MANIFEST
authoritative_for:
  - proposed Tarinkot AIRWING and SQUADRON object contract
  - Tarinkot unit and technical object naming derived from the July 2011 ORBAT
  - proposed Tarinkot local aircraft inventory and representation limits
  - exact Tarinkot Mission Editor names for the audited source mission
  - Tarinkot warehouse-anchor, client-reservation, seed-template, static, and zone contract
  - implementation gates before any Tarinkot Lua runtime work
not_authoritative_for:
  - DCS runtime acceptance
  - untested MOOSE API behavior
  - runtime parking suitability or final parking selection
  - historical subordinate unit identities not explicitly supported by cited evidence
  - project-wide binding effect before merge to main or explicit owner decision
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
supersedes_on_merge:
  - Tarinkot object assumptions from docs/tarinkot-air-operations-baseline PR 40
  - Tarinkot Mission Editor assumptions based on OMW_Template(3).miz
  - generic Tarinkot AIRWING and SQUADRON names not derived from the July 2011 ORBAT
---

# Tarinkot Air Operations Manifest and Object Contract

## 1. Zweck und Freigabegrenze

Dieses Dokument konsolidiert den Tarinkot-Objektvertrag gegen:

- den aktuellen Stand von `main`;
- die verbindliche historische Juli-2011-ORBAT;
- den älteren Tarinkot-Dokumentationsbranch;
- die aktuelle Missionsdatei `OMW_Template_v5_Salerno.miz`;
- die verbindliche airfield-spezifische G0-bis-G10-Arbeitsweise.

Der Vertrag besitzt erst nach Merge nach `main` oder einer ausdrücklichen Eigentümerentscheidung projektweite normative Wirkung.

Bis zur Annahme dieses Vertrags gilt:

```text
KEINE TARINKOT-LUA-IMPLEMENTIERUNG
```

## 2. Verbindliche Quellen- und Benennungsregel

### 2.1 Standardautorität für Verbandsnamen

Für Tarinkot und grundsätzlich für die aktive OMW-ORBAT gilt:

```text
Die Afghanistan Order of Battle vom Juli 2011 ist die Standardautorität
für Einheit, Parent, Task-Force-Zuordnung sowie AIRWING- und SQUADRON-Namen.
```

Davon darf nur abgewichen werden, wenn eine bessere und sicherere Quelle vorliegt, die für denselben Standort, Zeitraum und Gegenstand spezifischer oder höherrangig ist, insbesondere:

- offizielle zeitgenössische militärische Unterlagen;
- belastbare Unit-History oder Deployment Order;
- eindeutig datierte Primärquelle mit Standort- und Verbandsbezug;
- mehrere voneinander unabhängige, übereinstimmende hochwertige Quellen.

Eine Abweichung muss dokumentiert und begründet werden.

Nicht ausreichend, um eine ORBAT-Einheitszuordnung zu ersetzen, sind allein:

- Mission-Editor-Objektnamen;
- Satellitenbilder ohne eindeutige Verbandsidentifikation;
- DCS-Typverfügbarkeit;
- generische technische Begriffe wie `DET`, `UTILITY` oder `HEAVYLIFT`;
- Vermutungen aus dem Parent-Hub Kandahar.

Mission Editor und Bildquellen bestimmen physische Darstellung, Typen, Mengen und räumliche Anordnung. Sie bestimmen nicht automatisch den historischen Verbandsnamen.

### 2.2 Juli-2011-ORBAT für Tarinkot

Die projektinterne Juli-2011-ORBAT nennt für den Standort:

```text
Task Force Attack / 3-101 Attack Aviation
Standort: FOB Tarin Kowt
Auftrag: Aviation Support Uruzgan
```

Quelle:

- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md), Abschnitt `11.7 TF Thunder - Aviation RC South`.

Damit ist `Task Force Attack / 3-101 Attack Aviation` die verbindliche historische Parent-Identität für den Tarinkot-Aviation-Knoten, solange keine bessere Quelle vorliegt.

Die ORBAT nennt keine vollständige lokale Typen- oder Stückzahlliste und löst die vor Ort erkennbaren UH-60- und CH-47-Unterelemente nicht bis zu einer eigenen Company oder einem gesonderten Battalion auf.

Daraus folgt:

- AH-64 wird direkt als `3-101 Attack Aviation` benannt;
- UH-60 und CH-47 werden als an `Task Force Attack` angegliederte technische Pools benannt;
- UH-60 und CH-47 werden nicht ohne Quelle als organische Bestandteile des Attack-Battalions behauptet;
- es werden keine fremden Kandahar- oder Wolverine-Verbände nach Tarinkot übertragen;
- generische, vom ORBAT-Parent losgelöste `*_DET`-SQUADRON-Namen sind nicht zulässig.

### 2.3 Mission-Editor-Iststand

Aktuelle strukturelle Evidenz:

- [`OMW-EVIDENCE-TARINKOT-ME-AUDIT-OMW-TEMPLATE-V5-SALERNO`](evidence/tarinkot-mission-editor-audit-omw-template-v5-salerno.md)

Exakte Quellmission:

```text
OMW_Template_v5_Salerno.miz
SHA-256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
```

## 3. Fester Standort-, Parent- und AIRWING-Vertrag

```yaml
locationCode: TKOT
displayName: Tarinkot / Tarin Kowt / Camp Holland
dcsAirdromeId: 9
historicalParent: Task Force Attack / 3-101 Attack Aviation
airwingName: AW_US_TKOT_TF_ATTACK_3_101_AVN
warehouseAnchorName: WH_AIR_US_TARINKOT
```

### 3.1 Airbase-Auflösung

Die technische Identität des Flugplatzes ist `airdromeId = 9`.

Noch diagnostisch zu ermitteln:

```text
AIRBASE.Afghanistan.<exakte Konstante>
MOOSE runtime GetName()-Ergebnis
```

Es darf kein Name geraten und keine andere Airbase als Fallback verwendet werden.

### 3.2 Ein AIRWING

Tarinkot erhält genau einen lokalen AIRWING:

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
Historical label: Task Force Attack / 3-101 Attack Aviation
```

Nicht mehr zu verwenden:

```text
AW_US_TARINKOT
```

Nicht zulässig:

```text
zweiter AIRWING am selben Tarinkot-Bestand
separater MEDEVAC-AIRWING
separater CH-47-AIRWING
lokaler Fixed-Wing-AIRWING
```

Der AIRWING-Name folgt der Juli-2011-ORBAT. Er beschreibt den lokalen OMW-Aviation-Führungsknoten. Er behauptet nicht, dass jedes angegliederte Luftfahrzeug organisch zum 3-101 Attack Aviation Battalion gehörte.

## 4. Fester SQUADRON-Vertrag

### 4.1 AH-64D

```yaml
squadronName: SQ_US_TKOT_AH64D_3_101_AVN
historicalLabel: Task Force Attack / 3-101 Attack Aviation
template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
templateAircraftPerGroup: 2
registeredGroups: 2
maximumRegisteredAIAircraft: 4
clientReservationsMaximum: 2
staticRepresentation: 8
nominalInventory: 14
initialMissionCapability: CAS
packageSize: 2
```

Nicht mehr zu verwenden:

```text
SQ_US_TKOT_AH64D_ATTACK_DET
```

### 4.2 UH-60

```yaml
squadronName: SQ_US_TKOT_UH60_TF_ATTACK_ATTACHED
historicalLabel: Task Force Attack attached UH-60 support element
historicalParentAuthority: July 2011 ORBAT - Task Force Attack / 3-101 Attack Aviation at FOB Tarin Kowt
subordinateUnitIdentity: unresolved
template: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
templateAircraftPerGroup: 1
registeredGroups: 2
maximumRegisteredAIAircraft: 2
clientReservationsMaximum: 0
staticRepresentation: 4
nominalInventory: 6
initialMissionCapability:
  - MEDEVAC
  - UTILITY
```

Der Name leitet sich vom belegten Tarinkot-Parent `Task Force Attack` ab. `ATTACHED` kennzeichnet ausdrücklich, dass die Juli-2011-ORBAT keinen eigenen lokalen UH-60-Unterverband benennt und keine organische Zuordnung zum Attack-Battalion behauptet wird.

Nicht mehr zu verwenden:

```text
SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
```

Der aktuelle Mission Editor enthält einen 1-Ship-Seed. Zielvertrag:

```text
2 MOOSE-Gruppen aus demselben 1-Ship-Seed
1 gemeinsamer Sechserbestand
keine zweite unabhängige Bestandsquelle
```

Dieser Mechanismus ist vor Implementierung in MOOSE 2.9.18 zu prüfen.

MEDEVAC-Paketvertrag:

```text
Lead:    1 × UH-60A
Support: 1 × UH-60A
atomare Reservierung: 2 Airframes
```

Beide aktuellen Seed-Abbilder sind unbewaffnet. Der zweite Hubschrauber wird als `Support` und nicht als unbelegter bewaffneter Cover bezeichnet.

Nicht vorhandene und nicht zu verwendende Seed-Namen:

```text
TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP
```

### 4.3 CH-47

```yaml
squadronName: SQ_US_TKOT_CH47_TF_ATTACK_ATTACHED
historicalLabel: Task Force Attack attached CH-47 support element
historicalParentAuthority: July 2011 ORBAT - Task Force Attack / 3-101 Attack Aviation at FOB Tarin Kowt
subordinateUnitIdentity: unresolved
template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
templateAircraftPerGroup: 1
registeredGroups: 1
maximumRegisteredAIAircraft: 1
clientReservationsMaximum: 1
staticRepresentation: 0
nominalInventory: 2
initialMissionCapability:
  - HEAVYLIFT
  - TROOP_TRANSPORT
  - LOGISTICS_TRANSPORT
```

Der Name leitet sich vom belegten lokalen ORBAT-Parent ab. `ATTACHED` verhindert die unbelegte Behauptung, dass die CH-47 organisch zu 3-101 Attack Aviation gehörten.

Nicht mehr zu verwenden:

```text
SQ_US_TKOT_CH47_HEAVYLIFT_DET
```

Der aktuelle Seed und der Client verwenden `CH-47Fbl1`. Es wird kein zweiter Client oder Static erfunden.

### 4.4 Nicht anzulegen

```text
SQ_US_TKOT_OH58D_*
permanente lokale Fixed-Wing-SQUADRON
zusätzliche Rollen-SQUADRONs für dieselben Airframes
SQUADRON-Namen aus Kandahar TF Lift / 7-101 GSAB ohne Tarinkot-spezifischen Nachweis
SQUADRON-Namen aus FOB Wolverine TF Wings / 4-101 Assault Aviation
```

## 5. Logischer Bestand und Darstellungsledger

### 5.1 Nominaler lokaler Bestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Diese Werte sind eine vorbereitete OMW-Rekonstruktion. Die Juli-2011-ORBAT autorisiert den Parent und Standort, nicht diese vollständige Stückzahlliste.

### 5.2 Maximale gleichzeitige Darstellung

| Musterfamilie | Statics | aktive Clients maximal | aktive KI maximal | Summe |
|---|---:|---:|---:|---:|
| AH-64 | 8 | 2 | 4 | 14 |
| UH-60 | 4 | 0 | 2 | 6 |
| CH-47 | 0 | 1 | 1 | 2 |
| OH-58D | 0 | 0 | 0 | 0 |

### 5.3 Verbindliche Invariante

```text
sichtbare Statics
+ aktive Client-Luftfahrzeuge
+ aktive KI-Luftfahrzeuge
+ bestätigte Wartungs-/Stranded-Zustände
<= verbleibender lokaler Bestand je Musterfamilie
```

Dabei gilt:

- unbelegte Client-Slots sind keine aktiven Luftfahrzeuge;
- Late-Activation-Seeds sind kein zusätzlicher Bestand;
- SQUADRON-Gruppenzahl und Luftfahrzeugzahl sind getrennt;
- Verlust, Wartung und Stranding reduzieren denselben lokalen Ledger;
- Tarinkot darf nicht zusätzlich im Kandahar-Lokalbestand gezählt werden.

### 5.4 Regionalpool-Abgrenzung

```text
Tarinkot != Kandahar Heliport
Task Force Attack / 3-101 AVN != Task Force Guns / 4-227 AVN
Tarinkot-Bestand darf nicht als Kandahar-SQUADRON registriert werden
```

## 6. Mission-Editor-Objektvertrag

### 6.1 Clients

```text
CLIENT_US_TKOT_AH64D_01
└── CLIENT_US_TKOT_AH64D_01_UNIT_01
    DCS type: AH-64D_BLK_II
    Label: C01-H
    internal parking value: "20"

CLIENT_US_TKOT_AH64D_02
└── CLIENT_US_TKOT_AH64D_02_UNIT_01
    DCS type: AH-64D_BLK_II
    Label: C05-H
    internal parking value: 8

CLIENT_US_TKOT_CH47F_01
└── CLIENT_US_TKOT_CH47F_01_UNIT_01
    DCS type: CH-47Fbl1
    Label: C07-H
    internal parking value: 3
```

### 6.2 AI-Seeds

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
├── TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_01
└── TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_02

TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
└── TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP_UNIT_01

TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
└── TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP_UNIT_01
```

Alle Seeds sind Late Activation, kontrolliert, ohne Parking-ID und beginnen an einem Turning Point. Sie sind noch keine akzeptierten Parking-Starts.

### 6.3 Statics

```text
STATIC_AIR_US_TKOT_AH64_01 bis _08
STATIC_AIR_US_TKOT_UH60_UTILITY_01 bis _03
STATIC_AIR_US_TKOT_UH60_MEDEVAC_01
```

`STATIC_AIR_US_TKOT_AH64_07` verwendet `AH-64D` statt `AH-64D_BLK_II`. Diese statische Typabweichung wird nicht auf das KI-Template übertragen.

## 7. Payload- und Capability-Vertrag

### 7.1 AH-64D CAS

Aktuelle Baseline je Luftfahrzeug:

```text
2 × M261 mit M151 HE
2 × AGM-114K
IAFS_ComboPak_100
25 Prozent Gun
```

Initiale Capability:

```text
CAS als 2-Ship
```

### 7.2 UH-60

```text
UH-60A
keine Pylonen
Capabilities: MEDEVAC, UTILITY
```

### 7.3 CH-47F

```text
CH-47Fbl1
PORT M60D
STARBOARD M60D
Capabilities: HEAVYLIFT, TROOP_TRANSPORT, LOGISTICS_TRANSPORT
```

Transportsteuerung ist MOOSE-first, insbesondere gegen `OPSTRANSPORT`, zu prüfen.

## 8. Warehouse-Vertrag

```yaml
name: WH_AIR_US_TARINKOT
type: container_20ft
unitId: 1608
groupId: 1521
x: -149179.91252612
y: -30960.324668625
```

Spätere Runtime-Fail-fast-Regeln:

- exakt ein Objekt dieses Namens;
- keine Ersatzsuche nach beliebigen Containern oder Gebäuden;
- keine historische Lagerbezeichnung ohne Evidenz;
- keine CampaignState-Ableitung aus unbegrenzten nativen DCS-Warehouse-Werten;
- kein AIRWING-Start bei fehlendem oder mehrfach gefundenem Anker.

## 9. Parking-Vertrag

### 9.1 Harte Client-Reservierungen

```text
C01-H / interne ID 20
C05-H / interne ID 8
C07-H / interne ID 3
```

### 9.2 AI-Allowlist

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

`C01-H` bis `C21-H`, `K01` bis `K09` und `G01` bis `G03` sind keine bestätigte Kapazität.

Erforderliche Reihenfolge:

1. read-only AIRBASE-/Parking-Dump;
2. Abgleich gegen Clients und Statics;
3. typweise Positiv-Allowlist;
4. isolierte Spawn-/Startkalibrierung;
5. erst danach AIRWING-/SQUADRON-Parking-Policy.

## 10. Zonenvertrag

Vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Nicht vorhanden und vor funktionsabhängiger Nutzung im Mission Editor anzulegen:

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
```

Kein Lua-Fallback mit erfundenen Koordinaten ist zulässig.

## 11. MOOSE-first-Prüfauftrag

Vor Tarinkot-Lua sind an der tatsächlich eingebundenen MOOSE-Version 2.9.18 und dem exakten Artefakt mindestens zu prüfen:

```text
AIRBASE
  Namens- und ID-Auflösung
  Parking-Datenzugriff
  Parking-Blacklist

AIRWING
  New
  SetAirbase
  SetTakeoffCold
  SetSafeParkingOn
  AddSquadron
  NewPayload
  Start

SQUADRON
  New
  Gruppenzählung für 2-Ship- und 1-Ship-Seeds
  Wiederverwendung eines 1-Ship-Seeds für zwei Gruppen
  SetGrouping
  AddMissionCapability
  Parking-IDs und Warehouse-Asset-Verhalten

COMMANDER
  New
  AddAirwing
  Start
  CanMission
  AddMission
  Status

AUFTRAG
  CAS
  geeignete MEDEVAC-/Utility-Missionstypen

OPSTRANSPORT
  Heavy-Lift-, Troop- und Logistics-Transport

FLIGHTGROUP und Warehouse-Asset-Lifecycle
  Spawn, Start, Landung, Rückgabe, Verlust, Stranding, final parking
```

Evidenzreihenfolge:

1. eingebettete `Moose.lua` mit dokumentiertem Hash;
2. zugehörige MOOSE-2.9.18-Quellen;
3. passende Klassendokumentation;
4. passende Demos;
5. erst dann OMW-spezifischer Code.

## 12. G0-bis-G10-Status

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | `main`-Basis, Branch, MIZ- und MOOSE-Hash festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | Juli-2011-Parent und Benennungsregel festgelegt |
| G2 Objektvertrag | `PROPOSED_COMPLETE` | Eigentümerannahme oder Merge ausstehend |
| G3 Mission Editor | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; Zonen fehlen |
| G4 MOOSE-Quellenprüfung | `NOT_STARTED` | vor Lua zwingend |
| G5 Read-only Diagnose | `BLOCKED_BY_G2_G4` | noch kein Lua |
| G6 Parking-Kalibrierung | `NOT_STARTED` | keine positive AI-Allowlist |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt |
| G8 direkter Dispatch | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/operational parking | `NOT_STARTED` | gesperrt |
| G10 Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 13. Annahmekriterien

Der Tarinkot-Objektvertrag gilt als eindeutig, wenn angenommen werden:

1. Juli-2011-ORBAT als Standardautorität für Einheits-, AIRWING- und SQUADRON-Namen;
2. Abweichung nur bei dokumentierter besserer und sichererer Evidenz;
3. ein AIRWING `AW_US_TKOT_TF_ATTACK_3_101_AVN`;
4. Airbase-ID `9`, Runtime-Name wird diagnostisch ermittelt;
5. Warehouse `WH_AIR_US_TARINKOT`;
6. `SQ_US_TKOT_AH64D_3_101_AVN`;
7. `SQ_US_TKOT_UH60_TF_ATTACK_ATTACHED`;
8. `SQ_US_TKOT_CH47_TF_ATTACK_ATTACHED`;
9. `ATTACHED` behauptet keine organische Zugehörigkeit zum Attack-Battalion;
10. lokaler Nominalbestand `14 / 6 / 2 / 0`;
11. aktuelle Seed-Namen und DCS-Typen aus der MIZ;
12. ein UH-60-Seed für zwei 1-Ship-Gruppen, vorbehaltlich MOOSE-Prüfung;
13. Client-Parkpositionen als harte Sperren;
14. leere AI-Parking-Allowlist bis zur Kalibrierung;
15. fehlende operative Zonen als Mission-Editor-Aufgabe;
16. keine Tarinkot-Lua-Implementierung vor Abschluss von G4.

## 14. Erster zulässiger Schritt nach Annahme

```text
G4: exakte MOOSE-2.9.18-Quellen-/Dokumentationsprüfung
anschließend
G5: isoliertes read-only Tarinkot-Diagnosebundle
```

Das G5-Bundle darf ausschließlich Provenienz, Airbase, Warehouse, Clients, Seeds, Statics, Zonen, Parking und Namensfehler protokollieren.

Es darf nicht:

```text
AIRWING oder SQUADRON erzeugen
Payloads registrieren
Assets anfordern oder spawnen
AUFTRAG erzeugen
COMMANDER starten
OPSTRANSPORT erzeugen
CampaignState verändern
```
