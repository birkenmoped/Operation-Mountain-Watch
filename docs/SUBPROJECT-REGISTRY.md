---
document_id: OMW-GOV-SUBPROJECT-REGISTRY
status: BINDING
document_class: SUBPROJECT_REGISTRY
owning_policy: OMW-GOV-001
authoritative_for:
  - inventory and dependency structure of open project pull requests
  - distinction between branch acceptance and main-branch authority
not_authoritative_for:
  - merge approval
  - runtime acceptance beyond the cited pull-request evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - incomplete open-branch list in the documentation index
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Unterprojekt- und Branchregister

## 1. Zweck

Dieses Register bildet offene Pull Requests, ihre Abhängigkeiten, Dokumentationspfade und Acceptance-Grenzen ab. Es ersetzt keine Mergefreigabe. Jeder PR bleibt Draft, solange der Projektinhaber keine andere Entscheidung trifft.

## 2. Aktuelle offene Unterprojekte

| PR | Branch | Parent/Base | Thema | Primäre Pfade | Governance-Status | Acceptance-Status | Nachfolger | Produktionsrelevanz |
|---:|---|---|---|---|---|---|---|---|
| 3 | `design/warehouses-and-concealment` | `main` | frühe Logistics-/Warehouse-/MOOSE-Baseline | `docs/`, `mission/tests/`, `vendor/moose/` | `DRAFT`; Altbestand | keine repositoryweite Acceptance | 4 | Grundlage vieler späterer Stacks; vor Integration neu bewerten |
| 4 | `feature/tm01a-bootstrap` | PR 3 | TM01A Bootstrap | `mission/tests/tm01-blue-convoy/` | `DRAFT` | DCS-Bootstrap-PASS branchgebunden | 5 | technischer Nachweis |
| 5 | `feature/tm01a-physical-spawn` | PR 4 | kontrollierter Convoy-Spawn | gleicher TM01-Pfad | `DRAFT` | Spawn-PASS branchgebunden | 6 | technischer Nachweis |
| 6 | `feature/tm01a-road-routing` | PR 5 | kontrolliertes Road Routing | gleicher TM01-Pfad | `DRAFT` | Routing-PASS branchgebunden | 7 | technischer Nachweis |
| 7 | `docs/tm01a-findings-persistence-logistics` | PR 6 | TM01A Erkenntnisse und ADRs | `docs/`, TM01-Notes | `DRAFT` | Dokumentationskonsolidierung | 8 | historische Entwicklungsbasis |
| 8 | `feature/tm01b-convoy-caching` | PR 7 | TM01B/TM01C Proxy-/Caching-Experimente | `mission/tests/tm01-blue-convoy/` | `DRAFT`; gemischter historischer Teststand | TM01B nicht akzeptiert; TM01C teilweise/PASS je Test | 9 und 22 | nicht ungeprüft als Produktionsarchitektur übernehmen |
| 9 | `feature/tm02-red-side-foundation` | PR 8 | TM02A RED Relay | `mission/tests/tm02-red-relay/` | `DRAFT` | DCS-Validation ausstehend | 10 | früher vertikaler RED-Test |
| 10 | `feature/tm02-red-tree-fill` | PR 9 | TM02N Tree Fill | gleicher RED-Pfad | `DRAFT` | Version 2 DCS-Test ausstehend | 11 | frühes Baum-/Fill-Modell |
| 11 | `feature/tm02-red-loss-replenishment` | PR 10 | TM02R Loss Replenishment | gleicher RED-Pfad | `DRAFT` | DCS-Test ausstehend | 12 | früher Replenishment-Test |
| 12 | `feature/tm02-red-proxy-movement` | PR 11 | TM02V Proxy Fill | gleicher RED-Pfad | `HISTORICAL_TEST_FIXTURE` innerhalb Draft-PR | technische Teilnachweise; keine Produktionsarchitektur | 13 | ausdrücklich historisch |
| 13 | `feature/tm02w-red-network-registry` | PR 12 | TM02W1 Network Registry | `mission/tests/tm02-red-network/` | `DRAFT` | W1 DCS-PASS branchgebunden | 14 | Beginn der akzeptierten Produktionsrichtung |
| 14 | `feature/tm02w2-red-source-cost-selection` | PR 13 | TM02W2 Planner | gleicher Network-Pfad | `DRAFT` | Planner DCS-PASS branchgebunden | 15 | Planungsnachweis |
| 15 | `feature/tm02w2-red-task-execution` | PR 14 | TM02W2E Task Execution | gleicher Network-Pfad | `DRAFT` | DCS-Test ausstehend | 16 | Ausführungsprototyp |
| 16 | `feature/tm02w2f-red-initial-network-fill` | PR 15 | TM02W2F Initial Fill | gleicher Network-Pfad | `DRAFT` | DCS-Test ausstehend | offen | aktueller gestapelter RED-Testkopf |
| 17 | `agent/towns-discovery` | `main` | Towns-/Scenery-Discovery | Discovery-Dokumente und Testcode | `HISTORICAL_TEST_FIXTURE` innerhalb Draft-PR | Evidenzsammler; keine Native-DCS-Ausnahme genehmigt | offen | MOOSE-First-Neubewertung erforderlich |
| 18 | `feature/jalalabad-air-operations-diagnostics` | `main` | Jalalabad Air Operations | `mission/tests/jalalabad-air-operations/`, Dokumente 22–25 branchlokal | `DRAFT` | `ACCEPTED_TECHNICAL_BASELINE` nur für exakt dokumentierten Stand | 24 | technische Air-Ops-Baseline; nicht gemergt |
| 22 | `feature/tm01m-moose-native-baseline` | PR 8 | TM01M MOOSE-native Convoys | `mission/tests/tm01-blue-convoy/` | `DRAFT` | Ein- und Fünf-Convoy-PASS; Cleanup-Follow-up offen | offen | bevorzugte MOOSE-native Convoy-Richtung |
| 24 | `docs/bagram-air-operations-manifest` | PR 18 | Bagram/Kandahar Dokumentation | branchlokale Dokumente 31–36 | `DRAFT` | Dokumentationsabgleich; keine neue DCS-Acceptance | offen | Foundation-Build-Dokumentation |
| 33 | `agent/complete-documentation-authority-migration` | `main` | Governance-, Status- und Indexmigration | `docs/`, ausgewählte Test-READMEs, Validator | `DRAFT` | Dokumentationsvalidator erfolgreich; keine Runtime-Acceptance | offen | Ziel dieses Registers |

