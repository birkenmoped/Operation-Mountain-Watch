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
source_branch: agent/reconcile-main-documentation-phase1
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
| 34 | `agent/document-mq1-mq9-afghanistan` | `main` | MQ-1B-/MQ-9-Einsatzreferenz | `docs/50-mq1-mq9-afghanistan-employment.md`, Register | `DRAFT`; Dokumentnummer 50 kollidiert mit dem aktuellen `main`-Bestand | Dokumentation; keine DCS-Acceptance | offen | vor Integration fachlich prüfen, rebasen und neu nummerieren |
| 36 | `agent/document-salerno-air-operations` | `main` | frühere Salerno-Air-Ops-Baseline | branchlokale Dokumente 51–53 und Evidenz | `DRAFT`; durch Dokument 81 und den Merge von PR #51 fachlich abgelöst | keine neue Runtime-Acceptance | PR 51 (gemergt) und PR 52 | historischer Vorgänger; nicht als aktuelle Salerno-Baseline integrieren |
| 37 | `agent/document-ato-asr-aar-buddy-lasing` | `main` | ATO, ASR, Tanker und Buddy Lasing | Dokumente 29, 45 und branchlokale Dokumente 54–56 | `DRAFT`; Nummern und Inhalte überlappen den heutigen `main`-Bestand | Dokumentation; keine DCS-Acceptance | offen | vor selektiver Integration fachlich vergleichen und neu nummerieren |
| 39 | `docs/haqqani-network-reference` | `main` | Haqqani-Network-Referenz | `docs/insurgency/haqqani-network.md`, Register und Indizes | `DRAFT`; inhaltliche Überlappung mit späteren RED-/Netzwerkdokumenten auf `main` | Dokumentation; keine Runtime-Acceptance | offen | nur nach Dubletten- und Autoritätsprüfung integrieren |
| 40 | `docs/tarinkot-air-operations-baseline` | `docs/afghanistan-force-aviation-source-consolidation` / PR #38, inzwischen gemergt | Tarinkot-ME- und Air-Ops-Baseline | Tarinkot-Manifest und Evidenz | `DRAFT`; technischer Vorgänger von PR #53 | struktureller ME-Nachweis; keine vollständige Runtime-Acceptance | 53 | nicht unabhängig von PR #53 weiterführen |
| 41 | `agent/document-shindand-air-operations` | `docs/afghanistan-force-aviation-source-consolidation` / PR #38, inzwischen gemergt | Shindand-Air-Ops-Baseline | Shindand-Manifest, Handoff und Evidenz | `DRAFT`; Basisbranch wurde gemergt, Branch muss vor Integration neu abgeglichen werden | Mission-Editor-Struktur branchgebunden; Runtime nicht gelaufen | offen | offene Shindand-Foundation-Baseline |
| 45 | `agent/document-ch47-pool-allocation` | `main` | CH-47-Verteilung Bagram/Salerno/Shank | branchlokales Dokument 54 und Evidenz | `DRAFT`; Dokumentnummer 54 kollidiert mit dem aktuellen `main`-Bestand | Dokumentation; keine Runtime-Acceptance | offen | Bestandsentscheidung vor Integration abgleichen und neu nummerieren |
| 49 | `agent/next-airport-airwing-squadron-handoff` | `main` | frühere Auswahlübergabe für den nächsten Air-Ops-Knoten | Handoff und README | `DRAFT`; Auswahlstand durch nachfolgende Salerno- und Tarinkot-Arbeit überholt | keine Runtime-Acceptance | 51, 52 und 53 | historisches Handoff; keine aktuelle Arbeitsanweisung |
| 50 | `docs/bagram-air-operations-manifest` | `main` | Sammelintegration des alten Air-Ops-Branches | 150 Dateien aus Bagram, Jalalabad und Kandahar | offen, nicht Draft; stark überholt und mit `main` kollidierend | gemischte branchgebundene Nachweise; keine pauschale `main`-Acceptance | selektive spätere Main-Merges | nicht als Ganzes integrieren; nur datei- und autoritätsbezogen auswerten |
| 52 | `agent/salerno-read-only-diagnostics` | `docs/bagram-air-operations-manifest` | Salerno AIRWING/SQUADRON und COMMANDER-Runtime | `mission/tests/salerno-air-operations/`, Builder und technische Evidenz | `DRAFT`; kanonische Salerno-Dokumentation wurde über PR #51 nach `main` übernommen | `ACCEPTED_TECHNICAL_BASELINE` für den exakt dokumentierten Stage-18-Stand; Parking-Zuweisung nicht akzeptiert | offen | technische Salerno-Fixtures und Runtime-Historie |
| 53 | `agent/tarinkot-object-contract-reconciliation` | `main` | Tarinkot-Objektvertrag und nativer G8-Dispatch | `mission/tests/tarinkot-air-operations/` und zugehörige Evidenz | `DRAFT`; MOOSE-Parking-Override-Recherche abgeschlossen, Eigentümerentscheidung ausstehend | G7 branchgebunden akzeptiert; G8 durch WAREHOUSE-Parking blockiert; vertikaler Abflug nicht belegt | Eigentümerentscheidung A–E | aktueller Tarinkot-Technikzweig; DCS-Rerun, MIZ-/Parking-Änderung und MOOSE-Override bleiben gesperrt |

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
└── PR 53
```

## 4. Verbindliche Regeln

1. Ein branchgebundener PASS gilt nur für den dokumentierten Branch-, Commit-, Missions-, DCS- und MOOSE-Stand.
2. Gestapelte Nachfolger erben das Änderungs- und Verwerfungsrisiko des Parent-Branches.
3. Ein offener Draft-PR ist keine `main`-Autorität.
4. `HISTORICAL_TEST_FIXTURE` darf nicht als Produktionsarchitektur verwendet werden.
5. Merge und „Ready for Review“ benötigen weiterhin die ausdrückliche Freigabe des Projektinhabers.
6. Dieses Register wird bei Öffnen, Schließen, Retargeting, Neubau oder Ablösung eines dokumentationsrelevanten PR aktualisiert.

## 5. Registerabgleich vom 5. August 2026

```yaml
main_commit: cf1b5ff138c6cb5e59e0070f7ba8aef4cfb3823a
open_pull_requests: 29
pr_33: MERGED
pr_38: MERGED
source: GitHub pull-request state
```

Die 29 offenen PRs sind in Abschnitt 2 vollständig erfasst. Ein offener Zustand bedeutet weder aktuelle fachliche Autorität noch Integrationsreife; die Spalten Governance-Status, Acceptance-Status und Produktionsrelevanz bleiben maßgeblich.
