---
document_id: OMW-TEST-BAGRAM-MQ1A-LRE-FOUNDATION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS-tested Bagram MQ-1A LRE foundation baseline
  - seven-SQUADRON Bagram dual-AIRWING foundation acceptance
not_authoritative_for:
  - tactical RECON dispatch
  - tactical CAS or STRIKE execution
  - transport or CSAR execution
  - parking assignment compliance
  - recovery or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/bagram-mq1a-lre-foundation
source_commit: 4a327d998cb9214f698d0278bbb5fa657eb8deb6
acceptance_branch: agent/bagram-mq1a-lre-foundation
acceptance_commit: 4a327d998cb9214f698d0278bbb5fa657eb8deb6
acceptance_mission: OMW_Template_v20_BGRM_MQ1A_Foundation_Test.miz
acceptance_mission_sha256: fe9287b27d32e26ea208b3079ce04f9a8f83568f111e4bb0b348eeb324310081
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Bagram MQ-1A LRE Foundation Acceptance

## Ergebnis

Der DCS-Lauf vom 25.08.2026 erfüllt den Foundation-Gate für den exakt dokumentierten sieben-SQUADRON-Stand einschließlich der OMW-Abbildung des 62nd-ERS-Bagram-LRE.

```text
Result: PASS
Scope: AIRWING_SQUADRON_FOUNDATION_ONLY
```

Diese Acceptance gilt ausschließlich für den unten dokumentierten Source-, Bundle-, MIZ-, DCS- und MOOSE-Stand.

## Getestete Runtime-Struktur

```text
AW_US_BGRM_455_AEW
├── SQ_US_BGRM_F15E_335_EFS
├── SQ_US_BGRM_F16C_121_EFS
├── SQ_US_BGRM_MQ1A_62_ERS
├── SQ_US_BGRM_C130_774_EAS
└── SQ_US_BGRM_HH60G_83_ERQS

AW_US_BGRM_TF_FALCON_10_CAB
├── SQ_US_BGRM_UH60_A_1_169
└── SQ_US_BGRM_CH47_B_7_158
```

Der MQ-1A-Pool wurde über den Mission-Editor-Seed

```text
TPL_AIR_US_BGRM_MQ1A_RECON_1SHIP
```

als acht 1-Ship-Assetgruppen in `SQ_US_BGRM_MQ1A_62_ERS` registriert.

## Bestätigtes Accounting

Der DCS-Log enthält den vollständigen Foundation-RESULT-Marker:

```text
RESULT status=RUNNING airwings=2 squadrons=7 registeredGroups=69 representedAirframes=81 logicalAirframes=83 logicalReserve=2 rolePayloads=8 usafRunning=true armyRunning=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Damit sind bestätigt:

```text
airwings=2
squadrons=7
registeredGroups=69
representedAirframes=81
logicalAirframes=83
logicalReserve=2
rolePayloads=8
```

Bestandsdetail der registrierten SQUADRONs:

```text
F-15E   13 logical / 12 represented / 1 reserve / 6 x 2-ship asset groups
F-16C   13 logical / 12 represented / 1 reserve / 6 x 2-ship asset groups
MQ-1A    8 logical /  8 represented / 0 reserve / 8 x 1-ship asset groups
C-130   20 logical / 20 represented / 0 reserve / 20 x 1-ship asset groups
HH-60G   6 logical /  6 represented / 0 reserve / 6 x 1-ship asset groups
UH-60   10 logical / 10 represented / 0 reserve / 10 x 1-ship asset groups
CH-47   13 logical / 13 represented / 0 reserve / 13 x 1-ship asset groups
```

Vor `AIRWING:Start()` wurden 46 USAF- und 23 Army-Assetgruppen registriert. Beide AIRWINGs erreichten anschließend den RUNNING-Zustand.

## Foundation-Sicherheitsgate

Der Runtime-Marker bestätigt:

```text
usafRunning=true
armyRunning=true
missionsCreated=0
transportsCreated=0
commanderCreated=false
f10Controls=false
```

Der Test erzeugte damit im Bagram-Foundation-Pfad keine konkreten AUFTRAG-/OPSTRANSPORT-Missionen, keinen COMMANDER und keine F10-Teststeuerung. Der Builder-Stand enthielt außerdem keinen Parking-Override.

Der Test validiert ausdrücklich nur die Foundation-Erzeugung und Registrierung. `AUFTRAG.Type.RECON` ist in diesem Stand lediglich SQUADRON-Capability/Payload-Typ; ein konkreter RECON-Dispatch wurde nicht getestet.

## Exakte Provenienz

```text
OMW branch:
agent/bagram-mq1a-lre-foundation

