---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE-5
status: ACCEPTED_TECHNICAL_BASELINE
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
acceptance_mission: OMW_Template_v24_GroundWorks_base.miz
acceptance_mission_sha256: 8A1867DE2BBCA8E7EEAE65E7A2A6DA5733F81E35D6CFAB3C1E7FFD37320B1F07
internal_mission_sha256: 643391664E4A63C18D28918C70ED5749B017E750B0AC4DE95A53E10BC46D27D2
dcs_version: 2.9.29.27468
validated_in_dcs: true
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Production Base Acceptance 5 – Incident-local Guard

## Ergebnis

**PASS / ACCEPTED_TECHNICAL_BASELINE** fuer den exakt dokumentierten Source-, Bundle-, MIZ-, DCS- und MOOSE-Stand.

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

QRF-Engagement, Retargeting, On-Road-Marsch und Return-Lifecycle werden in Acceptance 5 nicht als neue Baseline bewertet; dafuer bleibt Production Base Acceptance 4 / A4-8 die akzeptierte technische Baseline. Der reale A5-Lauf zeigte den bestehenden QRF-Pfad zusaetzlich weiter in Betrieb.

## Testsite

```text
FOB_JOYCE
RED fixture: BadGuys_A3_JOYCE
```

Die RED-Fixture verwendete ihre vorhandene Mission-Editor-Route. Der Acceptance-Harness aktivierte sie nur und ersetzte ihre Route nicht.

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

Der Projektinhaber baute Acceptance 5 lokal aus folgendem Source-Stand:

```text
Source commit: a0ba5c32940fe928c2fef5e50a7fed9cf925f1d7
Production BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-18
Acceptance BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-5-2
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Builder-Ausgabe und separate `Get-FileHash`-Pruefung stimmten fuer alle gemeinsam geprueften Dateien exakt ueberein:

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

## MIZ-Preflight des real ausgefuehrten Artefakts

Das nach dem DCS-Lauf bereitgestellte Missionsartefakt wurde strukturell geprueft:

```text
Mission filename:
OMW_Template_v24_GroundWorks_base.miz

MIZ SHA-256:
8A1867DE2BBCA8E7EEAE65E7A2A6DA5733F81E35D6CFAB3C1E7FFD37320B1F07

Internal mission SHA-256:
643391664E4A63C18D28918C70ED5749B017E750B0AC4DE95A53E10BC46D27D2

Embedded Acceptance-5:
l10n/DEFAULT/OMW_FireSupStratResupply_Production_Base_Acceptance_5.lua
SHA-256 BCC906FECF7BB4443D3A94F249DFDF2E3865C90B3E1FCBB5A33CD9CD555D4BFB

Embedded Moose.lua:
l10n/DEFAULT/Moose.lua
SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

`l10n/DEFAULT/mapResource` bindet das Acceptance-Bundle an `ResKey_Action_246`; die interne Mission fuehrt diesen DO-SCRIPT-FILE-Resource-Key als Trigger-Action 19 aus. `Moose.lua` ist `ResKey_Action_6` und wird als Trigger-Action 1 geladen. Im bereitgestellten MIZ-Archiv ist kein weiterer Production-Base-Acceptance-Harness parallel eingebettet.

## Realer DCS-Lauf 2026-09-15

```text
DCS: 2.9.29.27468
Mission: OMW_Template_v24_GroundWorks_base.miz
Source commit: a0ba5c32940fe928c2fef5e50a7fed9cf925f1d7
Acceptance bundle SHA-256: BCC906FECF7BB4443D3A94F249DFDF2E3865C90B3E1FCBB5A33CD9CD555D4BFB
Runtime log: dcs(20260915-181616).log
Runtime log SHA-256: A6E80BD485DA9989C885B193B03DD5FBA078AC3801789F123F2CCA300903039E
Debrief: debrief(20260915-181615).log
Debrief SHA-256: 0F85AFF1E7061771B4CED909CD3B66EF0F4D67B1D7AE3B4094A23E261FDBA484
```

Beobachtete und geloggte Evidenz:

```text
- Startup gate bestaetigt: vor Alarm kein physischer Guard und kein Guard-Demand.
- BadGuys_A3_JOYCE wurde nach dem Startup-Gate aktiviert und bewegte sich auf der vorhandenen Mission-Editor-Route.
- MOOSE OPSZONE erkannte RED presence und die Runtime erzeugte PROXIMITY_INTRUSION.
- Der autoritative Installation Incident erzeugte genau zwei Incident-Demands:
  1x GUARD INSTALLATION_ATTACK_LOCAL_GUARD, cancelWhenIncidentClosed=true
  1x QRF INSTALLATION_ATTACK_INITIAL_QRF, cancelWhenIncidentClosed=false
- Guard wurde als Ground Infantry lokal materialisiert und erhielt MOOSE MissionType On Guard.
- Guard lag innerhalb des Joyce-Perimeters.
- QRF wurde weiterhin separat materialisiert und nahm konkrete Incident-Ziele ueber den bereits akzeptierten Direct-Target-Pfad auf.
- Nach null lebenden autoritativen Incident-Teilnehmern rief der Harness die produktive CloseInstallationIncident()-API auf.
- Nur der Guard-Demand erhielt den Incident-Close-Cancel; QRF blieb DISPATCHED.
- Guard wechselte ueber MOOSE RTZ/Returning und erreichte Returned.
- Acceptance meldete explizit PASS.
```

Zeitliche Kernevidenz aus dem Log:

```text
18:07:17  Installation Incident; Guard- und QRF-Demand erzeugt
18:08:22  GUARD_MATERIALIZED ... missionType=On Guard ... insidePerimeter=true
18:08:52  QRF_MATERIALIZED; bestehender Direct-Target-Pfad aktiv
18:13:28  AUTHORITATIVE_CLOSE_REQUESTED ... zeroLivingParticipants=true
18:13:29  GUARD_RTZ
18:14:24  GUARD_RETURNED ... Returning -> Returned
18:14:25  [PRODUCTION BASE A5][PASS]
```

Nach der Incident-Schliessung protokollierte der Perimeter spaeter separat `RED presence cleared ...; no incident close`. Damit blieb die bindende Semantik erhalten, dass Perimeter-Clear nicht selbst die Incident-/Response-Endbedingung besitzt.

Die wiederkehrende MOOSE-Warnung `Could not get EVENTMETA data for event ID=61` trat auch in diesem Lauf auf, blockierte die Acceptance jedoch nicht und ist fuer diesen PASS kein nachgewiesener Guard-Fehler.

## Acceptance-Entscheidung

```text
Source/Builder: VERIFIED_LOCAL_BUILD
MIZ embedding/provenance: VERIFIED
DCS: VALIDATED
Acceptance: PASS
Status: ACCEPTED_TECHNICAL_BASELINE
```

Diese technische Baseline gilt exakt fuer den oben dokumentierten Branch-/Commit-/MIZ-/Bundle-/DCS-/MOOSE-Stand. Projektweit normative Wirkung entsteht weiterhin erst nach Merge beziehungsweise ausdruecklicher Owner-Entscheidung gemaess Governance.
