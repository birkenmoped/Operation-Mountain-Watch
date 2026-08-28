---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - combined production-finalization acceptance scope
  - accepted AAR production integration test index for exact documented provenance
not_authoritative_for:
  - CampaignState strategic inventory authority outside the documented AAR contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: main
source_commit: 2e9cbe6104f2e23bc3031821459e1f16309a946b
validated_in_dcs: true
acceptance_branch: agent/aar-runtime-finalization
acceptance_commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
acceptance_mission: OMW_Template_v9_AirOps_rdy.miz
acceptance_mission_sha256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# AAR Production Integration

## Status

`AAR-PRODUCTION-FINAL-ACCEPTANCE-5` ist für den exakt dokumentierten Branch-/Commit-/Mission-/Bundle-/DCS-/MOOSE-Stand technisch akzeptiert. Vollständige Provenienz und Runtime-Marker stehen in [`ACCEPTANCE-5.md`](ACCEPTANCE-5.md).

## Betriebsbaseline

```text
STANDARD / kontinuierlich:
NELSON     FAST   MANAS      EGPAN   Texaco
PATTY      SLOW   MANAS      EGPAN   Texaco
MILHOUSE   SLOW   AL_UDEID   DAVER   Shell
KRUSTY     SLOW   AL_UDEID   DAVER   Arco

RESERVE / nur bei MissionDemand:
LISA       FAST   MANAS      PINAX   Texaco
MOE        FAST   MANAS      PINAX   Texaco
```

Die kontinuierliche Standardabdeckung ist eine OMW-Betriebsbaseline, kein historischer Nachweis einer 24/7-AAR-Abdeckung.

## Sortie- und Track-Identität

```text
NELSON/PATTY/LISA/MOE -> Texaco n-1
KRUSTY                 -> Arco n-1
MILHOUSE               -> Shell n-1
```

Jeder physische KC-135 ist eine eigene 1-Ship-Gruppe und behält seine Callsign-Familie während der Sortie. Radio/TACAN gehören ausschließlich dem aktuellen Station Owner. Link-16-STN bleibt MOOSE-gemanagt; OMW liest die materialisierte STN über `UNIT:GetSTN()` und setzt keine parallele `SPAWN:InitSTN()`-Logik.

## Spawn, FIR und Handoff

```text
external spawn
-> FIR ingress fix
-> AAR track
-> FIR egress fix
-> external handoff
-> exact-once recredit + despawn
```

Zuordnung:

```text
NELSON/PATTY    -> EGPAN
KRUSTY/MILHOUSE -> DAVER
LISA/MOE        -> PINAX
```

Vollständiges Lower-/Upper-Airway-Routing bleibt optionaler späterer Scope.

## Concurrency und Spacing

Für AAR gilt keine globale AI-Support-`2/2/4`-Grenze.

```text
normaler Standardzustand: 4 physische KC-135
Reserve bei Bedarf: +1 je geöffnetem Reserve-Track
pro Track maximal: 1 ACTIVE + 1 RELIEF
MANAS: mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen parallel materialisieren
```

## Scheduled Relief

```text
RELIEF ETA <= 5 min
-> nur handover armed
-> outgoing bleibt ACTIVE und behält Radio/TACAN
-> relief bleibt inbound

reale Track-Ankunft / enge Handover-Geometrie
-> relief wird Station Owner
-> Radio/TACAN wechseln
-> outgoing Cancel/Egress
```

Der Acceptance-Harness failt bei vorzeitigem Owner-Wechsel, Verlust der outgoing Station Identity oder vorzeitigem Egress.

## FuelLow

FuelLow bleibt bewusst getrennt:

```text
ACTIVE FuelLow
-> Immediate Egress
-> genau ein vorhandener oder neuer Relief
-> Ersatz übernimmt erst nach natürlicher Track-Ankunft
```

## Final Acceptance-5

```text
Branch: agent/aar-runtime-finalization
Acceptance commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Bestätigte Kernmarker:

```text
AAR_POLICY_BASELINE_PASS
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS
STANDARD_TRACKS_4_PASS
FIR_INGRESS_STANDARD_PASS
NATURAL_STANDARD_TRACK_ENTRY_PASS
SCHEDULED_RELIEF_ARMED_HOLD_PASS
SINGLE_SCHEDULED_RELIEF_PASS
FUEL_LOW_RELIEF_PASS
RESERVE_NATURAL_INGRESS_AND_TRACK_PASS
RESERVE_DEMAND_LIFECYCLE_PASS
AIRCRAFT_LOSS_PASS
FINAL_STEADY_STATE_PASS
RESULT PASS
```

## Dateien

```text
mission/tests/aar-production-integration/src/03-aar-production-final-acceptance-5.lua
mission/tests/aar-production-integration/src/04-aar-production-final-acceptance-5-cycle-control.lua
tools/build-aar-production-final-acceptance.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Final_Acceptance.lua
```

`dist/` ist builder-generiert. ChatGPT mutiert keine `.miz`; der Projektinhaber bindet das gebaute Lua-Bundle im Mission Editor ein.
