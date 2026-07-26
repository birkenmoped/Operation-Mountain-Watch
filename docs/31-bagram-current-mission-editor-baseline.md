# 31 – Bagram Current Mission Editor Baseline

## 1. Dokumentstatus

**Autoritativer Nachtrag zum tatsächlich gesetzten Bagram-Stand in `OMW_TEST_TM01M_MooseFirst(8).miz` und den danach bestätigten Projektentscheidungen.**

Dieses Dokument ersetzt für den aktuellen Missionseditor-Aufbau alle abweichenden Planwerte aus Dokument 28. Dokument 28 bleibt für die historische Fighter-ORBAT relevant; dieses Dokument ist für den tatsächlich gesetzten Bagram-Aufbau und die technischen Abbildungsregeln maßgeblich.

## 2. Verbindliche Client-Regel

Projektweit gilt:

```text
maximal 2 Client-Luftfahrzeuge je Muster und Flugplatz
1 Luftfahrzeug je Client-Gruppe
```

Für Bagram sind aktuell gesetzt:

```text
2 F-15E
2 F-16
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

Alle Clientgruppen bestehen aus einer Unit und verwenden `skill = Client`.

Aktuell verwendete Parkplätze:

```text
F-15E: M25, M26
F-16: M15, M16
C-130J-30: A09, A08
CH-47F: R21, R22
OH-58D: P01, P02
```

## 3. KI-Templates

Aktuell vorhanden:

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
KI-Skill der Fighter: High für beide Units
```

Für F-16 existiert bewusst nur das CAS-Two-Ship-Template. Ein separates `ARMED_RECON`-Template ist nicht vorgesehen.

## 4. Aktueller Static-Bestand

```text
6 F-15E
7 F-16
4 UH-60
2 UH-60A als HH-60G-/CSAR-Repräsentation
2 CH-47D
2 C-130
1 KC-130
1 C-17A
1 KC-135 MPRS
```

Gesamt:

```text
26 Luftfahrzeug-Statics
```

Die Statics dürfen bewusst DCS-Parkpositionen belegen. Sie dienen der sichtbaren Basisdarstellung und sind nicht als zusätzlicher verfügbarer AIRWING-Bestand zu zählen.

## 5. Spieler-, KI- und Static-Typen

Die unterschiedlichen DCS-Typen sind beabsichtigt:

```text
Spieler-/Client-Slots:
ausschließlich fliegbare DCS-Modulvarianten

KI-Templates:
bevorzugt native, weniger aufwendige DCS-AI-Modelle

Statics:
bevorzugt native DCS-Static-/AI-Modelle

Community-Mods:
optional, niemals Voraussetzung der Basismission
```

Konkrete Beispiele:

```text
F-15E:
Client = F-15ESE
KI/Static = F-15E

CH-47:
Client = CH-47Fbl1
KI/Static = CH-47D

HH-60G-/CSAR-Rolle:
KI/Static = UH-60A
```

DCS besitzt keinen nativen HH-60G als Modul, KI oder Static. Die Verwendung des UH-60A für CSAR ist eine bewusste und bereits in Jalalabad verwendete Ersatzdarstellung. Gruppen- und Static-Namen dürfen die historische Rolle `HH60G` ausdrücken.

## 6. Warehouse

```text
WH_AIR_US_BAGRAM
DCS-Objekttyp: container_20ft
```

## 7. Statics und Parking

Die aktuelle geometrische Prüfung ergab keine unmittelbare Überschneidung der gesetzten Bagram-Statics mit den zehn verwendeten Client-Parkpositionen.

Die `.miz` liefert:

- Static-Namen,
- Typen,
- Koordinaten,
- Client- und Templatepositionen.

Sie liefert am Static selbst jedoch keine direkt nutzbare TerminalID-Zuordnung. Der Projektinhaber muss TerminalIDs nicht manuell im Missionseditor ermitteln.

Die spätere Laufzeitdiagnose muss:

1. alle Bagram-Parking-Spots über DCS/MOOSE auslesen,
2. TerminalIDs und Koordinaten protokollieren,
3. Statics dem jeweils nächsten Parking-Spot zuordnen,
4. bewusst blockierte Spots als Blacklist-Kandidaten klassifizieren,
5. Safe Parking für Clients und dynamische KI prüfen.

## 8. Keine künstlichen Zonen

Für Statics werden keine Zonen nur zum Zählen, Gruppieren oder zur vereinfachten Auswertung angelegt.

Nicht anzulegen sind insbesondere frühere Planungskandidaten wie:

```text
ZONE_AIR_US_BGRM_STATIC_F15E
ZONE_AIR_US_BGRM_STATIC_F16C
ZONE_AIR_US_BGRM_F15E_AI_RESERVE
ZONE_AIR_US_BGRM_F16C_AI_RESERVE
ZONE_AIR_US_BGRM_FIGHTER_LOAD
ZONE_AIR_US_BGRM_FIGHTER_RECOVERY
```

Zonen werden ausschließlich angelegt, wenn eine konkrete Runtime-Funktion von MOOSE, AUFTRAG, OPSTRANSPORT, CSAR oder Logistik sie benötigt.

## 9. Satellitenauswertung der Hubschrauberbereiche

Für Dezember 2011 wurden auf den vorliegenden Aufnahmen konservativ unterschieden:

```text
bestätigt
wahrscheinlich
ungeklärt
```

Beobachtungen:

```text
mehrere UH-60-/Black-Hawk-Familienmaschinen
mindestens 4 klar erkennbare AH-64
bis zu 2 weitere mögliche AH-64
mindestens 2 wahrscheinlich erkennbare OH-58
möglicherweise 1 weiterer OH-58
```

Ein datierter Bildnachweis bestätigt einen US-Army-AH-64 auf der Flightline von Bagram am 31.12.2011. Die genaue AH-64-Untervariante ist aus dem Beleg nicht sicher abzuleiten.

Die Satellitenbilder dürfen nicht zur erzwungenen Identifikation jeder unklaren Silhouette führen.

## 10. Frequenzen

Die aktuell gesetzten Frequenzen sind noch keine finale Funknetzplanung.

Verbindliche Reihenfolge:

```text
1. alle möglichen Spieler-/Client-Muster je Basis bestimmen und setzen
2. danach missionsweite Frequenz- und Callsignplanung
3. anschließend AWACS, Tanker, JTAC, TACAN, ICLS und Package-Netze konsistent zuweisen
```

Die Frequenzplanung bleibt daher offen und ist derzeit kein Blocker für den weiteren ORBAT-Aufbau.

## 11. Autoritative Korrekturen gegenüber Dokument 28

Für den tatsächlichen Missionseditor-Aufbau gelten abweichend von älteren Planwerten:

```text
2 statt 4 Clients je Muster
kein F-16 ARMED_RECON-Template
keine künstlichen Static-, Reserve-, Load- oder Recovery-Zonen
6 statt 9 F-15E-Statics
7 F-16-Statics
Transport-, Rotary-Wing- und Tanker/Transport-Statics bereits ergänzt
Warehouse-Anker bereits gesetzt
```

Dokument 29 bleibt für die projektweite Client-Obergrenze autoritativ. Dieses Dokument 31 ist für den aktuellen Bagram-Missionseditorstand autoritativ.
