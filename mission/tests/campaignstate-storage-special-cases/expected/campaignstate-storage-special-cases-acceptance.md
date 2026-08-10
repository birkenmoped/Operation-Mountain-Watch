---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - DCS runtime evidence for STORAGE special-case topology
  - Kandahar main versus heliport liquid-store independence
  - Shindand main versus heliport liquid-store independence
  - FOB Salerno versus Khost liquid-store independence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-storage-special-cases
source_commit: b8f3c8328bfae08033a3f304ad2e9d92b5a3bc83
validated_in_dcs: true
acceptance_branch: agent/campaignstate-storage-special-cases
acceptance_commit: b8f3c8328bfae08033a3f304ad2e9d92b5a3bc83
acceptance_mission: OMW_Template_v8_AirOps_rdy(4).miz
acceptance_mission_sha256: 66bcf79696985a9a60c961b1078e7f36915ff5a83cd315f6c049d388981fc730
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
base_branch: agent/campaignstate-storage-sync-foundation
base_commit: 6087e389824a82d01ba735ba8e8f63951840cb08
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# STORAGE-Sonderfälle – DCS-Acceptance

## 1. Teststand

Der kombinierte Sonderfalltest wurde am 2026-08-10 in einem einzigen DCS-Lauf ausgeführt.

```text
Test ID: CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1
BuilderVersion: CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1
Source/Builder commit: b8f3c8328bfae08033a3f304ad2e9d92b5a3bc83
Built bundle SHA-256: 3b5a373752419fd1596a387b0af4256c1e99168c20ffa7d4b4b476d3775b4f92
Embedded bundle SHA-256: 3b5a373752419fd1596a387b0af4256c1e99168c20ffa7d4b4b476d3775b4f92
Mission: OMW_Template_v8_AirOps_rdy(4).miz
Mission SHA-256: 66bcf79696985a9a60c961b1078e7f36915ff5a83cd315f6c049d388981fc730
DCS log SHA-256: d096c8f398ba1c2fa1ae62a28b264461429cf35842d3697e1ac16746b661ade9
Debrief SHA-256: f1b8c867be49bcbc95e5705c726467b3c94567f580fadaa9b62cb4e3b8f4e65e
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die hochgeladene MIZ enthält das eingebettete Testbundle unter `l10n/DEFAULT/OMW_CampaignState_Storage_Special_Cases_Test.lua`; dessen SHA-256 ist bytegenau identisch mit dem zuvor lokal gebauten Bundle.

## 2. Runtime-Ergebnis

Gesamtergebnis:

```text
RESULT testId=CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1 status=PASS pairs=3 inconclusive=0 campaignStateMutation=false reverseOverwrite=false persistentMutation=false
```

### Kandahar / Kandahar Heliport

```text
Kandahar          airbaseId=7
Kandahar Heliport airbaseId=15
storageWrapperSame=false
JETFUEL before: 100000 / 100000 kg
Probe: Kandahar 100000 -> 100037 kg
Observer Kandahar Heliport: 100000 -> 100000 kg
classification=INDEPENDENT_BEHAVIOR
RESTORE_PASS
```

Damit sind Kandahar und Kandahar Heliport im getesteten DCS-/MOOSE-/MIZ-Stand als voneinander unabhängige MOOSE-STORAGE-/DCS-Liquid-Endpunkte bestätigt.

### Shindand / Shindand Heliport

```text
Shindand          airbaseId=3
Shindand Heliport airbaseId=14
storageWrapperSame=false
JETFUEL before: 100000 / 100000 kg
Probe: Shindand 100000 -> 100037 kg
Observer Shindand Heliport: 100000 -> 100000 kg
classification=INDEPENDENT_BEHAVIOR
RESTORE_PASS
```

Damit sind Shindand und Shindand Heliport im getesteten Stand als voneinander unabhängige MOOSE-STORAGE-/DCS-Liquid-Endpunkte bestätigt. Für OMW bleibt nur `Shindand Heliport` der relevante AirOps-Fuel-Knoten.

### FOB Salerno / Khost

```text
FOB Salerno airbaseId=23
Khost       airbaseId=25
storageWrapperSame=false
JETFUEL before: 100000 / 100000 kg
Probe: FOB Salerno 100000 -> 100037 kg
Observer Khost: 100000 -> 100000 kg
classification=INDEPENDENT_BEHAVIOR
RESTORE_PASS
```

Damit ist `FOB Salerno` als eigener STORAGE-/DCS-Liquid-Endpunkt gegenüber `Khost` bestätigt. Khost ist nicht der Warehouse-Ersatz für den OMW-Knoten Salerno.

## 3. Gemeinsame Beobachtungen

Alle sechs Endpunkte ließen sich über MOOSE auflösen. Für alle Endpunkte wurden zu Testbeginn jeweils `100000 kg` für `JETFUEL`, `GASOLINE`, `MW50` und `DIESEL` gelesen. Alle drei kontrollierten `37 kg`-JETFUEL-Proben erreichten am Quell-Storage exakt `100037 kg`, beeinflussten den jeweiligen Gegenendpunkt nicht und wurden anschließend mit `RESTORE_PASS` auf den Ausgangswert zurückgesetzt.

Der Debrief enthält `graveyard = {}`; aus dem Testpfad ergibt sich kein dokumentierter Objektverlust.

## 4. Akzeptierte Topologieauswirkung

Für die folgende CampaignState-to-STORAGE-Multi-Node-Arbeit gilt aus diesem Runtime-Test:

```text
Kandahar            -> eigener Fuel-Storage
Kandahar Heliport   -> eigener Fuel-Storage
Shindand Heliport   -> eigener Fuel-Storage; Shindand Main für OMW nicht erforderlich
FOB Salerno          -> eigener Fuel-Storage; nicht Khost
```

Die endgültige Multi-Node-Matrix darf deshalb Kandahar Main und Kandahar Heliport als zwei getrennte physische Fuel-Mirror-Endpunkte führen. Shindand Main wird nicht als zusätzlicher OMW-Fuel-Knoten aufgenommen.

## 5. Grenzen

Diese Acceptance belegt ausschließlich die getestete STORAGE-Topologie und das kontrollierte JETFUEL-Aliasing-/Restore-Verhalten. Nicht belegt sind dadurch:

```text
CampaignState multi-node synchronization
continuous reconciliation
persistence/restart behavior
multiplayer reconciliation
automatic aircraft fuel debit
weapon/item synchronization
CTLD or OPSTRANSPORT resource accounting
```

Ein produktiver Multi-Node-Sync benötigt eine eigene Acceptance.
