# 03 – Systemarchitektur

## Technologiestack

- DCS Mission Editor für Karte, Slots, Zonen, Vorlagen und statische Infrastruktur
- MOOSE als primäres Framework
- MOOSE CTLD für Spielerlogistik und Fracht
- MOOSE CSAR für Rettungsfälle
- eigene Lua-Module für Kampagnenzustand, Persistenz, Virtualisierung und gegnerische Entscheidungslogik

MIST wird nicht zusätzlich geladen, solange keine konkrete technische Abhängigkeit dokumentiert ist.

## Komponenten

### CampaignState

Autoritative Quelle für Basen, FOBs, Ressourcen, rote Zellen, strategische Entitäten, aktive Aufträge, CSAR-Fälle und Intelligence-Fortschritt.

### EntityManager

Verwaltet stabile strategische IDs, Zusammensetzung, Verluste, Aufträge und die Zuordnung zu temporären DCS-Gruppen.

### VirtualizationManager

Bewegt entfernte Verbände mathematisch, entscheidet über Materialisierung und Dematerialisierung und erhält Zusammensetzung sowie Zustand.

### LogisticsManager

Verarbeitet CTLD-Lieferungen, Konvois, Lufttransport, C-130J-Abwürfe und die Gutschrift von Ressourcen.

### RedDirector

Wählt Ziele, reserviert Kräfte, plant Angriffe, steuert Rückzug und Wiederaufbau und reagiert auf abstrakte HUMINT-Meldungen.

### CSARCampaignManager

Verknüpft MOOSE-CSAR mit roten Capture-Teams, Gefangenschaft, Evasion, Persistenz und Folgeoperationen.

### MissionGenerator

Erzeugt spielbare Aufträge aus dem aktuellen Kampagnenzustand.

### PersistenceManager

Speichert ausschließlich strategischen Zustand. MOOSE- oder DCS-Objekte werden beim Laden aus diesem Zustand rekonstruiert.

## Abhängigkeitsregel

Domänenlogik darf nicht direkt von einem konkreten DCS-Gruppennamen abhängen. DCS- und MOOSE-Aufrufe werden möglichst in Adapter- oder Systemmodulen gekapselt.

## Geplanter Startumfang

Ein vertikaler Prototyp umfasst eine Hauptbasis, einen FOB, eine getestete Straßenroute, einen blauen Konvoi, eine rote Zelle, einen C-130J-Abwurf und einen CSAR-Fall.
