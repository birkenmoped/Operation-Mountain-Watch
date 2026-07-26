# 28 – Bagram Air Operations Manifest

## 1. Dokumentstatus

**Historische Fighter-ORBAT bestätigt; Missionseditor-Grundaufbau noch nicht validiert**

Dieses Dokument ist die basisbezogene Arbeits- und Entscheidungsgrundlage für den nächsten Air-Operations-Knoten nach Jalalabad. Es beschreibt den historisch belegten Fighter-Bestand in Bagram im November/Dezember 2011 und überführt ihn in eine konkrete Missionseditor-Arbeitsliste.

Der Jalalabad-Knoten bleibt die validierte technische Referenz. Bagram erhält jedoch eigene Bestände, Parkflächen, Spielerlimits, Templates, Statics, Zonen und Parking-Regeln.

## 2. Historische Evidenz

### 2.1 Satellitenaufnahme Dezember 2011

Eine projektseitig ausgewertete Maxar-/Google-Earth-Aufnahme mit Datumsangabe `12/2011` zeigt auf dem östlichen Fighter Apron von Bagram mindestens:

```text
13 F-15E Strike Eagle
11 F-16 Fighting Falcon
```

Die F-16 stehen überwiegend auf der westlichen beziehungsweise linken Apronreihe, die F-15E auf der östlichen beziehungsweise rechten Reihe. Die getrennte Aufstellung spricht für zwei gleichzeitig betriebene Expeditionary Fighter Squadrons mit eigenen Rampbereichen.

Die Zählung ist eine Momentaufnahme. Nicht sichtbar sind Luftfahrzeuge, die zum Aufnahmezeitpunkt:

- im Einsatz,
- in Wartung oder Hallen,
- auf anderen Parkflächen,
- temporär verlegt

waren. Die Aufnahme belegt deshalb Mindestpräsenz und Rampbelegung, aber nicht automatisch den vollständigen administrativen Gesamtbestand.

### 2.2 F-16-Einheit

Für Oktober 2011 bis April 2012 ist in Bagram belegt:

```text
121st Expeditionary Fighter Squadron
Lead-Verband: 113th Wing, District of Columbia Air National Guard
Muster: F-16C Block 30
Einsatzzeitraum: 13.10.2011 bis 14.04.2012
```

Der Verband wurde als ANG-`Rainbow Deployment` betrieben. Flugzeuge und Personal kamen mindestens aus:

```text
119th Fighter Squadron – New Jersey ANG
121st Fighter Squadron – District of Columbia ANG
124th Fighter Squadron – Iowa ANG
```

Im F-16.net-Deployment-Thread sind mindestens 13 einzelne F-16C Block 30 durch Seriennummern beziehungsweise Fotobelege dokumentiert:

```text
119th FS:
85-1498
85-1501
85-1481
85-1474

121st FS:
86-0342
87-0304
87-0310
87-0306

124th FS:
87-0265
87-0340
86-0327
87-0236
87-0291
```

Für die aktive OMW-ORBAT wird daraus **ein gemeinsames Expeditionary Squadron** gebildet. Die drei Heimatstaffeln werden nicht als drei unabhängige Bagram-SQUADRONs umgesetzt.

### 2.3 F-15E-Einheit

Eine offizielle USAF-/AFCENT-Meldung vom 14. November 2011 nennt für Bagram ausdrücklich:

```text
335th Expeditionary Fighter Squadron
Muster: F-15E Strike Eagle
```

Die 335th EFS operierte am 8. November 2011 gemeinsam mit der 121st EFS von Bagram aus. Damit ist die vorherige Bagram-Zuordnung zur 336th EFS für diese konkrete Missionsphase zu korrigieren.

### 2.4 Quellen

- U.S. Air Forces Central, `Coalition Forces 70, Taliban 0`, 14.11.2011
- U.S. Air Force, `Close air support protects coalition forces, kills 70 insurgents`, 14.11.2011
- 113th Wing, `113th Wing initiates first ANG F-16 deployment to Afghanistan`, 11.10.2011
- F-16.net, `Bagram AB Deployment 2011-12`, einschließlich der dokumentierten Rainbow-Seriennummern
- projektseitig ausgewertete Maxar-/Google-Earth-Satellitenaufnahme `12/2011`

## 3. Verbindliche aktive Fighter-ORBAT

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
│   13 F-15E als konservativer lokaler Mindest-/Arbeitsbestand
└── SQ_US_BGRM_F16C_121_EFS
    13 F-16C Block 30 als dokumentierter Rainbow-Bestand
