# 19 – Verbindliche Entscheidungen zur aktiven Luft-ORBAT

## Zweck

Dieses Dokument hält die verbindlichen Auswahlentscheidungen für Einheiten fest, bei denen sich im historischen Kampagnenzeitraum Ablösungen, Überschneidungen oder alternative plausible Darstellungen ergeben.

Die vollständige historische und planerische Grundlage bleibt in [`us-air-orbat-2010-2011.md`](us-air-orbat-2010-2011.md) erhalten. Nicht ausgewählte Einheiten bleiben dort als historischer Kontext dokumentiert, werden aber nicht für Spieler-Slots, KI-Squadrons, Payload-Templates oder Statics der aktiven Mission umgesetzt.

Jeder Entscheidungsfall wird einzeln behandelt. Die Auswahl wird erst nach ausdrücklicher Entscheidung des Missionsdesigners verbindlich.

---

## Entscheidungsstatus

| Nr. | Flugplatz | Muster / Bereich | Gewählte Einheit | Status |
|---:|---|---|---|---|
| 1 | Bagram | F-15E | 336th Expeditionary Fighter Squadron | entschieden |
| 2 | Jalalabad | Army Aviation | Task Force Six Shooters / 6-6 Cavalry mit B/1-10 Aviation und Utility-/MEDEVAC-Element | entschieden |
| 3 | Kandahar | A-10C | 75th Expeditionary Fighter Squadron | entschieden |
| 4 | Camp Bastion | AH-1W / UH-1Y | offen | ausstehend |
| 5 | Camp Bastion | MV-22B | offen | ausstehend |
| 6 | Camp Bastion | CH-53D / CH-53E | offen | ausstehend |

---

## 1. Bagram – F-15E

### Historische Alternativen

Für den Kampagnenzeitraum standen als missionsgestalterische Auswahl zur Verfügung:

- 494th Expeditionary Fighter Squadron für die frühe Übergangsphase im August 2010,
- 336th Expeditionary Fighter Squadron für den größeren späteren Teil des Kampagnenzeitraums.

Die genaue Übergabe ist nicht taggenau als belastbare Grundlage für einen dynamischen Staffelwechsel gesichert.

### Verbindliche Entscheidung

Für die aktive Missions-ORBAT wird ausschließlich verwendet:

```text
Einheit: 336th Expeditionary Fighter Squadron
Flugplatz: Bagram Airfield
Muster: F-15E
Lokaler ORBAT-Bestand: 16 Luftfahrzeuge
```

### Betriebsgrenzen

- höchstens vier gleichzeitig aktive Spieler-Luftfahrzeuge,
- höchstens vier gleichzeitig aktive KI-Luftfahrzeuge als lokale technische Obergrenze,
- normale KI-Unterstützungsmissionen weiterhin durch die globale Grenze von zwei parallelen Two-Ship-Aufträgen beschränkt,
- gepoolte Static-Darstellung aus dem inaktiven lokalen Bestand,
- endgültige Verluste ohne automatischen Ersatz,
- F-15E bleibt wegen der unsicheren langfristigen Modulpflege als `THIRD_PARTY_AT_RISK` eingestuft.

### Ausgeschlossene aktive Umsetzung

Die 494th Expeditionary Fighter Squadron wird nicht als aktive Einheit aufgebaut. Für sie werden daher zunächst nicht angelegt:

- keine Spieler-Slots,
- keine KI-SQUADRON,
- keine eigenen Payload-Templates,
- keine eigenen Static-Gruppen oder Liveries,
- kein automatischer Staffelwechsel.

Die 494th EFS bleibt ausschließlich als historische Vorgängereinheit in der Forschungs- und ORBAT-Dokumentation erhalten.

### Noch für die Missionseditor-Arbeitsliste festzulegen

- konkrete Zahl sichtbarer F-15E-Statics innerhalb des empfohlenen Bereichs,
- verwendete Liveries,
- Spieler- und KI-Parkpositionen,
- Template-Gruppengrößen und Payloads,
- Verhalten bei fehlender oder später nicht mehr nutzbarer F-15E-Modulinstallation.

---

## 2. Jalalabad Airfield / FOB Fenty – Army Aviation

### Historische Alternativen

Für die aktive Missionsdarstellung standen zwei aufeinanderfolgende Zustände zur Auswahl:

- Task Force Lighthorse für den früheren Zeitraum bis ungefähr November 2010,
- Task Force Six Shooters / 6th Squadron, 6th Cavalry Regiment für den späteren Zeitraum ab ungefähr November 2010.

Beide Zustände werden nicht gleichzeitig umgesetzt. Ein automatischer Verbandswechsel während der laufenden Kampagne ist zunächst nicht vorgesehen.

### Verbindliche Entscheidung

Für die aktive Missions-ORBAT wird ausschließlich der spätere Zustand mit Task Force Six Shooters verwendet:

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

### Betriebsgrenzen

Für jeden der drei Luftfahrzeugtypen gelten:

- höchstens vier gleichzeitig aktive Spieler-Luftfahrzeuge, sofern ein spielbares Modul oder der eingeplante UH-60L Community Mod verfügbar ist,
- höchstens vier gleichzeitig aktive KI-Luftfahrzeuge als lokale technische Obergrenze,
- normale KI-Unterstützungsmissionen weiterhin durch die globale Grenze von zwei parallelen Aufträgen mit jeweils höchstens zwei Luftfahrzeugen beschränkt,
- gepoolte Static-Darstellung aus dem inaktiven lokalen Bestand,
- endgültige Verluste ohne automatischen Ersatz.

