---
document_id: OMW-AAR-ACCEPTANCE-7-FINALIZATION
status: BINDING_PROJECT_DECISION
document_class: ACCEPTANCE_DERIVED_DESIGN_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - final accepted AAR calibration after corrected Acceptance 7
  - production-facing source domains, FIR fixes, transit levels, initial fuel and FuelLow thresholds
  - accepted inbound 60-NM routing sequence and outbound egress sequence
  - AAR lifecycle timing and production/test separation
supersedes:
  - Acceptance-7-pending and candidate wording in docs/29-isaf-2009-2013-air-to-air-refueling.md
  - branch-local pre-Acceptance values in mission/tests/aar-fuel-telemetry/LRC-CANDIDATE.md
  - branch-local pre-Acceptance values in mission/tests/aar-fuel-telemetry/POST-MERGE-FINDINGS.md
  - branch-local pre-Acceptance worklist state in mission/tests/aar-fuel-telemetry/TODO.md
superseded_by:
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/aar-fuel-telemetry-calibration
source_commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
validated_in_dcs: true
---

# 73 – AAR Acceptance 7 Finalisierung

## 1. Zweck und Autoritätsgrenze

Dieses Dokument bindet den nach dem korrigierten Acceptance-7-Lauf akzeptierten AAR-Stand für OMW. Ältere `CANDIDATE`, `PENDING`, `SOURCE_REVIEWED` oder vorläufige Werte aus dem AAR-Kalibrierungsworkstream bleiben als historische Evidenz erhalten, sind für den hier geregelten Scope aber durch dieses Dokument superseded.

Die technische Testprovenienz steht vollständig in:

- `mission/tests/aar-production-integration/ACCEPTANCE-7.md`
- `docs/moose/AAR-LRC-TRANSIT.md`
- `docs/moose/VERIFIED-METHODS-AAR-ACCEPTANCE-7.md`

Die Runtime-Implementierung wird erst mit dem vorbereiteten Feature-Branch-Merge Bestandteil von `main`. Die hier dokumentierten Entscheidungen und Acceptance-Ergebnisse sind davon unabhängig bereits verbindlich dokumentiert.

## 2. Exakte Acceptance-Provenienz

```text
Testdatum: 2026-08-16
Branch: agent/aar-fuel-telemetry-calibration
Accepted source commit: 7d55a1383cbf3f52ea776d7354b37dbe5a920466
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-7
DCS: 2.9.28.26385 MT

Mission artifact: OMW_Template_v10_AirOps_rdy(5).miz
Mission SHA-256: 16d0a9b26a648c2dbcbd727b41afc93a28648620f8e2f8c357a770751e48cca5
Bundle SHA-256: 3338d0baa67593be6bff9c22b3ed72b3a8e837cd00820d060eefe920faf91ee2
Controller SHA-256: 547f0336b954b116e43e8a09ca0f001d893ea81d2394025891be5ff078388438
Builder SHA-256: 6ab1432a2b136b6b7c92646520f9407da35f3892c968346dd2ae52b7ada695a3
Validator SHA-256: 52aee90fc4273bc89eb96519f83830f0367f8da915889eefaf77f985f6e88b4f
LateApproach SHA-256: beb236e7abaaa4b988c7e603f94dc8771e5754c2513540a3015fad91a880477f
dcs.log SHA-256: 3157bc87a373f5b55262bf96c6be1cf52f06686bfa6daefd576fc23f88d9e320
debrief.log SHA-256: 66c4fed82e91045ef4ffbc08989dce6cfabf97375ea7faf225e2601ad826a0d4

MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

Result: PASS
```

## 3. Finales operatives Kernnetz

| Area | Profil | Verfügbarkeit | Source | FIR Fix | Initial Fuel | FuelLow |
|---|---|---|---|---|---:|---:|
| NELSON | FAST | STANDARD | MANAS | EGPAN | 91.4067 % | 24 % |
| PATTY | SLOW | STANDARD | MANAS | EGPAN | 91.4067 % | 26 % |
| MILHOUSE | SLOW | STANDARD | AL_UDEID | DAVER | 79.4558 % | 36 % |
| KRUSTY | SLOW | STANDARD | AL_UDEID | DAVER | 79.4558 % | 36 % |
| LISA | FAST | RESERVE | AL_UDEID | DAVER | 79.4558 % | 38 % |
| MOE | FAST | RESERVE | MANAS | PINAX | 91.4067 % | 31 % |

STANDARD läuft bis zu einer später genehmigten ATO-/Zeitfensterregel kontinuierlich. LISA und MOE starten nicht automatisch und werden ausschließlich durch passenden MissionDemand geöffnet.

