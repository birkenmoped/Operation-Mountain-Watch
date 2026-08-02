---
document_id: OMW-AIR-TKOT-MANIFEST
status: PROPOSED_BINDING_OBJECT_CONTRACT
owning_policy: OMW-GOV-001
document_class: AIR_OPERATIONS_MANIFEST
authoritative_for:
  - proposed Tarinkot AIRWING and SQUADRON object contract
  - proposed Tarinkot local aircraft inventory and representation limits
  - exact Tarinkot Mission Editor names for the audited source mission
  - Tarinkot warehouse-anchor, client-reservation, seed-template, static, and zone contract
  - implementation gates before any Tarinkot Lua runtime work
not_authoritative_for:
  - DCS runtime acceptance
  - untested MOOSE API behavior
  - runtime parking suitability or final parking selection
  - historical unit identities not explicitly supported by cited project evidence
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
---

# Tarinkot Air Operations Manifest and Object Contract

## 1. Zweck und Freigabegrenze

Dieses Dokument konsolidiert den Tarinkot-Objektvertrag gegen:

- den aktuellen Stand von `main`;
- die historische Juli-2011-ORBAT;
- den älteren Tarinkot-Dokumentationsbranch;
- die aktuelle Missionsdatei `OMW_Template_v5_Salerno.miz`;
- die verbindliche airfield-spezifische G0-bis-G10-Arbeitsweise.

Der Vertrag ist auf diesem Branch vollständig und eindeutig formuliert, besitzt aber gemäß Projekt-Governance erst nach Merge nach `main` oder einer ausdrücklichen Eigentümerentscheidung projektweite normative Wirkung.

Bis zur Annahme dieses Vertrags gilt ausdrücklich:

```text
KEINE TARINKOT-LUA-IMPLEMENTIERUNG
```

## 2. Quellen und Priorität

### 2.1 Mission-Editor-Iststand

Aktuelle strukturelle Evidenz:

- [`OMW-EVIDENCE-TARINKOT-ME-AUDIT-OMW-TEMPLATE-V5-SALERNO`](evidence/tarinkot-mission-editor-audit-omw-template-v5-salerno.md)

Exakte Quellmission:

```text
OMW_Template_v5_Salerno.miz
SHA-256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
```

### 2.2 Historische Einheitszuordnung

Die projektinterne Juli-2011-ORBAT nennt:

```text
Task Force Attack / 3-101 Attack Aviation
Standort: FOB Tarin Kowt
Auftrag: Aviation Support Uruzgan
```

Quelle:

- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md), Abschnitt `11.7 TF Thunder - Aviation RC South`.

Diese Quelle autorisiert die historische AH-64-Parent-Zuordnung. Sie nennt keine vollständige lokale Typen- oder Stückzahlliste und belegt keine exakten lokalen UH-60- oder CH-47-Unterverbände.

### 2.3 Bestandsstatus

Der lokale Arbeitsbestand bleibt die bereits vorbereitete OMW-Rekonstruktion:

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Diese Zahlen werden durch Merge dieses Manifests zur aktiven Tarinkot-Baseline vorgeschlagen. Sie sind getrennt von Statics, Client-Slots, Seed-Templates und aktiven KI-Gruppen zu führen.

## 3. Fester Standort- und AIRWING-Vertrag

```yaml
locationCode: TKOT
displayName: Tarinkot / Tarin Kowt / Camp Holland
dcsAirdromeId: 9
airwingName: AW_US_TARINKOT
warehouseAnchorName: WH_AIR_US_TARINKOT
```

### 3.1 Airbase-Auflösung

Die technische Identität des Flugplatzes ist für den Vertrag `airdromeId = 9`.

Nicht vorweggenommen wird:

```text
AIRBASE.Afghanistan.<exakte Konstante>
MOOSE runtime GetName()-Ergebnis
```

Diese Werte müssen im ersten read-only Diagnoselauf aus dem tatsächlich geladenen DCS-/MOOSE-Stand ermittelt und protokolliert werden. Es darf kein Name geraten und keine andere Airbase als Fallback verwendet werden.

### 3.2 Ein AIRWING

Tarinkot erhält genau einen lokalen AIRWING:

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

Der generische AIRWING-Name vermeidet die unbelegte Behauptung, dass alle lokalen Utility-, MEDEVAC- und Heavy-Lift-Elemente organisatorisch Teil des Attack-Battalions waren.

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

