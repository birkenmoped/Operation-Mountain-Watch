---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-3
status: HISTORICAL_TEST_FIXTURE
document_class: TECHNICAL_ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - observed runtime findings of AAR-KC135-RUNTIME-ACCEPTANCE-3
  - existing Bagram F-16C AI Boom receiver attempt in this acceptance
  - owner-observed TACAN and spawn-heading defects in this acceptance
not_authoritative_for:
  - final production MissionDemand/CampaignState activation logic
  - corrected A/A TACAN band for successor acceptance
  - corrected tanker materialization heading for successor acceptance
  - final tanker speed matrix
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-4
source_branch: agent/aar-rc-east-runtime-scope
source_commit: 1a4fc11b7a1ac9c8b8195a0bc390efba91e064ed
validated_in_dcs: false
---

# AAR Runtime Acceptance-3 – Ergebnis

## 1. Teststand

Der Owner-Lauf am 14.08.2026 wurde mit folgendem dokumentierten Quellstand vorbereitet:

```text
Branch: agent/aar-rc-east-runtime-scope
Commit: 1a4fc11b7a1ac9c8b8195a0bc390efba91e064ed
Test-ID: AAR-KC135-RUNTIME-ACCEPTANCE-3
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
```

Der Lauf verwendete die bereits genehmigten verlegten Gate-Kandidaten:

```text
OMW_TANKER_GATE_S  = N28.90264890 E64.61166667
OMW_TANKER_GATE_NE = N37.64268794 E70.96231552
```

Clancy und Nelson materialisierten gleichzeitig, weil sie verschiedenen Gate-Domänen angehören. Die produktive Regel von mindestens 60 Sekunden Abstand innerhalb derselben Gate-/Runtime-Domäne blieb unverändert.

## 2. Bestätigte Teilbefunde

Die Logauswertung bestätigt für den Acceptance-3-Lauf:

- `TANKER_START_PASS` für Clancy und Nelson an den verlegten Gate-Kandidaten;
- plausible verzögerte Seed-Fuel-Werte für 90 % beziehungsweise 96 %;
- Nelson erreichte `AUFTRAG:TANKER -> EXECUTING`;
- Clancy erreichte `AUFTRAG:TANKER -> EXECUTING`;
- der vorhandene Bagram-F-16C-AIRWING-/SQUADRON-Pfad war vorhanden und die Testmission wurde mit `RECEIVER_MISSION_ADDED_PASS` in den AIRWING gegeben;
- Texaco 1-1 antwortete bei der manuellen Prüfung auf 384.400 MHz AM.

Diese Befunde sind nur für den exakt getesteten Acceptance-3-Stand belastbar.

## 3. TACAN – Acceptance-3 fehlgeschlagen

Acceptance-3 konfigurierte die Air-to-Air-Tankerbeacons explizit als:

```text
CLANCY 60X / CLA
NELSON 47X / NEL
```

Der Projektinhaber konnte Texaco 1-1 auf 384.400 MHz ansprechen, erhielt jedoch auf 47X keinen TACAN-Ausschlag und kein nutzbares Tanker-TACAN.

Die anschließende MOOSE-First-Quellprüfung des tatsächlich gepinnten `Moose.lua` zeigt:

- `AUFTRAG:SetTACAN(Channel, Morse, UnitName, Band)` dokumentiert für Aircraft den Y-Band-Pfad als Standard;
- die MOOSE-`RECOVERYTANKER`-Dokumentation des gleichen Quellstands erklärt ausdrücklich, dass Air-to-Air-Tanker-TACAN im Y-Band betrieben werden soll und X für diesen Pfad nicht funktioniert;
- `BEACON:AATACAN()` dokumentiert ebenfalls Y als Air-to-Air-TACAN-Band.

Damit ist 47X/60X als DCS-Runtime-Konfiguration für die OMW-KC-135 nicht weiterzuverwenden. Die ursprünglichen X-Kanalwerte bleiben als Quellen-/Planungsdaten erhalten; der DCS-Runtime-Pfad wird davon getrennt.

## 4. Materialisierungsheading – Acceptance-3 fehlerhaft

Der Acceptance-3-Harness spawnte die Tanker mit:

```lua
SPAWN:New(spec.template):SpawnFromCoordinate(gateCoord)
```

Damit wurde kein Runtime-Heading gesetzt. Der Projektinhaber beobachtete insbesondere Texaco 1-1 am Nordost-Gate mit nördlicher Anfangsausrichtung, obwohl der Track südlich des Gate-Kandidaten liegt.

Im gepinnten MOOSE-Stand sind `COORDINATE:HeadingTo()` und `SPAWN:InitHeading()` vorhanden. Der Nachfolger setzt deshalb die Anfangsausrichtung aus Gate -> Track vor `SpawnFromCoordinate()`.

## 5. Tankergeschwindigkeit – Acceptance-3 nicht geeignet für A-10

Acceptance-3 setzte beide Tanker pauschal auf:

```text
CLANCY 300 KIAS
NELSON 300 KIAS
```

`AUFTRAG:NewTANKER()` dokumentiert den Speed-Parameter im gepinnten MOOSE-Stand als indicated airspeed in knots am gesetzten Orbit-Level.

Für A-10/KC-135 existiert eine periodennahe offizielle USAF-Typreferenz: Bei einer A-10-Refueling-Mission im Jahr 2008 hielt die KC-135 ungefähr 220 kt, um die A-10 sicher zu betanken. Für OMW wird daraus kein universeller KC-135-Speed abgeleitet. Für den Kandahar/RC-East-Zugang Clancy wird im Nachfolger jedoch 220 KIAS als gezielter A-10-kompatibler Acceptance-Wert verwendet. Nelson bleibt zunächst bei 300 KIAS als Fast-Jet-/Nord-Exemplar, bis eine vollständige receiverbezogene Speed-Matrix fachlich festgelegt und in DCS geprüft ist.

## 6. AI-Boom-Receiver – noch nicht nachgewiesen

Die Testmission für den vorhandenen Bagram-Pfad wurde erfolgreich in den AIRWING gegeben:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Im beobachteten Lauf blieb der Harness jedoch bei:

```text
receiverAssigned=false
receiverAirborne=false
refuelOrdered=false
refueled=false
fuelLowArmed=false
```

Damit wurde kein F-16C für diesen Acceptance-Auftrag materialisiert beziehungsweise an den Harness übergeben. Die Ursache ist durch Acceptance-3 nicht belegt und wird nicht geraten. Der Boom-Transfer bleibt offen. Acceptance-4 ergänzt deshalb zumindest die öffentliche MOOSE-Telemetrie `AUFTRAG:CountOpsGroups()` zur besseren Trennung zwischen Missionsqueue und tatsächlich zugeordneten OPSGROUPs; eine weitergehende Receiver-Architekturänderung erfolgt erst nach belastbarer Ursachenanalyse.

## 7. Bewertung

```text
Relocated tanker gates / materialization: PARTIAL PASS
Tanker mission -> EXECUTING: PASS for CLANCY and NELSON
NELSON radio 384.400 AM: MANUAL PASS
NELSON TACAN 47X: MANUAL FAIL
Spawn initial heading toward track: FAIL
Uniform 300 KIAS suitability for A-10: REJECTED FOR CLANCY
AI F-16 assignment: NOT PROVEN
AI Boom refueling: NOT TESTED
Post-refuel FuelLow/Egress in this run: NOT REACHED
Overall Acceptance-3: NOT ACCEPTED
```

Acceptance-3 ist deshalb kein `VALIDATED`-Stand. Die Korrekturen werden in `OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-4` isoliert weitergeführt.
