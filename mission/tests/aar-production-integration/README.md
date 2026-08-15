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

## Ziel

Der Testpfad trennt drei Evidenzstufen:

1. die bereits ausgeführten KC-135-Runtime-Acceptance-Läufe für die allgemeine Tankermechanik;
2. `AAR-PRODUCTION-INTEGRATION-3` beziehungsweise den korrigierten `3R1`-Harness für Mapping, Templates, Callsign, Source-Spacing und Transit;
3. den vom Projektinhaber am **15.08.2026 ausdrücklich freigegebenen** gemeinsamen produktiven Final-Acceptance-Scope `AAR-PRODUCTION-FINAL-ACCEPTANCE-1`.

Der Final-Acceptance-Test bündelt die noch offenen produktiven Änderungen in einem technischen Bereich, einem Bundle und einem DCS-Lauf. Getrennte Folgeläufe sind nur zur Fehlerisolierung vorgesehen.

## Bereits vorhandene DCS-Evidenz

`AAR-KC135-RUNTIME-ACCEPTANCE-6` bestätigt für den dokumentierten DCS-/MOOSE-Stand die allgemeine KC-135-Mechanik einschließlich Boom-AAR für A-10C/F-15E/F-16C, FAST/SLOW, 3.000-ft-Staffelung, FuelLow -> Cancel -> Egress -> Gate -> Handoff und Y-Band-TACAN.

`AAR-PRODUCTION-INTEGRATION-3` beobachtete praktisch:

- sechs MissionDemand-Mappings/Submissions;
- sechs area-spezifische Mission-Editor-Templates;
- damalige area-spezifische Callsigns;
- vier erforderliche Same-source-Folgeabstände mit jeweils `60.0 s`;
- parallele MANAS-/AL-UDEID-Materialisierung.

Die 3R1-Korrektur behebt nur zwei Harness-False-Negatives und wurde auf Eigentümerentscheidung nicht separat erneut in DCS ausgeführt.

## Produktiver Finalisierungsscope

Der aktuelle Produktionspfad ist:

```text
MissionDemand
-> Area / Profile / Source selection
-> bounded operational concurrency
-> CampaignState CanMaterialize
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
-> CampaignState consume 1 AIRCRAFT_KC135
-> transit identity
-> station identity
-> 3 h scheduled relief OR FuelLow relief
-> Demand COMPLETE/CANCELLED/ABORTED -> immediate station close/Egress
-> External Gate
-> exact-once handoff recredit
```

Bei Verlust:

```text
FLIGHTGROUP Dead
-> OnAfterDead
-> strategic OnLost
-> no AIRCRAFT_KC135 recredit
-> AIRCRAFT_KC135_LOST +1 exactly once
```

Bei Restore:

```text
recorded loss -> preserve loss
resolved handoff/restart credit -> no duplicate credit
unresolved consumed in-flight commitment -> exact-once restart reconciliation
```

## Strategische Ressourcen

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count
AIRCRAFT_KC135_LOST = 0 count initial audit

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
AIRCRAFT_KC135_LOST = 0 count initial audit
```

`AIRCRAFT_KC135_LOST` ist ein persistenter kumulativer Audit-Zähler und keine Verfügbarkeitsquelle. Es gibt kein zweites strategisches Bestandsbuch in MOOSE WAREHOUSE, AIRWING, DCS Warehouse oder SPAWN.

## Operative Concurrency

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Physisch noch vorhandene Egress-Tanker zählen bis Handoff oder Loss gegen das globale Aircraft-Limit.

## Transit- und Stationsidentität

```text
TRANSIT
- reservierter Transit-Callsign
- explizit eindeutige Link-16 STN
- Station-Radio OFF
- Station-TACAN OFF

ON STATION
- area-spezifischer Station-Callsign
- area-spezifische Frequenz
- area-spezifischer Y-TACAN

