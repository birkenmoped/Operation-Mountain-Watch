---
document_id: OMW-AIR-SHINDAND-IMPLEMENTATION-HANDOFF
status: BINDING
document_class: IMPLEMENTATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - Shindand Mission Editor structural baseline
  - Shindand AIRWING and SQUADRON implementation requirements
  - Shindand Warehouse detection and parking policy
  - Shindand AUFTRAG role mapping
  - Shindand loss return and inventory handoff requirements
  - Shindand functional zone plan
not_authoritative_for:
  - active Shindand ORBAT values defined by OMW-AIR-SHINDAND-MANIFEST
  - project-wide AIRWING architecture defined by OMW-AIR-IMPLEMENTATION
  - DCS runtime acceptance not explicitly proven here
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - undocumented Shindand Mission Editor structural state
superseded_by:
source_branch: agent/document-shindand-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
source_mission: OMW_Template(2).miz
source_mission_sha256: 645f09b21793324a1df4d442fbaeffc0d1a2ee7c97f6453a4c3a97dde82c6e00
source_mission_inner_sha256: 991ca54f076478b47bec2cc7899eb011733e12a1a665af0c4933a982f2a906db
source_runtime_script_sha256: 294e0d69ecb1d647bc67e20083da34a1a121c048fc0e11f8d57405c86b5d584f
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
structural_validation_status: PASS
runtime_validation_status: NOT_RUN
---

# Shindand Air Operations Implementation Handoff

## 1. Zweck und Abgrenzung

Dieses Dokument übergibt den fachlich und im Missionseditor vorbereiteten Shindand-Knoten an die noch ausstehende MOOSE-Laufzeitimplementierung.

Die verbindliche ORBAT, Client-, Template-, Static- und Ersatzmodellentscheidung steht in:

- [`OMW-AIR-SHINDAND-MANIFEST`](shindand-air-operations-manifest.md).

Die gemeinsamen technischen Regeln stehen in:

- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md);
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md).

Dieses Dokument behauptet keinen DCS-Laufzeit-PASS. Die Missionsdatei wurde strukturell aus dem `.miz`-Archiv geprüft. Ein kontrollierter Shindand-AIRWING-Lauf, ein Parking-Dump und ein vollständiger `dcs.log` liegen noch nicht vor.

## 2. Aktueller Missionseditorstand

### 2.1 Provenienz

```yaml
mission_file: OMW_Template(2).miz
mission_file_sha256: 645f09b21793324a1df4d442fbaeffc0d1a2ee7c97f6453a4c3a97dde82c6e00
inner_mission_sha256: 991ca54f076478b47bec2cc7899eb011733e12a1a665af0c4933a982f2a906db
TM01M_lua_sha256: 294e0d69ecb1d647bc67e20083da34a1a121c048fc0e11f8d57405c86b5d584f
Moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
structural_result: PASS
dcs_runtime_result: NOT_RUN
```

### 2.2 Strukturell bestätigte Objekte

```text
4 Client-Gruppen / 4 Client-Units
5 KI-Templategruppen / 6 Template-Units
9 Luftfahrzeug-Statics
1 Warehouse-Anker
0 Shindand-spezifische Funktionszonen
```

Bestätigt wurden:

- alle vier Clientgruppen mit je einer Unit;
- alle fünf KI-Templates mit den vorgesehenen sechs Units;
- `Late Activation = true` für alle fünf KI-Templates;
- `Uncontrolled = false` für alle fünf KI-Templates;
- alle neun vorgesehenen Shindand-Luftfahrzeug-Statics;
- `WH_AIR_US_SHINDAND` als benanntes Missionsobjekt;
- der korrigierte Unitname `TPL_AIR_US_SHND_UH60_UTILITY_1SHIP_UNIT_01`;
- AH-64A als gewolltes Vanilla-KI-/Static-Ersatzmodell ohne Longbow-Radar;
- keine Shindand-spezifische Runtime-Registrierung im vorhandenen Missionsskript;
- keine Shindand-spezifischen Triggerzonen.

