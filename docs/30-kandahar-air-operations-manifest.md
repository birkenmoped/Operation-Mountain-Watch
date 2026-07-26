# 30 – Kandahar Air Operations Manifest

## 1. Dokumentstatus

**USAF-Grundaufbau im Missionseditor begonnen; weitere US-Muster erst nach belastbarer Einheitenzuordnung**

Dieses Dokument hält den aktuellen, aus der Testmission `OMW_TEST_TM01M_MooseFirst(10).miz`, den ausgewerteten Quellen und den projektseitigen Entscheidungen abgeleiteten Stand für Kandahar Airfield fest.

Der Aufbau ist noch keine vollständig validierte AIRWING-/SQUADRON-Implementierung. Er ist die autoritative Missionseditor- und Recherchebaseline für den nächsten Ausbau.

## 2. Geltungsbereich

Für den aktuellen Kandahar-Ausbauschritt gelten:

```text
Zeitraum: November/Dezember 2011
Primärer Umfang: US-Kräfte
USMC: vorerst nicht Bestandteil des Grundaufbaus
andere ISAF-Nationen: vorerst nicht Bestandteil des Grundaufbaus
Afghanische Kräfte: vorerst nicht Bestandteil des Grundaufbaus
UN-/Vertragsnehmerdarstellung: nur separat gekennzeichnete Statics
```

Der eingeschränkte Umfang verhindert, dass eine einzelne Satellitenaufnahme als vollständige multinationale ORBAT fehlinterpretiert wird.

## 3. Verbindliche Bewertungsregel für Bild- und Satellitennachweise

Satellitenbilder sind Momentaufnahmen. Ein sichtbares Luftfahrzeug belegt zunächst nur seine Anwesenheit zum Aufnahmezeitpunkt, nicht automatisch die dauerhafte Stationierung einer Einheit.

### 3.1 Kategorie A – stationierter Verband

Ein Muster wird als dauerhafter Kandahar-Bestand aufgebaut, wenn mehrere belastbare Nachweise zusammenkommen, zum Beispiel:

- ORBAT oder offizielle Verbandszuordnung,
- konkrete Staffel beziehungsweise Einheit,
- offizielle Einsatzberichte,
- mehrere zeitgenössische Fotos,
- wiederholte Satellitensichtungen,
- Nachweis über einen längeren Zeitraum.

Ergebnis:

```text
Client-, KI-Template-, Static- und später SQUADRON-/AIRWING-Struktur zulässig
```

### 3.2 Kategorie B – temporäre Präsenz

Nur eine einzelne Sichtung, ein einzelnes Foto oder eine einzelne Satellitenaufnahme ohne belastbare Einheitenzuordnung.

Ergebnis:

```text
vorerst keine dauerhafte Client-, Template- oder Static-Struktur
```

Mögliche Ursachen sind Zwischenlandung, Wartung, Verlegung, Besuch, Defekt, Ferry Flight oder ein zeitlich begrenztes Detachment.

### 3.3 Kategorie C – Durchgangsverkehr

Regelmäßig auftretende, aber nicht dauerhaft stationierte Transporter, Tanker, Charter- oder Besuchsflugzeuge.

Ergebnis:

```text
später als dynamischer oder atmosphärischer Verkehr möglich,
nicht automatisch Teil der stationierten ORBAT
```

## 4. Historisch belegte USAF-Grundstruktur

### 4.1 A-10C

Für Juli 2011 nennt das ausgewertete Afghanistan-ORBAT-Dokument die 74th Expeditionary Fighter Squadron in Kandahar. Für November/Dezember 2011 ist durch zeitgenössische Bild- und Einsatznachweise die folgende Rotation maßgeblich:

```text
107th Expeditionary Fighter Squadron
Muster: A-10C
Standort: Kandahar Airfield
Rolle: Close Air Support
```

