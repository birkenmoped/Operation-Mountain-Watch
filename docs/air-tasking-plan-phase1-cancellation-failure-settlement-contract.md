---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-CANCELLATION-FAILURE-SETTLEMENT
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 cancellation, abort and failure semantics for Air Tasking domain records
  - separation of mission/request termination from CampaignState resource settlement
  - branch-local rules for cancellation eligibility, resource settlement delegation and replacement handling
not_authoritative_for:
  - concrete MOOSE FSM events or callbacks
  - new CampaignState resource APIs
  - concrete Warehouse/STORAGE runtime behavior beyond existing contracts
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Cancellation / Failure / Settlement Contract

## 1. Zweck

Dieses Dokument legt fest, was `CANCELLED`, `ABORTED` und `FAILED` in der Air-Tasking-Domain bedeuten und was daraus ausdrücklich **nicht** automatisch für strategische Ressourcen folgt.

Die zentrale Trennung lautet:

```text
request termination
!= mission termination
!= execution-attempt termination
!= CampaignState resource settlement
!= MissionDemand campaign result
```

Eine Statusänderung in Air Tasking darf deshalb weder Bestände zurückbuchen noch Verluste erzeugen, solange der zuständige CampaignState-/Warehouse-Vertrag dies nicht auf Basis des tatsächlichen Ressourcenverlaufs bestätigt.

## 2. Verbindliche Ausgangsgrenzen

Aus den bestehenden Phase-0-Verträgen gilt weiterhin:

```text
CampaignState
= strategische Ressourcen- und Settlement-Autorität

AIR_SUPPORT_REQUEST
= Supportbedarf über eine Authority-Grenze

AIR_TASKING_MISSION
= operative Missionsplanung und Zuordnung

MOOSE / DCS
= physische Ausführung und beobachtbare Runtime
```

Der vorhandene CampaignState-Ressourcenvertrag stellt bereits Transaktionsoperationen wie folgende bereit:

```text
Store:ReserveResource(spec)
Store:MarkLoading(transactionId)
Store:MarkInTransit(transactionId)
Store:MarkDelivered(transactionId)
Store:MarkLost(transactionId)
Store:Consume(transactionId)
Store:Cancel(transactionId)
Store:GetTransaction(transactionId)
```

Dieser Phase-1-Vertrag erfindet keine neue Methode und erweitert keine zulässigen Zustandsübergänge dieser bestehenden Ressourcen-API.

## 3. Drei unterschiedliche Beendigungsarten einer Mission

### 3.1 `CANCELLED`

`CANCELLED` bedeutet:

```text
autorisierte Beendigung vor normaler physischer Ausführung
```

Typische fachliche Ursachen können sein:

```text
- Bedarf entfallen
- Priorität geändert
- Mission vor Materialisierung zurückgezogen
- Asset-Zuweisung vor Execution aufgehoben
- Planänderung vor operativem Beginn
```

`CANCELLED` bedeutet **nicht** automatisch:

```text
refund all resources
release every reservation
no strategic consequence
```

Die Air-Tasking-Domain darf lediglich feststellen, welche `resource_reservation_refs` mit der Mission korreliert sind. Ob eine jeweilige CampaignState-Transaktion noch stornierbar ist, entscheidet ausschließlich deren bestehender Ressourcenvertrag.

### 3.2 `ABORTED`

`ABORTED` bedeutet:

```text
operative Ausführung hat bereits begonnen,
wurde aber vor normalem Missionsabschluss beendet
```

Mögliche Ursachen können später unter anderem sein:

```text
- mission-safety abort
- loss of required support
- weather / divert condition
- tactical abort
- authority-driven recall
- player or AI execution unable to continue
```

Aus `ABORTED` folgt keine pauschale Aussage darüber, ob Ressourcen:

```text
- noch reserviert
- bereits geladen
- bereits im Einsatz
- verbraucht
- verloren
- zurückgewonnen
```

sind.

### 3.3 `FAILED`

`FAILED` bedeutet:

```text
die konkrete AIR_TASKING_MISSION hat ihr operatives Missionsziel nicht erfolgreich abgeschlossen
```

`FAILED` ist ein missionsfachliches Ergebnis und kein Ressourcenstatus.

Insbesondere gilt:

