---
document_id: OMW-AIR-TKOT-MANIFEST
status: DRAFT
owning_policy: OMW-GOV-001
document_class: AIR_OPERATIONS_MANIFEST
authoritative_for:
  - proposed Tarinkot AIRWING and SQUADRON object contract
  - Tarinkot unit and technical object naming derived from the safest available sources
  - proposed Tarinkot local aircraft inventory and representation limits
  - exact Tarinkot Mission Editor names for the audited source mission
  - Tarinkot warehouse-anchor, client-reservation, seed-template, static, parking, and zone contract
  - implementation gates before any Tarinkot Lua runtime work
not_authoritative_for:
  - DCS runtime acceptance
  - untested MOOSE API behavior
  - runtime parking suitability or final parking selection
  - historical subordinate identities not explicitly supported by cited evidence
  - exact 2011 aircraft quantities beyond documented minimum presence
  - project-wide binding effect before merge to main or explicit owner decision
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_OBJECT_CONTRACT_RECONCILIATION
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
supersedes_on_merge:
  - Tarinkot object assumptions from docs/tarinkot-air-operations-baseline PR 40
  - Tarinkot Mission Editor assumptions based on OMW_Template(3).miz
  - generic Tarinkot AIRWING and SQUADRON names not derived from historical evidence
  - provisional UH-60 and CH-47 TF_ATTACK_ATTACHED names
object_contract_state: PROPOSED_COMPLETE_PENDING_OWNER_ACCEPTANCE
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations Manifest and Object Contract

## 1. Zweck und Freigabegrenze

Dieses Dokument konsolidiert den Tarinkot-Objektvertrag gegen:

- den aktuellen Stand von `main`;
- die Afghanistan Order of Battle vom Juli 2011;
- zeitgenössische offizielle U.S.-Army-/DVIDS-Quellen von 2010 und 2011;
- die dokumentierten Satellitenbeobachtungen vom Mai 2012;
- die aktuelle Mission `OMW_Template_v5_Salerno.miz`;
- die verbindliche G0-bis-G10-Arbeitsweise.

Der Vertrag besitzt erst nach Merge nach `main` oder einer ausdrücklichen Eigentümerentscheidung projektweite normative Wirkung.

Bis zur Annahme dieses Vertrags gilt:

```text
KEINE TARINKOT-LUA-IMPLEMENTIERUNG
```

## 2. Quellen- und Benennungsregel

### 2.1 Standardautorität

Für aktive historische Einheit, Parent, Task-Force-Zuordnung sowie AIRWING- und SQUADRON-Namen gilt:

```text
Die Juli-2011-ORBAT ist die Standardautorität,
sofern keine bessere, sicherere und spezifischere Quelle
für denselben Standort, Zeitraum und Gegenstand vorliegt.
```

Als bessere Quelle gelten insbesondere zeitgenössische offizielle militärische Veröffentlichungen, die Datum, Standort, Einheit und Luftfahrzeugtyp direkt gemeinsam nennen.

Nicht ausreichend zur Einheitsbenennung sind allein:

- Mission-Editor-Objektnamen;
- Satellitenbilder ohne Einheitsidentifikation;
- DCS-Typverfügbarkeit;
- generische technische Bezeichnungen;
- Ableitungen aus dem Parent-Hub Kandahar.

### 2.2 Historischer Parent

Die Juli-2011-ORBAT nennt:

```text
Task Force Attack / 3-101 Attack Aviation
Commander: Lt. Col. Rod Hynes
Standort: FOB Tarin Kowt
Auftrag: Aviation Support Uruzgan
```

Übergeordnet:

```text
Task Force Thunder / 159th Combat Aviation Brigade
```

Damit ist Task Force Attack / 3-101 der lokale Aviation-Task-Force-Knoten.

### 2.3 Zeitgenössischer Typennachweis

Eine offizielle Aufnahme der 159th Combat Aviation Brigade Public Affairs vom 11.09.2011 dokumentiert am FOB Tarin Kowt gemeinsam:

```text
2 × AH-64 Apache
1 × UH-60 Black Hawk
1 × CH-47 Chinook
```

Die Bildbeschreibung ordnet alle vier beteiligten Luftfahrzeuge ausdrücklich Task Force Attack / 3-101 Aviation Regiment zu.

Damit ist die Präsenz aller drei Musterfamilien innerhalb des OMW-Zeitraums nicht mehr ausschließlich aus Satellitenbildern abgeleitet.

Details:

- [`OMW-EVIDENCE-TARINKOT-AVIATION-2011`](evidence/tarinkot-2011-aviation-unit-and-aircraft-evidence.md)

### 2.4 CH-47-spezifische Einheit

Zeitgenössische offizielle Quellen belegen zusätzlich:

```text
B Company, 1-52 Aviation Regiment / Sugar Bears
CH-47D
Detachment at FOB Tarin Kowt
Einsatzbeginn in southern Afghanistan: June 2011
regional attached to Task Force Lift / 7-101 Aviation
local support to Task Force Attack at Tarin Kowt
```

Für den CH-47-SQUADRON-Namen ist daher B/1-52 die spezifischste sicher belegte fliegende Einheit.

### 2.5 UH-60-Grenze

Zeitgenössische Quellen belegen UH-60-Präsenz und die operative Task-Force-Attack-Zuordnung. Sie lösen den lokalen UH-60-Pool jedoch nicht sicher bis zu einer Company oder einem administrativen Herkunftsbataillon auf.

Deshalb wird keine Company- oder Battalion-Bezeichnung erfunden.

## 3. Standort-, Parent- und AIRWING-Vertrag

```yaml
locationCode: TKOT
displayName: Tarinkot / Tarin Kowt / Camp Holland
dcsAirdromeId: 9
historicalParent: Task Force Attack / 3-101 Attack Aviation
airwingName: AW_US_TKOT_TF_ATTACK_3_101_AVN
warehouseAnchorName: WH_AIR_US_TARINKOT
```

### 3.1 Airbase-Auflösung

Fest:

```text
DCS airdromeId = 9
```

Noch read-only zu ermitteln:

```text
AIRBASE.Afghanistan.<exakte Konstante>
MOOSE runtime GetName()-Ergebnis
```

Es darf kein Airbase-Name geraten und keine andere Airbase als Fallback verwendet werden.

### 3.2 Ein AIRWING

Tarinkot erhält genau einen lokalen Operationsknoten:

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
Historical label: Task Force Attack / 3-101 Attack Aviation
```

Der AIRWING-Name beschreibt den lokalen task-organized Aviation-Knoten. Er behauptet nicht, dass jede angegliederte Company organischer Bestandteil von 3-101 Attack Aviation war.

Nicht zulässig:

```text
AW_US_TARINKOT
zweiter AIRWING am selben Tarinkot-Bestand
separater MEDEVAC-AIRWING
separater CH-47-AIRWING
lokaler Fixed-Wing-AIRWING
```

## 4. SQUADRON-Vertrag

### 4.1 AH-64D – Task Force Attack / 3-101

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

Nicht zu verwenden:

```text
SQ_US_TKOT_AH64D_ATTACK_DET
```

### 4.2 UH-60 – belegte Task-Force-Zuordnung, Company offen

```yaml
squadronName: SQ_US_TKOT_UH60_TF_ATTACK
historicalLabel: UH-60 component of Task Force Attack at FOB Tarin Kowt
historicalParentAuthority: official 159th CAB evidence dated 2011-09-11
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

Nicht zu verwenden:

```text
SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
SQ_US_TKOT_UH60_TF_ATTACK_ATTACHED
unbelegte Company- oder Battalion-Bezeichnung
```

Der aktuelle Mission Editor enthält nur einen 1-Ship-Seed. Zielvertrag:

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

Der aktuelle Seed ist unbewaffnet. Der zweite Hubschrauber wird deshalb nicht als erfundener bewaffneter Cover bezeichnet.

