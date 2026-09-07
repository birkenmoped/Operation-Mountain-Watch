---
document_id: OMW-MOOSE-STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION
status: PLANNED
document_class: OWNER_DECISION_RECORD
authoritative_for:
  - branch-local Stage 3 CH-47 Air-AMMO transport architecture
  - rejection of the legacy AUFTRAG NewCARGOTRANSPORT handoff path
  - required MOOSE-first transport lifecycle for external slingload work
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
  - branch-local use of AUFTRAG:NewCARGOTRANSPORT for the current Stage 3 Air-AMMO target path
  - branch-local PauseMission/TaskDone/CargoTransportation route handoff architecture
superseded_by:
---

# Stage 3 – OPSTRANSPORT / Slingload Architekturentscheidung

## 1. Zweck

Dieses Dokument hält die ausdrückliche Entscheidung des Projektinhabers für den aktuellen Stage-3-CH-47-Air-AMMO-Pfad fest und verhindert, dass eine bereits verworfene Zwischenarchitektur erneut als aktueller Zielpfad verwendet wird.

Diese Entscheidung ist auf dem Arbeitsbranch unmittelbar anzuwenden. Repository-weite normative Wirkung entsteht gemäß `docs/00-project-governance.md` erst durch Merge nach `main` oder eine entsprechende Entscheidung auf `main`.

## 2. Verbindliche aktuelle Entscheidung

Für den aktuellen Stage-3-Air-AMMO-Transport gilt:

```text
Transport lifecycle: MOOSE OPSTRANSPORT
Carrier: MOOSE FLIGHTGROUP helicopter carrier
Carrier binding: FLIGHTGROUP:AddOpsTransport()
Transport path: OPSTRANSPORT:AddPathTransport()
Physical representation target: external slingload
Strategic authority: CampaignState
Physical runtime/lifecycle authority: MOOSE
```

Die Art der physischen Frachtrepresentation darf den Transport-Lifecycle nicht erneut auf einen anderen MOOSE-Missionstyp umstellen.

Insbesondere gilt:

```text
physical representation changes
!=
transport lifecycle changes
```

Der bereits funktionierende OPSTRANSPORT-Lifecycle bleibt deshalb die Grundlage. Die noch zu lösende Aufgabe besteht darin, die gewünschte sichtbare externe Slingload-Repräsentation in diesen MOOSE-Transportpfad einzubinden, nicht darin, OPSTRANSPORT durch einen anderen Missionsmechanismus zu ersetzen.

## 3. Explizit verworfener Altpfad

Der folgende Pfad ist **nicht mehr die aktuelle Architektur** und darf nicht weiter repariert, erweitert oder als Ziel-Implementation verwendet werden:

```text
AUFTRAG:NewCARGOTRANSPORT()
-> physical pickup
-> PauseMission()
-> TaskDone()
-> manual/public FLIGHTGROUP route handoff
-> re-issued DCS CargoTransportation waypoint task
-> AUFTRAG:Success()
```

Daraus folgen konkrete Verbote für den aktuellen Stage-3-Zielpfad:

```text
NO AUFTRAG:NewCARGOTRANSPORT()
NO PauseMission()/TaskDone() handoff
NO re-injected CargoTransportation waypoint task as route/lifecycle bridge
NO continuation of OMW_SlingloadCorridorHandoff as the active target architecture
```

Historische Tests und Dateien dürfen als Fehler-/Entwicklungsnachweis erhalten bleiben, dürfen aber nicht als aktuelle Architektur interpretiert werden.

## 4. Maßgebliche MOOSE-Richtung

Die relevante offizielle MOOSE-Demo ist:

```text
Ops/Transport/Transport - 051 - COMBINED By All Means/
Transport - 051 - COMBINED By All Means.lua
```

Sie ist für die weitere Umsetzung ausdrücklich als Referenz zu prüfen und bestätigt die Richtung:

```text
OPSTRANSPORT
FLIGHTGROUP helicopter carrier
AddOpsTransport()
AddPathTransport()
```

Gemäß `docs/26-moose-first-development-policy.md` ist vor weiterer eigener Lua-Logik zusätzlich der tatsächlich gepinnte MOOSE-Source zu prüfen. Dokumentation oder Demo allein beweisen keine Verfügbarkeit oder identische Signatur im verwendeten Stand.

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 5. Warum der interne OPSTRANSPORT-Test relevant bleibt

Der zuvor erfolgreiche interne Transporttest war nicht deshalb erfolgreich, weil interne Fracht grundsätzlich andere Routing-Eigenschaften besitzen muss, sondern weil dort der korrekte MOOSE-Transport-Lifecycle erhalten blieb:

