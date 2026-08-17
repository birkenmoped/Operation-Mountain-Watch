---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-MISSION-LIFECYCLE-VERIFICATION
status: DRAFT
document_class: MOOSE_CAPABILITY_VERIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase-2 source review of MOOSE mission assignment and lifecycle for Air Tasking
  - branch-local FSM callback boundary between COMMANDER, LEGION, AUFTRAG, FLIGHTGROUP, and ARMYGROUP
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance outside previously documented exact acceptance scopes
  - final OMW status mapping before remaining Phase-2 adapter-boundary review
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Phase 2 – Mission Assignment / Lifecycle / FSM Verification

## 1. Zweck

Dieses Dokument prüft den nativen MOOSE-Lifecycle von der Missionszuweisung bis zu Completion/Failure/Cancellation am tatsächlich in der aktuellen Missionsdatei enthaltenen MOOSE-Stand.

Geprüfte Baseline:

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE context: develop
```

Die Prüfung ist Source-Verifikation. Sie erzeugt keinen neuen DCS-Acceptance-Status.

## 2. AUFTRAG-FSM

Am eingebetteten Quellstand ist die AUFTRAG-FSM source-geprüft.

Wesentliche Status-/Event-Übergänge:

```text
*         -> Planned   -> PLANNED
PLANNED   -> Queued    -> QUEUED
QUEUED    -> Requested -> REQUESTED
REQUESTED -> Scheduled -> SCHEDULED
PLANNED   -> Scheduled -> SCHEDULED
SCHEDULED -> Started   -> STARTED
STARTED   -> Executing -> EXECUTING
*         -> Done      -> DONE
*         -> Cancel    -> CANCELLED
*         -> Success   -> SUCCESS
*         -> Failed    -> FAILED
*         -> Repeat    -> PLANNED
```

Zusätzliche Ereignisse ohne Statuswechsel sind unter anderem:

```text
Status
Stop
ElementDestroyed
GroupDead
AssetDead
```

Wichtige Grenze:

```text
AUFTRAG.Status
!= OMW AIR_TASKING_MISSION.status
```

Die beiden Statusmodelle können korreliert werden, dürfen aber nicht stillschweigend gleichgesetzt werden. OMW benötigt weiterhin eigene persistente Request-/Mission-Zustände aus Phase 1.

## 3. COMMANDER Mission Assignment

Source-geprüft:

```text
COMMANDER:onafterMissionAssign(From, Event, To, Mission, Legions)
```

Der Callback führt nativ aus:

```text
COMMANDER:AddMission(Mission)
Mission.statusCommander = AUFTRAG.Status.QUEUED
for each Legion:
    Legion:AddMission(Mission)
    Legion:MissionRequest(Mission)
```

Die Quellkommentierung ist eindeutig: `MissionAssign` erwartet, dass die Assets bereits ausgewählt beziehungsweise der Mission hinzugefügt sind. Die eigentliche Asset-Rekrutierung wurde im vorherigen COMMANDER-Review separat source-geprüft.

Damit ist für OMW die native Kette bestätigt:

```text
OMW strategic reservation / approved tasking
        ↓
COMMANDER native recruitment / assignment path
        ↓
COMMANDER:MissionAssign(...)
        ↓
LEGION:AddMission(...)
        ↓
