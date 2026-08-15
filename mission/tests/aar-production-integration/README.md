---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - six-core-area dispatch, area-template/callsign identity, source spacing and high-transit progress acceptance
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

`AAR-PRODUCTION-FINAL-ACCEPTANCE-1` bündelt die noch offenen produktiven AAR-Prüfungen in einem technischen Bereich und einem Bundle. Getrennte Folgeläufe dienen nur der Fehlerisolierung.

Der Harness prüft:

1. `OFFMAP_MANAS=16` und `OFFMAP_AL_UDEID=40`;
2. exakt eine CampaignState-KC-135-Buchung pro materialisiertem Tanker;
3. `2 Missionen / 2 Aircraft je Mission / 4 Aircraft global`;
4. unabhängige parallele MANAS-/AL-UDEID-Materialisierung;
5. eindeutige Transit-Callsigns und explizite eindeutige STNs;
6. Track-only Stationsidentität über den produktiven Callsign-/Radio-/TACAN-Pfad;
7. Scheduled-Relief mit maximal einem `RELIEF_INBOUND`;
8. FuelLow-Relief mit Wiederverwendung eines bereits inbound befindlichen Reliefs;
9. `COMPLETE`, `CANCELLED` und `ABORTED` mit sofortigem Station-Close/Egress beim letzten Demand;
10. External-Gate-Handoff mit exakt einmaligem Recredit;
11. Testverlust über die öffentliche MOOSE-Methode `UNIT:Explode()` -> `FLIGHTGROUP Dead/OnAfterDead` -> `OnLost`, ohne Aircraft-Recredit und mit Loss-Audit +1;
12. CampaignState Snapshot/Restore-Reconciliation für unresolved commitments und persistierte Losses ohne Doppelcredit.

## Testbeschleunigung und Grenzen

```text
controlledTrackEntry = true
controlledReliefTiming = true
physicalTeleport = false
```

Der Harness verändert keine physische Flugzeugposition. Für Track-Entry wird nur die vom Controller ausgewertete Test-Track-Koordinate auf die aktuelle reale Flugzeugkoordinate gesetzt. Für Scheduled Relief wird nur `reliefLaunchAt` auf den aktuellen Testzeitpunkt gesetzt; anschließend läuft der normale produktive Relief-/Identity-Pfad.

Der Lauf validiert deshalb nicht die natürliche dreistündige Wartezeit oder die vollständige Gate-to-Track-Flugzeit. Bereits vorhandene AAR-Integration-/Acceptance-Evidenz deckt Transitfortschritt und die allgemeine Tanker-/Egress-/Handoff-Mechanik ab.

## MOOSE-first Loss-Injection

```lua
unit:Explode(LOSS_EXPLOSION_POWER)
```

`UNIT:Explode(power, delay)` ist im gepinnten `Moose.lua` vorhanden. Es wird ausschließlich zur kontrollierten Zerstörung des ausgewählten Testtankers verwendet. Der produktive Loss-Pfad bleibt `FLIGHTGROUP Dead/OnAfterDead -> OMW Adapter`.

## Restore-Grenze

```text
CampaignState ExportSnapshot
-> CampaignState.Restore
-> OMW_AAR_RuntimeIntegration.Attach(restored=true)
```

Dies prüft Snapshot-/Restore-Settlement und Idempotenz im selben DCS-Lauf; es ist kein physischer Serverrestart. Diese Einschränkung bleibt Teil des Ergebnisses.

## Dateien

```text
mission/tests/aar-production-integration/src/02-aar-production-final-acceptance.lua
tools/build-aar-production-final-acceptance.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Final_Acceptance.lua
```

Der Builder bindet die aktuellen Produktionsmodule für CampaignState, StrategicStock, Initializer, Adapter, RuntimeIntegration und Controller ein. `dist/` ist builder-generiert; keine automatisierte `.miz`-Mutation.

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

Ein fehlender Pflichtmarker oder ein Lua-/Scheduler-/Runtime-Fehler verhindert `PASS`.

## Preflight

Vor DCS müssen gemäß `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION` exakter Branch/Commit, BuilderVersion, Bundle-SHA-256, MIZ-SHA-256, interner mission-SHA-256, identischer eingebetteter Bundle-Hash, gepinnter eingebetteter Moose.lua-Hash und Objektvertragssmoke vorliegen. Jedes Speichern oder Neuverpacken der `.miz` invalidiert die vorherige Hashkette.

Bis zum realen Final-Acceptance-Lauf bleiben die neuen Relief-/Identity-, CampaignState-Loss-/Restore- und Concurrency-Pfade **source-reviewed / nicht DCS-validiert**. `VERIFIED-METHODS.md` wird erst nach realer DCS-Evidenz erweitert.
