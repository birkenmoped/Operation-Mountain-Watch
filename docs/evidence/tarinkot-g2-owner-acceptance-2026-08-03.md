---
document_id: OMW-DECISION-TARINKOT-G2-OWNER-ACCEPTANCE-2026-08-03
status: BINDING_PROJECT_DECISION
document_class: PROJECT_OWNER_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - explicit owner acceptance of the complete Tarinkot G2 object contract
  - authorization and completion boundary for G4 MOOSE 2.9.18 source review
  - continued implementation lock against runtime activation before the relevant gate
not_authoritative_for:
  - DCS runtime acceptance
  - AI parking suitability
  - G5 or later test acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: TARINKOT_MOOSE_SOURCE_REVIEW_COMPLETE
decision_date: 2026-08-03
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
accepted_branch_head: 110c3f943f25d45ca2825ed7e788a959fb28c3a2
accepted_checklist: docs/evidence/tarinkot-g2-object-contract-acceptance-checklist-2026-08-03.md
source_mission: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: false
supersedes:
  - pending-owner-acceptance state recorded in the original Tarinkot G2 checklist
superseded_by: []
---

# Tarinkot – Eigentümerabnahme des vollständigen G2-Objektvertrags

## 1. Entscheidung

Der Projekteigentümer hat am 03.08.2026 mit der Anweisung `ok, go on` den vollständigen Tarinkot-G2-Objektvertrag ausdrücklich angenommen.

Angenommen sind damit insbesondere:

```text
historische Arbeitsbaseline:
März bis Dezember 2011

AIRWING:
AW_US_TKOT_TF_ATTACK_3_101_AVN

SQUADRONs:
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN

lokaler OMW-Nominalbestand:
14 AH-64D
 6 UH-60
 2 CH-47
 0 OH-58D

Warehouse:
WH_AIR_US_TARINKOT

DCS-Repräsentation:
historischer CH-47D wird durch CH-47Fbl1 technisch vertreten
```

Ebenfalls angenommen sind das Darstellungsledger, die Client-Reservierungen, die zunächst leeren KI-Parking-Allowlisten sowie die Zone-/Gate-Abhängigkeiten aus der G2-Checkliste.

## 2. Gate-Status

```yaml
G0_provenance: PASS_BRANCH
G1_ORBAT_and_evidence: PASS_BRANCH
G2_object_contract: OWNER_ACCEPTED_BRANCH
G3_mission_editor: PARTIAL
G4_MOOSE_source_review: PASS_SOURCE_REVIEW
G5_read_only_diagnostics: AUTHORIZED_NOT_STARTED
```

## 3. Freigabegrenze

Die Entscheidung autorisierte G4. G4 ist inzwischen mit der exakten eingebetteten MOOSE-Version 2.9.18 abgeschlossen und dokumentiert in:

```text
docs/evidence/tarinkot-g4-moose-2-9-18-source-review.md
```

Als nächster Schritt ist ausschließlich das isolierte read-only G5-Diagnosebundle zugelassen.

Nicht autorisiert sind weiterhin:

```text
operative AIRWING-/SQUADRON-Aktivierung
Payloadregistrierung in der Mission
Assets anfordern oder spawnen
AUFTRAG-Ausführung
COMMANDER-Ausführung
OPSTRANSPORT-Ausführung
MIZ-Änderungen
Merge oder Ready for Review
```

## 4. Verhältnis zur G2-Checkliste

Die G2-Checkliste enthält den vollständigen technischen Vertragsinhalt. Dieses Dokument ist der zugehörige Eigentümer-Abnahmenachweis.
