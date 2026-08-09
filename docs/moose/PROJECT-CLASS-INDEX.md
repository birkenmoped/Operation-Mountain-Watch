---
document_id: OMW-MOOSE-CLASS-INDEX
status: BINDING
document_class: MOOSE_CLASS_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project MOOSE class statuses
  - planned MOOSE integration candidates
  - scope boundaries of class-level evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - class index without consolidated AIRWING lifecycle evidence
superseded_by:
source_branch: agent/consolidate-air-ops-lifecycle-governance
source_commit: 801b88b58bd2fc799535edd2e80fc463bc4c4dc9
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module.

Der vollständige frühere Klassenindex bleibt unverändert erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

Technische Lifecycle-Details:

- [`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`](AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md)
- [`OMW-MOOSE-VERIFIED-METHODS`](VERIFIED-METHODS.md)

## 2. Statusbedeutung

```text
CANDIDATE
PLANNED
IN_USE_PARTIAL
VALIDATED_FOR_DOCUMENTED_SCOPE
VALIDATED_CONFIGURATION_AND_SOURCE_PATH
SOURCE_REVIEWED
INTERNAL_RESTRICTED
REJECTED_FOR_PROJECT_USE
```

Diese Klassenstatus sind keine Governance-Dokumentstatuswerte.

## 3. Aktuell besonders relevante Klassen

| Klasse | Projektstatus | Geltungsgrenze |
|---|---|---|
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung; `FindFreeParkingSpotForAircraft()` mit konfigurierbaren Scanparametern source-reviewed, aber nicht in WAREHOUSE verdrahtet |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, Grundstart und Idle-Foundation; Vertikaloption nur Konfiguration/Quellpfad bis G8 |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, `Ngroups`, Gruppierung, Capabilities, Payloads und post-start Assetbindung |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AirOps-Stockregistrierung und post-start Zuordnung; `_FindParkingForAssets()` source-reviewed mit nicht konfigurierbaren lokalen Scanwerten; strategische Logistik und Persistenz offen |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | post-start `AddAsset()` setzt `squadname`, `legion`, `cohort` und `assets` |
| `FLIGHTGROUP` | `SOURCE_REVIEWED` | `SetOptionPreferVertical()` und AIRWING-Weitergabepfad geprüft; tatsächlicher Tarinkot-Abflug offen |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno `New -> AddAirwing -> Start -> CanMission -> AddMission -> Status` bis AUFTRAG `started` |
| `AUFTRAG` | `IN_USE_PARTIAL` | Capability-/Payloadzuordnung und Salerno CAS-Dispatch; G8C `NewHOVER()` source-reviewed, DCS-Acceptance offen |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und verzögerte post-start Diagnose |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-, Static-, Warehouse- und Zonenvalidierung |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperations- und Bestandsmodell |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | taktisches Lagebild; Laufzeitnachweis im gepinnten Stand fehlt |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Netze; Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung; Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung; Verfügbarkeit offen |
| `DETECTION_*` | `PLANNED`, eingeschränkt | nur Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose und Templateprüfung |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | aktuelle Produktionsarchitektur `NOT_USED` |

## 4. AIRWING-Lifecycle-Grenzen

Verbindlich:

```text
SQUADRON:New
  -> Konfiguration vorhanden
  -> squadron.assets noch kein positiver Runtime-Bestand

AIRWING:AddSquadron
  -> Cohort registriert
  -> Warehouse-Stock synchron erhöht
  -> automatisches RELOCATECOHORT-Payload
  -> squadron.assets noch deferred

AIRWING:Start plus Initialisierung
  -> Warehouse-Assets werden COHORT/SQUADRON zugeordnet
  -> squadron.assets und geerbte asset.parkingIDs post-start prüfbar
```

Ein Pre-Start-PASS über nichtleere `squadron.assets` ist unzulässig.

## 5. Vertikaloption und COMMANDER

- `AIRWING:SetOptionPreferVerticalLanding()` muss vor `AIRWING:Start()` gesetzt werden.
- Der Quellpfad reicht die Option im nativen `FlightOnMission` an `FLIGHTGROUP:SetOptionPreferVertical()` weiter.
- Tatsächlicher vertikaler Abflug bleibt ein eigener DCS-Acceptance-Punkt.
- `AUFTRAG:NewHOVER()` sowie die öffentliche HOVER-Capability-Registrierung sind für G8C source-reviewed; sie sind bis zum DCS-Lauf nicht validiert.
- `COMMANDER:AddAirwing()` startet den COMMANDER nicht.
- Der akzeptierte Pfad enthält zwingend `COMMANDER:Start()` und den normalen Status-/Queuezyklus.

## 6. Fog-of-War- und RECCE-Grenzen

- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md) ist die vollständige Fähigkeits- und Grenzenanalyse.
- `AUFTRAG:NewRECON()` registriert das Asset nicht automatisch als `INTEL`-Agent.
- `INTEL:SetForgetTime()` ist im geprüften Develop-Stand als obsolet dokumentiert.
- Direkte Zonen- oder Datenbankscans dürfen das Fog-of-War-Modell nicht umgehen.
- `CHIEF` bleibt für die aktuelle Produktionsarchitektur `NOT_USED`.

## 7. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn:

- die verwendete MOOSE-Version identifiziert ist;
- API, Signatur und interner Lifecycle geprüft sind;
- Mission, OMW-Commit und relevante Hashes dokumentiert sind;
- beobachtetes Verhalten und Einschränkungen festgehalten sind;
- der Nachweis im Methodenregister oder Acceptance-Bericht verlinkt ist.

## 8. WAREHOUSE-Parking-Grenze

Die vollständige Recherche steht in:

- [`OMW-MOOSE-WAREHOUSE-PARKING-OVERRIDE-RESEARCH`](WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

Für den gepinnten MOOSE-Stand gilt:

```text
AIRBASE:FindFreeParkingSpotForAircraft(...)
  -> öffentliche, parametrierbare Parking-API

WAREHOUSE:_FindParkingForAssets(...)
  -> separate interne Implementierung
  -> scanradius/scanunits/scanstatics/scanscenery lokal festgelegt
  -> verysafe lokal, aber unbenutzt
  -> kein dokumentierter Setter oder Hook
```

Ein Runtime-Override bleibt `INTERNAL_RESTRICTED` und benötigt vor Entwurf oder Einsatz eine ausdrückliche Eigentümerfreigabe.
