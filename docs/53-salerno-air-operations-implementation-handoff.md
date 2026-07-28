---
document_id: OMW-AIR-SALERNO-IMPLEMENTATION-HANDOFF
status: BINDING
document_class: IMPLEMENTATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - FOB Salerno Mission Editor revision 20 structural baseline
  - FOB Salerno AIRWING and SQUADRON implementation requirements
  - FOB Salerno Warehouse detection and parking policy
  - FOB Salerno AUFTRAG role mapping
  - FOB Salerno loss return and inventory handoff requirements
  - FOB Salerno functional zone plan
not_authoritative_for:
  - active Salerno ORBAT values defined by OMW-AIR-SALERNO-MANIFEST
  - project-wide AIRWING architecture defined by OMW-AIR-IMPLEMENTATION
  - DCS runtime acceptance not explicitly proven here
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - undocumented Salerno Mission Editor revision 20 structural state
superseded_by:
source_branch: agent/document-salerno-air-operations
source_commit: PENDING_MERGE
validated_in_dcs: false
source_mission: OMW_TEST_TM01M_MooseFirst(20).miz
source_mission_sha256: 3ddeebac888af7f613e9e914b64bc2c747fe0d8a2551813a56a88507f69e622a
source_mission_inner_sha256: 954d5dcc31087bdce333ab00c147d37b77c420b0bb772ca593e2c0fe3de69f99
source_runtime_script_sha256: 294e0d69ecb1d647bc67e20083da34a1a121c048fc0e11f8d57405c86b5d584f
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
structural_validation_status: PASS
runtime_validation_status: NOT_RUN
---

# 53 – FOB Salerno Air Operations Implementation Handoff

## 1. Zweck und Abgrenzung

Dieses Dokument übergibt den fachlich und im Missionseditor vorbereiteten FOB-Salerno-Knoten an die noch ausstehende MOOSE-Laufzeitimplementierung.

Die verbindliche ORBAT, Client-, Template-, Static- und Organisationsentscheidung steht in:

- [`OMW-AIR-SALERNO-MANIFEST`](51-salerno-air-operations-manifest.md).

Die gemeinsamen technischen Regeln stehen in:

- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md);
- [`OMW-AIR-MANIFEST-NAMING`](52-air-operations-manifest-naming-standard.md).

Dieses Dokument behauptet keinen DCS-Laufzeit-PASS. Die hochgeladene Revision 20 wurde strukturell aus dem `.miz`-Archiv geprüft. Ein zugehöriger kontrollierter `dcs.log`, eine bestätigte DCS-Version und ein reproduzierbarer AIRWING-Lauf liegen noch nicht vor.

## 2. Aktueller Missionseditorstand – Revision 20

### 2.1 Provenienz

```yaml
mission_file: OMW_TEST_TM01M_MooseFirst(20).miz
mission_file_sha256: 3ddeebac888af7f613e9e914b64bc2c747fe0d8a2551813a56a88507f69e622a
inner_mission_sha256: 954d5dcc31087bdce333ab00c147d37b77c420b0bb772ca593e2c0fe3de69f99
TM01M_lua_sha256: 294e0d69ecb1d647bc67e20083da34a1a121c048fc0e11f8d57405c86b5d584f
Moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
structural_result: PASS
dcs_runtime_result: NOT_RUN
```

### 2.2 Strukturell bestätigte Objekte

```text
6 Client-Gruppen / 6 Client-Units
5 KI-Templategruppen / 8 Template-Units
15 Luftfahrzeug-Statics
1 Warehouse-Anker
0 Salerno-spezifische Funktionszonen
```

Bestätigt wurden:

- alle sechs modfreien Clientgruppen mit je einer Unit;
- alle fünf KI-Templates mit den vorgesehenen acht Units;
- `Late Activation = true` für alle fünf KI-Templates;
- `Uncontrolled = false` für alle fünf KI-Templates;
- alle 15 vorgesehenen Salerno-Luftfahrzeug-Statics;
- `WH_AIR_US_SALERNO` als benanntes Missionsobjekt;
- keine doppelten Salerno-Gruppen-, Unit-, Group-ID- oder Unit-ID-Werte;
- keine Salerno-spezifische Runtime-Registrierung in `TM01M.lua`;
- keine Salerno-spezifischen Triggerzonen in Revision 20.

