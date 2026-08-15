---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - six-core-area dispatch, area-template/callsign identity, source spacing and high-transit progress acceptance
  - next combined production-finalization acceptance scope
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

Der Testpfad trennt zwei Stufen:

1. den bereits ausgeführten `AAR-PRODUCTION-INTEGRATION-3` / korrigierten `3R1`-Harness für Mapping, Templates, Callsign, Source-Spacing und Transit;
2. den nächsten **gemeinsamen** produktiven Integrations-/Acceptance-Scope für Relief, Identity, CampaignState, Demand-Ende, Loss, Restore und Concurrency.

Die allgemeine KC-135-Grundmechanik wurde bereits separat über Acceptance-2 bis -6 geprüft und wird nicht künstlich erneut beschleunigt.

## Integration-3 – Owner-DCS-Lauf 14./15.08.2026

Bekannter Laufstand:

```text
Branch: agent/aar-runtime-finalization
Commit: 4a6bef1c8a5b8f67606762e10c516610f970e491
BuilderVersion/TestId: AAR-PRODUCTION-INTEGRATION-3
Bundle SHA-256: 39fb3ecf80f6552d3478a8d83122eb69c83449bb3787731007c956fbdb6b49d1
Controller SHA-256: a937b67874dded3bb31ffcb4e7ea60d186ffde21f1e43bcccac4cf43f9e2da97
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v9_AirOps_rdy.miz
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Praktisch beobachtet:

- sechs MissionDemand-Mappings/Submissions;
- sechs area-spezifische Mission-Editor-Templates;
- damalige area-spezifische Callsigns sichtbar und im Controller-Log korrekt;
- vier erforderliche Same-source-Folgeabstände mit jeweils `60.0 s`;
- parallele MANAS-/AL-UDEID-Materialisierung.

Zwei Harness-only False Negatives betrafen die Callsign-Darstellung (`Texaco2-1` vs. `Texaco21`) und einen zu frühen `GROUP:GetFuelMin()`-Read mit Sentinel `65535`. `AAR-PRODUCTION-INTEGRATION-3R1` korrigiert ausschließlich diese Harnessfehler und wurde auf Eigentümerentscheidung nicht allein deswegen erneut in DCS ausgeführt.

## Aktueller produktiver Controller-Scope

Der produktive Stand umfasst inzwischen zusätzlich:

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

Die Restore-Regel bildet keine Tail-Identität nach. Sie löst nur das strategische count-basierte Commitment, dessen physische DCS-Repräsentation nach Mission-/Serverrestart nicht mehr existiert.

## Strategische Produktionsgrenze

Der Controller verlangt einen strategischen Adapter mit:

```text
CanMaterialize(selection)
OnMaterialized(selection, runtime)
OnHandoff(selection, runtime)
OnLost(selection, runtime, reason)
```

Produktiv wird diese Grenze über folgende Module an **denselben** CampaignState-Store gebunden:

```text
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/air-operations/OMW_AAR_Controller.lua
```

Es gibt kein zweites Bestandsbuch in MOOSE WAREHOUSE, AIRWING, DCS Warehouse oder SPAWN.

## Strategische Ressourcen

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count
AIRCRAFT_KC135_LOST = 0 count initial audit

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
AIRCRAFT_KC135_LOST = 0 count initial audit
```

`AIRCRAFT_KC135_LOST` ist nur ein persistenter kumulativer Loss-Audit und keine Verfügbarkeitsquelle.

## Operative Concurrency

Produktiv:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der strategische Bestand `16/40` ist kein Spawnlimit. Physisch noch vorhandene Egress-Tanker zählen bis zum Handoff/Loss gegen das globale Aircraft-Limit.

## Station Identity

```text
TRANSIT
- reservierter Transit-Callsign
- eindeutige STN
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

Der neue Identity-Handover ist source-reviewed, aber noch nicht DCS-validiert.

## Sechs Core-Areas

```text
FAST / NORTHEAST / SUPPORT       -> NELSON / MANAS
SLOW / SOUTHEAST / RECOVERY      -> KRUSTY / AL_UDEID
SLOW / EAST / SUPPORT            -> PATTY / MANAS
SLOW / SOUTH_CENTRAL / RECOVERY  -> MILHOUSE / AL_UDEID
FAST / CENTRAL / SUPPORT         -> MOE / MANAS
SLOW / WEST / SUPPORT            -> LISA / MANAS
```

## Nächster gemeinsamer Acceptance-Scope

Ein neuer DCS-Lauf ist nur nach ausdrücklicher Eigentümerfreigabe vorgesehen. Er soll die **neuen produktiven Änderungen gemeinsam** prüfen und nicht erneut in Kleintests zerlegen:

1. CampaignState Off-map-Pools werden korrekt erkannt;
2. Materialisierung konsumiert genau eine KC-135;
3. 2/2/4-Concurrency blockiert zusätzliche Materialisierung, ohne den strategischen Pool als Concurrency-Autorität zu missbrauchen;
4. Transit-Identity und Station-Identity überlappen nicht unzulässig;
5. 3-h-Relief beziehungsweise testzeitlich kontrolliert ausgelöster äquivalenter Relief-Pfad erzeugt maximal einen `RELIEF_INBOUND`;
6. FuelLow verwendet vorhandenen Relief oder erzeugt genau einen Ersatz;
7. `COMPLETE`/`CANCELLED`/`ABORTED` schließt die letzte Demand-Station sofort und erzeugt keine weitere Ablösung;
8. erfolgreicher External-Gate-Handoff recreditiert exakt einmal;
9. `FLIGHTGROUP Dead` erzeugt `OnLost`, keinen Aircraft-Recredit und einen persistenten Loss-Audit;
10. Restore-Reconciliation erzeugt keine Doppelcredits und erhält bereits dokumentierte Losses;
11. MANAS und AL UDEID bleiben unabhängige Pools.

Der konkrete DCS-Test-Harness darf erst nach Owner-Freigabe für den neuen Testscope umgesetzt/ausgeführt werden, soweit die Governance dies verlangt.

## Source-Gates ohne DCS

Für den aktuellen Produktionsstand existieren zwei lokale Source-/Build-Gates:

```text
tools/build-aar-production-integration.ps1
tools/validate-aar-production-finalization.ps1
```

`build-aar-production-integration.ps1` bleibt ein Regression-/Bundle-Builder für 3R1 und ist **kein** Nachweis der neuen Runtime-Funktionalität.

`validate-aar-production-finalization.ps1` prüft die statischen Vertragsmarker für Demand-Ende, Loss, Restore, Concurrency, CampaignState-Adapter, Stock und Runtime-Integration. Auch dieser Source-Gate ersetzt keinen DCS-Test.

## Source / Builder / Dist

```text
scripts/air-operations/OMW_AAR_Controller.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
mission/tests/aar-production-integration/src/01-aar-production-integration.lua
tools/build-aar-production-integration.ps1
tools/validate-aar-production-finalization.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Integration.lua
```

`dist/` ist ausschließlich builder-generiert.