Die 74th EFS ist deshalb für den Zielzeitraum nicht als aktive Kandahar-Staffel zu verwenden.

### 4.2 C-130

Für den Zielzeitraum ist belegt:

```text
772nd Expeditionary Airlift Squadron
Muster: C-130J
Standort: Kandahar Airfield
Rolle: Tactical Airlift / Airdrop
```

### 4.3 CSAR

Das Juli-2011-ORBAT nennt:

```text
26th Expeditionary Rescue Squadron
Historisches Muster: HH-60G
Rolle: CSAR
```

DCS besitzt keinen nativen HH-60G als Spieler-, KI- oder Static-Modell. Deshalb gilt projektweit:

```text
Historische Bezeichnung und Rolle: HH-60G / CSAR
Technische DCS-Repräsentation: UH-60A
Community-Mods: optional, nicht verpflichtend
```

Die Gruppen- und Static-Namen dürfen die historische Rolle `HH60G` führen, obwohl das tatsächlich verwendete DCS-Modell `UH-60A` ist.

### 4.4 ISR

Die 361st Expeditionary Reconnaissance Squadron ist für Kandahar mit MC-12, MQ-1 und MQ-9 dokumentiert.

Für den aktuellen DCS-Grundaufbau werden nur native KI-/Static-Darstellungen berücksichtigt:

```text
MQ-1A Predator
MQ-9 Reaper
```

MC-12 wird derzeit nicht umgesetzt.

## 5. Aktueller Missionseditor-Stand

Quelle:

```text
OMW_TEST_TM01M_MooseFirst(10).miz
```

### 5.1 Client-Gruppen

Alle Clientgruppen bestehen aus genau einem Luftfahrzeug und stehen auf `Client`.

```text
CLIENT_US_KAF_A10C_01
  CLIENT_US_KAF_A10C_01_UNIT_01

CLIENT_US_KAF_A10C_02
  CLIENT_US_KAF_A10C_02_UNIT_01

CLIENT_US_KAF_C130_01
  CLIENT_US_KAF_C130_01_UNIT_01

CLIENT_US_KAF_C130_02
  CLIENT_US_KAF_C130_02_UNIT_01
```

DCS-Spielertypen:

```text
A-10C II: A-10C_2
C-130J-30: C-130J-30
```

Aktuell verwendete Parkpositionen:

```text
A-10C II: Z20, Z19
C-130J-30: S01, S02
```

Die projektweite Obergrenze wird eingehalten:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Flugplatz
1 Luftfahrzeug je Client-Gruppe
```

### 5.2 KI-Templates

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP
  TPL_AIR_US_KAF_A10C_CAS_2SHIP_UNIT_01
  TPL_AIR_US_KAF_A10C_CAS_2SHIP_UNIT_02

TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP
  TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP_UNIT_01

TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP
  TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP_UNIT_01

TPL_AIR_US_KAF_HH60G_CSAR_COVER_1SHIP
  TPL_AIR_US_KAF_HH60G_CSAR_COVER_1SHIP_UNIT_01
```

Eigenschaften:

```text
Late Activation: ja
Uncontrolled: nein
KI-Skill: High
```

Technische Typabbildung:

```text
A-10C-Template: native DCS-AI-Variante
C-130-Template: native DCS-AI-Variante
HH-60G-Rolle: UH-60A
```

### 5.3 US-Statics

A-10C:

```text
STATIC_AIR_US_KAF_A10C_01
STATIC_AIR_US_KAF_A10C_02
STATIC_AIR_US_KAF_A10C_03
STATIC_AIR_US_KAF_A10C_04
STATIC_AIR_US_KAF_A10C_05
STATIC_AIR_US_KAF_A10C_06
```

C-130:

```text
STATIC_AIR_US_KAF_C130_01
STATIC_AIR_US_KAF_C130_02
```

HH-60G-/CSAR-Repräsentation durch UH-60A:

```text
STATIC_AIR_US_KAF_HH60G_01
STATIC_AIR_US_KAF_HH60G_02
```

ISR:

```text
STATIC_AIR_US_KAF_MQ1A_01
STATIC_AIR_US_KAF_MQ1A_02
STATIC_AIR_US_KAF_MQ9_01
```

Aktueller US-Static-Bestand:

```text
6 A-10C
2 C-130
2 UH-60A als HH-60G/CSAR
2 MQ-1A Predator
1 MQ-9 Reaper
Gesamt: 13 US-Luftfahrzeug-Statics
```

### 5.4 Separat gekennzeichnete UN-Statics

```text
STATIC_AIR_UN_KAF_MI26_01
STATIC_AIR_UN_KAF_MI26_02

STATIC_AIR_UN_KAF_UH1H_01
STATIC_AIR_UN_KAF_UH1H_02
STATIC_AIR_UN_KAF_UH1H_03
STATIC_AIR_UN_KAF_UH1H_04
```

Bestand:

```text
2 Mi-26
4 UH-1H
Gesamt: 6 UN-Luftfahrzeug-Statics
```

Diese Objekte sind ausdrücklich nicht Teil der US-ORBAT.

### 5.5 Warehouse-Anker

```text
WH_AIR_US_KANDAHAR
DCS-Objekttyp: container_40ft
```

## 6. Projektweite DCS-Abbildungsregel

Die Unterschiede zwischen Client-, KI- und Static-Modellen sind beabsichtigt.

```text
Spieler-/Client-Slots:
ausschließlich tatsächlich fliegbare DCS-Modulvarianten

KI-Templates:
bevorzugt native, weniger aufwendige DCS-AI-Modelle

Statics:
bevorzugt native DCS-Static-/AI-Modelle

Community-Mods:
optional, niemals Voraussetzung der Basismission
```

Beispiele:

```text
F-15E:
Client = F-15ESE
KI/Static = F-15E

CH-47:
Client = CH-47Fbl1
KI/Static = CH-47D

HH-60G-Rolle:
KI/Static = UH-60A
```

Solche Unterschiede sind keine Inkonsistenz, sondern eine bewusste technische Trennung nach Verwendungszweck.

## 7. Auswertung der Kandahar-Satellitenbilder

Auf den vorliegenden Aufnahmen sind beziehungsweise erscheinen unter anderem:

```text
UH-1
CH-47
Mi-8/Mi-17
Mi-26
V-22
Drohnen
mindestens ein kleines Kampfflugzeug, wahrscheinlich F-16
```

Die Auswertung bleibt nach Evidenzgrad getrennt:

```text
sicher
wahrscheinlich
möglich / ungeklärt
```

Insbesondere das einzelne Kampfflugzeug besitzt eine F-16-kompatible Silhouette mit stark gepfeilten Tragflächen, getrennten Höhenleitwerken und möglicherweise sichtbaren Wingtip-Rails. Eine einzelne sichtbare Maschine ist jedoch kein ausreichender Nachweis für ein stationiertes F-16-Kontingent.

## 8. Noch nicht zu setzende Muster

Folgende Muster werden erst ergänzt, wenn die konkrete Einheit beziehungsweise der stationierte Verband für Kandahar im Zielzeitraum belastbar identifiziert ist:

```text
F-16
CH-47
AH-64
US-Army-UH-60
Mi-8 / Mi-17
V-22
```

Begründung:

- eine Satellitensichtung allein genügt nicht;
- bei Kandahar ist Besuchs-, Transit- und Detachment-Verkehr wahrscheinlich;
- die Mission soll die stationierte ORBAT und nicht eine zufällige Momentaufnahme abbilden;
- Statics, Clients und Templates werden nicht spekulativ angelegt.

Für CH-47 und AH-64 deuten mehrere sichtbare Maschinen auf eine längere Präsenz hin. Vor der Umsetzung fehlen aber noch Combat Aviation Brigade, Battalion oder vergleichbar belastbare Einheitenzuordnungen.

