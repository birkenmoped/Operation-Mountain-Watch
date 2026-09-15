---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE-5
status: PLANNED
document_class: ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - targeted DCS acceptance of incident-local Guard activation and cancellation semantics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: a0ba5c32940fe928c2fef5e50a7fed9cf925f1d7
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: a0ba5c32940fe928c2fef5e50a7fed9cf925f1d7
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Production Base Acceptance 5 – Incident-local Guard

## Ziel

Diese Acceptance prueft ausschliesslich die neue Guard-Differenz gegen die bereits akzeptierte QRF-Baseline A4-8.

```text
vor Alarm: kein physischer Guard
-> physische RED-Intrusion ueber vorhandene Joyce-Mission-Editor-Route
-> MOOSE OPSZONE scan/GetScannedGroupSet
-> PROXIMITY_INTRUSION
-> autoritativer Installation Incident
-> genau ein GUARD-Demand INSTALLATION_ATTACK_LOCAL_GUARD
-> bestehender QRF-Demand INSTALLATION_ATTACK_INITIAL_QRF
-> Guard lokal via MOOSE ONGUARD materialisiert
-> keine PATHLINE-Patrouille / kein proaktiver Guard-Target-Cycle
-> nach null lebenden Incident-Teilnehmern produktives CloseInstallationIncident()
-> Guard Cancel / ReturnToLegion / Returned
-> QRF wird durch Incident-Close nicht automatisch gecancelt
```

QRF-Engagement, Retargeting, On-Road-Marsch und Return-Lifecycle werden in Acceptance 5 nicht erneut bewertet; dafuer bleibt Production Base Acceptance 4 / A4-8 die akzeptierte technische Baseline.

## Testsite

```text
FOB_JOYCE
RED fixture: BadGuys_A3_JOYCE
```

Die RED-Fixture verwendet ihre vorhandene Mission-Editor-Route. Der Acceptance-Harness aktiviert sie nur und ersetzt ihre Route nicht.

## Harte Exclusions

```text
- keine direkte ReportInstallationEvidence()-Injektion
- kein Acceptance-eigenes ExpireDemand()
- kein direkter Guard-/QRF-Cancel aus dem Harness
- keine Acceptance-eigene Guard-/QRF-Zielauswahl
- kein SetEngageDetected fuer Guard
- kein Guard EngageTarget cycle
- kein GROUNDATTACK
- kein PATROLZONE/HuntingPatrol
- keine RED-Route-Manipulation
- kein Teleport
- keine neue Mission-Editor-Zone
```

## Owner-local Build 2026-09-15

Der Projektinhaber hat Acceptance 5 lokal aus folgendem Source-Stand gebaut:

```text
Source commit: a0ba5c32940fe928c2fef5e50a7fed9cf925f1d7
Production BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-18
Acceptance BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-5-2
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Builder-Ausgabe und separate `Get-FileHash`-Pruefung stimmen fuer alle gemeinsam geprueften Dateien exakt ueberein:

```text
Production builder SHA-256:
80C6130BCF0784E362E0AF0EB41B7B379445A438DD1F146F78A5A3167FED58C7

Production bundle SHA-256:
F4BFC2E16A3E6217C31BDB9487D9E80EC5FA271A349DECA052CFC20FCB662890

Acceptance source SHA-256:
185D231FCFDF00C278153039082CA3423527F6819E67B5BAEF1A20BD20D8BBD1

Acceptance builder SHA-256:
FDCA7066662CC6A49F5A4875211795951762683514E29B625B9456FF59C078F8

Acceptance bundle SHA-256:
BCC906FECF7BB4443D3A94F249DFDF2E3865C90B3E1FCBB5A33CD9CD555D4BFB
```

Der lokale `git status --short` zeigte ausschliesslich untracked generierte `dist/`-Verzeichnisse; keine versionierten Quelldateien waren lokal veraendert.

Damit ist der Build-Stand:

```text
Source/Builder: VERIFIED_LOCAL_BUILD
DCS: NOT VALIDATED
Acceptance: PLANNED
```

Der nachfolgende DCS-Test muss exakt das bereits erzeugte Acceptance-Bundle mit SHA-256

```text
BCC906FECF7BB4443D3A94F249DFDF2E3865C90B3E1FCBB5A33CD9CD555D4BFB
```

verwenden. Ein spaeterer reiner Dokumentationscommit darf nicht als neuer Build-Source-Commit missverstanden werden und ist kein Grund fuer einen Rebuild.

## Vor dem DCS-Lauf noch offen

Vor Ausfuehrung in DCS ist gemaess dem bindenden Build-/Transfer-/Validation-Workflow noch die konkrete `.miz`-Einbettung zu verifizieren:

```text
- exakter MIZ-Dateiname und SHA-256
- interner mission SHA-256
- eingebetteter Acceptance-5-Bundle SHA-256 = BCC906F...
- eingebetteter Moose.lua SHA-256 = E3B750...
- DO SCRIPT FILE / Ressourcenzuordnung auf genau Acceptance 5
- Moose.lua vor Acceptance-5-Bundle geladen
- kein paralleler alter Acceptance-Harness aktiv
- Object-contract smoke
```

Erst danach darf der DCS-Lauf beginnen.
