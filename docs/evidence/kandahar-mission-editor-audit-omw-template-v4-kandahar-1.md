---
document_id: OMW-EVIDENCE-KANDAHAR-ME-AUDIT-V4-1
status: STRUCTURALLY_AUDITED_UNVALIDATED
owning_policy: OMW-GOV-001
authoritative_for:
  - structural contents of OMW_Template_v4_Kandahar(1).miz
  - Kandahar client template static warehouse and zone inventory
  - Kandahar native airbase split
  - differences from documents 33 35 and 36
source_branch: agent/kandahar-airwing-baseline-contract
source_parent: docs/bagram-air-operations-manifest@0a3cfb5a8129d4f883de27c32e4653a02422c050
source_mission: OMW_Template_v4_Kandahar(1).miz
source_size_bytes: 2180824
source_sha256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
validated_in_dcs: false
---

# Kandahar Mission Editor Audit – OMW Template v4 Kandahar (1)

## 1. Zweck und Grenze

Dieses Dokument hält den strukturell geprüften Inhalt der vom Projektinhaber übergebenen Kandahar-Arbeitsmission fest. Es ersetzt keine DCS-Laufzeitvalidierung. Parking-, Taxi-, Spawn-, Landungs-, Rückgabe- und MOOSE-AIRWING-Funktionen sind erst nach einem separaten Diagnoselauf abgenommen.

Die Mission ist die aktuelle Mission-Editor-Source-of-Truth für die Weiterarbeit an Kandahar. Sie enthält zugleich den zuletzt eingebetteten Bagram-Laufzeitstand.

## 2. Dateiidentität

```text
Datei: OMW_Template_v4_Kandahar(1).miz
Größe: 2.180.824 Bytes
SHA-256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
Theatre: Afghanistan
Missionsdatum: 2011-01-14
```

## 3. Eingebettete Laufzeitkomponenten

Das Archiv enthält unter anderem:

```text
l10n/DEFAULT/Moose.lua
l10n/DEFAULT/OMW_AirOps_Bagram.lua
l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
l10n/DEFAULT/TM01M.lua
mission
warehouses
```

Eingebetteter MOOSE-Hash:

```text
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Dieser Hash entspricht dem im Projekt festgelegten MOOSE-2.9.18-Stand.

Bagram-Bundle-Metadaten:

```text
Builder: tools/build-bagram-air-operations-bundle.ps1
BuilderVersion: BGRAM-JBAD-FIXED-WING-WAVE-1
GitCommit: 9b0095dfaa7cdc4c4c1951f94e29e8c024a54f0a
```

Die späteren Bagram-Branch-Commits bis `0a3cfb5a8129d4f883de27c32e4653a02422c050` änderten die Übergabedokumentation, nicht den eingebetteten Laufzeitstand. Der automatische Bagram-Massentransfer ist in diesem Source-Stand standardmäßig deaktiviert.

Ein Kandahar-Laufzeitbundle oder Kandahar-Trigger ist noch nicht eingebettet.

## 4. Native Kandahar-Airbases

Die Mission verwendet zwei getrennte native DCS-Airbases:

```text
airdromeId 7
MOOSE: AIRBASE.Afghanistan.Kandahar
Verwendung: A-10C- und C-130-Clients / Main Airfield

airdromeId 15
MOOSE: AIRBASE.Afghanistan.Kandahar_Heliport
Verwendung: AH-64D-, OH-58D- und CH-47F-Clients / Mustang Ramp
```

Die Mission-Editor-Parkplatzbezeichnungen sind keine autoritativen MOOSE-TerminalIDs. Eine getrennte Laufzeitdiagnose ist für beide Airbases erforderlich.

## 5. Warehouse-Anker

Vorhanden ist genau ein technischer Anker:

```text
Gruppe/Einheit: WH_AIR_US_KANDAHAR
DCS-Typ: container_40ft
Group ID: 1422
Unit ID: 1499
X: -270272.82271524
Y: -30290.24801922
```

Ein zweiter Warehouse-Anker für `Kandahar_Heliport` ist nicht vorhanden.

## 6. Clientgruppen

### 6.1 Kandahar Main Airfield

```text
CLIENT_US_KAF_A10C_01 | A-10C_2   | Z20 | ME parking 282 | airdromeId 7
CLIENT_US_KAF_A10C_02 | A-10C_2   | Z19 | ME parking 287 | airdromeId 7
CLIENT_US_KAF_C130_01 | C-130J-30 | S01 | ME parking 294 | airdromeId 7
CLIENT_US_KAF_C130_02 | C-130J-30 | S02 | ME parking 92  | airdromeId 7
```

### 6.2 Kandahar Heliport / Mustang Ramp

```text
CLIENT_US_KAF_AH64D_01 | AH-64D_BLK_II | MST38-H | ME parking 30 | airdromeId 15
CLIENT_US_KAF_AH64D_02 | AH-64D_BLK_II | MST30-H | ME parking 19 | airdromeId 15
CLIENT_US_KAF_OH58D_01 | OH58D          | MST01-H | ME parking 80 | airdromeId 15
CLIENT_US_KAF_OH58D_02 | OH58D          | MST11-H | ME parking 23 | airdromeId 15
CLIENT_US_KAF_CH47F_01 | CH-47Fbl1      | MST75-H | ME parking 4  | airdromeId 15
CLIENT_US_KAF_CH47F_02 | CH-47Fbl1      | MST82-H | ME parking 47 | airdromeId 15
```

```text
Gesamt: 10 Clientgruppen / 10 Spielerluftfahrzeuge
Maximal zwei Clients je Muster und Basis
Je Clientgruppe ein Luftfahrzeug
UH-60-Clientgruppen: 0
```

## 7. Late-Activation-Templates

Alle folgenden Gruppen sind `Late Activation = true`, `Uncontrolled = false` und beginnen ohne feste Parking-ID als Authoring-Seeds:

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP          | 2 x A-10C
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP    | 1 x C-130
TPL_AIR_US_KAF_HH60G_CSAR_1SHIP        | 1 x UH-60A
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP        | 1 x RQ-1A Predator
TPL_AIR_US_KAF_MQ9_RECON_1SHIP         | 1 x MQ-9 Reaper
TPL_AIR_US_KAF_AH64D_CAS_2SHIP         | 2 x AH-64D_BLK_II
TPL_AIR_US_KAF_OH58D_RECON_2SHIP       | 2 x OH58D
TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP    | 1 x CH-47Fbl1
TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP    | 2 x UH-60A
TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP      | 1 x UH-60A
```

