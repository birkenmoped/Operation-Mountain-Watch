---
document_id: OMW-TEST-AAR-PRODUCTION-ACCEPTANCE-5
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR-PRODUCTION-FINAL-ACCEPTANCE-5 test scope
  - natural FIR and real-track transit expectations for the final AAR acceptance run
  - accepted AAR production runtime behavior for the exact documented provenance
not_authoritative_for:
  - repository-wide normative authority before merge to main
  - CampaignState strategic inventory authority outside the documented AAR integration contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/aar-runtime-finalization
acceptance_commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
acceptance_mission: OMW_Template_v9_AirOps_rdy.miz
acceptance_mission_sha256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# AAR Production Final Acceptance 5

## Zweck

`AAR-PRODUCTION-FINAL-ACCEPTANCE-5` ist der kombinierte technische Abschlusslauf für die aktuelle OMW-AAR-Produktionsintegration. Der Test prüft natürliche FIR- und Track-Transits, Scheduled Relief, FuelLow, Reserve-Lifecycle, Verlust/Replacement und CampaignState-Accounting gemeinsam.

Acceptance-5 verändert `runtime.trackCoord` nicht, teleportiert keine physischen Tanker und mutiert keine `.miz` automatisiert.

## Produktive Baseline

STANDARD, bis zu einer später genehmigten ATO-/Zeitfensterlogik kontinuierlich betrieben:

```text
NELSON    FAST   MANAS      EGPAN   Texaco
PATTY     SLOW   MANAS      EGPAN   Texaco
MILHOUSE  SLOW   AL_UDEID   DAVER   Shell
KRUSTY    SLOW   AL_UDEID   DAVER   Arco
```

RESERVE, nur auf passenden MissionDemand:

```text
LISA      FAST   MANAS      PINAX   Texaco
MOE       FAST   MANAS      PINAX   Texaco
```

Lower-/Upper-Airway-Routing bleibt ausdrücklich späterer optionaler Scope.

## Verbindliche Handover-Semantik

Scheduled Relief:

```text
RELIEF ETA <= 5 min
-> Handover nur ARMEN
-> outgoing bleibt ACTIVE und behält Station-Radio/TACAN
-> relief bleibt RELIEF / inbound

RELIEF erreicht den realen Track / die enge Handover-Geometrie
-> relief übernimmt Station-Radio/TACAN
-> erst jetzt outgoing Cancel/Egress
```

Das 5-Minuten-Gate ist kein Station-Owner-Wechsel und kein Egress-Gate.

FuelLow bleibt davon getrennt:

```text
ACTIVE FuelLow
-> outgoing verlässt die Station sofort und geht auf Egress
-> vorhandenen Relief wiederverwenden oder genau einen Emergency-Relief erzeugen
-> vorübergehende Track-Lücke ist zulässig
-> Ersatz übernimmt nach natürlicher Track-Ankunft
```

## Acceptance-Ablauf

1. CampaignState Restore/Reconciliation und Pools MANAS 16 / AL_UDEID 40 prüfen.
2. Nur die vier STANDARD-Tracks materialisieren; LISA/MOE bleiben ohne Demand absent.
3. Mindestens 60 s Same-source-Abstand prüfen; MANAS und AL_UDEID bleiben voneinander unabhängig.
4. Natürlichen FIR-Ingress der vier STANDARD-Tanker über EGPAN beziehungsweise DAVER abwarten.
5. Natürliche Ankunft an den tatsächlichen vier AAR-Tracks abwarten.
6. STANDARD-MissionDemand attach/end prüfen, ohne Track-Shutdown.
7. Scheduled Relief auf MILHOUSE auslösen; Shell-Familie und unterschiedliche `n-1`-Gruppennummer prüfen.
8. Zwischen 5-Minuten-Gate und realer Relief-Ankunft outgoing ACTIVE/Station Owner halten; jeder vorzeitige Owner-Wechsel oder Egress ist FAIL.
9. Erst bei realer Track-Ankunft MILHOUSE-Handover durchführen; danach DAVER-Egress, External Handoff, Despawn und exact-once Recredit prüfen.
10. FuelLow-Relief separat auf NELSON mit Immediate Egress prüfen; Replacement fliegt natürlich über EGPAN zum realen Track.
11. LISA und MOE per Demand starten, natürlichen PINAX-Ingress und natürliche Track-Ankunft prüfen.
12. Letzten Reserve-Demand beenden; PINAX-Egress und External Handoff beider Reserve-Tanker prüfen.
13. PATTY-Verlust mit MOOSE `UNIT:Explode()` injizieren; kein Recredit, Loss-Audit +1 und natürliche Replacement-Sortie prüfen.
14. Finalzustand: vier STANDARD-Tanker aktiv, LISA/MOE absent, MANAS 13 mit Loss-Audit 1, AL_UDEID 38.

## Verworfener Vorlauf vom 15.08.2026

