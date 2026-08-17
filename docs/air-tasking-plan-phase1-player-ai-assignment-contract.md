---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-PLAYER-AI-ASSIGNMENT
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 player-versus-AI assignment semantics for AIR_TASKING_MISSION
  - separation of assignment intent from aircraft/resource ownership and physical execution
  - prevention of duplicate player and AI execution for the same authoritative mission demand
not_authoritative_for:
  - concrete MOOSE PLAYERTASK or AUFTRAG APIs
  - concrete player task UI or F10 workflow
  - final AI asset-selection behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Player-/AI-Assignment Contract

## 1. Zweck

Dieses Dokument definiert, wie eine `AIR_TASKING_MISSION` fachlich einem Spieler oder der KI zur Ausführung zugeordnet werden darf, ohne dadurch eine zweite Aircraft-, Crew-, Fuel-, Weapon- oder Warehouse-Ressourcenhoheit zu erzeugen.

Grundlagen sind insbesondere:

- `OMW-GOV-001`;
- `OMW-GOV-MOOSE-FIRST`;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`;
- `OMW-AIR-TASKING-PLAN-FOUNDATION`;
- `OMW-AIR-TASKING-PLAN-PHASE1-DOMAIN-DATA-CONTRACT`;
- `OMW-AIR-TASKING-PLAN-PHASE1-STATUS-LIFECYCLE`;
- `OMW-AIR-TASKING-PLAN-PHASE1-CANCELLATION-FAILURE-SETTLEMENT`.

Der bestehende verbindliche Campaign-Vertrag legt bereits fest:

```text
MissionDemand.playerCapable
MissionDemand.aiCapable
```

und verlangt, dass Spieleraufgaben und KI-Ausführung auf demselben Bedarf arbeiten, ohne denselben Bedarf doppelt auszuführen.

## 2. Grundregel

`player_or_ai_assignment` ist ausschließlich ein Planungs- und Ausführungszuordnungsattribut.

Es bedeutet nicht:

```text
assigned aircraft inventory
assigned crew inventory
CampaignState reservation
MOOSE AIRWING ownership
MOOSE SQUADRON ownership
DCS client-slot ownership
physical aircraft existence
```

Verbindlich gilt:

```text
assignment intent
!= strategic resource allocation
!= physical execution
```

## 3. Kanonische Assignment-Modi

Für Phase 1 gelten genau folgende fachlichen Modi:

```text
UNASSIGNED
PLAYER
AI
```

### `UNASSIGNED`

Die Mission ist fachlich angelegt oder geplant, aber noch keinem Ausführungspfad zugewiesen.

### `PLAYER`

Die Mission ist für Spielerausführung vorgesehen beziehungsweise einem Spielerpfad zugeordnet.

### `AI`

Die Mission ist für KI-Ausführung vorgesehen beziehungsweise dem späteren MOOSE-Ausführungspfad zugeordnet.

Weitere Mischzustände wie `PLAYER_OR_AI`, `HYBRID`, `BOTH` oder parallele `PLAYER`- und `AI`-Flags sind nicht zulässig. Die Entscheidung muss zu jedem Zeitpunkt eindeutig sein.

## 4. Datenstruktur

Der bestehende Feldname `player_or_ai_assignment` wird in Phase 1 als strukturierter Planungswert konkretisiert:

```lua
local assignment = {
  mode = "UNASSIGNED",
  assignee_ref = nil,
  assigned_at = nil,
  assignment_reason = nil,
  change_serial = 1,
}
```

Für `AIR_TASKING_MISSION` gilt damit konzeptionell:

```lua
local mission = {
  mission_id = "ATM-000001",
  -- ...
  player_or_ai_assignment = {
    mode = "UNASSIGNED",
    assignee_ref = nil,
    assigned_at = nil,
    assignment_reason = nil,
    change_serial = 1,
  },
  -- ...
}
```

`assignee_ref` bleibt bewusst abstrakt. Es darf später beispielsweise auf eine stabile Spieler-/Task-/AI-Ausführungsreferenz zeigen, aber nicht auf ein Lua-Objekt, MOOSE-Objekt oder DCS-Userdata.

## 5. MissionDemand-Fähigkeit begrenzt die Zuordnung

Die Assignment-Entscheidung darf die Campaign-Domain nicht überschreiben.

Vor einer Zuordnung muss gelten:

```text
PLAYER assignment
requires MissionDemand.playerCapable == true

