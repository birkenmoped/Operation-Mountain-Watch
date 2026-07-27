---
document_id: OMW-AIR-BAGRAM-ME-BASELINE
status: BINDING
authoritative_for:
  - current Bagram Mission Editor object state
  - current Bagram clients templates statics warehouse and parking
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/31-bagram-current-mission-editor-baseline.md
  - conflicting implementation values in the former Bagram planning manifest
source_branch: docs/bagram-air-operations-manifest
validated_in_dcs: false
---

# 34 – Bagram Current Mission Editor Baseline

## 1. Dokumentstatus

Dieses Dokument ist für den tatsächlich gesetzten Bagram-Stand in `OMW_TEST_TM01M_MooseFirst(8).miz` autoritativ.

Autoritätsabgrenzung:

- `OMW-AIR-BAGRAM-MANIFEST`: historische Fighter-Evidenz und aktive Fighter-ORBAT;
- `OMW-AIR-PLAYER-SLOT-POLICY`: projektweite Clientregel und ausgeschlossene Templates/Zonen;
- dieses Dokument: tatsächlich gesetzte Missionseditorobjekte und technische Abbildung.

## 2. Clientregel und aktueller Bestand

Projektweit:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Flugplatz
1 Luftfahrzeug je Client-Gruppe
```

In Bagram gesetzt:

```text
2 F-15E
2 F-16C
2 C-130J-30
2 CH-47F
2 OH-58D
```

Gruppen:

```text
CLIENT_US_BGRM_F15E_01
CLIENT_US_BGRM_F15E_02
CLIENT_US_BGRM_F16_01
CLIENT_US_BGRM_F16_02
CLIENT_US_BGRM_C130_01
CLIENT_US_BGRM_C130_02
CLIENT_US_BGRM_CH47F_01
CLIENT_US_BGRM_CH47F_02
CLIENT_US_BGRM_OH58D_01
CLIENT_US_BGRM_OH58D_02
```

Alle Gruppen bestehen aus einer Unit und verwenden `skill = Client`.

Parkpositionen:

```text
F-15E: M25, M26
F-16C: M15, M16
C-130J-30: A09, A08
CH-47F: R21, R22
OH-58D: P01, P02
```

## 3. KI-Templates

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP
```

Eigenschaften:

```text
Late Activation: ja
Uncontrolled: nein
Fighter-Skill: High
```

Für F-16C existiert bewusst nur das CAS-Two-Ship-Template. Ein separates `ARMED_RECON`-Template ist nicht vorgesehen.

## 4. Aktueller Static-Bestand

```text
6 F-15E
7 F-16C
4 UH-60
2 UH-60A als HH-60G-/CSAR-Repräsentation
2 CH-47D
2 C-130
1 KC-130
1 C-17A
1 KC-135 MPRS
----------------
26 Luftfahrzeug-Statics
```

Diese Werte ersetzen frühere Planwerte, insbesondere neun F-15E-Statics.

Statics dürfen bewusst DCS-Parkpositionen belegen. Sie sind sichtbare Repräsentationen und kein zusätzlicher verfügbarer AIRWING-Bestand.

## 5. Spieler-, KI- und Static-Typen

```text
Client-Slots:
fliegbare DCS-Modulvarianten

KI-Templates:
bevorzugt native DCS-AI-Modelle

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

F-16C:
historisch = Block 30
Client/KI = DCS Block 50 als gekennzeichneter Ersatz

CH-47:
Client = CH-47Fbl1
KI/Static = CH-47D

HH-60G-/CSAR-Rolle:
KI/Static = UH-60A
```

## 6. Warehouse

```text
WH_AIR_US_BAGRAM
DCS-Objekttyp: container_20ft
```

## 7. Parking und Statics

Die geometrische Prüfung ergab keine unmittelbare Überschneidung der 26 Statics mit den zehn verwendeten Client-Parkpositionen.

Die `.miz` liefert Namen, Typen und Koordinaten. Die Zuordnung statischer Objekte zu TerminalIDs wird durch DCS-/MOOSE-Laufzeitdiagnose ermittelt.

Die Diagnose muss:

1. alle Bagram-Parking-Spots auslesen;
2. TerminalIDs und Koordinaten protokollieren;
3. Statics dem nächsten Parking-Spot zuordnen;
4. absichtlich blockierte Spots als Blacklist-Kandidaten klassifizieren;
5. Safe Parking für Clients und dynamische KI prüfen.

## 8. Keine künstlichen Zonen

Nicht anzulegen:

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Zonen werden ausschließlich für konkrete MOOSE-, AUFTRAG-, OPSTRANSPORT-, CSAR- oder Logistikfunktionen erstellt.

## 9. Satellitenauswertung der Hubschrauberbereiche

Für Dezember 2011 werden Beobachtungen nach `bestätigt`, `wahrscheinlich` und `ungeklärt` getrennt.

Derzeitige konservative Beobachtungen:

- mehrere UH-60-/Black-Hawk-Familienmaschinen;
- mindestens vier klar erkennbare AH-64;
- bis zu zwei weitere mögliche AH-64;
- mindestens zwei wahrscheinlich erkennbare OH-58;
- möglicherweise ein weiterer OH-58.

Ein datierter Bildnachweis bestätigt einen US-Army-AH-64 auf der Flightline am 31.12.2011. Die genaue Untervariante ist daraus nicht sicher abzuleiten.

## 10. Frequenzen

Die derzeit gesetzten Frequenzen sind keine finale Funknetzplanung.

Reihenfolge:

1. alle Clientmuster je Basis bestimmen und setzen;
2. missionsweite Frequenz- und Callsignplanung;
3. AWACS, Tanker, JTAC, TACAN, ICLS und Package-Netze konsistent zuweisen.

## 11. Verbindliche Korrekturen gegenüber älteren Bagram-Planwerten

```text
2 statt 4 Clients je Muster
kein F-16C ARMED_RECON-Template
keine künstlichen Static-, Reserve-, Load- oder Recovery-Zonen
6 statt 9 F-15E-Statics
7 F-16C-Statics
Transport-, Rotary-Wing- und Tanker/Transport-Statics ergänzt
Warehouse-Anker gesetzt
```

Diese Angaben sind die aktuelle Missionseditor-Wahrheit, bis eine neuere explizite Baseline sie ersetzt.
