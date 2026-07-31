---
document_id: OMW-AIR-KANDAHAR-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar USAF Mission Editor baseline
  - Kandahar evidence classification
  - Kandahar active A-10C unit and inventory
  - Kandahar dual-airbase runtime architecture
  - Kandahar-wide runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: AIRWING_OBJECT_CONTRACT
supersedes:
  - docs/30-kandahar-air-operations-manifest.md
  - Kandahar 75th EFS active baseline
  - single-AIRWING assumption across Kandahar and Kandahar Heliport
  - Kandahar Heliport warehouse missing/unapproved state
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(4).miz
source_mission_sha256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
validated_in_dcs: false
object_contract_validated_in_dcs: true
heliport_warehouse_validated_in_dcs: true
---

# 33 – Kandahar Air Operations Manifest

## 1. Dokumentstatus

Die aktuelle Kandahar-Mission-Editor-Baseline ist strukturell und hinsichtlich beider nativer Airbases, Parkingtabellen sowie beider Warehouse-Anker in DCS/MOOSE auditiert. Sie ist noch keine validierte produktive AIRWING-/SQUADRON-Laufzeitimplementierung.

Verbindliche Source-of-Truth:

```text
OMW_Template_v4_Kandahar(4).miz
2.183.450 Bytes
SHA-256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
```

Evidenz:

- [`OMW-EVIDENCE-KANDAHAR-ME-AUDIT-V4-1`](evidence/kandahar-mission-editor-audit-omw-template-v4-kandahar-1.md): vollständiger Ausgangsbestand;
- [`OMW-EVIDENCE-KANDAHAR-ME-AUDIT-V4-3`](evidence/kandahar-mission-editor-audit-omw-template-v4-kandahar-3.md): strukturelle Anlage des Heliport-Warehouses;
- [`Kandahar Dual-Airbase No-Spawn Diagnostic – PASS`](../mission/tests/kandahar-air-operations/results/2026-07-31-kandahar-dual-airbase-no-spawn-pass.md);
- [`Kandahar Heliport Warehouse No-Spawn Diagnostic – PASS`](../mission/tests/kandahar-air-operations/results/2026-07-31-kandahar-heliport-warehouse-pass.md).

Spezialdokumente:

- `OMW-AIR-KANDAHAR-ISR-POLICY`: MQ-1/MQ-9;
- `OMW-AIR-KANDAHAR-MUSTANG-RAMP`: Army Aviation / 159th CAB;
- `OMW-AIR-KANDAHAR-HELIPORT-WAREHOUSE`: verbindlicher Heliport-Warehouse-Vertrag;
- dieses Dokument: gemeinsame Kandahar-USAF-Struktur, Airbase-/Warehouse-Vertrag und basisweite Integrationsregeln.

## 2. Evidenz- und ORBAT-Regel

Kategorie A erlaubt Client-, Template-, Static- und SQUADRON-/AIRWING-Strukturen. Einzelne Sichtungen oder Durchgangsverkehr erzeugen keinen stationierten Bestand.

Verbindliche USAF-Auswahl:

```text
107th Expeditionary Fighter Squadron
Muster: A-10C
Rolle: CAS
Lokaler OMW-Bestand: 16

772nd Expeditionary Airlift Squadron
Muster: C-130J
Rolle: Tactical Airlift / Airdrop
Bestand: noch festzulegen

26th Expeditionary Rescue Squadron
historisches Muster: HH-60G
DCS-Repräsentation: UH-60A
Rolle: CSAR
Bestand und technische Airbase-Zuordnung: noch festzulegen

361st Expeditionary Reconnaissance Squadron
Muster: MQ-1 / MQ-9 / MC-12
DCS physisch: MQ-1A und MQ-9
Bestand und Verfügbarkeit: gemäß OMW-AIR-KANDAHAR-ISR-POLICY
```

81st, 74th und 75th EFS bleiben Rotationskontext und werden nicht als parallele aktive Kandahar-SQUADRONs angelegt.

## 3. Aktueller Missionseditor- und Runtime-Stand

### 3.1 Native Airbases