## 4. Inbound- und Outbound-Routing

### Inbound

```text
EXTERNAL SPAWN
-> FIR INGRESS
-> 60-NM LATE APPROACH
-> TRACK START
-> AAR TRACK
```

Die festgelegte inbound LRC-/Transferhöhe wird bis einschließlich 60-NM-Punkt gehalten. Der Tanker-AUFTRAG wird erst nach realer `PassingWaypoint`-Bestätigung dieses Punktes hinzugefügt.

Technische Reihenfolge:

```text
FLIGHTGROUP:AddWaypoint(FIR)
-> FLIGHTGROUP:AddWaypoint(60NM)
-> PassingWaypoint(FIR)
-> PassingWaypoint(60NM)
-> FLIGHTGROUP:AddMission(AUFTRAG)
-> exact track altitude
```

`AUFTRAG:SetMissionIngressCoord(lateApproachCoord, ...)` ist für den finalen Inbound-Pfad verworfen.

### Outbound

```text
TRACK ABORT/DEPARTURE
-> FIR EGRESS
-> EXTERNAL HANDOFF / DESPAWN
```

Die outbound LRC-/Transferhöhe wird ab Missionsabbruch beziehungsweise Verlassen der Tankermission angefordert.

## 5. 60-NM-Geometrie

Acceptance-7 Runtime-Geometrie:

| Area | FIR->60NM | 60NM->Track | FIR->Track |
|---|---:|---:|---:|
| NELSON | 63.7 NM | 60.0 NM | 123.7 NM |
| PATTY | 150.8 NM | 60.0 NM | 210.8 NM |
| MILHOUSE | 175.2 NM | 60.0 NM | 235.2 NM |
| KRUSTY | 197.5 NM | 60.0 NM | 257.5 NM |
| LISA | 225.6 NM | 60.0 NM | 285.6 NM |
| MOE | 165.2 NM | 60.0 NM | 225.2 NM |

LISA wurde aus Reaktionszeitgründen von MANAS/PINAX nach AL_UDEID/DAVER verschoben. Die alte PINAX->LISA-Strecke lag bei etwa 416.8 NM; die neue akzeptierte DAVER->LISA-FIR-Track-Geometrie liegt bei etwa 285.6 NM. Die sichtbare Reserve-Reaktionsstrecke verkürzt sich damit um rund 131 NM. Das ist keine Fuel-Optimierungsentscheidung.

## 6. Geschwindigkeit und Höhen

```text
SPAWN initialization: 480 kt
Transit route:        300 kt

MANAS -> Afghanistan:     FL340
Afghanistan -> MANAS:     FL350
AL_UDEID -> Afghanistan:  FL350
Afghanistan -> AL_UDEID:  FL340
```

Kein routinemäßiger Step-Climb. Die Track-Höhe wird mit `AUFTRAG:SetMissionAltitude(profile.altitudeFt)` exakt gesetzt.

## 7. Fuel-Berechnungsbasis

### 7.1 Grunddaten

```text
KC-135 max fuel used by OMW model: 90,700 kg
13,000 lb planned landing floor: about 5,896.7 kg = 6.5013 %
```

Die 45-Minuten-Reserve liegt für alle sechs Profile über dem 13,000-lb-Floor und ist die kontrollierende Reservekomponente.

### 7.2 Virtuelle Source-Base->External-Spawn-Strecken

```text
MANAS:
300.005 NM * 25.98 kg/NM
= about 7,794 kg
= 8.5933 % virtual burn
=> 91.4067 % initial fuel at External Spawn

AL_UDEID:
746.241 NM * 24.97 kg/NM
= about 18,633 kg
= 20.5443 % virtual burn
=> 79.4558 % initial fuel at External Spawn
```

Die physische Template-Fuel-Menge wird im Mission Editor gesetzt. Eine öffentliche MOOSE-`SPAWN:InitFuel(...)`-API wurde im gepinnten Stand nicht nachgewiesen.

### 7.3 45-Minuten-Reserve

```text
NELSON    9.5482 %
PATTY     7.9209 %
LISA      7.6182 %
MOE       8.4708 %
MILHOUSE  6.6748 %
KRUSTY    6.6384 %
```

### 7.4 Candidate-5 Track-Departure->External-Handoff-Burn

```text
NELSON     5.6753 %
PATTY      9.0161 %
LISA old  17.7909 %  [old MANAS/PINAX geometry only]
MOE       13.4644 %
MILHOUSE   8.1344 %
KRUSTY     8.5073 %
```

### 7.5 FuelLow-Rechnung

```text
FuelLow raw =
  measured TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtual EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve
```