MEDEVAC wird ausschließlich als Two-Ship-Paket eingesetzt:

```text
1 UH-60 MEDEVAC Lead: Landung und Aufnahme
1 UH-60 Cover: Sicherung und Feuerunterstützung aus der Luft
```

Ein einzelner UH-60 darf daher nicht als regulärer MEDEVAC-Auftrag eingesetzt werden.

### Geplante technische SQUADRON-Struktur

```text
AW_US_JALALABAD
├── SQ_6_6_CAV_OH58D
├── SQ_B_1_10_AVN_AH64D
└── SQ_JBAD_UTILITY_UH60
```

Die konkrete Anzahl der MOOSE-Gruppen wird später aus KI-Bestand und Template-Gruppengröße berechnet. Bei Two-Ship-Templates entsprechen vier aktive KI-Luftfahrzeuge zwei MOOSE-Gruppen.

### Ausgeschlossene aktive Umsetzung

Task Force Lighthorse wird nicht als aktive Einheit aufgebaut. Für den früheren Verbandszustand werden daher zunächst nicht angelegt:

- keine Spieler-Slots,
- keine KI-SQUADRONs,
- keine eigenen Payload-Templates,
- keine eigenen Static-Gruppen oder Liveries,
- kein automatischer Wechsel zu Task Force Six Shooters.

Task Force Lighthorse bleibt ausschließlich als historischer Vorgänger in der Forschungs- und ORBAT-Dokumentation erhalten.

### Noch für die Missionseditor-Arbeitsliste festzulegen

- konkrete Zahl sichtbarer OH-58D-, AH-64D- und UH-60-Statics,
- verfügbare und historisch passende Liveries,
- vier Spieler-Luftfahrzeuge je nutzbarem Muster und deren Parkpositionen,
- KI-Template-Parkpositionen und Startverfahren,
- Payload-Templates für Aufklärung, Armed Reconnaissance, CAS, Eskorte, Utility und MEDEVAC,
- getrennte Ein-Schiff-Templates für UH-60 MEDEVAC Lead und Cover,
- Warehouse-Anker und eindeutige Zuordnung zu Jalalabad Airfield,
- Kompatibilität des UH-60L Community Mods mit Multiplayer, Multicrew, Fracht und MOOSE-Ereigniserkennung.

---

## 3. Kandahar Airfield – A-10C

### Historische Alternativen

Für die aktive Missionsdarstellung standen zwei aufeinanderfolgende Expeditionary Fighter Squadrons zur Auswahl:

- 81st Expeditionary Fighter Squadron für den frühen Kampagnenzustand bis ungefähr Spätsommer 2010,
- 75th Expeditionary Fighter Squadron für den späteren Zustand ab ungefähr September 2010 bis 2011.

Beide Staffeln werden nicht gleichzeitig umgesetzt. Ein automatischer Staffelwechsel während der laufenden Kampagne ist zunächst nicht vorgesehen.

### Verbindliche Entscheidung

Für die aktive Missions-ORBAT wird ausschließlich die 75th Expeditionary Fighter Squadron verwendet:

```text
Einheit: 75th Expeditionary Fighter Squadron
Flugplatz: Kandahar Airfield
Muster: A-10C
Lokaler ORBAT-Bestand: 16 Luftfahrzeuge
```

### Betriebsgrenzen

- höchstens vier gleichzeitig aktive Spieler-Luftfahrzeuge,
- höchstens vier gleichzeitig aktive KI-Luftfahrzeuge als lokale technische Obergrenze,
- normale KI-Unterstützungsmissionen weiterhin durch die globale Grenze von zwei parallelen Aufträgen mit jeweils höchstens zwei Luftfahrzeugen beschränkt,
- reguläre A-10C-Unterstützung grundsätzlich als Einzel- oder Two-Ship-Auftrag, nicht als dauerhaft aktive Großformation,
- gepoolte Static-Darstellung aus dem inaktiven lokalen Bestand,
- endgültige Verluste ohne automatischen Ersatz.

### Geplante technische SQUADRON-Struktur

```text
AW_US_KANDAHAR
└── SQ_75_EFS_A10C
```

Die KI-Templates werden für maximal Two-Ship-Einsätze ausgelegt. Vier aktive KI-A-10C entsprechen daher höchstens zwei gleichzeitig verfügbaren Two-Ship-Gruppen; die globale operative KI-Grenze kann den tatsächlichen Einsatz weiter reduzieren.

### Ausgeschlossene aktive Umsetzung

Die 81st Expeditionary Fighter Squadron wird nicht als aktive Einheit aufgebaut. Für sie werden daher zunächst nicht angelegt:

- keine Spieler-Slots,
- keine KI-SQUADRON,
- keine eigenen Payload-Templates,
- keine eigenen Static-Gruppen oder Liveries,
- kein automatischer Wechsel zur 75th EFS.

Die 81st EFS bleibt ausschließlich als historische Vorgängereinheit in der Forschungs- und ORBAT-Dokumentation erhalten.

### Noch für die Missionseditor-Arbeitsliste festzulegen

- konkrete Zahl sichtbarer A-10C-Statics,
- historisch passende 75th-EFS-Liveries oder verfügbare Ersatzlackierungen,
- vier Spieler-Luftfahrzeuge und deren Parkpositionen,
- KI-Template-Parkpositionen und Startverfahren,
- Payload-Templates für CAS, Armed Overwatch und gegebenenfalls FAC(A),
- Warehouse-Anker und eindeutige Zuordnung zu Kandahar Airfield.
