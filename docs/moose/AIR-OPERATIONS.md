---
document_id: OMW-MOOSE-AIR-OPERATIONS
status: BINDING
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - project MOOSE air-operations architecture
  - AIRBASE, AIRWING, SQUADRON, COMMANDER and AUFTRAG responsibility boundaries
not_authoritative_for:
  - active air ORBAT
  - branch-independent runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE air-operations reference
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: partial
---

# MOOSE-Luftoperationen in Operation Mountain Watch

## 1. Architektur

```text
COMMANDER
└── AIRWING
    ├── SQUADRON
    ├── SQUADRON
    └── SQUADRON

AUFTRAG und OPSTRANSPORT werden an geeignete operative Empfänger übergeben.
```

Der vollständige frühere Methoden- und Klassenstand bleibt unverändert erhalten:

- [`Legacy-MOOSE-Air-Operations`](../evidence/source-records/legacy-moose-air-operations.md)

Aktive ORBAT und Clientgrenzen stehen ausschließlich in Dokument 19. Technische Bestands- und Darstellungsregeln stehen in Dokument 18.

## 2. Verantwortungen

### AIRBASE

- DCS-Flugplatz als MOOSE-Wrapper identifizieren;
- Name und ID versionsbezogen bestätigen;
- absichtlich blockierte Parkpositionen aus dem operativen Pool ausschließen.

### AIRWING

- lokaler operativer Ressourcen- und Einsatzmanager;
- Airbase- und Warehouse-Anbindung;
- Squadrons, Payloads, Parking und Auftragsausführung.

### SQUADRON

- typ- und rollenbezogener MOOSE-Assetbestand;
- Template-Gruppengröße in Assetzahl umrechnen;
- Skills, Capabilities, Payloads und Startverfahren konfigurieren.

### COMMANDER

- vorhandene Aufträge geeigneten operativen Ressourcen zuweisen;
- keine unabhängige zweite Kampagnen- oder Zielautorität bilden.

### AUFTRAG

- operative KI-Missionen abbilden;
- auf einem CampaignState-/MissionDemand-Bedarf basieren;
- Erfolg, Fehlschlag, Abbruch und Verlust zurückmelden.

## 3. Jalalabad-Nachweis

AIRBASE-, AIRWING-, SQUADRON- und COMMANDER-Grundkonstruktion ist für den dokumentierten PR-#18-Teststand belegt. Dieser Nachweis bleibt branch-, versions- und missionsgebunden.

Noch nicht allgemein akzeptiert:

- taktische Auftragsausführung;
- Transportketten;
- persistente Verluste und Rückkehr;
- andere Basen und Parkmodelle;
- vollständige Spieler-/KI-Auftragsübergabe.

## 4. MOOSE-First

Jede zusätzliche eigene Air-Ops-Mechanik benötigt die Prüfung vorhandener MOOSE-Funktionen und die ausdrückliche Projektinhaberfreigabe nach Dokument 26.
