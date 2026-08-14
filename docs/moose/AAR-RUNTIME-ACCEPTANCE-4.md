---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-4
status: HISTORICAL_TEST_FIXTURE
document_class: TECHNICAL_ACCEPTANCE_REPORT
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-run Acceptance-4 AAR runtime evidence
  - DCS-runtime Y-band tanker TACAN for CLANCY and NELSON
  - gate-to-track materialization heading for acceptance tankers
  - Bagram F-16 AI Boom refueling proof
  - Acceptance-4 Bagram F-16 receiver mission-range override
not_authoritative_for:
  - complete production tanker speed matrix
  - final area-specific FAST/SLOW altitude assignments
  - production MissionDemand/CampaignState activation logic
  - final Nelson ingress/egress gate
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-3
superseded_by:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-5
source_branch: agent/aar-rc-east-runtime-scope
source_commit: a71644a3117cb3ca59cb86d3d5252386d22c0e67
validated_in_dcs: partial
---

# AAR Runtime Acceptance-4 – Owner-Run Ergebnis

## 1. Provenienz

```text
Testdatum: 2026-08-14
Branch: agent/aar-rc-east-runtime-scope
Commit: a71644a3117cb3ca59cb86d3d5252386d22c0e67
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Source SHA-256: b558a0d234689bdeb16dea937bf380fecd2331efa0f44cff9f6553c36355768c
Builder SHA-256: bce0789debe9a386197df4335738577c732c3eaf9773b4243f180d07ceae935c
Bundle SHA-256: 1bcb27833a18a87828886d922ebda7152589f4817f1c7b9ad9b55f3e1581ad8d
```

## 2. Getestete Runtime-Konfiguration

```text
CLANCY / Shell 1
Gate: N28.90264890 E64.61166667
Track: N31.75441342 E66.82695501
Orbit: FL225 / 220 KIAS / 225.276 deg / 35 NM
Radio: 241.600 AM
DCS runtime TACAN: 60Y / CLA

NELSON / Texaco 1
Gate: N37.64268794 E70.96231552
Track: N36.37666667 E71.01833333
Orbit: FL275 / 300 KIAS / 10.428 deg / 35 NM
Radio: 384.400 AM
DCS runtime TACAN: 47Y / NEL
```

## 3. MOOSE-First-Nachweis