```text
MISSION FAILED
!= aircraft lost
!= fuel lost
!= weapon consumption unknown becomes loss
!= MissionDemand FAILED automatically
!= AIR_SUPPORT_REQUEST ABORTED automatically
```

Ein gescheiterter Missionsversuch kann einen weiter offenen Request hinterlassen und durch eine neue Mission ersetzt werden.

## 4. Request-Termination bleibt getrennt

Für `AIR_SUPPORT_REQUEST` gelten getrennte terminale Zustände:

```text
DENIED
CANCELLED
ABORTED
FULFILLED
```

Semantische Grenze:

```text
REQUEST CANCELLED
= Supportbedarf wird durch autorisierte Entscheidung beendet

REQUEST ABORTED
= bereits operativ begonnenes Supportvorhaben endet ohne Erfüllung

REQUEST DENIED
= Supportanforderung wird vor Tasking abgelehnt
```

Keine dieser Request-Transitionen verändert selbst eine CampaignState-Ressource.

Sind bereits Missionen oder Reservierungen zugeordnet, müssen diese separat reconciliiert und nach ihren eigenen Verträgen beendet beziehungsweise settled werden.

## 5. Settlement-Matrix nach Ressourcenfortschritt

Air Tasking bewertet Ressourcen nicht aus dem Missionsstatus, sondern anhand der korrelierten CampaignState-Transaktion und bestätigter physischer Ereignisse.

Konzeptionelle Matrix:

```text
MISSION TERMINATES
    ↓
inspect referenced CampaignState transaction
    ↓
current transaction / physical evidence determines settlement
```

### 5.1 Nur geplant, keine Reservierung

```text
mission CANCELLED / ABORTED / FAILED
resource_reservation_refs = {}
```

Folge:

```text
no Air Tasking resource mutation
```

### 5.2 Reservierung vorhanden, aber noch stornierbar

Wenn eine referenzierte CampaignState-Transaktion nach dem **bestehenden** Ressourcenvertrag noch stornierbar ist, darf der zuständige Resource-Settlement-Adapter deren vorhandene Cancel-Semantik verwenden.

```text
mission termination
    ↓
transaction still eligible for existing Cancel contract?
    ├── yes -> resource adapter may cancel transaction
    └── no  -> continue settlement according to actual transaction state/evidence
```

Air Tasking selbst entscheidet diese Eligibility nicht anhand des Missionsstatusnamens.

### 5.3 Ressource bereits in physischem Lifecycle

Sobald Ressourcen bereits geladen, in Transit, verbraucht oder physisch verloren sind, gilt:

```text
mission termination
!= rollback physical history
```

Die zuständige CampaignState-/Warehouse-/missionsspezifische Integration muss den realen Verlauf nach dem vorhandenen Ressourcenvertrag settlen.

### 5.4 Verlust

Ein strategischer Verlust darf nur aus einem dafür ausreichenden Ressourcen-/Runtime-Nachweis und dem zuständigen Settlement-Vertrag entstehen.

```text
MISSION FAILED
```

allein ist **kein** Verlustnachweis.

Ebenso ist:

```text
DCS group disappeared
```

allein kein ausreichender Verlustnachweis, wenn beispielsweise Server-/Missionsrestart oder kontrollierte Dematerialisierung als Ursache möglich ist.

## 6. Replacement statt terminalen Record zurückzusetzen

Ein terminaler Missionsrecord wird nicht stillschweigend reaktiviert.

Wenn ein weiter gültiger Request nach `FAILED`, `ABORTED` oder zulässigem `CANCELLED` einer Mission erneut bedient werden soll:

```text
existing ASR remains active where lifecycle allows
    ↓
create new AIR_TASKING_MISSION
    ↓
new ATM- ID
    ↓
new resource correlation as required
    ↓
new EXE- attempt when materialized
```

Damit bleibt nachvollziehbar:

```text
ASR-000020
  ATM-000011 FAILED
  ATM-000012 replacement PLANNED
```

Eine Replacement-Mission darf bestehende Ressourcenreservierungen nicht blind übernehmen. Wiederverwendung oder Freigabe einer CampaignState-Transaktion muss durch den zuständigen Ressourcenvertrag ausdrücklich zulässig sein.

## 7. Execution Attempt und Mission Outcome

