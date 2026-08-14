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
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: GIT_HISTORY
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
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung; Kandahar Main ID 7 und Kandahar Heliport ID 15 bestätigt; 12.08.2026 zusätzlich 296/296 Main- und 80/80 Heliport-Marker mit exakter `.miz parking == MOOSE TerminalID`-Korrelation; `SetParkingSpotWhitelist()`/`SetParkingSpotBlacklist()` für Kandahar source-reviewed und branchseitig konfiguriert; erster Runtime-Lauf 14.08.2026 bestätigte für Kandahar Main 316 Runtime-Parkings statt 315 Klassifikationszeilen und brach vor AIRWING-Konstruktion kontrolliert ab; physische Parking-Compliance weiter offen; Shindand Heliport ID 14 bestätigt; `FindFreeParkingSpotForAircraft()` mit konfigurierbaren Scanparametern source-reviewed, aber nicht in WAREHOUSE verdrahtet |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, Grundstart, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; Kandahar Dual-AIRWING Main/Heliport sowie Shindand Heliport mit finalem Drei-Rollen-Test bestätigt |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, `Ngroups`, Gruppierung, Capabilities, Payloads und post-start Assetbindung; Kandahar neun SQUADRONs / 76 Assetgruppen / 112 Airframes sowie Shindand drei SQUADRONs / 16 Assetgruppen / 20 Airframes bestätigt; Kandahar typgebundene `SetParkingIDs()`-Pools branchseitig konfiguriert, physische Compliance noch nicht DCS-validiert |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AirOps-Stockregistrierung und post-start Zuordnung; strategische Logistik und Persistenz offen; physische typgebundene HELIPAD-Parking-Garantie nicht belegt |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | post-start `AddAsset()` setzt `squadname`, `legion`, `cohort` und `assets`; Foundation-Läufe bestätigen die registrierte SQUADRON-/Warehouse-Kette, ohne Recovery-Nachweis |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AIRWING-`FlightOnMission`-Pfad, Cold-Takeoff-Prüfung und `SetOptionPreferVertical()`-Propagation im finalen Shindand-Lauf bestätigt; physisches Abflugprofil bleibt typabhängig |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno `New -> AddAirwing -> Start -> CanMission -> AddMission/Status` bis AUFTRAG `started`; Shindand Foundation verwendet COMMANDER ausdrücklich nicht |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno CAS sowie Shindand `NewCAS()`, `NewLANDATCOORDINATE()` und `AssignSquadrons()` im nativen AIRWING-Pfad bis Missionserfolg bestätigt; physische Außenlandung bei `LANDATCOORDINATE` nicht beobachtet |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und verzögerte post-start Diagnose; finaler Shindand-Kombinationstest bestätigt |
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

Der Kandahar-Foundation-Lauf bestätigt zusätzlich, dass zwei getrennte AIRWING-Instanzen mit getrennten Warehouse-Ankern und nativen Airbases innerhalb derselben Mission parallel konstruiert und gestartet werden können.

Der finale Shindand-Lauf bestätigt für einen Heliport-AIRWING mit drei SQUADRONs zusätzlich den direkten nativen `AIRWING:AddMission(AUFTRAG)`-Pfad für AH-64D CAS sowie UH-60/CH-47 `LANDATCOORDINATE` bis MOOSE-Missionserfolg. COMMANDER und OPSTRANSPORT sind dabei ausdrücklich nicht Teil der Foundation.

## 5. Vertikaloption und COMMANDER

- `AIRWING:SetOptionPreferVerticalLanding()` muss vor `AIRWING:Start()` gesetzt werden.
- Der Quellpfad reicht die Option im nativen `FlightOnMission` an `FLIGHTGROUP:SetOptionPreferVertical()` weiter.
- Der finale Shindand-Lauf bestätigte `OptionPreferVertical=true` für AH-64D, UH-60 und CH-47.
- Der Projektinhaber beobachtete UH-60 und CH-47 mit vertical takeoff; die AH-64D rollten zur Heli-Runway und starteten von dort. Die Option ist daher keine Garantie für einen senkrechten Start jedes Helikoptertyps.
- `AUFTRAG:NewHOVER()` sowie die öffentliche HOVER-Capability-Registrierung sind für G8C source-reviewed; sie sind bis zum DCS-Lauf nicht validiert.
- `COMMANDER:AddAirwing()` startet den COMMANDER nicht.
- Der akzeptierte COMMANDER-Pfad enthält zwingend `COMMANDER:Start()` und den normalen Status-/Queuezyklus.

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

Aktueller Kandahar-Foundation-Nachweis:

```text
Branch: agent/kandahar-foundation-july-2011-rebuild
Source-Commit: 578816472c53279290ff6b64296ed8d49982bc72
MIZ: OMW_Template_v6_Tarinkot(6).miz
DCS: 2.9.28.26385
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: 2 AIRWINGs / 9 SQUADRONs / 76 Assetgruppen / 112 Airframes / beide AIRWINGs Running
```

Aktueller Kandahar-Parking-Nachweis:

```text
Testdatum: 2026-08-12
Branch: agent/airborne-ammo-parking-correlation
Source-Commit: 5ad6d2c535c2e6796a677fd18975be794533ab8b
BuilderVersion: AIRBORNE-AMMO-PARKING-CORRELATION-3
Bundle SHA-256: cb650dd8bab448de39eb1a26f4bc856964f375600df51a5587fcf02c521a65fd
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 8f345af681276bc8634128b023873be4473df459deb2f6f9b230f3cbd901c84d
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: Kandahar Main 296/296; Kandahar Heliport 80/80; total 376/376 exact .miz parking == MOOSE TerminalID matches
Mapping: docs/data/kandahar-me-parking-to-moose-terminalid.csv
```

Erster Kandahar-Parking-Allocation-Runtimelauf:

```text
Testdatum: 2026-08-14
Branch: agent/kandahar-parking-allocation
Source-Commit: 1d96458c5598639485ce46d8d50ff399ff052b60
BuilderVersion: KAF-AIR-OPS-FOUNDATION-ONLY-2
Bundle SHA-256: 6e941f1436112055836e47b2acad1c5ba4e5cbcd5426cf2d6884a07fe87f25e2
MIZ: OMW_Template_v8_AirOps_rdy(20260814-060742).miz
MIZ SHA-256: 67ee9c695380c47489791741d73cfaba4fc54e1a7d85e0a09310993bdc2b4c05
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: FAIL before AIRWING construction; Kandahar Main runtime Parking=316, configured schema expected=315
```

Der Fail ist ein kontrollierter Schema-Guard und kein Nachweis physischer Parking-Compliance. Die owner-defined Klassifikation enthält 315 Kandahar-Main-Zeilen; der exakte zusätzliche Runtime-TerminalID wurde in diesem Lauf nicht identifiziert. Die korrigierte Branch-Policy hält die 69 explizit freigegebenen TerminalIDs unverändert und behandelt jeden übrigen Runtime-Spot fail-closed als Blacklist. Für 316 Runtime-Spots ergibt das 247 geblacklistete Main-Spots. Eine konkrete Benennung oder Typzuordnung des zusätzlichen Spots wird ohne separaten Nachweis nicht behauptet.

Aktueller Shindand-Nachweis:

```text
Branch: agent/shindand-heliport-parking-diagnostic
Source-Commit: 584ed674e1d3f642a22c96398c2ebc97b9efcb61
BuilderVersion: SHND-FINAL-FOUNDATION-ACCEPTANCE-1
Bundle SHA-256: 8202dfd353a854ea0a1ce7db3fcadb5bb716ae757b6ac41181dadb2cf7ecba7c
DCS: 2.9.28.26385 MT
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: 1 AIRWING / 3 SQUADRONs / 16 Assetgruppen / 20 Airframes / AH-64D CAS success / UH-60 und CH-47 LANDATCOORDINATE success
Limit: keine validierte physische Außenlandung; Parking kein Foundation-Acceptance-Kriterium
```

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

### 8.1 Kandahar Parking Allocation

Auf `agent/kandahar-parking-allocation` wird der owner-defined Parking-Vertrag mit ausschließlich öffentlichen MOOSE-APIs abgebildet:

```text
AIRBASE:SetParkingSpotWhitelist(...)
AIRBASE:SetParkingSpotBlacklist(...)
SQUADRON:SetParkingIDs(...)
```

Kandahar Main besitzt im DCS-Runtimelauf vom 14.08.2026 316 von MOOSE gelieferte Parking-Spots. Die owner-defined Klassifikation enthält 315 benannte Main-Positionen. Der Runtime-Vertrag gibt weiterhin genau 69 TerminalIDs frei und blacklisted fail-closed alle übrigen Runtime-Spots; damit ergeben sich 247 geblacklistete TerminalIDs. Die 69 freigegebenen Spots sind typgebunden: A-10C 24, C-130 22, MQ-1/MQ-9 gemeinsam 11 und 26th-ERQS-HH/UH-60-MEDEVAC-Ersatz 12 auf Lima `L01-H` bis `L12-H`. Lima `L13-H` bis `L15-H` bleiben geblacklistet. Der zusätzliche Runtime-Spot bleibt bis zu einer separaten Identifikation bewusst ohne erfundene ME-Bezeichnung oder Typzuordnung und ist durch die fail-closed Policy gesperrt.

Kandahar Heliport verwendet alle 86 bekannten `HelicopterOnly`-Spots als typgebundene SQUADRON-Pools: OH-58 19, AH-64 26, UH-60/Blackhawk 29 und CH-47/CH-53-Familie 12. Die Konfiguration ist source-reviewed, aber die physische Parking-Compliance des WAREHOUSE/AIRWING-Spawnpfads bleibt bis zum DCS-Test ausdrücklich unvalidiert. Der bekannte Shindand-G2-Befund (`asset.parkingIDs` korrekt, physischer Spawn außerhalb des Pools) bleibt als relevante Framework-/DCS-Grenze bestehen.
