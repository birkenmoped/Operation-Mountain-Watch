---
document_id: OMW-SP-LLM-COMMANDERS-INDEX
status: DRAFT_OPTIONAL_PROJECT
document_class: SPECIAL_PROJECT_CHARTER
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Optionales Spezialprojekt: Multi-LLM Commander Campaign

## 1. Zweck

Dieses Spezialprojekt untersucht eine eigenständige DCS-Kampagnenform, in der ein BLUE Commander gegen drei voneinander getrennte RED Commander antritt:

```text
BLUE_COMMANDER

gegen

TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Die vorhandene Dokumentation von Operation Mountain Watch dient als historische, geographische, taktische und technische Quellenbasis. Bestehende Hauptprojektentscheidungen zugunsten eines konsolidierten RED Commanders begrenzen dieses Spezialprojekt ausdrücklich nicht.

## 2. Projektstatus und Abgrenzung

```text
OPTIONAL_SPECIAL_PROJECT
NOT_MAIN_PROJECT_AUTHORITY
NOT_RUNTIME_ACCEPTED
NOT_MERGE_READY
```

Der Projektzweig darf eigene Entscheidungen zu folgenden Punkten treffen:

- getrennte Fraktionen und Ressourcenpools;
- getrennte Commander-Instanzen;
- Fraktionsbeziehungen, Kooperation und Konkurrenz;
- unvollständige und widersprüchliche Lagebilder;
- Verhandlungen, Unterstützungsanfragen und Ressourcentransfers;
- eigenständige strategische Ziele und Erfolgskriterien;
- ein BLUE-Commander-Modell als vierte LLM-Instanz.

Er verändert ohne gesonderte Entscheidung weder die Hauptprojektarchitektur noch bestehende verbindliche Dokumente auf `main`.

## 3. Historische Modellierungsregel

Jede Aussage wird einer der folgenden Klassen zugeordnet:

```text
SOURCE_DOCUMENTED
SOURCE_REPORTED_UNCORROBORATED
ANALYTICAL_INFERENCE
SIMULATION_ABSTRACTION
DESIGN_DECISION
UNKNOWN
```

Insbesondere gilt:

```text
historical_relationship != permanent_runtime_alliance
formal_subordination != complete_operational_control
shared_enemy != shared_resources
local_cooperation != strategic_unity
reported_strength != DCS_spawn_count
```

## 4. Zielarchitektur

Jeder Commander erhält getrennt:

- strategische Zielhierarchie;
- Führungs- und Persönlichkeitsprofil;
- eigenes Ressourcen- und Netzwerkmodell;
- eigenes, begrenztes Lagebild;
- eigene Annahmen und Fehleinschätzungen;
- regionale Interessen und Reichweite;
- lokale Unterkommandeure mit begrenzter Loyalität;
- Beziehungen zu den übrigen Commandern;
- zulässige strategische und operative Aktionen;
- harte technische Grenzen und weiche Verhaltenspräferenzen.

LLM-Ausgaben sind keine direkten DCS- oder Lua-Befehle. Sie werden durch eine deterministische Orchestrierungs- und Plausibilisierungsschicht geprüft.

```text
DCS_WORLD_STATE
-> FACTION_INFORMATION_FILTER
-> COMMANDER_BELIEF_STATE
-> LLM_DECISION
-> RULE_AND_RESOURCE_VALIDATION
-> EXECUTION_PLAN
-> MOOSE_OR_DCS_RUNTIME
```

## 5. Commander-Rollen

### 5.1 Taliban Commander

Schwerpunkt:

- landesweite politische und militärische Kampagne;
- Shadow Governance und Shadow Justice;
- Distrikt- und Provinzstrukturen;
- Bevölkerungskontrolle, Einschüchterung und Mobilisierung;
- strategische Kohäsion bei lokaler Ausführungsautonomie;
- langfristige Verdrängung staatlicher und ausländischer Kontrolle.

### 5.2 Haqqani Commander

Schwerpunkt:

- familien- und beziehungsgebundenes Netzwerk;
- externe Sanctuary-, Facilitation- und Spezialistenkanäle;
- hohe Operationssicherheit und Compartmentation;
- regionale Verankerung in Loya Paktia bei überregionaler Reichweite;
- Zusammenstellung komplexer Capability Packages;
- hohe Bedeutung psychologischer und medialer Wirkung.

### 5.3 HIG Commander

Schwerpunkt:

- eigenständige politische und militärische Organisation;
- regionale Kommandeurs- und Patronagenetzwerke;
- größere Verhandlungs- und Deal-Fähigkeit;
- opportunistische lokale Kooperation;
- Konkurrenz um Territorium, Steuern, Verkehrsachsen und politische Repräsentation;
- schwächere militärische Kohäsion bei zugleich hoher politischer Anschlussfähigkeit.

## 6. Fraktionsbeziehungen

Beziehungen werden nicht auf `ALLY`, `NEUTRAL` oder `ENEMY` reduziert. Mindestdimensionen:

```yaml
relationship_state:
  ideological_alignment: 0..100
  strategic_goal_overlap: 0..100
  personal_trust: 0..100
  operational_cooperation: 0..100
  intelligence_sharing: 0..100
  logistics_access: 0..100
  territorial_competition: 0..100
  recruitment_competition: 0..100
  revenue_competition: 0..100
  leadership_rivalry: 0..100
  betrayal_risk: 0..100
  armed_conflict_risk: 0..100
```

Beziehungen sind regional, zeitabhängig und ereignisgetrieben. Derselbe Akteur kann in einem Sektor kooperieren und in einem anderen konkurrieren.

## 7. Sicherheits- und Abstraktionsgrenze

Das Projekt modelliert militärische und politische Entscheidungslogik für eine Simulation. Es dokumentiert keine technischen Herstellungsanleitungen für Waffen, Sprengmittel oder reale Anschläge. Taktische Fähigkeiten werden als abstrakte Ressourcen, Missionsklassen und Capability Gates geführt.

## 8. Geplante Dokumente

```text
README.md
01-source-inventory-and-faction-baseline.md
02-common-commander-model.md
03-inter-faction-relations.md
04-information-belief-and-deception-model.md
05-taliban-dossier.md
06-haqqani-dossier.md
07-hig-dossier.md
08-blue-commander-dossier.md
09-action-and-negotiation-schema.md
10-adjudication-and-runtime-architecture.md
11-test-scenarios-and-acceptance.md
```

## 9. Arbeitsreihenfolge

1. Quelleninventar und Quellenkritik;
2. historische Fraktionsdossiers;
3. getrennte Commander-Persönlichkeiten und Zielhierarchien;
4. Fraktionsbeziehungen und Konfliktmechanik;
5. Informations-, Erinnerungs- und Täuschungsmodell;
6. maschinenlesbares Aktionsschema;
7. Runtime-Orchestrierung;
8. isolierte Szenariotests;
9. DCS-/MOOSE-Integration erst nach stabiler Entscheidungslogik.
