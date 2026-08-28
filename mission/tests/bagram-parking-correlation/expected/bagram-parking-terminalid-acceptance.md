---
document_id: OMW-TEST-BAGRAM-PARKING-TERMINALID-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS-tested Bagram 187-slot MOOSE TerminalID correlation baseline
not_authoritative_for:
  - SQUADRON parking pool allocation
  - SetParkingIDs production integration
  - parking compatibility by aircraft type
  - taxi, takeoff, landing or recovery behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/bagram-parking-terminalid-baseline
source_commit: 41fff9e313629fee091572a4fafbe38d206afd4b
acceptance_branch: agent/bagram-parking-terminalid-baseline
acceptance_mission: OMW_Template_v20_BGRM_Parking_Correlation_1.miz
acceptance_mission_sha256: e83433d383d5f82583e49ff602a0d89b721b79c534923fd6e3ca3a28ee441e1f
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
supersedes:
superseded_by:
acceptance_commit: 41fff9e313629fee091572a4fafbe38d206afd4b
---

# Bagram Parking TerminalID Acceptance

## Ergebnis

Der DCS-Lauf erfüllt das technische Gate für die vollständige Bagram-Parking-zu-MOOSE-TerminalID-Korrelation.

```text
Result: PASS
TestId: BAGRAM-PARKING-CORRELATION-2
Scope: READ_ONLY_BAGRAM_TERMINALID_SET_CORRELATION
```

Runtime-Ergebnis:

```text
RESULT status=PASS airbase=Bagram candidates=187 mapped=187 missingSpots=0 runtimeParkingSpots=187 runtimeUniqueTerminalIDs=187 runtimeDuplicateIDs=0 unexpectedRuntimeIDs=0
```

Damit gilt für den exakt dokumentierten Stand:

```text
187 Referenzparkplätze
= 187 eindeutige extrahierte Parkingwerte
= 187 eindeutige MOOSE Runtime TerminalIDs
= vollständige 187/187 Mengenübereinstimmung
```

## Bestätigte Sonderfälle

```text
R16   -> TerminalID 0
D09   -> TerminalID 10
D09-1 -> TerminalID 101
```

`TerminalID 0` ist damit für Bagram in diesem Stand ausdrücklich als gültig bestätigt. Die zwei D09-Referenzgruppen belegen zugleich, dass das sichtbare Mission-Editor-Label allein kein eindeutiger technischer Schlüssel ist.

## Provenienz

```text
Source branch:
agent/bagram-parking-terminalid-baseline

Source commit:
41fff9e313629fee091572a4fafbe38d206afd4b

BuilderVersion:
BAGRAM-PARKING-CORRELATION-2

Generated bundle SHA-256:
7c99719a8733480793de79afaef5f5072dc1ebd82b193516212ce7f7f2b78782

Source Lua SHA-256:
62278449c50bc745e0f7b49b6cf48d96ac4ebef9c5a11ed8b4a925ea01459140

Builder SHA-256:
69c405d5f3a6a58a5c6c680155ea97f0645f40fd2c7796451decb536a60b51e6

Acceptance mission:
OMW_Template_v20_BGRM_Parking_Correlation_1.miz

Acceptance mission SHA-256:
e83433d383d5f82583e49ff602a0d89b721b79c534923fd6e3ca3a28ee441e1f

DCS version:
2.9.28.26385

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Debrief SHA-256:
a4e9a3fbe0c82294b9b90b3109972d00a0149fecfe52480d6b71d1a46dd77d8e
```

Die konkrete DCS-Logdatei wurde im Testlauf bereitgestellt und ausgewertet. Ein nachträglicher Hash der live fortgeschriebenen Standard-`dcs.log` wird nicht als Acceptance-Provenienz verwendet.

## Validierte Datenquelle

Die aus diesem Test freigegebene Datenbasis ist:

```text
docs/data/bagram-me-parking-to-moose-terminalid-validated.csv
```

Die Candidate-Datei bleibt als historische Testeingabe erhalten und ist nicht die produktive Baseline.

## Nicht validiert

Diese Acceptance validiert ausdrücklich nicht:

- die Auswahl konkreter Parking-Pools für F-15E, F-16C, MQ-1A, C-130, HH-60G, UH-60 oder CH-47;
- `SQUADRON:SetParkingIDs()` in der Bagram-Foundation;
- Client-/AI-Konfliktfreiheit;
- aircraft-size- oder TerminalType-Kompatibilität;
- Taxi-, Start-, Lande- oder Recovery-Verhalten;
- Warehouse-, CampaignState- oder Ressourcenpfade.

Diese Punkte sind Folgearbeit und dürfen nicht aus diesem PASS abgeleitet werden.
