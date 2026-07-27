---
document_id: OMW-ARCH-SYSTEM
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - high-level system component boundaries
  - separation of campaign domain logic from DCS and MOOSE adapters
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - vertical prototype as current implementation sequence
superseded_by:
source_branch: agent/resolve-document-number-collisions
source_commit:
validated_in_dcs: false
---

# 03 – Systemarchitektur

## Autorität und Abgrenzung

Dieses Dokument beschreibt die übergeordnete Systemzerlegung. Für Detailentscheidungen gelten vorrangig:

- [`OMW-GOV-001`](00-project-governance.md) für Governance und Autorität;
- [`OMW-PHASE-VERTICAL-PROTOTYPE`](14-prototype-scope.md) für die Einordnung der ersetzten Prototypphase;
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) für MOOSE-First und das vollständige Ausnahmeverfahren;
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md) für CampaignState, MissionDemand und die Produktionsarchitektur;
- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md) für aktive Luftfahrzeugbestände und Client-Grenzen.

## Technologiestack

- DCS Mission Editor für Karte, Slots, Zonen, Vorlagen und statische Infrastruktur;
- MOOSE als primäres Framework;
- MOOSE CTLD für Spielerlogistik und Fracht;
- MOOSE CSAR für Rettungsfälle;
- projektspezifische Lua-Module nur für nachgewiesene Domänenlücken und nur nach dem vollständigen MOOSE-First-Ausnahmeverfahren.

MIST wird nicht zusätzlich geladen, solange keine konkrete technische Abhängigkeit dokumentiert und per ADR freigegeben ist.

## Komponenten

### CampaignState

Autoritative Quelle für Basen, FOBs, Ressourcen, rote Zellen, strategische Entitäten, aktive Aufträge, CSAR-Fälle und Intelligence-Fortschritt. Die vollständige Definition steht in Dokument 37.

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

## Historischer Startumfang – ersetzt

Der frühere vertikale Prototyp aus einer Hauptbasis, einem FOB, einer getesteten Straßenroute, einem blauen Konvoi, einer roten Zelle, einem C-130J-Abwurf und einem CSAR-Fall bleibt als Entwicklungsnachweis erhalten.

```yaml
status: SUPERSEDED
production_sequence: false
superseded_by:
  - OMW-GOV-001
  - OMW-PHASE-VERTICAL-PROTOTYPE
  - OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION
```

Die aktuelle Projektphase ist `COMPLETE_FOUNDATION_BUILD_PHASE`. Der vollständige Missionsgrundbau darf parallel nach fachlich getrennten Arbeitspaketen entstehen; Jalalabad–Connolly ist keine verpflichtende Eingangsschranke für andere Basen oder Systeme.