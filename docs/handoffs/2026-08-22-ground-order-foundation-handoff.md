---
document_id: OMW-HANDOFF-GROUND-ORDER-FOUNDATION-2026-08-22
status: PLANNED
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current ground-order foundation branch handoff state
  - completed documentation scope and remaining implementation gates
not_authoritative_for:
  - production runtime behavior
  - DCS acceptance
  - merge approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-order-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Order Foundation – Handoff 2026-08-22

## Ziel

Eine realistische, strukturierte Ground-Order-Schicht für Operation Mountain Watch festlegen, ohne ein frei erfundenes Ground-ATO/GTO-Format oder eine parallele Missionsausführungsengine einzuführen.

## Arbeitsbranch und Pull Request

```text
branch: agent/ground-order-foundation
pull request: 116
pull request state: OPEN DRAFT
base: main
```

Der Draft-Status ist beabsichtigt. Eine Änderung zu `Ready for Review` oder ein Merge benötigt weiterhin die ausdrückliche Freigabe des Projektinhabers.

## Primärdokument

```text
docs/91-ground-order-opord-frago-foundation.md
```

Dokument 91 ist im branchlokalen `DOCUMENT-REGISTRY.md` registriert und in `docs/README.md` sowie `docs/SUBPROJECT-REGISTRY.md` eingeordnet.

## Aktueller Stand

Dokumentiert sind:

- OPORD als längerlebender Operationsrahmen;
- FRAGO als konkrete Änderung/Auftragsausgabe unter einem Parent-OPORD;
- `GroundTask` als maschinenlesbarer militärischer Auftrag;
- `ExecutionAttempt` als einzelner physischer Ausführungsversuch;
- persistente Status- und Restart-Grenzen;
- strukturierte Ergebnisdaten;
- Cross-Domain-Verknüpfung zu Air Support Request / Air Tasking Plan;
- MOOSE-first-Ausführungsgrenze über `AUFTRAG`, `LEGION`/`BRIGADE` und `ARMYGROUP`;
- Ground-Task-Klassifikation und direkte/zusammengesetzte MOOSE-Abbildungen;
- zeitgenössische Fünf-Absatz-Struktur für OPORD/FRAGO;
- `NO CHANGE`-Semantik für FRAGO;
- WARNO als spätere Option, nicht als Foundation-Pflicht.

## Verifizierter lokaler Readback durch Projektinhaber

Für den ersten veröffentlichten Dokumentstand wurde real zurückgemeldet:

```text
branch: agent/ground-order-foundation
HEAD: 8eff0768260d48cea5dc656aef2fae7dda6d16f4
DOCUMENT SHA-256: 9F812F0E97F779B20D17538CC321721D7361BCE979CF0A149F7CBCC72C833DA2
```

Der lokale Working Tree enthielt zahlreiche bereits vorhandene untracked Build-/Testartefakte. Für `docs/91-ground-order-opord-frago-foundation.md` wurde keine lokale Modifikation gemeldet.

Lokale Dokumentationsvalidierung wurde **nicht ausgeführt**, da auf dem lokalen Windows-System des Projektinhabers kein Python installiert ist. Dies ist ausdrücklich weder PASS noch FAIL. Lokale Folgeanweisungen verwenden deshalb PowerShell/Git und vorhandene PowerShell-Projektskripte; Python-basierte Dokumentationsvalidierung läuft in Repository-CI.

## GitHub-CI-Dokumentationsvalidierung

Draft-PR #116 hat die GitHub-Actions-Dokumentationsvalidierung ausgeführt.

Erster Registerlauf:

```text
run: 32586791695
result: FAILURE
errors: 19
new branch-specific error:
docs/DOCUMENT-REGISTRY.md: numbered document is not registered: docs/91-ground-order-opord-frago-foundation.md
```

Dieser branchspezifische Registerfehler wurde korrigiert, indem Dokument 91 in das nummerierte Dokumentregister aufgenommen wurde.

Nachlauf nach Registerkorrektur:

```text
run: 32586858809
result: FAILURE
errors: 18
warnings: 0
new Ground Order Foundation validation errors: 0
```

Die verbleibenden 18 Fehler sind die bereits auf dem zugrunde liegenden Ground-/Main-Dokumentationsstand vorhandenen Metadaten-/Acceptance-Provenienzfehler, insbesondere in `docs/ground/` und `mission/tests/army-ground-foundation/`. Dokument 90 dokumentierte denselben vorhandenen 18-Fehler-Stand bereits vor PR #116. PR #116 fügt nach der Registerkorrektur keinen eigenen Validatorfehler hinzu.

Daraus folgt ausdrücklich **kein globaler Dokumentations-PASS**. Der korrekte Status lautet:

```text
repository documentation validation: FAILURE (18 pre-existing errors)
Ground Order Foundation branch-specific validation delta: PASS (0 new errors)
```

## Geprüfter MOOSE-Artefaktstand

```text
OMW_Template_v15.miz
SHA-256: c2b57957635df36cd3f2b2532c4285b8ae65c69262252f605eb6c7625fc0aceb

embedded l10n/DEFAULT/Moose.lua
SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

MOOSE commit recorded in source:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Diese Prüfung ist statisch und keine DCS-Runtime-Acceptance.

## Noch offen

1. Projektinhaber prüft den finalen Remote-Branchstand lokal per `git pull`, HEAD-/Hash-Readback und `git diff --check`; keine lokale Python-Anweisung.
2. Vor Merge erneut prüfen, dass Nummer 91 auf dem dann aktuellen `main` nicht kollidiert und PR #116 weiterhin konfliktfrei ist.
3. Bei neuer produktiver MOOSE-Nutzung `docs/moose/PROJECT-CLASS-INDEX.md`, thematische MOOSE-Dokumentation und gegebenenfalls `VERIFIED-METHODS.md` aktualisieren.
4. Noch **keinen** produktiven GroundOrderAdapter implementieren, bis der Informationsvertrag und die MOOSE-Abbildung als Foundation akzeptiert sind.
5. Vor Runtime-Code erneut aktuelle MOOSE-Dokumentation, tatsächlich gepinnte `Moose.lua`, Signaturen/FSMs und relevante offizielle Beispiele prüfen.
6. Spätere Runtime-Implementierung separat mit Syntax-, Diff-, CampaignState-, Restart-, MOOSE- und DCS-Acceptance prüfen.

## Nicht behauptet

- kein originaler historischer Afghanistan-OPORD/FRAGO;
- kein vollständiges USMTF-/ADatP-3-System;
- keine DCS-Runtime-Acceptance;
- keine produktive BLUE-COMMANDER-/GroundOrder-Runtime;
- kein globaler Dokumentationsvalidator-PASS;
- keine historische Frequenz-/COMSEC-/Authentifizierungsrekonstruktion.
