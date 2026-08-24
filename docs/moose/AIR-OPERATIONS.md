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
source_commit: 801b88b58bd2fc799535edd2e80fc463bc4c4dc9
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

Für Parking-Overrides ist diese Prüfung abgeschlossen:

- [`OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH`](WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

Der Bericht belegt eine parametrierbare AIRBASE-API, aber keinen WAREHOUSE-Setter oder -Hook. Er genehmigt keinen Runtime-Override und keine MOOSE-Quelländerung.

## 5. Extern basierter E-3-AWACS-Pfad

Für den extern basierten USAF-E-3-AWACS-Lifecycle wird kein DCS-Airbase-Ersatz für Al Dhafra erzeugt. `OFFMAP_AL_DHAFRA` bleibt ein reiner CampaignState-Knoten.

Der produktive branch-lokale Pfad verwendet weiterhin MOOSE-first:

```text
SPAWN
-> FLIGHTGROUP
-> AUFTRAG
-> FLIGHTGROUP:Refuel(...)
-> PassingWaypoint-/Refueled-FSM
-> External Handoff / Despawn
```

Die umfangreiche MOOSE-Klasse `AWACS` wird hierfür bewusst nicht verwendet, weil ihr eigener FEZ-/Fighter-Control-/SRS-/Home-Airbase-Scope über die angeforderte physische OMW-AWACS-Abbildung hinausgeht.

Der aktuell DCS-bestätigte branch-lokale Produktionspfad ist:

```text
OMW_AWACS_Controller_FullLifecycle_V3.lua
+ OMW_AWACS_MOE_Relief.lua
-> tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

Funktional bestätigt sind dabei der externe WIZARD-Lifecycle, der APOC-Orbit, der geplante erste AAR mit LISA, der geplante zweite AAR mit MOE, beide `Refueled`-/Rejoin-Pfade sowie der finale ROSIE-Egress und externe Handoff. Das neu benannte Base-Artefakt wurde zusätzlich in DCS als Packaging-Smoke-Test geladen und bis zum regulären APOC-Lifecycle ausgeführt.

Diese Aussage bleibt auf die dokumentierte Branch-/Commit-/MIZ-/Bundle-/DCS-/MOOSE-Provenienz beschränkt und erzeugt keine branch-unabhängige Validierung.

Technische Details, Evidenzgrenzen und Acceptance:

- [`OMW-MOOSE-AWACS-EXTERNAL-LIFECYCLE`](AWACS-EXTERNAL-LIFECYCLE.md)
- [`OMW-MOOSE-AWACS-FUEL-DRIVEN-AAR`](AWACS-FUEL-DRIVEN-AAR-LIFECYCLE.md)
- [`AWACS Acceptance 4`](../../mission/tests/awacs-external-lifecycle/ACCEPTANCE-4.md)