```

### 3.1 Bestandsstatus

| Squadron | Historischer Nachweis | OMW-Arbeitsbestand | Status |
|---|---:|---:|---|
| 335th EFS / F-15E | mindestens 13 sichtbar | 13 | konservativer Arbeitsbestand; administrativer Gesamtbestand offen |
| 121st EFS / F-16C Block 30 | 13 Seriennummern dokumentiert, 11 sichtbar | 13 | historisch ausreichend belegt |

Die Werte sind keine Behauptung, dass exakt 13 Luftfahrzeuge die vollständige USAF-TOE der jeweiligen Einheit bildeten. Sie definieren einen konservativen, durch die vorhandenen Belege gedeckten lokalen Kampagnenbestand.

## 4. DCS-Abbildung

### 4.1 F-15E

Vorgesehenes DCS-Modul beziehungsweise Typ:

```text
F-15E Strike Eagle
DCS-Typname im Missionseditor noch exakt zu bestätigen
```

Status:

```text
THIRD_PARTY_AT_RISK
```

Alle F-15E-Spielerobjekte, Templates und Payloadregistrierungen müssen deaktivierbar bleiben, ohne den Bagram-AIRWING strukturell neu aufzubauen.

### 4.2 F-16C

Historisches Muster:

```text
F-16C Block 30
```

Verfügbare native DCS-Spielerabbildung:

```text
F-16C Block 50
```

Die DCS F-16C Block 50 wird als bewusster technischer Ersatz für den historischen Block 30 verwendet. Diese Abweichung ist in Mission, Dokumentation und späterer Payloadauswahl sichtbar zu kennzeichnen. Der genaue DCS-Typname ist im Missionseditor zu bestätigen.

## 5. Spielergruppen

Bagram besitzt ausreichend Rampfläche, deshalb gilt zunächst die globale Obergrenze von vier Spielerluftfahrzeugen je Fighter-Typ. Jede Clientgruppe enthält genau ein Luftfahrzeug.

### 5.1 F-15E

```text
CLIENT_US_BGRM_F15E_01
  CLIENT_US_BGRM_F15E_01_UNIT_01

CLIENT_US_BGRM_F15E_02
  CLIENT_US_BGRM_F15E_02_UNIT_01

CLIENT_US_BGRM_F15E_03
  CLIENT_US_BGRM_F15E_03_UNIT_01

CLIENT_US_BGRM_F15E_04
  CLIENT_US_BGRM_F15E_04_UNIT_01
```

### 5.2 F-16C

```text
CLIENT_US_BGRM_F16C_01
  CLIENT_US_BGRM_F16C_01_UNIT_01

CLIENT_US_BGRM_F16C_02
  CLIENT_US_BGRM_F16C_02_UNIT_01

CLIENT_US_BGRM_F16C_03
  CLIENT_US_BGRM_F16C_03_UNIT_01

CLIENT_US_BGRM_F16C_04
  CLIENT_US_BGRM_F16C_04_UNIT_01
```

### 5.3 Platzierungsregel

```text
F-16C-Clients: westliche/linke Fighter-Apronreihe
F-15E-Clients: östliche/rechte Fighter-Apronreihe
```

Die Aufteilung folgt der Satellitenaufnahme. Je Typ sind die vier besten, kollisionsfreien DCS-Parking-Nodes für Spieler zu reservieren. Diese Positionen dürfen nicht durch Statics oder dynamische KI belegt werden.

## 6. KI-Templates

Alle Gruppen:

- BLUE / USA,
- Late Activation,
- nicht `Uncontrolled`,
- Cold Start beziehungsweise Ramp Start,
- eindeutige Gruppen- und Einheitennamen,
- nicht auf den dauerhaften Spielerpositionen,
- technische Authoring Seeds und kein zusätzlicher Kampagnenbestand.

### 6.1 F-15E

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
  TPL_AIR_US_BGRM_F15E_CAS_2SHIP_UNIT_01
  TPL_AIR_US_BGRM_F15E_CAS_2SHIP_UNIT_02
```

```text
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
  TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP_UNIT_01
  TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP_UNIT_02
```

Geplante Rollen:

```text
CAS
STRIKE
ESCORT
```

### 6.2 F-16C

```text
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
  TPL_AIR_US_BGRM_F16C_CAS_2SHIP_UNIT_01
  TPL_AIR_US_BGRM_F16C_CAS_2SHIP_UNIT_02
```

```text
TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP
  TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP_UNIT_01
  TPL_AIR_US_BGRM_F16C_ARMED_RECON_2SHIP_UNIT_02
```

Geplante Rollen:

```text
CAS
ARMED RECONNAISSANCE
ESCORT
```

SEAD/DEAD wird nicht allein wegen der DCS-F-16C-Fähigkeit automatisch aktiviert. Eine entsprechende Kampagnenrolle benötigt eine separate fachliche Entscheidung.

## 7. MOOSE-SQUADRON-Modell