## 3. AIRWING-Registrierung

### 3.1 Verbindliche Identitäten

```yaml
airwing_name: AW_US_SHINDAND
warehouse_anchor: WH_AIR_US_SHINDAND
dcs_airdrome_id_observed: 14
dcs_airbase_name: RUNTIME_CONFIRMATION_REQUIRED
operational_node: Shindand Air Base
site_code: SHND
```

Shindand erhält genau einen US-Army-Aviation-AIRWING für die in diesem Manifest ausgewählten Bestände. Afghanischer Ausbildungsbetrieb oder andere Koalitionskomponenten erzeugen ohne eigene Projektentscheidung keinen parallelen Zugriff auf denselben Bestand.

### 3.2 Initialisierungsreihenfolge

Die Laufzeitimplementierung muss in dieser Reihenfolge arbeiten:

1. eingebundene MOOSE-Version, Commit und Hash protokollieren;
2. `WH_AIR_US_SHINDAND` als benanntes Missionsobjekt auflösen;
3. Shindand über die beobachtete `airdromeId = 14` und den von DCS/MOOSE gelieferten Namen auflösen;
4. Warehouse-Koordinate und Airbase-Koordinate protokollieren;
5. Plausibilitätsprüfung durchführen, damit der Anker nicht an einen anderen Flugplatz gebunden wird;
6. `AW_US_SHINDAND` erzeugen und explizit mit dem bestätigten Warehouse-/Airbase-Bezug verbinden;
7. Payloads und SQUADRONs registrieren;
8. Safe-Parking-Regeln anwenden;
9. AIRWING starten, ohne beim Start automatisch taktische Missionen zu erzeugen;
10. erst danach Aufträge durch CampaignState, MissionDemand oder einen ausdrücklich freigegebenen Testgenerator zuführen.

Fehler beim Auflösen von Warehouse oder Airbase werden **fail closed** behandelt:

```text
kein Fallback auf einen anderen Flugplatz
kein AIRWING-Start mit unbekannter Basis
keine automatische Missionserzeugung
klarer ERROR-Logeintrag mit Objektname, Airbase-ID und Koordinaten
```

### 3.3 MOOSE-first-Pflicht

Vor Codeerstellung sind die tatsächlich verfügbaren Klassen, Konstruktoren und Methoden gegen den im Projekt eingebundenen MOOSE-Stand zu prüfen. Dies betrifft mindestens:

- `AIRWING`;
- `SQUADRON`;
- `AUFTRAG`;
- `FLIGHTGROUP`;
- `OPSTRANSPORT`;
- Warehouse-/Airbase-Auflösung;
- Safe Parking und Parking-Blacklists;
- Event- und Recovery-Lifecycle.

Eigene Adapterlogik darf nur den nachgewiesenen Restbedarf abbilden.

## 4. SQUADRON-Bestandsverwaltung

### 4.1 Verbindliche logische SQUADRONs

| SQUADRON | logischer Bestand | primäre Templates | Rolle |
|---|---:|---|---|
| `SQ_US_SHND_AH64D_ATTACK` | 8 AH-64D | `TPL_AIR_US_SHND_AH64D_CAS_2SHIP` | CAS, Attack, Escort, Armed Overwatch |
| `SQ_US_SHND_UH60_UTILITY_MEDEVAC` | 8 UH-60 gesamt | Utility, MEDEVAC Lead und MEDEVAC Cover | Utility, Air Assault und koordiniertes MEDEVAC |
| `SQ_US_SHND_CH47_HEAVYLIFT` | 4 CH-47 | `TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP` | Heavy Lift, Truppen- und Frachttransport |

Es werden keine erfundenen Company-/Battalion-Bezeichnungen in den SQUADRON-Namen verwendet.

### 4.2 Templategröße und Gruppenrechnung

