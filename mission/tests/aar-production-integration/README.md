---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - six-core-area dispatch, area-template/callsign identity, source spacing and high-transit progress acceptance
not_authoritative_for:
  - repository-wide DCS runtime acceptance without complete acceptance provenance
  - CampaignState strategic inventory implementation
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

Dieser Test prüft ausschließlich die produktive Integration oberhalb der bereits abgeschlossenen allgemeinen KC-135-Acceptance:

```text
MissionDemand
-> OMW Area-/FAST-/SLOW-Auswahl
-> area-spezifisches Mission-Editor-KC-135-Template
-> korrekter DCS-Rufname des Area-Templates
-> External Source Domain
-> MOOSE-Materialisierung am External Gate
-> High-Transit-Profil
-> nachweisbare Bewegung in Richtung Track
```

Spawn-Mechanik, Racetrack, TACAN Y, Radio, Boom-AAR, FuelLow, Cancel, Egress und Off-map-Handoff wurden bereits separat im KC-135-Runtime-Acceptance-Pfad geprüft und werden hier nicht künstlich erneut beschleunigt.

## Korrekturen aus den Owner-Läufen

### Integration-1

Der erste Owner-Lauf zeigte zwei Fehler im Testentwurf:

1. alle MANAS-Demands verwendeten `OMW_AAR_KC135_PATTY`, alle AL-UDEID-Demands `OMW_AAR_KC135_KRUSTY`; dadurch wurden Callsign und Gruppenidentität des falschen Seed-Templates geerbt;
2. der Harness verlangte `AUFTRAG:IsExecuting()` innerhalb von 900 s. Bei realen Gate->Track-Distanzen von mehreren hundert NM ist das kein sinnvoller fokussierter Integrationstest.

Integration-2 stellte deshalb auf sechs area-spezifische Mission-Editor-Templates und Transit-Fortschritt um.

### Integration-2

Der zweite Owner-Lauf bestätigte die area-spezifischen Gruppen-/Template-Namen, zeigte aber zwei weitere konkrete Fehler:

1. MOOSE `SPAWN` setzte ohne explizites `SPAWN:InitCallSign(...)` die BLUE-Einheitenrufnamen neu; dadurch erschienen insbesondere die MANAS-Tanker trotz korrekter Templates als `Texaco11`;
2. der Harness las unmittelbar nach Materialisierung `FLIGHTGROUP:GetFuelMin()`. Zu diesem Zeitpunkt können die `FLIGHTGROUP`-Elemente noch nicht vollständig initialisiert sein, wodurch `math.huge * 100` als `inf` zurückgegeben werden kann.

Integration-3 stellte den produktiven Controller deshalb auf den im gepinnten MOOSE-Stand vorhandenen `SPAWN:InitCallSign(...)`-Pfad um und prüfte den realen DCS-Rufnamen mit `GROUP:GetCallsign()`.

### Integration-3 – Owner-DCS-Lauf 14./15.08.2026

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

Der Lauf belegt praktisch für den getesteten Stand:

- sechs `POLICY_PASS` und sechs erfolgreiche `SubmitDemand`-Aufrufe;
- sechs area-spezifische Mission-Editor-Templates wurden tatsächlich materialisiert;
- die produktive `SPAWN:InitCallSign(...)`-Korrektur erzeugte sichtbar und im Controller-Log die vorgesehenen Rufnamen `Texaco11`, `Texaco21`, `Texaco31`, `Texaco41`, `Arco21`, `Shell21`;
- die vier erforderlichen Folge-Materialisierungen derselben Source Domain hielten jeweils 60.0 s Abstand;
- MANAS und AL UDEID konnten parallel materialisieren.

Der Harness selbst erzeugte zwei **False Negatives**, die keine beobachteten Produktivfehler darstellen:

1. `GROUP:GetCallsign()` lieferte die DCS/MOOSE-Darstellung mit Trenner (`Texaco2-1`), während der Harness gegen die kompakte OMW-Darstellung (`Texaco21`) verglich;
2. `GROUP:GetFuelMin()` wurde weiterhin zu früh ausgewertet und lieferte den Sentinel `65535`, den der Harness irrtümlich als `6553500 %` behandelte.

Weil `failed=true` dadurch bereits unmittelbar nach den Materialisierungen gesetzt wurde, wurde der quantitative `TRANSIT_PROGRESS_PASS`-Teil dieses Harness-Laufs nicht mehr bis zur 60-s-Auswertung fortgeführt. Aus diesem Lauf wird deshalb **kein** formaler Transit-PASS und kein Seed-Fuel-Runtime-PASS abgeleitet.

