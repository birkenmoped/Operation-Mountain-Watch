---
document_id: OMW-MOOSE-AWACS-EXTERNAL-LIFECYCLE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - DCS-validated MOOSE-first external E-3 routing lifecycle for the exact Acceptance-1 provenance
  - source-reviewed timed AWACS service and designated AAR receiver path pending Acceptance 2
not_authoritative_for:
  - complete AWACS production validation beyond the documented Acceptance-1 routing scope
  - historical 964th EAACS routing details not explicitly sourced
  - production promotion of dedicated AWACS AAR orchestration before Acceptance 2
  - loss and restart behavior before dedicated acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: bde8a6e8d006b7c8d744b739510b08aa9812d48b
validated_in_dcs: true
acceptance_branch: agent/awacs-external-lifecycle-foundation
acceptance_commit: bde8a6e8d006b7c8d744b739510b08aa9812d48b
acceptance_mission: OMW_Template_v19(8).miz
acceptance_mission_sha256: d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes:
superseded_by:
---

# MOOSE – External E-3 AWACS Lifecycle

## 1. Geltungsgrenze

Acceptance 1 bestätigt für den exakt dokumentierten Stand den physischen MOOSE-Lifecycle:

```text
OFFMAP_AL_DHAFRA
-> SPAWN
-> FLIGHTGROUP transit
-> ROSIE inbound
-> AUFTRAG:NewAWACS(...)
-> APOC
-> mission egress
-> ROSIE outbound
-> external handoff
-> Despawn / CampaignState recredit
```

Die danach entwickelte Zeit-/AAR-Erweiterung ist **SOURCE_REVIEWED / DCS_PENDING** und erweitert diese Acceptance-1-Aussage nicht rückwirkend.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Source-verifizierte MOOSE-Bausteine

Für den erweiterten Pfad wurden im tatsächlich gepinnten `Moose.lua` insbesondere geprüft:

```text
SPAWN:New(...)
SPAWN:InitCallSign(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)

FLIGHTGROUP:New(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
FLIGHTGROUP:MissionCancel(...)
FLIGHTGROUP:GetCoordinate()
FLIGHTGROUP:FindNearestTanker(...)
FLIGHTGROUP:Refuel(Coordinate)
FLIGHTGROUP OnAfterRefueled(...)
FLIGHTGROUP PassingWaypoint / OnAfterPassingWaypoint(...)
FLIGHTGROUP Dead / OnAfterDead(...)
OPSGROUP / FLIGHTGROUP Despawn(...)

AUFTRAG:NewORBIT_RACETRACK(...)
AUFTRAG:NewAWACS(...)
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

COORDINATE:NewFromLLDD(...)
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)
COORDINATE:GetLLDDM(...)

SCHEDULER:New(...)
UTILS.SecondsOfToday()
```

`FLIGHTGROUP:Refuel(...)` pausiert den bestehenden Missionspfad und verwendet den DCS-Refuelling-Task. Dieser Task wählt den nächstgelegenen kompatiblen Tanker; MOOSE stellt in diesem Pfad keinen Parameter bereit, um direkt eine konkrete Tanker-Gruppen-ID an den DCS-Refuelling-Task zu übergeben.

Deshalb verwendet OMW für die Acceptance einen getrennten Rendezvouspunkt und prüft unmittelbar vor dem Refuel-Task:

```text
FLIGHTGROUP:FindNearestTanker(radius)
-> returned group name must equal designated LISA group
-> only then FLIGHTGROUP:Refuel(rendezvous)
```

Das ist eine kleine Koordinationsschicht um vorhandene MOOSE-Funktionalität, kein eigener Refuelling-Task.

## 4. Warum nicht die MOOSE-Klasse `AWACS`

Die MOOSE-`AWACS`-Klasse ist im gepinnten Stand ein vollständiger Air-Controller mit FEZ, Fighter-Control, SRS/TTS, Shift-Change und Home-Airbase-Annahmen. OMW benötigt für diesen Scope nur den physischen E-3-Lifecycle und den nativen DCS-AWACS-Task.

Daher bleibt der MOOSE-first-Pfad:

```text
SPAWN
+ FLIGHTGROUP
+ AUFTRAG:NewORBIT_RACETRACK
+ AUFTRAG:NewAWACS
+ FLIGHTGROUP:Refuel
+ CampaignState adapter
```

## 5. Verbindliche OMW-Konfiguration für Acceptance 2

```text
Template:                 OMW_C2_E3A_WIZARD
Strategic source:         OFFMAP_AL_DHAFRA
Campaign resource:        AIRCRAFT_E3A_AWACS
External spawn:           N31°30'42.29" E069°13'47.32" approximately
FIR ingress/egress:       ROSIE
Primary AEW area:         APOC
Callsign:                 WIZARD
Frequency:                357.300 MHz AM

Spawn / ROSIE inbound:    FL340
ROSIE -> late approach:   FL350
Transfer speed:           300 kt
Late approach:            30 NM
Track altitude:           FL320
Track speed:              300 kt
Track heading:            017T
Track leg:                30 NM
Outbound transfer:        FL340 / 300 kt

AWACS service start:      15:30 local / 1100Z
Planned AAR departure:    19:30 local / 1500Z
AWACS service end:        23:30 local / 1900Z
Service window:           8 h
```