```text
AH-64:
  Templategröße 2
  logischer Gesamtbestand 8
  theoretisch 4 Two-Ship-Gruppen

UH-60:
  Templategröße 1
  logischer Gesamtbestand 8
  maximal 8 Single-Ship-Gruppen über den gemeinsamen Pool

CH-47:
  Templategröße 1
  logischer Gesamtbestand 4
  theoretisch 4 Single-Ship-Gruppen
```

`Ngroups` in `SQUADRON:New(...)` bezeichnet Gruppen und nicht einzelne Luftfahrzeuge.

### 4.3 Konservative Anfangsfreigabe ohne dynamische Static-Verteilung

Solange sichtbare Statics und Clientrepräsentationen nicht dynamisch gegen den CampaignState ein- und ausgeblendet werden, darf die gleichzeitig spawnfähige KI-Grundmenge den zunächst verbleibenden Bestand nicht überschreiten:

```yaml
initial_ai_spawnable_without_static_redistribution:
  AH64D_aircraft: 2
  UH60_aircraft: 4
  CH47_aircraft: 1
```

Daraus folgt zunächst:

```text
AH-64: maximal 1 Two-Ship-Gruppe
UH-60: maximal 4 Single-Ships, zusätzlich begrenzt durch globale Supportgrenzen
CH-47: maximal 1 Single-Ship
```

Eine spätere Registrierung des vollständigen logischen Bestands als spawnfähige MOOSE-Ressource ist erst zulässig, wenn:

- Clientbelegung gegen denselben Bestand reserviert wird;
- sichtbare Statics bei Nutzung des repräsentierten Bestands korrekt entfernt oder umverteilt werden;
- Rückkehr und Verlust idempotent in CampaignState gebucht werden;
- kein Airframe gleichzeitig als Static, Client und KI aktiv erscheinen kann.

### 4.4 Gemeinsamer UH-60-Pool

Die drei vorhandenen UH-60-Templates dürfen nicht als drei unabhängige SQUADRON-Bestände mit jeweils acht Maschinen registriert werden.

```text
UTILITY
MEDEVAC_LEAD
MEDEVAC_COVER
→ ein gemeinsamer Bestand von insgesamt 8 UH-60
```

Vor Implementierung ist MOOSE-first zu prüfen, ob:

1. ein primäres Single-Ship-Template mit unterschiedlichen `AUFTRAG`-/FLIGHTGROUP-Einstellungen genügt;
2. mehrere Templates innerhalb einer SQUADRON sicher verwendet werden können;
3. technisch getrennte SQUADRON-Objekte nur über eine gemeinsame CampaignState-Obergrenze zusammengefasst werden müssen.

Bis zu dieser Prüfung wird keine Lösung vorweggenommen, die den Bestand dupliziert.

### 4.5 Bestandsfelder und Invarianten

Für jede logische SQUADRON werden mindestens getrennt geführt:

```yaml
initial_inventory:
available:
reserved:
active:
damaged:
lost_permanent:
client_reserved:
static_represented:
quarantined:
```

Verbindliche Invarianten:

```text
Initialbestand wird nie durch Templates oder Statics erhöht.
Client- und KI-Reservierungen greifen auf denselben lokalen Bestand zu.
Eine Reservierung darf nur einmal aktiv sein.
Ein Verlust darf nur einmal abgezogen werden.
Eine Rückgabe darf nur eine vorherige Reservierung oder aktive Maschine freigeben.
MEDEVAC Lead und Cover reservieren zwei Maschinen aus demselben UH-60-Pool.
```

Technische Grenzen:

```text
maximal 4 gleichzeitig aktive KI-Luftfahrzeuge je Muster und Basis
maximal 2 gleichzeitige taktische Supportmissionen missionsweit
maximal 2 Luftfahrzeuge je Supportmission
maximal 4 taktische Support-Luftfahrzeuge gleichzeitig
```

