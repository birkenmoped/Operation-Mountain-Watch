---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-STATUS-LIFECYCLE
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 request and mission status models
  - allowed status-transition contract for AIR_SUPPORT_REQUEST and AIR_TASKING_MISSION
  - separation of planning status from MOOSE execution lifecycle and CampaignState settlement
not_authoritative_for:
  - concrete MOOSE FSM events or callbacks
  - DCS runtime behavior
  - final cancellation and failure settlement semantics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Status / Lifecycle Contract

## 1. Zweck

Dieses Dokument legt getrennte fachliche Statusautomaten fuer `AIR_SUPPORT_REQUEST` und `AIR_TASKING_MISSION` fest.

Die Trennung ist erforderlich, weil ein Support Request und eine konkrete Luftmission nicht denselben Lifecycle besitzen:

```text
request lifecycle
!=
mission planning lifecycle
!=
MOOSE execution lifecycle
!=
CampaignState resource settlement
```

Die Statuswerte sind OMW-Domainzustand. Sie duerfen spaeter aus geprueften MOOSE-/DCS-Ereignissen aktualisiert werden, sind aber nicht mit MOOSE-internen FSM-Zustaenden gleichzusetzen.

## 2. AIR_SUPPORT_REQUEST Statusmodell

Verbindlicher Phase-1-Statuskatalog:

```text
DRAFT
SUBMITTED
VALIDATED
PRIORITIZED
APPROVED
TASKED
EXECUTING
FULFILLED
DENIED
CANCELLED
ABORTED
```

### 2.1 Semantik

`DRAFT`
: Request ist fachlich angelegt, aber noch nicht zur Bearbeitung eingereicht.

`SUBMITTED`
: Request wurde an die zustaendige Supporting Authority uebergeben.

`VALIDATED`
: Request ist fachlich vollstaendig genug, Authority- und Plausibilitaetspruefung sind bestanden.

`PRIORITIZED`
: Request ist in die aktuelle Priorisierung eingeordnet. Daraus folgt noch keine Asset-Zuweisung.

`APPROVED`
: Request darf grundsaetzlich durch eine Air-Tasking-Mission erfuellt werden. Daraus folgt noch keine Ressourcenreservierung.

`TASKED`
: Mindestens eine konkrete `AIR_TASKING_MISSION` ist zur Erfuellung zugeordnet.

`EXECUTING`
: Mindestens eine zugeordnete Mission befindet sich in physischer Ausfuehrung fuer diesen Request.

`FULFILLED`
: Der angeforderte Air-Support-Bedarf ist fachlich erfuellt.

`DENIED`
: Der Request wurde vor Tasking abgelehnt.

`CANCELLED`
: Der Request wurde vor vollstaendiger Erfuellung durch autorisierte Entscheidung beendet.

`ABORTED`
: Ein bereits operativ begonnenes Support-Vorhaben wurde beendet, ohne den Request erfolgreich zu erfuellen.

### 2.2 Erlaubte Normaltransitionen

```text
DRAFT
  -> SUBMITTED

SUBMITTED
  -> VALIDATED
  -> DENIED
  -> CANCELLED

VALIDATED
  -> PRIORITIZED
  -> DENIED
  -> CANCELLED

PRIORITIZED
  -> APPROVED
  -> DENIED
  -> CANCELLED

APPROVED
  -> TASKED
  -> CANCELLED

TASKED
  -> EXECUTING
  -> CANCELLED
  -> ABORTED

EXECUTING
  -> FULFILLED
  -> ABORTED
  -> CANCELLED
```

Terminal:

```text
FULFILLED
DENIED
CANCELLED
ABORTED
```

Terminale Requests duerfen nicht ohne explizite spaetere Reopen-/Replacement-Regel in einen aktiven Zustand zurueckkehren. Eine solche Regel gehoert nicht zu Phase 1.

### 2.3 Kein automatisches Hochstufen

Nicht zulaessig:

```text
request_timing = EMERGENCY
-> automatically APPROVED
```

Ebenso nicht:

```text
assigned_mission_ids not empty
-> automatically FULFILLED
```

