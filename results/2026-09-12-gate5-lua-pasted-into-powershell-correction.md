---
document_id: OMW-RESULT-GATE5-LUA-POWERSHELL-CORRECTION
status: HISTORICAL_TEST_FIXTURE
authoritative_for:
  - documentation of the mistaken local execution instruction during Gate 5 runtime staging
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5 - Korrektur: Lua-Code wurde faelschlich als lokaler PowerShell-Schritt vermittelt

## Ereignis

Am 12.09.2026 wurde dem Projektinhaber ein neuer Gate-5-Lua-Test im Chat als Quelltext gezeigt, obwohl der Source zu diesem Zeitpunkt wegen eines blockierten GitHub-Write-Aufrufs noch nicht als versionierte Datei samt Builder im Branch veroeffentlicht war.

Der Projektinhaber fuehrte den gezeigten Lua-Text daraufhin in der lokalen PowerShell aus. PowerShell interpretierte Lua-Schluesselwoerter und Syntax (`local`, `function`, `if ... then`, `--`, `..`, Tabellenliterale usw.) als PowerShell und erzeugte entsprechend Parser- und CommandNotFound-Fehler.

## Bewertung

Diese Ausgabe ist **kein Lua-Test**, **kein DCS-Test** und **kein Fehlernachweis des geplanten Gate-5-Runtime-Codes**. Es wurde kein Lua-Interpreter gestartet und DCS wurde nicht beteiligt.

Der Fehler lag im Arbeitsablauf: Ein noch nicht versionierter Lua-Source wurde in einer Form geliefert, die als lokale Handlungsanweisung missverstanden werden konnte. Das widerspricht dem festgelegten Workflow, nach dem ChatGPT den Source selbst im Branch erstellt, prueft, committed und remote veroeffentlicht und der Projektinhaber danach ausschliesslich die notwendige nummerierte PowerShell-Anweisung fuer Pull/Build/Hash erhaelt.

## Verbindliche Anti-Regressionsregel fuer diesen Arbeitszweig

```text
Keinen Lua-Quelltext als lokal auszufuehrenden Schritt an den Projektinhaber geben.
Lua wird von ChatGPT als Repository-Datei erstellt und committed.
Der Projektinhaber erhaelt erst nach Remote-Verfuegbarkeit genau einen nummerierten PowerShell-Block fuer Pull/Build/Hash.
Direkte lokale lua/luac-Aufrufe bleiben auf dem bekannten Owner-Arbeitsplatz ausgeschlossen, solange keine geaenderte Tooling-Baseline bestaetigt wurde.
DCS-Test erst mit dem vom Builder erzeugten Bundle.
```

## Technischer Stand

Die PowerShell-Fehler haben den Repository-Stand nicht veraendert. Sie liefern keine Aussage ueber die geplante Six-Site-Guard-Runtime. Der naechste funktionale Schritt bleibt: versionierten Gate-5-Acceptance-Source und Builder remote erstellen, CI/Quellpruefung durchfuehren, danach genau ein lokaler Pull/Build/Hash und anschliessend DCS-Acceptance.