Nicht mehr vorhanden sind die in älteren Dokumenten getrennt geführten Seeds:

```text
TPL_AIR_US_KAF_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_KAF_HH60G_CSAR_COVER_1SHIP
TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP
TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP
```

Die aktuelle Mission verwendet typbasierte Seeds; Rollenvarianten sollen später über SQUADRON, Payload, AUFTRAG und FLIGHTGROUP abgebildet werden.

## 8. Aircraft-Statics

### 8.1 USAF / ISR

```text
6 x A-10C_2
2 x C-130J-30
2 x UH-60A als HH-60G-/CSAR-Repräsentation
2 x RQ-1A Predator
1 x MQ-9 Reaper
Gesamt: 13
```

### 8.2 Army Aviation / Mustang Ramp

```text
8 x AH-64D_BLK_II
8 x OH58D
10 x CH-47Fbl1
8 x UH-60A
Gesamt: 34
```

### 8.3 UN

```text
2 x Mi-26
4 x UH-1H
Gesamt: 6
```

US-Luftfahrzeug-Statics gesamt: 47. Diese Objekte sind visuelle Repräsentationen vorhandener Bestände und keine zusätzlichen logischen Airframes.

Zusätzlich vorhanden:

```text
STATIC_GND_US_KAF_M113_MEDIC
```

## 9. Vorhandene Triggerzone

```text
ZONE_AIR_US_KAF_CSAR_UNLOAD
X: -270821.26399861
Y: -29819.229623724
Radius: 30.48 m
```

Weitere Kandahar- oder Mustang-Ramp-Funktionszonen sind nicht vorhanden.

## 10. Payload-Rohbefund

Die exakte Waffenbezeichnung unbekannter CLSIDs ist vor einer verbindlichen Payload-Entscheidung gegen den tatsächlich verwendeten DCS-Datenstand zu prüfen.

### A-10C

Das KI-Template besitzt eine bewaffnete CAS-Konfiguration einschließlich zweier CBU-87 sowie weiterer belegter Stationen. Eine vollständige normalisierte Payloadliste steht noch aus.

### MQ-1A

Das Template besitzt zwei belegte Pylon-Einträge mit:

```text
{ee368869-c35a-486a-afe7-284beb7c5d52}
```

Damit ist die aktuelle Mission nicht mit der bisherigen dokumentierten unbewaffneten MQ-1-RECON-Baseline vereinbar. Vor Laufzeitregistrierung müssen die Pylons geleert oder der Typ eindeutig gemappt und ausdrücklich freigegeben werden.

### MQ-9

Rohbefund:

```text
Pylon 1: AGM114x2_OH_58
Pylon 2: Paveway-II-konfigurierter Bomben-CLSID, Laser Code 1688
Pylon 3: Paveway-II-konfigurierter Bomben-CLSID, Laser Code 1688
Pylon 4: AGM114x2_OH_58
```

Damit trägt das Template vier AGM-114 sowie zwei Paveway-II-konfigurierte Bomben. Die frühere Dokumentation mit zwei GBU-38 entspricht nicht der aktuellen Mission.

### AH-64D

Vorhanden sind M261-Raketenbehälter, zwei Hellfire-Racks, IAFS-Kombinationspaket und 25 Prozent Kanonenmunition.

### OH-58D

Vorhanden sind:

```text
M260_APKWS_M151
OH58D_AGM_114_R
```

Die zeitliche und projektseitige Zulässigkeit der APKWS-Konfiguration muss vor produktiver Verwendung gesondert entschieden werden.

### CH-47F

Vorhanden sind:

```text
CH47_PORT_M60D
CH47_STBD_M60D
```

