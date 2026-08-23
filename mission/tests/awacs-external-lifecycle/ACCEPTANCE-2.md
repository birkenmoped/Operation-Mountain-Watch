---
document_id: OMW-AWACS-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - full-duration AWACS flight-profile and service-window acceptance
  - visible designated reserve-tanker AAR acceptance
  - full-sortie fuel and racetrack telemetry acceptance
  - manual player-side WIZARD radio-service checks
not_authoritative_for:
  - production promotion of the test-only reserve-tanker coordinator before DCS acceptance
  - loss and restart reconciliation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# AWACS Acceptance 2 – vollständiger Dienst, sichtbare AAR und Flugprofil

## 1. Zweck

Acceptance 1 hat den grundlegenden physischen Routing-Lifecycle bestätigt:

```text
External Spawn
-> ROSIE inbound
-> APOC
-> controlled egress
-> ROSIE outbound
-> External Handoff
```

Acceptance 2 ist bewusst **kein weiterer Kurztest**. Es wird ein vollständiger WIZARD-Einsatz über das geplante historische Abdeckungsfenster geflogen und beobachtet:

```text
Mission start before service window
-> WIZARD external materialization
-> ROSIE
-> APOC standby orbit
-> 15:30 local / 1100Z: AWACS service ACTIVE
-> four hours coverage
-> designated LISA reserve tanker arrives near APOC
-> WIZARD leaves APOC on transfer profile
-> visible AAR
-> WIZARD returns on transfer profile
-> APOC AWACS service ACTIVE again
-> 23:30 local / 1900Z: AWACS service CLOSED
-> immediate transfer profile / ROSIE
-> external handoff / despawn / strategic recredit
```

## 2. Zeitmodell

Afghanistan Time ist UTC+04:30. Das für OMW verwendete WIZARD-Abdeckungsfenster lautet:

```text
1100Z = 15:30 local
1900Z = 23:30 local
Coverage duration = 8 h / 28,800 s
```

Für den Acceptance-Lauf wird die Missionsstartzeit auf **15:05 local** gesetzt. Der bisherige Stand der bereitgestellten `OMW_Template_v19(9).miz` war 15:25 local (`start_time = 55500`) und ist für einen extern materialisierten E-3 mit rund 76 NM sichtbarem Ingress zu spät.

Ziel des neuen Starts:

```text
15:05  mission start / WIZARD materialization
~15:20-15:25  APOC physical arrival expected
15:30  AWACS service enabled exactly by mission clock
```

Die reale Ankunftszeit wird nicht aus der Planung als PASS übernommen. Maßgeblich ist die DCS-Evidenz.

## 3. AWACS-Flugprofil

```text
External spawn -> ROSIE:
FL340 / transfer speed 300 kt after initial stabilization

ROSIE -> late approach:
FL350 / 300 kt

APOC:
FL320 / 300 kt / 017T / 30 NM racetrack

APOC -> AAR rendezvous:
leave AWACS mission
return to transfer profile FL340 / 300 kt

AAR rendezvous:
receiver joins designated tanker through MOOSE FLIGHTGROUP:Refuel(...)

AAR rendezvous -> APOC:
FL340 / 300 kt transfer
30 NM late approach
then re-establish FL320 / 300 kt AWACS racetrack

23:30 service end -> ROSIE:
immediate track departure
FL340 / 300 kt
```

Damit wird die bereits in Acceptance 1 funktionierende Trennung zwischen Track- und Transferprofil auch für den AAR-Unterbruch beibehalten.

## 4. Service-State

Physische Präsenz und AWACS-Dienst sind getrennt:

```text
INBOUND
STANDBY
ACTIVE
INTERRUPTED_AAR
REJOINING
ACTIVE
CLOSED
```

Vor 15:30 darf WIZARD physisch auf APOC kreisen, aber der DCS-AWACS-Task ist noch nicht aktiv. Um 15:30 ersetzt der Controller den Standby-Racetrack durch `AUFTRAG:NewAWACS(...)`. Während des AAR-Unterbruchs ist der AWACS-Task aufgehoben. Nach Rückkehr auf APOC wird er erneut gesetzt. Um 23:30 wird er endgültig beendet und der Rückflug eingeleitet.

