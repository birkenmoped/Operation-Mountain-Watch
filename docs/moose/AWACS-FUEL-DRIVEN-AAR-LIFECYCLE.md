---
document_id: OMW-MOOSE-AWACS-FUEL-DRIVEN-AAR
status: DRAFT
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS fuel-state driven AAR design on the working branch
  - branch-local AWACS production-bundle design
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: PENDING_MERGE
supersedes:
superseded_by:
validated_in_dcs: true
---

# AWACS Fuel-Driven AAR Lifecycle

## 1. Geltungsbereich

Dieses Dokument beschreibt den funktional in DCS bestätigten WIZARD-Lifecycle sowie dessen Produktivisierung als `OMW_AWACS_Base.lua`.

Architekturgrenzen:

```text
CampaignState = strategische Ressourcenautorität
DCS groups = temporäre physische Repräsentationen
MOOSE = primäres Framework
kein MIST
kein Native-DCS-Refuel-Ersatz
kein Live-Retask mit ClearWaypoints
```

Gepinnter Framework-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Validierter WIZARD-Lifecycle

Der erfolgreiche Abschlusslauf vom 24.08.2026 bestätigt funktional:

```text
OFFMAP_AL_DHAFRA
-> visible materialization
-> ROSIE ingress
-> FL350 / 270 KIAS transit
-> APOC FL320 / 250 KIAS persistent racetrack
-> scheduled sensor/service activation
-> first planned AAR with LISA
-> Refueled
-> APOC physical rejoin / sensor restore
-> second planned AAR with MOE
-> Refueled
-> APOC physical rejoin / sensor restore
-> service-end egress
-> ROSIE outbound
-> external handoff
-> despawn / strategic recredit
```

Getesteter Source-Stand vor dem Lauf:

```text
branch: agent/awacs-external-lifecycle-foundation
commit: 2bda2f066ce1ad11aeed5eb7b98b294d2e399e2d
controller: OMW_AWACS_Controller_FullLifecycle_V3.lua
MOE extension: OMW_AWACS_MOE_Relief.lua
DCS: 2.9.28.26385 MT
mission file reported by DCS/debrief: OMW_Template_v20.miz
```

Die exakten MIZ- und internal-`mission`-SHA-256-Werte dieses letzten Laufs sind noch nicht gebunden. Deshalb bleibt dieses Dokument `DRAFT` und wird nicht zu `ACCEPTED_TECHNICAL_BASELINE` erhoben.

## 3. Flight- und Performance-Baseline

Acceptance 5 hat 15 E-3A-Profile mit 20 NM Stabilisierung und 200 NM Messstrecke geflogen. Ergebnis:

```text
15/15 complete
14 STABLE
FL350 / 310 KIAS MARGINAL
```

Verwendete Produktionswerte:

```text
WIZARD normal transit: FL350 / 270 KIAS
WIZARD optional fast:  FL350 / 290 KIAS
APOC racetrack:        FL320 / 250 KIAS / 017T / 30 NM
LISA AAR track:        FL250 / 270 KIAS / 340T / 20 NM
MOE AAR track:         FL250 / 270 KIAS / 340T / 20 NM
WIZARD LISA RV target: FL250 / 290 KIAS
```

Gemeinsamer dedizierter AWACS-AAR-Anker:

```text
33.6233926368 N
68.6395554105 E
```

## 4. AAR-Zyklen

### Erster geplanter Zyklus – LISA

Der bewährte V3-Pfad bleibt unverändert:

```text
65 % WIZARD fuel
-> LISA pre-dispatch
-> LISA on dedicated AWACS track
-> LISA_READY
-> Controller.RequestRefuel()
-> FLIGHTGROUP:Refuel()
-> Refueled
-> APOC rejoin
```

LISA:

```text
Template: OMW_AAR_KC135_LISA
Source: AL_UDEID
FIR: DAVER
FuelLow: 38 %
Track: FL250 / 270 KIAS / 340T / 20 NM
```

### Zweiter geplanter Zyklus – MOE

`OMW_AWACS_MOE_Relief.lua` ergänzt ausschließlich den zweiten Zyklus. Die funktionierende WIZARD-Routing-/Refuel-Logik wird nicht ersetzt.

```text
first AAR complete
-> arm MOE second cycle
-> next 65 % crossing
-> MOE materialize
-> same dedicated AWACS track
-> MOE_READY
-> Controller.RequestRefuel()
-> FLIGHTGROUP:Refuel()
-> Refueled
-> MOE egress
-> APOC rejoin
```

MOE:

```text
Template: OMW_AAR_KC135_MOE
Source: MANAS
FIR: PINAX
FuelLow: 31 %
Track: FL250 / 270 KIAS / 340T / 20 NM
```