### 2.3 Aktuelle Client-Parkpositionen

Alle sechs Clients verwenden `airdromeId = 23` und starten cold von Parkingpositionen:

| Clientgruppe | DCS-Typ | Parking-ID | Status |
|---|---|---:|---|
| `CLIENT_US_SAL_AH64D_01` | `AH-64D_BLK_II` | 36 | exklusiv für Client reservieren |
| `CLIENT_US_SAL_AH64D_02` | `AH-64D_BLK_II` | 40 | exklusiv für Client reservieren |
| `CLIENT_US_SAL_OH58D_01` | `OH58D` | 22 | exklusiv für Client reservieren |
| `CLIENT_US_SAL_OH58D_02` | `OH58D` | 23 | exklusiv für Client reservieren |
| `CLIENT_US_SAL_CH47F_01` | `CH-47Fbl1` | 21 | exklusiv für Client reservieren |
| `CLIENT_US_SAL_CH47F_02` | `CH-47Fbl1` | 13 | exklusiv für Client reservieren |

Verbindliche Client-Blacklist für dynamische KI:

```lua
salernoClientParkingBlacklist = {
  13,
  21,
  22,
  23,
  36,
  40,
}
```

Diese Tabelle beschreibt die fachliche Reservierung. Der konkrete MOOSE-Aufruf zum Setzen sicherer Parkpositionen oder Blacklists ist vor Implementierung gegen den im Projekt gepinnten MOOSE-Stand zu verifizieren.

## 3. AIRWING-Registrierung

### 3.1 Verbindliche Identitäten

```yaml
airwing_name: AW_US_SALERNO
warehouse_anchor: WH_AIR_US_SALERNO
dcs_airdrome_id_observed: 23
dcs_airbase_name: RUNTIME_CONFIRMATION_REQUIRED
operational_node: FOB Salerno
physical_airfield_reference: Khost Airfield
```

FOB Salerno erhält genau einen Army-Aviation-AIRWING. Aus demselben physischen Standort wird ohne neue Projektentscheidung kein zweiter paralleler US-AIRWING für Khost erzeugt.

### 3.2 Initialisierungsreihenfolge

Die Laufzeitimplementierung muss in dieser Reihenfolge arbeiten:

1. gepinnte MOOSE-Version und Hash protokollieren;
2. `WH_AIR_US_SALERNO` als benanntes Missionsobjekt auflösen;
3. Khost über die beobachtete `airdromeId = 23` und den von DCS/MOOSE gelieferten Namen auflösen;
4. Warehouse-Koordinate und Airbase-Koordinate protokollieren;
5. Plausibilitätsprüfung durchführen, damit der Anker nicht versehentlich an einen anderen Flugplatz gebunden wird;
6. `AW_US_SALERNO` erzeugen und explizit mit dem bestätigten Warehouse-/Airbase-Bezug verbinden;
7. Payloads und SQUADRONs registrieren;
8. Safe-Parking-Regeln anwenden;
9. AIRWING starten, ohne beim Start automatisch taktische Missionen zu erzeugen;
10. erst danach Aufträge durch CampaignState, MissionDemand oder einen ausdrücklich freigegebenen Testgenerator zuführen.

Fehler beim Auflösen von Warehouse oder Airbase müssen **fail closed** behandelt werden:

```text
kein Fallback auf einen anderen Flugplatz
kein AIRWING-Start mit unbekannter Basis
keine automatische Missionserzeugung
klarer ERROR-Logeintrag mit Objektname, Airbase-ID und Koordinaten
```

## 4. SQUADRON-Bestandsverwaltung

### 4.1 Verbindliche SQUADRON-Tabelle

| SQUADRON | Template | Templategröße | logischer Bestand | MOOSE-Gruppen | Besonderheit |
|---|---|---:|---:|---:|---|
| `SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK` | `TPL_AIR_US_SAL_AH64D_CAS_2SHIP` | 2 | 8 | 4 | CAS, Attack, Escort, Overwatch |
| `SQ_US_SAL_OH58D_B_6_6_CAV` | `TPL_AIR_US_SAL_OH58D_RECON_2SHIP` | 2 | 8 | 4 | RECON, FAC(A), Armed Reconnaissance |
| `SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT` | `TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP` | 2 | 7 | 3 | 6 als drei Two-Ships; 1 getrennte logische Reserve |
| `SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN` | `TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP` | 1 | 3 | 3 | zwei Assets als Lead/Cover-Paket reservieren |
| `SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT` | `TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP` | 1 | 8 | 8 | Transport, Cargo, Slingload |

