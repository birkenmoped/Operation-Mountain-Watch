---
document_id: OMW-GOV-MOOSE-VERSION
status: BINDING
authoritative_for:
  - MOOSE version provenance
  - acceptance evidence requirements
  - documentation source hierarchy
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
---

# MOOSE-Version und Quellen

## 1. Grundsatz

MOOSE-Dokumentation, MOOSE-Quellcode und die tatsächlich in der DCS-Mission geladene `Moose.lua` müssen zueinander passen.

Eine Methode, die nur in der Develop-Dokumentation vorhanden ist, darf nicht als verfügbar vorausgesetzt werden, wenn die Mission einen älteren Master-, Stable- oder Release-Stand lädt.

## 2. Quellenhierarchie

Bei widersprüchlichen oder unvollständigen Angaben gilt:

1. tatsächlich geladene `Moose.lua` und ihr SHA-256-Hash;
2. zugehöriger MOOSE-Branch, Release und vollständiger Commit;
3. MOOSE-Quellcode dieses Commits;
4. dazu passende generierte Klassendokumentation;
5. offizielle Demo- und Testmissionen desselben oder eines nachweislich kompatiblen Stands;
6. ältere Guides, Forumseinträge und sonstige Beispiele nur als ergänzende Hinweise.

Für projektinterne Architektur- und Freigabeentscheidungen gilt zusätzlich `OMW-GOV-001`.

## 3. Offizielle Quellen

| Zweck | Quelle |
|---|---|
| Develop-Klassenreferenz | <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/index.html> |
| Stable-/Master-Klassenreferenz | <https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/> |
| MOOSE-Quellrepository | <https://github.com/FlightControl-Master/MOOSE> |
| Demo-Missionen | <https://github.com/FlightControl-Master/MOOSE_MISSIONS> |
| Ungepackte Demo-Missionen | <https://github.com/FlightControl-Master/MOOSE_MISSIONS_UNPACKED> |

## 4. Verbindlich zu erfassende Versionsdaten

Jeder neue MOOSE-basierte Acceptance-Bericht enthält mindestens:

```text
MOOSE branch/release: <Branch oder Release>
MOOSE commit:         <vollständiger Commit-SHA>
Moose.lua SHA-256:    <Hash der tatsächlich geladenen Datei>
MOOSE source path:    <Repository- oder Vendor-Pfad>
Dokumentationsstand:  <Stable/Develop plus Abrufdatum>
OMW branch:           <Projektbranch>
OMW commit:           <vollständiger Commit-SHA>
Mission:              <Missionsdatei>
Mission SHA-256:      <Hash>
Bundle:               <Datei>
Bundle SHA-256:       <Hash>
DCS version:          <Version>
```

Ist ein Commit technisch nicht ermittelbar, müssen mindestens Dateihash, Bezugsquelle und Bezugsdatum festgehalten werden.

## 5. Nachweisarten

### 5.1 Zeitgleich protokollierter Nachweis

Commit und Hash wurden im ursprünglichen Testlauf beziehungsweise Acceptance-Bericht erfasst.

```yaml
evidence_type: CONTEMPORANEOUS
```

### 5.2 Nachträglich rekonstruierter Nachweis

Die im Test geladene Datei wurde nachweislich nie verändert und kann durch einen identischen Repository-/Vendor-Artefakt-Hash einem bekannten MOOSE-Stand zugeordnet werden.

```yaml
evidence_type: RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
```

Eine solche Rekonstruktion ist zulässig, muss aber transparent von einem zeitgleich protokollierten Nachweis getrennt werden. Es darf kein Commit oder Hash allein aufgrund einer Vermutung ergänzt werden.

## 6. Jalalabad Air Operations Acceptance

Der Jalalabad-PASS beweist das Laufzeitverhalten der dort getesteten MOOSE-Struktur.

Aktueller nachvollziehbarer Nachweisstand:

```yaml
acceptance: JALALABAD_COMPLETE_AIR_OPERATIONS_NODE
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
evidence_type: RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
moose_lua_changed_locally: false
original_acceptance_report_contained_full_hash: false
```

Einordnung:

- Die `Moose.lua` wurde projektseitig nicht verändert.
- Der Hash ist aus anderen Tests beziehungsweise dem identischen unveränderten Artefakt bekannt.
- Damit besteht keine begründete funktionale Unsicherheit darüber, welche Datei verwendet wurde.
- Der vollständige Hash war im ursprünglichen Jalalabad-Bericht nicht zeitgleich protokolliert; dieser Unterschied bleibt aus Gründen der Nachvollziehbarkeit sichtbar.

Referenz:

- `docs/25-jalalabad-final-validation-and-operational-baseline.md`
- `mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md`

## 7. Umgang mit Develop-Funktionen

Eine Funktion aus `MOOSE_DOCS_DEVELOP` darf verwendet werden, wenn:

1. die geladene MOOSE-Version die Methode tatsächlich enthält;
2. Signatur und Voraussetzungen im Quellcode geprüft wurden;
3. die Verwendung im Projekt dokumentiert ist;
4. die Lösung der MOOSE-First-Richtlinie entspricht;
5. ein reproduzierbarer DCS-Test durchgeführt wird.

Der bloße Eintrag auf der Develop-Webseite ist kein Kompatibilitätsnachweis.

## 8. Versionswechsel

Bei einem MOOSE-Versions- oder Branchwechsel sind mindestens zu prüfen:

- alle `VALIDATED`-Einträge in `PROJECT-CLASS-INDEX.md`;
- alle Signaturen in `VERIFIED-METHODS.md`;
- FSM-Eventnamen und Callback-Signaturen;
- Konstruktoren und Startreihenfolgen;
- Warehouse-, Parking-, Transport-, Routing- und Spawnverhalten;
- Workarounds, Adapter und direkte Zugriffe auf Interna;
- sämtliche genehmigten Nicht-MOOSE-Ausnahmen.

Eine neue MOOSE-Version übernimmt nicht automatisch den Validierungsstatus der vorherigen Version.