## 5. MOOSE-first AAR-Grenze

Der tatsächlich gepinnte MOOSE-Stand bietet:

```text
FLIGHTGROUP:FindNearestTanker(...)
FLIGHTGROUP:Refuel(Coordinate)
FLIGHTGROUP OnAfterRefueled
AUFTRAG:NewTANKER(...)
AUFTRAG:NewAWACS(...)
AUFTRAG:NewORBIT_RACETRACK(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:AddMission(...)
SCHEDULER:New(...)
```

`FLIGHTGROUP:Refuel(...)` verwendet den DCS-Refuelling-Task zum **nächstgelegenen kompatiblen Tanker**. Deshalb behauptet OMW keine nicht vorhandene MOOSE-Schnittstelle zur direkten Tanker-ID-Auswahl. Stattdessen wird der gewünschte Reserve-Tanker an ein getrenntes Rendezvous gebracht und unmittelbar vor dem Refuel-Task mit `FindNearestTanker(...)` verifiziert. Nur wenn der gefundene Tanker exakt der designierte LISA-Verband ist, wird der Refuel-Task ausgelöst.

## 6. Designierter Reserve-Tanker

Für den Acceptance-Lauf wird die vorhandene LISA-Grundlage verwendet:

```text
Template: OMW_AAR_KC135_LISA
Callsign: Texaco 3-1
Strategic source: OFFMAP_AL_UDEID
FIR ingress/egress: DAVER
Availability class: RESERVE
Receiver profile: FAST / boom
```

Der Testkoordinator verwendet den **bereits laufenden AAR-CampaignState-Adapter** für `CanMaterialize`, `OnMaterialized`, `OnHandoff` und `OnLost`. Es entsteht keine zweite Ressourcenhoheit.

Der Testkoordinator ist noch keine produktive Erweiterung des AAR-Dispatchers. Er dient dazu, den vollständigen MOOSE/DCS-Pfad erst praktisch zu bestätigen.

## 7. AAR-Rendezvous und Tanker-Timing

Rendezvous:

```text
approximately 60 NM from APOC on bearing 340T
N33.6233926368 E068.6395554105
Tanker orbit: FL250 / 300 kt / 340T / 20 NM leg
```

Die Lage hält den Tanker vom APOC-Racetrack getrennt und vergrößert den Abstand zum nächstgelegenen Standardtanker KRUSTY. Die tatsächliche `FindNearestTanker`-Auflösung wird dennoch im DCS-Test geprüft und nicht vorausgesetzt.

Geometrische Planung LISA:

```text
Al Udeid external -> DAVER: ~40.3 NM
DAVER -> AWACS AAR rendezvous: ~316.6 NM
Total visible route: ~356.9 NM
Nominal transfer at 300 kt: ~71.4 min
```

Tankerplanung:

```text
18:10 local  LISA materialization / dispatch
~19:20 local expected rendezvous arrival
19:30 local  WIZARD planned AAR departure from APOC
```

Damit wartet der Reserve-Tanker nur kurz am Rendezvous, anstatt bereits seit 15:30 mehrere Stunden Kraftstoff zu verbrauchen.

## 8. Fuel-Modell für diesen Test

Das E-3-Mission-Editor-Template enthält 65,000 kg internen Kraftstoff. Acceptance 2 setzt **keine künstliche Spawn-Fuel-API** voraus. Der nahezu volle Spawnzustand wird als Abstraktion eines vorgelagerten, off-map erfolgten Top-off/AAR interpretiert.

Der vollständige Lauf misst den tatsächlichen DCS-Verbrauch über:

```text
spawn
ROSIE inbound
APOC standby
15:30 service start
pre-AAR station
AAR departure
pre-contact / post-contact
APOC return
service end
ROSIE outbound
external handoff
```

