# 19 – Verbindliche Entscheidungen zur aktiven Luft-ORBAT

## 1. Zweck und Autorität

Dieses Dokument hält die verbindlichen Auswahlentscheidungen für die aktive Luft-ORBAT fest. Historische Alternativen und nicht ausgewählte Vorgängereinheiten bleiben in:

```text
docs/us-air-orbat-2010-2011.md
```

dokumentiert, werden aber nicht automatisch als zusätzliche Spieler-, KI-, Static- oder CampaignState-Bestände umgesetzt.

Gemeinsame Betriebsregeln:

```text
docs/18-air-operations-implementation.md
```

Basisbezogene Manifeste dürfen aufgrund realer DCS-Park-, Asset- und Missionseditorgrenzen strengere lokale Regeln festlegen.

## 2. Aktueller Entscheidungsstatus

| Nr. | Flugplatz | Bereich | Verbindliche aktive Entscheidung | Status |
|---:|---|---|---|---|
| 1 | Bagram | F-15E | 336th Expeditionary Fighter Squadron, 16 F-15E | entschieden, noch technisch umzusetzen |
| 2 | Jalalabad / FOB Fenty | Army Aviation | Task Force Shooter mit 24 OH-58D, 8 AH-64D, 8 UH-60 und 8 CH-47 | **vollständig validierter Referenzknoten** |
| 3 | Kandahar | A-10C | 75th Expeditionary Fighter Squadron, 16 A-10C | entschieden, noch technisch umzusetzen |
| 4 | Camp Bastion | AH-1W / UH-1Y | HMLA-169 „Vipers“, 10 AH-1W und 5 UH-1Y | entschieden; UH-1Y-DCS-Abbildung offen |
| 5 | Camp Bastion | MV-22B | keine aktive Umsetzung | entschieden: entfällt vollständig |
| 6 | Camp Bastion | Heavy Lift | HMH-361 (-) Reinforced, 17 CH-53E | entschieden, DCS-/MOOSE-Verhalten noch zu validieren |

Automatische Verbandswechsel über ein fortlaufendes Kampagnendatum werden zunächst nicht umgesetzt.

## 3. Globale technische Obergrenzen

```text
maximale Spielerluftfahrzeuge je Typ und Basis: 4
maximale KI-Luftfahrzeuge je Typ und Basis: 4
maximale parallele KI-Unterstützungsmissionen: 2
maximale Luftfahrzeuge je Unterstützungsmission: 2
maximale aktive Unterstützungs-Luftfahrzeuge: 4
```

Diese Werte sind Obergrenzen, keine Pflichtwerte. Jalalabad verwendet aufgrund der verfügbaren Rampflächen das strengere lokale Spielerlimit von zwei Luftfahrzeugen je nutzbarem Typ.

## 4. Bagram – F-15E

### Verbindliche Entscheidung

```text
Einheit: 336th Expeditionary Fighter Squadron
Flugplatz: Bagram Airfield
Muster: F-15E
Lokaler ORBAT-Bestand: 16
```

Die 494th Expeditionary Fighter Squadron bleibt historische Vorgängereinheit und erhält keine eigene aktive Umsetzung.

Die F-15E bleibt wegen unsicherer langfristiger Modulpflege als `THIRD_PARTY_AT_RISK` eingestuft. Spieler- und Missionseditorobjekte müssen deaktivierbar bleiben, ohne den strategischen Kampagnenbestand strukturell umzubauen.

## 5. Jalalabad / FOB Fenty – Army Aviation

### 5.1 Validierter Bestand

```text
6th Squadron, 6th Cavalry Regiment / Task Force Shooter
OH-58D: 24

B Company, 1-10 Aviation
AH-64D: 8

angegliedertes Utility-/MEDEVAC-Element
UH-60-Familie: 8

Task Force Shooter Heavy-Lift-Element
CH-47: 8
```

Die genaue historische Kompaniebezeichnung des CH-47-Elements bleibt neutral, solange der exakte Rotationsbezug nicht abschließend belegt ist. Der Bestand und die lokale Präsenz sind für die Mission ausreichend begründet.

### 5.2 Satelliten-Momentaufnahme 2011

Mindestens gezählt:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Mi-8 und UH-1 werden als externe oder transiente Luftfahrzeuge dokumentiert und nicht dem US-Bestand zugerechnet.

### 5.3 Validierter Missionsbestand

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
│   24 Luftfahrzeuge / 12 Two-Ship-Asset-Gruppen / RECON
├── SQ_US_JBAD_AH64D_B_1_10_AVN
│   8 Luftfahrzeuge / 4 Two-Ship-Asset-Gruppen / CAS
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
│   8 Luftfahrzeuge / 8 Single-Ship-Asset-Gruppen
└── SQ_US_JBAD_CH47_HEAVYLIFT
    8 Luftfahrzeuge / 8 Single-Ship-Asset-Gruppen
