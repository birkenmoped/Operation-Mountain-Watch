---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11-RUNTIME
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - DCS runtime result of bundled fixed-fire-support rearm Acceptance 2-11
  - exact observed physical rearm and same-session restore-settlement markers for the documented runtime
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: d52a47a418fe3a1a996a5b68198b8dc033ff86c4
validated_in_dcs: true
acceptance_branch: agent/ground-ammo-rearm-integration
acceptance_commit: d52a47a418fe3a1a996a5b68198b8dc033ff86c4
acceptance_mission: OMW_Template_v16.miz
acceptance_mission_sha256: 388f02c932be83823543f97887b4edbb9e6764d4cebe543bd8423d43a6ed8620
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Ground Fire Support Acceptance 2-11 – Runtime-Ergebnis

## Ergebnis

```text
FUNCTIONAL DCS RESULT: PASS
PHYSICAL REARM SITES: 4/4 PASS
RESTORE SETTLEMENT: PASS IN SAME DCS SESSION
EXTERNAL PROCESS/SERVER PERSISTENCE: NOT TESTED / NOT CLAIMED
MISSION PROVENANCE: CLOSED
```

Gesamtmarker:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4 restoreSettlement=true
```

## Reale Runtime-Provenienz

```text
DCS: 2.9.28.26385 MT
Acceptance source/build commit: d52a47a418fe3a1a996a5b68198b8dc033ff86c4
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11
Acceptance bundle SHA-256: CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B

Executed mission path:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16.miz
Executed mission SHA-256:
388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620
internal mission SHA-256:
180D07D7001FA6EFBDD92D4867F8EDAEFFEFA72470FEE2AEC6A3616B5E919481

dcs(20260822-141914).log SHA-256:
B65B3010612F9FEDCB90210C0799DE889F64A7D643818CD8326730716662D128

debrief(20260822-141915).log SHA-256:
ED298DC7A21F153021C50726A7B9D245BD9BAF098163D6D59B9D4CB593E40C39
```

Der vom Debrief genannte lokale Runtime-Pfad wurde vom Projektinhaber real mit `Get-FileHash -Algorithm SHA256` gehasht. Das Ergebnis stimmt exakt mit dem zuvor read-only geprüften hochgeladenen Artefakt `OMW_Template_v16(2).miz` überein.

Eingebettete Komponenten des hochgeladenen, bytegleichen MIZ-Artefakts:

```text
Moose.lua:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

OMW_AirOps_Warehouse_Base.lua:
472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

OMW_Ground_Base.lua:
9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB

OMW_Ground_Fire_Support_Acceptance_2.lua:
CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B
```

## Phase A – physische Rearms

```text
BOSTICK   L118 300 -> 296 -> 301 / M1083 / GROUND_AMMO_PACKAGE 52 -> 51 / COMPLETED / returned / PASS
WRIGHT    L118 300 -> 296 -> 300/301 / M1083 / GROUND_AMMO_PACKAGE 30 -> 29 / COMPLETED / returned / PASS
FORTRESS  L118 150 -> 146 -> 151 / M1083 / GROUND_AMMO_PACKAGE 48 -> 47 / COMPLETED / returned / PASS
HONAKER   2B11 40 -> 0 -> 40 / M1083 / GROUND_AMMO_PACKAGE 40 -> 39 / COMPLETED / returned / PASS
```

Honaker produzierte:

```text
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
```

Damit ist für den dokumentierten Scope bestätigt: vollständige 2B11-Entleerung auf 0, erst danach Rearm-Request, M1083-Rearm und Wiederherstellung auf 40.

## Phase B – Restore-Settlement

Die Restore-Settlement-Phase lief auf isolierten `CampaignState.Restore(...)`-Kopien innerhalb derselben DCS-Session. Es fand kein DCS-Prozessneustart und kein externer Snapshot-Datei-Roundtrip statt.

Pflichtmarker:

```text
RESTORE_PHASE_START
RESTORE_INTERRUPTED_SNAPSHOT status=CONSUMED available=50
RESTORE_COMPENSATION_PASS available=51
RESTORE_IDEMPOTENCE_PASS newCompensations=0
RESTORE_NEW_TRANSACTION_PASS oldStatus=COMPENSATED newStatus=COMPLETED
RESTORE_COMPLETED_PRESERVED_PASS
RESTORE_PRECOMMIT_CANCEL_PASS case=RESERVED
RESTORE_PRECOMMIT_CANCEL_PASS case=LOADING
RESTORE_SETTLEMENT_PASS
```

Bestätigter same-session Scope:

```text
CONSUMED -> exactly-once compensation -> COMPENSATED
repeated restore -> no duplicate credit
new transaction after compensation -> new ID -> COMPLETED
COMPLETED restore -> no compensation
RESERVED restore -> CANCELLED
LOADING restore -> CANCELLED
authoritative runtime store remains isolated from fixture copies
```

## Nicht aus diesem PASS abzuleiten

```text
kein externer Dateisystem-/Server-Persistence-Host wurde getestet
kein echter DCS-Prozessneustart mit Snapshot-Datei wurde getestet
keine Aussage über einen noch nicht vorhandenen Persistence-Host
keine MIST-/Native-DCS-/Custom-Rearm-Ausnahme eingeführt
```

## Verdict

```text
Revision 2-11 functional DCS acceptance: PASS
Fixed-fire-support physical rearm contract: PASS for exact documented scope
Option-B ExportSnapshot -> Restore -> ReconcileRestore settlement contract: PASS in same-session DCS runtime
External process/server persistence: OUT OF SCOPE / NOT PRESENT / NOT CLAIMED
Exact executed-MIZ SHA-256: 388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620
Mission provenance: CLOSED
```