### 4.2 Ungerade UH-60-Assault-Stärke

Die sieben UH-60L Assault dürfen nicht durch vier Two-Ship-Gruppen als acht Maschinen registriert werden.

Bis eine MOOSE-first geprüfte alternative Abbildung vorliegt, gilt:

```text
3 spawnfähige Two-Ship-Gruppen = 6 Luftfahrzeuge
1 zusätzliche logische Reserve = nicht automatisch spawnfähig
```

Zulässige spätere Alternativen:

1. zusätzliches validiertes Single-Ship-Template für genau die Reserve;
2. sichere Laufzeit-Paketbildung aus Single-Ship-Assets;
3. die Reserve bleibt ausschließlich CampaignState-Bestand und wird erst nach Verlust-/Rückkehrereignissen nachgeführt.

Nicht zulässig ist die stillschweigende Registrierung von acht UH-60-Assault-Airframes.

### 4.3 Gemeinsame Bestandsinvarianten

Für jede SQUADRON müssen mindestens getrennt geführt werden:

```yaml
initial_inventory:
available:
reserved:
active:
damaged:
lost_permanent:
client_reserved:
```

Verbindliche Invarianten:

```text
Initialbestand wird nie durch Templates oder Statics erhöht.
Client- und KI-Reservierungen greifen auf denselben lokalen Bestand zu.
Eine Reservierung darf nur einmal aktiv sein.
Ein Verlust darf nur einmal abgezogen werden.
Eine Rückgabe darf nur eine vorherige Reservierung oder aktive Maschine freigeben.
```

Lokale technische Obergrenze:

```text
maximal 4 gleichzeitig aktive KI-Luftfahrzeuge je Muster und Basis
```

Missionsweite Anfangsgrenze:

```text
maximal 2 gleichzeitige taktische Supportmissionen
maximal 2 Luftfahrzeuge je Supportmission
maximal 4 taktische Support-Luftfahrzeuge gleichzeitig
```

## 5. Warehouse-Erkennung

### 5.1 Vorhandener Missionseditor-Anker

```yaml
object_name: WH_AIR_US_SALERNO
observed_dcs_object_type: Container brown
purpose: MOOSE AIRWING and Warehouse anchor
```

Der Anker ist ein technisches Missionsobjekt und kein zusätzlicher Luftfahrzeugbestand.

### 5.2 Erforderlicher Diagnosetest

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

Ein bloß vorhandener Name im `.miz` beweist noch nicht, dass MOOSE ihn in der verwendeten Konstruktor- und Airbase-Kombination akzeptiert.

## 6. AUFTRAG-Ausführung

### 6.1 Rollenmatrix