Statusaenderungen benoetigen fachlich gueltige Transitionen.

## 3. AIR_TASKING_MISSION Statusmodell

Verbindlicher Phase-1-Statuskatalog:

```text
DRAFT
PLANNED
ALLOCATED
TASKED
EXECUTING
COMPLETED
FAILED
CANCELLED
ABORTED
```

### 3.1 Semantik

`DRAFT`
: Missionsrecord existiert, darf aber noch unvollstaendig fuer operative Planung sein.

`PLANNED`
: Missionsdaten erfuellen die fuer die Planungsstufe erforderlichen Felder; noch keine verbindliche Asset-/Ressourcenzuordnung.

`ALLOCATED`
: Die Mission besitzt die erforderlichen fachlichen Zuordnungen und nach Bedarf autorisierte CampaignState-Reservierungsreferenzen. `ALLOCATED` bedeutet keine eigene Air-Tasking-Ressourcenhoheit.

`TASKED`
: Die Mission ist fuer physische Ausfuehrung freigegeben und darf nach Phase-2/3-Regeln an MOOSE materialisiert/uebergeben werden.

`EXECUTING`
: Ein aktiver `EXECUTION_ATTEMPT` repraesentiert die physische Ausfuehrung.

`COMPLETED`
: Die operative Mission wurde beendet und ihr mission-level result ist erfolgreich beziehungsweise abgeschlossen. Dies ist nicht automatisch gleichbedeutend mit MissionDemand-Erfolg.

`FAILED`
: Die konkrete Mission konnte ihren operativen Auftrag nicht erfolgreich abschliessen.

`CANCELLED`
: Die Mission wurde vor Beginn oder vor physischer Materialisierung autorisiert beendet.

`ABORTED`
: Die Mission wurde nach operativem Beginn vor normalem Abschluss beendet.

### 3.2 Erlaubte Normaltransitionen

```text
DRAFT
  -> PLANNED
  -> CANCELLED

PLANNED
  -> ALLOCATED
  -> CANCELLED

ALLOCATED
  -> TASKED
  -> CANCELLED

TASKED
  -> EXECUTING
  -> CANCELLED
  -> ABORTED

EXECUTING
  -> COMPLETED
  -> FAILED
  -> ABORTED
```

Terminal:

```text
COMPLETED
FAILED
CANCELLED
ABORTED
```

Ein spaeterer Retry oder Replacement erzeugt grundsaetzlich keinen stillen Ruecksprung eines terminalen Missionsrecords. Phase 1 haelt dafuer die getrennte `EXE-`-Identitaet bereit; konkrete Retry-/Replacement-Regeln folgen spaeter.

## 4. Request- und Mission-Status sind nur korreliert

Ein Request kann mehrere Missionen besitzen; eine Mission kann mehrere Requests referenzieren.

Deshalb gilt nicht:

```text
one mission status
= request status
```

Beispiele:

```text
ATM-000010 COMPLETED
but
ASR-000020 remains TASKED
because another required mission is still pending
```

oder:

```text
ATM-000011 FAILED
but
ASR-000020 remains TASKED
because replacement mission ATM-000012 was assigned
```

Die spaetere Request-Auswertung muss die fachlichen Erfuellungskriterien des Requests pruefen und darf nicht nur den letzten Missionsstatus spiegeln.

## 5. MissionDemand bleibt getrennt

Der bestehende `MissionDemand`-Lifecycle aus der Campaign-Architektur bleibt davon unberuehrt.

```text
AIR_SUPPORT_REQUEST FULFILLED
!= automatically MissionDemand SUCCESS

AIR_TASKING_MISSION COMPLETED
!= automatically MissionDemand SUCCESS
```

MissionDemand-Erfolg wird nach den zugehoerigen `successCriteria` und `failureConsequences` in der Campaign-Domain bewertet.

## 6. Resource Settlement bleibt getrennt

Keine der folgenden Transitionen darf implizit Ressourcen buchen, verbrauchen oder gutschreiben:

```text
REQUEST: APPROVED -> TASKED
MISSION: PLANNED -> ALLOCATED
MISSION: ALLOCATED -> TASKED
MISSION: EXECUTING -> COMPLETED
```

Strategische Ressourcenbewegungen erfolgen ausschliesslich ueber den zustaendigen CampaignState-/Warehouse-Vertrag.

Insbesondere gilt:

```text
mission CANCELLED
!= automatically refund everything

mission FAILED
!= automatically resource loss

mission COMPLETED
!= automatically resource consumption settled
```

Die konkrete Cancellation-/Failure-Settlement-Semantik ist ein separater Phase-1-Punkt.

## 7. Execution Attempt Status

`EXECUTION_ATTEMPT` besitzt einen kleineren technischen Domain-Lifecycle:

```text
PENDING
STARTED
ENDED
FAILED
CANCELLED
```

Zulaessige Grundtransitionen:

```text
PENDING -> STARTED | CANCELLED | FAILED
STARTED -> ENDED | FAILED | CANCELLED
```

Dieser Status dient nur der Korrelation eines physischen Materialisierungsversuchs. Die konkrete Abbildung auf MOOSE-FSM-Events wird erst in Phase 2 verifiziert.

## 8. Invarianten

Die spaetere Implementierung muss mindestens sicherstellen:

```text
- terminale Request-/Mission-Status sind ohne ausdrueckliche Reopen-Regel unveraenderlich
- REQUEST FULFILLED benoetigt fachlichen Erfuellungsnachweis
- MISSION EXECUTING benoetigt einen aktiven Execution Attempt
- MISSION COMPLETED/FAILED/ABORTED beendet den aktiven Execution Attempt fachlich
- kein MOOSE-FSM-Status wird ungeprueft als Domainstatus persistiert
- keine Statusaenderung erzeugt implizit strategische Ressourcen
- jede Transition erhoeht change_serial genau einmal
- unzulaessige Transitionen fail closed und loggen stabile Domain-ID
```

## 9. Abgrenzung zu Dokument 54

Dokument 54 enthaelt fachlich nuetzliche Lifecycle-Begriffe wie `DRAFT`, `SUBMITTED`, `VALIDATED`, `PRIORITIZED`, `APPROVED`, `TASKED`, `ON_CALL`, `DIVERTED`, `EXECUTING`, `COMPLETE`, `DENIED`, `CANCELLED` und `ABORTED` sowie Missionszustaende wie `PLANNED`, `ALERT`, `LAUNCHED`, `ON_STATION`, `RTB`, `COMPLETE`, `ABORTED`, `LOST`.

Fuer die produktive Air-Tasking-Domain werden diese nicht 1:1 als gemeinsamer Zustandsautomat uebernommen.

Begruendung:

- `ON_CALL`, `DIVERTED`, `ALERT`, `LAUNCHED`, `ON_STATION` und `RTB` sind operative Ausfuehrungs-/Readiness-Aspekte und koennen spaeter aus MOOSE-/Missionstyp-spezifischen Daten abgeleitet werden;
- sie duerfen den generischen Domain-Lifecycle nicht mit MOOSE- oder missionsspezifischen Runtimezustaenden vermischen;
- `LOST` ist primaer ein physisches/Ressourcenereignis und wird nicht als generischer Missionsstatus missbraucht.

## 10. Phase-1-Ergebnis

Mit diesem Dokument sind zwei Manifest-Punkte abgeschlossen:

```text
[x] Statusautomaten fuer Request und Mission getrennt definieren
[x] erlaubte Statusuebergaenge dokumentieren
```

Noch offen bleiben insbesondere:

```text
- Cancellation-/Failure-Semantik und Settlement
- Support-Beziehungen und Zyklusregeln
- Player-/AI-Assignment-Semantik
- konkreter Snapshot-/Serialisierungsvertrag
- vollstaendige Datenvalidierungs- und Logging-Regeln
```

Kein Runtime-Code wurde geaendert. Kein DCS-Test ist fuer diesen Domain-Contract erforderlich. `validated_in_dcs` bleibt `false`.
