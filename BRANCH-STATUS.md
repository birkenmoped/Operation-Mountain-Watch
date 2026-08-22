---
document_id: OMW-BRANCH-STATUS-MISSION-DEMAND-LEGACY
status: HISTORICAL_TEST_FIXTURE
document_class: BRANCH_STATUS
owning_policy: OMW-GOV-001
authoritative_for:
  - archival status of agent/mission-demand-resupply-cas-concept
not_authoritative_for:
  - current MissionDemand architecture
  - current RESUPPLY thresholds
  - current CAS runtime implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - main via PR #114 MissionDemand Domain Foundation
  - main via PR #115 Ground RESUPPLY thresholds
source_branch: agent/mission-demand-resupply-cas-concept
source_commit: SELF
validated_in_dcs: false
---

# Branch Status – archived / superseded

Dieser Branch ist ein historischer Entwicklungs- und Konzeptstand und darf nicht mehr als aktuelle Projektbaseline verwendet werden.

Aktuelle Autoritaet fuer das Thema liegt auf `main`.

Reconciliierte Nachfolger:

```text
agent/mission-demand-reconciliation
-> PR #114
-> MissionDemand Domain Foundation merged to main

agent/mission-demand-resupply-thresholds
-> PR #115
-> Ground RESUPPLY thresholds merged to main
```

Verbindliche Schwellen auf `main`:

```text
reorder  = 50% of target
critical = 25% of target
```

Dieser Branch ist daher fuer neue Entwicklung nicht fortzusetzen und nicht als Merge-Quelle zu verwenden.

Wichtig: Der Branch besitzt weiterhin historische, branch-eigene Commits. Diese werden nicht pauschal als wertlos oder vollstaendig in `main` enthalten bezeichnet. Sie gelten als Legacy-/Historienmaterial und muessen bei einer spaeteren Einzelfallnutzung erneut gegen die aktuelle Governance, `main` und MOOSE-First reconciliiert werden.

Status:

```text
ACTIVE DEVELOPMENT: NO
PROJECT AUTHORITY: NO
MERGE WHOLE BRANCH: NO
HISTORICAL REFERENCE: YES
CURRENT SOURCE OF TRUTH: main
```