LEGION:MissionRequest(...)
```

OMW soll diesen Pfad nicht mit einer eigenen Mission-Queue-/Asset-Dispatcher-Engine ersetzen.

## 4. LEGION Runtime Dispatch

Source-geprüft ist der gemeinsame LEGION-Callback:

```text
LEGION:onafterOpsOnMission(From, Event, To, OpsGroup, Mission)
```

Er unterscheidet nativ:

```text
AIRWING -> FlightOnMission(OpsGroup, Mission)
BRIGADE -> ArmyOnMission(OpsGroup, Mission)
FLEET   -> NavyOnMission(OpsGroup, Mission)
```

Danach propagiert LEGION den generischen `OpsOnMission`-Event an vorhandene höhere Ebenen:

```text
CHIEF
COMMANDER
```

Für OMW ist damit der gewünschte Beobachtungspunkt ohne Parallelframework vorhanden:

```text
COMMANDER:OnAfterOpsOnMission(...)
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)
```

Diese Callbacks liefern jeweils das konkrete Runtime-`OPSGROUP` und den zugehörigen `AUFTRAG`.

## 5. AIRWING / BRIGADE Rückmeldung

Source-geprüfte events:

```text
AIRWING FlightOnMission
BRIGADE ArmyOnMission
```

Signatur der callbacks:

```text
AIRWING:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
BRIGADE:OnAfterArmyOnMission(From, Event, To, ArmyGroup, Mission)
```

Damit kann ein kleiner OMW-Adapter die physische Runtime-Repräsentation an einen bereits bekannten `mission_id`-/execution-attempt-Kontext korrelieren, ohne globale DCS-Gruppenscans oder eigene Assignment-Scheduler einzuführen.

## 6. AUFTRAG Status callbacks

Am eingebetteten Stand sind insbesondere vorhanden:

```text
AUFTRAG:OnAfterPlanned
AUFTRAG:OnAfterQueued
AUFTRAG:OnAfterRequested
AUFTRAG:OnAfterScheduled
AUFTRAG:OnAfterStarted
AUFTRAG:OnAfterExecuting
AUFTRAG:OnAfterCancel
AUFTRAG:OnAfterDone
AUFTRAG:OnAfterSuccess
AUFTRAG:OnAfterFailed
AUFTRAG:OnAfterRepeat
```

Interne Implementierungen setzen unter anderem:

```text
STARTED   -> Tstarted = timer.getAbsTime()
EXECUTING -> Texecuting = timer.getAbsTime()
DONE      -> Tover = timer.getAbsTime(); Texecuting = nil
SUCCESS   -> statusChief/statusCommander/LEGION status = SUCCESS
FAILED    -> statusChief/statusCommander/LEGION status = FAILED
```

Damit sind native Lifecycle-Hooks vorhanden, aus denen OMW Laufzeitbeobachtungen ableiten kann.

## 7. Cancellation

`AUFTRAG:Cancel()` ist als FSM-Event vorhanden und im bestehenden OMW-AAR-Scope praktisch bestätigt.

Source-geprüfter `AUFTRAG:onafterCancel(...)`-Pfad:

```text
- setzt Tover;
- deaktiviert weitere Repeats;
- propagiert Cancellation je nach Besitzpfad an CHIEF, COMMANDER, LEGION oder direkt OPSGROUP;
- bei PLANNED/QUEUED/REQUESTED oder ohne lebende Gruppen wird anschließend Done() ausgelöst;
- andernfalls wartet AUFTRAG auf die zugeordneten Gruppen, bevor die Mission abschließend bewertet wird.
```

`COMMANDER:onafterMissionCancel(...)` setzt zusätzlich:

```text
Mission.statusCommander = CANCELLED
```

und:

```text
PLANNED -> remove from COMMANDER queue
otherwise -> Legion:MissionCancel(Mission)
```

Wichtige OMW-Grenze:

```text
MOOSE cancellation
= operative Runtime-Beendigung

CampaignState settlement / resource return
= OMW strategische Transaktion
```

Ein `Cancel()` darf daher nicht allein strategische Reservierungen freigeben. Der OMW-Adapter muss den bestätigten MOOSE-Endzustand mit dem bereits definierten exact-once Settlement-Vertrag korrelieren.

## 8. Loss / Asset death

AUFTRAG besitzt native Ereignisse:

```text
ElementDestroyed
GroupDead
AssetDead
```

Source-geprüft:

```text
GroupDead -> AssetDead(asset)
AssetDead -> zählt verbleibende OPSGROUPs
wenn keine Gruppen mehr leben und keine Verstärkung läuft:
    AUFTRAG:Cancel()
```

Damit existiert ein nativer MOOSE-Loss-Pfad. OMW muss keinen globalen DCS-World-Scan zur Erkennung des Missionsverlusts bauen.

Strategische Aircraft-/Personnel-/Resource-Verluste bleiben dennoch CampaignState-Settlement und werden nicht allein aus MOOSE-internen Assettabellen als strategische Wahrheit abgeleitet.

## 9. Done versus Success/Failed

Die Source zeigt eine wichtige semantische Trennung:

```text
DONE
!= SUCCESS
!= FAILED
```

`onafterDone(...)` setzt die technische Mission auf `DONE` und synchronisiert den Done-Status zu COMMANDER/LEGION. `Success` und `Failed` sind separate AUFTRAG-Endzustände mit eigener Repeat-/Stop-Logik.

Für OMW folgt:

```text
MOOSE DONE
= operative Missionsausführung beendet