```text
AIRBASE.Afghanistan.Kandahar
DCS airdromeId: 7
Kategorie: Airdrome
Verwendung: Main Airfield / Fixed Wing
Runtime-Parking: 316 Nodes

AIRBASE.Afghanistan.Kandahar_Heliport
DCS airdromeId: 15
Kategorie: Helipad
Verwendung: Mustang Ramp / Rotary Wing
Runtime-Parking: 86 Nodes
```

Mission-Editor-Parkplatznummern sind keine autoritativen MOOSE-TerminalIDs. Die verbindlichen MOOSE-TerminalIDs stammen aus dem akzeptierten Runtime-Dump.

### 3.2 USAF-Clientgruppen

```text
CLIENT_US_KAF_A10C_01 | A-10C_2   | Z20 | airdromeId 7 | TerminalID 282
CLIENT_US_KAF_A10C_02 | A-10C_2   | Z19 | airdromeId 7 | TerminalID 287
CLIENT_US_KAF_C130_01 | C-130J-30 | S01 | airdromeId 7 | TerminalID 294
CLIENT_US_KAF_C130_02 | C-130J-30 | S02 | airdromeId 7 | TerminalID 92
```

### 3.3 Mustang-Ramp-Clientgruppen

```text
CLIENT_US_KAF_AH64D_01 | AH-64D_BLK_II | MST38-H | airdromeId 15 | TerminalID 30
CLIENT_US_KAF_AH64D_02 | AH-64D_BLK_II | MST30-H | airdromeId 15 | TerminalID 19
CLIENT_US_KAF_OH58D_01 | OH58D          | MST01-H | airdromeId 15 | TerminalID 80
CLIENT_US_KAF_OH58D_02 | OH58D          | MST11-H | airdromeId 15 | TerminalID 23
CLIENT_US_KAF_CH47F_01 | CH-47Fbl1      | MST75-H | airdromeId 15 | TerminalID 4
CLIENT_US_KAF_CH47F_02 | CH-47Fbl1      | MST82-H | airdromeId 15 | TerminalID 47
```

Alle zehn Clientgruppen lagen beim akzeptierten Diagnoselauf mit `distance=0.00 m` auf ihrem Runtime-Terminal.

### 3.4 USAF-/ISR-KI-Templates

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP       | 2 x A-10C
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP | 1 x C-130
TPL_AIR_US_KAF_HH60G_CSAR_1SHIP     | 1 x UH-60A
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP     | 1 x RQ-1A Predator
TPL_AIR_US_KAF_MQ9_RECON_1SHIP      | 1 x MQ-9 Reaper
```

Alle sind Late Activation, nicht `Uncontrolled` und Authoring-Seeds ohne zusätzlichen logischen Bestand.

Das ältere HH-60G-Lead-/Cover-Templatepaar ist nicht mehr vorhanden. Die aktuelle Mission verwendet einen typbasierten CSAR-Seed.

### 3.5 USAF-/ISR-Statics

```text
6 x A-10C_2
2 x C-130J-30
2 x UH-60A als HH-60G-/CSAR-Repräsentation
2 x RQ-1A Predator
1 x MQ-9 Reaper
Gesamt: 13
```

### 3.6 Army-Aviation-Statics

```text
8 x AH-64D_BLK_II
8 x OH58D
10 x CH-47Fbl1
8 x UH-60A
Gesamt: 34
```

Zusammen mit USAF/ISR ergeben sich 47 US-Flugzeug-Statics.

### 3.7 UN-Statics

```text
2 x Mi-26
4 x UH-1H
```

Diese sechs Objekte sind nicht Teil der US-ORBAT oder eines US-AIRWING-Bestands.

### 3.8 Warehouse-Anker

```text
Kandahar Main Airfield
WH_AIR_US_KANDAHAR
DCS-Typ: container_40ft
Koalition: Blue / 2
Runtime: validiert