Begründung des technischen Namens:

- `3-101 Attack Aviation` ist für FOB Tarin Kowt im Juli 2011 belegt;
- eine Company-Bezeichnung wird nicht erfunden;
- der Name trennt die Tarinkot-Einheit eindeutig von `Task Force Guns / 4-227 Attack Aviation` in Kandahar.

Nicht mehr zu verwenden:

```text
SQ_US_TKOT_AH64D_ATTACK_DET
```

### 4.2 UH-60

```yaml
squadronName: SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
historicalLabel: local utility and MEDEVAC detachment; exact parent unresolved
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

Es wird kein historischer Company-, Battalion- oder Task-Force-Name ergänzt, solange keine entsprechende Quelle vorliegt.

Der aktuelle Mission Editor enthält nur einen 1-Ship-Seed. Der Zielvertrag lautet:

```text
2 MOOSE-Gruppen aus demselben 1-Ship-Seed
1 gemeinsamer Sechserbestand
keine zweite unabhängige Bestandsquelle
```

Dieser Mechanismus ist vor Implementierung in der tatsächlich eingebundenen MOOSE-Version 2.9.18 zu prüfen.

MEDEVAC-Paketvertrag:

```text
Lead:    1 × UH-60A
Support: 1 × UH-60A
atomare Reservierung: 2 Airframes
```

Beide aktuellen Seed-Abbilder sind unbewaffnet. Der zweite Hubschrauber wird deshalb als `Support` und nicht als erfundener bewaffneter Gunship-Cover bezeichnet. Eine bewaffnete Cover-Konfiguration benötigt eine gesonderte, quellen- und ME-geprüfte Entscheidung.

Nicht mehr zu verwenden:

```text
TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP
```

Diese Objekte existieren in der aktuellen MIZ nicht.

### 4.3 CH-47

```yaml
squadronName: SQ_US_TKOT_CH47_HEAVYLIFT_DET
historicalLabel: local heavy-lift detachment; exact parent unresolved
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

Der aktuelle Seed und der Client verwenden `CH-47Fbl1`. Es wird keine CH-47D-Abbildung behauptet und kein zweiter Client oder Static erfunden.

### 4.4 Nicht anzulegen

```text
SQ_US_TKOT_OH58D_*
permanente lokale Fixed-Wing-SQUADRON
zusätzliche Payload- oder Rollen-SQUADRONs für dieselben Airframes
```

## 5. Logischer Bestand und Darstellungsledger

### 5.1 Nominaler lokaler Bestand

| Musterfamilie | Nominalbestand |
|---|---:|
| AH-64D | 14 |
| UH-60 | 6 |
| CH-47 | 2 |
| OH-58D | 0 |

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

- ein unbelegter Client-Slot ist kein aktives Luftfahrzeug;
- ein Late-Activation-Seed ist kein eigener zusätzlicher Bestand;
- `SQUADRON`-Gruppenzahl und Luftfahrzeugzahl dürfen nicht verwechselt werden;
- Verlust, Wartung und Stranding müssen später denselben lokalen Ledger reduzieren;
- Tarinkot darf nicht zusätzlich im Kandahar-Lokalbestand gezählt werden.

### 5.4 Regionalpool-Abgrenzung

Die Tarinkot-Werte bleiben Teil der RC-South-Gesamtbetrachtung, sind aber lokal eigenständig verwaltet. Für spätere Konsolidierung gilt:

```text
Tarinkot != Kandahar Heliport
Tarinkot-Bestand darf nicht als Kandahar-SQUADRON registriert werden
3-101 Attack Aviation darf nicht als Kandahar-AH-64-Einheit verwendet werden
```

Eine spätere projektweite RC-South-Gesamttabelle muss die lokalen Basen addieren, nicht duplizieren.

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

Die drei internen Parking-Werte sind im read-only Diagnoselauf unverändert zu protokollieren. Insbesondere wird der Stringwert `"20"` nicht vor der Laufzeitprüfung stillschweigend normalisiert.

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

Alle Seeds sind:

```yaml
lateActivation: true
uncontrolled: false
initialParkingIds: none
initialWaypoint: Turning Point
```

Sie sind damit noch keine akzeptierten Parking-Starts.

### 6.3 Statics

