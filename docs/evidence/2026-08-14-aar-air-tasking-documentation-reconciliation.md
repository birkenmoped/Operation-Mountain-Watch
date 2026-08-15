---
document_id: OMW-EVIDENCE-AAR-AIR-TASKING-RECONCILIATION-2026-08-14
status: HISTORICAL_TEST_FIXTURE
document_class: EVIDENCE_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - historical record of the 2026-08-14 AAR and air-tasking documentation reconciliation
not_authoritative_for:
  - current AAR architecture
  - current DCS or MOOSE acceptance status
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AAR-/Air-Tasking-Dokumentations-Reconciliation vom 14.08.2026

Der historische Branch `agent/document-ato-asr-aar-buddy-lasing` (PR #37, Head `c73c9bc7eec11a625fe6ff49f8caef405c641a11`) wurde bei der AAR-Bereinigung in die `main`-Historie aufgenommen.

Die damaligen getrennten Entwürfe werden **nicht** wieder als aktuelle nummerierte Projektdokumente hergestellt. Ihre Themen wurden inzwischen in der aktuellen `main`-Dokumentation konsolidiert oder fortentwickelt:

- AAR-Planung und aktuelle OMW-AAR-Entscheidungen: `docs/29-isaf-2009-2013-air-to-air-refueling.md`
- Air-C2/CAS-Grundlagen: `docs/45-air-c2-cas-afghanistan.md`
- ATO-/ACO-/SPINS-, JTAR-/ASR-, AAR- und Buddy-Lasing-Datenmodell sowie Quellenabgrenzung: `docs/54-air-tasking-airspace-control-cas-requests-and-mission-data.md`

Die früheren Branch-Dateien `docs/54-air-tasking-order-aco-spins.md`, `docs/55-jtar-asr-air-support-request.md` und `docs/56-buddy-lasing-phraseology.md` werden nicht auf ihre alten Pfade zurückkopiert, weil die Dokumentnummern 55 und 56 auf `main` inzwischen anderen aktuellen Dokumenten zugeordnet sind und Dokument 54 die betreffenden Themen konsolidiert.

Die vollständigen historischen Inhalte bleiben über die Merge-Ancestry des Branch-Heads reproduzierbar. Diese Reconciliation hebt keine ältere Aussage über die aktuelle Governance-, AAR-, DCS- oder MOOSE-Baseline an; ausschließlich die aktuellen autoritativen Dokumente auf `main` gelten.
