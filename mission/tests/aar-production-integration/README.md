---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - combined production-finalization acceptance scope
not_authoritative_for:
  - repository-wide DCS runtime acceptance without complete acceptance provenance
  - CampaignState strategic inventory authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AAR Production Integration

## Final-Acceptance-1

Owner-Freigabe: **15.08.2026 im Projektchat ausdrücklich erteilt.**

`AAR-PRODUCTION-FINAL-ACCEPTANCE-1` bündelt die noch offenen produktiven AAR-Prüfungen in einem technischen Bereich und einem Bundle.

Geprüft werden CampaignState 16/40, exact-once Materialization/Handoff, 2/2/4-Concurrency, unabhängige MANAS-/AL-UDEID-Materialisierung, eindeutige Transit-Callsigns/STNs, Track-only Stationsidentität, Scheduled- und FuelLow-Relief, `COMPLETE`/`CANCELLED`/`ABORTED`, Loss ohne Recredit mit Audit +1 sowie Snapshot/Restore-Reconciliation ohne Doppelcredit.

## Testbeschleunigung

```text
controlledTrackEntry = true
controlledReliefTiming = true
physicalTeleport = false
```

Der Harness verschiebt kein Flugzeug. Für Track-Entry wird nur die vom Controller ausgewertete Track-Koordinate auf die aktuelle reale Flugzeugkoordinate gesetzt. Für Scheduled Relief wird nur `reliefLaunchAt` auf den aktuellen Testzeitpunkt gesetzt; danach läuft der produktive Relief-/Identity-Pfad.

Der Lauf validiert deshalb nicht die natürliche dreistündige Wartezeit oder die vollständige Gate-to-Track-Flugzeit. Frühere AAR-Acceptance-/Integrationsevidenz deckt allgemeine Tankermechanik und Transitfortschritt ab.

## MOOSE-first Loss-Injection

```lua
unit:Explode(LOSS_EXPLOSION_POWER)
```

`UNIT:Explode(power, delay)` ist im gepinnten `Moose.lua` source-reviewed. Es dient nur zur kontrollierten Zerstörung des Testtankers. Der produktive Loss-Pfad bleibt `FLIGHTGROUP Dead/OnAfterDead -> OMW Adapter`.

## Restore-Grenze

```text
CampaignState ExportSnapshot
-> CampaignState.Restore
-> OMW_AAR_RuntimeIntegration.Attach(restored=true)
```

Das prüft Settlement/Idempotenz eines gespeicherten Snapshots im DCS-Lauf, ist aber kein physischer Serverrestart.

## Dateien

```text
mission/tests/aar-production-integration/src/02-aar-production-final-acceptance.lua
tools/build-aar-production-final-acceptance.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Final_Acceptance.lua
```

Der Builder bindet die aktuellen Produktionsmodule für CampaignState, StrategicStock, Initializer, Adapter, RuntimeIntegration und Controller ein. `dist/` ist builder-generiert; keine automatische `.miz`-Mutation.

## Pflichtmarker

```text
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS
SOURCE_INDEPENDENCE_PASS
CONCURRENCY_MISSION_LIMIT_PASS
ABORT_HANDOFF_PASS
STATION_IDENTITY_PASS
CONCURRENCY_2_2_4_PASS
CONCURRENCY_GLOBAL_LIMIT_PASS
FUEL_LOW_RELIEF_PASS
FUEL_LOW_HANDOVER_PASS
SCHEDULED_RELIEF_PASS
LOSS_INJECTION_ARMED
AIRCRAFT_LOSS_PASS
DEMAND_END_PASS
FINAL_SETTLEMENT_PASS
RESULT PASS
```

Vor DCS müssen exakter Branch/Commit, BuilderVersion, Bundle-SHA-256, MIZ-SHA-256, interner mission-SHA-256, identischer eingebetteter Bundle-Hash, gepinnter eingebetteter Moose.lua-Hash und Objektvertragssmoke vorliegen. Jedes Speichern/Neuverpacken der `.miz` invalidiert die vorherige Hashkette.

Bis zum realen Final-Acceptance-Lauf bleiben die neuen Pfade source-reviewed / nicht DCS-validiert. `VERIFIED-METHODS.md` wird erst nach realer DCS-Evidenz erweitert.
