---
document_id: OMW-AIR-KANDAHAR-MANIFEST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar USAF Mission Editor baseline
  - Kandahar evidence classification
  - Kandahar active A-10C unit and inventory
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/30-kandahar-air-operations-manifest.md
  - Kandahar 75th EFS active baseline
source_branch: docs/bagram-air-operations-manifest
validated_in_dcs: false
---

# 33 – Kandahar Air Operations Manifest

## 1. Dokumentstatus

Der USAF-Grundaufbau im Missionseditor ist begonnen. Der Aufbau ist noch keine vollständig validierte AIRWING-/SQUADRON-Implementierung, aber die verbindliche Kandahar-USAF-Arbeitsbaseline.

Verbindlicher Kampagnen- und Recherchezeitraum:

```text
01.08.2010 bis 31.12.2011
```

Die aktive ORBAT ist eine bewusste, spielbare Auswahl innerhalb des Zeitraums. Historische Rotationen bleiben als Kontext erhalten, erzeugen aber keine parallelen aktiven Bestände.

## 2. Geltungsbereich

```text
Primärer Umfang: US-Kräfte
USMC: separat zu dokumentieren
andere ISAF-Nationen: separat zu dokumentieren
afghanische Kräfte: separat zu dokumentieren
UN-/Vertragsnehmerdarstellung: nur ausdrücklich gekennzeichnete Objekte
```

Eine Satellitenaufnahme wird nicht als vollständige multinationale ORBAT interpretiert.

## 3. Evidenzregel

### Kategorie A – stationierter Verband

Mehrere belastbare Nachweise, beispielsweise:

- offizielle Verbandszuordnung;
- konkrete Staffel oder Einheit;
- Einsatzberichte;
- mehrere zeitgenössische Fotos;
- wiederholte Satellitensichtungen;
- Nachweis über einen längeren Zeitraum.

Ergebnis: Client-, KI-Template-, Static- und spätere SQUADRON-/AIRWING-Struktur sind zulässig.

### Kategorie B – temporäre Präsenz

Eine einzelne Sichtung ohne belastbare Einheitenzuordnung.

Ergebnis: keine dauerhafte Client-, Template- oder Static-Struktur allein aus dieser Sichtung.

### Kategorie C – Durchgangsverkehr

Regelmäßig auftretende, aber nicht dauerhaft stationierte Transporter, Tanker, Charter- oder Besuchsflugzeuge.

Ergebnis: später als dynamischer beziehungsweise atmosphärischer Verkehr möglich, aber nicht automatisch stationierte ORBAT.

## 4. Verbindliche USAF-Grundstruktur

### 4.1 A-10C

```text
107th Expeditionary Fighter Squadron
Muster: A-10C
Standort: Kandahar Airfield
Rolle: Close Air Support
Lokaler OMW-Bestand: 16
```

Die 107th EFS ist die aktive OMW-Auswahl. 81st, 74th und 75th EFS bleiben zeitbezogener Rotations- und Recherchekontext und werden nicht zusätzlich als parallele aktive SQUADRONs umgesetzt.

### 4.2 C-130J

```text
772nd Expeditionary Airlift Squadron
Muster: C-130J
Rolle: Tactical Airlift / Airdrop
```

Der genaue aktive Bestand wird im zuständigen Bestands- und Missionseditordokument geführt.

### 4.3 CSAR

```text
26th Expeditionary Rescue Squadron
historisches Muster: HH-60G
technische DCS-Repräsentation: UH-60A
Rolle: CSAR
```

DCS besitzt keinen nativen HH-60G als Spieler-, KI- oder Static-Modell. Gruppen- und Static-Namen dürfen die historische Rolle `HH60G` führen, obwohl das DCS-Modell `UH-60A` verwendet wird. Community-Mods bleiben optional.

### 4.4 ISR

```text
361st Expeditionary Reconnaissance Squadron
MQ-1 / MQ-9 / MC-12
```

Im nativen DCS-Grundaufbau:

```text
MQ-1A Predator
MQ-9 Reaper
```

MC-12 wird derzeit nicht physisch umgesetzt. Die eingeschränkte operative Verwendung von MQ-1/MQ-9 regelt `OMW-AIR-KANDAHAR-ISR-POLICY`.

## 5. Aktueller Missionseditorstand

Quelle:

```text
OMW_TEST_TM01M_MooseFirst(10).miz
```

### 5.1 Clientgruppen

```text
CLIENT_US_KAF_A10C_01
CLIENT_US_KAF_A10C_02
CLIENT_US_KAF_C130_01
CLIENT_US_KAF_C130_02
```

Alle Clientgruppen:

```text
1 Luftfahrzeug je Gruppe
maximal 2 Client-Luftfahrzeuge je Muster und Basis
skill = Client
```

Aktuelle Parkpositionen:

