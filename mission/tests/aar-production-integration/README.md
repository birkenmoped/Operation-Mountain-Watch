---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - six-core-area dispatch and source-spacing acceptance
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
-> External Source Domain
-> MOOSE-Materialisierung am External Gate
-> High-Transit-Profil
-> AUFTRAG:NewTANKER
-> Mission EXECUTING
```

Spawn, Racetrack, TACAN Y, Radio, Boom-AAR, FuelLow, Cancel, Egress und Off-map-Handoff werden nicht erneut als allgemeine Mechanik getestet; dafür bleibt Acceptance-6 maßgeblich.

## Sechs Test-Demands

```text
FAST / NORTHEAST / SUPPORT       -> NELSON / MANAS
SLOW / SOUTHEAST / RECOVERY      -> KRUSTY / AL_UDEID
SLOW / EAST / SUPPORT             -> PATTY / MANAS
SLOW / SOUTH_CENTRAL / RECOVERY   -> MILHOUSE / AL_UDEID
FAST / CENTRAL / SUPPORT          -> MOE / MANAS
SLOW / WEST / SUPPORT             -> LISA / MANAS
```

Damit werden beide FLEX-Areas mit je einem konkreten Receiver-Profil geprüft: `MOE FAST`, `LISA SLOW`.

## Materialisierung

Es werden nur bereits in Acceptance-6 bestätigte Seed-Templates wiederverwendet:

```text
MANAS    -> OMW_AAR_KC135_PATTY  -> 96 % Seed
AL_UDEID -> OMW_AAR_KC135_KRUSTY -> 90 % Seed
```

Ein MOOSE-`SPAWN`-Objekt wird je Source Domain wiederverwendet, damit gleichzeitig bzw. nacheinander materialisierte Klone eindeutige Gruppennamen erhalten. Neue Mission-Editor-Tanker-Templates sind nicht erforderlich.

## Spawn-Staffelung

Produktive Regel:

```text
MANAS:    mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen gleichzeitig materialisieren
```

Damit wird die bereits beobachtete unplausible gleichzeitige Mehrfachmaterialisierung auf derselben Seite verhindert.

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

## Erwarteter Abschlussmarker

```text
POLICY_PASS x6
SUBMIT_PASS x6
STRATEGIC_MATERIALIZED x6
EXECUTING_PASS x6
INTEGRATION_PASS demands=6 ... artificialFuelLow=false
```

## Source / Builder / Dist

```text
scripts/air-operations/OMW_AAR_Controller.lua
mission/tests/aar-production-integration/src/01-aar-production-integration.lua
tools/build-aar-production-integration.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Integration.lua
```

`dist/` ist ausschließlich builder-generiert. Die `.miz` wird nicht automatisiert verändert.