Ein `EXECUTION_ATTEMPT` ist nur die physische Materialisierung einer `AIR_TASKING_MISSION`.

Grundregel:

```text
EXE status
= physical attempt correlation

ATM status/result
= mission-level operational meaning
```

Beispiele:

```text
EXE FAILED
-> adapter evaluates whether ATM becomes FAILED, ABORTED or remains reconcilable

EXE CANCELLED before start
-> ATM may become CANCELLED if mission is withdrawn

EXE ENDED
-> ATM is not automatically COMPLETED until mission-level outcome is evaluated
```

Die konkrete Zuordnung von MOOSE-FSM-/DCS-Ereignissen zu diesen Entscheidungen wird erst in Phase 2 verifiziert.

## 8. MissionDemand und Campaign Effect

Auch nach terminalem Missionsstatus bleibt die Campaign-Ebene separat:

```text
ATM FAILED
-> MissionDemand may remain OPEN/ACTIVE

ATM COMPLETED
-> MissionDemand may still fail its successCriteria

ASR FULFILLED
-> MissionDemand success still requires campaign-effect evaluation
```

Damit kann beispielsweise eine CAS-Mission operativ abgeschlossen sein, ohne dass das zu schützende Bodenobjekt tatsächlich gerettet wurde.

## 9. Idempotenz und doppelte Settlement-Verarbeitung

Jede Settlement-Verarbeitung muss über stabile IDs und bestehende CampaignState-Transaktions-IDs korreliert werden.

Nicht zulässig:

```text
same ATM terminal event processed twice
-> two Cancel calls / two credits / two losses
```

Die spätere Implementierung muss daher mindestens prüfen:

```text
- mission_id
- request_id where applicable
- execution_id
- transactionId / reservationId
- current transaction state
- whether the same settlement correlation was already processed
```

Die vorhandene CampaignState-Idempotenz bleibt maßgeblich; Air Tasking führt keine zweite Ressourcen-Idempotenzquelle ein.

## 10. Player-/AI-Neutralität

Cancellation und Failure besitzen dieselbe Domain-Semantik für Spieler und KI.

```text
player mission abort
!= automatic refund

AI mission abort
!= automatic loss
```

Unterschiede dürfen später nur aus tatsächlich unterschiedlichen Runtime-Ereignissen, Recovery-Semantiken oder missionsspezifischen Ressourcenverträgen entstehen.

## 11. MOOSE-First-Grenze

Dieser Vertrag definiert keine eigene Ausführungs- oder Recovery-Engine.

Phase 2 muss prüfen, welche MOOSE-Lifecycle-/Mission-Events zuverlässig anzeigen können, dass eine physische Mission:

```text
- noch nicht gestartet
- gestartet
- beendet
- fehlgeschlagen
- abgebrochen
- zurückgekehrt / recovered
```

ist.

Erst daraus darf der kleinste notwendige OMW-Adapter für Domainstatus und Settlement-Korrelation entstehen.

## 12. Invarianten

Die spätere Implementierung muss mindestens gewährleisten:

```text
- Air Tasking status never directly mutates strategic inventory
- CANCELLED does not imply blanket refund
- ABORTED does not imply blanket loss
- FAILED does not imply blanket loss
- physical consumption/loss is never rolled back because a mission failed
- reservation release uses only the existing CampaignState resource contract when eligible
- terminal ATM records are not silently reopened
- replacement uses a new ATM identity
- resource settlement and MissionDemand settlement remain separate
- settlement processing is idempotently correlated by stable IDs
```

## 13. Phase-1-Ergebnis

Mit diesem Dokument ist der Manifest-Punkt abgeschlossen:

```text
[x] Cancellation-/Failure-Semantik definieren
```

Statusautomaten und erlaubte Statusübergänge wurden bereits im separaten Lifecycle-Vertrag definiert.

Noch offen bleiben insbesondere:

```text
- Support-Beziehungen und Zyklusregeln
- Player-/AI-Assignment-Semantik
- konkreter Snapshot-/Serialisierungsvertrag
- vollständige Datenvalidierungs- und Logging-Regeln
```

Kein Runtime-Code wurde geändert. Kein DCS-Test ist für diesen Domain-Contract erforderlich. `validated_in_dcs` bleibt `false`.
