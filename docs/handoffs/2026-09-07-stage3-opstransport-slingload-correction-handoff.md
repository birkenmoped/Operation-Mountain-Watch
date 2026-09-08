---
document_id: OMW-HANDOFF-STAGE3-OPSTRANSPORT-SLINGLOAD-CORRECTION-2026-09-07
status: SUPERSEDED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - historical branch-local continuation after rejection of the reintroduced NewCARGOTRANSPORT slingload path
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
pull_request: 144
supersedes:
  - branch-local continuation instructions that treat AUFTRAG:NewCARGOTRANSPORT()/PauseMission/CargoTransportation as the current Stage 3 target architecture
superseded_by:
  - OMW-MOOSE-STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION
---

# Stage 3 – historische Übergabe nach OPSTRANSPORT-/Slingload-Korrekturentscheidung

> **SUPERSEDED:** Seit der Owner-Entscheidung vom 08.09.2026 ist externe Slingload-Entwicklung bis auf Weiteres gestoppt. Aktueller Zielpfad ist CH-47 + MOOSE OPSTRANSPORT + interne STORAGE-Fracht + konfigurierte FlightPath-Hin-/Rückroute. Maßgeblich ist `docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md`.

## 1. Damalige Owner-Entscheidung

Für die damalige Stage-3-CH-47-Air-AMMO-Arbeit galt auf diesem Branch:

```text
MOOSE OPSTRANSPORT
+ FLIGHTGROUP helicopter carrier
+ FLIGHTGROUP:AddOpsTransport()
+ OPSTRANSPORT:AddPathTransport()
+ external physical slingload representation as then-intended target
```

Explizit verworfen war bereits:

```text
AUFTRAG:NewCARGOTRANSPORT()
PauseMission()/TaskDone() route handoff
re-issued CargoTransportation waypoint task
continuation of the old OMW_SlingloadCorridorHandoff lifecycle bridge
```

## 2. Anlass

Der Assistent hatte gegen die vorherige Übergabe verstoßen und den bereits verworfenen `AUFTRAG:NewCARGOTRANSPORT()`-/PauseMission-/CargoTransportation-Handoff erneut als aktiven Zielpfad verwendet.

Das führte zu einem unnötigen weiteren DCS-Lauf am 07.09.2026. Der Fehler ist als Assistentenfehler zu behandeln, nicht als Projektentscheidung des Owners.

## 3. Reale DCS-Beobachtung vom 07.09.2026

Der Fehltest zeigte:

```text
external slingload pickup: observed
configured outbound FlightPath: observed
Wright physical delivery: not completed
mission lifecycle ended/cancelled before confirmed physical delivery
configured reverse FlightPath: not completed
AIRWING return path took over
```

Dieser Lauf testete die inzwischen verworfene Altarchitektur und darf nicht als Validierung der aktuellen OPSTRANSPORT-Zielarchitektur bezeichnet werden.

```text
validated_in_dcs: false
legacy path result: FAIL
current internal OPSTRANSPORT target tested by this run: NO
```

## 4. Relevante offizielle MOOSE-Referenz

Geprüfte MOOSE-Demo:

```text
Ops/Transport/Transport - 051 - COMBINED By All Means/
Transport - 051 - COMBINED By All Means.lua
```

Relevante Richtung:

```text
OPSTRANSPORT
FLIGHTGROUP helicopter carrier
AddOpsTransport()
AddPathTransport()
```

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 5. Historischer Erkenntnisstand

Der interne OPSTRANSPORT-Test hatte bereits gezeigt, dass der MOOSE-Transport-FSM den vollständigen Carrier-/Transport-Lifecycle sauber führen kann:

```text
KEEP:
OPSTRANSPORT lifecycle
carrier binding
MOOSE transport FSM
Delivered lifecycle
```

Die damals noch offene Slingload-Darstellung wird nach der späteren Owner-Entscheidung nicht weiterentwickelt.

## 6. Historische/verworfene Dateien

Die folgenden Dateien gehören zum gestoppten Slingload-Entwicklungspfad und dürfen nicht als aktuelle Zielarchitektur interpretiert werden:

```text
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
mission/tests/air-ammo-resupply/src/02-air-ammo-r500-slingload-handoff-acceptance.lua
tools/build-air-ammo-r500-slingload-handoff-acceptance-1.ps1
tools/verify-air-ammo-r500-slingload-handoff-miz.ps1
```

## 7. FlightPath-Vertrag bleibt gültig

```text
logical route identity: OMW_FlightPath
concrete ME variants: OMW_FlightPath / OMW_FlightPath_Rnnn / OMW_FlightPath_Lnnn
no hard-coded R500 requirement
0 matches -> explicit failure
>1 matches -> explicit ambiguity failure
```

Der damalige Missionsstand registrierte `OMW_FlightPath_R200`; daraus entsteht keine harte R200-Vorgabe.

## 8. Aktuelle Fortsetzung

Die weitere Arbeit erfolgt nicht aus diesem historischen Handoff, sondern gemäß:

```text
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
```

Aktueller Zielablauf:

```text
Jalalabad
-> CH-47 MOOSE OPSTRANSPORT internal STORAGE load
-> configured OMW_FlightPath outbound
-> Wright unload / OPSTRANSPORT Delivered
-> configured OMW_FlightPath reverse
-> Jalalabad landing
-> AIRWING/LEGION recovery
```
