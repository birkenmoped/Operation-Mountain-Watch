---
document_id: OMW-AIR-TKOT-MANIFEST
status: BINDING_PROJECT_DECISION
document_class: AIR_OPERATIONS_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - current Tarinkot Mission Editor air-operations baseline
  - Tarinkot AIRWING and SQUADRON registration contract
  - Tarinkot warehouse-anchor detection contract
  - Tarinkot AUFTRAG and OPSTRANSPORT capability contract
  - Tarinkot safe-parking and blacklist requirements
  - Tarinkot aircraft loss return and inventory-accounting contract
  - required Tarinkot air-operations functional zones
not_authoritative_for:
  - historical force evidence outside document 50 and document 55
  - local logical inventory values outside document 19
  - DCS or MOOSE runtime acceptance
  - untested AI parking identifiers
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: docs/tarinkot-air-operations-baseline
source_mission: OMW_Template(3).miz
source_mission_sha256: 2c0d94bdece19db797aa7f6ece79c6ca38901c4b06ced69b954fc484db6f5a83
validated_in_dcs: false
supersedes:
  - Tarinkot provisional authoring target of 10 AH-64 statics
  - Tarinkot provisional authoring target of 1 CH-47 static
  - Tarinkot provisional second CH-47F client group
---

# Tarinkot Air Operations Manifest

## 1. Zweck und Autoritätsgrenze

Dieses Manifest ist die verbindliche technische Übergabebaseline für Tarinkot. Es beschreibt den tatsächlich geprüften Mission-Editor-Stand und legt die Verträge fest, nach denen die noch zu implementierenden Komponenten arbeiten müssen:

- `AIRWING`-Registrierung;
- `SQUADRON`-Bestandsverwaltung;
- Warehouse-Erkennung;
- `AUFTRAG`-/`OPSTRANSPORT`-Ausführung;
- Safe-Parking-/Blacklist-Verfahren;
- Verlust-, Rückgabe- und Reconciliation-Logik;
- flugplatzspezifische Funktionszonen.

Historische Evidenz und lokale Gesamtbestände bleiben in Dokument 50, Dokument 55 und Dokument 19. Dieses Manifest ist für den konkreten Tarinkot-Authoring- und Implementierungsstand spezieller und ersetzt die früheren vorläufigen Angaben zu Statics und dem zweiten CH-47-Client.

Strukturelle Missionsbeobachtung:

- [`OMW-EVIDENCE-TARINKOT-ME-AUDIT-OMW-TEMPLATE-3`](evidence/tarinkot-mission-editor-audit-omw-template-3.md).

## 2. Feste Standort- und Objektnamen

```yaml
locationCode: TKOT
displayName: Tarinkot / Tarin Kowt / Camp Holland
dcsAirdromeId: 9
airwingName: AW_US_TARINKOT
warehouseAnchorName: WH_AIR_US_TARINKOT
```

Technische SQUADRON-Namen:

```text
SQ_US_TKOT_AH64D_ATTACK_DET
SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
SQ_US_TKOT_CH47_HEAVYLIFT_DET
```

Nicht anzulegen:

```text
SQ_US_TKOT_OH58D_*
zweiter AIRWING am selben Flugplatz
permanente lokale Fixed-Wing-SQUADRON
```

Ungeklärte historische Company-, Battalion- oder Task-Force-Zuordnungen werden nicht erfunden.

## 3. Verbindlicher lokaler Bestand und physische Darstellung

### 3.1 Logischer Kampagnenbestand

```yaml
nominalInventory:
  AH64D: 14
  UH60: 6
  CH47: 2
  OH58D: 0
```

Alle Tarinkot-Bestände werden vom Kandahar-/RC-South-Regionalpool abgezogen und dürfen nicht zusätzlich am Parent-Hub gezählt werden.

### 3.2 Aktueller Mission-Editor-Stand

| Musterfamilie | Statics | Clientgruppen | AI-Seed | maximale AI-Gruppen | maximale AI-Luftfahrzeuge |
|---|---:|---:|---|---:|---:|
| AH-64 | 8 | 2 × 1 Ship | 1 × 2 Ship | 2 | 4 |
| UH-60 | 4 | 0 | 2 × 1 Ship | 2 | 2 |
| CH-47 | 0 | 1 × 1 Ship | 1 × 1 Ship | 1 | 1 |
| OH-58D | 0 | 0 | keiner | 0 | 0 |

