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
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Unterprojekt- und Branchregister

## 1. Zweck

Dieses Register bildet offene Pull Requests, ihre Abhängigkeiten, Dokumentationspfade und Acceptance-Grenzen ab. Es ersetzt keine Mergefreigabe. Draft-, Ready- und Merge-Status werden aus GitHub übernommen; eine Änderung zu Ready for Review oder ein Merge benötigt weiterhin die ausdrückliche Freigabe des Projektinhabers.

## 2. Aktuelle offene Unterprojekte

| PR | Branch | Parent/Base | Thema | Primäre Pfade | Governance-Status | Acceptance-Status | Nachfolger | Produktionsrelevanz |
|---:|---|---|---|---|---|---|---|---|
| 3 | `design/warehouses-and-concealment` | `main` | frühe Logistics-/Warehouse-/MOOSE-Baseline | `docs/`, `mission/tests/`, `vendor/moose/` | `DRAFT`; Altbestand | keine repositoryweite Acceptance | 4 | Grundlage vieler späterer Stacks; vor Integration neu bewerten |
| 4 | `feature/tm01a-bootstrap` | PR 3 | TM01A Bootstrap | `mission/tests/tm01-blue-convoy/` | `DRAFT` | DCS-Bootstrap-PASS branchgebunden | 5 | technischer Nachweis |
| 5 | `feature/tm01a-physical-spawn` | PR 4 | TM01A kontrollierter Convoy-Spawn | gleicher TM01-Pfad | `DRAFT` | Spawn-PASS branchgebunden | 6 | technischer Nachweis |
| 6 | `feature/tm01a-road-routing` | PR 5 | kontrolliertes Road Routing | gleicher TM01-Pfad | `DRAFT` | Routing-PASS branchgebunden | 7 | technischer Nachweis |
| 7 | `docs/tm01a-findings-persistence-logistics` | PR 6 | TM01A Erkenntnisse und ADRs | `docs/`, TM01-Notes | `DRAFT` | Dokumentationskonsolidierung | 8 | historische Entwicklungsbasis |
| 8 | `feature/tm01b-convoy-caching` | PR 7 | TM01B/TM01C Proxy-/Caching-Experimente | `mission/tests/tm01-blue-convoy/` | `DRAFT`; gemischter historischer Teststand | TM01B nicht akzeptiert; TM01C teilweise/PASS je Test | 9 und 22 | nicht ungeprüft als Produktionsarchitektur übernehmen |
| 9 | `feature/tm02-red-side-foundation` | PR 8 | TM02A RED Relay | `mission/tests/tm02-red-relay/` | `DRAFT` | DCS-Validation ausstehend | 10 | früher vertikaler RED-Test |
| 10 | `feature/tm02-red-tree-fill` | PR 9 | TM02N Tree Fill | gleicher RED-Pfad | `DRAFT` | DCS-Test ausstehend | 11 | frühes Baum-/Fill-Modell |
| 11 | `feature/tm02-red-loss-replenishment` | PR 10 | TM02R Loss Replenishment | gleicher RED-Pfad | `DRAFT` | DCS-Test ausstehend | 12 | früher Replenishment-Test |
| 12 | `feature/tm02-red-proxy-movement` | PR 11 | TM02V Proxy Fill | gleicher RED-Pfad | `HISTORICAL_TEST_FIXTURE` innerhalb Draft-PR | technische Teilnachweise; keine Produktionsarchitektur | 13 | ausdrücklich historisch |
| 13 | `feature/tm02w-red-network-registry` | PR 12 | TM02W1 Network Registry | `mission/tests/tm02-red-network/` | `DRAFT` | W1 DCS-PASS branchgebunden | 14 | Beginn der akzeptierten Produktionsrichtung |
| 14 | `feature/tm02w2-red-source-cost-selection` | PR 13 | TM02W2 Planner | gleicher Network-Pfad | `DRAFT` | Planner DCS-PASS branchgebunden | 15 | Planungsnachweis |
| 15 | `feature/tm02w2-red-task-execution` | PR 14 | TM02W2E Task Execution | gleicher Network-Pfad | `DRAFT` | DCS-Test ausstehend | 16 | Ausführungsprototyp |
| 16 | `feature/tm02w2f-red-initial-network-fill` | PR 15 | TM02W2F Initial Fill | gleicher RED-Pfad | `DRAFT` | DCS-Test ausstehend | offen | aktueller gestapelter RED-Testkopf |
| 17 | `agent/towns-discovery` | `main` | Towns-/Scenery-Discovery | Discovery-Dokumente und Testcode | `HISTORICAL_TEST_FIXTURE` innerhalb Draft-PR | Evidenzsammler; keine Native-DCS-Ausnahme genehmigt | offen | MOOSE-First-Neubewertung erforderlich |
| 18 | `feature/jalalabad-air-operations-diagnostics` | `main` | Jalalabad Air Operations | `mission/tests/jalalabad-air-operations/`, Dokumente 22–25 branchlokal | `DRAFT` | `ACCEPTED_TECHNICAL_BASELINE` nur für exakt dokumentierten Stand | 24 | technische Air-Ops-Baseline; nicht gemergt |
| 22 | `feature/tm01m-moose-native-baseline` | PR 8 | TM01M MOOSE-native Convoys | `mission/tests/tm01-blue-convoy/` | `DRAFT` | Ein- und Fünf-Convoy-PASS; Cleanup-Follow-up offen | offen | bevorzugte MOOSE-native Convoy-Richtung |
| 24 | `docs/bagram-air-operations-manifest` | PR 18 | Bagram/Kandahar Dokumentation | branchlokale Dokumente 31–36 | `DRAFT` | Dokumentationsabgleich; keine neue DCS-Acceptance | offen | Foundation-Build-Dokumentation |
| 34 | `agent/document-mq1-mq9-afghanistan` | `main` | MQ-1B-/MQ-9-Einsatzreferenz | branchlokale Dokumentation | `DRAFT`; Nummernkollision mit aktuellem `main` möglich | Dokumentation; keine DCS-Acceptance | offen | vor Integration fachlich prüfen und neu nummerieren |
| 36 | `agent/document-salerno-air-operations` | `main` | frühere Salerno-Air-Ops-Baseline | branchlokale Dokumente und Evidenz | `DRAFT`; durch aktuelle Salerno-Baseline abgelöst | keine neue Runtime-Acceptance | gemergte Nachfolger | historischer Vorgänger |
| 37 | `agent/document-ato-asr-aar-buddy-lasing` | `main` | ATO, ASR, Tanker und Buddy Lasing | branchlokale Dokumentation | `DRAFT`; Überlappung mit aktuellem `main` | Dokumentation; keine DCS-Acceptance | offen | nur selektiv integrieren |
| 39 | `docs/haqqani-network-reference` | `main` | Haqqani-Network-Referenz | `docs/insurgency/` | `DRAFT`; Überlappung mit späteren RED-Dokumenten | keine Runtime-Acceptance | offen | Dubletten-/Autoritätsprüfung erforderlich |
| 40 | `docs/tarinkot-air-operations-baseline` | früherer Foundation-Stack | Tarinkot-ME-/Air-Ops-Vorgänger | Tarinkot-Dokumentation/Evidenz | `DRAFT`; durch gemergten aktuellen Tarinkot-Stand abgelöst | branchgebundene Strukturbelege | gemergter Nachfolger | historischer Vorgänger |
| 41 | `agent/document-shindand-air-operations` | früherer Foundation-Stack | Shindand-Air-Ops-Vorgänger | Shindand-Dokumentation/Evidenz | `DRAFT`; aktuelle Shindand-Foundation inzwischen auf `main` | branchgebundene Strukturbelege | PR 65 gemergt | historischer Vorgänger |
| 45 | `agent/document-ch47-pool-allocation` | `main` | CH-47-Verteilung | branchlokale Dokumentation/Evidenz | `DRAFT`; Nummernkollision möglich | Dokumentation | offen | vor Integration abgleichen |
| 49 | `agent/next-airport-airwing-squadron-handoff` | `main` | frühere Air-Ops-Auswahlübergabe | Handoff/README | `DRAFT`; durch spätere Airfield-Arbeit überholt | keine Runtime-Acceptance | 51, 52, 53, 60, 61, 63, 65 | historisches Handoff |
| 50 | `docs/bagram-air-operations-manifest` | `main` | alter Air-Ops-Sammelbranch | umfangreiche historische Air-Ops-Dateien | offen; stark überholt und kollidierend | gemischte branchgebundene Nachweise | selektive Main-Merges | nicht als Ganzes integrieren |
| 52 | `agent/salerno-read-only-diagnostics` | alter Air-Ops-Stack | Salerno COMMANDER-/Runtime-Historie | Tests/Builder/Evidenz | `DRAFT`; kanonische Foundation auf `main` | `ACCEPTED_TECHNICAL_BASELINE` für dokumentierten Stage-18-Stand | offen | technische Fixture-/Runtime-Historie |
| 66–84 | Warehouse-/CampaignState-/STORAGE-Stack | PR 66 startete von `main`; danach gestapelt | Resource ownership, Fuel/Weapon STORAGE, CampaignState transactions, loss/recovery, final fighter mapping | `scripts/campaign/`, `scripts/logistics/`, Warehouse-Testfixtures und branchgebundene Detaildokumentation | offene Draft-Historie; keine pauschale Main-Autorität | mehrere exakt dokumentierte DCS-Acceptance-Stände; finaler Fighter-Gate PASS | 85 | nicht als 214-Commit-Stack direkt integrieren; PR 85 war der saubere Main-Reconciliation-Pfad |
| 86 | `agent/air-ops-initial-stock-runtime-data` | `main` nach gemergtem PR 85 | AirOps Initial Stock Runtime, CampaignState-Initialisierung und zentraler Warehouse-Bootstrap | `scripts/logistics/`, `mission/tests/air-ops-warehouse-bootstrap/`, MOOSE-STORAGE-Dokumentation | `DRAFT`; aktuell nicht mergebar gegen `main` | `ACCEPTED_TECHNICAL_BASELINE` für Warehouse-Bootstrap auf Commit `2502516fe130b908e500117142399b3e2ca74007`; separate Onboard-Ammo-Acceptance offen | offen | Warehouse-Bootstrap technisch akzeptiert; vor Integration Reconciliation gegen aktuellen `main` erforderlich |
| 112 | `agent/ground-ammo-rearm-integration` | `main` | Ground ammo rearm lifecycle / fixed fire support | `scripts/campaign/`, `scripts/ground/`, `scripts/logistics/`, `mission/tests/ground-ammo-rearm-integration/`, `docs/moose/FIXED-FIRE-SUPPORT-REARM.md` | `DRAFT`; owner-gated Ready/Merge | `ACCEPTED_TECHNICAL_BASELINE` für Acceptance 2-11 auf `d52a47a418fe3a1a996a5b68198b8dc033ff86c4`; DCS 2.9.28.26385 MT; MIZ SHA-256 `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620`; externer Prozess-Persistence-Host nicht getestet/nicht behauptet | offen | MOOSE-first fixed-fire-support rearm; CampaignState bleibt alleinige strategische Ressourcenautorität |