AI assignment
requires MissionDemand.aiCapable == true
```

Wenn eine Mission mehrere `mission_demand_ids` referenziert, muss der gewählte Ausführungspfad für alle durch dieselbe physische Mission erfüllten Demands zulässig sein oder die Zusammenfassung ist unzulässig.

Nicht zulässig:

```text
MissionDemand.playerCapable = false
-> AIR_TASKING_MISSION assignment = PLAYER
```

oder:

```text
MissionDemand.aiCapable = false
-> AIR_TASKING_MISSION assignment = AI
```

## 6. Assignment erzeugt keine Ressourcenreservierung

Der Wechsel

```text
UNASSIGNED -> PLAYER
```

oder

```text
UNASSIGNED -> AI
```

führt nicht automatisch zu:

```text
CampaignState ReserveResource
fuel debit
weapon debit
aircraft decrement
SQUADRON allocation
DCS spawn
client-slot lock
```

Wenn eine Mission reale strategische Ressourcen bindet, bleibt dafür ausschließlich der bestehende CampaignState-/Warehouse-Vertrag zuständig.

Die `AIR_TASKING_MISSION.resource_reservation_refs` referenzieren solche autoritativen Vorgänge nur.

## 7. Spielerzuordnung

Eine PLAYER-Zuordnung beschreibt, dass der Auftrag über den Spielerpfad erfüllt werden soll.

Phase 1 legt noch nicht fest, ob dieser Pfad später technisch durch MOOSE `PLAYERTASK`, F10-Menüs, Mission Cards oder eine Kombination davon umgesetzt wird. Diese MOOSE-/UI-Frage wird vor Implementierung separat verifiziert.

Verbindliche Domain-Regeln:

```text
PLAYER assignment
-> no simultaneous AI execution for the same ATM
-> no second MissionDemand execution path for the same authoritative demand
-> no resource reservation merely because a player can see/accept the mission
```

Ein sichtbarer Auftrag ist noch keine physische Ausführung.

Ein späterer Player-Claim beziehungsweise eine tatsächliche Übernahme darf den Assignment-Datensatz konkretisieren, ohne die Ressourcendomäne zu duplizieren.

## 8. KI-Zuordnung

Eine AI-Zuordnung beschreibt, dass die Mission über den später verifizierten MOOSE-Ausführungspfad materialisiert werden darf.

Verbindlich gilt:

```text
AI assignment
!= chosen AIRWING/SQUADRON asset inventory
!= AUFTRAG object
!= FLIGHTGROUP object
```

Die konkrete Asset-Auswahl, Mission Assignment und physische Ausführung bleiben MOOSE-first und werden erst nach Phase-2-Verifikation an den Domain-Datensatz angebunden.

## 9. Wechsel zwischen PLAYER und AI

Ein Wechsel darf nur erfolgen, solange keine konkurrierende physische Ausführung entsteht.

Grundregel:

```text
UNASSIGNED -> PLAYER
UNASSIGNED -> AI
```

Eine direkte Umzuordnung

```text
PLAYER -> AI
AI -> PLAYER
```

ist nur zulässig, wenn der bisherige Pfad fachlich freigegeben wurde und kein aktiver `EXECUTION_ATTEMPT` beziehungsweise keine aktive Spielerübernahme mehr besteht.

Phase 1 erzwingt deshalb:

```text
active execution or active player claim
-> reassignment blocked
```

Konkrete Reassignment-/Retasking-Verfahren gehören zu späteren Phasen. Dieses Dokument legt nur die Sicherheitsgrenze fest.

## 10. Keine Doppelausführung

Für dieselbe `AIR_TASKING_MISSION` darf höchstens ein aktiver Ausführungspfad existieren.

Unzulässig:

```text
ATM-000100 assignment = PLAYER
and
active AI execution attempt for ATM-000100
```

Ebenso darf derselbe `MissionDemand` nicht gleichzeitig über zwei unabhängig konkurrierende Missionen ausgeführt werden, sofern die Campaign-Domain nicht ausdrücklich mehrere komplementäre Missionen für denselben Bedarf erlaubt.

Die verbindliche Grundregel aus der Campaign-Architektur bleibt:

```text
player task and AI AUFTRAG work on the same demand
without duplicate execution of that demand
```

## 11. Relationship zu Missionstatus

Assignment und Missionstatus sind getrennte Dimensionen.

Beispiele:

```text
status = PLANNED
assignment.mode = UNASSIGNED
```

ist zulässig.

```text
status = ALLOCATED
assignment.mode = PLAYER
```

kann zulässig sein, wenn die benötigten CampaignState-Reservierungsreferenzen beziehungsweise fachlichen Zuordnungen vorliegen.

```text
status = EXECUTING
assignment.mode = AI
```

setzt einen aktiven Execution Attempt voraus.

Ein Assignment-Wechsel darf keinen terminalen Missionstatus zurücksetzen.

## 12. Player-/AI-Assignment und Callsign/Asset-Felder

Felder wie

```text
assigned_airwing_id
assigned_squadron_id
aircraft_type
aircraft_count
callsign
```

bleiben Planungs-/Zuordnungswerte und sind nicht automatisch durch den Assignment-Modus erforderlich.

Beispiel:

```text
assignment.mode = PLAYER
```

bedeutet nicht automatisch, dass bereits eine konkrete Client-Gruppe oder ein konkretes Luftfahrzeug gebunden ist.

Ebenso bedeutet

```text
assignment.mode = AI
```

nicht automatisch, dass ein MOOSE-Squadron bereits ein konkretes Asset abgegeben hat.

## 13. Persistenz

Persistierbar sind ausschließlich die fachlichen Assignment-Daten:

```text
mode
stable assignee_ref if applicable
assigned_at
assignment_reason
change_serial
```

Nicht persistiert werden:

```text
player UNIT userdata
DCS client group object
MOOSE PLAYERTASK object
MOOSE AUFTRAG object
FLIGHTGROUP object
callback handles
menu handles
```

## 14. Validierungsregeln

Die spätere Domain-Implementierung muss mindestens fail-closed prüfen:

```text
- mode is one of UNASSIGNED | PLAYER | AI
- PLAYER requires every relevant MissionDemand to be playerCapable
- AI requires every relevant MissionDemand to be aiCapable
- no simultaneous PLAYER and AI mode
- no assignment transition while conflicting active execution exists
- no assignment operation creates authoritative resource stock
- persistent assignee_ref is a stable scalar/domain reference, never a runtime object
- assignment change increments the owning persistent change serial exactly once
```

Fehler müssen mit `mission_id` und, soweit relevant, `mission_demand_id` geloggt werden.

## 15. MOOSE-First-Grenze

Dieses Dokument definiert keine neue Dispatcher-Engine.

Für den AI-Pfad wird in Phase 2 geprüft, wie `COMMANDER`, `AIRWING`, `SQUADRON`, `AUFTRAG` und `FLIGHTGROUP` die tatsächliche Zuweisung und Ausführung tragen.

Für den Player-Pfad wird vor produktiver Nutzung geprüft, welche MOOSE-Funktionalität, insbesondere vorhandene Player-Task-Mechanismen, für OMW geeignet ist.

Erst nach dieser Verifikation darf der Adapter festlegen, wie

```text
PLAYER assignment
or
AI assignment
```

in konkrete MOOSE-/DCS-Ausführung übersetzt wird.

## 16. Phase-1-Ergebnis

Mit diesem Contract ist der Manifest-Punkt abgeschlossen:

```text
[x] Player-/AI-Assignment als Planungsattribut definieren, nicht als zweite Aircraft-Resource-Tabelle
```

Weiter offen bleiben:

```text
- Serialisierbarkeit der persistenten Teilmenge / Snapshot-Vertrag
- vollständige Datenvalidierungs- und Logging-Regeln
- Gate-1-Bewertung
```

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diesen Domain-Contract erforderlich. `validated_in_dcs` bleibt `false`.
