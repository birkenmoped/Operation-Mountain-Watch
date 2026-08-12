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

## 5. Genereller Hinweis zu Two-Ship-Recovery und Parking

Produktive `SQUADRON:SetParkingIDs(...)`-Pools, AIRBASE-White-/Blacklists und WAREHOUSE-Parkingprüfung steuern beziehungsweise begrenzen die **Materialisierung** von Assets. Daraus darf keine Garantie für eine individuelle Return-Parking-ID jedes Elements einer Mehrfachgruppe abgeleitet werden.

Für OMW ist deshalb zwischen zwei Problemklassen zu unterscheiden:

```text
Materialisierung / Spawn
  -> SQUADRON-/WAREHOUSE-Parking-Pool
  -> belegte Spawn-Parking-Grenzen

Recovery / Landung / Rollen zum Stand
  -> bestehender FLIGHTGROUP und DCS-AI-Lifecycle
  -> keine aus SetParkingIDs abgeleitete Einzelplatz-Garantie
```

In DCS-Läufen des Branches `agent/airborne-ammo-partial-consumption` wurde bei produktiven Two-Ships beobachtet, dass gleichzeitige beziehungsweise paarweise Recovery problematisch sein kann: Helikopter-Wingmen kreisten über dem Bereich des Lead, und A-10C konnten nach der Landung in belegte beziehungsweise statische Bereiche rollen. Diese branchgebundene Beobachtung ist **kein** allgemeiner DCS-Acceptance-Nachweis und ersetzt keine missionsspezifische Parking-Prüfung.

Der gepinnte MOOSE-Stand stellt mit `FLIGHTGROUP:SetOptionLandingRestrictPair()` einen öffentlichen, kleinen Eingriff bereit, der DCS anweist, die Gruppe nicht als Paar landen zu lassen. Der gezielte Ammo-V2-Test zeigte damit für AH-64D und OH-58D praktisch brauchbare `Landed -> Arrived`-Recovery; daraus folgt weiterhin **keine** Garantie bestimmter oder unterschiedlicher Parking-IDs. Für A-10C blieb `Arrived` in den bisherigen Läufen nicht zuverlässig erreichbar.

Projektregel für zukünftige Two-Ship-Tests und AirOps-Entwicklung:

1. Spawn-Parking und Return-Parking nicht gleichsetzen.
2. Keine individuelle Return-Parking-Zuweisung erfinden, solange MOOSE/DCS dafür keinen belegten öffentlichen Pfad bereitstellt.
3. Bei einem testblockierenden Pair-Recovery-Konflikt zuerst den öffentlichen MOOSE-Landing-Pfad prüfen; testlokale `SetOptionLandingRestrictPair()`-Nutzung ist einem Parking-Override oder Despawn-Workaround vorzuziehen.
4. Produktive Gruppierung nicht nur zur Testvereinfachung ändern. `Grouping=2` bleibt ein echtes Two-Ship-Asset.
5. `SetDespawnAfterLanding()`, `SetDespawnAfterHolding()` oder direkte testseitige `ReturnToLegion()`-Aufrufe dürfen nicht verwendet werden, wenn der reale Return-/Warehouse-Lifecycle Gegenstand des Tests ist.
6. Physische Parking-, Taxi- und Recovery-Wirkung bleibt airbase-, aircraft-, mission- und DCS-versionsabhängig und ist separat in DCS zu beobachten.
