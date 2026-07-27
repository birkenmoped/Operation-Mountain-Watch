---
document_id: OMW-REVIEW-TM01-TM02-MOOSE-FIRST
status: DRAFT
document_class: CODE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - current TM01 and TM02 MOOSE-first review findings
  - classification of reviewed historical test fixtures
not_authoritative_for:
  - merge approval
  - non-MOOSE exception approval
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: review/tm01-tm02-moose-first
source_commit:
validated_in_dcs: false
---

# 39 – TM01/TM02 MOOSE-First Code Review

## 1. Status und Einordnung

```text
Status: DRAFT / IN PROGRESS
```

Dieses Dokument ist die aktuelle Review-Zusammenfassung für TM01 und TM02. Es genehmigt weder einen Merge noch eine Nicht-MOOSE-Ausnahme.

Der vollständige bisherige Reviewstand bleibt unverändert erhalten:

- [`Legacy-Reviewfassung`](evidence/source-records/legacy-39-tm01-tm02-moose-first-code-review.md)

Verbindliche Grundlagen:

- [`OMW-GOV-001`](00-project-governance.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)

## 2. Reviewumfang

### TM01

Schwerpunkt:

- Konvoi-Spawn, Routen, Pack/Unpack und CampaignState-Abbildung;
- Player-/Representation-Interest;
- Watchguard und Stuck-Recovery;
- Scheduler, Events, Sets und Group-Wrapper;
- Vermeidung sichtbarer Teleportation während Aufklärung oder Kampf.

### TM02

Schwerpunkt:

- RED-Netzwerk, Quellenwahl und Task-Ausführung;
- Offroad-/Straßenrouting und Bewegungsrepräsentation;
- Commander-Zyklen, Progress-Watchdog und Route-Reassignment;
- Combat Events und Verlust-/Nachfülllogik;
- Abgleich mit der verbindlichen gewichteten Netzwerkarchitektur.

## 3. Verbindliche Reviewregel

Für jede eigene Mechanik wird dokumentiert:

1. fachlicher Zweck;
2. bestehende MOOSE-Kandidaten;
3. geprüfte API, Signatur und Version;
4. nachgewiesene Lücke;
5. kleinstmögliche verbleibende Eigenlogik;
6. erforderliche Eigentümerfreigabe;
7. benötigter DCS-Regressionsfall.

## 4. Ergebnisstatus

- TM01- und TM02-Code bleibt bis zum Abschluss der Prüfung branch- und testspezifisch.
- Historische PASS-Berichte beweisen nur ihren exakt getesteten Stand.
- Eigene Scheduler-, Movement-, Routing-, Messaging-, Marker-, FSM- und Spawnmechanismen werden gegen vorhandene MOOSE-Klassen geprüft.
- Produktionsentscheidungen werden erst im Adoptionsplan und den zugehörigen Acceptance-Berichten festgelegt.