OMW result.success / mission status
= nur nach missionsspezifischer Ergebnisbewertung setzen
```

Der Adapter darf `DONE` nicht pauschal als erfolgreichen Kampagneneffekt verbuchen.

## 10. Repeat

Source-geprüft:

```text
SetRepeat(...)
SetRepeatDelay(...)
SetRepeatOnFailure(...)
SetRepeatOnSuccess(...)
```

`AUFTRAG:onbeforeRepeat(...)` verweigert Repeat ohne CHIEF, COMMANDER oder LEGION.

`onafterRepeat(...)` setzt AUFTRAG wieder auf `PLANNED` und kann die Mission erneut durch die native C2-/LEGION-Auswahl führen.

OMW-Bewertung:

```text
AUFTRAG repeat
= native operative Wiederholungsmechanik
```

Er darf nicht automatisch für persistente OMW-Missionen aktiviert werden. Wiederholung, Ersatzsortie, Relief oder erneuter MissionDemand sind fachlich unterschiedliche Vorgänge und müssen im jeweiligen Missionsvertrag explizit entschieden werden.

## 11. Empfohlene Adapter-Hooks

Für den späteren kleinen OMW-Adapter sind nach Source-Review folgende Hooks geeignet:

```text
COMMANDER:OnAfterOpsOnMission(...)
AIRWING:OnAfterFlightOnMission(...)
BRIGADE:OnAfterArmyOnMission(...)

AUFTRAG:OnAfterStarted(...)
AUFTRAG:OnAfterExecuting(...)
AUFTRAG:OnAfterDone(...)
AUFTRAG:OnAfterSuccess(...)
AUFTRAG:OnAfterFailed(...)
AUFTRAG:OnAfterCancel(...)
```

Nicht alle müssen gleichzeitig verwendet werden. Die kleinste notwendige Auswahl soll erst nach der finalen Domain-to-MOOSE-Adaptergrenze festgelegt werden.

Insbesondere soll OMW nicht:

```text
poll all missions every frame
scan all DCS groups globally
mirror the complete AUFTRAG FSM in a second scheduler
persist MOOSE runtime object references
```

## 12. Vorläufige Statuskorrelation

Eine belastbare, aber noch nicht endgültige Korrelation lautet:

| MOOSE observation | OMW interpretation boundary |
|---|---|
| `MissionAssign` / queued at LEGION | operative Zuweisung erfolgt; strategische Reservation muss bereits existieren |
| `FlightOnMission` / `ArmyOnMission` | konkrete physische Execution-Instanz existiert |
| `AUFTRAG STARTED` | MOOSE-Mission gestartet |
| `AUFTRAG EXECUTING` | Missions-Task wird ausgeführt |
| `AUFTRAG DONE` | MOOSE-Ausführung beendet; noch kein pauschaler OMW-Erfolg |
| `AUFTRAG SUCCESS` | positiver MOOSE-Endzustand; fachlicher Kampagneneffekt weiterhin missionsspezifisch prüfen |
| `AUFTRAG FAILED` | negativer MOOSE-Endzustand; OMW Failure/Settlement korrelieren |
| `AUFTRAG CANCELLED` | Runtime-Abbruch eingeleitet; Settlement erst exact-once nach OMW-Vertrag |
| `AssetDead` / kein OPSGROUP verbleibt | nativer Loss-Pfad; strategischen Verlust separat settlen |

Die endgültige Mapping-Tabelle wird erst nach FLIGHTGROUP-/ARMYGROUP-Review und finaler Adaptergrenze verbindlich.

## 13. Ergebnis für Phase 2

Der Manifestpunkt

```text
Mission Assignment / Lifecycle / FSM callbacks
```

ist für den Foundation-Scope source-seitig abgeschlossen.

Ergebnis:

```text
PASS_FOR_SOURCE_REVIEW
validated_in_dcs: false
```

MOOSE stellt bereits die benötigten Mission-Assignment-, Lifecycle-, Loss- und Cancellation-Hooks bereit. Es ist keine parallele OMW-Mission-FSM für die physische Ausführung erforderlich.

Der nächste Phase-2-Punkt ist:

```text
FLIGHTGROUP / ARMYGROUP status/lifecycle integration
```
