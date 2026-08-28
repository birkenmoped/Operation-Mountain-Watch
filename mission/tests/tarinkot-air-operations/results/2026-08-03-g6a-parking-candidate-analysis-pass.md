---
document_id: OMW-TEST-TKOT-G6A-PARKING-CANDIDATE-PASS-2026-08-03
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G6A DCS runtime result from 2026-08-03
  - geometric parking candidate sets derived from the exact embedded MOOSE 2.9.18 behavior
  - authorization of isolated G6B controlled placement tests
not_authoritative_for:
  - final SQUADRON or WAREHOUSE parking allowlists
  - operational parking compliance
  - rotor, taxi, takeoff, return, landing or recovery acceptance
  - AIRWING, SQUADRON, payload, AUFTRAG, COMMANDER or OPSTRANSPORT acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: a58fdfb82082bb7e9043f314e1c483a9a6ba3775
validated_in_dcs: true
acceptance_branch: agent/tarinkot-object-contract-reconciliation
acceptance_commit: a58fdfb82082bb7e9043f314e1c483a9a6ba3775
acceptance_mission: OMW_Template_v5_Salerno.miz
acceptance_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
supersedes: []
superseded_by: []
---

# Tarinkot G6A – Parking Candidate Analysis PASS

## 1. Ergebnis

```yaml
test_gate: G6A_PARKING_CANDIDATE_ANALYSIS
result: PASS_DATASET
dcs_version: 2.9.28.26385
branch: agent/tarinkot-object-contract-reconciliation
commit: a58fdfb82082bb7e9043f314e1c483a9a6ba3775
builder_version: TKOT-G6A-PARKING-ANALYSIS-1
bundle_sha256: 8ae673b45205c49e1f6e67dd5229146e8b1396a5223ef2571c1660b829fef341
runtime_airbase: Tarinkot
runtime_airbase_id: 9
parking_count: 33
model_missing: 0
candidate_set_failures: 0
active_player_clients: 0
parking_mutation: 0
spawns: 0
```

Der Lauf endete mit:

```text
RESULT G6A_PARKING_CANDIDATE_ANALYSIS status=PASS_DATASET reason=none parkingCount=33 modelMissing=0 candidateSetFailures=0 activePlayerClients=0 parkingMutation=0 spawns=0
```

Damit ist G6A abgeschlossen. Das Ergebnis autorisiert ausschließlich isolierte G6B-Spawn- und Platzierungstests.

## 2. Provenienz

```yaml
source_mission_contract: OMW_Template_v5_Salerno.miz
source_mission_sha256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
embedded_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
embedded_moose_release: 2.9.18
runtime_mission_path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v5_Salerno.miz
runtime_debrief_graveyard_empty: true
```

Der Lauf wurde unter dem unveränderten Quellmissionsnamen gespeichert. Das ist eine Provenienz-Warnung für die Testablage, aber kein technischer G6A-Fehler: Builder-Commit, Bundle-Version, Airbase-ID, Parking-Anzahl, Read-only-Sperre und Ergebnismarker sind eindeutig protokolliert.

## 3. Read-only-Nachweis

```text
READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 PARKING_ASSIGNMENT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0
```

Der Test erzeugte keine Tarinkot-Runtime-Objekte und änderte weder Parking-Konfiguration noch CampaignState oder MIZ.

## 4. Modellreferenzen

```yaml
AH64:
  dcs_type: AH-64D_BLK_II
  source: TPL_AIR_US_TKOT_AH64D_CAS_2SHIP_UNIT_01
  bounding_radius_m: 9.967
  longest_dimension_m: 19.934
  length_m: 19.934
  height_m: 7.339
  width_m: 16.121

UH60:
  dcs_type: UH-60A
  source: TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP_UNIT_01
  bounding_radius_m: 10.020
  longest_dimension_m: 20.041
  length_m: 20.041
  height_m: 5.823
  width_m: 16.067

CH47:
  dcs_type: CH-47Fbl1
  source: TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP_UNIT_01
  bounding_radius_m: 7.910
  longest_dimension_m: 15.821
  length_m: 15.821
  height_m: 5.883
  width_m: 4.380
```

Die CH-47-Modellabmessungen bilden erkennbar nicht die vollständige Rotorfläche ab. Für CH-47 ist der geometrische G6A-Nachweis deshalb nur eine Vorfilterung; sichtbare Rotor-, Hindernis- und Bodenfreiheit muss in G6B separat bestätigt werden.

## 5. Kandidatenlisten

```yaml
AH64_terminal_ids:
  - 0
  - 1
  - 6
  - 11
  - 13
  - 14
  - 18
  - 22
  - 24
  - 25
  - 28
  - 33
AH64_candidate_count: 12
AH64_valid_pairs: 66

UH60_terminal_ids:
  - 0
  - 1
  - 6
  - 11
  - 13
  - 14
  - 18
  - 22
  - 24
  - 25
  - 28
  - 33
UH60_candidate_count: 12
UH60_valid_pairs: 66

CH47_terminal_ids:
  - 0
  - 1
  - 6
  - 11
  - 13
  - 14
  - 18
  - 22
  - 24
  - 25
  - 28
  - 29
  - 33
CH47_candidate_count: 13
```

Die Client-Reservierungen `3`, `8` und `20` sind in keiner Kandidatenliste enthalten.

## 6. Abgeleitete G6B-Probe-Sets

Die ersten kontrollierten Platzierungstests verwenden bewusst nur konservative Kandidaten:

```yaml
AH64:
  terminal_ids: [0, 25]
  center_distance_m: 31.679
  required_distance_m: 21.928
  geometric_margin_m: 9.751
  expected_runtime_shape: one two-ship group

UH60:
  terminal_ids: [13, 22]
  center_distance_m: 31.548
  required_distance_m: 22.045
  geometric_margin_m: 9.503
  expected_runtime_shape: two independent one-ship groups

CH47:
  terminal_ids: [14]
  obstacle_count_within_50m_at_g6a: 0
  expected_runtime_shape: one one-ship group
```

Terminal `29` wird nicht im ersten CH-47-Test verwendet. Der G6A-Abstand zur nächstgelegenen Revetment-Geometrie lag dort nur rund `1.194 m` über der MOOSE-Sicherheitsgrenze; zusammen mit der unvollständigen Rotorabbildung ist das für den ersten kontrollierten Test nicht konservativ genug.

## 7. Nicht akzeptiert

```yaml
acceptedAHParkingIds: []
acceptedUH60ParkingIds: []
acceptedCH47ParkingIds: []
```

G6A beweist nicht:

- exakten DCS-Spawn auf der angeforderten TerminalID;
- korrekte Mehrfachplatzierung einer AH-64-Zweiergruppe;
- parallele Platzierung zweier unabhängiger UH-60-One-Ships;
- CH-47-Rotorfreiheit;
- Cold-Start-, Taxi- oder Takeoff-Verhalten;
- Rückkehr-, Lande- oder Endparkverhalten.

## 8. Gate-Folge

```yaml
G6A: PASS_DCS
G6B_controlled_placement: AUTHORIZED_NOT_STARTED
G7_airwing_squadron_payload: BLOCKED_BY_G6B
```
