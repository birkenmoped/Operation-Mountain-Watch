---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - six-core-area dispatch, area-template identity, source spacing and high-transit progress acceptance
not_authoritative_for:
  - DCS runtime acceptance before owner-run test
  - CampaignState strategic inventory implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AAR Production Integration

## Ziel

Dieser Test prüft ausschließlich die noch offene produktive Integration oberhalb der bereits abgeschlossenen allgemeinen KC-135-Acceptance:

```text
MissionDemand
-> OMW Area-/FAST-/SLOW-Auswahl
-> area-spezifisches Mission-Editor-KC-135-Template
-> External Source Domain
-> MOOSE-Materialisierung am External Gate
-> High-Transit-Profil
-> nachweisbare Bewegung in Richtung Track
```

Spawn-Mechanik, Racetrack, TACAN Y, Radio, Boom-AAR, FuelLow, Cancel, Egress und Off-map-Handoff wurden bereits separat im KC-135-Runtime-Acceptance-Pfad geprüft und werden hier nicht künstlich erneut beschleunigt.

## Korrektur gegenüber Integration-1

Der erste Owner-Lauf zeigte zwei Fehler im Testentwurf:

1. alle MANAS-Demands verwendeten `OMW_AAR_KC135_PATTY`, alle AL-UDEID-Demands `OMW_AAR_KC135_KRUSTY`; dadurch wurden Callsign und Gruppenidentität des falschen Seed-Templates geerbt;
2. der Harness verlangte `AUFTRAG:IsExecuting()` innerhalb von 900 s. Bei realen Gate->Track-Distanzen von mehreren hundert NM ist das kein sinnvoller fokussierter Integrationstest, weil `EXECUTING` erst am eigentlichen Tanker-Missionsabschnitt erwartet werden kann.

Integration-2 verwendet deshalb für jede Core-Area ein eigenes Mission-Editor-Template und prüft statt vollständiger Track-Ankunft die korrekte Materialisierung sowie messbaren High-Transit-Fortschritt.

## Sechs Test-Demands

```text
FAST / NORTHEAST / SUPPORT       -> NELSON / MANAS
SLOW / SOUTHEAST / RECOVERY      -> KRUSTY / AL_UDEID
SLOW / EAST / SUPPORT            -> PATTY / MANAS
SLOW / SOUTH_CENTRAL / RECOVERY  -> MILHOUSE / AL_UDEID
FAST / CENTRAL / SUPPORT         -> MOE / MANAS
SLOW / WEST / SUPPORT            -> LISA / MANAS
```

Damit werden beide FLEX-Areas mit je einem konkreten Receiver-Profil geprüft: `MOE FAST`, `LISA SLOW`.

## Area-spezifische Templates

```text
NELSON    -> OMW_AAR_KC135_NELSON    -> MANAS    -> 96 % Seed
PATTY     -> OMW_AAR_KC135_PATTY     -> MANAS    -> 96 % Seed
LISA      -> OMW_AAR_KC135_LISA      -> MANAS    -> 96 % Seed
MOE       -> OMW_AAR_KC135_MOE       -> MANAS    -> 96 % Seed
KRUSTY    -> OMW_AAR_KC135_KRUSTY    -> AL_UDEID -> 90 % Seed
MILHOUSE  -> OMW_AAR_KC135_MILHOUSE  -> AL_UDEID -> 90 % Seed
```

Die drei neuen Templates `LISA`, `MOE` und `MILHOUSE` werden durch den Projektinhaber im Mission Editor angelegt. Die `.miz` wird nicht automatisiert verändert.

## Spawn-Staffelung

Produktive Regel:

```text
MANAS:    mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen gleichzeitig materialisieren
```

Der Harness misst die tatsächliche Simulationszeit zwischen Materialisierungen derselben Source Domain.

## Transit-Acceptance

Nach jeder Materialisierung speichert der Harness die anfängliche 2D-Distanz zum zugewiesenen Track. Nach mindestens 60 s muss die Distanz um mindestens 2 NM abgenommen haben.

```text
initialTrackDistanceNm
-> >= 60 s High-Transit
-> currentTrackDistanceNm <= initialTrackDistanceNm - 2 NM
-> TRANSIT_PROGRESS_PASS
```

Damit wird geprüft, dass die area-spezifische Mission tatsächlich in Richtung des richtigen Tracks geroutet wird. Eine vollständige Gate->Track-Ankunft ist für diesen fokussierten Test ausdrücklich nicht erforderlich.

## FuelLow

Der Test verwendet ausschließlich die produktiven Schwellen:

```text
LISA      24 %
MOE       22 %
MILHOUSE  27 %
KRUSTY    27 %
PATTY     21 %
NELSON    20 %
```

Es gibt keine 99-%- oder sonstige beschleunigte FuelLow-Schaltung.

## Strategische Grenze

Der produktive Controller verlangt vor `SubmitDemand` einen strategischen Adapter mit:

```text
CanMaterialize
OnMaterialized
OnHandoff
```

Im Test wird dafür ausdrücklich ein `testAdapter=true` verwendet, der alle sechs Demands zulässt. Das ist kein Ersatz für CampaignState. Die produktive CampaignState-Bindung wird separat an diese Schnittstelle angeschlossen; der Controller selbst übernimmt keine strategische Ressourcenhoheit.

## Erwartete Kernmarker

```text
POLICY_PASS x6
SUBMIT_PASS x6
TEMPLATE_IDENTITY_PASS x6
SEED_FUEL_PASS x6
SOURCE_SPACING_PASS x4
TRANSIT_PROGRESS_PASS x6
INTEGRATION_PASS ... artificialFuelLow=false fullTrackArrivalRequired=false
```

`SOURCE_SPACING_PASS x4` ergibt sich aus drei Folge-Materialisierungen im MANAS-Pool und einer Folge-Materialisierung im AL-UDEID-Pool.

## Source / Builder / Dist

```text
scripts/air-operations/OMW_AAR_Controller.lua
mission/tests/aar-production-integration/src/01-aar-production-integration.lua
tools/build-aar-production-integration.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Integration.lua
```

`dist/` ist ausschließlich builder-generiert.