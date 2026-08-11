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
source_branch: agent/storage-fuel-adapter-foundation
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module.

Der vollständige frühere Klassenindex bleibt unverändert erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

Technische Lifecycle-Details:

- [`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`](AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE.md)
- [`OMW-MOOSE-STORAGE-AIRWING-WEAPON-LIFECYCLE`](STORAGE-AIRWING-WEAPON-LIFECYCLE.md)
- [`OMW-MOOSE-VERIFIED-METHODS`](VERIFIED-METHODS.md)
- [`OMW-ARCH-RESOURCE-WAREHOUSE-OWNERSHIP`](../resource-warehouse-ownership-contract.md)
- [`OMW-MOOSE-LOGISTICS-TRANSPORT`](LOGISTICS-AND-TRANSPORT.md)

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
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Auflösung, ID, Parkingdump und airfield-spezifische Kalibrierung; Kandahar Main ID 7, Kandahar Heliport ID 15 und Shindand Heliport ID 14 bestätigt; `FindFreeParkingSpotForAircraft()` mit konfigurierbaren Scanparametern source-reviewed, aber nicht in WAREHOUSE verdrahtet |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, Stockregistrierung, Grundstart, SQUADRON-Bindung und direkter AUFTRAG-Dispatch; Kandahar Dual-AIRWING Main/Heliport sowie Shindand Heliport mit finalem Drei-Rollen-Test bestätigt; Wiederverwendung nach nativer Recovery ist für `STORAGE-AIRWING-WEAPON-LIFECYCLE-1` source-reviewed und DCS-offen |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion, `Ngroups`, Gruppierung, Capabilities, Payloads und post-start Assetbindung; Kandahar neun SQUADRONs / 76 Assetgruppen / 112 Airframes sowie Shindand drei SQUADRONs / 16 Assetgruppen / 20 Airframes bestätigt |
| `WAREHOUSE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AirOps-Stockregistrierung und post-start Zuordnung; strategische Logistik und Persistenz offen; physische typgebundene HELIPAD-Parking-Garantie nicht belegt |
| `STORAGE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Limited-Liquid- und Weapon-Inventory-Lesepfade bestätigt; AH-64D M151/AGM-114K/IAFS External-Store-Debit für dokumentierten Scope validiert; Return/Recredit-Semantik bleibt Gegenstand des Lifecycle-Gates |
| `COHORT` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | post-start `AddAsset()` setzt `squadname`, `legion`, `cohort` und `assets`; Foundation-Läufe bestätigen die registrierte SQUADRON-/Warehouse-Kette; konkrete Recovery-Wiederverwendung DCS-offen |
| `FLIGHTGROUP` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AIRWING-`FlightOnMission`-Pfad, Cold-Takeoff und Vertikaloption bestätigt; `IsLanding`/`IsLanded`/`IsArrived`, `GetAmmoTot`, `OnAfterLanded`/`OnAfterArrived` und nativer `onafterArrived -> ReturnToLegion(1)`-Pfad sind für den neuen Lifecycle-Gate source-reviewed |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno `New -> AddAirwing -> Start -> CanMission -> AddMission -> Status` bis AUFTRAG `started`; Shindand Foundation verwendet COMMANDER ausdrücklich nicht |
| `AUFTRAG` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Salerno CAS sowie Shindand `NewCAS()`, `NewLANDATCOORDINATE()` und `AssignSquadrons()` im nativen AIRWING-Pfad bis Missionserfolg bestätigt; physische Außenlandung bei `LANDATCOORDINATE` nicht beobachtet |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und verzögerte post-start Diagnose; neuer Lifecycle-Gate nutzt bounded 5-s-Telemetrie mit 1800-s Safety-Timeout |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-, Static-, Warehouse- und Zonenvalidierung |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperations- und Bestandsmodell |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport einschließlich source-reviewed `AddCargoStorage(...)`; OMW-Runtime-Acceptance ausstehend |
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

Aktueller Kandahar-Nachweis:

```text
Branch: agent/kandahar-foundation-july-2011-rebuild
Source-Commit: 578816472c53279290ff6b64296ed8d49982bc72
MIZ: OMW_Template_v6_Tarinkot(6).miz
DCS: 2.9.28.26385
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: 2 AIRWINGs / 9 SQUADRONs / 76 Assetgruppen / 112 Airframes / beide AIRWINGs Running
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

Aktueller STORAGE-Fuel-Adapter-Nachweis:

```text
Branch: agent/storage-fuel-adapter-foundation
Source/Acceptance-Commit: 0e5992f96a37b7400d7859fbcd3e98829f935d68
BuilderVersion: STORAGE-FUEL-ADAPTER-FOUNDATION-1
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 54e9bd5d1d841a6c22980e59e07b463aef580032813f3441f1030b221fec66e9
Bundle SHA-256: 16faa7da140334ddd3a001480e6f2677842b3dcc3cff64626796e039cd0769db
DCS: 2.9.28.26385 MT
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Condition: Kandahar Limited Liquids; initial JETFUEL/GASOLINE 100000 kg / 100000 kg
Result: write/readback PASS; JP-8/AVGAS separation PASS; idempotency PASS; restore PASS
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

## 9. STORAGE-Grenze

Source-reviewed gegen den gepinnten `Moose.lua`-Stand und für den Kandahar-Foundation-Scope praktisch bestätigt:

```text
STORAGE
  -> Wrapper um das DCS-Warehouse eines Airbases
  -> Liquids lesen/schreiben
  -> Liquid-Mengen in kg
  -> JETFUEL und GASOLINE getrennte Liquid-Typen
```

Der Branch `agent/storage-fuel-adapter-foundation` verwendet einen kleinen projektspezifischen STORAGE-Adapter in:

```text
scripts/logistics/OMW_StorageFuelAdapter.lua
```

Verwendete öffentliche API:

```text
STORAGE:FindByName()
AIRBASE:FindByName() / AIRBASE:GetStorage() als source-reviewed Fallback
STORAGE:GetLiquidAmount()
STORAGE:SetLiquid()
STORAGE.Liquid.JETFUEL
STORAGE.Liquid.GASOLINE
```

Für den dokumentierten Kandahar-Lauf sind praktisch bestätigt:

```text
STORAGE:FindByName("Kandahar")
STORAGE:GetLiquidAmount(JETFUEL)
STORAGE:GetLiquidAmount(GASOLINE)
STORAGE:SetLiquid(JETFUEL, amountKg)
STORAGE:SetLiquid(GASOLINE, amountKg)
100 t ME liquid -> 100000 kg STORAGE readback
same desired snapshot -> changeCount=0
restore original quantities -> verified=true
```

Technische Voraussetzung des akzeptierten Pfads:

```text
CampaignState-managed STORAGE fuel node
-> DCS Unlimited Liquids = OFF
```

Nicht belegt bleiben:

- CampaignState-Integration über einen realen CampaignState-Store;
- DCS-Warehouse als strategische Ressourcenhoheit;
- DCS-Warehouse-Waffenrueckgutschrift bei AIRWING-Recovery;
- STORAGE-Persistenz;
- Multiplayer-/Restart-Reconciliation;
- automatische Aircraft-Fuel-Abbuchung.

Der Accepted-Technical-Baseline-Nachweis steht in [`OMW-TEST-STORAGE-FUEL-ADAPTER-FOUNDATION-ACCEPTANCE`](../../mission/tests/storage-fuel-adapter/expected/storage-fuel-adapter-foundation-acceptance.md). Die methodenspezifische Evidenz ist im Methodenregister zu führen.

## 10. Geplanter Weapon-Recovery-Lifecycle

`STORAGE-AIRWING-WEAPON-LIFECYCLE-1` verwendet keine eigene Recovery-Implementierung. Der gepinnte MOOSE-Stand wurde fuer `FLIGHTGROUP`-`Landed`/`Arrived`, den AI-`ReturnToLegion(1)`-Pfad, `GetAmmoTot()`, `AIRWING:CountAssets()` und `AIRWING:CountAssetsOnMission()` source-reviewed. Der Gate beobachtet zwei aufeinanderfolgende no-fire AH-64D-CAS-Sorties und die STORAGE-Deltas vor, waehrend und nach der nativen Recovery. Bis zum dokumentierten DCS-Lauf bleibt die Recredit- und Wiederverwendungssemantik `PLANNED`.