Nicht vorhandene Seed-Namen:

```text
TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP
```

### 4.3 CH-47 – B Company, 1-52 Aviation Regiment

```yaml
squadronName: SQ_US_TKOT_CH47_B_1_52_AVN
historicalLabel: B Company, 1-52 Aviation Regiment / Sugar Bears
historicalAircraftType: CH-47D
regionalAttachment: Task Force Lift / 7-101 Aviation
localOperationalAssociation: Task Force Attack / 3-101 Aviation Regiment
template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
dcsSubstituteType: CH-47Fbl1
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

Nicht zu verwenden:

```text
SQ_US_TKOT_CH47_HEAVYLIFT_DET
SQ_US_TKOT_CH47_TF_ATTACK_ATTACHED
```

Die historische CH-47D-Komponente wird im aktuellen DCS-Stand durch `CH-47Fbl1` repräsentiert. Diese Abweichung muss in Dokumentation, Mission und Payload-/Capability-Registrierung sichtbar bleiben.

### 4.4 Nicht anzulegen

```text
SQ_US_TKOT_OH58D_*
permanente lokale Fixed-Wing-SQUADRON
zusätzliche Rollen-SQUADRONs für dieselben Airframes
TF-Lift-SQUADRON-Namen ohne lokalen B/1-52-Bezug
FOB-Wolverine-Einheiten
```

## 5. Präsenz, Nominalbestand und Darstellungsledger

### 5.1 Evidenzstatus

| Aussage | Status |
|---|---|
| AH-64 am FOB Tarin Kowt 2011 | `CONFIRMED` |
| UH-60 am FOB Tarin Kowt 2011 | `CONFIRMED` |
| CH-47 am FOB Tarin Kowt 2011 | `CONFIRMED` |
| B/1-52 CH-47D-Detachment | `CONFIRMED` |
| exakte UH-60-Untereinheit | `UNRESOLVED` |
| exakte lokale 2011er Stückzahlen | `RECONSTRUCTED` |

### 5.2 Nominaler OMW-Arbeitsbestand

```yaml
AH64D: 14
UH60: 6
CH47: 2
OH58D: 0
```

Diese Werte sind eine OMW-Rekonstruktion. Die zeitgenössischen Quellen belegen Typenpräsenz und Einheitsbezüge, nicht den vollständigen lokalen Sollbestand.

Die Satellitenaufnahme vom 17.05.2012 zeigt als `POST_PERIOD_CONTEXT`:

```text
14 AH-64
6 UH-60
1 CH-47
0 bestätigte OH-58D
```

### 5.3 Maximale gleichzeitige Darstellung

| Musterfamilie | Statics | aktive Clients maximal | aktive KI maximal | Summe |
|---|---:|---:|---:|---:|
| AH-64 | 8 | 2 | 4 | 14 |
| UH-60 | 4 | 0 | 2 | 6 |
| CH-47 | 0 | 1 | 1 | 2 |
| OH-58D | 0 | 0 | 0 | 0 |

### 5.4 Invariante

```text
sichtbare Statics
+ aktive Client-Luftfahrzeuge
+ aktive KI-Luftfahrzeuge
+ bestätigte Wartungs-/Stranded-Zustände
<= verbleibender lokaler Bestand je Musterfamilie
```

Dabei gilt:

- unbelegter Client-Slot ist kein aktives Luftfahrzeug;
- Late-Activation-Seed ist kein zusätzlicher Bestand;
- SQUADRON-Gruppenzahl und Luftfahrzeugzahl sind getrennt;
- Verlust, Wartung und Stranding reduzieren denselben Ledger;
- Tarinkot-Bestände dürfen nicht zusätzlich in Kandahar gezählt werden.

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

Der Stringwert `"20"` wird vor einer Laufzeitprüfung nicht stillschweigend normalisiert.

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

Sie sind keine akzeptierten Parking-Starts.

### 6.3 Statics

```text
STATIC_AIR_US_TKOT_AH64_01 bis _08
STATIC_AIR_US_TKOT_UH60_UTILITY_01 bis _03
STATIC_AIR_US_TKOT_UH60_MEDEVAC_01
```

`STATIC_AIR_US_TKOT_AH64_07` verwendet abweichend `AH-64D` statt `AH-64D_BLK_II`. Diese rein statische Typabweichung darf nicht auf den AI-Seed übertragen werden.

## 7. Capability- und Payload-Grenzen

### 7.1 AH-64D

Initial:

```text
CAS als 2-Ship
```

Der Seed muss die projektweite AH-64D-CAS-Baseline abbilden. Weitere Rollen dürfen keinen zusätzlichen Bestand erzeugen.

### 7.2 UH-60

Aktueller Seed:

```text
UH-60A
keine Pylonen
kein belegter bewaffneter Cover-Loadout
```

Initial:

```text
MEDEVAC
UTILITY
```

Die zeitgenössische Quelle belegt UH-60 unter Task Force Attack, aber keine separate MEDEVAC-Company. Missionsrolle und historische Einheitsidentität bleiben getrennt.

### 7.3 CH-47

Historisch:

```text
B/1-52 AVN
CH-47D
```

DCS-Ersatz:

```text
CH-47Fbl1
PORT M60D
STARBOARD M60D
```

Initial:

```text
HEAVYLIFT
TROOP_TRANSPORT
LOGISTICS_TRANSPORT
```

Transportabwicklung ist MOOSE-first über vorhandene Transportklassen und insbesondere `OPSTRANSPORT` zu prüfen.

## 8. Warehouse-Vertrag

```yaml
name: WH_AIR_US_TARINKOT
type: container_20ft
unitId: 1608
groupId: 1521
x: -149179.91252612
y: -30960.324668625
```

Spätere Fail-fast-Regeln:

- exakt ein Objekt dieses Namens;
- keine Ersatzsuche nach beliebigen Containern oder Gebäuden;
- keine Verwendung als historisch benanntes Lager ohne Evidenz;
- keine Ableitung unbegrenzter CampaignState-Ressourcen aus nativen DCS-Warehouse-Werten;
- kein AIRWING-Start bei fehlendem oder mehrfach gefundenem Anker.

## 9. Parking-Vertrag

### 9.1 Harte Client-Reservierungen

```text
C01-H / interne ID "20"
C05-H / interne ID 8
C07-H / interne ID 3
```

Diese Positionen sind für KI-Initialspawns zu blockieren.

### 9.2 AI-Allowlist

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

Es gibt noch keine runtime-validierte positive Parking-Allowlist.

### 9.3 Keine Kapazitätsannahme

Die Labels:

```text
C01-H bis C21-H
K01 bis K09
G01 bis G03
```

beweisen keine freie Stellfläche, Rotorfreiheit, Spawnrichtung, Rollweg- oder Mustereignung.

### 9.4 Reihenfolge

1. read-only AIRBASE-/Parking-Dump;
2. Abgleich gegen Clients und Statics;
3. typweise Positiv-Allowlist;
4. isolierte Spawn-/Startkalibrierung;
5. AIRWING-/SQUADRON-Parking-Policy.

Operational parking und final parking nach Landung bleiben getrennte Akzeptanzgegenstände.

## 10. Zonenvertrag

Vorhanden:

```text
OMW_LOG_NODE_TARINKOT
```

Vorgesehen, aber in der aktuellen MIZ nicht vorhanden:

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
- G5 darf fehlende Zonen nur melden;
- zonenabhängige Funktionen bleiben deaktiviert;
- Zonen werden im Mission Editor angelegt und danach erneut auditiert.

## 11. MOOSE-first-Prüfauftrag

Vor eigenem Tarinkot-Lua müssen an der tatsächlich eingebundenen MOOSE-Version 2.9.18 und dem exakten Artefakt mindestens geprüft werden:

```text
AIRBASE
  FindByName
  ID-Auflösung
  GetName
  GetID
  Parking-Datenzugriff
  SetParkingSpotBlacklist oder äquivalente API

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
  Spawn
  Start
  Landung
  Rückgabe
  Verlust
  Stranding
  Parking nach Landung