## 5. Warehouse-Erkennung

### 5.1 Vorhandener Missionseditor-Anker

```yaml
object_name: WH_AIR_US_SHINDAND
observed_dcs_object_type: container_40ft
observed_category: Fortifications
coordinate_x: -63332.072378192
coordinate_y: -368169.94400035
purpose: MOOSE AIRWING and Warehouse anchor
```

Der Anker ist ein technisches Missionsobjekt und kein zusätzlicher Luftfahrzeugbestand.

### 5.2 Autorität des Bestands

Das native DCS-Warehouse der beobachteten Airbase-ID 14 ist in der geprüften Mission nicht als begrenzter Kampagnenbestand eingerichtet. Daher gilt:

```text
CampaignState / SQUADRON-Ledger = autoritative Airframe-Buchführung
DCS-Warehouse = Treibstoff-/Munitions-/Terrainfunktion nach gesonderter Konfiguration
Warehouse-Anker = technischer AIRWING-Bezug
```

Ein unbegrenztes DCS-Warehouse darf verlorene Luftfahrzeuge nicht implizit ersetzen.

### 5.3 Erforderlicher Diagnosetest

Der erste Laufzeittest muss mindestens protokollieren:

```text
Objekt gefunden: ja/nein
DCS-Kategorie und Typ
Koordinate des Warehouse-Ankers
aufgelöste Airbase-ID
aufgelöster DCS-/MOOSE-Airbase-Name
Entfernung Anker ↔ Airbase-Referenz
AIRWING-Konstruktion erfolgreich: ja/nein
AIRWING-Start erfolgreich: ja/nein
```

Ein vorhandener Name im `.miz` beweist noch nicht, dass MOOSE ihn in der gewählten Konstruktor- und Airbase-Kombination akzeptiert.

## 6. AUFTRAG-Ausführung

### 6.1 Rollenmatrix

| Bedarf / MissionDemand | bevorzugte SQUADRON | bestehendes Seed-Template | Standardpaket |
|---|---|---|---:|
| CAS / Attack | AH-64D Attack | `TPL_AIR_US_SHND_AH64D_CAS_2SHIP` | 2 |
| Escort / Armed Overwatch | AH-64D Attack | gleiches AH-64-Template | 2 |
| Utility Transport | UH-60 Utility/MEDEVAC | `TPL_AIR_US_SHND_UH60_UTILITY_1SHIP` | 1 oder 2 |
| Air Assault | UH-60 Utility/MEDEVAC | gleiches Utility-Template | 2 |
| MEDEVAC | UH-60 Utility/MEDEVAC | Lead- und Cover-Seed | 1 Lead + 1 Cover |
| Heavy Lift / Cargo | CH-47 Heavy Lift | `TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP` | 1 oder 2, lokal anfangs höchstens 1 KI-Asset |
| Slingload | CH-47 Heavy Lift | gleiches CH-47-Template | 1 |

### 6.2 MOOSE-first-Regeln

Vor weiteren Mission-Editor-Templates ist zu prüfen, ob Rollenunterschiede durch folgende MOOSE-Mittel ausreichend abgebildet werden:

- `AUFTRAG`-Typ und Zielzuweisung;
- Payload-Registrierung und Payloadauswahl;
- ROE und Alarm State;
- FLIGHTGROUP-Optionen;
- Formation und Paketgröße;
- `OPSTRANSPORT` für Truppen und Fracht;
- Cargo- und Slingload-Unterstützung.

Daher bleiben zunächst ausgeschlossen:

```text
kein separates AH-64-Escort-Template
kein separates UH-60-Air-Assault-Template ohne technischen Nachweis
kein separates CH-47-Slingload-Template
keine automatisch erzeugten Missionen beim AIRWING-Start
```

### 6.3 Payloadstatus

Die vorhandene Struktur ist nicht als endgültige Payloadbaseline abgenommen. Vor AUFTRAG-Tests sind festzulegen und zu registrieren:

- AH-64D-Spieler- und AH-64A-KI-CAS-Payloads;
- CH-47F-Türbewaffnung beziehungsweise bewusst unbewaffnete Konfiguration;
- Treibstoff- und Munitionswerte;
- zulässige Payloads je Rolle;
- Fallback bei nicht verfügbarer Modul- oder Waffenvariante.

## 7. Safe Parking und Blacklists

### 7.1 Verbindlich gesperrte Clientpositionen

Technische DCS-Parkingwerte:

```text
6, 8, 12, 28
```

```lua
shindandClientParkingBlacklist = {
  6,
  8,
  12,
  28,
}
```

Diese IDs dürfen weder für dynamische KI noch für Rückkehr-/Recovery-Spawns freigegeben werden, solange ein entsprechender Client-Slot existiert.

### 7.2 Sichtbare Missionseditorbezeichnungen

| technischer `parking`-Wert | sichtbare ME-Parkingbezeichnung | Verwendung |
|---:|---:|---|
| 6 | 09 | AH-64D Client 01 |
| 8 | 06 | AH-64D Client 02 |
| 12 | 40 | CH-47F Client 01 |
| 28 | 38 | CH-47F Client 02 |

Die sichtbare Parkplatznummer darf nicht anstelle der technischen TerminalID in Code oder Blacklists verwendet werden.

### 7.3 Zusätzlich zu ermittelnde Listen

Noch nicht bekannt sind die TerminalIDs der durch Statics belegten oder funktional gesperrten Rampenstände. Nach einem Shindand-spezifischen Parking-Dump werden getrennt geführt:

```yaml
client_reserved_ids:
static_occupied_ids:
maintenance_or_transient_ids:
hot_refuel_ids:
validated_ai_allowed_ids_by_aircraft_size:
```

### 7.4 Größen- und Funktionsregeln

- CH-47 darf nur auf Heavy-Lift-tauglichen Positionen verwendet werden.
- AH-64 und UH-60 erhalten typ- beziehungsweise größenkompatible Kandidatenlisten.
- Statics dürfen keine Spawn-, Taxi-, Recovery- oder Rotorflächen blockieren.
- Hot-Refueling-Flächen sind keine dauerhaften Spawn- oder Recoverypositionen.
- Safe Parking muss mit mehreren gleichzeitig zurückkehrenden Gruppen getestet werden.
- Funktionszonen ersetzen keine TerminalID-Blacklist.

### 7.5 Erforderlicher Parking-Diagnoselauf

Der Diagnoselauf muss mindestens liefern:

```text
alle Parking-/Helipad-IDs von Shindand
Koordinaten und Terminaltypen
Abstand zu Clientgruppen und Statics
Zuordnung Static ↔ nächster Parking-Spot
Größeneignung je AH-64/UH-60/CH-47
finale AI-Allowlist
finale Blacklist mit Begründung
```

## 8. Verlust- und Rückgabelogik

### 8.1 Grundsatz

```lua
lossPolicy = "PERMANENT"
replacementPolicy = "NONE"
```

Bestätigte Verluste reduzieren den lokalen Bestand dauerhaft. Es gibt keinen automatischen Ersatz.

### 8.2 Zustandsfolge

```text
AVAILABLE
  → RESERVED
  → ACTIVE
  → RETURNED
  → AVAILABLE
```

Mögliche Abzweigungen:

```text
RESERVED → RELEASED → AVAILABLE
ACTIVE → DAMAGED
ACTIVE → LOST_PERMANENT
ACTIVE → QUARANTINED
```

### 8.3 Rückgabe

Ein KI- oder Client-Asset darf erst zurückgegeben werden, wenn die gewählte MOOSE-/DCS-Ereigniskette reproduzierbar bestätigt, dass:

1. die Maschine zur vorgesehenen Basis zurückgekehrt ist;
2. kein zerstörtes oder aufgegebenes Luftfahrzeug als erfolgreich zurückgegeben gilt;
3. die Reservierung genau einmal freigegeben wird;
4. eine beschädigte Landung nicht automatisch als voll einsatzbereite Rückgabe gilt;
5. Mehrfachereignisse wie `LAND`, `ENGINE_SHUTDOWN`, Despawn und AIRWING-Recovery nicht mehrfach buchen.

### 8.4 Verlust

Ein permanenter Verlust benötigt:

```text
eindeutige Asset-/Gruppenidentität
eindeutige Zuordnung zur SQUADRON und lokalen Basis
idempotente Ereignisverarbeitung
genau eine Bestandsminderung
CampaignState-Protokollierung mit Ursache und Zeit
```

Zu testen sind mindestens:

- Zerstörung im Flug;
- Ejection und anschließende Zerstörung;
- Crash bei Start oder Landung;
- zerstörter CH-47 nach erfolgreichem Ausladen;
- Verlust von MEDEVAC Lead oder Cover;
- Spieler-Disconnect in der Luft;
- Spieler-Disconnect am Boden;
- beschädigte Rückkehr;
- Missionsabbruch vor Spawn;
- Spawnfehler wegen fehlender sicherer Parkposition;
- zerstörtes Static mit eindeutiger Kampagnenzuordnung.

Ein zerstörtes Static darf erst nach eindeutiger Ereignis- und Bestandszuordnung genau einen logischen Airframe abziehen.

### 8.5 Client-Reservierung

Client-Slots reservieren nicht dauerhaft zusätzliche Luftfahrzeuge. Die Laufzeitlogik muss den tatsächlichen Beitritt, Spawn, Verlust, Disconnect und die sichere Rückgabe gegen denselben lokalen Bestand buchen.

Ein leerer Client-Slot darf den KI-Bestand nicht unbegrenzt blockieren, sofern die Architektur eine sichere dynamische Reservierung unterstützt. Bis dieser Ablauf getestet ist, gilt die konservative Authoring-Aufteilung des Manifests.

## 9. Shindand-spezifische Funktionszonen

### 9.1 Aktueller Zustand

Die geprüfte Mission enthält:

```text
0 Shindand-spezifische Funktionszonen
```

Das ist für den reinen Missionseditor-Grundaufbau zulässig, reicht aber nicht für die vollständige MEDEVAC-, Logistik- und Transportfunktion.

### 9.2 Minimal erforderliche Produktionszonen

Folgende Zonen sind vor Aktivierung der jeweiligen Funktion im Missionseditor anzulegen und geometrisch zu dokumentieren:

| Zonenname | Status | Zweck |
|---|---|---|
| `ZONE_AIR_US_SHND_MEDEVAC_READY` | erforderlich vor MEDEVAC | Bereitschafts- und Paketbildungsbereich für Lead/Cover |
| `ZONE_AIR_US_SHND_MEDEVAC_TRANSFER` | erforderlich vor Patienten-/CSAR-Übergabe | Übergabe geretteter oder verwundeter Personen an die medizinische Einrichtung |
| `ZONE_AIR_US_SHND_LOGISTICS_LOAD` | erforderlich vor OPSTRANSPORT | Aufnahme von Truppen oder interner Fracht |
| `ZONE_AIR_US_SHND_LOGISTICS_UNLOAD` | erforderlich vor OPSTRANSPORT-Rückgabe | Entladung und Übergabe eingehender Fracht oder Truppen |

### 9.3 Bedingt erforderliche Zonen

| Zonenname | nur anlegen, wenn | Zweck |
|---|---|---|
| `ZONE_AIR_US_SHND_SLING_PICKUP` | Slingload technisch umgesetzt wird | Außenlast-Aufnahmepunkt außerhalb regulärer Parkpositionen |
| `ZONE_AIR_US_SHND_HOT_REFUEL` | Hot-Refueling funktional simuliert wird | ausschließlich transienter Refueling-/Turnaround-Bereich |
| `ZONE_AIR_US_SHND_HEAVYLIFT_LOAD` | CH-47-Ladefläche von `LOGISTICS_LOAD` getrennt werden muss | CH-47-spezifischer Lade- und Stagingbereich |
| `ZONE_AIR_US_SHND_TEST_SAFETY` | nur im Testharness | kontrollierter Diagnose-/Sicherheitsbereich |