```text
STATIC_AIR_US_TKOT_AH64_01 bis _08
STATIC_AIR_US_TKOT_UH60_UTILITY_01 bis _03
STATIC_AIR_US_TKOT_UH60_MEDEVAC_01
```

Keine weitere Tarinkot-Airframe-Static-Serie wird vorausgesetzt.

Die Typabweichung von `STATIC_AIR_US_TKOT_AH64_07` (`AH-64D` statt `AH-64D_BLK_II`) ist dokumentiert und zunächst akzeptiert als rein statische Darstellung. Sie darf nicht auf das AI-Template übertragen werden.

## 7. Payload- und Capability-Vertrag

### 7.1 AH-64D CAS

Der aktuelle Seed entspricht der projektweiten AH-64D-CAS-Baseline:

```text
2 × M261 mit M151 HE
2 × AGM-114K, jeweils einzeln auf den äußeren M299-Positionen
IAFS_ComboPak_100
25 Prozent Gun
```

Initial zulässige Capability:

```text
CAS als 2-Ship
```

Weitere Rollen dürfen denselben Seed nur verwenden, wenn MOOSE-Capability, ROE und Auftragstyp nachweislich passen. Es wird kein neuer Bestand durch zusätzliche Rollen erzeugt.

### 7.2 UH-60

Aktueller Seed:

```text
UH-60A
keine Pylonen
kein belegter bewaffneter Cover-Loadout
```

Initial zulässige Capabilities:

```text
MEDEVAC
UTILITY
```

### 7.3 CH-47F

Aktueller Seed:

```text
CH-47Fbl1
PORT M60D
STARBOARD M60D
```

Initial zulässige Capabilities:

```text
HEAVYLIFT
TROOP_TRANSPORT
LOGISTICS_TRANSPORT
```

Die Transportabwicklung ist MOOSE-first über vorhandene Transportklassen und insbesondere `OPSTRANSPORT` zu prüfen. Eigene Transportsteuerung ist nur nach dokumentierter Lückenanalyse zulässig.

## 8. Warehouse-Vertrag

```yaml
name: WH_AIR_US_TARINKOT
type: container_20ft
unitId: 1608
groupId: 1521
x: -149179.91252612
y: -30960.324668625
```

Fail-fast-Regeln für einen späteren Runtime-Stand:

- exakt ein Objekt dieses Namens;
- keine Ersatzsuche nach beliebigen Containern oder Gebäuden;
- keine Verwendung als historisch benanntes Lager ohne Evidenz;
- keine automatische Ableitung unbegrenzter CampaignState-Ressourcen aus den nativen DCS-Warehouse-Werten;
- kein AIRWING-Start bei fehlendem oder mehrfach gefundenem Anker.

## 9. Parking-Vertrag

### 9.1 Harte Client-Reservierungen

```text
C01-H / interne ID 20
C05-H / interne ID 8
C07-H / interne ID 3
```

Diese Positionen sind für KI-Initialspawns zu blockieren.

### 9.2 Aktueller AI-Allowlist-Status

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

Es gibt noch keine runtime-validierte positive Parking-Allowlist.

### 9.3 Nicht als Kapazitätsnachweis zu behandeln

```text
C01-H bis C21-H
K01 bis K09
G01 bis G03
```

Die bloße Existenz von Labels beweist weder freie Stellfläche noch Rotorabstand, Spawnrichtung, Rollweg, Kollisionfreiheit oder Eignung für bestimmte Hubschraubertypen.

### 9.4 Erforderliche Reihenfolge

1. read-only AIRBASE-/Parking-Dump;
2. Abgleich gegen Clients und Statics;
3. typweise Positiv-Allowlist;
4. isolierte Spawn-/Startkalibrierung;
5. erst danach AIRWING-/SQUADRON-Parking-Policy.

Operational parking und final parking nach Landung bleiben getrennte Akzeptanzgegenstände.

## 10. Zonenvertrag

Vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Für spätere operative Funktionen vorgesehen, aber in der aktuellen MIZ nicht vorhanden:

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

Vertrag:

- kein Lua-Fallback mit erfundenen Koordinaten;
- G5-Diagnostik darf fehlende Zonen lediglich melden;
- eine Funktion, die eine Zone benötigt, bleibt bis zur Mission-Editor-Anlage deaktiviert;
- Zonen werden im Mission Editor nach Benennungsschema angelegt und danach erneut auditiert.