Kandahar Heliport / Mustang Ramp
WH_AIR_US_KANDAHAR_HELI
DCS-Typ: container_20ft
Koalition: Blue / 2
Runtime: validiert
Nächste Heliport-TerminalID: 60
Abstand: 149.63 m
Nächste Main-TerminalID: 90
Abstand: 722.85 m
```

Der Heliport-Warehouse-Name und der Mission-Editor-Anker sind damit verbindlich und runtime-validiert.

### 3.9 Vorhandene Funktionszone

```text
ZONE_AIR_US_KAF_CSAR_UNLOAD
Radius: 30.48 m
```

Weitere Kandahar-Funktionszonen sind in der aktuellen Mission nicht vorhanden.

## 4. Verbindliche Dual-Airbase-Architektur

Der tatsächlich eingebettete MOOSE-2.9.18-Stand bindet ein `AIRWING` über sein `WAREHOUSE` an genau eine Airbase. Parking-IDs einer SQUADRON gelten innerhalb der Airbase des übergeordneten AIRWING-Warehouses.

Daraus folgt verbindlich:

```text
Ein einziges technisches AIRWING-/WAREHOUSE-Paar darf nicht gleichzeitig
Kandahar Main Airfield und Kandahar Heliport betreiben.
```

### 4.1 Main-Airfield-Vertrag

```text
AW_US_KANDAHAR
WH_AIR_US_KANDAHAR
AIRBASE.Afghanistan.Kandahar
```

Vorgesehene Komponenten:

```text
SQ_US_KAF_A10C_107_EFS
SQ_US_KAF_C130_772_EAS
```

Die technische Zuordnung von `SQ_US_KAF_HH60G_26_ERS`, `SQ_US_KAF_MQ1_361_ERS` und `SQ_US_KAF_MQ9_361_ERS` wird vor Registrierung gesondert entschieden.

### 4.2 Heliport-/Mustang-Ramp-Vertrag

```text
AIRBASE.Afghanistan.Kandahar_Heliport
WH_AIR_US_KANDAHAR_HELI
AIRWING-Name: noch festzulegen
```

Verbindliche Grenze:

- der zweite AIRWING-Name wird nicht erfunden;
- der Warehouse-Name `WH_AIR_US_KANDAHAR_HELI` ist genehmigt und runtime-validiert;
- der Warehouse-Anker ist korrekt dem Heliport zugeordnet;
- Mustang-Ramp-SQUADRONs dürfen erst nach AIRWING-Namensfreigabe, Bestandsfestlegung und Parking-Preflight registriert werden;
- bis dahin bleibt der Heliport-AIRWING-Vertrag fail-closed deaktiviert.

## 5. AIRWING-Registrierung

Die spätere Implementierung muss:

1. `WH_AIR_US_KANDAHAR` eindeutig erkennen und an `AIRBASE.Afghanistan.Kandahar` binden;
2. `WH_AIR_US_KANDAHAR_HELI` eindeutig erkennen und an `AIRBASE.Afghanistan.Kandahar_Heliport` binden;
3. jedes AIRWING erst nach erfolgreicher Warehouse-, Template-, Inventory- und Parking-Prüfung starten;
4. USAF-, ISR- und Army-Aviation-SQUADRONs ohne Doppelzählung registrieren;
5. Clientgruppen, Statics und Templates nicht als zusätzliche Airframes zählen;
6. native DCS-Ersatztypen transparent den historischen Rollen zuordnen;
7. ISR-Einschränkungen und Army-Aviation-Regeln aus den Spezialdokumenten übernehmen;
8. nicht freigegebene F-16-, V-22- oder Mi-8/Mi-17-Strukturen nicht automatisch registrieren;
9. bei jeder unklaren Airbase-, Warehouse-, Template-, Typ- oder Bestandszuordnung fail-closed bleiben.

## 6. SQUADRON-Bestandsverwaltung

Verbindlich:

```text
SQ_US_KAF_A10C_107_EFS: 16 Airframes
```

Noch festzulegen:

```text
SQ_US_KAF_C130_772_EAS
SQ_US_KAF_HH60G_26_ERS
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
Mustang-Ramp-SQUADRONs
```

Bestände dürfen nicht aus Static-, Client- oder Templateanzahlen abgeleitet werden. Für jede SQUADRON sind separat zu konfigurieren:

```text
initialer Gesamtbestand
maximal gleichzeitig einsetzbar
virtuelle/nicht dargestellte Reserve
extern gebunden oder nicht verfügbar
Wartung/Cooldown
beschädigt
verloren
Wiederbeschaffungs- oder Reparaturregel
```

MQ-1/MQ-9 bleiben zusätzlich durch externe Priorisierung und Verfügbarkeitsfreigabe eingeschränkt.

## 7. Parent-Pool- und Doppelzählungsregel

Tarinkot besitzt verbindlich:

```text
14 AH-64D
6 UH-60
2 CH-47
0 OH-58D
```

Diese Luftfahrzeuge werden vom Kandahar-/RC-South-Regionalpool abgezogen. Weitere Forward Detachments sind ebenfalls zu berücksichtigen.

```text
regionaler Kandahar-/RC-South-Gesamtpool
- Tarinkot
- weitere verbindliche Forward Detachments
= am Kandahar-Stammknoten verfügbarer Bestand
```

Solange der regionale Gesamtpool nicht festgelegt ist, dürfen keine produktiven Kandahar-Army-SQUADRON-Bestände registriert werden.

## 8. Typ- und Payload-Grenzen

Aktueller Typbefund:

```text
A-10 Clients/Statics: A-10C_2
A-10 KI-Template: A-10C
C-130 Clients/Statics: C-130J-30
C-130 KI-Template: C-130
AH-64 Clients/Templates/Statics: AH-64D_BLK_II
CH-47 Clients/Templates/Statics: CH-47Fbl1
```

A-10- und C-130-Templateabweichungen müssen vor SQUADRON-Registrierung korrigiert oder ausdrücklich als DCS-Repräsentation genehmigt werden.

ISR-Payloadabweichungen stehen verbindlich in Dokument 35. OH-58D-APKWS benötigt vor produktiver Verwendung eine separate Perioden-/Projektentscheidung.

## 9. Safe Parking und Blacklist

Die vollständigen Runtime-Parkingtables sind erfasst:

```text
Kandahar Main: 316 Nodes
Kandahar Heliport: 86 Nodes
```

Die Client-TerminalIDs sind verbindlich reserviert. Die endgültigen Safe-Parking-Allow-/Blocklists bleiben noch abzuleiten.

Verbindliche nächste Schritte:

1. Client-TerminalIDs dauerhaft sperren;
2. Statics und bewusst belegte Nodes in Blocklist-Kandidaten überführen;
3. Safe Parking je Luftfahrzeugklasse testen;
4. Größen-, Rotor-, Shelter-, Rollweg- und Revettementkonflikte sperren;
5. Main-Airfield- und Heliport-Allow-/Blocklists getrennt dokumentieren;
6. kontrollierte Einzelspawns erst nach bestandenem No-Spawn-Preflight zulassen.

Die endgültigen Listen werden ausschließlich aus den akzeptierten Laufzeitdaten abgeleitet.

## 10. Verlust- und Rückgabelogik

Verbindliche Zustandsfolge:

```text
angefordert -> reserviert
aktiviert/gestartet -> aktiv
sicher gelandet/zurückgekehrt -> verfügbar oder Wartung/Cooldown
beschädigt zurück -> beschädigt/Wartung
abgebrochen und sicher zurück -> verfügbar oder Wartung/Cooldown
zerstört/Crash -> verloren
Despawn ohne bestätigte Rückkehr -> nicht automatisch verfügbar
```

Ein Auftragserfolg darf einen anschließend verlorenen Airframe nicht zurückgeben. UAVs erhalten zusätzlich die in `OMW-AIR-KANDAHAR-ISR-POLICY` festgelegte externe Nichtverfügbarkeits-/Cooldown-Ebene.

Persistente Verluste werden später an CampaignState übergeben. Bis dahin ist eine deterministische lokale Bestandsbilanz mit Eventprotokollierung erforderlich.

## 11. AUFTRAG-Ausführung

Basisweite Rollen:

```text
A-10C: CAS, Show of Presence/Force nur gemäß ROE-Dokumentation
C-130: TRANSPORT, AIRDROP, ggf. OPSTRANSPORT
HH-60G: CSAR
MQ-1/MQ-9: RECON; ARMED ISR nur ausdrücklich freigegeben
AH-64: CAS, ESCORT
OH-58D: RECON/AFAC, ESCORT
CH-47/UH-60: TRANSPORT, OPSTRANSPORT, MEDEVAC/UTILITY gemäß Spezialdokument
```

Jeder AUFTRAG benötigt definierte SQUADRON, Payload, Gruppengröße, ROE, Start-/Zielbedingung, Erfolg, Abbruch, Rückkehr und Verlustbehandlung.

Vor Eigenlogik sind `AIRWING`, `SQUADRON`, `AUFTRAG`, `OPSTRANSPORT`, `FLIGHTGROUP`, MOOSE CSAR und vorhandene Recon/Detection-Funktionen zu prüfen.

## 12. Flugplatzspezifische Funktionszonen

Keine Zone wird nur zum Zählen, Gruppieren oder Markieren von Statics angelegt.

Aktuell vorhanden ist ausschließlich:

```text
ZONE_AIR_US_KAF_CSAR_UNLOAD
```

Weitere Zonen werden erst angelegt, wenn eine konkrete MOOSE-/OPSTRANSPORT-/CSAR-/MEDEVAC-Funktion sie benötigt. Parking wird über Airbase-/Helipad-Daten, Safe Parking und Allow-/Blocklists gelöst.

## 13. Nächster Runtime-Inkrement

Nach dem bestandenen Dual-Airbase- und Heliport-Warehouse-Audit ist der nächste technische Teststand:

```text
Kandahar Dual-AIRWING Registration Preflight
```

Voraussetzungen vor Implementierung:

```text
verbindlicher Heliport-AIRWING-Name
A-10-/C-130-Template-Typentscheidung
logischer C-130-Bestand für den ersten Fixed-Wing-Stand oder ausdrücklicher A-10-only-Start
regionale Army-Aviation-Bestandsentscheidung vor Mustang-SQUADRON-Registrierung
```

Der Preflight muss:

- beide Warehouse-Anker und nativen Airbases erneut fail-closed validieren;
- beide AIRWING-Verträge konstruieren, aber noch nicht automatisch starten;
- keine produktiven SQUADRON-Bestände ohne freigegebene Inventarzahlen registrieren;
- Clientreservierungen und spätere Parking-Allow-/Blocklists laden;
- keine AUFTRAG-, OPSTRANSPORT-, CSAR- oder ISR-Funktion erzeugen;
- keine automatischen Spawns zulassen.

## 14. Offene Kandahar-Entscheidungen

- AIRWING-Name für Kandahar Heliport;
- logische Anfangsbestände außer A-10C;
- regionale Army-Aviation-Gesamtbestände und Detachment-Abzüge;
- technische Airbase-Zuordnung des 26th ERQS;
- UAV-Warehouse- oder externes Kontingentmodell;
- vollständige Allow-/Blocklist-Tabellen;
- Payloads, ROE und Freigabeautoritäten;
- A-10-/C-130-Template-Typangleichung;
- Wartung, Cooldown, Reparatur und Wiederbeschaffung;
- CampaignState-Schnittstelle;
- Controlled-Spawn-, Performance- und Runtime-Acceptance.

## 15. Acceptance-Kriterien für die spätere Registrierung

```text
beide technischen AIRWING-/WAREHOUSE-Verträge eindeutig getrennt
genau ein Warehouse-Anker je nativer Airbase erkannt
keine Doppelzählung von Clients, Templates oder Statics
16 A-10C logisch registriert
weitere Bestände nur nach ausdrücklicher Entscheidung registriert
keine Spawns auf Client- oder Static-Nodes
Late-Activation-Templates bleiben bis zur Zuweisung inaktiv
AUFTRAG reserviert, startet, führt zurück und gibt korrekt frei
Verluste und beschädigte Rückkehr verändern den Bestand korrekt
keine ungeklärten Muster werden automatisch als stationierte SQUADRON registriert
keine relevante Lua-, Parking-, Timer- oder Eventfehler
```