## 11. Typ- und Dokumentabweichungen

```text
A-10 Clients/Statics: A-10C_2
A-10 KI-Template: A-10C

C-130 Clients/Statics: C-130J-30
C-130 KI-Template: C-130

AH-64 Clients/Templates/Statics: AH-64D_BLK_II
CH-47 Clients/Templates/Statics: CH-47Fbl1
OH-58D Clients/Templates/Statics: OH58D
UH-60 Templates/Statics: UH-60A
```

Die A-10- und C-130-Templateabweichungen müssen vor SQUADRON-Registrierung entweder korrigiert oder als bewusste DCS-Repräsentation dokumentiert werden.

## 12. Sichtbarer Footprint – keine Bestandsentscheidung

Bei vollständiger Belegung aller Clients und einmaliger Aktivierung jedes aktuellen Seeds ergibt sich rein darstellerisch:

```text
A-10:   6 Statics + 2 Clients + 2 KI = 10
C-130:  2 Statics + 2 Clients + 1 KI = 5
HH-60:  2 Statics + 0 Clients + 1 KI = 3
MQ-1:   2 Statics + 0 Clients + 1 KI = 3
MQ-9:   1 Static  + 0 Clients + 1 KI = 2
AH-64:  8 Statics + 2 Clients + 2 KI = 12
OH-58D: 8 Statics + 2 Clients + 2 KI = 12
CH-47: 10 Statics + 2 Clients + 1 KI = 13
UH-60:  8 Statics + 0 Clients + 3 KI = 11
```

Diese Zahlen sind keine logischen Anfangsbestände. Nur der Bestand von 16 A-10C ist bislang verbindlich festgelegt.

## 13. MOOSE-Architekturentscheidung

Der eingebettete MOOSE-2.9.18-Stand bindet ein `AIRWING` über sein `WAREHOUSE` an genau eine Airbase. `SQUADRON:SetParkingIDs()` arbeitet innerhalb der Airbase des übergeordneten AIRWING-Warehouses.

Daraus folgt verbindlich:

```text
Kandahar Main Airfield und Kandahar Heliport dürfen nicht durch ein einziges
technisches AIRWING-/WAREHOUSE-Paar betrieben werden.
```

Festgelegt wird:

1. `AW_US_KANDAHAR` und `WH_AIR_US_KANDAHAR` bleiben für den Main-Airfield-/USAF-Vertrag reserviert.
2. Für `AIRBASE.Afghanistan.Kandahar_Heliport` wird ein zweites AIRWING-/WAREHOUSE-Paar benötigt.
3. Der zweite AIRWING- und Warehouse-Name wird nicht erfunden, sondern vor Mission-Editor- und Lua-Umsetzung durch den Projektinhaber festgelegt.
4. Mustang-Ramp-SQUADRONs bleiben bis zur Anlage und Validierung dieses zweiten Warehouse-Ankers fail-closed deaktiviert.
5. Die technische Zuordnung der 26th-ERQS-CSAR-Repräsentation sowie der Luftstart-UAVs wird vor Registrierung gesondert entschieden.

## 14. Parent-Pool- und Doppelzählungsgrenze

Tarinkot besitzt verbindlich:

```text
14 AH-64D
6 UH-60
2 CH-47
0 OH-58D
```

Diese Luftfahrzeuge sind aus dem Kandahar-/RC-South-Regionalpool abzuziehen. Weitere Forward Detachments sind ebenfalls zu berücksichtigen. Ohne verbindlichen regionalen Gesamtpool dürfen für die Kandahar-Army-SQUADRONs keine Anfangsbestände aus Statics, Clients oder Templates abgeleitet werden.

## 15. Offene Blocker vor AIRWING-Registrierung

- zweiter Warehouse-Anker und freigegebene Bezeichner für Kandahar Heliport;
- logische Bestände für C-130, HH-60G, MQ-1, MQ-9, AH-64, OH-58D, CH-47 und UH-60;
- Tarinkot- und weitere Forward-Detachment-Abzüge;
- technische Stationierung des 26th ERQS;
- UAV-Warehouse- oder externes Kontingentmodell;
- Korrektur beziehungsweise Freigabe der MQ-1-/MQ-9-Payloads;
- Entscheidung zur OH-58D-APKWS-Konfiguration;
- A-10- und C-130-Template-Typangleichung;
- getrennte Runtime-Parkingdaten für beide Airbases;
- Safe-Parking-Allow-/Blocklists;
- Funktionszonen nur nach konkretem MOOSE-Bedarf.

## 16. Nächster ausführbarer Test

Der nächste Runtime-Inkrement ist ein reiner:

```text
Kandahar Dual-Airbase No-Spawn Diagnostic
```

Er muss MOOSE-Version, beide Airbases, Warehouse-Anker, Clients, Templates, Statics, Payload-Signaturen, Zonen und sämtliche Parking-/Helipad-Daten protokollieren.

Er darf noch keine AIRWINGs starten, keine SQUADRON-Bestände registrieren, keine Assets spawnen und keine AUFTRAG-/OPSTRANSPORT-/CSAR-/ISR-Funktion ausführen.