Der Projektinhaber hat entschieden, dass wegen dieser ausschließlich im Harness liegenden Fehler **kein weiterer DCS-Lauf nur für die Harness-Korrektur** durchgeführt wird. Die nächste DCS-Prüfung erfolgt erst mit neuer produktiver Lifecycle-/CampaignState-Integration oder einem anderen governance-seitig erforderlichen Regressionstrigger.

Die vollständige `ACCEPTED_TECHNICAL_BASELINE`-Provenienz ist für diesen Lauf noch nicht hergestellt, solange insbesondere Missions- und Log-Hashes nicht im Projekt dokumentiert sind. Der Stand bleibt deshalb `validated_in_dcs: partial`.

### Integration-3R1 – korrigierter Harness, nicht erneut in DCS ausgeführt

Der Harness wurde nach dem Owner-Lauf ausschließlich diagnostisch korrigiert:

```text
AAR-PRODUCTION-INTEGRATION-3R1
```

Änderungen:

- Callsign-Vergleich normalisiert ausschließlich Leerzeichen und `-`, sodass `Texaco2-1` und `Texaco21` dieselbe operative Identität darstellen;
- `GROUP:GetFuelMin()` wird erst bewertet, wenn ein plausibler Fuel-Fraction-Wert im Bereich `0..1` vorliegt;
- bis dahin bleibt die Fuel-Prüfung pending und erzeugt keinen False Negative.

Diese Harness-Korrektur verändert den produktiven `OMW_AAR_Controller.lua` nicht und erhält ausdrücklich **keinen eigenen DCS-VALIDATED-Status**.

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

## Area-spezifische Templates und Rufnamen

```text
NELSON    -> OMW_AAR_KC135_NELSON    -> Texaco 1-1 -> MANAS    -> 96 % Seed
PATTY     -> OMW_AAR_KC135_PATTY     -> Texaco 2-1 -> MANAS    -> 96 % Seed
LISA      -> OMW_AAR_KC135_LISA      -> Texaco 3-1 -> MANAS    -> 96 % Seed
MOE       -> OMW_AAR_KC135_MOE       -> Texaco 4-1 -> MANAS    -> 96 % Seed
KRUSTY    -> OMW_AAR_KC135_KRUSTY    -> Arco   2-1 -> AL_UDEID -> 90 % Seed
MILHOUSE  -> OMW_AAR_KC135_MILHOUSE  -> Shell  2-1 -> AL_UDEID -> 90 % Seed
```

Die `.miz` wird nicht automatisiert verändert.

## Spawn-Staffelung

Produktive Regel:

```text
MANAS:    mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL UDEID dürfen gleichzeitig materialisieren
```

Der Owner-Lauf von Integration-3 bestätigte die vier erforderlichen Folgeabstände mit jeweils `deltaSec=60.0`.

## Transit-Acceptance

Der Harness speichert nach jeder Materialisierung die anfängliche 2D-Distanz zum zugewiesenen Track. Nach mindestens 60 s muss die Distanz um mindestens 2 NM abgenommen haben.

```text
initialTrackDistanceNm
-> >= 60 s High-Transit
-> currentTrackDistanceNm <= initialTrackDistanceNm - 2 NM
-> TRANSIT_PROGRESS_PASS
```

Eine vollständige Gate->Track-Ankunft ist für diesen fokussierten Test ausdrücklich nicht erforderlich. Integration-3 erreichte wegen der beiden frühen Harness-False-Negatives keine formale 60-s-Transit-Auswertung; dieser Punkt wird nicht rückwirkend als PASS behauptet.

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

## Erwartete Kernmarker bei einem zukünftigen 3R1-Regressionslauf

```text
POLICY_PASS x6
SUBMIT_PASS x6
TEMPLATE_IDENTITY_PASS x6
CALLSIGN_IDENTITY_PASS x6
SEED_FUEL_PASS x6
SOURCE_SPACING_PASS x4
TRANSIT_PROGRESS_PASS x6
INTEGRATION_PASS ... artificialFuelLow=false fullTrackArrivalRequired=false
```

Ein solcher erneuter Lauf ist **nicht** allein wegen der Harness-Korrektur vorgesehen.

## Source / Builder / Dist

```text
scripts/air-operations/OMW_AAR_Controller.lua
mission/tests/aar-production-integration/src/01-aar-production-integration.lua
tools/build-aar-production-integration.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Integration.lua
```

`dist/` ist ausschließlich builder-generiert.