```text
A-10C II: Z20, Z19
C-130J-30: S01, S02
```

DCS-Spielertypen:

```text
A-10C II: A-10C_2
C-130J-30: C-130J-30
```

### 5.2 KI-Templates

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP
TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_KAF_HH60G_CSAR_COVER_1SHIP
```

Eigenschaften:

```text
Late Activation: ja
Uncontrolled: nein
KI-Skill: High, sofern nicht rollenspezifisch anders festgelegt
```

Templates sind Authoring-Seeds und kein zusätzlicher logischer Bestand.

### 5.3 US-Statics

```text
6 A-10C
2 C-130
2 UH-60A als HH-60G-/CSAR-Repräsentation
2 MQ-1A Predator
1 MQ-9 Reaper
Gesamt: 13 US-Luftfahrzeug-Statics
```

Benennung:

```text
STATIC_AIR_US_KAF_A10C_01 ... _06
STATIC_AIR_US_KAF_C130_01 ... _02
STATIC_AIR_US_KAF_HH60G_01 ... _02
STATIC_AIR_US_KAF_MQ1A_01 ... _02
STATIC_AIR_US_KAF_MQ9_01
```

### 5.4 Separat gekennzeichnete UN-Statics

```text
2 Mi-26
4 UH-1H
Gesamt: 6 UN-Luftfahrzeug-Statics
```

Diese Objekte sind nicht Bestandteil der US-ORBAT.

### 5.5 Warehouse

```text
WH_AIR_US_KANDAHAR
DCS-Objekttyp: container_40ft
```

## 6. DCS-Abbildungsregel

```text
Client-Slots:
fliegbare DCS-Modulvarianten

KI-Templates:
bevorzugt native, weniger aufwendige DCS-AI-Modelle

Statics:
bevorzugt native DCS-Static-/AI-Modelle

Community-Mods:
optional, niemals Voraussetzung der Basismission
```

Beispiele:

```text
F-15E: Client F-15ESE, KI/Static F-15E
CH-47: Client CH-47Fbl1, KI/Static CH-47D
HH-60G-Rolle: KI/Static UH-60A
```

Diese Unterschiede sind bewusst dokumentierte technische Ersatzdarstellungen.

## 7. Satellitenbildauswertung

Auf vorliegenden Kandahar-Aufnahmen sind beziehungsweise erscheinen unter anderem:

- UH-1;
- CH-47;
- Mi-8/Mi-17;
- Mi-26;
- V-22;
- Drohnen;
- mindestens ein kleines Kampfflugzeug, wahrscheinlich F-16.

Bewertung bleibt getrennt nach:

```text
sicher
wahrscheinlich
möglich / ungeklärt
```

Eine einzelne F-16-kompatible Silhouette ist kein ausreichender Nachweis für ein dauerhaft stationiertes F-16-Kontingent.

## 8. Army Aviation / Mustang Ramp

AH-64, OH-58D, CH-47 und US-Army-UH-60 sind für die 159th Combat Aviation Brigade / Task Force Thunder als stationierte Kategorie-A-Muster ausreichend belegt.

Ihre Client-, Template-, Static- und Ramp-Baseline wird ausschließlich in `OMW-AIR-KANDAHAR-MUSTANG-RAMP` geführt. Damit ist die frühere pauschale Zurückstellung dieser vier Army-Muster aufgehoben.

Nicht dadurch freigegeben sind:

- ein stationiertes Kandahar-F-16-Kontingent;
- Mi-8/Mi-17 als US-Bestand;
- V-22 als US-Army-Bestand;
- ungeklärte Silhouetten ohne Verbandszuordnung.

## 9. MOOSE-First-Architektur

Vor eigener Laufzeitlogik sind mindestens zu prüfen:

- `AIRWING` und `SQUADRON`;
- `AUFTRAG` für CAS, Reconnaissance, Escort, Transport und CSAR;
- `OPSTRANSPORT` für Truppen und Fracht;
- Warehouse- und Asset-Bestände;
- Parking, Safe Parking und TerminalIDs;
- ROE, Alarm State und kontrollierte Waffenfreigabe;
- Loss-, Recovery- und Persistenzintegration.

Jede Nicht-MOOSE-Ergänzung benötigt die dokumentierte technische Lücke und ausdrückliche Projektinhaberfreigabe.

## 10. Autoritätsregel

- Dieses Dokument: Kandahar-USAF-Grundaufbau, 107th EFS mit 16 A-10C und Evidenzklassen.
- `OMW-AIR-KANDAHAR-ISR-POLICY`: MQ-1/MQ-9-Verfügbarkeit und Rollen.
- `OMW-AIR-KANDAHAR-MUSTANG-RAMP`: stationierter Army-Aviation-Knoten.

Ältere Angaben zur 75th EFS als aktive Kandahar-Staffel sind ersetzt.