| Bedarf / MissionDemand | bevorzugte SQUADRON | bestehendes Seed-Template | Standardpaket |
|---|---|---|---:|
| CAS / Attack | AH-64D Attack | `TPL_AIR_US_SAL_AH64D_CAS_2SHIP` | 2 |
| Escort / Armed Overwatch | AH-64D Attack | gleiches AH-64D-Template | 2 |
| RECON / FAC(A) | OH-58D Cavalry | `TPL_AIR_US_SAL_OH58D_RECON_2SHIP` | 2 |
| Armed Reconnaissance | OH-58D Cavalry | gleiches OH-58D-Template | 2 |
| Air Assault / Utility Transport | UH-60 Assault | `TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP` | 2 |
| MEDEVAC | UH-60 MEDEVAC | `TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP` | 1 Lead + 1 Cover |
| Medium Lift / Cargo | CH-47 Medium Lift | `TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP` | 1 oder 2 |
| Slingload | CH-47 Medium Lift | gleiches CH-47-Template | 1 |

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
kein separates OH-58-Escort-Template
kein separates CH-47-Slingload-Template
keine automatisch erzeugten Missionen beim AIRWING-Start
```

Die genauen MOOSE-Klassenmethoden und Enum-Namen müssen vor Codeerstellung in der zum eingebundenen MOOSE-Artefakt passenden offiziellen Dokumentation bestätigt und im Projektindex der verifizierten Methoden nachgeführt werden.

## 7. Safe Parking und Blacklists

### 7.1 Verbindlich gesperrte Clientpositionen

```text
13, 21, 22, 23, 36, 40
```

Diese IDs dürfen weder für dynamische KI noch für Rückkehr-/Recovery-Spawns freigegeben werden.

### 7.2 Zusätzlich zu ermittelnde Blacklists

Noch nicht bekannt sind die TerminalIDs der durch Statics belegten Rampenstände. Sie sind mit einem Khost-spezifischen Parking-Dump zu ermitteln.

Danach werden getrennt geführt:

```yaml
client_reserved_ids:
static_occupied_ids:
maintenance_or_transient_ids:
hot_refuel_ids:
validated_ai_allowed_ids_by_aircraft_size:
```

### 7.3 Größen- und Funktionsregeln

- CH-47 darf nur auf als Heavy-Lift-tauglich validierten Positionen verwendet werden.
- AH-64, UH-60 und OH-58 erhalten typ- beziehungsweise größenkompatible Kandidatenlisten.
- die ausgerichtete zentrale Rampenlücke ist kein Parkplatz;
- wahrscheinliche Hot-Refueling-Flächen sind keine dauerhaften Spawn- oder Recoverypositionen;
- die CH-47-Wartungsfläche ist keine reguläre Verfügbarkeitsposition;
- die unklassifizierte westliche Fläche bleibt gesperrt, bis ihre Funktion geklärt ist;
- Safe Parking muss aktiviert und mit mehreren gleichzeitig zurückkehrenden Gruppen getestet werden;
- Parkpositionszonen ersetzen keine TerminalID-Blacklist.

### 7.4 Erforderlicher Parking-Diagnoselauf

Der Diagnoselauf muss mindestens liefern:

```text
alle Parking-/Helipad-IDs von Khost
Koordinaten und Terminaltypen
Abstand zu Clientgruppen und Statics
Zuordnung Static ↔ nächster Parking-Spot
Größeneignung je AH-64/OH-58/UH-60/CH-47
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
RESERVED → RELEASED → AVAILABLE         bei abgebrochenem Auftrag vor Spawn
ACTIVE → DAMAGED                         bei bestätigtem reparaturrelevantem Schaden
ACTIVE → LOST_PERMANENT                  bei bestätigter Zerstörung
ACTIVE → QUARANTINED                     bei ungeklärtem Disconnect oder Ereigniswiderspruch
```

### 8.3 Rückgabe

Ein KI-Asset darf erst zurückgegeben werden, wenn die gewählte MOOSE-/DCS-Ereigniskette reproduzierbar bestätigt, dass:

1. die Gruppe zur vorgesehenen Basis zurückgekehrt ist;
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
- zerstörtes Transportluftfahrzeug nach erfolgreichem Ausladen;
- Spieler-Disconnect in der Luft;
- Spieler-Disconnect am Boden;
- beschädigte Rückkehr;
- Missionsabbruch vor Spawn;
- Spawnfehler wegen fehlender sicherer Parkposition;
- zerstörtes Static mit eindeutiger Kampagnenzuordnung.

Ein zerstörtes Static darf erst nach bestätigter eindeutiger Zuordnung genau einen logischen Airframe abziehen.

## 9. Salerno-spezifische Funktionszonen

### 9.1 Aktueller Zustand

Revision 20 enthält:

```text
0 Salerno-spezifische Funktionszonen
```

Das ist für den reinen Missionseditor-Grundaufbau zulässig, reicht aber nicht für die vollständige MEDEVAC-, Logistik- und Transportfunktion.

### 9.2 Minimal erforderliche Produktionszonen

Folgende Zonen sind vor Aktivierung der jeweiligen Funktion im Missionseditor anzulegen und geometrisch zu dokumentieren:

| Zonenname | Status | Zweck |
|---|---|---|
| `ZONE_AIR_US_SAL_MEDEVAC_READY` | erforderlich vor MEDEVAC | Bereitschafts- und Paketbildungsbereich für Lead/Cover |
| `ZONE_AIR_US_SAL_MEDEVAC_TRANSFER` | erforderlich vor Patienten-/CSAR-Übergabe | Übergabe geretteter oder verwundeter Personen an die medizinische Einrichtung |
| `ZONE_AIR_US_SAL_LOGISTICS_LOAD` | erforderlich vor OPSTRANSPORT | Aufnahme von Truppen oder interner Fracht |
| `ZONE_AIR_US_SAL_LOGISTICS_UNLOAD` | erforderlich vor OPSTRANSPORT-Rückgabe | Entladung und Übergabe eingehender Fracht oder Truppen |

### 9.3 Bedingt erforderliche Zonen

| Zonenname | nur anlegen, wenn | Zweck |
|---|---|---|
| `ZONE_AIR_US_SAL_SLING_PICKUP` | Slingload technisch umgesetzt wird | klarer Außenlast-Aufnahmepunkt außerhalb regulärer Parkpositionen |
| `ZONE_AIR_US_SAL_HOT_REFUEL` | Hot-Refueling funktional simuliert wird | ausschließlich transienter Refueling-/Turnaround-Bereich |
| `ZONE_AIR_US_SAL_HEAVYLIFT_LOAD` | CH-47-Ladefläche geometrisch oder logisch von `LOGISTICS_LOAD` getrennt werden muss | CH-47-spezifischer Lade- und Stagingbereich |
| `ZONE_AIR_US_SAL_TEST_SAFETY` | nur im Testharness | kontrollierter Diagnose-/Sicherheitsbereich; nicht automatisch Produktionsbestandteil |

### 9.4 Nicht vorsorglich anzulegende Zonen

Ohne konkreten technischen Verbraucher werden nicht angelegt:

```text
keine STATIC-Reihenzonen nur zur optischen Gruppierung
keine generische AI_RESERVE-Zone
keine generische AI_SPAWN-Zone bei nativer AIRWING-/Airbase-Parking-Nutzung
keine generische RECOVERY-Zone bei nativer Airbase-Rückkehr
keine Zone als Ersatz für Parking-IDs oder Blacklists
keine Zone auf der zentralen Sicherheits-/Zufahrtslücke
keine Produktionszone auf der unklassifizierten westlichen Fläche
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