```text
NELSON:    5.6753 +  8.5933 + 9.5482 = 23.8168 -> 24 %
PATTY:     9.0161 +  8.5933 + 7.9209 = 25.5303 -> 26 %
MOE:      13.4644 +  8.5933 + 8.4708 = 30.5285 -> 31 %
MILHOUSE:  8.1344 + 20.5443 + 6.6748 = 35.3535 -> 36 %
KRUSTY:    8.5073 + 20.5443 + 6.6384 = 35.6900 -> 36 %
```

LISA = 38 % ist die akzeptierte konservative Neuberechnung für AL_UDEID/DAVER. Der alte 17.7909-%-Burn ist nicht übertragbar. Ein separater südlicher LISA-`TRACK_DEPARTURE -> EXTERNAL_HANDOFF`-Messlauf existiert nicht; Acceptance 7 bestätigt den 38-%-Vertrag im Gesamt-Lifecycle, nicht einen separaten südlichen Burn-Messwert.

## 8. Timing und Lifecycle

```text
Same-source spawn spacing: >= 60 s
Dispatcher interval:        5 s
Station monitor interval:   5 s
Planned station cycle:      10,800 s = 3 h
Relief ETA arm gate:        300 s = 5 min
FIR radius:                 5 NM
Track-entry radius:         5 NM
External-handoff radius:    10 NM
Per-track maximum:          1 ACTIVE + 1 RELIEF
```

MANAS und AL_UDEID dürfen parallel materialisieren.

Scheduled Relief:

```text
ACTIVE -> one RELIEF
ETA <= 5 min -> handover armed only
outgoing remains station owner
real track arrival -> ownership/radio/TACAN transfer
outgoing -> Cancel/Egress
```

FuelLow:

```text
ACTIVE FuelLow
-> reuse existing relief or create exactly one relief
-> outgoing station identity off + immediate egress
-> replacement takes station only after natural track arrival
```

Loss:

```text
confirmed loss
-> no aircraft recredit
-> AIRCRAFT_KC135_LOST audit increment exact-once
-> replacement according to still-open track state
```

## 9. CampaignState-Ressourcenhoheit

```text
OFFMAP_MANAS:    AIRCRAFT_KC135 = 16
OFFMAP_AL_UDEID: AIRCRAFT_KC135 = 40
```

```text
materialization -> consume 1 AIRCRAFT_KC135
external handoff -> exact-once recredit 1 AIRCRAFT_KC135
loss -> no recredit; exact-once loss audit
```

CampaignState bleibt alleinige strategische Autorität. MOOSE-Gruppen sind physische Repräsentationen.

## 10. Acceptance-7 bestätigte Gates

```text
AAR_POLICY_BASELINE_PASS
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS MANAS=16 AL_UDEID=40
STANDARD_TRACKS_4_PASS initialAircraft=4 reserveAircraft=0
natural FIR ingress
FIR before 60-NM before AUFTRAG ordering
high LRC hold through 60-NM point
exact track altitude
MILHOUSE scheduled relief
NELSON FuelLow relief
LISA demand -> AL_UDEID/DAVER
MOE demand -> MANAS/PINAX
reserve demand lifecycle
PATTY intentional test loss -> natural replacement
external handoff / exact-once settlement
FINAL_STEADY_STATE_PASS standardTracks=4 reserveTracks=0 supportAircraft=4
RESULT PASS
```

Nach dem offiziellen PASS trat zusätzlich ein natürlicher KRUSTY-FuelLow auf und löste korrekt Relief und Egress aus.

## 11. Test-only vs. produktiv

Acceptance-only:

```text
accelerated selected scheduled relief timing
background scheduled-relief isolation
artificial NELSON FuelLow trigger
intentional PATTY UNIT:Explode() loss
in-process CampaignState Snapshot/Restore exercise
```

Produktives Missionsgrundgerüst:

```text
STANDARD auto-start/continuous:
NELSON / PATTY / MILHOUSE / KRUSTY

RESERVE default inactive / MissionDemand-only:
LISA / MOE

real runtime triggers only:
actual FuelLow
normal planned/scheduled relief
actual aircraft loss
MissionDemand open/close
```

Keine künstliche Verlustinjektion, kein vorgetriggerter FuelLow-Status und keine Acceptance-Zeitbeschleunigung.

## 12. Merge-Grenze

Der akzeptierte Stand ist eine `ACCEPTED_TECHNICAL_BASELINE` für die exakte oben dokumentierte Provenienz. Der Feature-Branch wird separat nach `main` integriert. Erst danach wird das produktive AAR-Missionsgrundgerüst ohne Acceptance-Testinstrumentierung gebaut und erneut per Build/Hash sowie DCS-Sanity-/Acceptance-Lauf geprüft.