EGRESS
- Station-Radio OFF
- Station-TACAN OFF
- zurück auf Transit-Callsign
```

## Final-Acceptance-1 – genehmigter Scope

Owner-Freigabe: **15.08.2026 im Projektchat ausdrücklich erteilt.**

Der kombinierte Harness prüft:

1. `OFFMAP_MANAS=16` und `OFFMAP_AL_UDEID=40`;
2. exakt eine CampaignState-KC-135-Buchung pro materialisiertem Tanker;
3. `2 Missionen / 2 Aircraft je Mission / 4 Aircraft global`;
4. unabhängige parallele MANAS-/AL-UDEID-Materialisierung;
5. eindeutige Transit-Callsigns und explizite eindeutige STNs;
6. Track-only Stationsidentität über den produktiven `SwitchCallsign`-/Radio-/TACAN-Pfad;
7. Scheduled-Relief mit maximal einem `RELIEF_INBOUND`;
8. FuelLow-Relief mit Wiederverwendung eines bereits inbound befindlichen Reliefs;
9. `COMPLETE`, `CANCELLED` und `ABORTED` mit sofortigem Station-Close/Egress beim letzten Demand;
10. erfolgreichen External-Gate-Handoff mit exakt einmaligem Recredit;
11. physischen Testverlust über die öffentliche MOOSE-Methode `UNIT:Explode()` -> `FLIGHTGROUP Dead/OnAfterDead` -> `OnLost`, ohne Aircraft-Recredit und mit Loss-Audit +1;
12. CampaignState Snapshot/Restore-Reconciliation für unresolved commitments und persistierte Losses ohne Doppelcredit.

## Testbeschleunigung und Geltungsgrenze

Der Final-Acceptance-Harness darf die drei Stunden Stationszeit nicht real abwarten. Er beschleunigt ausschließlich **Testzustände**, nicht die physische DCS-Position:

```text
controlledTrackEntry = true
controlledReliefTiming = true
physicalTeleport = false
```

Für den Track-Entry wird die vom Controller ausgewertete Test-Track-Koordinate auf die aktuelle reale Flugzeugkoordinate gesetzt. Das Flugzeug selbst wird nicht verschoben. Für Scheduled Relief wird nur der produktive `reliefLaunchAt`-Zeitpunkt im Harness auf den aktuellen Testzeitpunkt gesetzt. Danach durchläuft der Controller seinen normalen Relief-/Identity-Pfad.

Damit validiert dieser Lauf nicht die natürliche dreistündige Wartezeit oder die vollständige reale Gate-to-Track-Flugzeit. Die bereits vorhandene Integration-3/3R1-Evidenz deckt Transitfortschritt ab; Acceptance-6 deckt die allgemeine Tanker-/Egress-/Handoff-Mechanik ab.

## Loss-Injection – MOOSE-first

Für den gezielten Testverlust wird **keine native DCS-Event-Parallelimplementierung** eingeführt. Verwendet wird:

```lua
unit:Explode(LOSS_EXPLOSION_POWER)
```

`UNIT:Explode(power, delay)` ist im tatsächlich gepinnten `Moose.lua` vorhanden. Der Test verwendet es ausschließlich zur kontrollierten Zerstörung des dafür ausgewählten Testtankers. Der produktive Loss-Pfad selbst bleibt `FLIGHTGROUP Dead/OnAfterDead -> OMW Adapter`.

## Restore-Grenze

Restore wird im selben DCS-Lauf deterministisch über

```text
CampaignState ExportSnapshot
-> CampaignState.Restore
-> OMW_AAR_RuntimeIntegration.Attach(restored=true)
```

geprüft. Das ist **kein physischer DCS-Serverrestart**. Ein realer Serverrestart ist für die count-basierte Reconciliation nicht erforderlich, um Idempotenz und Settlement des gespeicherten CampaignState-Snapshots zu prüfen; diese Einschränkung bleibt im Ergebnisbericht ausdrücklich erhalten.

## Source / Builder / Dist

```text
scripts/campaign/OMW_CampaignState.lua
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/air-operations/OMW_AAR_Controller.lua
mission/tests/aar-production-integration/src/01-aar-production-integration.lua
mission/tests/aar-production-integration/src/02-aar-production-final-acceptance.lua
tools/build-aar-production-integration.ps1
tools/build-aar-production-final-acceptance.ps1
tools/validate-aar-production-finalization.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Integration.lua
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Final_Acceptance.lua
```

`dist/` ist ausschließlich builder-generiert. Der Builder mutiert keine `.miz`.

## Pflichtmarker des Final-Acceptance-Laufs

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

## Preflight vor DCS

Vor der DCS-Ausführung müssen gemäß `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION` mindestens vorliegen:

```text
exakter Branch und Commit
BuilderVersion
lokaler Bundle-SHA-256
MIZ-SHA-256
interner mission-SHA-256
eingebetteter Bundle-SHA-256 == lokaler Bundle-SHA-256
eingebetteter Moose.lua-SHA-256 == gepinnter Moose.lua-SHA-256
Objektvertragssmoke für die sechs AAR-Templates
```

Jedes Speichern oder Neuverpacken der `.miz` invalidiert die vorherige MIZ-Hashkette.

## Ergebnisstatus

Bis zum real ausgeführten Final-Acceptance-Lauf bleiben Relief-/Identity-, CampaignState-Loss-/Restore- und Concurrency-Pfade **source-reviewed / nicht DCS-validiert**. `VERIFIED-METHODS.md` wird für diese neuen Pfade erst nach realer DCS-Evidenz aktualisiert.