Maximale rechnerische Vollbelegung:

```text
AH-64: 8 Statics + 2 Clients + 4 AI = 14
UH-60: 4 Statics + 0 Clients + 2 AI = 6
CH-47: 0 Statics + 1 Client + 1 AI = 2
```

Verbindliche Invariante:

```text
sichtbare Statics
+ aktive Client-Luftfahrzeuge
+ aktive KI-Luftfahrzeuge
+ bestätigte Wartungs-/Stranded-Zustände
<= verbleibender lokaler Bestand je Muster
```

Ein im Mission Editor vorhandener, aber nicht belegter Client-Slot zählt nicht als aktives Luftfahrzeug. Ein Late-Activation-Template zählt nicht als Bestand. Erst Reservierung beziehungsweise Materialisierung belegt einen Airframe-Slot.

## 4. AIRWING-Registrierungsvertrag

### 4.1 Erforderliche Reihenfolge

1. gepinnte MOOSE-Version und Hash prüfen;
2. `WH_AIR_US_TARINKOT` exakt per Name finden;
3. DCS-Airbase mit `airdromeId = 9` auflösen und den tatsächlichen DCS-/MOOSE-Namen protokollieren;
4. Parking-Policy und Blacklist laden;
5. `AW_US_TARINKOT` genau einmal erzeugen;
6. SQUADRONs und deren Payload-/Mission-Capabilities registrieren;
7. Bestandsledger mit Dokument-19-Werten initialisieren beziehungsweise aus CampaignState wiederherstellen;
8. AIRWING erst danach starten;
9. Registrierungszusammenfassung und Fehlerstatus protokollieren.

### 4.2 Fail-fast-Regeln

Der Tarinkot-AIRWING darf nicht stillschweigend mit Ersatznamen oder einem beliebigen Szenery-Gebäude starten.

Startabbruch beziehungsweise `DEGRADED_NOT_STARTED` bei:

- fehlendem `WH_AIR_US_TARINKOT`;
- mehrfach vorhandenem Warehouse-Namen;
- nicht auflösbarer Airbase-ID 9;
- fehlendem erforderlichen KI-Template;
- Bestandswert kleiner als bereits persistierte Verluste oder aktive Reservierungen;
- unauflösbarer Parking-Policy.

Kein zweiter AIRWING darf denselben lokalen Bestand verwalten.

## 5. Warehouse-Erkennung und Bestandsautorität

### 5.1 Vorhandener technischer Anker

```yaml
name: WH_AIR_US_TARINKOT
type: container_20ft
x: -149179.91252612
y: -30960.324668625
unitId: 1608
```

Der Anker ist ein technisches MOOSE-Objekt. Er ist nicht automatisch:

- das sichtbare Hauptlager von Camp Holland;
- ein zerstörbares strategisches Fuel Depot;
- die Quelle unbegrenzter CampaignState-Ressourcen.

### 5.2 Native DCS-Warehouse-Werte

`warehouses.airports[9]` ist im geprüften `.miz` für Flugzeuge, Munition und Treibstoff unbegrenzt. Diese Werte dienen aktuell nur dem DCS-Basissetup. Für OMW gelten getrennt:

1. Dokument 19 für nominale Luftfahrzeugzahlen;
2. SQUADRON/AIRWING für KI-Verfügbarkeit;
3. CampaignState für Verluste, Wartung, Stranding und spätere Logistikressourcen;
4. DCS-Warehouse-Einstellungen dürfen diese Ebenen nicht überschreiben.

### 5.3 Zerstörung des technischen Ankers

Der technische Warehouse-Anker wird nicht als normaler Kampagnenverlust gezählt. Eine später gewünschte zerstörbare Lagerinfrastruktur benötigt getrennte Namen und CampaignState-Objekte. Der technische Anker darf nicht als Ziel oder Statikersatz für ein Munitionslager benutzt werden.

## 6. SQUADRON-Registrierung und Gruppenzähler

`Ngroups` bezeichnet MOOSE-Gruppen, nicht einzelne Luftfahrzeuge.

### 6.1 AH-64

```yaml
squadron: SQ_US_TKOT_AH64D_ATTACK_DET
template: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
templateAircraft: 2
Ngroups: 2
maximumAIAircraft: 4
clientReservationsMaximum: 2
staticRepresentation: 8
nominalInventory: 14
```

