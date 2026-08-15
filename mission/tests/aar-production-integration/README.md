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

## Final-Acceptance-3

Owner-Freigabe: **15.08.2026 im Projektchat ausdrücklich erteilt.** Der Scope wurde nach zwei Eigentümerkorrekturen finalisiert:

- die 2/2/4-Begrenzung für AI-Unterstützungsmissionen gilt **nicht** für AAR;
- die sechs ausgewählten AAR-Core-Tracks werden bis auf Weiteres kontinuierlich betrieben;
- `LISA` und `MOE` werden im aktuellen Core-Betrieb als `FAST` geflogen.

`AAR-PRODUCTION-FINAL-ACCEPTANCE-3` ersetzt die nicht akzeptierten Acceptance-1/2-Scopefassungen. Frühere positive Beobachtungen bleiben nur Evidenz für das jeweils tatsächlich beobachtete Verhalten.

## Aktuelle AAR-Betriebsentscheidung

Bis eine spätere historisch/operativ belastbare ATO-/Zeitfensterregel festgelegt wird, behandelt OMW die sechs Core-Tracks als kontinuierlich verfügbar:

```text
LISA      FAST
MOE       FAST
MILHOUSE  SLOW
KRUSTY    SLOW
PATTY     SLOW
NELSON    FAST
```

Das ist eine **vorläufige OMW-Betriebsentscheidung**, keine Behauptung historisch nachgewiesener 24/7-CAS- oder 24/7-AAR-Abdeckung und kein 24-Stunden-Endurance-Test.

Produktiv gilt:

```text
6 Core-Tracks gleichzeitig aktiv
kein globales AAR-Mission-Limit = 2
kein globales AAR-Aircraft-Limit = 4
pro Track maximal:
  1 ACTIVE
  1 RELIEF
=> bei gleichzeitigem Relief aller sechs Tracks bis zu 12 physische KC-135
```

MissionDemand nutzt einen kompatiblen bereits betriebenen Core-Track. Ein `COMPLETE`, `CANCELLED` oder `ABORTED` beendet den Demand, **nicht** den kontinuierlichen Core-Track.

Die weiterhin gültigen Grenzen sind der CampaignState-Bestand, mindestens 60 s Materialisierungsabstand innerhalb derselben Source Domain, maximal ein Relief je Track und eindeutige physische Transitidentität.

## MOOSE-first STN-Korrektur

Der Controller setzt keine feste STN mehr mit `SPAWN:InitSTN(...)`.

Im gepinnten `Moose.lua` verwaltet SPAWN Template-STN-Kollisionen selbst. OMW greift nicht auf `_DATABASE` zu. Nach dem Spawn liest OMW ausschließlich über die öffentliche Wrapper-Methode

```lua
unit:GetSTN()
```

die tatsächlich materialisierte STN aus und speichert sie als Runtime-Telemetrie für Eindeutigkeitsprüfung und Logging.

## Acceptance-3 Scope

Der kombinierte Lauf prüft:

1. CampaignState-Pools MANAS 16 / AL_UDEID 40;
2. automatischer Start aller sechs Core-Tracks ohne MissionDemand als Starttrigger;
3. `LISA=FAST`, `MOE=FAST`, `MILHOUSE/KRUSTY/PATTY=SLOW`, `NELSON=FAST`;
4. vier MANAS- und zwei AL_UDEID-Materialisierungen mit >=60 s Same-source-Abstand und unabhängigen Source Domains;
5. MissionDemand-Attach an laufende Core-Tracks ohne zusätzliches Aircraft;
6. eindeutige Transit-Callsigns und tatsächlich von MOOSE materialisierte STNs;
7. Track-only Station-Callsign/Radio/TACAN;
8. sechs gleichzeitige Reliefs: 6 ACTIVE + 6 RELIEF = 12 physische KC-135;
9. Scheduled Relief aller sechs Tracks und natural External-Gate-Handoff mit exact-once Recredit;
10. `COMPLETE` / `CANCELLED` / `ABORTED` lassen den jeweiligen Core-Track weiterlaufen und erzeugen keinen Demand-End-Egress;
11. FuelLow erzeugt höchstens einen Relief, Egress des alten Tankers und Wiederherstellung der Core-Abdeckung;
12. MOOSE `UNIT:Explode()` -> FLIGHTGROUP Dead/OnAfterDead -> kein Aircraft-Recredit + Loss-Audit + Ersatzmaterialisierung für den weiter benötigten Core-Track;
13. CampaignState Snapshot/Restore-Reconciliation ohne Doppelcredit.

## Testbeschleunigung

```text
controlledTrackEntry = true
controlledReliefTiming = true
physicalTeleport = false
naturalIngressGateTransitRequired = false
naturalEgressGateHandoffRequired = true
```

Der Harness verschiebt kein Flugzeug. Für Track-Entry wird nur die vom Controller ausgewertete Track-Koordinate auf die aktuelle reale Flugzeugkoordinate gesetzt. Für Scheduled Relief wird nur `reliefLaunchAt` auf den aktuellen Testzeitpunkt gesetzt. Egress und Off-map-Handoff werden **nicht** künstlich an die aktuelle Position verlegt; der Handoff bleibt an den produktiven External Gates.

Der Lauf validiert deshalb nicht die natürliche dreistündige Wartezeit, die vollständige Gate-to-Track-Flugzeit oder reale 24-Stunden-Verfügbarkeit. Er validiert den produktiven Lifecycle unter kontrollierter Zeitverkürzung.

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

## Pflichtmarker Acceptance-3

```text
AAR_POLICY_BASELINE_PASS
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS
SOURCE_INDEPENDENCE_PASS
CORE_TRACKS_6_SIMULTANEOUS_PASS
MISSION_DEMAND_ATTACH_PASS
STATION_IDENTITY_PASS
RELIEF_6_TRACKS_12_AIRCRAFT_PASS
SCHEDULED_RELIEF_PASS
SCHEDULED_HANDOFF_SETTLEMENT_PASS
DEMAND_END_PASS
FUEL_LOW_RELIEF_PASS
LOSS_INJECTION_ARMED
AIRCRAFT_LOSS_PASS
FINAL_STEADY_STATE_PASS
RESULT PASS
```

Vor DCS müssen exakter Branch/Commit, BuilderVersion, Bundle-SHA-256, MIZ-SHA-256, interner mission-SHA-256, identischer eingebetteter Bundle-Hash und gepinnter eingebetteter Moose.lua-Hash vorliegen. Jedes Speichern der `.miz` im Mission Editor erzeugt einen neuen Missionsstand und invalidiert die vorherige Hashkette.

Bis zum realen Final-Acceptance-3-Lauf bleiben die neu korrigierten Continuous-Core-/Relief-/STN-/Demand-End-/Loss-Pfade source-reviewed / nicht DCS-validiert. `VERIFIED-METHODS.md` wird erst nach realer DCS-Evidenz erweitert.