Der Arbeitsbranch `agent/army-ground-foundation-reconciliation` besitzt zum Stand dieser Reconciliation noch keinen Pull Request und wird daher nicht mit einer erfundenen PR-Nummer in die Tabelle aufgenommen. Sobald ein PR existiert, ist er hier mit realem PR-Status und Abhängigkeit nachzutragen.

## 3. Stackstruktur

```text
main
├── PR 3 → 4 → 5 → 6 → 7 → 8
│   ├── PR 9 → 10 → 11 → 12 → 13 → 14 → 15 → 16
│   └── PR 22
├── PR 17
├── PR 18 → PR 24
│           ├── PR 50
│           └── PR 52
├── PR 34
├── PR 36
├── PR 37
├── PR 39
├── PR 40
├── PR 41
├── PR 45
├── PR 49
└── PR 66 → ... → PR 84
                    └── PR 85 (merged clean Warehouse reconciliation)

main
├── PR 86 (AirOps initial-stock runtime and accepted Warehouse bootstrap; reconciliation required)
└── PR 112 (Ground ammo rearm lifecycle; Acceptance 2-11 accepted technical baseline; owner-gated Ready/Merge)
```

PR #53 (Tarinkot), PR #60 (Salerno Foundation), PR #61 (Kandahar Foundation), PR #62 (Dokumentationsmetadaten), PR #63 (Bagram duale AIRWING Foundation), PR #64 (AIRWING-Naming-Reconciliation), PR #65 (Shindand Foundation), PR #85 (Warehouse Main Reconciliation) und PR #108 (Kunar Ground Site Reconciliation / FOB Bostick) sind nach `main` gemergt und werden nicht mehr als offene aktuelle Foundation-Unterprojekte geführt.

