---
document_id: OMW-AIR-KANDAHAR-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar USAF Mission Editor baseline
  - Kandahar evidence classification
  - Kandahar active A-10C unit and inventory
  - Kandahar-wide runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/30-kandahar-air-operations-manifest.md
  - Kandahar 75th EFS active baseline
source_branch: docs/bagram-air-operations-manifest
source_mission: OMW_TEST_TM01M_MooseFirst(18).miz
validated_in_dcs: false
---

# 33 – Kandahar Air Operations Manifest

## 1. Dokumentstatus

Der Kandahar-Grundaufbau ist in der gemeinsamen Missionseditor-Testmission weit fortgeschritten. Die Objekte sind noch keine validierte AIRWING-/SQUADRON-Laufzeitimplementierung. Dieses Dokument ist die basisweite Übergabe für die spätere MOOSE-Registrierung.

Spezialdokumente:

- `OMW-AIR-KANDAHAR-ISR-POLICY`: MQ-1/MQ-9;
- `OMW-AIR-KANDAHAR-MUSTANG-RAMP`: Army Aviation / 159th CAB;
- dieses Dokument: gemeinsame Kandahar-USAF-Struktur, Warehouse und basisweite Integrationsregeln.

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
Bestand: noch festzulegen

361st Expeditionary Reconnaissance Squadron
Muster: MQ-1 / MQ-9 / MC-12
DCS physisch: MQ-1A und MQ-9
Bestand und Verfügbarkeit: gemäß OMW-AIR-KANDAHAR-ISR-POLICY
```

81st, 74th und 75th EFS bleiben Rotationskontext und werden nicht als parallele aktive Kandahar-SQUADRONs angelegt.

## 3. Aktueller Missionseditorstand

Quelle:

```text
OMW_TEST_TM01M_MooseFirst(18).miz
```

### 3.1 USAF-Clientgruppen

```text
CLIENT_US_KAF_A10C_01
CLIENT_US_KAF_A10C_02
CLIENT_US_KAF_C130_01
CLIENT_US_KAF_C130_02
```

Parkpositionen:

```text
A-10C II: Z20, Z19
C-130J-30: S01, S02
```

### 3.2 USAF-KI-Templates

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP
TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_KAF_HH60G_CSAR_COVER_1SHIP
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
```

Alle sind Late Activation, nicht `Uncontrolled` und Authoring-Seeds ohne zusätzlichen logischen Bestand.

### 3.3 USAF-Statics

```text
6 A-10C
2 C-130
2 UH-60A als HH-60G-/CSAR-Repräsentation
2 MQ-1A Predator
1 MQ-9 Reaper
Gesamt: 13 USAF-Luftfahrzeug-Statics
```

### 3.4 UN-Statics

```text
2 Mi-26
4 UH-1H
```

Diese sechs Objekte sind nicht Teil der US-ORBAT oder des US-AIRWING-Bestands.

### 3.5 Warehouse-Anker

```text
WH_AIR_US_KANDAHAR
DCS-Objekttyp: container_40ft
```

## 4. Basisweite Runtime-Zielstruktur

```text
AW_US_KANDAHAR
├── SQ_US_KAF_A10C_107_EFS
├── SQ_US_KAF_C130_772_EAS
├── SQ_US_KAF_HH60G_26_ERS
├── SQ_US_KAF_MQ1_361_ERS
├── SQ_US_KAF_MQ9_361_ERS
├── Army-Aviation-SQUADRONs gemäß OMW-AIR-KANDAHAR-MUSTANG-RAMP
└── spätere separat freigegebene Komponenten

WH_AIR_US_KANDAHAR
```

Es wird genau ein Kandahar-AIRWING verwendet, sofern der MOOSE-First-Architekturtest nicht zwingend getrennte AIRWINGs für USAF und US Army erfordert. Eine solche Trennung wäre eine Architekturentscheidung und muss vor Umsetzung ausdrücklich dokumentiert werden.

## 5. AIRWING-Registrierung

Die Implementierung muss:

1. `WH_AIR_US_KANDAHAR` eindeutig erkennen;
2. das Kandahar-AIRWING erst nach erfolgreicher Warehouse-, Template- und Parking-Prüfung starten;
3. USAF-, ISR- und Army-Aviation-SQUADRONs ohne Doppelzählung registrieren;
4. Clientgruppen, Statics und Templates nicht als zusätzliche Airframes zählen;
5. native DCS-Ersatztypen transparent den historischen Rollen zuordnen;
6. ISR-Einschränkungen und Army-Aviation-Regeln aus den Spezialdokumenten übernehmen;
7. nicht freigegebene F-16-, V-22- oder Mi-8/Mi-17-Strukturen nicht automatisch registrieren.

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
Army-Aviation-SQUADRONs
```

Bestände dürfen nicht aus Static- oder Templateanzahlen abgeleitet werden. Für jede SQUADRON sind separat zu konfigurieren:

```text
initialer Gesamtbestand
maximal gleichzeitig einsetzbar
Reserve/nicht verfügbar
Wartung/Cooldown
beschädigt
verloren
Wiederbeschaffungs- oder Reparaturregel
```

MQ-1/MQ-9 bleiben zusätzlich durch externe Priorisierung und Verfügbarkeitsfreigabe eingeschränkt.

## 7. Warehouse-Erkennung

Die Erkennung von `WH_AIR_US_KANDAHAR` erfolgt fail-closed:

- nicht gefunden: AIRWING nicht starten;
- mehrfach gefunden: Konfigurationsfehler;
- falsche Koalition/ungültiges Objekt: Konfigurationsfehler;
- Erfolg: Name, Typ, Koalition und Koordinate protokollieren.

Der Container ist ein technischer Anker. Seine DCS-Objektart definiert weder Lagerkapazität noch SQUADRON-Bestand.

## 8. AUFTRAG-Ausführung

Basisweite Rollen:

```text
A-10C: CAS, Show of Presence/Force nur gemäß ROE-Dokumentation
C-130: TRANSPORT, AIRDROP, ggf. OPSTRANSPORT
HH-60G: CSAR Lead/Cover
MQ-1/MQ-9: RECON; ARMED ISR nur ausdrücklich freigegeben
AH-64: CAS, ESCORT
OH-58D: RECON/AFAC, ESCORT
CH-47/UH-60: TRANSPORT, OPSTRANSPORT, MEDEVAC/UTILITY gemäß Spezialdokument
```

Jeder AUFTRAG benötigt definierte SQUADRON, Payload, Gruppengröße, ROE, Start-/Zielbedingung, Erfolg, Abbruch, Rückkehr und Verlustbehandlung.

Vor Eigenlogik sind `AIRWING`, `SQUADRON`, `AUFTRAG`, `OPSTRANSPORT`, `FLIGHTGROUP`, MOOSE CSAR und vorhandene Recon/Detection-Funktionen zu prüfen.

## 9. Safe Parking und Blacklist

Die Runtime-Diagnose muss für Kandahar getrennt erfassen:

```text
Main Airfield / Fixed-Wing-Parking
USAF-CSAR-Bereich
ISR-Bereich
Mustang Ramp / Army Aviation
```

Verbindliche Schritte:

1. alle TerminalIDs, Helipad-IDs und Koordinaten protokollieren;
2. Clientpositionen dauerhaft reservieren;
3. Statics dem nächsten Parking-/Helipad-Node zuordnen;
4. bewusst belegte Nodes als Blacklist-Kandidaten ausgeben;
5. Safe Parking je Luftfahrzeugklasse testen;
6. Größen-, Rotor-, Shelter-, Rollweg- und Revettementkonflikte sperren;
7. Mustang-Ramp- und Fixed-Wing-Blacklists getrennt dokumentieren.

Die endgültigen Blacklists werden ausschließlich aus Laufzeitdaten abgeleitet.

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

## 11. Flugplatzspezifische Funktionszonen

Keine Zonen werden nur zum Zählen, Gruppieren oder Markieren von Statics angelegt.

Voraussichtlich funktional benötigte Zonen:

```text
Kandahar Fixed-Wing Cargo-/Airdrop-Stagingzone
Kandahar OPSTRANSPORT Ladezone
Kandahar OPSTRANSPORT Entlade-/Stagingzone
Kandahar CSAR-/MEDEVAC-Übergabezone
Mustang Ramp Cargo-/Slingload-Zone
Mustang Ramp Troop-Embarkation-Zone
Mustang Ramp MEDEVAC-Aufnahme-/Übergabezone
```

ISR-Orbits, Recon-Gebiete und Zielzonen sind auftragsbezogen und keine dauerhaften Flugplatz-Hilfszonen.

Namen, Koordinaten und Radien werden erst festgelegt, wenn die jeweilige MOOSE-Funktion sie tatsächlich benötigt. Parking wird über Airbase-/Helipad-Daten, Safe Parking und Blacklists gelöst.

## 12. Offene Kandahar-Entscheidungen

- logische Anfangsbestände außer A-10C;
- ein gemeinsames oder getrennte USAF-/Army-AIRWINGs;
- vollständige TerminalID-/Helipad-/Blacklist-Tabellen;
- konkrete Funktionszonen;
- Payloads, ROE und Freigabeautoritäten;
- Wartung, Cooldown, Reparatur und Wiederbeschaffung;
- CampaignState-Schnittstelle;
- Performance- und Runtime-Acceptance.

## 13. Acceptance-Kriterien

```text
genau 1 Warehouse-Anker erkannt
keine Doppelzählung von Clients, Templates oder Statics
16 A-10C logisch registriert
Spezialbestände gemäß ISR- und Mustang-Ramp-Dokumenten registriert
keine Spawns auf Client- oder Static-Nodes
Late-Activation-Templates bleiben bis zur Zuweisung inaktiv
AUFTRAG reserviert, startet, führt zurück und gibt korrekt frei
Verluste und beschädigte Rückkehr verändern den Bestand korrekt
keine ungeklärten Muster werden automatisch als stationierte SQUADRON registriert
keine relevante Lua-, Parking-, Timer- oder Eventfehler
```