Vor 15:30 wird auf demselben APOC-Racetrack `AUFTRAG:NewORBIT_RACETRACK(...)` ohne AWACS-Task verwendet. Um 15:30 wird der Standby-Task beendet und `AUFTRAG:NewAWACS(...)` gesetzt. Während des AAR-Unterbruchs ist der AWACS-Task nicht aktiv. Nach Rückkehr wird er erneut gesetzt. Um 23:30 wird er beendet und der physische Rückflug sofort eingeleitet.

## 6. Transferprofil bei AAR

Der AAR-Unterbruch darf nicht mit Trackhöhe über die Karte geflogen werden:

```text
APOC FL320 / 300 kt
-> AWACS task off
-> climb / transfer FL340 / 300 kt
-> 30-NM AAR late approach
-> designated tanker / refuel
-> FL340 / 300 kt return transfer
-> 30-NM APOC late approach
-> AWACS task on
-> APOC FL320 / 300 kt
```

Damit bleibt die in Acceptance 1 bestätigte Trennung zwischen Einsatz- und Reiseprofil erhalten.

## 7. Designierter Reserve-Tanker für Acceptance 2

Acceptance 2 verwendet die vorhandene LISA-Grundlage:

```text
Template:                 OMW_AAR_KC135_LISA
Callsign:                 Texaco 3-1
Strategic source:         OFFMAP_AL_UDEID
FIR fix:                  DAVER
Availability:             RESERVE
Profile:                  FAST
Rendezvous:               N33.6233926368 E068.6395554105
Rendezvous relation:      approximately 60 NM / 340T from APOC
Tanker orbit:             FL250 / 300 kt / 340T / 20 NM
Dispatch:                 18:10 local
Expected ready:           approximately 19:20 local
WIZARD AAR departure:     19:30 local
```

Der Acceptance-Harness verwendet für den LISA-Lifecycle den bereits laufenden AAR-`StrategicAdapter`; `CampaignState` bleibt damit die einzige Ressourcenautorität. Die physische LISA-Koordination des Acceptance-Harness ist test-only und wird erst nach erfolgreichem DCS-Lauf für eine Produktionsintegration bewertet.

## 8. Fuel-Grenze

Das Mission-Editor-Template enthält 65.000 kg E-3-Fuel. OMW verwendet keine erfundene `SPAWN:InitFuel(...)`-API. Der nahezu volle Spawnzustand wird für Acceptance 2 als Ergebnis eines nicht dargestellten off-map Top-off/AAR interpretiert.

Acceptance 2 misst den realen DCS-Verbrauch über den vollständigen sichtbaren Einsatz. Erst danach werden produktive FuelLow-/AAR-Schwellen festgelegt.

## 9. Acceptance 1 – Routing-Lifecycle PASS

```text
Test date:                2026-08-23
Branch:                   agent/awacs-external-lifecycle-foundation
Tested source commit:     bde8a6e8d006b7c8d744b739510b08aa9812d48b
Mission:                  OMW_Template_v19(8).miz
Mission SHA-256:          d788af36535d3acd1866d15ffb5d354b2c44b5f8ee40d4baf6fd1d97b7c0f8a5
DCS:                      2.9.28.26385 MT
Embedded Moose.lua SHA:   e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Embedded Warehouse SHA:   01a9ca70988198ecbd76f4d1cab4304261f2cc56911584b44741c0d49c7b146c
Embedded AWACS bundle SHA:639841a552343f4d0f7180f657a4a0b3141fb0b9af3ed6f1d9915ec955444fc2
dcs.log SHA-256:          593d02d455db0cae04cfd0e7651671d3af1d76ab430ff3232da7b19dac391c2f
debrief.log SHA-256:      32df4af4943f5ca3d2a98dde61e452054b5183fd21fa9f6b78750894ec106eb7
Result:                    PASS for routing lifecycle scope
```

Validated runtime sequence:

```text
MATERIALIZED
-> FIR_INGRESS_PASSED ROSIE
-> LATE_APPROACH_PASSED / ADD_AWACS_MISSION
-> ON_STATION APOC
-> EGRESS_ORDERED
-> FIR_EGRESS_PASSED ROSIE
-> MOOSE Mission [AWACS] success
-> EXTERNAL_HANDOFF / DESPAWN_AND_RECREDIT
```

Vollständige Acceptance-1-Evidenz:

- [`AWACS External Lifecycle Acceptance`](../../mission/tests/awacs-external-lifecycle/ACCEPTANCE.md)

## 10. Acceptance 2 – DCS pending

Acceptance 2 soll in **einem vollständigen Lauf** prüfen:

```text
pre-service arrival / standby
15:30 exact AWACS activation
full eight-hour service clock
cruise / track / AAR transfer profiles
APOC racetrack geometry
visible designated LISA AAR
AAR service interruption and restoration
complete fuel telemetry
23:30 immediate service closure / departure
ROSIE outbound
AWACS and tanker external handoffs
player-side WIZARD radio behavior
```

Bis zu diesem Lauf bleiben `FindNearestTanker(...)`, der E-3-`Refuel(...)`-Pfad, die zeitgesteuerte Serviceumschaltung und die vollständige LISA-AAR-Koordination für AWACS **SOURCE_REVIEWED / DCS_PENDING**.
