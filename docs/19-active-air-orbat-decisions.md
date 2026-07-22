# 19 – Verbindliche Entscheidungen zur aktiven Luft-ORBAT

## Zweck

Dieses Dokument hält die verbindlichen Auswahlentscheidungen für Einheiten fest, bei denen sich im historischen Kampagnenzeitraum Ablösungen, Überschneidungen oder alternative plausible Darstellungen ergeben.

Die vollständige historische und planerische Grundlage bleibt in [`us-air-orbat-2010-2011.md`](us-air-orbat-2010-2011.md) erhalten. Nicht ausgewählte Einheiten bleiben dort als historischer Kontext dokumentiert, werden aber nicht für Spieler-Slots, KI-Squadrons, Payload-Templates, Statics oder Bestände der aktiven Mission umgesetzt.

Die gemeinsamen Betriebsregeln stehen in [`18-air-operations-implementation.md`](18-air-operations-implementation.md). Dazu gehören insbesondere gepoolte Statics, endgültige Verluste, maximal vier Spieler- und vier KI-Luftfahrzeuge je Typ und Basis als lokale Obergrenze sowie maximal zwei parallele KI-Unterstützungsmissionen mit jeweils höchstens zwei Luftfahrzeugen.

---

## Entscheidungsstatus

| Nr. | Flugplatz | Muster / Bereich | Verbindliche Entscheidung | Status |
|---:|---|---|---|---|
| 1 | Bagram | F-15E | 336th Expeditionary Fighter Squadron, 16 F-15E | entschieden |
| 2 | Jalalabad | Army Aviation | Task Force Six Shooters / 6-6 Cavalry mit B/1-10 Aviation und Utility-/MEDEVAC-Element | entschieden |
| 3 | Kandahar | A-10C | 75th Expeditionary Fighter Squadron, 16 A-10C | entschieden |
| 4 | Camp Bastion | AH-1W / UH-1Y | HMLA-169 „Vipers“, 10 AH-1W und 5 UH-1Y | entschieden |
| 5 | Camp Bastion | MV-22B | keine aktive Umsetzung | entschieden: entfällt vollständig |
| 6 | Camp Bastion | CH-53D / CH-53E | HMH-361 (-) Reinforced, 17 CH-53E | entschieden |

Damit sind die bisher identifizierten Ablösungs- und Überschneidungsfälle abgeschlossen. Ein automatisches fortlaufendes Kampagnendatum mit dynamischen Staffelwechseln wird zunächst nicht umgesetzt.

---

## 1. Bagram – F-15E

### Verbindliche Entscheidung

```text
Einheit: 336th Expeditionary Fighter Squadron
Flugplatz: Bagram Airfield
Muster: F-15E
Lokaler ORBAT-Bestand: 16 Luftfahrzeuge
```

### Nicht aktiv umgesetzt

Die 494th Expeditionary Fighter Squadron bleibt ausschließlich als historische Vorgängereinheit dokumentiert. Für sie werden nicht angelegt:

- keine Spieler-Slots,
- keine KI-SQUADRON,
- keine eigenen Payload-Templates,
- keine eigenen Static-Gruppen oder Liveries,
- kein automatischer Staffelwechsel.

Die F-15E bleibt wegen der unsicheren langfristigen Modulpflege als `THIRD_PARTY_AT_RISK` eingestuft. Ihre Spieler- und Missionseditorobjekte müssen deaktivierbar bleiben, ohne die strategische Struktur der Kampagne umzubauen.

---

## 2. Jalalabad Airfield / FOB Fenty – Army Aviation

### Verbindliche Entscheidung

```text
Flugplatz: Jalalabad Airfield / FOB Fenty

Einheit: 6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters
Muster: OH-58D
Lokaler ORBAT-Bestand: 24 Luftfahrzeuge

Einheit: B Company, 1-10 Aviation
Muster: AH-64D
Lokaler ORBAT-Bestand: 8 Luftfahrzeuge

Einheit: angegliedertes Utility-/MEDEVAC-Element
Muster: UH-60-Familie
Lokaler ORBAT-Bestand: 6 Luftfahrzeuge
```