### 9.4 Nicht vorsorglich anzulegende Zonen

Ohne konkreten technischen Verbraucher werden nicht angelegt:

```text
keine STATIC-Reihenzonen nur zur optischen Gruppierung
keine generische AI_RESERVE-Zone
keine generische AI_SPAWN-Zone bei nativer AIRWING-/Airbase-Parking-Nutzung
keine generische RECOVERY-Zone bei nativer Airbase-Rückkehr
keine Zone als Ersatz für Parking-IDs oder Blacklists
```

### 9.5 Platzierungsanforderungen

Für jede angelegte Zone sind zu dokumentieren:

```yaml
name:
purpose:
shape:
center_coordinate:
radius_or_vertices:
associated_moose_consumer:
allowed_aircraft_types:
conflicting_parking_ids:
conflicting_statics:
validation_test:
```

Zonen dürfen sich nicht unbeabsichtigt mit Clientpositionen, statisch belegten Pads, Rotorflächen, Taxiwegen oder Sicherheitsachsen überschneiden.

## 10. Noch fehlende Implementierungsartefakte

Für einen vollständigen Shindand-Laufzeitstand fehlen weiterhin:

1. Shindand-spezifische Lua-Konfiguration oder ein eigenes Modul;
2. bestätigte MOOSE-Aufrufe für AIRWING, SQUADRON, Payloads, Parking und AUFTRAG;
3. Shindand-Airbase-/Parking-Diagnoselog;
4. Warehouse-Probe;
5. finale AI-Allowlist und Parking-Blacklist;
6. die vier minimal erforderlichen Funktionszonen;
7. CampaignState-Adapter für Reservierung, Rückgabe und permanenten Verlust;
8. idempotente Ereignisverarbeitung;
9. AUFTRAG-/OPSTRANSPORT-Testfälle;
10. kontrollierter DCS-Lauf mit `dcs.log`;
11. Mission-, Bundle-, DCS-, MOOSE- und Commit-Provenienz;
12. Multiplayer- und Langzeittest;
13. dynamische Static-/Rampenumverteilung oder eine dauerhaft konservative KI-Kapazitätsentscheidung.

## 11. Verbindliche Implementierungsreihenfolge

```text
1. Shindand Airbase, Warehouse und Parking diagnostizieren
2. Funktionszonen im Missionseditor setzen
3. AIRWING ohne automatische Missionen registrieren
4. SQUADRONs und Payloads registrieren
5. Bestandsinvarianten und Safe Parking prüfen
6. je ein Template kontrolliert erzeugen und zurückführen
7. MEDEVAC-Lead/Cover-Paket testen
8. AUFTRAG-Rollen einzeln testen
9. OPSTRANSPORT und Heavy Lift testen
10. Client-Reservierung und Disconnect-Fälle testen
11. Verlust- und Rückgabelogik testen
12. dynamische Statics nur nach eigener Acceptance aktivieren
```

## 12. Acceptance-Grenze

Der aktuelle Stand ist:

```yaml
mission_editor_structure: PASS
object_names_and_counts: PASS
replacement_model_decisions: PASS
warehouse_anchor_present: PASS
client_parking_baseline: PASS
functional_zones_present: false
parking_allowlist_validated: false
moose_airwing_runtime: NOT_RUN
auftrag_execution: NOT_RUN
loss_and_return_logic: NOT_RUN
validated_in_dcs: false
```

Kein Abschnitt dieses Dokuments ersetzt die noch erforderlichen Laufzeittests.