Erst diese Daten entscheiden, ob der angenommene eine sichtbare Mid-mission-AAR für die spätere Produktionsbaseline ausreicht.

## 9. Testartefakte und Ladefolge

```text
1. Moose.lua
2. OMW_AirOps_Warehouse_Base.lua
3. OMW_AAR_Base.lua
4. OMW_AWACS_Foundation.lua
5. OMW_AWACS_Acceptance_2.lua
```

Der frühere Acceptance-1-Trigger `RequestEgress("ACCEPTANCE_1_ROUTING_EGRESS")` darf in dieser Testmission nicht aktiv sein.

Source:

```text
mission/tests/awacs-external-lifecycle/src/02-awacs-flight-profile-acceptance.lua
```

Builder:

```text
tools/build-awacs-acceptance-2.ps1
```

Generated bundle:

```text
mission/tests/awacs-external-lifecycle/dist/OMW_AWACS_Acceptance_2.lua
```

## 10. Automatische Evidenz

AWACS-Telemetrie wird einmal pro Minute protokolliert:

```text
mission clock
service state
AAR phase
altitude ft
speed kt
heading deg
fuel percent
fuel kg
max internal fuel kg
geodetic latitude / longitude via COORDINATE:GetLLDDM()
```

Wichtige Marker:

```text
[OMW][AWACS.Controller] SERVICE_STANDBY
[OMW][AWACS.Controller] SERVICE_ACTIVE
[OMW][AWACS.Controller] AAR_TRANSFER_STARTED
[OMW][AWACS.Controller] AAR_REFUEL_TASK
[OMW][AWACS.Controller] AAR_REFUELED
[OMW][AWACS.Controller] AAR_RETURN_TRANSFER
[OMW][AWACS.Controller] AAR_RETURN_ON_STATION
[OMW][AWACS.Controller] SERVICE_CLOSED
[OMW][AWACS.Controller] FIR_EGRESS_PASSED
[OMW][AWACS.Controller] EXTERNAL_HANDOFF

[OMW][AWACS.Acceptance2] TANKER_DISPATCHED
[OMW][AWACS.Acceptance2] TANKER_FIR_INGRESS
[OMW][AWACS.Acceptance2] TANKER_READY
[OMW][AWACS.Acceptance2] AWACS_AAR_REQUESTED
[OMW][AWACS.Acceptance2] AWACS_AAR_COMPLETED
[OMW][AWACS.Acceptance2] TANKER_EGRESS_ORDERED
[OMW][AWACS.Acceptance2] TANKER_EXTERNAL_HANDOFF
[OMW][AWACS.Acceptance2] AUTOMATED_CAPTURE_COMPLETE
```

## 11. Manuelle Radio-Beobachtung

Der Projektinhaber prüft mit einem geeigneten Client:

```text
before 15:30: WIZARD service not available
15:30 onward: WIZARD / 357.300 MHz AM available
before AAR: normal AWACS response
while AWACS task is interrupted for AAR: no operational WIZARD service expected
on APOC return: WIZARD service available again
from 23:30: WIZARD service closed
```

Diese Spielerinteraktion kann nicht aus internen Controllerzuständen als bestanden abgeleitet werden.

## 12. PASS-Grenze

Acceptance 2 kann für den exakt dokumentierten Branch-/Commit-/MIZ-/Bundle-/DCS-/MOOSE-Stand bestätigen:

```text
pre-service physical arrival / standby
exact 15:30 service activation
8-hour service-window clock
physical transfer and track profiles
APOC racetrack geometry
visible designated LISA AAR
return to APOC after AAR
actual DCS fuel burn across the complete sortie
native WIZARD radio service behavior
exact 23:30 service closure
immediate return transfer
ROSIE outbound / external handoff
LISA strategic settlement
```

Weiterhin getrennt offen bleiben insbesondere:

```text
AWACS loss settlement under actual aircraft destruction
restart reconciliation with unresolved AWACS/AAR commitments
production promotion of the dedicated AWACS AAR demand orchestration
```