### MEDEVAC-Regel

MEDEVAC wird ausschließlich als Two-Ship-Paket eingesetzt:

```text
1 UH-60 MEDEVAC Lead: Landung und Aufnahme
1 UH-60 Cover: Sicherung und Feuerunterstützung aus der Luft
```

Ein einzelner UH-60 darf nicht als regulärer MEDEVAC-Auftrag eingesetzt werden.

### Geplante technische Struktur

```text
AW_US_JALALABAD
├── SQ_6_6_CAV_OH58D
├── SQ_B_1_10_AVN_AH64D
└── SQ_JBAD_UTILITY_UH60
```

### Nicht aktiv umgesetzt

Task Force Lighthorse bleibt ausschließlich als historische Vorgängereinheit dokumentiert. Es werden keine Lighthorse-Spieler-Slots, KI-SQUADRONs, Payload-Templates, Statics, Liveries oder automatischen Verbandswechsel vorbereitet.

---

## 3. Kandahar Airfield – A-10C

### Verbindliche Entscheidung

```text
Einheit: 75th Expeditionary Fighter Squadron
Flugplatz: Kandahar Airfield
Muster: A-10C
Lokaler ORBAT-Bestand: 16 Luftfahrzeuge
```

### Geplante technische Struktur

```text
AW_US_KANDAHAR
└── SQ_75_EFS_A10C
```

### Nicht aktiv umgesetzt

Die 81st Expeditionary Fighter Squadron bleibt ausschließlich als historische Vorgängereinheit dokumentiert. Für sie werden keine Spieler-Slots, KI-SQUADRON, Payload-Templates, Statics, Liveries oder automatischen Staffelwechsel angelegt.

---

## 4. Camp Bastion – HMLA Light Attack / Utility

### Verbindliche Entscheidung

```text
Einheit: HMLA-169 „Vipers“
Flugplatz: Camp Bastion

Muster: AH-1W
Lokaler ORBAT-Bestand: 10 Luftfahrzeuge

Muster: UH-1Y
Lokaler ORBAT-Bestand: 5 Luftfahrzeuge
```

Die fünf UH-1Y bleiben Bestandteil der historischen und strategischen ORBAT. Ihre physische Umsetzung in DCS bleibt deaktiviert, bis ein geeignetes natives oder ausdrücklich zugelassenes Asset bestätigt ist. Eine UH-1H wird nicht automatisch als historisch falscher Ersatz verwendet.

### Geplante technische Struktur

```text
AW_USMC_BASTION
├── SQ_HMLA_169_AH1W
└── SQ_HMLA_169_UH1Y   # erst nach bestätigter Asset-Entscheidung aktivieren
```

### Nicht aktiv umgesetzt

HMLA-369 „Gunfighters“ bleibt ausschließlich als historische Vorgängereinheit dokumentiert. Für diesen früheren Verbandszustand werden keine KI-SQUADRONs, Payload-Templates, Statics, Liveries oder automatischen Staffelwechsel angelegt.

---

## 5. Camp Bastion – MV-22B

### Verbindliche Entscheidung

Da kein verwendbares MV-22B-Asset für die vorgesehene Mission zur Verfügung steht, werden VMM-365 „Blue Knights“ und VMM-264 „Black Knights“ vollständig aus der aktiven Missions-ORBAT gestrichen.

```text
VMM-365 „Blue Knights“: keine aktive Umsetzung
VMM-264 „Black Knights“: keine aktive Umsetzung
MV-22B-Bestand in der aktiven Mission: 0
```

Es wird nicht vorgesehen:

- kein strategischer oder abstrakter MV-22B-Bestand im CampaignState,
- keine Spieler-Slots,
- keine KI-SQUADRON,
- keine Late-Activation-Templates,
- keine Payload-Templates,
- keine Statics oder Ersatzdarstellungen,
- keine RAT-Flüge,
- keine verpflichtende oder optionale MV-22B-Community-Mod-Abhängigkeit.

Eine spätere Wiedereinführung wäre eine neue ausdrückliche Architektur- und ORBAT-Entscheidung.

---

## 6. Camp Bastion – Heavy Lift

### Historische Alternativen

Für den Kampagnenzeitraum waren mehrere CH-53-Verbände relevant:

- HMH-363 „Red Lions“ mit CH-53D für den frühen Zeitraum,
- HMH-362 „Ugly Angels“ als späterer CH-53D-Verband,
- HMH-361 (-) Reinforced mit CH-53E ab Kampagnenbeginn.

Die CH-53D- und CH-53E-Bestände werden nicht addiert. Eine parallele Darstellung aller Verbände würde einen überhöhten Bestand erzeugen und für die CH-53D eine nicht bestätigte Ersatzlösung erfordern.

### Verbindliche Entscheidung

Für die aktive Missions-ORBAT wird ausschließlich verwendet:

```text
Einheit: HMH-361 (-) Reinforced
Flugplatz: Camp Bastion
Muster: CH-53E
Lokaler ORBAT-Bestand: 17 Luftfahrzeuge
```

### Betriebs- und Darstellungsregeln

- CH-53E wird als KI-Luftfahrzeug eingeplant, sofern der konkrete DCS-Typname, das Parkverhalten und die MOOSE-AIRWING-Nutzung in der verwendeten DCS-Version bestätigt sind.
- Es werden keine CH-53E-Spieler-Slots vorgesehen.
- Höchstens vier CH-53E dürfen gleichzeitig als lokale technische Obergrenze aktiv sein.
- Normale Transport- oder Unterstützungsaufträge werden als Einzel- oder Two-Ship-Flüge geplant.
- Die globale Grenze von zwei parallelen KI-Unterstützungsmissionen bleibt wirksam.
- Die statische Darstellung erfolgt aus dem gepoolten inaktiven Bestand.
- Verluste sind endgültig und werden nicht automatisch ersetzt.

### Geplante technische Struktur

```text
AW_USMC_BASTION
└── SQ_HMH_361_CH53E
```

### Nicht aktiv umgesetzt

HMH-363 und HMH-362 sowie sämtliche CH-53D-Bestände werden nicht aktiv umgesetzt. Für sie werden nicht angelegt:

- keine KI-SQUADRONs,
- keine Late-Activation-Templates,
- keine Payload-Templates,
- keine Statics oder Ersatzdarstellungen,
- kein automatischer Verbandswechsel,
- keine CH-53E- oder andere Ersatzdarstellung für CH-53D.

Die CH-53D-Verbände bleiben nur als historischer Kontext in der Forschungs- und ORBAT-Dokumentation erhalten.

---

## Verbleibende offene Punkte

Die Ablösungsentscheidungen sind abgeschlossen. Noch offen sind keine Staffelwechsel, sondern technische und missionsgestalterische Detailentscheidungen:

- genaue Zahl und Platzierung gepoolter Statics je Muster,
- historisch passende oder verfügbare Liveries,
- konkrete Spieler- und KI-Parkpositionen,
- Payload- und Rollen-Templates,
- technische Verwendbarkeit karteneigener Warehouse-Gebäude,
- DCS-Typnamen und MOOSE-Verhalten der KI-Muster,
- physische Darstellung der UH-1Y,
- versionsbezogene Prüfung des UH-60L Community Mods,
- Fallback-Verhalten für F-15E und andere Risikomodule.

Diese Punkte werden in der Missionseditor-Arbeitsliste getrennt nach Aufgaben des Missionsdesigners und vorzubereitenden Entwicklungsinformationen geführt.