Zonen dürfen sich nicht unbeabsichtigt mit Clientpositionen, statisch belegten Pads, Rotorflächen oder der zentralen freizuhaltenden Rampenachse überschneiden.

## 10. Noch fehlende Implementierungsartefakte

Für einen vollständigen Salerno-Laufzeitstand fehlen weiterhin:

1. Salerno-spezifische Lua-Konfiguration oder ein eigenes Modul;
2. bestätigte MOOSE-Aufrufe für AIRWING, SQUADRON, Payloads, Parking und AUFTRAG;
3. Khost-Airbase-/Parking-Diagnoselog;
4. Warehouse-Probe;
5. finale AI-Allowlist und Parking-Blacklist;
6. die vier minimal erforderlichen Funktionszonen;
7. CampaignState-Adapter für Reservierung, Rückgabe und permanenten Verlust;
8. idempotente Ereignisverarbeitung;
9. AUFTRAG-/OPSTRANSPORT-Testfälle;
10. kontrollierter DCS-Lauf mit `dcs.log`;
11. Mission-, Bundle-, DCS-, MOOSE- und Commit-Provenienz;
12. Multiplayer- und Langzeittest.

## 11. Verbindliche Implementierungsreihenfolge

```text
1. Khost Airbase, Warehouse und Parking diagnostizieren
2. Funktionszonen im Missionseditor setzen
3. AIRWING ohne automatische Missionen registrieren
4. SQUADRONs und Payloads registrieren
5. Bestandsinvarianten und Safe Parking prüfen
6. je ein Template kontrolliert erzeugen und zurückführen
7. MEDEVAC-Lead/Cover-Paket testen
8. AUFTRAG-Rollen einzeln testen
9. OPSTRANSPORT/Cargo/Slingload testen
10. Verlust-, Rückgabe- und Disconnectfälle testen
11. CampaignState und Persistenz anbinden
12. Multiplayer- und Langzeit-Acceptance durchführen
```

Jede Stufe muss reproduzierbar protokolliert werden. Ein struktureller `.miz`-PASS wird nicht als AIRWING-, MOOSE- oder DCS-Laufzeit-Acceptance bezeichnet.
