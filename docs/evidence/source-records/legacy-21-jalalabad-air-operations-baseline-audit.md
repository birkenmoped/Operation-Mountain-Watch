# 21 – Jalalabad Air Operations: Prüfung der Ausgangsmission

## Geprüfte Datei

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
SHA-256: 898703f5b738a632492e514f8943327634a0d094716fd7f4c971c9b2582fb50b
```

Die Datei wurde als unveränderte Arbeitskopie für die erste AIRWING-/ORBAT-Umsetzung bereitgestellt.

## Technischer Inhalt der `.miz`

Die Mission ist eine gültige ZIP-basierte DCS-Mission und enthält:

```text
mission
warehouses
options
theatre
l10n/DEFAULT/Moose.lua
l10n/DEFAULT/TM02W2F.lua
l10n/DEFAULT/dictionary
l10n/DEFAULT/mapResource
```

### Missionsrahmen

```text
Karte: Afghanistan
Missionsdatum: 2. Mai 2011
Startzeit: 08:00 Uhr Missionszeit
DCS-Missionsformat: Version 23
requiredModules: leer
```

Das Missionsdatum passt zum gewählten späteren ORBAT-Zustand mit Task Force Six Shooters, 75th EFS und HMLA-169.

### Eingebettete MOOSE-Version

Die Mission lädt zuerst `Moose.lua`.

```text
MOOSE GitHub commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Build timestamp:
2026-06-14T16:11:05+02:00

SHA-256 der eingebetteten Moose.lua:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Diese Datei wird als erste festgeschriebene MOOSE-Version für den Jalalabad-Air-Ops-Prototyp verwendet. Ein späterer Versionswechsel benötigt einen eigenen Testlauf und eine dokumentierte Freigabe.

### Vorhandene Mission-Start-Skripte

Die Triggerreihenfolge ist:

```text
1. LOAD_MOOSE    -> Moose.lua
2. LOAD_TM02W2F  -> TM02W2F.lua
```

`TM02W2F.lua` ist weiterhin der RED-Initial-Network-Fill-/Watchdog-Testbundle und nicht Teil der neuen Luftoperationslogik.

Für die erste reine AIRWING-Validierung muss daher bewusst entschieden werden:

- **Integrationstest:** TM02W2F bleibt aktiv; Air Operations werden unter gleichzeitiger RED-Testlast geprüft.
- **Isolationstest:** In einer weiteren Arbeitskopie wird nur der Trigger `LOAD_TM02W2F` deaktiviert; MOOSE bleibt unverändert aktiv.

Die bereitgestellte Datei selbst bleibt als unveränderte Baseline erhalten.

## Vorhandene Mission-Editor-Objekte

### Luftfahrzeuge

In der Ausgangsmission existiert genau eine bemannte Luftfahrzeuggruppe:

```text
Gruppe: TEST_TM01A_CLIENT_01
Einheit: TEST_TM01A_CLIENT_UNIT_01
Typ: OH58D
Skill: Player
Airbase-ID: 16
Parkplatz ME: C10
interner Parking-Wert: 112
Position: Bagram Airfield
```

Damit existiert noch kein Spieler-Slot in Jalalabad und noch kein Luftfahrzeug-Template für die neue ORBAT.

### Jalalabad Air Operations

In der Ausgangsmission wurden nicht gefunden:

- keine Gruppen mit Präfix `CLIENT_US_JBAD_`,
- keine Gruppen mit Präfix `TPL_AIR_US_JBAD_`,
- keine Statics mit Präfix `STATIC_AIR_US_JBAD_`,
- kein technischer Warehouse-Anker `WH_AIR_US_JALALABAD`,
- keine Air-Ops-Zonen mit Präfix `ZONE_AIR_US_JBAD_`,
- kein AIRWING-/SQUADRON-Bootstrap.

Das ist der erwartete Ausgangszustand vor der ersten Air-Ops-Platzierung.

### Triggerzonen

Die Mission enthält 26 Triggerzonen. Dazu gehören bestehende TM01-/TM02-Testzonen und die Jalalabad-Zielzone:

```text
ZONE_TM01_TARGET_JALALABAD
OMW_BLUE_OBJECTIVE_Airport
```

Diese Zonen sind keine Ersatzobjekte für die noch anzulegenden Air-Ops-Park-, Static-, MEDEVAC- und Logistikzonen.

### Statische Objekte

Die Mission enthält 1.273 blaue Static-Gruppen, überwiegend FOB-, HESCO-, Gebäude-, Personal- und FARP-Infrastruktur. Im Radius von fünf Kilometern um die vorhandene Jalalabad-Airport-Zielzone wurde jedoch kein als Missions-Static platziertes Objekt gefunden.

Die auf der Afghanistan-Karte sichtbaren Gebäude in Jalalabad/Fenty sind daher in dieser Mission zunächst als Kartenszenerie beziehungsweise DCS-Airbase-Infrastruktur zu behandeln, nicht als benannte MOOSE-`STATIC`-Objekte.

### DCS-Warehouse-Datei

Die `.miz` besitzt eine reguläre DCS-Datei `warehouses` mit 26 Airfield-Einträgen sowie acht Missions-Warehouse-Einträgen. Die acht Missions-Warehouses gehören vorhandenen `FARP_SINGLE_01`-Statics an anderen FOB-Standorten.

Für Jalalabad ist noch kein eindeutig benannter Missions-Static als MOOSE-AIRWING-Anker vorhanden. Das vorhandene DCS-Airfield-Warehouse ersetzt den von `AIRWING:New()` benötigten benannten `STATIC`-/`UNIT`-Anker nicht automatisch.

## Vorhandene Koordinatenreferenz

Die Mission enthält einen Navigationspunkt:

```text
FOB Fenty
x = 72606.96657529
y = 389160.02536148
```

Diese Position dient nur als Orientierung. Operative Parkpositionen, Warehouse-Anker und Zonen werden nicht anhand dieses einzelnen Navigationspunkts automatisch festgelegt, sondern im Mission Editor und über den Parking-Dump validiert.

## Ergebnis

Die Mission ist als unveränderte Referenz und Ausgangskopie geeignet. Sie ist jedoch noch keine vorbereitete Air-Ops-Testmission.

Vor dem ersten AIRWING-Start fehlen vollständig:

1. Jalalabad-Warehouse-Anker,
2. Spieler-Slots,
3. KI-Late-Activation-Templates,
4. gepoolte Luftfahrzeug-Statics,
5. Air-Ops-Zonen,
6. Payload-Templates,
7. AIRWING-/SQUADRON-Bootstrap.

Die nächsten Schritte werden durch das Jalalabad Air Operations Manifest und die Diagnosewerkzeuge unter `mission/tests/jalalabad-air-operations/` festgelegt.
