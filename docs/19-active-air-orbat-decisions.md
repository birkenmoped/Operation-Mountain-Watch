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
| 2 | Jalalabad | Army Aviation | offen | ausstehend |
| 3 | Kandahar | A-10C | offen | ausstehend |
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