## 11. MOOSE-first-Prüfauftrag vor jeder Implementierung

Vor eigenem Tarinkot-Lua müssen an der tatsächlich eingebundenen MOOSE-Version 2.9.18 und dem exakten eingebetteten Artefakt mindestens geprüft werden:

```text
AIRBASE
  FindByName
  FindByID beziehungsweise vorhandene ID-Auflösung
  GetName
  GetID
  Parking-Datenzugriff
  SetParkingSpotBlacklist oder aktuelle äquivalente API

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
  Gruppenzählung bei 2-Ship- und 1-Ship-Seeds
  Wiederverwendung eines 1-Ship-Seeds für zwei registrierte Gruppen
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
  MEDEVAC-/Utility-geeignete Missionstypen

OPSTRANSPORT
  Heavy-Lift-, Troop- und Logistics-Transport

FLIGHTGROUP und Warehouse-Asset-Lifecycle
  Spawn
  Start
  Landung
  Rückgabe
  Verlust
  Stranding
  Parking nach Landung
```

Reihenfolge der Evidenz:

1. eingebettete `Moose.lua` mit dokumentiertem Hash;
2. zugehörige MOOSE-2.9.18-Quellen;
3. passende Klassendokumentation;
4. passende Demos;
5. erst dann OMW-spezifischer Code.

## 12. G0-bis-G10-Status

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | `main`-Basis, Branch, MIZ- und MOOSE-Hash festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | Juli-2011-Zuordnung und aktueller ME-Audit konsolidiert |
| G2 Objektvertrag | `PROPOSED_COMPLETE` | dieses Manifest; Eigentümerannahme/Merge ausstehend |
| G3 Mission-Editor-Build | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; operative Zonen fehlen |
| G4 MOOSE-Quellenprüfung | `NOT_STARTED` | vor Lua zwingend |
| G5 Read-only Diagnose | `BLOCKED_BY_G2_G4` | noch kein Lua |
| G6 Parking-Kalibrierung | `NOT_STARTED` | keine positive AI-Allowlist |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt |
| G8 direkter Dispatch | `NOT_STARTED` | gesperrt |
| G9 COMMANDER-Dispatch / operational parking | `NOT_STARTED` | gesperrt |
| G10 Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 13. Annahmekriterien für den Objektvertrag

Der Tarinkot-Objektvertrag gilt als eindeutig, wenn der Projekteigentümer beziehungsweise ein Merge nach `main` folgende Punkte annimmt:

1. ein AIRWING `AW_US_TARINKOT`;
2. Airbase-Identität DCS-ID `9`, runtime Name wird diagnostisch ermittelt;
3. Warehouse `WH_AIR_US_TARINKOT` exakt wie auditiert;
4. AH-64-SQUADRON `SQ_US_TKOT_AH64D_3_101_AVN`;
5. generische, nicht historisch überdehnte UH-60- und CH-47-SQUADRON-Namen;
6. lokaler Nominalbestand `14 / 6 / 2 / 0`;
7. aktuelle Seed-Namen und DCS-Typen aus der MIZ;
8. ein gemeinsamer UH-60-Seed für zwei 1-Ship-Gruppen, vorbehaltlich MOOSE-Quellenprüfung;
9. Client-Parkpositionen als harte Sperren;
10. leere AI-Parking-Allowlist bis zur Kalibrierung;
11. fehlende operative Zonen als Mission-Editor-Aufgabe, nicht als Lua-Fallback;
12. keine Tarinkot-Lua-Implementierung vor Abschluss von G4.

## 14. Erster zulässiger Schritt nach Annahme

Nach Annahme dieses Vertrags wird noch nicht unmittelbar ein AIRWING erzeugt.

Der nächste zulässige Arbeitsschritt ist:

```text
G4: exakte MOOSE-2.9.18-Quellen-/Dokumentationsprüfung
anschließend
G5: isoliertes read-only Tarinkot-Diagnosebundle
```

Das G5-Bundle darf ausschließlich protokollieren:

- MIZ-/Bundle-/MOOSE-Provenienz;
- Airbase-ID und runtime Name;
- Warehouse-Anker;
- Clients;
- AI-Seeds;
- Statics;
- vorhandene und fehlende Zonen;
- Parking-Spots und Terminaldaten;
- Namensduplikate und fehlende Objekte.

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