### 7.1 F-15E

Der Bestand 13 ist nicht glatt durch Two-Ship-Gruppen teilbar. Deshalb wird der technische MOOSE-Bestand nicht vorschnell als sieben Two-Ship-Gruppen mit rechnerisch 14 Flugzeugen angelegt.

Vor der Implementierung ist eine der folgenden Varianten verbindlich zu wählen und zu testen:

```text
Variante A:
12 Luftfahrzeuge / 6 Two-Ship-Asset-Gruppen
+ 1 separat geführte Reserve im CampaignState

Variante B:
13 Single-Ship-Asset-Gruppen
AUFTRAG-Paketbildung später über Missionszuweisung
```

Bevorzugter Testkandidat ist Variante A, weil die operativen Fighter-Aufträge als Two-Ship-Pakete vorgesehen sind und kein vierzehntes Flugzeug erfunden wird.

### 7.2 F-16C

Gleiche Bestandsproblematik:

```text
12 Luftfahrzeuge / 6 Two-Ship-Asset-Gruppen
+ 1 separat geführte Reserve im CampaignState
```

### 7.3 Geplante Struktur

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
└── SQ_US_BGRM_F16C_121_EFS
```

Der Bagram-Grundtest beginnt als Fighter-Knoten. C-130, HH-60G, UH-60 und CH-47 werden anschließend in einem eigenen Erweiterungsinkrement ergänzt, damit Fighter-Parking, Typen und AIRWING-Grundstart isoliert validiert werden können.

## 8. Sichtbare Statics

### 8.1 Grundsatz

Die Satellitenaufnahme soll erkennbar nachgebildet werden, ohne Spieler- und KI-Parking zu blockieren oder Luftfahrzeuge doppelt als verfügbaren Bestand zu zählen.

Bevorzugte erste Baseline:

```text
9 F-15E-Statics
7 F-16C-Statics
```

Zusammen mit maximal vier gleichzeitig aktiven Spieler- oder KI-Luftfahrzeugen je Typ kann damit die beobachtete Größenordnung von 13 F-15E beziehungsweise 11 F-16 auf dem Apron erreicht werden.

Die Statics bleiben visuelle Repräsentationen des logischen Bestands und sind keine zusätzlichen Luftfahrzeuge.

### 8.2 Namen F-15E

```text
STATIC_AIR_US_BGRM_F15E_01
STATIC_AIR_US_BGRM_F15E_02
STATIC_AIR_US_BGRM_F15E_03
STATIC_AIR_US_BGRM_F15E_04
STATIC_AIR_US_BGRM_F15E_05
STATIC_AIR_US_BGRM_F15E_06
STATIC_AIR_US_BGRM_F15E_07
STATIC_AIR_US_BGRM_F15E_08
STATIC_AIR_US_BGRM_F15E_09
```

### 8.3 Namen F-16C

```text
STATIC_AIR_US_BGRM_F16C_01
STATIC_AIR_US_BGRM_F16C_02
STATIC_AIR_US_BGRM_F16C_03
STATIC_AIR_US_BGRM_F16C_04
STATIC_AIR_US_BGRM_F16C_05
STATIC_AIR_US_BGRM_F16C_06
STATIC_AIR_US_BGRM_F16C_07
```

### 8.4 Optionale Erweiterung

Wenn genügend freie, nicht für Runtime benötigte Fläche vorhanden ist, kann die sichtbare Baseline nach einem Parking-Test bis auf die Satellitenzählung erweitert werden:

```text
maximal 13 F-15E-Statics
maximal 11 F-16C-Statics
```

Diese maximale Darstellung darf erst nach dokumentierter Parking- und Rollwegprüfung aktiviert werden.

## 9. Warehouse und Funktionszonen

### 9.1 Warehouse-Anker

```text
WH_AIR_US_BAGRAM
```

Der Anker ist außerhalb von Taxiway, Parking-Nodes, Blast-Bereichen und der Fighter-Ramp zu platzieren. Er muss als von MOOSE referenzierbares STATIC oder UNIT existieren.

### 9.2 Zonen

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Für den Fighter-Grundknoten werden zunächst keine Transport-, Slingload-, MEDEVAC- oder C-130-Zonen verlangt. Diese folgen mit der späteren Bagram-Transporterweiterung.

## 10. Missionseditor-Arbeitsanweisung

### Schritt 1 – leere technische Ausgangsmission

- Bagram BLUE/USA zuordnen.
- vorhandene zufällige oder alte Fighter-Gruppen entfernen beziehungsweise eindeutig außerhalb dieses Manifests kennzeichnen.
- keine Bagram-KI automatisch starten lassen.

### Schritt 2 – Parking erfassen

- alle verfügbaren Fighter-Parking-Nodes im DCS Mission Editor prüfen;
- TerminalIDs beziehungsweise Parking-Nummern dokumentieren;
- westliche F-16- und östliche F-15E-Reihe getrennt erfassen;
- ungeeignete Nodes markieren: zu eng, kollidierend, blockierter Rollweg, problematische Shelter-Geometrie;
- vier Spielerpositionen je Typ auswählen;
- mindestens vier dynamische KI-Reservepositionen je Typ vorsehen.

Ergebnis dieses Schrittes muss eine Tabelle enthalten:

```text
Parking-ID
Rampbereich
vorgesehener Typ
Client / KI / Static / frei
bekannte Einschränkung
```

### Schritt 3 – Clientgruppen setzen

- vier F-16C-Clientgruppen auf der westlichen Reihe;
- vier F-15E-Clientgruppen auf der östlichen Reihe;
- Skill `Client`;
- eine Unit pro Gruppe;
- Gruppen- und Unitnamen exakt nach Abschnitt 5;
- Cold Start;
- realistische Startausrichtung und keine gegenseitige Flügelüberdeckung.

### Schritt 4 – KI-Templates setzen

- zwei F-15E-Two-Ship-Templates;
- zwei F-16C-Two-Ship-Templates;
- Late Activation;
- Cold Start;
- Namen exakt nach Abschnitt 6;
- zunächst standardisierte, klar unterscheidbare Testpayloads;
- keine Templategruppe darf beim Missionsstart physisch erscheinen.

### Schritt 5 – Warehouse-Anker setzen

- Objektname exakt `WH_AIR_US_BAGRAM`;
- außerhalb aller Roll- und Parkingflächen;
- Koalition BLUE/USA;
- Objektart und DCS-Typ im Manifest nachtragen.

### Schritt 6 – Zonen setzen

- sechs Zonen aus Abschnitt 9.2;
- Static-Zonen über den historischen Rampreihen;
- KI-Reservezonen nur über tatsächlich geeigneten Runtime-Positionen;
- Load- und Recovery-Zone nicht mit Static-Zonen gleichsetzen;
- Radien so klein wie möglich und so groß wie technisch erforderlich.

### Schritt 7 – Statics setzen

Zuerst:

```text
9 F-15E
7 F-16C
```

Platzierung:

```text
F-16C westliche/linke Reihe
F-15E östliche/rechte Reihe
```

Dabei:

- Spieler- und KI-Reservepositionen freihalten;
- Flügel-, Leitwerks- und Shelterabstände kontrollieren;
- Taxiwege und Fahrgassen nicht blockieren;
- echte Parking-Nodes nur bewusst belegen;
- jede bewusst belegte TerminalID dokumentieren;
- spätere Parking-Blacklist aus genau diesen IDs ableiten.

### Schritt 8 – Mission speichern und Inventarliste liefern

Nach der Platzierung werden bereitgestellt:

- `.miz`,
- Screenshots der beiden Fighter-Rampen,
- Parking-/TerminalID-Liste,
- Liste aller Gruppen, Units, Statics und Zonen,
- verwendete DCS-Typnamen,
- verwendete Liveries,
- auffällige Kollisionen oder nicht nutzbare Nodes.

Erst danach wird das Bagram-Diagnose- und AIRWING-Bundle gebaut.

## 11. Erster Acceptance-Umfang

Der Fighter-Grundknoten muss mindestens nachweisen:

```text
8 Clientgruppen
4 Late-Activation-Templates / 8 Templateflugzeuge
16 sichtbare Statics
6 Zonen
1 Warehouse-Anker
2 SQUADRONs
1 AIRWING
1 bestehender BLUE COMMANDER
0 spontane Fighter-Spawns
0 Parking-Kollisionen
```

Zusätzlich:

- korrekte DCS-Typen,
- korrekte Gruppengrößen,
- korrekte Bestandsrechnung ohne erfundenes 14. Flugzeug,
- Safe Parking für alle acht Clientpositionen,
- dokumentierte Blacklist für bewusst durch Statics belegte Parking-Nodes,
- AIRWING-Start erst nach vollständiger Validierung,
- keine relevante Lua- oder Timerfehlermeldung.

## 12. Spätere Bagram-Erweiterung

Nach Fighter-Grundknoten-PASS folgen getrennt:

```text
C-130 / 774th Expeditionary Airlift Squadron
HH-60G / 83rd Expeditionary Rescue Squadron
UH-60-Familie / Task-Force- beziehungsweise Utility-Element
CH-47 Heavy Lift
CSAR
Transport und OPSTRANSPORT
Logistik-, Lade- und Entladezonen
```

Diese Erweiterung darf die validierten Fighter-Parking- und Rampregeln nicht ungeprüft verändern.