```

Validierte DCS-Typen:

```text
OH58D
AH-64D_BLK_II
UH-60A
CH-47Fbl1
```

### 5.4 Spielerlimit

```text
OH-58D: 2 Clientgruppen
AH-64D: 2 Clientgruppen
CH-47: 2 Clientgruppen
UH-60L Community Mod: 0 oder 2 optionale Clientgruppen
```

### 5.5 Static-Obergrenzen

```text
7 OH-58D
4 AH-64D
4 UH-60A
5 CH-47F
```

### 5.6 Darstellung und Verluste

Logischer Bestand, aktive Luftfahrzeuge, sichtbare Statics und virtuelle Reserve sind getrennte Ebenen.

Ein endgültiger Verlust reduziert den logischen Bestand dauerhaft. Ein anderes bereits vorhandenes Reserveflugzeug darf später nachrücken, stellt aber keinen externen Ersatz dar.

### 5.7 MEDEVAC

```text
1 UH-60 Lead
+
1 UH-60 Cover
=
1 logisches Two-Ship-MEDEVAC-Paket
```

Kein regulärer Single-Ship-Fallback.

### 5.8 Validierungsstatus

```text
Source-Commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
BuilderVersion: JBAD-AIR-OPS-COMPLETE-5
Ergebnis: OPERATIONAL / ACCEPTED
```

Bestätigt:

- Airbase-ID 19 und 50 Parking-Einträge,
- Warehouse-Anker und Storage,
- sechs Clientgruppen,
- fünf KI-Templates,
- 20 Statics,
- elf Zonen,
- vier SQUADRONs,
- CH-47-Parking-Blacklist `23,35,37,49`,
- Safe Parking,
- AIRWING- und COMMANDER-Start,
- keine spontane Jalalabad-KI-Mission.

Autoritative Details:

```text
docs/21-jalalabad-air-operations-manifest.md
docs/23-jalalabad-parking-template-and-medevac-model.md
docs/24-jalalabad-ch47-static-parking-reservations.md
docs/25-jalalabad-final-validation-and-operational-baseline.md
```

Task Force Lighthorse bleibt ausschließlich als historische Vorgängereinheit dokumentiert.

## 6. Kandahar – A-10C

```text
Einheit: 75th Expeditionary Fighter Squadron
Flugplatz: Kandahar Airfield
Muster: A-10C
Lokaler ORBAT-Bestand: 16
```

Die 81st Expeditionary Fighter Squadron bleibt historische Vorgängereinheit und erhält keine eigene aktive Umsetzung.

Geplante Struktur:

```text
AW_US_KANDAHAR
└── SQ_75_EFS_A10C
```

## 7. Camp Bastion – HMLA

```text
Einheit: HMLA-169 „Vipers“
AH-1W: 10
UH-1Y: 5
```

Die fünf UH-1Y bleiben Bestandteil der historischen und strategischen ORBAT. Ihre physische DCS-Umsetzung bleibt deaktiviert, bis ein geeignetes natives oder ausdrücklich zugelassenes Asset bestätigt ist. Eine UH-1H wird nicht automatisch als historisch falscher Ersatz verwendet.

HMLA-369 bleibt ausschließlich als historische Vorgängereinheit dokumentiert.

Geplante Struktur:

```text
AW_USMC_BASTION
├── SQ_HMLA_169_AH1W
└── SQ_HMLA_169_UH1Y   # erst nach bestätigter Asset-Entscheidung
```

## 8. Camp Bastion – MV-22B

```text
aktive Umsetzung: keine
CampaignState-Bestand: 0
Spieler-Slots: 0
KI-SQUADRONs: 0
Statics/RAT/Ersatzdarstellungen: 0
```

VMM-365 und VMM-264 bleiben historische Dokumentation. Eine spätere Wiedereinführung wäre eine neue ausdrückliche Architekturentscheidung.

## 9. Camp Bastion – Heavy Lift

### Verbindliche Entscheidung

```text
Einheit: HMH-361 (-) Reinforced
Muster: CH-53E
Lokaler ORBAT-Bestand: 17
```

CH-53D-Alternativen werden nicht parallel addiert.

Vor aktiver Umsetzung noch zu bestätigen:

- konkreter DCS-Typname,
- Parking- und Spawnverhalten,
- MOOSE-AIRWING-/SQUADRON-Nutzung,
- Spieler- oder reine KI-Verfügbarkeit,
- Static- und Liveryverfügbarkeit.

## 10. Offene basisübergreifende technische Entscheidungen

Jalalabad ist als Grundknoten abgeschlossen. Für andere Basen bleiben basisbezogen zu klären:

- konkrete Park- und Spawnflächen,
- Warehouse-Anker,
- DCS-Typnamen und Liveries,
- Spieler- und KI-Templategrößen,
- Static-Obergrenzen,
- Risikomodul-Fallbacks,
- physische UH-1Y-Darstellung,
- CH-53E-Verhalten,
- optionale Community-Mod-Abhängigkeiten.

Projektweit noch umzusetzen:

- taktische AUFTRAG-Erzeugung,
- OPSTRANSPORT,
- persistente Bestands- und Verlustrechnung,
- persistente Ramp-/Static-Neuverteilung,
- vollständige MEDEVAC-Koordination.

Der Jalalabad-Grundaufbau dient hierfür als validierte technische Referenz, seine Bestände und lokalen Limits werden jedoch nicht ungeprüft auf andere Basen übertragen.