```text
OPSTRANSPORT owns transport lifecycle
-> carrier remains attached to OPSTRANSPORT
-> MOOSE loading/transport/unloading/delivery lifecycle remains intact
-> Delivered is reached by the transport FSM
```

Die gewünschte externe Slingload-Darstellung darf diesen funktionierenden Lifecycle nicht erneut durch `AUFTRAG:NewCARGOTRANSPORT()` ersetzen.

## 6. DCS-Lauf 07.09.2026 – Fehltest des verworfenen Altpfads

Der DCS-Lauf vom 07.09.2026 mit dem erneut eingeführten `AUFTRAG:NewCARGOTRANSPORT()`-/PauseMission-Handoff ist **kein Test der aktuellen Zielarchitektur**.

Beobachtet wurde:

```text
CH-47 external slingload pickup: observed
configured outbound FlightPath: observed
physical Wright delivery: not completed
mission lifecycle ended/cancelled before confirmed delivery
return route contract: not completed
AIRWING return took over
```

Dieser Lauf dokumentiert das Scheitern der erneut verwendeten Altarchitektur. Er ist nicht als Argument zu verwenden, diesen Handoff weiter zu patchen.

Status:

```text
legacy NewCARGOTRANSPORT handoff: REJECTED_CURRENT_ARCHITECTURE
current OPSTRANSPORT external-slingload target: NOT_YET_DCS_VALIDATED
```

## 7. Dokumentierter Regelverstoß des Assistenten

Der Assistent hat entgegen der bereits vorhandenen Übergabeentscheidung den verworfenen Altpfad erneut verwendet und weiterentwickelt.

Konkret wurden folgende bereits ausgeschlossene Elemente erneut eingeführt beziehungsweise als aktiver Zielpfad behandelt:

```text
AUFTRAG:NewCARGOTRANSPORT()
PauseMission()
TaskDone()
re-issued CargoTransportation task
OMW_SlingloadCorridorHandoff as current target path
```

Das war kein Owner-Entscheid und kein neuer Architekturentscheid, sondern ein Implementierungs- und Übergabeverstoß des Assistenten.

Dieser Fehler darf nicht als Projektentscheidung, genehmigte Ausnahme oder MOOSE-first-Abweichung fortgeschrieben werden.

## 8. Pflicht für die nächste Implementierung

Vor neuer Implementierung ist in dieser Reihenfolge zu arbeiten:

```text
1. Current governance and this decision record
2. Pinned MOOSE documentation
3. Pinned Moose.lua source
4. Official Transport 051 demo
5. OPSTRANSPORT lifecycle and FLIGHTGROUP carrier binding
6. AddOpsTransport() behavior/signature
7. AddPathTransport() behavior/signature
8. Determine supported physical external-slingload representation within this lifecycle
9. Only if a verified gap remains: document smallest adapter
10. Obtain owner approval before any new non-MOOSE/native-DCS exception
```

Es darf **kein weiterer DCS-Test** auf Basis des verworfenen `NewCARGOTRANSPORT`-/PauseMission-Handoffs angefordert werden.

## 9. Zielbild

Aktuelles Zielbild:

```text
CampaignState Air-AMMO demand/reservation
-> Jalalabad CH-47 physical asset
-> MOOSE OPSTRANSPORT
-> FLIGHTGROUP:AddOpsTransport()
-> OPSTRANSPORT:AddPathTransport(configured FlightPath)
-> external physical slingload representation
-> Wright physical delivery
-> OPSTRANSPORT Delivered
-> configured reverse/recovery path as supported by the verified MOOSE design
-> Jalalabad landing
-> AIRWING/LEGION recovery
-> idempotent CampaignState settlement
```

Noch nicht behauptet werden darf:

```text
external slingload under OPSTRANSPORT is already implemented: NO
external slingload under OPSTRANSPORT is DCS validated: NO
exact AddPathTransport integration for the current pinned MOOSE stand is proven: PENDING_SOURCE_AND_DEMO_REVIEW
```

## 10. Acceptance-Grenze

Vor dem nächsten DCS-Lauf müssen mindestens statisch/offline nachgewiesen sein:

```text
no active Stage 3 target code calls AUFTRAG:NewCARGOTRANSPORT()
no active Stage 3 target code uses PauseMission/TaskDone as slingload route handoff
no active Stage 3 target code re-injects CargoTransportation as lifecycle bridge
OPSTRANSPORT carrier binding uses verified public MOOSE API
AddPathTransport use matches pinned MOOSE source and official demo semantics
configured FlightPath selection remains logical-name based, not hard-coded to R500
```

Erst danach darf ein neuer DCS-Lauf geplant werden.