```

Evidenzreihenfolge:

1. eingebettete `Moose.lua` mit dokumentiertem Hash;
2. zugehörige MOOSE-2.9.18-Quellen;
3. passende Klassendokumentation;
4. passende Demos;
5. erst dann OMW-Code.

## 12. G0-bis-G10-Status

| Gate | Status | Tarinkot-Ergebnis |
|---|---|---|
| G0 Provenienz | `PASS_BRANCH` | main-Basis, Branch, MIZ- und MOOSE-Hash festgelegt |
| G1 Dokumente/ORBAT/Evidenz | `PASS_BRANCH` | ORBAT, offizielle 2011er Quellen, Satelliten- und ME-Audit konsolidiert |
| G2 Objektvertrag | `PROPOSED_COMPLETE` | Eigentümerannahme/Merge ausstehend |
| G3 Mission Editor | `PARTIAL` | Clients, Seeds, Statics und Warehouse vorhanden; operative Zonen fehlen |
| G4 MOOSE-Quellenprüfung | `NOT_STARTED` | vor Lua zwingend |
| G5 Read-only Diagnose | `BLOCKED_BY_G2_G4` | noch kein Lua |
| G6 Parking-Kalibrierung | `NOT_STARTED` | keine positive AI-Allowlist |
| G7 AIRWING/SQUADRON/Payload | `NOT_STARTED` | gesperrt |
| G8 direkter Dispatch | `NOT_STARTED` | gesperrt |
| G9 COMMANDER/operational parking | `NOT_STARTED` | gesperrt |
| G10 Ergebnisse/Handoff | `NOT_STARTED` | gesperrt |

## 13. Annahmekriterien

Der Objektvertrag ist eindeutig, wenn angenommen werden:

1. `AW_US_TKOT_TF_ATTACK_3_101_AVN`;
2. DCS-Airbase-ID 9, Runtime-Name diagnostisch ermitteln;
3. `WH_AIR_US_TARINKOT`;
4. `SQ_US_TKOT_AH64D_3_101_AVN`;
5. `SQ_US_TKOT_UH60_TF_ATTACK`, Company weiterhin offen;
6. `SQ_US_TKOT_CH47_B_1_52_AVN` mit CH-47D → CH-47Fbl1-Ersatz;
7. Typenpräsenz 2011 ist bestätigt, Stückzahlen `14/6/2/0` bleiben OMW-Rekonstruktion;
8. aktuelle Seed-Namen und DCS-Typen aus der MIZ;
9. gemeinsamer UH-60-Seed für zwei 1-Ship-Gruppen, vorbehaltlich MOOSE-Prüfung;
10. Client-Parkpositionen als harte Sperren;
11. leere AI-Parking-Allowlist bis zur Kalibrierung;
12. fehlende operative Zonen als Mission-Editor-Aufgabe;
13. keine Tarinkot-Lua-Implementierung vor Abschluss von G4.

## 14. Erster zulässiger Schritt nach Annahme

```text
G4: exakte MOOSE-2.9.18-Quellen-, Dokumentations- und Demo-Prüfung
anschließend
G5: isoliertes read-only Tarinkot-Diagnosebundle
```

G5 darf ausschließlich protokollieren:

- MIZ-/Bundle-/MOOSE-Provenienz;
- Airbase-ID und Runtime-Name;
- Warehouse-Anker;
- Clients;
- AI-Seeds;
- Statics;
- vorhandene und fehlende Zonen;
- Parking-Spots und Terminaldaten;
- Namensduplikate und fehlende Objekte.

G5 darf nicht:

```text
AIRWING oder SQUADRON erzeugen
Payloads registrieren
Assets anfordern oder spawnen
AUFTRAG erzeugen
COMMANDER starten
OPSTRANSPORT erzeugen
CampaignState verändern
```