Der Mission-Editor-Seed verwendet aus DCS-Gründen `AH-64A`; die Spielergruppen verwenden `AH-64D_BLK_II`. Diese technische Ersatzdarstellung muss in Payload-, Livery- und Capability-Registrierung sichtbar bleiben.

### 6.2 UH-60

```yaml
squadron: SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
templates:
  - TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP
  - TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP
templateAircraftEach: 1
NgroupsTotal: 2
maximumAIAircraft: 2
clientReservationsMaximum: 0
staticRepresentation: 4
nominalInventory: 6
```

Lead und Cover teilen einen gemeinsamen Sechserbestand. Falls der gepinnte MOOSE-Stand mehrere Seeds nicht direkt in einem SQUADRON abbilden kann, darf keine zweite unabhängige Bestandsquelle entstehen. Die technische Abbildung muss weiterhin einen gemeinsamen Ledger und eine atomare Zwei-Airframe-Reservierung verwenden.

### 6.3 CH-47

```yaml
squadron: SQ_US_TKOT_CH47_HEAVYLIFT_DET
template: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
templateAircraft: 1
Ngroups: 1
maximumAIAircraft: 1
clientReservationsMaximum: 1
staticRepresentation: 0
nominalInventory: 2
```

Der KI-Seed verwendet `CH-47D`; der Client verwendet `CH-47Fbl1`. Es wird kein zweiter CH-47F-Client und kein CH-47-Static angelegt.

## 7. Mission-Editor-Objekte

### 7.1 Clients

```text
CLIENT_US_TKOT_AH64D_01
└── CLIENT_US_TKOT_AH64D_01_UNIT_01
    Parking: C01-H

CLIENT_US_TKOT_AH64D_02
└── CLIENT_US_TKOT_AH64D_02_UNIT_01
    Parking: C05-H

CLIENT_US_TKOT_CH47F_01
└── CLIENT_US_TKOT_CH47F_01_UNIT_01
    Parking: C07-H
```

### 7.2 KI-Seeds

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
├── TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_01
└── TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_02

TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP
└── TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP_UNIT_01

TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP
└── TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP_UNIT_01

TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
└── TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP_UNIT_01
```

Alle Seeds sind `Late Activation`, `uncontrolled = false`, besitzen keine Parking-ID und beginnen an einem `Turning Point`. Sie dürfen nicht als bereits akzeptierte direkte Parking-Starts behandelt werden.

### 7.3 Statics

```text
STATIC_AIR_US_TKOT_AH64_01 bis _08

STATIC_AIR_US_TKOT_UH60_UTILITY_01 bis _03
STATIC_AIR_US_TKOT_UH60_MEDEVAC_01
```

Keine weitere Static-Serie ist freigegeben.

## 8. AUFTRAG- und OPSTRANSPORT-Vertrag

Vor eigener Missionssteuerung ist die gepinnte MOOSE-Dokumentation zu `AIRWING`, `SQUADRON`, `AUFTRAG`, `COMMANDER` und `OPSTRANSPORT` zu prüfen.

### 8.1 AH-64

Initial freigegebener Auftrag:

```text
CAS als 2-Ship-Paket
```

Rahmen:

- Standardreservierung: zwei AH-64;
- maximal zwei gleichzeitig aktive lokale AI-Gruppen beziehungsweise vier AI-AH-64;
- zusätzliche Escort- oder Armed-Recon-Rollen sollen denselben Seed wiederverwenden, sofern MOOSE Mission Capability, Payload und ROE dies zulassen;
- eine getrennte Escort-Vorlage wird nicht ohne technische Notwendigkeit angelegt;
- Auftrag bleibt pending oder wird abgelehnt, wenn kein sicheres Two-Ship-Parking verfügbar ist.

### 8.2 UH-60 MEDEVAC

```text
1 × MEDEVAC Lead
1 × MEDEVAC Cover
```

Verbindlich:

- atomare Reservierung von zwei UH-60;
- keine Aussendung nur eines Luftfahrzeugs;
- Lead und Cover erhalten dieselbe Mission-/Package-ID;
- getrennte Gruppen und Ereignisse, aber gemeinsamer Package-Status;
- Verlust eines Paketmitglieds wird einzeln gebucht und beendet oder degradiert den gemeinsamen Auftrag nach definierter Regel;
- keine zusätzliche Utility-Mission, solange dadurch der Sechserbestand überschritten würde.

### 8.3 CH-47

Initiale Rollen:

```text
HEAVYLIFT
TROOP_TRANSPORT
LOGISTICS_TRANSPORT
```

Umsetzung bevorzugt über `OPSTRANSPORT` beziehungsweise vorhandene MOOSE-Transportfunktionen. Ein zusätzlicher Slingload-Seed wird erst angelegt, wenn MOOSE die erforderliche physische Konfiguration nicht am vorhandenen Seed setzen kann.

Gleichzeitig zulässig:

```text
1 aktiver CH-47F-Client
+ 1 aktiver CH-47-AI
= 2 lokale CH-47
```

Nach einem bestätigten CH-47-Verlust muss die parallele Verfügbarkeit entsprechend reduziert werden.

### 8.4 Übergreifende Einsatzgrenzen

Es gelten weiterhin Dokument 18 und die globale Supportgrenze:

```text
maxAIAircraftPerTypeAndBase = 4
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Ein Auftrag darf keine Luftfahrzeuge allein deshalb erzeugen, weil ein Template vorhanden ist.

