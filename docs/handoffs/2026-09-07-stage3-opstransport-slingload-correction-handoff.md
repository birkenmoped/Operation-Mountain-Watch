---
document_id: OMW-HANDOFF-STAGE3-OPSTRANSPORT-SLINGLOAD-CORRECTION-2026-09-07
status: PLANNED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
authoritative_for:
  - branch-local continuation after rejection of the reintroduced NewCARGOTRANSPORT slingload path
  - next permitted Stage 3 CH-47 Air-AMMO implementation sequence
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
---

# Stage 3 – aktuelle Übergabe nach OPSTRANSPORT-/Slingload-Korrekturentscheidung

## 1. Sofort maßgebliche Owner-Entscheidung

Für die weitere Stage-3-CH-47-Air-AMMO-Arbeit gilt ab jetzt auf diesem Branch:

```text
CURRENT TARGET:
MOOSE OPSTRANSPORT
+ FLIGHTGROUP helicopter carrier
+ FLIGHTGROUP:AddOpsTransport()
+ OPSTRANSPORT:AddPathTransport()
+ external physical slingload representation
```

Explizit verworfen:

```text
AUFTRAG:NewCARGOTRANSPORT()
PauseMission()/TaskDone() route handoff
re-issued CargoTransportation waypoint task
continuation of the old OMW_SlingloadCorridorHandoff lifecycle bridge
```

Vollständiger Entscheidungsnachweis:

```text
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
```

## 2. Anlass

Der Assistent hat gegen die vorherige Übergabe verstoßen und den bereits verworfenen `AUFTRAG:NewCARGOTRANSPORT()`-/PauseMission-/CargoTransportation-Handoff erneut als aktiven Zielpfad verwendet.

Das führte zu einem unnötigen weiteren DCS-Lauf am 07.09.2026.

Der Fehler ist ausdrücklich als Assistentenfehler zu behandeln, nicht als neue Projektentscheidung des Owners.

## 3. Reale DCS-Beobachtung vom 07.09.2026

Der aktuelle Fehltest zeigte:

```text
external slingload pickup: observed
configured outbound FlightPath: observed
Wright physical delivery: not completed
mission lifecycle ended/cancelled before confirmed physical delivery
configured reverse FlightPath: not completed
AIRWING return path took over
```

Dieser Lauf testete die inzwischen erneut verworfene Altarchitektur und darf nicht als Validierung der aktuellen OPSTRANSPORT-Zielarchitektur bezeichnet werden.

```text
validated_in_dcs: false
legacy path result: FAIL
current target architecture tested: NO
```

## 4. Relevante offizielle MOOSE-Referenz

Vor weiterer Implementierung ist ausdrücklich diese offizielle MOOSE-Demo zu prüfen:

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

Zusätzlich ist der gepinnte MOOSE-Source maßgeblich:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 5. Was aus dem internen OPSTRANSPORT-Test übernommen wird

Der interne OPSTRANSPORT-Test bleibt wichtig, weil er bereits gezeigt hat, dass der MOOSE-Transport-FSM den vollständigen Carrier-/Transport-Lifecycle sauber führen kann.

Die weitere Arbeit darf daher nicht den Lifecycle austauschen, nur weil die physische Darstellung von interner Fracht auf extern sichtbare Slingload-Fracht geändert werden soll.

```text
KEEP:
OPSTRANSPORT lifecycle
carrier binding
MOOSE transport FSM
Delivered lifecycle

CHANGE/INVESTIGATE:
physical external slingload representation within that lifecycle
configured FlightPath integration through verified AddPathTransport semantics
```

## 6. Aktuell als historisch/verworfener Pfad zu behandeln

Die folgenden aktuellen Branch-Dateien enthalten oder unterstützen den alten Handoff und sind vor dem nächsten DCS-Test zu reconciliieren:

```text
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
mission/tests/air-ammo-resupply/src/02-air-ammo-r500-slingload-handoff-acceptance.lua
tools/build-air-ammo-r500-slingload-handoff-acceptance-1.ps1
tools/verify-air-ammo-r500-slingload-handoff-miz.ps1
```

Sie dürfen bis zur Reconciliation nicht als aktuelle Zielarchitektur interpretiert werden.

Der historische Dateiname `R500` ist außerdem fachlich irreführend, weil die konfigurierte Route gemäß aktuellem Naming-Contract logisch `OMW_FlightPath` heißt und die konkrete `_Rnnn/_Lnnn`-Variante aus der Mission stammt.

## 7. FlightPath-Vertrag bleibt bestehen

Unabhängig vom Transport-Lifecycle bleibt die bereits bestätigte Naming-Regel erhalten:

```text
logical route identity: OMW_FlightPath
concrete ME variants: OMW_FlightPath / OMW_FlightPath_Rnnn / OMW_FlightPath_Lnnn
no hard-coded R500 requirement
0 matches -> explicit failure
>1 matches -> explicit ambiguity failure
```

Der zuletzt verwendete Missionsstand registrierte real `OMW_FlightPath_R200`; daraus darf keine neue harte R200-Vorgabe werden.

## 8. Nächste erlaubte Arbeitsreihenfolge

Vor weiterer Runtime-Implementierung:

```text
1. Governance/current decision record verify
2. Pinned MOOSE documentation inspect
3. Pinned Moose.lua inspect
4. Official Transport 051 demo inspect
5. Verify exact AddOpsTransport() semantics/signature
6. Verify exact AddPathTransport() semantics/signature
7. Determine how external slingload is represented with OPSTRANSPORT in the verified MOOSE path
8. Reconcile current Stage 3 source/build/test files away from NewCARGOTRANSPORT
9. Add offline/static regressions that reject reintroduction of the old path
10. Full diff / syntax / documentation review
11. Remote commit
12. Local pull/build/hash/static preflight
13. Only after real preflight PASS: request a new DCS test
```

## 9. Explicit no-test gate

Bis die Punkte 1 bis 10 abgeschlossen sind, gilt:

```text
DO NOT REQUEST ANOTHER DCS TEST
```

Insbesondere darf kein weiterer Test auf Basis von `AUFTRAG:NewCARGOTRANSPORT()`, `PauseMission()` oder einem re-injizierten `CargoTransportation`-Task angefordert werden.

## 10. Status

```text
owner decision documented: YES
legacy NewCARGOTRANSPORT path current: NO
OPSTRANSPORT target current: YES
external slingload representation under OPSTRANSPORT proven in current OMW code: NO
next step: MOOSE source + official demo reconciliation
DCS retest authorized: NO
production validation: NO
```
