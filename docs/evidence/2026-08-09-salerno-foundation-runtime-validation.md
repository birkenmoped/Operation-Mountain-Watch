---
document_id: OMW-EVIDENCE-SALERNO-FOUNDATION-RUNTIME-2026-08-09
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Salerno AIRWING/SQUADRON foundation runtime validation for the exact documented artifact chain
  - Salerno foundation-only no-tasking boundary for the exact documented run
not_authoritative_for:
  - parking assignment or parking compliance
  - tactical dispatch, recovery, persistence, COMMANDER or OPSTRANSPORT acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/salerno-airops-foundation-cleanup
source_commit: d7b54e310aed83c4c2e4d08be81e9f31a9b9a45e
validated_in_dcs: true
acceptance_branch: agent/salerno-airops-foundation-cleanup
acceptance_commit: d7b54e310aed83c4c2e4d08be81e9f31a9b9a45e
acceptance_mission: OMW_Template_v6_Tarinkot.miz
acceptance_mission_sha256: f0b0b5ce14643f510ef7581f2122c10777475c2d148daf2e6f2c316c80dd96aa
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# FOB Salerno AIRWING/SQUADRON Foundation – Runtime-Validierung 2026-08-09

## Status

```yaml
status: VALIDATED
scope: SALERNO_AIRWING_SQUADRON_FOUNDATION_ONLY
parking_state: DEFERRED
commander: ABSENT
test_dispatch: ABSENT
```

Diese Validierung gilt ausschließlich für den unten dokumentierten, exakt nachgewiesenen Stand. Sie ersetzt keine frühere Stage-18-COMMANDER-Akzeptanz und erweitert deren Scope nicht.

## Provenienz

```text
OMW branch:              agent/salerno-airops-foundation-cleanup
OMW commit:              d7b54e310aed83c4c2e4d08be81e9f31a9b9a45e
BuilderVersion:          SAL-AIR-OPS-FOUNDATION-ONLY-2
Generated bundle:        mission/tests/salerno-air-operations/dist/OMW_AirOps_Salerno.lua
Bundle SHA-256:          6d967c51cd68fa36e8a232c92546c3de94b66c92ff3b9457cceb2ce91db6ab55
Executed mission:        OMW_Template_v6_Tarinkot.miz
Mission SHA-256:         f0b0b5ce14643f510ef7581f2122c10777475c2d148daf2e6f2c316c80dd96aa
DCS version:             2.9.28.26385
MOOSE release:           2.9.18
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded Moose.lua SHA:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die lokal ausgeführte Missionsdatei und die anschließend bereitgestellte Missionsdatei wurden über denselben SHA-256 `f0b0b5ce14643f510ef7581f2122c10777475c2d148daf2e6f2c316c80dd96aa` als byte-identisch nachgewiesen.

Das in der Missionsdatei eingebettete `l10n/DEFAULT/OMW_AirOps_Salerno.lua` entspricht mit SHA-256 `6d967c51cd68fa36e8a232c92546c3de94b66c92ff3b9457cceb2ce91db6ab55` exakt dem lokal reproduzierbar gebauten Foundation-Bundle.

## Build- und Lifecycle-Prüfung

Der Builder wurde zweimal auf demselben Commit ausgeführt und erzeugte in beiden Läufen denselben Bundle-Hash. Damit ist der Build für den dokumentierten Commit reproduzierbar.

`tools/Test-AirOpsLifecycleGuards.ps1` meldete:

```text
AirOps lifecycle guard: PASS
PreStartFunction: constructFoundation
PostStartFunction: inspectIdleFoundation
PostStartAssetValidationRequired: False
VerticalPolicyBeforeStartRequired: False
FoundationScope: True
LifecycleGuard: PASS
TestDispatch: ABSENT
AUFTRAGInstances: ABSENT
OPSTRANSPORTInstances: ABSENT
Commander: ABSENT
```

## DCS-Runtime-Ergebnis

Der Salerno-Foundation-Bootstrap lief in DCS bis zum vorgesehenen RUNNING-Zustand. Der Abschlussmarker bestätigte:

```text
[OMW][AirOps.SAL.Foundation] RESULT status=RUNNING airwings=1 squadrons=5 registeredGroups=20 representedAircraft=31 logicalAircraft=32 logicalReserve=1 rolePayloads=5 parkingState=DEFERRED missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

Damit sind für diesen exakten Teststand bestätigt:

- ein gestarteter Salerno-AIRWING;
- fünf registrierte SQUADRONs;
- zwanzig registrierte Warehouse-Asset-Gruppen;
- 31 direkt repräsentierte Luftfahrzeuge plus eine logische UH-60-Assault-Reserve = 32 logische Luftfahrzeuge;
- fünf Rollen-/Payload-Registrierungen;
- kein eigener Missionsauftrag;
- kein OPSTRANSPORT;
- kein COMMANDER;
- keine F10-Teststeuerung;
- Parking weiterhin ausdrücklich `DEFERRED`.

## Nicht validiert

Diese Foundation-Validierung belegt ausdrücklich nicht:

- operative Parking-Zuweisung oder Parking-Compliance;
- geschützte Client-Parking-Bereiche;
- exakte Spawnpositionen einzelner Luftfahrzeuge;
- Missionsdispatch oder Zielbekämpfung;
- Rückkehr, Landung und Recovery;
- persistente Verlust-/Bestandsbuchung;
- OPSTRANSPORT;
- theaterweiten COMMANDER;
- Multiplayer- oder Endurance-Verhalten.

## Ergebnis

Für den dokumentierten Commit, das dokumentierte Bundle, die dokumentierte MIZ, DCS 2.9.28.26385 und den gepinnten MOOSE-Stand ist der Salerno AIRWING/SQUADRON-Foundation-Scope `VALIDATED`.
