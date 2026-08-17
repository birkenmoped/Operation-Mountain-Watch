---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-MOOSE-VERSION-BASELINE
status: DRAFT
document_class: VERIFICATION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 2 MOOSE commit and Moose.lua artifact baseline for Air Tasking verification
  - exact MOOSE source commit against which Air Tasking APIs must be checked
  - distinction between verified artifact provenance and later DCS runtime validation
not_authoritative_for:
  - MOOSE API availability before source inspection
  - concrete MOOSE method signatures, returns, events or FSM behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 2 MOOSE Version Baseline

## 1. Zweck

Dieses Dokument fixiert den exakten MOOSE-Stand, gegen den die Air-Tasking-Foundation in Phase 2 geprüft wird.

Es erfüllt ausschließlich den ersten Phase-2-Schritt:

```text
pinned MOOSE branch / commit / Moose.lua hash bestimmen
```

Noch nicht geprüft oder freigegeben werden dadurch konkrete Klassen, Methoden, Events, FSM-Callbacks oder Runtime-Verhalten.

## 2. Verbindliche Versionsquelle im Projekt

`OMW-GOV-MOOSE-VERSION` (`docs/moose/VERSION-AND-SOURCES.md`) nennt für das unveränderte, projektseitig verwendete MOOSE-Artefakt:

```text
MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

evidence type:
RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
```

Die dort dokumentierte Provenienz bleibt maßgeblich. Der ursprüngliche Jalalabad-Acceptance-Bericht enthielt den vollständigen Hash nicht zeitgleich; der Nachweis wurde aus einem identischen unveränderten Artefakt rekonstruiert.

## 3. In dieser Phase erneut geprüfter Moose.lua-Artefaktstand

Für die aktuelle Phase-2-Arbeit wurde die vom Projektinhaber bereitgestellte `Moose.lua` erneut geprüft.

Ergebnis:

```text
SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

embedded MOOSE commit header:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

embedded build timestamp:
2026-06-14T16:11:05+02:00
```

Damit stimmen:

```text
project version policy
= supplied Moose.lua artifact hash
= embedded Moose.lua commit ID
```

für den aktuellen Phase-2-Verifikationsstand überein.

Diese Prüfung beweist Artefaktidentität, nicht DCS-Runtime-Verhalten.

## 4. Upstream-Commit-Kontext

Der Commit

```text
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

existiert im offiziellen Repository `FlightControl-Master/MOOSE`.

Upstream-Metadaten:

```text
commit date: 2026-06-14T14:11:05Z
commit message: Merge remote-tracking branch 'origin/master-ng' into develop
```

Damit wird für Phase 2 der folgende Quellkontext verwendet:

```text
MOOSE source line: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Es wird kein Release-Tag behauptet, solange dafür kein eigener Nachweis vorliegt.

## 5. Dokumentationsstand

Da der gepinnte Commit aus dem `develop`-Kontext stammt, ist die Develop-Klassendokumentation die primäre Dokumentationslinie für die Phase-2-Recherche.

Die Dokumentation allein beweist jedoch keine API-Verfügbarkeit. Für jede tatsächlich benötigte Funktion gilt weiterhin zwingend:

```text
Develop documentation
-> pinned Moose.lua / upstream source at exact commit
-> signature / return / prerequisites / side effects / FSM behavior
-> official demo/test mission where relevant
```

Eine heute sichtbare Develop-Dokumentation kann neuer als der gepinnte Commit sein. Deshalb darf eine dort gefundene Methode erst nach Prüfung gegen Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` als für OMW verfügbar gelten.

## 6. Phase-2-Verifikationsbaseline

Für alle folgenden Air-Tasking-MOOSE-Prüfungen gilt damit:

```text
MOOSE branch/context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Documentation line: MOOSE_DOCS_DEVELOP, always cross-checked against pinned source
DCS validation: not performed by this record
```

## 7. Nächster Prüfschritt

Nach dieser Baseline beginnt die eigentliche Capability-Verifikation.

Die Klassen werden nicht aus Erinnerung als geeignet angenommen. Für jede Klasse werden mindestens geprüft:

```text
responsibility / authority boundary
constructors and required objects
mission assignment mechanisms
status / lifecycle / FSM events
asset selection implications
CampaignState / Air Tasking boundary
relevant official examples
```

Der nächste Manifest-Punkt ist die Prüfung der `CHIEF`-relevanten APIs und Verantwortungsgrenzen.

Kein Runtime-Code wurde geändert. Kein DCS-Test wurde durchgeführt. `validated_in_dcs` bleibt `false`.
