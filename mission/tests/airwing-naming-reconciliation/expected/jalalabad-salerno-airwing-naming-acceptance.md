---
document_id: OMW-TEST-AIRWING-NAMING-JBAD-SAL-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact DCS runtime acceptance of the normalized Jalalabad and Salerno AIRWING identifiers
  - exact bundle, mission, DCS and MOOSE provenance for the 2026-08-10 naming smoke test
not_authoritative_for:
  - tactical mission execution
  - parking compliance beyond the pre-existing node contracts
  - COMMANDER, AUFTRAG or OPSTRANSPORT production behavior
  - multiplayer or endurance acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/airwing-naming-reconciliation
source_commit: 9769df469774069ab6d399d0bd25fdb344319c66
acceptance_branch: agent/airwing-naming-reconciliation
acceptance_commit: 9769df469774069ab6d399d0bd25fdb344319c66
acceptance_mission: OMW_Template_v6_Tarinkot(10).miz
acceptance_mission_sha256: 75e145f8c6bee9f8e5d3bb44ae5a06c72c882093f7e935360bc2b4e92f3cc115
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# Jalalabad-/Salerno-AIRWING-Naming – Runtime Acceptance

## 1. Zweck

Dieser Nachweis bestätigt ausschließlich, dass die beiden durch ADR 0007 normalisierten AIRWING-Identifier mit den unveränderten Foundation-Verträgen in DCS gestartet werden und den erwarteten Idle-Foundation-Zustand erreichen.

```text
AW_US_JBAD_TF_SHOOTER_6_6_CAV
AW_US_SAL_TF_TIGERSHARK_1_10_AVN
```

Historische Acceptance-Artefakte mit `AW_US_JALALABAD` beziehungsweise `AW_US_SALERNO` bleiben unverändert und gelten weiterhin nur für ihre damaligen Artefaktstände.

## 2. Provenienz

```yaml
omw_branch: agent/airwing-naming-reconciliation
omw_source_commit: 9769df469774069ab6d399d0bd25fdb344319c66

jalalabad_builder: JBAD-AIR-OPS-FOUNDATION-ONLY-2
jalalabad_bundle_sha256: 74c83ba5bf135cca3bea95547f803c11da14d27a4eecb5d0d213a312be52c6de

salerno_builder: SAL-AIR-OPS-FOUNDATION-ONLY-3
salerno_bundle_sha256: cbdd258c2125780213aaf90ec926cee630972826d04d43fa60be32bbe298d06f

mission_file: OMW_Template_v6_Tarinkot(10).miz
mission_file_sha256: 75e145f8c6bee9f8e5d3bb44ae5a06c72c882093f7e935360bc2b4e92f3cc115
embedded_mission_sha256: 9af64d080bc1562cd256694ca9b2f636d8979601a1f465eb00d2f5adb4e64d29

dcs_log: dcs(20260810-074636).log
dcs_log_sha256: a8761418dc325a9ac88c1d6f9efb138d684d8745712b62087fac171ba3d47f67

debrief_log: debrief(20260810-074634).log
debrief_log_sha256: 9faa73c10d910623d379721f1f8168ee4410d2cb11e6347bdfe136e6765c5f88

dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die hochgeladene `.miz` wurde read-only als ZIP geprüft. Die eingebetteten Jalalabad- und Salerno-Bundles stimmen bytegenau mit den zuvor lokal erzeugten und gehashten Artefakten überein.

## 3. Jalalabad Runtime

Beobachteter AIRWING:

```text
AW_US_JBAD_TF_SHOOTER_6_6_CAV
Warehouse: WH_AIR_US_JALALABAD
Airbase: Jalalabad
```

Beobachteter Foundation-Marker:

```text
RESULT status=RUNNING airwings=1 squadrons=4 aircraft=48 payloads=5 missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Acceptance:

```yaml
warehouse_resolution: PASS
airwing_start_with_new_identifier: PASS
squadrons_registered: 4
represented_aircraft: 48
payloads: 5
missions_created: 0
transports_created: 0
commander_created: false
f10_controls: false
```

## 4. Salerno Runtime

Beobachteter AIRWING:

```text
AW_US_SAL_TF_TIGERSHARK_1_10_AVN
Warehouse: WH_AIR_US_SALERNO
Airbase: FOB Salerno
```

Beobachteter Foundation-Marker:

```text
RESULT status=RUNNING airwings=1 squadrons=5 registeredGroups=20 representedAircraft=31 logicalAircraft=32 logicalReserve=1 rolePayloads=5 parkingState=DEFERRED missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Acceptance:

```yaml
warehouse_resolution: PASS
airwing_start_with_new_identifier: PASS
squadrons_registered: 5
registered_groups: 20
represented_aircraft: 31
logical_aircraft: 32
logical_reserve: 1
role_payloads: 5
parking_state: DEFERRED
missions_created: 0
transports_created: 0
commander_created: false
f10_controls: false
```

## 5. Abgrenzung und Logbewertung

Der Lauf bestätigt die Naming-Reconciliation und den Foundation-Start. Er erweitert nicht die bereits dokumentierten Grenzen zu taktischer Missionserfüllung, Parking-Realisierung, Recovery, Persistenz, Multiplayer oder theaterweitem COMMANDER.

Im DCS-Log tritt beim Dispatcher-Stop weiterhin der bekannte Saved-Games-Hook-Fehler auf:

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

Der Fehler tritt nach den erfolgreichen Foundation-`RESULT`-Markern auf und gehört nicht zum OMW-Bundle. Er wird daher nicht als Fehler der Naming-Reconciliation gewertet.

## 6. Ergebnis

```yaml
jalalabad_normalized_airwing_runtime: PASS
salerno_normalized_airwing_runtime: PASS
foundation_scope_preserved: PASS
naming_reconciliation_runtime_acceptance: ACCEPTED_TECHNICAL_BASELINE
```