OMW source / acceptance commit:
4a327d998cb9214f698d0278bbb5fa657eb8deb6

Builder:
BGRAM-AIR-OPS-DUAL-FOUNDATION-3

Generated / embedded Bagram bundle SHA-256:
681cef282f06bafa2def45402105584a726bdf907bee618411e893e6cfbacb0d

Source Lua SHA-256:
550c33c4ac221171c80439008047f7d36c7d1dbd6f7c37ed772004e673d78505

Builder SHA-256:
b33df31ecde305465c4ea14e02465754462c3a5b8093d19ad469ee94969d3e2a

DCS-tested mission:
OMW_Template_v20_BGRM_MQ1A_Foundation_Test.miz

Mission SHA-256:
fe9287b27d32e26ea208b3079ce04f9a8f83568f111e4bb0b348eeb324310081

DCS version:
2.9.28.26385

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

DCS log SHA-256:
03fde3fd3170735620d7ca1116daf1e162bc69ecf2e267e7d72723c30edbf64a

Debrief log SHA-256:
e0479d73498acc6dd0269c810b951ccb55b1eaeb1130ae6e49b4580a79c86bc6
```

Der DCS-Log bestätigt außerdem den gepinnten MOOSE-Stand direkt im Bagram-Foundation-Start:

```text
MOOSE commit=73d3ed119cd9e7e3f2cfcabbaa34513d30529b54 sha256=e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Laufzeitbeobachtungen außerhalb des Bagram-Scopes

Im DCS-Log treten Engine-, Modul-, Texture- und Saved-Games-Hook-Meldungen auf. Für den Bagram-Foundation-Pfad wurde zwischen BEGIN, den sieben SQUADRON_REGISTERED-Meldungen und dem RESULT-Marker kein Lua-Scripting-Fehler festgestellt.

Der bekannte externe Saved-Games-Hook-Fehler

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

tritt gegen Ende des Laufs auf und stammt aus `Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua`. Er ist kein Fehler des Bagram-Foundation-Bundles und ändert den zuvor erreichten Bagram-RESULT-Marker nicht.

Der Debrief endet mit `mission end` bei `t=87.888`. Es gibt darin keine Evidenz für einen durch den Bagram-Foundation-Pfad ausgelösten MQ-1A-Start oder einen taktischen RECON-Einsatz; das entspricht dem erwarteten Foundation-only-Scope.

## Nicht validiert

Diese Acceptance validiert ausdrücklich nicht:

- konkreten MQ-1A-RECON-Dispatch oder ISR-Orchestrierung;
- taktische CAS-/STRIKE-Ausführung;
- C-130-Transportausführung;
- CSAR-Ausführung;
- Helicopter Cargo-/Troop-Transportausführung;
- Parking-Zuweisungen oder Client-Space-Compliance;
- Taxi, Start oder Landung der registrierten Assettypen;
- Recovery/RTB;
- Post-Landing-Despawn/Return;
- Loss Accounting;
- CampaignState-Persistenz;
- Multiplayer-Endurance.

Die historische sechs-SQUADRON-Acceptance vom 10.08.2026 bleibt für ihren exakt dokumentierten damaligen Stand erhalten und wird durch diesen Nachweis nicht rückwirkend verändert.
