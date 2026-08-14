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
source_branch: agent/aar-rc-east-runtime-scope
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
- [`OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION`](STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md)

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
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung; Kandahar Main ID 7 und Kandahar Heliport ID 15 bestätigt; 12.08.2026 zusätzlich 296/296 Main- und 80/80 Heliport-Marker mit exakter `.miz parking == MOOSE TerminalID`-Korrelation; Shindand Heliport ID 14 bestätigt; `FindFreeParkingSpotForAircraft()` mit konfigurierbaren Scanparametern source-reviewed, aber nicht in WAREHOUSE verdrahtet |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, Grundstart, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; Kandahar Dual-AIRWING Main/Heliport sowie Shindand Heliport mit finalem Drei-Rollen-Test bestätigt; Tanker-Selektion nach Boom/Probe in `CheckTANKER()` und kompatible Tankersuche in `GetTankerForFlight()` für den gepinnten Stand zusätzlich source-reviewed, aber noch nicht als OMW-AAR-Lauf validiert |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, `Ngroups`, Gruppierung, Capabilities, Payloads und post-start Assetbindung; Kandahar neun SQUADRONs / 76 Assetgruppen / 112 Airframes sowie Shindand drei SQUADRONs / 16 Assetgruppen / 20 Airframes bestätigt |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AirOps-Stockregistrierung und post-start Zuordnung; strategische Logistik und Persistenz offen; physische typgebundene HELIPAD-Parking-Garantie nicht belegt |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | CampaignState->DCS-Warehouse Item-/Liquid-Mirror, Technical Availability sowie native Ground-Crew-/Materialization-Transaktionen für dokumentierte Pfade; zentraler Warehouse-Bootstrap NEW/RESTORE am 13.08.2026 mit Item-, Fuel- und Technical-Readback sowie 0.5-kg Fuel-Toleranz bestätigt; keine strategische Rückautorität |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | post-start `AddAsset()` setzt `squadname`, `legion`, `cohort` und `assets`; Foundation-Läufe bestätigen die registrierte SQUADRON-/Warehouse-Kette, ohne Recovery-Nachweis |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AIRWING-`FlightOnMission`-Pfad, Cold-Takeoff-Prüfung und `SetOptionPreferVertical()`-Propagation im finalen Shindand-Lauf bestätigt; AAR zusätzlich source-reviewed für `GetFuelMin()`, `SetFuelLowThreshold()`, `SetFuelLowRTB(false)`, FuelLow-Callback und aktuelle Gruppenkoordinate; physisches AAR-/Egress-Verhalten bleibt Acceptance-pflichtig |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno `New -> AddAirwing -> Start -> CanMission -> AddMission -> Status` bis AUFTRAG `started`; Shindand Foundation verwendet COMMANDER ausdrücklich nicht; `AddTankerZone(...)` ist im gepinnten Stand source-reviewed, aber für OMW nicht ausgewählt oder DCS-validiert |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno CAS sowie Shindand `NewCAS()`, `NewLANDATCOORDINATE()` und `AssignSquadrons()` im nativen AIRWING-Pfad bis Missionserfolg bestätigt; physische Außenlandung bei `LANDATCOORDINATE` nicht beobachtet; `NewTANKER()`, `SetRadio()`, `SetTACAN()`, `SetMissionEgressCoord()`, `IsExecuting()` und `Cancel()` sind für AAR im gepinnten Stand source-reviewed, jedoch noch nicht als vollständiger OMW-Tanker-Lifecycle DCS-validiert |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und verzögerte post-start Diagnose; finaler Shindand-Kombinationstest sowie 1-s-Delay im Warehouse-Acceptance-Harness bestätigt |
| `USERFLAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Warehouse-Acceptance-Harness setzt `OMW_WAREHOUSE_READY` fail-closed 0->1; `New()`, `Set()` und `Get()` im gepinnten MOOSE-Stand und DCS-Debriefzustand `1` am 13.08.2026 bestätigt |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-, Static-, Warehouse- und Zonenvalidierung |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperations- und Bestandsmodell; für den AAR-Retest ist `OPSGROUP:Despawn(Delay, NoEventRemoveUnit)` zusätzlich source-reviewed als kontrollierter physischer Off-map-Handoff nach Egress-Gate-Eintritt, noch nicht DCS-validiert |
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

## 7. AAR-Source-Review-Grenze

Für den aktuellen AAR-Planungs- und Acceptance-Stand sind `AUFTRAG:NewTANKER()`, `AUFTRAG:SetRadio()`, `AUFTRAG:SetTACAN()`, `AUFTRAG:SetMissionEgressCoord()`, `AUFTRAG:IsExecuting()`, `AUFTRAG:Cancel()`, `FLIGHTGROUP:GetFuelMin()`, `FLIGHTGROUP:SetFuelLowThreshold()`, `FLIGHTGROUP:SetFuelLowRTB(false)`, der FuelLow-Callback, die Gruppenkoordinate, `COORDINATE:Get2DDistance()`, `OPSGROUP:Despawn(Delay, NoEventRemoveUnit)`, `AIRWING:CheckTANKER()`, `AIRWING:GetTankerForFlight()` und `COMMANDER:AddTankerZone()` im tatsächlich gepinnten `Moose.lua` geprüft. Der Source-Review bestätigt API-Verfügbarkeit und Signaturen, nicht das reale DCS-Verhalten von KC-135-Orbit, Funk, TACAN, Fuel, Offload, Egress oder Off-map-Handoff. Diese Pfade bleiben für AAR deshalb `SOURCE_REVIEWED` innerhalb der bereits grundsätzlich validierten Klassen.

`AAR-KC135-RUNTIME-ACCEPTANCE-2` nutzt `OPSGROUP:Despawn(1, true)` erst innerhalb eines 10-NM-Radius um das zugewiesene Egress-Gate. Die `true`-Option unterdrückt die normalen Remove-Unit-Events und verhindert im isolierten Test damit einen fälschlichen Warehouse-/Legion-Rücklauf. CampaignState wird im Retest nicht verändert.

Die fachliche AAR-Architektur und offenen Acceptance-Punkte stehen in [`OMW-MOOSE-ISR-FAC-CAS-AAR`](ISR-FAC-CAS-AAR.md).

## 8. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn:

- die verwendete MOOSE-Version identifiziert ist;
- API, Signatur und interner Lifecycle geprüft sind;
- Mission, OMW-Commit und relevante Hashes dokumentiert sind;
- beobachtetes Verhalten und Einschränkungen festgehalten sind;
- der Nachweis im Methodenregister oder Acceptance-Bericht verlinkt ist.

Aktueller Warehouse-Bootstrap-Nachweis:

```text
Testdatum: 2026-08-13
Branch: agent/air-ops-initial-stock-runtime-data
Acceptance-Commit: 2502516fe130b908e500117142399b3e2ca74007
BuilderVersion/TestId: AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1
Bundle SHA-256: 025855c07896ee396b545ae2b131c2f4181e6eed88c412580288d644f4d311ac
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: dd25f68a7361c36fa121a581022a9535f55372ad1f32a7992d4013e9c6f0c0d8
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Result: strategic item/fuel/technical NEW+RESTORE PASS; OMW_WAREHOUSE_READY=1; AirOps gated startup PASS
```

Vollständiger Nachweis:

- [`OMW-TEST-AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE`](../../mission/tests/air-ops-warehouse-bootstrap/expected/air-ops-warehouse-bootstrap-acceptance-2026-08-13.md)

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

## 9. WAREHOUSE-Parking-Grenze

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
