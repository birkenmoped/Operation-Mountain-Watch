---
document_id: OMW-ACC-FIGHTER-STORE-RUNTIME-CORRELATION-2026-08-13
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - exact F-15E STRIKE GBU-31(V)1/B STORAGE runtime mapping
  - exact F-15E STRIKE GBU-31(V)3/B STORAGE runtime mapping
  - exact F-16 deployment AIM-9 STORAGE runtime mapping
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unresolved fighter-store mapping status for the documented Warehouse foundation scope
superseded_by:
source_branch: agent/fighter-store-runtime-correlation
source_commit: d95a15275f148cba02a9a2728dfbf825c274e366
validated_in_dcs: true
acceptance_branch: agent/fighter-store-runtime-correlation
acceptance_commit: d95a15275f148cba02a9a2728dfbf825c274e366
acceptance_mission: executed MIZ identified by acceptance_mission_sha256; filename not separately preserved in the acceptance record
acceptance_mission_sha256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# Fighter Store Runtime Correlation – Acceptance 13.08.2026

## 1. Provenienz

```text
DCS: 2.9.28.26385 MT
Source/Builder commit: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
Internal mission SHA-256: 0f38447dade1934d63baa8e08ac536edd7865f47897f734450a8575594a19a2c
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: ec0238a8211d5804b1d1152190497b5e46ee8af45946e723abbe629efa22683f
debrief.log SHA-256: 89bca4398de33df36dffdbe67dca27b0e19a6ba330b02e5b0d927b28824f2fc5
```

Der Dateiname der ausgeführten `.miz` wurde im Acceptance-Datensatz nicht separat konserviert. Deshalb wird er nicht nachträglich geraten; die ausgeführte Mission ist durch den SHA-256 eindeutig identifiziert.

## 2. F-15E STRIKE

Der produktive Bagram-F-15E-SQUADRON-Pfad materialisierte das vorhandene Two-Ship-STRIKE-Template. Beobachtet:

```text
weapons.bombs.GBU_31       100 -> 98  delta -2
weapons.bombs.GBU_31_V_3B  100 -> 98  delta -2
```

Finale Zuordnung:

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
```

Status: `RUNTIME_MAPPING_VALIDATED`.

## 3. F-16 Deployment AIM-9

Über den normalen DCS-Ground-Crew-Rearm-Pfad wurden zwei AIM-9M ergänzt. Beobachtet:

```text
STORAGE weapons.missiles.AIM_9  98 -> 97 -> 96
cumulative STORAGE delta = -2

Aircraft AIM_9  0 -> 1 -> 2
cumulative aircraft delta = +2
```

Finale Zuordnung:

```text
AMMUNITION_AIM9 -> weapons.missiles.AIM_9
```

Status: `RUNTIME_MAPPING_VALIDATED`.

## 4. Gesamtergebnis

```text
RESULT testId=FIGHTER-STORE-RUNTIME-CORRELATION-1
status=PASS
reason=F15_STRIKE_AND_F16_AIM9_CORRELATED
f15StrikeMapping=true
f16Aim9Mapping=true
storageMutation=false
campaignStateMutation=false
nativeDcs=false
```

Damit sind die letzten offenen Fighter-Store-Runtime-Mappings des Warehouse-/Resource-Finalisierungsblocks geschlossen.

## 5. Acceptance-Grenze

Der Lauf validiert nur die drei konkreten Store-Korrelationen für die dokumentierte Provenienz. Eine zukünftige schreibende CampaignState-to-STORAGE-Initialisierung oder Equipment-Reservation-/Result-Integration ist dadurch nicht automatisch validiert.

Für den abgeschlossenen Foundation-Scope gilt:

```text
strategic initial-stock planning = CLOSED
resource ownership contract = CLOSED
fighter exact item mapping = CLOSED
warehouse/resource foundation decision block = CLOSED
```

## 6. Lokale Abschlussverifikation des Quellbranches

Der Projektinhaber hat den veröffentlichten Quellbranch lokal per Fast-Forward übernommen und die zentralen Abschlussartefakte unabhängig mit PowerShell verifiziert.

```text
Local verified HEAD: ac9ea1e2ad8926df603229a54ab59ef7eea1fd2a
fighter-store-runtime-correlation-acceptance-2026-08-13.md SHA-256: 2A861EA76E1122F9ECECADF7F4D80955737E752E9A9FA8187518C691624B3E60
ammunition-item-mapping-contract.md SHA-256: B13F6C90DFD532395B294D237A2D672A3895B8E7E65BA7E8301845E648049250
ammunition-resource-id-contract.md SHA-256: 0AC2DF53224DA0084261CE3BEB06015156E9924D3F1D018455A7D48770E73117
air-operations-initial-stock-finalization-2026-08-13.md SHA-256: 58393448B8E67F37BDB8D720943520E4FA1BCA7C142D7F6EA3EBF62B2A5A0162
air-operations-initial-store-stock-v20.csv SHA-256: F64E52731AA611186054566C48F195E8D7B4CADABDE6911BE19EBD74521BF69A
```

Diese Hashes dokumentieren den ursprünglichen Abschlussstand. Main-Reconciliation-Dateien erhalten durch die spätere Konsolidierung neue Hashes und dürfen nicht mit diesen Quellbranch-Hashes gleichgesetzt werden.