## 9. Safe-Parking- und Blacklist-Vertrag

### 9.1 Bestätigte harte Reservierungen

Folgende Parking-IDs sind ausschließlich für Clients reserviert und für AI zu sperren:

```text
C01-H
C05-H
C07-H
```

### 9.2 Statische Ausschlüsse

Die zwölf statischen Luftfahrzeuge besitzen keine `parking_id`. Ihre exakten Koordinaten stehen im Audit. Die Parking-Implementierung muss deshalb zusätzlich zur ID-Blacklist geometrisch prüfen:

- Abstand eines Kandidaten zur Position jedes Statics;
- Rotor- und Rumpffreigang für den konkreten Typ;
- Abstand zu aktiven Clients und KI-Gruppen;
- freie Abroll- beziehungsweise Abflugrichtung;
- keine Überschneidung mit Warehouse-Anker, Gebäuden, Rollwegen oder Funktionszonen.

Die konkrete Mindestdistanz ist in DCS zu validieren und darf nicht aus Mittelpunktabständen allein abgeleitet werden.

### 9.3 Flächenpräferenz

| Bereich | vorgesehene Verwendung | Status |
|---|---|---|
| `C01-H` bis `C21-H` | AH-64/UH-60-Rampe, vorhandene Clients und Statics, ausgewählte AI-Parkings | teilweise belegt; vollständige sichere ID-Liste offen |
| `K01` bis `K09` | bevorzugte CH-47-/Rotary-Staging- und Overflow-Fläche | in DCS noch zu validieren |
| `G01` bis `G03` | transienter Fixed-Wing-Verkehr und C-130-Kompatibilitätstests | nicht für lokale Rotary-SQUADRON reservieren |

### 9.4 Fehlerverhalten

Wenn kein sicherer Parkplatz vorhanden ist:

- kein Teleport in belegte oder unsichere Position;
- kein Spawn auf Client-Parkplätzen;
- Auftrag bleibt `PENDING_NO_SAFE_PARKING` oder wird kontrolliert abgelehnt;
- Ursache, Typ, benötigte Gruppengröße und geprüfte Parking-IDs werden protokolliert;
- keine Bestandsabbuchung ohne erfolgreiche Reservierung;
- bei teilweiser Two-Ship-Reservierung vollständiges Rollback.

### 9.5 Zu erstellender Parking-Testdatensatz

Die technische Parking-Validierung muss je ID mindestens speichern:

```yaml
parkingId: string
internalParkingIndex: integer|null
allowedTypes: []
clientReserved: boolean
staticConflict: boolean
taxiOrRotorConflict: boolean
spawnTest: PASS|FAIL|NOT_TESTED
returnTest: PASS|FAIL|NOT_TESTED
notes: string|null
```

Erst nach diesem Test darf eine positive AI-Allowlist oder vollständige Blacklist als akzeptiert gelten.

## 10. Verlust-, Rückgabe- und Reconciliation-Logik

### 10.1 Zustände

```text
AVAILABLE
RESERVED_CLIENT
RESERVED_AI
ACTIVE_CLIENT
ACTIVE_AI
RETURNING
MAINTENANCE
STRANDED
UNRESOLVED
DESTROYED
```

`DESTROYED` ist endgültig. Automatischer Ersatz ist nicht zulässig.

