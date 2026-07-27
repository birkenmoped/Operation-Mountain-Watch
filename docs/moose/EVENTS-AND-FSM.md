---
document_id: OMW-MOOSE-EVENTS-FSM
status: BINDING
document_class: TECHNICAL_DEVELOPMENT_POLICY
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE event, FSM, callback and scheduler usage rules
  - prohibition of unnecessary polling and parallel state machines
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE events and FSM reference
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: partial
---

# MOOSE-Events, FSM und Scheduler in Operation Mountain Watch

## 1. Grundregel

Vor eigenen Polling-Schleifen, parallelen Zustandsautomaten oder Timerketten werden die vorhandenen MOOSE-Zustände, Events, verzögerten Events und Callbacks der konkreten Klasse geprüft.

Der vollständige frühere technische Text bleibt erhalten:

- [`Legacy-MOOSE-Events und FSM`](../evidence/source-records/legacy-moose-events-and-fsm.md)

Dies gilt insbesondere für:

- AIRWING, COMMANDER und AUFTRAG;
- FLIGHTGROUP, ARMYGROUP und OPSGROUP;
- OPSTRANSPORT und WAREHOUSE;
- CTLD, CSAR und AICSAR;
- `Core.Fsm`, `Core.Event` und `Core.Scheduler`.

## 2. Pflichtprüfung je Klasse

1. Zustände und Endzustände;
2. synchrone und verzögerte Events;
3. `OnBefore...`- und `OnAfter...`-Callbacks;
4. exakte Signaturen und Groß-/Kleinschreibung;
5. Verlust-, Abbruch- und zerstörte Assetzustände;
6. Reihenfolge mehrfach ausgelöster Events;
7. vorhandene Scheduler- und Retrymechanismen.

## 3. Callback-Regel

Callbacknamen und Signaturen werden aus dem tatsächlich verwendeten MOOSE-Quellcode übernommen. Ältere Dokumentationsbeispiele sind kein ausreichender Nachweis.

## 4. Scheduler-Regel

- `SCHEDULER` statt direkter `timer.scheduleFunction`-Ketten verwenden, soweit passend;
- keine hochfrequenten Polls ohne dokumentierten Grund;
- Scheduler bei Abschluss, Verlust oder ungültigem Asset beenden;
- IDs und Zustandsübergänge protokollieren;
- Retryzähler und Recoverybedingungen fachlich begrenzen.

## 5. Eigene FSMs

Projektspezifische Domänen-FSMs sind nur für CampaignState-Zustände zulässig, die MOOSE nicht besitzt. Sie dürfen MOOSE-Laufzeit-FSMs nicht unkontrolliert duplizieren und benötigen das Ausnahmeverfahren aus Dokument 26.