Der frühere Lauf auf Commit `877f0c15c0b46dc8d08f39f7cdcde36e065563b5` erreichte formal `RESULT PASS`, war aber **nicht akzeptabel**:

```text
RELIEF_FINAL_INGRESS etaSec=297 distanceNm=24.7
-> outgoing bereits STATION_IDENTITY_OFF + EGRESS_ORDERED
-> relief wenige Sekunden später Station Owner
```

Zusätzlich fehlte ein vollständiger Mission-SHA-256. Dieser Vorlauf bleibt historische Fehler- und Regressionsevidenz, ist aber keine Acceptance-Baseline.

## Akzeptierter Owner-DCS-Lauf vom 15.08.2026

### Vollständige Provenienz

```text
Branch: agent/aar-runtime-finalization
Commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-5
Mission file observed by DCS: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
Harness SHA-256: 7fbe327a45d89cdc90ff7847854f5b2487f7a39a45c1fd03a98806a51ffebccb
CycleControl SHA-256: 34ab413eb726ac6ab8c388fba43f262a41d56a378c137b362ea407dd462a422b
Controller SHA-256: 8457772aad8bee8b14ac617b347e246c9281e485b212d2d06751ca3e303db9b4
RuntimeIntegration SHA-256: 598aa378d95f9dcde9aa982222d40070006c3c892ffa66668576c64ff07aa91b
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: 3c4b5b74f91b9d94e272a1f02f1df839bbe6b3a2362fa03338916e4fc8b4a060
debrief.log SHA-256: ba78783fce55d045735e76e9ddab4e23a2237fa93eabf90fed56bd58770873a0
```

Die vom Projektinhaber hochgeladene Testmission wurde nach dem Lauf geprüft. Das eingebettete Acceptance-Bundle entsprach dem dokumentierten Build-Hash und enthielt den dokumentierten Git-Commit. Die eingebettete `Moose.lua` entsprach dem dokumentierten MOOSE-Commit und SHA-256.

### Runtime-Ergebnis

Der Harness protokollierte den geforderten Armed-Hold-Zustand:

```text
SCHEDULED_RELIEF_ARMED_HOLD_PASS area=MILHOUSE outgoingStillActive=true reliefStillInbound=true
```

Damit blieb der bisherige MILHOUSE-Tanker nach Erreichen des 5-Minuten-Gates ACTIVE und Station Owner. Erst bei tatsächlicher Relief-Ankunft erfolgten Station-Identity-Transfer und outgoing Egress.

Weitere positive Marker:

```text
AAR_POLICY_BASELINE_PASS
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS
STANDARD_TRACKS_4_PASS
FIR_INGRESS_STANDARD_PASS
NATURAL_STANDARD_TRACK_ENTRY_PASS
STANDARD_DEMAND_END_PASS
RELIEF_TRANSIT_OVERLAP_PASS
SINGLE_SCHEDULED_RELIEF_PASS area=MILHOUSE armedHold=true
FUEL_LOW_RELIEF_PASS
RESERVE_NATURAL_INGRESS_AND_TRACK_PASS
RESERVE_DEMAND_LIFECYCLE_PASS
AIRCRAFT_LOSS_PASS
FINAL_STEADY_STATE_PASS
RESULT PASS
```

Belegt sind für exakt diesen Branch-/Commit-/Mission-/Bundle-/DCS-/MOOSE-Stand:

- vier kontinuierliche STANDARD-Tracks;
- zwei demand-gesteuerte RESERVE-Tracks;
- Callsign-Familien und getrennte `n-1`-Sorties;
- MOOSE-gemanagte STN-Auslesung;
- mindestens 60 s Same-source-Materialisierung;
- natürliche FIR-Passage über EGPAN, DAVER und PINAX;
- External Spawn/Handoff getrennt von FIR-Ingress/Egress;
- Scheduled Relief ohne vorzeitige Stationsfreigabe;
- Radio/TACAN-Transfer erst bei realer Relief-Übernahme;
- FuelLow als Immediate-Egress-Pfad;
- Reserve-Shutdown nach Ende des letzten Demands;
- PATTY Loss/Replacement über MOOSE `UNIT:Explode()` und FLIGHTGROUP Dead/OnAfterDead;
- CampaignState exact-once Recredit beziehungsweise Loss-Audit;
- finaler Steady State ohne verbliebenen Reserve-/Relief-Restbestand.

## Acceptance-Status

```text
VALIDATED: true
FINAL ACCEPTANCE: PASS
ACCEPTED_TECHNICAL_BASELINE: yes, exact documented provenance only
NEXT DCS TEST REQUIRED FOR THIS SCOPE: no
```

Diese Acceptance verleiht dem ungemergten Branch keine repositoryweite normative Autorität. Projektweite Wirkung entsteht gemäß `OMW-GOV-001` erst nach Merge nach `main` oder einer ausdrücklichen Governance-Entscheidung.