Der Abschlusslauf bestätigt `AAR_REFUELED` mit `OMW_AAR_KC135_MOE#001`, `SECOND_CYCLE_COMPLETE` und den anschließenden APOC-Rejoin.

## 5. Fuel-Policy

```text
65 % -> planned dedicated tanker pre-dispatch
40 % -> fallback AAR trigger
25 % -> visible off-map contingency floor
```

Die 40-%-Schwelle ist keine normale geplante AAR-Startschwelle.

Die 25-%-Schwelle bleibt eine OMW-DCS-Contingency-Grenze und ist keine ungeprüfte reale E-3A-Landing-Fuel-Aussage.

## 6. MOOSE-First-Vertrag

Source-verifizierte Kernpfade:

```text
SPAWN
FLIGHTGROUP
AUFTRAG
COORDINATE
SCHEDULER
UTILS.IasToTas
FLIGHTGROUP:SetDefaultSpeed
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:SetFuelLowThreshold
FLIGHTGROUP:SetFuelCriticalThreshold
FLIGHTGROUP:FindNearestTanker
FLIGHTGROUP:Refuel
FuelLow / FuelCritical / Refueled FSM callbacks
PauseMission / UnpauseMission lifecycle
AUFTRAG:NewTANKER
```

Receiver-Ablauf:

```text
FLIGHTGROUP:Refuel(Coordinate)
-> PauseMission()
-> DCS TaskRefueling()
-> Refueled FSM
-> persistent APOC mission rejoin
```

Nicht verwendet:

```text
MIST
Native-DCS-Refuel-Parallelimplementation
parallel contact controller
ClearWaypoints live route surgery
MissionScripting.lua changes
undocumented SPAWN fuel mutation
```

## 7. Verworfenes V4-/AAR-Base-Retask-Experiment

Der zwischenzeitliche Ansatz, LISA/MOE über ihre produktiven Standard-AAR-Tracks zu beziehen und anschließend live auf einen AWACS-Track umzurouten, ist verworfen.

Begründung aus DCS:

```text
production reserve track geometry pulled WIZARD away from APOC
subsequent live route override did not establish the intended tanker mission reliably
```

Dieser Ansatz gehört nicht zur Produktionsbaseline und wird vom Base-Builder explizit durch das Verbot von `ClearWaypoints(` ausgeschlossen.

## 8. Produktionsbundle `OMW_AWACS_Base.lua`

Nach funktionalem Abschluss wird die bisherige Entwicklungsbezeichnung `Foundation` abgelöst.

Produktionsartefakt:

```text
tools/build-awacs-base.ps1
-> mission/runtime/air-operations/OMW_AWACS_Base.lua
```

Enthaltene Source-Komponenten:

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AirOpsInitialStock.lua
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/air-operations/OMW_AWACS_CampaignStateAdapter.lua
scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua
scripts/air-operations/OMW_AWACS_MOE_Relief.lua
scripts/air-operations/OMW_AirOps_AWACS_Bootstrap.lua
```

`OMW_AWACS_Acceptance_4.lua` wird **nicht** in die Base aufgenommen.

Die bisherige `tools/build-awacs-foundation.ps1` bleibt nur als Übergangs-/Kompatibilitätseinstieg und delegiert an den Base-Builder. Neue Missionen sollen ausschließlich `OMW_AWACS_Base.lua` laden.

## 9. Lade- und Autoritätsgrenze

Empfohlene Mission-Ladeordnung:

```text
Moose.lua
shared CampaignState / required common foundations
OMW_AAR_Base.lua
OMW_AWACS_Base.lua
other AirOps systems
```

Die AWACS-Base darf vorhandene gemeinsame strategische Daten nutzen, erzeugt aber keine zweite strategische Ressourcenautorität.

Der dedizierte LISA-/MOE-AWACS-AAR-Pfad gehört zum validierten AWACS-Lifecycle. Die allgemeine `OMW_AAR_Base.lua` bleibt unabhängig für die übrige Tankerinfrastruktur zuständig; der verworfene Versuch, deren geografische Standardtracks als AWACS-Track zu verwenden, wird nicht wieder eingeführt.

## 10. Produktivisierungs-Gate

Die Source-Logik ist funktional in DCS validiert. Die Umbenennung zum generierten `OMW_AWACS_Base.lua` verändert Header und Bundle-Hash. Deshalb sind nach Erstellung noch erforderlich:

```text
local build of OMW_AWACS_Base.lua
real Base SHA-256
Lua 5.1 / CI syntax check
short DCS load/smoke confirmation of the renamed artifact
```

Erst danach wird das neue Base-Artefakt als exakt DCS-geprüfter Produktionsstand dokumentiert.