Für PR #108 ist der reale GitHub-Merge-Stand:

```text
PR: 108
status: MERGED
merge_commit: 08f679926e5ac059e9853f54ffa7bb634063eaa4
```

## 4. Verbindliche Regeln

1. Ein branchgebundener PASS gilt nur für den dokumentierten Branch-, Commit-, Missions-, DCS- und MOOSE-Stand.
2. Gestapelte Nachfolger erben das Änderungs- und Verwerfungsrisiko des Parent-Branches.
3. Ein offener Draft-PR ist keine `main`-Autorität.
4. `HISTORICAL_TEST_FIXTURE` darf nicht als Produktionsarchitektur verwendet werden.
5. Merge und „Ready for Review“ benötigen weiterhin die ausdrückliche Freigabe des Projektinhabers.
6. Dieses Register wird bei Öffnen, Schließen, Retargeting, Neubau oder Ablösung eines dokumentationsrelevanten PR aktualisiert.

## 5. Registerabgleich vom 13. August 2026

```yaml
warehouse_source_stack: PR_66_THROUGH_PR_84_OPEN_DRAFT_HISTORY
warehouse_clean_integration_pr: 85
warehouse_clean_integration_status: MERGED
warehouse_clean_integration_merge_commit: 3b4d2470639409e9a82ceed0fee85aa0627c0b3c
warehouse_runtime_pr: 86
warehouse_runtime_branch: agent/air-ops-initial-stock-runtime-data
warehouse_runtime_status: OPEN_DRAFT_NOT_MERGEABLE
warehouse_bootstrap_acceptance_commit: 2502516fe130b908e500117142399b3e2ca74007
warehouse_bootstrap_acceptance_status: ACCEPTED_TECHNICAL_BASELINE
warehouse_runtime_main_at_merge_assessment: 3223db1f7eb130ae2070a926b6f476e6a010f515
warehouse_runtime_branch_relation: DIVERGED
warehouse_foundation_decision_block: CLOSED
source: GitHub pull-request state plus documented exact-provenance DCS evidence
```

Ein offener Zustand bedeutet weder aktuelle fachliche Autorität noch Integrationsreife; die Spalten Governance-Status, Acceptance-Status und Produktionsrelevanz bleiben maßgeblich.