Für die einzelne mögliche F-16 gilt besonders:

```text
möglicher Besucher, Defekt, Wartungsfall, Verlegung oder temporäres Detachment
keine dauerhafte Kandahar-F-16-Struktur ohne weiteren Nachweis
```

## 9. Mission-Editor- und Zonenprinzip

Der Missionseditor bleibt minimal.

Nicht anzulegen sind:

- Hilfszonen nur zum Zählen oder Gruppieren von Statics,
- Platzhaltergruppen ohne konkrete Runtime-Funktion,
- Reserve- oder Load-/Recovery-Zonen ohne nachgewiesenen MOOSE-/AUFTRAG-/OPSTRANSPORT-Bedarf.

Die `.miz` ist die Quelle für Namen, Typen, Anzahl und Positionen der gesetzten Objekte.

Zonen werden erst angelegt, wenn eine konkrete Runtime-Funktion sie benötigt.

## 10. Parking und bewusst durch Statics belegte Plätze

Statics dürfen bewusst reguläre DCS-Parkpositionen belegen, wenn dies für die historische beziehungsweise optische Flugplatzdarstellung erforderlich ist.

Der Projektinhaber muss keine TerminalIDs im Missionseditor manuell auslesen; DCS zeigt diese dort nicht praktikabel an.

Die spätere technische Validierung muss:

1. die Bagram- und Kandahar-Parking-Daten zur Laufzeit auslesen,
2. TerminalIDs und Koordinaten protokollieren,
3. die nächsten Statics geometrisch zuordnen,
4. bewusst blockierte Plätze als Blacklist-Kandidaten ausgeben,
5. Client- und dynamische KI-Positionen auf Kollisionen prüfen.

Die manuelle Arbeit beschränkt sich auf die sinnvolle Platzierung der Statics.

## 11. Frequenzen

Die aktuell gesetzten Frequenzen sind noch keine finale Funknetzplanung.

Projektentscheidung:

```text
Zuerst alle möglichen Spieler-/Client-Muster auf den vorgesehenen Basen bestimmen und setzen.
Danach missionsweite Frequenz-, Callsign-, Tanker-, AWACS-, JTAC-, TACAN- und ICLS-Planung.
```

Frequenzabweichungen oder Überschneidungen sind bis dahin kein Blocker, sofern die Gruppen technisch korrekt funktionieren.

## 12. Nächste Arbeitsschritte

1. belastbare Einheitenzuordnung für US-Army-CH-47, AH-64 und UH-60 in Kandahar Ende 2011;
2. Prüfung einer möglichen dauerhaften F-16-Präsenz, ohne die Einzelsichtung zu überinterpretieren;
3. Prüfung von V-22-Präsenz und Betreiber/Einheit;
4. erst danach Ergänzung von Clients, KI-Templates und Statics;
5. Parking-/TerminalID-Diagnoselauf;
6. AIRWING-/SQUADRON- und Safe-Parking-Validierung;
7. missionsweite Frequenzplanung erst nach Abschluss der Spielerstruktur.

## 13. Autoritative Festlegungen

Dieses Dokument ist für den aktuellen Kandahar-Aufbau autoritativ.

Besonders verbindlich sind:

```text
US-only-Grundaufbau; USMC vorerst ausgenommen
maximal 2 Clients je Muster und Flugplatz
1 Luftfahrzeug je Client-Gruppe
native Spieler-Module für Clients
native AI-Modelle für KI und Statics
UH-60A als HH-60G-/CSAR-Ersatz
keine verpflichtenden Community-Mods
keine spekulativen Einheiten aus einzelnen Satellitensichtungen
keine künstlichen Hilfszonen ohne Runtime-Bedarf
Frequenzplanung nach Abschluss der Spielerstruktur
```
