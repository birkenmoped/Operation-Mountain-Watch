# ADR 0013 – Rote Kräfte als kostenbewertetes Netzwerk mit begrenzter und verzögerter Führung modellieren

- Status: Accepted
- Date: 2026-07-18

## Context

Der frühe TM02-Entwurf verwendete einen festen Baum mit einem zentralen HQ und top-down aufgefüllten Stationen. Dieses Modell ist für technische Packet-, Proxy- und Bilanztests geeignet, bildet den späteren Kampagnenbetrieb aber nur unzureichend ab.

Ein dauerhaft festgeschriebener Mindestbestand je Station würde Personal praktisch an den Knoten binden. Angriffe, Patrouillen, Rückzüge, lokale Verstärkung und bewusste Schwerpunktbildung wären nur über Sonderlogik möglich.

Gleichzeitig darf der rote Kommandeur nicht allwissend oder unmittelbar reaktiv sein. Historisch standen lokalen Taliban-Netzen wirksame HUMINT- und Frühwarnmöglichkeiten zur Verfügung, während zentrale Auswertung, Kommunikation und technische Aufklärung begrenzt waren.

## Decision

### Netzwerk

Das Produktionsmodell verwendet einen gewichteten Graphen aus Knoten und geprüften Verbindungen.

- Ein Baum bleibt als einfacher Spezialfall zulässig.
- Ein Knoten kann mehrere Nachbarn und mehrere mögliche Personalquellen besitzen.
- HQs, Unter-HQs und geeignete Stationen dürfen Personal bereitstellen.
- Quelle und Route werden nach Kosten und Auftragspriorität gewählt.

### Bewegliche Personalbestände

Personal gehört nicht dauerhaft einem Knoten. Ein Knoten hält einen aktuellen Bestand und kann ihn für Aufträge freigeben.

Standardparameter für den ersten Netztest:

| Klasse | Grundwache | Bereitschaftsziel | Harte Kapazität |
|---|---:|---:|---:|
| `STATION` | 2 | 6 | 12 |
| `REGIONAL_HUB` / `SUB_HQ` | 4 | 12 | 24 |

Ein Auftrag darf einen Quellknoten bewusst unter sein Bereitschaftsziel bringen. Eine Unterschreitung der normalen Grundwache erfordert eine ausdrücklich akzeptierte temporäre Untergrenze.

### Mobile Kräfte

- Lauf- und Verstärkungsteams sind ein bis sechs Mann stark.
- Sechs Mann sind eine Obergrenze, keine Pflichtgröße für jede Bewegung.
- Ein Standardangriff besteht aus zwei unabhängigen Sechserteams.
- Beide Angriffsteams behalten getrennte Identität, Position, Verluste und Repräsentation.

### Kostenmodell

Mindestens einzubeziehen sind:

- erwartete Reisezeit;
- Entfernung;
- Routenrisiko;
- Schwächung der Quelle;
- Zeit bis zur Wiederauffüllung der Quelle;
- Alter und Zuverlässigkeit der Feindmeldung;
- bereits gebundene Kräfte und Verbindungen.

Der erste Planer ist ein ereignisgesteuerter Greedy-Dispatcher. Ein globaler Optimierer ist nicht erforderlich.

### Begrenztes Wissen

Der Simulationscontroller kennt den tatsächlichen Zustand. Der rote Kommandeur plant ausschließlich mit zugestellten Meldungen.

Meldungen besitzen mindestens:

- Ereigniszeit;
- Zustellzeit;
- Quelle;
- räumliche Genauigkeit;
- Größenband;
- Zuverlässigkeit;
- Ablaufzeit.

Feindmeldungen werden als `CONFIRMED`, `REPORTED`, `RUMORED` oder `STALE` klassifiziert.

### Begrenzte Entscheidungen

Strategische Planung läuft periodisch und mit begrenztem Budget. Bewegungsüberwachung bleibt davon getrennt.

Erste Testwerte:

```lua
commander = {
  localCycleSeconds = 45,
  subHqCycleSeconds = 120,
  mainHqCycleSeconds = 240,

  localOrdersPerCycle = 1,
  subHqOrdersPerCycle = 2,
  mainHqOrdersPerCycle = 2,
}
```

Technische Suchgrenzen:

```lua
limits = {
  maxTasksEvaluatedPerCycle = 8,
  maxSourcesPerTask = 4,
  maxRouteSearchesPerCycle = 12,
}
```

Auftragsbindung, Quellknoten-Cooldown und Mindeständerungen vor Neuplanung verhindern Pendelbewegungen.

## Consequences

### Positive

- Erstbesetzung, Nachersatz, lokale Umverteilung und operative Kräftebereitstellung verwenden dasselbe Personalmodell.
- Rückwärtige Knoten können Personal abgeben und später aus besser versorgten Knoten aufgefüllt werden.
- Der rote Kommandeur reagiert glaubwürdig verzögert statt übermenschlich sofort.
- HUMINT kann lokal stark sein, ohne eine vollständige Blue-Lage zu erzeugen.
- Entscheidungs- und Suchbudgets begrenzen CPU-Kosten.
- Der bestehende TM02-Baum bleibt als kontrollierbarer Testdatensatz verwendbar.

### Negative

- Mehrquellenwahl, Reservierungen und Kostenbewertung sind komplexer als ein fester Baum.
- Veraltete Informationen erzeugen absichtlich suboptimale Entscheidungen.
- Oszillation und unnötige Verlegungen müssen durch Bindungs- und Cooldownregeln verhindert werden.
- Testabdeckung muss Kommandozyklen, Meldeverzögerung und konkurrierende Aufträge einschließen.

## Rejected alternatives

### Produktionssystem als fester HQ-Baum

Verworfen, weil lokale Quellen, Querbewegungen und operative Abgaben nur über Sonderfälle möglich wären.

### Jeder Knoten muss dauerhaft voll besetzt bleiben

Verworfen, weil dadurch praktisch keine Kräfte für Angriffe oder Patrouillen verfügbar wären.

### Sofortige globale Neuplanung nach jedem Verlust

Verworfen, weil sie unglaubwürdig, CPU-intensiv und übermenschlich reaktiv wäre.

### Vollständiger globaler Optimierer

Vorläufig verworfen. Ein begrenzter ereignisgesteuerter Greedy-Dispatcher ist leichter zu testen und für die Kampagnenanforderungen ausreichend.

## Required validation

- mehrere zulässige Quellen für dasselbe Ziel;
- Auswahl nach Reisezeit und Quellschwächung;
- geplante Unterbesetzung eines rückwärtigen Knotens;
- spätere Wiederauffüllung aus HQ oder Unter-HQ;
- keine Doppelreservierung von Personal oder Zielkapazität;
- begrenzte Auftragszahl pro Zyklus;
- keine Entscheidung vor Zustellung der relevanten Meldung;
- veraltetes Kommandowissen darf vom tatsächlichen Zustand abweichen;
- Standardangriff aus zwei unabhängigen Sechserteams;
- exakte Gesamtpersonalbilanz trotz Verlusten, Abbruch und Neuplanung.