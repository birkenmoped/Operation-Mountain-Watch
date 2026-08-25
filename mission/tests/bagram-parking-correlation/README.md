---
document_id: OMW-TEST-BAGRAM-PARKING-CORRELATION
status: VALIDATED_FOR_DOCUMENTED_SCOPE
document_class: TEST_PACKAGE_README
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram ME parking label to MOOSE TerminalID correlation test package
  - exact 187-slot runtime correlation result for the documented DCS/MOOSE state
not_authoritative_for:
  - SQUADRON parking pool design
  - SetParkingIDs integration
  - taxi, takeoff, landing or recovery behavior
  - client parking allocation policy
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/bagram-parking-terminalid-baseline
source_commit: 41fff9e313629fee091572a4fafbe38d206afd4b
validated_in_dcs: true
---

# Bagram Parking Correlation Test

## Ergebnis

Der Runtime-Test `BAGRAM-PARKING-CORRELATION-2` ist für den dokumentierten Stand bestanden.

```text
RESULT status=PASS
airbase=Bagram
candidates=187
mapped=187
missingSpots=0
runtimeParkingSpots=187
runtimeUniqueTerminalIDs=187
runtimeDuplicateIDs=0
unexpectedRuntimeIDs=0
```

Damit ist für diesen DCS-/Afghanistan-/MOOSE-Stand bestätigt, dass die 187 aus der Referenzmission `BAGRAM.miz` extrahierten numerischen Parkingwerte die vollständige Menge der von MOOSE über `AIRBASE:GetParkingSpotsTable()` gelieferten Bagram-`TerminalID`s bilden.

Die Referenzgruppen aus `BAGRAM.miz` sind ausdrücklich keine Voraussetzung der OMW-Testmission. Sie dienen nur zur statischen Erfassung der sichtbaren Mission-Editor-Parkingbezeichnungen.

## Validierte Datenbasis

Die validierte Zuordnung liegt unter:

```text
docs/data/bagram-me-parking-to-moose-terminalid-validated.csv
```

Die ursprüngliche Candidate-Datei bleibt als Testprovenienz erhalten:

```text
docs/data/bagram-me-parking-to-moose-terminalid-candidate.csv
```

Besondere bestätigte Fälle:

```text
R16   -> TerminalID 0
D09   -> TerminalID 10
D09-1 -> TerminalID 101
```

## Exakter Teststand

```text
Branch:
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

DCS-tested mission:
OMW_Template_v20_BGRM_Parking_Correlation_1.miz

Mission SHA-256 after the tested save:
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

Die ausgewertete DCS-Logdatei des Laufs wurde im Projektgespräch bereitgestellt und enthält den oben dokumentierten PASS-Marker. Ein nachträglicher Hash der live fortgeschriebenen `Saved Games\...\Logs\dcs.log` ist bewusst nicht Teil dieser Provenienz, da diese Datei bei weiteren DCS-Starts verändert wird.

## Scope-Grenze

Der PASS validiert ausschließlich die vollständige Bagram-TerminalID-Korrelation. Er validiert nicht:

- welche TerminalIDs einzelnen SQUADRONs zugewiesen werden;
- `SQUADRON:SetParkingIDs()` im produktiven Bagram-Pfad;
- Client-/AI-Parking-Trennung;
- Parking-Kompatibilität einzelner Flugzeugtypen;
- Taxi, Takeoff, Landing, Recovery oder Despawn;
- Warehouse-, CampaignState- oder Ressourcenverhalten.

Diese Punkte benötigen getrennte Designentscheidungen bzw. Folge-Acceptance.
