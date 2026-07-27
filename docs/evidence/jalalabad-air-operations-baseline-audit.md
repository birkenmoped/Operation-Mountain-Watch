---
document_id: OMW-EVIDENCE-JBAD-AIR-OPS-BASELINE-AUDIT
status: HISTORICAL_TEST_FIXTURE
document_class: EVIDENCE_RECORD
authoritative_for:
  - inspected contents of the supplied Jalalabad baseline mission
  - contemporaneous mission inventory at audit time
not_authoritative_for:
  - active campaign ORBAT
  - current player slot limits
  - current project governance
source_record: docs/evidence/source-records/legacy-21-jalalabad-air-operations-baseline-audit.md
validated_in_dcs: false
---

# Jalalabad Air Operations – Prüfung der Ausgangsmission

## Einordnung

Dieses Dokument ist ein **unnummeriertes Evidenzdokument**. Es beansprucht nicht die reguläre Dokumentnummer 21.

Die Nummer `21` gehört ausschließlich zu:

- `OMW-AIR-JBAD-MANIFEST – docs/21-jalalabad-air-operations-manifest.md`

Der unveränderte ursprüngliche Audittext mit seinem damaligen Titel bleibt aus Gründen der Nachvollziehbarkeit erhalten:

- [`Legacy-Audit: früheres Dokument 21`](source-records/legacy-21-jalalabad-air-operations-baseline-audit.md)

Aussagen zu früheren Staffelzuordnungen, Beständen oder Projektgrenzen sind historische Prüffeststellungen. Aktuelle verbindliche Entscheidungen stehen in `OMW-GOV-001`, `OMW-AIR-ACTIVE-ORBAT` und den jeweils zuständigen Fachmanifesten.

## Geprüfte Datei

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
SHA-256: 898703f5b738a632492e514f8943327634a0d094716fd7f4c971c9b2582fb50b
```

Die Datei wurde als unveränderte Arbeitskopie für die erste AIRWING-/ORBAT-Umsetzung bereitgestellt.

## Technischer Missionsinhalt

Die geprüfte DCS-Mission enthielt:

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

### Eingebettete MOOSE-Version

```text
MOOSE GitHub commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Build timestamp:
2026-06-14T16:11:05+02:00

SHA-256 der eingebetteten Moose.lua:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Provenienz ist im aktuellen zentralen MOOSE-Nachweisdokument genauer klassifiziert. Dieses Audit bleibt der Nachweis dafür, welche Datei in der geprüften Baseline eingebettet war.

## Vorhandene Startskripte

Die Triggerreihenfolge war:

```text
1. LOAD_MOOSE    -> Moose.lua
2. LOAD_TM02W2F  -> TM02W2F.lua
```

`TM02W2F.lua` war der RED-Initial-Network-Fill-/Watchdog-Testbundle und nicht Teil der neuen Luftoperationslogik.

Für die erste AIRWING-Validierung wurden zwei Testformen unterschieden:

- **Integrationstest:** TM02W2F bleibt aktiv.
- **Isolationstest:** Nur `LOAD_TM02W2F` wird in einer weiteren Arbeitskopie deaktiviert; MOOSE bleibt unverändert aktiv.

Die bereitgestellte Datei selbst blieb als unveränderte Baseline erhalten.

## Vorhandene Mission-Editor-Objekte

### Luftfahrzeuge

In der Ausgangsmission existierte genau eine bemannte Luftfahrzeuggruppe:

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

Damit existierte noch kein Spieler-Slot in Jalalabad und noch kein Luftfahrzeug-Template für die neue ORBAT.

### Jalalabad Air Operations

Nicht vorhanden waren:

- Gruppen mit Präfix `CLIENT_US_JBAD_`;
- Gruppen mit Präfix `TPL_AIR_US_JBAD_`;
- Statics mit Präfix `STATIC_AIR_US_JBAD_`;
- technischer Warehouse-Anker `WH_AIR_US_JALALABAD`;
- Air-Ops-Zonen mit Präfix `ZONE_AIR_US_JBAD_`;
- AIRWING-/SQUADRON-Bootstrap.

Das war der erwartete Ausgangszustand vor der ersten Air-Ops-Platzierung.

### Triggerzonen

Die Mission enthielt 26 Triggerzonen, darunter:

```text
ZONE_TM01_TARGET_JALALABAD
OMW_BLUE_OBJECTIVE_Airport
```

Diese Zonen ersetzten keine noch anzulegenden Air-Ops-Park-, Static-, MEDEVAC- und Logistikzonen.

### Statische Objekte

Die Mission enthielt 1.273 blaue Static-Gruppen, überwiegend FOB-, HESCO-, Gebäude-, Personal- und FARP-Infrastruktur. Im Radius von fünf Kilometern um die Jalalabad-Airport-Zielzone wurde kein als Missions-Static platziertes Objekt gefunden.

Die sichtbaren Gebäude in Jalalabad/Fenty waren daher zunächst als Kartenszenerie beziehungsweise DCS-Airbase-Infrastruktur zu behandeln, nicht als benannte MOOSE-`STATIC`-Objekte.

### DCS-Warehouse-Datei

Die `.miz` enthielt 26 Airfield-Einträge sowie acht Missions-Warehouse-Einträge. Die acht Missions-Warehouses gehörten vorhandenen `FARP_SINGLE_01`-Statics an anderen FOB-Standorten.

Für Jalalabad war kein eindeutig benannter Missions-Static als MOOSE-AIRWING-Anker vorhanden. Das DCS-Airfield-Warehouse ersetzte den von `AIRWING:New()` benötigten benannten `STATIC`-/`UNIT`-Anker nicht automatisch.

## Koordinatenreferenz

Die Mission enthielt den Navigationspunkt:

```text
FOB Fenty
x = 72606.96657529
y = 389160.02536148
```

Diese Position diente nur als Orientierung. Operative Parkpositionen, Warehouse-Anker und Zonen mussten im Mission Editor und über den Parking-Dump validiert werden.

## Prüfergebnis

Die Mission war als unveränderte Referenz und Ausgangskopie geeignet, aber noch keine vorbereitete Air-Ops-Testmission.

Vor dem ersten AIRWING-Start fehlten:

1. Jalalabad-Warehouse-Anker;
2. Spieler-Slots;
3. KI-Late-Activation-Templates;
4. gepoolte Luftfahrzeug-Statics;
5. Air-Ops-Zonen;
6. Payload-Templates;
7. AIRWING-/SQUADRON-Bootstrap.

Die nachfolgenden Arbeiten wurden durch das Jalalabad Air Operations Manifest und die Diagnosewerkzeuge unter `mission/tests/jalalabad-air-operations/` gesteuert.
