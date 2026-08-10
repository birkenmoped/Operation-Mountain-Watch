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
source_branch: agent/blue-commander-foundation
source_commit: GIT_HISTORY
validated_in_dcs: partial
---

# MOOSE-Luftoperationen in Operation Mountain Watch

## 1. Architektur

```text
CampaignState
= Strategie und Ressourcenhoheit

Mission Coordinator / Adapter
= CampaignState -> AUFTRAG

COMMANDER
= operative Auswahl geeigneter Legion/AIRWING

AIRWING
= lokaler operativer Ressourcen- und Einsatzmanager

SQUADRON
= typ- und rollenbezogener MOOSE-Assetbestand
```

Der vollständige frühere Methoden- und Klassenstand bleibt unverändert erhalten:

- [`Legacy-MOOSE-Air-Operations`](../evidence/source-records/legacy-moose-air-operations.md)

Aktive ORBAT und Clientgrenzen stehen ausschließlich in Dokument 19. Technische Bestands- und Darstellungsregeln stehen in Dokument 18.

## 2. Verantwortungen

### AIRBASE

- DCS-Flugplatz als MOOSE-Wrapper identifizieren;
- Name und ID versionsbezogen bestätigen;
- absichtlich blockierte Parkpositionen aus dem operativen Pool ausschließen.
- Die öffentliche Methode `FindFreeParkingSpotForAircraft()` besitzt konfigurierbare Scanparameter, ist aber nicht der von WAREHOUSE/AIRWING verwendete Auswahlpfad.

### AIRWING

- lokaler operativer Ressourcen- und Einsatzmanager;
- Airbase- und Warehouse-Anbindung;
- Squadrons, Payloads, Parking und Auftragsausführung.
- Die geerbte WAREHOUSE-Parkplatzsuche besitzt im gepinnten Stand keine öffentliche Konfiguration für Radius, Unit-, Static- oder Scenery-Scan.

### SQUADRON

- typ- und rollenbezogener MOOSE-Assetbestand;
- Template-Gruppengröße in Assetzahl umrechnen;
- Skills, Capabilities, Payloads und Startverfahren konfigurieren.

### COMMANDER

- vorhandene Aufträge geeigneten operativen Ressourcen zuweisen;
- keine unabhängige zweite Kampagnen-, Ziel- oder Ressourcenautorität bilden;
- in der BLUE-Foundation ausschließlich produktive, bereits laufende AIRWINGs registrieren und den COMMANDER starten.

### Mission Coordinator / Adapter

- zukünftige, klar getrennte Schicht zwischen `CampaignState` und MOOSE-AUFTRAG;
- erzeugt beziehungsweise übergibt operative Bedarfe erst nach definiertem Ressourcenhoheitsvertrag;
- ist nicht Bestandteil der BLUE-COMMANDER-Foundation.

### AUFTRAG

- operative KI-Missionen abbilden;
- auf einem CampaignState-/MissionDemand-Bedarf basieren;
- Erfolg, Fehlschlag, Abbruch und Verlust zurückmelden.

## 3. BLUE-COMMANDER-Foundation

Die zentrale produktive Datei ist:

```text
scripts/command/OMW_Blue_Commander.lua
```

Der Foundation-Scope ist absichtlich minimal:

```text
COMMANDER:New(...)
COMMANDER:AddAirwing(...)
COMMANDER:Start()
```

Registriert werden ausschließlich die produktiven AIRWING-Exports, die auf `main` aus den Bagram-, Jalalabad-, Kandahar-, Salerno-, Shindand- und Tarinkot-Foundations bereitgestellt werden. Bagram und Kandahar besitzen jeweils zwei getrennte AIRWINGs; damit beträgt der erwartete Gesamtbestand acht AIRWINGs.

Nicht Bestandteil dieses Scopes:

```text
AUFTRAG-Erzeugung
COMMANDER:AddMission()
OPSTRANSPORT
CTLD
CSAR
F10-Missionsgenerierung
Persistenz
strategisches Targeting
CampaignState-Mutation
```

Fehlende oder nicht laufende AIRWING-Exports werden mit stabiler Registry-ID protokolliert und übersprungen. Ein Start ohne mindestens einen registrierten AIRWING wird als Fehler behandelt. Der kombinierte Foundation-Acceptance-Test verlangt alle acht erwarteten AIRWINGs und null übersprungene Einträge.

## 4. MOOSE-Quellprüfung für die Foundation

Für den gepinnten MOOSE-Stand `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` wurde vor Implementierung erneut geprüft:

- `COMMANDER:New(Coalition, Alias)` setzt den Startzustand `NotReadyYet` und die Transition `Start -> OnDuty`;
- `COMMANDER:AddAirwing(Airwing)` delegiert an `AddLegion(Airwing)` und startet den COMMANDER nicht;
- `COMMANDER:onafterStart(...)` startet nur angehängte LEGIONs, die noch `NotReadyYet` sind, und plant anschließend den Statuszyklus;
- der Statuszyklus prüft vorhandene Operations-, Target-, Mission- und Transportqueues. Die BLUE-Foundation konfiguriert keine Supply-/CAP-Zonen und legt keine Missionen oder Transporte in diese Queues.

Damit wird vorhandene MOOSE-Funktionalität direkt verwendet. Eine Nicht-MOOSE-Ausnahme oder parallele Dispatch-Implementierung ist für diesen Scope nicht erforderlich.

## 5. Jalalabad-Nachweis

AIRBASE-, AIRWING-, SQUADRON- und COMMANDER-Grundkonstruktion ist für den dokumentierten PR-#18-Teststand belegt. Dieser Nachweis bleibt branch-, versions- und missionsgebunden.

Noch nicht allgemein akzeptiert:

- taktische Auftragsausführung;
- Transportketten;
- persistente Verluste und Rückkehr;
- andere Basen und Parkmodelle;
- vollständige Spieler-/KI-Auftragsübergabe.

## 6. MOOSE-First

Jede zusätzliche eigene Air-Ops-Mechanik benötigt die Prüfung vorhandener MOOSE-Funktionen und die ausdrückliche Projektinhaberfreigabe nach Dokument 26.

Für Parking-Overrides ist diese Prüfung abgeschlossen:

- [`OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH`](WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

Der Bericht belegt eine parametrierbare AIRBASE-API, aber keinen WAREHOUSE-Setter oder -Hook. Er genehmigt keinen Runtime-Override und keine MOOSE-Quelländerung.
