---
document_id: OMW-AIROPS-AAR-PRODUCTION-BASE
status: BINDING
document_class: RUNTIME_INTEGRATION_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - permanent OMW AAR production runtime composition
  - production-versus-acceptance boundary
  - standard and reserve tanker startup semantics
  - MissionDemand-facing AAR service facade
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 248f722fdbf6b0914c458f745f89c05f9821077c
validated_in_dcs: partial
---

# AAR Production Base

## 1. Zweck

Die AAR Production Base ist das dauerhaft mit OMW AIR-OPS zu ladende produktive AAR-Subsystem. Sie ersetzt kein Acceptance-Dokument und enthält keine Teststeuerung.

Produktiver Einstieg:

```text
mission/runtime/air-operations/OMW_AAR_Base.lua
```

Erzeugt durch:

```text
tools/build-aar-production-base.ps1
```

Quellkomponenten:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AirOpsInitialStock.lua
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/air-operations/OMW_AAR_Controller.lua
scripts/air-operations/OMW_AirOps_AAR_Bootstrap.lua
```

## 2. Automatischer Produktionsbetrieb

Beim Laden startet `OMW_AAR_RuntimeIntegration` ausschließlich die STANDARD-Abdeckung des akzeptierten Controllers:

```text
NELSON    FAST  MANAS     EGPAN  STANDARD
PATTY     SLOW  MANAS     EGPAN  STANDARD
MILHOUSE  SLOW  AL_UDEID  DAVER  STANDARD
KRUSTY    SLOW  AL_UDEID  DAVER  STANDARD
```

Diese vier Tracks werden bis zu einer später genehmigten ATO-/Zeitfensterlogik kontinuierlich gehalten.

```text
station cycle:                 3 h
handover-arm gate:             5 min ETA
same-source materialization:   >= 60 s
per-track physical maximum:    1 ACTIVE + 1 RELIEF
```

Geplante Ablösung, reale FuelLow-Ablösung und Ersatz nach realem Aircraft Loss sind Bestandteile des Produktionscontrollers.

## 3. Reserve-Tanker

Die beiden Reserve-Tracks starten nicht automatisch:

```text
LISA  FAST  AL_UDEID  DAVER  RESERVE
MOE   FAST  MANAS     PINAX  RESERVE
```

Produktive Schnittstelle:

```lua
OMW.AirOps.AAR.SubmitDemand(demand)
OMW.AirOps.AAR.EndDemand(demand, terminalStatus)
```

Der spätere COMMANDER beziehungsweise die OMW-MissionDemand-Schicht darf über diese Schnittstelle Bedarf anmelden und beenden. COMMANDER besitzt dabei weder KC-135-Bestand noch Spawnhoheit. CampaignState bleibt strategische Ressourcenautorität; AAR Controller/Adapter materialisieren nur die physische Repräsentation.

Der erste passende Reserve-Demand öffnet den Track. Weitere passende Demands verwenden denselben Track. Nach Ende des letzten Demands wird der Reserve-Track geschlossen und vorhandene ACTIVE-/RELIEF-Tanker gehen auf normalen Egress.

## 4. Routing- und Fuel-Baseline

Verbindlicher Hinflug:

```text
EXTERNAL SPAWN
-> FIR INGRESS
-> 60-NM LATE APPROACH
-> TRACK START
```

Die inbound LRC-/Transferhöhe wird bis einschließlich des 60-NM-Late-Approach gehalten. Erst danach wird der Tanker-AUFTRAG hinzugefügt und der Übergang auf die exakte Track-Höhe eingeleitet.

Verbindlicher Rückflug:

```text
TRACK DEPARTURE / ABORT
-> FIR EGRESS
-> EXTERNAL HANDOFF
-> DESPAWN
```

Die outbound LRC-/Transferhöhe wird ab Missionsabbruch beziehungsweise Verlassen der Tankermission kommandiert.

```text
SPAWN initialization:          480 kt
Transit route command:        300 kt
MANAS inbound/outbound:       FL340 / FL350
AL_UDEID inbound/outbound:    FL350 / FL340
```

Initial Fuel:

```text
MANAS:      91.4067 %
AL_UDEID:   79.4558 %
```

FuelLow:

```text
NELSON:     24 %
PATTY:      26 %
LISA:       38 %
MOE:        31 %
MILHOUSE:   36 %
KRUSTY:     36 %
```

Die vollständige Rechenbasis, virtuellen Source->External-Distanzen, Candidate-5-Messwerte, Reserveannahmen und Acceptance-7-Provenienz stehen in der AAR-Fachdokumentation und im Acceptance-7-Evidenzdokument.

## 5. CampaignState-Komposition

Die Base verwendet genau einen `OMW.AirOps.CampaignContext`.

```text
wenn OMW.AirOps.CampaignContext bereits existiert
-> vorhandenen Store wiederverwenden

wenn kein Context existiert
-> CampaignState einmalig aus genehmigtem AirOps Initial Stock
   + OMW_AARStrategicStock erzeugen
-> als OMW.AirOps.CampaignContext veröffentlichen
```

Damit existiert kein separater AAR-Ressourcenstore neben CampaignState.

Off-map Pools:

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

Materialisierung verbraucht genau ein KC-135-Count. Bestätigter External Handoff credited genau einmal zurück. Realer Totalverlust credited das Aircraft nicht zurück und erhöht den Verlust-Audit genau einmal.

## 6. Production-vs-Test-Grenze

Nicht Bestandteil der Production Base:

```text
Acceptance harness
künstliche FuelLow-Auslösung
UNIT:Explode() Testverlust
beschleunigte MILHOUSE-Ablösung
Background scheduled-relief isolation
TestForceEgress()
Acceptance RESULT/PASS-Assertions
in-process Restore-Testsequenz
```

Diese Mechanismen dürfen ausschließlich in `mission/tests/` existieren.

Bestandteil der Production Base:

```text
normaler 3-h station cycle
reales FuelLow
realer MOOSE Dead/OnAfterDead Loss-Pfad
natürlicher Replacement-Lifecycle
MissionDemand reserve activation
FIR -> 60-NM -> Track Routing
FIR Egress -> External Handoff
CampaignState exact-once accounting
```

## 7. MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Production Base führt keine neue MOOSE-API ein. Sie komponiert ausschließlich den bereits source-reviewed und in Acceptance 7 für den dokumentierten Scope praktisch bestätigten AAR-Controller/Adapter-Pfad.

## 8. Missionsintegration

ChatGPT mutiert keine `.miz`.

Die gebaute Production Base ist als permanenter AIR-OPS-`DO SCRIPT FILE` nach `Moose.lua` zu laden. Die sechs KC-135 Mission-Editor-Templates müssen bereits vorhanden sein; ihre physischen Initial-Fuel-Werte bleiben Mission-Editor-Konfiguration.

Nach der einmaligen Mission-Editor-Integration wird nicht mehr das Acceptance-7-Bundle geladen, sondern ausschließlich die produktive Base. Acceptance-Bundles bleiben Testartefakte und gehören nicht in den normalen Missionsstartup.