### 10.2 Client-Lebenszyklus

```text
AVAILABLE
→ RESERVED_CLIENT
→ ACTIVE_CLIENT
→ RETURNING
→ AVAILABLE oder MAINTENANCE
```

Regeln:

- Reservierung erst bei tatsächlicher Client-Materialisierung;
- unbesetzter Slot verbraucht keinen Airframe;
- sichere Rückgabe nur nach bestätigter Landung auf Tarinkot und nachvollziehbarem Ende des aktiven Luftfahrzeugs;
- Disconnect in der Luft führt nicht zu sofortiger Rückgabe;
- verschwindendes Luftfahrzeug ohne eindeutiges Rückkehr- oder Verlustereignis wird `UNRESOLVED`;
- Crash, Tod, Ejection mit aufgegebenem Luftfahrzeug oder bestätigtes `DEAD` führt nach Ereignis-Deduplizierung zu `DESTROYED`;
- Rückkehr auf einer anderen Basis führt zu `STRANDED` oder Transferstatus, nicht zu Tarinkot-`AVAILABLE`.

### 10.3 AI-Lebenszyklus

```text
AVAILABLE
→ RESERVED_AI
→ ACTIVE_AI
→ RETURNING
→ AVAILABLE oder MAINTENANCE
```

Regeln:

- Gruppenreservierung entspricht der Template-Größe;
- fehlgeschlagener Spawn gibt die gesamte Reservierung zurück;
- erfolgreiche Heimkehr und ordnungsgemäße MOOSE-Rückgabe darf genau einmal gutschreiben;
- CampaignState und MOOSE-SQUADRON dürfen dieselbe Rückkehr nicht doppelt buchen;
- Landung auf Fremdbasis bleibt `STRANDED` beziehungsweise erzeugt eine explizite Transferentscheidung;
- zerstörte oder aufgegebene Luftfahrzeuge werden einzeln dauerhaft abgezogen;
- bei einem Two-Ship kann ein überlebendes Luftfahrzeug zurückgegeben werden, während das andere verloren ist.

### 10.4 Static-Verluste

Jedes benannte Tarinkot-Static ist einer Musterfamilie zugeordnet. Nach bestätigtem `DEAD`-Ereignis:

- genau ein lokaler Airframe-Verlust;
- Static bleibt zerstört beziehungsweise wird nicht automatisch ersetzt;
- kein zusätzlicher Verlust durch mehrfach eintreffende DCS-Ereignisse;
- Abgleich mit Persistenz beim nächsten Missionsstart.

### 10.5 Idempotenz und Schlüssel

Jede Reservierung und jedes Verlust-/Rückgabeereignis benötigt mindestens:

```yaml
locationCode: TKOT
aircraftFamily: AH64D|UH60|CH47
sourceKind: CLIENT|AI|STATIC
sourceName: string
missionOrReservationId: string|null
eventKey: string
timestamp: number
processed: boolean
```

Ein `eventKey` darf nur einmal bestandswirksam verarbeitet werden.

### 10.6 Missionsneustart

Beim Neustart:

1. persistierten nominalen Restbestand laden;
2. persistierte dauerhafte Verluste anwenden;
3. alte aktive Reservierungen als `UNRESOLVED` markieren, nicht automatisch als verfügbar buchen;
4. aktuellen Missionseditorbestand gegen den Ledger prüfen;
5. keine Statics materialisieren, deren zugrunde liegender Bestand bereits verloren ist;
6. Inkonsistenzen als Startfehler oder dokumentierten Degraded-State behandeln.

## 11. Flugplatzspezifische Funktionszonen

Im geprüften `.miz` existieren noch keine `ZONE_AIR_US_TKOT_*`-Zonen. Folgende Zonen sind verbindlich anzulegen, bevor die jeweilige Funktion implementiert wird:

| Zone | technische Funktion | vorgesehener Bereich | Status |
|---|---|---|---|
| `ZONE_AIR_US_TKOT_AH64_RAMP` | AH-64-Rückkehr, Rampenbelegung, Static-/Parking-Abgleich | AH-64-Anteil der C-Rampe | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_UH60_RAMP` | UH-60-Rückkehr und Bestandserkennung | UH-60-Anteil der C-Rampe | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_MEDEVAC_READY` | Lead-/Cover-Staging und Package-Start | zwei sichere UH-60-Positionen | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_CH47_READY` | CH-47-Bereitstellung und Rückkehr | bevorzugt K-Rampe | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_ROTARY_STAGING` | temporäre Verstärkung, Overflow und Air-Assault-Staging | freie K-Positionen | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_LOGISTICS_LOAD` | OPSTRANSPORT-Aufnahme und Manifestübergabe | nahe Warehouse, rollwegfrei | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD` | Entladung und CampaignState-Übergabe | getrennt von Load-Zone | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_HELO_RECOVERY` | beschädigte Rückkehr, AOG-/Recovery-Übergabe | freie sichere Rotary-Fläche | `REQUIRED_NOT_CREATED` |
| `ZONE_AIR_US_TKOT_TRANSIENT_FIXED_WING` | C-130-/Transport-Transit ohne lokale SQUADRON | G01–G03 | `REQUIRED_NOT_CREATED` |

Zonen werden nicht allein zur optischen Gruppierung angelegt. Jede Zone benötigt:

- dokumentierte Position und Radius beziehungsweise Polygon;
- genau benannten technischen Verbraucher;
- Kollisionsprüfung gegen Statics und Parkplätze;
- eigenen Acceptance-Test;
- keine Überschneidung, die gleichzeitig widersprüchliche Übergaben auslösen kann.

## 12. Noch offene technische Entscheidungen

Nicht durch dieses Manifest als Laufzeit-PASS bestätigt:

- exakter MOOSE-Konstruktor- und Methodenaufruf im gepinnten Stand;
- genaue positive AI-Parking-Allowlist;
- Rotorfreigang je Parking-ID;
- K01–K09-Eignung für CH-47-Spawn und Rückkehr;
- G01–G03-Eignung für C-130;
- Payload-Registrierung der AH-64A-, UH-60A- und CH-47D-KI-Ersatztypen;
- AIRWING-Rückgabe nach normaler Landung;
- Client-Disconnect- und Reconnect-Verhalten;
- Static-`DEAD`-Ereigniszuordnung;
- Persistenz und Missionsneustart;
- Position und Größe aller Funktionszonen.

## 13. Mindest-Acceptance für Tarinkot

Vor produktiver Aktivierung sind mindestens folgende Tests erforderlich:

1. `WH_AIR_US_TARINKOT` wird eindeutig gefunden;
2. Airbase-ID 9 wird korrekt zu Tarinkot aufgelöst;
3. `AW_US_TARINKOT` startet genau einmal;
4. alle drei SQUADRONs werden mit korrektem Gruppenlimit registriert;
5. AH-64-Two-Ship findet zwei sichere Parkplätze oder startet kontrolliert nicht;
6. MEDEVAC reserviert und startet Lead plus Cover atomar;
7. CH-47-AI und CH-47-Client überschreiten gemeinsam nie zwei Airframes;
8. Client-Parkplätze C01-H, C05-H und C07-H werden niemals von AI belegt;
9. Statics werden geometrisch als Parking-Hindernisse erkannt;
10. AI kehrt auf sicheren Parkplatz zurück und wird genau einmal gutgeschrieben;
11. Fremdbasislandung führt nicht zur Tarinkot-Rückgabe;
12. Crash, Ejection, Static-Verlust und Airborne-Disconnect werden korrekt klassifiziert;
13. kein Ereignis verursacht Doppelverlust oder Doppelrückgabe;
14. Zonenübergaben funktionieren getrennt für MEDEVAC, Logistik und Recovery;
15. Mission-, Bundle-, Commit-, DCS- und MOOSE-Version werden im Testbericht festgehalten.

## 14. Verbindlicher aktueller Abnahmestand

Strukturell abgenommen:

```text
8 AH-64-Statics
4 UH-60-Statics
0 CH-47-Statics
2 AH-64D-Clients
1 CH-47F-Client
4 Late-Activation-KI-Seeds
1 technischer Warehouse-Anker
```

Nicht abgenommen:

```text
AIRWING-Runtime
SQUADRON-Runtime
AUFTRAG/OPSTRANSPORT
Safe Parking
AI-Rückkehr
Verlust-/Rückgabelogik
Funktionszonen
```

Dieses Manifest liefert für diese noch zu erstellenden Funktionen den verbindlichen Implementierungsvertrag; es behauptet keinen bereits bestandenen DCS-/MOOSE-Laufzeittest.