Verwendete, im gepinnten `Moose.lua` geprüfte öffentliche Pfade:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetRadio(...)
AUFTRAG:SetTACAN(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:SetMissionRange(...)
AUFTRAG:CountOpsGroups()
COHORT:CanMission(...)
COORDINATE:HeadingTo(...)
SPAWN:InitHeading(...)
SPAWN:SpawnFromCoordinate(...)
AIRWING:AddMission(...)
AIRWING:OnAfterFlightOnMission(...)
FLIGHTGROUP:IsAirborne()
FLIGHTGROUP:Refuel(...)
FLIGHTGROUP:OnAfterRefueled(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
OPSGROUP:Despawn(...)
```

Kein MIST, kein paralleler Native-DCS-Tankercontroller, kein neues Mission-Editor-Receiver-Template und keine automatisierte `.miz`-Mutation.

## 4. Bestätigte Ergebnisse

### 4.1 Tanker-Materialisierung und Heading

Beide KC-135 materialisierten und erreichten `AUFTRAG:TANKER -> EXECUTING`.

Nelson materialisierte nach der `COORDINATE:HeadingTo() -> SPAWN:InitHeading()`-Korrektur sichtbar in Richtung seines südlich gelegenen Tracks. Der frühere nordwärts gerichtete Acceptance-3-Spawn ist damit für den dokumentierten Scope korrigiert.

### 4.2 Y-Band-A/A-TACAN

Der Projektinhaber bestätigte anschließend im F-16-Cockpit per Bildbeweis beide DCS-Runtime-Beacons:

```text
CLANCY / Shell 1
60Y
Ident CLA
Bearing/DME usable

NELSON / Texaco 1
47Y
Ident NEL
Bearing/DME usable
```

Damit ist der DCS-Runtime-Y-Band-Pfad für diese beiden Acceptance-Exemplare praktisch bestätigt. Die historischen/planerischen X-Band-Angaben bleiben als Quelldaten erhalten, sind aber nicht die verwendete DCS-Runtime-Konfiguration.

### 4.3 Tankergeschwindigkeiten

Der Projektinhaber bestätigte die unterschiedlichen Orbitgeschwindigkeiten visuell/per F10-Beobachtung:

```text
CLANCY: 220 KIAS
NELSON: 300 KIAS
```

220 KIAS ist damit als funktionierender KC-135-Runtime-Wert bestätigt. Der Projektinhaber beobachtete zugleich, dass F-16 bei diesem langsamen Tankerprofil einen deutlich hohen Anstellwinkel benötigen. Das stützt die getrennte OMW-Planung von SLOW- und FAST-Tankerprofilen, ist aber noch kein A-10-AAR-Nachweis.

### 4.4 Bagram F-16 AI Boom

Der Test-AUFTRAG erhielt ausschließlich für Acceptance-4:

```lua
mission:SetMissionRange(250)
```

Danach wurde der bestehende Bagram-F-16-Pfad tatsächlich rekrutiert und materialisiert:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Der Projektinhaber beobachtete beide F-16 visuell am Boom. Lead blieb länger am Boom als Follow.

Die Runtime-Telemetrie bestätigte zusätzlich einen plausiblen realen Fuel-Anstieg:

```text
fuelBeforePct=82.85
fuelAfterPct=99.96
```

Damit ist der dokumentierte MOOSE-`FLIGHTGROUP:Refuel()`-Pfad bis zum tatsächlichen DCS-Boom-Transfer für diesen Acceptance-Scope bestätigt.

## 5. Offene/negative Befunde

### 5.1 Nelson-Gate weiterhin ungeeignet

Der Acceptance-4-Gatepunkt

```text
N37.64268794 E70.96231552
```

liegt nach visueller F10-Prüfung noch deutlich innerhalb des nordöstlichen Afghanistan-Zipfels und wird verworfen.

Historische/geografische Reconciliation:

```text
Northern tanker origin: MANAS / Kyrgyzstan
Transit region: Tajikistan
Kabul FIR entry reference: EGPAN
EGPAN: N38°25'00" E070°44'00"
High airway reference: M881
Low airway reference: V876
```

Für Acceptance-5 wird ein vorgelagerter Materialisierungspunkt etwa 50 km NNE von EGPAN in Tajikistan verwendet.

### 5.2 Post-Refuel-FuelLow zu aggressiv

Acceptance-4 schaltete unmittelbar nach dem ersten `OnAfterRefueled`-Event den künstlichen 99-%-FuelLow-Trigger scharf. Der Projektinhaber beobachtete zwar beide F-16 am Boom, aber der Wingman war kürzer angeschlossen. Es ist nicht bewiesen, dass der frühe Test-Trigger die Ursache war; der Harness erzeugte dafür jedoch eine unnötig enge zeitliche Kopplung.

Acceptance-5 führt deshalb nach dem ersten dokumentierten Refuel-Abschluss einen 60-s-Post-Refuel-Dwell als reinen Acceptance-Testwert ein, bevor der beschleunigte FuelLow-Pfad aktiviert wird.

## 6. FAST-/SLOW-Dual-Tanker-Regel

Für zwei unabhängig arbeitende Tanker in derselben AAR-Area gilt weiterhin:

```text
SLOW tanker
-> lower orbit
-> A-10 / slow-receiver focus
-> approximately 220 KIAS acceptance reference

FAST tanker
-> upper orbit
-> F-15 / F-16 / fast-receiver focus
-> approximately 300-315 KIAS planning range

minimum vertical tanker-to-tanker separation:
3,000 ft
```

Die konkrete Höhe bleibt area-spezifisch und muss innerhalb des AAR-Blocks sowie oberhalb der Safety Altitude liegen. Die MOOSE-interne 1.000-ft-Slotstaffelung aus `AIRWING:CheckTANKER()` ist nicht die OMW-Mindeststaffelung für unabhängige FAST-/SLOW-Tanker.

## 7. Ergebnisgrenze

Acceptance-4 bestätigt für den exakten oben dokumentierten Stand:

```text
PASS:
- CLANCY/NELSON materialization
- corrected initial heading
- AUFTRAG:TANKER execution
- CLANCY 220-KIAS runtime
- NELSON 300-KIAS runtime
- CLANCY 60Y / CLA TACAN
- NELSON 47Y / NEL TACAN
- Bagram F-16 AIRWING recruitment with test-only 250-NM mission range
- 2-ship F-16 materialization
- both F-16 visually observed at Boom
- plausible Boom fuel transfer telemetry
- FuelLow -> Cancel -> Egress -> gate handoff path

FAIL / superseded for next test:
- Acceptance-4 Nelson gate location
- immediate post-refuel accelerated FuelLow sequencing

OPEN:
- practical A-10 receiver test at SLOW tanker
- simultaneous FAST/SLOW dual-tanker acceptance in one area
- deterministic receiver -> correct FAST/SLOW tanker assignment
- production MissionDemand/CampaignState activation logic
```

`validated_in_dcs: partial` bleibt absichtlich bestehen; nur der explizit oben dokumentierte Teilumfang ist praktisch bestätigt.