## 3. Stackstruktur

```text
main
├── PR 3 → 4 → 5 → 6 → 7 → 8
│   ├── PR 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16
│   └── PR 22
├── PR 17
├── PR 18 → PR 24
└── PR 33
```

## 4. Verbindliche Regeln

1. Ein branchgebundener PASS gilt nur für den dokumentierten Branch-, Commit-, Missions-, DCS- und MOOSE-Stand.
2. Gestapelte Nachfolger erben das Änderungs- und Verwerfungsrisiko des Parent-Branches.
3. Ein offener Draft-PR ist keine `main`-Autorität.
4. `HISTORICAL_TEST_FIXTURE` darf nicht als Produktionsarchitektur verwendet werden.
5. Merge und „Ready for Review“ benötigen weiterhin die ausdrückliche Freigabe des Projektinhabers.
6. Dieses Register wird bei Öffnen, Schließen, Retargeting, Neubau oder Ablösung eines dokumentationsrelevanten PR aktualisiert.

## 5. Synchronisierungsnachweis PR #33

```yaml
base_branch: main
integrated_main_commit: 56fb6b99cf06d699167dfd17a8c2abf626d7da13
synchronization_pr: 35
synchronization_merge_commit: 41d10ee4c866bace086b34263de31912c37000bb
behind_main_at_sync: 0
ready_for_review: false
merged_to_main: false
```

PR #35 war ein technischer Reverse-PR von `main` in den PR-#33-Branch. Er veränderte `main` nicht und begründet keine Mergefreigabe für PR #33.
